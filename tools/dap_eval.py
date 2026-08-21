#!/usr/bin/env python3
"""
Console Lua remoto no processo do Jagged Alliance 3, via o debug adapter (DAP)
que o JA3Debug.exe serve em 127.0.0.1:8165.

Uso:
    python tools/dap_eval.py "tostring(g_Combat ~= nil)"
    python tools/dap_eval.py -f trecho.lua
    echo "return 1+1" | python tools/dap_eval.py -

Varias expressoes numa chamada so (uma conexao, avaliadas em ordem):
    python tools/dap_eval.py "expr1" "expr2" "expr3"

O adapter anexa um dump de metatable ao resultado de strings; --raw mostra o
resultado cru, sem essa limpeza.
"""

import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dap_probe import DapClient  # noqa: E402


def clean_result(text, raw):
    if raw or not isinstance(text, str):
        return text
    # o inspetor do adapter anexa "{\n\tmetatable = table: 0x... [n]\n}" ao valor
    return re.sub(r"\s*\{\s*metatable = table: [0-9A-Fa-f]+ \[\d+\]\s*\}\s*$", "", text)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("exprs", nargs="*", help='expressoes Lua; "-" le do stdin')
    ap.add_argument("-f", "--file", action="append", default=[],
                    help="arquivo .lua para avaliar como um bloco unico")
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8165)
    ap.add_argument("--timeout", type=float, default=10.0)
    ap.add_argument("--raw", action="store_true", help="nao limpa o dump de metatable")
    ap.add_argument("--quiet", action="store_true", help="so o resultado, sem cabecalho")
    ap.add_argument("-c", "--chunk", action="store_true",
                    help="envolve o codigo num IIFE -- o adapter faz `return <expr>`, "
                         "entao statements soltos nao compilam sem isso")
    args = ap.parse_args()

    chunks = []
    for path in args.file:
        with open(path, encoding="utf-8") as fh:
            chunks.append(fh.read())
    for expr in args.exprs:
        if expr == "-":
            chunks.append(sys.stdin.read())
        else:
            chunks.append(expr)

    if not chunks:
        ap.error("nada para avaliar")

    client = DapClient(args.host, args.port, args.timeout)
    # o DapClient loga tudo; aqui queremos saida limpa
    client.log_msg = lambda direction, msg: None
    client.log_meta = lambda text: None

    failures = 0
    try:
        client.connect()
    except OSError as exc:
        print("FALHA ao conectar em %s:%d -- o jogo esta aberto? %s"
              % (args.host, args.port, exc), file=sys.stderr)
        return 2

    try:
        seq = client.request("initialize", {
            "clientID": "dap_eval", "adapterID": "solengine",
            "linesStartAt1": True, "columnsStartAt1": True, "pathFormat": "path",
            "supportsRunInTerminalRequest": False,
        })
        if client.wait_response(seq) is None:
            print("FALHA: sem resposta ao initialize", file=sys.stderr)
            return 2

        seq = client.request("attach", {
            "type": "solengine", "request": "attach",
            "address": args.host, "debugServer": args.port,
        })
        client.wait_response(seq)
        client.drain(0.3)

        for i, chunk in enumerate(chunks):
            expr = chunk
            if args.chunk:
                expr = "(function() " + chunk + " end)()"
            seq = client.request("evaluate", {"expression": expr, "context": "repl"})
            resp = client.wait_response(seq)

            if not args.quiet and len(chunks) > 1:
                head = chunk.strip().splitlines()[0] if chunk.strip() else ""
                print("--- [%d] %s" % (i + 1, head[:90]))

            if resp is None:
                print("<TIMEOUT>", file=sys.stderr)
                failures += 1
                continue
            if not resp.get("success"):
                print("<ERRO> %s" % resp.get("message"), file=sys.stderr)
                failures += 1
                continue
            body = resp.get("body") or {}
            print(clean_result(body.get("result"), args.raw))
    finally:
        try:
            if client.sock is not None:
                seq = client.request("disconnect",
                                     {"terminateDebuggee": False, "restart": False})
                client.wait_response(seq, timeout=2.0)
        except OSError:
            pass
        client.close()

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())

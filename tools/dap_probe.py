#!/usr/bin/env python3
"""
Sonda DAP para o debug adapter do Jagged Alliance 3 (SolEngine).

Hipotese: o proprio executavel do jogo serve Debug Adapter Protocol em TCP
127.0.0.1:8165 (o package.json da extensao SolEngineLua usa `debugServer`, que no
VS Code significa "conecte na porta, nao lance um adapter").

Somente leitura: nao coloca breakpoint, nao altera arquivo nenhum, e sempre manda
`disconnect` com terminateDebuggee=false, inclusive em caminho de erro.

Uso:
    python tools/dap_probe.py [--host 127.0.0.1] [--port 8165] [--timeout 3.0]
"""

import argparse
import json
import socket
import sys
import time


class DapError(Exception):
    pass


class DapClient:
    def __init__(self, host, port, timeout):
        self.host = host
        self.port = port
        self.timeout = timeout
        self.sock = None
        self.buf = b""
        self.seq = 0
        self.trace = []          # tudo que entrou ou saiu, em ordem
        self.unsolicited = []    # events / mensagens que chegaram sem ser pedidas

    # ---------------------------------------------------------------- transporte

    def connect(self):
        self.log_meta("connect %s:%d (timeout %.1fs)" % (self.host, self.port, self.timeout))
        self.sock = socket.create_connection((self.host, self.port), timeout=self.timeout)
        self.sock.settimeout(0.25)

    def close(self):
        if self.sock is not None:
            try:
                self.sock.close()
            except OSError:
                pass
            self.sock = None

    def log_meta(self, text):
        self.trace.append(("meta", text))
        print("[meta] %s" % text, flush=True)

    def log_msg(self, direction, msg):
        self.trace.append((direction, msg))
        arrow = "-->" if direction == "sent" else "<--"
        print("%s %s" % (arrow, json.dumps(msg, ensure_ascii=False)), flush=True)

    def send(self, msg):
        body = json.dumps(msg, ensure_ascii=False).encode("utf-8")
        header = ("Content-Length: %d\r\n\r\n" % len(body)).encode("ascii")
        self.sock.sendall(header + body)
        self.log_msg("sent", msg)

    def request(self, command, arguments=None):
        self.seq += 1
        msg = {"seq": self.seq, "type": "request", "command": command}
        if arguments is not None:
            msg["arguments"] = arguments
        self.send(msg)
        return self.seq

    def _parse_buffered(self):
        """Tenta extrair uma mensagem completa do buffer. None se ainda nao da."""
        idx = self.buf.find(b"\r\n\r\n")
        if idx == -1:
            return None
        header = self.buf[:idx].decode("ascii", "replace")
        length = None
        for line in header.split("\r\n"):
            if line.lower().startswith("content-length:"):
                try:
                    length = int(line.split(":", 1)[1].strip())
                except ValueError:
                    pass
        if length is None:
            # framing invalido: descarta o cabecalho e segue, mas registra
            self.log_meta("cabecalho sem Content-Length, descartado: %r" % header)
            self.buf = self.buf[idx + 4:]
            return self._parse_buffered()
        total = idx + 4 + length
        if len(self.buf) < total:
            return None
        body = self.buf[idx + 4:total]
        self.buf = self.buf[total:]
        try:
            return json.loads(body.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            self.log_meta("corpo nao e JSON valido (%s): %r" % (exc, body[:400]))
            return {"_raw": body.decode("utf-8", "replace")}

    def read_message(self, deadline):
        """Le UMA mensagem. None em timeout ou conexao fechada."""
        while True:
            msg = self._parse_buffered()
            if msg is not None:
                self.log_msg("recv", msg)
                return msg
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return None
            self.sock.settimeout(min(0.25, remaining))
            try:
                chunk = self.sock.recv(65536)
            except socket.timeout:
                continue
            except OSError as exc:
                self.log_meta("erro de socket na leitura: %s" % exc)
                return None
            if not chunk:
                self.log_meta("conexao fechada pelo outro lado")
                return None
            self.buf += chunk

    def wait_response(self, req_seq, timeout=None):
        """Le ate achar a response de req_seq. Guarda o resto em unsolicited."""
        deadline = time.monotonic() + (timeout if timeout is not None else self.timeout)
        while True:
            msg = self.read_message(deadline)
            if msg is None:
                return None
            if msg.get("type") == "response" and msg.get("request_seq") == req_seq:
                return msg
            self.unsolicited.append(msg)

    def drain(self, seconds):
        """Le o que chegar durante N segundos, sem esperar nada especifico."""
        deadline = time.monotonic() + seconds
        got = []
        while True:
            msg = self.read_message(deadline)
            if msg is None:
                break
            got.append(msg)
            self.unsolicited.append(msg)
        return got


# ------------------------------------------------------------------------- sonda


def summarize(label, resp):
    if resp is None:
        print("\n### %s -> TIMEOUT / sem resposta" % label, flush=True)
        return None
    ok = resp.get("success")
    print("\n### %s -> success=%s" % (label, ok), flush=True)
    if not ok:
        print("    message: %s" % resp.get("message"), flush=True)
    body = resp.get("body")
    if body is not None:
        print("    body: %s" % json.dumps(body, ensure_ascii=False, indent=2), flush=True)
    return body


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8165)
    ap.add_argument("--timeout", type=float, default=3.0)
    args = ap.parse_args()

    client = DapClient(args.host, args.port, args.timeout)
    results = {}

    try:
        client.connect()
    except OSError as exc:
        print("FALHA ao conectar: %s" % exc, flush=True)
        return 1

    try:
        # 1 --------------------------------------------------------- initialize
        seq = client.request("initialize", {
            "clientID": "probe",
            "clientName": "dap_probe",
            "adapterID": "solengine",
            "locale": "en-us",
            "linesStartAt1": True,
            "columnsStartAt1": True,
            "pathFormat": "path",
            "supportsVariableType": True,
            "supportsVariablePaging": False,
            "supportsRunInTerminalRequest": False,
            "supportsMemoryReferences": False,
            "supportsProgressReporting": False,
            "supportsInvalidatedEvent": False,
        })
        resp = client.wait_response(seq)
        results["initialize"] = summarize("initialize", resp)

        # 2 ------------------------------------------------------------- attach
        seq = client.request("attach", {
            "type": "solengine",
            "request": "attach",
            "name": "Attach to SolEngine",
            "address": args.host,
            "debugServer": args.port,
        })
        resp = client.wait_response(seq)
        results["attach"] = summarize("attach", resp)

        # 3 -------------------------------------- eventos espontaneos (initialized?)
        print("\n### drenando eventos por 1.5s", flush=True)
        client.drain(1.5)

        # 4 ------------------------------------------------------------ threads
        seq = client.request("threads")
        resp = client.wait_response(seq)
        results["threads"] = summarize("threads", resp)

        thread_id = None
        if resp and resp.get("success"):
            threads = (resp.get("body") or {}).get("threads") or []
            if threads:
                thread_id = threads[0].get("id")

        # 5 ------------------------------- evaluate SEM frameId, com o jogo solto
        for expr in ("tostring(_G ~= nil)",
                     "tostring(g_Combat ~= nil)",
                     "tostring(const and const.Scale and const.Scale.AP)"):
            seq = client.request("evaluate", {"expression": expr, "context": "repl"})
            resp = client.wait_response(seq)
            results["evaluate:" + expr] = summarize("evaluate(repl, sem frameId) %r" % expr, resp)

        # 6 ------------------------------------------------- stackTrace (read-only)
        if thread_id is not None:
            seq = client.request("stackTrace", {"threadId": thread_id,
                                                "startFrame": 0, "levels": 5})
            resp = client.wait_response(seq)
            results["stackTrace"] = summarize("stackTrace", resp)

            frame_id = None
            if resp and resp.get("success"):
                frames = (resp.get("body") or {}).get("stackFrames") or []
                if frames:
                    frame_id = frames[0].get("id")

            if frame_id is not None:
                seq = client.request("scopes", {"frameId": frame_id})
                resp = client.wait_response(seq)
                results["scopes"] = summarize("scopes", resp)

                scopes = (resp.get("body") or {}).get("scopes") if resp else None
                if scopes:
                    ref = scopes[0].get("variablesReference")
                    if ref:
                        seq = client.request("variables", {"variablesReference": ref})
                        resp = client.wait_response(seq)
                        results["variables"] = summarize("variables", resp)

                seq = client.request("evaluate", {"expression": "tostring(_G ~= nil)",
                                                  "context": "repl", "frameId": frame_id})
                resp = client.wait_response(seq)
                results["evaluate:frameId"] = summarize("evaluate(repl, COM frameId)", resp)
            else:
                print("\n### sem stackFrames -> nao da para testar evaluate com frameId "
                      "(esperado: jogo nao esta pausado)", flush=True)
        else:
            print("\n### sem threadId -> pulando stackTrace/scopes/variables", flush=True)

        # 7 ---------------------------- setBreakpoints com lista VAZIA (nao arma nada)
        seq = client.request("setBreakpoints", {
            "source": {"path": "probe_nonexistent.lua"},
            "breakpoints": [],
            "lines": [],
        })
        resp = client.wait_response(seq)
        results["setBreakpoints(vazio)"] = summarize("setBreakpoints (lista vazia)", resp)

    finally:
        # ------------------------------------------------------------ disconnect
        try:
            if client.sock is not None:
                seq = client.request("disconnect", {"terminateDebuggee": False,
                                                    "restart": False})
                resp = client.wait_response(seq, timeout=2.0)
                summarize("disconnect", resp)
        except OSError as exc:
            print("[meta] falha ao mandar disconnect: %s" % exc, flush=True)
        finally:
            if client.buf:
                print("\n[meta] bytes nao consumidos no buffer: %r" % client.buf[:600], flush=True)
            client.close()

    # -------------------------------------------------------------------- resumo
    print("\n" + "=" * 70, flush=True)
    print("RESUMO", flush=True)
    print("=" * 70, flush=True)
    for key in results:
        print("  %-46s %s" % (key, "OK" if results[key] is not None else "sem body/falhou"))
    print("\nMensagens nao solicitadas (events etc.): %d" % len(client.unsolicited))
    for msg in client.unsolicited:
        print("  %s" % json.dumps(msg, ensure_ascii=False)[:300])
    return 0


if __name__ == "__main__":
    sys.exit(main())

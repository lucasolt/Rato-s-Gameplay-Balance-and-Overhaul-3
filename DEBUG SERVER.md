# Tarefa: sondar o debug adapter do Jagged Alliance 3

## Contexto (já apurado, não precisa redescobrir)

A extensão `SolEngineLua.vsix` (publisher HaemimontGames, v0.1.0, 2024-01-17) contém
**um único arquivo**, `extension/package.json`, com 790 bytes. Nenhum código de adapter.
O manifesto declara:

```json
"contributes": {
  "breakpoints": [{ "language": "lua" }],
  "debuggers": [{
    "type": "solengine",
    "label": "SolEngine Lua Debugger",
    "languages": ["lua"],
    "initialConfigurations": [{
      "type": "solengine",
      "request": "attach",
      "name": "Attach to SolEngine",
      "address": "localhost",
      "debugServer": 8165
    }]
  }]
}
```
Dependência: `vscode-debugprotocol`.

`debugServer` no VS Code significa "conecte na porta em vez de lançar um adapter".
Logo, a hipótese de trabalho é: **o próprio executável do jogo é o debug adapter e
serve DAP (Debug Adapter Protocol) em TCP 127.0.0.1:8165**. Confirmar ou refutar isso
é o objetivo.

## O que eu quero saber, em ordem de prioridade

1. A porta 8165 está escutando quando o jogo está rodando? Precisa de alguma flag
   (`-dev`, ModTools, etc.) para abrir?
2. O handshake DAP completa? Qual o objeto `capabilities` que ele devolve?
3. A requisição `evaluate` existe? Se sim:
   - funciona com `context: "repl"` **sem** `frameId`, com o jogo rodando livre?
   - ou exige estar pausado num breakpoint (precisa de `frameId` de um `stackTrace`)?
4. `threads`, `stackTrace`, `scopes`, `variables`, `setBreakpoints` respondem?

O item 3 é o que decide tudo. Se `evaluate` funcionar sem pausa, temos um console Lua
remoto no processo do jogo. Se exigir pausa, ainda é útil, mas o uso muda.

## Como fazer

Escreva uma sonda em Python 3 (stdlib apenas, sem pip) em
`tools/dap_probe.py` do repo do mod. Se Python não estiver disponível no PATH,
Node com módulo `net` serve igual.

Framing do DAP (é o mesmo do LSP):
```
Content-Length: <bytes do corpo>\r\n\r\n<json utf-8>
```
Sequência mínima:
1. `{"seq":1,"type":"request","command":"initialize","arguments":{
    "clientID":"probe","adapterID":"solengine","linesStartAt1":true,
    "columnsStartAt1":true,"pathFormat":"path","supportsRunInTerminalRequest":false}}`
2. ler a `response` de `initialize` → **imprimir `body` inteiro** (são as capabilities)
3. `{"seq":2,"type":"request","command":"attach","arguments":{
    "type":"solengine","request":"attach","address":"localhost","debugServer":8165}}`
4. aguardar o evento `initialized`, se vier
5. `{"seq":3,"type":"request","command":"threads"}`
6. `{"seq":4,"type":"request","command":"evaluate","arguments":{
    "expression":"tostring(_G ~= nil)","context":"repl"}}`
   — depois repetir com algo do jogo, ex. `"tostring(g_Combat ~= nil)"`
7. `{"seq":5,"type":"request","command":"disconnect","arguments":{"terminateDebuggee":false}}`

O leitor precisa ser tolerante: o adapter vai intercalar `event` no meio das
`response`. Faça um loop que lê mensagens até casar o `request_seq` esperado ou
estourar timeout, e **logue tudo que chegar**, inclusive o que não foi pedido.

Timeout de 3s por requisição. Nada de bloqueio infinito.

## Antes de rodar a sonda

Confira se a porta existe, com o jogo aberto:
```powershell
netstat -ano | findstr 8165
```
Se não aparecer nada, **pare e me reporte** — a próxima pergunta é como fazer o jogo
abrir a porta, e eu não quero que você fique chutando flags de linha de comando.

## Restrições

- **Não modifique nenhum arquivo do jogo nem do mod.** Esta tarefa é só leitura +
  criar `tools/dap_probe.py`.
- **Não coloque breakpoint nesta rodada.** Um breakpoint que dispara sem alguém para
  dar `continue` congela o jogo.
- Sempre mande `disconnect` no fim, inclusive em caminho de erro (use `try/finally`).
- Não tente lançar o jogo você mesmo. Eu abro, você sonda.

## Entregável

O script, mais um relatório curto respondendo os 4 itens acima, com o JSON de
`capabilities` colado literalmente. Se o handshake falhar, quero o traço bruto do que
foi enviado e do que voltou (ou do timeout), não uma interpretação.
# Remote Lua Console in the Running Game

The Jagged Alliance 3 executable **is** a debug adapter: it serves the Debug Adapter Protocol (DAP) on `127.0.0.1:8165`. This is the port used by the `SolEngineLua.vsix` extension (HaemimontGames) with `"request": "attach"` — but DAP can also be used directly, without VS Code in the middle.

`tools/dap_probe.py` does this. Python 3 stdlib only, no pip required.

## The important finding

**`evaluate` works while the game is running freely**, without a breakpoint and without a `frameId`. In other words, this is a live Lua console inside the running process, not an inspector that only works while paused.

See `DEBUG_SERVER.md` for instructions on connecting to the debug server and using it to inspect realtime game state.

Capabilities returned by the adapter:

```json
{
  "completionTriggerCharacters": [".", ":", "}"],
  "supportTerminateDebuggee": true,
  "supportsBreakpointLocationsRequest": true,
  "supportsCompletionsRequest": true,
  "supportsConditionalBreakpoints": true,
  "supportsConfigurationDoneRequest": true,
  "supportsHitConditionalBreakpoints": true,
  "supportsLogPoints": true,
  "supportsSetExpression": false,
  "supportsSetVariable": true,
  "supportsTerminateRequest": true,
  "supportsVariableType": true
}
```

`threads` / `stackTrace` / `scopes` / `variables` / `setBreakpoints` also respond —
`--frame` grabs a `frameId` from the first frame when evaluation inside a local scope is needed. For normal use (reading and modifying game globals), it is not necessary.

## Prerequisite

The port only exists on **`JA3Debug.exe`**. Check with the game open:

```powershell
netstat -ano | findstr 8165
```

Without `LISTENING`, there is no point insisting on the probe — the open game is the normal `JA3.exe`.

An `ESTABLISHED` line appearing alongside it is normal (VS Code or a previous probe); the adapter accepts multiple clients.

## Usage

```bash
# standalone expressions
python tools/dap_probe.py 'tostring(RATOAI_Debug)' 'tostring(g_Combat.current_turn)'

# a multiline block
python tools/dap_probe.py -f consulta.lua

# via stdin
echo 'tostring(SelectedObj.session_id)' | python tools/dap_probe.py -

# handshake only, to inspect capabilities
python tools/dap_probe.py --caps
```

Flags:

* `-v` echoes all DAP traffic to stderr.
* `--events` prints received events.
* `--raw` disables cleanup of the `metatable` footer that the adapter appends to every value.
* `--frame` evaluates inside the first stack frame.

For multiple lines in a single expression, wrap them in an immediately invoked anonymous function — this is the reliable way to return a value:

```lua
(function()
    local out = {}

    for _, t in ipairs(g_Teams or {}) do
        for _, u in ipairs(t.units or {}) do
            if u.ai_context then
                out[#out + 1] = tostring(u.session_id)
            end
        end
    end

    return table.concat(out, " | ")
end)()
```

## Precautions

* **Never use a breakpoint without someone at the keyboard.** A breakpoint that triggers without a `continue` freezes the game. The probe does not set any breakpoints.

* The probe always sends `disconnect` at the end, including on error paths (`try/finally`).

* **Evaluation is not free.** Calling `AIPrecalcDamageScore` consumes RNG (`unit:RandRange`, `InteractionRand`) and modifies the unit's `ai_context`. During an actual game this changes state. Set `context.dbg_freeze_target_rand = true` beforehand, which is what `IModeAIDebug:PrecalcForDebug` itself does.

* **Hard rule, learned the hard way: the probe is for READING.** Reading a field (`unit.ActionPoints`, `context.dbg_targets[dest]`, `pol.Weight`) is safe. Calling an engine function with a position/voxel **constructed manually** is not: `point_pack(WorldToVoxel(...))` constructed inside the query, or `policy:EvalDest(context, dest, grid_voxel)` invoked outside the normal flow, triggers an invalid-point assertion (`IsValidPos`, `RATOAI_ValidatePos`) and pollutes the session of whoever is playing. If you need a derived value, prefer reading what the current turn has already recorded — that is what `DEBUG (D1)` is for.

* Benchmarking is the one tolerable exception, but use positions that came from the game (`GetPassSlab(unit)`, `unit:GetPos()`), never reconstructed coordinates.

* 5-second timeout per request, with no infinite blocking.

## Real-world example: how this found B16

The Target page of the debug panel showed all new columns as `-`. Three expressions solved it:

```text
tostring(RATOAI_Debug)                                      => false

tostring(Platform.developer) .. " / " .. tostring(Platform.cheats)
                                                            => true / true

tostring(IModeAIDebug.PrecalcForDebug ~= nil)               => true
```

New code was loaded, cheats were enabled, and yet the flag was still `false`: it was evaluated once during load, before the mod's *Rato Dev* `ForceDev.lua` enabled the `Platform.*` flags. See **B16** in `WEIGHTS_AUDIT.md`.

Then, with `RATOAI_Debug = true` set live and `AIPrecalcDamageScore` rerun on an enemy's `ai_context`, the entire `DEBUG (D1)` capture appeared — proving that the flag was the only missing piece:

```text
targets=4  best=117  thr=94  total=228  roll=84  finalists=2  chosen=Barry
  Grizzly  dist=24  shots=1  cth1=28  hit=28  score=111
  Barry    dist=14  shots=1  cth1=51  hit=51  score=117   <- chosen
  MD       dist=19  shots=1  cth1=0                      rej="sum of CTH 0 <= 0"
  Kalyna   dist=25  shots=1  cth1=8   hit=8   score=82    (below cutoff)
```

## Useful queries

```lua
-- mod debug state

tostring(RATOAI_Debug)

-- who currently has a live ai_context
-- (the game clears it at the end of the unit's turn)

(function()
    local out = {}

    for _, t in ipairs(g_Teams or {}) do
        for _, u in ipairs(t.units or {}) do
            if u.ai_context then
                out[#out + 1] = string.format(
                    "%s side=%s dests=%d",
                    tostring(u.session_id),
                    tostring(t.side),
                    #(u.ai_context.destinations or {})
                )
            end
        end
    end

    return table.concat(out, " | ")
end)()

-- per-target rows for a destination
-- requires RATOAI_Debug to have been enabled during the turn

(function()
    local u = SelectedObj
    local c = u and u.ai_context
    local d = c and c.ai_destination
    local dd = d and c.dbg_targets and c.dbg_targets[d]

    if not dd then
        return "no dbg_targets"
    end

    local out = {}

    for tgt, row in pairs(dd.by_target) do
        out[#out + 1] = string.format(
            "%s cth1=%s hit=%s score=%s rej=%s",
            tostring(tgt.session_id),
            tostring(row.cth1),
            tostring(row.hit),
            tostring(row.score),
            tostring(row.reject)
        )
    end

    return table.concat(out, " ;; ")
end)()
```

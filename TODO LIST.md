# TODO

```lua
CheatAddItem("itemid")
```

## Reimplementation necessary
- [X] Camouflage. DONE: needs rewriting of descriptions
- [ ] How to deal with scopes that give bonuses to hit body parts or bypass cover?
  - Handzolt.
  - Scout Scope.
- [ ] What about grazing? Is it possible to keep it in the game?
- [ ] Grizzly Perk
- [ ] Spiritual Perk
- [ ] MGSetup Get AP (Should be the same as overwatch??) PS: Fix bug in the rotate button using max AP
- [ ] Check if Run and Gun penalty modifier for recoil was implemented
- [ ] out of breath impact on aim
 
## QOL
- [ ] Implement F1 "wiki"

## aCTH Balancing

- [ ] Stray shots should have a lower chance to inflict status effects. General inquiring about how strays are working now. Maybe be stray when hit other bodyparts of the same target? I am not even sure how the damage is being calculated right now.
- [ ] Calibrar o recuo de segunda ordem.
  - Ancorar `KickBase` e o mapa `control -> CFMax` nas duas.
  - Ver linhas extremas do ladder do `1cc229c`.
  - Depois conferir um calibre pesado.
  - Ver `RECOIL MODEL.md`.

## aCTH Possible fragilities
- [ ] Make sure AI will orient before checking for cover in LOF.
- [ ] Check how the `aCTH` deals with out-of-sight targets (wallbang).
- [ ] Check how it works agains non-humanoids
- [ ] does the night vision penalty affects it

## aCTH Descriptions that need change

- [ ] Autofire max aim levels
- [ ] Burst and aim bonus
- [ ] Camouflage effect
- [ ] MG Setup and set up bonuses/held gun
 
## New mechanics intended
- [ ] Autofire shot count.
- [x] MG Recoil/setup rework (needs further testing)
- [x] Crouch and prone effect on the aperture, elliptical

## New mechanics (luxury)
- [ ] MG and bipods setting up on cover/crouch
- [ ] Change AP scale for more gradient AP costs, specially for stance, rotation etc
- [ ] **MEGA LUXURY** Vision cones/directional vision. Would need to make AI take this into account.
 
## Later Balancing
- [ ] Shotgun pellet balancing.
- [ ] **General balancing:** OW tuning — minor.

## AI OVERHAUL - other mod 
- [ ] Implement smoke usage.
- [ ] Make sure AI will not try to shoot through walls. (especially with aCTH)
- [ ] Enemy `LastPos` should generate threat. They should also try to "chase" the last position.
- [ ] Investigate the shot-selection threshold.
  - Currently at `1`.
  - Consider increasing it to `2`.
- [x]  Check grenade distribution.
  - Give more timed grenades to enemies.
  - Less frustrating, but still a challenge to the player.
- [ ] Need to simplify `Threat Exposure`, remove the stuff that is just leftovers and tune the policy
	- [X] Fix LOS 
	- [ ] Fix Debug overlay not decomposing ready curve 
- [ ] Check recoil calc for AI when using aCTH


## Threat Exposure 
# Range / Falloff Shape — "How Much Does Distance Matter"

- `PlateauTiles` — **CORE.** Distance where weight stays at 100 before decay starts. Fixes the "linear from zero" mismatch with real accuracy curves.
- `FalloffCurve` — **CORE.** Curvature after the plateau (`0 = linear`, `100 = quadratic`). Sinks the middle while keeping both ends pinned.
- `RangeCapTiles` — **BIAS.** Hard cutoff that *rescales the whole ramp*, not just truncates it. Off (`0`) by default. Different tool from `FalloffCurve` — don't conflate them.
- `MeleeRange` — **CORE.** Fallback range for unarmed/melee enemies.

# Setup / Readiness — "How Ready Is He to Shoot Me Well"

- `SetupBias` — **CORE.** Master toggle for the whole mechanic.
- `SetupReadyPct` / `SetupCostlyPct` — **OVERLAP.** Flat amplitude multiplier: same factor at 2 tiles and 25. This is the thing behind the "up close = flat" complaint.
- `SetupCurveSpread` — **OVERLAP.** Routes readiness into `FalloffCurve` instead. This is the fix, but it only works cleanly if the amplitude knobs above are pulled to neutral (`100/100`). Right now you likely have both active and fighting.

> **Decision needed:** choose between flat amplitude modulation and curve-based readiness modulation. Don't add more code.

- `const.RATOAI.ThreatSetupReady/Costly` — Same knob in console-tunable form; redundant with the property when the property is `0`.
- `GetEnemyCeiling()` (B49) — **CORE, not a property.** Internal correctness fix so `"N enemies"` stays true when `ready > 100`. Don't touch; just know it exists.

# Cover Cancellation — "Does Cover Stop This Threat"

- `CoverCancels` — **CORE.** Master switch: cancel cover here vs. let `AIPolicyCustomSeekCover` do it externally. Mutually exclusive with that policy in the same list.
- `CoverTrust` — **BIAS.** How much the AI believes in cover (`100 = full cancel`).
- `CoverNearTiles` / `CoverTrustNear` — **BIAS, off by default (`0`).** Cover is cheap to walk out of up close, so this discounts it near the enemy. Keep only if you've actually felt the AI over-trusting point-blank cover.

# Stance Mitigation — "Does Crouch/Prone at the Destination Help"

- `StanceCancels` — **CORE.** Mirrors GBO3's real CTH mechanic, not a bias. Grows with distance and does nothing point-blank.
- `StanceTrust` — **BIAS.** Additional discount on top of the real mechanic, representing the AP cost to stand back up.
- `ProneMaxTiles` / `CrouchMaxTiles` — **CORE.** Must match GBO3's hardcoded `24/26`. Not tunable in spirit; they mirror numbers that live nowhere else.

# Status Effects — "Is This Enemy Currently Weaker"

- `const.RATOAI.ThreatEffectMods` — **CORE mechanism, empty by design.** Current uncommitted entries (`Suppressed`, `Blinded`, `Inaccurate`, `dazed_flashbang`) are calibration choices, not code-correctness issues.

# Gating

- `RequireLOS` — **BROKEN.** As measured, it gates on an aggregate `"does anyone see this"` cache that is `nil` for ~94% of tiles on a real map. `nil` passes through, and it doesn't ask per-enemy LOS at all.

> This is the actual bug behind LegionRaider/Smiley — not stance or cover math.

- `visibility_mode` — **CORE.** `self` / `team` / `all`. Unrelated to the LOS bug: this controls which enemies count as visible to us, not whether they can see a given tile.

# Debug-Only — Not Gameplay Knobs

- `end_of_turn`, `optimal_location` — Locked, `no_edit`; ignore.
- `const.RATOAI.ThreatDebug` — Overlay trace toggle.
- `GetEditorView` — Panel label. Cosmetic, but currently under-reports which knobs are live; it misses `CoverCancels` / `CoverTrust`.

# Reminders for Later

- [ ] Fix `Decompose` in `Rato Dev/Code/RATODBG_AIDebugUI.lua` — it doesn't know about `SetupCurveSpread`, so panel numbers lie whenever readiness ≠ `100`.
- [ ] Fix `RequireLOS` — replace the aggregate/nil-passthrough cache with real per-enemy LOS, or the `"wall should cancel threat"` case (LegionRaider/Smiley) will remain broken.
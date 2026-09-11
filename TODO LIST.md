# TODO

```lua
CheatAddItem("itemid")
```
## Housekeeping
- [X] Implement unified Component handling, with ancestor/CTH mode
	- [ ] fix/unifiy with aCTH logic!!!
	- [ ] Verify if patch called from TOG is redundant.

## aCTH Possible fragilities
- [ ] Make sure AI will orient before checking for cover in LOF.
- [ ] Check how the `aCTH` deals with out-of-sight targets (wallbang).
- [X] Check how it works agains non-humanoids
- [ ] does the night vision penalty affects it?
- [ ] check if AI is considering bonus from crouch
- [ ] ricochets still work?

## AI OVERHAUL - other mod 
- [ ] Mechanics check
- [ ] Grenade range policy bugged/grenadiers?
- [ ] Take cover action is more important, should be used
- [ ] in aCTH they should try to shoot the head if its the only part out of cover
- [ ] Implement smoke usage.
- [ ] Make sure AI will not try to shoot through walls. (especially with aCTH)
- [X] Enemy `LastPos` should generate threat. They should also try to "chase" the last position.
- [ ] Investigate the shot-selection threshold in regards to aCTH. Enemies are shooting "0%" shots in aCTH
- [ ] in aCTH, they should not use autofire from the hip unless very close
- [x]  Check grenade distribution.
  - Give more timed grenades to enemies.
  - Less frustrating, but still a challenge to the player.
- [ ] Tune `Threat Exposure`, possibly simplify
	- [X] Fix LOS 
	- [X] Fix Debug overlay not decomposing ready curve 
- [X] Check recoil calc for AI when using aCTH
- [X] Fix AI trying to shoot prone when there is a very small cover in front of it, making impossible to actually hit (see savegame) **---> Done. Needs testing - BTW, this could make AI incapable of wallbanging? check**

## AI Overhaul new stuff
- [ ] Overwatch against last target pos when unit is hidden. also make them throw grenades at it, specially when at a rooftop

## aCTH Balancing

- [ ] Close range might get _too_ strong
- [X] Re-scale Aim Accuracy bonus for more gradient
	- [X] UV dot
	- [ ] No stock penalty should be re-scaled as handguns have changed. Decide if more range penalty or more aim penalty is appropriate
	- [ ] Light stock?
	- [X] Match ammo
	- [X] grips -> its a flat attack accuracy bonus
	- [X] better handling of the component aim scaler
- [X] review the Handling while standing penalty
	- [ ] Decide if Recoil while standing should use the same parameters (currently uses `weigth_held_mul`)
- [X] Stray shots should have a lower chance to inflict status effects. 
	- [ ] Pellets
- [ ] Calibrar o recuo de segunda ordem.
  - Ancorar `KickBase` e o mapa `control -> CFMax` nas duas.
  - Ver linhas extremas do ladder do `1cc229c`.
  - Depois conferir um calibre pesado.
  - Ver `RECOIL MODEL.md`.

## Reimplementation necessary
- [ ] Snipe/Pin Down action
- [ ] gas, smoke, other grazing mechanics need to be changed
- [ ] CQC bonus perk?
- [X] low profile cth mod for crocs disabled when using aCTH
- [X] Camouflage.
- [ ] How to deal with scopes that give bonuses to hit body parts or bypass cover?
  - Handzolt.
  - Scout Scope.
- [ ] What about grazing? Is it possible to keep it in the game?
- [X] Grizzly Perk - **there is something in the recoil cacl, check if its enough**
- [ ] Major Perk (Bullet hell)
- [ ] Spiritual Perk
- [X] MGSetup Get AP (**ended up decreasing delta by 1**)
	- [ ] Fix bug in the rotate button using max AP
- [X] Check if Run and Gun penalty modifier for recoil was implemented
- [ ] out of breath impact on aim
------------------------------------------------------------------------------------------------------------------------------
# Later Stuff
## aCTH Descriptions that need change
- [ ] DualShot max aim = 3
- [ ] Autofire max aim levels
- [ ] Burst and aim bonus
- [ ] Camouflage effect
- [ ] MG Setup and set up bonuses/held gun
- [ ] UI CTH should change, put aperture in a differnt setting, also recoil
 
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

## QOL
- [ ] Implement F1 "wiki"


------------------------------------------------------------------------------------------------------------------------------


# Threat Exposure 
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
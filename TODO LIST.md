# TODO

```lua
CheatAddItem("itemid")
```
## Patch Notes
```
4.00
- When set up, MGs will have lower snapshot penalty for interrupt attacks at long distances
- Setting up MG now costs more if you are not prone. This extra cost can be paid with free move ap. Base cost reduced by 1
- Components and perks effect on recoil/snapshot/hipfire and aim tweaked
- Snipe action bonus crit per aim from 5 to 4.
- Heavy rain no longer increases aim AP. Instead, it makes aiming less effective 
- Reflex sights no longer increase range
- Snapshot penalty for opportunity attacks was decreased (from extra +20% to +10%). Reflex will grant bigger accuracy boost

- NEW MECHANIC: Redesigned reliability mechanics. The value will now govern the chance of jamming instead of condition degradation by shot. The formula was changed, high reliability weapons will be able to perform even when in lower condition.

- Changed fog vision radius reduction. Fog no longer causes grazing hits
- Critical chance based on aim levels was tuned down
- Shotgun attack AP cost reduced, same value as single shot
- Other balance tweaks that I forgot

- AP Scale changed. What before was 1 AP, now is 10 AP. This opens avenues to tweak ap costs in a more granular way.
- Manually cycling AP has been tweaked (it cost less). The effects from dexterity are now not in threshold steps, but instead are a smooth progression. Every point of dexterity helps (mostly)
- Components impact on shooting stance cost was changed (barrels and stock have less increase, handgun barrels have a very small change now)

- Heavy Weapons perk now reduces Shooting Stance AP instead of Setup AP (indirectly still reduces Setup AP). 

- Fixed and improved Shooting Stance animations (shoutout to @dabhand)
- Fixed bugs related to shotgun

-- new CTH mode: aCTH --

This was created because I felt that accuracy was too high on long ranges, and just shooting first was what determined a fight result. I want it to feel more like a firefight, prolonged, suppression based (please use the Pinned Down mod).
Heavily inspired by 1.13 NuCTH. In this mode, every shot is simulated. Your accuracy will generate an aperture that denotes the possible dispersion. A shot will be randomly fired in this area. Aiming turns the dispersion tighter.
Shots can hit other body parts than what you intended. In these cases, inflicting status effect and crit have their chance lowered by 33%, and the base damage suffers 10% reduction.
Shots can hit cover. There is no more hardscripted cover. A small, thin lightpost can save you from a bullet (or your enemy). 
Expect dynamic (chaotic) results (that is the fun part!). You need to have stomach for bouts of randomness to use this mode.

(aCTH) Handling:
- new weapon stat: Handling -> is the base precision factor for every attack. Small weapons will have less penalty, but in turn have less aiming bonus. Replaces Point Blank/Close Range bonus.
- Heavy/big weapons (MGs, Barret, PSG) have worse handling if you are not prone. Some of this can be negated with high str. 

(aCTH) Recoil:
- Recoil deviation is simulated. Str controls how much you control, dexterity/marksmanship will help you get back on target.
- MGs have recoil penalty (and the aforementioned handling penalty) when firing not prone. There are no penalties to fire without setup, that is, the benefits have been all transfered to being prone or having a bipod. MG Setup is now a way to OW (with one bonus attack per turn)
- Being prone and have a bipod will have an impact biased to reduce the vertical component of recoil.


(aCTH) Aim and Sights:
- Aim accuracy scale has been changed (values will range from ~~5 to 70)
- Aim accuracy is very important to determine how well can you hit at range
- Scopes work differently, mostly increasing max aim levels. Big scopes have more snapshot penalty, and work better with high aim accuracy weapons.
- Reflex sights have flat accuracy bonus (equally good for weapons with high or low aim accuracy)
- Weapon range now is mostly relevant to how tight you can make the dispersion. In some ways, they are a floor to dispersion and a ceiling to aim accuracy. So high range weapons will benefit more from scopes, low range will have little benefit, as you approach the floor earlier.

(aCTH) Other stuff:
- Autofire has no cap on max aim levels
- Dual shot has max 3 aim levels, you will get no benefit from scopes or sights.
- CQC perk will reduce snapshot and hipfire penalty for firearms, instead of bonus acc at close range. Melee and thrown weapons remains the same as the original.
 
-- -- -- -- -- -- -- -- -- 
```


## Housekeeping
- [X] Implement unified Component handling, with ancestor/CTH mode
	- [X] fix/unify with aCTH logic!!!
	- [ ] Verify if patch called from TOG is redundant.

## Components

- [ ] Remove TOG handguards
- [ ] no interchangeable stock between RKs
- [ ] check components that make sense and remove the ones that dont. elegance first.
- [ ] Re-tune component AP cost now that the scale has changed
	- [X] Handgun barrels -> 3
	- [X] Light stock -> 5
	- [ ] Heavy stock
	- [ ] Barrels

- [ ] fix folded stock AP reduction (M11 was bugged)

## FINISH THE SLUG LOGIC !

## aCTH Possible fragilities
- [ ] **Make sure aCTH lite works as intended**
- [ ] Make sure AI will orient before checking for cover in LOF.
- [ ] Check how the `aCTH` deals with out-of-sight targets (wallbang).
- [X] Check how it works agains non-humanoids
- [X] ricochets still work?
- [X] Aim is being used in the Interrupt? shows 0 levels

-[ ] **BUG** Shotgun "killed unit was reported, but no "attack hit" actually struck it." See save Shotty Bug

## AI OVERHAUL - other mod 
- [ ] Disabled pindown action for now
- [ ] decision making logic relating to grenades-> they should not use if they are very close to another target (that could be killed or kill them)
- [x] **possible BUG** - Buckshot should not degrade to single shot - **STILL HAPPENING?**
- [ ] Mechanics check
- [ ] in aCTH they should try to shoot the head if its the only part out of cover
- [ ] Implement smoke usage.
- [X] Enemy `LastPos` should generate threat. They should also try to "chase" the last position.
- [ ] Investigate the shot-selection threshold in regards to aCTH. Enemies are shooting "0%" shots in aCTH
- [ ] in aCTH, they should not use autofire from the hip unless very close
- [x]  Check grenade distribution.
  - Give more timed grenades to enemies.
  - Less frustrating, but still a challenge to the player.
- [X] Check recoil calc for AI when using aCTH
- [X] Fix AI trying to shoot prone when there is a very small cover in front of it, making impossible to actually hit (see savegame) **---> Done. Needs testing - BTW, this could make AI incapable of wallbanging? check**

## AI Overhaul new stuff
- [ ] Overwatch against last target pos when unit is hidden. also make them throw grenades at it, specially when at a rooftop
- [ ] Bandage

## AI Overhaul - minor
- [ ] Take cover action is more important, should be used
- [ ] Make sure AI will not try to shoot through walls. (especially with aCTH)
- [ ] Tune `Threat Exposure`, possibly simplify
	- [X] Fix LOS 
	- [X] Fix Debug overlay not decomposing ready curve 

## aCTH Balancing

- [ ] Remove stray from get cover action?
- [X] Evaluate aim soft cap, to see if new values are not capped (its 70 the cap)
- [X] Pinned down mod suppression for strays
- [X] Re-scale Aim Accuracy bonus for more gradient
	- [X] UV dot
	- [X] No stock penalty should be re-scaled as handguns have changed. Decide if more range penalty or more aim penalty is appropriate
	- [X] Light stock?
	- [X] Match ammo
	- [X] grips -> its a flat attack accuracy bonus
	- [X] better handling of the component aim scaler
- [X] review the Handling while standing penalty
	- [ ] Decide if Recoil while standing should use the same parameters (currently uses `weigth_held_mul`)
- [X] Stray shots should have a lower chance to inflict status effects. 
	- [X] Pellets
- [ ] Calibrar o recuo de segunda ordem.
  - Ancorar `KickBase` e o mapa `control -> CFMax` nas duas.
  - Ver linhas extremas do ladder do `1cc229c`.
  - Depois conferir um calibre pesado.
  - Ver `RECOIL MODEL.md`.

## Reimplementation necessary
- [X] out of breath impact on aim
- [X] AN94 2 round burst
- [X] Snipe/Pin Down action

- [X] low profile cth mod for crocs disabled when using aCTH
- [X] Camouflage.

- [ ] How to deal with scopes that give bonuses to hit body parts or bypass cover?
  - Handzolt.
  - Scout Scope.

- [ ] What about grazing? Is it possible to keep it in the game?
- [ ] gas, smoke, other grazing mechanics need to be changed

- [X] Grizzly Perk - **there is something in the recoil cacl, check if its enough**
- [X] CQC bonus perk?
- [ ] Major Perk (Bullet hell)
- [X] Spiritual Perk

- [X] MGSetup Get AP (**ended up decreasing delta by 1**)
	- [ ] Fix bug in the rotate button using max AP
- [X] Check if Run and Gun penalty modifier for recoil was implemented

------------------------------------------------------------------------------------------------------------------------------
# Later Stuff
## aCTH Descriptions that need change
- [ ] Recoil CTH UI display
- [ ] Snapshot will not reset when shooting the same target **Only at page description**
- [X] DualShot max aim = 3 instead of 1
- [X] Autofire max aim levels no longer 1
- [X] Burst shots no longer lose aim bonus (logic is different)
- [X] Camouflage effect
- [X] MG Setup and set up bonuses/held  - the bonus is actually on being prone now
- [ ] UI CTH should change, put aperture in a differnt setting, also recoil
 
## New mechanics intended
- [X] change AP scale
	- [X] Rotation cost smooth
	- [X] Manual cycling AP cost dexterity scaling smooth
		- [X] Retune the costs of manual cycling
- [ ] Autofire shot count.
- [x] MG Recoil/setup rework (needs further testing)
- [x] Crouch and prone effect on the aperture, elliptical


## New mechanics (luxury)

- [ ] MG and bipods setting up on cover/crouch
- [ ] **MEGA LUXURY** Vision cones/directional vision. Would need to make AI take this into account.
 
## Later Balancing
- [ ] Shotgun pellet balancing and spread, duckbill etc.
- [ ] Slug damage?
- [ ] **General balancing:** OW tuning — minor.

## QOL
- [X] Fix Shooting Stance animation, particulary in regards to mobile attack 
- [ ] Crosshair AP cost breakdown refactor, for more clear stance ap cost display
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
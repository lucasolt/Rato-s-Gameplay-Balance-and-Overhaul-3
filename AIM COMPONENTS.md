# Aim-related WeaponComponentEffects — old CTH vs angular CTH

Written 2026-09-03 against branch `feat/cth-angular`. Inventory only — no code was changed.

---

## 1. Where a component can plug in

The two models are not two implementations of the same thing. They have **different numbers of
doors**, and that is the whole source of the confusion.

**Old CTH** has exactly one door: a `ChanceToHitModifier` returns points, points are summed. Every
aim component is read inside `aim_cth()` in [CTH_aim.lua](Code/CTH_aim.lua).

**Angular CTH** has five, and they are not interchangeable:

| # | Door | Where | What a component does there |
|---|------|-------|------------------------------|
| A | **weapon stat** | engine, `StatToModify` | changes `AimAccuracy` / `MaxAimActions` / `WeaponRange` before anything runs. Free, automatic, works in both models. |
| B | **`sigma_0` multiplier** | [FUNCTIONS_aperture.lua:378](Code/FUNCTIONS_aperture.lua:378), step 3 | one cone multiplier applied once at `aim >= 1`. Hardcoded to `AccuracyBonusWhenAimed`. |
| C | **decay ladder / threshold** | `A.ComponentEffectsAimBonus` → [GetApertureComponentAccBonus](Code/FUNCTIONS_aperture.lua:216) | `+acc` to `AimAccuracy` **only on aim levels `from..to`**. The "scope is a curve, not a step" door. |
| D | **decay multiplier** | `A.AimDecayMuls` → [FUNCTIONS_aperture.lua:255](Code/FUNCTIONS_aperture.lua:255) | scales how much *each level* closes. Stance/rain/handgun live here; only `grip_prone_penalty` uses it per-component. |
| E | **residual absorption** | [SOURCE_UnitCalcChanceToHit.lua:175](Code/SOURCE_UnitCalcChanceToHit.lua:175) → `Rat_ConeAbsorb` | any surviving `ChanceToHitModifier`'s points become a cone multiplier. Free — a component that still works through a live modifier keeps working. |

Anything read **inside `aim_cth()`** and not ported to B/C/D is **dead**, because `aim_cth` returns
`false, 0` when `Rat_AngularActive` is true ([CTH_aim.lua:32](Code/CTH_aim.lua:32)).

---

## 2. The inventory

Owner: **V** = vanilla preset, **M** = mine (new or redefining vanilla), **M(items)** = authored in
`items.lua`.

### 2.1 Live in both models

| id | Owner | Param | Old CTH | Angular | Notes |
|----|-------|-------|---------|---------|-------|
| `IncreaseAimAccuracy` | V | `AimAccuracyIncrease` | stat | stat (A) | forced **off** on every scope profile, [SetScopeEffects.lua:82](Code/SetScopeEffects.lua:82) |
| `DecreaseAimAccuracy` | M | `AimAccuracyDecrease` | stat | stat (A) | never named in any code path — pure stat |
| `IncreaseMaxAimActions` | M | `MaxAimActionsIncrease` | stat | stat (A) | the scopes' extra aim levels |
| `AccuracyBonusWhenAimed` | M (redefines V) | `bonus_cth` | additive points | door B, gated by `A.SightAimBonus` | the only user of door B |
| `pso_dragunov_scope` | M | — | `aim>=2` | door C `from=5 acc=3` | **threshold moved 2 → 5** |
| `sniper_aim_scope` | M | — | `aim>=3` | door C `from=5 acc=5` | **3 → 5** |
| `sniper_adv_aim_scope` | M | — | `aim>=4` | door C `from=6 acc=5` | **4 → 6** |
| `FirstAimBonusModifier` | M (redefines V) | *(none in mine; V had `first_aim_bonus`)* | `+min_bonus*0.3 + 2.1` | door C `from=1 to=1 acc=3` | see §3.4 |
| `grip_prone_penalty` | M | — | `const.Combat.ProneGripAimMul` | door D `ProneGripPenalty=105` | only per-component user of door D |
| `ScopePenalty1/2/3` | M | `range_penalty` *(declared, unread)* | own modifier, points | door E | [CTH_scope.lua](Code/CTH_scope.lua) is never gated off; distances and penalties are hardcoded, so the param is decorative |
| `bodypart_scope`, `body_part_uv` | M | — | targeted-shot modifier | door E, ×`TargetedResidualPct` | [CTH_targeted_noburst.lua:26](Code/CTH_targeted_noburst.lua:26) |
| `AccuracyBonusProne` | M (redefines V) | `bonus_cth` | bipod + recoil | door E + recoil | not an aim-decay effect at all |
| `OpportunityAttackBonusCth` | M (redefines V) | `bonus_cth_interrupt` | own modifier | door E | |
| `MinorAccuracyBonus` | V | `bonus_cth` | vanilla modifier | door E | still runs; nothing in the mod touches it |
| `scope_snapshot` | M | `snap_reduc` | snapshot penalty | `GetWeaponHipfireOrSnapshotMul` → step 5 | |
| `SnapshotPropertyMul` | M(items) | `snap_mul` | stat `wep_base_snapshot_mul` | same | how the profiles make magnification cost something |

### 2.2 Angular-side only

| id | Owner | Why |
|----|-------|-----|
| `_x2ScopeAimBonus` | M(items) | exists only as a door-C entry, `from=4 acc=3`. `aim_cth` never reads it. |
| `BonusAccuracyWhenFullyAimed` | V | actually both — `aim_cth` reads it at full aim ([CTH_aim.lua:240](Code/CTH_aim.lua:240)) *and* it is a door-C entry `from=3 to=3 acc=2`. But the `_2x` profile forces it off. |

### 2.3 Dead in angular, live in old CTH

The silent regressions on this branch.

| id | Owner | What it did | Status |
|----|-------|-------------|--------|
| `AccuracyBonusWhenAimed_vgrip` | M | `+bonus_cth_v` points when not dual-wielding | **dead** — vertical grip lost its aim bonus entirely |
| `reflex_sight_close_range` | M | `+Close_bonus` inside close range | **dead** — yet still attached to 5 reflex/laser profiles, [SetScopeEffects.lua:219](Code/SetScopeEffects.lua:219) |
| `light_stock_aim_reduce` | M | `bonus * 0.90` | **dead** — has an unwired door-D entry, §3.1 |
| `ReduceAimAccuracy` | V | `bonus * 0.5` | **dead** — has an unwired door-D entry, §3.1 |

### 2.4 Dead everywhere

| id | Owner | Status |
|----|-------|--------|
| `SightAimBonus` | M(items) | declared, commented out in `ComponentEffectsAimBonus`, read nowhere. Its own description says "Not implemented yet". |
| `acc_penal_stock` | M | `bonus_cth = -5` declared; **no reader in either model** |

---

## 3. Concrete problems

### 3.1 `A.AimDecayMuls.CompEffects` is an orphan
[__ApertureParams.lua:252](Code/__ApertureParams.lua:252) declares

```lua
CompEffects = { light_stock_aim_reduce = {mul = 110}, ReduceAimAccuracy = {mul = 150} }
```

and **nothing reads `CompEffects`** anywhere in `Code/`. The door-D loop only handles the fixed
stance/rain/handgun keys. Both effects are inert while the table says otherwise — the same failure
mode as the `APincrease` orphan already fixed in the recoil work.

### 3.2 Two copies of `ComponentEffectsAimBonus`
Live table: [SetScopeEffects.lua:20](Code/SetScopeEffects.lua:20). Stale commented copy with
*different numbers*: [__ApertureParams.lua:226](Code/__ApertureParams.lua:226). Params belong in
`__ApertureParams.lua`; `SetScopeEffects.lua` is the apply layer.

### 3.3 Threshold drift
Old CTH: PSO 2+, sniper 3+, adv 4+. Angular: 5, 5, 6. The player-facing
`WeaponComponentEffect` descriptions still say 2+/3+/4+, and the `SetScopeEffects` comment claims the
`from` values match those texts. They no longer do.

### 3.4 `FirstAimBonusModifier` works by accident in old CTH
My redefinition dropped vanilla's `first_aim_bonus` parameter. `GetComponentEffectValue` falls
through to `... or 0`, and `if modifyVal then` passes because **`0` is truthy in Lua**. It works, but
only for that reason.

### 3.5 Names that fight each other
- `DecreaseAimAccuracy` (mine, stat) vs `ReduceAimAccuracy` (vanilla, CTH points) — near-homonyms,
  different doors. My comment on `DecreaseAimAccuracy` says *"Increases the bonus…"* and is
  copy-pasted onto `Ow_decrease_flat` too.
- Four `AccuracyBonus*` names on four different doors: `AccuracyBonusWhenAimed` (B),
  `BonusAccuracyWhenFullyAimed` (C), `AccuracyBonusWhenAimed_vgrip` (dead), `AccuracyBonusProne` (E).
- `bodypart_scope` / `body_part_uv` — same concept, two spellings.
- `group` is noise: `pso_dragunov_scope`, `sniper_aim_scope`, `bodypart_scope`,
  `light_stock_aim_reduce` and `reflex_sight_close_range` all sit in **`"FX Placeholders"`** while
  driving real math, while `AccuracyBonusWhenAimed` is in `"Aiming"` and `AccuracyBonusProne` in
  `"ChanceToHit"`.

---

## 4. Suggested reorganization

Organize by **the door, not the flavour**. A reader should be able to tell from the id or the group
which of A–E an effect uses.

### 4.1 Make `group` mean the door (no code change, editor pass)

| group | door | members |
|-------|------|---------|
| `Aim/Stat` | A | `IncreaseAimAccuracy`, `DecreaseAimAccuracy`, `IncreaseMaxAimActions` |
| `Aim/Cone` | B | `AccuracyBonusWhenAimed` |
| `Aim/Threshold` | C | `pso_dragunov_scope`, `sniper_*`, `_x2ScopeAimBonus`, `FirstAimBonusModifier`, `BonusAccuracyWhenFullyAimed` |
| `Aim/Decay` | D | `grip_prone_penalty`, `light_stock_aim_reduce`, `ReduceAimAccuracy` |
| `Aim/Residual` | E | `ScopePenalty*`, `bodypart_scope`, `body_part_uv`, `reflex_sight_close_range` |

`"FX Placeholders"` then means *literally nothing but a description line* — and anything left in it
that a code path reads is a bug by definition.

### 4.2 Collapse the threshold family into one parametrised effect
`pso_dragunov_scope`, `sniper_aim_scope`, `sniper_adv_aim_scope`, `_x2ScopeAimBonus` and
`BonusAccuracyWhenFullyAimed` are the *same mechanic* with different `(from, to, acc)`. Five ids exist
only because door C's table is keyed by id. One new effect —

```
id = "AimThresholdBonus", params: aim_from, aim_to, aim_acc
```

— read by `GetApertureAimComponentEffects` through `GetComponentEffectValue` would put the numbers on
the component in the editor (where you want them) and delete `A.ComponentEffectsAimBonus` entirely.
Keep the old ids as aliases while ToG variants still reference them. Old CTH can read the same params:
`aim_from`/`aim_acc` map straight onto `if num >= from then bonus = bonus + acc`.

### 4.3 Generalise doors B and D so they stop being one-effect specials
Door B hardcodes `"AccuracyBonusWhenAimed"`; door D hardcodes `grip_prone_penalty`. Both should
iterate a params table the way door C does:

```lua
A.ConeMulEffects = { AccuracyBonusWhenAimed = {param = "bonus_cth"} }        -- door B
A.AimDecayMuls.CompEffects = { light_stock_aim_reduce = {mul = 110}, ... }   -- door D, just wire it
```

Door D's table **already exists** (§3.1) and only needs its loop. That one fix revives
`light_stock_aim_reduce` and `ReduceAimAccuracy` and gives `AccuracyBonusWhenAimed_vgrip` an obvious
home (`{mul = 95}`) without inventing anything new.

### 4.4 Give `reflex_sight_close_range` a real angular home
It is the reflex sight's whole identity and currently does nothing. Two honest options:
- door E — a small standalone `ChanceToHitModifier` for close range (cheapest, absorbed automatically); or
- door D with a distance condition, i.e. the reflex closes the cone *faster* up close.

### 4.5 Delete
`SightAimBonus` and `acc_penal_stock`: no reader in either model.

### 4.6 Rename once, deliberately
`bodypart_scope` → `body_part_scope`, and stop using `Decrease*`/`Reduce*` interchangeably
(`Decrease*` = stat, `Reduce*` = vanilla CTH points). Renames must be paired with the component
presets referencing the id, so this is an editor pass, not a `sed`.

---

## 5. Fastest path

1. Wire `CompEffects` (§3.1) — one loop, revives two effects, unblocks §4.3.
2. Resolve the duplicated `ComponentEffectsAimBonus` (§3.2).
3. Decide `reflex_sight_close_range` and `AccuracyBonusWhenAimed_vgrip` (§4.3/§4.4) — the two
   regressions a player would actually feel.
4. Fix the scope description texts to match the real thresholds (§3.3).
5. Only then consider the `AimThresholdBonus` collapse (§4.2), which is the big one.

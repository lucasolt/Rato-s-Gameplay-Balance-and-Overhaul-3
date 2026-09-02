# Angular CTH — balance model, measurements and tuning

> **STALE as of 2026-09-02.** Sections 1 and 2 rest on `d50 = 1022 / sigma`, which came from the
> area-equivalent circle. The circle was replaced by a separable per-axis model fed by the target's
> animation box, and the constant both moved and stopped being a single number — it now depends on
> stance and aspect angle. The *identity* `d50 = C / sigma` still holds (C is sigma-invariant).
> A live measurement of C on 2026-09-01 did not reconcile with the analytic value and is not
> trustworthy; re-measure before rewriting these tables. See `TODO NOTES.md`.


> **Status:** everything in §3, §4, §5 and §7 is **implemented** on `feat/cth-angular` and verified
> in the live process. §1, §2 and §6 are the model and the measurements; they are the reference,
> not a to-do. What was deliberately *not* changed is listed in "Applied" at the bottom.

Written against the live process (JA3Debug, combat loaded, `IMP_Merc1`, aCTH + SimulateShots on).
Everything numeric here is either read out of the game or produced by `tools/aperture_model.py`,
which is a bit-exact integer replica of `Code/FUNCTIONS_aperture.lua` — validated against
`Rat_GetAperture` on the live weapon (identical sigma at every aim level: `Base 150 / skill 59 /
floor 24 / step 294 / sigma 262·135·74·44`).

Reproduce every table with:

```bash
python tools/aperture_report.py
```

---

## 1. The model, and the three identities that make it comparable

```
sigma_n = F(range) + ( sigma_0(marks, handling) - F(range) ) * PROD(decay_i)
sigma   = sigma_n * step(aim)                       -- hipfire / snapshot, aim <= 2 only
sigma   = sigma   * PROD(residual cone multipliers) -- recoil, perks, scope close-range, ...
CTH     = 1 - exp( -(theta/sigma)^2 / 2 )
```

Three consequences do all the work. They are what lets you compare a scope, a handling bonus,
a point of Marksmanship and an aim level in the same unit.

### 1.1 Effective range *is* 1/sigma

For a standing torso `theta = 1203/d` (d in tiles), so the distance at which a given cone still
gives 50% is

```
d50 = 1022 / sigma          (standing torso)
```

**A cone multiplier of `m` is exactly a `1/m` change in effective range, at every distance.**
That is the common currency. A residual that reports "cone ×108%" is "−7% of your reach".
Nothing else in the model needs its own scale.

### 1.2 `WeaponRange` buys the asymptote, and nothing else

`Rat_ApertureFloor` is `FloorPct% × theta(range)`, so the floor is a pure function of range and

```
d50_max = 1022 / F = 1.545 x WeaponRange           (at FloorPct = 55)
```

`FloorPct` has one clean meaning: **the CTH a fully-converged shot gets at the weapon's own
`WeaponRange`.**

| `A.FloorPct` | converged CTH at own max range | absolute range ceiling |
|---|---|---|
| 45 | 92% | 1.89 × range |
| 50 | 87% | 1.70 × range |
| **55 (current)** | **81%** | **1.55 × range** |
| 60 | 75% | 1.42 × range |
| 65 | 69% | 1.31 × range |
| 70 | 64% | 1.22 × range |

Range does *nothing* at aim 0 — at aim 0 the cone is ~10× the floor, so the floor is invisible.
That is exactly the property the new scope philosophy needs.

| archetype | range | floor | sigma₀ (M90) | gap/floor | d50 max | converged CTH at 0.5R / 1R / 1.5R / 2R |
|---|---|---|---|---|---|---|
| Pistol Glock17 | 18 | 37 | 90 | 1.43 | 27.6 | 97 / 81 / 52 / 33 |
| SMG MP5 | 22 | 30 | 90 | 2.00 | 34.0 | 97 / 81 / 51 / 33 |
| AR AK47 | 26 | 25 | 90 | 2.60 | 40.9 | 97 / 82 / 54 / 35 |
| AR AK74 | 28 | 24 | 90 | 2.75 | 42.6 | 97 / 80 / 52 / 32 |
| MG MG42 | 30 | 22 | 90 | 3.09 | 46.4 | 97 / 81 / 53 / 34 |
| Sniper M24 | 32 | 21 | 90 | 3.29 | 48.6 | 97 / 81 / 51 / 34 |
| Sniper PSG1 | 34 | 19 | 90 | 3.74 | 53.8 | 97 / 82 / 55 / 36 |
| Barrett | 40 | 17 | 90 | 4.29 | 60.1 | 97 / 79 / 50 / 32 |

### 1.3 Range realisation — why long weapons *need* aim levels

```
rho(n) = F / sigma_n = 1 / ( 1 + (gap/F) * r^n )       r = decay fraction per level
```

`gap/F` is in the table above and **grows with range**: the Barrett starts 4.3× above its own
asymptote, the pistol only 1.4×. So the longer the weapon, the more aim levels it takes to cash in
the range it nominally has. That is the mechanism your scope design is built on, and it works.

**d50 (tiles) actually reached at each aim level** — Marks 90, HE 100, no scope, no residuals:

| archetype | acc | decay | aim 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|---|---|
| Pistol Glock17 | 2 | 88% | 4.1 | 6.8 | 10.1 | 14.0 | 14.8 | 15.7 | 16.5 |
| SMG MP5 | 4 | 76% | 4.1 | 7.5 | 12.0 | 17.9 | 20.0 | 22.2 | 24.3 |
| AR AK47 | 3 | 82% | 4.1 | 7.3 | 11.6 | 17.0 | 18.9 | 20.8 | 22.7 |
| AR AK74 | 5 | 70% | 4.1 | 8.1 | 14.0 | 22.2 | 26.2 | 29.2 | 31.9 |
| BattleR FNFAL | 4 | 76% | 4.1 | 7.7 | 12.6 | 19.6 | 22.7 | 26.2 | 29.2 |
| MG MG42 | 2 | 88% | 4.1 | 6.9 | 10.4 | 14.8 | 16.2 | 17.6 | 18.9 |
| Sniper SVD | 7 | 58% | 4.1 | 9.3 | 17.3 | 29.2 | 34.0 | 37.8 | 40.9 |
| Sniper M24 | 9 | 46% | 4.1 | 10.8 | 21.7 | 36.5 | 42.6 | 46.4 | 48.6 |
| Sniper PSG1 | 9 | 46% | 4.1 | 10.9 | 23.2 | 39.3 | 46.4 | 51.1 | 53.8 |
| Barrett | 8 | 52% | 4.1 | 10.3 | 21.3 | 37.8 | 46.4 | 51.1 | 53.8 |

Read the last three columns: **two extra aim levels are worth +8.9 tiles to the M24, +7.3 to the
AK74, +4.3 to the MP5, +2.7 to the MG42.** Scope levels already scale with range × AimAccuracy
exactly as you intended. That part needs no parameter change.

Note the aim-0 column: **4.1 tiles for everything.** `A.AimStep[0] = 280` swamps every weapon
difference. There is currently no weapon-intrinsic term at aim 0 at all — that is the hole handling
is supposed to fill (§3).

---

## 2. The uncomfortable part: a ratio model has no natural close-range crossover

CTH depends only on `theta/sigma`. Both scale as `1/d`. So **any accuracy term that is not itself a
function of distance helps identically at every distance.** AimAccuracy, WeaponRange, Marksmanship,
handling — all of them shift the whole curve. There is no distance at which a high-AimAccuracy
weapon is worse than a low one at the same aim level.

Measured, with handling already applied on sigma₀ (Marks 90, standing torso):

| distance | MP5 / AK74 / **M24** | aim 1 | aim 2 | aim 3 |
|---|---|---|---|---|
| 8 tiles | | 61 / 57 / **67** | 90 / 91 / **97** | 97 / 97 / 97 |
| 18 tiles | | 17 / 16 / **20** | 37 / 38 / **62** | 62 / 69 / **94** |

The sniper is ahead at 8 tiles too. So the design intent — *"small weapons good without investment,
long weapons overtake them with aiming"* — **cannot be expressed through the cone alone.** Only two
things can produce a crossover:

1. **An explicitly distance-dependent term.** You already have one: `CTH_scope.lua`
   (`ScopePenalty1/2/3`, −20/−40/−55 scaling in below 7/14/17 tiles). It is the *only* one in the model.
2. **The AP economy.** This is where the design actually lives.

### The AP economy is the real crossover

`ShootAP` 3 (SMG) vs 4 (rifles); `APStance` 3 / 4 / 5 / 6; ~1 AP per aim level; 12 AP a turn.
Expected hits per turn (`shots × CTH`), best line in brackets:

| distance | MP5 (3/3) | AK74 (4/4) | FNFAL (4/4) | M24 (4/5) |
|---|---|---|---|---|
| 5 t | **[2×91% = 1.82]** | [1×97 = 0.97] | [1×97 = 0.97] | [1×97 = 0.97] |
| 10 t | [1×97 = 0.97] | [1×97 = 0.97] | [1×97 = 0.97] | [1×97 = 0.97] |
| 16 t | [1×86 = 0.86] | [1×87 = 0.87] | [1×77 = 0.77] | **[1×97 = 0.97]** |
| 24 t | [1×58 = 0.58] | [1×60 = 0.60] | [1×48 = 0.48] | **[1×80 = 0.80]** |
| 32 t | [1×39 = 0.39] | [1×41 = 0.41] | [1×31 = 0.31] | **[1×60 = 0.60]** |

That is your intended curve, and it comes almost entirely from the SMG getting a second shot at
≤ 8 tiles. **Design in this table, not in the CTH table.** The knobs that move it are `ShootAP`,
`APStance` and `A.AimStep` — not AimAccuracy.

Concretely: the 10-tile row is a dead tie across the whole arsenal because everyone clamps at
`A.MaxCTH = 97`. If you want a real mid-range identity, that band needs either a lower `MaxCTH`,
bigger `A.AimStep[1..2]`, or a wider `APStance` spread.

---

## 3. Handling: put it on sigma₀, not through the residual path

### What is wrong with the current wiring

`CTH_pointblank.lua:22` returns `GetPBbonus(weapon) * A.PBAsHandlingMul/100` **as CTH points**,
which `Rat_ConeAbsorb` converts through `Rat_ConeMulForPoints` and applies to the **final** sigma.
Two things go wrong.

**(a) The points→cone map at `A.ConeRefCTH = 80` is very asymmetric.** Measured:

| ConeRefCTH | +40 | +20 | +10 | +5 | −5 | −10 | −20 | −40 | −55 |
|---|---|---|---|---|---|---|---|---|---|
| 50 | 76 | 87 | 93 | 96 | 103 | 108 | 116 | 140 | 163 |
| 65 | 82 | 91 | 95 | 97 | 104 | 109 | 120 | 146 | 175 |
| **80 (current)** | **87** | **94** | **97** | **98** | **106** | **112** | **125** | **157** | **190** |
| 90 | 90 | 95 | 98 | 98 | 108 | 118 | 134 | 172 | 209 |

At ref 80 the Glock's `PB +19` buys a cone of **95%** — a 5% effect, i.e. nothing. The same scale
prices `ScopePenalty3` (−55) at **×1.90**. Bonuses are free, penalties are double-charged. If you
keep routing anything through this map, move `ConeRefCTH` to **65**, which is roughly symmetric.

**(b) Applied to the *final* cone it has the wrong shape.** Same nominal handling, applied to
sigma₀ versus to the final sigma (d50, tiles):

| | aim 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| **MP5**, no handling | 4.1 | 7.5 | 12.0 | 17.9 | 20.0 | 22.2 | 24.3 |
| A — on sigma₀ (`×79`) | 5.1 | 9.3 | 14.6 | 21.3 | 23.2 | 24.9 | 26.9 |
| B — on final (`×79`) | 5.1 | 9.5 | 15.2 | 22.7 | 25.5 | 28.4 | 31.0 |
| **M24**, no handling | 4.1 | 10.8 | 21.7 | 36.5 | 42.6 | 46.4 | 48.6 |
| A — on sigma₀ (`×109`) | 3.7 | 10.1 | 21.3 | 36.5 | 42.6 | 46.4 | 48.6 |
| B — on final (`×109`) | 3.7 | 9.8 | 20.0 | 33.0 | 39.3 | 42.6 | 44.4 |

**A washes out as you aim** — the cone converges on the floor, which handling never touched, so by
aim 3 the M24 has paid nothing for its bad handling and the MP5 banked most of its bonus early.
**B is a flat percentage forever** and permanently taxes the sniper's converged shot. A is your
design; B is what the code does today.

### Recipe

1. `A.PBAsHandlingMul = 0` (or drop the branch) — stop the residual path.
2. The `HandlingMul` property already exists live (`FirearmProperties`, default 100, every weapon at
   100) and `Rat_GetAperture` line 256 already reads it. Nothing to add — just set it:

```lua
A.HandlingScale = 150   -- cone % per point of PBbonus
weapon.HandlingMul = Clamp(100 - MulDivRound(A.HandlingScale, GetPBbonus(weapon), 100), 60, 140)
```

| | PB | HandlingMul | reach at aim 0 |
|---|---|---|---|
| Glock17 | +19 | 71 | 1.4× |
| MP5 / AKSU | +14 | 79 | 1.2× |
| AK47 | +8 | 88 | 1.1× |
| AK74 | +7 | 89 | 1.1× |
| FNFAL | +2 | 97 | 1.0× |
| MG42 | −2 | 103 | 0.97× |
| M24 | −6 | 109 | 0.92× |
| PSG1 | −9 | 114 | 0.88× |
| Barrett | −13 | 120 | 0.83× |

3. Decide whether `PBbonus` should also drive hipfire/snapshot. It nearly does already:
   `wep_base_hip_mul` / `wep_base_snapshot_mul` are strongly anti-correlated with PB (Glock 116/70,
   Barrett 83/159). And `A.UseHandling` is **nil**, so `Rat_ApertureSnapMul` / `ApertureSnapHipMul`
   (the `OverwatchAngle`-seeded values in `PATCH_GBO_weapons.lua`) are currently **dead code** — the
   snapshot step ignores them entirely. Either turn `A.UseHandling` on or delete the branch; right
   now it is a third handling channel that silently does nothing.

---

## 4. Scopes: the "cherry" should be the floor, not AimAccuracy at high levels

### The thresholds in `SetScopeEffects.lua` are too big and land too late

```lua
{id = "sniper_aim_scope",     from = 5, acc = 8},   -- M24/PSG1 base acc 9 -> 17
{id = "sniper_adv_aim_scope", from = 6, acc = 10},
```

`decay% = 100 - 6*acc`, so `acc 17` clamps at `A.DecayMinPct = 20`: level 5 closes 80% of what is
left. But at level 5 with `acc 9` only **2% of the original gap is left**. Measured on the M24
(Marks 90), d50 in tiles:

| variant | aim 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| no scope, aim ≤ 3 | 4.1 | 10.8 | 21.7 | 36.5 | — | — |
| +2 levels only | 4.1 | 10.8 | 21.7 | 36.5 | 42.6 | 46.4 |
| **+2 lvl, +8 acc from lvl 5** | 4.1 | 10.8 | 21.7 | 36.5 | 42.6 | **46.4** |
| +2 lvl, +3 acc from lvl 3 | 4.1 | 10.8 | 21.7 | 40.9 | 46.4 | 48.6 |
| +2 lvl, **floor ×87** | 4.1 | 11.1 | 23.8 | 40.9 | 48.6 | **53.8** |
| +2 lvl, +3 acc from 3, floor ×87 | 4.1 | 11.1 | 23.8 | 46.4 | 53.8 | 56.7 |

**`+8 AimAccuracy at level 5 is worth exactly zero** — after integer rounding sigma is 22 either
way. The bonus is spectacular on paper and invisible in play.

### Magnification is a commitment, not an upgrade

The extra aim *level* is not the weak part — at 40 tiles, level 3→4 on a scoped M24 is **+23 CTH**.
What is worthless is extra *AimAccuracy* at a late level: AimAccuracy sets the **rate** the gap
closes, and by level 4-5 there is no gap left to close faster. The floor is the only lever that
**creates** gap, so it is the only one that makes late levels worth having.

Two measured constraints shaped the final ladder:

- **`A.DecayMinPct = 30` clamps the decay at AimAccuracy 12.** A sniper starts at 9, so `+3` and
  `+5` from a scope produce the *same* decay. Threshold bonuses cannot separate 4x from 6x on the
  weapons that care most. The floor multiplier has no such ceiling.
- Every tier must be **worse** than the smaller one until the aim investment is paid, or a bigger
  scope is a strict upgrade and the choice is fake.

So each magnification step pays up front and collects late:

| tier | max aim | floor ×  | `snap_reduc` | ScopePenalty | threshold |
|---|---|---|---|---|---|
| Reflex | +0 | 100 | +10 (bonus) | — | — |
| 1.5x | +1 | 98 | — | none | — |
| 2x quick (ACOG, WideScope) | +1 | 98 | +5 (bonus, kept) | 1 | from 3 only, +2 |
| 2x | +1 | 96 | **−10** | 1 | from 3 only, +2 |
| 4x | +2 | 86 | **−25** | 2 | from 3, +2 |
| 6x | +3 | 74 | **−40** | 3 | from 4, +3 |

`snap_reduc` runs through the existing `scope_snapshot` component channel, which computes
`(100 − snap_reduc)/100` — a **negative** value is already a penalty, so this needed no new code,
shows up in the Snapshot line the player already reads, and only applies while `aim ≤ 2`
(the `A.AimStep` window). The later threshold onset is what keeps the 6x behind at aim 3.

Result (M24 R39 acc 9, Marks 90 — CTH by aim level):

| | | aim 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|---|
| **10 t** | no scope | 9 | 53 | 97 | 97 | | | |
| | 2x | 9 | 50 | 97 | 97 | 97 | | |
| | 4x | 8 | 41 | 96 | 97 | 97 | 97 | |
| | 6x | 6 | 33 | 92 | 97 | 97 | 97 | 97 |
| **40 t** | no scope | 1 | 5 | 21 | 51 | | | |
| | 2x | 1 | 4 | 21 | 61 | 71 | | |
| | 4x | 1 | 4 | 21 | 64 | 79 | 83 | |
| | 6x | 1 | 4 | 21 | 64 | **87** | **90** | **93** |

Up close the bigger scope is pure downside and everything converges to 97 by aim 3 anyway — the
scope choice costs you and buys nothing. Past ~25 tiles the 6x falls behind through aim 3 and then
overtakes from aim 4 and never stops gaining. The ladder holds the same shape on the SVD, AK74 and
MP5 (`python tools/aperture_report.py`).

**So: does it become useful further away? That is the only place it is useful.** The last aim level
is worth `+0` at 10 tiles for every weapon (saturated), and `+3` to `+15` at 40 tiles depending on
how much gap the floor left open — which is exactly what the floor multiplier is for.

### Housekeeping in the scope pass

`A.ApertureComponentTier` covers 16 ids and `RAT_SCOPE_ORIGINALS` has the same 16. Everything outside
that list is untouched, and **14 optics still carry `IncreaseRange`**:

```
SSG69_Scope_1  (+16)   _Master_SSG69_Scope_TOG   (+16)
VSS_Scope_1    (+10)   _Master_PSO-1M2_Scope_TOG (+10)
SteyrS_Scope_1 (+10)   _Master_SteyrS_Scope_TOG  (+10)
m76_scope_1    (+10)   _Master_m76_scope_TOG     (+10)
G11_Scope_1    (+4)    _Master_G11_Scope_1       (+4)
GW43_Scope_1   (+4)    _Master_GW43_Scope_TOG    (+4)
ThermalScope_1 (+10)   ThermalScope_2            (+10)
```

Plus these have no tier and no pristine entry, so they keep vanilla/ToG behaviour:
`AWP_Scope_1`, `Caws_Scope_1`, `NTW_20_Scope_1`, `WA2000_Scope_1`, `AN94_Scope_1`, `FN2000_Scope_1`,
`G11_Rail_7/9`, `TAR21_Scope_Rflx_1`, `ImprovedIronsight_AR15`.

(Barrels and bipods keeping `IncreaseRange` is fine — that is real barrel length, not optics.)

---

## 5. Suggested starting parameter set

| param | now | suggested | why |
|---|---|---|---|
| `A.FloorPct` | 55 | 55 | 81% converged at own max range reads right; it is the cleanest knob you have — change it only to move the whole game's long-range lethality |
| `A.DecayScale` | 6 | 6 | the runway is fine: acc 9 reaches ρ = 0.76 at aim 3 and 0.94 at aim 5 |
| `A.DecayMinPct` | 20 | 30 | at 20 a single clamped level closes 80% of the gap; 30 stops threshold optics from becoming step functions |
| `A.ConeRefCTH` | 80 | 65 | current map makes every bonus worthless and every penalty double-priced |
| `A.PBAsHandlingMul` | 100 | 0 | handling moves to `HandlingMul` (§3) |
| `A.HandlingScale` | — | 150 | new; `HandlingMul = 100 − 1.5 × PBbonus`, clamped 60..140 |
| `A.ScopeFloorMul` | — | `{_2x=96, _4x=92, _6x=87}` | new; the max-aim cherry |
| `A.UseHandling` | nil | `false`, explicitly | dead either way — make the intent visible |
| `ComponentEffectsAimBonus` | `from 5/6, acc 8/10` | `from 3, acc 2/3/4` | current values are worth 0 after rounding |

---

## 6. UI vs simulation — measured

`Rat_DbgShots` fires sampled shots through the real `GetLoFData` path and reports the displayed CTH
beside the empirical hit rate. Grizzly (prone, 5 tiles) and Barry (standing, 2 tiles), n = 400–600,
σ ≈ 2%:

| target | stance | aim | displayed CTH | simulated | sigma | theta |
|---|---|---|---|---|---|---|
| Grizzly | Prone | 0 | 41% | **48%** | 146 | 149 |
| Grizzly | Prone | 1 | 36% | **47%** | 158 | 149 |
| Grizzly | Prone | 2 | 71% | 71% | 94 | 149 |
| Grizzly | Prone | 3 | 97% (clamped) | 93% | 53 | 149 |
| Barry | Standing | 2 | 97% (clamped) | 100% | 102 | 538 |
| Barry | Standing | 4 | 97% (clamped) | 100% | 53 | 538 |

**The geometry itself is exact.** The Python replica reproduces `Rat_GetAperture` to the unit, and
`Rayleigh(theta, sigma)` reproduces the displayed number to the point at every row. There are two
divergences, and **neither can be caused by parameter tuning** — both numbers come from the same
sigma, so only the target *geometry* and the clamps can pull them apart.

**(a) `A.Silhouette` is a geometric-mean radius, not an equal-area radius.** The comment records
prone as `74 × 51 cm` measured; `sqrt(w*h)/2 = 31`, which is the value in the table, but a circle of
r = 31 has area 3019 cm² against the box's 3774 — 25% small. In the low-CTH regime P is roughly
linear in area, which is exactly the +7 / +11 point bias in the first two rows; at aim 2 the shot
saturates and the bias disappears. Equal-area radius is `sqrt(w*h/pi)`:

| stance | measured box | current | equal-area | note |
|---|---|---|---|---|
| Standing | 76 × 95 | 42 | 48 | same 1.13× bias, not tested here |
| Crouch | 59 × 72 | 37 | 37 | already correct |
| Prone | 74 × 51 | 31 | 35 | deliberately low, to preserve the old −30 flat prone penalty |

The prone value is a documented deliberate fudge — but it is now a **visible** one: the UI
under-reports the shot by ~10 points against a prone target. To align them, calibrate with
`Rat_DbgShots` in the 30–70% band and raise `A.BaseFactor` by the same factor so the difficulty does
not move. (Raising the silhouette alone makes the game easier by ~7 points in that band; raising
sigma alone lowers both numbers together and never converges — you need both.)

Re-measured after all the §8 changes (same target, n = 500): aim 0 `38 vs 46`, aim 1 `40 vs 51`,
aim 2 `78 vs 72`. Same shape, unchanged magnitude — as expected, since none of the changes touch
the silhouette. It confirms the divergence is geometric and not a consequence of tuning.

**(b) `A.MaxCTH = 97` is a display-only clamp.** The simulation never sees it, so at point blank the
UI says 97% and the shot lands 100% of the time. One-directional and in the player's favour, but the
advertised 3% miss does not exist in aCTH mode.

---

## 7. Bugs found while measuring

### B1 — aiming one level can make the shot *worse*, at the same AP cost

Measured, Grizzly at 5 tiles, `shooting_stance` active:

```
aim=0  cth=41  geo_sigma=150  final=146  | PointBlank=+2(mul 97)
aim=1  cth=36  geo_sigma=150  final=158  | PointBlank=+2(mul 97)  ScopePenal=-5(mul 108)
```

`Rat_ResolveAngular` bumps `aim` to ≥ 1 under `shooting_stance`, so **aim 0 and aim 1 have identical
geometry**. But `CTH_scope.lua:11` gates on the *un-bumped* aim (`if aim < 1 then return false, 0`),
so the scope close-range penalty appears only from aim 1. `GetAPCost` reports **5 AP for both**.
Aim 1 is therefore a strictly dominated option the UI still offers: same cost, −5 CTH.

Fix: apply the scope close-range penalty at aim 0 too, or gate it on the same effective aim the
geometry uses.

### B2 — the scope override never reaches weapons already in the field

`GBO_ApplyApertureCTHMode` calls `ApplyApertureItemParams()` (rewrites the presets) but not
`Rat_ReapplyApertureComponents()` (pushes them into equipped `Firearm` instances). Only
`Rat_SetAngularCTH` calls both. Measured on the loaded save — same weapon, before and after calling
`Rat_ReapplyApertureComponents()` by hand:

```
before:  WeaponRange 28   AimAccuracy 6   MaxAimActions 3    <- old preset, IncreaseRange still live
after:   WeaponRange 22   AimAccuracy 4   MaxAimActions 4    <- the _2x profile
```

So on a normal load, or after changing the mod option, **the entire scope refactor silently does
nothing** on weapons already equipped. `MaxAimActionsIncrease` in particular never applies, so the
extra aim levels the whole design depends on are not there.

Fix: call `Rat_ReapplyApertureComponents()` from `GBO_ApplyApertureCTHMode` (guard on `g_Units`).

### B3 — `A.UseHandling` is nil, so `ApertureSnapHipMul` is dead

`FUNCTIONS_aperture.lua:323` multiplies the hipfire/snapshot excess by `Rat_ApertureSnapMul(weapon)`
only when `a.UseHandling` is truthy. It is never set. The ~40 per-weapon `ApertureSnapHipMul` values
in `PATCH_GBO_weapons.lua` (Barrett 125 … AKSU 83) have no effect. Decide and make it explicit; see
§3.3.


---

## 8. Applied

Implemented and verified live (`ReloadLua` + `ApplyApertureItemParams` + `Rat_ReapplyApertureComponents`).

**Handling**
- `Rat_ApertureHandlingMul(weapon)` = `Clamp(100 - 1.5 * GetPBbonus(weapon), 60, 140)`, applied to
  sigma₀ in `Rat_GetAperture`. Because `GetPBbonus` already sums class + weapon + components
  (barrel, bullpup, grips, handguard), **every component that used to grant Point Blank Accuracy
  now grants handling instead**, with no per-component work.
- `CTH_pointblank.lua` returns `false, 0` under aCTH — the residual path is gone, and with it the
  `A.ConeRefCTH` asymmetry problem for handling specifically.
- The overlay's `Weapon` cone line is now `Handling`; the weapon-description hint shows it as a
  multiplier (`0.85 X`, lower is better) alongside Hipfire / Snapshot / Recoil.
- Verified: VSK94 with `PB +10` → `HandlingMul 85`, no `PointBlank` line in the modifier list.

**No second hipfire/snapshot multiplier**
- `A.UseHandling`, `Rat_ApertureSnapMul`, `Rat_SeedSnapFromOverwatch`, `_test_SeedHandling` and the
  `SeedOW*` params are deleted. The step is scaled only by `GetWeaponHipfireOrSnapshotMul`, i.e. by
  `wep_base_hip_mul` / `wep_base_snapshot_mul` — stats the player already reads.
- The ~40 `ApertureSnapHipMul` assignments in `PATCH_GBO_weapons.lua` are left alone: that file is
  generated, and the property is now inert.

**Scopes**
- `A.ScopeFloorMul = {_6x = 87, _4x = 92, _2x = 96, _1dot5x = 98}` applied in `Rat_ApertureFloor`.
  Moves the asymptote only; `WeaponRange` is untouched, so max aim range, AP, out-of-range checks
  and the AI are unaffected.
- Thresholds now start **later** for bigger scopes, matching the text already on the
  `WeaponComponentEffect` presets: `pso_dragunov_scope` from 2 (+1), `sniper_aim_scope` from 3 (+2),
  `sniper_adv_aim_scope` from 4 (+3), `BonusAccuracyWhenFullyAimed` from 3 only (+2). Kept small —
  above AimAccuracy 12 the decay clamps and further points do nothing.
- `snap_reduc` per magnification (`−10 / −25 / −40`) through the existing `scope_snapshot` channel,
  and `ScopePenalty1/2/3` forced to match the tier, so a bigger scope is strictly worse until the
  aim is paid for. `_2xQuick` (ACOG, WideScope) keeps its authored `+5` speed bonus instead.
- `IncreaseAimAccuracy` removed from every magnification profile — raw AimAccuracy is a weapon stat;
  what the optic contributes goes through the thresholds.
- Previously-untouched optics added to `ApertureComponentTier` + `RAT_SCOPE_ORIGINALS`, but only
  those reachable from a **patched or vanilla** weapon — audited live by `Scope` slot against
  `is_tog_patched`: SSG69, VSS/PSO-1M2, SteyrScout, m76, GW43, G11, TAR21 reflex,
  `ImprovedIronsight_AR15`, plus their `_Master_*` templates. Left alone as out of scope:
  `AWP_Scope_1`, `WA2000_Scope_1`, `NTW_20_Scope_1`, `Caws_Scope_1`, `FN2000_Scope_1`,
  `G11_Rail_7/9` (unpatched ToG weapons only) and `AN94_Scope_1`, `ThermalScope_1/2` (no weapon
  uses them). **Optics still granting `IncreaseRange`: 0** (was 14).
- `RAT_PCT` was a global param-name → percent map, but `bonus_cth` is a percent param on
  GW43/`ImprovedIronsight_AR15` and a plain number elsewhere. Percent typing is now per-component
  (`pct = {...}` on the pristine entry), falling back to the global map.

**Weapon range under aCTH** — `RAT_APERTURE_WEAPON_RANGE`, `{pristine, aCTH}` per weapon, applied and
restored with the optics. Stretch above 20 tiles: **+55% snipers/marksman (capped at 44), +35% MG,
+30% assault rifles, +15% SMG, 0 for pistols / revolvers / shotguns.** Barrett 40→44, PSG1 34→42,
M24 32→39, MG42 30→34, AK74 28→30, HK53 28→29, MP5/Glock unchanged. Grenade launchers and the flare
gun excluded. `apply_range` refuses to write (and prints) if the current value is neither the
pristine nor the aCTH value, so retuning `PATCH_GBO_weapons` cannot be silently overwritten.

**B2 fixed, and it was worse than it looked.** `WeaponRange` is read from `base_WeaponRange`
(`Modifiers.lua`), which lives on the *class* — writing `cls.WeaponRange` alone changes nothing on
any weapon. `apply_range` now writes both, `Rat_ReapplyApertureComponents` rebases the instances
(`SetBase` / `RestoreModifiableValue`) and re-applies *every* component, not just known optics, and
the mode switch itself now calls it. Verified idempotent: re-running leaves one `WeaponRange`
modifier (`Mosin_Barrel_long_1 add=4`), not two, and the aCTH-on → off → on round trip is exact.
The reapply is called from `OnMsg.ApplyModOptions` / `DataLoaded` / `ModsReloaded`, **never from
file scope** — calling it during load aborted the rest of `__ApertureParams.lua` and left half the
parameter table undefined.

**B1 — not a bug in the UI, but a real leak elsewhere.** The player cannot select 0 aim levels while
in shooting stance, so the dominated option was never offered. The underlying desync was real
though: the geometry bumped aim to ≥ 1 while `CTH_scope.lua` read the raw aim, so **scoped
overwatch / interrupt / MG-setup shots escaped the close-range penalty entirely**.
`Rat_EffectiveAim(attacker, action, aim, opportunity_attack, target)` is now the single definition
of "what aim level is this shot really", used by both `Rat_ResolveAngular` and `CTH_scope`.
Verified: the penalty now shows at aim 0, and CTH goes 38 → 40 → 78 → 97 across aim 0-3, monotone.

**Parameters** — `A.ConeRefCTH` 80 → 65, `A.DecayMinPct` 20 → 30, `A.HandlingScale/Min/Max` added,
`A.PBAsHandlingMul` removed.

### Not changed

- `A.FloorPct` (55) and `A.DecayScale` (6) — the runway measures fine; these move the whole game.
- `A.Silhouette` / `A.BaseFactor` — the §6 (a) divergence is a documented deliberate fudge for the
  prone flat penalty. Fixing it means recalibrating both together against `Rat_DbgShots`, which is a
  balance pass of its own.
- `A.MaxCTH` (97) — the §6 (b) clamp is display-only and favours the player.
- The AP economy (§2) — `ShootAP`, `APStance` and `A.AimStep` are where the close-range identity
  actually lives, and that is a design decision, not a fix.

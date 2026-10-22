# Accuracy stages (aCTH) — design note for the next version

Status: current proposal implemented behind a toggle on 2026-10-22 (see Implementation). Written 2026-10-21 after
the AN-94 / G36 burst investigation.

## Current proposal (2026-10-21): base precision + aim

This supersedes the stages model and Alternative B below as the preferred direction; they stay for reference.

**Concept:** an attack's precision = the gun's precision before aiming (today's "Handling") plus what each aim
level buys (AimAccuracy). An aim-3 attack is "base + 3 levels of AimAccuracy". The code already has this shape:
the base sets the starting cone, and each level closes part of what's left toward the floor.

**Round 1 (and single shots):**
- starting cone = R x base precision (positive part only)
- each aim level closes the gap with AimAccuracy
- aim 1-2: snapshot penalty, now also holding big-gun clumsiness (today's negative Handling, x1.06-1.24 on
  SVD / Barrett / MG42)
- aim 0: hipfire penalty

**Follow-up rounds of a string:** round 1 without the aim levels: R x base precision x held weight x the chosen
level's hip/snapshot step. Recoil undoes the sight picture (aim), not the shouldering (step), so the step is never
spared. Round 2+ can therefore never beat round 1 (decided 2026-10-22). The recoil walk (Str force, Marks
correction) does the rest.

**What falls out of it:**
- **Aim pays on round 1 only,** so long strings no longer spread the aim AP. That gives the volume (Str/Marks) vs
  precision (Dex) split.
- **Braced MGs:** their clumsiness lives in the snapshot, which follow-ups keep, so a cheap aim-1 MG string is
  not free. An MG identity for cheap long strings needs its own lever (e.g. the MG snapshot value).
- **Light guns need no compensation:** positive base precision stays at every level (MP5 x0.90, pistols x0.87,
  where AimAccuracy closes little).
- **Big guns aimed:** at aim 3 they lose the leftover Handling factor (MG42 prone ~48 -> ~42, Barrett 15 -> 14,
  SVD 32 -> 31).
- **The graph stays readable:** snapshot and hipfire remain visible round-1 penalties.
- **Expected follow-up cones:** about 57-66' (MP5 59, Beretta 57, AK-74 ~63, AK-47 / FAL / SVD / MG ~66 braced),
  between today's aim 1 (AK-74 77) and aim 2 (52). Autofire identity then comes mostly from recoil.

**Explicit rules:**
1. **Hip strings stay hip.** This falls out of the formula: at aim 0 the follow-up cone is round 1's cone.
2. **Held weight stays in follow-ups.** An unbraced MG42 standing is still x2.12.

**Naming and components (open):**
- **Name: keep "Handling"** (researched 2026-10-21). In shooting usage, handling is how a gun feels and moves in the
  hands: balance, weight distribution, how it points and swings. Point shooting (no sights) gets its accuracy from
  the shooter's familiarity with that weight and balance. So the property behind unaimed precision is handling.
  Tooltip: "how naturally the weapon points without aiming; applies before aim levels and to follow-up rounds in
  automatic fire". The quickness side (bringing the gun up) is the snapshot. "Base Accuracy" was the alternative.
- **Every Handling point source must be re-read:** does the part make the gun more precise unaimed (-> base) or
  quicker / clumsier to bring up (-> snapshot)?
  - **Length is neutral for Handling.** Length already has three owners, each pointing one way: snapshot (short
    wins), hipfire (long wins), AimAccuracy (long wins). Adding it to Handling would stack long guns into both
    deliberate fire and follow-ups.
    - **Owners:** length -> snapshot / hipfire / AimAccuracy. Mass -> recoil and held weight. Handling ->
      ergonomics and balance only (grips, stock type, bullpup balance, design quality).
    - **Barrel parts** therefore lose their Handling points. Short barrel: snapshot + and hipfire - (support points
      close; the old "MP5 good at snapshot, bad at hipfire" rule). Long barrel: the opposite.
    - **Follow-up cones** end up similar across guns, so autofire identity comes from recoil (caliber, RPM, mass,
      bipod). That is where the long-string MG identity lives.
    - **Background:** in real guns, length and mass are an inertia trade-off. Long and heavy is slower but steadier;
      short is quicker but less stable (Wikipedia "Long gun"; shotgun swing lore). The game expresses this through
      the owners above, not through Handling.
  - **Tac / vertical grip:** base (steadier hold).
  - **Folded stock:** snapshot (quick to shoulder), arguably negative base (less stable). It is not a base bonus.

**First measurement:** follow-ups at R x base precision in `Rat_EstimateBurst`, same table as the Phase 1
measurements below.

### Implementation (2026-10-22, behind `A.BasePrecisionModel`)

Set `A.BasePrecisionModel = false` in `__ApertureCTHParams.lua` to return to the old model. Handling data is
untouched (no length-neutral retune yet).

- **Negative Handling cut:** `Rat_GetAperture` divides out the gun's Handling factor above x1.00 when
  aim > `AimStepMaxLevel`. Held weight stays.
- **Follow-up cone:** `Rat_GetAperture(..., base_only)` skips the aim ladder and scope frames but keeps the
  chosen level's hip/snap step and the same cut. `Rat_FollowUpConeMul` returns it as a per-mille of the round-1
  aperture (floored at 1000), so residuals (cover, stance) carry over. It returns nil at aim 0, on single shots
  and on hyperburst.
- **Wired into:**
  - `Rat_SimPlanShots`: scatter of rounds 2+, with sigma_y re-derived and the same inherited recoil.
  - `Rat_SimReplanShot`.
  - `Rat_SimRecoilLadder` / `Rat_EstimateBurst` (9th argument; the BurstAimLossSpeed prototype is removed).
  - `Rat_GetShotConeRatios`.
  - The weapon hint's aimed chart, the recoil debug overlay, and the Rato Dev sheet.

**Measured (stub shooter, all stats 85; hits per attack off > on, 10 / 20 tiles; follow-up cone in brackets):**

| Gun, mode | Aim 1 | Aim 3 |
|---|---|---|
| AK-74 auto 10 | 2.66 > 2.31 / 0.80 > 0.66 [124] | 3.99 > 3.34 / 1.66 > 1.39 [81] |
| AK-47 auto 10 | 1.27 > 1.23 [121] | 1.73 > 1.70 |
| FAL auto 10 | 0.91 > 0.92 [128] | 1.33 > 1.35 / 0.79 > 0.84 |
| MP5 auto 10 | 1.92 > 1.85 [97] | 2.37 > 2.25 [77] |
| AN-94 hyperburst 2 | unchanged 1.20 | unchanged 1.94 / 1.33 |
| AN-94 auto 3 | 1.47 > 1.23 | 2.30 > 1.89 |
| G36 burst 2 | 0.97 > 0.86 | 1.69 > 1.46 |
| G36 auto 3 | 1.16 > 1.04 | 1.92 > 1.67 |
| MG42 prone auto 10 | 2.48 > 1.74 / 0.73 > 0.51 [192] | 6.79 > 5.02 / 2.72 > 1.92 [86] |
| Minimi prone auto 10 | 3.70 > 2.72 [143] | 7.45 > 5.25 [84] |
| MG42 standing auto 10 | 0.28 > 0.19 [460] | 0.74 > 0.72 [199] |

Single shots at aim 3: M24 cone 27 -> 25, Barrett prone 18 -> 17, MG42 prone 48 -> 42; CTH barely moves.

**Read:**
- **Aim on strings now pays on round 1 only.** Light-recoil guns (AK-74, AUG, G36, AN-94 auto) lose 15-20% of
  aim-3 string hits. Heavy-recoil guns (AK-47, FAL) don't move, since recoil already owned their strings.
- **The AN-94 hyperburst** now beats its own 3-round auto per attack at aim 3 (1.94 vs 1.89). The G36's 2-round
  burst still loses to its 3-round auto (1.46 vs 1.67).
- **Aim-1 strings lose too** (AK-74 -13%, AN-94 auto -16%), since rounds 2+ lose aim 1's decay but keep its step.
  Braced MGs lose the most at aim 1 (MG42 -30%, Minimi -26%): their step is the biggest.
- **No inversion:** live, AK-47 crouched at 7 tiles, aim 1 reads 27% then 21%, 17%, 14%... (the first try,
  without the step, read 27% then 39%).
- **MG identity for cheap long strings** is open: it now needs its own lever.

## Problem

1. **Two systems describe the same concept.** The aim-0/1 cone in `Rat_GetAperture` stacks:
   - **Handling** (1.13 import): scales `sigma_0`, fades with each aim level.
   - **Hip/snapshot step** (the original GBO system): `GetWeaponHipfireOrSnapshotMul`, `Rat_StepAttrMul`
     (Reflexes / Str / Agility), CQC, MG setup.

   Both mean "how good is the shot without deliberate aim". Components show up in both (tac grip
   `tac_grip_PB` vs `VerticalGripMul`, light stock, barrels), so every retune is ambiguous.
2. **Deliberate aim spills into the whole string.** Every round of a burst draws from the aimed cone. The
   ~30 AP of aim 3 spreads over a long string, so the lab always favors long autofire. At 10 tiles the
   AN-94's 2-round burst gets 0.49 D/AP against 0.71 for 6-round auto, even though it hits 1.9 of 2.

## Model: each accuracy closes part of the remaining gap, one owner per stage

```
R  = Base x Marks                        reference cone: the shooter, no weapon
F  = floor (WeaponRange / scope)         where deliberate aim converges

aim 1  snapshot    s1 = F + (R - F) x SnapGap        Snapshot Accuracy, Reflexes, components, braced
aim 0  hipfire     s0 = max(s1, R x HipMul)          Hipfire Accuracy, Reflexes / Str, components
aim 2+ deliberate  sk = F + (s(k-1) - F) x decay_k   AimAccuracy, Dex (Hand-Eye), optics, Settled
```

**Why this shape:**
- **No jumps:** the deliberate ladder starts from the snapshot cone, so stages never replace each other.
- **No meaningless sums:** each stage closes a fraction of the gap, so the cone stays between F and its start.
- **No inversions:** hip is `max(s1, ...)`, and deliberate levels only close gap.
- **Hip is independent of snapshot:** HipMul is computed from R, so a gun that's terrible from the hip
  (a sniper rifle) doesn't carry that onto the shoulder.

**Owners:**

| Stage | Owner |
|---|---|
| aim 0 | Hipfire |
| aim 1 | Snapshot |
| each deliberate level | AimAccuracy |
| the floor | Range / scope |

Handling leaves aCTH: its points (tac grip, folded stock, barrels) move into the components' hip/snap
qualities. Old CTH keeps Handling as PB.

## Alternative B: snapshot as the AP price of aiming

Instead of a snapshot cone stage, the snapshot stops being an accuracy penalty and becomes **time to bring the
gun onto target**, which in JA3 is AP. A sniper isn't inaccurate on a quick shot; it's slow. Pricing that as a
cone penalty is what forced the compensation (SVD +44% at aim 1).

| Concept | Today | Alternative B |
|---|---|---|
| Hipfire (aim 0) | cone penalty | stays a cone penalty (no shoulder, no stance) |
| Snapshot | cone step applied after the aim decay | AP cost of aim levels, mostly the first ones |
| Handling | scales `sigma_0` (wrong sign for big guns) | the AP price of aiming: low Handling = slow to aim, not inaccurate |
| AimAccuracy | how much each level closes | unchanged, with no counterweight in the same level |
| Range / scope | floor | unchanged |

**What falls out of it:**
- The aim-1 cone is just the ladder's first level. Each parameter owns one thing.
- **Repeat attacks on the same target:** the first aim level is discounted (already on target). That's the
  old CTH rule in AP terms, without the identity inversion: the sniper still pays its expensive levels, just
  one fewer.
- **Braced** (bipod, set-up MG) makes aiming cheaper, which supports the MG identity.
- It joins the AP economy (stance, cycling, RPM, recoil) instead of being a cone hack. The 100 AP scale
  gives the granularity for per-gun prices.

**Risks and open choices:**
1. **Overlap with shooting stance AP,** which is already "bringing the gun up" and is weapon-dependent.
   Split them: stance = entering the position (once per position), aim price = acquiring this target (per
   attack). Otherwise this becomes a third system for one concept.
2. **High-magnification scopes** currently carry a bigger snapshot penalty. Move it either into aim AP (slow
   to acquire) or into a low-aim cone penalty owned by the optic.
3. **Reflexes** scales the snapshot step today. Here it would make aiming cheaper (fast acquisition), which
   changes what the stat buys.
4. **It doesn't fix the autofire leak by itself:** aim still applies to every round. It still needs the
   follow-up-rounds rule, but now against a clean first level.
5. **UI:** the price per aim level must be readable on the crosshair, since it carries identity the cone
   used to show.

**Complexity:** about the same number of mechanisms as today, and clearer. It removes a cone penalty that
needed compensation and adds per-level AP prices.

**Stages model vs Alternative B:** both give each concept one owner and both need the follow-up-rounds rule.
The stages model keeps the snapshot as accuracy (its own cone stage). B moves it into time (AP).
B fixes Handling's sign for free; the stages model drops Handling in aCTH.

## Follow-up rounds in a string

- Round 1 uses the chosen aim. Rounds 2+ use the **snapshot stage** (`s1`): the shooter is in stance but
  spends no AP aiming between rounds.
- In follow-up rounds the snapshot stat is **Marks** (reflexive correction), not Reflexes.
- **Braced** (bipod deployed, set-up MG, emplacement) improves SnapGap. The gun is already on target and
  the bipod carries the weight, which is where MGs get their long-string identity.
- **Hyperburst** (AN-94, G11): round 2 keeps round 1's aim, because it leaves before the kick
  (`hyperburst` correlation).
- Hip autofire stays hip.
- Recoil is unchanged: Str = force (`cf_max`), Marks = correction (`max_inc`, `accuracy`), and the weapon
  enters through kick, RPM, bipod and mass.

**Expected effects:**
- Aim levels pay only on round 1, so long strings work at low aim. That gives the Str/Marks (volume)
  vs Dex (aimed single shot) split, without a pricing rule.
- The 2-round selective burst competes again, the AN-94 most of all.
- Braced MGs stay best at long strings. Unbraced battle rifles on auto get worse at range, which matches
  the full-power identity.

## Repeat attacks on the same target: recoil takes over from the snapshot

Old CTH skips the snapshot when `aim > 0` and the target is the last one attacked (`GetLastAttack() == target`,
not for Overwatch / MobileShot / RunAndGun / interrupts). Persistent recoil then takes over. aCTH has no such
rule: every attack at aim 1-2 pays the step.

**Goal: one currency for caliber.** After the first attack, single-shot recoil (the persistent offset) carries
the caliber's cost, the same way the recoil walk does in autofire. A full-power round then pays for its kick
in both modes through one mechanism, with Str (force) and Marks (correction) deciding how much. The snapshot
keeps one meaning: target acquisition (the first attack, or a target switch), which is where light guns shine.

**In the stages model:** "already on target" means the snapshot stage is reached for free, deliberate levels
still cost AP, and persistent recoil adds spread. That's the same rule as follow-up rounds inside a string: the
shooter starts from the snapshot stage.

**Don't port it to the current pipeline.** Today's step compensates for aim, so skipping it on repeats gains
in proportion to the gun's aim. Cone at aim 1 with and without the step, stat-100, single shot:

| Gun | With step | Without | Step widens it by |
|---|---|---|---|
| MP5 | 70 | 57 | 19% |
| Beretta 93R | 65 | 58 | 11% |
| AK-74 | 77 | 53 | 31% |
| FAL | 76 | 53 | 30% |
| SVD | 93 | 52 | 44% |
| Barrett prone | 71 | 40 | 44% |
| MG42 prone | 115 | 66 | 43% |

The SVD's repeat at aim 1 would equal today's aim 2 for 10 AP less, and "light guns are good at snapshot"
would vanish on repeats.

**Prerequisites for persistent recoil to carry the weight:**
- **Aim reduces it, doesn't reset it.** `RecoilPersistAimMul` is 100/66/33/0, so a fully aimed shot pays
  nothing for the last one and aimed semi-auto loses the caliber cost.
- **AP heals it.** `RecoilPersistRetainPerAP = 100` means no decay per AP spent. Turn it on so rapid fire
  pays a lot, calm fire pays little, and the full-power round pays more in both.
- **The offset is already caliber-driven:** one kick of the last attack's walk (Str gate, Marks correction).
  The difference exists today; it just barely weighs in.

**Measure:** a sheet view for N repeat attacks on one target at aim k. D/AP by caliber (5.56 / 7.62x39 /
7.62 NATO / SVD) with the snapshot paid only on the first attack.

## Optics on follow-up rounds

Optics act on the **correction** (recoil walk `accuracy` / `max_inc`), not on the cone, so they differ
from aim levels:

| Optic | Effect on correction |
|---|---|
| Red dot / reflex | better (a reference that stays in view) |
| Low magnification (ACOG, 1-4x) | about neutral |
| High magnification | worse (the recoil throws the picture out of the field of view) |

Values per optic go in `RAT_ATT_BALANCE`. Round 1 keeps today's optic behavior.

## Cost and migration

- **The trade-off:** aim 1 becomes "shoulder only", so with max aim 3 there are 2 deliberate levels instead
  of 3. Retune AimAccuracy to close more per level; that's preferred over merging shouldering with the
  first deliberate level.
- **What's affected:** the cone calibrations (d50 table, crit per aim, sheet identities) were made on the
  current pipeline.
- **Migration steps, each one stoppable:**
  1. **Behavior-preserving conversion:** per gun, solve HipMul / SnapGap so aim 0 and aim 1 come out equal
     to today, then turn off the Handling term in aCTH. Measure the aim 2/3 drift. Produce the per-gun
     values for the weapon sheet.
  2. **AimAccuracy retune** for the shorter deliberate ladder.
  3. **Follow-up rounds at the snapshot stage**, behind a param, in the 4 places that must agree:
     `Rat_EstimateBurst`, the real shot simulation, the crosshair, and the sheet.
  4. **Optics on the correction.**

## Measurements so far

- **Prototype:** per-round aim decay by muzzle speed (`A.BurstAimLossSpeed`, 8d961cb, off by default). It
  hurt prone MGs the most (MG42 6 rounds @10 tiles -19%) and spared wild guns (AK-47, FAL; the wider cone
  can even help when the muzzle is off target). It didn't make aim 1 the right choice on long strings
  (AK-74: aim 3 still +25% hits for +13% AP).
  - Conclusion: decay alone isn't enough. The snapshot cone itself must stop carrying unbraced penalties
    into braced follow-ups.
- **Muzzle speed after round 1 (minutes per round):**

  | Gun | Speed |
  |---|---|
  | AN-94 hyperburst | 10 |
  | MG42 prone | ~36 |
  | AK-74 | ~50 |
  | G36 | 60-70 |
  | AK-47 | 70-115 |
  | FAL | 80-160 |
  | MG42 standing | up to 167 |
- **Cones, stat-100 standing** (hip / snap / aim 3):

  | Gun | Hip | Snap | Aim 3 |
  |---|---|---|---|
  | AK-74 | 139 | 77 | 37 |
  | AK-47 | 139 | 84 | 52 |
  | MG42 standing | 354 | 273 | 123 |
  | MG42 prone | 175 | 115 | 48 |

## Phase 1 measurements (2026-10-21)

Live, stat-100 stand-in shooter, default loadouts, standing unless noted, theta 120' (standing torso at 10 tiles),
64 seeded walks. D/AP excludes crit. AP is `GetAPCost`, which includes the shooting-stance entry on the first aimed
attack. Counterfactuals: `A.HandlingPointPct` (Handling), `A.HandlingHeldSlope` (held weight) and
`A.AimStepMaxLevel` (step) set to 0 / -1 around `Rat_GetAperture`.

### Who owns each aim level today

Cone, then the factor each part applies (H Handling, Aim decay, Step hip/snapshot). R = 66 for every gun.

| Gun | aim 0 | aim 1 | aim 2 | aim 3 | Floor |
|---|---|---|---|---|---|
| MP5 | 148 (H .90, Step 2.51) | 70 (H .91, Aim .95, Step 1.23) | 59 (H .89, Aim .92, Step 1.07) | 53 (H .90, Aim .89) | 33 |
| Beretta 92 | 173 (H .87, Step 3.04) | 65 (H .87, Aim 1.00, Step 1.14) | 60 (Step 1.05) | 57 (H .86, Aim 1.00) | 45 |
| AK-74 | 139 (H .95, Step 2.21) | 77 (Aim .83, Step 1.45) | 52 (Aim .71, Step 1.16) | 37 (Aim .56) | 24 |
| AK-47 | 139 | 84 (Aim .92, Step 1.42) | 63 (Step 1.15) | 52 (Aim .80) | 26 |
| FAL | 138 | 76 (Aim .82, Step 1.43) | 51 (Step 1.16) | 38 (Aim .58) | 17 |
| SVD (PSO) | 140 (H 1.08, Step 1.97) | 93 (H 1.06, Aim .74, Step 1.79) | 51 (Step 1.28) | 32 (H 1.03, Aim .47) | 16 |
| Barrett prone | 163 (H 1.24, Step 1.99) | 71 (H 1.22, Aim .50, Step 1.78) | 28 (H 1.17, Step 1.27) | 15 (H 1.07, Aim .21) | 10 |
| MG42 standing | 354 (held x2.12, H 1.19) | 273 (held x2.12, Step 1.81) | 174 | 123 (held x2.12, H 1.16) | 24 |
| MG42 prone | 175 (H 1.19, Step 2.22) | 115 (H 1.19, Aim .85, Step 1.74) | 70 (Step 1.25) | 48 (H 1.14, Aim .64) | 19 |
| AN-94 | 133 | 71 (Aim .73, Step 1.42) | 49 (Step 1.14) | 38 (Aim .58) | 24 |

- **Aim 0:** the hip step (x2-3). Handling moves it by 5-24%.
- **Aim 1:** the snapshot step, on every gun except pistols and the standing MG42 (held weight). Deliberate aim closes
  only 0-50% here.
- **Aim 2:** shared; the step is still +5-29%.
- **Aim 3:** AimAccuracy on rifles. On the MP5, Handling (-10%) equals all aim levels together; on pistols the
  AimAccuracy closes nothing and the cone is R x Handling.
- **Handling's sign:** x1.06-1.24 on the SVD, Barrett and MG42 at every level, never fully fading.
- **Share of the aim 1 -> 3 gain that is just the step going away:** MP5 74%, pistol 100%, AK-47 73%, MG42 prone 63%,
  AN-94 56%, SVD 55%, FAL 52%, AK-74 51%, Barrett prone 37%. This is what autofire spreads across its rounds.

### Models as sketched

- **Stages:** behavior-preserving conversion. s0 / s1 = today's aim 0 / 1; one per-gun decay keeps aim 3 equal to
  today (aim 2 moves 2' at most). Follow-up rounds at today's s1.
- **B:** Handling and the snapshot step leave the cone; hip step and held weight stay. Follow-up rounds at B's aim-1
  cone. Price sketch: level 1 = 10 AP x the gun's snapshot mul; levels 2+ = 10 AP x Handling.

**Single shot, cone / AP / CTH:**

| Gun | aim 1 today | aim 1 B | aim 3 today | aim 3 B |
|---|---|---|---|---|
| MP5 | 70 / 45 / 77% | 63 / 42 / 84% | 53 / 65 / 92% | 59 / 60 / 87% |
| Beretta 92 | 65 / 37 / 82% | 66 / 31 / 81% | 57 / 57 / 89% | 66 / 49 / 81% |
| AK-74 | 77 / 65 / 70% | 55 / 69 / 91% | 37 / 85 | same |
| AK-47 | 84 / 60 / 64% | 61 / 63 / 86% | 52 / 80 | 53 / 82 |
| SVD | 93 / 65 / 56% | 49 / 79 / 95% | 32 / 85 | 31 / 101 |
| Barrett prone | 71 / 80 / 76% | 33 / 99 / 97% | 15 / 100 | 14 / 123 |
| MG42 prone | 115 / 99 | 56 / 117 | 48 / 119 | 42 / 141 |

B's light guns lose the full-aim edge (Handling now buys AP); precise guns get tight quick shots. The level-1 price
that keeps today's aim-1 D/AP at 10 tiles: MP5 14, pistol 10, AN-94 23, AK/FAL 29-31, Barrett 32, SVD 55 AP.

**Burst vs auto, best D/AP @ aim (p stance paid, f already in stance):**

| Mode | Today | Stages | B |
|---|---|---|---|
| AN-94 2-round burst | 0.75 hip / f 1.19 @1 | 0.75 hip / f 1.19 @1 | 0.73 @1 / f 1.35 @1 |
| AN-94 6-round auto | 0.84 @2 / f 1.13 @2 | 0.76 @1 / f 1.05 @1 | 0.87 @1 / f 1.20 @1 |
| AK-74 auto | 0.84 @3 / f 1.21 @2 | 0.73 @1 / f 1.10 @1 | 0.86 @1 / f 1.28 @1 |
| AK-47 auto | 0.53 @2 | 0.53 hip | 0.58 @1 |
| FAL auto | 0.47 hip / f 0.65 @2 | same | 0.48 @1 / f 0.71 @1 |
| MP5 auto | 0.65 @1 | 0.65 @1 | 0.73 @1 |
| MG42 prone auto | 1.48 @3 / f 2.76 @3 | 1.12 hip, aimed 0.83-0.87 / f 1.87 | 1.46 hip, 1.40 @1 / f 2.65 @1 |

- Both models make aim 1 the best level for 6-round strings.
- **Stages breaks braced MGs:** today's prone s1 (115', snapshot x1.74) puts an unbraced penalty on every follow-up,
  and hipfire wins. The braced SnapGap is a prerequisite.
- B keeps the MG because its follow-up cone (56') is clean.
- The AN-94 burst beats auto only with the stance already paid.

**3 single shots on one target, aim 1** (attacks 2-3 skip stance in every model). D/AP, CTH of attacks 2 / 3:

| Gun | Today | Old-CTH port (skip step) | Stages (aim 1 free) | B (level 1 free) |
|---|---|---|---|---|
| MP5 | 0.43 (73/67) | 0.48 | 0.54 | 0.61 (80/73) |
| AK-74 | 0.43 (69/66) | 0.52 | 0.51 | 0.63 (89/85) |
| FAL | 0.52 (63/47) | 0.61 | 0.62 | 0.77 (81/62) |
| SVD | 0.44 (52/44) | 0.61 | 0.52 | 0.77 (88/74) |

At 20 tiles: SVD 0.14 / 0.24 / 0.17 / 0.37, MP5 0.17 / 0.20 / 0.20 / 0.25. The port gains in proportion to the step
(SVD +39%, MP5 +12%); stages gives every gun ~+20% and keeps the order; B makes rifle quick-repeats dominant unless
persistent recoil carries real weight.

### Findings for both models

- **Shooting-stance AP is already an acquisition price** (MP5 15, pistol 7, AK 30-35, SVD 35, Barrett/MG42 50-55),
  paid on the first aimed attack and free on repeats: that is B's "level 1 discounted" rule. A separate level-1 price
  would mostly duplicate it. With stance paid, hipfire wins D/AP at 10 tiles for the FAL, SVD and AK-74.
- **Persistent recoil per single shot doesn't follow caliber** (offset in minutes): Beretta 92 137, FAL 128, SVD 107,
  AK-47 103, MP5 74, Barrett prone 50, AK-74 49, AN-94 47. At aim 1 it costs 1-11 CTH points.

### Current read

B is the cleaner fix for the leak and for Handling's sign, with no braced special case. Its cost is the compensation
the step hid: precise guns need something to price quick shots back, either a large first-level price (overlapping
stance AP) or an optic-owned low-aim penalty. Candidate: fold the acquisition price into stance AP, re-charged on a
target switch. Stages is the safer migration but only works after the braced SnapGap, and keeps the step's
compensation inside s1.

**Caveats:** 10 tiles saturates rifles at 97% from aim 2; the B price list is a sketch; persistent recoil uses an
area-equivalent circle and an upper-bound offset for attack 3.

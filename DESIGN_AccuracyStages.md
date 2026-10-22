# Accuracy stages (aCTH) — design note for the next version

Status: idea, not implemented. Written 2026-10-21 after the AN-94 / G36 burst investigation.

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

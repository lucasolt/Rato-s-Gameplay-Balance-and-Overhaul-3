# Recoil model — second order, 1.13 style

Spec for replacing the first-order binary recoil with a position + velocity model whose
counter-force aims the muzzle back at the target centre. Reference implementation is JA2 1.13
NCTH (`Tactical/LOS.cpp`, `CalcCounterForceChange` / `CalcCounterForceMax` /
`CalcCounterForceAccuracy`), adapted to our angular geometry.

---

## 1. Why

The current model has one state — position — and each shot adds one of two values to it. Every
complaint about it traces back to that:

* **Control is binary** because there is nothing continuous to modulate. Without a velocity, the
  only thing left to roll is "held / not held".
* **Overcorrection is fake.** `RecoilCorrectPct - RecoilControlResidual` is a fixed downward
  fraction of one kick. It always steps down by the same amount and can never *pass* the target
  and come back. Real overshoot is a velocity phenomenon: the muzzle is moving toward centre too
  fast and sweeps past it.
* **Skill is a coin, not a force.** A merc who wins the roll controls the gun almost perfectly; a
  merc who loses it controls nothing. There is no "this merc holds every shot, but only partly".

Second order fixes all three with one change: **counter-force acts on velocity, not position.**

HEADROCK's own framing, which is the design target:

> the shooter wants to reach 0,0 while at the same time having the right amount of CF to hold the
> muzzle there against the gun's recoil — resulting in the muzzle being both pointed directly at
> the target AND completely stationary. Doing so is very hard.

## 2. What we do NOT need

**No closed-form burst CTH.** This is the constraint that shaped the current design and it is gone.
`Rat_BurstShotCTH` and the whole binomial mixture exist only to produce an exact per-shot hit
probability without simulating. We do not display one.

Consequence: the estimator can be **Monte Carlo over the same step function the bullets use**. There
is then exactly one implementation of the recoil, so prediction and bullet cannot drift apart — a
failure mode the current code has explicit comments warning about.

---

## 3. State

All quantities are **2D vectors in the target plane**, angular, in **minutes of arc**. `x` is
lateral (positive = right), `y` is vertical (positive = up). Time is measured in **shots**, so
`dt = 1` and only two units exist in the whole model.

| symbol | unit | meaning | init |
|---|---|---|---|
| `p` | minutes | muzzle offset from the aim point | `0, 0` |
| `v` | minutes / shot | muzzle angular velocity | `0, 0` |
| `cf` | minutes / shot | counter-force the shooter is currently applying | `0, 0` |

`p` is the only one that reaches the bullet. `v` and `cf` are internal.

The weapon's dispersion cone (`sigma`) is unchanged and still applies around `p` on every shot.
Recoil moves where the gun points; it does not widen the cone.

## 4. The step

Everything below runs once per shot, in this order.

```
--- 1. FIRE. The bullet leaves from p, scattered by the weapon cone.
    impact = ShotScatterPoint(attack_pos, WalkPoint(aim_pos, p), sigma)

--- 2. WHERE THE SHOOTER WANTS THE VELOCITY TO GO.
    PD controller aiming at (p, v) -> (0, 0):
    a_des  = -(Kp * p + Kd * v)

--- 3. WHAT COUNTER-FORCE THAT IMPLIES. cf must also cancel the incoming kick.
    cf_des = a_des - kick
    delta  = clamp(cf_des - cf, +/- MaxIncrement)   -- grip cannot change instantly

--- 4. MANDATORY ERROR, per axis, applied to the CHANGE not the position.
    mag        = max(MinError, ErrorRatio * |delta| * (100 - accuracy) / 100)
    delta.x   += rand(mag) * randsign()
    delta.y   += rand(mag) * randsign()

--- 5. APPLY, CLAMPED BY HOW MUCH FORCE THE MERC HAS.
    cf = cf + delta
    if |cf| > CFMax then cf = cf * CFMax / |cf| end   -- Pythagorean, not per-axis

--- 6. INTEGRATE.
    v = v + kick + cf
    p = p + v
```

### The controller gains

For the discrete double integrator (`v += a; p += v`), the closed loop is

```
z^2 - (2 - Kd) z + (1 - Kd + Kp) = 0
```

A double root at `r = 1 - 1/T` — critical damping, settling in about `T` shots — gives

```
Kd = 2 / T
Kp = 1 / T^2
```

`T` (`SettleShots`) is the one skill-driven number here: a better shooter tries to null the muzzle
in fewer shots. Expose `Damping` as `Kd = Damping * 2 / T` so the response can be pushed
under- or over-damped deliberately.

**Default `Damping = 1`.** At critical damping the nominal trajectory does not overshoot at all,
which means **every overshoot in the game is a mistake the shooter made** — the error term is the
only thing that can send a shot past centre and out the other side. That is the behaviour asked
for. Setting `Damping < 1` makes the gun oscillate even for a perfect shooter, which is a
different (and probably worse) claim about the world.

### Why the error is applied to `delta`

The error perturbs the *correction*, not the position. Undershoot the correction and the muzzle is
still on the kick side; overshoot it and the muzzle crosses centre and keeps going. Both are the
same mechanism at different signs, which is exactly "erra de um lado ou do outro".

1.13's shape is worth keeping verbatim: the error is **proportional to the size of the correction
being attempted** (`ErrorRatio * |delta|`). Hauling a .308 back generates more error than nudging a
9mm, so the caliber's difficulty falls out of the mechanism instead of being tuned in by hand.

And `MinError` is a floor, never scaled away by skill. Nobody is ever perfect. This is the knob
that enforces "mercs muito bons não podem ficar PERFEITOS", and it is a floor on error rather than
an artificial ceiling on the stat, which is a much cleaner way to say it.

### The caliber gate

At steady state the shooter wants `kick + cf = 0`, so `|cf| = |kick|`. But step 5 clamps `|cf|` to
`CFMax`. Therefore:

> **If `CFMax < |kick|`, the muzzle can never be stabilised.** `v` grows every shot and the burst
> runs off the target no matter how well the shooter aims the correction.

This is a hard, legible, physical threshold, and it is the honest version of "mercs com pouca força
vão deixar a arma subir muito". It replaces the current Strength-vs-breakpoint multiplier with a
statement you can read off two numbers in the same unit.

---

## 5. Constants

| name | unit | drives | comes from |
|---|---|---|---|
| `KickMag` | minutes / shot | raw torque of one shot | weapon + caliber + components |
| `KickAngle` | degrees | direction, up and right | weapon (global default first) |
| `CFMax` | minutes / shot | how much force the merc can bring | Strength, Agility, stance, bipod |
| `MaxIncrement` | minutes / shot | how fast the grip can change | constant to start |
| `SettleShots` (`T`) | shots | how aggressively they try to return | Dexterity, Auto Weapons perk |
| `Damping` | — | 1 = critical (overshoot only from error) | balance constant |
| `ErrorRatio` | — | sloppiness in proportion to correction size | balance constant |
| `MinError` | minutes / shot | the floor nobody escapes | balance constant |
| `Accuracy` | 0–100 | reduces error above the floor | Dexterity, Marksmanship, Auto Weapons |

Everything with a unit is in minutes or minutes/shot, and **θ is also in minutes**. That is the
point of the rewrite as much as the dynamics are: balance statements become directly checkable
instead of superstitious.

θ for a standing torso at 10 tiles is 167'. So:

* "the second shot must still threaten" → `|v|` after shot 1 must be well under θ.
* "a competent merc stays on target through shot 4" → `|p|` at shot 4 under θ/2.
* "a merc who cannot handle this caliber loses the burst fast" → `CFMax < KickMag`, and the ladder
  falls off on its own.

Compare with today's `mod`, `control`, `excess`, `gun`, `hold`, `climb` — six numbers, five of them
dimensionless, none comparable to the target.

### Splitting the existing chain

`Rat_GetRecoilBaseMod` already separates weapon from shooter and that split is exactly the one the
new model needs:

* `mod / control` — the stance-invariant weapon value (173.81 for the MP5, identical standing,
  crouched and prone) → feeds **`KickMag`**.
* `control` — everything the shooter contributes → feeds **`CFMax`** (inverted: lower control means
  more force available).

So the tuned chain in `FUNCTIONS_recoil.lua` survives. Only its two outputs get pointed at different
things.

---

## 6. The estimator

```lua
Rat_EstimateBurst(prof, theta, sigma, num_shots, samples, seed)
    -> { cth, px, py, spread, offset, speed }   -- per shot, in minutes
```

Built against the profile rather than against `(attacker, weapon, action, target)`: every caller
already has the geometry resolved, and re-deriving it would have been the second implementation
this rewrite exists to avoid. `Rat_SimRecoilLadder(..., want_cth)` is the wrapper that turns a
unit and a weapon into one.

* **Same step function as the real shot.** Not a parallel implementation.
* **Seeded, not unsynced.** `BraidRandomCreate(seed)` with a fixed seed from the params. This
  turned out to be better than `AsyncRand`: the ladder becomes a deterministic function of the
  profile, so it cannot desync co-op *and* it cannot flicker between calls. Real bullets keep
  using `attacker:Random`.
* **Off the real shot path.** `Rat_ISqrt` costs ~5.5 us and `Rat_RiceCTH` ~6.9 us, so 384 samples
  is ~100 ms — far too much per burst. The bullet reads `p` directly and never needs a
  probability, so `want_cth` is opt-in: debug tools pass it, `Rat_GetShotConeRatios` passes 48
  (it produces a *ratio*, and the vanilla pipeline is the only consumer), and the real shot passes
  nothing. `Rat_SimSnapshot` derives the displayed CTH and cone from the `p` that bullet actually
  had, which is more exact than the ladder's mean anyway.
* **Verified against the bullets.** 3000 synced bursts vs the seeded estimator, same profile:
  48 samples +4 %, 128 +5 %, 384 +1 % on mean `|p|` at shot 6. Sampling error, converging.

`offset` and `speed` are what make the model tunable: the hit percentage says a burst went wrong,
the velocity says why.

## 7. What this deletes

Removed outright:

* `Rat_BurstShotCTH`, `Rat_Binomial` — the whole binomial mixture
* `Rat_RecoilYawFactors`, `Rat_YawCos` — direction variance folded into σ; direction is now
  deterministic and the spread comes out of the simulation
* `Rat_RecoilHeld`, `Rat_RecoilHeldStep` — the coin
* `Rat_RecoilKick` in its present form
* the `gun` / `hold` / `excess` machinery inside `Rat_GetRecoilClimb`
* params `RecoilClimbBase`, `RecoilClimbMax`, `RecoilControlPivot`, `RecoilControlGain`,
  `RecoilControlMax`, `RecoilControlResidual`, `RecoilCorrectPct`, `RecoilWalkYaw`
* `RecoilMode = "growth"` and `RecoilGrowthBase` / `RecoilGrowthMax` — already unreachable

Kept:

* `Rat_GetRecoilBaseMod` and the whole tuned chain in `FUNCTIONS_recoil.lua`
* `Rat_RecoilWalkAxis`, `Rat_RecoilLateralAxis`, `Rat_RecoilWalkPoint` — the geometry
* `Rat_RiceCTH` / `Rat_RayleighCTH` — still needed for the single-shot cone
* `Rat_ShotScatterPoint`

The model gets larger; the code gets smaller and the tuning surface shrinks to nine constants that
all have units.

## 8. What NOT to copy from 1.13

1.13 scales recoil by `uiRange / NORMAL_RECOIL_DISTANCE` because its muzzle offsets are linear in
the target plane. **Ours are angular.** Distance already enters through the geometry, with θ falling
as 1/d. Copying that scaling would count distance twice.

Also deferred, not rejected: `CalcPreRecoilOffset` (the first bullet of a volley being
pre-compensated by experienced shooters). Nice flavour, orthogonal to this, separate change.

---

## 9. Calibration — done

Anchored on MP5 / BurstFire / theta 167' / sigma 115', against the `1cc229c` ladder. Shipped
values: `KickBase 52`, `CFMaxBase 78`, `ControlGain 260`, `MaxIncrement 60`, `SettleShots 3`,
`Damping 100`, `ErrorRatio 140`, `MinErrorPct 25`, `KickAngle 12`.

Measured, at Dexterity 60 (the old model had no Dexterity axis, so this is the like-for-like row):

| merc | old (`1cc229c`) | new |
|---|---|---|
| M50 S50   | 65/42/20/8/3/1   | 65/60/41/16/2/0 |
| M100 S50  | 65/51/37/25/17/11 | 65/60/47/34/25/18 |
| M50 S100  | 65/47/30/17/9/5  | 65/60/45/26/12/3 |
| M100 S100 | 65/55/45/35/28/21 | 65/60/48/38/33/30 |

The ordering holds in every column and shots 4-6 land close. **Shot 2 is deliberately more
generous** — 60 % for everyone against 42-55 % before. Reproducing the old shot 2 would have
required `kick` larger than what any shooter can oppose on the first bullet, i.e. exactly the
"second shot can barely hit anything" the rewrite was asked to remove. The skill separation now
opens from shot 3, which is where the old ladder had it anyway.

Two things fell out that the spec had not predicted:

* **The MP5 sits ON the gate**, and that is what makes the ladder work: `kick` 90 against `CFMax`
  60 (weak) to 122 (strong). The weak shooter cannot stabilise an SMG; the strong one can, with
  headroom. Below `ErrorRatio` ~100 the deterministic gate drowns the Dexterity noise entirely and
  accuracy stops mattering — 140 is where the two coexist.
* **`MinErrorPct` is load-bearing, not a detail.** At 10 % the complete merc (M100 S100 D90) froze
  at 59 % from shot 3 on — immune to recoil. At 25 % he falls to 45 % and is still clearly the best.

Heavy calibers, measured: AK47 and MG42 both `kick` ~115, gated for a weak shooter (`CFMax` 40)
and passable for a strong one (117-128). A mounted MG42 takes a weak shooter from unusable to
65/57/35/23/19/17 — the mount is force he did not have to bring.

## 10. Decisions taken

1. **`MaxIncrement` is a constant.** As recommended. It also turned out to be the ceiling on
   `|delta|`, so it sets the scale `ErrorRatio` reads — conflating it with force would have made
   both untunable, exactly as feared.
2. **Stat mapping: `CFMax` from `control`, `Accuracy` from raw Dexterity.** Not Strength + Agility.
   `control` already aggregates Marksmanship, stance, bipod, Strength-vs-caliber and perks, and it
   is *tuned* — re-deriving force from raw stats would have thrown that away for nothing.
   Dexterity is the one attribute the chain does not already spend, so nothing is counted twice.
   `SettleShots` stayed a constant: three skill-driven quantities at once makes calibration
   ill-posed.
3. **`KickAngle` is global** (12 degrees right of vertical). Per-weapon needs an editor preset.
4. **Samples: 384** by default, 48 for the cone ratios. Measured, see §6.

Also changed from the spec while building:

* **ROF shrinks the shooter's side (`CFMax`, `MaxIncrement`) instead of inflating the kick.** A
  cartridge does not kick harder because the trigger is pulled faster; what a high rate of fire
  costs is time to reassert the grip. The old code multiplied the climb.
* **The `control -> CFMax` map has a floor of 30 on the divisor.** A mounted MG drives `control`
  near 50, which `ControlGain 260` takes negative; without the floor one point of control swung
  the force from 239 to 716 minutes/shot.

## 11. Open for the author

* **The Auto5 is not stabilisable by anyone** — `kick` 142 against a best-case `CFMax` of 128, so
  even M100 S100 gets 65/55/26/9/2/0. Physically defensible for a 12-gauge, but it is a balance
  statement, not a measurement. Lower `KickBase`, or give shotguns their own kick scale.
* **Shot 2 at 60 % for everyone** (see §9) is a deliberate departure from the old ladder.
* `CalcPreRecoilOffset` — the first bullet of a volley pre-compensated by experienced shooters —
  is still deferred, and still orthogonal.

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
Rat_EstimateBurst(attacker, weapon, action, target, num_shots, samples, seed)
    -> { hit_pct per shot }, { mean |p| per shot }, { mean |v| per shot }
```

Runs the step above `samples` times and counts hits. Requirements:

* **Uses the same step function as the real shot.** Not a parallel implementation. This is the
  whole reason we can afford a stochastic model.
* **Unsynced rng.** `AsyncRand(n)` — verified in the live process, does not touch the synced
  stream, so estimating never desyncs co-op. Real bullets keep using `attacker:Random` /
  `attacker:RandRange`.
* **Seeded for reproducibility.** `BraidRandomCreate(seed)` — verified: same seed gives the same
  stream. Pass a fixed seed so a balance number does not flicker between calls, and so a specific
  bad volley can be replayed in the visualiser.

Return `|p|` and `|v|` per shot alongside the hit percentage. Those two are what make the model
tunable — the hit percentage tells you *that* it went wrong, the velocity tells you *why*.

---

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

## 9. Calibration

Anchor on the current ladders so the rewrite is not also a balance change. Reference case is the
one every measurement in this branch used: **MP5, BurstFire, standing, θ 167', σ 115'**.

Post-decoupling values at `HEAD` (`1cc229c`), measured live:

| merc | climb | hold | CTH shots 1–6 |
|---|---|---|---|
| M50 S50 | 166' | 18 % | 65/42/20/8/3/1 |
| M100 S50 | 141' | 39 % | 65/51/37/25/17/11 |
| M50 S100 | 152' | 30 % | 65/47/30/17/9/5 |
| M100 S100 | 129' | 50 % | 65/55/45/35/28/21 |

Procedure:

1. Fix `Damping = 1`, `MinError`, `ErrorRatio` at first guesses.
2. Solve `KickMag` and the `control -> CFMax` mapping against the **two extreme rows** — two
   anchors, two unknowns.
3. Check the two middle rows land between them. If they do not, the `control -> CFMax` curve is
   the wrong shape, not the kick.
4. Only then tune `SettleShots` and `MinError`, which control the *shape* of the falloff rather
   than its endpoints.

Verify on a second weapon with a very different caliber before touching anything else — the whole
point of a raw per-caliber kick is that the heavy weapons should behave differently, so a model
that reproduces the MP5 and nothing else has failed.

---

## 10. Open decisions

1. **`MaxIncrement`: constant or skill-driven?** 1.13 has it as an INI constant. Recommend
   constant first — it is the difference between "can't change grip fast" and "isn't strong
   enough", and conflating them makes both untunable.
2. **JA3 stat mapping.** 1.13 uses Str/Agi/ExpLevel for `CFMax` and Dex/Wis/Agi/AutoWeapons for
   accuracy. Proposal: `CFMax` from Strength + Agility, `Accuracy` from Dexterity + Marksmanship.
   Keeping Marksmanship in accuracy preserves the stat that currently feeds recoil.
3. **`KickAngle` per weapon or global?** Per-weapon is right physically but needs a preset field,
   which means the in-game editor. Recommend a single global constant first; it costs nothing to
   make it per-weapon later.
4. **Sample count** for the estimator against UI refresh cost, if it is ever called outside debug.

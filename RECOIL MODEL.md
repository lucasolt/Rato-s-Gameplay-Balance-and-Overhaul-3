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

`Rat_GetRecoilBaseMod` already separates weapon from shooter, but the shooter side is *two* things
and they must not be one number. `Rat_GetRecoilControl` now returns both separately:

| output | feeds | meaning |
|---|---|---|
| `gun` = `mod / control` | **`KickMag`** | the cartridge. Stance- and skill-invariant. |
| `str_control` | **`CFMax`** | Strength against **this caliber's** breakpoint |
| `other_control` | **`MaxIncrement`** | stance, bipod, Marksmanship, perks |

`str_control` comes out of `GetCaliberStrRecoil` already relative to the weapon — 1.00 whenever
Strength clears the breakpoint, 1.71 far below it — so `CFMax` is set as a *fraction of this
weapon's kick*. The gate then reads **"do you have the muscle for this caliber"**, not "is this
caliber big". A merc with Strength to spare holds down a 9mm however poor his marksmanship, and
Strength above the breakpoint correctly stops mattering at all.

Skill lives in `MaxIncrement`: how much of the grip is already on the gun when bullet 2 leaves.
Once the kick is weapon-only — which is the whole point — that is the *only* place a shot-2
gradient can come from.

Two consequences worth stating, because both bit during calibration:

* **The error floor must come from the neutral increment**, never from this merc's `MaxIncrement`.
  Scaling it with a skill-driven quantity makes skill raise its own error.
* **`Accuracy` needs `other_control` as well as Dexterity.** With Dexterity alone, skill buys a
  bigger correction *and* a proportionally bigger error (`ErrorRatio * |delta|`), and cancels itself.

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

Anchored on MP5 / BurstFire / theta 167' / sigma 115'. Shipped: `KickBase 95`, `CFHeadroom 170`,
`StrGain 200`, `MaxIncBase 70`, `OtherGain 250`, `SettleShots 3`, `Damping 100`, `ErrorRatio 140`,
`MinErrorPct 25`, `KickAngle 12`.

### The old-CTH reference, measured properly

Earlier revisions of this file quoted a synthetic M50-M100 / S50-S100 sweep. That sweep **crosses
caliber breakpoints**, so it attributed the breakpoint cliff to Strength as a smooth gradient. The
numbers below come from `get_recoil` on real mercs, bare weapons, aperture off, 8 tiles.

Old CTH resolves to a single linear law:

```
loss = round( 0.5 * ( mod/100 * -90 * dist/36  -  5 ) )      dist in tiles, clamped at 36
```

Three consequences worth keeping in mind:

* **Distance is a plain multiplier.** 8 -> 14 tiles is x1.6 on every merc and every weapon at once;
  it changes no ordering. Field numbers taken at different ranges are not comparable.
* **The merc axis is nearly flat.** Barry / Grizzly / MD on the AK47: -24 / -23 / -23, about 5 %
  apart. `mod` spans 160 -> 150 across the whole roster.
* **The caliber axis is the strong one.** Barry, 8 tiles: MP40 -20, AK47 -24, FNFAL -27, G3 -30.

### Strength above the breakpoint, in the OLD model

Grizzly, Strength swept, per weapon (breakpoint in brackets):

| | S50 | S70 | S80 | S95 |
|---|---|---|---|---|
| MP40 (48) | -20 | -19 | -19 | -19 |
| AK47 (71) | -30 | -24 | -24 | -23 |
| FNFAL (77) | -34 | -28 | -26 | -26 |

**Old CTH flattens above the breakpoint as well** — 1-2 points out of 26, while the cliff at the
breakpoint is worth ~24 %. `other_control` stays pinned at 91 through the entire sweep, so Strength
reaches the old model through exactly one channel. A heavier caliber moves *where* the cliff sits,
not what muscle above it buys.

So `MaxIncrement` reading the full `control` is a **departure** from old CTH, not a reproduction of
it: it is what gives Strength above the breakpoint a small continuous benefit the old model never
had. Same sweep through the new model — FNFAL S80 65/37/7/3/2/3, S95 65/38/9/5/5/5.

### New vs old, same mercs and weapons

Barry, 8 tiles, ladder from base 65:

| | old (linear) | new |
|---|---|---|
| MP40  | 65/45/25/5/0/0 | 65/54/28/18/16/15 |
| AK47  | 65/41/17/0/0/0 | 65/43/8/2/1/2 |
| FNFAL | 65/38/11/0/0/0 | 65/36/3/0/0/0 |

The heavy calibers track old CTH closely on shots 2-3. The MP40 is where they part: kinder early,
and it keeps a floor where the old ladder runs to zero.

Two scale facts that are not obvious and cost time:

* **`KickBase` has to put the kick near theta.** Shot 2 fires from `kick - cf1`; if that is small
  next to the cone, Rice barely moves and shot 2 is the same for everyone no matter how much skill
  varies. 165' against a 167' torso is the right order.
* **`SettleShots` is small (3) on purpose.** `Kp = 1/T^2` is the ONLY term that pulls the muzzle
  back to the target; `Kd = 2/T` merely brakes it. At T = 6 Kp is 12x weaker than Kd and the muzzle
  coasts to a halt wherever it happens to be — which reads, correctly, as compensating against the
  previous shot rather than against the original aim. At T = 3 the return is real: |p| for a
  complete merc goes 0 -> 53 -> 83 -> 95 -> 97 -> 97. The cost is that his ladder converges instead
  of falling forever, which is the direct consequence of "aim back at the target" and is a
  deliberate trade, not a bug.

## 10. Decisions taken

1. **`MaxIncrement` is skill-driven after all**, from `other_control`. The spec recommended a
   constant to keep "can't re-grip fast" apart from "isn't strong enough" — but with the kick
   weapon-only, a constant leaves shot 2 identical for every shooter. The separation the
   recommendation wanted is preserved anyway, because force now comes from `str_control`.
2. **Stat mapping: `CFMax` from `str_control`, `MaxIncrement` from `other_control`, `Accuracy`
   from Dexterity scaled by `other_control`.** Not Strength + Agility, and not the aggregate
   `control` — see §5.
3. **`KickAngle` is global** (12 degrees right of vertical). Per-weapon needs an editor preset.
4. **Samples: 384** by default, 48 for the cone ratios. Measured, see §6.

Also changed from the spec while building:

* **ROF shrinks `MaxIncrement` only.** Not the kick (that is the cartridge) and not `CFMax` (that
  is muscle). What a high rate of fire costs is time to reassert the grip.
* **Both control maps floor their divisor at 30.** A mounted MG drives both factors far down, and
  without the floor one point of control swung the result wildly.

## 11. Open for the author

* **The merc axis is amplified relative to old CTH.** Sitting near the stability gate turns a 6 %
  spread in `control` into roughly 2x on the tail. Measured on real mercs (MP40, shot 6, Barry vs
  MD): `OtherGain` 250 -> 15 vs 28, 150 -> 15 vs 20, 100 -> 14 vs 17. Old CTH's own spread is ~5 %,
  so 100 is the faithful setting and 250 is a deliberate choice to give bursts a skill gradient.
* **Shot 2 is kinder than the old ladder for a poor shooter** — 50 % against 42 %. Reproducing 42
  would need a kick larger than any shooter can oppose on the first bullet, which is the
  "second shot can barely hit anything" the rewrite was asked to remove.
* **The tails floor rather than reaching zero** (9 % at shot 6 for the worst merc, against 1 %
  before). That is the settled state of a stabilised muzzle plus the error floor. Raising
  `MinErrorPct` deepens the tail but flattens the skill spread with it.
* **Distance bites harder here than in old CTH at shot 2.** The offset is angular and the target's
  angular radius shrinks with range, so the penalty compounds rather than scaling linearly. Barry
  with an AK at 14 tiles: old 65/25/0, new 66/19/0.
* `CalcPreRecoilOffset` — the first bullet pre-compensated by experienced shooters — is still
  deferred, and still orthogonal.

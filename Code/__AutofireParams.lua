---- Selectable-length autofire (AutoFire and MGBurstFire). Logic in FEATURE_VariableAutofire.lua.
const.Combat.Autofire = {
    MinShots = 1,
    ---- autofire and bursts cost a Single Shot for BaseShots rounds, plus AutoFireCustomDeltaAP (per-gun
    ---- weight, AutoFire only); each round past BaseShots pays by RPM (BurstRPM in a burst)
    BaseShots = 1,
    ---- AP per extra round at RPMRef; scales by RPMRef / weapon.RPM
    APPerRoundRef = 750,
    RPMRef = 600,
    ---- vanilla AutoFire suppressed the target even on a miss; only bursts this long still do
    SuppressMinShots = 6,
    ---- length the AI uses for its AutoFire signature (the long, suppressive burst)
    AILongShots = 6,

    ---- Overrun: extra rounds slip out; they spend ammo and AP (clamped at 0 AP).
    ---- Chance on (100 - Composure)^1.5, from Best at Composure 100 to Worst at 0.
    OverrunChanceBest = 4,
    OverrunChanceWorst = 70,
    OverrunChanceMax = 70,
    OverrunStatusChance = {Suppressed = 10, PinnedDown = 15, Panicked = 30, Berserk = 30},
    ---- % of the RPM deviation from RPMRef applied to the Composure chance: 50 -> 1200 RPM x1.5, 400 x0.83
    OverrunRPMWeight = 50,
    ---- an overrun fires 1 extra round, then each further one slips out with this chance (geometric):
    ---- RPM x per-1000 / 1000, capped; 600 RPM -> 30%: +1 70%, +2 21%, +3 6%
    OverrunContinuePer1000RPM = 50,
    OverrunContinueMax = 60,
    OverrunMaxRounds = 5,
    ---- tapping a single round in autofire: chance per 1000 RPM, times (100 - Composure)%
    SingleTapChancePer1000RPM = 40,

    ---- Psycho: on proc, autofire doubles its length for free (AP already paid); added rounds capped
    PsychoProcChance = 6,
    PsychoShotsMul = 200,
    PsychoMaxExtra = 10,
    ---- a Single Shot upgraded to autofire (no burst limiter) fires this many rounds
    PsychoSingleShots = 3,
    ---- added to the overrun chance in automatic
    PsychoOverrunChance = 10,
    ---- Auto Weapons perk: percent of the overrun chance kept (multiplier, so it never reaches 0)
    AutoWeaponsOverrunMul = 80,
    ---- with Platform.rat: overrun chance next to the round count on the crosshair
    ShowOverrunChance = true,

    ---- Cadence (FEATURE_AutofireCadence.lua): rounds per fire-anim loop; the anim speed (per 1000)
    ---- is scaled so one loop lasts that many RPM intervals. 3 at 600 RPM plays the 300 ms anim at 1x
    CadenceShotsPerAnim = 3,
    CadenceAnimSpeedMin = 400,
    CadenceAnimSpeedMax = 3000,

    ---- Bullet Hell (COMBAT_ACTIONS_BulletHell.lua): sweep aim height over the floor. Measured torso
    ---- spot: standing 1005, crouched 715, prone ~150-190
    BulletHellAimHeight = 1000,
    ---- a sweep bearing within this half-width (mm) of a visible enemy aims at his torso instead
    BulletHellSilhouetteHalfWidth = 300,
    ---- fixed cone (arcminutes) whatever the gun; a stock UZI measures 1523 live
    BulletHellConeAngle = 1600,
}

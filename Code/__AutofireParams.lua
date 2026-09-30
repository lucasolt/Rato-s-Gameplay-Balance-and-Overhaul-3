---- Selectable-length autofire (AutoFire and MGBurstFire). Logic in FEATURE_VariableAutofire.lua.
const.Combat.Autofire = {
    MinShots = 1,
    ---- AutoFire and MGBurstFire replace the gun's ShootAP with BaseAP, which buys BaseShots rounds;
    ---- per-gun weight goes in AutoFireCustomDeltaAP. Each round past BaseShots pays by RPM.
    BaseAP = 2000,
    BaseShots = 1,
    ---- AP per extra round at RPMRef; scales by RPMRef / weapon.RPM
    APPerRoundRef = 500,
    RPMRef = 600,
    ---- vanilla AutoFire suppressed the target even on a miss; only bursts this long still do
    SuppressMinShots = 6,
    ---- length the AI uses for its AutoFire signature (the long, suppressive burst)
    AILongShots = 8,

    ---- Overrun: extra rounds slip out; they spend ammo and AP (clamped at 0 AP).
    ---- Chance on (100 - Composure)^1.5, from Best at Composure 100 to Worst at 0.
    OverrunChanceBest = 2,
    OverrunChanceWorst = 60,
    OverrunChanceMax = 60,
    OverrunStatusChance = {Suppressed = 10, PinnedDown = 15, Panicked = 30, Berserk = 30},
    ---- max extra rounds per 1000 RPM, at least 1
    OverrunRoundsPer1000RPM = 3,
    ---- tapping a single round in autofire: chance per 1000 RPM, times (100 - Composure)%
    SingleTapChancePer1000RPM = 40,

    ---- Bullet Hell (COMBAT_ACTIONS_BulletHell.lua): sweep aim height over the floor. Measured torso
    ---- spot: standing 1005, crouched 715, prone ~150-190
    BulletHellAimHeight = 1000,
    ---- a sweep bearing within this half-width (mm) of a visible enemy aims at his torso instead
    BulletHellSilhouetteHalfWidth = 300,
    ---- fixed cone (arcminutes) whatever the gun; a stock UZI measures 1523 live
    BulletHellConeAngle = 1600,
}

---- Selectable-length autofire (AutoFire and MGBurstFire). Logic in FEATURE_VariableAutofire.lua.
const.Combat.Autofire = {
    MinShots = 2,
    ---- the length that costs exactly ShootAP + deltas; shorter is cheaper, longer pays per round
    BaseShots = 3,
    ---- AP per extra round at RPMRef; scales by RPMRef / weapon.rpm
    APPerRoundRef = 500,
    RPMRef = 600,
    ---- vanilla AutoFire suppressed the target even on a miss; only bursts this long still do
    SuppressMinShots = 6,
    ---- length the AI uses for its AutoFire signature (the long, suppressive burst)
    AILongShots = 8,

    ---- Overrun: low Composure lets extra rounds out. Ammo is spent, AP is not.
    OverrunComposureRef = 70,
    OverrunChancePerPoint = 2,
    OverrunChanceMax = 60,
    OverrunStatusChance = {Suppressed = 10, PinnedDown = 15, Panicked = 30, Berserk = 30},
    ---- max extra rounds per 1000 RPM, at least 1
    OverrunRoundsPer1000RPM = 3,
    ---- tapping a single round on an auto-only weapon: chance per 1000 RPM, times (100 - Composure)%
    SingleTapChancePer1000RPM = 40,
}

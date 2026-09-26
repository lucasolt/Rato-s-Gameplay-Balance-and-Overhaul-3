---- Selectable-length autofire (AutoFire and MGBurstFire). Logic in FEATURE_VariableAutofire.lua.
const.Combat.Autofire = {
    MinShots = 1,
    ---- the length that costs exactly ShootAP + deltas; shorter is cheaper, longer pays per round
    BaseShots = 3,
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
}

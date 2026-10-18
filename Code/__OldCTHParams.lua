---------------------------------------------------------------------------------------------------
---- OLD CTH ONLY. aCTH disables the modifiers that read these (IsACHTActive) or never calls them.
---- Loads after __RecoilParams and __SnapshotHipfireParams, which create the tables.
---------------------------------------------------------------------------------------------------

----- Aim modifier (aCTH: AimAccuracy closes the cone, A.AimDecayMuls)
const.Combat.CrouchAimMul = 105.0 -- float
const.Combat.ProneAimMul = 110.0 -- float
const.Combat.ProneGripAimMul = 90.0 -- float
-- const.Combat.MobileAttackAimMul =
const.EnvEffects.HeavyRainAimingCTHMul = 80

----- Targeted shot (aCTH: silhouette geometry, A.TargetedResidualPct)
const.Combat.R_MinTargetedScaling = 10
const.Combat.R_MaxTargetedScaling = 100

----- Burst recoil as CTH lost per shot (aCTH: Rat_RecoilProfile kick)
const.Combat.MaxShotIndexForRecoilCTHLoss = 6
const.Combat.Recoil.MaxDistforPenalty = 36 -- 26 ----- -18
const.Combat.Recoil.MGSetupMul = 0.8--0.60 ---- * -- MG Setup recoil reduction
const.Combat.Recoil.RunAndGunExtraPenalty = -5

----- Hipfire / Snapshot as CTH points (aCTH: A.AimStep widens the cone)
const.Combat.Hipfire.BasePenalty = -10 --- - 18
const.Combat.Hipfire.MaxPenalty = -123 ---- -75
const.Combat.Hipfire.MaxDistforPenalty = 28 -- 26
const.Combat.Snapshot.BasePenalty = -6 ---- -10
const.Combat.Snapshot.MaxPenalty = -61
const.Combat.Snapshot.MaxDistforPenalty = 40 --- tiles

---- MachineGun interrupt: distance weighs less without making the shot cheaper
const.Combat.Snapshot.MGInterruptBasePenalty = -16
const.Combat.Snapshot.MGInterruptMaxDist = 90 --- tiles

const.Combat.Snapshot.MGSetupInterruptMul = 80 -- MulDivRound
const.Combat.Snapshot.InterruptMul = 110 --- MulDivRound

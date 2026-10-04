----- Crit
const.Combat.AutoFireCritMul = 30 -- % of crit kept by autofire; BurstFire uses the weapon's BurstCritMul

----- CTH
const.Combat.SprintingCTH = -10 --- to hit sprinting target
-- Aim
const.Combat.CrouchAimMul = 105.0 -- float
const.Combat.ProneAimMul = 110.0 -- float
const.Combat.ProneGripAimMul = 90.0 -- float
-- const.Combat.MobileAttackAimMul = 
const.EnvEffects.HeavyRainAimingCTHMul = 80

-- Recoil
const.Combat.MultishotGrazeThreshold = 18 -- 12
const.Combat.SingleShotGrazeThreshold = 10
const.Combat.PelletShotGrazeThreshold = 22
const.Combat.MultishotMinCTH = 4
---- Teto do desconto de CTH por tiro do pipeline VANILLA. O modelo angular nao usa: la o cano
---- se assenta sozinho pelo contra-esforco, sem plato tabelado.
const.Combat.MaxShotIndexForRecoilCTHLoss = 6

---- Unidade so re-encara o inimigo mais proximo no PROPRIO turno. Ver
---- SOURCE_UnitSetTargetDummyFromPos: sem isto a silhueta exposta muda sozinha a cada
---- VisibilityUpdate, e com ela o CTH e a parte do corpo atingida.
const.Combat.FreezeIdleFacing = true
-------------------- Add for MG calcs here

-- RunAndGun
const.Combat.RunAndGunMaxPenalty = -10
const.Combat.RunAndGun_MaxDistforPenalty = 14
const.Combat.RunAndGunNumShotsBase = 3
const.Combat.RunAndGunMoveAPBase = 9
const.Combat.RunAndGunMoveAPMin = 6

-- MobileShot
const.Combat.MobileShotNumShotsBase = 3
const.Combat.MobileShotMoveAPBase = 9
const.Combat.MobileShotMoveAPMin = 6

-- Sprint
--const.Combat.SprintMoveAPBase = 8 -- Set in the editor
--const.Combat.SprintMoveAPMin = 7

-- OW
const.Combat.MGSetupBonusInterruptAccuracy = 0
const.Combat.MGSetupConeMul = 110 --- MulDivRound
const.Combat.MGSetupConeFlat = 180 --- addition (minutes)
const.Combat.OWMinDelta = 20
const.Combat.OWMaxDelta = -10

------ old
const.Combat.R_MinTargetedScaling = 10
const.Combat.R_MaxTargetedScaling = 100
const.Combat.R_MinAimScaling = 10
const.Combat.R_MaxAimScaling = 100


----- AP
const.Combat.CumbersomeStanceAP_StrThreshold = 80
const.Combat.ShootMoveSMGorHandgun_FreeMoveMul = 50

----- BoltAction
const.Combat.BoltActionDexStart = 65
const.Combat.BoltActionDexMaxPct = 75 -- asymptote of the cycle cost reduction, % of base
const.Combat.BoltActionDexHalf = 15 -- Dex above Start that yields half of MaxPct
const.Combat.TexPerkCycleBasePct = 50 -- % taken off the base cost before the Dex curve

----- Shotgun: ShootAP is the buckshot price; slug attacks cost this much less (x const.Scale.AP)
const.Combat.ShotgunBuckshotExtraAP = 10

------ Pindown (Sniping)
const.Combat.PindownCritPerAimLevel = 400 -- hundredths of %, added to CritPerAim
const.Combat.PindownAimLevelsForAPCost = 2
const.Combat.PindownRangeMul = 150 --- MulDivRound


------ Perks
const.Combat.Perks = {}
const.Combat.Perks.RelentlessAdvanceFreeMoveMul = 150
const.Combat.Perks.OutOfBreathAimMul = 70
const.Combat.Perks.SaviorAdrenalineRushFreeMoveMul = 120
const.Combat.Perks.SaviorAdrenalineRushFreeMoveBonus = R_VanillaAPToDisplay(4)
const.Combat.Perks.SaviorAdrenalineRushBonusAP = R_VanillaAPToDisplay(2)

----- Critical
const.Combat.Critical = {}
const.Combat.Critical.PSOScopeCritOnAimed = 10
const.Combat.Critical.FirstAimCrit = 6
-------------
const.Combat.AwareSightRange = 56
const.Combat.UnawareSightRange = 18
----- Vanilla
const.Combat.GrazingHitDamage = 30 --- %
const.Combat.MGFreeInterruptAttacks = 1
const.Weapons.PointBlankRange = 6 --- tiles
const.EnvEffects.RainAimingMultiplier = 0 --- %
const.Weapons.CriticalDamage = 50
const.Weapons.DoubleBarrelDamageBonus = 0 -- 50
const.Weapons.DoubleBarrelSlugSpacing = 3 --- cm between parallel slugs
const.EnvEffects.RainConditionLossMod = 75
const.EnvEffects.FogSightMod = -30
const.EnvEffects.FogGrazeChance = 0-- 25
const.EnvEffects.FireStormSightMod = -10
const.EnvEffects.DustStormSightMod = -10
const.EnvEffects.DustStormGrazeChance = 0
const.EnvEffects.DarknessSightMod = -40 -- default da opcao NightSight; sobrescrito por ela
const.EnvEffects.DarknessDetectionRate = -40 -- -30
const.EnvEffects.DarknessCTHPenalty = -30 -- -20

--
-- simulated aCTH only; replaces the gas graze
const.EnvEffects.SmokeCTHPenaltyPerVoxel = -10 -- -8 
const.EnvEffects.SmokeCTHPenaltyMax = -60 -- -40


const.Weapons.ItemConditionUsed	= 70	
const.Weapons.ItemConditionNeedsRepair= 40	
const.Combat.ConditionPenaltyNeedsRepair = 5	
const.Combat.ConditionPenaltyPoor = 20
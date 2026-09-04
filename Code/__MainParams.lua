----- Crit
const.Combat.BurstFireCriticalChanceMul = 70 -- % -- Crit * Constant / 100
---TODO: Change all my crit per aim to be per aim and then make it not affect burst fire

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
---- Quantos coices SOBEM o cano. Passado isso o modelo angular nao congela o recuo: o coice passa
---- a sair de lado, com sinal sorteado e sem acumular (Rat_RecoilLateral). O cano para de piorar
---- mas continua se mexendo, e o grupo abre em largura em vez de subir sem fim.
const.Combat.MaxShotIndexForRecoilCTHLoss = 6

---- Unidade so re-encara o inimigo mais proximo no PROPRIO turno. Ver
---- SOURCE_UnitSetTargetDummyFromPos: sem isto a silhueta exposta muda sozinha a cada
---- VisibilityUpdate, e com ela o CTH e a parte do corpo atingida.
const.Combat.FreezeIdleFacing = true
-------------------- Add for MG calcs here

-- RunAndGun
const.Combat.RunAndGunMaxPenalty = -10
const.Combat.RunAndGun_MaxDistforPenalty = 14

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
const.Combat.BoltActionDexFirstThreshold = 80
const.Combat.BoltActionDexSecondThreshold = 95

------ Pindown (Sniping)
const.Combat.PindownCritPerAimLevel = 4
const.Combat.PindownAimLevelsForAPCost = 2
const.Combat.PindownRangeMul = 150 --- MulDivRound

------ Perks
const.Combat.Perks = {}
const.Combat.Perks.RelentlessAdvanceFreeMoveMul = 150
const.Combat.Perks.OutOfBreathAimMul = 70
const.Combat.Perks.SaviorAdrenalineRushFreeMoveMul = 120
const.Combat.Perks.SaviorAdrenalineRushFreeMoveBonus = 4
const.Combat.Perks.SaviorAdrenalineRushBonusAP = 2

----- Critical
const.Combat.Critical = {}
const.Combat.Critical.PrismScopeCritPerAim = 3 -- 4
const.Combat.Critical.LaserDotCritPerAim = 1
const.Combat.Critical.PSOScopeCritOnAimed = 10
const.Combat.Critical.FirstAimCrit = 6
const.Combat.HandEyeCritScalingFactor = 80
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
const.EnvEffects.RainConditionLossMod = 75
const.EnvEffects.FogSightMod = -40 -- -30
const.EnvEffects.FogGrazeChance = 0-- 25
const.EnvEffects.FireStormSightMod = -10
const.EnvEffects.DustStormSightMod = -10
const.EnvEffects.DustStormGrazeChance = 0
const.EnvEffects.DarknessSightMod = -40 -- default da opcao NightSight; sobrescrito por ela
const.EnvEffects.DarknessDetectionRate = -40 -- -30
const.EnvEffects.DarknessCTHPenalty = -30 -- -20

---------------------------------------------------------------------------------------------------
---- SHARED: every CTH mode. Old-CTH-only constants live in __OldCTHParams.lua, aCTH in __Aperture*.
---- Sight ranges and darkness come from the mod options (GBO_ApplyOptions).
---------------------------------------------------------------------------------------------------

----- Crit
const.Combat.AutoFireCritMul = 30 -- % of crit kept by autofire; BurstFire uses the weapon's BurstCritMul
const.Combat.Critical = {}
const.Combat.Critical.PSOScopeCritOnAimed = 10
const.Combat.Critical.FirstAimCrit = 6

----- Target modifiers (aCTH absorbs them into the cone)
const.Combat.SprintingCTH = -10 --- to hit sprinting target

----- Multishot / graze
const.Combat.MultishotGrazeThreshold = 18 -- 12
const.Combat.SingleShotGrazeThreshold = 10
const.Combat.PelletShotGrazeThreshold = 22
const.Combat.MultishotMinCTH = 4

----- RunAndGun
const.Combat.RunAndGunMaxPenalty = -10
const.Combat.RunAndGun_MaxDistforPenalty = 14
const.Combat.RunAndGunNumShotsBase = 3
const.Combat.RunAndGunMoveAPBase = 9
const.Combat.RunAndGunMoveAPMin = 6

----- MobileShot
const.Combat.MobileShotNumShotsBase = 3
const.Combat.MobileShotMoveAPBase = 9
const.Combat.MobileShotMoveAPMin = 6
const.Combat.MobileShotPenalty = -8

-- Sprint
--const.Combat.SprintMoveAPBase = 8 -- Set in the editor
--const.Combat.SprintMoveAPMin = 7

----- Overwatch / interrupts
const.Combat.MGSetupBonusInterruptAccuracy = 0
const.Combat.MGSetupConeMul = 110 --- MulDivRound
const.Combat.MGSetupConeFlat = 180 --- addition (minutes)
const.Combat.OWMinDelta = 20
const.Combat.OWMaxDelta = -10
const.Combat.OWMinCTH = 6 -- aCTH: overwatch holds fire below this and waits for a better tile
---- Interrupt range bonus (Rat_OWRangeConeMul): cone narrowing eased from Min(Start, StartPct) to FullPct of WeaponRange
const.Combat.OWRangeStart = 8 -- tiles
const.Combat.OWRangeStartPct = 25 -- % of WeaponRange, when shorter than Start
const.Combat.OWRangeFullPct = 50 -- % of WeaponRange
const.Combat.OWRangeConePerTile = 6 -- per-mille per tile of scope-aware range, x Reflexes/100
const.Combat.OWRangeConeCap = 400 -- per-mille
---- Reflexes scaling of the OW modifier (old CTH also uses it for Aim and Point Blank)
const.Combat.R_MinAimScaling = 10
const.Combat.R_MaxAimScaling = 100

----- AP
const.Combat.CumbersomeStanceAP_StrThreshold = 80
-- shooting angle (%) of a gun whose bipod is not braced, i.e. not prone
const.Combat.BipodUnbracedAngleMul = 90
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
const.Combat.PindownRangeMul = 150 --- MulDivRound; aCTH uses A.PindownRangeMul

------ Perks
const.Combat.Perks = {}
const.Combat.Perks.RelentlessAdvanceFreeMoveMul = 150
const.Combat.Perks.FastRunnerMobileMoveAP = 1 --- vanilla AP added to mobile attacks' move AP (not Sprint)
const.Combat.Perks.OutOfBreathAimMul = 70
const.Combat.Perks.SaviorAdrenalineRushFreeMoveMul = 120
const.Combat.Perks.SaviorAdrenalineRushFreeMoveBonus = R_VanillaAPToDisplay(4)
const.Combat.Perks.SaviorAdrenalineRushBonusAP = R_VanillaAPToDisplay(2)
const.Combat.Perks.OpportunisticKillerBonusAttacks = 1
const.Combat.Perks.KillzoneAimByTarget = {3, 2, 1} -- aim per distinct target this turn; last entry repeats
const.Combat.Perks.SharpshooterMaxStacks = 2 -- keep equal to Rat_Settled max_stacks (items.lua)
const.Combat.Perks.SharpshooterAccPerStack = 5 -- AimAccuracy added to every aim level
const.Combat.Perks.SharpshooterCritPerAimPerStack = 1 -- % crit chance
const.Combat.Perks.SharpshooterCritDmgPerAimPerStack = 3 -- % crit damage
const.Combat.Perks.AnatomicalPrecisionFlankedCrit = 10 -- % crit chance vs Flanked, exempt from the fire-mode mul

----- Vanilla overrides
const.Combat.GrazingHitDamage = 30 --- %
const.Combat.MGFreeInterruptAttacks = 1
const.Weapons.PointBlankRange = 6 --- tiles
const.Weapons.CriticalDamage = 50
const.Weapons.DoubleBarrelDamageBonus = 0 -- 50
const.Weapons.DoubleBarrelSlugSpacing = 3 --- cm between parallel slugs

----- Condition
const.Weapons.ItemConditionUsed	= 70
const.Weapons.ItemConditionNeedsRepair= 40
const.Combat.ConditionPenaltyNeedsRepair = 5
const.Combat.ConditionPenaltyPoor = 20

----- Environment
const.EnvEffects.RainAimingMultiplier = 0 --- %
const.EnvEffects.RainConditionLossMod = 75
---- weather scales the base sight range (GBO_BaseSight) so stealth/camo/grass still stack above the floor
const.EnvEffects.FogSightMod = 0 -- -40
const.EnvEffects.FireStormSightMod = 0 -- -20
const.EnvEffects.DustStormSightMod = 0 -- -35
const.EnvEffects.FogSightReduction = 60 --- %
const.EnvEffects.DustStormSightReduction = 50 --- %
const.EnvEffects.FireStormSightReduction = 20 --- %
---- the graze is replaced by a CTH penalty (CTH_smoke.lua place_obscured_cth)
const.EnvEffects.FogGrazeChance = 0-- 25
const.EnvEffects.DustStormGrazeChance = 0
const.EnvEffects.FogCTHPenalty = -10
const.EnvEffects.DustStormCTHPenalty = -10
const.EnvEffects.DarknessCTHPenalty = -10 -- -20
---- % of the night sight penalty removed; Night Ops + NVG don't stack, the better one applies
const.EnvEffects.NightOpsSightReduction = 25 -- also written into NightOps' param for the text
const.EnvEffects.NVGSightReduction = 50

---------------------------------------------------------------------------------------------------
---- aCTH ONLY (simulated); replaces the gas graze
---------------------------------------------------------------------------------------------------
const.EnvEffects.SmokeCTHPenaltyPerVoxel = -10 -- -8
const.EnvEffects.SmokeCTHPenaltyMax = -60 -- -40

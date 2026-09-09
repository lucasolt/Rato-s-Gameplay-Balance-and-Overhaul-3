-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

local function storeProps(item, prop, value, mode, tbl)
	tbl[item] = tbl[item] or {}
	tbl[item][prop] = tbl[item][prop] or {}
	if tbl[item][prop][mode] == nil then
		tbl[item][prop][mode] = value
	end
end

function RatoGBO_WepPatch()
	print("Running PATCH_GBO_weapons...")
	BarretM82.is_vanilla_firearm = true
	BarretM82.Cost = 15940
	BarretM82.Damage = 70
	BarretM82.CritChanceScaled = 20
	storeProps(BarretM82, "AimAccuracy", 50, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BarretM82, "AimAccuracy", 8, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BarretM82, "WeaponRange", 40, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BarretM82, "WeaponRange", 42, "oldCTH", GBO_gCTHModeItemPropertyTable)
	BarretM82.PBbonus_base = -10
	BarretM82.HandlingBaseMul = 125
	BarretM82.HandlingNotProneMul = 300
	BarretM82.ShootAP = 4000
	BarretM82.ReloadAP = 3000
	BarretM82.OverwatchAngle = 545
	BarretM82.MagazineSize = 5
	BarretM82.Cumbersome = 1
	BarretM82.Noise = 22
	BarretM82.PointBlankBonus = 1
	BarretM82.PreparedAttackType = "Both"
	BarretM82.AvailableAttacks = {"SingleShot", "CancelShot"}
	BarretM82.APStance = 6
	BarretM82.Rat_swap_ap = 4
	BarretM82.wep_base_recoil_mul = 85
	BarretM82.wep_base_snapshot_mul = 159
	BarretM82.wep_base_hip_mul = 83
	BarretM82.weigth_held_mul = 200
	BarretM82.recoil_mechanism = "Recoil_Operated"
	BarretM82.Rat_cycling = "SemiAuto"
	BarretM82.default_long_barrel = true
	BarretM82.unwieldy_weapon = true
	BarretM82.rat_barrel_len = 730
	BarretM82.rat_weigth = 14000
	BarretM82.ScrapParts = 16
	BarretM82.RepairCost = 80
	BarretM82.Reliability = 74
	BarretM82.AdditionalHint = T{614748331117,[[<description_hints>]]}
	BarretM82.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Bipod_m82', Modifiable = true, AvailableComponents = {'Bipod_m82', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_5', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', 'LROpticsAdvanced', 'ImprovedIronsight', 'PSG_DefaultScope', 'WideScope', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'Compensator', Modifiable = true, AvailableComponents = {'Compensator', 'Suppressor', }}}
	BarretM82.Valuable = 1
	BarretM82.CanAppearInShop = true
	BarretM82.Tier = 3
	BarretM82.MaxStock = 1
	BarretM82.RestockWeight = 20
	BarretM82.CategoryPair = "Rifles"
	BarretM82.PenetrationClass = 1


	M24Sniper.is_vanilla_firearm = true
	M24Sniper.Cost = 8600
	M24Sniper.Damage = 31
	M24Sniper.CritChanceScaled = 30
	storeProps(M24Sniper, "AimAccuracy", 56, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M24Sniper, "AimAccuracy", 9, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M24Sniper, "WeaponRange", 36, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M24Sniper, "WeaponRange", 38, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M24Sniper.PBbonus_base = -3
	M24Sniper.HandlingBaseMul = 116
	M24Sniper.ShootAP = 4000
	M24Sniper.ReloadAP = 3000
	M24Sniper.OverwatchAngle = 772
	M24Sniper.MagazineSize = 5
	M24Sniper.Cumbersome = 0
	M24Sniper.Noise = 22
	M24Sniper.PointBlankBonus = 1
	M24Sniper.PreparedAttackType = "Both"
	M24Sniper.AvailableAttacks = {"SingleShot", "CancelShot"}
	M24Sniper.APStance = 5
	M24Sniper.Rat_swap_ap = 3
	M24Sniper.wep_base_recoil_mul = 91
	M24Sniper.wep_base_snapshot_mul = 119
	M24Sniper.wep_base_hip_mul = 89
	M24Sniper.weigth_held_mul = 137
	M24Sniper.recoil_mechanism = "Bolt_Action"
	M24Sniper.Rat_cycling = "BoltAction"
	M24Sniper.default_long_barrel = true
	M24Sniper.rat_barrel_len = 610
	M24Sniper.rat_weigth = 5200
	M24Sniper.ScrapParts = 14
	M24Sniper.RepairCost = 80
	M24Sniper.Reliability = 95
	M24Sniper.AdditionalHint = T{713886804400,[[<description_hints>]]}
	M24Sniper.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockLight', 'StockNormal', }}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'LROptics', Modifiable = true, AvailableComponents = {'LROptics', 'LROpticsAdvanced', 'ReflexSight', 'ScopeCOG', 'ThermalScope', 'PSG_DefaultScope', 'WideScope', '_ReflexSIghtVigilance', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Suppressor', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Bolt_action', Modifiable = true, AvailableComponents = {'Bolt_action', }}}
	M24Sniper.CanAppearInShop = true
	M24Sniper.Tier = 2
	M24Sniper.MaxStock = 2
	M24Sniper.RestockWeight = 50
	M24Sniper.CategoryPair = "Rifles"
	M24Sniper.PenetrationClass = 1


	PSG1.is_vanilla_firearm = true
	PSG1.Cost = 12540
	PSG1.Damage = 31
	PSG1.CritChanceScaled = 30
	storeProps(PSG1, "AimAccuracy", 52, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PSG1, "AimAccuracy", 9, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PSG1, "WeaponRange", 36, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PSG1, "WeaponRange", 40, "oldCTH", GBO_gCTHModeItemPropertyTable)
	PSG1.PBbonus_base = -6
	PSG1.HandlingBaseMul = 125
	PSG1.HandlingNotProneMul = 188
	PSG1.ShootAP = 4000
	PSG1.ReloadAP = 2000
	PSG1.OverwatchAngle = 596
	PSG1.MagazineSize = 5
	PSG1.Cumbersome = 0
	PSG1.Noise = 22
	PSG1.PointBlankBonus = 1
	PSG1.PreparedAttackType = "Both"
	PSG1.AvailableAttacks = {"SingleShot", "CancelShot"}
	PSG1.APStance = 5
	PSG1.Rat_swap_ap = 3
	PSG1.wep_base_recoil_mul = 87
	PSG1.wep_base_snapshot_mul = 128
	PSG1.wep_base_hip_mul = 87
	PSG1.weigth_held_mul = 150
	PSG1.recoil_mechanism = "Gas_Operated"
	PSG1.Rat_cycling = "SemiAuto"
	PSG1.default_long_barrel = true
	PSG1.rat_barrel_len = 650
	PSG1.rat_weigth = 7000
	PSG1.ScrapParts = 14
	PSG1.RepairCost = 80
	PSG1.Reliability = 76
	PSG1.AdditionalHint = T{998230614287,[[<description_hints>]]}
	PSG1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockNormal', 'StockHeavy', }}, {CanBeEmpty = false, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagNormalFine', 'MagLarge_10', 'MagLargeFine_10', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'PSG_DefaultScope', Modifiable = true, AvailableComponents = {'PSG_DefaultScope', 'LROpticsAdvanced', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', '_ReflexSIghtVigilance', 'WideScope', 'LROptics', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'FlashlightDot_PSG_M1', 'Flashlight_PSG_M1', 'LaserDot_PSG_M1', 'UVDot_PSG_M1', }}}
	PSG1.Valuable = 1
	PSG1.CanAppearInShop = true
	PSG1.Tier = 3
	PSG1.MaxStock = 1
	PSG1.RestockWeight = 30
	PSG1.CategoryPair = "Rifles"
	PSG1.PenetrationClass = 1


	MG58.is_vanilla_firearm = true
	MG58.Cost = 3000
	MG58.Damage = 30
	MG58.CritChanceScaled = 10
	storeProps(MG58, "AimAccuracy", 23, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG58, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG58, "WeaponRange", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG58, "WeaponRange", 40, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MG58.PBbonus_base = -3
	MG58.HandlingBaseMul = 125
	MG58.HandlingNotProneMul = 250
	MG58.ShootAP = 4000
	MG58.ReloadAP = 5000
	MG58.OverwatchAngle = 571
	MG58.MagazineSize = 50
	MG58.Cumbersome = 1
	MG58.Noise = 22
	MG58.PointBlankBonus = 1
	MG58.PreparedAttackType = "Machine Gun"
	MG58.AvailableAttacks = {"MGBurstFire"}
	MG58.long_shots = 7
	MG58.APStance = 5
	MG58.Rat_swap_ap = 3
	MG58.wep_base_recoil_mul = 82
	MG58.wep_base_snapshot_mul = 138
	MG58.wep_base_hip_mul = 92
	MG58.weigth_held_mul = 182
	MG58.recoil_mechanism = "Gas_Operated"
	MG58.Rat_cycling = "Auto"
	MG58.rat_barrel_len = 550
	MG58.rat_weigth = 11600
	MG58.ScrapParts = 12
	MG58.RepairCost = 80
	MG58.Reliability = 88
	MG58.AdditionalHint = T{240845249658,[[<description_hints>]]}
	MG58.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Bipod_MG42', Modifiable = false, AvailableComponents = {'Bipod_MG42', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'ImprovedIronsight', Modifiable = false, AvailableComponents = {'ImprovedIronsight', }}}
	MG58.Valuable = 1
	MG58.Tier = 1
	MG58.PenetrationClass = 1


	GoldenGun.is_vanilla_firearm = true
	GoldenGun.Cost = 18000
	GoldenGun.Damage = 31
	GoldenGun.CritChanceScaled = 40
	storeProps(GoldenGun, "AimAccuracy", 50, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(GoldenGun, "AimAccuracy", 9, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(GoldenGun, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(GoldenGun, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	GoldenGun.PBbonus_base = -1
	GoldenGun.HandlingBaseMul = 111
	GoldenGun.ShootAP = 4000
	GoldenGun.ReloadAP = 3000
	GoldenGun.OverwatchAngle = 870
	GoldenGun.MagazineSize = 10
	GoldenGun.Cumbersome = 1
	GoldenGun.Noise = 22
	GoldenGun.PointBlankBonus = 1
	GoldenGun.PreparedAttackType = "Both"
	GoldenGun.AvailableAttacks = {"SingleShot"}
	GoldenGun.APStance = 4
	GoldenGun.Rat_swap_ap = 3
	GoldenGun.wep_base_recoil_mul = 100
	GoldenGun.wep_base_snapshot_mul = 100
	GoldenGun.wep_base_hip_mul = 90
	GoldenGun.weigth_held_mul = 100
	GoldenGun.recoil_mechanism = "Single_Shot"
	GoldenGun.Rat_cycling = "SemiAuto"
	GoldenGun.ScrapParts = 16
	GoldenGun.RepairCost = 80
	GoldenGun.Reliability = 78
	GoldenGun.AdditionalHint = T{864686045799,[[<description_hints>]]}
	GoldenGun.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Bipod', Modifiable = false, AvailableComponents = {'Bipod', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'LROptics', Modifiable = false, AvailableComponents = {'LROptics', }}}
	GoldenGun.Valuable = 1
	GoldenGun.CategoryPair = "AssaultRifles"
	GoldenGun.PenetrationClass = 1


	Gewehr98.is_vanilla_firearm = true
	Gewehr98.Cost = 2000
	Gewehr98.Damage = 32
	Gewehr98.CritChanceScaled = 20
	storeProps(Gewehr98, "AimAccuracy", 42, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr98, "AimAccuracy", 7, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr98, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr98, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Gewehr98.PBbonus_base = -7
	Gewehr98.HandlingBaseMul = 122
	Gewehr98.ShootAP = 4000
	Gewehr98.ReloadAP = 3000
	Gewehr98.OverwatchAngle = 651
	Gewehr98.MagazineSize = 5
	Gewehr98.Cumbersome = 0
	Gewehr98.Noise = 22
	Gewehr98.PointBlankBonus = 1
	Gewehr98.PreparedAttackType = "Both"
	Gewehr98.AvailableAttacks = {"SingleShot", "CancelShot"}
	Gewehr98.APStance = 5
	Gewehr98.Rat_swap_ap = 3
	Gewehr98.wep_base_recoil_mul = 89
	Gewehr98.wep_base_snapshot_mul = 126
	Gewehr98.wep_base_hip_mul = 82
	Gewehr98.weigth_held_mul = 132
	Gewehr98.recoil_mechanism = "Bolt_Action"
	Gewehr98.Rat_cycling = "BoltAction"
	Gewehr98.default_long_barrel = true
	Gewehr98.rat_barrel_len = 740
	Gewehr98.rat_weigth = 4500
	Gewehr98.ScrapParts = 8
	Gewehr98.RepairCost = 80
	Gewehr98.Reliability = 97
	Gewehr98.AdditionalHint = T{973204362273,[[<description_hints>]]}
	Gewehr98.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'GewehrDefaultSight', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ScopeCOG', 'GewehrDefaultSight', 'ImprovedIronsight', 'ReflexSightAdvanced', 'ScopeCOGQuick', 'ThermalScope', '_ReflexSIghtVigilance', 'WideScope', 'LROpticsAdvanced', 'PSG_DefaultScope', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Bolt_action', Modifiable = true, AvailableComponents = {'Bolt_action', }}}
	Gewehr98.CanAppearInShop = true
	Gewehr98.Tier = 1
	Gewehr98.MaxStock = 3
	Gewehr98.RestockWeight = 100
	Gewehr98.CategoryPair = "Rifles"
	Gewehr98.PenetrationClass = 1


	DragunovSVD.is_vanilla_firearm = true
	DragunovSVD.Cost = 8440
	DragunovSVD.Damage = 32
	DragunovSVD.CritChanceScaled = 20
	storeProps(DragunovSVD, "AimAccuracy", 40, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DragunovSVD, "AimAccuracy", 7, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DragunovSVD, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DragunovSVD, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	DragunovSVD.PBbonus_base = -2
	DragunovSVD.HandlingBaseMul = 114
	DragunovSVD.ShootAP = 4000
	DragunovSVD.ReloadAP = 3000
	DragunovSVD.OverwatchAngle = 820
	DragunovSVD.MagazineSize = 10
	DragunovSVD.Cumbersome = 0
	DragunovSVD.Noise = 22
	DragunovSVD.PointBlankBonus = 1
	DragunovSVD.PreparedAttackType = "Both"
	DragunovSVD.AvailableAttacks = {"SingleShot", "CancelShot"}
	DragunovSVD.APStance = 5
	DragunovSVD.Rat_swap_ap = 3
	DragunovSVD.wep_base_recoil_mul = 92
	DragunovSVD.wep_base_snapshot_mul = 117
	DragunovSVD.wep_base_hip_mul = 89
	DragunovSVD.weigth_held_mul = 132
	DragunovSVD.recoil_mechanism = "Gas_Operated"
	DragunovSVD.Rat_cycling = "SemiAuto"
	DragunovSVD.default_long_barrel = true
	DragunovSVD.rat_barrel_len = 610
	DragunovSVD.rat_weigth = 4500
	DragunovSVD.ScrapParts = 14
	DragunovSVD.RepairCost = 80
	DragunovSVD.Reliability = 85
	DragunovSVD.AdditionalHint = T{715363343098,[[<description_hints>]]}
	DragunovSVD.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockLight', 'StockNormal', }}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'LROptics_DragunovDefault', Modifiable = true, AvailableComponents = {'LROptics_DragunovDefault', 'ReflexSight', 'ScopeCOG', 'ThermalScope', 'LROpticsAdvanced', 'ReflexSightAdvanced', 'ScopeCOGQuick', '_ReflexSIghtVigilance', 'WideScope', 'PSG_DefaultScope', 'LROptics', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'Compensator', Modifiable = true, AvailableComponents = {'Compensator', 'Suppressor', }}}
	DragunovSVD.CanAppearInShop = true
	DragunovSVD.Tier = 2
	DragunovSVD.MaxStock = 2
	DragunovSVD.RestockWeight = 60
	DragunovSVD.CategoryPair = "Rifles"
	DragunovSVD.PenetrationClass = 1


	M14SAW.is_vanilla_firearm = true
	M14SAW.object_class = "AssaultRifle"
	M14SAW.Cost = 3600
	M14SAW.Damage = 29
	M14SAW.CritChanceScaled = 10
	storeProps(M14SAW, "AimAccuracy", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M14SAW.PBbonus_base = -1
	M14SAW.HandlingBaseMul = 110
	M14SAW.ShootAP = 4000
	M14SAW.ReloadAP = 3000
	M14SAW.OverwatchAngle = 870
	M14SAW.MagazineSize = 10
	M14SAW.Cumbersome = 0
	M14SAW.Noise = 20
	M14SAW.PointBlankBonus = 1
	M14SAW.PreparedAttackType = "Both"
	M14SAW.AvailableAttacks = {"SingleShot", "CancelShot"}
	M14SAW.APStance = 4
	M14SAW.Rat_swap_ap = 3
	M14SAW.wep_base_recoil_mul = 87
	M14SAW.wep_base_snapshot_mul = 109
	M14SAW.wep_base_hip_mul = 97
	M14SAW.weigth_held_mul = 137
	M14SAW.recoil_mechanism = "Gas_Operated"
	M14SAW.Rat_cycling = "SemiAuto"
	M14SAW.rat_barrel_len = 457
	M14SAW.rat_weigth = 5220
	M14SAW.ScrapParts = 10
	M14SAW.RepairCost = 80
	M14SAW.Reliability = 78
	M14SAW.AdditionalHint = T{517364861436,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Civilian issued, most commonly found variant. Only fires in semi-auto]]}
	M14SAW.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong', 'BarrelLongImproved', 'BarrelNormal', 'BarrelNormalImproved', 'BarrelShort', 'BarrelShortImproved', 'BarrelHeavyLong', 'BarrelLight', 'long_barrel_light', 'BarrelShort_Light', 'BarrelHeavy', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockHeavy', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockNormal', 'StockLight', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge_5', 'MagLargeFine_5', 'MagNormal', 'MagNormalFine', 'MagQuick', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = true, AvailableComponents = {'GrenadeLauncher_M14', 'TacGrip_M14', 'Bipod_Under', 'VerticalGrip_M14', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'M14_Default_Muzzle', Modifiable = true, AvailableComponents = {'M14_Default_Muzzle', 'Compensator', 'Suppressor', 'ImprovisedSuppressor', 'MuzzleBooster', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'LaserDot', 'FlashlightDot', 'UVDot', 'Flashlight', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ImprovedIronsight', 'LROptics', 'LROpticsAdvanced', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', 'WideScope', '_ReflexSIghtVigilance', }}}
	M14SAW.CanAppearInShop = true
	M14SAW.Tier = 2
	M14SAW.MaxStock = 3
	M14SAW.RestockWeight = 80
	M14SAW.CategoryPair = "AssaultRifles"
	M14SAW.PenetrationClass = 1


	M14SAW_AUTO.is_vanilla_firearm = true
	M14SAW_AUTO.object_class = "AssaultRifle"
	M14SAW_AUTO.Cost = 4320
	M14SAW_AUTO.Damage = 29
	M14SAW_AUTO.CritChanceScaled = 10
	storeProps(M14SAW_AUTO, "AimAccuracy", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW_AUTO, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW_AUTO, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW_AUTO, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M14SAW_AUTO.PBbonus_base = -1
	M14SAW_AUTO.HandlingBaseMul = 110
	M14SAW_AUTO.ShootAP = 4000
	M14SAW_AUTO.ReloadAP = 3000
	M14SAW_AUTO.OverwatchAngle = 870
	M14SAW_AUTO.MagazineSize = 10
	M14SAW_AUTO.Cumbersome = 0
	M14SAW_AUTO.Noise = 20
	M14SAW_AUTO.PointBlankBonus = 1
	M14SAW_AUTO.PreparedAttackType = "Overwatch"
	M14SAW_AUTO.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	M14SAW_AUTO.APStance = 4
	M14SAW_AUTO.Rat_swap_ap = 3
	M14SAW_AUTO.wep_base_recoil_mul = 87
	M14SAW_AUTO.wep_base_snapshot_mul = 109
	M14SAW_AUTO.wep_base_hip_mul = 97
	M14SAW_AUTO.weigth_held_mul = 137
	M14SAW_AUTO.burst_recoil_delta = 125
	M14SAW_AUTO.long_recoil_delta = 125
	M14SAW_AUTO.auto_recoil_delta = 125
	M14SAW_AUTO.recoil_mechanism = "Gas_Operated"
	M14SAW_AUTO.Rat_cycling = "Auto"
	M14SAW_AUTO.rat_barrel_len = 457
	M14SAW_AUTO.rat_weigth = 5220
	M14SAW_AUTO.ScrapParts = 10
	M14SAW_AUTO.RepairCost = 80
	M14SAW_AUTO.Reliability = 78
	M14SAW_AUTO.AdditionalHint = T{419078734073,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Military variant with burst fire and auto fire modes
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Has a big recoil penalty]]}
	M14SAW_AUTO.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong', 'BarrelLongImproved', 'BarrelNormal', 'BarrelShort', 'BarrelShortImproved', 'BarrelHeavyLong', 'BarrelLight', 'long_barrel_light', 'BarrelShort_Light', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockHeavy', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockNormal', 'StockLight', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge_5', 'MagLargeFine_5', 'MagNormal', 'MagNormalFine', 'MagQuick', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = true, AvailableComponents = {'GrenadeLauncher_M14', 'TacGrip_M14', 'VerticalGrip_M14', 'Bipod_Under', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'M14_Default_Muzzle', Modifiable = true, AvailableComponents = {'M14_Default_Muzzle', 'Compensator', 'Suppressor', 'ImprovisedSuppressor', 'MuzzleBooster', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'LaserDot', 'FlashlightDot', 'UVDot', 'Flashlight', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ImprovedIronsight', 'LROptics', 'LROpticsAdvanced', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', 'WideScope', '_ReflexSIghtVigilance', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'm14_component_recoil', Modifiable = false, AvailableComponents = {'m14_component_recoil', }}}
	M14SAW_AUTO.CanAppearInShop = true
	M14SAW_AUTO.Tier = 2
	M14SAW_AUTO.MaxStock = 1
	M14SAW_AUTO.RestockWeight = 40
	M14SAW_AUTO.CategoryPair = "AssaultRifles"
	M14SAW_AUTO.SubIcon = "Mod/cfahRED/Images/m143.png"
	M14SAW_AUTO.PenetrationClass = 1


	HK21.is_vanilla_firearm = true
	HK21.Cost = 11415
	HK21.Damage = 30
	HK21.CritChanceScaled = 10
	storeProps(HK21, "AimAccuracy", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK21, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK21, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK21, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	HK21.PBbonus_base = -3
	HK21.HandlingBaseMul = 120
	HK21.HandlingNotProneMul = 200
	HK21.ShootAP = 4000
	HK21.ReloadAP = 5000
	HK21.OverwatchAngle = 695
	HK21.MagazineSize = 20
	HK21.Cumbersome = 1
	HK21.Noise = 22
	HK21.PointBlankBonus = 1
	HK21.PreparedAttackType = "Machine Gun"
	HK21.AvailableAttacks = {"MGBurstFire"}
	HK21.APStance = 5
	HK21.Rat_swap_ap = 3
	HK21.wep_base_recoil_mul = 89
	HK21.wep_base_snapshot_mul = 124
	HK21.wep_base_hip_mul = 93
	HK21.weigth_held_mul = 157
	HK21.recoil_mechanism = "Roller_Delayed"
	HK21.Rat_cycling = "Auto"
	HK21.rat_barrel_len = 530
	HK21.rat_weigth = 8000
	HK21.ScrapParts = 16
	HK21.RepairCost = 80
	HK21.Reliability = 82
	HK21.AdditionalHint = T{671286970025,[[<description_hints>]]}
	HK21.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong', 'BarrelLongImproved', 'BarrelNormal', 'BarrelNormalImproved', 'BarrelShort', 'BarrelShortImproved', 'long_barrel_light', 'BarrelShort_Light', 'BarrelLight', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'DefaultMuzzle_HK21', Modifiable = true, AvailableComponents = {'DefaultMuzzle_HK21', 'MuzzleBooster', 'Compensator', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ImprovedIronsight', 'LROptics', 'LROpticsAdvanced', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', 'WideScope', '_ReflexSIghtVigilance', 'PSG_DefaultScope', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockNormal', 'StockLight', }}, {CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = true, AvailableComponents = {'TacGrip', 'VerticalGrip', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_8', }}}
	HK21.Valuable = 1
	HK21.CanAppearInShop = true
	HK21.Tier = 3
	HK21.MaxStock = 1
	HK21.RestockWeight = 40
	HK21.CategoryPair = "MachineGuns"
	HK21.PenetrationClass = 1


	FNFAL.is_vanilla_firearm = true
	FNFAL.Cost = 5340
	FNFAL.Damage = 30
	FNFAL.CritChanceScaled = 10
	storeProps(FNFAL, "AimAccuracy", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNFAL, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNFAL, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNFAL, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	FNFAL.PBbonus_base = -2
	FNFAL.HandlingBaseMul = 104
	FNFAL.ShootAP = 4000
	FNFAL.ReloadAP = 3000
	FNFAL.OverwatchAngle = 1021
	FNFAL.MagazineSize = 20
	FNFAL.Cumbersome = 0
	FNFAL.Noise = 22
	FNFAL.PointBlankBonus = 1
	FNFAL.PreparedAttackType = "Overwatch"
	FNFAL.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	FNFAL.APStance = 4
	FNFAL.Rat_swap_ap = 3
	FNFAL.wep_base_recoil_mul = 95
	FNFAL.wep_base_snapshot_mul = 106
	FNFAL.wep_base_hip_mul = 93
	FNFAL.weigth_held_mul = 132
	FNFAL.recoil_mechanism = "Gas_Operated"
	FNFAL.Rat_cycling = "Auto"
	FNFAL.rat_barrel_len = 450
	FNFAL.rat_weigth = 4600
	FNFAL.ScrapParts = 10
	FNFAL.RepairCost = 80
	FNFAL.Reliability = 79
	FNFAL.AdditionalHint = T{634047228362,[[<description_hints>]]}
	FNFAL.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Handguard', DefaultComponent = 'FNFAL_Handguard', Modifiable = false, AvailableComponents = {'FNFAL_Handguard', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ScopeCOG', 'ScopeCOGQuick', 'LROptics', 'ThermalScope', 'ReflexSight', 'ReflexSightAdvanced', 'WideScope', '_ReflexSIghtVigilance', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'Suppressor', 'ImprovisedSuppressor', 'MuzzleBooster', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagNormalFine', 'MagLarge', 'MagLargeFine', }}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelNormalImproved', 'BarrelHeavy', 'BarrelLong', 'BarrelLongImproved', 'BarrelShort', 'BarrelShortImproved', 'long_barrel_light', 'BarrelShort_Light', 'BarrelLight', 'BarrelHeavyLong', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge', 'MagLargeFine', 'MagNormal', 'MagNormalFine', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockNormal', 'StockHeavy', 'StockLight', 'StockNo', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = true, AvailableComponents = {'GrenadeLauncher', 'TacGrip', 'VerticalGrip', }}}
	FNFAL.Valuable = 1
	FNFAL.CanAppearInShop = true
	FNFAL.Tier = 2
	FNFAL.MaxStock = 3
	FNFAL.RestockWeight = 40
	FNFAL.CategoryPair = "AssaultRifles"
	FNFAL.PenetrationClass = 1


	Galil_FlagHill.is_vanilla_firearm = true
	Galil_FlagHill.Cost = 7860
	Galil_FlagHill.Damage = 30
	Galil_FlagHill.CritChanceScaled = 30
	storeProps(Galil_FlagHill, "AimAccuracy", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil_FlagHill, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil_FlagHill, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil_FlagHill, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Galil_FlagHill.PBbonus_base = 2
	Galil_FlagHill.HandlingBaseMul = 101
	Galil_FlagHill.ShootAP = 4000
	Galil_FlagHill.ReloadAP = 3000
	Galil_FlagHill.OverwatchAngle = 1080
	Galil_FlagHill.MagazineSize = 25
	Galil_FlagHill.Cumbersome = 0
	Galil_FlagHill.Noise = 22
	Galil_FlagHill.PointBlankBonus = 1
	Galil_FlagHill.PreparedAttackType = "Overwatch"
	Galil_FlagHill.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	Galil_FlagHill.APStance = 4
	Galil_FlagHill.Rat_swap_ap = 3
	Galil_FlagHill.wep_base_recoil_mul = 100
	Galil_FlagHill.wep_base_snapshot_mul = 106
	Galil_FlagHill.wep_base_hip_mul = 93
	Galil_FlagHill.weigth_held_mul = 100
	Galil_FlagHill.recoil_mechanism = "Gas_Operated"
	Galil_FlagHill.Rat_cycling = "Auto"
	Galil_FlagHill.ScrapParts = 10
	Galil_FlagHill.RepairCost = 50
	Galil_FlagHill.Reliability = 87
	Galil_FlagHill.AdditionalHint = T{811371938636,[[<description_hints>]]}
	Galil_FlagHill.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'long_barrel_light', Modifiable = false, AvailableComponents = {'long_barrel_light', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = false, AvailableComponents = {'StockNormal', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'Galil_Brake_Default', Modifiable = false, AvailableComponents = {'Galil_Brake_Default', }}, {CanBeEmpty = false, SlotType = 'Under', DefaultComponent = 'Bipod_Galil', Modifiable = false, AvailableComponents = {'Bipod_Galil', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'WideScope', Modifiable = false, AvailableComponents = {'WideScope', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = false, AvailableComponents = {'MagNormal', }}}
	Galil_FlagHill.PenetrationClass = 1


	FNMinimi.is_vanilla_firearm = true
	FNMinimi.Cost = 11220
	FNMinimi.Damage = 23
	FNMinimi.CritChanceScaled = 10
	storeProps(FNMinimi, "AimAccuracy", 25, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNMinimi, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNMinimi, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNMinimi, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	FNMinimi.PBbonus_base = -1
	FNMinimi.HandlingBaseMul = 116
	FNMinimi.HandlingNotProneMul = 195
	FNMinimi.ShootAP = 4000
	FNMinimi.ReloadAP = 5000
	FNMinimi.OverwatchAngle = 781
	FNMinimi.MagazineSize = 100
	FNMinimi.Cumbersome = 0
	FNMinimi.Noise = 22
	FNMinimi.PointBlankBonus = 1
	FNMinimi.PreparedAttackType = "Machine Gun"
	FNMinimi.AvailableAttacks = {"MGBurstFire"}
	FNMinimi.APStance = 5
	FNMinimi.Rat_swap_ap = 3
	FNMinimi.wep_base_recoil_mul = 91
	FNMinimi.wep_base_snapshot_mul = 119
	FNMinimi.wep_base_hip_mul = 97
	FNMinimi.weigth_held_mul = 156
	FNMinimi.recoil_mechanism = "Gas_Operated"
	FNMinimi.Rat_cycling = "Auto"
	FNMinimi.rat_barrel_len = 460
	FNMinimi.rat_weigth = 7900
	FNMinimi.ScrapParts = 16
	FNMinimi.RepairCost = 120
	FNMinimi.Reliability = 85
	FNMinimi.AdditionalHint = T{616169182043,[[<description_hints>]]}
	FNMinimi.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong', 'BarrelLongImproved', 'BarrelNormal', 'BarrelNormalImproved', 'BarrelShort', 'BarrelShortImproved', 'long_barrel_light', 'BarrelLight', 'BarrelShort_Light', }}, {CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockNormal', 'StockLight', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ImprovedIronsight', 'ReflexSight', 'ReflexSightAdvanced', 'LROptics', 'LROpticsAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', 'WideScope', '_ReflexSIghtVigilance', 'PSG_DefaultScope', 'UVDot_Anaconda', 'LaserDot_Anaconda', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_12', }}}
	FNMinimi.CanAppearInShop = true
	FNMinimi.Tier = 3
	FNMinimi.MaxStock = 1
	FNMinimi.RestockWeight = 25
	FNMinimi.CategoryPair = "MachineGuns"
	FNMinimi.PenetrationClass = 1


	RPK74.is_vanilla_firearm = true
	RPK74.Cost = 6280
	RPK74.Damage = 24
	RPK74.CritChanceScaled = 10
	storeProps(RPK74, "AimAccuracy", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPK74, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPK74, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPK74, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	RPK74.PBbonus_base = -3
	RPK74.HandlingBaseMul = 110
	RPK74.HandlingNotProneMul = 180
	RPK74.ShootAP = 4000
	RPK74.ReloadAP = 4000
	RPK74.OverwatchAngle = 815
	RPK74.MagazineSize = 45
	RPK74.Cumbersome = 0
	RPK74.Noise = 22
	RPK74.PointBlankBonus = 1
	RPK74.PreparedAttackType = "Machine Gun"
	RPK74.AvailableAttacks = {"MGBurstFire"}
	RPK74.APStance = 4
	RPK74.Rat_swap_ap = 3
	RPK74.wep_base_recoil_mul = 91
	RPK74.wep_base_snapshot_mul = 119
	RPK74.wep_base_hip_mul = 91
	RPK74.weigth_held_mul = 140
	RPK74.recoil_mechanism = "Gas_Operated"
	RPK74.Rat_cycling = "Auto"
	RPK74.rat_barrel_len = 580
	RPK74.rat_weigth = 5600
	RPK74.ScrapParts = 16
	RPK74.RepairCost = 80
	RPK74.Reliability = 89
	RPK74.AdditionalHint = T{553717282985,[[<description_hints>]]}
	RPK74.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Bipod', DefaultComponent = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelNormalImproved', 'BarrelLight', 'rpk_to762wp', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagNormalFine', 'MagQuick', 'MagLarge_2', }}, {CanBeEmpty = false, SlotType = 'Handguard', DefaultComponent = 'RPK74_Hanguard_Basic', Modifiable = true, AvailableComponents = {'RPK74_Hanguard_Basic', 'RPK74_VerticalGrip', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ScopeCOG', 'ThermalScope', 'LROpticsAdvanced', 'ScopeCOGQuick', 'ReflexSightAdvanced', '_ReflexSIghtVigilance', 'WideScope', 'LROptics_DragunovDefault', 'UVDot_Anaconda', 'LaserDot_Anaconda', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'MuzzleBooster', 'Suppressor', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockNormal', 'StockLight', }}}
	RPK74.CanAppearInShop = true
	RPK74.Tier = 2
	RPK74.MaxStock = 2
	RPK74.RestockWeight = 30
	RPK74.CategoryPair = "MachineGuns"
	RPK74.PenetrationClass = 1


	MG42.is_vanilla_firearm = true
	MG42.Cost = 2520
	MG42.Damage = 28
	MG42.CritChanceScaled = 10
	storeProps(MG42, "AimAccuracy", 21, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG42, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG42, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG42, "WeaponRange", 38, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MG42.PBbonus_base = -4
	MG42.HandlingBaseMul = 125
	MG42.HandlingNotProneMul = 250
	MG42.ShootAP = 4000
	MG42.ReloadAP = 5000
	MG42.OverwatchAngle = 571
	MG42.MagazineSize = 50
	MG42.Cumbersome = 1
	MG42.Noise = 22
	MG42.PointBlankBonus = 1
	MG42.PreparedAttackType = "Machine Gun"
	MG42.AvailableAttacks = {"MGBurstFire"}
	MG42.APStance = 5
	MG42.Rat_swap_ap = 3
	MG42.wep_base_recoil_mul = 82
	MG42.wep_base_snapshot_mul = 138
	MG42.wep_base_hip_mul = 92
	MG42.weigth_held_mul = 182
	MG42.recoil_mechanism = "Short_Recoil"
	MG42.Rat_cycling = "Auto"
	MG42.rat_barrel_len = 550
	MG42.rat_weigth = 11600
	MG42.ScrapParts = 12
	MG42.RepairCost = 80
	MG42.Reliability = 85
	MG42.AdditionalHint = T{386845693893,[[<description_hints>]]}
	MG42.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Bipod_MG42', Modifiable = false, AvailableComponents = {'Bipod_MG42', }}}
	MG42.CanAppearInShop = true
	MG42.Tier = 1
	MG42.MaxStock = 1
	MG42.RestockWeight = 80
	MG42.CategoryPair = "MachineGuns"
	MG42.PenetrationClass = 1


	BrowningM2HMG.is_vanilla_firearm = true
	BrowningM2HMG.Cost = 2520
	BrowningM2HMG.Damage = 45
	BrowningM2HMG.CritChanceScaled = 10
	storeProps(BrowningM2HMG, "AimAccuracy", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BrowningM2HMG, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BrowningM2HMG, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BrowningM2HMG, "WeaponRange", 38, "oldCTH", GBO_gCTHModeItemPropertyTable)
	BrowningM2HMG.PBbonus_base = 0
	BrowningM2HMG.HandlingBaseMul = 100
	BrowningM2HMG.ShootAP = 4000
	BrowningM2HMG.ReloadAP = 6000
	BrowningM2HMG.OverwatchAngle = 3600
	BrowningM2HMG.MagazineSize = 100
	BrowningM2HMG.Cumbersome = 1
	BrowningM2HMG.Noise = 30
	BrowningM2HMG.PointBlankBonus = 1
	BrowningM2HMG.PreparedAttackType = "Machine Gun"
	BrowningM2HMG.AvailableAttacks = {"MGBurstFire"}
	BrowningM2HMG.long_shots = 5
	BrowningM2HMG.Rat_swap_ap = 3
	BrowningM2HMG.wep_base_recoil_mul = 60
	BrowningM2HMG.wep_base_snapshot_mul = 90
	BrowningM2HMG.wep_base_hip_mul = 100
	BrowningM2HMG.weigth_held_mul = 100
	BrowningM2HMG.recoil_mechanism = "Recoil_Operated"
	BrowningM2HMG.Rat_cycling = "Auto"
	BrowningM2HMG.ScrapParts = 20
	BrowningM2HMG.RepairCost = 80
	BrowningM2HMG.Reliability = 90
	BrowningM2HMG.AdditionalHint = T{891996501927,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Stationary weapon
 ]]}
	BrowningM2HMG.ComponentSlots = {{CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'browning_bipod', Modifiable = false, AvailableComponents = {'browning_bipod', }}}
	BrowningM2HMG.Tier = 1
	BrowningM2HMG.MaxStock = 3
	BrowningM2HMG.PenetrationClass = 1


	G36.is_vanilla_firearm = true
	G36.Cost = 9000
	G36.Damage = 23
	G36.CritChanceScaled = 20
	storeProps(G36, "AimAccuracy", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G36, "AimAccuracy", 6, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G36, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G36, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	G36.PBbonus_base = 1
	G36.HandlingBaseMul = 104
	G36.ShootAP = 3000
	G36.ReloadAP = 3000
	G36.OverwatchAngle = 1023
	G36.MagazineSize = 30
	G36.Cumbersome = 0
	G36.Noise = 18
	G36.PointBlankBonus = 1
	G36.PreparedAttackType = "Overwatch"
	G36.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	G36.burst_shots = 2
	G36.APStance = 4
	G36.Rat_swap_ap = 3
	G36.wep_base_recoil_mul = 98
	G36.wep_base_snapshot_mul = 106
	G36.wep_base_hip_mul = 96
	G36.weigth_held_mul = 128
	G36.burst_selective = true
	G36.AutoFireCustomDeltaAP = 1
	G36.SingleShotCustomDeltaAP = 1
	G36.burst_recoil_delta = 70
	G36.recoil_mechanism = "Gas_Operated"
	G36.Rat_cycling = "Auto"
	G36.rat_barrel_len = 480
	G36.rat_weigth = 4000
	G36.ScrapParts = 10
	G36.RepairCost = 80
	G36.Reliability = 82
	G36.AdditionalHint = T{507516354956,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Special 2-shot burst mode with improved critical chance and reduced recoil]]}
	G36.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'long_barrel_light', 'BarrelLong', 'BarrelHeavyLong', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'G36_SCOPE', Modifiable = true, AvailableComponents = {'G36_SCOPE', 'ThermalScope', 'ReflexSightAdvanced', 'SCOPE_G36_2', 'PSG_DefaultScope', '_ReflexSIghtVigilance', 'WideScope', 'ScopeCOG', 'ScopeCOGQuick', 'LROptics', 'ImprovedIronsight', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'Compensator', Modifiable = true, AvailableComponents = {'Compensator', 'Suppressor', 'ImprovisedSuppressor', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_9', 'MagQuick', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = true, AvailableComponents = {'TacGrip', 'VerticalGrip', 'GrenadeLauncher', 'Bipod_Under', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'foldable_StockNormal', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockLight', 'foldable_StockNormal', 'StockFolded', }}}
	G36.Valuable = 1
	G36.CanAppearInShop = true
	G36.Tier = 3
	G36.MaxStock = 3
	G36.RestockWeight = 20
	G36.CategoryPair = "AssaultRifles"
	G36.PenetrationClass = 1


	AK74.is_vanilla_firearm = true
	AK74.Cost = 7500
	AK74.Damage = 25
	AK74.CritChanceScaled = 20
	storeProps(AK74, "AimAccuracy", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK74, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK74, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK74, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AK74.PBbonus_base = 3
	AK74.HandlingBaseMul = 100
	AK74.ShootAP = 4000
	AK74.ReloadAP = 3000
	AK74.OverwatchAngle = 1127
	AK74.MagazineSize = 30
	AK74.Cumbersome = 0
	AK74.Noise = 22
	AK74.PointBlankBonus = 1
	AK74.PreparedAttackType = "Overwatch"
	AK74.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	AK74.APStance = 4
	AK74.Rat_swap_ap = 3
	AK74.wep_base_recoil_mul = 100
	AK74.wep_base_snapshot_mul = 101
	AK74.wep_base_hip_mul = 100
	AK74.weigth_held_mul = 127
	AK74.recoil_mechanism = "Gas_Operated"
	AK74.Rat_cycling = "Auto"
	AK74.rat_barrel_len = 410
	AK74.rat_weigth = 3800
	AK74.ScrapParts = 10
	AK74.RepairCost = 20
	AK74.Reliability = 90
	AK74.AdditionalHint = T{470765972773,[[<description_hints>]]}
	AK74.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockHeavy', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockLight', 'StockNo', 'StockNormal', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormalFine', Modifiable = true, AvailableComponents = {'MagNormalFine', 'MagLarge', 'MagLargeFine', 'MagQuick', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'LROpticsAdvanced', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', 'WideScope', '_ReflexSIghtVigilance', 'LROptics_DragunovDefault', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'MuzzleBooster', 'ImprovisedSuppressor', 'Suppressor', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = true, AvailableComponents = {'GrenadeLauncher', 'Bipod_Under', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Barrel', Modifiable = true, AvailableComponents = {'BarrelHeavy', 'BarrelLight', }}}
	AK74.Valuable = 1
	AK74.CanAppearInShop = true
	AK74.Tier = 3
	AK74.MaxStock = 3
	AK74.RestockWeight = 80
	AK74.CategoryPair = "AssaultRifles"
	AK74.PenetrationClass = 1


	AR15.is_vanilla_firearm = true
	AR15.Cost = 5160
	AR15.Damage = 24
	AR15.CritChanceScaled = 20
	storeProps(AR15, "AimAccuracy", 29, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR15, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR15, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR15, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AR15.PBbonus_base = 2
	AR15.HandlingBaseMul = 100
	AR15.ShootAP = 4000
	AR15.ReloadAP = 3000
	AR15.OverwatchAngle = 1130
	AR15.MagazineSize = 30
	AR15.Cumbersome = 0
	AR15.Noise = 20
	AR15.PointBlankBonus = 1
	AR15.PreparedAttackType = "Overwatch"
	AR15.AvailableAttacks = {"SingleShot", "BurstFire", "CancelShot"}
	AR15.APStance = 4
	AR15.Rat_swap_ap = 3
	AR15.wep_base_recoil_mul = 101
	AR15.wep_base_snapshot_mul = 101
	AR15.wep_base_hip_mul = 98
	AR15.weigth_held_mul = 121
	AR15.recoil_mechanism = "Gas_Operated"
	AR15.Rat_cycling = "SemiAuto"
	AR15.rat_barrel_len = 450
	AR15.rat_weigth = 3000
	AR15.ScrapParts = 10
	AR15.RepairCost = 80
	AR15.Reliability = 80
	AR15.AdditionalHint = T{145852997392,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Only semi-auto with standard stocks]]}
	AR15.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'DefaultIronsight_AR15', Modifiable = true, AvailableComponents = {'ScopeCOG', 'LROptics', 'LROpticsAdvanced', 'ThermalScope', 'ReflexSight', 'DefaultIronsight_AR15', 'ImprovedIronsight_AR15', 'WideScope', '_ReflexSIghtVigilance', 'ReflexSightAdvanced', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagNormalFine', 'MagLarge', 'MagLargeFine', 'MagQuick', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelNormalImproved', 'BarrelShort', 'BarrelShortImproved', 'BarrelLongImproved', 'BarrelLight', 'long_barrel_light', 'BarrelShort_Light', 'BarrelHeavyLong', 'BarrelLong', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockHeavy_AR_BurstOnly', Modifiable = true, AvailableComponents = {'StockHeavy_AR_BurstOnly', 'StockLight_AR_BurstOnly', 'StockBump', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = true, AvailableComponents = {'GrenadeLauncher', 'VerticalGrip', 'TacGrip', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Muzzle', DefaultComponent = 'Compensator', Modifiable = true, AvailableComponents = {'Compensator', 'ImprovisedSuppressor', 'Suppressor', 'MuzzleBooster', }}}
	AR15.CanAppearInShop = true
	AR15.Tier = 2
	AR15.MaxStock = 3
	AR15.RestockWeight = 90
	AR15.CategoryPair = "AssaultRifles"
	AR15.PenetrationClass = 1


	M16A2.is_vanilla_firearm = true
	M16A2.object_class = "AssaultRifle"
	M16A2.Cost = 5940
	M16A2.Damage = 24
	M16A2.CritChanceScaled = 10
	storeProps(M16A2, "AimAccuracy", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M16A2, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M16A2, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M16A2, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M16A2.PBbonus_base = 1
	M16A2.HandlingBaseMul = 104
	M16A2.ShootAP = 4000
	M16A2.ReloadAP = 3000
	M16A2.OverwatchAngle = 1024
	M16A2.MagazineSize = 20
	M16A2.Cumbersome = 0
	M16A2.Noise = 18
	M16A2.PointBlankBonus = 1
	M16A2.PreparedAttackType = "Overwatch"
	M16A2.AvailableAttacks = {"BurstFire", "SingleShot", "CancelShot"}
	M16A2.APStance = 4
	M16A2.Rat_swap_ap = 3
	M16A2.wep_base_recoil_mul = 98
	M16A2.wep_base_snapshot_mul = 106
	M16A2.wep_base_hip_mul = 95
	M16A2.weigth_held_mul = 125
	M16A2.burst_selective = true
	M16A2.burst_recoil_delta = 90
	M16A2.recoil_mechanism = "Gas_Operated"
	M16A2.Rat_cycling = "Auto"
	M16A2.rat_barrel_len = 500
	M16A2.rat_weigth = 3600
	M16A2.ScrapParts = 10
	M16A2.RepairCost = 80
	M16A2.Reliability = 78
	M16A2.AdditionalHint = T{550693603298,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No Auto firing mode]]}
	M16A2.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Handguard', Modifiable = false, AvailableComponents = { }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ScopeCOG', 'ScopeCOGQuick', 'LROptics', 'ThermalScope', 'ReflexSight', 'WideScope', '_ReflexSIghtVigilance', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', DefaultComponent = 'Compensator', Modifiable = true, AvailableComponents = {'Compensator', 'Suppressor', 'ImprovisedSuppressor', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelLight', 'BarrelHeavy', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge', 'MagNormal', 'R_MagQuickLarge', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockNormal', 'StockLight', 'StockNo', }}, {CanBeEmpty = false, SlotType = 'Under', DefaultComponent = 'M16_Handguard', Modifiable = true, AvailableComponents = {'GrenadeLauncher_M16A1', 'VerticalGrip_M16', 'M16_Handguard', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}}
	M16A2.CanAppearInShop = true
	M16A2.Tier = 2
	M16A2.MaxStock = 3
	M16A2.RestockWeight = 40
	M16A2.CategoryPair = "AssaultRifles"
	M16A2.PenetrationClass = 1


	AK47.is_vanilla_firearm = true
	AK47.Cost = 1680
	AK47.Damage = 26
	AK47.CritChanceScaled = 10
	storeProps(AK47, "AimAccuracy", 21, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK47, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK47, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK47, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AK47.PBbonus_base = 4
	AK47.HandlingBaseMul = 105
	AK47.ShootAP = 4000
	AK47.ReloadAP = 3000
	AK47.OverwatchAngle = 1086
	AK47.MagazineSize = 30
	AK47.Cumbersome = 0
	AK47.Noise = 22
	AK47.PointBlankBonus = 1
	AK47.PreparedAttackType = "Overwatch"
	AK47.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	AK47.APStance = 4
	AK47.Rat_swap_ap = 3
	AK47.wep_base_recoil_mul = 99
	AK47.wep_base_snapshot_mul = 103
	AK47.weigth_held_mul = 131
	AK47.recoil_mechanism = "Gas_Operated"
	AK47.Rat_cycling = "Auto"
	AK47.rat_barrel_len = 410
	AK47.rat_weigth = 4400
	AK47.ScrapParts = 10
	AK47.RepairCost = 20
	AK47.Reliability = 90
	AK47.AdditionalHint = T{720411688179,[[<description_hints>]]}
	AK47.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = true, SlotType = 'Grenadelauncher', Modifiable = true, AvailableComponents = {'AK47_Launcher', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockNormal', 'StockLight', 'StockNo', 'StockHeavy', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge', 'MagQuick', }}, {CanBeEmpty = false, SlotType = 'Handguard', DefaultComponent = 'AK47_Handguard_basic', Modifiable = true, AvailableComponents = {'AK47_VerticalGrip', 'AK47_Handguard_basic', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ScopeCOG', 'ThermalScope', 'LROptics_DragunovDefault', 'WideScope', 'ScopeCOGQuick', 'ReflexSightAdvanced', '_ReflexSIghtVigilance', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'MuzzleBooster', 'Suppressor', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Barrel', Modifiable = true, AvailableComponents = {'BarrelLight', 'BarrelHeavy', }}}
	AK47.CanAppearInShop = true
	AK47.Tier = 1
	AK47.MaxStock = 5
	AK47.RestockWeight = 120
	AK47.CategoryPair = "AssaultRifles"
	AK47.PenetrationClass = 1


	AUG.is_vanilla_firearm = true
	AUG.Cost = 6120
	AUG.Damage = 23
	AUG.CritChanceScaled = 10
	storeProps(AUG, "AimAccuracy", 29, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AUG, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AUG, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AUG, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AUG.PBbonus_base = 0
	AUG.HandlingBaseMul = 106
	AUG.ShootAP = 4000
	AUG.ReloadAP = 3000
	AUG.OverwatchAngle = 983
	AUG.MagazineSize = 30
	AUG.Cumbersome = 0
	AUG.Noise = 20
	AUG.PointBlankBonus = 1
	AUG.PreparedAttackType = "Overwatch"
	AUG.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	AUG.APStance = 3
	AUG.Rat_swap_ap = 3
	AUG.wep_base_recoil_mul = 97
	AUG.wep_base_snapshot_mul = 108
	AUG.wep_base_hip_mul = 95
	AUG.weigth_held_mul = 130
	AUG.burst_selective = true
	AUG.burst_recoil_delta = 95
	AUG.recoil_mechanism = "Gas_Operated"
	AUG.Rat_cycling = "Auto"
	AUG.rat_barrel_len = 500
	AUG.rat_weigth = 4200
	AUG.ScrapParts = 10
	AUG.RepairCost = 80
	AUG.Reliability = 85
	AUG.AdditionalHint = T{780533559812,[[<description_hints>]]}
	AUG.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelShort_AUG', 'BarrelShortImproved_AUG', 'BarrelLong_AUG', 'BarrelLongImproved_AUG', 'BarrelLight', 'long_barrel_AUG_light', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'AUGCompensator_01', Modifiable = true, AvailableComponents = {'AUGCompensator_01', 'AUGCompensator_03', 'Suppressor', }}, {CanBeEmpty = true, SlotType = 'Under', DefaultComponent = 'VerticalGrip', Modifiable = true, AvailableComponents = {'VerticalGrip', }}, {CanBeEmpty = true, SlotType = 'Grenadelauncher', Modifiable = true, AvailableComponents = {'GrenadeLauncher_AUG', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge_7', 'MagNormal', 'MagQuick', }}, {CanBeEmpty = true, SlotType = 'Mount', Modifiable = false, AvailableComponents = {'AUGMount', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'AUGScope_Default', Modifiable = true, AvailableComponents = {'LROptics', 'LROpticsAdvanced', 'ThermalScope', 'ReflexSight', 'ScopeCOG', 'AUGScope_Default', '_ReflexSIghtVigilance', 'WideScope', 'ReflexSightAdvanced', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'bullup', Modifiable = false, AvailableComponents = {'bullup', }}}
	AUG.Valuable = 1
	AUG.CanAppearInShop = true
	AUG.Tier = 2
	AUG.MaxStock = 3
	AUG.RestockWeight = 20
	AUG.CategoryPair = "AssaultRifles"
	AUG.PenetrationClass = 1


	Galil.is_vanilla_firearm = true
	Galil.Cost = 7860
	Galil.Damage = 30
	Galil.CritChanceScaled = 20
	storeProps(Galil, "AimAccuracy", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Galil.PBbonus_base = 3
	Galil.HandlingBaseMul = 102
	Galil.ShootAP = 4000
	Galil.ReloadAP = 3000
	Galil.OverwatchAngle = 1052
	Galil.MagazineSize = 25
	Galil.Cumbersome = 0
	Galil.Noise = 22
	Galil.PointBlankBonus = 1
	Galil.PreparedAttackType = "Overwatch"
	Galil.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	Galil.APStance = 4
	Galil.Rat_swap_ap = 3
	Galil.wep_base_recoil_mul = 92
	Galil.wep_base_snapshot_mul = 112
	Galil.wep_base_hip_mul = 93
	Galil.weigth_held_mul = 131
	Galil.recoil_mechanism = "Gas_Operated"
	Galil.Rat_cycling = "Auto"
	Galil.rat_barrel_len = 535
	Galil.rat_weigth = 4450
	Galil.ScrapParts = 10
	Galil.RepairCost = 50
	Galil.Reliability = 87
	Galil.AdditionalHint = T{233977894097,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> In-built bottle opener]]}
	Galil.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong', 'BarrelNormal', 'BarrelShort', 'long_barrel_light', 'BarrelLight', 'BarrelShort_Light', 'BarrelHeavyLong', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockHeavy', 'StockLight', 'StockNormal', 'StockNo', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'Galil_Brake_Default', Modifiable = true, AvailableComponents = {'Galil_Brake_Default', 'Compensator', 'Suppressor', 'ImprovisedSuppressor', 'MuzzleBooster', }}, {CanBeEmpty = false, SlotType = 'Under', DefaultComponent = 'Galil_Handguard_Default', Modifiable = true, AvailableComponents = {'GrenadeLauncher_Galil', 'Galil_Handguard_Default', 'Bipod_Galil', 'VerticalGrip', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ThermalScope', 'ScopeCOG', '_ReflexSIghtVigilance', 'WideScope', 'ReflexSightAdvanced', 'ScopeCOGQuick', 'ImprovedIronsight', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge', 'MagNormal', 'MagQuick', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}}
	Galil.Valuable = 1
	Galil.CanAppearInShop = true
	Galil.Tier = 3
	Galil.MaxStock = 3
	Galil.RestockWeight = 40
	Galil.CategoryPair = "AssaultRifles"
	Galil.PenetrationClass = 1


	M4Commando.is_vanilla_firearm = true
	M4Commando.Cost = 10050
	M4Commando.Damage = 23
	M4Commando.CritChanceScaled = 10
	storeProps(M4Commando, "AimAccuracy", 27, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M4Commando, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M4Commando, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M4Commando, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M4Commando.PBbonus_base = 7
	M4Commando.HandlingBaseMul = 100
	M4Commando.ShootAP = 3000
	M4Commando.ReloadAP = 3000
	M4Commando.OverwatchAngle = 1429
	M4Commando.MagazineSize = 20
	M4Commando.Cumbersome = 0
	M4Commando.Noise = 20
	M4Commando.PointBlankBonus = 1
	M4Commando.PreparedAttackType = "Overwatch"
	M4Commando.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
	M4Commando.APStance = 3
	M4Commando.Rat_swap_ap = 2
	M4Commando.wep_base_recoil_mul = 116
	M4Commando.wep_base_snapshot_mul = 86
	M4Commando.wep_base_hip_mul = 108
	M4Commando.weigth_held_mul = 117
	M4Commando.recoil_mechanism = "Gas_Operated"
	M4Commando.Rat_cycling = "Auto"
	M4Commando.rat_barrel_len = 250
	M4Commando.rat_weigth = 2430
	M4Commando.ScrapParts = 10
	M4Commando.RepairCost = 80
	M4Commando.Reliability = 74
	M4Commando.AdditionalHint = T{502423132983,[[<description_hints>]]}
	M4Commando.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Under', DefaultComponent = 'Handguard_Commando', Modifiable = true, AvailableComponents = {'Handguard_Commando', 'VerticalGrip_Commando', 'GrenadeLauncher_Commando', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagNormalFine', 'MagLarge', 'MagLargeFine', 'R_MagQuickLarge', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = true, AvailableComponents = {'StockNormal', 'StockLight', 'StockNo', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ScopeCOG', 'ThermalScope', 'ReflexSightAdvanced', 'ScopeCOGQuick', '_ReflexSIghtVigilance', 'WideScope', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', DefaultComponent = 'Compensator', Modifiable = true, AvailableComponents = {'Compensator', 'MuzzleBooster', 'Suppressor', 'ImprovisedSuppressor', }}}
	M4Commando.Valuable = 1
	M4Commando.CanAppearInShop = true
	M4Commando.Tier = 3
	M4Commando.MaxStock = 3
	M4Commando.RestockWeight = 30
	M4Commando.CategoryPair = "SubmachineGuns"
	M4Commando.PenetrationClass = 1


	Winchester1894.is_vanilla_firearm = true
	Winchester1894.object_class = "AssaultRifle"
	Winchester1894.Cost = 2700
	Winchester1894.Damage = 28
	Winchester1894.CritChanceScaled = 10
	storeProps(Winchester1894, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester1894, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester1894, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester1894, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Winchester1894.PBbonus_base = 0
	Winchester1894.HandlingBaseMul = 102
	Winchester1894.ShootAP = 4000
	Winchester1894.ReloadAP = 3000
	Winchester1894.OverwatchAngle = 1053
	Winchester1894.MagazineSize = 9
	Winchester1894.Cumbersome = 0
	Winchester1894.Noise = 20
	Winchester1894.PointBlankBonus = 1
	Winchester1894.PreparedAttackType = "Both"
	Winchester1894.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	Winchester1894.APStance = 4
	Winchester1894.Rat_swap_ap = 3
	Winchester1894.wep_base_recoil_mul = 97
	Winchester1894.wep_base_snapshot_mul = 107
	Winchester1894.wep_base_hip_mul = 93
	Winchester1894.weigth_held_mul = 121
	Winchester1894.recoil_mechanism = "Lever_Action"
	Winchester1894.Rat_cycling = "LeverAction"
	Winchester1894.rat_barrel_len = 540
	Winchester1894.rat_weigth = 3000
	Winchester1894.ScrapParts = 8
	Winchester1894.RepairCost = 80
	Winchester1894.Reliability = 85
	Winchester1894.AdditionalHint = T{709693708737,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Lever action
 ]]}
	Winchester1894.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong', 'BarrelNormal', 'BarrelShort_Winchester', 'BarrelLight', 'long_barrel_light', 'winni_to54r', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Suppressor', 'ImprovisedSuppressor', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ImprovedIronsight', 'LROptics', 'LROpticsAdvanced', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', '_ReflexSIghtVigilance', 'WideScope', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'lever_action', Modifiable = false, AvailableComponents = {'lever_action', }}}
	Winchester1894.CanAppearInShop = true
	Winchester1894.Tier = 1
	Winchester1894.MaxStock = 3
	Winchester1894.CategoryPair = "Rifles"
	Winchester1894.PenetrationClass = 1


	Winchester_Quest.is_vanilla_firearm = true
	Winchester_Quest.object_class = "AssaultRifle"
	Winchester_Quest.Cost = 2700
	Winchester_Quest.Damage = 27
	Winchester_Quest.CritChanceScaled = 10
	storeProps(Winchester_Quest, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester_Quest, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester_Quest, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester_Quest, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Winchester_Quest.PBbonus_base = 2
	Winchester_Quest.HandlingBaseMul = 102
	Winchester_Quest.ShootAP = 4000
	Winchester_Quest.ReloadAP = 3000
	Winchester_Quest.OverwatchAngle = 1320
	Winchester_Quest.MagazineSize = 4
	Winchester_Quest.Cumbersome = 0
	Winchester_Quest.Noise = 30
	Winchester_Quest.PointBlankBonus = 1
	Winchester_Quest.PreparedAttackType = "Both"
	Winchester_Quest.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	Winchester_Quest.APStance = 4
	Winchester_Quest.Rat_swap_ap = 3
	Winchester_Quest.wep_base_recoil_mul = 97
	Winchester_Quest.wep_base_snapshot_mul = 100
	Winchester_Quest.wep_base_hip_mul = 93
	Winchester_Quest.weigth_held_mul = 100
	Winchester_Quest.recoil_mechanism = "Lever_Action"
	Winchester_Quest.Rat_cycling = "LeverAction"
	Winchester_Quest.ScrapParts = 8
	Winchester_Quest.RepairCost = 80
	Winchester_Quest.Reliability = 85
	Winchester_Quest.AdditionalHint = T{271837025192,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Backstabby and Silent
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Lever action
 ]]}
	Winchester_Quest.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'barrel_confidante', Modifiable = false, AvailableComponents = {'barrel_confidante', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'stealth_ironsight_confidante', Modifiable = false, AvailableComponents = {'stealth_ironsight_confidante', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'Suppressor', Modifiable = false, AvailableComponents = {'Suppressor', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'lever_action', Modifiable = false, AvailableComponents = {'lever_action', }}}
	Winchester_Quest.PenetrationClass = 1


	FAMAS.is_vanilla_firearm = true
	FAMAS.Cost = 3120
	FAMAS.Damage = 22
	FAMAS.CritChanceScaled = 10
	storeProps(FAMAS, "AimAccuracy", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FAMAS, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FAMAS, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FAMAS, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	FAMAS.PBbonus_base = 0
	FAMAS.HandlingBaseMul = 102
	FAMAS.ShootAP = 4000
	FAMAS.ReloadAP = 4000
	FAMAS.OverwatchAngle = 1051
	FAMAS.MagazineSize = 25
	FAMAS.Cumbersome = 0
	FAMAS.Noise = 18
	FAMAS.PointBlankBonus = 1
	FAMAS.PreparedAttackType = "Overwatch"
	FAMAS.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	FAMAS.APStance = 3
	FAMAS.Rat_swap_ap = 3
	FAMAS.wep_base_recoil_mul = 97
	FAMAS.wep_base_snapshot_mul = 108
	FAMAS.wep_base_hip_mul = 94
	FAMAS.weigth_held_mul = 127
	FAMAS.burst_selective = true
	FAMAS.burst_recoil_delta = 90
	FAMAS.recoil_mechanism = "Gas_Operated"
	FAMAS.Rat_cycling = "Auto"
	FAMAS.rat_barrel_len = 510
	FAMAS.rat_weigth = 3900
	FAMAS.ScrapParts = 10
	FAMAS.RepairCost = 80
	FAMAS.Reliability = 76
	FAMAS.AdditionalHint = T{423566125417,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increased Reload cost]]}
	FAMAS.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Under', Modifiable = true, AvailableComponents = {'VerticalGrip', }}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'Bipod', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = { 'ReflexSight', 'ScopeCOGQuick', 'ScopeCOG', '_ReflexSIghtVigilance', 'ReflexSightAdvanced', 'WideScope', 'ImprovedIronsight', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'Compensator', Modifiable = true, AvailableComponents = {'Compensator', 'Suppressor', 'ImprovisedSuppressor', }}, {CanBeEmpty = true, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = false, AvailableComponents = {'MagNormal', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'bullup', Modifiable = false, AvailableComponents = {'bullup', }}}
	FAMAS.CanAppearInShop = true
	FAMAS.Tier = 1
	FAMAS.MaxStock = 3
	FAMAS.RestockWeight = 80
	FAMAS.CategoryPair = "AssaultRifles"
	FAMAS.PenetrationClass = 1


	AKSU.is_vanilla_firearm = true
	AKSU.Cost = 4500
	AKSU.Damage = 21
	AKSU.CritChanceScaled = 10
	storeProps(AKSU, "AimAccuracy", 23, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AKSU, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AKSU, "WeaponRange", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AKSU, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AKSU.PBbonus_base = 9
	AKSU.HandlingBaseMul = 100
	AKSU.ShootAP = 3000
	AKSU.ReloadAP = 3000
	AKSU.OverwatchAngle = 1448
	AKSU.MagazineSize = 30
	AKSU.Cumbersome = 0
	AKSU.Noise = 20
	AKSU.PointBlankBonus = 1
	AKSU.PreparedAttackType = "Overwatch"
	AKSU.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
	AKSU.APStance = 3
	AKSU.Rat_swap_ap = 2
	AKSU.wep_base_recoil_mul = 119
	AKSU.wep_base_snapshot_mul = 84
	AKSU.wep_base_hip_mul = 111
	AKSU.weigth_held_mul = 120
	AKSU.recoil_mechanism = "Gas_Operated"
	AKSU.Rat_cycling = "Auto"
	AKSU.rat_barrel_len = 210
	AKSU.rat_weigth = 2900
	AKSU.ScrapParts = 10
	AKSU.RepairCost = 50
	AKSU.Reliability = 86
	AKSU.AdditionalHint = T{326130558343,[[<description_hints>]]}
	AKSU.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = false, AvailableComponents = {'BarrelNormal', }}, {CanBeEmpty = false, SlotType = 'Handguard', DefaultComponent = 'AKSU_Hanguard_Basic', Modifiable = true, AvailableComponents = {'AKSU_Hanguard_Basic', 'AKSU_VerticalGrip', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagNormalFine', 'MagLarge', 'MagQuick', 'MagLargeFine', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', 'WideScope', '_ReflexSIghtVigilance', 'LROptics_DragunovDefault', 'ImprovedIronsight', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'MuzzleBooster', Modifiable = true, AvailableComponents = {'Compensator', 'MuzzleBooster', 'Suppressor', 'ImprovisedSuppressor', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockLight', Modifiable = true, AvailableComponents = {'StockLight', }}}
	AKSU.Valuable = 1
	AKSU.CanAppearInShop = true
	AKSU.Tier = 2
	AKSU.MaxStock = 3
	AKSU.RestockWeight = 40
	AKSU.CategoryPair = "SubmachineGuns"
	AKSU.PenetrationClass = 1


	M41Shotgun.is_vanilla_firearm = true
	M41Shotgun.Cost = 3000
	M41Shotgun.Damage = 7
	M41Shotgun.ObjDamageMod = 150
	M41Shotgun.CritChanceScaled = 20
	storeProps(M41Shotgun, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M41Shotgun, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M41Shotgun, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M41Shotgun, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M41Shotgun.PBbonus_base = -3
	M41Shotgun.HandlingBaseMul = 111
	M41Shotgun.ShootAP = 4000
	M41Shotgun.ReloadAP = 5000
	M41Shotgun.OverwatchAngle = 881
	M41Shotgun.MagazineSize = 6
	M41Shotgun.Cumbersome = 0
	M41Shotgun.Noise = 20
	M41Shotgun.PointBlankBonus = 1
	M41Shotgun.PreparedAttackType = "Overwatch"
	M41Shotgun.AvailableAttacks = {"Buckshot", "CancelShotCone", "SingleShot", "CancelShot"}
	M41Shotgun.BuckshotConeAngle = 240
	M41Shotgun.BuckshotFalloffDamage = 50
	M41Shotgun.APStance = 3
	M41Shotgun.Rat_swap_ap = 3
	M41Shotgun.wep_base_recoil_mul = 104
	M41Shotgun.wep_base_snapshot_mul = 97
	M41Shotgun.wep_base_hip_mul = 103
	M41Shotgun.weigth_held_mul = 127
	M41Shotgun.recoil_mechanism = "Gas_Operated"
	M41Shotgun.Rat_cycling = "SemiAuto"
	M41Shotgun.rat_barrel_len = 355
	M41Shotgun.rat_weigth = 3860
	M41Shotgun.ScrapParts = 10
	M41Shotgun.RepairCost = 50
	M41Shotgun.Reliability = 82
	M41Shotgun.AdditionalHint = T{374576456352,[[<description_hints>]]}
	M41Shotgun.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelShortShotgun_Benelli', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', 'ReflexSightAdvanced', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Compensator', }}}
	M41Shotgun.CanAppearInShop = true
	M41Shotgun.Tier = 2
	M41Shotgun.MaxStock = 3
	M41Shotgun.RestockWeight = 60
	M41Shotgun.CategoryPair = "Shotguns"
	M41Shotgun.PenetrationClass = 1


	LionRoar.is_vanilla_firearm = true
	LionRoar.Cost = 1800
	LionRoar.Damage = 19
	LionRoar.CritChanceScaled = 10
	storeProps(LionRoar, "AimAccuracy", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(LionRoar, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(LionRoar, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(LionRoar, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	LionRoar.PBbonus_base = 8
	LionRoar.HandlingBaseMul = 100
	LionRoar.ShootAP = 3000
	LionRoar.ReloadAP = 3000
	LionRoar.OverwatchAngle = 1410
	LionRoar.MagazineSize = 20
	LionRoar.Cumbersome = 0
	LionRoar.Noise = 20
	LionRoar.PointBlankBonus = 1
	LionRoar.PreparedAttackType = "Overwatch"
	LionRoar.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun"}
	LionRoar.APStance = 2
	LionRoar.Rat_swap_ap = 1
	LionRoar.wep_base_recoil_mul = 108
	LionRoar.wep_base_snapshot_mul = 95
	LionRoar.wep_base_hip_mul = 110
	LionRoar.weigth_held_mul = 100
	LionRoar.recoil_mechanism = "Gas_Operated"
	LionRoar.Rat_cycling = "Auto"
	LionRoar.ScrapParts = 10
	LionRoar.RepairCost = 80
	LionRoar.Reliability = 86
	LionRoar.AdditionalHint = T{901243090653,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> OUR weapon
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Burst fire has 4 shots
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Limited ammo capacity]]}
	LionRoar.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'LionRoar_compensator', Modifiable = false, AvailableComponents = {'LionRoar_compensator', }}, {CanBeEmpty = false, SlotType = 'Internal', DefaultComponent = 'Internal_plus_burstshot', Modifiable = false, AvailableComponents = {'Internal_plus_burstshot', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNo', Modifiable = false, AvailableComponents = {'StockNo', }}}
	LionRoar.PenetrationClass = 1


	MP5.is_vanilla_firearm = true
	MP5.Cost = 1920
	MP5.Damage = 19
	MP5.CritChanceScaled = 10
	storeProps(MP5, "AimAccuracy", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP5, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP5, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP5, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MP5.PBbonus_base = 9
	MP5.HandlingBaseMul = 100
	MP5.ShootAP = 3000
	MP5.ReloadAP = 3000
	MP5.OverwatchAngle = 1437
	MP5.MagazineSize = 15
	MP5.Cumbersome = 0
	MP5.Noise = 20
	MP5.PointBlankBonus = 1
	MP5.PreparedAttackType = "Overwatch"
	MP5.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
	MP5.APStance = 3
	MP5.Rat_swap_ap = 2
	MP5.wep_base_recoil_mul = 109
	MP5.wep_base_snapshot_mul = 85
	MP5.wep_base_hip_mul = 110
	MP5.weigth_held_mul = 120
	MP5.recoil_mechanism = "Roller_Delayed"
	MP5.Rat_cycling = "Auto"
	MP5.rat_barrel_len = 220
	MP5.rat_weigth = 2880
	MP5.ScrapParts = 8
	MP5.RepairCost = 80
	MP5.Reliability = 85
	MP5.AdditionalHint = T{150064858793,[[<description_hints>]]}
	MP5.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Under', DefaultComponent = 'MP5_Handguard', Modifiable = false, AvailableComponents = {'MP5_Handguard', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelLong_handgun', 'long_barrel_light_handgun', 'BarrelLight_handgun', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_5', 'MagQuick', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockLight', Modifiable = true, AvailableComponents = {'StockLight', 'StockHeavy', 'StockNo', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_5', 'MagQuick', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'ThermalScope', '_ReflexSIghtVigilance', 'WideScope', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'Suppressor', 'ImprovisedSuppressor', }}}
	MP5.CanAppearInShop = true
	MP5.Tier = 2
	MP5.MaxStock = 3
	MP5.RestockWeight = 50
	MP5.CategoryPair = "SubmachineGuns"
	MP5.PenetrationClass = 1


	MP5K.is_vanilla_firearm = true
	MP5K.Cost = 2160
	MP5K.Damage = 19
	MP5K.CritChanceScaled = 10
	storeProps(MP5K, "AimAccuracy", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP5K, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP5K, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP5K, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MP5K.PBbonus_base = 9
	MP5K.HandlingBaseMul = 100
	MP5K.ShootAP = 3000
	MP5K.ReloadAP = 3000
	MP5K.OverwatchAngle = 1437
	MP5K.MagazineSize = 15
	MP5K.Cumbersome = 0
	MP5K.Noise = 20
	MP5K.PointBlankBonus = 1
	MP5K.PreparedAttackType = "Overwatch"
	MP5K.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "DualShot", "RunAndGun", "CancelShot"}
	MP5K.APStance = 3
	MP5K.Rat_swap_ap = 2
	MP5K.wep_base_recoil_mul = 109
	MP5K.wep_base_snapshot_mul = 74
	MP5K.wep_base_hip_mul = 110
	MP5K.weigth_held_mul = 114
	MP5K.recoil_mechanism = "Roller_Delayed"
	MP5K.Rat_cycling = "Auto"
	MP5K.rat_barrel_len = 110
	MP5K.rat_weigth = 2000
	MP5K.ScrapParts = 8
	MP5K.RepairCost = 80
	MP5K.Reliability = 85
	MP5K.LargeItem = 0
	MP5K.HandSlot = "OneHanded"
	MP5K.AdditionalHint = T{793746590177,[[<description_hints>]]}
	MP5K.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Under', DefaultComponent = 'VerticalGrip', Modifiable = true, AvailableComponents = {'VerticalGrip', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelShort_handgun', Modifiable = true, AvailableComponents = {'BarrelShort_handgun', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_5', 'MagQuick', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNo', Modifiable = true, AvailableComponents = {'StockLight', 'StockHeavy', 'StockNo', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', '_ReflexSIghtVigilance', 'WideScope', 'ImprovedIronsight', }}, {CanBeEmpty = false, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Suppressor', 'Compensator', 'ImprovisedSuppressor', }}}
	MP5K.CanAppearInShop = true
	MP5K.Tier = 2
	MP5K.MaxStock = 3
	MP5K.RestockWeight = 30
	MP5K.CategoryPair = "SubmachineGuns"
	MP5K.Icon = "Mod/cfahRED/Images/mp5k.png"
	MP5K.PenetrationClass = 1


	MP40.is_vanilla_firearm = true
	MP40.Cost = 1400
	MP40.Damage = 18
	MP40.CritChanceScaled = 10
	storeProps(MP40, "AimAccuracy", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP40, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP40, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MP40, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MP40.PBbonus_base = 7
	MP40.HandlingBaseMul = 100
	MP40.ShootAP = 3000
	MP40.ReloadAP = 3000
	MP40.OverwatchAngle = 1321
	MP40.MagazineSize = 32
	MP40.Cumbersome = 0
	MP40.Noise = 20
	MP40.PointBlankBonus = 1
	MP40.PreparedAttackType = "Overwatch"
	MP40.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
	MP40.APStance = 3
	MP40.Rat_swap_ap = 2
	MP40.wep_base_recoil_mul = 95
	MP40.wep_base_snapshot_mul = 91
	MP40.wep_base_hip_mul = 108
	MP40.weigth_held_mul = 128
	MP40.recoil_mechanism = "Blowback"
	MP40.Rat_cycling = "Auto"
	MP40.rat_barrel_len = 250
	MP40.rat_weigth = 4000
	MP40.ScrapParts = 6
	MP40.RepairCost = 80
	MP40.Reliability = 75
	MP40.AdditionalHint = T{749284137120,[[<description_hints>]]}
	MP40.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockLight', Modifiable = true, AvailableComponents = {'StockLight', }}, {CanBeEmpty = true, SlotType = 'Scope' , Modifiable = false, AvailableComponents = {}}}
	MP40.CanAppearInShop = true
	MP40.Tier = 1
	MP40.MaxStock = 3
	MP40.RestockWeight = 70
	MP40.CategoryPair = "SubmachineGuns"
	MP40.PenetrationClass = 1


	UZI.is_vanilla_firearm = true
	UZI.Cost = 960
	UZI.Damage = 18
	UZI.CritChanceScaled = 10
	storeProps(UZI, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UZI, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UZI, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UZI, "WeaponRange", 24, "oldCTH", GBO_gCTHModeItemPropertyTable)
	UZI.PBbonus_base = 8
	UZI.HandlingBaseMul = 100
	UZI.ShootAP = 3000
	UZI.ReloadAP = 3000
	UZI.OverwatchAngle = 1410
	UZI.MagazineSize = 25
	UZI.Cumbersome = 0
	UZI.Noise = 20
	UZI.PointBlankBonus = 1
	UZI.PreparedAttackType = "Overwatch"
	UZI.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "DualShot", "RunAndGun", "CancelShot"}
	UZI.APStance = 3
	UZI.Rat_swap_ap = 1
	UZI.wep_base_recoil_mul = 110
	UZI.wep_base_snapshot_mul = 86
	UZI.wep_base_hip_mul = 108
	UZI.weigth_held_mul = 119
	UZI.recoil_mechanism = "Blowback"
	UZI.Rat_cycling = "Auto"
	UZI.rat_barrel_len = 250
	UZI.rat_weigth = 2700
	UZI.ScrapParts = 6
	UZI.RepairCost = 80
	UZI.Reliability = 86
	UZI.AdditionalHint = T{862681616280,[[<description_hints>]]}
	UZI.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelNormalImproved', 'BarrelLong_handgun', 'BarrelLongImproved_handgun', 'long_barrel_light_handgun', 'BarrelLight_handgun', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_4', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge', 'MagLargeFine', 'MagNormalFine', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ReflexSightAdvanced', '_ReflexSIghtVigilance', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'Suppressor', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNo', Modifiable = true, AvailableComponents = {'StockNo', 'StockHeavy', 'StockLight', }}}
	UZI.CanAppearInShop = true
	UZI.Tier = 1
	UZI.MaxStock = 4
	UZI.RestockWeight = 100
	UZI.CategoryPair = "SubmachineGuns"
	UZI.PenetrationClass = 1


	AA12.is_vanilla_firearm = true
	AA12.Cost = 7920
	AA12.Damage = 6
	AA12.ObjDamageMod = 150
	AA12.CritChanceScaled = 10
	storeProps(AA12, "AimAccuracy", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AA12, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AA12, "WeaponRange", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AA12, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AA12.PBbonus_base = 1
	AA12.HandlingBaseMul = 105
	AA12.ShootAP = 4000
	AA12.ReloadAP = 3000
	AA12.OverwatchAngle = 1001
	AA12.MagazineSize = 8
	AA12.Cumbersome = 0
	AA12.Noise = 25
	AA12.PointBlankBonus = 1
	AA12.PreparedAttackType = "Overwatch"
	AA12.AvailableAttacks = {"BuckshotBurst", "Buckshot", "CancelShotCone", "BurstFire", "SingleShot", "CancelShot"}
	AA12.BuckshotConeAngle = 355
	AA12.BuckshotFalloffDamage = 50
	AA12.APStance = 4
	AA12.Rat_swap_ap = 3
	AA12.wep_base_recoil_mul = 90
	AA12.wep_base_snapshot_mul = 107
	AA12.wep_base_hip_mul = 97
	AA12.weigth_held_mul = 133
	AA12.recoil_mechanism = "Gas_Operated"
	AA12.Rat_cycling = "Auto"
	AA12.rat_barrel_len = 460
	AA12.rat_weigth = 4700
	AA12.ScrapParts = 12
	AA12.RepairCost = 50
	AA12.Reliability = 84
	AA12.AdditionalHint = T{141818519778,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Special firing mode: Buckshot Burst]]}
	AA12.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelLongShotgun', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge_6', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSightAdvanced', 'ReflexSight', 'ScopeCOGQuick', '_ReflexSIghtVigilance', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight_aa12', 'LaserDot_aa12', 'FlashlightDot_aa12', 'UVDot_aa12', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Suppressor', 'Compensator', }}}
	AA12.Valuable = 1
	AA12.CanAppearInShop = true
	AA12.Tier = 3
	AA12.MaxStock = 3
	AA12.RestockWeight = 40
	AA12.CategoryPair = "Shotguns"
	AA12.PenetrationClass = 1


	Auto5.is_vanilla_firearm = true
	Auto5.Cost = 1020
	Auto5.Damage = 7
	Auto5.ObjDamageMod = 150
	Auto5.CritChanceScaled = 10
	storeProps(Auto5, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5, "WeaponRange", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Auto5.PBbonus_base = -1
	Auto5.HandlingBaseMul = 107
	Auto5.ShootAP = 4000
	Auto5.ReloadAP = 4000
	Auto5.OverwatchAngle = 959
	Auto5.MagazineSize = 4
	Auto5.Cumbersome = 0
	Auto5.Noise = 25
	Auto5.PointBlankBonus = 1
	Auto5.PreparedAttackType = "Overwatch"
	Auto5.AvailableAttacks = {"Buckshot", "CancelShotCone", "SingleShot", "CancelShot"}
	Auto5.BuckshotConeAngle = 300
	Auto5.BuckshotFalloffDamage = 50
	Auto5.APStance = 3
	Auto5.Rat_swap_ap = 3
	Auto5.wep_base_recoil_mul = 98
	Auto5.wep_base_snapshot_mul = 100
	Auto5.wep_base_hip_mul = 100
	Auto5.weigth_held_mul = 100
	Auto5.recoil_mechanism = "Recoil_Operated"
	Auto5.Rat_cycling = "SemiAuto"
	Auto5.rat_weigth = 4000
	Auto5.ScrapParts = 10
	Auto5.RepairCost = 50
	Auto5.Reliability = 80
	Auto5.AdditionalHint = T{413545464036,[[<description_hints>]]}
	Auto5.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'DuckbillChoke', 'FullChoke', 'Compensator', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Auto5_Basic_NMag', Modifiable = true, AvailableComponents = {'Auto5_Basic_LMag', 'Auto5_Basic_NMag', 'Auto5_Long_LMag', 'Auto5_Long_NMag', 'Auto5_Short_NMag', }}}
	Auto5.CanAppearInShop = true
	Auto5.Tier = 1
	Auto5.MaxStock = 3
	Auto5.RestockWeight = 50
	Auto5.CategoryPair = "Shotguns"
	Auto5.PenetrationClass = 1


	DoubleBarrelShotgun.is_vanilla_firearm = true
	DoubleBarrelShotgun.Cost = 660
	DoubleBarrelShotgun.Damage = 6
	DoubleBarrelShotgun.ObjDamageMod = 150
	DoubleBarrelShotgun.CritChanceScaled = 10
	storeProps(DoubleBarrelShotgun, "AimAccuracy", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DoubleBarrelShotgun, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DoubleBarrelShotgun, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DoubleBarrelShotgun, "WeaponRange", 20, "oldCTH", GBO_gCTHModeItemPropertyTable)
	DoubleBarrelShotgun.PBbonus_base = -3
	DoubleBarrelShotgun.HandlingBaseMul = 110
	DoubleBarrelShotgun.ShootAP = 4000
	DoubleBarrelShotgun.ReloadAP = 4000
	DoubleBarrelShotgun.OverwatchAngle = 901
	DoubleBarrelShotgun.MagazineSize = 2
	DoubleBarrelShotgun.Cumbersome = 0
	DoubleBarrelShotgun.Noise = 25
	DoubleBarrelShotgun.PointBlankBonus = 1
	DoubleBarrelShotgun.PreparedAttackType = "Overwatch"
	DoubleBarrelShotgun.AvailableAttacks = {"Buckshot", "DoubleBarrel", "CancelShotCone", "SingleShot", "CancelShot"}
	DoubleBarrelShotgun.BuckshotConeAngle = 390
	DoubleBarrelShotgun.BuckshotFalloffDamage = 50
	DoubleBarrelShotgun.APStance = 3
	DoubleBarrelShotgun.Rat_swap_ap = 3
	DoubleBarrelShotgun.wep_base_recoil_mul = 100
	DoubleBarrelShotgun.wep_base_snapshot_mul = 100
	DoubleBarrelShotgun.wep_base_hip_mul = 100
	DoubleBarrelShotgun.weigth_held_mul = 100
	DoubleBarrelShotgun.recoil_mechanism = "Break_Action"
	DoubleBarrelShotgun.rat_weigth = 4000
	DoubleBarrelShotgun.ScrapParts = 8
	DoubleBarrelShotgun.RepairCost = 50
	DoubleBarrelShotgun.Reliability = 99
	DoubleBarrelShotgun.AdditionalHint = T{150578847961,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Special firing mode: Double Barrel]]}
	DoubleBarrelShotgun.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLongShotgun', 'BarrelNormal', 'BarrelShortShotgun', }}}
	DoubleBarrelShotgun.CanAppearInShop = true
	DoubleBarrelShotgun.Tier = 1
	DoubleBarrelShotgun.MaxStock = 3
	DoubleBarrelShotgun.RestockWeight = 120
	DoubleBarrelShotgun.CategoryPair = "Shotguns"
	DoubleBarrelShotgun.PenetrationClass = 1


	Auto5_quest.is_vanilla_firearm = true
	Auto5_quest.Cost = 720
	Auto5_quest.Damage = 6
	Auto5_quest.ObjDamageMod = 150
	Auto5_quest.CritChanceScaled = 10
	storeProps(Auto5_quest, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5_quest, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5_quest, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5_quest, "WeaponRange", 20, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Auto5_quest.PBbonus_base = -1
	Auto5_quest.HandlingBaseMul = 107
	Auto5_quest.ShootAP = 4000
	Auto5_quest.ReloadAP = 5000
	Auto5_quest.OverwatchAngle = 959
	Auto5_quest.MagazineSize = 8
	Auto5_quest.Cumbersome = 0
	Auto5_quest.Noise = 25
	Auto5_quest.PointBlankBonus = 1
	Auto5_quest.PreparedAttackType = "Overwatch"
	Auto5_quest.AvailableAttacks = {"BuckshotBurst", "BurstFire"}
	Auto5_quest.BuckshotConeAngle = 300
	Auto5_quest.BuckshotFalloffDamage = 100
	Auto5_quest.APStance = 3
	Auto5_quest.Rat_swap_ap = 3
	Auto5_quest.wep_base_recoil_mul = 98
	Auto5_quest.wep_base_snapshot_mul = 100
	Auto5_quest.wep_base_hip_mul = 100
	Auto5_quest.weigth_held_mul = 100
	Auto5_quest.recoil_mechanism = "Recoil_Operated"
	Auto5_quest.Rat_cycling = "Auto"
	Auto5_quest.ScrapParts = 10
	Auto5_quest.RepairCost = 50
	Auto5_quest.Reliability = 80
	Auto5_quest.AdditionalHint = T{732527392585,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Rapid Invalidation]]}
	Auto5_quest.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Auto5_Basic_NMag', Modifiable = false, AvailableComponents = {'Auto5_Basic_LMag', }}}
	Auto5_quest.PenetrationClass = 1


	ColtAnaconda.is_vanilla_firearm = true
	ColtAnaconda.Cost = 4600
	ColtAnaconda.Damage = 25
	ColtAnaconda.CritChanceScaled = 30
	storeProps(ColtAnaconda, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtAnaconda, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtAnaconda, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtAnaconda, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	ColtAnaconda.PBbonus_base = 12
	ColtAnaconda.HandlingBaseMul = 100
	ColtAnaconda.ShootAP = 4000
	ColtAnaconda.ReloadAP = 3000
	ColtAnaconda.OverwatchAngle = 2118
	ColtAnaconda.MagazineSize = 6
	ColtAnaconda.Cumbersome = 0
	ColtAnaconda.Noise = 18
	ColtAnaconda.PointBlankBonus = 1
	ColtAnaconda.PreparedAttackType = "Overwatch"
	ColtAnaconda.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	ColtAnaconda.APStance = 1
	ColtAnaconda.Rat_swap_ap = 1
	ColtAnaconda.wep_base_recoil_mul = 106
	ColtAnaconda.wep_base_snapshot_mul = 75
	ColtAnaconda.wep_base_hip_mul = 114
	ColtAnaconda.weigth_held_mul = 110
	ColtAnaconda.recoil_mechanism = "Revolver"
	ColtAnaconda.Rat_cycling = "DoubleAction"
	ColtAnaconda.rat_barrel_len = 150
	ColtAnaconda.rat_weigth = 1400
	ColtAnaconda.ScrapParts = 8
	ColtAnaconda.RepairCost = 30
	ColtAnaconda.Reliability = 90
	ColtAnaconda.AdditionalHint = T{879153829726,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Double action
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded]]}
	ColtAnaconda.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong_handgun', 'BarrelNormal', 'BarrelShort_handgun', 'BarrelLight', 'long_barrel_light_handgun', 'BarrelShort_Light_handgun', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'BaseIronsight_Anaconda', Modifiable = true, AvailableComponents = {'BaseIronsight_Anaconda', 'ImprovedIronsight', 'ReflexSight', 'ReflexSightAdvanced', 'ScopeCOG', 'ScopeCOGQuick', 'LaserDot_Anaconda', 'FlashlightDot_Anaconda', 'UVDot_Anaconda', '_ReflexSIghtVigilance', 'WideScope', }}, {CanBeEmpty = false, SlotType = 'Trigger', DefaultComponent = 'SADA_action', Modifiable = false, AvailableComponents = {'SADA_action', }}}
	ColtAnaconda.Valuable = 1
	ColtAnaconda.CanAppearInShop = true
	ColtAnaconda.Tier = 2
	ColtAnaconda.MaxStock = 3
	ColtAnaconda.RestockWeight = 70
	ColtAnaconda.CategoryPair = "Handguns"
	ColtAnaconda.PenetrationClass = 1


	DesertEagle.is_vanilla_firearm = true
	DesertEagle.Cost = 7000
	DesertEagle.Damage = 26
	DesertEagle.CritChanceScaled = 20
	storeProps(DesertEagle, "AimAccuracy", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DesertEagle, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DesertEagle, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DesertEagle, "WeaponRange", 28, "oldCTH", GBO_gCTHModeItemPropertyTable)
	DesertEagle.PBbonus_base = 11
	DesertEagle.HandlingBaseMul = 100
	DesertEagle.ShootAP = 4000
	DesertEagle.ReloadAP = 3000
	DesertEagle.OverwatchAngle = 1936
	DesertEagle.MagazineSize = 8
	DesertEagle.Cumbersome = 0
	DesertEagle.Noise = 20
	DesertEagle.PointBlankBonus = 1
	DesertEagle.PreparedAttackType = "Overwatch"
	DesertEagle.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	DesertEagle.APStance = 1
	DesertEagle.Rat_swap_ap = 1
	DesertEagle.wep_base_recoil_mul = 99
	DesertEagle.wep_base_snapshot_mul = 77
	DesertEagle.wep_base_hip_mul = 114
	DesertEagle.weigth_held_mul = 115
	DesertEagle.recoil_mechanism = "Short_Recoil"
	DesertEagle.Rat_cycling = "SemiAuto"
	DesertEagle.rat_barrel_len = 150
	DesertEagle.rat_weigth = 2100
	DesertEagle.ScrapParts = 10
	DesertEagle.RepairCost = 70
	DesertEagle.Reliability = 68
	DesertEagle.AdditionalHint = T{467653092333,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded]]}
	DesertEagle.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', 'ReflexSightAdvanced', 'ImprovedIronsight', '_ReflexSIghtVigilance', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagNormal', 'MagLarge', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong_handgun', 'BarrelNormal', 'Barrel50BMG_DesertEagle', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Suppressor', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'FlashlightDot', 'Flashlight', 'LaserDot', 'UVDot', }}}
	DesertEagle.Valuable = 1
	DesertEagle.CanAppearInShop = true
	DesertEagle.Tier = 3
	DesertEagle.MaxStock = 3
	DesertEagle.RestockWeight = 40
	DesertEagle.CategoryPair = "Handguns"
	DesertEagle.PenetrationClass = 1


	ColtPeacemaker.is_vanilla_firearm = true
	ColtPeacemaker.Cost = 900
	ColtPeacemaker.Damage = 24
	ColtPeacemaker.CritChanceScaled = 10
	storeProps(ColtPeacemaker, "AimAccuracy", 12, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtPeacemaker, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtPeacemaker, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtPeacemaker, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	ColtPeacemaker.PBbonus_base = 11
	ColtPeacemaker.HandlingBaseMul = 100
	ColtPeacemaker.ShootAP = 4000
	ColtPeacemaker.ReloadAP = 3000
	ColtPeacemaker.OverwatchAngle = 2162
	ColtPeacemaker.MagazineSize = 6
	ColtPeacemaker.Cumbersome = 0
	ColtPeacemaker.Noise = 18
	ColtPeacemaker.PointBlankBonus = 1
	ColtPeacemaker.PreparedAttackType = "Overwatch"
	ColtPeacemaker.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	ColtPeacemaker.APStance = 1
	ColtPeacemaker.Rat_swap_ap = 1
	ColtPeacemaker.wep_base_recoil_mul = 107
	ColtPeacemaker.wep_base_snapshot_mul = 73
	ColtPeacemaker.wep_base_hip_mul = 110
	ColtPeacemaker.weigth_held_mul = 105
	ColtPeacemaker.recoil_mechanism = "Revolver"
	ColtPeacemaker.Rat_cycling = "SingleAction"
	ColtPeacemaker.rat_barrel_len = 160
	ColtPeacemaker.rat_weigth = 720
	ColtPeacemaker.ScrapParts = 6
	ColtPeacemaker.RepairCost = 30
	ColtPeacemaker.Reliability = 94
	ColtPeacemaker.AdditionalHint = T{626602087367,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Single action
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded]]}
	ColtPeacemaker.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong_handgun', 'BarrelNormal', 'BarrelShort_handgun', 'BarrelLight', 'long_barrel_light_handgun', 'BarrelShort_Light_handgun', }}, {CanBeEmpty = false, SlotType = 'Trigger', DefaultComponent = 'single_action', Modifiable = false, AvailableComponents = {'single_action', }}}
	ColtPeacemaker.CanAppearInShop = true
	ColtPeacemaker.Tier = 1
	ColtPeacemaker.MaxStock = 3
	ColtPeacemaker.RestockWeight = 100
	ColtPeacemaker.CategoryPair = "Handguns"
	ColtPeacemaker.PenetrationClass = 1


	TexRevolver.is_vanilla_firearm = true
	TexRevolver.Cost = 1200
	TexRevolver.Damage = 24
	TexRevolver.CritChanceScaled = 60
	storeProps(TexRevolver, "AimAccuracy", 12, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(TexRevolver, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(TexRevolver, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(TexRevolver, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	TexRevolver.PBbonus_base = 11
	TexRevolver.HandlingBaseMul = 100
	TexRevolver.ShootAP = 4000
	TexRevolver.ReloadAP = 3000
	TexRevolver.OverwatchAngle = 2162
	TexRevolver.MagazineSize = 6
	TexRevolver.Cumbersome = 0
	TexRevolver.Noise = 18
	TexRevolver.PointBlankBonus = 1
	TexRevolver.PreparedAttackType = "Overwatch"
	TexRevolver.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	TexRevolver.APStance = 1
	TexRevolver.Rat_swap_ap = 1
	TexRevolver.wep_base_recoil_mul = 107
	TexRevolver.wep_base_snapshot_mul = 73
	TexRevolver.wep_base_hip_mul = 110
	TexRevolver.weigth_held_mul = 100
	TexRevolver.recoil_mechanism = "Revolver"
	TexRevolver.Rat_cycling = "SingleAction"
	TexRevolver.rat_barrel_len = 160
	TexRevolver.rat_weigth = 720
	TexRevolver.ScrapParts = 8
	TexRevolver.RepairCost = 50
	TexRevolver.Reliability = 94
	TexRevolver.AdditionalHint = T{596143246468,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Tex has reduced penalty when using Dual Shot with his revolvers
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Single action]]}
	TexRevolver.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Trigger', DefaultComponent = 'single_action_tex', Modifiable = false, AvailableComponents = {'single_action_tex', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong_handgun', 'BarrelNormal', 'BarrelShort_handgun', 'BarrelLight', 'long_barrel_light_handgun', 'BarrelShort_Light_handgun', }}}
	TexRevolver.Tier = 1
	TexRevolver.MaxStock = 3
	TexRevolver.CategoryPair = "Handguns"
	TexRevolver.PenetrationClass = 1


	HiPower.is_vanilla_firearm = true
	HiPower.Cost = 600
	HiPower.Damage = 17
	HiPower.CritChanceScaled = 10
	storeProps(HiPower, "AimAccuracy", 11, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HiPower, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HiPower, "WeaponRange", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HiPower, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	HiPower.PBbonus_base = 12
	HiPower.HandlingBaseMul = 100
	HiPower.ShootAP = 4000
	HiPower.ReloadAP = 3000
	HiPower.OverwatchAngle = 2216
	HiPower.MagazineSize = 13
	HiPower.Cumbersome = 0
	HiPower.Noise = 18
	HiPower.PointBlankBonus = 1
	HiPower.PreparedAttackType = "Overwatch"
	HiPower.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	HiPower.APStance = 1
	HiPower.Rat_swap_ap = 1
	HiPower.wep_base_recoil_mul = 115
	HiPower.wep_base_snapshot_mul = 71
	HiPower.wep_base_hip_mul = 116
	HiPower.weigth_held_mul = 107
	HiPower.recoil_mechanism = "Short_Recoil"
	HiPower.Rat_cycling = "SemiAuto"
	HiPower.rat_barrel_len = 110
	HiPower.rat_weigth = 1050
	HiPower.ScrapParts = 6
	HiPower.RepairCost = 70
	HiPower.Reliability = 85
	HiPower.AdditionalHint = T{345858616651,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded]]}
	HiPower.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', 'Compensator', }}, {CanBeEmpty = false, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', '_ReflexSIghtVigilance', 'ReflexSightAdvanced_Glock', 'ImprovedIronsight', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge_1', 'MagNormal', 'MagLargeFine_1', 'MagNormalFine', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelNormalImproved', 'BarrelShort_handgun', 'BarrelShortImproved_handgun', 'BarrelLong_handgun', 'BarrelLongImproved_handgun', 'BarrelLight', 'long_barrel_light_handgun', 'BarrelShort_Light_handgun', }}}
	HiPower.CanAppearInShop = true
	HiPower.Tier = 1
	HiPower.MaxStock = 3
	HiPower.RestockWeight = 100
	HiPower.CategoryPair = "Handguns"
	HiPower.PenetrationClass = 1


	Bereta92.is_vanilla_firearm = true
	Bereta92.Cost = 1200
	Bereta92.Damage = 17
	Bereta92.CritChanceScaled = 30
	storeProps(Bereta92, "AimAccuracy", 11, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Bereta92, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Bereta92, "WeaponRange", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Bereta92, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Bereta92.PBbonus_base = 12
	Bereta92.HandlingBaseMul = 100
	Bereta92.ShootAP = 4000
	Bereta92.ReloadAP = 3000
	Bereta92.OverwatchAngle = 2209
	Bereta92.MagazineSize = 15
	Bereta92.Cumbersome = 0
	Bereta92.Noise = 18
	Bereta92.PointBlankBonus = 1
	Bereta92.PreparedAttackType = "Overwatch"
	Bereta92.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	Bereta92.APStance = 1
	Bereta92.Rat_swap_ap = 1
	Bereta92.wep_base_recoil_mul = 115
	Bereta92.wep_base_snapshot_mul = 71
	Bereta92.wep_base_hip_mul = 116
	Bereta92.weigth_held_mul = 106
	Bereta92.recoil_mechanism = "Short_Recoil"
	Bereta92.Rat_cycling = "SemiAuto"
	Bereta92.rat_barrel_len = 120
	Bereta92.rat_weigth = 950
	Bereta92.ScrapParts = 6
	Bereta92.RepairCost = 70
	Bereta92.Reliability = 81
	Bereta92.AdditionalHint = T{612920982302,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded]]}
	Bereta92.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', '_ReflexSIghtVigilance', 'ReflexSightAdvanced_Glock', 'ImprovedIronsight', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge', 'MagNormal', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelLong_handgun', 'BarrelNormal', 'long_barrel_light_handgun', 'BarrelLight', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}}
	Bereta92.CanAppearInShop = true
	Bereta92.Tier = 1
	Bereta92.MaxStock = 3
	Bereta92.RestockWeight = 70
	Bereta92.CategoryPair = "Handguns"
	Bereta92.PenetrationClass = 1


	Glock18.is_vanilla_firearm = true
	Glock18.Cost = 1680
	Glock18.Damage = 16
	Glock18.CritChanceScaled = 10
	storeProps(Glock18, "AimAccuracy", 7, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Glock18, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Glock18, "WeaponRange", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Glock18, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Glock18.PBbonus_base = 13
	Glock18.HandlingBaseMul = 100
	Glock18.ShootAP = 3000
	Glock18.ReloadAP = 3000
	Glock18.OverwatchAngle = 2232
	Glock18.MagazineSize = 15
	Glock18.Cumbersome = 0
	Glock18.Noise = 18
	Glock18.PointBlankBonus = 1
	Glock18.PreparedAttackType = "Overwatch"
	Glock18.AvailableAttacks = {"BurstFire", "SingleShot", "DualShot", "CancelShot", "MobileShot", "RunAndGun", "AutoFire"}
	Glock18.burst_shots = 4
	Glock18.auto_shots = 12
	Glock18.APStance = 1
	Glock18.Rat_swap_ap = 1
	Glock18.wep_base_recoil_mul = 116
	Glock18.wep_base_snapshot_mul = 70
	Glock18.wep_base_hip_mul = 116
	Glock18.weigth_held_mul = 106
	Glock18.AutoFireCustomDeltaAP = 1
	Glock18.SingleShotCustomDeltaAP = 1
	Glock18.burst_recoil_delta = 108
	Glock18.long_recoil_delta = 108
	Glock18.auto_recoil_delta = 108
	Glock18.recoil_mechanism = "Striker_Fired"
	Glock18.Rat_cycling = "Auto"
	Glock18.rat_barrel_len = 110
	Glock18.rat_weigth = 880
	Glock18.ScrapParts = 6
	Glock18.RepairCost = 70
	Glock18.Reliability = 88
	Glock18.AdditionalHint = T{850719596587,[[<description_hints>
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded
 <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Automatic firing modes]]}
	Glock18.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', 'ReflexSightAdvanced_Glock', 'ImprovedIronsight', '_ReflexSIghtVigilance', }}, {CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', 'Compensator_Glock', }}, {CanBeEmpty = false, SlotType = 'Handguard', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge_3', 'MagNormal', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'LaserDot', 'FlashlightDot', 'UVDot', }}}
	Glock18.CanAppearInShop = true
	Glock18.Tier = 2
	Glock18.MaxStock = 3
	Glock18.RestockWeight = 30
	Glock18.CategoryPair = "Handguns"
	Glock18.PenetrationClass = 1


GBO_ApplyCHTModeItemProps(GBO_gCTHModeItemPropertyTable)

	print("PATCH_GBO_weapons done")
end
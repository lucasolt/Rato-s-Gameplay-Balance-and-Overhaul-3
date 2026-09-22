-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

local function storeProps(item, prop, value, mode, tbl)
	tbl[item] = tbl[item] or {}
	tbl[item][prop] = tbl[item][prop] or {}
	if tbl[item][prop][mode] == nil then
		tbl[item][prop][mode] = value
	end
end

function RatoTOG_Patch()
	print("Running RatoTOG_Patch...")
	AN94_1.is_tog_patched = true
	AN94_1.is_vanilla_firearm = false
	AN94_1.object_class = "AssaultRifle"
	AN94_1.Cost = 12340
	AN94_1.Damage = 24
	AN94_1.ObjDamageMod = 100
	AN94_1.CritChance = 0
	AN94_1.CritChanceScaled = 20
	storeProps(AN94_1, "AimAccuracy", 36, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AN94_1, "AimAccuracy", 6, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AN94_1, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AN94_1, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AN94_1.PBbonus_base = 3
	AN94_1.HandlingBaseMul = 100
	AN94_1.PenetrationClass = 1
	AN94_1.ShootAP = 2000
	AN94_1.ReloadAP = 3000
	AN94_1.APStance = 40
	AN94_1.OverwatchAngle = 1118
	AN94_1.MagazineSize = 30
	AN94_1.Cumbersome = 0
	AN94_1.Noise = 20
	AN94_1.PointBlankBonus = 1
	AN94_1.PreparedAttackType = "Overwatch"
	AN94_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	AN94_1.burst_shots = 2
	AN94_1.Rat_swap_ap = 3
	AN94_1.wep_base_snapshot_mul = 101
	AN94_1.weigth_held_mul = 127
	AN94_1.burst_selective = true
	AN94_1.AutoFireCustomDeltaAP = 1
	AN94_1.SingleShotCustomDeltaAP = 2
	AN94_1.hyperburst = 85
	AN94_1.burst_recoil_delta = 5
	AN94_1.long_recoil_delta = 85
	AN94_1.auto_recoil_delta = 85
	AN94_1.recoil_mechanism = "Gas_Operated"
	AN94_1.Rat_cycling = "Auto"
	AN94_1.rat_scope_block = false
	AN94_1.pistol_swap = false
	AN94_1.default_long_barrel = false
	AN94_1.unwieldy_weapon = false
	AN94_1.rat_barrel_len = 414
	AN94_1.rat_weigth = 3850
	AN94_1.Weigth = 3850
	AN94_1.ScrapParts = 10
	AN94_1.RepairCost = 30
	AN94_1.Reliability = 72
	AN94_1.LargeItem = 1
	AN94_1.HandSlot = "TwoHanded"
	AN94_1.AdditionalHint = T( 418962743486, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Unique 2 shot burst function at 1800 rounds per minute]] )
	AN94_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'AN94_Stock_def_1', Modifiable = true, AvailableComponents = {'AN94_Stock_def_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'AN94_Mag_def_1', Modifiable = true, AvailableComponents = {'AN94_Mag_def_1', 'AN94_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'ImprovedIronsight', Modifiable = true, AvailableComponents = {'LROptics_DragunovDefault', 'ImprovedIronsight', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_vigilanceRS', 'RAT_TOG_ACOG', 'RAT_TOG_Prism', 'RAT_TOG_LRoptics', 'RAT_TOG_WideScope', 'RAT_TOG_thermal', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'RAT_TOG_compensator', Modifiable = true, AvailableComponents = {'RAT_TOG_compensator', }}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'AN94_Bip_def_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'AN94_Barrel_def_1', Modifiable = true, AvailableComponents = {'AN94_Barrel_short_1', 'AN94_Barrel_def_1', 'AN94_Barrel_ext_1', }}}
	AN94_1.Valuable = 1
	AN94_1.CanAppearInShop = true
	AN94_1.CanAppearUsed = true
	AN94_1.Tier = 3
	AN94_1.MaxStock = 1
	AN94_1.RestockWeight = 25
	AN94_1.CategoryPair = "AssaultRifles"
	AN94_1.Description = T(260761277742, [[<style PerkststsBold ><scale 600>The AN-94 is a Russian assault rifle designed as a potential replacement to the AK-74<newline><newline>It offers a unique two-shot burst function at a stated 1800 rounds per minute, increasing hit probability under the most adverse combat conditions.<newline><newline>Due to its complex design and expense, it failed to fill its intended role as a replacement for the AK-74, but it is in limited use as a special purpose weapon.<newline><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	AN94_1.PenetrationClass = 1


	HK33A2_1.is_tog_patched = true
	HK33A2_1.is_vanilla_firearm = false
	HK33A2_1.object_class = "AssaultRifle"
	HK33A2_1.Cost = 8700
	HK33A2_1.Damage = 24
	HK33A2_1.ObjDamageMod = 100
	HK33A2_1.CritChance = 0
	HK33A2_1.CritChanceScaled = 10
	storeProps(HK33A2_1, "AimAccuracy", 35, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK33A2_1, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK33A2_1, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK33A2_1, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	HK33A2_1.PBbonus_base = 3
	HK33A2_1.HandlingBaseMul = 100
	HK33A2_1.PenetrationClass = 1
	HK33A2_1.ShootAP = 4000
	HK33A2_1.ReloadAP = 3000
	HK33A2_1.APStance = 40
	HK33A2_1.OverwatchAngle = 1119
	HK33A2_1.MagazineSize = 10
	HK33A2_1.Cumbersome = 0
	HK33A2_1.Noise = 20
	HK33A2_1.PointBlankBonus = 1
	HK33A2_1.PreparedAttackType = "Overwatch"
	HK33A2_1.AvailableAttacks = {"BurstFire", "SingleShot", "CancelShot"}
	HK33A2_1.Rat_swap_ap = 3
	HK33A2_1.wep_base_snapshot_mul = 101
	HK33A2_1.weigth_held_mul = 129
	HK33A2_1.burst_selective = false
	HK33A2_1.recoil_mechanism = "Roller_Delayed"
	HK33A2_1.Rat_cycling = "Auto"
	HK33A2_1.rat_scope_block = false
	HK33A2_1.pistol_swap = false
	HK33A2_1.default_long_barrel = false
	HK33A2_1.unwieldy_weapon = false
	HK33A2_1.rat_barrel_len = 400
	HK33A2_1.rat_weigth = 4100
	HK33A2_1.Weigth = 4100
	HK33A2_1.ScrapParts = 10
	HK33A2_1.RepairCost = 80
	HK33A2_1.Reliability = 83
	HK33A2_1.LargeItem = 1
	HK33A2_1.HandSlot = "TwoHanded"
	HK33A2_1.AdditionalHint = T( 630164376246, [[<description_hints>]] )
	HK33A2_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'hk33_barrel_def_1', Modifiable = true, AvailableComponents = {'hk33_barrel_shrt_1', 'hk33_barrel_def_1', 'hk33_barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'hk33_muzzle_1', Modifiable = true, AvailableComponents = {'RAT_TOG_suppressor', 'ImprovisedSuppressor', 'hk33_muzzle_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'hk33_magazine_31', Modifiable = true, AvailableComponents = {'hk33_magazine_11', 'hk33_magazine_31', 'hk33_drum_mag_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'hk33_Stock_1', Modifiable = true, AvailableComponents = {'hk33_Stock_1', 'G3A3_stock_hvy_1', 'HK53_stock_unfld_1', }}, {CanBeEmpty = true, SlotType = 'Bipod', DefaultComponent = 'hk33_bipod_fld_1', Modifiable = true, AvailableComponents = {'hk33_bipod_fld_1', }}, {CanBeEmpty = false, SlotType = 'Handguard', DefaultComponent = 'hk33_handguard_cl_1', Modifiable = true, AvailableComponents = {'hk33_handguard_cl_1', 'hk33_handguard_new_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_PSGScope', 'RAT_TOG_LRoptics_advanced', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'hk33_lower_modern_1', Modifiable = true, AvailableComponents = {'hk33_lower_classic_1', 'hk33_lower_modern_1', }}, {CanBeEmpty = false, SlotType = 'Side2', DefaultComponent = 'side_2_empty', Modifiable = true, AvailableComponents = {'ToG_Flashlight_2', 'ToG_Red_Dot_2', 'ToG_UV_Dot_2', 'side_2_empty', }}}
	HK33A2_1.Valuable = 1
	HK33A2_1.CanAppearInShop = true
	HK33A2_1.CanAppearUsed = true
	HK33A2_1.Tier = 2
	HK33A2_1.MaxStock = 3
	HK33A2_1.RestockWeight = 50
	HK33A2_1.CategoryPair = "AssaultRifles"
	HK33A2_1.fxClass = "G36"
	HK33A2_1.Description = T(419973268941, [[<style PerkststsBold ><scale 600>The HK33 is a 5.56mm assault rifle developed in the 1960s<newline><newline>
The HK33 series of rifles were adopted by the Brazilian Air Force (Força Aérea Brasileira or FAB), the armed forces of Thailand and Malaysia where they were produced under a licence agreement. The rifle was also licence-built in Turkey, and exported from France but actually made in Germany.<newline><newline>A copy of the HK33 was built under licence as T223 during the Vietnam War. Although heavier than the M16, it was used in small numbers by SEAL teams due to its available 40-round magazine.<newline><newline>In Myanmar, the Karen National Liberation Army fielded government-made HK33s. Thai government units fielded HK33s during the South Thailand insurgency. Some of these rifles were seized by groups such as the Patani United Liberation Organisation or the Gerakan Mujahidin Islam Patani<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	HK33A2_1.PenetrationClass = 1


	AR10std.is_tog_patched = true
	AR10std.is_vanilla_firearm = false
	AR10std.object_class = "AssaultRifle"
	AR10std.Cost = 7300
	AR10std.Damage = 30
	AR10std.ObjDamageMod = 100
	AR10std.CritChance = 0
	AR10std.CritChanceScaled = 10
	storeProps(AR10std, "AimAccuracy", 35, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR10std, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR10std, "WeaponRange", 36, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR10std, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AR10std.PBbonus_base = 1
	AR10std.HandlingBaseMul = 108
	AR10std.PenetrationClass = 1
	AR10std.ShootAP = 4000
	AR10std.ReloadAP = 3000
	AR10std.APStance = 40
	AR10std.OverwatchAngle = 1014
	AR10std.MagazineSize = 20
	AR10std.Cumbersome = 0
	AR10std.Noise = 20
	AR10std.PointBlankBonus = 1
	AR10std.PreparedAttackType = "Overwatch"
	AR10std.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	AR10std.Rat_swap_ap = 3
	AR10std.wep_base_recoil_mul = 94
	AR10std.wep_base_snapshot_mul = 100
	AR10std.wep_base_hip_mul = 106
	AR10std.burst_selective = false
	AR10std.recoil_mechanism = "Gas_Operated"
	AR10std.Rat_cycling = "Auto"
	AR10std.rat_scope_block = false
	AR10std.pistol_swap = false
	AR10std.default_long_barrel = false
	AR10std.unwieldy_weapon = false
	AR10std.rat_barrel_len = 508
	AR10std.rat_weigth = 3600
	AR10std.Weigth = 3600
	AR10std.ScrapParts = 10
	AR10std.RepairCost = 80
	AR10std.Reliability = 79
	AR10std.LargeItem = 1
	AR10std.HandSlot = "TwoHanded"
	AR10std.AdditionalHint = T( 664367469884, [[<description_hints>]] )
	AR10std.ComponentSlots = {{AvailableComponents = {'AR10_barrel_shrt', 'AR10_barrel_def', 'AR10_barrel_ext'}, DefaultComponent = 'AR10_barrel_def', SlotType = 'Barrel', Modifiable = true}, {AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism', 'RAT_TOG_Reflex', 'RAT_TOG_WideScope', 'RAT_TOG_compactRS', 'RAT_TOG_vigilanceRS'}, CanBeEmpty = true, SlotType = 'Scope', Modifiable = true}, {AvailableComponents = {'RAT_TOG_compensator', 'RAT_TOG_suppressor_762', 'MuzzleBooster', 'ImprovisedSuppressor', 'AR10_muzzle_def'}, DefaultComponent = 'AR10_muzzle_def', SlotType = 'Muzzle', Modifiable = true}, {AvailableComponents = { 'U100_bipod_fld_1'}, CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true}, {AvailableComponents = {'AR10_mag_def', 'AR10_mag_dual'}, DefaultComponent = 'AR10_mag_def', SlotType = 'Magazine', Modifiable = true}, {AvailableComponents = {'AR10_stock_erg', 'AR10_stock_def', 'AR10_stock_hvy'}, DefaultComponent = 'AR10_stock_def', SlotType = 'Stock', Modifiable = true}, {DefaultComponent = 'side_2_empty', AvailableComponents = {'side_2_empty', 'ToG_Flashlight_2', 'ToG_Red_Dot_2', 'ToG_UV_Dot_2'}, CanBeEmpty = false, SlotType = 'Side2', Modifiable = true}, {DefaultComponent = 'mountfront_empty', AvailableComponents =  {'mountfront_empty','AR10_grip_mountfront', 'ToG_NatoGL'}, CanBeEmpty = false, SlotType = 'Mountfront', Modifiable = true}}
	AR10std.CanAppearInShop = true
	AR10std.CanAppearUsed = true
	AR10std.Tier = 2
	AR10std.MaxStock = 3
	AR10std.RestockWeight = 50
	AR10std.CategoryPair = "AssaultRifles"
	AR10std.Description = T(862731285839, [[<style PerkststsBold ><scale 450>The AR-10 is a 7.62×51mm NATO battle rifle designed by Eugene Stoner in the late 1950s<newline><newline>When first introduced in 1956, the AR-10 used an innovative combination forged alloy parts resulting in a small arm significantly easier to control in automatic fire and over 0.45 kg lighter than other infantry rifles of the day.<newline><newline>During 1960 U.S. Army tests and in Portuguese service, the AR-10 was praised for its accuracy, hitting 25 mm groups at 100 meters with standard ammo. Despite limited production, countries like Guatemala, Burma, Italy, Cuba, Sudan, and Portugal issued it to their troops. The AR-10 remained in service with Sudanese Special Forces until 1985 and was used in various African conflicts, sometimes captured and repurposed.<newline><newline>In Chad, the AR-10 was much appreciated by members of the French Foreign Legion. As one police instructor in the Congo stated, "It was a good combat weapon that never failed me; a bit too long (but not as bad as the FAL or M14) for house-to-house work or really heavy brush, but great for 400-800 meters, in the flats - and really nice on the body, after wandering around 12-14 hours looking for bad guys."<newline><newline>Over its production life, the original AR-10 was built in relatively small numbers, with fewer than 10,000 rifles assembled.However, the AR-10 would become the progenitor for a wide range of firearms.<newline><style MMOptionEntry>Made in USA <image UI/Icons/Flags/f_usa.dds 1600>]])
	AR10std.PenetrationClass = 1


	G11_1.is_tog_patched = true
	G11_1.is_vanilla_firearm = false
	G11_1.object_class = "AssaultRifle"
	G11_1.Cost = 20000
	G11_1.Damage = 22
	G11_1.ObjDamageMod = 100
	G11_1.CritChance = 0
	G11_1.CritChanceScaled = 10
	storeProps(G11_1, "AimAccuracy", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G11_1, "AimAccuracy", 6, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G11_1, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G11_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	G11_1.PBbonus_base = -1
	G11_1.HandlingBaseMul = 108
	G11_1.PenetrationClass = 1
	G11_1.ShootAP = 3000
	G11_1.ReloadAP = 2000
	G11_1.APStance = 30
	G11_1.OverwatchAngle = 965
	G11_1.MagazineSize = 45
	G11_1.Cumbersome = 0
	G11_1.Noise = 20
	G11_1.PointBlankBonus = 1
	G11_1.PreparedAttackType = "Overwatch"
	G11_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	G11_1.Rat_swap_ap = 3
	G11_1.wep_base_recoil_mul = 89
	G11_1.wep_base_snapshot_mul = 100
	G11_1.wep_base_hip_mul = 95
	G11_1.burst_selective = true
	G11_1.AutoFireCustomDeltaAP = 1
	G11_1.SingleShotCustomDeltaAP = 1
	G11_1.hyperburst = 75
	G11_1.burst_recoil_delta = 50
	G11_1.long_recoil_delta = 100
	G11_1.auto_recoil_delta = 100
	G11_1.recoil_mechanism = "Gas_Operated"
	G11_1.Rat_cycling = "Auto"
	G11_1.rat_scope_block = false
	G11_1.pistol_swap = false
	G11_1.default_long_barrel = false
	G11_1.unwieldy_weapon = false
	G11_1.ScrapParts = 15
	G11_1.RepairCost = 110
	G11_1.Reliability = 62
	G11_1.LargeItem = 1
	G11_1.HandSlot = "TwoHanded"
	G11_1.AdditionalHint = T( 840010918341, [[<description_hints><newline><image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Special 3-shot burst mode with improved rate of fire and greatly reduced recoil]])
	G11_1.ComponentSlots = {{SlotType = 'Barrel', DefaultComponent = 'G11_Barrel_def_1', AvailableComponents = {'G11_Barrel_def_1', 'G11_Barrel_ext_1'}, Modifiable = true}, {SlotType = 'Scope', DefaultComponent = 'G11_Scope_1', AvailableComponents = {'G11_Scope_1', 'G11_Rail_1'}, Modifiable = true}, {SlotType = 'Muzzle', DefaultComponent = 'CAWS_Muzzle_def_1', AvailableComponents = {'CAWS_Muzzle_def_1', 'RAT_TOG_compensator'}, Modifiable = true}, {SlotType = 'Magazine', DefaultComponent = 'G11_Mag_def_1', AvailableComponents = {'G11_Mag_def_1', 'G11_Mag_ext_1', 'G11_Mag_ext2_1'}, Modifiable = true}, {SlotType = 'Under', CanBeEmpty = true, AvailableComponents = {'G11_Grenadelauncher_1', 'G11_Grip_CAWS_1'}, Modifiable = true}, {SlotType = 'Bipod', CanBeEmpty = true, AvailableComponents = {'G11_Bipod_1'}, Modifiable = true},{CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'bullup', Modifiable = false, AvailableComponents = {'bullup', }}}
	G11_1.Valuable = 1
	G11_1.CanAppearInShop = true
	G11_1.CanAppearUsed = true
	G11_1.Tier = 3
	G11_1.MaxStock = 1
	G11_1.RestockWeight = 5
	G11_1.CategoryPair = "AssaultRifles"
	G11_1.Icon = "Mod/KKh3Yhf/Images/G11_icon.png"
	G11_1.fxClass = "G36"
	G11_1.Description = T(483015059058, [[<style PerkststsBold ><scale 450>The G11 is a non-production prototype assault rifle developed from the late 1960s-1980s.<newline><newline>It was primarily a project of West Germany, though it was of significance to the other NATO countries as well. In particular, versions of the G11 were included in the U.S. Advanced Combat Rifle program. In 1990, the development of the G11 was finished.<newline><newline>Although the weapon was a technical success, it never entered full production due to the political changes of German reunification and lack of procurement contract.<newline><newline>Only 1000 units were ever produced, some of which made their way into the hands of the Bundeswehr. Ultimately, the German armed forces replaced the G3 with the G36.<style MMOptionEntry><newline><newline>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	G11_1.PenetrationClass = 1


	TAR21_1.is_tog_patched = true
	TAR21_1.is_vanilla_firearm = false
	TAR21_1.object_class = "AssaultRifle"
	TAR21_1.Cost = 7800
	TAR21_1.Damage = 24
	TAR21_1.ObjDamageMod = 100
	TAR21_1.CritChance = 0
	TAR21_1.CritChanceScaled = 10
	storeProps(TAR21_1, "AimAccuracy", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(TAR21_1, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(TAR21_1, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(TAR21_1, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	TAR21_1.PBbonus_base = 4
	TAR21_1.HandlingBaseMul = 100
	TAR21_1.PenetrationClass = 1
	TAR21_1.ShootAP = 4000
	TAR21_1.ReloadAP = 4000
	TAR21_1.APStance = 30
	TAR21_1.OverwatchAngle = 1080
	TAR21_1.MagazineSize = 30
	TAR21_1.Cumbersome = 0
	TAR21_1.Noise = 20
	TAR21_1.PointBlankBonus = 1
	TAR21_1.PreparedAttackType = "Overwatch"
	TAR21_1.AvailableAttacks = {"BurstFire", "SingleShot", "AutoFire", "CancelShot"}
	TAR21_1.Rat_swap_ap = 3
	TAR21_1.wep_base_recoil_mul = 101
	TAR21_1.wep_base_snapshot_mul = 101
	TAR21_1.wep_base_hip_mul = 98
	TAR21_1.weigth_held_mul = 125
	TAR21_1.burst_selective = false
	TAR21_1.recoil_mechanism = "Gas_Operated"
	TAR21_1.Rat_cycling = "Auto"
	TAR21_1.rat_scope_block = false
	TAR21_1.pistol_swap = false
	TAR21_1.default_long_barrel = false
	TAR21_1.unwieldy_weapon = false
	TAR21_1.rat_barrel_len = 435
	TAR21_1.rat_weigth = 3500
	TAR21_1.Weigth = 3500
	TAR21_1.ScrapParts = 10
	TAR21_1.RepairCost = 80
	TAR21_1.Reliability = 82
	TAR21_1.LargeItem = 1
	TAR21_1.HandSlot = "TwoHanded"
	TAR21_1.AdditionalHint = T( 292214856686, [[<description_hints>]] )
	TAR21_1.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Scope', DefaultComponent = 'ImprovedIronsight', Modifiable = true, AvailableComponents = {'ImprovedIronsight', 'TAR21_Scope_Rflx_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'TAR21_Mag_def_1', Modifiable = true, AvailableComponents = {'TAR21_Mag_def_1', 'TAR21_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'TAR21_Muzzle_def_1', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'RAT_TOG_suppressor_762', 'MuzzleBooster', 'TAR21_Muzzle_def_1', }}, {CanBeEmpty = true, SlotType = 'General', DefaultComponent = 'bullup', Modifiable = false, AvailableComponents = {'bullup', }}}
	TAR21_1.Valuable = 1
	TAR21_1.CanAppearInShop = true
	TAR21_1.CanAppearUsed = true
	TAR21_1.Tier = 2
	TAR21_1.MaxStock = 1
	TAR21_1.RestockWeight = 35
	TAR21_1.CategoryPair = "AssaultRifles"
	TAR21_1.fxClass = "FNFAL"
	TAR21_1.Description = T(829730422375, [[<style PerkststsBold ><scale 600>The TAR-21 is an Israeli bullpup assault rifle chambered in 5.56×45mm NATO calibre, designed and produced in Israel.<newline><newline>Built around a long-stroke piston system (as found in the M1 Garand and AK-47), the Tar-21 is designed to maximise reliability, durability, simplicity of design, and ease of maintenance, particularly under adverse or battlefield conditions.<newline><newline>The Tar-21 prevailed over the M4A1 in a series of trials conducted during 2001 by the Israel Defense Force. Qualities tested included Mean Rounds Between Failures (MRBF), reliability, ergonomics during long marches, and ease-of-maintenance.<newline><newline><style MMOptionEntry>Made in Israel<image Mod/HXzCpFa/Icons/Flags/Israel.png 1600>]])
	TAR21_1.PenetrationClass = 1


	M1Garand_2.is_tog_patched = true
	M1Garand_2.is_vanilla_firearm = false
	M1Garand_2.object_class = "AssaultRifle"
	M1Garand_2.__parents[1] = "AssaultRifle"
	M1Garand_2.ItemType = "AssaultRifle"
	M1Garand_2.Cost = 3200
	M1Garand_2.Damage = 30
	M1Garand_2.ObjDamageMod = 100
	M1Garand_2.CritChance = 0
	M1Garand_2.CritChanceScaled = 10
	storeProps(M1Garand_2, "AimAccuracy", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M1Garand_2, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M1Garand_2, "WeaponRange", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M1Garand_2, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M1Garand_2.PBbonus_base = -3
	M1Garand_2.HandlingBaseMul = 110
	M1Garand_2.PenetrationClass = 1
	M1Garand_2.ShootAP = 4000
	M1Garand_2.ReloadAP = 3000
	M1Garand_2.APStance = 40
	M1Garand_2.OverwatchAngle = 820
	M1Garand_2.MagazineSize = 8
	M1Garand_2.Cumbersome = 0
	M1Garand_2.Noise = 22
	M1Garand_2.PointBlankBonus = 1
	M1Garand_2.PreparedAttackType = "Overwatch"
	M1Garand_2.AvailableAttacks = {"SingleShot", "CancelShot"}
	M1Garand_2.Rat_swap_ap = 3
	M1Garand_2.wep_base_recoil_mul = 90
	M1Garand_2.wep_base_snapshot_mul = 117
	M1Garand_2.wep_base_hip_mul = 92
	M1Garand_2.weigth_held_mul = 132
	M1Garand_2.burst_selective = false
	M1Garand_2.recoil_mechanism = "Gas_Operated"
	M1Garand_2.Rat_cycling = "SemiAuto"
	M1Garand_2.rat_scope_block = false
	M1Garand_2.pistol_swap = false
	M1Garand_2.default_long_barrel = false
	M1Garand_2.unwieldy_weapon = false
	M1Garand_2.rat_barrel_len = 610
	M1Garand_2.rat_weigth = 4500
	M1Garand_2.Weigth = 4500
	M1Garand_2.ScrapParts = 9
	M1Garand_2.RepairCost = 80
	M1Garand_2.Reliability = 86
	M1Garand_2.LargeItem = 1
	M1Garand_2.HandSlot = "TwoHanded"
	M1Garand_2.AdditionalHint = T( 297407062004, [[<description_hints>]] )
	M1Garand_2.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'RAT_TOG_suppressor_762', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'ImprovedIronsight', Modifiable = true, AvailableComponents = {'ImprovedIronsight', }}}
	M1Garand_2.Valuable = 0
	M1Garand_2.CanAppearInShop = true
	M1Garand_2.CanAppearUsed = true
	M1Garand_2.Tier = 1
	M1Garand_2.MaxStock = 4
	M1Garand_2.RestockWeight = 90
	M1Garand_2.CategoryPair = "AssaultRifles"
	M1Garand_2.fxClass = "Gewehr98"
	M1Garand_2.Description = T(757423265427, [[<style PerkststsBold ><scale 600>The M1 Garand or M1 rifle is a semi-automatic rifle that was the service rifle of the U.S. Army during World War II and the Korean War.<newline><newline>The rifle is chambered for the .30-06 Springfield cartridge and is named after its Canadian-American designer, John Garand. It was the first standard-issue autoloading rifle for the United States. By most accounts, the M1 rifle performed well. General George S. Patton called it "the greatest battle implement ever devised".<newline><newline>The M1 replaced the bolt-action M1903 Springfield as the U.S. service rifle in 1936, and was itself replaced by the selective-fire M14 rifle on March 26, 1958.<newline><newline><style MMOptionEntry>Made in USA <image UI/Icons/Flags/f_usa.dds 1600>]])
	M1Garand_2.PenetrationClass = 1


	G3A3_1.is_tog_patched = true
	G3A3_1.is_vanilla_firearm = false
	G3A3_1.object_class = "AssaultRifle"
	G3A3_1.Cost = 5400
	G3A3_1.Damage = 31
	G3A3_1.ObjDamageMod = 100
	G3A3_1.CritChance = 0
	G3A3_1.CritChanceScaled = 10
	storeProps(G3A3_1, "AimAccuracy", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G3A3_1, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G3A3_1, "WeaponRange", 36, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G3A3_1, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	G3A3_1.PBbonus_base = 2
	G3A3_1.HandlingBaseMul = 105
	G3A3_1.PenetrationClass = 1
	G3A3_1.ShootAP = 4000
	G3A3_1.ReloadAP = 3000
	G3A3_1.APStance = 40
	G3A3_1.OverwatchAngle = 1106
	G3A3_1.MagazineSize = 20
	G3A3_1.Cumbersome = 0
	G3A3_1.Noise = 20
	G3A3_1.PointBlankBonus = 1
	G3A3_1.PreparedAttackType = "Overwatch"
	G3A3_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	G3A3_1.Rat_swap_ap = 3
	G3A3_1.wep_base_recoil_mul = 105
	G3A3_1.wep_base_snapshot_mul = 102
	G3A3_1.wep_base_hip_mul = 99
	G3A3_1.weigth_held_mul = 129
	G3A3_1.burst_selective = false
	G3A3_1.recoil_mechanism = "Roller_Delayed"
	G3A3_1.Rat_cycling = "Auto"
	G3A3_1.rat_scope_block = false
	G3A3_1.pistol_swap = false
	G3A3_1.default_long_barrel = false
	G3A3_1.unwieldy_weapon = false
	G3A3_1.rat_barrel_len = 410
	G3A3_1.rat_weigth = 4100
	G3A3_1.Weigth = 4100
	G3A3_1.ScrapParts = 10
	G3A3_1.RepairCost = 65
	G3A3_1.Reliability = 84
	G3A3_1.LargeItem = 1
	G3A3_1.HandSlot = "TwoHanded"
	G3A3_1.AdditionalHint = T( 540692805911, [[<description_hints>]] )
	G3A3_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'G3A3_barrel_def_1', Modifiable = true, AvailableComponents = {'G3A3_barrel_shrt_1', 'G3A3_barrel_def_1', 'G3A3_barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'G3A3_muzzle_1', Modifiable = true, AvailableComponents = {'RAT_TOG_suppressor', 'ImprovisedSuppressor', 'G3A3_muzzle_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'G3A3_magazine_1', Modifiable = true, AvailableComponents = {'G3A3_magazine_1', }}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'hk33_bipod_fld_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'G3A3_Stock_1', Modifiable = true, AvailableComponents = {'G3A3_Stock_1', 'G3A3_stock_hvy_1', 'HK53_stock_unfld_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_PSGScope', 'RAT_TOG_LRoptics_advanced', }}}
	G3A3_1.Valuable = 0
	G3A3_1.CanAppearInShop = false
	G3A3_1.CanAppearUsed = true
	G3A3_1.Tier = 2
	G3A3_1.MaxStock = 2
	G3A3_1.RestockWeight = 30
	G3A3_1.CategoryPair = "AssaultRifles"
	G3A3_1.fxClass = "G36"
	G3A3_1.Description = T(780263210373, [[<style PerkststsBold ><scale 600>The G3 (Gewehr 3) is a 7.62×51mm NATO, select-fire battle rifle developed in the 1950s<newline><newline>The modular designed G3 has over the years been exported to over 70 countries and manufactured under licence in at least 15 countries, bringing the total number built to around 7,800,000. It was the service rifle of the armed forces of Germany until it was replaced by the G36 in the 1990s.<newline><newline>The G3A3 is the most well known 1963 version. Drum sights with an improved front sight, a flash-suppressor/muzzle brake capable of firing NATO standard grenades, a fixed solid plastic buttstock, and a plastic handguard that does not contact the free-floating barrel. The handguard came in a slim, ventilated version and a wide version. The latter allows for the attachment of a bipod.<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	G3A3_1.PenetrationClass = 1


	G3A3Green_1.is_tog_patched = true
	G3A3Green_1.is_vanilla_firearm = false
	G3A3Green_1.object_class = "AssaultRifle"
	G3A3Green_1.Cost = 5400
	G3A3Green_1.Damage = 31
	G3A3Green_1.ObjDamageMod = 100
	G3A3Green_1.CritChance = 0
	G3A3Green_1.CritChanceScaled = 10
	storeProps(G3A3Green_1, "AimAccuracy", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G3A3Green_1, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G3A3Green_1, "WeaponRange", 36, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G3A3Green_1, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	G3A3Green_1.PBbonus_base = 2
	G3A3Green_1.HandlingBaseMul = 105
	G3A3Green_1.PenetrationClass = 1
	G3A3Green_1.ShootAP = 4000
	G3A3Green_1.ReloadAP = 3000
	G3A3Green_1.APStance = 40
	G3A3Green_1.OverwatchAngle = 1106
	G3A3Green_1.MagazineSize = 20
	G3A3Green_1.Cumbersome = 0
	G3A3Green_1.Noise = 20
	G3A3Green_1.PointBlankBonus = 1
	G3A3Green_1.PreparedAttackType = "Overwatch"
	G3A3Green_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	G3A3Green_1.Rat_swap_ap = 3
	G3A3Green_1.wep_base_recoil_mul = 105
	G3A3Green_1.wep_base_snapshot_mul = 102
	G3A3Green_1.wep_base_hip_mul = 99
	G3A3Green_1.weigth_held_mul = 129
	G3A3Green_1.burst_selective = false
	G3A3Green_1.recoil_mechanism = "Roller_Delayed"
	G3A3Green_1.Rat_cycling = "Auto"
	G3A3Green_1.rat_scope_block = false
	G3A3Green_1.pistol_swap = false
	G3A3Green_1.default_long_barrel = false
	G3A3Green_1.unwieldy_weapon = false
	G3A3Green_1.rat_barrel_len = 410
	G3A3Green_1.rat_weigth = 4100
	G3A3Green_1.Weigth = 4100
	G3A3Green_1.ScrapParts = 10
	G3A3Green_1.RepairCost = 65
	G3A3Green_1.Reliability = 84
	G3A3Green_1.LargeItem = 1
	G3A3Green_1.HandSlot = "TwoHanded"
	G3A3Green_1.AdditionalHint = T( 334688337888, [[<description_hints>]] )
	G3A3Green_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'G3A3_barrel_def_1', Modifiable = true, AvailableComponents = {'G3A3_barrel_shrt_1', 'G3A3_barrel_def_1', 'G3A3_barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'G3A3_muzzle_1', Modifiable = true, AvailableComponents = {'RAT_TOG_suppressor', 'ImprovisedSuppressor', 'G3A3_muzzle_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'G3A3_magazine_1', Modifiable = true, AvailableComponents = {'G3A3_magazine_1', }}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'hk33_bipod_fld_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_PSGScope', 'RAT_TOG_LRoptics_advanced', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'G3A3_Stock_1', Modifiable = true, AvailableComponents = {'G3A3_Stock_1', 'G3A3_stock_hvy_1', 'HK53_stock_unfld_1', }}}
	G3A3Green_1.Valuable = 0
	G3A3Green_1.CanAppearInShop = true
	G3A3Green_1.CanAppearUsed = true
	G3A3Green_1.Tier = 2
	G3A3Green_1.MaxStock = 2
	G3A3Green_1.RestockWeight = 30
	G3A3Green_1.CategoryPair = "AssaultRifles"
	G3A3Green_1.fxClass = "G36"
	G3A3Green_1.Description = T(937019771354, [[<style PerkststsBold ><scale 600>The G3 (Gewehr 3) is a 7.62×51mm NATO, select-fire battle rifle developed in the 1950s<newline><newline>The modular designed G3 has over the years been exported to over 70 countries and manufactured under licence in at least 15 countries, bringing the total number built to around 7,800,000. It was the service rifle of the armed forces of Germany until it was replaced by the G36 in the 1990s.<newline><newline>The G3A3 is the most well known 1963 version. Drum sights with an improved front sight, a flash-suppressor/muzzle brake capable of firing NATO standard grenades, a fixed solid plastic buttstock, and a plastic handguard that does not contact the free-floating barrel. The handguard came in a slim, ventilated version and a wide version. The latter allows for the attachment of a bipod.<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	G3A3Green_1.PenetrationClass = 1


	RK95_1.is_tog_patched = true
	RK95_1.is_vanilla_firearm = false
	RK95_1.object_class = "AssaultRifle"
	RK95_1.Cost = 4000
	RK95_1.Damage = 26
	RK95_1.ObjDamageMod = 100
	RK95_1.CritChance = 0
	RK95_1.CritChanceScaled = 20
	storeProps(RK95_1, "AimAccuracy", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RK95_1, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RK95_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RK95_1, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	RK95_1.PBbonus_base = 3
	RK95_1.PenetrationClass = 1
	RK95_1.ShootAP = 4000
	RK95_1.ReloadAP = 3000
	RK95_1.APStance = 40
	RK95_1.OverwatchAngle = 1111
	RK95_1.MagazineSize = 30
	RK95_1.Cumbersome = 0
	RK95_1.Noise = 20
	RK95_1.PointBlankBonus = 1
	RK95_1.PreparedAttackType = "Overwatch"
	RK95_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	RK95_1.Rat_swap_ap = 3
	RK95_1.wep_base_recoil_mul = 99
	RK95_1.wep_base_snapshot_mul = 102
	RK95_1.weigth_held_mul = 129
	RK95_1.burst_selective = false
	RK95_1.recoil_mechanism = "Gas_Operated"
	RK95_1.Rat_cycling = "Auto"
	RK95_1.rat_scope_block = false
	RK95_1.pistol_swap = false
	RK95_1.default_long_barrel = false
	RK95_1.unwieldy_weapon = false
	RK95_1.rat_barrel_len = 406
	RK95_1.rat_weigth = 4100
	RK95_1.Weigth = 4100
	RK95_1.ScrapParts = 10
	RK95_1.RepairCost = 15
	RK95_1.Reliability = 90
	RK95_1.LargeItem = 1
	RK95_1.HandSlot = "TwoHanded"
	RK95_1.AdditionalHint = T( 266083134551, [[<description_hints>]] )
	RK95_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'RK95_Stock_def_1', Modifiable = true, AvailableComponents = {'RK95_Stock_def_1', 'RK95_Stock_shrt_1' }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'RK95_Mag_def_1', Modifiable = true, AvailableComponents = {'RK95_Mag_def_1', 'RK95_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Handguard', DefaultComponent = 'RK95_Handguard_def_1', Modifiable = false, AvailableComponents = {'RK95_Handguard_shrt_1', 'RK95_Handguard_def_1', 'RK95_Handguard_ext_1', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'RK95_Irons_1', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_LRoptics_advanced', 'RK95_Irons_1', }}, {CanBeEmpty = true, SlotType = 'Muzzle', DefaultComponent = 'RK95_Muzzle_def_1', Modifiable = true, AvailableComponents = {'RK95_Muzzle_def_1', 'MuzzleBooster', 'RAT_TOG_suppressor', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'RK95_Barrel_def_1', Modifiable = true, AvailableComponents = {'RK95_Barrel_shrt_1', 'RK95_Barrel_def_1', 'RK95_Barrel_ext_1', }}}
	RK95_1.Valuable = 0
	RK95_1.CanAppearInShop = true
	RK95_1.CanAppearUsed = true
	RK95_1.Tier = 2
	RK95_1.MaxStock = 3
	RK95_1.RestockWeight = 60
	RK95_1.CategoryPair = "AssaultRifles"
	RK95_1.Description = T(296496696034, [[<style PerkststsBold ><scale 600>The RK 95 TP is a 7.62×39mm Finnish assault rifle adopted in relatively small numbers by the Finnish Defence Forces in the 1990s.<newline><newline>The rifle was developed in the late 1980s in response to a requirement to replace the 7.62mm RK 62 service rifle. Between 1988 and 1990, the M90 prototype was developed, which was a substantially upgraded variant of the RK 62.<newline><newline>After undergoing further testing and implementing several changes (among them, the selector mechanism was reverted to the familiar RK 62 configuration) the rifle was introduced into service with the Finnish Army as the 7.62 RK 95 TP. Deliveries to the Finnish started in 1995 and ended at 1997 with further orders ceasing in 1998.<newline><newline><style MMOptionEntry>Made in Finland <image Mod/HXzCpFa/Icons/Flags/Finland.png 1600>]])
	RK95_1.PenetrationClass = 1


	RK62_1.is_tog_patched = true
	RK62_1.is_vanilla_firearm = false
	RK62_1.object_class = "AssaultRifle"
	RK62_1.Cost = 3400
	RK62_1.Damage = 26
	RK62_1.ObjDamageMod = 100
	RK62_1.CritChance = 0
	RK62_1.CritChanceScaled = 10
	storeProps(RK62_1, "AimAccuracy", 31, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RK62_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RK62_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RK62_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	RK62_1.PBbonus_base = 3
	RK62_1.PenetrationClass = 1
	RK62_1.ShootAP = 4000
	RK62_1.ReloadAP = 3000
	RK62_1.APStance = 40
	RK62_1.OverwatchAngle = 1139
	RK62_1.MagazineSize = 30
	RK62_1.Cumbersome = 0
	RK62_1.Noise = 20
	RK62_1.PointBlankBonus = 1
	RK62_1.PreparedAttackType = "Overwatch"
	RK62_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	RK62_1.Rat_swap_ap = 3
	RK62_1.wep_base_recoil_mul = 101
	RK62_1.weigth_held_mul = 126
	RK62_1.burst_selective = false
	RK62_1.recoil_mechanism = "Gas_Operated"
	RK62_1.Rat_cycling = "Auto"
	RK62_1.rat_scope_block = false
	RK62_1.pistol_swap = false
	RK62_1.default_long_barrel = false
	RK62_1.unwieldy_weapon = false
	RK62_1.rat_barrel_len = 406
	RK62_1.rat_weigth = 3700
	RK62_1.Weigth = 3700
	RK62_1.ScrapParts = 12
	RK62_1.RepairCost = 25
	RK62_1.Reliability = 90
	RK62_1.LargeItem = 1
	RK62_1.HandSlot = "TwoHanded"
	RK62_1.AdditionalHint = T( 347255431158, [[<description_hints>]] )
	RK62_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'RK62_Stock_def_1', Modifiable = true, AvailableComponents = {'RK62_Stock_shrt_1', 'RK62_Stock_def_1', 'RK62_Stock_hvy_1' }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'RK62_Mag_def_1', Modifiable = true, AvailableComponents = {'RK62_Mag_def_1', 'RK62_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Handguard', DefaultComponent = 'RK62_Handguard_def_1', Modifiable = false, AvailableComponents = {'RK62_Handguard_shrt_1', 'RK62_Handguard_def_1', 'RK62_Handguard_ext_1', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'RK62_Irons_1', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_LRoptics_advanced', 'RK62_Irons_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'RK62_Muzzle_def_1', Modifiable = true, AvailableComponents = {'RK62_Muzzle_def_1', 'MuzzleBooster', 'RAT_TOG_suppressor', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'RK62_Barrel_def_1', Modifiable = true, AvailableComponents = {'RK62_Barrel_shrt_1', 'RK62_Barrel_def_1', 'RK62_Barrel_ext_1', }}}
	RK62_1.Valuable = 0
	RK62_1.CanAppearInShop = true
	RK62_1.CanAppearUsed = true
	RK62_1.Tier = 1
	RK62_1.MaxStock = 2
	RK62_1.RestockWeight = 40
	RK62_1.CategoryPair = "AssaultRifles"
	RK62_1.Description = T(164668406560, [[<style PerkststsBold ><scale 600>The RK 62 officially 7.62 RK 62, is the standard issue infantry weapon of the Finnish Defence Forces.<newline><newline>Lauri Oksanen designed the RK 62 between 1957 and 1962, based on the Polish licensed version of the Soviet AK-47 design. The RK 62 uses the same 7.62×39mm cartridge as the AK-47. It is considered a high-quality variant of the AK-47, with a unique design that includes a three-pronged flash suppressor and a groove for a specially designed knife bayonet that can be used alone as a combat knife.<newline><newline>The RK 62 has several improvements over most AK variants, including the metallurgical quality of the receiver and barrel. The most significant improvement is in the sights: while most AK variants have the rear sight mounted on top of the gas piston housing on top of the receiver, in the RK 62, it is mounted on the rear of the receiver cover with tritium illuminated night-sights. The sight radius is doubled, enhancing accuracy along with the hammer-forged match CM barrel.<newline><newline><style MMOptionEntry>Made in Finland <image Mod/HXzCpFa/Icons/Flags/Finland.png 1600>]])
	RK62_1.PenetrationClass = 1


	Gewehr43_1.is_tog_patched = true
	Gewehr43_1.is_vanilla_firearm = false
	Gewehr43_1.object_class = "AssaultRifle"
	Gewehr43_1.ItemType = "AssaultRifle"
	Gewehr43_1.Cost = 1700
	Gewehr43_1.Damage = 30
	Gewehr43_1.ObjDamageMod = 100
	Gewehr43_1.CritChance = 0
	Gewehr43_1.CritChanceScaled = 10
	storeProps(Gewehr43_1, "AimAccuracy", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr43_1, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr43_1, "WeaponRange", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr43_1, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Gewehr43_1.PBbonus_base = -1
	Gewehr43_1.HandlingBaseMul = 101
	Gewehr43_1.PenetrationClass = 1
	Gewehr43_1.ShootAP = 4000
	Gewehr43_1.ReloadAP = 4000
	Gewehr43_1.APStance = 40
	Gewehr43_1.OverwatchAngle = 959
	Gewehr43_1.MagazineSize = 10
	Gewehr43_1.Cumbersome = 0
	Gewehr43_1.Noise = 22
	Gewehr43_1.PointBlankBonus = 1
	Gewehr43_1.PreparedAttackType = "Both"
	Gewehr43_1.AvailableAttacks = {"SingleShot", "CancelShot"}
	Gewehr43_1.Rat_swap_ap = 3
	Gewehr43_1.wep_base_recoil_mul = 92
	Gewehr43_1.wep_base_snapshot_mul = 110
	Gewehr43_1.wep_base_hip_mul = 92
	Gewehr43_1.weigth_held_mul = 125
	Gewehr43_1.burst_selective = false
	Gewehr43_1.recoil_mechanism = "Gas_Operated"
	Gewehr43_1.Rat_cycling = "SemiAuto"
	Gewehr43_1.rat_scope_block = false
	Gewehr43_1.pistol_swap = false
	Gewehr43_1.default_long_barrel = false
	Gewehr43_1.unwieldy_weapon = false
	Gewehr43_1.rat_barrel_len = 550
	Gewehr43_1.rat_weigth = 3600
	Gewehr43_1.Weigth = 3600
	Gewehr43_1.ScrapParts = 8
	Gewehr43_1.RepairCost = 80
	Gewehr43_1.Reliability = 78
	Gewehr43_1.LargeItem = 1
	Gewehr43_1.HandSlot = "TwoHanded"
	Gewehr43_1.AdditionalHint = T( 538484376797, [[<description_hints>]] )
	Gewehr43_1.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'GW43_Scope_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'G43_Barrel_def_1', Modifiable = true, AvailableComponents = {'G43_Barrel_def_1', 'G43_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'ToG_VFX_Muzzle', 'RAT_TOG_compensator', 'RAT_TOG_suppressor', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'G43_Mag_def_1', Modifiable = true, AvailableComponents = {'G43_Mag_def_1', 'G43_Mag_ext_1', }}}
	Gewehr43_1.Valuable = 0
	Gewehr43_1.CanAppearInShop = true
	Gewehr43_1.CanAppearUsed = true
	Gewehr43_1.Tier = 1
	Gewehr43_1.MaxStock = 3
	Gewehr43_1.RestockWeight = 40
	Gewehr43_1.CategoryPair = "AssaultRifles"
	Gewehr43_1.fxClass = "PSG1"
	Gewehr43_1.Description = T(314229886535, [[<style PerkststsBold ><scale 700>The Gewehr 43 or Karabiner 43 is a semi-automatic rifle developed by Germany during World War II.<newline><newline>In 1941, Germany invaded the Soviet Union as part of Operation Barbarossa. Just prior to the opening of hostilities the Soviet Red Army had started re-arming its infantry, complementing its older bolt-action rifles with the new semi-automatic SVT-38s and SVT-40s. This was a shock to the Germans, who ramped up their own semi-automatic rifle development efforts significantly.<newline><newline>The Gewehr 43 was put into production in October 1943 and followed in 1944 by the Karabiner 43 (K43), which was identical to the G43 in every way except for the letter stamped on the side.<newline><newline>It was manufactured using innovative mass-production techniques, with production amounting to just over 400,000 between 1943 and 1945.<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	Gewehr43_1.PenetrationClass = 1


	M70_1.is_tog_patched = true
	M70_1.is_vanilla_firearm = false
	M70_1.object_class = "AssaultRifle"
	M70_1.Cost = 2800
	M70_1.Damage = 27
	M70_1.ObjDamageMod = 100
	M70_1.CritChance = 0
	M70_1.CritChanceScaled = 10
	storeProps(M70_1, "AimAccuracy", 29, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M70_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M70_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M70_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M70_1.PBbonus_base = -2
	M70_1.HandlingBaseMul = 108
	M70_1.PenetrationClass = 1
	M70_1.ShootAP = 4000
	M70_1.ReloadAP = 3000
	M70_1.APStance = 40
	M70_1.OverwatchAngle = 1068
	M70_1.MagazineSize = 30
	M70_1.Cumbersome = 0
	M70_1.Noise = 20
	M70_1.PointBlankBonus = 1
	M70_1.PreparedAttackType = "Overwatch"
	M70_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	M70_1.Rat_swap_ap = 3
	M70_1.wep_base_recoil_mul = 97
	M70_1.wep_base_snapshot_mul = 104
	M70_1.wep_base_hip_mul = 99
	M70_1.weigth_held_mul = 132
	M70_1.burst_selective = false
	M70_1.recoil_mechanism = "Gas_Operated"
	M70_1.Rat_cycling = "Auto"
	M70_1.rat_scope_block = false
	M70_1.pistol_swap = false
	M70_1.default_long_barrel = false
	M70_1.unwieldy_weapon = false
	M70_1.rat_barrel_len = 415
	M70_1.rat_weigth = 4560
	M70_1.Weigth = 4560
	M70_1.ScrapParts = 10
	M70_1.RepairCost = 20
	M70_1.Reliability = 88
	M70_1.LargeItem = 1
	M70_1.HandSlot = "TwoHanded"
	M70_1.AdditionalHint = T( 943877456040, [[<description_hints>]] )
	M70_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'M70_stock_unfld_1', Modifiable = true, AvailableComponents = {'M70_stock_unfld_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'M70_mag_def_1', Modifiable = true, AvailableComponents = {'M70_mag_def_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'RAT_TOG_CompensatorNoEntity', Modifiable = true, AvailableComponents = {'RAT_TOG_CompensatorNoEntity' }}, {CanBeEmpty = false, SlotType = 'Mountfront', DefaultComponent = 'M70_grndl_fld_1', Modifiable = true, AvailableComponents = {'M70_grndl_fld_1', 'M70_grndl_unfld_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'M70_barrel_def_1', Modifiable = true, AvailableComponents = {'M70_barrel_shrt_1', 'M70_barrel_def_1', 'M70_barrel_ext_1', }}}
	M70_1.Valuable = 0
	M70_1.CanAppearInShop = true
	M70_1.CanAppearUsed = true
	M70_1.Tier = 1
	M70_1.MaxStock = 3
	M70_1.RestockWeight = 60
	M70_1.CategoryPair = "AssaultRifles"
	M70_1.Description = T(960118679815, [[<style PerkststsBold ><scale 500>The M70 is a 7.62×39mm assault rifle. Developed in the Socialist Federal Republic of Yugoslavia during the 1960s, the M70 was an unlicensed derivative of the Soviet AK-47 (specifically the Type 3 variant).<newline><newline>Due to political differences between the Soviet Union and Yugoslavia at the time, namely the latter's refusal to join the Warsaw Pact, Yugoslavia was unable to directly obtain the technical specifications for the AK and opted to reverse engineer the weapon type. Although the M70 was functionally identical to the AK, it had unique in-built features that better enabled it to fire rifle grenades. These included thicker receivers, new latches for the dust cover to ensure it wouldn't be jarred loose by a grenade's discharge, and folding grenade sight brackets over the rifles' gas blocks, which also shut off the gas system when raised.<newline><newline>The M70 became the standard issue infantry weapon in the Yugoslav People's Army in 1970, complementing and later superseding the Zastava M59/66. It remains in use with all former Yugoslav nations, although some are replacing it with more modern designs. Additionally the M70 has been widely exported and encountered often in Africa, Asia and the Middle East.<newline><newline><style MMOptionEntry>Made in Yugoslavia <image Mod/KKh3Yhf/Images/Yugoslavia.png 1600>]])
	M70_1.PenetrationClass = 1


	Papovka2SKS_1.is_tog_patched = true
	Papovka2SKS_1.is_vanilla_firearm = false
	Papovka2SKS_1.object_class = "AssaultRifle"
	Papovka2SKS_1.__parents[1] = "AssaultRifle"
	Papovka2SKS_1.ItemType = "AssaultRifle"
	Papovka2SKS_1.Cost = 1700
	Papovka2SKS_1.Damage = 26
	Papovka2SKS_1.ObjDamageMod = 100
	Papovka2SKS_1.CritChance = 0
	Papovka2SKS_1.CritChanceScaled = 10
	storeProps(Papovka2SKS_1, "AimAccuracy", 29, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Papovka2SKS_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Papovka2SKS_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Papovka2SKS_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Papovka2SKS_1.PBbonus_base = 0
	Papovka2SKS_1.HandlingBaseMul = 105
	Papovka2SKS_1.PenetrationClass = 1
	Papovka2SKS_1.ShootAP = 4000
	Papovka2SKS_1.ReloadAP = 3000
	Papovka2SKS_1.APStance = 40
	Papovka2SKS_1.OverwatchAngle = 876
	Papovka2SKS_1.MagazineSize = 10
	Papovka2SKS_1.Cumbersome = 0
	Papovka2SKS_1.Noise = 20
	Papovka2SKS_1.PointBlankBonus = 1
	Papovka2SKS_1.PreparedAttackType = "Overwatch"
	Papovka2SKS_1.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	Papovka2SKS_1.Rat_swap_ap = 3
	Papovka2SKS_1.wep_base_recoil_mul = 94
	Papovka2SKS_1.wep_base_snapshot_mul = 100
	Papovka2SKS_1.wep_base_hip_mul = 95
	Papovka2SKS_1.weigth_held_mul = 127
	Papovka2SKS_1.burst_selective = false
	Papovka2SKS_1.recoil_mechanism = "Gas_Operated"
	Papovka2SKS_1.Rat_cycling = "SemiAuto"
	Papovka2SKS_1.rat_scope_block = false
	Papovka2SKS_1.pistol_swap = false
	Papovka2SKS_1.default_long_barrel = false
	Papovka2SKS_1.unwieldy_weapon = false
	Papovka2SKS_1.rat_barrel_len = 508
	Papovka2SKS_1.rat_weigth = 3850
	Papovka2SKS_1.Weigth = 3850
	Papovka2SKS_1.ScrapParts = 14
	Papovka2SKS_1.RepairCost = 30
	Papovka2SKS_1.Reliability = 87
	Papovka2SKS_1.LargeItem = 1
	Papovka2SKS_1.HandSlot = "TwoHanded"
	Papovka2SKS_1.AdditionalHint = T( 682979088346, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Grenade Launcher]] )
	Papovka2SKS_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Papovka2_Bay_fld_1', Modifiable = true, AvailableComponents = {'Papovka2_Bay_fld_1', 'Papovka2_Bay_unfld_1', }}, {CanBeEmpty = false, SlotType = 'Mountfront', DefaultComponent = 'Papovka2_Grnd_fld_1', Modifiable = true, AvailableComponents = {'Papovka2_Grnd_fld_1', 'Papovka2_Grnd_unfld_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_laser_dot', 'RAT_TOG_uv_dot', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'LROptics_DragunovDefault', }}, {CanBeEmpty = false, SlotType = 'Mount', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Papovka2_Bolt_1', Modifiable = false, AvailableComponents = {'Papovka2_Bolt_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = false, AvailableComponents = {'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Gassblock', DefaultComponent = 'RAT_pap_compensator', Modifiable = true, AvailableComponents = {'RAT_pap_compensator', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Papovka2_Barrel_def_1', Modifiable = true, AvailableComponents = {'Papovka2_Barrel_def_1', 'Papovka2_Barrel_ext_1', 'Papovka2_Barrel_shrt_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'Papovka2_Stock_def_1', Modifiable = true, AvailableComponents = {'Papovka2_Stock_def_1', 'Papovka2_Stock_erg_1', 'Papovka2_Stock_hvy_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'Papovka2_Mag_def_1', Modifiable = true, AvailableComponents = {'Papovka2_Mag_def_1', 'Papovka2_Mag_ext_1', }}}
	Papovka2SKS_1.Valuable = 0
	Papovka2SKS_1.CanAppearInShop = true
	Papovka2SKS_1.CanAppearUsed = true
	Papovka2SKS_1.Tier = 1
	Papovka2SKS_1.MaxStock = 2
	Papovka2SKS_1.RestockWeight = 20
	Papovka2SKS_1.CategoryPair = "AssaultRifles"
	Papovka2SKS_1.Description = T(545078610627, [[<style PerkststsBold ><scale 700>M59/66 PAP, also known as papovka, is a Yugoslav licensed version of Soviet SKS semi-automatic rifle.<newline><newline>In 1959, Yugoslavia acquired the rights to manufacture the Soviet SKS semi-automatic carbine under license. Limited production of the SKS commenced in 1961, however, no SKS carbines were produced at the Kragujevac facility again until 1964, when the weapon type finally entered serialized mass production.<newline><newline>In 1966, the M59 was redesigned to fire 22mm rifle grenades via the addition of an integrated grenade launcher spigot. The new model also included a folding ladder sight for use with the rifle grenades<newline><newline>During the South African Border War, the People's Liberation Army of Namibia (PLAN) received an unknown number of M59/66s and 22mm M60 rifle grenades, also of Yugoslav origin, as military aid.<newline><newline><style MMOptionEntry>Made in Yugoslavia <image Mod/KKh3Yhf/Images/Yugoslavia.png 1600>]])
	Papovka2SKS_1.PenetrationClass = 1


	PapovkaSKS_1.is_tog_patched = true
	PapovkaSKS_1.is_vanilla_firearm = false
	PapovkaSKS_1.object_class = "AssaultRifle"
	PapovkaSKS_1.__parents[1] = "AssaultRifle"
	PapovkaSKS_1.ItemType = "AssaultRifle"
	PapovkaSKS_1.Cost = 1700
	PapovkaSKS_1.Damage = 26
	PapovkaSKS_1.ObjDamageMod = 100
	PapovkaSKS_1.CritChance = 0
	PapovkaSKS_1.CritChanceScaled = 10
	storeProps(PapovkaSKS_1, "AimAccuracy", 29, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PapovkaSKS_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PapovkaSKS_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PapovkaSKS_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	PapovkaSKS_1.PBbonus_base = 0
	PapovkaSKS_1.HandlingBaseMul = 105
	PapovkaSKS_1.PenetrationClass = 1
	PapovkaSKS_1.ShootAP = 4000
	PapovkaSKS_1.ReloadAP = 3000
	PapovkaSKS_1.APStance = 40
	PapovkaSKS_1.OverwatchAngle = 876
	PapovkaSKS_1.MagazineSize = 10
	PapovkaSKS_1.Cumbersome = 0
	PapovkaSKS_1.Noise = 22
	PapovkaSKS_1.PointBlankBonus = 1
	PapovkaSKS_1.PreparedAttackType = "Overwatch"
	PapovkaSKS_1.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	PapovkaSKS_1.Rat_swap_ap = 3
	PapovkaSKS_1.wep_base_recoil_mul = 94
	PapovkaSKS_1.wep_base_snapshot_mul = 100
	PapovkaSKS_1.wep_base_hip_mul = 95
	PapovkaSKS_1.weigth_held_mul = 127
	PapovkaSKS_1.burst_selective = false
	PapovkaSKS_1.recoil_mechanism = "Gas_Operated"
	PapovkaSKS_1.Rat_cycling = "SemiAuto"
	PapovkaSKS_1.rat_scope_block = false
	PapovkaSKS_1.pistol_swap = false
	PapovkaSKS_1.default_long_barrel = false
	PapovkaSKS_1.unwieldy_weapon = false
	PapovkaSKS_1.rat_barrel_len = 508
	PapovkaSKS_1.rat_weigth = 3850
	PapovkaSKS_1.Weigth = 3850
	PapovkaSKS_1.ScrapParts = 14
	PapovkaSKS_1.RepairCost = 30
	PapovkaSKS_1.Reliability = 87
	PapovkaSKS_1.LargeItem = 1
	PapovkaSKS_1.HandSlot = "TwoHanded"
	PapovkaSKS_1.AdditionalHint = T( 610094615575, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Grenade Launcher]] )
	PapovkaSKS_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Papovka_Bay_fld_1', Modifiable = true, AvailableComponents = {'Papovka_Bay_fld_1', 'Papovka_Bay_unfld_1', }}, {CanBeEmpty = false, SlotType = 'Mountfront', DefaultComponent = 'Papovka_Grnd_fld_1', Modifiable = true, AvailableComponents = {'Papovka_Grnd_fld_1', 'Papovka_Grnd_unfld_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_laser_dot', 'RAT_TOG_uv_dot', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'LROptics_DragunovDefault', }}, {CanBeEmpty = false, SlotType = 'Mount', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Gassblock', DefaultComponent = 'RAT_pap_compensator', Modifiable = true, AvailableComponents = {'RAT_pap_compensator', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = false, AvailableComponents = {'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Papovka_Barrel_def_1', Modifiable = true, AvailableComponents = {'Papovka_Barrel_ext_1', 'Papovka_Barrel_shrt_1', 'Papovka_Barrel_def_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'Papovka_Stock_def_1', Modifiable = true, AvailableComponents = {'Papovka_Stock_erg_1', 'Papovka_Stock_def_1', 'Papovka_Stock_hvy_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'Papovka_Mag_def_1', Modifiable = true, AvailableComponents = {'Papovka2_Mag_def_1', 'Papovka2_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Papovka_Bolt_1', Modifiable = false, AvailableComponents = {'Papovka_Bolt_1', }}}
	PapovkaSKS_1.Valuable = 0
	PapovkaSKS_1.CanAppearInShop = true
	PapovkaSKS_1.CanAppearUsed = true
	PapovkaSKS_1.Tier = 1
	PapovkaSKS_1.MaxStock = 2
	PapovkaSKS_1.RestockWeight = 25
	PapovkaSKS_1.CategoryPair = "AssaultRifles"
	PapovkaSKS_1.Description = T(414698211337, [[<style PerkststsBold ><scale 700>M59/66 PAP, also known as papovka, is a Yugoslav licensed version of Soviet SKS semi-automatic rifle.<newline><newline>In 1959, Yugoslavia acquired the rights to manufacture the Soviet SKS semi-automatic carbine under license. Limited production of the SKS commenced in 1961, however, no SKS carbines were produced at the Kragujevac facility again until 1964, when the weapon type finally entered serialized mass production.<newline><newline>In 1966, the M59 was redesigned to fire 22mm rifle grenades via the addition of an integrated grenade launcher spigot. The new model also included a folding ladder sight for use with the rifle grenades<newline><newline>During the South African Border War, the People's Liberation Army of Namibia (PLAN) received an unknown number of M59/66s and 22mm M60 rifle grenades, also of Yugoslav origin, as military aid.<newline><newline><style MMOptionEntry>Made in Yugoslavia <image Mod/KKh3Yhf/Images/Yugoslavia.png 1600>]])
	PapovkaSKS_1.PenetrationClass = 1


	SKS_1.is_tog_patched = true
	SKS_1.is_vanilla_firearm = false
	SKS_1.object_class = "AssaultRifle"
	SKS_1.__parents[1] = "AssaultRifle"
	SKS_1.ItemType = "AssaultRifle"
	SKS_1.Cost = 1260
	SKS_1.Damage = 26
	SKS_1.ObjDamageMod = 100
	SKS_1.CritChance = 0
	SKS_1.CritChanceScaled = 10
	storeProps(SKS_1, "AimAccuracy", 29, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SKS_1, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SKS_1, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SKS_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	SKS_1.PBbonus_base = 1
	SKS_1.HandlingBaseMul = 105
	SKS_1.PenetrationClass = 1
	SKS_1.ShootAP = 4000
	SKS_1.ReloadAP = 3000
	SKS_1.APStance = 40
	SKS_1.OverwatchAngle = 973
	SKS_1.MagazineSize = 10
	SKS_1.Cumbersome = 0
	SKS_1.Noise = 20
	SKS_1.PointBlankBonus = 1
	SKS_1.PreparedAttackType = "Overwatch"
	SKS_1.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	SKS_1.Rat_swap_ap = 3
	SKS_1.wep_base_recoil_mul = 93
	SKS_1.wep_base_snapshot_mul = 93
	SKS_1.wep_base_hip_mul = 100
	SKS_1.weigth_held_mul = 127
	SKS_1.burst_selective = false
	SKS_1.recoil_mechanism = "Gas_Operated"
	SKS_1.Rat_cycling = "SemiAuto"
	SKS_1.rat_scope_block = false
	SKS_1.pistol_swap = false
	SKS_1.default_long_barrel = false
	SKS_1.unwieldy_weapon = false
	SKS_1.rat_barrel_len = 526
	SKS_1.rat_weigth = 3850
	SKS_1.Weigth = 3850
	SKS_1.ScrapParts = 14
	SKS_1.RepairCost = 80
	SKS_1.Reliability = 87
	SKS_1.LargeItem = 1
	SKS_1.HandSlot = "TwoHanded"
	SKS_1.AdditionalHint = T( 990920247618, [[<description_hints>]] )
	SKS_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'SKS_Bay_fld_1', Modifiable = true, AvailableComponents = {'SKS_Bay_fld_1', 'SKS_Bay_unfld_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_laser_dot', 'RAT_TOG_uv_dot', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'LROptics_DragunovDefault', }}, {CanBeEmpty = false, SlotType = 'Mount', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_compensator', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'SKS_Barrel_def_1', Modifiable = true, AvailableComponents = {'SKS_Barrel_def_1', 'SKS_Barrel_ext_1', }}}
	SKS_1.Valuable = 0
	SKS_1.CanAppearInShop = true
	SKS_1.CanAppearUsed = true
	SKS_1.Tier = 1
	SKS_1.MaxStock = 3
	SKS_1.RestockWeight = 90
	SKS_1.CategoryPair = "AssaultRifles"
	SKS_1.Description = T(522192688036, [[<style PerkststsBold ><scale 700>The SKS is a semi-automatic rifle designed by Soviet small arms designer Sergei Gavrilovich Simonov in 1945.<newline><newline>As the SKS lacked select-fire capability and its magazine was limited to ten rounds, it was rendered obsolete in the Soviet Armed Forces by the introduction of the AK-47 in the 1950s. Nevertheless, SKS carbines continued to see service with the Soviet Border Troops, Internal Troops, and second-line and reserve army units for decades.<newline><newline>Beginning in the 1960s, vast quantities of obsolete and redundant SKS carbines from military reserve stocks were donated by the Soviet Union and China to left-wing guerrilla movements around the world. The increasing ubiquity of the SKS altered the dynamics of asymmetric warfare in developing nations and colonial territories, where most guerrillas had previously been armed with bolt-action rifles<newline><newline>Since 1988, millions have also been sold on the civilian market in North America, where they remain popular as hunting and sporting rifles.<newline><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	SKS_1.PenetrationClass = 1


	STG44R_1.is_tog_patched = true
	STG44R_1.is_vanilla_firearm = false
	STG44R_1.object_class = "AssaultRifle"
	STG44R_1.ItemType = "AssaultRifle"
	STG44R_1.Cost = 1320
	STG44R_1.Damage = 25
	STG44R_1.ObjDamageMod = 100
	STG44R_1.CritChance = 0
	STG44R_1.CritChanceScaled = 10
	storeProps(STG44R_1, "AimAccuracy", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(STG44R_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(STG44R_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(STG44R_1, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	STG44R_1.PBbonus_base = 2
	STG44R_1.HandlingBaseMul = 110
	STG44R_1.PenetrationClass = 1
	STG44R_1.ShootAP = 4000
	STG44R_1.ReloadAP = 3000
	STG44R_1.APStance = 40
	STG44R_1.OverwatchAngle = 1025
	STG44R_1.MagazineSize = 30
	STG44R_1.Cumbersome = 0
	STG44R_1.Noise = 20
	STG44R_1.PointBlankBonus = 1
	STG44R_1.PreparedAttackType = "Overwatch"
	STG44R_1.AvailableAttacks = {"BurstFire", "SingleShot", "AutoFire", "CancelShot"}
	STG44R_1.Rat_swap_ap = 3
	STG44R_1.wep_base_recoil_mul = 90
	STG44R_1.wep_base_snapshot_mul = 106
	STG44R_1.wep_base_hip_mul = 99
	STG44R_1.weigth_held_mul = 135
	STG44R_1.burst_selective = false
	STG44R_1.recoil_mechanism = "Gas_Operated"
	STG44R_1.Rat_cycling = "Auto"
	STG44R_1.rat_scope_block = false
	STG44R_1.pistol_swap = false
	STG44R_1.default_long_barrel = false
	STG44R_1.unwieldy_weapon = false
	STG44R_1.rat_barrel_len = 425
	STG44R_1.rat_weigth = 5000
	STG44R_1.Weigth = 5000
	STG44R_1.ScrapParts = 10
	STG44R_1.RepairCost = 80
	STG44R_1.Reliability = 79
	STG44R_1.LargeItem = 1
	STG44R_1.HandSlot = "TwoHanded"
	STG44R_1.AdditionalHint = T( 587956002848, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> A relic of war]] )
	STG44R_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'STG44_Mag_def_1', Modifiable = true, AvailableComponents = {'STG44_Mag_def_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'STG44_Barrel_def_1', Modifiable = true, AvailableComponents = {'STG44_Barrel_shrt_1', 'STG44_Barrel_def_1', 'STG44_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'STG44_Stock_def_1', Modifiable = true, AvailableComponents = {'STG44_Stock_hvy_1', 'STG44_Stock_def_1', 'STG44_Stock_erg_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'GW43_Scope_1', }}}
	STG44R_1.Valuable = 0
	STG44R_1.CanAppearInShop = true
	STG44R_1.CanAppearUsed = true
	STG44R_1.Tier = 1
	STG44R_1.MaxStock = 1
	STG44R_1.RestockWeight = 40
	STG44R_1.CategoryPair = "AssaultRifles"
	STG44R_1.fxClass = "AK47"
	STG44R_1.Description = T(484150379917, [[<style PerkststsBold ><scale 500>The StG 44 (abbreviation of Sturmgewehr 44, "assault rifle 44") is a German assault rifle developed during World War II by Hugo Schmeisser.<newline><newline>Countries to use the StG 44 after World War II included Czechoslovakia (although it was not officially adopted) and Yugoslavia, where units such as the 63rd Paratroop Battalion were equipped with it until the 1980s, when the rifles were ultimately transferred to Territorial Defense reserves or sold to friendly regimes in the Middle East and Africa. France adopted captured StG 44 for colonial Foreign Legion units.<newline><newline>The StG 44 was the first assault rifle to be accepted into widespread service and put into mass production. At the end of the war, Hugo Schmeisser claimed that 424,000 StG 44 rifles were built between June 1943 and April 1945<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	STG44R_1.PenetrationClass = 1


	A91_2.is_tog_patched = true
	A91_2.is_vanilla_firearm = false
	A91_2.object_class = "AssaultRifle"
	A91_2.Cost = 5300
	A91_2.Damage = 23
	A91_2.CritChance = 0
	A91_2.CritChanceScaled = 10
	storeProps(A91_2, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(A91_2, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(A91_2, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(A91_2, "WeaponRange", 28, "oldCTH", GBO_gCTHModeItemPropertyTable)
	A91_2.PBbonus_base = 3
	A91_2.HandlingBaseMul = 100
	A91_2.PenetrationClass = 1
	A91_2.ShootAP = 4000
	A91_2.ReloadAP = 3000
	A91_2.APStance = 30
	A91_2.OverwatchAngle = 1232
	A91_2.MagazineSize = 30
	A91_2.Cumbersome = 0
	A91_2.Noise = 20
	A91_2.PointBlankBonus = 1
	A91_2.PreparedAttackType = "Overwatch"
	A91_2.AvailableAttacks = {"BurstFire", "SingleShot", "AutoFire", "CancelShot"}
	A91_2.Rat_swap_ap = 3
	A91_2.wep_base_recoil_mul = 98
	A91_2.wep_base_snapshot_mul = 90
	A91_2.wep_base_hip_mul = 100
	A91_2.burst_selective = false
	A91_2.recoil_mechanism = "Gas_Operated"
	A91_2.Rat_cycling = "Auto"
	A91_2.rat_scope_block = false
	A91_2.pistol_swap = false
	A91_2.default_long_barrel = false
	A91_2.unwieldy_weapon = false
	A91_2.Reliability = 83
	A91_2.LargeItem = 1
	A91_2.HandSlot = "TwoHanded"
	A91_2.AdditionalHint = T(836660682051, [[<description_hints>]] )
	A91_2.ComponentSlots = {{Modifiable = false, AvailableComponents = {'bullup'}, SlotType = 'General', DefaultComponent = 'bullup'}, {SlotType = 'Barrel', AvailableComponents = {'A91_762_barrel_shrt_1', 'A91_762_barrel_def_1', 'A91_762_barrel_ext_1'}, DefaultComponent = 'A91_762_barrel_def_1', Modifiable = true}, {SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSightAdvanced', 'ReflexSight', 'ScopeCOGQuick', 'ScopeCOG', 'ThermalScope', 'RAT_TOG_vigilanceRS', 'RAT_TOG_WideScope', 'DefaultIronsight_AR15'}, DefaultComponent = 'DefaultIronsight_AR15'}, {Modifiable = false, SlotType = 'Muzzle', AvailableComponents = {'ToG_VFX_Muzzle'}, DefaultComponent = 'ToG_VFX_Muzzle'}, {Modifiable = true, AvailableComponents = {'RAT_TOG_CompensatorNoEntity'}, SlotType = 'Gassblock', DefaultComponent = 'RAT_TOG_CompensatorNoEntity'}, {SlotType = 'Magazine', AvailableComponents = {'A91_762_mag_def_1', 'A91_762_mag_ext_1'}, DefaultComponent = 'A91_762_mag_def_1', Modifiable = true}, {Modifiable = true, AvailableComponents = {'A91_GrenadeLauncher'}, SlotType = 'Under' ,CanBeEmpty = true}}
	A91_2.CanAppearInShop = true
	A91_2.CanAppearUsed = true
	A91_2.Tier = 2
	A91_2.MaxStock = 3
	A91_2.RestockWeight = 40
	A91_2.CategoryPair = "AssaultRifles"
	A91_2.Description = T(832950361147, [[<style PerkststsBold ><scale 450>The A-91 is a bullpup assault rifle developed during the 1990s as an offspring of the 9A-91 firearm family.<newline><newline>The A-91 has a forward ejection system, initially developed in Tula by designers like Afanasiev during the early 1960s. In this system, the ejection port is located right above the pistol grip, and is directed forward. Extracted cases go from bolt head through the short ejection tube to the ejection port, and fall out of the gun well clear of the shooter's face, even when firing from the left shoulder.<newline><newline> As for now, the A-91 is made in small numbers and, probably, is used by some elite police units in Russia<newline><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	A91_2.PenetrationClass = 1


	Type56A_1.is_tog_patched = true
	Type56A_1.is_vanilla_firearm = false
	Type56A_1.object_class = "AssaultRifle"
	Type56A_1.__parents[1] = "AssaultRifle"
	Type56A_1.ItemType = "AssaultRifle"
	Type56A_1.Cost = 1560
	Type56A_1.Damage = 26
	Type56A_1.ObjDamageMod = 100
	Type56A_1.CritChance = 0
	Type56A_1.CritChanceScaled = 10
	storeProps(Type56A_1, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56A_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56A_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56A_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Type56A_1.PBbonus_base = 5
	Type56A_1.HandlingBaseMul = 105
	Type56A_1.PenetrationClass = 1
	Type56A_1.ShootAP = 4000
	Type56A_1.ReloadAP = 3000
	Type56A_1.APStance = 40
	Type56A_1.OverwatchAngle = 994
	Type56A_1.MagazineSize = 10
	Type56A_1.Cumbersome = 0
	Type56A_1.Noise = 22
	Type56A_1.PointBlankBonus = 1
	Type56A_1.PreparedAttackType = "Overwatch"
	Type56A_1.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	Type56A_1.Rat_swap_ap = 3
	Type56A_1.wep_base_snapshot_mul = 93
	Type56A_1.wep_base_hip_mul = 105
	Type56A_1.burst_selective = false
	Type56A_1.recoil_mechanism = "Gas_Operated"
	Type56A_1.Rat_cycling = "SemiAuto"
	Type56A_1.rat_scope_block = false
	Type56A_1.pistol_swap = false
	Type56A_1.default_long_barrel = false
	Type56A_1.unwieldy_weapon = false
	Type56A_1.ScrapParts = 14
	Type56A_1.RepairCost = 30
	Type56A_1.Reliability = 89
	Type56A_1.LargeItem = 1
	Type56A_1.HandSlot = "TwoHanded"
	Type56A_1.AdditionalHint = T( 360259104299, [[<description_hints>]] )
	Type56A_1.ComponentSlots = {
        {
            CanBeEmpty = false,
            SlotType = 'Bipod',
            DefaultComponent = 'Type56A_Bay_fld_1',
            Modifiable = true,
            AvailableComponents = {'Type56A_Bay_fld_1', 'Type56A_Bay_unfld_1'}
        }, {
            CanBeEmpty = true,
            SlotType = 'Scope',
            Modifiable = true,
            AvailableComponents = {
                'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism',
                'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_laser_dot', 'RAT_TOG_uv_dot',
                'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'LROptics_DragunovDefault'
            }
        }, {
            CanBeEmpty = false,
            SlotType = 'General',
            DefaultComponent = 'Type56A_Bolt_1',
            Modifiable = false,
            AvailableComponents = {
                'Papovka2_Bolt_1', 'Papovka_Bolt_1', 'Type56A_Bolt_1', 'Type56B_Bolt_1',
                'Type56C_Bolt_1', 'Type56D_Bolt_1'
            }
        }, {CanBeEmpty = false, SlotType = 'Mount', Modifiable = false, AvailableComponents = {}},
        {
            CanBeEmpty = false,
            SlotType = 'Muzzle',
            DefaultComponent = 'ToG_VFX_Muzzle',
            Modifiable = true,
            AvailableComponents = {'RAT_TOG_compensator', 'ToG_VFX_Muzzle'}
        }, {
            CanBeEmpty = false,
            SlotType = 'Barrel',
            DefaultComponent = 'Type56A_Barrel_def_1',
            Modifiable = true,
            AvailableComponents = {
                'Type56A_Barrel_shrt_1', 'Type56A_Barrel_def_1', 'Type56A_Barrel_ext_1'
            }
        }, {
            CanBeEmpty = false,
            SlotType = 'Stock',
            DefaultComponent = 'Type56A_stock_def_1',
            Modifiable = true,
            AvailableComponents = {
                'Type56A_stock_erg_1', 'Type56A_stock_def_1', 'Type56A_stock_hvy_1'
            }
        }, {
            CanBeEmpty = false,
            SlotType = 'Magazine',
            DefaultComponent = 'Type56A_Mag_def_1',
            Modifiable = true,
            AvailableComponents = {'Papovka_Mag_ext_1', 'Type56A_Mag_def_1'}
        }
    }
	Type56A_1.Valuable = 0
	Type56A_1.CanAppearInShop = true
	Type56A_1.CanAppearUsed = true
	Type56A_1.Tier = 1
	Type56A_1.MaxStock = 1
	Type56A_1.RestockWeight = 10
	Type56A_1.CategoryPair = "AssaultRifles"
	Type56A_1.Description = T(596990177362, [[<style PerkststsBold ><scale 700>The Type 56 is a cold-war era Chinese SKS derivate, chambered in 7.62x39R.<newline><newline>Factory workers skillfully produced the SKS with the help of their Soviet advisors, and the Chinese military adopted the SKS as the Type 56 in 1956. Chinese factories made changes over the lifetime of the SKS's production to simplify manufacturing and increase efficiency. One notable shift in production was the introduction of a stamped trigger guard.<newline><newline> China continued to produce the Type 56 for many years even after adopting an AK47 variant for its own front line military use. As crucial as the Type 56 was for the Chinese military, the Type 56 became even more vital for export. Just as the Soviet Union gave and sold military equipment to sympathetic nations and groups, China did the same sending Type 56s around the world, from Vietnam to Africa and all points in between.<newline><newline><style MMOptionEntry>Made in China <image Mod/HXzCpFa/Icons/Flags/China.png 1600>]])
	Type56A_1.PenetrationClass = 1


	Type56B_1.is_tog_patched = true
	Type56B_1.is_vanilla_firearm = false
	Type56B_1.object_class = "AssaultRifle"
	Type56B_1.__parents[1] = "AssaultRifle"
	Type56B_1.ItemType = "AssaultRifle"
	Type56B_1.Cost = 1560
	Type56B_1.Damage = 26
	Type56B_1.ObjDamageMod = 100
	Type56B_1.CritChance = 0
	Type56B_1.CritChanceScaled = 10
	storeProps(Type56B_1, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56B_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56B_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56B_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Type56B_1.PBbonus_base = 5
	Type56B_1.HandlingBaseMul = 105
	Type56B_1.PenetrationClass = 1
	Type56B_1.ShootAP = 4000
	Type56B_1.ReloadAP = 3000
	Type56B_1.APStance = 40
	Type56B_1.OverwatchAngle = 994
	Type56B_1.MagazineSize = 10
	Type56B_1.Cumbersome = 0
	Type56B_1.Noise = 22
	Type56B_1.PointBlankBonus = 1
	Type56B_1.PreparedAttackType = "Overwatch"
	Type56B_1.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	Type56B_1.Rat_swap_ap = 3
	Type56B_1.wep_base_snapshot_mul = 93
	Type56B_1.wep_base_hip_mul = 105
	Type56B_1.burst_selective = false
	Type56B_1.recoil_mechanism = "Gas_Operated"
	Type56B_1.Rat_cycling = "SemiAuto"
	Type56B_1.rat_scope_block = false
	Type56B_1.pistol_swap = false
	Type56B_1.default_long_barrel = false
	Type56B_1.unwieldy_weapon = false
	Type56B_1.ScrapParts = 14
	Type56B_1.RepairCost = 30
	Type56B_1.Reliability = 89
	Type56B_1.LargeItem = 1
	Type56B_1.HandSlot = "TwoHanded"
	Type56B_1.AdditionalHint = T( 975770966024, [[<description_hints>]] )
	Type56B_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Type56B_Bay_fld_1', Modifiable = true, AvailableComponents = {'Type56B_Bay_fld_1', 'Type56B_Bay_unfld_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_laser_dot', 'RAT_TOG_uv_dot', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'LROptics_DragunovDefault', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Type56B_Bolt_1', Modifiable = false, AvailableComponents = {'Papovka2_Bolt_1', 'Papovka_Bolt_1', 'Type56A_Bolt_1', 'Type56B_Bolt_1', 'Type56C_Bolt_1', 'Type56D_Bolt_1', }}, {CanBeEmpty = false, SlotType = 'Mount', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true,             AvailableComponents = {'RAT_TOG_compensator', 'ToG_VFX_Muzzle'}}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Type56B_Barrel_def_1', Modifiable = true, AvailableComponents = {'Type56B_Barrel_shrt_1', 'Type56B_Barrel_def_1', 'Type56B_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'Type56B_stock_def_1', Modifiable = true, AvailableComponents = {'Type56B_stock_erg_1', 'Type56B_stock_def_1', 'Type56B_stock_hvy_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'Type56B_Mag_def_1', Modifiable = true, AvailableComponents = {'Papovka_Mag_ext_1', 'Type56B_Mag_def_1', }}}
	Type56B_1.Valuable = 0
	Type56B_1.CanAppearInShop = true
	Type56B_1.CanAppearUsed = true
	Type56B_1.Tier = 1
	Type56B_1.MaxStock = 1
	Type56B_1.RestockWeight = 10
	Type56B_1.CategoryPair = "AssaultRifles"
	Type56B_1.Description = T(257661389059, [[<style PerkststsBold ><scale 700>The Type 56 is a cold-war era Chinese SKS derivate, chambered in 7.62x39R.<newline><newline>Factory workers skillfully produced the SKS with the help of their Soviet advisors, and the Chinese military adopted the SKS as the Type 56 in 1956. Chinese factories made changes over the lifetime of the SKS's production to simplify manufacturing and increase efficiency. One notable shift in production was the introduction of a stamped trigger guard.<newline><newline> China continued to produce the Type 56 for many years even after adopting an AK47 variant for its own front line military use. As crucial as the Type 56 was for the Chinese military, the Type 56 became even more vital for export. Just as the Soviet Union gave and sold military equipment to sympathetic nations and groups, China did the same sending Type 56s around the world, from Vietnam to Africa and all points in between.<newline><newline><style MMOptionEntry>Made in China <image Mod/HXzCpFa/Icons/Flags/China.png 1600>]])
	Type56B_1.PenetrationClass = 1


	Type56C_1.is_tog_patched = true
	Type56C_1.is_vanilla_firearm = false
	Type56C_1.object_class = "AssaultRifle"
	Type56C_1.__parents[1] = "AssaultRifle"
	Type56C_1.ItemType = "AssaultRifle"
	Type56C_1.Cost = 1560
	Type56C_1.Damage = 26
	Type56C_1.ObjDamageMod = 100
	Type56C_1.CritChance = 0
	Type56C_1.CritChanceScaled = 10
	storeProps(Type56C_1, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56C_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56C_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56C_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Type56C_1.PBbonus_base = 5
	Type56C_1.HandlingBaseMul = 105
	Type56C_1.PenetrationClass = 1
	Type56C_1.ShootAP = 4000
	Type56C_1.ReloadAP = 3000
	Type56C_1.APStance = 40
	Type56C_1.OverwatchAngle = 994
	Type56C_1.MagazineSize = 10
	Type56C_1.Cumbersome = 0
	Type56C_1.Noise = 22
	Type56C_1.PointBlankBonus = 1
	Type56C_1.PreparedAttackType = "Overwatch"
	Type56C_1.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	Type56C_1.Rat_swap_ap = 3
	Type56C_1.wep_base_snapshot_mul = 93
	Type56C_1.wep_base_hip_mul = 105
	Type56C_1.burst_selective = false
	Type56C_1.recoil_mechanism = "Gas_Operated"
	Type56C_1.Rat_cycling = "SemiAuto"
	Type56C_1.rat_scope_block = false
	Type56C_1.pistol_swap = false
	Type56C_1.default_long_barrel = false
	Type56C_1.unwieldy_weapon = false
	Type56C_1.ScrapParts = 14
	Type56C_1.RepairCost = 30
	Type56C_1.Reliability = 89
	Type56C_1.LargeItem = 1
	Type56C_1.HandSlot = "TwoHanded"
	Type56C_1.AdditionalHint = T( 196297267299, [[<description_hints>]] )
	Type56C_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Type56C_Bay_fld_1', Modifiable = true, AvailableComponents = {'Type56C_Bay_fld_1', 'Type56C_Bay_unfld_1', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Type56C_Bolt_1', Modifiable = false, AvailableComponents = {'Papovka2_Bolt_1', 'Papovka_Bolt_1', 'Type56A_Bolt_1', 'Type56B_Bolt_1', 'Type56C_Bolt_1', 'Type56D_Bolt_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_laser_dot', 'RAT_TOG_uv_dot', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'LROptics_DragunovDefault', }}, {CanBeEmpty = false, SlotType = 'Mount', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_compensator', 'ToG_VFX_Muzzle'}}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Type56C_Barrel_def_1', Modifiable = true, AvailableComponents = {'Type56C_Barrel_shrt_1', 'Type56C_Barrel_def_1', 'Type56C_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'Type56C_stock_def_1', Modifiable = true, AvailableComponents = {'Type56C_stock_erg_1', 'Type56C_stock_def_1', 'Type56C_stock_hvy_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'Type56C_Mag_def_1', Modifiable = true, AvailableComponents = {'Papovka_Mag_ext_1', 'Type56C_Mag_def_1', }}}
	Type56C_1.Valuable = 0
	Type56C_1.CanAppearInShop = true
	Type56C_1.CanAppearUsed = true
	Type56C_1.Tier = 1
	Type56C_1.MaxStock = 1
	Type56C_1.RestockWeight = 10
	Type56C_1.CategoryPair = "AssaultRifles"
	Type56C_1.Description = T(401244908096, [[<style PerkststsBold ><scale 700>The Type 56 is a cold-war era Chinese SKS derivate, chambered in 7.62x39R.<newline><newline>Factory workers skillfully produced the SKS with the help of their Soviet advisors, and the Chinese military adopted the SKS as the Type 56 in 1956. Chinese factories made changes over the lifetime of the SKS's production to simplify manufacturing and increase efficiency. One notable shift in production was the introduction of a stamped trigger guard.<newline><newline> China continued to produce the Type 56 for many years even after adopting an AK47 variant for its own front line military use. As crucial as the Type 56 was for the Chinese military, the Type 56 became even more vital for export. Just as the Soviet Union gave and sold military equipment to sympathetic nations and groups, China did the same sending Type 56s around the world, from Vietnam to Africa and all points in between.<newline><newline><style MMOptionEntry>Made in China <image Mod/HXzCpFa/Icons/Flags/China.png 1600>]])
	Type56C_1.PenetrationClass = 1


	Type56D_1.is_tog_patched = true
	Type56D_1.is_vanilla_firearm = false
	Type56D_1.object_class = "AssaultRifle"
	Type56D_1.__parents[1] = "AssaultRifle"
	Type56D_1.ItemType = "AssaultRifle"
	Type56D_1.Cost = 1560
	Type56D_1.Damage = 26
	Type56D_1.ObjDamageMod = 100
	Type56D_1.CritChance = 0
	Type56D_1.CritChanceScaled = 10
	storeProps(Type56D_1, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56D_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56D_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Type56D_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Type56D_1.PBbonus_base = 5
	Type56D_1.HandlingBaseMul = 105
	Type56D_1.PenetrationClass = 1
	Type56D_1.ShootAP = 4000
	Type56D_1.ReloadAP = 3000
	Type56D_1.APStance = 40
	Type56D_1.OverwatchAngle = 994
	Type56D_1.MagazineSize = 10
	Type56D_1.Cumbersome = 0
	Type56D_1.Noise = 22
	Type56D_1.PointBlankBonus = 1
	Type56D_1.PreparedAttackType = "Overwatch"
	Type56D_1.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
	Type56D_1.Rat_swap_ap = 3
	Type56D_1.wep_base_snapshot_mul = 93
	Type56D_1.wep_base_hip_mul = 105
	Type56D_1.burst_selective = false
	Type56D_1.recoil_mechanism = "Gas_Operated"
	Type56D_1.Rat_cycling = "SemiAuto"
	Type56D_1.rat_scope_block = false
	Type56D_1.pistol_swap = false
	Type56D_1.default_long_barrel = false
	Type56D_1.unwieldy_weapon = false
	Type56D_1.ScrapParts = 14
	Type56D_1.RepairCost = 30
	Type56D_1.Reliability = 89
	Type56D_1.LargeItem = 1
	Type56D_1.HandSlot = "TwoHanded"
	Type56D_1.AdditionalHint = T( 363064227137, [[<description_hints>]] )
	Type56D_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'Type56D_Bay_fld_1', Modifiable = true, AvailableComponents = {'Type56D_Bay_fld_1', 'Type56D_Bay_unfld_1', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Type56D_Bolt_1', Modifiable = false, AvailableComponents = {'Papovka2_Bolt_1', 'Papovka_Bolt_1', 'Type56A_Bolt_1', 'Type56B_Bolt_1', 'Type56C_Bolt_1', 'Type56D_Bolt_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_Prism', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_laser_dot', 'RAT_TOG_uv_dot', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'LROptics_DragunovDefault', }}, {CanBeEmpty = false, SlotType = 'Mount', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_compensator', 'RAT_TOG_suppressor', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Type56D_Barrel_def_1', Modifiable = true, AvailableComponents = {'Type56D_Barrel_shrt_1', 'Type56D_Barrel_def_1', 'Type56D_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'Type56D_stock_def_1', Modifiable = true, AvailableComponents = {'Type56D_stock_erg_1', 'Type56D_stock_def_1', 'Type56D_stock_hvy_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'Type56D_Mag_def_1', Modifiable = true, AvailableComponents = {'Papovka_Mag_ext_1', 'Type56D_Mag_def_1', }}}
	Type56D_1.Valuable = 0
	Type56D_1.CanAppearInShop = false
	Type56D_1.CanAppearUsed = true
	Type56D_1.Tier = 1
	Type56D_1.MaxStock = 3
	Type56D_1.RestockWeight = 100
	Type56D_1.CategoryPair = "AssaultRifles"
	Type56D_1.Description = T(921319479641, [[<style PerkststsBold ><scale 700>The Type 56 is a cold-war era Chinese SKS derivate, chambered in 7.62x39R.<newline><newline>Factory workers skillfully produced the SKS with the help of their Soviet advisors, and the Chinese military adopted the SKS as the Type 56 in 1956. Chinese factories made changes over the lifetime of the SKS's production to simplify manufacturing and increase efficiency. One notable shift in production was the introduction of a stamped trigger guard.<newline><newline> China continued to produce the Type 56 for many years even after adopting an AK47 variant for its own front line military use. As crucial as the Type 56 was for the Chinese military, the Type 56 became even more vital for export. Just as the Soviet Union gave and sold military equipment to sympathetic nations and groups, China did the same sending Type 56s around the world, from Vietnam to Africa and all points in between.<newline><newline><style MMOptionEntry>Made in China <image Mod/HXzCpFa/Icons/Flags/China.png 1600>]])
	Type56D_1.PenetrationClass = 1


	M79SAW_1.is_tog_patched = true
	M79SAW_1.is_vanilla_firearm = false
	M79SAW_1.object_class = "GrenadeLauncher"
	M79SAW_1.Cost = 2400
	M79SAW_1.HandlingBaseMul = 100
	M79SAW_1.burst_selective = false
	M79SAW_1.rat_scope_block = false
	M79SAW_1.pistol_swap = false
	M79SAW_1.default_long_barrel = false
	M79SAW_1.unwieldy_weapon = false
	M79SAW_1.ScrapParts = 16
	M79SAW_1.RepairCost = 80
	M79SAW_1.Reliability = 96
	M79SAW_1.AdditionalHint = T( 309537575554, [[<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Shoots 40mm Grenades
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Mishap chance increased with distance
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Slow rate of Fire]] )
	M79SAW_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = false, AvailableComponents = {'ToG_VFX_Muzzle', }}}
	M79SAW_1.Valuable = 0
	M79SAW_1.CanAppearInShop = false
	M79SAW_1.CanAppearUsed = true
	M79SAW_1.Tier = 2
	M79SAW_1.MaxStock = 2
	M79SAW_1.RestockWeight = 75
	M79SAW_1.CategoryPair = "HeavyWeapons"
	M79SAW_1.fxClass = "UnderslungGrenadeLauncher"
	M79SAW_1.Description = T(937706780893, [[<style PerkststsBold ><scale 900>The M79 grenade launcher is a single-shot, shoulder-fired, break-action grenade launcher that fires a 40×46mm grenade<newline><newline>It can fire a wide variety of 40 mm rounds, including explosive, anti-personnel, smoke, buckshot, flechette (pointed steel projectiles with a vaned tail for stable flight), and illumination. While largely replaced by the M203, the M79 has remained in service in many units worldwide in niche roles.<newline><newline>In 1961, the first M79 grenade launchers were delivered to the US Army. Owing to its ease of use, reliability, and firepower, the M79 became popular among American soldiers, who dubbed it "the platoon leader's artillery".<newline><newline><style MMOptionEntry>Made in USA <image UI/Icons/Flags/f_usa.dds 1600>]])
	M79SAW_1.PenetrationClass = 1


	M79SAW2_1.is_tog_patched = true
	M79SAW2_1.is_vanilla_firearm = false
	M79SAW2_1.object_class = "GrenadeLauncher"
	M79SAW2_1.Cost = 2400
	M79SAW2_1.HandlingBaseMul = 100
	M79SAW2_1.burst_selective = false
	M79SAW2_1.rat_scope_block = false
	M79SAW2_1.pistol_swap = false
	M79SAW2_1.default_long_barrel = false
	M79SAW2_1.unwieldy_weapon = false
	M79SAW2_1.ScrapParts = 16
	M79SAW2_1.RepairCost = 80
	M79SAW2_1.Reliability = 96
	M79SAW2_1.AdditionalHint = T( 455509044395, [[<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Shoots 40mm Grenades
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Mishap chance increased with distance
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Slow rate of Fire]] )
	M79SAW2_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = false, AvailableComponents = {'ToG_VFX_Muzzle', }}}
	M79SAW2_1.Valuable = 0
	M79SAW2_1.CanAppearInShop = true
	M79SAW2_1.CanAppearUsed = true
	M79SAW2_1.Tier = 2
	M79SAW2_1.MaxStock = 2
	M79SAW2_1.RestockWeight = 40
	M79SAW2_1.CategoryPair = "HeavyWeapons"
	M79SAW2_1.fxClass = "UnderslungGrenadeLauncher"
	M79SAW2_1.Description = T(296206496671, [[<style PerkststsBold ><scale 900>The M79 grenade launcher is a single-shot, shoulder-fired, break-action grenade launcher that fires a 40×46mm grenade<newline><newline>It can fire a wide variety of 40 mm rounds, including explosive, anti-personnel, smoke, buckshot, flechette (pointed steel projectiles with a vaned tail for stable flight), and illumination. While largely replaced by the M203, the M79 has remained in service in many units worldwide in niche roles.<newline><newline>In 1961, the first M79 grenade launchers were delivered to the US Army. Owing to its ease of use, reliability, and firepower, the M79 became popular among American soldiers, who dubbed it "the platoon leader's artillery".<newline><newline><style MMOptionEntry>Made in USA <image UI/Icons/Flags/f_usa.dds 1600>]])
	M79SAW2_1.PenetrationClass = 1


	PKM_1.is_tog_patched = true
	PKM_1.is_vanilla_firearm = false
	PKM_1.object_class = "RPK74"
	PKM_1.ItemType = "MachineGun"
	PKM_1.Cost = 7200
	PKM_1.Damage = 32
	PKM_1.ObjDamageMod = 100
	PKM_1.CritChance = 0
	PKM_1.CritChanceScaled = 10
	storeProps(PKM_1, "AimAccuracy", 29, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PKM_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PKM_1, "WeaponRange", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PKM_1, "WeaponRange", 42, "oldCTH", GBO_gCTHModeItemPropertyTable)
	PKM_1.PBbonus_base = -4
	PKM_1.HandlingBaseMul = 120
	PKM_1.HandlingNotProneMul = 200
	PKM_1.PenetrationClass = 1
	PKM_1.ShootAP = 4000
	PKM_1.ReloadAP = 5000
	PKM_1.APStance = 45
	PKM_1.OverwatchAngle = 583
	PKM_1.MagazineSize = 100
	PKM_1.Cumbersome = 1
	PKM_1.Noise = 20
	PKM_1.PointBlankBonus = 1
	PKM_1.PreparedAttackType = "Overwatch"
	PKM_1.AvailableAttacks = {"MGBurstFire"}
	PKM_1.wep_base_recoil_mul = 75
	PKM_1.wep_base_snapshot_mul = 127
	PKM_1.weigth_held_mul = 157
	PKM_1.burst_selective = false
	PKM_1.recoil_mechanism = "Gas_Operated"
	PKM_1.Rat_cycling = "Auto"
	PKM_1.rat_scope_block = false
	PKM_1.pistol_swap = false
	PKM_1.default_long_barrel = false
	PKM_1.unwieldy_weapon = false
	PKM_1.rat_barrel_len = 575
	PKM_1.rat_weigth = 8000
	PKM_1.Weigth = 8000
	PKM_1.RepairCost = 80
	PKM_1.Reliability = 88
	PKM_1.LargeItem = 1
	PKM_1.HandSlot = "TwoHanded"
	PKM_1.AdditionalHint = T( 921786310095, [[<description_hints>]] )
	PKM_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelNormalImproved', 'R_TOG_light_barrel', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = false, AvailableComponents = {'MagNormal', 'MagNormalFine', 'MagQuick', 'MagLarge', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ScopeCOG', 'ThermalScope', 'LROpticsAdvanced', 'ScopeCOGQuick', 'ReflexSightAdvanced', 'WideScope', '_ReflexSIghtVigilance', }}, {DefaultComponent = 'RAT_TOG_compensator', CanBeEmpty = false, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_compensator' }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNormal', Modifiable = false, AvailableComponents = {'StockNormal', }}, {CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'PKM_Bipod_Fold_1', Modifiable = true, AvailableComponents = {'PKM_Bipod_Fold_1', }}}
	PKM_1.Valuable = 0
	PKM_1.CanAppearInShop = true
	PKM_1.CanAppearUsed = true
	PKM_1.Tier = 1
	PKM_1.MaxStock = 3
	PKM_1.RestockWeight = 40
	PKM_1.CategoryPair = "MachineGuns"
	PKM_1.Description = T(389126554458, [[<style PerkststsBold ><scale 600>The PKM is a belt-fed general-purpose machine gun, chambered for the 7.62×54mmR rimmed cartridge.<newline><newline>Designed in the Soviet Union and currently in production in Russia, the original PK machine gun was introduced in 1961 and the improved PKM variant was introduced in 1969.<newline><newline>Unlike the AKM and RPK the PK machine gun series is an open bolt design, which improves heat management during automatic fire compared to closed bolt designs and helps avoiding the dangerous phenomenon known as "cook-off"<newline><newline><style ConversationChoiceNormalRollover ><scale  900>Designed by Mikhail Kalashnikov<newline><image Mod/KKh3Yhf/Images/KalashnikovM_icon(mil.ru).png 1000><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	PKM_1.PenetrationClass = 1


	HK23E_1.is_tog_patched = true
	HK23E_1.is_vanilla_firearm = false
	HK23E_1.object_class = "MachineGun"
	HK23E_1.Cost = 10950
	HK23E_1.Damage = 24
	HK23E_1.ObjDamageMod = 100
	HK23E_1.CritChance = 0
	HK23E_1.CritChanceScaled = 10
	storeProps(HK23E_1, "AimAccuracy", 27, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK23E_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK23E_1, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK23E_1, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	HK23E_1.PBbonus_base = -1
	HK23E_1.HandlingBaseMul = 116
	HK23E_1.HandlingNotProneMul = 220
	HK23E_1.PenetrationClass = 1
	HK23E_1.ShootAP = 4000
	HK23E_1.ReloadAP = 5000
	HK23E_1.APStance = 45
	HK23E_1.OverwatchAngle = 736
	HK23E_1.MagazineSize = 100
	HK23E_1.Cumbersome = 1
	HK23E_1.Noise = 20
	HK23E_1.PointBlankBonus = 1
	HK23E_1.PreparedAttackType = "Machine Gun"
	HK23E_1.AvailableAttacks = {"MGBurstFire"}
	HK23E_1.Rat_swap_ap = 3
	HK23E_1.wep_base_recoil_mul = 85
	HK23E_1.wep_base_snapshot_mul = 128
	HK23E_1.wep_base_hip_mul = 97
	HK23E_1.weigth_held_mul = 162
	HK23E_1.burst_selective = false
	HK23E_1.recoil_mechanism = "Roller_Delayed"
	HK23E_1.Rat_cycling = "Auto"
	HK23E_1.rat_scope_block = false
	HK23E_1.pistol_swap = false
	HK23E_1.default_long_barrel = false
	HK23E_1.unwieldy_weapon = false
	HK23E_1.rat_barrel_len = 450
	HK23E_1.rat_weigth = 8750
	HK23E_1.Weigth = 8750
	HK23E_1.ScrapParts = 16
	HK23E_1.RepairCost = 80
	HK23E_1.Reliability = 83
	HK23E_1.LargeItem = 1
	HK23E_1.HandSlot = "TwoHanded"
	HK23E_1.AdditionalHint = T( 390378831477, [[<description_hints>]] )
	HK23E_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'hk23e_barrel_def_1', Modifiable = true, AvailableComponents = {'hk23e_barrel_shrt_1', 'hk23e_barrel_def_1', 'hk23e_barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'hk23e_muzzle_1', Modifiable = true, AvailableComponents = {'hk23e_muzzle_1', 'MuzzleBooster', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_PSGScope', 'RAT_TOG_LRoptics_advanced', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'hk23e_stock_def_1', Modifiable = true, AvailableComponents = {'hk23e_stock_hvy_1', 'hk23e_stock_def_1', 'hk23e_stock_erg_1', }}, {CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'hk23e_bipod_fld_1', Modifiable = true, AvailableComponents = {'hk23e_bipod_fld_1', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Mountside', DefaultComponent = 'hk23e_siderail_1', Modifiable = true, AvailableComponents = {'hk23e_siderail_1', }}, {CanBeEmpty = false, SlotType = 'Mountfront', DefaultComponent = 'hk23e_handle_fld_1', Modifiable = false, AvailableComponents = {'hk23e_handle_fld_1', 'hk23e_handle_unfld_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'hk23e_mag_1', Modifiable = true, AvailableComponents = {'hk23e_mag_1', }}}
	HK23E_1.Valuable = 1
	HK23E_1.CanAppearInShop = true
	HK23E_1.CanAppearUsed = true
	HK23E_1.Tier = 3
	HK23E_1.MaxStock = 1
	HK23E_1.RestockWeight = 35
	HK23E_1.CategoryPair = "MachineGuns"
	HK23E_1.Description = T(946262450526, [[<style PerkststsBold ><scale 600>The HK23 is a West German 5.56×45mm NATO light machine gun.<newline><newline>The HK23 was developed in 1972. The purpose of this gun was to compete with various small calibre guns of the time. The main purpose of the gun was to export to foreign markets instead of special development for the German Bundeswehr and German law enforcement agencies. Ten years later, in order to participate in the U.S. military's automatic class weapon campaign, the HK23E participated in the election under the name of XM262, but eventually lost to the M249 SAW<newline><newline>Although the 5.56 NATO HK23E didn't enjoy the same level widespread success as its big brother in 7.62mm NATO - similar to the HK33 vs. the G3 - it did see service with multiple countries, and a few of them are still around in the hands of private collectors as well.<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	HK23E_1.PenetrationClass = 1


	HK23ECamo_1.is_tog_patched = true
	HK23ECamo_1.is_vanilla_firearm = false
	HK23ECamo_1.object_class = "MachineGun"
	HK23ECamo_1.Cost = 10950
	HK23ECamo_1.Damage = 24
	HK23ECamo_1.ObjDamageMod = 100
	HK23ECamo_1.CritChance = 0
	HK23ECamo_1.CritChanceScaled = 10
	storeProps(HK23ECamo_1, "AimAccuracy", 27, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK23ECamo_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK23ECamo_1, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK23ECamo_1, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	HK23ECamo_1.PBbonus_base = -1
	HK23ECamo_1.HandlingBaseMul = 116
	HK23ECamo_1.HandlingNotProneMul = 220
	HK23ECamo_1.PenetrationClass = 1
	HK23ECamo_1.ShootAP = 4000
	HK23ECamo_1.ReloadAP = 5000
	HK23ECamo_1.APStance = 45
	HK23ECamo_1.OverwatchAngle = 736
	HK23ECamo_1.MagazineSize = 100
	HK23ECamo_1.Cumbersome = 1
	HK23ECamo_1.Noise = 20
	HK23ECamo_1.PointBlankBonus = 1
	HK23ECamo_1.PreparedAttackType = "Machine Gun"
	HK23ECamo_1.AvailableAttacks = {"MGBurstFire"}
	HK23ECamo_1.Rat_swap_ap = 3
	HK23ECamo_1.wep_base_recoil_mul = 85
	HK23ECamo_1.wep_base_snapshot_mul = 128
	HK23ECamo_1.wep_base_hip_mul = 97
	HK23ECamo_1.weigth_held_mul = 162
	HK23ECamo_1.burst_selective = false
	HK23ECamo_1.recoil_mechanism = "Roller_Delayed"
	HK23ECamo_1.Rat_cycling = "Auto"
	HK23ECamo_1.rat_scope_block = false
	HK23ECamo_1.pistol_swap = false
	HK23ECamo_1.default_long_barrel = false
	HK23ECamo_1.unwieldy_weapon = false
	HK23ECamo_1.rat_barrel_len = 450
	HK23ECamo_1.rat_weigth = 8750
	HK23ECamo_1.Weigth = 8750
	HK23ECamo_1.ScrapParts = 16
	HK23ECamo_1.RepairCost = 80
	HK23ECamo_1.Reliability = 83
	HK23ECamo_1.LargeItem = 1
	HK23ECamo_1.HandSlot = "TwoHanded"
	HK23ECamo_1.AdditionalHint = T( 230948710696, [[<description_hints>]] )
	HK23ECamo_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'hk23e_barrel_def_1', Modifiable = true, AvailableComponents = {'hk23e_barrel_shrt_1', 'hk23e_barrel_def_1', 'hk23e_barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'hk23e_muzzle_1', Modifiable = true, AvailableComponents = {'hk23e_muzzle_1', 'MuzzleBooster'}}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_PSGScope', 'RAT_TOG_LRoptics_advanced', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'hk23e_stock_def_1', Modifiable = true, AvailableComponents = {'hk23e_stock_hvy_1', 'hk23e_stock_def_1', 'hk23e_stock_erg_1', }}, {CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'hk23e_bipod_fld_1', Modifiable = true, AvailableComponents = {'hk23e_bipod_fld_1', }}, {CanBeEmpty = true, SlotType = 'Under', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'Mountside', DefaultComponent = 'hk23e_siderail_1', Modifiable = true, AvailableComponents = {'hk23e_siderail_1', }}, {CanBeEmpty = false, SlotType = 'Mountfront', DefaultComponent = 'hk23e_handle_fld_1', Modifiable = false, AvailableComponents = {'hk23e_handle_fld_1', 'hk23e_handle_unfld_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'hk23e_mag_1', Modifiable = true, AvailableComponents = {'hk23e_mag_1', }}}
	HK23ECamo_1.Valuable = 1
	HK23ECamo_1.CanAppearInShop = false
	HK23ECamo_1.CanAppearUsed = true
	HK23ECamo_1.Tier = 3
	HK23ECamo_1.MaxStock = 1
	HK23ECamo_1.RestockWeight = 30
	HK23ECamo_1.CategoryPair = "MachineGuns"
	HK23ECamo_1.Description = T(483613388445, [[<style PerkststsBold ><scale 600>The HK23 is a West German 5.56×45mm NATO light machine gun.<newline><newline>The HK23 was developed in 1972. The purpose of this gun was to compete with various small calibre guns of the time. The main purpose of the gun was to export to foreign markets instead of special development for the German Bundeswehr and German law enforcement agencies. Ten years later, in order to participate in the U.S. military's automatic class weapon campaign, the HK23E participated in the election under the name of XM262, but eventually lost to the M249 SAW<newline><newline>Although the 5.56 NATO HK23E didn't enjoy the same level widespread success as its big brother in 7.62mm NATO - similar to the HK33 vs. the G3 - it did see service with multiple countries, and a few of them are still around in the hands of private collectors as well.<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	HK23ECamo_1.PenetrationClass = 1


	RPD_1.is_tog_patched = true
	RPD_1.is_vanilla_firearm = false
	RPD_1.object_class = "MachineGun"
	RPD_1.Cost = 3240
	RPD_1.Damage = 25
	RPD_1.ObjDamageMod = 100
	RPD_1.CritChance = 0
	RPD_1.CritChanceScaled = 10
	storeProps(RPD_1, "AimAccuracy", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPD_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPD_1, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPD_1, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	RPD_1.PBbonus_base = -2
	RPD_1.HandlingBaseMul = 110
	RPD_1.HandlingNotProneMul = 190
	RPD_1.PenetrationClass = 1
	RPD_1.ShootAP = 4000
	RPD_1.ReloadAP = 5000
	RPD_1.APStance = 45
	RPD_1.OverwatchAngle = 632
	RPD_1.MagazineSize = 100
	RPD_1.Cumbersome = 0
	RPD_1.Noise = 22
	RPD_1.PointBlankBonus = 1
	RPD_1.PreparedAttackType = "Machine Gun"
	RPD_1.AvailableAttacks = {"MGBurstFire"}
	RPD_1.Rat_swap_ap = 3
	RPD_1.wep_base_recoil_mul = 95
	RPD_1.wep_base_snapshot_mul = 115
	RPD_1.wep_base_hip_mul = 92
	RPD_1.weigth_held_mul = 153
	RPD_1.burst_selective = false
	RPD_1.recoil_mechanism = "Gas_Operated"
	RPD_1.Rat_cycling = "Auto"
	RPD_1.rat_scope_block = false
	RPD_1.pistol_swap = false
	RPD_1.default_long_barrel = false
	RPD_1.unwieldy_weapon = false
	RPD_1.rat_barrel_len = 550
	RPD_1.rat_weigth = 7500
	RPD_1.Weigth = 7500
	RPD_1.ScrapParts = 16
	RPD_1.RepairCost = 80
	RPD_1.Reliability = 88
	RPD_1.LargeItem = 1
	RPD_1.HandSlot = "TwoHanded"
	RPD_1.AdditionalHint = T( 862873342222, [[<description_hints>]] )
	RPD_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Bipod', DefaultComponent = 'RPD_bipod_fld_1', Modifiable = true, AvailableComponents = {'RPD_bipod_fld_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'RPD_barrel_def_1', Modifiable = true, AvailableComponents = {'RPD_barrel_def_1', 'R_TOG_light_barrel', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'RPD_mag_def_1', Modifiable = true, AvailableComponents = {'RPD_mag_def_1', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'RPD_ironsight_1', Modifiable = true, AvailableComponents = {'LROptics', 'ReflexSight', 'ScopeCOG', 'LROpticsAdvanced', 'ScopeCOGQuick', 'ReflexSightAdvanced', 'RPD_ironsight_1', 'WideScope', '_ReflexSIghtVigilance', 'ThermalScope', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ToG_VFX_Muzzle', 'RAT_TOG_compensator', 'RAT_TOG_suppressor', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'RPD_stock_def_1', Modifiable = false, AvailableComponents = {'RPD_stock_def_1', }}}
	RPD_1.Valuable = 0
	RPD_1.CanAppearInShop = true
	RPD_1.CanAppearUsed = true
	RPD_1.Tier = 1
	RPD_1.MaxStock = 2
	RPD_1.RestockWeight = 80
	RPD_1.CategoryPair = "MachineGuns"
	RPD_1.Description = T(283294446635, [[<style PerkststsBold ><scale 600>The RPD is a 7.62x39mm light machine gun developed in the Soviet Union<newline><newline>It was created as a replacement for the DP machine gun chambered for the 7.62×54mmR round. It is a precursor of most squad automatic weapons. It was succeeded in Soviet service by the RPK.<newline><newline>Work on the weapon commenced in 1943. Three prominent Soviet engineers were asked to submit their own designs: Vasily Degtyaryov, Sergei Simonov and Alexei Sudayev. Among the completed prototypes prepared for evaluation, the Degtyaryov design proved superior and was accepted into service with the Soviet armed forces<newline><newline>After the introduction of the Kalashnikov-pattern support weapons, such as the RPK and PK machine guns in the 1960s, the RPD was withdrawn from most first-tier units of the former Warsaw Pact. However, the RPD remains in active service in many African and Asian nations<newline><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	RPD_1.PenetrationClass = 1


	M1911_1.is_tog_patched = true
	M1911_1.is_vanilla_firearm = false
	M1911_1.object_class = "Pistol"
	M1911_1.Cost = 2100
	M1911_1.Damage = 22
	M1911_1.ObjDamageMod = 100
	M1911_1.CritChance = 0
	M1911_1.CritChanceScaled = 10
	storeProps(M1911_1, "AimAccuracy", 14, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M1911_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M1911_1, "WeaponRange", 14, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M1911_1, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M1911_1.PBbonus_base = 12
	M1911_1.HandlingBaseMul = 100
	M1911_1.PenetrationClass = 1
	M1911_1.ShootAP = 4000
	M1911_1.ReloadAP = 3000
	M1911_1.APStance = 10
	M1911_1.OverwatchAngle = 2183
	M1911_1.MagazineSize = 7
	M1911_1.Cumbersome = 0
	M1911_1.Noise = 20
	M1911_1.PointBlankBonus = 1
	M1911_1.PreparedAttackType = "Overwatch"
	M1911_1.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	M1911_1.Rat_swap_ap = 1
	M1911_1.wep_base_recoil_mul = 113
	M1911_1.wep_base_snapshot_mul = 72
	M1911_1.wep_base_hip_mul = 115
	M1911_1.weigth_held_mul = 107
	M1911_1.burst_selective = false
	M1911_1.recoil_mechanism = "Short_Recoil"
	M1911_1.Rat_cycling = "SemiAuto"
	M1911_1.rat_scope_block = false
	M1911_1.pistol_swap = false
	M1911_1.default_long_barrel = false
	M1911_1.unwieldy_weapon = false
	M1911_1.rat_barrel_len = 127
	M1911_1.rat_weigth = 1100
	M1911_1.Weigth = 1100
	M1911_1.ScrapParts = 7
	M1911_1.RepairCost = 70
	M1911_1.Reliability = 86
	M1911_1.LargeItem = 0
	M1911_1.HandSlot = "OneHanded"
	M1911_1.AdditionalHint = T( 566181481232, [[<description_hints>]] )
	M1911_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_suppressor', 'Compensator', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'M1911_Mag_def_1', Modifiable = true, AvailableComponents = {'M1911_Mag_def_1', 'M1911_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'M1911_Barrel_def_1', Modifiable = true, AvailableComponents = {'M1911_Barrel_def_1', 'M1911_Barrel_ext_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_compactRS', 'RAT_TOG_vigilanceRS', 'RAT_TOG_uv_dot', 'RAT_TOG_laser_dot', }}}
	M1911_1.Valuable = 0
	M1911_1.CanAppearInShop = true
	M1911_1.CanAppearUsed = true
	M1911_1.Tier = 1
	M1911_1.MaxStock = 3
	M1911_1.RestockWeight = 60
	M1911_1.CategoryPair = "Handguns"
	M1911_1.fxClass = "HiPower"
	M1911_1.Description = T(120228027438, [[<style PerkststsBold ><scale 600>The 1911 is a single-action, recoil-operated, semi-automatic pistol chambered for the .45 ACP cartridge.<newline><newline>The pistol's formal U.S. military designation as of 1940 was , "1911" for the original model adopted March 1911, and "1911A1" for the improved 1911 model which entered service in 1926. 
<newline><newline><style MMOptionEntry>Made in USA <image UI/Icons/Flags/f_usa.dds 1600>]])
	M1911_1.PenetrationClass = 1


	P08_1.is_tog_patched = true
	P08_1.is_vanilla_firearm = false
	P08_1.object_class = "Pistol"
	P08_1.Cost = 2000
	P08_1.Damage = 17
	P08_1.ObjDamageMod = 100
	P08_1.CritChance = 0
	P08_1.CritChanceScaled = 10
	storeProps(P08_1, "AimAccuracy", 14, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(P08_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(P08_1, "WeaponRange", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(P08_1, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	P08_1.PBbonus_base = 13
	P08_1.HandlingBaseMul = 100
	P08_1.PenetrationClass = 1
	P08_1.ShootAP = 4000
	P08_1.ReloadAP = 4000
	P08_1.APStance = 10
	P08_1.OverwatchAngle = 2221
	P08_1.MagazineSize = 8
	P08_1.Cumbersome = 0
	P08_1.Noise = 18
	P08_1.PointBlankBonus = 1
	P08_1.PreparedAttackType = "Overwatch"
	P08_1.AvailableAttacks = {"SingleShot", "DualShot", "LeftHandShot", "RightHandShot", "CancelShot", "MobileShot"}
	P08_1.Rat_swap_ap = 1
	P08_1.wep_base_recoil_mul = 131
	P08_1.wep_base_snapshot_mul = 71
	P08_1.wep_base_hip_mul = 116
	P08_1.weigth_held_mul = 107
	P08_1.burst_selective = false
	P08_1.recoil_mechanism = "Short_Recoil"
	P08_1.Rat_cycling = "SemiAuto"
	P08_1.rat_scope_block = false
	P08_1.pistol_swap = false
	P08_1.default_long_barrel = false
	P08_1.unwieldy_weapon = false
	P08_1.rat_barrel_len = 110
	P08_1.rat_weigth = 1000
	P08_1.Weigth = 1000
	P08_1.ScrapParts = 5
	P08_1.RepairCost = 80
	P08_1.Reliability = 70
	P08_1.LargeItem = 0
	P08_1.HandSlot = "OneHanded"
	P08_1.AdditionalHint = T( 346431845219, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded]] )
	P08_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'P08_Mag_def_1', Modifiable = true, AvailableComponents = {'P08_Mag_def_1', 'P08_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'P08_Barrel_def_1', Modifiable = true, AvailableComponents = {'P08_Barrel_def_1', 'P08_Barrel_Long_1', }}, {CanBeEmpty = true, SlotType = 'Muzzle', DefaultComponent = 'CAWS_Muzzle_def_1', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', 'Compensator', 'CAWS_Muzzle_def_1', }}}
	P08_1.Valuable = 0
	P08_1.CanAppearInShop = true
	P08_1.CanAppearUsed = true
	P08_1.Tier = 1
	P08_1.MaxStock = 3
	P08_1.RestockWeight = 40
	P08_1.CategoryPair = "Handguns"
	P08_1.fxClass = "HiPower"
	P08_1.Description = T(980505415616, [[<style PerkststsBold ><scale 600>The Pistole Parabellum or Parabellum-Pistole, commonly known as just the Luger or Luger P08, is a toggle-locked recoil-operated semi-automatic pistol. The Luger was produced in several models and by several nations from 1898 to 1949.<newline><newline>The Luger was officially adopted by the Swiss military in 1900, the Imperial German Navy in 1906 and the German Army in 1908. The Luger was the standard service pistol of Switzerland, Portugal, the Netherlands, Brazil, Bolivia, and Bulgaria. It was widely used in other countries as a military service pistol and by police forces.<newline><newline>In the German Army service, it was adopted in a slightly modified form as the Pistole Modell 1908 (Pistole 08) in caliber 9×19mm Parabellum.<newline><newline>The Model 08 was eventually succeeded by the P38.
<newline><newline><style ConversationChoiceNormalRollover ><scale  600>Designed by Georg von Luger <newline><image Mod/KKh3Yhf/Images/designers/GJvLuger.png 1200><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	P08_1.PenetrationClass = 1


	B93RR_1.is_tog_patched = true
	B93RR_1.is_vanilla_firearm = false
	B93RR_1.object_class = "Pistol"
	B93RR_1.__parents[1] = "Pistol"
	B93RR_1.ItemType = "Handgun"
	B93RR_1.Cost = 2350
	B93RR_1.Damage = 16
	B93RR_1.ObjDamageMod = 100
	B93RR_1.CritChance = 0
	B93RR_1.CritChanceScaled = 10
	storeProps(B93RR_1, "AimAccuracy", 12, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(B93RR_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(B93RR_1, "WeaponRange", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(B93RR_1, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	B93RR_1.PBbonus_base = 10
	B93RR_1.HandlingBaseMul = 100
	B93RR_1.PenetrationClass = 1
	B93RR_1.ShootAP = 3000
	B93RR_1.ReloadAP = 4000
	B93RR_1.APStance = 10
	B93RR_1.OverwatchAngle = 2180
	B93RR_1.MagazineSize = 20
	B93RR_1.Cumbersome = 0
	B93RR_1.Noise = 22
	B93RR_1.PointBlankBonus = 1
	B93RR_1.PreparedAttackType = "Overwatch"
	B93RR_1.AvailableAttacks = {"BurstFire", "SingleShot", "DualShot", "CancelShot", "MobileShot", "RunAndGun"}
	B93RR_1.Rat_swap_ap = 1
	B93RR_1.wep_base_recoil_mul = 115
	B93RR_1.wep_base_snapshot_mul = 72
	B93RR_1.wep_base_hip_mul = 115
	B93RR_1.weigth_held_mul = 108
	B93RR_1.burst_selective = true
	B93RR_1.SingleShotCustomDeltaAP = 1
	B93RR_1.burst_recoil_delta = 90
	B93RR_1.recoil_mechanism = "Short_Recoil"
	B93RR_1.Rat_cycling = "Auto"
	B93RR_1.rat_scope_block = false
	B93RR_1.pistol_swap = false
	B93RR_1.default_long_barrel = false
	B93RR_1.unwieldy_weapon = false
	B93RR_1.rat_barrel_len = 124
	B93RR_1.rat_weigth = 1180
	B93RR_1.Weigth = 1180
	B93RR_1.ScrapParts = 6
	B93RR_1.RepairCost = 70
	B93RR_1.Reliability = 79
	B93RR_1.LargeItem = 0
	B93RR_1.HandSlot = "OneHanded"
	B93RR_1.AdditionalHint = T( 599431805405, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Selective fire burst mode leads to less recoil]] )
	B93RR_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ToG_VFX_Muzzle', 'ImprovisedSuppressor', 'Suppressor', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'B93RR_mag_def_1', Modifiable = true, AvailableComponents = {'B93RR_mag_def_1', 'B93RR_mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'B93RR_barrel_def_1', Modifiable = true, AvailableComponents = {'B93RR_barrel_shrt_1', 'B93RR_barrel_def_1', 'B93RR_barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Under', DefaultComponent = 'B93RR_grip_fld_1', Modifiable = true, AvailableComponents = {'B93RR_grip_fld_1', 'B93RR_grip_unfld_1'}}}
	B93RR_1.Valuable = 0
	B93RR_1.CanAppearInShop = true
	B93RR_1.CanAppearUsed = true
	B93RR_1.Tier = 2
	B93RR_1.MaxStock = 2
	B93RR_1.RestockWeight = 50
	B93RR_1.CategoryPair = "Handguns"
	B93RR_1.fxClass = "UZI"
	B93RR_1.Description = T(485390782648, [[<style PerkststsBold ><scale 600>The 93R is an Italian selective-fire machine pistol, designed in the late 1970s for police and military use, that is derived from their semi-automatic 92. The "R" stands for Raffica, which is Italian for "volley", "flurry", or "burst"<newline><newline>The 93R was designed to be used by the Italian counter-terrorism forces of the national police but was also adopted by other police and military forces who required a concealable weapon with rapid fire capabilities.<newline><newline>Much more controllable compared to other machine pistols because it was designed with only a three-round burst mode as well as a ported barrel
<newline><newline><style MMOptionEntry>Made in Italy<image Mod/HXzCpFa/Icons/Flags/Italy.png 1600>]])
	B93RR_1.PenetrationClass = 1


	USP_1.is_tog_patched = true
	USP_1.is_vanilla_firearm = false
	USP_1.object_class = "Pistol"
	USP_1.Cost = 950
	USP_1.Damage = 17
	USP_1.ObjDamageMod = 100
	USP_1.CritChance = 0
	USP_1.CritChanceScaled = 20
	storeProps(USP_1, "AimAccuracy", 10, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(USP_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(USP_1, "WeaponRange", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(USP_1, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	USP_1.PBbonus_base = 13
	USP_1.HandlingBaseMul = 100
	USP_1.PenetrationClass = 1
	USP_1.ShootAP = 4000
	USP_1.ReloadAP = 3000
	USP_1.APStance = 10
	USP_1.OverwatchAngle = 2165
	USP_1.MagazineSize = 15
	USP_1.Cumbersome = 0
	USP_1.Noise = 18
	USP_1.PointBlankBonus = 1
	USP_1.PreparedAttackType = "Overwatch"
	USP_1.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	USP_1.Rat_swap_ap = 1
	USP_1.wep_base_recoil_mul = 117
	USP_1.wep_base_snapshot_mul = 69
	USP_1.wep_base_hip_mul = 116
	USP_1.weigth_held_mul = 105
	USP_1.burst_selective = false
	USP_1.recoil_mechanism = "Short_Recoil"
	USP_1.Rat_cycling = "SemiAuto"
	USP_1.rat_scope_block = false
	USP_1.pistol_swap = false
	USP_1.default_long_barrel = false
	USP_1.unwieldy_weapon = false
	USP_1.rat_barrel_len = 108
	USP_1.rat_weigth = 700
	USP_1.Weigth = 700
	USP_1.ScrapParts = 6
	USP_1.RepairCost = 70
	USP_1.Reliability = 88
	USP_1.LargeItem = 0
	USP_1.HandSlot = "OneHanded"
	USP_1.AdditionalHint = T( 928500227524, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded.]] )
	USP_1.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'uspr_mag_def_1', Modifiable = true, AvailableComponents = {'uspr_mag_def_1', 'uspr_mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'ToG_Comp_Pstl_Barrel_Long', 'ToG_Comp_Pstl_Barrel_Long_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex_pistol', 'RAT_TOG_compactRS', 'ImprovedIronsight', 'RAT_TOG_vigilanceRS', 'RAT_TOG_uv_dot', 'RAT_TOG_laser_dot', }}}
	USP_1.Valuable = 0
	USP_1.CanAppearInShop = true
	USP_1.CanAppearUsed = true
	USP_1.Tier = 1
	USP_1.MaxStock = 3
	USP_1.RestockWeight = 80
	USP_1.CategoryPair = "Handguns"
	USP_1.Description = T(313263970388, [[<style PerkststsBold ><scale 700>The USP (Universelle Selbstladepistole or "universal self-loading pistol") is a semi-automatic pistol developed in Germany as a replacement for the P7 series of handguns.<newline><newline>Design work on a new family of pistols commenced in September 1989, focused primarily on the United States commercial and law enforcement markets. USP prototypes participated in rigorous testing in the Offensive Handgun Weapon System (OHWS) program requested by the U.S. Special Operations Command (USSOCOM), which would later result in the Mk 23<newline><newline>One of the distinguishing features of the USP is the mechanical recoil reduction system. It consists of a short additional spring located within the main recoil spring on the breech end of the recoil spring assembly. Designed primarily to reduce wear on the pistol's components, the system also lowers the peak recoil forces felt by the shooter.<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	USP_1.PenetrationClass = 1


	VikingMP446_1.is_tog_patched = true
	VikingMP446_1.is_vanilla_firearm = false
	VikingMP446_1.object_class = "Pistol"
	VikingMP446_1.Cost = 800
	VikingMP446_1.Damage = 18
	VikingMP446_1.ObjDamageMod = 100
	VikingMP446_1.CritChance = 0
	VikingMP446_1.CritChanceScaled = 10
	storeProps(VikingMP446_1, "AimAccuracy", 8, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VikingMP446_1, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VikingMP446_1, "WeaponRange", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VikingMP446_1, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	VikingMP446_1.PBbonus_base = 13
	VikingMP446_1.HandlingBaseMul = 100
	VikingMP446_1.PenetrationClass = 1
	VikingMP446_1.ShootAP = 4000
	VikingMP446_1.ReloadAP = 3000
	VikingMP446_1.APStance = 10
	VikingMP446_1.OverwatchAngle = 2166
	VikingMP446_1.MagazineSize = 10
	VikingMP446_1.Cumbersome = 0
	VikingMP446_1.Noise = 18
	VikingMP446_1.PointBlankBonus = 1
	VikingMP446_1.PreparedAttackType = "Overwatch"
	VikingMP446_1.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	VikingMP446_1.Rat_swap_ap = 1
	VikingMP446_1.wep_base_recoil_mul = 114
	VikingMP446_1.wep_base_snapshot_mul = 70
	VikingMP446_1.wep_base_hip_mul = 116
	VikingMP446_1.weigth_held_mul = 105
	VikingMP446_1.burst_selective = false
	VikingMP446_1.recoil_mechanism = "Striker_Fired"
	VikingMP446_1.Rat_cycling = "SemiAuto"
	VikingMP446_1.rat_scope_block = false
	VikingMP446_1.pistol_swap = false
	VikingMP446_1.default_long_barrel = false
	VikingMP446_1.unwieldy_weapon = false
	VikingMP446_1.rat_barrel_len = 106
	VikingMP446_1.rat_weigth = 800
	VikingMP446_1.Weigth = 800
	VikingMP446_1.ScrapParts = 6
	VikingMP446_1.RepairCost = 60
	VikingMP446_1.Reliability = 84
	VikingMP446_1.LargeItem = 0
	VikingMP446_1.HandSlot = "OneHanded"
	VikingMP446_1.AdditionalHint = T( 746490991929, [[<description_hints>]] )
	VikingMP446_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'Viking_mag_def_1', Modifiable = true, AvailableComponents = {'Viking_mag_def_1', 'Viking_mag_ext_1', 'Viking_mag_extQ_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Viking_Barrel_def_1', Modifiable = true, AvailableComponents = {'Viking_Barrel_def_1', 'Viking_Barrel_ext_1', }}}
	VikingMP446_1.Valuable = 0
	VikingMP446_1.CanAppearInShop = true
	VikingMP446_1.CanAppearUsed = true
	VikingMP446_1.Tier = 2
	VikingMP446_1.MaxStock = 4
	VikingMP446_1.RestockWeight = 60
	VikingMP446_1.CategoryPair = "Handguns"
	VikingMP446_1.Description = T(602960483459, [[<style PerkststsBold ><scale 700>The MP-446 Viking is an internal hammer firing 9mm semi-automatic handgun originating from Russia.<newline><newline>It is a short recoil operated, locked breech pistol. The Browning-type locking is achieved using traditional cam system and one large lug on the breech of the barrel, which engages the enlarged ejection port in the slide. The frame of the pistol is made from high-strength polymer.<newline><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	VikingMP446_1.PenetrationClass = 1


	Glock17_1.is_tog_patched = true
	Glock17_1.is_vanilla_firearm = false
	Glock17_1.object_class = "Pistol"
	Glock17_1.Cost = 570
	Glock17_1.Damage = 16
	Glock17_1.ObjDamageMod = 100
	Glock17_1.CritChance = 0
	Glock17_1.CritChanceScaled = 10
	storeProps(Glock17_1, "AimAccuracy", 7, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Glock17_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Glock17_1, "WeaponRange", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Glock17_1, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Glock17_1.PBbonus_base = 14
	Glock17_1.HandlingBaseMul = 100
	Glock17_1.PenetrationClass = 1
	Glock17_1.ShootAP = 4000
	Glock17_1.ReloadAP = 3000
	Glock17_1.APStance = 10
	Glock17_1.OverwatchAngle = 2245
	Glock17_1.MagazineSize = 15
	Glock17_1.Cumbersome = 0
	Glock17_1.Noise = 18
	Glock17_1.PointBlankBonus = 1
	Glock17_1.PreparedAttackType = "Overwatch"
	Glock17_1.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
	Glock17_1.Rat_swap_ap = 1
	Glock17_1.wep_base_recoil_mul = 116
	Glock17_1.wep_base_snapshot_mul = 70
	Glock17_1.wep_base_hip_mul = 116
	Glock17_1.weigth_held_mul = 104
	Glock17_1.burst_selective = false
	Glock17_1.recoil_mechanism = "Striker_Fired"
	Glock17_1.Rat_cycling = "SemiAuto"
	Glock17_1.rat_scope_block = false
	Glock17_1.pistol_swap = false
	Glock17_1.default_long_barrel = false
	Glock17_1.unwieldy_weapon = false
	Glock17_1.rat_barrel_len = 114
	Glock17_1.rat_weigth = 650
	Glock17_1.Weigth = 650
	Glock17_1.ScrapParts = 6
	Glock17_1.RepairCost = 70
	Glock17_1.Reliability = 88
	Glock17_1.LargeItem = 0
	Glock17_1.HandSlot = "OneHanded"
	Glock17_1.AdditionalHint = T( 246679208709, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded]] )
	Glock17_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', 'ToG_VFX_Muzzle', 'Compensator_Glock', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'ToG_Comp_Pstl_defmag_1', Modifiable = true, AvailableComponents = {'ToG_Comp_Pstl_defmag_1', 'ToG_Comp_Pstl_finemag_1', 'ToG_Comp_Pstl_expmag_1', 'ToG_Comp_Pstl_ergmag_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex_pistol', 'RAT_TOG_compactRS', 'ImprovedIronsight', 'RAT_TOG_vigilanceRS', 'RAT_TOG_uv_dot', 'RAT_TOG_laser_dot', }}}
	Glock17_1.Valuable = 0
	Glock17_1.CanAppearInShop = true
	Glock17_1.CanAppearUsed = true
	Glock17_1.Tier = 1
	Glock17_1.MaxStock = 4
	Glock17_1.RestockWeight = 100
	Glock17_1.CategoryPair = "Handguns"
	Glock17_1.fxClass = "Glock18"
	Glock17_1.Description = T(442902725085, [[<style PerkststsBold ><scale 700>The Glock 17 is a short recoil-operated, locked-breech semi-automatic pistol that uses a modified Browning cam-lock system adapted from the Hi-Power pistol.<newline><newline>The handgun was adopted into service with the Austrian military and law enforcement in 1982 as the Pistole 80, with an initial order for 25,000 guns. The Glock 17 outperformed eight different pistols from five other established manufacturers<newline><newline>In 1985, after joint Norwegian and Swedish trials from 1983 to 1985, the Glock 17 was accepted into service as the P80 in Norway, and in 1988 as the Pistol 88 in Sweden, where it surpassed all prior NATO durability standards. As a result, the Glock 17 became a standard NATO-classified sidearm<newline><newline><style MMOptionEntry>Made in Austria<image Mod/HXzCpFa/Icons/Flags/Austria.png 1600>]])
	Glock17_1.PenetrationClass = 1


	SSG69_1.is_tog_patched = true
	SSG69_1.is_vanilla_firearm = false
	SSG69_1.object_class = "SniperRifle"
	SSG69_1.ItemType = "Sniper"
	SSG69_1.Cost = 6560
	SSG69_1.Damage = 31
	SSG69_1.ObjDamageMod = 100
	SSG69_1.CritChance = 0
	SSG69_1.CritChanceScaled = 20
	storeProps(SSG69_1, "AimAccuracy", 51, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SSG69_1, "AimAccuracy", 7, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SSG69_1, "WeaponRange", 44, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SSG69_1, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	SSG69_1.PBbonus_base = -4
	SSG69_1.HandlingBaseMul = 122
	SSG69_1.PenetrationClass = 1
	SSG69_1.ShootAP = 4000
	SSG69_1.ReloadAP = 3000
	SSG69_1.APStance = 40
	SSG69_1.OverwatchAngle = 847
	SSG69_1.MagazineSize = 5
	SSG69_1.Cumbersome = 0
	SSG69_1.Noise = 20
	SSG69_1.PointBlankBonus = 1
	SSG69_1.PreparedAttackType = "Both"
	SSG69_1.AvailableAttacks = {"SingleShot", "CancelShot"}
	SSG69_1.Rat_swap_ap = 3
	SSG69_1.wep_base_recoil_mul = 86
	SSG69_1.wep_base_snapshot_mul = 115
	SSG69_1.wep_base_hip_mul = 90
	SSG69_1.weigth_held_mul = 130
	SSG69_1.burst_selective = false
	SSG69_1.recoil_mechanism = "Bolt_Action"
	SSG69_1.Rat_cycling = "BoltAction"
	SSG69_1.rat_scope_block = false
	SSG69_1.pistol_swap = false
	SSG69_1.default_long_barrel = false
	SSG69_1.unwieldy_weapon = false
	SSG69_1.rat_barrel_len = 600
	SSG69_1.rat_weigth = 4300
	SSG69_1.Weigth = 4300
	SSG69_1.ScrapParts = 8
	SSG69_1.RepairCost = 80
	SSG69_1.Reliability = 95
	SSG69_1.LargeItem = 1
	SSG69_1.HandSlot = "TwoHanded"
	SSG69_1.AdditionalHint = T( 787968005557, [[<description_hints>]] )
	SSG69_1.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'SSG69_Scope_1', 'ScopeCOGQuick', 'ScopeCOG', 'WideScope', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'SSG69_Barrel_def_1', Modifiable = true, AvailableComponents = {'SSG69_Barrel_def_1', 'SSG69_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ToG_VFX_Muzzle', 'AUGCompensator_01', 'ImprovisedSuppressor', 'RAT_TOG_suppressor', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'SSG69_Mag_def_1', Modifiable = true, AvailableComponents = {'SSG69_Mag_def_1', 'SSG69_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Bolt_action', Modifiable = true, AvailableComponents = {'Bolt_action', }}}
	SSG69_1.Valuable = 0
	SSG69_1.CanAppearInShop = true
	SSG69_1.CanAppearUsed = true
	SSG69_1.Tier = 2
	SSG69_1.MaxStock = 2
	SSG69_1.RestockWeight = 80
	SSG69_1.CategoryPair = "Rifles"
	SSG69_1.fxClass = "PSG1"
	SSG69_1.Description = T(393371357000, [[<style PerkststsBold ><scale 700>The SSG 69 is a bolt-action sniper rifle that serves as the standard sniper rifle for the Austrian Army.<newline><newline>Designed as a sniper system to replace the SSG 98k sniper rifle (modified and accurized surplus Karabiner 98k rifles) and adopted in 1969 (hence the designation), it was ahead of its time with the use of synthetics like the stock, trigger guard, and magazines and cold hammer-forged barrels for durability.<newline><newline>Aside from being the Austrian Army's standard issue sniper rifle, it is also used by several law enforcement organizations. For its era and weight, it is extremely accurate and several international competitions have been won using an SSG-69 with accuracy being sub 0.15 mrad<newline><newline>The choice for a synthetic stock was remarkable, as other sniper rifles at the time were still using wood stocks.<newline><newline><style MMOptionEntry>Made in Austria<image Mod/HXzCpFa/Icons/Flags/Austria.png 1600>]])
	SSG69_1.PenetrationClass = 1


	SteyrScout_1.is_tog_patched = true
	SteyrScout_1.is_vanilla_firearm = false
	SteyrScout_1.object_class = "SniperRifle"
	SteyrScout_1.Cost = 5880
	SteyrScout_1.Damage = 30
	SteyrScout_1.ObjDamageMod = 100
	SteyrScout_1.CritChance = 0
	SteyrScout_1.CritChanceScaled = 30
	storeProps(SteyrScout_1, "AimAccuracy", 49, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SteyrScout_1, "AimAccuracy", 8, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SteyrScout_1, "WeaponRange", 38, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(SteyrScout_1, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	SteyrScout_1.PBbonus_base = -1
	SteyrScout_1.HandlingBaseMul = 100
	SteyrScout_1.PenetrationClass = 1
	SteyrScout_1.ShootAP = 4000
	SteyrScout_1.ReloadAP = 3000
	SteyrScout_1.APStance = 40
	SteyrScout_1.OverwatchAngle = 970
	SteyrScout_1.MagazineSize = 5
	SteyrScout_1.Cumbersome = 0
	SteyrScout_1.Noise = 18
	SteyrScout_1.PointBlankBonus = 1
	SteyrScout_1.PreparedAttackType = "Both"
	SteyrScout_1.AvailableAttacks = {"SingleShot", "CancelShot"}
	SteyrScout_1.Rat_swap_ap = 3
	SteyrScout_1.wep_base_recoil_mul = 91
	SteyrScout_1.wep_base_snapshot_mul = 110
	SteyrScout_1.wep_base_hip_mul = 94
	SteyrScout_1.weigth_held_mul = 132
	SteyrScout_1.burst_selective = false
	SteyrScout_1.recoil_mechanism = "Bolt_Action"
	SteyrScout_1.Rat_cycling = "BoltAction"
	SteyrScout_1.rat_scope_block = false
	SteyrScout_1.pistol_swap = false
	SteyrScout_1.default_long_barrel = false
	SteyrScout_1.unwieldy_weapon = false
	SteyrScout_1.rat_barrel_len = 510
	SteyrScout_1.rat_weigth = 4500
	SteyrScout_1.Weigth = 4500
	SteyrScout_1.ScrapParts = 14
	SteyrScout_1.RepairCost = 80
	SteyrScout_1.Reliability = 92
	SteyrScout_1.LargeItem = 1
	SteyrScout_1.HandSlot = "TwoHanded"
	SteyrScout_1.AdditionalHint = T( 542907374091, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Faster bolt-action mechanism
]] )
	SteyrScout_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'SteyrS_Barrel_def_1', Modifiable = true, AvailableComponents = {'SteyrS_Barrel_def_1', 'SteyrS_Barrel_ext_1', 'RAT_TOG_SteyrS_Barrel_ext_556', 'RAT_TOG_SteyrS_Barrel_def_555',}}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = false, AvailableComponents = {'ToG_Bipod_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'SSG69_Mag_def_1', Modifiable = false, AvailableComponents = {'SSG69_Mag_def_1', 'SSG69_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'SteyrS_Scope_1', Modifiable = true, AvailableComponents = {'SteyrS_Scope_1', 'ReflexSight', 'ScopeCOG', 'ThermalScope', 'ReflexSightAdvanced', 'ScopeCOGQuick', 'LROptics', 'LROpticsAdvanced', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Bolt_action_scout', Modifiable = true, AvailableComponents = {'Bolt_action_scout', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_compensator', 'SteyrS_Muzzle_def_1', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockLight', Modifiable = true, AvailableComponents = {'StockLight', }}}
	SteyrScout_1.Valuable = 0
	SteyrScout_1.CanAppearInShop = true
	SteyrScout_1.CanAppearUsed = true
	SteyrScout_1.Tier = 2
	SteyrScout_1.MaxStock = 2
	SteyrScout_1.RestockWeight = 50
	SteyrScout_1.CategoryPair = "Rifles"
	SteyrScout_1.Description = T(724580740435, [[<style PerkststsBold ><scale 600>The Scout Tactical is an Austrian bolt-action rifle chambered for 7.62 NATO or 5.56mm <newline><newline>It is intended to fill the role of a versatile, lightweight all-around rifle as specified in Jeff Cooper's scout rifle concept. Apart from the barrel and action, the gun is made primarily of polymers and is designed to be accurate to at least 800 m<newline><newline>A variant and effectively the successor of the Scout is the Tactical Elite, a more robustly constructed model with many of the same features of the Scout, but designed primarily for the law enforcement market for an urban tactical role. Differences to the standard Scout include an extended STANAG type mounting rail, an enlarged bolt knob of the SSG type, an adjustable cheek piece, and a height-adjustable buttpad.<newline><newline>It is fitted with a heavy 570 mm (22 in) barrel, and can produce high muzzle velocities due to a "fast" internal profile. The additional features of the Elite give it a weight of over 4.2 kg (9.3 lb), which makes it fall outside the definition of a scout rifle.<newline><newline><style MMOptionEntry>Made in Austria<image Mod/HXzCpFa/Icons/Flags/Austria.png 1600>]])
	SteyrScout_1.PenetrationClass = 1


	M76_1.is_tog_patched = true
	M76_1.is_vanilla_firearm = false
	M76_1.object_class = "SniperRifle"
	M76_1.Cost = 3900
	M76_1.Damage = 30
	M76_1.ObjDamageMod = 100
	M76_1.CritChance = 0
	M76_1.CritChanceScaled = 20
	storeProps(M76_1, "AimAccuracy", 40, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M76_1, "AimAccuracy", 6, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M76_1, "WeaponRange", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M76_1, "WeaponRange", 38, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M76_1.PBbonus_base = -3
	M76_1.HandlingBaseMul = 112
	M76_1.PenetrationClass = 1
	M76_1.ShootAP = 4000
	M76_1.ReloadAP = 3000
	M76_1.APStance = 40
	M76_1.OverwatchAngle = 833
	M76_1.MagazineSize = 10
	M76_1.Cumbersome = 0
	M76_1.Noise = 28
	M76_1.PointBlankBonus = 1
	M76_1.PreparedAttackType = "Both"
	M76_1.AvailableAttacks = {"SingleShot", "CancelShot"}
	M76_1.Rat_swap_ap = 3
	M76_1.wep_base_recoil_mul = 85
	M76_1.wep_base_snapshot_mul = 116
	M76_1.wep_base_hip_mul = 89
	M76_1.weigth_held_mul = 132
	M76_1.burst_selective = false
	M76_1.recoil_mechanism = "Gas_Operated"
	M76_1.Rat_cycling = "SemiAuto"
	M76_1.rat_scope_block = false
	M76_1.pistol_swap = false
	M76_1.default_long_barrel = false
	M76_1.unwieldy_weapon = false
	M76_1.rat_barrel_len = 600
	M76_1.rat_weigth = 4500
	M76_1.Weigth = 4500
	M76_1.ScrapParts = 14
	M76_1.RepairCost = 70
	M76_1.Reliability = 87
	M76_1.LargeItem = 1
	M76_1.HandSlot = "TwoHanded"
	M76_1.AdditionalHint = T( 542588930667, [[<description_hints>]] )
	M76_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'm76_stock_def_1', Modifiable = true, AvailableComponents = {'m76_stock_erg_1', 'm76_stock_def_1', 'm76_stock_hvy_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'm76_mag_def_1', Modifiable = true, AvailableComponents = {'m76_mag_def_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'RAT_TOG_suppressor', 'RAT_TOG_compensator', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'ImprovedIronsight', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex_rpk_mount', 'RAT_TOG_ACOG_rpk_mount', 'RAT_TOG_compactRS_rpk_mount', 'RAT_TOG_Prism_rpk_mount', 'RAT_TOG_vigilanceRS_rpk_mount', 'RAT_TOG_thermal_rpk_mount', 'RAT_TOG_WideScope_rpk_mount', 'RAT_TOG_LRoptics_rpk_mount', 'm76_scope_1', 'RAT_TOG_LRoptics_advanced_rpk_mount', 'ImprovedIronsight', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'm76_barrel_def_1', Modifiable = true, AvailableComponents = {'m76_barrel_shrt_1', 'm76_barrel_def_1', 'm76_barrel_ext_1', }}}
	M76_1.Valuable = 0
	M76_1.CanAppearInShop = true
	M76_1.CanAppearUsed = true
	M76_1.Tier = 2
	M76_1.MaxStock = 3
	M76_1.RestockWeight = 100
	M76_1.CategoryPair = "Rifles"
	M76_1.Description = T(979114916169, [[<style PerkststsBold ><scale 600>The M76 is a military semi-automatic designated marksman rifle released in the mid-1970s<newline><newline>The M76 is similar in concept to the Russian Dragunov SVD sniper/designated marksman rifle; a semi-automatic rifle using a full-power cartridge from a 10-round magazine. However, the M76 is closer to the AK-47/RPK design and the unlicensed M70 AK-derivative than the Dragunov SVD. Rather than being a Dragunov clone, it looks more like a lengthened AK-47 with a heavier barrel, an impression strengthened by the separate stock and pistol grip rather than the Dragunov's thumbhole combination stock<newline><newline>The typical telescopic sight used is a ZRAK ON-M76 scope. The reticle illumination of the ZRAK M76 is provided by (radioactive) tritium. The tritium light source has to be replaced every 8-12 years, since it gradually loses its brightness due to radioactive decay.<newline><newline><style MMOptionEntry>Made in Yugoslavia <image Mod/KKh3Yhf/Images/Yugoslavia.png 1600>]])
	M76_1.PenetrationClass = 1


	Mosin_1.is_tog_patched = true
	Mosin_1.is_vanilla_firearm = false
	Mosin_1.object_class = "SniperRifle"
	Mosin_1.ItemType = "Sniper"
	Mosin_1.Cost = 2100
	Mosin_1.Damage = 31
	Mosin_1.ObjDamageMod = 100
	Mosin_1.CritChance = 0
	Mosin_1.CritChanceScaled = 30
	storeProps(Mosin_1, "AimAccuracy", 38, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Mosin_1, "AimAccuracy", 6, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Mosin_1, "WeaponRange", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Mosin_1, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Mosin_1.PBbonus_base = 6
	Mosin_1.HandlingBaseMul = 118
	Mosin_1.PenetrationClass = 1
	Mosin_1.ShootAP = 4000
	Mosin_1.ReloadAP = 3000
	Mosin_1.APStance = 30
	Mosin_1.OverwatchAngle = 1091
	Mosin_1.MagazineSize = 8
	Mosin_1.Cumbersome = 0
	Mosin_1.Noise = 22
	Mosin_1.PointBlankBonus = 1
	Mosin_1.PreparedAttackType = "Both"
	Mosin_1.AvailableAttacks = {"SingleShot", "CancelShot"}
	Mosin_1.Rat_swap_ap = 3
	Mosin_1.wep_base_recoil_mul = 93
	Mosin_1.wep_base_snapshot_mul = 109
	Mosin_1.wep_base_hip_mul = 94
	Mosin_1.weigth_held_mul = 128
	Mosin_1.burst_selective = false
	Mosin_1.recoil_mechanism = "Bolt_Action"
	Mosin_1.Rat_cycling = "BoltAction"
	Mosin_1.rat_scope_block = false
	Mosin_1.pistol_swap = false
	Mosin_1.default_long_barrel = false
	Mosin_1.unwieldy_weapon = false
	Mosin_1.rat_barrel_len = 520
	Mosin_1.ScrapParts = 9
	Mosin_1.RepairCost = 80
	Mosin_1.Reliability = 96
	Mosin_1.LargeItem = 1
	Mosin_1.HandSlot = "TwoHanded"
	Mosin_1.AdditionalHint = T( 471813286018, [[<description_hints>]] )
	Mosin_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'Mosin_Scope_iron_1', Modifiable = true, AvailableComponents = {'Mosin_Scope_iron_1', 'ReflexSightAdvanced', 'ReflexSight', '_ReflexSIghtVigilance', 'LROptics', 'ScopeCOGQuick', 'WideScope', 'LROpticsAdvanced', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Mosin_Barrel_def_1', Modifiable = true, AvailableComponents = {'Mosin_Barrel_def_1', 'Mosin_Barrel_long_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ToG_VFX_Muzzle', 'ImprovisedSuppressor', 'Suppressor', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Bolt_action', Modifiable = true, AvailableComponents = {'Bolt_action', }}}
	Mosin_1.Valuable = 0
	Mosin_1.CanAppearInShop = true
	Mosin_1.CanAppearUsed = true
	Mosin_1.Tier = 1
	Mosin_1.MaxStock = 4
	Mosin_1.RestockWeight = 100
	Mosin_1.CategoryPair = "Rifles"
	Mosin_1.fxClass = "Gewehr98"
	Mosin_1.Description = T(913798103123, [[<style PerkststsBold ><scale 600>The Mosin-Nagant is a five-shot, bolt-action, internal magazine-fed military rifle. Known officially as the 3-line rifle M1891 and informally in Russia and the former Soviet Union as Mosin's rifle.<newline><newline>It is primarily found chambered for its original 7.62×54mmR cartridge. Developed from 1882 to 1891, it was used by the armed forces of the Russian Empire, the Soviet Union and various other states. It is one of the most mass-produced military bolt-action rifles in history, with over 37 million units produced since 1891. In spite of its age, it has been used in various conflicts around the world up to the present day.<newline><newline>Large numbers of Mosin-Nagants were captured by German and Austro-Hungarian forces in WW1 and saw service with the rear-echelon forces of both armies, and also with the Imperial German Navy.<newline><newline><style ConversationChoiceNormalRollover ><scale  900>Designed by Mosin & Nagant <newline><image Mod/KKh3Yhf/Images/designers/Mosin_Mosin.png 1200><image Mod/KKh3Yhf/Images/designers/Mosin_Nagant.png 1000><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	Mosin_1.PenetrationClass = 1


	VSS_1.is_tog_patched = true
	VSS_1.is_vanilla_firearm = false
	VSS_1.object_class = "BarretM82"
	VSS_1.Cost = 5160
	VSS_1.Damage = 26
	VSS_1.ObjDamageMod = 100
	VSS_1.CritChance = 0
	VSS_1.CritChanceScaled = 30
	storeProps(VSS_1, "AimAccuracy", 38, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VSS_1, "AimAccuracy", 6, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VSS_1, "WeaponRange", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VSS_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	VSS_1.PBbonus_base = 6
	VSS_1.HandlingBaseMul = 100
	VSS_1.HandlingNotProneMul = 100
	VSS_1.PenetrationClass = 1
	VSS_1.ShootAP = 4000
	VSS_1.ReloadAP = 2000
	VSS_1.APStance = 30
	VSS_1.OverwatchAngle = 1465
	VSS_1.MagazineSize = 10
	VSS_1.Cumbersome = 0
	VSS_1.Noise = 20
	VSS_1.PointBlankBonus = 1
	VSS_1.PreparedAttackType = "Overwatch"
	VSS_1.AvailableAttacks = {"SingleShot", "CancelShot", "BurstFire", "AutoFire"}
	VSS_1.Rat_swap_ap = 3
	VSS_1.wep_base_recoil_mul = 110
	VSS_1.wep_base_snapshot_mul = 83
	VSS_1.wep_base_hip_mul = 111
	VSS_1.weigth_held_mul = 120
	VSS_1.burst_selective = false
	VSS_1.burst_recoil_delta = 108
	VSS_1.long_recoil_delta = 108
	VSS_1.auto_recoil_delta = 108
	VSS_1.recoil_mechanism = "Gas_Operated"
	VSS_1.Rat_cycling = "Auto"
	VSS_1.rat_scope_block = false
	VSS_1.pistol_swap = false
	VSS_1.default_long_barrel = false
	VSS_1.unwieldy_weapon = false
	VSS_1.rat_barrel_len = 200
	VSS_1.rat_weigth = 2850
	VSS_1.Weigth = 2850
	VSS_1.ScrapParts = 13
	VSS_1.RepairCost = 90
	VSS_1.Reliability = 82
	VSS_1.LargeItem = 1
	VSS_1.HandSlot = "TwoHanded"
	VSS_1.AdditionalHint = T( 413559350745, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Silent Attacks]] )
	VSS_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'VSS_Mag_def_1', Modifiable = true, AvailableComponents = {'VSS_Mag_def_1', 'VSS_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'VSS_Ironsight_1', Modifiable = true, AvailableComponents = {'VSS_Ironsight_1', 'VSS_Scope_1', 'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_LRoptics', 'RAT_TOG_LRoptics_advanced', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', }}, {CanBeEmpty = true, SlotType = 'Bipod', Modifiable = true, AvailableComponents = {'ToG_Bipod_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', Modifiable = false, AvailableComponents = {}}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'R_VSS_suppressor', Modifiable = true, AvailableComponents = {'R_VSS_suppressor', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'VSS_Stock_def_1', Modifiable = false, AvailableComponents = {'VSS_Stock_def_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'VSS_Barrel_def_1', Modifiable = true, AvailableComponents = {'VSS_Barrel_def_1', 'VSS_Barrel_ext_1', }}}
	VSS_1.Valuable = 0
	VSS_1.CanAppearInShop = false
	VSS_1.CanAppearUsed = true
	VSS_1.Tier = 2
	VSS_1.MaxStock = 3
	VSS_1.RestockWeight = 100
	VSS_1.CategoryPair = "Rifles"
	VSS_1.ModifyRightHandGrip = true
	VSS_1.fxClass = "BarretM82"
	VSS_1.Description = T(880238376758, [[<style PerkststsBold ><scale 600>The VSS Vintorez is a Soviet-designed assault rifle featuring an integral suppressor based on the prototype RG-036 completed in 1981<newline><newline>The VSS Vintorez is integrally suppressed and chambered for the 9×39mm subsonic cartridge.<newline><newline>The rifle also has an "AK-type" Warsaw Pact rail for various optical sights, namely the PSO-1-1, PSO-1M2-1, and 1-PN-51 calibrated for use with the 9x39mm cartridge.<newline><newline>The Vintorez (beginning in 1983) were developed to replace modified general-purpose firearms, such as the AKS-74UB. Production began after its adoption by the Armed Forces of the Soviet Union in 1987.<newline><newline><style ConversationChoiceNormalRollover ><scale  500>Designed by Pyotr Serdyukov and Vladimir Krasnikov<newline><image Mod/KKh3Yhf/Images/designers/Pyotr-Serdyukov.png 1200><newline><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	VSS_1.PenetrationClass = 1


	Delisle_1.is_tog_patched = true
	Delisle_1.is_vanilla_firearm = false
	Delisle_1.object_class = "SniperRifle"
	Delisle_1.ItemType = "Sniper"
	Delisle_1.Cost = 3000
	Delisle_1.Damage = 22
	Delisle_1.ObjDamageMod = 100
	Delisle_1.CritChance = 0
	Delisle_1.CritChanceScaled = 20
	storeProps(Delisle_1, "AimAccuracy", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Delisle_1, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Delisle_1, "WeaponRange", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Delisle_1, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Delisle_1.PBbonus_base = 5
	Delisle_1.HandlingBaseMul = 105
	Delisle_1.HandlingNotProneMul = 100
	Delisle_1.PenetrationClass = 1
	Delisle_1.ShootAP = 4000
	Delisle_1.ReloadAP = 3000
	Delisle_1.APStance = 40
	Delisle_1.OverwatchAngle = 1360
	Delisle_1.MagazineSize = 7
	Delisle_1.Cumbersome = 0
	Delisle_1.Noise = 20
	Delisle_1.PointBlankBonus = 1
	Delisle_1.PreparedAttackType = "Both"
	Delisle_1.AvailableAttacks = {"SingleShot", "CancelShot"}
	Delisle_1.Rat_swap_ap = 3
	Delisle_1.wep_base_recoil_mul = 112
	Delisle_1.wep_base_snapshot_mul = 89
	Delisle_1.wep_base_hip_mul = 110
	Delisle_1.weigth_held_mul = 128
	Delisle_1.burst_selective = false
	Delisle_1.recoil_mechanism = "Bolt_Action"
	Delisle_1.Rat_cycling = "BoltAction"
	Delisle_1.rat_scope_block = false
	Delisle_1.pistol_swap = false
	Delisle_1.default_long_barrel = false
	Delisle_1.unwieldy_weapon = false
	Delisle_1.rat_barrel_len = 220
	Delisle_1.ScrapParts = 8
	Delisle_1.RepairCost = 70
	Delisle_1.Reliability = 95
	Delisle_1.LargeItem = 1
	Delisle_1.HandSlot = "TwoHanded"
	Delisle_1.AdditionalHint = T( 528620989138, [[<description_hints>]] )
	Delisle_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'RAT_TOG_suppressor', Modifiable = false, AvailableComponents = {'RAT_TOG_suppressor', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'Bolt_action', Modifiable = true, AvailableComponents = {'Bolt_action', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'stealth_ironsight_confidante', Modifiable = true, AvailableComponents = {'stealth_ironsight_confidante', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'DeLisle_stock_def_1', Modifiable = true, AvailableComponents = {'DeLisle_stock_def_1', 'DeLisle_stock_erg_1', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'DeLisle_barrel_def_1', Modifiable = false, AvailableComponents = {'DeLisle_barrel_def_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'DeLisle_mag_def_1', Modifiable = false, AvailableComponents = {'DeLisle_mag_def_1', }}}
	Delisle_1.Valuable = 0
	Delisle_1.CanAppearInShop = true
	Delisle_1.CanAppearUsed = true
	Delisle_1.Tier = 1
	Delisle_1.MaxStock = 1
	Delisle_1.RestockWeight = 20
	Delisle_1.CategoryPair = "Rifles"
	Delisle_1.fxClass = "AK47"
	Delisle_1.Description = T(616470478099, [[<style PerkststsBold ><scale 550>De Lisle Commando carbine was a British firearm used during World War II that was designed with an integrated suppressor. That, combined with its use of subsonic ammunition, made it extremely quiet in action, possibly one of the quietest firearms ever made.<newline><newline>The weapon was designed as a private venture by William Godfray de Lisle (known as Godfray), an engineer who worked for the Air Ministry. In 1943, he approached Major Sir Malcolm Campbell with his prototype<newline><newline>Subsequent official firing tests recorded the De Lisle produced 85.5 dB of noise when fired. As a comparison, modern testing on a selection of handguns has shown that they produce 156 to 168 dB when firing without a suppressor, and 117 to 140 dB when firing with one fitted. The De Lisle's quietness was found to be comparable to the British Welrod pistol<newline><newline>A number of De Lisles were shipped to the Far East and used during the Burma Campaign. The De Lisle would also be used during the Korean War and the Malayan Emergency. It has been claimed the weapon was also used by the Special Air Service during the Northern Irish Troubles.
<newline><newline><style MMOptionEntry>Made in England <image UI/Icons/Flags/f_england.dds 1600>]])
	Delisle_1.PenetrationClass = 1


	VSK94_1.is_tog_patched = true
	VSK94_1.is_vanilla_firearm = false
	VSK94_1.object_class = "SniperRifle"
	VSK94_1.Cost = 3300
	VSK94_1.Damage = 24
	VSK94_1.ObjDamageMod = 100
	VSK94_1.CritChance = 0
	VSK94_1.CritChanceScaled = 10
	storeProps(VSK94_1, "AimAccuracy", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VSK94_1, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VSK94_1, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VSK94_1, "WeaponRange", 28, "oldCTH", GBO_gCTHModeItemPropertyTable)
	VSK94_1.PBbonus_base = 8
	VSK94_1.HandlingBaseMul = 100
	VSK94_1.PenetrationClass = 1
	VSK94_1.ShootAP = 4000
	VSK94_1.ReloadAP = 3000
	VSK94_1.APStance = 30
	VSK94_1.OverwatchAngle = 1335
	VSK94_1.MagazineSize = 20
	VSK94_1.Cumbersome = 0
	VSK94_1.Noise = 28
	VSK94_1.PointBlankBonus = 1
	VSK94_1.PreparedAttackType = "Both"
	VSK94_1.AvailableAttacks = {"SingleShot", "BurstFire", "CancelShot", "AutoFire", "RunAndGun"}
	VSK94_1.Rat_swap_ap = 3
	VSK94_1.wep_base_recoil_mul = 115
	VSK94_1.wep_base_snapshot_mul = 90
	VSK94_1.wep_base_hip_mul = 108
	VSK94_1.weigth_held_mul = 127
	VSK94_1.burst_selective = false
	VSK94_1.burst_recoil_delta = 110
	VSK94_1.long_recoil_delta = 110
	VSK94_1.auto_recoil_delta = 110
	VSK94_1.recoil_mechanism = "Gas_Operated"
	VSK94_1.Rat_cycling = "Auto"
	VSK94_1.rat_scope_block = true
	VSK94_1.pistol_swap = false
	VSK94_1.default_long_barrel = false
	VSK94_1.unwieldy_weapon = false
	VSK94_1.rat_barrel_len = 250
	VSK94_1.rat_weigth = 3800
	VSK94_1.Weigth = 3800
	VSK94_1.ScrapParts = 14
	VSK94_1.RepairCost = 80
	VSK94_1.Reliability = 83
	VSK94_1.LargeItem = 1
	VSK94_1.HandSlot = "TwoHanded"
	VSK94_1.AdditionalHint = T( 500671780217, [[<description_hints>]] )
	VSK94_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'VSK94_Stock_hvy_1', Modifiable = true, AvailableComponents = {'VSK94_Stock_hvy_1', 'VSK94_Pistolgrip_1', 'VSK94_stock_unfld_1', 'VSK94_stock_fld_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'VSK94_Mag_def_1', Modifiable = true, AvailableComponents = {'VSK94_Mag_def_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'LROptics_DragunovDefault', 'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_LRoptics', 'RAT_TOG_LRoptics_advanced', 'RAT_TOG_Prism', 'RAT_TOG_thermal', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'VSK94_barrel_def_1', Modifiable = false, AvailableComponents = {'VSK94_barrel_def_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'RAT_VSK_Suppressor', Modifiable = true, AvailableComponents = {'RAT_VSK_Suppressor', }}}
	VSK94_1.Valuable = 0
	VSK94_1.CanAppearInShop = true
	VSK94_1.CanAppearUsed = true
	VSK94_1.Tier = 2
	VSK94_1.MaxStock = 1
	VSK94_1.RestockWeight = 20
	VSK94_1.CategoryPair = "Rifles"
	VSK94_1.Description = T(218260476236, [[<style PerkststsBold ><scale 600>The VSK-94 is a 9x39mm suppressed designated marksman rifle designed in 1995 in the KBP Instrument Design Bureau<newline><newline>The VSK-94 retains the gas-driven operating principle of the 9A-91 with a rotating bolt and hammer fire mechanism. The rifle features a stamped steel receiver, skeletonized polymer stock integrated with the pistol grip and a synthetic forearm. The VSK-94 is equipped with a 4x PSO-1 optical sight (adapted for subsonic rounds shooting) and standard flip iron sights from the 9A-91.<newline><newline>Since the 9x39mm bullet weighs about twice as much as that of the 9×19mm Parabellum, its muzzle energy is about twice as high as that of a subsonic 9×19mm Parabellum bullet fired from an HK MP5SD<newline><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	VSK94_1.PenetrationClass = 1


	HK53_1.is_tog_patched = true
	HK53_1.is_vanilla_firearm = false
	HK53_1.object_class = "SubmachineGun"
	HK53_1.__parents[1] = "SubmachineGun"
	HK53_1.Cost = 8310
	HK53_1.Damage = 22
	HK53_1.ObjDamageMod = 100
	HK53_1.CritChance = 0
	HK53_1.CritChanceScaled = 10
	storeProps(HK53_1, "AimAccuracy", 25, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK53_1, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK53_1, "WeaponRange", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK53_1, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	HK53_1.PBbonus_base = 8
	HK53_1.HandlingBaseMul = 100
	HK53_1.PenetrationClass = 1
	HK53_1.ShootAP = 3000
	HK53_1.ReloadAP = 3000
	HK53_1.APStance = 30
	HK53_1.OverwatchAngle = 1488
	HK53_1.MagazineSize = 10
	HK53_1.Cumbersome = 0
	HK53_1.Noise = 20
	HK53_1.PointBlankBonus = 1
	HK53_1.PreparedAttackType = "Overwatch"
	HK53_1.AvailableAttacks = {"BurstFire", "SingleShot", "CancelShot", "RunAndGun"}
	HK53_1.wep_base_recoil_mul = 118
	HK53_1.wep_base_snapshot_mul = 82
	HK53_1.wep_base_hip_mul = 109
	HK53_1.weigth_held_mul = 125
	HK53_1.burst_selective = false
	HK53_1.recoil_mechanism = "Roller_Delayed"
	HK53_1.Rat_cycling = "Auto"
	HK53_1.rat_scope_block = false
	HK53_1.pistol_swap = false
	HK53_1.default_long_barrel = false
	HK53_1.unwieldy_weapon = false
	HK53_1.rat_barrel_len = 240
	HK53_1.rat_weigth = 3500
	HK53_1.Weigth = 3500
	HK53_1.ScrapParts = 10
	HK53_1.RepairCost = 80
	HK53_1.Reliability = 84
	HK53_1.LargeItem = 1
	HK53_1.HandSlot = "TwoHanded"
	HK53_1.AdditionalHint = T( 123942705172, [[<description_hints>]] )
	HK53_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'hk33_barrel_def_1', Modifiable = true, AvailableComponents = {'hk33_barrel_def_1', }}, {CanBeEmpty = false, SlotType = 'Side2', DefaultComponent = 'side_2_empty', Modifiable = true, AvailableComponents = {'ToG_Flashlight_2', 'ToG_Red_Dot_2', 'ToG_UV_Dot_2', 'side_2_empty', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'hk33_muzzle_1', Modifiable = true, AvailableComponents = {'RAT_TOG_suppressor', 'ImprovisedSuppressor', 'hk33_muzzle_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'hk33_magazine_11', Modifiable = true, AvailableComponents = {'hk33_magazine_11', 'hk33_magazine_31', 'hk33_drum_mag_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'HK53_stock_unfld_1', Modifiable = true, AvailableComponents = {'hk53_Stock_heavy', 'HK53_stock_unfld_1', }}, {CanBeEmpty = false, SlotType = 'Handguard', DefaultComponent = 'hk33_handguard_cl_1', Modifiable = true, AvailableComponents = {'hk33_handguard_cl_1', 'hk33_handguard_new_1', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'hk33_lower_modern_1', Modifiable = true, AvailableComponents = {'hk33_lower_classic_1', 'hk33_lower_modern_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex', 'RAT_TOG_ACOG', 'RAT_TOG_compactRS', 'RAT_TOG_Prism', 'RAT_TOG_vigilanceRS', 'RAT_TOG_thermal', 'RAT_TOG_WideScope', }}}
	HK53_1.Valuable = 1
	HK53_1.CanAppearInShop = true
	HK53_1.CanAppearUsed = true
	HK53_1.Tier = 2
	HK53_1.MaxStock = 1
	HK53_1.RestockWeight = 50
	HK53_1.CategoryPair = "SubmachineGuns"
	HK53_1.fxClass = "G36"
	HK53_1.Description = T(326107292886, [[<style PerkststsBold ><scale 600>The HK 53 is a compact assault rifle of German origin and the short carbine variant of the HK 33 rifle. It is often classified as a sub machine gun due to its compact size.<newline><newline>A number of police forces and militaries adopted the HK53 for a variety of roles. Special forces units around the world including the British SAS, Royal Military Police Close Protection Unit and Royal Marines, designated the L101A1 in British service, who typically used it during close protection duties and operations involving close quarter battle.<newline><newline>During its service life the HK53 went through a series of changes to furniture mouldings, buttstock types and fire selector options. It remained in production into the early 2000s, when the HK33 and HK53 where replaced with the G36 and G36K<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	HK53_1.PenetrationClass = 1


	P90_2.is_tog_patched = true
	P90_2.is_vanilla_firearm = false
	P90_2.object_class = "SubmachineGun"
	P90_2.ItemType = "SMG"
	P90_2.Cost = 6540
	P90_2.Damage = 17
	P90_2.ObjDamageMod = 100
	P90_2.CritChance = 0
	P90_2.CritChanceScaled = 10
	storeProps(P90_2, "AimAccuracy", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(P90_2, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(P90_2, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(P90_2, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	P90_2.PBbonus_base = 9
	P90_2.HandlingBaseMul = 100
	P90_2.PenetrationClass = 1
	P90_2.ShootAP = 3000
	P90_2.ReloadAP = 5000
	P90_2.APStance = 20
	P90_2.OverwatchAngle = 1363
	P90_2.MagazineSize = 50
	P90_2.Cumbersome = 0
	P90_2.Noise = 20
	P90_2.PointBlankBonus = 1
	P90_2.PreparedAttackType = "Overwatch"
	P90_2.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
	P90_2.burst_shots = 4
	P90_2.auto_shots = 12
	P90_2.wep_base_recoil_mul = 113
	P90_2.wep_base_snapshot_mul = 88
	P90_2.wep_base_hip_mul = 108
	P90_2.weigth_held_mul = 122
	P90_2.burst_selective = false
	P90_2.recoil_mechanism = "Blowback"
	P90_2.Rat_cycling = "Auto"
	P90_2.rat_scope_block = false
	P90_2.pistol_swap = false
	P90_2.default_long_barrel = false
	P90_2.unwieldy_weapon = false
	P90_2.rat_barrel_len = 260
	P90_2.rat_weigth = 3200
	P90_2.Weigth = 3200
	P90_2.ScrapParts = 15
	P90_2.RepairCost = 80
	P90_2.Reliability = 84
	P90_2.LargeItem = 1
	P90_2.HandSlot = "TwoHanded"
	P90_2.AdditionalHint = T( 157356398627, [[<description_hints>]] )
	P90_2.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', 'ReflexSightAdvanced', 'LROptics', 'ScopeCOGQuick', 'ScopeCOG', '_ReflexSIghtVigilance', 'WideScope', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'ToG_Comp_AR_Barrel_Long_1_SMG', 'ToG_Comp_AR_Barrel_Long_2_SMG', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'ToG_VFX_Muzzle', 'RAT_TOG_suppressor', 'RAT_TOG_compensator', }}, {CanBeEmpty = false, SlotType = 'General', DefaultComponent = 'bullup', Modifiable = false, AvailableComponents = {'bullup', }}}
	P90_2.Valuable = 0
	P90_2.CanAppearInShop = true
	P90_2.CanAppearUsed = true
	P90_2.Tier = 2
	P90_2.MaxStock = 2
	P90_2.RestockWeight = 50
	P90_2.CategoryPair = "SubmachineGuns"
	P90_2.Icon = "Mod/Dau6w/Images/P90_icon_new_scaled3.png"
	P90_2.fxClass = "MP5K"
	P90_2.Description = T(788185092104, [[<style PerkststsBold ><scale 600>The P90 is a submachine gun chambered for the 5.7×28mm cartridge, also classified as a personal defense weapon. Created in response to NATO requests for a replacement for 9×19mm Parabellum firearms, the P90 was designed as a compact but powerful firearm for vehicle crews, operators of crew-served weapons, support personnel, special forces, and counter-terrorist groups.
<newline><newline><style MMOptionEntry>Made in Belgium]])
	P90_2.PenetrationClass = 1


	UMP_1.is_tog_patched = true
	UMP_1.is_vanilla_firearm = false
	UMP_1.object_class = "SubmachineGun"
	UMP_1.ItemType = "SMG"
	UMP_1.Cost = 3700
	UMP_1.Damage = 22
	UMP_1.ObjDamageMod = 100
	UMP_1.CritChance = 0
	UMP_1.CritChanceScaled = 10
	storeProps(UMP_1, "AimAccuracy", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UMP_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UMP_1, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UMP_1, "WeaponRange", 24, "oldCTH", GBO_gCTHModeItemPropertyTable)
	UMP_1.PBbonus_base = 9
	UMP_1.HandlingBaseMul = 100
	UMP_1.PenetrationClass = 1
	UMP_1.ShootAP = 3000
	UMP_1.ReloadAP = 3000
	UMP_1.APStance = 30
	UMP_1.OverwatchAngle = 1456
	UMP_1.MagazineSize = 25
	UMP_1.Cumbersome = 0
	UMP_1.Noise = 20
	UMP_1.PointBlankBonus = 1
	UMP_1.PreparedAttackType = "Overwatch"
	UMP_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
	UMP_1.wep_base_recoil_mul = 117
	UMP_1.wep_base_snapshot_mul = 84
	UMP_1.wep_base_hip_mul = 109
	UMP_1.weigth_held_mul = 117
	UMP_1.burst_selective = false
	UMP_1.recoil_mechanism = "Blowback"
	UMP_1.Rat_cycling = "Auto"
	UMP_1.rat_scope_block = false
	UMP_1.pistol_swap = false
	UMP_1.default_long_barrel = false
	UMP_1.unwieldy_weapon = false
	UMP_1.rat_barrel_len = 225
	UMP_1.rat_weigth = 2500
	UMP_1.Weigth = 2500
	UMP_1.ScrapParts = 15
	UMP_1.RepairCost = 80
	UMP_1.Reliability = 86
	UMP_1.LargeItem = 1
	UMP_1.HandSlot = "TwoHanded"
	UMP_1.AdditionalHint = T( 863330837058, [[<description_hints>]] )
	UMP_1.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_suppressor_762', 'ImprovisedSuppressor', 'MuzzleBooster', 'RAT_TOG_compensator', }}, {CanBeEmpty = true, SlotType = 'Side', Modifiable = true, AvailableComponents = {'Flashlight', 'FlashlightDot', 'LaserDot', 'UVDot', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', 'ReflexSightAdvanced', 'LROptics', '_ReflexSIghtVigilance', 'ScopeCOGQuick', 'ScopeCOG', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockLight', Modifiable = true, AvailableComponents = {'StockLight', }}}
	UMP_1.Valuable = 0
	UMP_1.CanAppearInShop = true
	UMP_1.CanAppearUsed = true
	UMP_1.Tier = 2
	UMP_1.MaxStock = 2
	UMP_1.RestockWeight = 50
	UMP_1.CategoryPair = "SubmachineGuns"
	UMP_1.fxClass = "MP5K"
	UMP_1.Description = T(919036161362, [[<style PerkststsBold ><scale 600>The UMP (Universale Maschinenpistole, German for "Universal Machine Pistol") is a submachine, developed the as a lighter and cheaper successor to the MP5, though both remain in production.
<newline>
The UMP has been adopted for use by various countries including Brazil, Canada, and the United States.<newline><newline>A small number of UMPs chambered in .45 ACP were officially purchased by the 5th Special Forces Group of the United States Army Special Forces, with some of the weapons seeing limited service in the early years of the Iraqi insurgency, making them one of the more popular submachine guns being deployed by the U.S. military personnel in recent conflicts around the world.
<newline><newline><style MMOptionEntry>Made in Germany <image UI/Icons/Flags/f_germany.dds 1600>]])
	UMP_1.PenetrationClass = 1


	MicroUZI_1.is_tog_patched = true
	MicroUZI_1.is_vanilla_firearm = false
	MicroUZI_1.object_class = "SubmachineGun"
	MicroUZI_1.Cost = 2200
	MicroUZI_1.Damage = 15
	MicroUZI_1.ObjDamageMod = 100
	MicroUZI_1.CritChance = 0
	MicroUZI_1.CritChanceScaled = 10
	storeProps(MicroUZI_1, "AimAccuracy", 19, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MicroUZI_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MicroUZI_1, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MicroUZI_1, "WeaponRange", 24, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MicroUZI_1.PBbonus_base = 11
	MicroUZI_1.HandlingBaseMul = 95
	MicroUZI_1.PenetrationClass = 1
	MicroUZI_1.ShootAP = 3000
	MicroUZI_1.ReloadAP = 3000
	MicroUZI_1.APStance = 20
	MicroUZI_1.OverwatchAngle = 1547
	MicroUZI_1.MagazineSize = 20
	MicroUZI_1.Cumbersome = 0
	MicroUZI_1.Noise = 20
	MicroUZI_1.PointBlankBonus = 1
	MicroUZI_1.PreparedAttackType = "Overwatch"
	MicroUZI_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "DualShot", "RunAndGun", "CancelShot"}
	MicroUZI_1.burst_shots = 4
	MicroUZI_1.auto_shots = 12
	MicroUZI_1.Rat_swap_ap = 1
	MicroUZI_1.wep_base_recoil_mul = 117
	MicroUZI_1.wep_base_snapshot_mul = 79
	MicroUZI_1.wep_base_hip_mul = 114
	MicroUZI_1.weigth_held_mul = 119
	MicroUZI_1.burst_selective = false
	MicroUZI_1.recoil_mechanism = "Blowback"
	MicroUZI_1.Rat_cycling = "Auto"
	MicroUZI_1.rat_scope_block = false
	MicroUZI_1.pistol_swap = true
	MicroUZI_1.default_long_barrel = false
	MicroUZI_1.unwieldy_weapon = false
	MicroUZI_1.rat_barrel_len = 144
	MicroUZI_1.rat_weigth = 2700
	MicroUZI_1.Weigth = 2700
	MicroUZI_1.ScrapParts = 6
	MicroUZI_1.RepairCost = 80
	MicroUZI_1.Reliability = 83
	MicroUZI_1.LargeItem = 0
	MicroUZI_1.HandSlot = "OneHanded"
	MicroUZI_1.AdditionalHint = T( 118830685302, [[<description_hints>
<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded]] )
	MicroUZI_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'MicroUZI_Barrel_def_1', Modifiable = true, AvailableComponents = {'MicroUZI_Barrel_def_1', 'MicroUZI_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MicroUZI_Mag_def_1', Modifiable = true, AvailableComponents = {'MicroUZI_Mag_def_1', 'MicroUZI_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Scope', DefaultComponent = 'MicroUZI_Scope_def_1', Modifiable = true, AvailableComponents = {'RAT_TOG_Reflex_pistol', 'RAT_TOG_compactRS', 'RAT_TOG_laser_dot', 'RAT_TOG_uv_dot', 'RAT_TOG_vigilanceRS', 'MicroUZI_Scope_def_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_compensator', 'RAT_TOG_suppressor', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockNo', Modifiable = true, AvailableComponents = {'StockNo', }}}
	MicroUZI_1.Valuable = 0
	MicroUZI_1.CanAppearInShop = true
	MicroUZI_1.CanAppearUsed = true
	MicroUZI_1.Tier = 1
	MicroUZI_1.MaxStock = 2
	MicroUZI_1.RestockWeight = 40
	MicroUZI_1.CategoryPair = "SubmachineGuns"
	MicroUZI_1.Description = T(696572248221, [[<style PerkststsBold ><scale 600>The Micro Uzi is an even further scaled down version of the Mini Uzi, introduced in 1986.<newline><newline>It was designed as a semi-automatic, tactical pistol with high firepower. Its distinctive design is unique and recognizable at first glance. It has a blowback operating principle, manual safety with additional palm safety, adjustable sights, and a magazine capacity of 20 rounds.<newline><newline>The most significant mechanical difference between this version and the original Uzi is that the Micro Uzi fires from a closed bolt instead of an open bolt.<newline><newline><style MMOptionEntry>Made in Israel<image Mod/HXzCpFa/Icons/Flags/Israel.png 1600>]])
	MicroUZI_1.PenetrationClass = 1


	StenMK2_1.is_tog_patched = true
	StenMK2_1.is_vanilla_firearm = false
	StenMK2_1.object_class = "SubmachineGun"
	StenMK2_1.Cost = 1140
	StenMK2_1.Damage = 17
	StenMK2_1.ObjDamageMod = 100
	StenMK2_1.CritChance = 0
	StenMK2_1.CritChanceScaled = 10
	storeProps(StenMK2_1, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(StenMK2_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(StenMK2_1, "WeaponRange", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(StenMK2_1, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	StenMK2_1.PBbonus_base = 10
	StenMK2_1.HandlingBaseMul = 100
	StenMK2_1.PenetrationClass = 1
	StenMK2_1.ShootAP = 3000
	StenMK2_1.ReloadAP = 3000
	StenMK2_1.APStance = 30
	StenMK2_1.OverwatchAngle = 1426
	StenMK2_1.MagazineSize = 32
	StenMK2_1.Cumbersome = 0
	StenMK2_1.Noise = 25
	StenMK2_1.PointBlankBonus = 1
	StenMK2_1.PreparedAttackType = "Overwatch"
	StenMK2_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
	StenMK2_1.wep_base_recoil_mul = 116
	StenMK2_1.wep_base_snapshot_mul = 85
	StenMK2_1.wep_base_hip_mul = 111
	StenMK2_1.weigth_held_mul = 125
	StenMK2_1.burst_selective = false
	StenMK2_1.recoil_mechanism = "Blowback"
	StenMK2_1.Rat_cycling = "Auto"
	StenMK2_1.rat_scope_block = false
	StenMK2_1.pistol_swap = false
	StenMK2_1.default_long_barrel = false
	StenMK2_1.unwieldy_weapon = false
	StenMK2_1.rat_barrel_len = 196
	StenMK2_1.rat_weigth = 3500
	StenMK2_1.Weigth = 3500
	StenMK2_1.ScrapParts = 5
	StenMK2_1.RepairCost = 40
	StenMK2_1.Reliability = 70
	StenMK2_1.LargeItem = 1
	StenMK2_1.HandSlot = "TwoHanded"
	StenMK2_1.AdditionalHint = T( 615691579287, [[<description_hints>]] )
	StenMK2_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'Sten_mag_def_1', Modifiable = false, AvailableComponents = {'Sten_mag_def_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'StockLight', Modifiable = true, AvailableComponents = {'StockLight', }}}
	StenMK2_1.Valuable = 0
	StenMK2_1.CanAppearInShop = true
	StenMK2_1.CanAppearUsed = true
	StenMK2_1.Tier = 1
	StenMK2_1.MaxStock = 3
	StenMK2_1.RestockWeight = 50
	StenMK2_1.CategoryPair = "SubmachineGuns"
	StenMK2_1.Description = T(351352336825, [[<style PerkststsBold ><scale 600>The STEN (or Sten gun) is a British submachine gun chambered in 9×19mm which was used extensively by British and Commonwealth forces throughout World War II and post war including the Korean War.<newline><newline>The Sten was a simple design with very low production cost for mass production to meet demand for submachine guns. As well as equipping regular units, the Sten was distributed to resistance groups within occupied Europe; its simple design making it an effective insurgency weapon for resistance groups.<newline><newline>Around four million Stens in various versions were made in the 1940s, making it the second most produced submachine gun of the Second World War, after the Soviet PPSh-41. The Sten served as the basis for the Sterling submachine gun, which replaced the Sten in British service from the 1950s. The Mark II was the most common mainstream variant, with two million units produced.<newline><newline><style MMOptionEntry>Made in England <image UI/Icons/Flags/f_england.dds 1600>]])
	StenMK2_1.PenetrationClass = 1


	PP91_1.is_tog_patched = true
	PP91_1.is_vanilla_firearm = false
	PP91_1.object_class = "SubmachineGun"
	PP91_1.Cost = 1850
	PP91_1.Damage = 16
	PP91_1.ObjDamageMod = 100
	PP91_1.CritChanceScaled = 10
	storeProps(PP91_1, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PP91_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PP91_1, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PP91_1, "WeaponRange", 24, "oldCTH", GBO_gCTHModeItemPropertyTable)
	PP91_1.PBbonus_base = 11
	PP91_1.HandlingBaseMul = 100
	PP91_1.PenetrationClass = 1
	PP91_1.ShootAP = 3000
	PP91_1.ReloadAP = 3000
	PP91_1.APStance = 20
	PP91_1.OverwatchAngle = 1528
	PP91_1.MagazineSize = 20
	PP91_1.Cumbersome = 0
	PP91_1.Noise = 20
	PP91_1.PointBlankBonus = 1
	PP91_1.PreparedAttackType = "Overwatch"
	PP91_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
	PP91_1.Rat_swap_ap = 1
	PP91_1.wep_base_recoil_mul = 121
	PP91_1.wep_base_snapshot_mul = 80
	PP91_1.wep_base_hip_mul = 112
	PP91_1.weigth_held_mul = 117
	PP91_1.burst_selective = false
	PP91_1.recoil_mechanism = "Blowback"
	PP91_1.Rat_cycling = "Auto"
	PP91_1.rat_scope_block = true
	PP91_1.pistol_swap = false
	PP91_1.default_long_barrel = false
	PP91_1.unwieldy_weapon = false
	PP91_1.rat_barrel_len = 170
	PP91_1.rat_weigth = 2500
	PP91_1.Weigth = 2500
	PP91_1.ScrapParts = 10
	PP91_1.RepairCost = 50
	PP91_1.Reliability = 82
	PP91_1.LargeItem = 0
	PP91_1.HandSlot = "OneHanded"
	PP91_1.AdditionalHint = T( 183411732483, [[<description_hints>]] )
	PP91_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'PP91_Barrel_def_1', Modifiable = true, AvailableComponents = {'PP91_Barrel_def_1', 'PP91_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'PP91_Mag_def_1', Modifiable = true, AvailableComponents = {'PP91_Mag_def_1', 'PP91_Mag_ext_1', }}, {CanBeEmpty = false, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'Compensator', 'MuzzleBooster', 'Suppressor', 'ImprovisedSuppressor', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'PP91_Stock_fld_1', Modifiable = true, AvailableComponents = {'PP91_Stock_fld_1', 'PP91_Stock_unfld_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_ACOG', 'RAT_TOG_WideScope', 'RAT_TOG_Reflex', 'RAT_TOG_compactRS', 'RAT_TOG_vigilanceRS', }}}
	PP91_1.Valuable = 0
	PP91_1.CanAppearInShop = true
	PP91_1.CanAppearUsed = true
	PP91_1.Tier = 1
	PP91_1.MaxStock = 3
	PP91_1.RestockWeight = 60
	PP91_1.CategoryPair = "SubmachineGuns"
	PP91_1.Description = T(112464140424, [[<style PerkststsBold ><scale 600>The PP-91 Kedr is a 9mm machine pistol developed from a prototype from the 1970s and since 1994 adopted by the Russian Ministry of Internal Affairs.<newline><newline>It is blowback operated and fires from a closed bolt, allowing for more accurate shooting than would be possible from an open bolt design. Ammunition is fed from a double column box magazine and it is supplied with folding shoulder stock.<newline><newline>Despite the small caliber of the round it uses, the notable advantages of the PP-91 are its compact size and the weight of only 1.5 kg, making it very easy to carry, and can be fired effectively by only one hand. The safety/selector lever is located on the right hand side and allows for semi-automatic single shots and fully automatic fire at the rate of 800 rounds per minute. The effective range of the PP-91 is between 50-100m<newline><newline><style MMOptionEntry>Made in Russia <image UI/Icons/Flags/f_russia.dds 1600>]])
	PP91_1.PenetrationClass = 1


	MAC11_1.is_tog_patched = true
	MAC11_1.is_vanilla_firearm = false
	MAC11_1.object_class = "SubmachineGun"
	MAC11_1.Cost = 1700
	MAC11_1.Damage = 16
	MAC11_1.ObjDamageMod = 100
	MAC11_1.CritChance = 0
	MAC11_1.CritChanceScaled = 10
	storeProps(MAC11_1, "AimAccuracy", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MAC11_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MAC11_1, "WeaponRange", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MAC11_1, "WeaponRange", 24, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MAC11_1.PBbonus_base = 11
	MAC11_1.HandlingBaseMul = 100
	MAC11_1.PenetrationClass = 1
	MAC11_1.ShootAP = 3000
	MAC11_1.ReloadAP = 3000
	MAC11_1.APStance = 25
	MAC11_1.OverwatchAngle = 1532
	MAC11_1.MagazineSize = 32
	MAC11_1.Cumbersome = 0
	MAC11_1.Noise = 20
	MAC11_1.PointBlankBonus = 1
	MAC11_1.PreparedAttackType = "Overwatch"
	MAC11_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "DualShot", "RunAndGun", "CancelShot"}
	MAC11_1.burst_shots = 4
	MAC11_1.auto_shots = 12
	MAC11_1.Rat_swap_ap = 1
	MAC11_1.wep_base_recoil_mul = 122
	MAC11_1.wep_base_snapshot_mul = 80
	MAC11_1.wep_base_hip_mul = 114
	MAC11_1.weigth_held_mul = 120
	MAC11_1.burst_selective = false
	MAC11_1.recoil_mechanism = "Blowback"
	MAC11_1.Rat_cycling = "Auto"
	MAC11_1.rat_scope_block = true
	MAC11_1.pistol_swap = false
	MAC11_1.default_long_barrel = false
	MAC11_1.unwieldy_weapon = false
	MAC11_1.rat_barrel_len = 148
	MAC11_1.rat_weigth = 2840
	MAC11_1.Weigth = 2840
	MAC11_1.ScrapParts = 6
	MAC11_1.RepairCost = 80
	MAC11_1.Reliability = 78
	MAC11_1.LargeItem = 0
	MAC11_1.HandSlot = "OneHanded"
	MAC11_1.AdditionalHint = T( 681827100466, [[<description_hints>]] )
	MAC11_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'Mac11_Barrel_def_1', Modifiable = true, AvailableComponents = {'Mac11_Barrel_def_1', 'Mac11_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'Mac11_Mag_def_1', Modifiable = true, AvailableComponents = {'Mac11_Mag_def_1', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'RAT_TOG_vigilanceRS', 'RAT_TOG_compactRS', 'RAT_TOG_Reflex_pistol', 'RAT_TOG_uv_dot', 'RAT_TOG_laser_dot', }}, {CanBeEmpty = false, SlotType = 'Muzzle', DefaultComponent = 'ToG_VFX_Muzzle', Modifiable = true, AvailableComponents = {'RAT_TOG_compensator', 'RAT_TOG_suppressor', 'ToG_VFX_Muzzle', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'Mac11_Stock_fld_1', Modifiable = true, AvailableComponents = {'Mac11_Stock_fld_1', 'Mac11_Stock_unfld_1', }}}
	MAC11_1.Valuable = 0
	MAC11_1.CanAppearInShop = true
	MAC11_1.CanAppearUsed = true
	MAC11_1.Tier = 1
	MAC11_1.MaxStock = 3
	MAC11_1.RestockWeight = 70
	MAC11_1.CategoryPair = "SubmachineGuns"
	MAC11_1.Description = T(247259528688, [[<style PerkststsBold ><scale 650>The Model-11 is a machine pistol/submachine gun developed by American firearm designer Gordon Ingram during the 1970s<newline><newline>Like the larger M-10, the M-11 has iron sights with the rear pinhole sight welded to the receiver. These sights are for use with the folding stock, as using them without the stock is nearly useless because of the initial jump of the weapon due to its heavy, open-bolt design.<newline><newline>The rate of fire of the M-11A1 is one of the biggest complaints about the firearm. Listed as 1,200 rounds per minute, the M-11's high cyclic rate is able to empty the entire 32-round magazine in about two seconds, which many users view as a drawback.<newline><newline>Noting the weapon's poor accuracy, in the 1970s International Association of Police Chiefs weapons researcher David Steele described the M series as "fit only for combat in a phone booth".<newline><newline><style MMOptionEntry>Made in USA <image UI/Icons/Flags/f_usa.dds 1600>]])
	MAC11_1.PenetrationClass = 1


	VigM2_1.is_tog_patched = true
	VigM2_1.is_vanilla_firearm = false
	VigM2_1.object_class = "SubmachineGun"
	VigM2_1.Cost = 540
	VigM2_1.Damage = 18
	VigM2_1.ObjDamageMod = 100
	VigM2_1.CritChance = 0
	VigM2_1.CritChanceScaled = 10
	storeProps(VigM2_1, "AimAccuracy", 15, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VigM2_1, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VigM2_1, "WeaponRange", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(VigM2_1, "WeaponRange", 24, "oldCTH", GBO_gCTHModeItemPropertyTable)
	VigM2_1.PBbonus_base = 10
	VigM2_1.HandlingBaseMul = 100
	VigM2_1.PenetrationClass = 1
	VigM2_1.ShootAP = 3000
	VigM2_1.ReloadAP = 3000
	VigM2_1.APStance = 20
	VigM2_1.OverwatchAngle = 1463
	VigM2_1.MagazineSize = 32
	VigM2_1.Cumbersome = 0
	VigM2_1.Noise = 10
	VigM2_1.PointBlankBonus = 1
	VigM2_1.PreparedAttackType = "Overwatch"
	VigM2_1.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "DualShot", "RunAndGun", "CancelShot"}
	VigM2_1.Rat_swap_ap = 1
	VigM2_1.wep_base_recoil_mul = 120
	VigM2_1.wep_base_snapshot_mul = 83
	VigM2_1.wep_base_hip_mul = 111
	VigM2_1.weigth_held_mul = 121
	VigM2_1.burst_selective = false
	VigM2_1.recoil_mechanism = "Blowback"
	VigM2_1.Rat_cycling = "Auto"
	VigM2_1.rat_scope_block = false
	VigM2_1.pistol_swap = false
	VigM2_1.default_long_barrel = false
	VigM2_1.unwieldy_weapon = false
	VigM2_1.rat_barrel_len = 196
	VigM2_1.rat_weigth = 2950
	VigM2_1.Weigth = 2950
	VigM2_1.ScrapParts = 5
	VigM2_1.RepairCost = 75
	VigM2_1.Reliability = 76
	VigM2_1.LargeItem = 1
	VigM2_1.HandSlot = "TwoHanded"
	VigM2_1.AdditionalHint = T( 595870360399, [[<description_hints>]] )
	VigM2_1.ComponentSlots = {{CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'VigM2_Barrel_def_1', Modifiable = true, AvailableComponents = {'VigM2_Barrel_shrt_1', 'VigM2_Barrel_def_1', 'VigM2_Barrel_ext_1', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'VigM2_mag_def_1', Modifiable = true, AvailableComponents = {'VigM2_mag_def_1', }}, {CanBeEmpty = false, SlotType = 'Stock', DefaultComponent = 'VigM2_Stock_unfld_1', Modifiable = true, AvailableComponents = {'VigM2_Stock_unfld_1', }}}
	VigM2_1.Valuable = 0
	VigM2_1.CanAppearInShop = true
	VigM2_1.CanAppearUsed = true
	VigM2_1.Tier = 1
	VigM2_1.MaxStock = 3
	VigM2_1.RestockWeight = 80
	VigM2_1.CategoryPair = "SubmachineGuns"
	VigM2_1.Description = T(714227871457, [[<style PerkststsBold ><scale 550>The Vigneron is a submachine gun manufactured in Belgium during the 1950s. It used the 9×19mm NATO cartridge and was used by the Belgian Army until the 1980s.It remains reasonably accurate up to 100 m using sighted semi-automatic fire.<newline><newline>After World War II the Belgian Army was equipped with a mixture of British and American guns. The army wanted to replace these weapons with modern designs of preferable Belgian origin. The Vigneron is a simple blowback design and was made out of stamped sheet metal and a plastic grip frame. It uses the standard 9×19mm NATO round out of a 32-shot double-column, single-feed, box magazine. Army doctrine recommends to shortload the magazine to 28 rounds to prevent failures. A box type loading tool is used to assist loading the magazine.<newline><newline>Influence by some popular WW-II-era designs is apparent. The "Cutts" type barrel compensator and cooling rings are reminiscent of the Thompson submachine gun, the wire stock looks like the M3 submachine gun, the bolt design is nearly identical to the Sten and the magazine is almost the same as the one designed for the MP40. However MP40 magazines will not interchange with Vigneron magazines. Neither will fit the other weapon.<newline><newline><style MMOptionEntry>Made in Belgium <image Mod/HXzCpFa/Icons/Flags/Belgium.png 1600>]])
	VigM2_1.PenetrationClass = 1


	GBO_ApplyCHTModeItemProps(GBO_gCTHModeItemPropertyTable)

	print("RatoTOG_Patch done")
end

function RatoGBO_WepPatch()
	print("Running PATCH_GBO_weapons...")
	G36.is_vanilla_firearm = true
	G36.Cost = 9000
	G36.Damage = 23
	G36.CritChanceScaled = 20
	storeProps(G36, "AimAccuracy", 36, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G36, "AimAccuracy", 6, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G36, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(G36, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	G36.PBbonus_base = 1
	G36.HandlingBaseMul = 104
	G36.ShootAP = 3000
	G36.ReloadAP = 3000
	G36.APStance = 40
	G36.OverwatchAngle = 1023
	G36.MagazineSize = 30
	G36.Cumbersome = 0
	G36.Noise = 18
	G36.PointBlankBonus = 1
	G36.PreparedAttackType = "Overwatch"
	G36.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
	G36.burst_shots = 2
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
	storeProps(AK74, "AimAccuracy", 35, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK74, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK74, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK74, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AK74.PBbonus_base = 3
	AK74.HandlingBaseMul = 100
	AK74.ShootAP = 4000
	AK74.ReloadAP = 3000
	AK74.APStance = 40
	AK74.OverwatchAngle = 1127
	AK74.MagazineSize = 30
	AK74.Cumbersome = 0
	AK74.Noise = 22
	AK74.PointBlankBonus = 1
	AK74.PreparedAttackType = "Overwatch"
	AK74.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
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
	storeProps(AR15, "AimAccuracy", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR15, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR15, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AR15, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AR15.PBbonus_base = 2
	AR15.HandlingBaseMul = 100
	AR15.ShootAP = 4000
	AR15.ReloadAP = 3000
	AR15.APStance = 40
	AR15.OverwatchAngle = 1130
	AR15.MagazineSize = 30
	AR15.Cumbersome = 0
	AR15.Noise = 20
	AR15.PointBlankBonus = 1
	AR15.PreparedAttackType = "Overwatch"
	AR15.AvailableAttacks = {"SingleShot", "BurstFire", "CancelShot"}
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


	FNFAL.is_vanilla_firearm = true
	FNFAL.Cost = 5340
	FNFAL.Damage = 30
	FNFAL.CritChanceScaled = 10
	storeProps(FNFAL, "AimAccuracy", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNFAL, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNFAL, "WeaponRange", 36, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNFAL, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	FNFAL.PBbonus_base = -2
	FNFAL.HandlingBaseMul = 104
	FNFAL.ShootAP = 4000
	FNFAL.ReloadAP = 3000
	FNFAL.APStance = 40
	FNFAL.OverwatchAngle = 1021
	FNFAL.MagazineSize = 20
	FNFAL.Cumbersome = 0
	FNFAL.Noise = 22
	FNFAL.PointBlankBonus = 1
	FNFAL.PreparedAttackType = "Overwatch"
	FNFAL.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
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


	M14SAW_AUTO.is_vanilla_firearm = true
	M14SAW_AUTO.object_class = "AssaultRifle"
	M14SAW_AUTO.Cost = 4320
	M14SAW_AUTO.Damage = 29
	M14SAW_AUTO.CritChanceScaled = 10
	storeProps(M14SAW_AUTO, "AimAccuracy", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW_AUTO, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW_AUTO, "WeaponRange", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW_AUTO, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M14SAW_AUTO.PBbonus_base = -1
	M14SAW_AUTO.HandlingBaseMul = 110
	M14SAW_AUTO.ShootAP = 4000
	M14SAW_AUTO.ReloadAP = 3000
	M14SAW_AUTO.APStance = 40
	M14SAW_AUTO.OverwatchAngle = 870
	M14SAW_AUTO.MagazineSize = 10
	M14SAW_AUTO.Cumbersome = 0
	M14SAW_AUTO.Noise = 20
	M14SAW_AUTO.PointBlankBonus = 1
	M14SAW_AUTO.PreparedAttackType = "Overwatch"
	M14SAW_AUTO.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
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


	M14SAW.is_vanilla_firearm = true
	M14SAW.object_class = "AssaultRifle"
	M14SAW.Cost = 3600
	M14SAW.Damage = 29
	M14SAW.CritChanceScaled = 10
	storeProps(M14SAW, "AimAccuracy", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW, "WeaponRange", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M14SAW, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M14SAW.PBbonus_base = -1
	M14SAW.HandlingBaseMul = 110
	M14SAW.ShootAP = 4000
	M14SAW.ReloadAP = 3000
	M14SAW.APStance = 40
	M14SAW.OverwatchAngle = 870
	M14SAW.MagazineSize = 10
	M14SAW.Cumbersome = 0
	M14SAW.Noise = 20
	M14SAW.PointBlankBonus = 1
	M14SAW.PreparedAttackType = "Both"
	M14SAW.AvailableAttacks = {"SingleShot", "CancelShot"}
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


	M16A2.is_vanilla_firearm = true
	M16A2.object_class = "AssaultRifle"
	M16A2.Cost = 5940
	M16A2.Damage = 24
	M16A2.CritChanceScaled = 10
	storeProps(M16A2, "AimAccuracy", 33, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M16A2, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M16A2, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M16A2, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M16A2.PBbonus_base = 1
	M16A2.HandlingBaseMul = 104
	M16A2.ShootAP = 4000
	M16A2.ReloadAP = 3000
	M16A2.APStance = 40
	M16A2.OverwatchAngle = 1024
	M16A2.MagazineSize = 20
	M16A2.Cumbersome = 0
	M16A2.Noise = 18
	M16A2.PointBlankBonus = 1
	M16A2.PreparedAttackType = "Overwatch"
	M16A2.AvailableAttacks = {"BurstFire", "SingleShot", "CancelShot"}
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


	Galil_FlagHill.is_vanilla_firearm = true
	Galil_FlagHill.Cost = 7860
	Galil_FlagHill.Damage = 30
	Galil_FlagHill.CritChanceScaled = 30
	storeProps(Galil_FlagHill, "AimAccuracy", 33, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil_FlagHill, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil_FlagHill, "WeaponRange", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil_FlagHill, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Galil_FlagHill.PBbonus_base = 2
	Galil_FlagHill.HandlingBaseMul = 101
	Galil_FlagHill.ShootAP = 4000
	Galil_FlagHill.ReloadAP = 3000
	Galil_FlagHill.APStance = 40
	Galil_FlagHill.OverwatchAngle = 1080
	Galil_FlagHill.MagazineSize = 25
	Galil_FlagHill.Cumbersome = 0
	Galil_FlagHill.Noise = 22
	Galil_FlagHill.PointBlankBonus = 1
	Galil_FlagHill.PreparedAttackType = "Overwatch"
	Galil_FlagHill.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
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


	Galil.is_vanilla_firearm = true
	Galil.Cost = 7860
	Galil.Damage = 30
	Galil.CritChanceScaled = 20
	storeProps(Galil, "AimAccuracy", 33, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil, "WeaponRange", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Galil, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Galil.PBbonus_base = 3
	Galil.HandlingBaseMul = 102
	Galil.ShootAP = 4000
	Galil.ReloadAP = 3000
	Galil.APStance = 40
	Galil.OverwatchAngle = 1052
	Galil.MagazineSize = 25
	Galil.Cumbersome = 0
	Galil.Noise = 22
	Galil.PointBlankBonus = 1
	Galil.PreparedAttackType = "Overwatch"
	Galil.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
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


	Winchester1894.is_vanilla_firearm = true
	Winchester1894.object_class = "AssaultRifle"
	Winchester1894.Cost = 2700
	Winchester1894.Damage = 28
	Winchester1894.CritChanceScaled = 10
	storeProps(Winchester1894, "AimAccuracy", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester1894, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester1894, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester1894, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Winchester1894.PBbonus_base = 0
	Winchester1894.HandlingBaseMul = 102
	Winchester1894.ShootAP = 4000
	Winchester1894.ReloadAP = 3000
	Winchester1894.APStance = 40
	Winchester1894.OverwatchAngle = 1053
	Winchester1894.MagazineSize = 9
	Winchester1894.Cumbersome = 0
	Winchester1894.Noise = 20
	Winchester1894.PointBlankBonus = 1
	Winchester1894.PreparedAttackType = "Both"
	Winchester1894.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
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
	storeProps(Winchester_Quest, "AimAccuracy", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester_Quest, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester_Quest, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Winchester_Quest, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Winchester_Quest.PBbonus_base = 2
	Winchester_Quest.HandlingBaseMul = 102
	Winchester_Quest.ShootAP = 4000
	Winchester_Quest.ReloadAP = 3000
	Winchester_Quest.APStance = 40
	Winchester_Quest.OverwatchAngle = 1320
	Winchester_Quest.MagazineSize = 4
	Winchester_Quest.Cumbersome = 0
	Winchester_Quest.Noise = 30
	Winchester_Quest.PointBlankBonus = 1
	Winchester_Quest.PreparedAttackType = "Both"
	Winchester_Quest.AvailableAttacks = {"SingleShot", "CancelShot", "MobileShot"}
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


	AUG.is_vanilla_firearm = true
	AUG.Cost = 6120
	AUG.Damage = 23
	AUG.CritChanceScaled = 10
	storeProps(AUG, "AimAccuracy", 31, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AUG, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AUG, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AUG, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AUG.PBbonus_base = 0
	AUG.HandlingBaseMul = 106
	AUG.ShootAP = 4000
	AUG.ReloadAP = 3000
	AUG.APStance = 30
	AUG.OverwatchAngle = 983
	AUG.MagazineSize = 30
	AUG.Cumbersome = 0
	AUG.Noise = 20
	AUG.PointBlankBonus = 1
	AUG.PreparedAttackType = "Overwatch"
	AUG.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
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


	FAMAS.is_vanilla_firearm = true
	FAMAS.Cost = 3120
	FAMAS.Damage = 22
	FAMAS.CritChanceScaled = 10
	storeProps(FAMAS, "AimAccuracy", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FAMAS, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FAMAS, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FAMAS, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	FAMAS.PBbonus_base = 0
	FAMAS.HandlingBaseMul = 100
	FAMAS.ShootAP = 4000
	FAMAS.ReloadAP = 4000
	FAMAS.APStance = 30
	FAMAS.OverwatchAngle = 1051
	FAMAS.MagazineSize = 25
	FAMAS.Cumbersome = 0
	FAMAS.Noise = 18
	FAMAS.PointBlankBonus = 1
	FAMAS.PreparedAttackType = "Overwatch"
	FAMAS.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
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


	AK47.is_vanilla_firearm = true
	AK47.Cost = 1680
	AK47.Damage = 26
	AK47.CritChanceScaled = 10
	storeProps(AK47, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK47, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK47, "WeaponRange", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AK47, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AK47.PBbonus_base = 3
	AK47.HandlingBaseMul = 105
	AK47.ShootAP = 4000
	AK47.ReloadAP = 3000
	AK47.APStance = 40
	AK47.OverwatchAngle = 1086
	AK47.MagazineSize = 30
	AK47.Cumbersome = 0
	AK47.Noise = 22
	AK47.PointBlankBonus = 1
	AK47.PreparedAttackType = "Overwatch"
	AK47.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "CancelShot"}
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


	HK21.is_vanilla_firearm = true
	HK21.Cost = 11415
	HK21.Damage = 30
	HK21.CritChanceScaled = 10
	storeProps(HK21, "AimAccuracy", 33, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK21, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK21, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(HK21, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	HK21.PBbonus_base = -3
	HK21.HandlingBaseMul = 120
	HK21.HandlingNotProneMul = 200
	HK21.ShootAP = 4000
	HK21.ReloadAP = 5000
	HK21.APStance = 45
	HK21.OverwatchAngle = 695
	HK21.MagazineSize = 20
	HK21.Cumbersome = 1
	HK21.Noise = 22
	HK21.PointBlankBonus = 1
	HK21.PreparedAttackType = "Machine Gun"
	HK21.AvailableAttacks = {"MGBurstFire"}
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


	FNMinimi.is_vanilla_firearm = true
	FNMinimi.Cost = 11220
	FNMinimi.Damage = 23
	FNMinimi.CritChanceScaled = 10
	storeProps(FNMinimi, "AimAccuracy", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNMinimi, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNMinimi, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(FNMinimi, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	FNMinimi.PBbonus_base = -1
	FNMinimi.HandlingBaseMul = 116
	FNMinimi.HandlingNotProneMul = 195
	FNMinimi.ShootAP = 4000
	FNMinimi.ReloadAP = 5000
	FNMinimi.APStance = 45
	FNMinimi.OverwatchAngle = 781
	FNMinimi.MagazineSize = 100
	FNMinimi.Cumbersome = 0
	FNMinimi.Noise = 22
	FNMinimi.PointBlankBonus = 1
	FNMinimi.PreparedAttackType = "Machine Gun"
	FNMinimi.AvailableAttacks = {"MGBurstFire"}
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
	storeProps(RPK74, "AimAccuracy", 29, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPK74, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPK74, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(RPK74, "WeaponRange", 34, "oldCTH", GBO_gCTHModeItemPropertyTable)
	RPK74.PBbonus_base = -3
	RPK74.HandlingBaseMul = 110
	RPK74.HandlingNotProneMul = 180
	RPK74.ShootAP = 4000
	RPK74.ReloadAP = 4000
	RPK74.APStance = 40
	RPK74.OverwatchAngle = 815
	RPK74.MagazineSize = 45
	RPK74.Cumbersome = 0
	RPK74.Noise = 22
	RPK74.PointBlankBonus = 1
	RPK74.PreparedAttackType = "Machine Gun"
	RPK74.AvailableAttacks = {"MGBurstFire"}
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


	MG58.is_vanilla_firearm = true
	MG58.Cost = 3000
	MG58.Damage = 30
	MG58.CritChanceScaled = 10
	storeProps(MG58, "AimAccuracy", 28, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG58, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG58, "WeaponRange", 32, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG58, "WeaponRange", 40, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MG58.PBbonus_base = -3
	MG58.HandlingBaseMul = 125
	MG58.HandlingNotProneMul = 250
	MG58.ShootAP = 4000
	MG58.ReloadAP = 5000
	MG58.APStance = 45
	MG58.OverwatchAngle = 571
	MG58.MagazineSize = 50
	MG58.Cumbersome = 1
	MG58.Noise = 22
	MG58.PointBlankBonus = 1
	MG58.PreparedAttackType = "Machine Gun"
	MG58.AvailableAttacks = {"MGBurstFire"}
	MG58.long_shots = 7
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


	MG42.is_vanilla_firearm = true
	MG42.Cost = 2520
	MG42.Damage = 28
	MG42.CritChanceScaled = 10
	storeProps(MG42, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG42, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG42, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(MG42, "WeaponRange", 38, "oldCTH", GBO_gCTHModeItemPropertyTable)
	MG42.PBbonus_base = -4
	MG42.HandlingBaseMul = 125
	MG42.HandlingNotProneMul = 250
	MG42.ShootAP = 4000
	MG42.ReloadAP = 5000
	MG42.APStance = 45
	MG42.OverwatchAngle = 571
	MG42.MagazineSize = 50
	MG42.Cumbersome = 1
	MG42.Noise = 22
	MG42.PointBlankBonus = 1
	MG42.PreparedAttackType = "Machine Gun"
	MG42.AvailableAttacks = {"MGBurstFire"}
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
	storeProps(BrowningM2HMG, "AimAccuracy", 25, "aCTH", GBO_gCTHModeItemPropertyTable)
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


	DesertEagle.is_vanilla_firearm = true
	DesertEagle.Cost = 7000
	DesertEagle.Damage = 26
	DesertEagle.CritChanceScaled = 20
	storeProps(DesertEagle, "AimAccuracy", 16, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DesertEagle, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DesertEagle, "WeaponRange", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DesertEagle, "WeaponRange", 28, "oldCTH", GBO_gCTHModeItemPropertyTable)
	DesertEagle.PBbonus_base = 11
	DesertEagle.HandlingBaseMul = 100
	DesertEagle.ShootAP = 4000
	DesertEagle.ReloadAP = 3000
	DesertEagle.APStance = 10
	DesertEagle.OverwatchAngle = 1936
	DesertEagle.MagazineSize = 8
	DesertEagle.Cumbersome = 0
	DesertEagle.Noise = 20
	DesertEagle.PointBlankBonus = 1
	DesertEagle.PreparedAttackType = "Overwatch"
	DesertEagle.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
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
	DesertEagle.Tier = 2
	DesertEagle.MaxStock = 3
	DesertEagle.RestockWeight = 40
	DesertEagle.CategoryPair = "Handguns"
	DesertEagle.PenetrationClass = 1


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
	Bereta92.APStance = 10
	Bereta92.OverwatchAngle = 2209
	Bereta92.MagazineSize = 15
	Bereta92.Cumbersome = 0
	Bereta92.Noise = 18
	Bereta92.PointBlankBonus = 1
	Bereta92.PreparedAttackType = "Overwatch"
	Bereta92.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
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
	HiPower.APStance = 10
	HiPower.OverwatchAngle = 2216
	HiPower.MagazineSize = 13
	HiPower.Cumbersome = 0
	HiPower.Noise = 18
	HiPower.PointBlankBonus = 1
	HiPower.PreparedAttackType = "Overwatch"
	HiPower.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
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
	HiPower.ComponentSlots = {{CanBeEmpty = true, SlotType = 'Muzzle', Modifiable = true, AvailableComponents = {'ImprovisedSuppressor', 'Suppressor', 'Compensator', }}, {CanBeEmpty = true, SlotType = 'Scope', Modifiable = true, AvailableComponents = {'ReflexSight', '_ReflexSIghtVigilance', 'ReflexSightAdvanced_Glock', 'ImprovedIronsight', }}, {CanBeEmpty = false, SlotType = 'Magazine', DefaultComponent = 'MagNormal', Modifiable = true, AvailableComponents = {'MagLarge_1', 'MagNormal', 'MagLargeFine_1', 'MagNormalFine', }}, {CanBeEmpty = false, SlotType = 'Barrel', DefaultComponent = 'BarrelNormal', Modifiable = true, AvailableComponents = {'BarrelNormal', 'BarrelNormalImproved', 'BarrelShort_handgun', 'BarrelShortImproved_handgun', 'BarrelLong_handgun', 'BarrelLongImproved_handgun', 'BarrelLight', 'long_barrel_light_handgun', 'BarrelShort_Light_handgun', }}}
	HiPower.CanAppearInShop = true
	HiPower.Tier = 1
	HiPower.MaxStock = 3
	HiPower.RestockWeight = 100
	HiPower.CategoryPair = "Handguns"
	HiPower.PenetrationClass = 1


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
	Glock18.APStance = 10
	Glock18.OverwatchAngle = 2232
	Glock18.MagazineSize = 15
	Glock18.Cumbersome = 0
	Glock18.Noise = 18
	Glock18.PointBlankBonus = 1
	Glock18.PreparedAttackType = "Overwatch"
	Glock18.AvailableAttacks = {"BurstFire", "SingleShot", "DualShot", "CancelShot", "MobileShot", "RunAndGun", "AutoFire"}
	Glock18.burst_shots = 4
	Glock18.auto_shots = 12
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


	ColtAnaconda.is_vanilla_firearm = true
	ColtAnaconda.Cost = 4600
	ColtAnaconda.Damage = 25
	ColtAnaconda.CritChanceScaled = 30
	storeProps(ColtAnaconda, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtAnaconda, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtAnaconda, "WeaponRange", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(ColtAnaconda, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	ColtAnaconda.PBbonus_base = 12
	ColtAnaconda.HandlingBaseMul = 100
	ColtAnaconda.ShootAP = 4000
	ColtAnaconda.ReloadAP = 3000
	ColtAnaconda.APStance = 10
	ColtAnaconda.OverwatchAngle = 2118
	ColtAnaconda.MagazineSize = 6
	ColtAnaconda.Cumbersome = 0
	ColtAnaconda.Noise = 18
	ColtAnaconda.PointBlankBonus = 1
	ColtAnaconda.PreparedAttackType = "Overwatch"
	ColtAnaconda.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
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
	TexRevolver.APStance = 10
	TexRevolver.OverwatchAngle = 2162
	TexRevolver.MagazineSize = 6
	TexRevolver.Cumbersome = 0
	TexRevolver.Noise = 18
	TexRevolver.PointBlankBonus = 1
	TexRevolver.PreparedAttackType = "Overwatch"
	TexRevolver.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
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
	ColtPeacemaker.APStance = 10
	ColtPeacemaker.OverwatchAngle = 2162
	ColtPeacemaker.MagazineSize = 6
	ColtPeacemaker.Cumbersome = 0
	ColtPeacemaker.Noise = 18
	ColtPeacemaker.PointBlankBonus = 1
	ColtPeacemaker.PreparedAttackType = "Overwatch"
	ColtPeacemaker.AvailableAttacks = {"SingleShot", "DualShot", "CancelShot", "MobileShot"}
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


	M41Shotgun.is_vanilla_firearm = true
	M41Shotgun.Cost = 3000
	M41Shotgun.Damage = 7
	M41Shotgun.ObjDamageMod = 150
	M41Shotgun.CritChanceScaled = 20
	storeProps(M41Shotgun, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M41Shotgun, "AimAccuracy", 5, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M41Shotgun, "WeaponRange", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M41Shotgun, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M41Shotgun.PBbonus_base = -3
	M41Shotgun.HandlingBaseMul = 111
	M41Shotgun.ShootAP = 3000
	M41Shotgun.ReloadAP = 5000
	M41Shotgun.APStance = 40
	M41Shotgun.OverwatchAngle = 881
	M41Shotgun.MagazineSize = 6
	M41Shotgun.Cumbersome = 0
	M41Shotgun.Noise = 20
	M41Shotgun.PointBlankBonus = 1
	M41Shotgun.PreparedAttackType = "Overwatch"
	M41Shotgun.AvailableAttacks = {"Buckshot", "CancelShotCone", "SingleShot", "CancelShot"}
	M41Shotgun.BuckshotConeAngle = 240
	M41Shotgun.BuckshotFalloffDamage = 50
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


	AA12.is_vanilla_firearm = true
	AA12.Cost = 7920
	AA12.Damage = 6
	AA12.ObjDamageMod = 150
	AA12.CritChanceScaled = 10
	storeProps(AA12, "AimAccuracy", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AA12, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AA12, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AA12, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AA12.PBbonus_base = 1
	AA12.HandlingBaseMul = 105
	AA12.ShootAP = 3000
	AA12.ReloadAP = 3000
	AA12.APStance = 40
	AA12.OverwatchAngle = 1001
	AA12.MagazineSize = 8
	AA12.Cumbersome = 0
	AA12.Noise = 25
	AA12.PointBlankBonus = 1
	AA12.PreparedAttackType = "Overwatch"
	AA12.AvailableAttacks = {"BuckshotBurst", "Buckshot", "CancelShotCone", "BurstFire", "SingleShot", "CancelShot"}
	AA12.BuckshotConeAngle = 355
	AA12.BuckshotFalloffDamage = 50
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


	DoubleBarrelShotgun.is_vanilla_firearm = true
	DoubleBarrelShotgun.Cost = 860
	DoubleBarrelShotgun.Damage = 6
	DoubleBarrelShotgun.ObjDamageMod = 150
	DoubleBarrelShotgun.CritChanceScaled = 10
	storeProps(DoubleBarrelShotgun, "AimAccuracy", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DoubleBarrelShotgun, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DoubleBarrelShotgun, "WeaponRange", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DoubleBarrelShotgun, "WeaponRange", 20, "oldCTH", GBO_gCTHModeItemPropertyTable)
	DoubleBarrelShotgun.PBbonus_base = -3
	DoubleBarrelShotgun.HandlingBaseMul = 110
	DoubleBarrelShotgun.ShootAP = 3000
	DoubleBarrelShotgun.ReloadAP = 4000
	DoubleBarrelShotgun.APStance = 40
	DoubleBarrelShotgun.OverwatchAngle = 901
	DoubleBarrelShotgun.MagazineSize = 2
	DoubleBarrelShotgun.Cumbersome = 0
	DoubleBarrelShotgun.Noise = 25
	DoubleBarrelShotgun.PointBlankBonus = 1
	DoubleBarrelShotgun.PreparedAttackType = "Overwatch"
	DoubleBarrelShotgun.AvailableAttacks = {"Buckshot", "DoubleBarrel", "CancelShotCone", "SingleShot", "CancelShot"}
	DoubleBarrelShotgun.BuckshotConeAngle = 390
	DoubleBarrelShotgun.BuckshotFalloffDamage = 50
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


	Auto5.is_vanilla_firearm = true
	Auto5.Cost = 1200
	Auto5.Damage = 7
	Auto5.ObjDamageMod = 150
	Auto5.CritChanceScaled = 10
	storeProps(Auto5, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5, "WeaponRange", 22, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Auto5.PBbonus_base = -1
	Auto5.HandlingBaseMul = 107
	Auto5.ShootAP = 3000
	Auto5.ReloadAP = 4000
	Auto5.APStance = 40
	Auto5.OverwatchAngle = 959
	Auto5.MagazineSize = 4
	Auto5.Cumbersome = 0
	Auto5.Noise = 25
	Auto5.PointBlankBonus = 1
	Auto5.PreparedAttackType = "Overwatch"
	Auto5.AvailableAttacks = {"Buckshot", "CancelShotCone", "SingleShot", "CancelShot"}
	Auto5.BuckshotConeAngle = 300
	Auto5.BuckshotFalloffDamage = 50
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


	Auto5_quest.is_vanilla_firearm = true
	Auto5_quest.Cost = 1200
	Auto5_quest.Damage = 6
	Auto5_quest.ObjDamageMod = 150
	Auto5_quest.CritChanceScaled = 10
	storeProps(Auto5_quest, "AimAccuracy", 18, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5_quest, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5_quest, "WeaponRange", 20, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Auto5_quest, "WeaponRange", 20, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Auto5_quest.PBbonus_base = -1
	Auto5_quest.HandlingBaseMul = 107
	Auto5_quest.ShootAP = 3000
	Auto5_quest.ReloadAP = 5000
	Auto5_quest.APStance = 30
	Auto5_quest.OverwatchAngle = 959
	Auto5_quest.MagazineSize = 8
	Auto5_quest.Cumbersome = 0
	Auto5_quest.Noise = 25
	Auto5_quest.PointBlankBonus = 1
	Auto5_quest.PreparedAttackType = "Overwatch"
	Auto5_quest.AvailableAttacks = {"BuckshotBurst", "BurstFire"}
	Auto5_quest.BuckshotConeAngle = 300
	Auto5_quest.BuckshotFalloffDamage = 100
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


	M24Sniper.is_vanilla_firearm = true
	M24Sniper.Cost = 8600
	M24Sniper.Damage = 31
	M24Sniper.CritChanceScaled = 30
	storeProps(M24Sniper, "AimAccuracy", 58, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M24Sniper, "AimAccuracy", 9, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M24Sniper, "WeaponRange", 44, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M24Sniper, "WeaponRange", 38, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M24Sniper.PBbonus_base = -3
	M24Sniper.HandlingBaseMul = 116
	M24Sniper.ShootAP = 4000
	M24Sniper.ReloadAP = 3000
	M24Sniper.APStance = 45
	M24Sniper.OverwatchAngle = 772
	M24Sniper.MagazineSize = 5
	M24Sniper.Cumbersome = 0
	M24Sniper.Noise = 22
	M24Sniper.PointBlankBonus = 1
	M24Sniper.PreparedAttackType = "Both"
	M24Sniper.AvailableAttacks = {"SingleShot", "CancelShot"}
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
	storeProps(PSG1, "AimAccuracy", 54, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PSG1, "AimAccuracy", 9, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PSG1, "WeaponRange", 48, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(PSG1, "WeaponRange", 40, "oldCTH", GBO_gCTHModeItemPropertyTable)
	PSG1.PBbonus_base = -6
	PSG1.HandlingBaseMul = 125
	PSG1.HandlingNotProneMul = 188
	PSG1.ShootAP = 4000
	PSG1.ReloadAP = 2000
	PSG1.APStance = 45
	PSG1.OverwatchAngle = 596
	PSG1.MagazineSize = 5
	PSG1.Cumbersome = 0
	PSG1.Noise = 22
	PSG1.PointBlankBonus = 1
	PSG1.PreparedAttackType = "Both"
	PSG1.AvailableAttacks = {"SingleShot", "CancelShot"}
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


	BarretM82.is_vanilla_firearm = true
	BarretM82.Cost = 15940
	BarretM82.Damage = 70
	BarretM82.CritChanceScaled = 20
	storeProps(BarretM82, "AimAccuracy", 52, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BarretM82, "AimAccuracy", 8, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BarretM82, "WeaponRange", 50, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(BarretM82, "WeaponRange", 42, "oldCTH", GBO_gCTHModeItemPropertyTable)
	BarretM82.PBbonus_base = -10
	BarretM82.HandlingBaseMul = 125
	BarretM82.HandlingNotProneMul = 400
	BarretM82.ShootAP = 4000
	BarretM82.ReloadAP = 3000
	BarretM82.APStance = 55
	BarretM82.OverwatchAngle = 545
	BarretM82.MagazineSize = 5
	BarretM82.Cumbersome = 1
	BarretM82.Noise = 22
	BarretM82.PointBlankBonus = 1
	BarretM82.PreparedAttackType = "Both"
	BarretM82.AvailableAttacks = {"SingleShot", "CancelShot"}
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


	GoldenGun.is_vanilla_firearm = true
	GoldenGun.Cost = 18000
	GoldenGun.Damage = 31
	GoldenGun.CritChanceScaled = 40
	storeProps(GoldenGun, "AimAccuracy", 52, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(GoldenGun, "AimAccuracy", 9, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(GoldenGun, "WeaponRange", 30, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(GoldenGun, "WeaponRange", 32, "oldCTH", GBO_gCTHModeItemPropertyTable)
	GoldenGun.PBbonus_base = -1
	GoldenGun.HandlingBaseMul = 111
	GoldenGun.ShootAP = 4000
	GoldenGun.ReloadAP = 3000
	GoldenGun.APStance = 40
	GoldenGun.OverwatchAngle = 870
	GoldenGun.MagazineSize = 10
	GoldenGun.Cumbersome = 1
	GoldenGun.Noise = 22
	GoldenGun.PointBlankBonus = 1
	GoldenGun.PreparedAttackType = "Both"
	GoldenGun.AvailableAttacks = {"SingleShot"}
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
	storeProps(Gewehr98, "AimAccuracy", 44, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr98, "AimAccuracy", 7, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr98, "WeaponRange", 34, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(Gewehr98, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	Gewehr98.PBbonus_base = -7
	Gewehr98.HandlingBaseMul = 122
	Gewehr98.ShootAP = 4000
	Gewehr98.ReloadAP = 3000
	Gewehr98.APStance = 45
	Gewehr98.OverwatchAngle = 651
	Gewehr98.MagazineSize = 5
	Gewehr98.Cumbersome = 0
	Gewehr98.Noise = 22
	Gewehr98.PointBlankBonus = 1
	Gewehr98.PreparedAttackType = "Both"
	Gewehr98.AvailableAttacks = {"SingleShot", "CancelShot"}
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
	storeProps(DragunovSVD, "AimAccuracy", 42, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DragunovSVD, "AimAccuracy", 7, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DragunovSVD, "WeaponRange", 38, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(DragunovSVD, "WeaponRange", 36, "oldCTH", GBO_gCTHModeItemPropertyTable)
	DragunovSVD.PBbonus_base = -2
	DragunovSVD.HandlingBaseMul = 114
	DragunovSVD.ShootAP = 4000
	DragunovSVD.ReloadAP = 3000
	DragunovSVD.APStance = 45
	DragunovSVD.OverwatchAngle = 820
	DragunovSVD.MagazineSize = 10
	DragunovSVD.Cumbersome = 0
	DragunovSVD.Noise = 22
	DragunovSVD.PointBlankBonus = 1
	DragunovSVD.PreparedAttackType = "Both"
	DragunovSVD.AvailableAttacks = {"SingleShot", "CancelShot"}
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


	M4Commando.is_vanilla_firearm = true
	M4Commando.Cost = 10050
	M4Commando.Damage = 23
	M4Commando.CritChanceScaled = 10
	storeProps(M4Commando, "AimAccuracy", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M4Commando, "AimAccuracy", 4, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M4Commando, "WeaponRange", 26, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(M4Commando, "WeaponRange", 30, "oldCTH", GBO_gCTHModeItemPropertyTable)
	M4Commando.PBbonus_base = 7
	M4Commando.HandlingBaseMul = 100
	M4Commando.ShootAP = 3000
	M4Commando.ReloadAP = 3000
	M4Commando.APStance = 35
	M4Commando.OverwatchAngle = 1429
	M4Commando.MagazineSize = 20
	M4Commando.Cumbersome = 0
	M4Commando.Noise = 20
	M4Commando.PointBlankBonus = 1
	M4Commando.PreparedAttackType = "Overwatch"
	M4Commando.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
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


	AKSU.is_vanilla_firearm = true
	AKSU.Cost = 4500
	AKSU.Damage = 21
	AKSU.CritChanceScaled = 10
	storeProps(AKSU, "AimAccuracy", 25, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AKSU, "AimAccuracy", 3, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AKSU, "WeaponRange", 24, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(AKSU, "WeaponRange", 26, "oldCTH", GBO_gCTHModeItemPropertyTable)
	AKSU.PBbonus_base = 9
	AKSU.HandlingBaseMul = 100
	AKSU.ShootAP = 3000
	AKSU.ReloadAP = 3000
	AKSU.APStance = 30
	AKSU.OverwatchAngle = 1448
	AKSU.MagazineSize = 30
	AKSU.Cumbersome = 0
	AKSU.Noise = 20
	AKSU.PointBlankBonus = 1
	AKSU.PreparedAttackType = "Overwatch"
	AKSU.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
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
	LionRoar.APStance = 20
	LionRoar.OverwatchAngle = 1410
	LionRoar.MagazineSize = 20
	LionRoar.Cumbersome = 0
	LionRoar.Noise = 20
	LionRoar.PointBlankBonus = 1
	LionRoar.PreparedAttackType = "Overwatch"
	LionRoar.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun"}
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
	MP5K.APStance = 30
	MP5K.OverwatchAngle = 1437
	MP5K.MagazineSize = 15
	MP5K.Cumbersome = 0
	MP5K.Noise = 20
	MP5K.PointBlankBonus = 1
	MP5K.PreparedAttackType = "Overwatch"
	MP5K.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "DualShot", "RunAndGun", "CancelShot"}
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
	MP5.APStance = 30
	MP5.OverwatchAngle = 1437
	MP5.MagazineSize = 15
	MP5.Cumbersome = 0
	MP5.Noise = 20
	MP5.PointBlankBonus = 1
	MP5.PreparedAttackType = "Overwatch"
	MP5.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
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


	UZI.is_vanilla_firearm = true
	UZI.Cost = 960
	UZI.Damage = 18
	UZI.CritChanceScaled = 10
	storeProps(UZI, "AimAccuracy", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UZI, "AimAccuracy", 2, "oldCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UZI, "WeaponRange", 22, "aCTH", GBO_gCTHModeItemPropertyTable)
	storeProps(UZI, "WeaponRange", 24, "oldCTH", GBO_gCTHModeItemPropertyTable)
	UZI.PBbonus_base = 8
	UZI.HandlingBaseMul = 100
	UZI.ShootAP = 3000
	UZI.ReloadAP = 3000
	UZI.APStance = 30
	UZI.OverwatchAngle = 1410
	UZI.MagazineSize = 25
	UZI.Cumbersome = 0
	UZI.Noise = 20
	UZI.PointBlankBonus = 1
	UZI.PreparedAttackType = "Overwatch"
	UZI.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "DualShot", "RunAndGun", "CancelShot"}
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
	MP40.APStance = 30
	MP40.OverwatchAngle = 1321
	MP40.MagazineSize = 32
	MP40.Cumbersome = 0
	MP40.Noise = 20
	MP40.PointBlankBonus = 1
	MP40.PreparedAttackType = "Overwatch"
	MP40.AvailableAttacks = {"BurstFire", "AutoFire", "SingleShot", "RunAndGun", "CancelShot"}
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


	GBO_ApplyCHTModeItemProps(GBO_gCTHModeItemPropertyTable)

	print("PATCH_GBO_weapons done")
end


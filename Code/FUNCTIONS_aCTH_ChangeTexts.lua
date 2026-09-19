
local file_str = 'FUNCTIONS_aCTH_ChangeTexts.lua'
function ratT(file_str, id, text)
	ratG_T_table[file_str] = ratG_T_table[file_str] or {}
	ratG_T_table[file_str][id] = text
	return T(id, text)
end
---- Texts whose mechanic differs under aCTH: {map, id, field, old CTH text, aCTH text}.
local acth_text_swaps = {
    ---- PBbonus feeds Handling (Rat_ApertureHandlingMul) instead of a point blank bonus
    {"WeaponComponentEffects", "bullpup", "Description",
        ratT(file_str,498763703334, "Bullpup design, increases Point Blank range accuracy bonus and Shooting Angle"),
        ratT(file_str,621889104903, "Bullpup design, decreases <em>Handling</em> penalty and increases Shooting Angle")},
    {"WeaponComponentEffects", "longbarrel", "Description",
        ratT(file_str,915008271800, "Decreased Hipfire penalty, increased Snapshot penalty, reduced Recoil penalty, decreased Point Blank range accuracy, harder to hit at melee range"),
        ratT(file_str,986565498973, "Decreased Hipfire penalty, increased Snapshot penalty, reduced Recoil penalty, increased <em>Handling</em> penalty, harder to hit at melee range")},
    {"WeaponComponentEffects", "shortbarrel", "Description",
        ratT(file_str,173836158177, "Increased Hipfire penalty, decreased Snapshot penalty, increased Recoil penalty, increased Point Blank range accuracy, easier to hit at melee range"),
        ratT(file_str,729906022611, "Increased Hipfire penalty, decreased Snapshot penalty, increased Recoil penalty, decreased <em>Handling</em> penalty, easier to hit at melee range")},
    {"WeaponComponentEffects", "tac_grip_PB", "Description",
        ratT(file_str,952508575329, "Slightly increased Point-Blank range accuracy bonus"),
        ratT(file_str,174091519276, "Slightly decreased <em>Handling</em> penalty")},
    {"WeaponComponentEffects", "IncreasePointBlankAccuracyBonus", "Description",
        ratT(file_str,912316475877, "Increases Point-Blank range accuracy bonus"),
        ratT(file_str,791929867524, "Decreases <em>Handling</em> penalty")},
    {"WeaponComponentEffects", "DecreasePointBlankAccuracyBonus", "Description",
        ratT(file_str,156932878971, "Decreases Point-Blank range accuracy bonus"),
        ratT(file_str,695014801114, "Increases <em>Handling</em> penalty")},
    {"WeaponComponentEffects", "vigneron_folded_PB", "Description",
        ratT(file_str,897995963554, "Increases Point Blank Range accuracy bonus by 1"),
        ratT(file_str,169244869056, "Slightly decreases <em>Handling</em> penalty")},
    {"WeaponComponentEffects", "handguard_short", "Description",
        ratT(file_str,236633317127, "Decreases weapon length, affecting Recoil, Snapshot, Hipfire accuracy penalties and Point Blank Range accuracy modifiers"),
        ratT(file_str,588843192458, "Decreases weapon length, affecting Recoil, Snapshot, Hipfire accuracy and <em>Handling</em> penalties")},
    {"WeaponComponentEffects", "handguard_ext", "Description",
        ratT(file_str,219179226706, "Increases weapon length, affecting Recoil, Snapshot, Hipfire accuracy penalties and Point Blank Range accuracy modifiers"),
        ratT(file_str,700413725434, "Increases weapon length, affecting Recoil, Snapshot, Hipfire accuracy and <em>Handling</em> penalties")},

    {"CombatActions", "BurstFire", "Description",
        ratT(file_str,617859618521, "Shoots <em><num> bullets</em> at the target. The accuracy of each shot is reduced by <em>Recoil</em>. Critical chance is reduced.\n\nOnly the first shot will benefit from <em>Aim</em> bonus."),
        ratT(file_str,927619797396, "Shoots <em><num> bullets</em> at the target. The accuracy of each shot is reduced by <em>Recoil</em>. Critical chance is reduced.")},
    {"CombatActions", "AutoFire", "Description",
        ratT(file_str,373274572555, "Shoots a hail of <em><bullets> bullets</em> and inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Maximum <em>aim</em> level reduced. Critical chance is reduced"),
        ratT(file_str,440275763653, "Shoots a hail of <em><bullets> bullets</em> and inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Critical chance is reduced.")},
    {"CombatActions", "DualShot", "Description",
        ratT(file_str,364947777453, "The Dual Shot attack produces a Basic Attack from each gun. Maximum <em>aim</em> level is reduced. Has a penalty based on <em>Dexterity</em>."),
        ratT(file_str,538170264913, "The Dual Shot attack produces a Basic Attack from each gun. Maximum <em>aim</em> level is 3. <em>Sights</em> and <em>grips</em> grant no accuracy bonus. Has a penalty that can be reduced by <em>Dexterity</em>.")},
    ---- aCTH has no body part penalties to reduce; Snipe gives aim accuracy instead (A.PindownAimAcc)
    {"CombatActions", "PinDown", "Description",
        ratT(file_str,854982151651, "<em>Spends all AP</em>\nThe target is <em><GameTerm('Marked')></em>. At the start of next turn, shoot the target if the target is still in the line of sight. The attack will have max aim levels. Each aim level grants <bonus_crit> extra critical chance. This attack bypasses low cover, has reduced penalties to hit body parts and <em>increases the weapon's effective range by 50%</em>.\n\nSnipe requires a clear line and sight to the target."),
        ratT(file_str,291547951652, "<em>Spends all AP</em>\nThe target is <em><GameTerm('Marked')></em>. At the start of next turn, shoot the target if the target is still in the line of sight. The attack will have max aim levels. Each aim level grants <bonus_crit> extra critical chance. This attack has increased <em>aim accuracy</em> and <em>increases the weapon's effective range by 50%</em>.\n\nSnipe requires a clear line and sight to the target.")},

    ---- the accuracy bonus comes from firing prone, not from setup itself
    {"CombatActions", "MGSetup", "Description",
        ratT(file_str,564696256945, "Focus on a cone-shaped area, immobilizing yourself and going <em>prone</em>. You can only shoot enemies inside that cone. Accuracy is increased and enemies will provoke <em>interrupt</em> attacks with actions inside the cone (even if your AP are spent). <em>Interrupt</em> attacks have bonus accuracy. Your weapon will have increased <em>Shooting Angle</em> while you are in setup."),
        ratT(file_str,656962772885, "Focus on a cone-shaped area, immobilizing yourself and going <em>prone</em>. You can only shoot enemies inside that cone. Enemies will provoke <em>interrupt</em> attacks with actions inside the cone (even if your AP are spent). <em>Interrupt</em> attacks have bonus accuracy. Your weapon will have increased <em>Shooting Angle</em> while you are in setup.")},
    {"CombatActions", "MGBurstFire", "Description",
        ratT(file_str,863161981262, "Make a burst attack<coneDescription>. Lower accuracy against distant enemies, and further reduced accuracy if fired without being Set.<interrupts_info>"),
        ratT(file_str,872453352285, "Make a burst attack<coneDescription>. Lower accuracy against distant enemies, and further reduced accuracy if not fired <em>prone</em>, braced on the bipod.<interrupts_info>")},
    {"GameTerm", "Setup", "Description",
        ratT(file_str,777731488769, "<em>Machine guns</em> need to be set before firing to avoid suffering a heavy <em>Accuracy</em> penalty."),
        ratT(file_str,681987343557, "Heavy weapons such as <em>machine guns</em> suffer heavy <em>Accuracy</em> and <em>Recoil</em> penalties unless fired <em>prone</em>. Setting up a machine gun puts you prone.")},

    ---- camouflage shrinks the visible silhouette (A.CamoExposedPct) instead of weakening aim
    {"InventoryItemDefs", "CamoArmor_Light", "AdditionalHint",
        ratT(file_str,990395288798, "<bullet_point> Harder to detect by enemies\n<bullet_point> Aiming is less effective against camouflaged targets\n<bullet_point> Can't be combined with weave or ceramics"),
        ratT(file_str,957147208105, "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point>Can't be combined with weave or ceramics")},
    {"InventoryItemDefs", "CamoArmor_Medium", "AdditionalHint",
        ratT(file_str,265860069213, "<bullet_point> Harder to detect by enemies\n<bullet_point> Aiming is less effective against camouflaged targets\n<bullet_point> Can't be combined with weave or ceramics"),
        ratT(file_str,118813633810, "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point>Can't be combined with weave or ceramics")},
    {"InventoryItemDefs", "CamoArmor_Light_Kompositum", "AdditionalHint",
        ratT(file_str,484160716674, "<bullet_point> Harder to detect by enemies\n<bullet_point> Aiming is less effective against camouflaged targets\n<bullet_point> Combined with Kompositum 58"),
        ratT(file_str,860032154218, "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point>Combined with Kompositum 58")},
    {"InventoryItemDefs", "CamoArmor_Medium_Kompositum", "AdditionalHint",
        ratT(file_str,409387533354, "<bullet_point> Harder to detect by enemies\n<bullet_point> Aiming is less effective against camouflaged targets\n<bullet_point> Combined with Kompositum 58"),
        ratT(file_str,990049214333, "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point>Combined with Kompositum 58")},

    ---- CQC shrinks the hipfire/snapshot step (A.CQCStepReduc) instead of a range-scaled bonus
    {"CharacterEffectDefs", "CQCTraining", "Description",
        ratT(file_str,145788352124, "Major <em>Accuracy</em> bonus when attacking enemies at short range (degrades with distance)."),
        ratT(file_str,583920174465, "Reduced <em>Hipfire</em> and <em>Snapshot</em> penalties.\n\nMajor <em>Accuracy</em> bonus with <em>Melee</em> and <em>Thrown</em> attacks at short range (degrades with distance).")},

    ---- Grizzly skips the not-prone weight recoil and handling maluses; aim capped by singleMaxActions
    {"CharacterEffectDefs", "GrizzlyPerk", "Description",
        ratT(file_str,272740235755, "<em>Machine Gun attack</em> with reduced <em>Accuracy</em> penalty that does not suffer increased penalties if firing without <GameTerm('Setup')>."),
        ratT(file_str,279916694418, "<em>Machine Gun attack</em> fired from the hip. Ignores the heavy weapon <em>Recoil</em> and <em>Handling</em> penalties for not firing <em>prone</em>. Maximum <em>aim</em> level is 1.")},
}

---- Runs after rat_apply_changes() and on every CTH mode change (GBO_ApplyApertureCTHMode).
function GBO_SwapACTHTexts()
    local idx = IsACHTActive() and 5 or 4
    for _, s in ipairs(acth_text_swaps) do
        ---- GameTerm has no global map
        local map = s[1] == "GameTerm" and Presets.GameTerm.Default or _G[s[1]]
        local preset = (map or empty_table)[s[2]]
        if preset then
            preset[s[3]] = s[idx]
        end
        ---- item and perk instances read the generated class, not the preset
        local class = (s[1] == "InventoryItemDefs" or s[1] == "CharacterEffectDefs") and g_Classes[s[2]]
        if class then
            class[s[3]] = s[idx]
        end
    end
end




---- Weapon modification screen bars. Store vanilla once so a mod reload doesn't wrap the override.
local vanilla_modify_props = _G.GBO_VanillaGetWeaponModifyProperties or GetWeaponModifyProperties
GBO_VanillaGetWeaponModifyProperties = vanilla_modify_props

local ModifyBarMaxShootAPVanilla = 10
local ModifyBarMaxAimAccuracyACTH = 70

function GetWeaponModifyProperties(item)
	local statList = vanilla_modify_props(item)
	local aim_bind = Presets.WeaponPropertyDef.Default.AimAccuracy.bind_to
	for _, stat in ipairs(statList) do
		if stat.id == "ShootAP" then
			stat.max = R_VanillaAP(ModifyBarMaxShootAPVanilla) / const.Scale.AP
		elseif stat.bind_to == aim_bind and IsACHTActive() then
			stat.max = ModifyBarMaxAimAccuracyACTH
		end
	end
	return statList
end
	
--ratG_T_table['FUNCTIONS_aCTH_ChangeTexts.lua'] = {	
--	[927619797396] = "Shoots <em><num> bullets</em> at the target. The accuracy of each shot is reduced by <em>Recoil</em>. Critical chance is reduced.",
--	[440275763653] = "Shoots a hail of <em><bullets> bullets</em> and inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Critical chance is reduced.",
--	[538170264913] = "The Dual Shot attack produces a Basic Attack from each gun. Maximum <em>aim</em> level is 3. <em>Sights</em> and <em>grips</em> grant no accuracy bonus. Has a penalty that can be reduced by <em>Dexterity</em>.",
--	[402918376154] = "<em>Spends all AP</em>\nThe target is <em><GameTerm('Marked')></em>. At the start of next turn, shoot the target if the target is still in the line of sight. The attack will have max aim levels. Each aim level grants <bonus_crit> extra critical chance. This attack has increased <em>aim accuracy</em> and <em>increases the weapon's effective range by 50%</em>.\n\nSnipe requires a clear line and sight to the target.",
--	[656962772885] = "Focus on a cone-shaped area, immobilizing yourself and going <em>prone</em>. You can only shoot enemies inside that cone. Enemies will provoke <em>interrupt</em> attacks with actions inside the cone (even if your AP are spent). <em>Interrupt</em> attacks have bonus accuracy. Your weapon will have increased <em>Shooting Angle</em> while you are in setup.",
--	[872453352285] = "Make a burst attack<coneDescription>. Lower accuracy against distant enemies, and further reduced accuracy if not fired <em>prone</em>, braced on the bipod.<interrupts_info>",
--	[681987343557] = "Heavy weapons such as <em>machine guns</em> suffer heavy <em>Accuracy</em> and <em>Recoil</em> penalties unless fired <em>prone</em>. Setting up a machine gun puts you prone.",
--	[957147208105] = "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point> Can't be combined with weave or ceramics",
--	[118813633810] = "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point> Can't be combined with weave or ceramics",
--	[860032154218] = "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point> Combined with Kompositum 58",
--	[990049214333] = "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point> Combined with Kompositum 58",
--	[583920174465] = "Reduced <em>Hipfire</em> and <em>Snapshot</em> penalties.\n\nMajor <em>Accuracy</em> bonus with <em>Melee</em> and <em>Thrown</em> attacks at short range (degrades with distance).",
--	[279916694418] = "<em>Machine Gun attack</em> fired from the hip. Ignores the heavy weapon <em>Recoil</em> penalty and the <em>Handling</em> penalty for not firing <em>prone</em>. Maximum <em>aim</em> level is 1."
--}
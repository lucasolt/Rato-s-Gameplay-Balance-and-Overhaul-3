
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
        ratT(file_str,815903264417, "Shoots a burst of <em><bullets> bullets</em>. Use the <em>mouse wheel</em> to change its length; each extra round costs AP by the weapon's rate of fire. Long bursts inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Maximum <em>aim</em> level reduced. Critical chance is reduced"),
        ratT(file_str,562081937740, "Shoots a burst of <em><bullets> bullets</em>. Use the <em>mouse wheel</em> to change its length; each extra round costs AP by the weapon's rate of fire. Long bursts inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Critical chance is reduced.")},
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
        ratT(file_str,318845207716, "Make a burst attack<coneDescription>. Use the <em>mouse wheel</em> to change its length; each extra round costs AP by the weapon's rate of fire. Lower accuracy against distant enemies, and further reduced accuracy if fired without being Set.<interrupts_info>"),
        ratT(file_str,509127364481, "Make a burst attack<coneDescription>. Use the <em>mouse wheel</em> to change its length; each extra round costs AP by the weapon's rate of fire. Lower accuracy against distant enemies, and further reduced accuracy if not fired <em>prone</em>, braced on the bipod.<interrupts_info>")},
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

    ---- gas costs CTH instead of grazing (CTH_smoke.lua); only with simulated shots, so `sim = true`
    {"InventoryItemDefs", "SmokeGrenade", "AdditionalHint", no_mod = "RATONADE", sim = true,
        T(112062042147, "<bullet_point> Ranged attacks passing through gas become <em>grazing</em> hits\n<bullet_point> No damage\n<bullet_point> Almost silent"),
        ratT(file_str,418273650912, "<bullet_point> Ranged attacks passing through gas are less accurate\n<bullet_point> No damage\n<bullet_point> Almost silent")},
    {"InventoryItemDefs", "TearGasGrenade", "AdditionalHint", no_mod = "RATONADE", sim = true,
        T(102232599134, "<bullet_point> Inflicts <em>Blinded</em>\n<bullet_point> Ranged attacks passing through gas become <em>grazing</em> hits\n<bullet_point> No damage\n<bullet_point> High mishap chance\n<bullet_point> Almost silent"),
        ratT(file_str,529384716203, "<bullet_point> Inflicts <em>Blinded</em>\n<bullet_point> Ranged attacks passing through gas are less accurate\n<bullet_point> No damage\n<bullet_point> High mishap chance\n<bullet_point> Almost silent")},
    {"InventoryItemDefs", "ToxicGasGrenade", "AdditionalHint", no_mod = "RATONADE", sim = true,
        T(277464468866, "<bullet_point> Inflicts <em>Choking</em>\n<bullet_point> Ranged attacks passing through gas become grazing hits\n<bullet_point> High mishap chance\n<bullet_point> Almost silent"),
        ratT(file_str,640495827314, "<bullet_point> Inflicts <em>Choking</em>\n<bullet_point> Ranged attacks passing through gas are less accurate\n<bullet_point> High mishap chance\n<bullet_point> Almost silent")},
    {"InventoryItemDefs", "MortarShell_Smoke", "AdditionalHint", sim = true,
        T(890174082428, "<bullet_point> Ranged attacks passing through gas become <em>grazing</em> hits\n<bullet_point> No damage\n<bullet_point> Almost silent"),
        ratT(file_str,751506938425, "<bullet_point> Ranged attacks passing through gas are less accurate\n<bullet_point> No damage\n<bullet_point> Almost silent")},
    {"InventoryItemDefs", "MortarShell_Gas", "AdditionalHint", sim = true,
        T(789422211618, "<bullet_point> Inflicts <em>Choking</em>\n<bullet_point> Ranged attacks passing through gas become Grazing hits\n<bullet_point> Almost silent"),
        ratT(file_str,862617049536, "<bullet_point> Inflicts <em>Choking</em>\n<bullet_point> Ranged attacks passing through gas are less accurate\n<bullet_point> Almost silent")},
    ---- Explosive Overhaul rewrites the grenade hints in its own format (RatoEO_Patch, items.lua)
    {"InventoryItemDefs", "SmokeGrenade", "AdditionalHint", mod = "RATONADE", sim = true,
        T(109176686173, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas become <color EmStyle>grazing</color> hits\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No damage\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent"),
        ratT(file_str,973728150647, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas are less accurate\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No damage\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent")},
    {"InventoryItemDefs", "SmokeGrenade_IED", "AdditionalHint", mod = "RATONADE", sim = true,
        T(953201278809, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas become <color EmStyle>grazing</color> hits\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No damage\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent"),
        ratT(file_str,184839261758, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas are less accurate\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No damage\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent")},
    {"InventoryItemDefs", "TearGasGrenade", "AdditionalHint", mod = "RATONADE", sim = true,
        T(961521854617, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Inflicts <color EmStyle>Blinded</color>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas become <color EmStyle>grazing</color> hits\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No damage\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent"),
        ratT(file_str,295940372869, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Inflicts <color EmStyle>Blinded</color>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas are less accurate\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No damage\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent")},
    {"InventoryItemDefs", "TearGasGrenade_IED", "AdditionalHint", mod = "RATONADE", sim = true,
        T(468937308243, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Inflicts <color EmStyle>Blinded</color>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas become <color EmStyle>grazing</color> hits\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No damage\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent"),
        ratT(file_str,306051483970, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Inflicts <color EmStyle>Blinded</color>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas are less accurate\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> No damage\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent")},
    {"InventoryItemDefs", "ToxicGasGrenade", "AdditionalHint", mod = "RATONADE", sim = true,
        T(838998848652, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Inflicts <color EmStyle>Choking</color>\n <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas become grazing hits\n <image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent"),
        ratT(file_str,417162594081, "<EO_description_hints>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Inflicts <color EmStyle>Choking</color>\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Ranged attacks passing through gas are less accurate\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Almost silent")},
}

---- Runs after rat_apply_changes() and on every CTH mode change (GBO_ApplyApertureCTHMode).
---- Optional row keys: `sim` follows simulated aCTH instead of aCTH; `mod`/`no_mod` gate on a mod id.
function GBO_SwapACTHTexts()
    local acth, sim = IsACHTActive(), IsACHTActive(nil, nil, nil, true)
    for _, s in ipairs(acth_text_swaps) do
        if (not s.mod or IsMod_loaded(s.mod)) and not (s.no_mod and IsMod_loaded(s.no_mod)) then
            local idx = (s.sim and sim or not s.sim and acth) and 5 or 4
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
end

---- Throw action tooltip: vanilla keeps these in a local table (Grenade.lua GrenadeCustomDescriptions)
local acth_gas_action_descr = {
    smoke = ratT(file_str,528273605192, "Ranged attacks passing through gas are less accurate."),
    teargas = ratT(file_str,639384716303, "Inflicts <em>Blinded</em>, making affected characters less accurate. Ranged attacks passing through gas are less accurate."),
    toxicgas = ratT(file_str,740495827414, "Inflicts <em>Choking</em>, forcing affected characters to take damage and lose energy, eventually fall <em>unconscious</em>. Ranged attacks passing through gas are less accurate."),
}

local vanilla_grenade_action_descr = _G.GBO_VanillaGrenadeActionDescr or Grenade.GetCustomActionDescription
GBO_VanillaGrenadeActionDescr = vanilla_grenade_action_descr

function Grenade:GetCustomActionDescription(...)
    local descr = acth_gas_action_descr[self.aoeType]
    if descr and IsACHTActive(nil, nil, nil, true) then
        return descr
    end
    return vanilla_grenade_action_descr(self, ...)
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
--	[562081937740] = "Shoots a burst of <em><bullets> bullets</em>. Use the <em>mouse wheel</em> to change its length; each extra round costs AP by the weapon's rate of fire. Long bursts inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Critical chance is reduced.",
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
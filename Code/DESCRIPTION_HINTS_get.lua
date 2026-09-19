function GBO_GetDescriptionHints(self)
    local formattedString = "<style CrosshairAPTotal>"

    local function GetRecoil_mul(self)

        local weapon = self

        local attacker = false

        if self.owner then
            attacker = not gv_SatelliteView and g_Units[self.owner] or gv_UnitData[self.owner]
        else
            attacker = {}
            attacker.placeholder = true
            attacker.Marksmanship = 100
            attacker.Strength = 100 -- Recoil_StrBreakpoint(self)
        end

        local display = true
        local recoil = GetWepRecoil(weapon, attacker, display)

        local other = 1.0
        local caliber = 1.0
        if attacker then
            other = GetRecoilOther(weapon, attacker, false)
            caliber = GetCaliberStrRecoil(weapon, attacker)
        end

        recoil = recoil * other * caliber

        return string.format("%.2f", recoil)
    end

    local function GetHipfire_mul(self) -- ok
        local weapon = self

        local attacker = false
        local action = false
        local aim = 0
        local display = true
        local hip = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, display, aim)
        return string.format("%.2f", hip)
    end

    local function GetSnapshot_mul(self) ---ok

        local weapon = self

        local attacker = false
        local action = false
        local aim = 1
        local display = true
        local hip = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, display, aim)
        return string.format("%.2f", hip)
    end

    local function Getangle_display(self)
        -- return 0
        local angle = self:GetProperty("OverwatchAngle") / 60.0
        return string.format("%.2f", angle)
    end

    local function GetPBbonus_display(self)
        -- return 0

        local weapon = self
        local value = GetPBbonus(weapon)

        return value
    end

    local function GetSTR_RECOIL(self)

        local weapon1 = self

        local str = Recoil_StrBreakpoint(weapon1)

        return str
    end

    local function GetAPStance_display(self)
        -- return 0
        -- local ap = self.APStance

        local unit = g_Units[self.owner] or gv_UnitData[self.owner]

        local ap = MulDivRound(GetWeapon_StanceAP(unit, self, true), 1, const.Scale.AP)
        local aim_cost = MulDivRound(Get_AimCost(unit), 1, const.Scale.AP)
        -- if unit then
        -- ap = Cumbersome_StanceAP(unit, self, ap)
        -- elseif self:IsCumbersome() then
        -- ap = ap +1
        -- end

        return string.format("%d", ap + aim_cost)--MulDivRound(ap + aim_cost,1,1)

    end

    local function GeBuckangle_display(self)
        -- return 0
        local angle = self:GetProperty("BuckshotConeAngle") / 60.0
        return string.format("%.2f", angle)
    end

    local angularCTHActive = IsACHTActive()
	local termList = {
	    {
	        id = "ShootingStanceCost",
	        TranslationTable[242435461626] or "Shooting Stance Cost: ",
	        GetAPStance_display(self) or 0, " AP"
	    },
	    {
	        id = "ShootingAngle",
	        TranslationTable[766379566745] or "Shooting Angle: ",
	        Getangle_display(self) or 0, "º"
	    },
	    {
	        id = "Reliability",
	        TranslationTable[412593832155] or "Reliability: ",
	        self.Reliability, "%"
	    },
	    {
	        id = "NoiseRadius",
	        TranslationTable[654134899415] or "Noise Radius: ",
	        self.Noise, " tiles"
	    },
	    {
	        id = "BaseCriticalChance",
	        TranslationTable[684546854913] or "Base critical chance: ",
	        self.CritChance, "%"
	    },
	    {
	        id = "MaximumCriticalScaling",
	        TranslationTable[507781478006] or "Maximum critical scaling: ",
	        self.CritChanceScaled, "%"
	    },
	    {
	        id = "ExtraCriticalDamage",
	        TranslationTable[247182652462] or "Extra critical damage: ",
	        self.CritDamage, "%"
	    },
		{
			id = "AimAccuracy",
			TranslationTable[219437987174] or "Aim accuracy: ",
			self.AimAccuracy, ""
		},
	    {
	        id = "PointBlankRangeAccuracy",
	        angularCTHActive and (TranslationTable[184329577856] or "Handling Penalty Multiplier: ") or (TranslationTable[651371401489] or "Point Blank Range Accuracy: "),
			---- em aCTH o manejo e multiplicador de cone: mesma leitura de hipfire/snapshot/recoil, MENOR = melhor
	        angularCTHActive and string.format("%.2f", Rat_ApertureHandlingMul(self) / 100.0)
				or (GetPBbonus_display(self) or 0),
			angularCTHActive and "X" or "%"
	    },
	    {
	        id = "HipfirePenaltyMultiplier",
	        TranslationTable[852084205321] or "Hipfire Penalty Multiplier: ",
	        GetHipfire_mul(self) or 0, "X"
	    },
	    {
	        id = "SnapshotPenaltyMultiplier",
	        TranslationTable[258395588915] or "Snapshot Penalty Multiplier: ",
	        GetSnapshot_mul(self) or 0, "X"
	    },
	    {
	        id = "RecoilPenaltyMultiplier",
	        (self.owner and (TranslationTable[151451884832] or "Recoil Penalty Multiplier: ")) or
	            (TranslationTable[896979362710] or "Minimum Recoil Multiplier: "),
	        GetRecoil_mul(self) or 0, "X"
	    },
	    {
	        id = "RecommendedStrength",
	        TranslationTable[158466723759] or "Recommended Strength: ",
	        GetSTR_RECOIL(self),
	        TranslationTable[785975283217] or " STR"
	    }
	}

	local shotty_terms = {
	    {
	        id = "NumberOfPellets",
	        TranslationTable[7195836321172] or "Number of Pellets: ",
	        self.NumPellets or 0, ""
	    },
	    {
	        id = "PelletSpreadAngle",
	        TranslationTable[193184162359] or "Pellet Spread Angle: ",
	        GeBuckangle_display(self) or 0, "º"
	    }
	}

	if (self.NumPellets or 0) > 1 then
	    for _, term in ipairs(shotty_terms) do
	        table.insert(termList, term)
	    end
	end

	local AngularCthActiveExclusionList = {
		--PointBlankRangeAccuracy = true
	}


	for _, term in ipairs(termList) do
		if not angularCTHActive or not AngularCthActiveExclusionList[term.id] then
	    	formattedString = formattedString ..
	    	    "<color PDABrowserFlavorMedium>" .. term[1] ..
	    	    "</color>" ..
	    	    "<color PDABrowserTextHighlight>" .. term[2] ..
	    	    "</color>" .. term[3] .. "\n"
		end
	end

	formattedString = formattedString .. "</style>"

	if self:IsCumbersome() then
	    formattedString = formattedString .. (TranslationTable[153781665575] or
	        "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Cumbersome (no Free Move)\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increases Stance AP cost by 1 (negated by high Strength)\n")
	end

	return T {formattedString}
end

---- Texts whose mechanic differs under aCTH: {map, id, field, old CTH text, aCTH text}.
local acth_text_swaps = {
    ---- PBbonus feeds Handling (Rat_ApertureHandlingMul) instead of a point blank bonus
    {"WeaponComponentEffects", "bullpup", "Description",
        T(498763703334, "Bullpup design, increases Point Blank range accuracy bonus and Shooting Angle"),
        T(621889104903, "Bullpup design, decreases <em>Handling</em> penalty and increases Shooting Angle")},
    {"WeaponComponentEffects", "longbarrel", "Description",
        T(915008271800, "Decreased Hipfire penalty, increased Snapshot penalty, reduced Recoil penalty, decreased Point Blank range accuracy, harder to hit at melee range"),
        T(986565498973, "Decreased Hipfire penalty, increased Snapshot penalty, reduced Recoil penalty, increased <em>Handling</em> penalty, harder to hit at melee range")},
    {"WeaponComponentEffects", "shortbarrel", "Description",
        T(173836158177, "Increased Hipfire penalty, decreased Snapshot penalty, increased Recoil penalty, increased Point Blank range accuracy, easier to hit at melee range"),
        T(729906022611, "Increased Hipfire penalty, decreased Snapshot penalty, increased Recoil penalty, decreased <em>Handling</em> penalty, easier to hit at melee range")},
    {"WeaponComponentEffects", "tac_grip_PB", "Description",
        T(952508575329, "Slightly increased Point-Blank range accuracy bonus"),
        T(174091519276, "Slightly decreased <em>Handling</em> penalty")},
    {"WeaponComponentEffects", "IncreasePointBlankAccuracyBonus", "Description",
        T(912316475877, "Increases Point-Blank range accuracy bonus"),
        T(791929867524, "Decreases <em>Handling</em> penalty")},
    {"WeaponComponentEffects", "DecreasePointBlankAccuracyBonus", "Description",
        T(156932878971, "Decreases Point-Blank range accuracy bonus"),
        T(695014801114, "Increases <em>Handling</em> penalty")},
    {"WeaponComponentEffects", "vigneron_folded_PB", "Description",
        T(897995963554, "Increases Point Blank Range accuracy bonus by 1"),
        T(169244869056, "Slightly decreases <em>Handling</em> penalty")},
    {"WeaponComponentEffects", "handguard_short", "Description",
        T(236633317127, "Decreases weapon length, affecting Recoil, Snapshot, Hipfire accuracy penalties and Point Blank Range accuracy modifiers"),
        T(588843192458, "Decreases weapon length, affecting Recoil, Snapshot, Hipfire accuracy and <em>Handling</em> penalties")},
    {"WeaponComponentEffects", "handguard_ext", "Description",
        T(219179226706, "Increases weapon length, affecting Recoil, Snapshot, Hipfire accuracy penalties and Point Blank Range accuracy modifiers"),
        T(700413725434, "Increases weapon length, affecting Recoil, Snapshot, Hipfire accuracy and <em>Handling</em> penalties")},

    {"CombatActions", "BurstFire", "Description",
        T(617859618521, "Shoots <em><num> bullets</em> at the target. The accuracy of each shot is reduced by <em>Recoil</em>. Critical chance is reduced.\n\nOnly the first shot will benefit from <em>Aim</em> bonus."),
        T(927619797396, "Shoots <em><num> bullets</em> at the target. The accuracy of each shot is reduced by <em>Recoil</em>. Critical chance is reduced.")},
    {"CombatActions", "AutoFire", "Description",
        T(373274572555, "Shoots a hail of <em><bullets> bullets</em> and inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Maximum <em>aim</em> level reduced. Critical chance is reduced"),
        T(440275763653, "Shoots a hail of <em><bullets> bullets</em> and inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Critical chance is reduced.")},
    {"CombatActions", "DualShot", "Description",
        T(364947777453, "The Dual Shot attack produces a Basic Attack from each gun. Maximum <em>aim</em> level is reduced. Has a penalty based on <em>Dexterity</em>."),
        T(111492168137, "The Dual Shot attack produces a Basic Attack from each gun. Has a penalty based on <em>Dexterity</em>.")},

    ---- the accuracy bonus comes from firing prone, not from setup itself
    {"CombatActions", "MGSetup", "Description",
        T(564696256945, "Focus on a cone-shaped area, immobilizing yourself and going <em>prone</em>. You can only shoot enemies inside that cone. Accuracy is increased and enemies will provoke <em>interrupt</em> attacks with actions inside the cone (even if your AP are spent). <em>Interrupt</em> attacks have bonus accuracy. Your weapon will have increased <em>Shooting Angle</em> while you are in setup."),
        T(656962772885, "Focus on a cone-shaped area, immobilizing yourself and going <em>prone</em>. You can only shoot enemies inside that cone. Enemies will provoke <em>interrupt</em> attacks with actions inside the cone (even if your AP are spent). <em>Interrupt</em> attacks have bonus accuracy. Your weapon will have increased <em>Shooting Angle</em> while you are in setup.")},
    {"CombatActions", "MGBurstFire", "Description",
        T(863161981262, "Make a burst attack<coneDescription>. Lower accuracy against distant enemies, and further reduced accuracy if fired without being Set.<interrupts_info>"),
        T(872453352285, "Make a burst attack<coneDescription>. Lower accuracy against distant enemies, and further reduced accuracy if not fired <em>prone</em>, braced on the bipod.<interrupts_info>")},
    {"GameTerm", "Setup", "Description",
        T(777731488769, "<em>Machine guns</em> need to be set before firing to avoid suffering a heavy <em>Accuracy</em> penalty."),
        T(681987343557, "Heavy weapons such as <em>machine guns</em> suffer heavy <em>Accuracy</em> and <em>Recoil</em> penalties unless fired <em>prone</em>. Setting up a machine gun puts you prone.")},

    ---- camouflage shrinks the visible silhouette (A.CamoExposedPct) instead of weakening aim
    {"InventoryItemDefs", "CamoArmor_Light", "AdditionalHint",
        T(990395288798, "<bullet_point> Harder to detect by enemies\n<bullet_point> Aiming is less effective against camouflaged targets\n<bullet_point> Can't be combined with weave or ceramics"),
        T(957147208105, "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point>Can't be combined with weave or ceramics")},
    {"InventoryItemDefs", "CamoArmor_Medium", "AdditionalHint",
        T(265860069213, "<bullet_point> Harder to detect by enemies\n<bullet_point> Aiming is less effective against camouflaged targets\n<bullet_point> Can't be combined with weave or ceramics"),
        T(118813633810, "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point>Can't be combined with weave or ceramics")},
    {"InventoryItemDefs", "CamoArmor_Light_Kompositum", "AdditionalHint",
        T(484160716674, "<bullet_point> Harder to detect by enemies\n<bullet_point> Aiming is less effective against camouflaged targets\n<bullet_point> Combined with Kompositum 58"),
        T(860032154218, "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point>Combined with Kompositum 58")},
    {"InventoryItemDefs", "CamoArmor_Medium_Kompositum", "AdditionalHint",
        T(409387533354, "<bullet_point> Harder to detect by enemies\n<bullet_point> Aiming is less effective against camouflaged targets\n<bullet_point> Combined with Kompositum 58"),
        T(990049214333, "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point>Combined with Kompositum 58")},
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
        ---- item instances read the generated class, not the preset
        local class = s[1] == "InventoryItemDefs" and g_Classes[s[2]]
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


local t_id_table = {
    [153781665575] = "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Cumbersome (no Free Move)\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increases Stance AP cost by 1 (negated by high Strength)\n",
    [242435461626] = "Shooting Stance Cost: ",
    [766379566745] = "Shooting Angle: ",
    [412593832155] = "Reliability: ",
    [654134899415] = "Noise Radius: ",
    [684546854913] = "Base critical chance: ",
    [507781478006] = "Maximum critical scaling: ",
    [247182652462] = "Extra critical damage: ",
    [651371401489] = "Point Blank Range Accuracy: ",
    [852084205321] = "Hipfire Penalty Multiplier: ",
    [258395588915] = "Snapshot Penalty Multiplier: ",
    [151451884832] = "Recoil Penalty Multiplier: ",
    [896979362710] = "Minimum Recoil Multiplier: ",
    [158466723759] = "Recommended Strength: ",
    [785975283217] = " STR",
    [719583632117] = "Number of Pellets: ",
    [193184162359] = "Pellet Spread Angle: ",
	[184329577856] = "Handling Penalty Multiplier: ",
	[219437987174] = "Aim accuracy: ",
	[927619797396] = "Shoots <em><num> bullets</em> at the target. The accuracy of each shot is reduced by <em>Recoil</em>. Critical chance is reduced.",
	[440275763653] = "Shoots a hail of <em><bullets> bullets</em> and inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Critical chance is reduced.",
	[111492168137] = "The Dual Shot attack produces a Basic Attack from each gun. Has a penalty based on <em>Dexterity</em>.",
	[656962772885] = "Focus on a cone-shaped area, immobilizing yourself and going <em>prone</em>. You can only shoot enemies inside that cone. Enemies will provoke <em>interrupt</em> attacks with actions inside the cone (even if your AP are spent). <em>Interrupt</em> attacks have bonus accuracy. Your weapon will have increased <em>Shooting Angle</em> while you are in setup.",
	[872453352285] = "Make a burst attack<coneDescription>. Lower accuracy against distant enemies, and further reduced accuracy if not fired <em>prone</em>, braced on the bipod.<interrupts_info>",
	[681987343557] = "Heavy weapons such as <em>machine guns</em> suffer heavy <em>Accuracy</em> and <em>Recoil</em> penalties unless fired <em>prone</em>. Setting up a machine gun puts you prone.",
	[957147208105] = "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point> Can't be combined with weave or ceramics",
	[118813633810] = "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point> Can't be combined with weave or ceramics",
	[860032154218] = "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point> Combined with Kompositum 58",
	[990049214333] = "<bullet_point> Harder to detect by enemies\n<bullet_point> Camouflaged targets are harder to hit, as less of their body can be seen\n<bullet_point> Combined with Kompositum 58"
}

ratG_T_table['DESCRIPTION_HINTS_get.lua'] = t_id_table


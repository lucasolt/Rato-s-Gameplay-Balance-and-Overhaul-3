local file_str = 'DESCRIPTION_HINTS_get.lua'

function GBO_GetDescriptionHints(self)
    local formattedString = "<style CrosshairAPTotal>"

    local owner = self.owner and (not gv_SatelliteView and g_Units[self.owner] or gv_UnitData[self.owner])
    ---- merc stats cap at 100, so this is the weapon's own best value
    local reference = {placeholder = true, Marksmanship = 100, Dexterity = 100, Strength = 100}

    local function GetRecoil_mul(self, attacker)
        local recoil = GetWepRecoil(self, attacker, true)
        if attacker then
            recoil = recoil * GetRecoilOther(self, attacker, false) * GetCaliberStrRecoil(self, attacker)
        end
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

    local function GetAPStance_display(self, unit)
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

    local function GetCritPerAim_display(self, unit)
        local per_aim = MulDivRound(Rat_WeaponCritPerAim(self), rGetHandEyeCoordination(unit), 100)
        local sign = per_aim < 0 and "-" or ""
        per_aim = abs(per_aim)
        return string.format("%s%d.%02d", sign, per_aim / 100, per_aim % 100)
    end

    local angularCTHActive = IsACHTActive()
	local termList = {
	    {
	        id = "ShootingStanceCost",
	        TranslationTable[242435461626] or "Shooting Stance Cost: ",
	        GetAPStance_display(self, owner or reference), " AP",
	        base = owner and GetAPStance_display(self, reference),
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
	        id = "CriticalPerAim",
	        TranslationTable[318826540117] or "Critical chance per aim: ",
	        GetCritPerAim_display(self, owner or reference), "%",
	        base = owner and GetCritPerAim_display(self, reference),
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
	        TranslationTable[151451884832] or "Recoil Penalty Multiplier: ",
	        GetRecoil_mul(self, owner or reference), "X",
	        base = owner and GetRecoil_mul(self, reference),
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

	if self:CanAutofire() then
		local tenths = MulDivRound(Rat_AutoAPPerRound(self), 10, const.Scale.AP)
		table.insert(termList, {
			id = "RateOfFire",
			TranslationTable[638215904417] or "Rate of Fire: ",
			self.RPM or 0,
			string.format(" RPM (<color PDABrowserTextHighlight>%d.%d</color> ", tenths / 10, tenths % 10) ..
				_InternalTranslate(ratT(file_str, 638215904418, "AP/extra round")) .. ")" ..
				(self.AutoFireOnly and (TranslationTable[638215904419] or ", full auto only") or "")
		})
	end

	local crit_idx = table.find(termList, "id", "CriticalPerAim")
	if self:CanAutofire() then
		table.insert(termList, crit_idx + 1, {
			id = "AutofireCritical",
			TranslationTable[318826540119] or "Critical chance on autofire: " ,
			--"x" .. const.Combat.AutoFireCritMul, "%"
			const.Combat.AutoFireCritMul/100.00, "x"
		})
	end
	if Rat_HasSelectiveBurst(self) and table.find(self.AvailableAttacks or empty_table, "BurstFire") then
		table.insert(termList, crit_idx + 1, {
			id = "BurstCritical",
			TranslationTable[318826540118] or "Critical chance on burst: ",
			--"x" .. self.BurstCritMul, "%"
			self.BurstCritMul/100.00, "x"
		})
	end

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
	    	    "</color>" .. term[3] ..
	    	    ((term.base and term.base ~= term[2]) and ("<color PDABrowserFlavor> (" .. term.base .. term[3] .. ")</color>") or "") ..
	    	    "\n"
		end
	end

	formattedString = formattedString .. "</style>"

	if self:IsCumbersome() then
	    formattedString = formattedString .. (TranslationTable[153781665575] or
	        "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Cumbersome (no Free Move)\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increases Stance AP cost by 1 (negated by high Strength)\n")
	end

	return T {formattedString}
end



local t_id_table = {
    [153781665575] = "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Cumbersome (no Free Move)\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increases Stance AP cost by 1 (negated by high Strength)\n",
    [242435461626] = "Shooting Stance Cost: ",
    [766379566745] = "Shooting Angle: ",
    [412593832155] = "Reliability: ",
    [654134899415] = "Noise Radius: ",
    [684546854913] = "Base critical chance: ",
    [318826540117] = "Critical chance per aim: ",
    [318826540118] = "Critical chance on burst: ",
    [318826540119] = "Critical chance on autofire: ",
    [247182652462] = "Extra critical damage: ",
    [651371401489] = "Point Blank Range Accuracy: ",
    [852084205321] = "Hipfire Penalty Multiplier: ",
    [258395588915] = "Snapshot Penalty Multiplier: ",
    [151451884832] = "Recoil Penalty Multiplier: ",
    [158466723759] = "Recommended Strength: ",
    [785975283217] = " STR",
    [719583632117] = "Number of Pellets: ",
    [193184162359] = "Pellet Spread Angle: ",
	[184329577856] = "Handling Penalty Multiplier: ",
	[219437987174] = "Aim accuracy: ",
	[638215904417] = "Rate of Fire: ",
	--[638215904418] = "AP per extra round",

}

ratG_T_table[file_str] = ratG_T_table[file_str] or {}

for id, text in pairs(t_id_table) do
    ratG_T_table[file_str][id] = text
end

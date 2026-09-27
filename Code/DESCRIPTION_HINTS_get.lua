local file_str = 'DESCRIPTION_HINTS_get.lua'

---- merc stats cap at 100, so this is the weapon's own best value
local HintReference = {placeholder = true, Marksmanship = 100, Dexterity = 100, Agility = 100, Strength = 100}

local function HintRecoil(weapon, attacker)
    local recoil = GetWepRecoil(weapon, attacker, true)
    if attacker then
        recoil = recoil * GetRecoilOther(weapon, attacker, false) * GetCaliberStrRecoil(weapon, attacker)
    end
    return cRound(recoil * 100)
end

---- aim 0 = hipfire, 1 = snapshot; Reflexes factor mirrors CTH_hipfire_and_snapshot.lua
local function HintHipSnap(weapon, aim, unit)
    local mul = GetWeaponHipfireOrSnapshotMul(weapon, false, false, true, aim)
    if unit then
        mul = mul * (1.35 - 0.70 * rGetReflex(unit) / 100)
    end
    return cRound(mul * 100)
end

---- Hand-Eye scaling mirrors CTH_pointblank.lua; a negative bonus scales inversely there
local function HintPB(weapon, unit)
    local pb = GetPBbonus(weapon)
    if not unit then
        return pb
    end
    local min, max = const.Combat.R_MinAimScaling, const.Combat.R_MaxAimScaling
    local scale = Clamp(min + MulDivRound(max - min, rGetHandEyeCoordination(unit) - 10, 90), min, max)
    if pb < 0 then
        scale = 150 - scale
    end
    return MulDivRound(pb, scale, 100)
end

local function HintStanceAP(weapon, unit)
    return MulDivRound(GetWeapon_StanceAP(unit, weapon, true), 1, const.Scale.AP) +
               MulDivRound(Get_AimCost(unit), 1, const.Scale.AP)
end

local function HintCritPerAim(weapon, unit)
    return MulDivRound(Rat_WeaponCritPerAim(weapon), rGetHandEyeCoordination(unit), 100)
end

local function HintHundredths(v)
    local sign = v < 0 and "-" or ""
    v = abs(v)
    return string.format("%s%d.%02d", sign, v / 100, v % 100)
end

---- bar value of each row at the reference merc, for the preset scan; lower = smaller is better
local HintBarRows = {
    StanceAP = {lower = true, value = function(w) return HintStanceAP(w, HintReference) end},
    Angle = {value = function(w) return w:GetProperty("OverwatchAngle") end},
    Reliability = {value = function(w) return w.Reliability end},
    Noise = {lower = true, value = function(w) return w.Noise end},
    Crit = {value = function(w) return w.CritChance end},
    CritPerAim = {value = function(w) return HintCritPerAim(w, HintReference) end},
    CritDamage = {value = function(w) return w.CritDamage end},
    AimAccuracy = {value = function(w) return w.AimAccuracy end},
    PB = {value = function(w) return GetPBbonus(w) end},
    Handling = {lower = true, value = function(w) return Rat_ApertureHandlingMul(w) end},
    Hipfire = {lower = true, value = function(w) return HintHipSnap(w, 0) end},
    Snapshot = {lower = true, value = function(w) return HintHipSnap(w, 1) end},
    Recoil = {lower = true, value = function(w) return HintRecoil(w, HintReference) end},
    RPM = {value = function(w) return w.RPM or 0 end, applies = function(w) return w:CanAutofire() end},
}

---- headroom past the stock extremes, since components push values beyond them
local HintBarPadPct = 15
local HintBarRanges

---- scans every firearm preset once per session
local function GetHintBarRanges()
    if HintBarRanges then
        return HintBarRanges
    end
    local lo, hi = {}, {}
    ForEachPreset("InventoryItemCompositeDef", function(preset)
        local class = g_Classes[preset.id]
        if not IsKindOf(class, "Firearm") or IsKindOf(class, "HeavyWeapon") then
            return
        end
        local w = PlaceInventoryItem(preset.id)
        for id, row in pairs(HintBarRows) do
            if not row.applies or row.applies(w) then
                local ok, v = pcall(row.value, w)
                if ok and v then
                    lo[id] = Min(lo[id] or v, v)
                    hi[id] = Max(hi[id] or v, v)
                end
            end
        end
        DoneObject(w)
    end)
    HintBarRanges = {}
    for id in pairs(lo) do
        local pad = Max(1, MulDivRound(hi[id] - lo[id], HintBarPadPct, 100))
        HintBarRanges[id] = {lo[id] - pad, hi[id] + pad}
    end
    return HintBarRanges
end

---- ~150ms: run it behind the loading screen instead of on the first hover
function OnMsg.NewMapLoaded()
    GetHintBarRanges()
end

local function HintBarFrac(id, v)
    local r = GetHintBarRanges()[id]
    if not r or not v then
        return
    end
    local frac = Clamp(MulDivRound(v - r[1], 1000, r[2] - r[1]), 0, 1000)
    return HintBarRows[id].lower and 1000 - frac or frac
end

---- bar built from 4px-unit tiles: <image> cannot clip, and 1px tiles truncate to 0 width at ImageScale 500
local HintBarSeg, HintBarSegs, HintBarDiv = 12, 4, 1
local HintBarUnits = HintBarSeg * HintBarSegs + HintBarDiv * (HintBarSegs - 1)
local HintBarImg = "Mod/cfahRED/Images/StatBar/"
local HintBarColors = {fill = "206 200 178", ref = "110 106 92", empty = "52 57 68", gap = "12 12 12"}

local function HintBarTiles(units, color)
    local s = ""
    for _, u in ipairs{8, 4, 2, 1} do
        while units >= u do
            s = s .. "<image " .. HintBarImg .. "u" .. u .. ".png 1000 " .. HintBarColors[color] .. ">"
            units = units - u
        end
    end
    return s
end

---- fill up to the owner's value, dim up to the reference when the reference is better
local function HintBar(id, v, ref)
    local fv = HintBarFrac(id, v)
    if not fv then
        return "<image " .. HintBarImg .. "blank.png 1000>"
    end
    local fr = Max(fv, HintBarFrac(id, ref) or fv)
    local total = HintBarSeg * HintBarSegs
    fv, fr = MulDivRound(total, fv, 1000), MulDivRound(total, fr, 1000)
    local s = ""
    for i = 0, HintBarSegs - 1 do
        local a = i * HintBarSeg
        local f = Clamp(fv - a, 0, HintBarSeg)
        local r = Clamp(fr - a, 0, HintBarSeg) - f
        s = s .. HintBarTiles(f, "fill") .. HintBarTiles(r, "ref") .. HintBarTiles(HintBarSeg - f - r, "empty")
        if i < HintBarSegs - 1 then
            s = s .. HintBarTiles(HintBarDiv, "gap")
        end
    end
    return s
end

function GBO_GetDescriptionHints(self)
    local formattedString = "<style CrosshairAPTotal>"

    local owner = self.owner and (not gv_SatelliteView and g_Units[self.owner] or gv_UnitData[self.owner])
    local unit = owner or HintReference

    local angularCTHActive = IsACHTActive()
    ---- only the classic CTH scales hipfire/snapshot/PB by the merc; aCTH reads no stat there
    local classic_owner = not angularCTHActive and owner

    local stance_ap, crit_per_aim, recoil = HintStanceAP(self, unit), HintCritPerAim(self, unit), HintRecoil(self, unit)
    local hip, snap = HintHipSnap(self, 0, classic_owner), HintHipSnap(self, 1, classic_owner)
    local pb = HintPB(self, classic_owner)
    local handling = Rat_ApertureHandlingMul(self)

	local termList = {
	    {
	        id = "ShootingStanceCost",
	        TranslationTable[242435461626] or "Shooting Stance Cost: ",
	        stance_ap, " AP",
	        base = owner and HintStanceAP(self, HintReference),
	        bar = "StanceAP",
	    },
	    {
	        id = "ShootingAngle",
	        TranslationTable[766379566745] or "Shooting Angle: ",
	        string.format("%.2f", self:GetProperty("OverwatchAngle") / 60.0), "º",
	        bar = "Angle", bar_v = self:GetProperty("OverwatchAngle"),
	    },
	    {
	        id = "Reliability",
	        TranslationTable[412593832155] or "Reliability: ",
	        self.Reliability, "%",
	        bar = "Reliability",
	    },
	    {
	        id = "NoiseRadius",
	        TranslationTable[654134899415] or "Noise Radius: ",
	        self.Noise, " tiles",
	        bar = "Noise",
	    },
	    {
	        id = "BaseCriticalChance",
	        TranslationTable[684546854913] or "Base critical chance: ",
	        self.CritChance, "%",
	        bar = "Crit",
	    },
	    {
	        id = "CriticalPerAim",
	        TranslationTable[318826540117] or "Critical chance per aim: ",
	        HintHundredths(crit_per_aim), "%",
	        base = owner and HintHundredths(HintCritPerAim(self, HintReference)),
	        bar = "CritPerAim", bar_v = crit_per_aim, bar_ref = owner and HintCritPerAim(self, HintReference),
	    },
	    {
	        id = "ExtraCriticalDamage",
	        TranslationTable[247182652462] or "Extra critical damage: ",
	        self.CritDamage, "%",
	        bar = "CritDamage",
	    },
		{
			id = "AimAccuracy",
			TranslationTable[219437987174] or "Aim accuracy: ",
			self.AimAccuracy, "",
			bar = "AimAccuracy",
		},
	    angularCTHActive and {
	        id = "PointBlankRangeAccuracy",
	        TranslationTable[184329577856] or "Handling Penalty Multiplier: ",
			---- em aCTH o manejo e multiplicador de cone: mesma leitura de hipfire/snapshot/recoil, MENOR = melhor
	        HintHundredths(handling), "X",
	        bar = "Handling", bar_v = handling,
	    } or {
	        id = "PointBlankRangeAccuracy",
	        TranslationTable[651371401489] or "Point Blank Range Accuracy: ",
	        pb, "%",
	        base = classic_owner and GetPBbonus(self),
	        bar = "PB",
	    },
	    {
	        id = "HipfirePenaltyMultiplier",
	        TranslationTable[852084205321] or "Hipfire Penalty Multiplier: ",
	        HintHundredths(hip), "X",
	        base = classic_owner and HintHundredths(HintHipSnap(self, 0)),
	        bar = "Hipfire", bar_v = hip, bar_ref = classic_owner and HintHipSnap(self, 0),
	    },
	    {
	        id = "SnapshotPenaltyMultiplier",
	        TranslationTable[258395588915] or "Snapshot Penalty Multiplier: ",
	        HintHundredths(snap), "X",
	        base = classic_owner and HintHundredths(HintHipSnap(self, 1)),
	        bar = "Snapshot", bar_v = snap, bar_ref = classic_owner and HintHipSnap(self, 1),
	    },
	    {
	        id = "RecoilPenaltyMultiplier",
	        TranslationTable[151451884832] or "Recoil Penalty Multiplier: ",
	        HintHundredths(recoil), "X",
	        base = owner and HintHundredths(HintRecoil(self, HintReference)),
	        bar = "Recoil", bar_v = recoil, bar_ref = owner and HintRecoil(self, HintReference),
	    },
	    {
	        id = "RecommendedStrength",
	        TranslationTable[158466723759] or "Recommended Strength: ",
	        Recoil_StrBreakpoint(self),
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
	        string.format("%.2f", self:GetProperty("BuckshotConeAngle") / 60.0), "º"
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
				(self.AutoFireOnly and (TranslationTable[638215904419] or ", full auto only") or ""),
			bar = "RPM",
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
			local bar_ref = term.bar_ref or (type(term.base) == "number" and term.base)
	    	formattedString = formattedString ..
	    	    HintBar(term.bar, term.bar_v or term[2], bar_ref) .. "  " ..
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

---- Numeric mod option, or `default` while options are not loaded yet
function GBO_Opt(id, default)
	local v = CurrentModOptions and CurrentModOptions[id]
	return type(v) == "number" and v or default
end

---- Vanilla SightModMinValue; Blinded/Distracted get exactly this floor as their sight
GBO_SIGHT_FLOOR = 40

---- Night base sight in tiles against an unlit target. NightSightReduction scales Aware; Unaware (and
---- anyone looking at a Hidden unit) never sees further than that. Stealth, camo, prone and grass
---- then apply as by day: the darkness modifier is 0, so it no longer sinks every case to the floor.
function GBO_NightBaseSight(unit, base_sight, unaware)
	local pct = GBO_Opt("NightSightReduction", 70)
	if unit:HasNightVision() then
		pct = MulDivRound(pct, CharacterEffectDefs.NightOps:ResolveValue("night_vision_penalty_reduction"), 100)
	end
	local aware = MulDivRound(base_sight or const.Combat.AwareSightRange, 100 - pct, 100)
	return unaware and Min(aware, const.Combat.UnawareSightRange) or aware
end

local GetSightRadius_orig = Unit.GetSightRadius

function Unit:GetSightRadius(other, base_sight, step_pos)
	if other and (GameState.Night or GameState.Underground) and not IsIlluminated(other, nil, nil, step_pos) then
		---- same Unaware rule as vanilla: a hidden target is judged with Unaware sight; a given base is Aware
		local unaware = not base_sight and (IsKindOf(other, "Unit") and other:HasStatusEffect("Hidden") or not self:IsAware())
		base_sight = GBO_NightBaseSight(self, base_sight, unaware)
	end
	return GetSightRadius_orig(self, other, base_sight, step_pos)
end

function GBO_ApplyOptions()
	print("GBO - Options setting up...")

	const.Combat.UnawareSightRange = GBO_Opt("UnawareSightRange", 14)
	const.Combat.AwareSightRange = GBO_Opt("AwareSightRange", 56)
	const.EnvEffects.DarknessDetectionRate = -GBO_Opt("NightDetectReduction", 40)
	---- the night penalty lives in GBO_NightBaseSight
	const.EnvEffects.DarknessSightMod = 0
	const.Combat.SightModMinValue = GBO_SIGHT_FLOOR

	const.Combat.R_OWMul = GBO_Opt("OWBonusPct", 100)
	const.Combat.R_MarksMul = GBO_Opt("MarksEffectPct", 100)
	const.Combat.R_MeleeMul = GBO_Opt("MeleeStatPct", 100)
	const.Combat.R_Recoil = GBO_Opt("RecoilPct", 100)
	const.Combat.R_RecoilP = GBO_Opt("PersistentRecoilPct", 100)
	const.Combat.R_ExtraAP = GBO_Opt("ExtraMaxAP", 0)

	print("GBO - Options setting finished")
end

function OnMsg.ApplyModOptions(id)
    if id ~= CurrentModId then
        return
    end
	GBO_ApplyOptions()
end

---- Our GetOptionMeta wrapper -> what it wrapped, so a hot load does not stack wrappers
GBO_OPT_META_WRAPS = setmetatable({}, weak_keys_meta)

function GBO_FormatOptionDefault(option)
	local v = option.DefaultValue
	if type(v) == "boolean" then
		return v and "On" or "Off"
	end
	return tostring(v)
end

---- `<default>` in a GBO option's Help shows its DefaultValue in the in-game tooltip
function GBO_HookOptionDefaultTag()
	local orig = ModItemOption.GetOptionMeta
	while GBO_OPT_META_WRAPS[orig] do
		orig = GBO_OPT_META_WRAPS[orig]
	end
	local function wrapper(self)
		local meta = orig(self)
		if self.mod and self.mod.id == CurrentModId and meta.help then
			meta.help = T{meta.help, default = GBO_FormatOptionDefault(self)}
		end
		return meta
	end
	GBO_OPT_META_WRAPS[wrapper] = orig
	---- Number/Choice call ModItemOption.GetOptionMeta; Toggle got a copy of it at class build
	for _, class in pairs(g_Classes) do
		if IsKindOf(class, "ModItemOption") and GBO_OptMetaIsBase(class.GetOptionMeta, orig) then
			class.GetOptionMeta = wrapper
		end
	end
end

function GBO_OptMetaIsBase(fn, orig)
	while GBO_OPT_META_WRAPS[fn] do
		fn = GBO_OPT_META_WRAPS[fn]
	end
	return fn == orig
end

---- Classes are rebuilt after mod code loads, which drops a file-scope hook
OnMsg.ClassesBuilt = GBO_HookOptionDefaultTag
OnMsg.AutorunEnd = GBO_HookOptionDefaultTag
OnMsg.ModsReloaded = GBO_HookOptionDefaultTag




function OnMsg.ApplyModOptions(mod_id)

    if mod_id == "Msdfsds3" or mod_id == "SmartOverwatch" then
        print("GBO - Smart Overwatch detected, overwriting MG setup get ap")
        rat_MGSetup_getap()
        -- add_recalcUI()
    end
end

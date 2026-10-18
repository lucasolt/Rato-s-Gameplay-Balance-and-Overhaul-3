---- Numeric mod option, or `default` while options are not loaded yet
function GBO_Opt(id, default)
	local v = CurrentModOptions and CurrentModOptions[id]
	return type(v) == "number" and v or default
end

function GBO_ApplyOptions()
	print("GBO - Options setting up...")

	const.Combat.UnawareSightRange = GBO_Opt("UnawareSightRange", 14)
	const.Combat.AwareSightRange = GBO_Opt("AwareSightRange", 56)
	const.EnvEffects.DarknessDetectionRate = -GBO_Opt("NightDetectReduction", 40)
	const.EnvEffects.DarknessSightMod = -GBO_Opt("NightSightReduction", 40)

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




function OnMsg.ApplyModOptions(mod_id)

    if mod_id == "Msdfsds3" or mod_id == "SmartOverwatch" then
        print("GBO - Smart Overwatch detected, overwriting MG setup get ap")
        rat_MGSetup_getap()
        -- add_recalcUI()
    end
end

---- Numeric mod option, or `default` while options are not loaded yet
function GBO_Opt(id, default)
	local v = CurrentModOptions and CurrentModOptions[id]
	return type(v) == "number" and v or default
end

---- Vanilla SightModMinValue. GetSightRadius clamps the whole sight modifier there, which capped
---- NightSightReduction at 60; Blinded/Distracted get exactly this floor as their sight.
GBO_SIGHT_FLOOR = 40

---- At night (and underground) the floor drops to what NightSightReduction leaves
function GBO_UpdateSightFloor()
	local floor = GBO_SIGHT_FLOOR
	if GameState.Night or GameState.Underground then
		floor = Min(floor, 100 - GBO_Opt("NightSightReduction", 40))
	end
	const.Combat.SightModMinValue = floor
end

function OnMsg.GameStateChanged(changed)
	if changed.Night ~= nil or changed.Underground ~= nil then
		GBO_UpdateSightFloor()
	end
end

function GBO_ApplyOptions()
	print("GBO - Options setting up...")

	const.Combat.UnawareSightRange = GBO_Opt("UnawareSightRange", 14)
	const.Combat.AwareSightRange = GBO_Opt("AwareSightRange", 56)
	const.EnvEffects.DarknessDetectionRate = -GBO_Opt("NightDetectReduction", 40)
	const.EnvEffects.DarknessSightMod = -GBO_Opt("NightSightReduction", 40)
	GBO_UpdateSightFloor()

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

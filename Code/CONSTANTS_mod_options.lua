local function extractNumberWithSignFromString(str)
    if not str then
        return false
    end
    local num = tonumber(string.match(str, "[+-]?%d+"))
    if num then
        return num
    else
        return false
    end
end

function GBO_ApplyOptions(current_mod)
	print("GBO - Options setting up...")
	local GBOMOD_Options 
	if current_mod then 
		GBOMOD_Options = CurrentModOptions
	else
		for _, mod in ipairs(ModsLoaded) do
			if mod.id == "cfahRED" then
				GBOMOD_Options = mod.options
				break
			end
		end
	end
	if not GBOMOD_Options then 
		return 
	end

    const.Combat.UnawareSightRange = extractNumberWithSignFromString(
                                         GBOMOD_Options['UnawareSight']) or const.Combat.UnawareSightRange
    const.Combat.AwareSightRange =
        extractNumberWithSignFromString(GBOMOD_Options['AwareSight']) or const.Combat.AwareSightRange
    const.EnvEffects.DarknessDetectionRate = extractNumberWithSignFromString(
                                                 GBOMOD_Options['NightDetect']) or const.EnvEffects.DarknessDetectionRate
    const.EnvEffects.DarknessSightMod = extractNumberWithSignFromString(
                                            GBOMOD_Options['NightSight']) or const.EnvEffects.DarknessSightMod 

    -- custom
    const.Combat.R_AimMul = extractNumberWithSignFromString(GBOMOD_Options['aim_multiplier']) or
                                100
    const.Combat.R_OWMul = extractNumberWithSignFromString(GBOMOD_Options['ow_multiplier']) or
                               100
    const.Combat.R_MarksMul =
        extractNumberWithSignFromString(GBOMOD_Options['marks_multiplier']) or const.Combat.R_MarksMul
    const.Combat.R_MeleeMul =
        extractNumberWithSignFromString(GBOMOD_Options['melee_multiplier']) or const.Combat.R_MeleeMul

    const.Combat.R_Recoil = extractNumberWithSignFromString(GBOMOD_Options['recoil_setting']) or
                                const.Combat.R_Recoil 
    const.Combat.R_RecoilP = extractNumberWithSignFromString(
                                 GBOMOD_Options['recoil_persistent_setting']) or const.Combat.R_RecoilP

    const.Combat.R_TargetedMul = extractNumberWithSignFromString(
                                     GBOMOD_Options['targeted_multiplier']) or const.Combat.R_TargetedMul

    const.Combat.R_AIReduc =
        extractNumberWithSignFromString(GBOMOD_Options['ai_penal_setting']) or const.Combat.R_AIReduc

    const.Combat.R_ExtraAP = extractNumberWithSignFromString(GBOMOD_Options['Extra_start_ap']) or
                                 const.Combat.R_ExtraAP
	print("GBO - Options setting finished")
end

function OnMsg.ApplyModOptions(id)
    if id ~= CurrentModId then
        return
    end
	GBO_ApplyOptions(true) 
end




function OnMsg.ApplyModOptions(mod_id)

    if mod_id == "Msdfsds3" or mod_id == "SmartOverwatch" then
        print("GBO - Smart Overwatch detected, overwriting MG setup get ap")
        rat_MGSetup_getap()
        -- add_recalcUI()
    end
end

function OnMsg.DataLoaded()
    if CurrentModOptions["noise_setting_num"] == "Vanilla" then
        rat_noise_settings("Vanilla")
    end
end

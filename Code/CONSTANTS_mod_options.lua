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

function OnMsg.ApplyModOptions(id)

    if id ~= CurrentModId then

        return
    end

    print("RAT MOD - options setting up")

    const.Combat.UnawareSightRange = extractNumberWithSignFromString(
                                         CurrentModOptions['UnawareSight']) or const.Combat.UnawareSightRange
    const.Combat.AwareSightRange =
        extractNumberWithSignFromString(CurrentModOptions['AwareSight']) or const.Combat.AwareSightRange
    const.EnvEffects.DarknessDetectionRate = extractNumberWithSignFromString(
                                                 CurrentModOptions['NightDetect']) or const.EnvEffects.DarknessDetectionRate
    const.EnvEffects.DarknessSightMod = extractNumberWithSignFromString(
                                            CurrentModOptions['NightSight']) or const.EnvEffects.DarknessSightMod 

    -- custom
    const.Combat.R_AimMul = extractNumberWithSignFromString(CurrentModOptions['aim_multiplier']) or
                                100
    const.Combat.R_OWMul = extractNumberWithSignFromString(CurrentModOptions['ow_multiplier']) or
                               100
    const.Combat.R_MarksMul =
        extractNumberWithSignFromString(CurrentModOptions['marks_multiplier']) or 100
    const.Combat.R_MeleeMul =
        extractNumberWithSignFromString(CurrentModOptions['melee_multiplier']) or 100

    const.Combat.R_Recoil = extractNumberWithSignFromString(CurrentModOptions['recoil_setting']) or
                                100
    const.Combat.R_RecoilP = extractNumberWithSignFromString(
                                 CurrentModOptions['recoil_persistent_setting']) or 100

    const.Combat.R_TargetedMul = extractNumberWithSignFromString(
                                     CurrentModOptions['targeted_multiplier']) or 100

    const.Combat.R_AIReduc =
        extractNumberWithSignFromString(CurrentModOptions['ai_penal_setting']) or 100

    const.Combat.R_ExtraAP = extractNumberWithSignFromString(CurrentModOptions['Extra_start_ap']) or
                                 1
end

function OnMsg.ApplyModOptions(mod_id)

    if mod_id == "Msdfsds3" or mod_id == "SmartOverwatch" then
        print("Smart Overwatch detected, overwriting MG setup get ap for RatMod")
        rat_MGSetup_getap()
        -- add_recalcUI()
    end
end

function OnMsg.DataLoaded()
    if CurrentModOptions["noise_setting_num"] == "Vanilla" then
        rat_noise_settings("Vanilla")
    end
end

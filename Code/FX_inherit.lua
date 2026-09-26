function OnMsg.GetCustomFXInheritActorRules(rules)
    rat_apply_inherit(rules)
end

function rat_apply_inherit(rules)
    -- Define the data table with categories as keys and tags as values
    local data = {
        BarrelLong = {
            "long_barrel_light", "long_barrel_AUG_light", "BarrelHeavyLong", "winni_to54r",
            "BarrelLong_jaggerMeister", "BarrelLongImproved_handgun", "long_barrel_light_handgun",
            "BarrelLong_handgun"
        },
        BarrelNormal = {"BarrelLight", "rpk_to762wp", "BarrelLight_handgun"},
        BarrelShort = {"BarrelShort_Light", "BarrelShort_Light_handgun", "BarrelShort_handgun"},
        M14SAW = {"M14SAW_AUTO"},
        Suppressor = {
            "R_VSS_suppressor", "VSS_Barrel_def_1", "VSS_Barrel_ext_1", "RAT_TOG_suppressor",
            "RAT_VSK_Suppressor", "RAT_TOG_suppressor_762", "RAT_TOG_suppressor_wp",
            "SteyrS_Muzzle_def_1", "VSK94_barrel_def_1"
        },
        Compensator = {"RAT_TOG_compensator", "LionRoar_compensator"},
        LaserDot = {"RAT_TOG_laser_dot", "TAR21_Scope_Rflx_1"},
        UVDot = {"RAT_TOG_uv_dot"},
        -- HE_Grenade = {"HE_Grenade_1"},
        FragGrenade = {"ShapedCharge"},
        UnderslungGrenadeLauncher = {"rat_22mmUnderslungGrenadeLauncher"},
        Warhead_Frag = {"_22m_HE"},
        MP40 = {"VigM2_1", "PP91_1"},
        ToG_VFX_Muzzle = {
            "VigM2_Barrel_def_1", "PP91_Barrel_def_1", "RAT_TOG_compensator",
            "RAT_TOG_CompensatorNoEntity"
        },
		MuzzleBooster = {"MuzzleBooster_Reliability"}
    }

    -- Iterate over the data table to populate the rules
    for category, tags in pairs(data) do
        for _, tag in ipairs(tags) do
            rules[#rules + 1] = tag
            rules[#rules + 1] = category
        end
    end
end

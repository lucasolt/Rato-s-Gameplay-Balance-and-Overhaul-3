if FirstLoad then
    ratG_T_table = {}
    ratG_GunsHurtOriginalDMGValues = {}
    ratG_APScaleOriginals = {}
    ratG_original_UnitGetBaseAimLevelRange =
        Unit.GetBaseAimLevelRange

    ratG_originalFirearmFireBullet =
        Firearm.FireBullet
    ratG_recoilData = {
        small = {
            modifier = 1.20,
            aim_mul = 0.8,
            -- Group 1: Small Caliber Pistols
            ["7_65x21"] = {str = 44},
            ["9x18"] = {str = 45},
            ["22LR"] = {str = 40},
            ["32ACP"] = {str = 42},
            ["380ACP"] = {str = 41},
            -- Group 2: Standard Service and Self-Defense Pistols
            ["9mm"] = {str = 48},
            ["38SP"] = {str = 50},
            ["40SW"] = {str = 52},
            ["45ACP"] = {str = 55},
            ["357MAG"] = {str = 56},
            -- Group 3: High-Velocity Small Calibers
            ["4_6x30"] = {str = 42},
            ["5_7x28"] = {str = 44},
            ["7_62x25"] = {str = 52},
            -- Group 4: Magnum and Large Caliber Pistols
            ["32HRMAG"] = {str = 55},
            -- ["44CAL"] = {str = 58} --- 44Special, no longer used

            ["44AMP"] = {str = 58}

        },
        medium = {
            modifier = 1.40,
            aim_mul = 0.9,
            ["556"] = {str = 65},
            -- Group 5: Assault Rifle and Intermediate Cartridges
            ["5_45x39"] = {str = 62},
            ["4_7x33"] = {str = 60},
            ["300Blackout"] = {str = 64},
            ["9x39"] = {str = 66},
            -----
            ["44MAG"] = {str = 70}, --- 44CAL now is Magnum
            ["44CAL"] = {str = 70}

        },
        medium_large = {
            modifier = 1.50,
            aim_mul = 1.0,

            -- Group 5: Assault Rifle and Intermediate Cartridges
            ["762WP"] = {str = 71},
            ["7_92x33"] = {str = 72},
            -- Group 8: Military Surplus and Obsolete Cartridges
            ["7_5x54"] = {str = 70},
            ["280"] = {str = 68},
            ["303"] = {str = 69},
            -----
            ["50AE"] = {str = 75}

        },
        large = {
            modifier = 1.55,
            aim_mul = 1.1,
            ["12gauge"] = {str = 86},
            -- Group 6: Battle Rifle and Full-Power Rifle Cartridges
            ["30-60"] = { -- 30-06
                str = 80
            },
            ["308Win"] = {str = 78},
            ["762NATO"] = {str = 77},
            ["7_62x54R"] = {str = 81},
            ["7_92x57"] = {str = 79},
            -- Group 7: Precision and Long-Range Rifle Cartridges
            ["6_5Creedmoor"] = {
                str = 75
            },
            ["6_5Grendel"] = {str = 74}

        },
        extra_large = {
            modifier = 1.60,
            aim_mul = 1.3,
            ["50BMG"] = {str = 90},
            ["20x82"] = {str = 90},
            -- Group 7: Precision and Long-Range Rifle Cartridges
            ["300WinMag"] = {str = 84},
            ["338_Lapua_Magnum"] = {
                str = 86
            },
            ["408_ChayTac"] = {str = 88}
        }
    }

    ----- If other mods compatible with GBO want to use different calibers, just insert the caliber on this table
    ratG_UsedCalibers = {
        "9mm", "9x39", "380ACP",
        "7_92x57", "762WP", "9x18",
        "44CAL", "556", "12gauge",
        "308Win", "30-60", "5_7x28",
        "50AE", "5_45x39", "7_92x33",
        "50BMG", "7_62x54R", "762NATO",
        "45ACP", "4_7x33"
    }
end

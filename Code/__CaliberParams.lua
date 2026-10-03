const.Calibers = {
    AP = {
        CostMul = 200,
        AdditionalHint = T({
            "<bullet_point> Improved armor penetration\n<bullet_point> Decreased Critical Damage\n<bullet_point> Increased recoil"
        }),
        Modifications = {
            PenetrationClass = 2,
            CritDamage = -20,
            ArmorPir = 1
        }
    },

    IntermediateCalsAPparams = {
        Modifications = {
            PenetrationClass = -1,
            CritDamage = 10
        }
    },

    HP = {
        CostMul = 200,
        AdditionalHint = T({
            "<bullet_point> No armor penetration\n<bullet_point> High Critical Damage\n<bullet_point> Inflicts <color EmStyle>Bleeding</color> "
        }),
        Modifications = {
            CritDamage = 50,
            PenetrationClass = -4
        },
        AppliedEffects = {"Bleeding"}
    },

    Match = {
        CostMul = 250,
        AdditionalHint = T({
            "<bullet_point> Increased bonus from Aiming\n<bullet_point> Increased range\n<bullet_point> Increased Critical Chance per aim"
        }),
        Modifications = {
            AimAccuracy = 2,
            WeaponRange = 2,
            CritPerAim = 100
        }
    },

    Shock = {
        CostMul = 200,
        AdditionalHint = T({
            "<bullet_point> Reduced range\n<bullet_point> Greater Critical Damage\n<bullet_point> Inflicts <color EmStyle>Bleeding</color> and <color EmStyle>Exposed</color>"
        }),
        Modifications = {
            CritDamage = 70,
            WeaponRange = -4
        },
        AppliedEffects = {
            "Exposed", "Bleeding"
        }
    },

    Tracer = {
        CostMul = 200,
        AdditionalHint = T({
            "<bullet_point> Hit enemies are <color EmStyle>Marked</color> \n<bullet_point> Attacker and target have their positions <color EmStyle>Revealed</color>, making them easier to hit in the dark\n<bullet_point> Easier to compensate recoil in multishot attacks"
        }),
        Modifications = {tracer = 1},
        AppliedEffects = {
            "Marked", "Revealed_R"
        }
    },

    Subsonic = {
        CostMul = 200,
        AdditionalHint = T({
            "<bullet_point> Less noisy\n<bullet_point> Less bullet speed, resulting in less Aim Accuracy, Range and Armor Penetration"
        }),
        Modifications = {
            ---- if table, first is mod_add, second is mod_mul

            Noise = {0, 350},
            PenetrationClass = -1,
            AimAccuracy = -1,
            WeaponRange = -2
        }
    },

    Slug = {
        CostMul = 250,
        DisplayName = T({
            "12-gauge Slug"
        }),
        DisplayNamePlural = T({
            "12-gauge Slugs"
        }),
        AdditionalHint = T({
            "<bullet_point> Fires a single projectile\n<bullet_point> Longer range\n<bullet_point> Improved armor penetration\n<bullet_point> Knocks down target\n<bullet_point> Decreased Critical Damage\n<bullet_point> Increased recoil"
        }),
        Modifications = {
            CritDamage = -20,
            WeaponRange = 8, -- {0, 1500},
            PenetrationClass = 1,
            NumPellets = {0, 0},
            Damage = 31, -- {0, 5000},
            ArmorPir = 1
        },
        AppliedEffects = {"KnockDown"}

    },

    Flechette = {
        CostMul = 200,
        DisplayName = T({
            "12-gauge Flechette"
        }),
        DisplayNamePlural = T({
            "12-gauge Flechettes"
        }),
        AdditionalHint = T({
            "<bullet_point> Longer range\n<bullet_point> Fires more pellets\n<bullet_point> Tighter pellet spread\n<bullet_point> Less damage\n<bullet_point> Penetrates Light Armor\n<bullet_point> Greatly decreased Critical Damage\n<bullet_point> Inflicts <color EmStyle>Bleeding</color>"
        }),
        Modifications = {
            CritDamage = -50,
            PenetrationClass = 1,
            Damage = {0, 400},
            WeaponRange = 2,
            BuckshotConeAngle = {0, 500},
            NumPellets = {0, 2000}
        },
        AppliedEffects = {"Bleeding"}

    },

    Saltshot = {
        CostMul = 150,
        AdditionalHint = T({
            "<bullet_point> Fires more pellets\n<bullet_point> No armor penetration\n<bullet_point> Low damage\n<bullet_point> Shorter range\n<bullet_point> Very wide pellet spread\n<bullet_point> Inflicts <color EmStyle>Inaccurate</color> and <color EmStyle>Slowed</color>"
        }),
        Modifications = {
            PenetrationClass = -4,
            Damage = {0, 100},
            WeaponRange = -4,
            BuckshotConeAngle = {
                0, 2500
            },
            NumPellets = {0, 4000}
        },
        AppliedEffects = {
            "Inaccurate", "Slowed"
        }
    },

    Buckshot = {
        AdditionalHint = T({""})
    },

    HE = {
        CostMul = 200,
        Modifications = {
            CritChance = 50,
            PenetrationClass = -4
        }
    },

    Incendiary = {
        CostMul = 200,
        AppliedEffects = {
            "Exposed", "Burning"
        }
    },

    SLAP = {
        CostMul = 250,
        Modifications = {
            CritChance = 15,
            PenetrationClass = 5
        }
    },

    ---------------------------------------------- Calibers

    _9mm = {
        Cost = 50,
        Modifications = {
            PenetrationClass = 0
        }
    },
    _9x18 = {
        Cost = 35,
        Modifications = {
            PenetrationClass = 0
        }
    },
    _380ACP = {
        Cost = 40,
        Modifications = {
            PenetrationClass = 0
        }
    },
    _45ACP = {
        Cost = 65,
        Modifications = {
            PenetrationClass = 0,
            CritDamage = 20
        }
    },

    _44CAL = {
        Cost = 75,
        Modifications = {
            PenetrationClass = 1
        }
    },

    _5_7x28 = {
        Cost = 180,
        Modifications = {
            PenetrationClass = 1
        }
    },

    _5_45x39 = {
        Description = T({
            "5.45x39 mm ammo for Soviet Assault Rifles, SMGs and Machine Guns.\n\n<bullet_point> Tumbling effects increase Critical Chance"
        }),
        Cost = 150,
        Modifications = {
            CritChance = 8,
            PenetrationClass = 2
        }
    },
    _556 = {
        Description = T({
            "5.56 Ammo for Assault Rifles, SMGs, and Machine Guns.\n\n<bullet_point> Fragmentation effects increase Critical Damage"
        }),
        Cost = 170,
        Modifications = {
            CritDamage = 30,
            PenetrationClass = 2
        }
    },

    _4_7x33 = {
        Cost = 250,
        Modifications = {
            PenetrationClass = 2
        }
    },

    ["_30-60"] = {
        Cost = 100,
        Modifications = {
            PenetrationClass = 2
        }
    },
    _308Win = {
        Cost = 110,
        Modifications = {
            PenetrationClass = 2,
            CritDamage = 10
        }
    },

    _762WP = {
        Cost = 90,
        Modifications = {
            PenetrationClass = 1
        }
    },
    -- TODO: change the 9x39 noise reduction to come from the ammo instead of being on the weapon itself
    _9x39 = {
        Cost = 200,
        Modifications = {
            PenetrationClass = 2
            -- Noise = 13
        }
    },
    _7_92x33 = {
        Cost = 70,
        Modifications = {
            PenetrationClass = 2
        }
    },
    _762NATO = {
        Cost = 180,
        Modifications = {
            PenetrationClass = 2
        }
    },
    _7_62x54R = {
        Cost = 170,
        Modifications = {
            PenetrationClass = 2
        }
    },
    _50AE = {
        Cost = 175,
        Modifications = {
            PenetrationClass = 1
        }
    },

    _7_92x57 = {
        Cost = 80,
        Modifications = {
            PenetrationClass = 2
        }
    },
    _12gauge = {
        Cost = 90,
        Modifications = {
            PenetrationClass = 0
        }
    },
    _50BMG = {
        Cost = 350,
        Modifications = {
            PenetrationClass = 3
        }
    },

    Noise = {
        -- vanilla
        ["9mm"] = 13,
        ["44CAL"] = 19,
        ["12gauge"] = 34,
        ["762WP"] = 25,
        ["556"] = 23,
        ["762NATO"] = 30,
        -- old GBO
        ["5.7x28mm"] = 14,
        ["545x39"] = 22,
        ["792x33"] = 26,
        ["792x57"] = 31,
        ["762x54R"] = 32,
        ["50BMG"] = 41,
        -- Zulib(which were in GBO before udner the same id)
        ["45ACP"] = 13,
        ----
        -- ["MoW_45ACP"] = 17,
        ----
        ["9x39"] = 13,
        -- Zulib
        ["4_6x30"] = 16,
        ["4_7x33"] = 22,
        ["5_7x28"] = 16,
        ["5_45x39"] = 22,
        ["6_5Creedmoor"] = 25,
        ["6_5Grendel"] = 24,
        ["7_5x54"] = 24,
        ["7_62x25"] = 17,
        ["7_62x54R"] = 32,
        ["7_65x21"] = 14,
        ["7_92x33"] = 24,
        ["7_92x57"] = 31,
        ["9x18"] = 13,
        ["20x82"] = 39,
        ["22LR"] = 12,
        ["30-60"] = 25,
        ["32ACP"] = 12,
        ["32HRMAG"] = 18,
        ["38SP"] = 18,
        ["40SW"] = 16,
        ["44AMP"] = 19,
        ["44MAG"] = 19,
        ["50AE"] = 21,
        ["280"] = 24,
        ["300Blackout"] = 21,
        ["300WinMag"] = 26,
        ["303"] = 25,
        ["308Win"] = 30,
        ["338_Lapua_Magnum"] = 27,
        ["357MAG"] = 20,
        ["380ACP"] = 13,
        ["408_ChayTac"] = 28
    }
}

---- weapon Damage = base + Clamp((barrel_len - barrel) * per_100mm / 1000, min, max); per_100mm is in tenths
const.CaliberDamage = {
    ["380ACP"] = {base = 16, barrel = 120, per_100mm = 15, min = -1, max = 2},
    ["9x18"] = {base = 16, barrel = 120, per_100mm = 15, min = -1, max = 2},
    ["9mm"] = {base = 19, barrel = 115, per_100mm = 15, min = -1, max = 2},
    ["5_7x28"] = {base = 18, barrel = 260, per_100mm = 10, min = -1, max = 1},
    ["45ACP"] = {base = 22, barrel = 127, per_100mm = 10, min = -1, max = 1},
    ---- .44 Magnum: a carbine barrel gains much more than a pistol round would
    ["44CAL"] = {base = 27, barrel = 150, per_100mm = 10, min = -1, max = 4},
    ["9x39"] = {base = 25, barrel = 200, per_100mm = 10, min = -1, max = 1},
    ["4_7x33"] = {base = 25, barrel = 380, per_100mm = 8, min = -2, max = 1},
    ["5_45x39"] = {base = 26, barrel = 415, per_100mm = 8, min = -3, max = 1},
    ["556"] = {base = 26, barrel = 500, per_100mm = 8, min = -3, max = 1},
    ["762WP"] = {base = 31, barrel = 415, per_100mm = 8, min = -2, max = 1},
    ["7_92x33"] = {base = 29, barrel = 425, per_100mm = 8, min = -2, max = 1},
    ["762NATO"] = {base = 35, barrel = 500, per_100mm = 6, min = -2, max = 1},
    ["7_62x54R"] = {base = 36, barrel = 600, per_100mm = 6, min = -2, max = 1},
    ["30-60"] = {base = 37, barrel = 610, per_100mm = 6, min = -2, max = 1},
    ["7_92x57"] = {base = 37, barrel = 600, per_100mm = 6, min = -2, max = 1},
    ---- hand cannon: Desert Eagle through its .50 barrel
    ["50AE"] = {base = 30, barrel = 150, per_100mm = 10, min = -1, max = 3},
    ["50BMG"] = {base = 72, barrel = 730, per_100mm = 10, min = -5, max = 2}
}

---- fixed damage that ignores caliber and barrel. The emplaced M2 fires 5-round bursts of full .50 hits
---- at whoever walks into its arc; at 72 a burst is a near-certain kill
const.WeaponDamageHold = {
    BrowningM2HMG = 55
}

function print_const_ammos()
    local amm = const.Calibers
    for k, v in pairs(amm) do
        if k:sub(1, 1) == "_" then -- Check if the first character is "_"
            print(k:sub(2)) -- Remove the underscore and print the rest
        end
    end
end

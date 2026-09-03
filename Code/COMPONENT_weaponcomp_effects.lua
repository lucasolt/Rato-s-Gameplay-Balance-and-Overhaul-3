function weapon_components_rat()

    PlaceObj('WeaponComponentEffect', {
        Description = T(183998509789, "Grants bonus Critical Chance per aim level"),
        group = "FX Placeholders",
        id = "teste"
    })

    PlaceObj('WeaponComponentEffect', {
        Comment = "ChangeWeapon combat action",
        Description = T(954592406374, "Reduce AP necessary to swap to this weapon"),
        group = "Other",
        id = "FreeWeaponSwap"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(388838149410,
                        "Reduced <em>recoil penalty</em>. Reduced <em>Hipfire</em> and <em>Snapshot</em> penalty"),
        group = "FX Placeholders",
        id = "Vert_grip_recoil"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(149904848408, "Greatly increased <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "no_stock"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(498763703334,
                        "Bullpup design, increases Point Blank range accuracy bonus and Shooting Angle"),
        group = "FX Placeholders",
        id = "bullpup"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(187052039397,
                        "Reduced <em>penalty</em> when using <em>Single Shot</em> to target body parts"),
        group = "FX Placeholders",
        id = "boltaction"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(472185658894, "Significant increase in <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "m14_recoil"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(640458057266,
                        "Targets attacked at point-blank range at night become <em>Obfuscated</em>"),
        group = "FX Placeholders",
        id = "FL_blind"

    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(375224625649, "Harder to hit closer targets"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "range_penalty", 'Tag', "<range_penalty>"})
        },
        group = "ChanceToHit",
        id = "ScopePenalty1"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(226367424021, "Harder to hit closer targets"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "range_penalty", 'Tag', "<range_penalty>"})
        },
        group = "ChanceToHit",
        id = "ScopePenalty2"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(938572490156, "Harder to hit closer targets"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "range_penalty", 'Tag', "<range_penalty>"})
        },
        group = "ChanceToHit",
        id = "ScopePenalty3"
    })

    PlaceObj('WeaponComponentEffect', {
        Comment = "Increases the bonus of the Aiming cth modifier. Scales per aim level. ReduceAimAccuracy reduces the same stat, but is implemented through the cth modifier.",
        Description = T(975264803458, "Decreases Accuracy bonus from Aiming"),
        ModificationType = "Subtract",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "AimAccuracyDecrease", 'Tag', "<AimAccuracyDecrease>"})
        },
        RequiredParams = {"AimAccuracyDecrease"},
        StatToModify = "AimAccuracy",
        group = "Stats",
        id = "DecreaseAimAccuracy"
    })

    PlaceObj('WeaponComponentEffect', {
        Comment = "Increases the bonus of the Aiming cth modifier. Scales per aim level. ReduceAimAccuracy reduces the same stat, but is implemented through the cth modifier.",
        Description = T(107850155064, "test"),
        ModificationType = "Subtract",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "OverwatchAngleFlat", 'Tag', "<OverwatchAngleFlat>"})
        },
        RequiredParams = {"OverwatchAngleFlat"},
        StatToModify = "OverwatchAngle",
        group = "Stats",
        id = "Ow_decrease_flat"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(915008271800,
                        "Decreased Hipfire penalty, increased Snapshot penalty, reduced Recoil penalty, decreased Point Blank range accuracy, harder to hit at melee range"),
        group = "ChanceToHit",
        id = "longbarrel"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(173836158177,
                        "Increased Hipfire penalty, decreased Snapshot penalty, increased Recoil penalty, increased Point Blank range accuracy, easier to hit at melee range"),
        group = "ChanceToHit",
        id = "shortbarrel"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(780091744194, "Has bonus damage against <em>Flanked</em> targets"),
        group = "FX Placeholders",
        id = "flanker"

    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(742720959709, "Recovers half <em>free move AP</em> after shooting"),
        group = "FX Placeholders",
        id = "ShootMoving"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(282151114911, "<em>Accuracy</em> penalty when not prone"),
        group = "FX Placeholders",
        id = "bipod_penalty"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(153429703325, "Minor <em>Accuracy</em> penalty"),
        Parameters = {
            PlaceObj('PresetParamPercent', {'Name', "bonus_cth", 'Value', -5, 'Tag', "<bonus_cth>%"})
        },
        group = "FX Placeholders",
        id = "acc_penal_stock"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(176134897607, --[[WeaponComponentEffect ReduceDamage Description]]
                        "Damaged reduced by <DamageReduced>"),
        ModificationType = "Subtract",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "DamageReduced", 'Value', 1, 'Tag', "<DamageReduced>"})
        },
        RequiredParams = {"DamageReduced"},
        StatToModify = "Damage",
        group = "Stats",
        id = "ReduceDamage"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(985718079927, --[[WeaponComponentEffect ReduceDamage Description]]
                        "Damaged reduced by <DamageReducedMul>%"),
        ModificationType = "Multiply",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "DamageReducedMul", 'Value', 100, 'Tag', "<DamageReducedMul>"})
        },
        RequiredParams = {"DamageReducedMul"},
        StatToModify = "Damage",
        group = "Stats",
        id = "ReduceDamagePercentage"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(624517971084,
                        "Decreased <em>Recoil</em> penalty when using the <em>Burst Fire</em> attack mode"),
        ModificationType = "Multiply",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "BurstRecoilDeltaMul", 'Value', 100, 'Tag', "<BurstRecoilDeltaMul>"})
        },
        RequiredParams = {"BurstRecoilDeltaMul"},
        StatToModify = "burst_recoil_delta",
        group = "Stats",
        id = "Reduce_recoil_burst_delta"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(531446098401, --[[WeaponComponentEffect ReduceDamage Description]]
                        "Damaged increased by <DamageIncreasedMul>%"),
        ModificationType = "Multiply",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "DamageIncreasedMul", 'Value', 100, 'Tag', "<DamageIncreasedMul>"})
        },
        RequiredParams = {"DamageIncreasedMul"},
        StatToModify = "Damage",
        group = "Stats",
        id = "IncreaseDamagePercentage"
    })

    PlaceObj('WeaponComponentEffect', {
        CaliberChange = "7_62x54R",
        Description = T(486765316396, "Changes caliber to 7.62x54mmR"),
        group = "Caliber",
        id = "ChangeCaliberTo762_54r"
    })

    PlaceObj('WeaponComponentEffect', {
        CaliberChange = "556",
        Description = T(864532654693, "Changes caliber to 5.56x45mm"),
        group = "Caliber",
        id = "ChangeCaliberTo556"
    })

    PlaceObj('WeaponComponentEffect', {
        CaliberChange = "762WP",
        Description = T(953726500783, "Changes caliber to 7.62x39mm WP"),
        group = "Caliber",
        id = "ChangeCaliberTo762wp"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(687659582586, "Decreases critical chance bonus that scales per merc level"),
        ModificationType = "Subtract",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "CritChangeScaledDecrease", 'Tag', "<CritChangeScaledDecrease>"})
        },
        RequiredParams = {"CritChangeScaledDecrease"},
        StatToModify = "CritChanceScaled",
        group = "Stats",
        id = "DecreaseCritChangeScaled"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(939111789534, "Decreases base critical chance"),
        ModificationType = "Subtract",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "CritChangeDecrease", 'Tag', "<CritChangeDecrease>"})
        },
        RequiredParams = {"CritChangeDecrease"},
        StatToModify = "CritChance",
        group = "Stats",
        id = "DecreaseCritChange"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(398049834770, "Reduced <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "compensator_effect"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(954822518050, "Slightly reduced <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "recoil_booster_effect"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(598891097935, "Reduced <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "integr_muzzle_brake"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(743623158693, "Reduced <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "compensator_effect_silencer"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(776447188724, "Slightly reduced <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "compensator_effect_ugly_silencer"
    })

    --------------------------------------------------------------------------shooting stance update
    PlaceObj('WeaponComponentEffect', {
        Description = T(940310929156,
                        "Reduces <em>AP</em> necessary to get into <em>Shooting Stance</em>"),
        ModificationType = "Subtract",
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "APdecrease", 'Value', 1, 'Tag', "<APdecrease>"})
        },
        RequiredParams = {"APdecrease"},
        StatToModify = "APStance",
        group = "Stats",
        id = "StanceAPdecrease"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(581740565531,
                        "Increases <em>AP</em> necessary to get into <em>Shooting Stance</em>"),
        ModificationType = "Add",
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "APincrease", 'Value', 1, 'Tag', "<APincrease>"})
        },
        RequiredParams = {"APincrease"},
        StatToModify = "APStance",
        group = "Stats",
        id = "StanceAPincrease"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(400216040089, "Decreases <em>Shooting Angle</em>"),
        ModificationType = "Multiply",
        Parameters = {
            PlaceObj('PresetParamNumber', {
                'Name', "OverwatchAngleDecrease", 'Value', 88, 'Tag', "<OverwatchAngleDecrease>"
            })
        },
        -- RequiredParams = {
        -- "OverwatchAngleDecrease",
        -- },
        StatToModify = "OverwatchAngle",
        group = "Stats",
        id = "DecreaseOverwatchAngle"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(601041780492, "Increases <em>Shooting Angle</em>"),
        ModificationType = "Multiply",
        Parameters = {
            PlaceObj('PresetParamNumber', {
                'Name', "OverwatchAngleIncrease", 'Value', 140, 'Tag', "<OverwatchAngleIncrease>"
            })
        },
        RequiredParams = {"OverwatchAngleIncrease"},
        StatToModify = "OverwatchAngle",
        group = "Stats",
        id = "IncreaseOverwatchAngle"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(558731788097, "Increased <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "stocklight_effect_recoil"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(203713773863, "Reduced <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "stockheavy_effect_recoil"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(796931242458,
                        "Significantly reduced penalty to <em>target body parts</em> with attacks with 4+ aim levels"),
        group = "FX Placeholders",
        id = "bodypart_scope"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(725526889720, "Grants bonus Critical Chance per aim level"),
        group = "FX Placeholders",
        id = "critical_per_aim_scope"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(353562872144,
                        "Grants bonus Accuracy to attacks with 3+ aim levels - bonus is based on <em>Weapon Aim Accuracy</em>"),
        group = "FX Placeholders",
        id = "sniper_aim_scope"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(213711882780,
                        "Grants significant bonus Accuracy to attacks with 4+ aim levels - bonus is based on <em>Weapon Aim Accuracy</em>"),
        group = "FX Placeholders",
        id = "sniper_adv_aim_scope"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(247212055308,
                        "Grants bonus Accuracy to attacks with 2+ aim levels - bonus is based on <em>Weapon Aim Accuracy</em>"),
        group = "FX Placeholders",
        id = "pso_dragunov_scope"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(872923011488, "Grants bonus Critical Chance to attacks with 2+ aim levels"),
        group = "FX Placeholders",
        id = "pso_dragunov_scope_critical"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(369880626294, "Grants bonus Critical Chance with aimed attacks"),
        group = "FX Placeholders",
        id = "first_aim_crit"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(905983597373, "Grants a small bonus Critical Chance per aim level"),
        group = "FX Placeholders",
        id = "critical_per_aim_laser"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(617033974337,
                        "Slightly reduced penalty to <em>target body parts</em> with attacks with 3+ aim levels"),
        group = "FX Placeholders",
        id = "body_part_uv"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(337691694250, "Increase AP cost when attacking"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "ShootAPIncrease", 'Tag', "<ShootAPIncrease>"})
        },
        RequiredParams = {"ShootAPIncrease"},
        Scale = "AP",
        StatToModify = "ShootAP",
        group = "Stats",
        id = "IncreaseShootAP"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(830130229420,
                        "Enables - or improves - the <em>Run And Gun</em> attack action"),
        group = "FX Placeholders",
        id = "Enable_RunAndGun"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(165863400633,
                        "Significantly reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "hipfire_dot_effect_laser"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(889586830737,
                        "Significantly reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "hipfire_dot_effect_uv"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(936610188234,
                        "Reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "hipfire_short_barrel"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(649325420444,
                        "Increased <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "hipfire_long_barrel"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(336485327528,
                        "Reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "hipfire_vert_grip"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(905040013361, "Reduced <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "hipfire_no_stock"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(949818133594,
                        "Light Barrel, reduced <em>Snapshot</em> accuracy <em>penalty</em>, increased <em>Recoil</em> penalty"),
        group = "FX Placeholders",
        id = "hipfire_light_barrel"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(983043466921,
                        "Heavy Barrel, reduced <em>Recoil</em> penalty, increased <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "heavy_barrel_effect"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(498214252783, "Increased cost to rotate weapon when prone"),
        group = "FX Placeholders",
        id = "rotate_ap_bipod"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(879653741676,
                        "Enables <em>Burst Fire</em> attack mode, except on interrupt attacks"),
        group = "FX Placeholders",
        id = "Enable_BurstFire"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(958768643867,
                        "Decreased accuracy in <em>Full Auto</em> and <em>Burst Fire</em> attacks"),
        group = "FX Placeholders",
        id = "recoil_bump"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(849532998072,
                        "Decreases number of attacks when using the <em>Run and Gun</em> action"),
        group = "FX Placeholders",
        id = "heavy_stock_rungun"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(159267356053,
                        "Reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "hipfire_light_stock"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(376073238620, "Enables free-swap"),
        group = "FX Placeholders",
        id = "Tog_B93_Grip_freeswap"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(873379225473,
                        "The <em>total</em> Accuracy bonus from aiming is reduced by 10%"),
        group = "FX Placeholders",
        id = "light_stock_aim_reduce"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(183183480025, "Increased <em>Snapshot</em> accuracy <em>penalty</em>"),
        group = "FX Placeholders",
        id = "drum_mag_hipfire"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(266874774409, "Decreases Aim accuracy when prone"),
        group = "FX Placeholders",
        id = "grip_prone_penalty"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(982346640578, "Slightly reduced <em>recoil penalty</em>"),
        group = "FX Placeholders",
        id = "tac_grip_recoil"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(845256852079, "Reduced <em>Hipfire and Snapshot penalty</em>"),
        group = "FX Placeholders",
        id = "tac_grip_hipfire"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(952508575329, "Slightly increased Point-Blank range accuracy bonus"),
        group = "FX Placeholders",
        id = "tac_grip_PB"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(685331648680, "Increases max aim level by <MaxAimActionsIncrease>"),
        Parameters = {
            PlaceObj('PresetParamNumber', {
                'Name', "MaxAimActionsIncrease", 'Value', 1, 'Tag', "<MaxAimActionsIncrease>"
            })
        },
        RequiredParams = {"MaxAimActionsIncrease"},
        StatToModify = "MaxAimActions",
        group = "Stats",
        id = "IncreaseMaxAimActions"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(832057249458,
                        "Increases aim accuracy in <em>close range</em> by <Close_bonus>%"),
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "Close_bonus", 'Value', 6, 'Tag', "<Close_bonus>"})
        },

        RequiredParams = {"Close_bonus"},
        group = "FX Placeholders",
        id = "reflex_sight_close_range"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(244679400091, "Reduces <em>Snapshot Penalty</em> by <snap_reduc>%"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "snap_reduc", 'Value', 10, 'Tag', "<snap_reduc>"})
        },

        RequiredParams = {"snap_reduc"},
        group = "FX Placeholders",
        id = "scope_snapshot"
    })


    PlaceObj('WeaponComponentEffect', {
        Comment = "In OpportunityAttack Cth Modifier",
        Description = T(299071168122,
                        "Increases Accuracy for Interrupt attacks by <bonus_cth_interrupt>%"),
        Parameters = {
            PlaceObj('PresetParamPercent',
                     {'Name', "bonus_cth_interrupt", 'Value', 10, 'Tag', "<bonus_cth_interrupt>%"})
        },

        RequiredParams = {"bonus_cth_interrupt"},
        group = "ChanceToHit",
        id = "OpportunityAttackBonusCth"
    })

    PlaceObj('WeaponComponentEffect', {
        Comment = "In aiming cth",
        Description = T(355372332150, "Increases Accuracy for aimed attacks by <bonus_cth>%"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "bonus_cth", 'Value', 3, 'Tag', "<bonus_cth>"})
        },

        RequiredParams = {"bonus_cth"},
        group = "Aiming",
        id = "AccuracyBonusWhenAimed"
    })

    PlaceObj('WeaponComponentEffect', {
        Comment = "In aiming cth",
        Description = T(210060101900, "Increases Accuracy for aimed attacks by <bonus_cth_v>%"),
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "bonus_cth_v", 'Value', 3, 'Tag', "<bonus_cth_v>"})
        },

        RequiredParams = {"bonus_cth_v"},
        group = "Aiming",
        id = "AccuracyBonusWhenAimed_vgrip"
    })

    PlaceObj('WeaponComponentEffect', {
        Comment = "In aiming cth",
        Description = T(175082911037,
                        "Increases Accuracy for aimed attacks - bonus is based on <em>Weapon Aim Accuracy</em>"),
        group = "Aiming",
        id = "FirstAimBonusModifier"
    })

    PlaceObj('WeaponComponentEffect', {
        Comment = "In aiming cth",
        Description = T(978415485249, "Grants bonus Critical Chance for aimed attacks at the head"),
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "critical_head", 'Value', 20, 'Tag', "<critical_head>"})
        },
        RequiredParams = {"critical_head"},
        group = "Aiming",
        id = "scout_scope_crit"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(195877439875, "Increases <em>Recoil</em> penalty"),
        group = "FX Placeholders",
        id = "FullChokeRecoil"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(674215963791, "Changes pellet spread pattern, reducing vertical spread"),
        ModificationType = "Subtract",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "VerticalSpreadReduction", 'Tag', "<VerticalSpreadReduction>"})
        },
        RequiredParams = {"VerticalSpreadReduction"},
        StatToModify = "VerticalPelletSpreadFactorMul",
        group = "Stats",
        id = "ReduceVerticalPelletSpread"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(912316475877, "Increases Point-Blank range accuracy bonus"),
        ModificationType = "Add",
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "PointBlankBonus", 'Tag', "<PointBlankBonus>"})
        },
        RequiredParams = {"PointBlankBonus"},
        StatToModify = "PBbonus_base",
        group = "Stats",
        id = "IncreasePointBlankAccuracyBonus"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(156932878971, "Decreases Point-Blank range accuracy bonus"),
        ModificationType = "Subtract",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "PointBlankPenalty", 'Tag', "<PointBlankPenalty>"})
        },
        RequiredParams = {"PointBlankPenalty"},
        StatToModify = "PBbonus_base",
        group = "Stats",
        id = "DecreasePointBlankAccuracyBonus"
    })

    PlaceObj('WeaponComponentEffect', {
        Comment = "In aiming cth",
        Description = T(320356428271, "Grants bonus Critical Chance for aimed attacks at the torso"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "crit_torso", 'Value', 20, 'Tag', "<crit_torso>"})
        },
        RequiredParams = {"crit_torso"},
        -- unit_reactions = {
        -- PlaceObj('UnitReaction', {
        -- Event = "OnFirearmAttackStart",
        -- Handler = function (self, target, attacker, attack_target, action, attack_args)

        -- rat_zrak_scope(self, target, attacker, attack_target, action, attack_args)
        -- end,
        -- param_bindings = false,
        -- }),
        -- },
        group = "Aiming",
        id = "zrak_scope_crit"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(695581761922,
                        "After firing, needs to be manually cycled using <ap_manual> AP\nHigh <em>Dexterity</em> can reduce this cost"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "ap_manual", 'Value', 3, 'Tag', "<ap_manual>"})
        },
        RequiredParams = {"ap_manual"},
        group = "Other",
        id = "bolt_action_ap",
        unit_reactions = {
            -- PlaceObj('UnitReaction', {
            -- Event = "OnCalcAPCost",
            -- Handler = function (self, target, current_ap, action, weapon, aim)
            -- if weapon == target then
            -- local attacked = self.fired_bolt_weapon
            -- print("attacked", attacked)

            -- if attacked then 
            -- return current_ap + 1 * const.Scale.AP
            -- end
            -- end
            -- end,
            -- param_bindings = false,
            -- }),
            PlaceObj('UnitReaction', {
                Event = "OnEndTurn",
                Handler = function(self, target)
                    rat_endturn_bolt(self, target)
                end,
                param_bindings = false
            }), PlaceObj('UnitReaction', {
                Event = "OnCombatEnd",
                Handler = function(self, target)
                    rat_endcombat_bolt(self, target)
                end,
                param_bindings = false
            }) -- PlaceObj('UnitReaction', {
            -- Event = "OnUnitAttack",
            -- Handler = function (self, target, attacker, action, attack_target, results, attack_args)
            -- rat_unbolt(self, target, attacker, action, attack_target, results, attack_args)
            -- end,
            -- param_bindings = false,
            -- }),
        }
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(646661766533,
                        "After firing, increases attack AP cost by <ap_double_action>\nCan be manually cycled using <ap_manual> AP\nHigh <em>Dexterity</em> can reduce this cost"),
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "ap_manual", 'Value', 3, 'Tag', "<ap_manual>"}),
            PlaceObj('PresetParamNumber',
                     {'Name', "ap_double_action", 'Value', 1, 'Tag', "<ap_double_action>"})
        },
        RequiredParams = {"ap_double_action", "ap_manual"},
        group = "Other",
        id = "DASA_action_ap",
        unit_reactions = {
            -- PlaceObj('UnitReaction', {
            -- Event = "OnCalcAPCost",
            -- Handler = function (self, target, current_ap, action, weapon, aim)
            -- if weapon == target then
            -- local attacked = self.fired_bolt_weapon
            -- print("attacked", attacked)

            -- if attacked then 
            -- return current_ap + 1 * const.Scale.AP
            -- end
            -- end
            -- end,
            -- param_bindings = false,
            -- }),
            PlaceObj('UnitReaction', {
                Event = "OnEndTurn",
                Handler = function(self, target)
                    rat_endturn_bolt(self, target)
                end,
                param_bindings = false
            }), PlaceObj('UnitReaction', {
                Event = "OnCombatEnd",
                Handler = function(self, target)
                    rat_endcombat_bolt(self, target)
                end,
                param_bindings = false
            }) -- PlaceObj('UnitReaction', {
            -- Event = "OnUnitAttack",
            -- Handler = function (self, target, attacker, action, attack_target, results, attack_args)
            -- rat_unbolt(self, target, attacker, action, attack_target, results, attack_args)
            -- end,
            -- param_bindings = false,
            -- }),
        }
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(212821718310,
                        "Increase Stance AP cost by <StanceIncreaseSTR>, can be negated with <STR_threshold> Strength"),
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "StanceIncreaseSTR", 'Tag', "<StanceIncreaseSTR>"}),
            PlaceObj('PresetParamNumber', {'Name', "STR_threshold", 'Tag', "<STR_threshold>"})
        },
        RequiredParams = {"StanceIncreaseSTR", "STR_threshold"},
        -- Scale = "AP",
        -- StatToModify = "ShootAP",
        -- group = "Stats",
        id = "stance_ap_inc_STR"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(547256645082, "Increases Accuracy and reduces Recoil when Prone"),
        Parameters = {
            PlaceObj('PresetParamPercent', {'Name', "bonus_cth", 'Value', 20, 'Tag', "<bonus_cth>%"})
        },
        group = "ChanceToHit",
        id = "AccuracyBonusProne"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(897995963554, "Increases Point Blank Range accuracy bonus by 1"),
        group = "ChanceToHit",
        id = "vigneron_folded_PB"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(236633317127,
                        "Decreases weapon length, affecting Recoil, Snapshot, Hipfire accuracy penalties and Point Blank Range accuracy modifiers"),
        Parameters = {
            PlaceObj('PresetParamPercent',
                     {'Name', "recoil_mul", 'Value', 100, 'Tag', "<recoil_mul>%"}),
            PlaceObj('PresetParamPercent',
                     {'Name', "snapshot_mul", 'Value', 100, 'Tag', "<snapshot_mul>%"}),
            PlaceObj('PresetParamPercent',
                     {'Name', "hipfire_mul", 'Value', 100, 'Tag', "<hipfire_mul>%"}),
            PlaceObj('PresetParamNumber',
                     {'Name', "pb_bonus_hg", 'Value', 2, 'Tag', "<pb_bonus_hg>"})
        },
        RequiredParams = {"pb_bonus_hg", "hipfire_mul", "snapshot_mul", "recoil_mul"},
        group = "ChanceToHit",
        id = "handguard_short"
    })

    PlaceObj('WeaponComponentEffect', {
        Description = T(219179226706,
                        "Increases weapon length, affecting Recoil, Snapshot, Hipfire accuracy penalties and Point Blank Range accuracy modifiers"),
        Parameters = {
            PlaceObj('PresetParamPercent',
                     {'Name', "recoil_mul", 'Value', 100, 'Tag', "<recoil_mul>%"}),
            PlaceObj('PresetParamPercent',
                     {'Name', "snapshot_mul", 'Value', 100, 'Tag', "<snapshot_mul>%"}),
            PlaceObj('PresetParamPercent',
                     {'Name', "hipfire_mul", 'Value', 100, 'Tag', "<hipfire_mul>%"}),
            PlaceObj('PresetParamNumber',
                     {'Name', "pb_bonus_hg", 'Value', -2, 'Tag', "<pb_bonus_hg>"})
        },
        RequiredParams = {"pb_bonus_hg", "hipfire_mul", "snapshot_mul", "recoil_mul"},
        group = "ChanceToHit",
        id = "handguard_ext"
    })

	PlaceObj('WeaponComponentEffect', {
        Description = T(645613895578, "Increases weapon condition degradation"),
        ModificationType = "Add",
        Parameters = {
            PlaceObj('PresetParamNumber',
                     {'Name', "ConditionDegradationMulIncrease", 'Tag', "<ConditionDegradationMulIncrease>", 'Default', 10})
        },
        RequiredParams = {"ConditionDegradationMulIncrease"},
        StatToModify = "ConditionDegradationMul",
        group = "Stats",
        id = "IncreaseConditionDegradationMul"
    })

    -------------------------------------------------------------------------

    if WeaponComponentEffects and WeaponComponentEffects.ExtraOverwatchShots then
        WeaponComponentEffects.ExtraOverwatchShots.unit_reactions = {
            PlaceObj('UnitReaction', {
                Event = "OnCalcOverwatchAttacks",
                Handler = function(self, target, value, action, args)
                    if not target then
                        return value
                    end
                    local wep = target:GetActiveWeapons()
                    if not wep then
                        return value
                    end
                    local bonus = WeaponComponentEffects.ExtraOverwatchShots:ResolveValue(
                                      "extra_attacks") or 1
                    if wep == self then
                        return value + bonus
                    end
                    return value
                end
            })
        }
    end
end

local t_table = {
    [183998509789] = 'Grants bonus Critical Chance per aim level',
    [954592406374] = 'Reduce AP necessary to swap to this weapon',
    [388838149410] = 'Reduced <em>recoil penalty</em>. Reduced <em>Hipfire</em> and <em>Snapshot</em> penalty',
    [149904848408] = 'Greatly increased <em>recoil penalty</em>',
    [498763703334] = 'Bullpup design, increases Point Blank range accuracy bonus and Shooting Angle',
    [187052039397] = 'Reduced <em>penalty</em> when using <em>Single Shot</em> to target body parts',
    [472185658894] = 'Significant increase in <em>recoil penalty</em>',
    [640458057266] = 'Targets attacked at point-blank range at night become <em>Obfuscated</em>',
    [375224625649] = 'Harder to hit closer targets',
    [226367424021] = 'Harder to hit closer targets',
    [938572490156] = 'Harder to hit closer targets',
    [975264803458] = 'Decreases Accuracy bonus from Aiming',
    [915008271800] = 'Decreased Hipfire penalty, increased Snapshot penalty, reduced Recoil penalty, decreased Point Blank range accuracy, harder to hit at melee range',
    [173836158177] = 'Increased Hipfire penalty, decreased Snapshot penalty, increased Recoil penalty, increased Point Blank range accuracy, easier to hit at melee range',
    [780091744194] = 'Has bonus damage against <em>Flanked</em> targets',
    [742720959709] = 'Recovers half <em>free move AP</em> after shooting',
    [282151114911] = '<em>Accuracy</em> penalty when not prone',
    [153429703325] = 'Minor <em>Accuracy</em> penalty',
    [629687776924] = 'Damaged reduced by <DamageReduced>',
    [624517971084] = 'Decreased <em>Recoil</em> penalty when using the <em>Burst Fire</em> attack mode',
    [486765316396] = 'Changes caliber to 7.62x54mmR',
    [953726500783] = 'Changes caliber to 7.62x39mm WP',
    [687659582586] = 'Decreases critical chance bonus that scales per merc level',
    [939111789534] = 'Decreases base critical chance',
    [398049834770] = 'Reduced <em>recoil penalty</em>',
    [954822518050] = 'Slightly reduced <em>recoil penalty</em>',
    [598891097935] = 'Reduced <em>recoil penalty</em>',
    [743623158693] = 'Reduced <em>recoil penalty</em>',
    [776447188724] = 'Slightly reduced <em>recoil penalty</em>',
    [940310929156] = 'Reduces <em>AP</em> necessary to get into <em>Shooting Stance</em>',
    [581740565531] = 'Increases <em>AP</em> necessary to get into <em>Shooting Stance</em>',
    [400216040089] = 'Decreases <em>Shooting Angle</em>',
    [601041780492] = 'Increases <em>Shooting Angle</em>',
    [558731788097] = 'Increased <em>recoil penalty</em>',
    [203713773863] = 'Reduced <em>recoil penalty</em>',
    [796931242458] = 'Significantly reduced penalty to <em>target body parts</em> with attacks with 4+ aim levels',
    [725526889720] = 'Grants bonus Critical Chance per aim level',
    [353562872144] = 'Grants bonus Accuracy to attacks with 3+ aim levels - bonus is based on <em>Weapon Aim Accuracy</em>',
    [213711882780] = 'Grants significant bonus Accuracy to attacks with 4+ aim levels - bonus is based on <em>Weapon Aim Accuracy</em>',
    [247212055308] = 'Grants bonus Accuracy to attacks with 2+ aim levels - bonus is based on <em>Weapon Aim Accuracy</em>',
    [872923011488] = 'Grants bonus Critical Chance to attacks with 2+ aim levels',
    [369880626294] = 'Grants bonus Critical Chance with aimed attacks',
    [905983597373] = 'Grants a small bonus Critical Chance per aim level',
    [617033974337] = 'Slightly reduced penalty to <em>target body parts</em> with attacks with 3+ aim levels',
    [337691694250] = 'Increase AP cost when attacking',
    [830130229420] = 'Enables - or improves - the <em>Run And Gun</em> attack action',
    [165863400633] = 'Significantly reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>',
    [889586830737] = 'Significantly reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>',
    [936610188234] = 'Reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>',
    [649325420444] = 'Increased <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>',
    [336485327528] = 'Reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>',
    [905040013361] = 'Reduced <em>Snapshot</em> accuracy <em>penalty</em>',
    [949818133594] = 'Light Barrel, reduced <em>Snapshot</em> accuracy <em>penalty</em>, increased <em>Recoil</em> penalty',
    [983043466921] = 'Heavy Barrel, reduced <em>Recoil</em> penalty, increased <em>Snapshot</em> accuracy <em>penalty</em>',
    [498214252783] = 'Increased cost to rotate weapon when prone',
    [879653741676] = 'Enables <em>Burst Fire</em> attack mode, except on interrupt attacks',
    [958768643867] = 'Decreased accuracy in <em>Full Auto</em> and <em>Burst Fire</em> attacks',
    [849532998072] = 'Decreases number of attacks when using the <em>Run and Gun</em> action',
    [159267356053] = 'Reduced <em>Hipfire</em> and <em>Snapshot</em> accuracy <em>penalty</em>',
    [376073238620] = 'Enables free-swap',
    [873379225473] = 'The <em>total</em> Accuracy bonus from aiming is reduced by 10%',
    [183183480025] = 'Increased <em>Snapshot</em> accuracy <em>penalty</em>',
    [266874774409] = 'Decreases Aim accuracy when prone',
    [982346640578] = 'Slightly reduced <em>recoil penalty</em>',
    [845256852079] = 'Reduced <em>Hipfire and Snapshot penalty</em>',
    [952508575329] = 'Slightly increased Point-Blank range accuracy bonus',
    [685331648680] = 'Increases max aim level by <MaxAimActionsIncrease>',
    [832057249458] = 'Increases aim accuracy in <em>close range</em> by <Close_bonus>%',
    [244679400091] = 'Reduces <em>Snapshot Penalty</em> by <snap_reduc>%',
    [299071168122] = 'Increases Accuracy for Interrupt attacks by <bonus_cth_interrupt>%',
    [355372332150] = 'Increases Accuracy for aimed attacks by <bonus_cth>%',
    [210060101900] = 'Increases Accuracy for aimed attacks by <bonus_cth_v>%',
    [175082911037] = 'Increases Accuracy for aimed attacks - bonus is based on <em>Weapon Aim Accuracy</em>',
    [978415485249] = 'Grants bonus Critical Chance for aimed attacks at the head',
    [320356428271] = 'Grants bonus Critical Chance for aimed attacks at the torso',
    [695581761922] = 'After firing, needs to be manually cycled using <ap_manual> AP\nHigh <em>Dexterity</em> can reduce this cost',
    [646661766533] = 'After firing, increases attack AP cost by <ap_double_action>\nCan be manually cycled using <ap_manual> AP\nHigh <em>Dexterity</em> can reduce this cost',
    [212821718310] = 'Increase Stance AP cost by <StanceIncreaseSTR>, can be negated with <STR_threshold> Strength',
    [547256645082] = 'Increases Accuracy and reduces Recoil when Prone',
    [897995963554] = 'Increases Point Blank Range accuracy bonus by 1',
    [236633317127] = 'Decreases weapon length, affecting Recoil, Snapshot, Hipfire accuracy penalties and Point Blank Range accuracy modifiers',
    [219179226706] = 'Increases weapon length, affecting Recoil, Snapshot, Hipfire accuracy penalties and Point Blank Range accuracy modifiers',
    [864532654693] = "Changes caliber to 5.56x45mm",
    [195877439875] = "Increases <em>Recoil</em> penalty",
    [674215963791] = "Changes pellet spread pattern, reducing vertical spread",
    [156932878971] = "Decreases Point-Blank range accuracy bonus",
    [912316475877] = "Increases Point-Blank range accuracy bonus",
	[645613895578] = "Increases weapon condition degradation"
}

ratG_T_table['COMPONENT_weaponcomp_effects.lua'] = t_table


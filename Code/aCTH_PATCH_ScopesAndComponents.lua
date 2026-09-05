--------------------------------------------------------------------------------------------------
---- Override de opticas SO enquanto o aperture esta ligado (A.Enabled). Mexe apenas nas chaves
---- listadas por perfil; o resto do componente (custo, visuais, outros efeitos) fica intacto.
----
---- O "pristino" e HARDCODADO em RAT_SCOPE_ORIGINALS abaixo -- NAO lido do preset em runtime.
---- Motivo: WeaponComponents nao e gerado por PlaceObj de preset toda hora; e a mesma tabela viva.
---- Se o apply mutasse e o editor salvasse o mod, os valores do aperture vazariam pro items.lua.
---- Com a fonte hardcodada, apply e restore sao deterministicos e o items.lua nunca e a verdade.
----
---- Restaura: Rat_RestoreApertureItemParams(). Reaplica em armas em campo: Rat_ReapplyApertureComponents().
--------------------------------------------------------------------------------------------------
local A = const.Combat.Aperture

--- Refactored Scopes
---- Limiar de mira por ampliacao. Regra: quanto MAIOR a ampliacao, mais TARDE o bonus comeca e
---- maior ele e. E o que faz a luneta grande ser um compromisso e nao um upgrade direto.
A.ComponentEffectsAimBonus = {
    --{
    --    id = "pso_dragunov_scope",
    --    from = 5,
    --    acc = 3
    --}, {
    --    id = "sniper_aim_scope",
    --    from = 5,
    --    acc = 5
    --}, {
    --    id = "sniper_adv_aim_scope",
    --    from = 6,
    --    acc = 5
    --},
    -- {id = "_x2ScopeAimBonus", from = 4, acc = 3},
    --{
    --    id = "FirstAimBonusModifier",
    --    from = 1,
    --    to = 1,
    --    acc = 3
    --}, 
	--{
    --    id = "BonusAccuracyWhenFullyAimed", -- HeavyStock
    --    from = 3,
    --    to = 3,
    --    acc = 2
    --} 
}

---- A CEREJA da optica: multiplicador do PISO do cone por ampliacao (Rat_ApertureFloor). E a unica
---- coisa que move a ASSINTOTA, e a assintota e todo o cone que sobra com mira cheia. Nao mexe em
---- WeaponRange, entao alcance maximo, custo de AP, checagem de fora de alcance e IA ficam iguais:
---- e "alcance so com mira cheia". Invisivel no aim 0-1 (la o cone e ~10x o piso). MENOR = melhor.
----
---- E aqui que as ampliacoes se separam, NAO no limiar de mira: o piso nao tem teto, enquanto o
---- bonus de AimAccuracy satura em A.DecayMinPct e faz 4x e 6x colapsarem no mesmo numero.
---- Reativado 2026-09-03: com tudo em 100 a assintota era a mesma para toda optica e a unica
---- separacao que sobrava era o numero de niveis de mira. Medido no processo vivo (M24 @40 tiles,
---- mira cheia): 6x 70 -> 81, 4x 62 -> 64. So morde de verdade na ampliacao alta com alcance
---- longo, que e exatamente onde a ampliacao deve pagar.
A.ScopeFloorMul = {
    _6x = 74,
    _4x = 84,
    _2x = 94,
    _2xQuick = 94,
    _1dot5x = 98,
    Reflex = 100,
    Ironsight = 100
}

---- Miras: o `bonus_cth` autorado no componente vira multiplicador de cone, aplicado uma vez com
---- aim >= 1 ou required aim. Cada entrada daqui e um componente independente -- 
---- Nao muda a assintota, ganho de velocidade de convergencia
A.ConeMulBonus = true
A.ConeMulEffects = {
    {
        id = "AccuracyBonusWhenAimed", -- Sights
        param = "bonus_cth"
    }, {
		id = "BonusAccuracyWhenFullyAimed", -- Heavy Stock
		param = "bonus_cth",
		required_aim = 3
	},
	{
		id = "AccuracyBonusWhenAimed_vgrip", -- Vgrip
		param = "bonus_cth_v",
	}
}

---- Perfis por ampliacao. Parameters = {NomeDoParam = valor_inteiro} (param % usa o inteiro cru,
---- 150 = 150%). ModificationEffects = {EffectId = true garante presente | false garante ausente}.
---- Efeito de "niveis de mira" = IncreaseMaxAimActions (param MaxAimActionsIncrease); "range" da
---- optica = IncreaseRange (param RangeIncrease).
A.ApertureMagnifications = {
    ---- AMPLIACAO E COMPROMISSO, nao upgrade. Cada degrau paga adiantado e cobra depois:
    ----   niveis de mira a mais + piso mais baixo   (so rende com mira alta e longe)
    ----   ScopePenalty maior                        (pior de perto, em qualquer nivel)
    ----   limiar de mira comecando mais tarde       (pior no aim 3, melhor do 4 em diante)
    _6x = {
        Parameters = {
            MaxAimActionsIncrease = 3,
            snap_mul_inc = 160, -- 140
            aim_level_threshold = 6,
            threshold_bonus_acc = 5
        },
        ModificationEffects = {
            ScopeAimThresholdBonus = true,
            IncreaseMaxAimActions = true,
            IncreaseSnapshotMul = true,
            ScopePenalty3 = true,
            ScopePenalty2 = false,
            ScopePenalty1 = false,
            IncreaseRange = true,
            IncreaseAimAccuracy = false,
            StanceAPincrease = false,
            sniper_adv_aim_scope = false
        }
    },
    _4x = {
        Parameters = {
            MaxAimActionsIncrease = 2,
            snap_mul_inc = 140, -- 125
            aim_level_threshold = 5,
            threshold_bonus_acc = 5
        },
        ModificationEffects = {
            ScopeAimThresholdBonus = true,
            IncreaseMaxAimActions = true,
            IncreaseSnapshotMul = true,
            ScopePenalty2 = true,
            ScopePenalty1 = false,
            ScopePenalty3 = false,
            IncreaseRange = true,
            IncreaseAimAccuracy = false,
            StanceAPincrease = false,
            sniper_aim_scope = false,
            pso_dragunov_scope = false
        }
    },
    _2x = {
        Parameters = {
            MaxAimActionsIncrease = 1,
            snap_mul_inc = 125, -- 110 
            aim_level_threshold = 4,
            threshold_bonus_acc = 3
        },
        ModificationEffects = {
            ScopeAimThresholdBonus = true,
            BonusAccuracyWhenFullyAimed = false,
            IncreaseMaxAimActions = true,
            IncreaseSnapshotMul = true,
            ScopePenalty1 = true,
            ScopePenalty2 = false,
            ScopePenalty3 = false,
            IncreaseRange = true,
            IncreaseAimAccuracy = false
        }
    },
    ---- 2x de aquisicao rapida (ACOG/WideScope): trocam o piso e a mira alta pelo snapshot. O
    ---- `snap_reduc` positivo autorado no componente e mantido -- o perfil nao o sobrescreve.
    _2xQuick = {
        Parameters = {
            MaxAimActionsIncrease = 1,
            aim_level_threshold = 4,
            threshold_bonus_acc = 2,
			first_aim_bonus = 3
        },
        ModificationEffects = {
            IncreaseMaxAimActions = true,
            scope_snapshot = false,
            ScopePenalty1 = true,
            ScopePenalty2 = false,
            ScopePenalty3 = false,
            IncreaseRange = true,
            IncreaseAimAccuracy = false,
            FirstAimBonusModifier = true
        }
    },
    _2xWide = {
        Parameters = {
            MaxAimActionsIncrease = 1,
			snap_mul_reduc = 95,
			first_aim_bonus = 2
        },
        ModificationEffects = {
            IncreaseMaxAimActions = true,
            scope_snapshot = false,
			DecreaseSnapshotMul = true,
            ScopePenalty1 = true,
            ScopePenalty2 = false,
            ScopePenalty3 = false,
            IncreaseRange = true,
            IncreaseAimAccuracy = false,
            FirstAimBonusModifier = true
        }
    },
    _1dot5x = {
        Parameters = {
            MaxAimActionsIncrease = 1
        },
        ModificationEffects = {
            IncreaseMaxAimActions = true,
            IncreaseRange = true,
            IncreaseAimAccuracy = false,
            ScopePenalty1 = false,
            ScopePenalty2 = false,
            ScopePenalty3 = false
        }
    },
    ---- bonus_cth 10 -> 12: a reflex e a opcao BARATA (sem nivel de mira extra, sem AP de entrada),
    ---- entao precisa ser a melhor no aim 1-3 ou a 2x rapida a domina sem custar nada a mais.
    Reflex = {
        Parameters = {bonus_cth = 12,
		snap_mul_reduc = 85
			},
        ModificationEffects = {
            AccuracyBonusWhenAimed = true,
            reflex_sight_close_range = false,
			scope_snapshot = false,-- old hardcoded effect
			DecreaseSnapshotMul = true
        }
    },
    ReflexAdvanced = {
        Parameters = {bonus_cth = 10, 
			snap_mul_reduc = 90},
        ModificationEffects = {
            AccuracyBonusWhenAimed = true,
            reflex_sight_close_range = false,
			scope_snapshot = false, 
			DecreaseSnapshotMul = true
        }
    },
    ReflexVigilance = {
        Parameters = {bonus_cth = 5,
			snap_mul_reduc = 85},
        ModificationEffects = {
            AccuracyBonusWhenAimed = true,
            reflex_sight_close_range = false,
			scope_snapshot = false,
			DecreaseSnapshotMul = true
			
        }
    },
    Ironsight = {
        Parameters = {bonus_cth = 3},
        ModificationEffects = {
            AccuracyBonusWhenAimed = true
        }
    }
    -- Laser = {
    --	
    -- }
    -- VerticalGrip = { -- no op
    --	Parameters = {bonus_cth = 3},
    --	ModificationEffects = {AccuracyBonusWhenAimed = true},
    -- }
}

---- Componente -> perfil. Componente ausente daqui nao e tocado. Chute inicial de tiers:
A.ApertureComponentTier = {
    ReflexSight = "Reflex",
    ReflexSightAdvanced = "ReflexAdvanced",
    ReflexSightAdvanced_Glock = "ReflexAdvanced",
    _ReflexSIghtVigilance = "ReflexVigilance",
    ImprovedIronsight = "Ironsight",
    ImprovedIronsight_AR15 = "Ironsight", -- AR15
    G36_SCOPE = "_2x",
    SCOPE_G36_2 = "_2x",
    AUGScope_Default = "_1dot5x",
    ScopeCOG = "_2x",
    ---- ACOG e WideScope sao as 2x de aquisicao rapida: ja autoram scope_snapshot POSITIVO
    WideScope = "_2xWide",
    ScopeCOGQuick = "_2xQuick",
    LROptics = "_4x",
    LROptics_DragunovDefault = "_4x",
    ThermalScope = "_4x",
    LROpticsAdvanced = "_6x",
    PSG_DefaultScope = "_6x",

    -----
    -- VerticalGrip = "VerticalGrip",
    -- VerticalGrip_aug = "VerticalGrip",
    -- AK47_VerticalGrip = "VerticalGrip",
    -- VerticalGrip_M14 = "VerticalGrip",
    -- VerticalGrip_M16 = "VerticalGrip",
    -- VerticalGrip_Commando = "VerticalGrip",
    -- AKSU_VerticalGrip = "VerticalGrip",
    -- RPK74_VerticalGrip  = "VerticalGrip",

    ---- Opticas de ToG que ficavam de fora e continuavam dando IncreaseRange. So entram as que
    ---- servem arma PATCHED (is_tog_patched) ou vanilla -- auditado no processo vivo por slot
    ---- "Scope". Os `_Master_*` sao os templates de onde as variantes herdam: os dois precisam entrar.
    SSG69_Scope_1 = "_6x", -- SSG69_1
    _Master_SSG69_Scope_TOG = "_6x",
    VSS_Scope_1 = "_4x", -- VSS_1
    ["_Master_PSO-1M2_Scope_TOG"] = "_4x",
    SteyrS_Scope_1 = "_4x", -- SteyrScout_1
    _Master_SteyrS_Scope_TOG = "_4x",
    m76_scope_1 = "_4x", -- M76_1
    _Master_m76_scope_TOG = "_4x",
    GW43_Scope_1 = "_2x", -- STG44R_1, Gewehr43_1
    _Master_GW43_Scope_TOG = "_2x",
    G11_Scope_1 = "_1dot5x", -- G11_1
    _Master_G11_Scope_1 = "_1dot5x",
    TAR21_Scope_Rflx_1 = "Reflex" -- TAR21_1

    ---- FORA de proposito -- so servem arma ToG NAO patched, fora do escopo de balance do mod:
    ---- AWP_Scope_1, WA2000_Scope_1, NTW_20_Scope_1, Caws_Scope_1, FN2000_Scope_1,
    ---- G11_Rail_7, G11_Rail_9. E sem arma nenhuma: AN94_Scope_1, ThermalScope_1, ThermalScope_2.
}

---------------------------------------------------------------------------------------------------
---- PRISTINO HARDCODADO -- transcrito do items.lua (folder "Scopes"). effects em ordem de autoria,
---- params por nome. So o que o restore/apply precisa; visuais, custo e tags ficam no preset.
---------------------------------------------------------------------------------------------------
RAT_SCOPE_ORIGINALS = {
    -- VerticalGrip = {
    --	effects = { "AccuracyBonusWhenAimed_vgrip", "Vert_grip_recoi",  "grip_prone_penalty"},
    --	params = { bonus_cth_v = 3 },
    -- },
    PSG_DefaultScope = {
        effects = {
            "IncreaseMaxAimActions",
            "IncreaseRange",
            "ScopePenalty3",
            "DecreaseOverwatchAngle",
            "bodypart_scope"
        },
        params = {
            MaxAimActionsIncrease = 1,
            RangeIncrease = 16,
            crit = 15,
            OverwatchAngleDecrease = 50,
            APincrease = 1
        }
    },
    ThermalScope = {
        effects = {
            "IgnoreInTheDarkWhenFullyAimed",
            "IgnoreCoverCtHWhenFullyAimed",
            "IgnoreLightOfSightWhenFullyAimed",
            "IgnoreGrazingHitsWhenFullyAimed",
            "IncreaseRange",
            "ScopePenalty2",
            "DecreaseOverwatchAngle"
        },
        params = {
            RangeIncrease = 10,
            OverwatchAngleDecrease = 50,
            APincrease = 1
        }
    },
    SCOPE_G36_2 = {
        effects = {
            "CritBonusWhenFullyAimed",
            "ScopePenalty1",
            "IncreaseRange",
            "IgnoreInTheDarkWhenFullyAimed",
            "DecreaseOverwatchAngle",
            "IncreaseAimAccuracy"
        },
        params = {
            RangeIncrease = 10,
            AimAccuracyIncrease = 2,
            crit = 15,
            OverwatchAngleDecrease = 75
        }
    },
    G36_SCOPE = {
        effects = {
            "CritBonusWhenFullyAimed",
            "ScopePenalty1",
            "IncreaseRange",
            "IgnoreInTheDarkWhenFullyAimed",
            "DecreaseOverwatchAngle",
            "IncreaseAimAccuracy"
        },
        params = {
            crit = 15,
            AimAccuracyIncrease = 2,
            RangeIncrease = 6,
            OverwatchAngleDecrease = 75
        }
    },
    AUGScope_Default = {
        effects = {
            "IncreaseAimAccuracy",
            "IncreaseRange",
            "DecreaseOverwatchAngle"
        },
        params = {
            AimAccuracyIncrease = 3,
            RangeIncrease = 4,
            OverwatchAngleDecrease = 90
        }
    },
    _ReflexSIghtVigilance = {
        effects = {
            "OpportunityAttackBonusCth",
            "IncreaseOverwatchAngle",
            "scope_snapshot",
            "reflex_sight_close_range",
            "AccuracyBonusWhenAimed"
        },
        params = {
            bonus_cth = 3,
            bonus_cth_interrupt = 10,
            OverwatchAngleIncrease = 125,
            Close_bonus = 5,
            snap_reduc = 10,
            RangeIncrease = 4
        }
    },
    ReflexSightAdvanced_Glock = {
        effects = {
            "first_aim_crit",
            "IncreaseOverwatchAngle",
            "scope_snapshot",
            "reflex_sight_close_range",
            "AccuracyBonusWhenAimed"
        },
        params = {
            RangeIncrease = 2,
            OverwatchAngleIncrease = 115,
            Close_bonus = 5,
            bonus_cth = 3,
            snap_reduc = 10
        }
    },
    ReflexSightAdvanced = {
        effects = {
            "IncreaseOverwatchAngle",
            "first_aim_crit",
            "scope_snapshot",
            "reflex_sight_close_range",
            "AccuracyBonusWhenAimed"
        },
        params = {
            RangeIncrease = 4,
            bonus_cth = 3,
            OverwatchAngleIncrease = 125,
            Close_bonus = 5,
            snap_reduc = 10
        }
    },
    ReflexSight = {
        effects = {
            "AccuracyBonusWhenAimed",
            "IncreaseOverwatchAngle",
            "reflex_sight_close_range",
            "scope_snapshot"
        },
        params = {
            RangeIncrease = 2,
            OverwatchAngleIncrease = 115,
            Close_bonus = 10,
            bonus_cth = 3,
            snap_reduc = 10
        }
    },
    ScopeCOG = {
        effects = {
            "IncreaseRange",
            "ScopePenalty1",
            "DecreaseOverwatchAngle",
            "critical_per_aim_scope",
            "IncreaseAimAccuracy"
        },
        params = {
            RangeIncrease = 6,
            OverwatchAngleDecrease = 90,
            AimAccuracyIncrease = 2
        }
    },
    ScopeCOGQuick = {
        effects = {
            "FirstAimBonusModifier",
            "IncreaseRange",
            "ScopePenalty1",
            "IncreaseAimAccuracy",
            "scope_snapshot",
            "IncreaseOverwatchAngle"
        },
        params = {
            RangeIncrease = 6,
            AimAccuracyIncrease = 2,
            snap_reduc = 5,
            OverwatchAngleIncrease = 110,
			first_aim_bonus_acc = 3
        }
    },
    WideScope = {
        effects = {
            "OpportunityAttackBonusCth",
            "IncreaseRange",
            "ScopePenalty1",
            "IncreaseAimAccuracy",
            "scope_snapshot"
        },
        params = {
            bonus_cth_interrupt = 8,
            AimAccuracyIncrease = 2,
            RangeIncrease = 6,
            snap_reduc = 5
        }
    },
    LROptics_DragunovDefault = {
        effects = {
            "IncreaseRange",
            "pso_dragunov_scope_critical",
            "ScopePenalty2",
            "DecreaseOverwatchAngle",
            "pso_dragunov_scope",
            "IncreaseMaxAimActions"
        },
        params = {
            crit_bonus = 15,
            MaxAimActionsIncrease = 1,
            RangeIncrease = 10,
            OverwatchAngleDecrease = 68,
            APincrease = 1
        }
    },
    LROptics = {
        effects = {
            "IncreaseMaxAimActions",
            "IncreaseRange",
            "ScopePenalty2",
            "DecreaseOverwatchAngle",
            "sniper_aim_scope"
        },
        params = {
            MaxAimActionsIncrease = 1,
            RangeIncrease = 10,
            OverwatchAngleDecrease = 65,
            APincrease = 1
        }
    },
    LROpticsAdvanced = {
        effects = {
            "IncreaseMaxAimActions",
            "IncreaseRange",
            "ScopePenalty3",
            "DecreaseOverwatchAngle",
            "sniper_adv_aim_scope"
        },
        params = {
            MaxAimActionsIncrease = 2,
            RangeIncrease = 16,
            OverwatchAngleDecrease = 50,
            APincrease = 1
        }
    },
    ImprovedIronsight = {
        effects = {
            "AccuracyBonusWhenAimed"
        },
        params = {bonus_cth = 3}
    },

    ---- Opticas de ToG / armas modadas. Lidas do processo vivo ANTES de qualquer override
    ---- (nao estavam em ApertureComponentTier, entao o que estava em memoria era o pristino).
    SSG69_Scope_1 = {
        effects = {
            "IncreaseRange",
            "IncreaseMaxAimActions",
            "CritBonusWhenFullyAimed",
            "ScopePenalty3",
            "DecreaseOverwatchAngle"
        },
        params = {
            RangeIncrease = 16,
            MaxAimActionsIncrease = 1,
            crit = 20,
            OverwatchAngleDecrease = 60
        }
    },
    _Master_SSG69_Scope_TOG = {
        effects = {
            "IncreaseRange",
            "IncreaseMaxAimActions",
            "CritBonusWhenFullyAimed",
            "ScopePenalty3",
            "DecreaseOverwatchAngle"
        },
        params = {
            RangeIncrease = 16,
            MaxAimActionsIncrease = 1,
            crit = 20,
            OverwatchAngleDecrease = 60
        }
    },
    VSS_Scope_1 = {
        effects = {
            "pso_dragunov_scope",
            "IncreaseRange",
            "ScopePenalty2",
            "DecreaseOverwatchAngle",
            "StealthKillBonusPerAim",
            "IncreaseMaxAimActions"
        },
        params = {
            RangeIncrease = 10,
            OverwatchAngleDecrease = 60,
            APincrease = 1,
            stealth_kill_bonus = 6,
            MaxAimActionsIncrease = 1
        }
    },
    ["_Master_PSO-1M2_Scope_TOG"] = {
        effects = {
            "pso_dragunov_scope",
            "IncreaseRange",
            "ScopePenalty2",
            "DecreaseOverwatchAngle",
            "StealthKillBonusPerAim",
            "IncreaseMaxAimActions"
        },
        params = {
            RangeIncrease = 10,
            OverwatchAngleDecrease = 60,
            APincrease = 1,
            stealth_kill_bonus = 6,
            MaxAimActionsIncrease = 1
        }
    },
    SteyrS_Scope_1 = {
        effects = {
            "pso_dragunov_scope",
            "IncreaseMaxAimActions",
            "ScopePenalty2",
            "scout_scope_crit",
            "IncreaseRange",
            "DecreaseOverwatchAngle"
        },
        params = {
            RangeIncrease = 10,
            OverwatchAngleDecrease = 60,
            APincrease = 1,
            MaxAimActionsIncrease = 1,
            critical_head = 15
        }
    },
    _Master_SteyrS_Scope_TOG = {
        effects = {
            "pso_dragunov_scope",
            "IncreaseMaxAimActions",
            "ScopePenalty2",
            "scout_scope_crit",
            "IncreaseRange",
            "DecreaseOverwatchAngle"
        },
        params = {
            RangeIncrease = 10,
            OverwatchAngleDecrease = 60,
            APincrease = 1,
            MaxAimActionsIncrease = 1,
            critical_head = 15
        }
    },
    m76_scope_1 = {
        effects = {
            "IncreaseMaxAimActions",
            "IncreaseRange",
            "DecreaseOverwatchAngle",
            "ScopePenalty2",
            "pso_dragunov_scope",
            "zrak_scope_crit"
        },
        params = {
            MaxAimActionsIncrease = 1,
            RangeIncrease = 10,
            OverwatchAngleDecrease = 68,
            crit_torso = 12
        }
    },
    _Master_m76_scope_TOG = {
        effects = {
            "IncreaseMaxAimActions",
            "IncreaseRange",
            "DecreaseOverwatchAngle",
            "ScopePenalty2",
            "pso_dragunov_scope",
            "zrak_scope_crit"
        },
        params = {
            MaxAimActionsIncrease = 1,
            RangeIncrease = 10,
            OverwatchAngleDecrease = 68,
            crit_torso = 12
        }
    },
    G11_Scope_1 = {
        effects = {
            "IncreaseRange",
            "AccuracyBonusWhenAimed"
        },
        params = {
            RangeIncrease = 4,
            bonus_cth = 10
        }
    },
    _Master_G11_Scope_1 = {
        effects = {
            "IncreaseRange",
            "AccuracyBonusWhenAimed"
        },
        params = {
            RangeIncrease = 4,
            bonus_cth = 10
        }
    },
    GW43_Scope_1 = {
        effects = {
            "AccuracyBonusWhenAimed",
            "DecreaseOverwatchAngle",
            "IncreaseRange"
        },
        params = {
            RangeIncrease = 4,
            bonus_cth = 15,
            OverwatchAngleDecrease = 85
        },
        pct = {bonus_cth = true}
    },
    _Master_GW43_Scope_TOG = {
        effects = {
            "AccuracyBonusWhenAimed",
            "DecreaseOverwatchAngle",
            "IncreaseRange"
        },
        params = {
            RangeIncrease = 4,
            bonus_cth = 15,
            OverwatchAngleDecrease = 85
        },
        pct = {bonus_cth = true}
    },
    TAR21_Scope_Rflx_1 = {
        effects = {
            "IncreaseOverwatchAngle",
            "hipfire_dot_effect_laser",
            "IncreaseCritChangeScaled",
            "critical_per_aim_laser",
            "reflex_sight_close_range",
            "AccuracyBonusWhenAimed"
        },
        params = {
            bonus_cth = 10,
            OverwatchAngleIncrease = 130,
            Close_bonus = 5,
            snap_reduc = 15,
            CritChangeScaledIncrease = 10
        }
    },
    ImprovedIronsight_AR15 = {
        effects = {
            "AccuracyBonusWhenAimed"
        },
        params = {bonus_cth = 5},
        pct = {bonus_cth = true}
    }
}

---------------------------------------------------------------------------------------------------
---- ALCANCE DAS ARMAS no aCTH. Opticas nao dao mais WeaponRange, entao o alcance volta a ser
---- propriedade da ARMA -- e e a assintota do cone (d50 maximo = 1.545 x WeaponRange). Esticado no
---- topo da escala: +55% do que passa de 20 tiles em snipers (teto 44), +35% MG, +30% fuzil,
---- +15% SMG, 0 em pistola/revolver/escopeta. {pristino, valor_no_aCTH}.
---- SO vale com o aperture ligado; Rat_RestoreApertureItemParams devolve o pristino.
---------------------------------------------------------------------------------------------------
RAT_APERTURE_WEAPON_RANGE = {
    ---- Snipers / marksman
    BarretM82 = {40, 44},
    PSG1 = {34, 42},
    M24Sniper = {32, 40},
    SSG69_1 = {32, 40},
    DragunovSVD = {30, 36},
    Gewehr98 = {30, 36},
    GoldenGun = {30, 36},
    M76_1 = {30, 36},
    Gewehr43_1 = {28, 32},
    Mosin_1 = {28, 32},
    SteyrScout_1 = {28, 32},
    Winchester1894 = {26, 28},
    Winchester_Quest = {26, 28},
    VSS_1 = {24, 26},
    Delisle_1 = {22, 24},
    VSK94_1 = {22, 24},
    ---- Metralhadoras
    MG58 = {32, 36},
    PKM_1 = {32, 36},
    BrowningM2HMG = {30, 34},
    HK21 = {30, 34},
    MG42 = {30, 34},
    FNMinimi = {28, 32},
    HK23ECamo_1 = {28, 32},
    HK23E_1 = {28, 32},
    RPD_1 = {28, 32},
    RPK74 = {28, 32},
    ---- Fuzis de assalto
    AR10std = {30, 34},
    FNFAL = {30, 36},
    G3A3Green_1 = {30, 34},
    G3A3_1 = {30, 34},
    Galil_FlagHill = {30, 30},
    M14SAW = {30, 32},
    M14SAW_AUTO = {30, 32},
    AK74 = {28, 30},
    AN94_1 = {28, 30},
    AR15 = {28, 30},
    G36 = {28, 30},
    HK33A2_1 = {28, 30},
    M16A2 = {28, 30},
    M1Garand_2 = {28, 30},
    A91_2 = {26, 28},
    AK47 = {26, 28},
    AUG = {26, 28},
    FAMAS = {26, 28},
    Galil = {26, 28},
    M70_1 = {26, 28},
    Papovka2SKS_1 = {26, 28},
    PapovkaSKS_1 = {26, 28},
    RK62_1 = {26, 28},
    RK95_1 = {26, 28},
    SKS_1 = {26, 28},
    STG44R_1 = {26, 28},
    TAR21_1 = {26, 28},
    Type56A_1 = {26, 28},
    Type56B_1 = {26, 28},
    Type56C_1 = {26, 28},
    Type56D_1 = {26, 28},
    G11_1 = {24, 26},
    Groza_1 = {22, 24},
    ---- Submetralhadoras (so as de cano longo mudam)
    HK53_1 = {28, 30},
    AKSU = {24, 26},
    M4Commando = {24, 26},

    --
    M41Shotgun = {22, 26},
    Auto5 = {20, 24},
    AA12 = {20, 24},
    DoubleBarrelShotgun = {18, 22},
    Auto5_quest = {18, 22}
}

---- params autorados como PresetParamPercent no items.lua (so muda o tipo do PlaceObj / a tag).
---- `bonus_cth` nao entra aqui: e percent em GW43/ImprovedIronsight_AR15 e number no resto, entao
---- esses tres declaram `pct` proprio na entrada de RAT_SCOPE_ORIGINALS.
local RAT_PCT = {
    crit = true,
    crit_bonus = true,
    bonus_cth_interrupt = true,
    stealth_kill_bonus = true
}

---- reescreve ModificationEffects/Parameters do preset e refaz o cache de params (g_PresetParamCache
---- e o que ResolveValue le; PostLoad o reconstroi).
local function aperture_write(comp,
                              effects,
                              params_map,
                              pct_map)
    comp.ModificationEffects = effects

    local list = {}
    for name, value in
        sorted_pairs(params_map) do
        local is_pct =
            (pct_map and pct_map[name]) or
                RAT_PCT[name]
        local cls = is_pct and
                        'PresetParamPercent' or
                        'PresetParamNumber'
        local tag = is_pct and
                        ("<" .. name ..
                            ">%") or
                        ("<" .. name ..
                            ">")
        list[#list + 1] =
            PlaceObj(cls, {
                'Name', name, 'Value',
                value, 'Tag', tag
            })
    end
    comp.Parameters = list

    g_PresetParamCache[comp] = nil
    comp:PostLoad()
end

---- Escreve um id a partir do pristino hardcodado + overrides (nil = so o pristino).
local function apply_one(id, tier)
    local orig = RAT_SCOPE_ORIGINALS[id]
    local comp = WeaponComponents[id]
    if not orig then
        print(
            "GBO aperture: sem pristino hardcodado para",
            id)
        return
    end
    if not comp then
        print(
            "GBO aperture: componente inexistente",
            id)
        return
    end

    local eff_override = tier and
                             tier.ModificationEffects or
                             empty_table
    local par_override = tier and
                             tier.Parameters or
                             empty_table

    ---- efeitos: pristino, tira os marcados false, poe os marcados true que faltam (mantem ordem)
    local effects, seen = {}, {}
    for _, e in ipairs(orig.effects) do
        if eff_override[e] ~= false then
            effects[#effects + 1] = e
            seen[e] = true
        end
    end
    for e, want in pairs(eff_override) do
        if want and not seen[e] then
            effects[#effects + 1] = e
        end
    end

    ---- params: pristino + overrides do perfil
    local params = {}
    for name, value in
        pairs(orig.params) do
        params[name] = value
    end
    for name, value in pairs(
                           par_override) do
        params[name] = value
    end

    aperture_write(comp, effects,
                   params, orig.pct)
end

---- WeaponRange da classe. `idx` 1 = pristino, 2 = valor do aCTH. So escreve se o valor atual for
---- um dos dois: se PATCH_GBO_weapons mudar o pristino, avisa em vez de gravar por cima calado.
---- `base_WeaponRange` (Modifiers.lua) e quem a instancia le de fato -- mexer so em WeaponRange
---- muda a classe e nao muda arma nenhuma.
local function apply_range(idx)
    for id, pair in pairs(
                        RAT_APERTURE_WEAPON_RANGE) do
        local cls = g_Classes[id]
        if cls then
            local cur =
                rawget(cls,
                       "base_WeaponRange") or
                    cls.WeaponRange
            if cur ~= pair[1] and cur ~=
                pair[2] then
                print(
                    "GBO aperture: WeaponRange inesperado em",
                    id, cur,
                    "-- esperava",
                    pair[1], "ou",
                    pair[2])
            else
                cls.WeaponRange =
                    pair[idx]
                if rawget(cls,
                          "base_WeaponRange") ~=
                    nil then
                    cls.base_WeaponRange =
                        pair[idx]
                end
            end
        end
    end
end

---- Volta TODA optica conhecida (e o alcance) ao pristino hardcodado (ignora tiers).
function Rat_RestoreApertureItemParams()
    for id in pairs(RAT_SCOPE_ORIGINALS) do
        apply_one(id, nil)
    end
    apply_range(1)
end

function ApplyApertureItemParams()
    local ap = const.Combat.Aperture -- sempre a tabela viva (recriada a cada reload de __ApertureParams)
    if not ap or not ap.Enabled then
        return
            Rat_RestoreApertureItemParams()
    end
    for id, tier_name in pairs(
                             ap.ApertureComponentTier or
                                 empty_table) do
        apply_one(id,
                  (ap.ApertureMagnifications or
                      empty_table)[tier_name])
    end
    apply_range(2)
end

---- Ancora de load: garante que o override roda depois deste arquivo (e do __ApertureParams) carregar.
---- __ApertureParams tambem chama via GBO_ApplyApertureCTHMode, mas so se ApplyModOptions/DataLoaded disparar.
function OnMsg.ModsReloaded()
    ApplyApertureItemParams()
    if g_Units and #g_Units > 0 then
        Rat_ReapplyApertureComponents()
    end
end

---- Empurra o override para as armas ja equipadas em campo, sem esperar UnitCreated. Reaplica TODO
---- componente, nao so as opticas conhecidas: o valor da instancia foi calculado sobre a base
---- ANTIGA da classe, entao trocar WeaponRange exige recomputar tambem cano longo, bipe, etc.
function Rat_ReapplyApertureComponents()
    local n = 0
    for _, u in ipairs(
                    g_Units or
                        empty_table) do
        if IsValid(u) then
            for _, wslot in ipairs({
                "Handheld A",
                "Handheld B"
            }) do
                for _, w in ipairs(
                                u:GetEquippedWeapons(
                                    wslot) or
                                    empty_table) do
                    ---- a instancia guarda o WeaponRange resolvido no momento em que foi criada;
                    ---- trocar a base da classe nao chega ate ela sozinho.
                    if IsKindOf(w,
                                "Firearm") and
                        RAT_APERTURE_WEAPON_RANGE[w.class] then
                        local base =
                            rawget(
                                g_Classes[w.class],
                                "base_WeaponRange")
                        if rawget(w,
                                  "base_WeaponRange") ~=
                            nil and base then
                            w:SetBase(
                                "WeaponRange",
                                base)
                        else
                            w:RestoreModifiableValue(
                                "WeaponRange")
                        end
                    end
                    if IsKindOf(w,
                                "Firearm") and
                        w.components then
                        for cslot, cid in
                            sorted_pairs(
                                w.components) do
                            if WeaponComponents[cid] then
                                w:SetWeaponComponent(
                                    cslot,
                                    cid)
                                n = n +
                                        1
                            end
                        end
                        w.rat_updated_in =
                            nil
                        ObjModified(w)
                    end
                end
            end
            u.combat_cache = nil
        end
    end
    return "aperture: reaplicado em " ..
               n .. " componentes"
end

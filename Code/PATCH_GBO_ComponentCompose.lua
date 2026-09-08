---------------------------------------------------------------------------------------------------
---- COMPOSITOR DE COMPONENTES
----
---- Um componente deixa de ter efeitos/params autorados a mao e passa a ser uma LISTA DE TRACOS
---- ("Barrel.Short", "Barrel.Light"). Cada traco e uma receita; o compositor funde as receitas e
---- escreve o resultado no preset vivo.
----
---- REGRA DURA DO MOTOR que dita todo o desenho: Weapon.lua chama AddModifier(component_id, stat)
---- e Modifiers.lua remove a entrada anterior de mesmo id -- ou seja, DOIS efeitos do MESMO
---- componente sobre o MESMO StatToModify nao somam, o segundo apaga o primeiro em silencio.
---- Por isso a fusao acontece num espaco canonico com sinal (OverwatchAngle, e nao
---- ...Increase/...Decrease) e so no fim se escolhe UM efeito por stat pelo lado do produto.
---- Entre componentes DIFERENTES o motor ja compoe multiplicativamente (ModAccumulate), entao
---- 107 x 103 = 110 sai de graca -- o mesmo 110 hoje setado na mao no Short Light Barrel.
---------------------------------------------------------------------------------------------------

---- Como cada param canonico se combina quando dois tracos o declaram.
---- mul_pct: percentual base 100 (MulDivRound). add: soma. max/min/set: sem identidade.
GBO_PARAM_COMBINE = {
    OverwatchAngle = "mul_pct",
    snapshot_mul = "mul_pct",
    hip_mul = "mul_pct",
    recoil_mul = "mul_pct",

    RangeIncrease = "add",
    RangeDecrease = "add",
    DamageIncrease = "add",
    DamageReduced = "add",
    AimAccuracyIncrease = "add",
    APincrease = "add",
    APdecrease = "add",
    MagazineSizeDecrease = "add",
    ReliabilityIncrease = "add",
    ReliabilityDecrease = "add",
    MaxAimActionsIncrease = "add",
    BuckshotAngleIncrease = "max",
    bonus_cth = "max"
}

---- Params canonicos COM SINAL: o compositor escolhe o efeito pelo lado do 100 em que o produto
---- caiu, e nao emite nada quando o produto e exatamente 100. E o unico jeito de garantir
---- <= 1 efeito por stat sem depender da ordem em que os tracos foram listados.
GBO_STAT_EMIT = {
    OverwatchAngle = {
        base = 100,
        above = {"IncreaseOverwatchAngle", "OverwatchAngleIncrease"},
        below = {"DecreaseOverwatchAngle", "OverwatchAngleDecrease"}
    },
    snapshot_mul = {
        base = 100,
        above = {"IncreaseSnapshotMul", "snap_mul_inc"},
        below = {"DecreaseSnapshotMul", "snap_mul_reduc"}
    },
    hip_mul = {
        base = 100,
        above = {"IncreaseHipfireMul", "hip_mul_inc"},
        below = {"DecreaseHipfireMul", "hipfire_mul_reduc"}
    }
    ---- recoil_mul ainda nao tem par Increase/Decrease autorado no editor.
}

---- params escritos como PresetParamPercent (so muda a classe do PlaceObj e a tag; a conta do
---- motor le Scale do EFEITO, nao daqui). `bonus_cth` fica de fora porque e percent em GW43 e em
---- ImprovedIronsight_AR15 e number no resto -- essas receitas declaram `pct` proprio.
----
---- snap_mul_reduc / snap_mul_inc / hip_mul_inc / hipfire_mul_reduc NAO entram: o items.lua os
---- autora como percent mas o caminho do aperture sempre os escreveu como number, e number e o que
---- esta em campo. Divergencia herdada, mantida de proposito para o refactor nao mudar nada.
GBO_COMPOSE_PCT = {
    crit = true,
    crit_bonus = true,
    bonus_cth_interrupt = true,
    stealth_kill_bonus = true
}

---------------------------------------------------------------------------------------------------
---- RECEITAS. Um nome de param que esteja em GBO_STAT_EMIT e canonico e sera traduzido no fim;
---- qualquer outro e o proprio nome do param do efeito e sai como esta.
---------------------------------------------------------------------------------------------------
GBO_COMP_TRAITS = {
    ["Barrel.Long"] = {
        effects = {
            "longbarrel", "IncreaseRange", "IncreaseAimAccuracy", "IncreaseDamage",
            "StanceAPincrease"
        },
        params = {
            OverwatchAngle = 95,
            RangeIncrease = 4,
            DamageIncrease = 1,
            AimAccuracyIncrease = 2,
            APincrease = 1
        }
    },
	["Barrel.LongShotgun"] = {
        effects = {
            "longbarrel", "IncreaseRange", "IncreaseAimAccuracy",
            "StanceAPincrease"
        },
        params = {
            OverwatchAngle = 95,
            RangeIncrease = 4,
            AimAccuracyIncrease = 2,
            APincrease = 1
        }
    },
    ["Barrel.Short"] = {
        effects = {"shortbarrel", "ReduceRange", "ReduceDamage", "StanceAPdecrease"},
        params = {
            OverwatchAngle = 107,
            RangeDecrease = 2,
            DamageReduced = 1,
            APdecrease = 1
        }
    },
	    ["Barrel.ShortShotgun"] = {
        effects = {"shortbarrel", "ReduceRange", "StanceAPdecrease"},
        params = {
            OverwatchAngle = 107,
            RangeDecrease = 2,
            APdecrease = 1
        }
    },
    ---- cano curto de pistola: sem perda de dano nem de AP de postura, e o cone abre menos.
    ["Barrel.ShortHandgun"] = {
        effects = {"shortbarrel", "ReduceRange"},
        params = {OverwatchAngle = 105, RangeDecrease = 2}
    },
	["Barrel.LongHandgun"] ={
		effects = {
				"IncreaseRange",
				"IncreaseAimAccuracy",
				"longbarrel",
				"DecreaseOverwatchAngle",
			},
		params = {
			RangeIncrease = 2,
			DamageIncrease = 1,
			AimAccuracyIncrease = 1,
			OverwatchAngle = 92
		}
	},
    ["Barrel.Light"] = {
        effects = {"hipfire_light_barrel", "ExtraOverwatchShots"},
        params = {OverwatchAngle = 103}
    },

    ["Barrel.Heavy"] = {
        effects = {"heavy_barrel_effect"},
        params = {OverwatchAngle = 95}
    },
    ["Barrel.Improved"] = {
        effects = {"IncreaseReliability"},
        params = {ReliabilityIncrease = 10}
    },
    ["Mag.Reduced2"] = {
        effects = {"ReduceMagazineSize"},
        params = {MagazineSizeDecrease = 2}
    },
	["General.ReduceReliability"]= {
        effects = {"ReduceReliability"},
        params = {ReliabilityDecrease = 10}
    },
	["Mag.Multiplier150"]= {
        effects = {"MagazineSizeMultiplier"},
        params = {MagazineSizeMultiplier = 150}
    },
    ["Shotgun.WideBuckshot"] = {
        effects = {"IncreaseBuckshotAngle"},
        params = {BuckshotAngleIncrease = 122}
    },

	["Shotgun.NarrowBuckshot"] = {
        effects = {"DecreaseBuckshotAngle"},
        params = {BuckshotAngleDecrease = 78}
    },
	["Bipod"] ={
		effects = {			
			"AccuracyBonusProne",
			"bipod_penalty",
			"rotate_ap_bipod",
			"RecoilControlWhenProne",
		},
		params = {bonus_cth = 10}
	},
	["Barrel.to50AE"]={
		effects = {			
			"IncreaseDamage",
			"ChangeCaliberToBMG",
			"ReduceReliability",
			"StanceAPincrease" -- as it is a handgun, normally long barrel do not extend
		},
		params = {
			DamageIncrease = 10,
			ReliabilityDecrease = 10,
			APincrease = 1,
		}
	},
	["Barrel.to762_54R"]={
		effects = {			
			"IncreaseDamage",
			"ChangeCaliberTo762_54r",
			"ReduceReliabilityPercent",
		},
		params = {
			DamageIncrease = 7,
			ReliabilityDecreasePercent = 50,
		}
	},
	
}

---- Componente -> tracos, para ids que ainda nao tem a propriedade GBO_ComponentTraits autorada.
---- A propriedade do preset SEMPRE ganha; este mapa e so o caminho de escape para testar um id
---- sem passar pelo editor. Componente ausente dos dois nao e tocado.
----
---- Os sete barris de fundacao (BarrelLong, BarrelShort, BarrelShort_handgun,
---- BarrelShort_Winchester, BarrelShortShotgun_Benelli, BarrelLongImproved, BarrelHeavyLong)
---- migraram para a propriedade em 2026-09-08, depois de o diff no processo vivo dar IDENTICO
---- nos sete -- composicao sem nenhuma mudanca de balance.
---------------------------------------------------------------------------------------------------
---- RECEITAS BASE -- o que cada componente E, antes de qualquer modo de CTH. Vieram do
---- RAT_SCOPE_ORIGINALS, o pristino hardcodado do aperture; mover para ca acabou com os
---- dois sistemas paralelos escrevendo o mesmo preset.
----
---- Continuam hardcodadas de proposito: o compositor MUTA o preset vivo, e se a verdade
---- fosse lida do preset em runtime um save no editor gravaria o resultado composto por
---- cima da fonte. Com a fonte aqui, o items.lua vira saida derivada e descartavel.
----
---- Cada entrada vira o traco "Base.<id>" automaticamente (GBO_RegisterBaseRecipes).
---------------------------------------------------------------------------------------------------
--TODO: do I need to remove the entries here?
GBO_BASE_RECIPES = {
    -- VerticalGrip = {
    --	effects = { "AccuracyBonusWhenAimed_vgrip", "Vert_grip_recoi",  "grip_prone_penalty"},
    --	params = { bonus_cth_v = 3 },
    -- },
	UVDot = {
		effects = {
			--"hipfire_dot_effect_uv",
			"DecreaseSnapshotMul",
			"DecreaseHipfireMul",
			"IncreaseAimAccuracy",
			"body_part_uv"},
		params = {
			AimAccuracyIncrease = 1,
			snap_mul_reduc = const.Combat.SnapshotHipfire.Components.LaserMul or 90,
			hipfire_mul_reduc = const.Combat.SnapshotHipfire.Components.LaserMul or 90
		},
	},
	LaserDot = {
		effects = {
			--"hipfire_dot_effect_uv",
			"DecreaseSnapshotMul",
			"DecreaseHipfireMul",
			"IncreaseCritChangeScaled",
			"critical_per_aim_laser"},
		params = {
			CritChangeScaledIncrease = 10,
			snap_mul_reduc = const.Combat.SnapshotHipfire.Components.LaserMul or 90,
			hipfire_mul_reduc = const.Combat.SnapshotHipfire.Components.LaserMul or 90
		},
	},
	BarrelLong = {
		effects = {
			"IncreaseRange",
			"IncreaseAimAccuracy",
			"longbarrel",
			"IncreaseDamage",
			"StanceAPincrease",
			"DecreaseOverwatchAngle",
		},
		params = {
			RangeIncrease = 4,
			DamageIncrease = 1,
			AimAccuracyIncrease = 2,
			APincrease = 1,
			OverwatchAngleDecrease = 95,
		}
	},
	BarrelShort = {
		effects = {
			"ReduceRange",
			"shortbarrel",
			"ReduceDamage",
			"IncreaseOverwatchAngle",
			"StanceAPdecrease",
		},
		params = {
			DamageReduced = 1,
			RangeDecrease = 2,
			OverwatchAngleIncrease = 107,
			APdecrease = 1
		}
	},
	BarrelShort_handgun = {
		effects = {
		"ReduceRange",
		"shortbarrel",
		"IncreaseOverwatchAngle",},
		params = {			
			--DamageReduced = 1,
			RangeDecrease = 2,
			OverwatchAngleIncrease = 105,
		}
	},
	BarrelShort_Winchester ={
		effects = {
			"ReduceRange",
			"shortbarrel",
			"ReduceDamage",
			"IncreaseOverwatchAngle",
			"StanceAPdecrease",
			"ReduceMagazineSize"
		},
		params = {
			DamageReduced = 1,
			RangeDecrease = 2,
			OverwatchAngleIncrease = 107,
			APdecrease = 1,
			MagazineSizeDecrease = 2
		}
	},
	BarrelShortShotgun_Benelli  ={
		effects = {
			"ReduceRange",
			"shortbarrel",
			"ReduceDamage",
			"IncreaseOverwatchAngle",
			"StanceAPdecrease",
			"ReduceMagazineSize",
			"IncreaseBuckshotAngle"
		},
		params = {
			DamageReduced = 1,
			RangeDecrease = 2,
			OverwatchAngleIncrease = 107,
			APdecrease = 1,
			MagazineSizeDecrease = 2,
			BuckshotAngleIncrease = 122,
		}
	},
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

GBO_COMPONENT_TRAITS = {}

---- Camadas condicionais ao modo de jogo. Cada overlay e uma funcao(id, comp) que devolve uma
---- receita ou nil. Diferente de um traco, o overlay SOBRESCREVE params em vez de combinar, e o
---- seu `effects` e um mapa {id = true|false} -- true garante presente, false garante ausente.
---- O arquivo do aperture registra o dele aqui; o compositor nao sabe o que e uma optica.
GBO_COMPOSE_OVERLAYS = {}

---- Toda receita base vira o traco "Base.<id>", e o componente de mesmo nome passa a declarar esse
---- traco por padrao. Assim um scope sem nada autorado continua sendo ele mesmo, e quem quiser
---- compor por cima e so listar mais tracos na propriedade.
function GBO_RegisterBaseRecipes()
    for id, recipe in pairs(GBO_BASE_RECIPES or empty_table) do
        local tname = "Base." .. id
        GBO_COMP_TRAITS[tname] = recipe
        GBO_COMPONENT_TRAITS[id] = GBO_COMPONENT_TRAITS[id] or {tname}
    end
end
GBO_RegisterBaseRecipes()

---------------------------------------------------------------------------------------------------

---- Aplica a regra de combinacao. `acc` nil = primeiro valor visto, entao nao ha identidade a
---- declarar por regra.
local function combine(rule, acc, value)
    if acc == nil then
        return value
    end
    if rule == "mul_pct" then
        return MulDivRound(acc, value, 100)
    elseif rule == "add" then
        return acc + value
    elseif rule == "max" then
        return acc > value and acc or value
    elseif rule == "min" then
        return acc < value and acc or value
    end
    return value -- "set": o ultimo vence
end

---- Lista de tracos de um componente. Propriedade primeiro (texto separado por virgula), mapa de
---- codigo como fallback.
local function traits_of(id, comp)
    local prop = comp and rawget(comp, "GBO_ComponentTraits")
    if type(prop) == "table" and #prop > 0 then
        return prop
    end
    if type(prop) == "string" and prop ~= "" then
        local list = {}
        for name in string.gmatch(prop, "[^,%s]+") do
            list[#list + 1] = name
        end
        if #list > 0 then
            return list
        end
    end
    return GBO_COMPONENT_TRAITS[id]
end

---- Funde as receitas dos tracos num trio {effects, params, pct}. `overlay` entra depois de tudo
---- com semantica de SOBRESCRITA (ver GBO_COMPOSE_OVERLAYS): params trocam de valor em vez de
---- combinar, e effects e {id = true|false} para forcar presenca ou ausencia.
function GBO_ComposeTraits(trait_list, overlay)
    local effects, seen, params, pct = {}, {}, {}, {}

    for _, tname in ipairs(trait_list or empty_table) do
        local recipe = GBO_COMP_TRAITS[tname]
        if not recipe then
            print("GBO compose: traco inexistente --", tname)
        else
            for _, eid in ipairs(recipe.effects or empty_table) do
                if not seen[eid] then
                    seen[eid] = true
                    effects[#effects + 1] = eid
                end
            end
            for name, value in sorted_pairs(recipe.params or empty_table) do
                params[name] = combine(GBO_PARAM_COMBINE[name] or "set", params[name], value)
            end
            for name in pairs(recipe.pct or empty_table) do
                pct[name] = true
            end
        end
    end

    if overlay then
        local want = overlay.ModificationEffects or overlay.effects or empty_table
        local kept = {}
        for _, eid in ipairs(effects) do
            if want[eid] == false then
                seen[eid] = nil
            else
                kept[#kept + 1] = eid
            end
        end
        effects = kept
        for eid, on in sorted_pairs(want) do
            if on and not seen[eid] then
                seen[eid] = true
                effects[#effects + 1] = eid
            end
        end
        for name, value in sorted_pairs(overlay.Parameters or overlay.params or empty_table) do
            params[name] = value -- sobrescreve, nao combina
        end
    end

    ---- canonicos com sinal viram no maximo UM efeito cada
    local emitted = {}
    for name, emit in sorted_pairs(GBO_STAT_EMIT) do
        local value = params[name]
        params[name] = nil
        if value and value ~= emit.base then
            local pair = value > emit.base and emit.above or emit.below
            if not seen[pair[1]] then
                seen[pair[1]] = true
                effects[#effects + 1] = pair[1]
            end
            emitted[pair[2]] = value
        end
    end
    for name, value in pairs(emitted) do
        params[name] = value
    end

    return effects, params, pct
end

---- Avisa quando dois efeitos do mesmo componente disputam o mesmo StatToModify -- nesse caso o
---- motor mantem so o ultimo, calado. O compositor nao deveria produzir isso; a checagem existe
---- porque a lista `effects` dos tracos e escrita a mao.
local function warn_stat_collisions(id, effects)
    local by_stat = {}
    for _, eid in ipairs(effects) do
        local eff = WeaponComponentEffects and WeaponComponentEffects[eid]
        local stat = eff and eff.StatToModify
        if stat then
            if by_stat[stat] then
                print("GBO compose: colisao de stat em", id, "--", stat, "por", by_stat[stat],
                      "e", eid)
            else
                by_stat[stat] = eid
            end
        end
    end
end

---- Reescreve ModificationEffects/Parameters e refaz o cache de params. Mesmo contrato do
---- aperture_write em aCTH_PATCH_ScopesAndComponents: limpar g_PresetParamCache antes do PostLoad.
function GBO_WriteComponent(comp, effects, params_map, pct_map)
    comp.ModificationEffects = effects

    local list = {}
    for name, value in sorted_pairs(params_map) do
        local is_pct = (pct_map and pct_map[name]) or GBO_COMPOSE_PCT[name]
        local cls = is_pct and 'PresetParamPercent' or 'PresetParamNumber'
        local tag = is_pct and ("<" .. name .. ">%") or ("<" .. name .. ">")
        list[#list + 1] = PlaceObj(cls, {'Name', name, 'Value', value, 'Tag', tag})
    end
    comp.Parameters = list

    g_PresetParamCache[comp] = nil
    comp:PostLoad()
end

---- Passada principal. UNICO escritor de componente do mod: le os tracos, aplica os overlays de
---- modo e escreve. Roda no fim de GBO_GeneralComponentPatch e de novo a cada troca de modo.
function GBO_ApplyComponentCompose()
    local n = 0
    for id, comp in sorted_pairs(WeaponComponents or empty_table) do
        local list = traits_of(id, comp)
        if list then
            local overlay
            for _, fn in ipairs(GBO_COMPOSE_OVERLAYS) do
                overlay = fn(id, comp) or overlay
            end
            local effects, params, pct = GBO_ComposeTraits(list, overlay)
            warn_stat_collisions(id, effects)
            GBO_WriteComponent(comp, effects, params, pct)
            n = n + 1
        end
    end
    print("GBO compose: " .. n .. " componentes compostos")
    return n
end

---- Dump para conferir no processo vivo sem aplicar nada.
function GBO_ComposeReport(id)
    local comp = WeaponComponents and WeaponComponents[id]
    local list = traits_of(id, comp)
    if not list then
        return id .. ": sem tracos"
    end
    local overlay
    for _, fn in ipairs(GBO_COMPOSE_OVERLAYS) do
        overlay = fn(id, comp) or overlay
    end
    local effects, params = GBO_ComposeTraits(list, overlay)
    local out = {id .. " [" .. table.concat(list, ", ") .. "]"}
    out[#out + 1] = "  effects: " .. table.concat(effects, ", ")
    for name, value in sorted_pairs(params) do
        out[#out + 1] = "  " .. name .. " = " .. value
    end
    return table.concat(out, "\n")
end

---------------------------------------------------------------------------------------------------
---- NAO MAPEADOS -- a composicao diverge do autorado, entao entrar aqui MUDA balance. Decidir
---- caso a caso antes de mover para GBO_COMPONENT_TRAITS (medido no processo vivo, 2026-09-08):
----
----   BarrelShort_Light            Short+Light da angulo 110 (== autorado), mas RangeDecrease 2
----                                contra 4 autorado. O cano curto leve perde alcance dobrado por
----                                escolha, nao por composicao -- precisa de traco proprio ou de
----                                RangeDecrease no Barrel.Light.
----   BarrelShort_Light_handgun    autorado 107; ShortHandgun+Light da 105 x 103 = 108. Alem
----                                disso carrega DamageReduced=1 que o ShortHandgun sozinho nao
----                                tem. Provavelmente copiado do variante de fuzil sem revisar.
----   BarrelLight                  carrega AimAccuracyDecrease=2 sem nenhum efeito que leia esse
----                                param -- param orfao, some se o componente for composto.
----   BarrelHeavy                  idem: xrng=2, dmg=3, bonus_cth=5 orfaos.
---------------------------------------------------------------------------------------------------

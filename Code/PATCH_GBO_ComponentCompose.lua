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
    AimAccuracyDecrease = "add",
    APincrease = "add",
    APdecrease = "add",
    MagazineSizeDecrease = "add",
    ReliabilityIncrease = "add",
    ReliabilityDecrease = "add",
    MaxAimActionsIncrease = "add",
    BuckshotAngleIncrease = "mul_pct",
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
            "longbarrel",
			"IncreaseRange",
			"IncreaseAimAccuracy",
			"IncreaseDamage",
            "StanceAPincrease"
        },
        params = {
            OverwatchAngle = 95,
            RangeIncrease = 4,
            DamageIncrease = 1,
            AimAccuracyIncrease = 2,
            APincrease = 1
        },
        modes = {
            aCTH = {
                params = {AimAccuracyIncrease = 10},
            },
        },
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
        },
		modes = {
			aCTH = {
				params = {AimAccuracyIncrease = 10},
			},
		},
    },
    ["Barrel.Short"] = {
        effects = {"shortbarrel", "ReduceRange", "ReduceDamage", "StanceAPdecrease"},
        params = {
            OverwatchAngle = 107,
            RangeDecrease = 2,
            DamageReduced = 1,
            APdecrease = 1
        },
		modes = {
			aCTH = {
				effects = {DecreaseAimAccuracy = true},
				params = {AimAccuracyDecrease = 2, RangeDecrease = 4},
			},
		},
    },
	    ["Barrel.ShortShotgun"] = {
        effects = {"shortbarrel", "ReduceRange", "StanceAPdecrease"},
        params = {
            OverwatchAngle = 107,
            RangeDecrease = 2,
            APdecrease = 1
        },
		modes = {
			aCTH = {
				effects = {DecreaseAimAccuracy = true},
				params = {AimAccuracyDecrease = 2, RangeDecrease = 4},
			},
		},
    },
    ---- cano curto de pistola: sem perda de dano nem de AP de postura, e o cone abre menos.
    ["Barrel.ShortHandgun"] = {
        effects = {"shortbarrel", "ReduceRange"},
        params = {OverwatchAngle = 105, RangeDecrease = 2},
		modes = {
			aCTH = {
				effects = {DecreaseAimAccuracy = true},
				params = {AimAccuracyDecrease = 1},
			},
		},
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
		},
		modes = {
			aCTH = {
				params = {AimAccuracyIncrease = 5},
			},
		},
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
	["Stock.Light"] = {
		effects = 			{
			"light_stock_aim_reduce",
			"NoFullAuto",
			"StanceAPdecrease",
			"hipfire_light_stock",
			"stocklight_effect_recoil",},
		params = {
			APdecrease = 1
		},
	},
	["Stock.Bump"] = {
		effects = {
			"NoFullAuto",
		}

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

--	Mode deltas (see GBO_ComposeModeLayers). Replace this trait's own values before the merge:
--	["Bipod"] = {
--		effects = {"AccuracyBonusProne", "bipod_penalty", "rotate_ap_bipod"},
--		params = {bonus_cth = 10, aim_bonus = 2},
--		modes = {
--			aCTH = {
--				effects = {AccuracyBonusProne = false, RecoilControlWhenProne = true},
--				params = {bonus_cth = false, aim_bonus = 10, recoil_bonus = 9},
--			},
--		},
--	},
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
GBO_BASE_RECIPES = {
    ---------------------------------------------------------------------------------------------
    ---- ANCESTRAIS que ate 2026-09-11 so existiam como preset autorado. Cada um e a fonte de um
    ---- GBO_ComponentAncestor, entao entrar aqui traz a subarvore inteira junto (ver o mapa em
    ---- GBO_ApplyComponentAncestorEffect): 30 descendentes em _Master_MagLarge, 20 em StockHeavy,
    ---- 14 em VerticalGrip, 9 em Compensator. Transcritos do preset vivo, valor por valor.
    ----
    ---- `OverwatchAngleDecrease` solto (sem DecreaseOverwatchAngle na lista) e param ORFAO: o
    ---- motor nao tem efeito que o leia, entao nao faz nada. Copiado como estava de proposito --
    ---- corrigir e mudanca de balance, nao de transcricao.
    ---------------------------------------------------------------------------------------------
    VerticalGrip = {
        effects = {"Vert_grip_recoil", "grip_prone_penalty", "AccuracyBonusWhenAimed_vgrip"},
        params = {bonus_cth_v = 3}
    },
    StockHeavy = {
        effects = {"BonusAccuracyWhenFullyAimed", "stance_ap_inc_STR", "stockheavy_effect_recoil"},
        params = {range = 10, bonus_cth = 10, StanceIncreaseSTR = 1, STR_threshold = 85},
        pct = {bonus_cth = true}
    },
    StockNormal = {effects = {}},
    TacGrip = {
        effects = {"tac_grip_hipfire", "tac_grip_recoil", "tac_grip_PB", "grip_prone_penalty"},
        params = {accuracy = 5},
        pct = {accuracy = true}
    },
    Compensator = {
        effects = {"compensator_effect"},
        params = {cth = 10},
        pct = {cth = true}
    },
    Suppressor = {
        effects = {
            "SilentShots", "flanker", "compensator_effect_silencer", "DecreaseOverwatchAngle",
            "IncreaseConditionDegradationMul"
        },
        params = {
            NoiseMultiplier = 30,
            bonus_cth_flank = 10,
            OverwatchAngle = 97,
            ConditionDegradationMulIncrease = 10
        },
        pct = {NoiseMultiplier = true}
    },
    Flashlight = {effects = {"IgnoreInTheDark"}},
    FlashlightDot = {
        effects = {"StealthKillBonusPerAim", "IgnoreInTheDark"},
        params = {maxaims = 1, aim_bonus = 1, stealth_kill_bonus = 4},
        pct = {aim_bonus = true}
    },
    GrenadeLauncher = {
        effects = {"GrenadeLauncher", "DecreaseOverwatchAngle"},
        params = {OverwatchAngle = 80}
    },
    ---- MAGAZINES. OverwatchAngleDecrease orfao em todas -- ver o aviso no topo do bloco.
    _Master_MagLarge = {
        effects = {"IncreaseReloadAP", "MagazineSizeMultiplier"},
        params = {ReloadAPIncrease = 1, MagazineSizeMultiplier = 150, OverwatchAngleDecrease = 88}
    },
    _Master_MagLargeFine = {
        effects = {"MagazineSizeMultiplier"},
        params = {MagazineSizeMultiplier = 150, OverwatchAngleDecrease = 88}
    },
    _Master_MagNormalFine = {
        effects = {"IncreaseReliability"},
        params = {ReliabilityIncrease = 10}
    },
    _Master_DrumMag = {
        effects = {"MagazineSizeMultiplier", "drum_mag_hipfire"},
        params = {MagazineSizeMultiplier = 250, OverwatchAngleDecrease = 83}
    },
    MagQuick = {
        effects = {"ReduceReloadAP"},
        params = {ReloadAPDecrease = 2, OverwatchAngleDecrease = 85}
    },
    R_MagQuickLarge = {
        effects = {"ReduceReloadAP", "MagazineSizeMultiplier"},
        params = {ReloadAPDecrease = 1, MagazineSizeMultiplier = 150, OverwatchAngleDecrease = 72}
    },
    ---- MASTERS DO ToG. AimAccuracyDecrease/Increase sem o efeito par tambem e orfao: e por isso
    ---- que a penalidade de coronha viva vem de A.ComponentEffectsAimBonus, que casa pelo MARCADOR
    ---- (light_stock_aim_reduce / ReduceAimAccuracy) e nao pelo param.
    _Master_StockFolded_TOG = {
        effects = {
            "ReduceAimAccuracy", "no_stock", "StanceAPdecrease", "IncreaseOverwatchAngle",
            "hipfire_no_stock", "Enable_RunAndGun", "zzStockEquipped", "ReduceRange"
        },
        params = {AimAccuracyDecrease = 3, OverwatchAngle = 108, APdecrease = 1, RangeDecrease = 4}
    },
    _Master_StockLightUnfolded_TOG = {
        effects = {
            "light_stock_aim_reduce", "StanceAPdecrease", "stocklight_effect_recoil",
            "hipfire_light_stock", "zzStockEquipped"
        },
        params = {AimAccuracyDecrease = 2, APdecrease = 1}
    },
    _Master_StockNormalUnfolded_TOG = {effects = {"zzStockEquipped"}},
    _Master_VigM2_Stock_unfld_TOG = {
        effects = {"IncreaseAimAccuracy", "zzStockEquipped"},
        params = {AimAccuracyIncrease = 2},
        modes = {
            aCTH = {
                params = {AimAccuracyIncrease = 10},
            },
        },
    },
    _Master_VigM2_Stock_fld_TOG = {
        effects = {"vigneron_folded_PB", "zzStockEquipped", "IncreaseOverwatchAngle"},
        params = {OverwatchAngle = 107}
    },
    _Master_BayonetFolded_TOG = {
        effects = {"zzBayonetEquipped"},
        params = {AimAccuracyIncrease = 1}
    },
    _Master_BayonetUnfolded_TOG = {
        effects = {"Bayonet", "DecreaseOverwatchAngle", "zzBayonetEquipped"},
        params = {OverwatchAngle = 95, AimAccuracyDecrease = 1}
    },
    _Master_GrenadeLauncherFolded_TOG = {effects = {"zzGrndlEquipped"}},
    _Master_GrenadeLauncherUnfolded_TOG = {
        effects = {"DecreaseOverwatchAngle", "RAT_TOG_22m_launcher", "zzGrndlEquipped"},
        params = {OverwatchAngle = 95, AimAccuracyDecrease = 1}
    },
    _Master_ReceiverFullAuto_TOG = {effects = {"EnableFullAuto"}},
    _Master_ReceiverBurst_TOG = {
        effects = {"NoFullAuto", "Reduce_recoil_burst_delta"},
        params = {BurstRecoilDeltaMul = 90}
    },
    _Master_B93RR_grip_fld_TOG = {
        effects = {"ReduceReloadAP"},
        params = {ReloadAPDecrease = 1}
    },
	LightStock = {
		effects = 			{
			"light_stock_aim_reduce",
			"NoFullAuto",
			"StanceAPdecrease",
			"hipfire_light_stock",
			"stocklight_effect_recoil",
		},
		params = {
			APdecrease = 1
		},
	},
	NoStock = {
		effects = {
			"ReduceAimAccuracy",
			"no_stock",
			"StanceAPdecrease",
			"IncreaseOverwatchAngle",
			"hipfire_no_stock",
			"Enable_RunAndGun",
			"ReduceRange",
		},
		params = {
			OverwatchAngleIncrease = 108,
			APdecrease = 1,
			RangeDecrease = 4
	},
	},
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
		modes = {
			aCTH = {
				params = {AimAccuracyIncrease = 5},
			},
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
		},
		modes = {
			aCTH = {
				params = {AimAccuracyIncrease = 10},
			},
		},
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
        },
        modes = {
            aCTH = {
                params = {AimAccuracyIncrease = 10},
            },
        },
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
        },
        modes = {
            aCTH = {
                params = {AimAccuracyIncrease = 10},
            },
        },
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
        },
        modes = {
            aCTH = {
                params = {AimAccuracyIncrease = 15},
            },
        },
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
        },
        modes = {
            aCTH = {
                params = {AimAccuracyIncrease = 10},
            },
        },
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
        },
        modes = {
            aCTH = {
                params = {AimAccuracyIncrease = 10},
            },
        },
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
        },
        modes = {
            aCTH = {
                params = {AimAccuracyIncrease = 10},
            },
        },
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

---- Ids cuja composicao autorada ja e IDENTICA a de um traco existente -- medido no preset vivo,
---- assinatura por assinatura. Nao ganham receita propria: apontam para o traco e pronto.
GBO_COMPONENT_TRAITS = {
    StockNo = {"Base.NoStock"}, -- mesmo componente que NoStock, escrito duas vezes

    AK47_Launcher = {"Base.GrenadeLauncher"},
    GrenadeLauncher_AUG = {"Base.GrenadeLauncher"},
    GrenadeLauncher_Commando = {"Base.GrenadeLauncher"},
    GrenadeLauncher_M14 = {"Base.GrenadeLauncher"},
    GrenadeLauncher_M16A1 = {"Base.GrenadeLauncher"},
    BM59_grndl_fld = {"Base._Master_GrenadeLauncherFolded_TOG"},

    Flashlight_Anaconda = {"Base.Flashlight"},
    Flashlight_PSG_M1 = {"Base.Flashlight"},
    Flashlight_aa12 = {"Base.Flashlight"},
    G11_Rail_12 = {"Base.Flashlight"},
    ToG_Flashlight_1 = {"Base.Flashlight"},

    B93R_Under_fld_1 = {"Base._Master_B93RR_grip_fld_TOG"},
    FAMAE_mag2_1 = {"Base._Master_B93RR_grip_fld_TOG"},
    NTW20_stock_fld_1 = {"Base._Master_StockNormalUnfolded_TOG"},
    VigM2_Stock_hlffld_1 = {"Base._Master_StockNormalUnfolded_TOG"},
    StockNormal_AR_BurstOnly = {"Stock.Bump"},

    BarrelNormalImproved = {"Barrel.Improved"},
    FN2000_gasblock_ext_1 = {"Barrel.Improved"},
    Auto5_Basic_LMag = {"Mag.Multiplier150"},
    MagLargeFine_6 = {"Base._Master_DrumMag"}
}

---- Camadas condicionais ao modo de jogo. Cada overlay e uma funcao(id, comp) que devolve uma
---- receita ou nil. Diferente de um traco, o overlay SOBRESCREVE params em vez de combinar, e o
---- seu `effects` e um mapa {id = true|false} -- true garante presente, false garante ausente.
---- O arquivo do aperture registra o dele aqui; o compositor nao sabe o que e uma optica.
GBO_COMPOSE_OVERLAYS = {}

---- Reescalas condicionais ao modo, aplicadas sobre o param JA FUNDIDO -- depois dos tracos e do
---- overlay, antes do emit. Cada entrada e uma funcao(params) que altera a tabela recebida.
----
---- Existem porque escalar a RECEITA e errado de tres jeitos: acumula (o valor escalado vira a
---- nova base e o proximo load escala de novo), nao desfaz quando o modo desliga, e depende de a
---- passada rodar depois de GBO_RegisterBaseRecipes -- foi assim que a versao anterior deixou
---- toda luneta de fora e so escalou os tracos escritos a mao. Aqui nada disso pode acontecer: a
---- receita nunca e tocada e a escala e recalculada em toda composicao.
GBO_COMPOSE_SCALERS = {}

---- AimAccuracy ja NAO e escalado aqui: cada receita autora o valor de aCTH em `modes`. A escala
---- proporcional comprimia tudo perto de A.DecayMinPct, onde o bonus satura.

---- O aperture nao escreve mais componente nenhum: quem escreve e o compositor
---- (GBO_ApplyComponentCompose), que le as receitas base e aplica esta camada por cima. Aqui so
---- sobra o WeaponRange, que e propriedade de CLASSE e nao de componente.
----
---- A camada: com o aperture ligado, o componente listado em ApertureComponentTier ganha o perfil
---- da sua ampliacao. No perfil, `ModificationEffects` e true = garante presente / false = garante
---- ausente, e `Parameters` SOBRESCREVE em vez de combinar -- por isso entra como overlay e nao
---- como mais um traco.


local function aperture_overlay(id)
    local ap = const.Combat.Aperture -- sempre a tabela viva
    if not ap or not ap.Enabled then
        return nil
    end
    local tier =
        (ap.ApertureComponentTier or
            empty_table)[id]
    return tier and
               (ap.ApertureMagnifications or
                   empty_table)[tier] or
               nil
end
GBO_COMPOSE_OVERLAYS[#GBO_COMPOSE_OVERLAYS+1] = aperture_overlay

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

---- Active mode layers, general to specific; later layers override earlier ones.
GBO_COMPOSE_MODE_KEYS = {oldCTH = true, aCTH = true, aCTHSim = true}

function GBO_ComposeModeLayers()
    local ap = const.Combat.Aperture
    if not ap or not ap.Enabled then
        return {"oldCTH"}
    end
    return ap.SimulateShots and {"aCTH", "aCTHSim"} or {"aCTH"}
end

---- {id = true} appends if missing, {id = false} removes; keeps `seen` in sync with the list.
local function apply_effect_delta(effects, seen, want)
    local kept = {}
    for _, eid in ipairs(effects) do
        if want[eid] == false then
            seen[eid] = nil
        else
            kept[#kept + 1] = eid
        end
    end
    for eid, on in sorted_pairs(want) do
        if on and not seen[eid] then
            seen[eid] = true
            kept[#kept + 1] = eid
        end
    end
    return kept
end

---- The trait as seen in the active mode. Param value = set, false = remove. Returns a new table:
---- the recipe itself is the pristine source and must never be mutated.
local function resolve_modes(tname, recipe, layers)
    local modes = recipe.modes
    if not modes then
        return recipe
    end
    for key in pairs(modes) do
        if not GBO_COMPOSE_MODE_KEYS[key] then
            print("GBO compose: modo inexistente --", tname, key)
        end
    end
    local effects, seen = {}, {}
    for _, eid in ipairs(recipe.effects or empty_table) do
        if not seen[eid] then
            seen[eid] = true
            effects[#effects + 1] = eid
        end
    end
    local params = table.copy(recipe.params or empty_table)
    local pct = table.copy(recipe.pct or empty_table)
    for _, key in ipairs(layers) do
        local delta = modes[key]
        if delta then
            effects = apply_effect_delta(effects, seen, delta.effects or empty_table)
            for name, value in pairs(delta.params or empty_table) do
                params[name] = value or nil
            end
            for name, on in pairs(delta.pct or empty_table) do
                pct[name] = on or nil
            end
        end
    end
    return {effects = effects, params = params, pct = pct}
end

---- Funde as receitas dos tracos num trio {effects, params, pct}. `overlay` entra depois de tudo
---- com semantica de SOBRESCRITA (ver GBO_COMPOSE_OVERLAYS): params trocam de valor em vez de
---- combinar, e effects e {id = true|false} para forcar presenca ou ausencia.
function GBO_ComposeTraits(trait_list, overlay, layers)
    local effects, seen, params, pct = {}, {}, {}, {}
    layers = layers or GBO_ComposeModeLayers()

    for _, tname in ipairs(trait_list or empty_table) do
        local recipe = GBO_COMP_TRAITS[tname]
        if not recipe then
            print("GBO compose: traco inexistente --", tname)
        else
            recipe = resolve_modes(tname, recipe, layers)
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
        effects = apply_effect_delta(effects, seen,
                                     overlay.ModificationEffects or overlay.effects or empty_table)
        for name, value in sorted_pairs(overlay.Parameters or overlay.params or empty_table) do
            params[name] = value -- sobrescreve, nao combina
        end
    end

    for _, fn in ipairs(GBO_COMPOSE_SCALERS) do
        fn(params, trait_list, overlay)
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
    local layers = GBO_ComposeModeLayers()
    for id, comp in sorted_pairs(WeaponComponents or empty_table) do
        local list = traits_of(id, comp)
        if list then
            local overlay
            for _, fn in ipairs(GBO_COMPOSE_OVERLAYS) do
                overlay = fn(id, comp) or overlay
            end
            local effects, params, pct = GBO_ComposeTraits(list, overlay, layers)
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


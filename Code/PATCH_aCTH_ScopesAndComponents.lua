--------------------------------------------------------------------------------------------------
---- PERFIS DE OPTICA do aperture. Este arquivo so DESCREVE o que cada ampliacao faz; quem escreve
---- no componente e o compositor (PATCH_GBO_ComponentCompose), que registra cada ampliacao como o
---- traco "Scope.<tier>" (A.ScopeTraits) e o compoe por cima da receita base. O pristino que era hardcodado aqui
---- (RAT_SCOPE_ORIGINALS) virou GBO_BASE_RECIPES no compositor -- eram dois sistemas escrevendo o
---- mesmo preset, e a ordem dos handlers decidia quem ganhava.
----
---- O que sobrou de escrita aqui e o WeaponRange, que e propriedade de CLASSE e nao de componente.
---- Reaplica em armas em campo: Rat_ReapplyApertureComponents().
--------------------------------------------------------------------------------------------------
local A = const.Combat.Aperture

--- Refactored Scopes
---- Flat AimAccuracy per component effect on aim levels from..to (to nil = every aimed level); negative = penalty.
---- Stocks stay HERE and not in a trait's aCTH mode: 62 stock components carry these markers and
---- only 2 have traits, so a trait would drop the penalty from the other 60. Revisit once they do.
A.ComponentEffectsAimBonus = {
    {id = "light_stock_aim_reduce", from = 1, acc = -4}, -- light/unfolded stocks; -8 equals the old x110 decay at acc 22
    {id = "ReduceAimAccuracy", from = 1, acc = -12}, -- no/folded stocks
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
---- Per-magnification value lives in each Scope trait as `floor_mul` (absent = 100).

---- Miras: o `bonus_cth` autorado no componente vira multiplicador de cone, aplicado uma vez com
---- aim >= 1 ou required aim. Cada entrada daqui e um componente independente -- 
---- Nao muda a assintota, ganho de velocidade de convergencia
A.ConeMulBonus = true
A.ConeMulEffects = {
    {
        id = "AccuracyBonusWhenAimed", -- Sights
        param = "bonus_cth",
        no_dual = true -- nobody sights two guns at once
    }, {
        id = "BonusAccuracyWhenFullyAimed", -- Heavy Stock
        param = "bonus_cth",
        required_aim = 3
    }, {
        id = "AccuracyBonusWhenAimed_vgrip", -- Vgrip
        param = "bonus_cth_v",
        no_dual = true -- one hand per gun, no grip to hold
    }
}

---- Magnifications are traits ("Scope._6x"), registered into GBO_COMP_TRAITS by the compositor.
---- `effects`/`params` outside `modes` are what EVERY scope of that magnification has in both CTH
---- modes -- measured as the common part of the components bound to the tier. A component only
---- authors what differs from this. A number here is overwritten on nobody: it is common by
---- construction, and a scope that deviates needs a mode block or a tier of its own.
---- `overwrite`: params replace instead of combining, effects {id = true|false} force presence.
---- Everything sits under modes.aCTH, so under oldCTH a Scope trait composes to nothing.
---- Params: integer values (percent params use the raw integer, 150 = 150%). Aim levels =
---- IncreaseMaxAimActions (MaxAimActionsIncrease); optic range = IncreaseRange (RangeIncrease).
local function scale_aim(aim)
    local ap = const.Combat.Aperture
    return MulDivRound(aim, ap.aCTHAimAccuracyScaleMul, 100)
end

A.ScopeTraits = {
    ---- AMPLIACAO E COMPROMISSO, nao upgrade. Cada degrau paga adiantado e cobra depois:
    ----   niveis de mira a mais + piso mais baixo   (so rende com mira alta e longe)
    ----   ScopePenalty maior                        (pior de perto, em qualquer nivel)
    ----   limiar de mira comecando mais tarde       (pior no aim 3, melhor do 4 em diante)
    ["Scope._6x"] = {
        overwrite = true,
        effects = {"IncreaseMaxAimActions", "IncreaseRange", "ScopePenalty3"},
        params = {RangeIncrease = 16},
        floor_mul = 74,
        modes = {
            aCTH = {
                params = {
                    MaxAimActionsIncrease = 3,
                    snap_mul_inc = 160, -- 140
                    aim_level_threshold = 6,
                    threshold_bonus_aim_acc = scale_aim(5)
                },
                effects = {
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
            }
        }
    },
    ["Scope._4x"] = {
        overwrite = true,
        effects = {"IncreaseRange", "ScopePenalty2"},
        params = {RangeIncrease = 10},
        floor_mul = 84,
        modes = {
            aCTH = {
                params = {
                    MaxAimActionsIncrease = 2,
                    snap_mul_inc = 140, -- 125
                    aim_level_threshold = 5,
                    threshold_bonus_aim_acc = scale_aim(5)
                },
                effects = {
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
            }
        }
    },
    ["Scope._2x"] = {
        overwrite = true,
        effects = {"IncreaseAimAccuracy", "IncreaseRange", "ScopePenalty1"},
        params = {AimAccuracyIncrease = 2},
        floor_mul = 94,
        modes = {
            aCTH = {
                params = {
                    MaxAimActionsIncrease = 1,
                    snap_mul_inc = 125, -- 110
                    aim_level_threshold = 4,
                    threshold_bonus_aim_acc = scale_aim(3)
                },
                effects = {
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
            }
        }
    },
    ---- 2x de aquisicao rapida (ACOG/WideScope): trocam o piso e a mira alta pelo snapshot. O
    ---- `snap_reduc` positivo autorado no componente e mantido -- o perfil nao o sobrescreve.
    ["Scope._2xQuick"] = {
        overwrite = true,
        effects = {"FirstAimBonusModifier", "IncreaseAimAccuracy", "IncreaseRange", "ScopePenalty1", "scope_snapshot"},
        params = {AimAccuracyIncrease = 2, OverwatchAngle = 110, RangeIncrease = 6, first_aim_bonus_acc = 3, snap_reduc = 5},
        floor_mul = 94,
        modes = {
            aCTH = {
                params = {
                    MaxAimActionsIncrease = 1,
                    aim_level_threshold = 4,
                    -- threshold_bonus_aim_acc = scale_aim(2),
                    first_aim_bonus_acc = scale_aim(3)
                },
                effects = {
                    ScopeAimThresholdBonus = false,
                    IncreaseMaxAimActions = true,
                    scope_snapshot = false,
                    ScopePenalty1 = true,
                    ScopePenalty2 = false,
                    ScopePenalty3 = false,
                    IncreaseRange = true,
                    IncreaseAimAccuracy = false,
                    FirstAimBonusModifier = true
                }
            }
        }
    },
    ["Scope._2xWide"] = {
        overwrite = true,
        effects = {"IncreaseAimAccuracy", "IncreaseRange", "OpportunityAttackBonusCth", "ScopePenalty1", "scope_snapshot"},
        params = {AimAccuracyIncrease = 2, RangeIncrease = 6, bonus_cth_interrupt = 8, snap_reduc = 5},
        modes = {
            aCTH = {
                params = {
                    MaxAimActionsIncrease = 1,
                    snap_mul_reduc = 95,
                    first_aim_bonus_acc = 8--scale_aim(2)
                },
                effects = {
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
            }
        }
    },
    ["Scope._1dot5x"] = {
        overwrite = true,
        effects = {"IncreaseRange"},
        params = {RangeIncrease = 4},
        floor_mul = 98,
        modes = {
            aCTH = {
                params = {MaxAimActionsIncrease = 1},
                effects = {
                    IncreaseMaxAimActions = true,
                    IncreaseRange = true,
                    IncreaseAimAccuracy = false,
                    ScopePenalty1 = false,
                    ScopePenalty2 = false,
                    ScopePenalty3 = false,
					AccuracyBonusWhenAimed = false
                }
            }
        }
    },
    ---- bonus_cth 10 -> 12: a reflex e a opcao BARATA (sem nivel de mira extra, sem AP de entrada),
    ---- entao precisa ser a melhor no aim 1-3 ou a 2x rapida a domina sem custar nada a mais.
--TODO: old cth has missing params and effects here
    ["Scope.Reflex"] = {
        overwrite = true,
        effects = {"AccuracyBonusWhenAimed", "reflex_sight_close_range", "DecreaseSnapshotMul"},
		--params = {bonus_cth = x, snap_mul_reduc = 85, Close_bonus},
        floor_mul = 100, -- explicit: stops Rat_ScopeFloorMul scanning other components
        modes = {
            aCTH = {
                params = {bonus_cth = 12, snap_mul_reduc = 85},
                effects = {
                    AccuracyBonusWhenAimed = true,
                    reflex_sight_close_range = false,
                    scope_snapshot = false, -- old hardcoded effect
                    DecreaseSnapshotMul = true
                }
            }
        }
    },
    ["Scope.ReflexAdvanced"] = {
        overwrite = true,
        effects = {"AccuracyBonusWhenAimed", "first_aim_crit", "reflex_sight_close_range", "DecreaseSnapshotMul"},
        params = {Close_bonus = 5, bonus_cth = 3, snap_mul_reduc = 90},
        modes = {
            aCTH = {
                params = {bonus_cth = 10, snap_mul_reduc = 90},
                effects = {
                    AccuracyBonusWhenAimed = true,
                    reflex_sight_close_range = false,
                    scope_snapshot = false,
                    DecreaseSnapshotMul = true
                }
            }
        }
    },
    ["Scope.ReflexVigilance"] = {
        overwrite = true,
        effects = {"AccuracyBonusWhenAimed", "OpportunityAttackBonusCth", "reflex_sight_close_range", "scope_snapshot"},
        params = {Close_bonus = 5, OverwatchAngle = 125, RangeIncrease = 4, bonus_cth = 3, bonus_cth_interrupt = 10, snap_reduc = 10},
        modes = {
            aCTH = {
                params = {bonus_cth = 5, snap_mul_reduc = 85},
                effects = {
                    AccuracyBonusWhenAimed = true,
                    reflex_sight_close_range = false,
                    scope_snapshot = false,
                    DecreaseSnapshotMul = true
                }
            }
        }
    },
    ["Scope.Ironsight"] = {
        overwrite = true,
        effects = {"AccuracyBonusWhenAimed"},
        floor_mul = 100,
        modes = {
            aCTH = {
                params = {bonus_cth = 3},
                effects = {AccuracyBonusWhenAimed = true}
            }
        }
    }
    -- VerticalGrip = { -- no op
    --	Parameters = {bonus_cth = 3},
    --	ModificationEffects = {AccuracyBonusWhenAimed = true},
    -- }
}

---- Code-side binding, used only when the component's trait list has no Scope trait of its own.
A.ScopeTraitOf = {
    ReflexSight = "Scope.Reflex",
    ReflexSightAdvanced = "Scope.ReflexAdvanced",
    ReflexSightAdvanced_Glock = "Scope.ReflexAdvanced",
    _ReflexSIghtVigilance = "Scope.ReflexVigilance",
    ImprovedIronsight = "Scope.Ironsight",
    ImprovedIronsight_AR15 = "Scope.Ironsight", -- AR15
    G36_SCOPE = "Scope._2x",
    SCOPE_G36_2 = "Scope._2x",
    AUGScope_Default = "Scope._1dot5x",
    ScopeCOG = "Scope._2x",
    ---- ACOG e WideScope sao as 2x de aquisicao rapida: ja autoram scope_snapshot POSITIVO
    WideScope = "Scope._2xWide",
    ScopeCOGQuick = "Scope._2xQuick",
    LROptics = "Scope._4x",
    LROptics_DragunovDefault = "Scope._4x",
    ThermalScope = "Scope._4x",
    LROpticsAdvanced = "Scope._6x",
    PSG_DefaultScope = "Scope._6x",

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
    _Master_SSG69_Scope_TOG = "Scope._6x",
    ["_Master_PSO-1M2_Scope_TOG"] = "Scope._4x",
    _Master_SteyrS_Scope_TOG = "Scope._4x",
    _Master_m76_scope_TOG = "Scope._4x",
    _Master_GW43_Scope_TOG = "Scope._1dot5x",
    _Master_G11_Scope_1 = "Scope._1dot5x",
    TAR21_Scope_Rflx_1 = "Scope.Reflex" -- TAR21_1

    ---- FORA de proposito -- so servem arma ToG NAO patched, fora do escopo de balance do mod:
    ---- AWP_Scope_1, WA2000_Scope_1, NTW_20_Scope_1, Caws_Scope_1, FN2000_Scope_1,
    ---- G11_Rail_7, G11_Rail_9. E sem arma nenhuma: AN94_Scope_1, ThermalScope_1, ThermalScope_2.
}







---- Ancora de load: garante que o override roda depois deste arquivo (e do __ApertureParams) carregar.
---- __ApertureParams tambem chama via GBO_ApplyApertureCTHMode, mas so se ApplyModOptions/DataLoaded disparar.
function OnMsg.ModsReloaded()
    --ApplyApertureItemParams()
    if g_Units and #g_Units > 0 then
        Rat_ReapplyApertureComponents()
    end
end

---- Empurra o override para as armas ja equipadas em campo, sem esperar UnitCreated. Reaplica TODO
---- componente, nao so as opticas conhecidas: o valor da instancia foi calculado sobre a base
---- ANTIGA da classe, entao trocar WeaponRange exige recomputar tambem cano longo, bipe, etc.
--TODO: probably this is vestigial, clean or salvage
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
                    --if IsKindOf(w,
                    --            "Firearm") and
                    --    RAT_APERTURE_WEAPON_RANGE[w.class] then
                    --    local base =
                    --        rawget(
                    --            g_Classes[w.class],
                    --            "base_WeaponRange")
                    --    if rawget(w,
                    --              "base_WeaponRange") ~=
                    --        nil and base then
                    --        w:SetBase(
                    --            "WeaponRange",
                    --            base)
                    --    else
                    --        w:RestoreModifiableValue(
                    --            "WeaponRange")
                    --    end
                    --end
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

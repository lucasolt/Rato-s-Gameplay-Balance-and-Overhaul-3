--------------------------------------------------------------------------------------------------
---- PERFIS DE OPTICA do aperture. Este arquivo so DESCREVE o que cada ampliacao faz; quem escreve
---- no componente e o compositor (PATCH_GBO_ComponentCompose), que le a receita base e aplica o
---- perfil daqui como overlay quando A.Enabled. O pristino que era hardcodado aqui
---- (RAT_SCOPE_ORIGINALS) virou GBO_BASE_RECIPES no compositor -- eram dois sistemas escrevendo o
---- mesmo preset, e a ordem dos handlers decidia quem ganhava.
----
---- O que sobrou de escrita aqui e o WeaponRange, que e propriedade de CLASSE e nao de componente.
---- Reaplica em armas em campo: Rat_ReapplyApertureComponents().
--------------------------------------------------------------------------------------------------
local A = const.Combat.Aperture

--- Refactored Scopes
---- Flat AimAccuracy per component effect on aim levels from..to (to nil = every aimed level); negative = penalty.
A.ComponentEffectsAimBonus = {
    {id = "light_stock_aim_reduce", from = 1, acc = -8}, -- light/unfolded stocks; -8 equals the old x110 decay at acc 22
    {id = "ReduceAimAccuracy", from = 1, acc = -12}, -- no/folded stocks
    -- {
    --    id = "pso_dragunov_scope",
    --    from = 5,
    --    acc = 3
    -- }, {
    --    id = "sniper_aim_scope",
    --    from = 5,
    --    acc = 5
    -- }, {
    --    id = "sniper_adv_aim_scope",
    --    from = 6,
    --    acc = 5
    -- },
    -- {id = "_x2ScopeAimBonus", from = 4, acc = 3},
    -- {
    --    id = "FirstAimBonusModifier",
    --    from = 1,
    --    to = 1,
    --    acc = 3
    -- }, 
    -- {
    --    id = "BonusAccuracyWhenFullyAimed", -- HeavyStock
    --    from = 3,
    --    to = 3,
    --    acc = 2
    -- } 
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
    }, {
        id = "AccuracyBonusWhenAimed_vgrip", -- Vgrip
        param = "bonus_cth_v"
    }
}

---- Perfis por ampliacao. Parameters = {NomeDoParam = valor_inteiro} (param % usa o inteiro cru,
---- 150 = 150%). ModificationEffects = {EffectId = true garante presente | false garante ausente}.
---- Efeito de "niveis de mira" = IncreaseMaxAimActions (param MaxAimActionsIncrease); "range" da
---- optica = IncreaseRange (param RangeIncrease).
local function scale_aim(aim)
    local ap = const.Combat.Aperture
    return MulDivRound(aim,
                       ap.aCTHAimAccuracyScaleMul,
                       100)
end

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
            threshold_bonus_aim_acc = scale_aim(
                5)
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
            threshold_bonus_aim_acc = scale_aim(
                5)
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
            threshold_bonus_aim_acc = scale_aim(
                3)
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
            threshold_bonus_aim_acc = scale_aim(
                2),
            first_aim_bonus_acc = 3
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
            first_aim_bonus_acc = scale_aim(
                2)
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
        Parameters = {
            bonus_cth = 12,
            snap_mul_reduc = 85
        },
        ModificationEffects = {
            AccuracyBonusWhenAimed = true,
            reflex_sight_close_range = false,
            scope_snapshot = false, -- old hardcoded effect
            DecreaseSnapshotMul = true
        }
    },
    ReflexAdvanced = {
        Parameters = {
            bonus_cth = 10,
            snap_mul_reduc = 90
        },
        ModificationEffects = {
            AccuracyBonusWhenAimed = true,
            reflex_sight_close_range = false,
            scope_snapshot = false,
            DecreaseSnapshotMul = true
        }
    },
    ReflexVigilance = {
        Parameters = {
            bonus_cth = 5,
            snap_mul_reduc = 85
        },
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
---- ALCANCE DAS ARMAS no aCTH. {pristino, valor_no_aCTH}. NAO E MAIS APLICADO (ver apply_range):
---- o alcance por modo agora vem da planilha, via storeProps "WeaponRange" em PATCH_GBO_weapons.
---- Mantido so como referencia -- e a assintota do cone (d50 maximo = 1.545 x WeaponRange), regra
---- de esticao: +55% do que passa de 20 tiles em snipers (teto 44), +35% MG, +30% fuzil, +15% SMG,
---- 0 em pistola/revolver/escopeta.
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
    AKSU = {24, 24}, -- second was 26
    M4Commando = {24, 26},

    --
    M41Shotgun = {22, 26},
    Auto5 = {20, 24},
    AA12 = {20, 24},
    DoubleBarrelShotgun = {18, 22},
    Auto5_quest = {18, 22},

    TexRevolver = {20, 18},
    ColtPeacemaker = {20, 18},
    Bereta92 = {18, 16},
    Glock18 = {18, 16},
    HiPower = {18, 16},
    ColtAnaconda = {22, 18},
    DesertEagle = {24, 20},

    M1911_1 = {16, 14},
    P08_1 = {18, 16},
    B93RR_1 = {18, 16},
    Glock17_1 = {18, 16},
    USP_1 = {18, 16},
    VikingMP446_1 = {18, 16}
}

---- DESATIVADO 2026-09-10: o WeaponRange por modo agora sai de GBO_gCTHModeItemPropertyTable,
---- gerado pela planilha junto com o resto do PATCH_GBO_weapons (storeProps ... "WeaponRange").
---- Havia dois escritores discordando -- p.ex. PSG1 aCTH: 42 nesta tabela, 36 na planilha -- e o
---- resultado dependia de a guarda "valor inesperado" abaixo passar ou nao. A planilha ganha.
---- RAT_APERTURE_WEAPON_RANGE acima fica so como referencia do que foi migrado.
local function apply_range(idx)
end


---- Mantidas porque outros arquivos chamam: hoje so mexem no WeaponRange.
function Rat_RestoreApertureItemParams()
    apply_range(1)
end

function ApplyApertureItemParams()
    local ap = const.Combat.Aperture
    apply_range(
        ap and ap.Enabled and 2 or 1)
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

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

---- params que o motor le como PresetParamPercent. Os de barril sao todos Number.
GBO_COMPOSE_PCT = {
    snap_mul_inc = true,
    snap_mul_reduc = true,
    hip_mul_inc = true,
    hipfire_mul_reduc = true
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
    ["Barrel.Short"] = {
        effects = {"shortbarrel", "ReduceRange", "ReduceDamage", "StanceAPdecrease"},
        params = {
            OverwatchAngle = 107,
            RangeDecrease = 2,
            DamageReduced = 1,
            APdecrease = 1
        }
    },
    ---- cano curto de pistola: sem perda de dano nem de AP de postura, e o cone abre menos.
    ["Barrel.ShortHandgun"] = {
        effects = {"shortbarrel", "ReduceRange"},
        params = {OverwatchAngle = 105, RangeDecrease = 2}
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
    ["Shotgun.WideBuckshot"] = {
        effects = {"IncreaseBuckshotAngle"},
        params = {BuckshotAngleIncrease = 122}
    }
}

---- Componente -> tracos, para ids que ainda nao tem a propriedade GBO_ComponentTraits autorada.
---- A propriedade do preset SEMPRE ganha; este mapa e so o caminho de escape para testar um id
---- sem passar pelo editor. Componente ausente dos dois nao e tocado.
----
---- Os sete barris de fundacao (BarrelLong, BarrelShort, BarrelShort_handgun,
---- BarrelShort_Winchester, BarrelShortShotgun_Benelli, BarrelLongImproved, BarrelHeavyLong)
---- migraram para a propriedade em 2026-09-08, depois de o diff no processo vivo dar IDENTICO
---- nos sete -- composicao sem nenhuma mudanca de balance.
GBO_COMPONENT_TRAITS = {}

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

---- Funde as receitas dos tracos num par {effects, params}. `extra` entra por ultimo com as mesmas
---- regras de combinacao -- e o gancho para os perfis de aperture entrarem como mais uma camada.
function GBO_ComposeTraits(trait_list, extra)
    local effects, seen, params = {}, {}, {}

    local function absorb(recipe)
        for _, eid in ipairs(recipe.effects or empty_table) do
            if not seen[eid] then
                seen[eid] = true
                effects[#effects + 1] = eid
            end
        end
        for name, value in sorted_pairs(recipe.params or empty_table) do
            params[name] = combine(GBO_PARAM_COMBINE[name] or "set", params[name], value)
        end
    end

    for _, tname in ipairs(trait_list or empty_table) do
        local recipe = GBO_COMP_TRAITS[tname]
        if not recipe then
            print("GBO compose: traco inexistente --", tname)
        else
            absorb(recipe)
        end
    end
    if extra then
        absorb(extra)
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

    return effects, params
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

---- Passada principal. Roda DEPOIS de ApplyApertureItemParams: para todo componente que declara
---- tracos o compositor e a fonte da verdade, com aperture ligado ou desligado.
function GBO_ApplyComponentCompose()
    local n = 0
    for id, comp in sorted_pairs(WeaponComponents or empty_table) do
        local list = traits_of(id, comp)
        if list then
            local effects, params = GBO_ComposeTraits(list)
            warn_stat_collisions(id, effects)
            GBO_WriteComponent(comp, effects, params)
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
    local effects, params = GBO_ComposeTraits(list)
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

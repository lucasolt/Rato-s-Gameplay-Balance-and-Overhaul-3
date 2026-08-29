local function rT(id, text)
    return {id, text}
end

local function processMetatext(id, text, populate_crosshair)
    local in_id, in_text = id, text
    if type(id) == "table" then
        in_id = id[1]
        in_text = id[2]
    end
    if populate_crosshair then
        return TranslationTable[in_id] or in_text
    end
    return T(in_id, in_text)
end

---------------------------------------------------------------------------------------------------
---- Sobretaxa de MIRA por recoil acumulado, em unidades de AP (passos de 0,5).
----
---- Extraida de `ApplyPersistantRecoilEffects` para ficar CONSULTAVEL sem efeito
---- colateral. A IA do Rato's AI Overhaul precisa PREVER este custo ao planejar quantos
---- disparos mirados cabem no AP; sem isso ela orcava mira pelo preco base, a execucao
---- cobrava a sobretaxa por cima e o ultimo disparo simplesmente nao saia.
----
---- O ponto de extrair em vez de a IA reimplementar: a formula e cheia de float
---- (0.7 / 30.00 / cRoundFlt em 0,5 / 0.6). Uma copia em aritmetica inteira do outro
---- lado divergiria em silencio na primeira vez que um destes numeros mudasse -- e o mod
---- ja tem um caso assim, o `RECOIL_STACKS_PCT`, duplicado com um comentario de "manter
---- em sincronia".
----
---- PURA: nao le nem escreve o efeito `Rat_recoil`; `stacks` entra por argumento.
---- O consumidor no jogo e `Rat_recoil.OnCalcAPCost`, como `cRoundDown(aim_cost * aim)`.
---------------------------------------------------------------------------------------------------
function Rat_GetRecoilAimCost(attacker, action, weapon, stacks)
    if not attacker or not IsKindOf(weapon, "Firearm") then
        return 0, 0
    end

    local option_mul = tonumber(CurrentModOptions["recoil_persistent_aim_effect"]) or 100
    local recoil_value = get_recoilP_value(attacker, action, weapon, false, stacks, false)
    local aim_mul = GetAimMul_Recoil_byCaliber(weapon)

    local aim_cost = ((-recoil_value * 0.7 * aim_mul / 30.00) * (option_mul or 100)) / 100.0
    local bolt_cost_adj = 0
    if rat_canBolt(weapon) then
        bolt_cost_adj = rat_get_manual_cyclingAP(attacker, weapon, true) * 0.6
    end

    aim_cost = Max(0, aim_cost - bolt_cost_adj)
    aim_cost = cRoundFlt(aim_cost, 0.5)
    aim_cost = Min(5, aim_cost)

    if HasPerk(attacker, "shooting_stance") then
        local stance_cost = (GetWeapon_StanceAP(attacker, weapon) + (Get_AimCost(attacker) * 2)) /
                                1000.00
        aim_cost = Min(stance_cost, aim_cost)
    end

    return aim_cost, recoil_value
end

function Unit:ApplyPersistantRecoilEffects(aim, action, weapon, attack_args)
    if aim > 2 then
        local effect_reset = self:GetStatusEffect("Rat_recoil")
        if effect_reset then
            self:RemoveStatusEffect("Rat_recoil", "all")

        end
    end

    local num_shots = attack_args.num_shots or 1

    self:AddStatusEffect("Rat_recoil", 1)
    local effect = self:GetStatusEffect("Rat_recoil")

    local stacks = effect.stacks
    local aim_cost, recoil_value = Rat_GetRecoilAimCost(self, action, weapon, stacks)

    effect:SetParameter("Recoil_value", recoil_value)
    effect:SetParameter("aim_cost", aim_cost)
    effect:SetParameter("movement", 0)
end

function GetWepRecoil(weapon, attacker, display)
    local mod = 1.00
    local metaText = {}
    local recoil_components = const.Combat.Recoil.Components

    -----
    mod = mod * ((weapon.wep_base_recoil_mul or 100) / 100.00)
    mod = mod * (weapon.class_base_recoil / 100.00)

    -----
    local weapon2 = false
    if attacker and not attacker.placeholder then
        local slot = attacker:GetEquippedWeaponSlot(weapon)
        local equipped_w = attacker:GetEquippedWeapons(slot)
        weapon2 = equipped_w and equipped_w[2] or false
    end

    -----
    local specialWeapons = {
        BrowningM2HMG = {text = "Stationary"},
        LionRoar = {mod = recoil_components.CompensatorMul, text = "Compensator"}
    }

    for weaponType, data in pairs(specialWeapons) do
        if IsKindOf(weapon, weaponType) then
            if data.mod then
                mod = mod * data.mod
            end
            if data.text then
                metaText[#metaText + 1] = data.text
            end
        end
    end

    ------
    local mech, meta_mech = GetMechanismRecoil(weapon)
    mod = mod * mech
    if meta_mech then
        metaText[#metaText + 1] = rT(meta_mech)
    end

    ------
    local components = {
        {
            name = "Vert_grip_recoil",
            mod = recoil_components.VerticalGripMul,
            text = rT(892823936544, "Vertical Grip"),
            condition = not weapon2
        }, {
            name = "tac_grip_recoil",
            mod = recoil_components.FoldableGripMul,
            text = rT(371872683581, "Foldable Grip"),
            condition = not weapon2
        }, {
            name = "no_stock",
            mod = function(w)
                return IsKindOfClasses(w, "SubmachineGun") and
                           recoil_components.NoStockMul.SubmachineGun or
                           recoil_components.NoStockMul.Other
            end,
            text = rT(115796595571, "(-) No Stock")
        }, {
            name = "compensator_effect",
            mod = recoil_components.CompensatorMul,
            text = rT(134618826773, "Compensator")
        }, {
            name = "recoil_booster_effect",
            mod = recoil_components.RecoilBoosterMul,
            text = rT(862593714174, "Recoil Booster")
        }, {
            name = "integr_muzzle_brake",
            mod = recoil_components.IntegratedMuzzleBrakeMul,
            text = rT(585361131592, "Integrated Muzzle Brake")
        }, {
            name = "compensator_effect_silencer",
            mod = recoil_components.SuppressorMul,
            text = rT(263781558966, "Suppressor")
        }, {
            name = "compensator_effect_ugly_silencer",
            mod = recoil_components.ImprovisedSuppressorMul,
            text = rT(696373868183, "Improvised Suppressor")
        }, {
            name = "longbarrel",
            mod = function(w)
                if IsKindOf(w, "Pistol") or w.pistol_swap then
                    return recoil_components.LongBarrelMul.Pistol
                elseif IsKindOf(w, "Revolver") then
                    return recoil_components.LongBarrelMul.Revolver
                elseif IsKindOf(w, "SubmachineGun") then
                    return recoil_components.LongBarrelMul.SubmachineGun
                end
                return recoil_components.LongBarrelMul.Other
            end,
            text = rT(894953874886, "Extended Barrel")
        }, {
            name = "shortbarrel",
            mod = function(w)
                if IsKindOf(w, "Pistol") or w.pistol_swap then
                    return recoil_components.ShortBarrelMul.Pistol
                elseif IsKindOf(w, "Revolver") then
                    return recoil_components.ShortBarrelMul.Revolver
                elseif IsKindOf(w, "SubmachineGun") then
                    return recoil_components.ShortBarrelMul.SubmachineGun
                end
                return recoil_components.ShortBarrelMul.Other
            end,
            text = rT(228113672715, "(-) Short Barrel")
        }, {
            name = "heavy_barrel_effect",
            mod = function(w)
                if IsKindOf(w, "Pistol") or w.pistol_swap then
                    return recoil_components.HeavyBarrelMul.Pistol
                elseif IsKindOf(w, "Revolver") then
                    return recoil_components.HeavyBarrelMul.Revolver
                elseif IsKindOf(w, "SubmachineGun") then
                    return recoil_components.HeavyBarrelMul.SubmachineGun
                end
                return recoil_components.HeavyBarrelMul.Other
            end,
            text = rT(649749565849, "Heavy Barrel")
        }, {
            name = "hipfire_light_barrel",
            mod = function(w)
                if IsKindOf(w, "Pistol") or w.pistol_swap then
                    return recoil_components.LightBarrelMul.Pistol
                elseif IsKindOf(w, "Revolver") then
                    return recoil_components.LightBarrelMul.Revolver
                elseif IsKindOf(w, "SubmachineGun") then
                    return recoil_components.LightBarrelMul.SubmachineGun
                end
                return recoil_components.LightBarrelMul.Other
            end,
            text = rT(826212377342, "(-) Light Barrel")
        }, {
            name = "stockheavy_effect_recoil",
            mod = recoil_components.HeavyStockMul,
            text = rT(456789123654, "Heavy Stock")
        }, {
            name = "stocklight_effect_recoil",
            mod = recoil_components.LightStockMul,
            text = rT(321654987321, "(-) Light Stock")
        }, {
            name = "FullChokeRecoil",
            mod = recoil_components.FullChokeRecoilMul,
            text = rT(984651387752, "(-) Full Choke")
        }
    }
    for _, comp in ipairs(components) do
        if weapon and weapon:HasComponent(comp.name) and (comp.condition == nil or comp.condition) then
            local component_mod = type(comp.mod) == "function" and comp.mod(weapon) or comp.mod
            mod = mod * component_mod
            metaText[#metaText + 1] = comp.text
        end
    end

    return mod, metaText
end

function GetCaliberStrRecoil(weapon, attacker, num_shots)
    local weapon1 = weapon
    local metaText = {}

    local str = attacker.Strength

    local scaleFactor = 0

    local breakpoint, modifier = Recoil_StrBreakpoint(weapon1)

    if not breakpoint or breakpoint == 0 then
        return 1
    end

    local adjust = 0.4
    local adjusted_breakpoint = breakpoint * adjust
    local adjusted_str = str * adjust

    if str < breakpoint then
        scaleFactor = 20.0 +
                          ((100.0 - 20.0) * (adjusted_breakpoint - adjusted_str) /
                              adjusted_breakpoint)
        metaText[#metaText + 1] = rT(285153762692, "(-) Low Strength")
    else
        scaleFactor = 20.0 -
                          (20.0 * (adjusted_str - adjusted_breakpoint) /
                              (100.0 - adjusted_breakpoint))

        metaText[#metaText + 1] = rT(988872717528, "Strength")

    end

    local modified_breakpoint = breakpoint * modifier
    local str_mod_f = ((scaleFactor * 2.5 * adjust) + 35.0 + modified_breakpoint) / 100

    str_mod_f = str_mod_f ^ 1.9

    if num_shots and num_shots > 1 and weapon.tracer == 1 then
        str_mod_f = str_mod_f * const.Combat.Recoil.Other.Tracer
        metaText[#metaText + 1] = rT(669471256347, "Tracer Rounds")
    end

    if weapon.ArmorPir == 1 then
        str_mod_f = str_mod_f * const.Combat.Recoil.Other.AP
        metaText[#metaText + 1] = rT(281796668818, "(-) AP Rounds")
    end

    return str_mod_f, metaText
end

function GetRecoilOther(weapon, attacker, action)

    local metaText = {}
    local mod = 1.00
    if action and action.id ~= "RunAndGun" then
        if attacker.stance then
            if attacker.stance == "Prone" then
                mod = mod * const.Combat.Recoil.Other.Prone
                metaText[#metaText + 1] = rT(294661659116, "Prone")
                if weapon and weapon:HasComponent("AccuracyBonusProne") then
                    mod = mod * const.Combat.Recoil.Components.BipodMul
                    metaText[#metaText + 1] = rT(523692869416, "Bipod")
                end
            elseif attacker.stance == "Crouch" then
                mod = mod * const.Combat.Recoil.Other.Crouch
                metaText[#metaText + 1] = rT(663793494488, "Crouching")
            end
        end
    end

    local marks = attacker.Marksmanship
    local min_reduction = const.Combat.Recoil.MarksmanshipMaxReduction
    local min_stat = const.Combat.Recoil.MarksmanshipMinStat

    if marks > min_stat then
        local marks_scaling = min_reduction + (1 - min_reduction) *
                                  (1 - (marks - min_stat * 1.00) / (100 - min_stat) * 1.00)
        mod = mod * marks_scaling

        if marks == 100 then
            metaText[#metaText + 1] = rT(869135768177, "Perfect Technique")
        elseif marks >= 85 then
            metaText[#metaText + 1] = rT(495676736357, "High Marksmanship")
        else
            metaText[#metaText + 1] = rT(889423438892, "Marksmanship")
        end
    else
        metaText[#metaText + 1] = rT(946448112577, "(-) Low Marksmanship")
    end

    -----------------perks
    if not attacker.placeholder then
        if attacker:HasStatusEffect("TakeAim") then
            mod = mod * const.Combat.Recoil.Perks.TakeAimMul
            metaText[#metaText + 1] = rT(712682745289, "Perk: Recoil Management")
        end

        if action and
            not (action.id == "SingleShot" or action.id == "Buckshot" or action.id == "Pindown" or
                action.id == "MobileShot") and attacker:HasStatusEffect("AutoWeapons") then
            mod = mod * const.Combat.Recoil.Perks.AutoWeaponsMul
            metaText[#metaText + 1] = rT(764956297274, "Perk: Auto Weapons")

        end

        if action and
            (action.id == "BurstFire" or action.id == "RunAndGun" or action.id == "RecklessAssault") then

            if weapon.burst_recoil_delta and weapon.burst_recoil_delta ~= 100 then
                local burst_delta = weapon.burst_recoil_delta / 100.0
                mod = mod * burst_delta
            end

            if weapon.burst_selective or weapon:HasComponent("Reduce_recoil_burst_delta") then
                local name = type(weapon.DisplayName) == "table" and weapon.DisplayName[2] or false
                local meta_name = name and name .. " Selective Burst" or "Selective Burst"
                metaText[#metaText + 1] = rT(false, meta_name)
            end
        end

        if action and (action.id == "AutoFire" or action.id == "BurstFire") then
            if weapon and weapon:HasComponent("recoil_bump") then
                mod = mod * const.Combat.Recoil.Components.RecoilBumpMul
                metaText[#metaText + 1] = rT(749694622664, "(-) Bump Stock")
            end
        end

        if action and (action.id == "AutoFire") then
            if weapon.auto_recoil_delta and weapon.auto_recoil_delta ~= 100 then
                local auto_delta = weapon.auto_recoil_delta / 100.0
                mod = mod * auto_delta
            end
        end

        if action and (action.id == "MGBurstFire" or action.id == "GrizzlyPerk") then
            if weapon.long_recoil_delta and weapon.long_recoil_delta ~= 100 then
                local long_delta = weapon.long_recoil_delta / 100.0
                mod = mod * long_delta
            end
        end
    end

    return mod, metaText
end

function GetMechanismRecoil(weapon)
    local mechs = {
        ["Blowback"] = 104,
        ["Striker_Fired"] = 105,
        ["Short_Recoil"] = 106,
        ["Gas_Operated"] = 94,
        ["Recoil_Operated"] = 95,
        ["Roller_Delayed"] = 96
        -- ["Break_Action"] = 96,
        -- ["Pump_Action"] = 97,
        -- ["Bolt_Action"] = 98,
        -- ["Lever_Action"] = 99,
        -- ["Single_Shot"] = 105,
        -- ["Revolver"] = 106,
    }

    local metaTextMap = {
        ["Striker_Fired"] = rT(132322127855, "(-) Striker Fired"),
        ["Short_Recoil"] = rT(758234761279, "(-) Short Recoil"),
        ["Gas_Operated"] = rT(226357388522, "Gas Operated"),
        ["Recoil_Operated"] = rT(756261568764, "Recoil Operated"),
        ["Roller_Delayed"] = rT(778967917912, "Roller Delayed"),
        ["Blowback"] = rT(642385744896, "(-) Blowback")
        -- ["Revolver"] = "Revolver",
        -- ["Single_Shot"] = "Single Shot",
        -- ["Break_Action"] = "Break Action",
        -- ["Pump_Action"] = "Pump Action",
        -- ["Bolt_Action"] = "Bolt Action",
        -- ["Lever_Action"] = "Lever Action",
    }

    local mod = mechs[weapon.recoil_mechanism]

    if mod then
        mod = mod / 100.00
    else
        mod = 1.00
    end

    local metaText = metaTextMap[weapon.recoil_mechanism] or false

    return mod, metaText
end

function Recoil_StrBreakpoint(weapon1)

    local category = nil
    local caliberData = nil

    for cat, calibers in pairs(ratG_recoilData) do
        if calibers[weapon1.Caliber] then
            category = cat
            caliberData = calibers[weapon1.Caliber]
            break
        end
    end

    if caliberData then
        local str = caliberData.str
        local modifier = ratG_recoilData[category].modifier
        return str, modifier
    else
        return 0, 0
    end
end

function GetAimMul_Recoil_byCaliber(weapon1)
    local category = nil
    local caliberData = nil

    for cat, calibers in pairs(ratG_recoilData) do
        if calibers[weapon1.Caliber] then
            category = cat
            caliberData = calibers[weapon1.Caliber]
            break
        end
    end

    if caliberData then

        local modifier = ratG_recoilData[category].aim_mul
        return modifier
    else
        return 1.00
    end
end

function Rat_GetROF(weapon, action_id)
    local num_shots = 3
    if action_id == "MGBurstFire" then
        num_shots = weapon.long_shots
    else
        action_id = "BurstFire"
        num_shots = weapon.burst_shots
    end

    local cost = (weapon.ShootAP + rat_getDeltaAP(false, weapon, action_id)) / const.Scale.AP

    local shotsBoost = GetComponentEffectValue(weapon, "ExtraBurstShots", action_id)

    if shotsBoost then
        num_shots = num_shots + shotsBoost
    end

    local ROF = num_shots * 1.00 / cost

    ROF = ROF + 0.25
    ROF = (ROF - 1.00) * 0.2 + 1.00
    return ROF
end

local stacks_multiplier = const.Combat.Recoil.StacksMultiplier
local flat_penalty_base = const.Combat.Recoil.BasePenalty
local param_base = const.Combat.Recoil.MaxPenalty

---------------------------------------------------------------------------------------------------
---- Produto multiplicativo do recoil: arma x componentes x mecanismo x postura x
---- perks x calibre/Forca. E a parte que `get_recoil` e `get_recoilP_value` tinham
---- IDENTICA, e que o modelo de cone angular precisa como terceiro consumidor.
----
---- Extraida em vez de copiada: o mod ja tem um caso de constante duplicada com um
---- comentario de "manter em sincronia" (RECOIL_STACKS_PCT), e uma terceira copia
---- desta cadeia divergiria em silencio na primeira vez que um destes numeros mudasse.
----
---- Retorna `mod` na mesma escala de antes (comeca em 100 e e multiplicado por
---- fatores em torno de 1.0) e a lista de metaText acumulada.
---------------------------------------------------------------------------------------------------
function Rat_GetRecoilBaseMod(attacker, action, weapon, num_shots)
    local mod = 100
    local metaText = {}
    local display = false

    local w1, weapon2 = attacker:GetActiveWeapons()
    local dual = action and action.id == "DualShot"

    local weapon_recoil_mod, metaText_wep = GetWepRecoil(weapon, attacker, display)
    if dual then
        local weapon_recoil_mod2 = GetWepRecoil(weapon2, attacker, display)
        weapon_recoil_mod = (weapon_recoil_mod + weapon_recoil_mod2) / 2
        metaText_wep = {rT(461685692199, "Average Recoil: Two Weapons")}
    end
    mod = mod * weapon_recoil_mod
    for i, text in ipairs(metaText_wep) do
        table.insert(metaText, text)
    end

    -----------------------Stance, perks
    local other, otherMeta = GetRecoilOther(weapon, attacker, action)
    mod = mod * other
    for i, text in ipairs(otherMeta) do
        table.insert(metaText, text)
    end

    -----------------str/caliber
    local str_caliber_mod, meta_text_caliber = GetCaliberStrRecoil(weapon, attacker, num_shots)
    if dual then
        local str_caliber_mod2 = GetCaliberStrRecoil(weapon2, attacker, num_shots)
        meta_text_caliber = {}
        str_caliber_mod = (str_caliber_mod + str_caliber_mod2) / 2
    end
    mod = mod * str_caliber_mod
    for i, text in ipairs(meta_text_caliber) do
        table.insert(metaText, text)
    end

    return mod, metaText
end

---------------------------------------------------------------------------------------------------
---- Recoil no modelo angular: taxa de ABERTURA do cone por tiro.
----
---- No modelo somado o recoil vira `cth_loss_per_shot` e e subtraido linearmente
---- (SOURCE_FirearmGetAttackResults.lua:260). Aqui ele faz o que fisicamente faz --
---- abre o cone -- e a perda de CTH passa a ser consequencia da geometria.
----
---- IMPORTANTE: isto NAO substitui a dependencia de distancia por uma taxa fixa.
---- O recoil antigo nunca foi flat: `get_recoil` tem rampa linear ate
---- MaxDistforPenalty (36 tiles), medida em -13 a 4 tiles e -76 a 28 tiles. No
---- modelo angular a distancia continua mandando, so que pela via correta: um cone
---- mais aberto custa pouco de perto, onde o alvo ja e maior que ele, e muito de
---- longe, onde a silhueta e que e a restricao. A rampa deixa de precisar ser
---- tabelada porque ela emerge de theta cair com 1/d.
----
---- Toda a cadeia relativa ja tunada sobrevive: arma, componentes, mecanismo,
---- calibre, breakpoint de Forca, ROF, postura e perks continuam significando a
---- mesma coisa, so que definindo quao RAPIDO o cone abre em vez de quantos pontos
---- somem. Medido: mod_total vai de ~130 (MP5) a ~230 (AK47, MG42).
----
---- Retorna a taxa em % (122 = cone 1,22x por tiro).
---------------------------------------------------------------------------------------------------
function Rat_GetRecoilConeGrowth(attacker, action, weapon, num_shots, test)
    local a = const.Combat.Aperture
    if not attacker or not IsKindOf(weapon, "Firearm") then
        return 100
    end

    local mod = Rat_GetRecoilBaseMod(attacker, action, weapon, num_shots)

    ---- cadencia: mais tiros no mesmo tempo, menos tempo para reassentar a arma
    if not IsKindOf(weapon, "Shotgun") then
        local action_id_rof = (action and action.id) or ""
        if action_id_rof == "GrizzlyPerk" then
            action_id_rof = "MGBurstFire"
        end
        local ROF = Rat_GetROF(weapon, action_id_rof)
        if ROF and ROF > 1 then
            mod = mod * ROF
        end
    end

    ---- MG montada absorve recoil; MG na mao, nao
    local aid = action and action.id
    if aid == "MGBurstFire" then
        if test or (g_Overwatch[attacker] and g_Overwatch[attacker].permanent) then
            mod = mod * const.Combat.Recoil.MGSetupMul
        end
    elseif aid == "GrizzlyPerk" then
        mod = mod * const.Combat.Recoil.MGSetupMul
    end

    local excess = MulDivRound(a.RecoilGrowthBase, cRound(mod), 100)
    excess = Clamp(excess, 0, a.RecoilGrowthMax)

    ---- o dial global de recoil do jogador continua valendo
    excess = MulDivRound(excess, const.Combat.R_Recoil or 100, 100)

    return 100 + excess
end

function get_recoil(attacker, target, target_pos, action, weapon, aim, num_shots, stacks, test,
                    test_distance, unit_command, populate_recoil, attacker_pos)

    if not attacker or not target then
        return 0
    end

    if not IsKindOf(weapon, "Firearm") then
        return 0
    end

    local extra = 0
    ----------------------------------------------------------------------------------------------------------mods
    local target_pos = target_pos or IsKindOf(target, "Unit") and target:GetPos()

    local attacker_pos = attacker_pos or attacker:GetPos()

    local w1, weapon2 = attacker:GetActiveWeapons()

    local param = param_base
    local flat_penalty = flat_penalty_base

    local mod, metaText = Rat_GetRecoilBaseMod(attacker, action, weapon, num_shots)

    ----------------------------------------------------------------------------------------------------------mods

    local penalty
    local held_mg

    local mg_setup_mul = const.Combat.Recoil.MGSetupMul

    local ROF

    if not IsKindOf(weapon, "Shotgun") then
        local action_id_rof = action.id or ""
        if action_id_rof == "GrizzlyPerk" then
            action_id_rof = "MGBurstFire"
        end
        ROF = Rat_GetROF(weapon, action_id_rof)
    end

    if ROF and ROF > 1 then
        mod = mod * ROF
        metaText[#metaText + 1] = rT(851619126995, "(-) High Rate of Fire")
    end

    if action.id == "MGBurstFire" then
        if test or g_Overwatch[attacker] and g_Overwatch[attacker].permanent then
            mod = mod * mg_setup_mul
            metaText[#metaText + 1] = rT(665399583815, "MG Setup")
        else
            held_mg = true
        end
    elseif action.id == "GrizzlyPerk" then
        mod = mod * mg_setup_mul
        held_mg = false
        metaText[#metaText + 1] = rT(228847175552, "Off the Hip") -- GrizzlyPerk.DisplayName
    end

    local action_command = attacker.action_command or ''

    if action_command == "RunAndGun" or action_command == "RecklessAssault" then
        param = param + const.Combat.Recoil.RunAndGunExtraPenalty
    end

    local penalty = 0
    local pb_dist = const.Weapons.PointBlankRange * const.SlabSizeX

    penalty = MulDivRound(penalty, mod, 100)
    local dist
    if test then
        dist = test_distance
    else
        dist = attacker_pos:Dist(target_pos)
    end

    local max_dist = const.Combat.Recoil.MaxDistforPenalty * const.SlabSizeX
    local max_penalty = param + extra

    dist = Min(dist, max_dist)
    penalty = penalty + (Min(-1, MulDivRound(dist, max_penalty - penalty, max_dist)))

    penalty = MulDivRound(penalty, mod, 100)

    if (action.id == "MGBurstFire" or action.id == "GrizzlyPerk") then

        local str = attacker.Strength
        local mg_mod = 120
        local hip_mod = 1.0

        if held_mg then
            metaText[#metaText + 1] = rT(594122678151, "(-) Held MG")
            hip_mod = (GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, false, 1) * 0.5 *
                          (weapon.weigth_held_mul / 100.0))
            mg_mod = 140 * hip_mod
        end

        if str > 49 then
            local str_mod_mg = 0.8 + 0.2 * (1 - (str - 50 * 1.00) / 50 * 1.00)
            mg_mod = mg_mod * str_mod_mg
        end
        penalty = MulDivRound(penalty, mg_mod, 100)
    end

    local side = attacker and attacker.team and attacker.team.side or ''
    if not (side == 'player1' or side == 'player2') and not test then
        penalty = AIpenal_reduc(attacker, penalty, "Recoil", stacks and true or false)
    end

    penalty = penalty + flat_penalty

    if penalty == 0 then
        return 0
    end

    for i, text in ipairs(metaText) do
        metaText[i] = processMetatext(text[1], text[2], populate_recoil)
    end

    if stacks then
        penalty = cRound(penalty * stacks_multiplier * (stacks or 1))

        return MulDivRound(penalty, const.Combat.R_RecoilP, 100), #metaText ~= 0 and metaText
    end

    penalty = cRound(penalty * 0.5)
    return MulDivRound(penalty, const.Combat.R_Recoil, 100), #metaText ~= 0 and metaText
end

function get_recoilP_value(attacker, action, weapon1, aim, stacks, unit_command)

    if not attacker then
        return 0
    end
    if not IsKindOf(weapon1, "Firearm") then
        return 0
    end

    local extra = 0
    ----------------------------------------------------------------------------------------------------------mods
    local w1, weapon2 = attacker:GetActiveWeapons()

    local weapon = weapon1

    local param = param_base
    local flat_penalty = flat_penalty_base

    ---- mesma cadeia de get_recoil, so que com num_shots = false
    local mod, metaText = Rat_GetRecoilBaseMod(attacker, action, weapon, false)

    ----------------------------------------------------------------------------------------------------------mods

    local penalty = param

    penalty = MulDivRound(penalty, mod, 100)

    local side = attacker and attacker.team and attacker.team.side or ''

    if not (side == 'player1' or side == 'player2') then
        penalty = AIpenal_reduc(attacker, penalty, "Recoil", true)
    end

    penalty = penalty + flat_penalty

    if penalty == 0 then
        return 0
    end

    penalty = penalty * stacks_multiplier * (stacks or 1)

    for i, text in ipairs(metaText) do
        metaText[i] = processMetatext(text[1], text[2], false)
    end

    return MulDivRound(penalty, const.Combat.R_RecoilP, 100), #metaText ~= 0 and metaText

end

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [892823936544] = "Vertical Grip",
    [371872683581] = "Foldable Grip",
    [115796595571] = "(-) No Stock",
    [395163141224] = "Extended Handguard",
    [963983387333] = "(-) Short Handguard",
    [134618826773] = "Compensator",
    [862593714174] = "Recoil Booster",
    [585361131592] = "Integrated Muzzle Brake",
    [263781558966] = "Suppressor",
    [696373868183] = "Improvised Suppressor",
    [894953874886] = "Extended Barrel",
    [228113672715] = "(-) Short Barrel",
    [826212377342] = "(-) Light Barrel",
    [649749565849] = "Heavy Barrel",
    [779417232291] = "Heavy Stock",
    [662981363158] = "(-) Light Stock",
    [285153762692] = "(-) Low Strength",
    [988872717528] = "Strength",
    [949639567956] = "Perfect Technique",
    [824796784687] = "High Marksmanship",
    [294753784373] = "Marksmanship",
    [286526555251] = "(-) Low Marksmanship",
    [669471256347] = "Tracer Rounds",
    [281796668818] = "(-) AP Rounds",
    [294661659116] = "Prone",
    [523692869416] = "Bipod",
    [663793494488] = "Crouching",
    [869135768177] = "Perfect Technique",
    [495676736357] = "High Marksmanship",
    [889423438892] = "Marksmanship",
    [946448112577] = "(-) Low Marksmanship",
    [712682745289] = "Perk: Recoil Management",
    [764956297274] = "Perk: Auto Weapons",
    [749694622664] = "(-) Bump Stock",
    [642385744896] = "(-) Blowback",
    [132322127855] = "(-) Striker Fired",
    [758234761279] = "(-) Short Recoil",
    [226357388522] = "Gas Operated",
    [756261568764] = "Recoil Operated",
    [778967917912] = "Roller Delayed",
    [461685692199] = "Average Recoil: Two Weapons",
    [851619126995] = "(-) High Rate of Fire",
    [665399583815] = "MG Setup",
    [228847175552] = "Off the Hip",
    [594122678151] = "(-) Held MG",
    [219911149892] = "Point-Blank Range",
    [574718433471] = "Recoil",
    [862325237281] = "Average Recoil: Two Weapons",
    [984651387752] = "(-) Full Choke"
}

ratG_T_table['FUNCTIONS_recoil.lua'] = t_id_table

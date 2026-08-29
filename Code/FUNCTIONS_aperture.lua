---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- funcoes puras
----
---- Nenhuma funcao aqui le ou escreve estado de jogo, rola dado ou aplica efeito.
---- Sao consultaveis pela UI (crosshair, em previsao) e pela IA
---- (AIPrecalcConeTargetZones avalia muitas posicoes por turno) sem efeito colateral
---- e sem consumir random sincronizado -- o mesmo motivo pelo qual
---- Rat_GetRecoilAimCost foi extraida de ApplyPersistantRecoilEffects.
----
---- Tudo em aritmetica INTEIRA. Ver o cabecalho de __ApertureParams.lua.
---------------------------------------------------------------------------------------------------

local A --- resolvido em tempo de chamada: __ApertureParams pode carregar depois deste arquivo
local function P()
    A = A or const.Combat.Aperture
    return A
end

---------------------------------------------------------------------------------------------------
---- Aritmetica
---------------------------------------------------------------------------------------------------

---- Raiz quadrada inteira (Newton). Deterministica, sem float -- `sqrt` do engine
---- devolve float e nao pode entrar no caminho que alimenta NetUpdateHash.
function Rat_ISqrt(n)
    if n <= 0 then
        return 0
    end
    local x = n
    local y = (x + 1) / 2
    while y < x do
        x = y
        y = (x + n / x) / 2
    end
    return x
end

---- Meia-largura aparente do alvo, em minutos de angulo.
---- half_cm em centimetros; dist em unidades do engine (guic = 10 = 1 cm).
---- 1 radiano = 3438 minutos; com a conversao de cm embutida vira 34380.
function Rat_ThetaTarget(dist, half_cm)
    if not dist or dist < 1 then
        return 100000 --- encostado: alvo ocupa tudo
    end
    return Max(1, MulDivRound(half_cm, 34380, dist))
end

---------------------------------------------------------------------------------------------------
---- Silhueta do alvo
---------------------------------------------------------------------------------------------------

---- Raio equivalente do alvo em centimetros.
----   target        -- Unit (ou nil, cai em Standing)
----   body_part_def -- preset TargetBodyPart, ou string, ou nil (Torso)
----   exposed_pct   -- 0..100, fracao da silhueta NAO ocluida por cobertura.
----                    Entra como raiz, porque a fracao e de AREA e theta e um raio.
function Rat_TargetSilhouette(target, body_part_def, exposed_pct, stance_override)
    local a = P()

    local part_id = body_part_def
    if type(part_id) == "table" then
        part_id = part_id.id
    end

    local r
    local absolute = part_id and a.BodyPartAbsolute[part_id]
    if absolute then
        --- cabeca/pescoco: medidos constantes nas tres posturas
        r = absolute
    else
        local stance = stance_override
        if not stance and IsKindOf(target, "Unit") then
            stance = target:GetHitStance()
        end
        r = a.Silhouette[stance] or a.Silhouette.Standing

        local part = part_id and a.BodyPart[part_id]
        if part then
            r = MulDivRound(r, part, 100)
        end
    end

    if exposed_pct and exposed_pct < 100 then
        exposed_pct = Max(0, exposed_pct)
        --- raiz de area -> raio: sqrt(pct/100) em % = sqrt(pct * 100)
        r = MulDivRound(r, Rat_ISqrt(exposed_pct * 100), 100)
    end

    return Max(1, r)
end

---------------------------------------------------------------------------------------------------
---- Componentes da abertura
---------------------------------------------------------------------------------------------------

---- Marksmanship escala o cone inteiro. x2.60 (Marks 0) .. x1.00 (Marks 100).
function Rat_ApertureSkillMul(attacker, weapon)
    local a = P()
    local skill_name = (weapon and weapon.base_skill) or "Marksmanship"
    local skill = (attacker and attacker[skill_name]) or 50
    skill = Clamp(skill, 0, 100)
    return a.SkillMax - MulDivRound(a.SkillMax - a.SkillMin, skill, 100)
end

---- Quanto CADA nivel de mira fecha o cone, em % (80 = fecha para 80% do anterior).
---- AimAccuracy define o teto; Hand-Eye Coordination define quanto disso o atirador
---- realmente cobra -- e a "Aiming Rework" do mod, expressa no angulo.
function Rat_ApertureAimDecay(weapon, attacker)
    local a = P()

    local acc = (weapon and weapon.AimAccuracy) or 3
    if IsKindOfClasses(weapon, "Pistol", "Revolver") then
        acc = MulDivRound(acc, 50, 100)
    end

    local decay = 100 - (a.DecayBase + a.DecayScale * acc)
    decay = Max(a.DecayMinPct, decay)

    --- Hand-Eye Coordination (Dex+Marks): abaixo de 100 o fechamento e parcial.
    local he = 100
    if attacker and not attacker.placeholder and IsKindOf(weapon, "Firearm") then
        he = Clamp(rGetHandEyeCoordination(attacker) or 100, 10, 100)
    end
    --- decay_efetivo = 100 - (100 - decay) * he/100
    decay = 100 - MulDivRound(100 - decay, he, 100)

    return Clamp(decay, a.DecayMinPct, 99)
end

---- Multiplicador do degrau de hipfire/snapshot desta arma (propriedade nova).
function Rat_ApertureSnapMul(weapon)
    local v = weapon and weapon.rat_aperture_snap or 0
    if v and v > 0 then
        return v
    end
    return Rat_SeedSnapFromOverwatch(weapon)
end

---- Semente: converte OverwatchAngle em estimativa inicial de manejo.
---- NAO substitui o OverwatchAngle -- so da um ponto de partida para armas que
---- ainda nao declararam `rat_aperture_snap`. Ver __ApertureParams.lua.
function Rat_SeedSnapFromOverwatch(weapon)
    local a = P()
    local ow = weapon and weapon.OverwatchAngle
    if not ow then
        return 100
    end
    local span = Max(1, a.SeedOWMax - a.SeedOWMin)
    local h = Clamp(MulDivRound(ow - a.SeedOWMin, 100, span), 0, 100)
    return a.SeedSnapHeavy - MulDivRound(a.SeedSnapHeavy - a.SeedSnapHandy, h, 100)
end

---- Piso mecanico: o cone mais fechado que a arma alcanca, derivado do WeaponRange.
---- Scopes rebaixam este piso (e a conversao natural do RangeIncrease a ser removido).
function Rat_ApertureFloor(weapon)
    local a = P()
    local range = (weapon and weapon.WeaponRange) or 20
    local floor_dist = range * const.SlabSizeX
    local theta = Rat_ThetaTarget(floor_dist, a.Silhouette.Standing)
    return Max(1, MulDivRound(theta, a.FloorPct, 100))
end

---------------------------------------------------------------------------------------------------
---- Abertura (sigma), em minutos de angulo
---------------------------------------------------------------------------------------------------

---- Retorna sigma e a lista de contribuicoes (para a UI mostrar em minutos de cone,
---- no lugar da lista aditiva de pontos percentuais que o modelo antigo exibia).
function Rat_GetAperture(weapon, attacker, action, aim, opportunity_attack)
    local a = P()
    aim = aim or 0

    local meta = {}
    local s = a.Base

    --- 1. precisao intrinseca da arma
    local base_mul = (weapon and weapon.rat_aperture_base_mul) or 100
    if base_mul ~= 100 then
        s = MulDivRound(s, base_mul, 100)
    end

    --- 2. Marksmanship escala o cone inteiro
    local skill_mul = Rat_ApertureSkillMul(attacker, weapon)
    s = MulDivRound(s, skill_mul, 100)

    --- 3. cada nivel de mira FECHA o cone
    local decay = Rat_ApertureAimDecay(weapon, attacker)
    for _ = 1, aim do
        s = MulDivRound(s, decay, 100)
    end

    --- 4. degrau de "arma no ombro" -- hipfire / snapshot.
    ---    O produto de GetWeaponHipfireOrSnapshotMul e uma escala RELATIVA de
    ---    penalidade, nao um multiplicador de cone: escala o EXCESSO do alargamento,
    ---    nunca o cone inteiro. Ver o bloco AimStep em __ApertureParams.lua.
    local hipsnap, step = 100, 100
    if aim <= a.AimStepMaxLevel then
        if weapon and GetWeaponHipfireOrSnapshotMul then
            local m = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, true, aim)
            hipsnap = Clamp(cRound((m or 1.0) * 100), 25, 400)
        end

        local excess = (a.AimStep[aim] or 100) - 100
        if excess > 0 then
            excess = MulDivRound(excess, hipsnap, 100)
            excess = MulDivRound(excess, Rat_ApertureSnapMul(weapon), 100)
            step = 100 + excess
            s = MulDivRound(s, step, 100)
            meta[#meta + 1] = (aim == 0) and T(588769789298, "Hipfire") or
                                  T(335346378867, "Snapshot")
        end
    end

    --- 5. piso mecanico do WeaponRange
    local floor = Rat_ApertureFloor(weapon)
    if s < floor then
        s = floor
        meta[#meta + 1] = T(353401714895, "Range")
    end

    return Max(1, s), meta, {
        base = a.Base,
        base_mul = base_mul,
        hipsnap = hipsnap,
        skill = skill_mul,
        decay = decay,
        step = step,
        floor = floor
    }
end

---------------------------------------------------------------------------------------------------
---- Abertura -> CTH
---------------------------------------------------------------------------------------------------

---- P = 1 - exp(-k^2 / 2), k = theta/sigma. LUT interpolada, em porcento.
function Rat_RayleighCTH(theta, sigma)
    local a = P()
    if not sigma or sigma < 1 then
        return 100
    end

    local k1000 = MulDivRound(theta, 1000, sigma)
    local step = a.RayleighStep
    local idx = k1000 / step
    local last = #a.Rayleigh

    if idx >= last then
        return 100
    end

    local lo = a.Rayleigh[idx]
    local hi = a.Rayleigh[idx + 1]
    local frac = k1000 - idx * step
    local permil = lo + MulDivRound(hi - lo, frac, step)

    return MulDivRound(permil, 100, 1000)
end

---------------------------------------------------------------------------------------------------
---- CTH geometrico completo
---------------------------------------------------------------------------------------------------

---- Retorna cth (0..100), sigma, theta e metaText.
---- `exposed_pct` (0..100) e o gancho para o modelo de cobertura por silhueta
---- ocluida; enquanto nao existir, passa nil e a silhueta vem inteira.
function Rat_AngularCTH(attacker, target, body_part_def, action, weapon, aim, opportunity_attack,
                        attacker_pos, target_pos, exposed_pct)
    local a = P()

    attacker_pos = attacker_pos or (attacker and attacker:GetPos())
    target_pos = target_pos or (IsPoint(target) and target) or (IsValid(target) and target:GetPos())
    if not attacker_pos or not target_pos then
        return 0
    end

    local dist = attacker_pos:Dist(target_pos)

    local sigma, meta, parts = Rat_GetAperture(weapon, attacker, action, aim, opportunity_attack)
    local half_cm = Rat_TargetSilhouette(target, body_part_def, exposed_pct)
    local theta = Rat_ThetaTarget(dist, half_cm)

    local cth = Rat_RayleighCTH(theta, sigma)
    cth = Clamp(cth, a.MinCTH, a.MaxCTH)

    return cth, sigma, theta, meta, parts, dist, half_cm
end

---------------------------------------------------------------------------------------------------
---- Guarda
----
---- Chamada no topo de cada modifier que o modelo angular SUBSTITUI (os baldes
---- "multiplicam o cone" e "alteram a silhueta"). Com Enabled = false devolve
---- false e o mod se comporta exatamente como antes.
---------------------------------------------------------------------------------------------------

function Rat_AngularActive(weapon, action, attacker)
    local a = P()
    if not a or not a.Enabled then
        return false
    end
    if not IsKindOf(weapon, "Firearm") then
        return false
    end
    if action and action.ActionType == "Melee Attack" then
        return false
    end
    return true
end

---------------------------------------------------------------------------------------------------
---- Semeadura das propriedades novas
----
---- Roda em DataLoaded, DEPOIS do PATCH_GBO_weapons: percorre todas as classes de
---- Firearm e preenche `rat_aperture_snap` para quem nao declarou o seu. Cobre as
---- armas adicionadas por Tons of Guns / Zulib sem precisar editar tabela nenhuma.
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---- Ferramentas de comparacao (console)
----
---- Rat_SetAngularCTH(true/false) -- liga/desliga o modelo em runtime
---- Rat_CompareCTH(atacante, alvo) -- lado a lado, modelo somado x modelo angular
---------------------------------------------------------------------------------------------------

function Rat_SetAngularCTH(on)
    P().Enabled = not not on
    for _, u in ipairs(g_Units or empty_table) do
        u.combat_cache = nil
    end
    return "CTH angular: " .. (P().Enabled and "LIGADO" or "desligado")
end

function Rat_CompareCTH(attacker, target, max_aim)
    attacker = attacker or SelectedObj
    if not attacker then
        return "sem atacante"
    end
    if not target then
        for _, o in ipairs(g_Units or empty_table) do
            if o ~= attacker and not o:IsDead() and attacker:IsOnEnemySide(o) then
                target = o
                break
            end
        end
    end
    if not target then
        return "sem alvo"
    end

    local weapon = attacker:GetActiveWeapons()
    local action = attacker:GetDefaultAttackAction("ranged")
    if not IsKindOf(weapon, "Firearm") or not action then
        return "sem arma de fogo"
    end

    local was = P().Enabled
    local lines = {}
    local dist = attacker:GetDist(target)
    lines[#lines + 1] = string.format("%s (%s, Marks %d) -> %s [%s] a %.1f tiles",
                                      tostring(attacker.session_id), tostring(weapon.class),
                                      attacker.Marksmanship, tostring(target.session_id),
                                      tostring(target:GetHitStance()), dist / const.SlabSizeX)
    lines[#lines + 1] = "aim | somado | angular | sigma  theta"

    local args_base = {target_spot_group = "Torso", prediction = true,
                       step_pos = attacker:GetPos(), target_pos = target:GetPos()}

    for aim = 0, (max_aim or 4) do
        args_base.aim = aim

        P().Enabled = false
        local old = attacker:CalcChanceToHit(target, action, args_base, "chance_only")
        P().Enabled = true
        local new = attacker:CalcChanceToHit(target, action, args_base, "chance_only")

        local _, sigma, theta = Rat_AngularCTH(attacker, target, nil, action, weapon, aim, false,
                                               attacker:GetPos(), target:GetPos())
        lines[#lines + 1] = string.format(" %d  |  %3d   |   %3d   | %5d  %5d", aim, old or -1,
                                          new or -1, sigma, theta)
    end

    P().Enabled = was
    return table.concat(lines, "\n")
end

function Rat_SeedApertureProperties()
    local n = 0
    for _, classdef in pairs(g_Classes) do
        if type(classdef) == "table" and rawget(classdef, "OverwatchAngle") and
            IsKindOf(classdef, "Firearm") then
            if (rawget(classdef, "rat_aperture_snap") or 0) == 0 then
                classdef.rat_aperture_snap = Rat_SeedSnapFromOverwatch(classdef)
                n = n + 1
            end
        end
    end
    return n
end

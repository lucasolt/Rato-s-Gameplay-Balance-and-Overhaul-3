---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- visualizadores
----
---- Desenham no mundo o que o modelo esta "vendo", para conferir de olho o que as
---- tabelas dizem. Somente leitura: nao rolam dado, nao mudam estado, nao consomem
---- random sincronizado.
----
---- Uso tipico no console (F2 / debug):
----     Rat_DbgCover()        -- raios de cobertura no alvo sob o cursor
----     Rat_DbgCone()         -- cone de abertura contra a silhueta, por nivel de mira
----     Rat_DbgAll()          -- os dois
----     Rat_DbgClear()        -- limpa
----
---- Todos aceitam (target, attacker); sem argumentos usam a unidade selecionada como
---- atirador e o inimigo mais proximo com linha de tiro como alvo.
---------------------------------------------------------------------------------------------------

local clrHit = const.clrGreen
local clrMiss = const.clrRed
local clrCone = const.clrYellow or RGB(255, 220, 0)
local clrSilh = const.clrCyan
local clrAxis = const.clrWhite

---- 1 radiano = 3438 minutos de angulo. Raio que um cone de `minutes` cobre a `dist`.
local function cone_radius(dist, minutes)
    return MulDivRound(dist, minutes, 3438)
end

function Rat_DbgClear()
    DbgClearVectors()
    DbgClearTexts()
    return "limpo"
end

---------------------------------------------------------------------------------------------------
---- Escolha de alvo/atirador
---------------------------------------------------------------------------------------------------

local function pick_attacker(attacker)
    return attacker or SelectedObj
end

local function pick_target(attacker, target)
    if target then
        return target
    end
    ---- preferencia: alvo sob o cursor, senao o inimigo mais proximo
    local best, best_d
    for _, o in ipairs(g_Units or empty_table) do
        if o ~= attacker and not o:IsDead() and attacker:IsOnEnemySide(o) then
            local d = attacker:GetDist(o)
            if not best_d or d < best_d then
                best, best_d = o, d
            end
        end
    end
    return best
end

---------------------------------------------------------------------------------------------------
---- Raios de cobertura
----
---- Verde = o raio chegou no alvo. Vermelho = bloqueado, e o traco para exatamente
---- onde bateu, com o nome do que bloqueou. E a leitura direta da fracao exposta:
---- conte os verdes.
---------------------------------------------------------------------------------------------------

function Rat_DbgCover(target, attacker, body_part)
    attacker = pick_attacker(attacker)
    if not attacker then
        return "sem atacante (selecione um merc)"
    end
    target = pick_target(attacker, target)
    if not target then
        return "sem alvo"
    end

    local a = const.Combat.Aperture
    local was_en, was_ray = a.Enabled, a.CoverRaycast
    a.Enabled, a.CoverRaycast = true, true

    local dbg = {}
    local pct = Rat_MeasureExposure(attacker, target, attacker:GetPos(), target:GetPos(), body_part,
                                    attacker:GetActiveWeapons(), dbg)

    a.Enabled, a.CoverRaycast = was_en, was_ray

    DbgClearVectors()
    DbgClearTexts()

    local n_hit = 0
    for _, r in ipairs(dbg) do
        local color = r.reached and clrHit or clrMiss
        ---- raio bloqueado para onde bateu; raio limpo vai ate o corpo
        local endpoint = r.reached and r.to or (r.stuck or r.to)
        DbgAddVector(r.from, endpoint - r.from, color)
        if r.reached then
            n_hit = n_hit + 1
            DbgAddCircle(endpoint, const.SlabSizeX / 12, color)
        elseif r.blocker then
            DbgAddText(r.blocker, endpoint, clrMiss)
        end
    end

    if dbg.anchor then
        DbgAddCircle(dbg.anchor, const.SlabSizeX / 8, clrSilh)
    end

    local txt = string.format("exposto %d%%  (%d/%d raios)  [%s]", pct, n_hit, #dbg,
                              tostring(dbg.mode))
    if dbg.anchor then
        DbgAddText(txt, dbg.anchor + point(0, 0, 1200), clrAxis)
    end

    return string.format("%s -> %s (%s%s) a %.1f tiles\n  %s\n  verde = chegou, vermelho = bloqueado",
                         tostring(attacker.session_id), tostring(target.session_id),
                         tostring(target:GetHitStance()),
                         body_part and (", " .. tostring(body_part)) or "",
                         attacker:GetDist(target) / const.SlabSizeX, txt)
end

---------------------------------------------------------------------------------------------------
---- Cone de abertura contra silhueta
----
---- Desenha, NA DISTANCIA DO ALVO, um circulo por nivel de mira com o raio que o
---- cone cobre ali, e um circulo ciano com a silhueta real do alvo. E o modelo
---- inteiro numa imagem: o alvo cabe no cone, ou o cone e maior que o alvo?
----
---- Perto, todos os circulos de mira ficam menores que o ciano -- por isso mirar
---- quase nao muda nada. Longe, eles engolem o ciano, e cada nivel de mira comprado
---- e um circulo que encolhe.
---------------------------------------------------------------------------------------------------

function Rat_DbgCone(target, attacker, body_part)
    attacker = pick_attacker(attacker)
    if not attacker then
        return "sem atacante (selecione um merc)"
    end
    target = pick_target(attacker, target)
    if not target then
        return "sem alvo"
    end

    local weapon = attacker:GetActiveWeapons()
    if not IsKindOf(weapon, "Firearm") then
        return "sem arma de fogo"
    end
    local action = attacker:GetDefaultAttackAction("ranged")

    local a = const.Combat.Aperture
    local was = a.Enabled
    a.Enabled = true

    DbgClearVectors()
    DbgClearTexts()

    local apos, tpos = attacker:GetPos(), target:GetPos()
    local dist = apos:Dist(tpos)

    ---- plano do alvo: o circulo e desenhado na altura do ponto de mira
    local exposed = Rat_MeasureExposure(attacker, target, apos, tpos, body_part, weapon)
    local half_cm = Rat_TargetSilhouette(target, body_part, exposed)
    local center = tpos:SetZ((tpos:IsValidZ() and tpos:z() or terrain.GetHeight(tpos)) +
                                 (target:GetHitStance() == "Prone" and 200 or 800))

    ---- silhueta efetiva (ja encolhida pela cobertura), em unidades do engine
    DbgAddCircle(center, half_cm * 10, clrSilh)
    DbgAddText(string.format("silhueta %dcm (exposto %d%%)", half_cm, exposed), center, clrSilh)

    local lines = {}
    local _, max_aim = attacker:GetBaseAimLevelRange(action, target)
    max_aim = Clamp(max_aim or 3, 1, 6)

    for aim = 0, max_aim do
        local cth, sigma, theta = Rat_AngularCTH(attacker, target, body_part, action, weapon, aim,
                                                 false, apos, tpos)
        local r = cone_radius(dist, sigma)
        DbgAddCircle(center, r, clrCone)
        DbgAddText(string.format("aim %d: %d%%", aim, cth),
                   center + point(0, 0, 260 * (aim + 1)), clrCone)
        lines[#lines + 1] = string.format("  aim %d | cone %5d' (raio %4dcm no alvo) | CTH %3d%%",
                                          aim, sigma, r / 10, cth)
    end

    ---- eixo de tiro
    DbgAddVector(apos, center - apos, clrAxis)

    a.Enabled = was

    return string.format("%s (%s) -> %s [%s] a %.1f tiles | theta do alvo = %d'\n%s\n" ..
                             "  ciano = silhueta do alvo, amarelo = cone por nivel de mira",
                         tostring(attacker.session_id), tostring(weapon.class),
                         tostring(target.session_id), tostring(target:GetHitStance()),
                         dist / const.SlabSizeX,
                         Rat_ThetaTarget(dist, half_cm), table.concat(lines, "\n"))
end

---------------------------------------------------------------------------------------------------

---- Os dois desenhos juntos. Rat_DbgCone e chamado primeiro porque limpa o canvas;
---- os raios sao redesenhados aqui por cima, em vez de chamar Rat_DbgCover (que
---- limparia o cone recem-desenhado).
function Rat_DbgAll(target, attacker, body_part)
    local cone = Rat_DbgCone(target, attacker, body_part)

    attacker = pick_attacker(attacker)
    target = pick_target(attacker, target)
    if not attacker or not target then
        return cone
    end

    local a = const.Combat.Aperture
    local was_en, was_ray = a.Enabled, a.CoverRaycast
    a.Enabled, a.CoverRaycast = true, true
    local dbg = {}
    local pct = Rat_MeasureExposure(attacker, target, attacker:GetPos(), target:GetPos(), body_part,
                                    attacker:GetActiveWeapons(), dbg)
    a.Enabled, a.CoverRaycast = was_en, was_ray

    local n_hit = 0
    for _, r in ipairs(dbg) do
        local color = r.reached and clrHit or clrMiss
        local endpoint = r.reached and r.to or (r.stuck or r.to)
        DbgAddVector(r.from, endpoint - r.from, color)
        if r.reached then
            n_hit = n_hit + 1
        elseif r.blocker then
            DbgAddText(r.blocker, endpoint, clrMiss)
        end
    end

    return cone .. string.format("\n  cobertura: %d%% exposto (%d/%d raios, %s)", pct, n_hit, #dbg,
                                 tostring(dbg.mode))
end

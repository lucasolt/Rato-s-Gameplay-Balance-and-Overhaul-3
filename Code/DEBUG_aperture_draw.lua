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
----     Rat_DbgShots(24, 2)   -- dispara 24 tiros de MENTIRA com mira 2 e desenha o grupo
----     Rat_DbgLastShots()    -- desenha os vetores do ultimo tiro de VERDADE
----     Rat_DbgClear()        -- limpa
----
---- Todos aceitam (target, attacker); sem argumentos usam a unidade selecionada como
---- atirador e o inimigo mais proximo com linha de tiro como alvo.
----
---- Rat_DbgShots e a unica que consome random sincronizado (usa o mesmo sorteio do
---- tiro real). Em jogo solo e inofensivo.
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

---------------------------------------------------------------------------------------------------
---- Z valido.
----
---- Unit:GetPos() devolve ponto com Z INVALIDO quando a unidade esta no terreno, e
---- aritmetica de vetor com ele degrada para 2D em silencio: (center - apos) virava
---- (894,-447) sem Z, o vetor perpendicular virava (0,0), e o disco saia horizontal.
---- Era essa a causa dos circulos deitados no chao -- nao a orientacao do desenho.
---------------------------------------------------------------------------------------------------
local function vz(pos)
    if not pos or pos:IsValidZ() then
        return pos
    end
    return pos:SetTerrainZ()
end

---------------------------------------------------------------------------------------------------
---- Disco NO PLANO PERPENDICULAR a linha de tiro -- um alvo de papel de frente para
---- o atirador, nao um circulo deitado no chao.
----
---- DbgAddCircle desenha no plano XY (horizontal), que num jogo tatico faz sentido
---- para area de efeito no chao, mas aqui cortava a unidade ao meio e nao dava para
---- comparar cone com silhueta.
----
---- RotateAxis(v, eixo, angulo) roda `v` em torno de `eixo`: partindo de um offset
---- vertical e rodando em torno da direcao de tiro, os pontos caem exatamente no
---- plano perpendicular a ela. E a mesma primitiva que GetPelletScatterData usa para
---- montar o cone de chumbo grosso. Angulo em MINUTOS (360*60 = volta completa).
---------------------------------------------------------------------------------------------------
local function draw_disc(center, radius, dir, color, segments)
    if not radius or radius < 1 then
        return
    end
    segments = segments or 24
    if not dir or not dir:IsValidZ() then
        --- direcao sem Z nao define plano nenhum: o disco sairia deitado
        dir = point(dir and dir:x() or 0, dir and dir:y() or 0, 0)
    end
    if dir:Len() == 0 then
        return
    end
    dir = SetLen(dir, 1000)

    ---- Partir de um vetor GENUINAMENTE perpendicular a dir. RotateAxis preserva a
    ---- componente paralela ao eixo, entao rodar um (0,0,r) cru daria um circulo
    ---- correto no plano mas deslocado ao longo do eixo, e com raio efetivo menor
    ---- que r -- o erro cresce com a inclinacao do tiro, e aqui o raio e justamente
    ---- a grandeza que esta sendo comparada com a silhueta.
    local up = point(0, 0, 1000)
    local par = Dot(up, dir) / 1000 --- componente de `up` ao longo de dir
    local perp = up - MulDivRound(dir, par, 1000)
    if perp:Len() < 10 then
        --- tiro quase vertical: usa a horizontal como referencia
        perp = point(-dir:y(), dir:x(), 0)
    end
    perp = SetLen(perp, radius)

    local full = 360 * 60
    local prev
    for i = 0, segments do
        local pt = center + RotateAxis(perp, dir, MulDivRound(full, i, segments))
        if prev then
            DbgAddSegment(prev, pt, color)
        end
        prev = pt
    end
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
        local rdir = endpoint - r.from
        DbgAddVector(r.from, rdir, color)
        if r.reached then
            n_hit = n_hit + 1
            ---- marcador de frente para o raio, nao deitado no chao
            draw_disc(endpoint, const.SlabSizeX / 12, SetLen(rdir, 1000), color, 10)
        elseif r.blocker then
            DbgAddText(r.blocker, endpoint, clrMiss)
        end
    end

    ---- A caixa da silhueta saiu daqui junto com a grade: a amostragem agora sai dos
    ---- spots reais do corpo, entao os proprios raios ja desenham o padrao e nao ha
    ---- retangulo que o descreva. (dbg.halfh deixou de existir nessa troca.)

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

    ---- Z valido ANTES de qualquer matematica de vetor: ver o comentario em vz()
    local apos, tpos = vz(attacker:GetPos()), vz(target:GetPos())
    local dist = apos:Dist(tpos)

    ---- plano do alvo: o circulo e desenhado na altura do ponto de mira
    local exposed = Rat_MeasureExposure(attacker, target, apos, tpos, body_part, weapon)
    local half_cm = Rat_TargetSilhouette(target, body_part, exposed)
    local center = tpos:SetZ(tpos:z() + (target:GetHitStance() == "Prone" and 200 or 800))

    ---- direcao de tiro: define o plano de TODOS os discos abaixo
    local dir = center - apos
    if dir:Len() == 0 then
        dir = point(1000, 0, 0)
    end
    dir = SetLen(dir, 1000)

    ---- silhueta efetiva (ja encolhida pela cobertura), em unidades do engine
    draw_disc(center, half_cm * 10, dir, clrSilh, 32)
    DbgAddText(string.format("silhueta %dcm (exposto %d%%)", half_cm, exposed), center, clrSilh)

    local lines = {}
    local _, max_aim = attacker:GetBaseAimLevelRange(action, target)
    max_aim = Clamp(max_aim or 3, 1, 6)

    ---- Os discos mostram o raio que contem ~96% dos tiros (2.5 sigma), nao 1 sigma:
    ---- num circulo de 1 sigma cabem so 39% dos disparos, entao desenha-lo daria a
    ---- impressao de acerto certo em tiros de 72%. Mesmo criterio do crosshair.
    local smul = a.CrosshairSigmaMul or 250
    for aim = 0, max_aim do
        local cth, sigma, theta = Rat_AngularCTH(attacker, target, body_part, action, weapon, aim,
                                                 false, apos, tpos)
        local spread = MulDivRound(sigma, smul, 100)
        local r = cone_radius(dist, spread)
        draw_disc(center, r, dir, clrCone, 32)
        ---- rotulo na borda superior do proprio disco, para nao empilhar no centro
        DbgAddText(string.format("aim %d: %d%%", aim, cth), center + point(0, 0, r), clrCone)
        lines[#lines + 1] = string.format(
            "  aim %d | sigma %4d' grupo %5d' (raio %4dcm no alvo) | CTH %3d%% | %s",
            aim, sigma, spread, r / 10, cth,
            (spread <= theta) and "grupo cabe no alvo" or "transborda")
    end

    ---- eixo de tiro
    DbgAddVector(apos, center - apos, clrAxis)

    a.Enabled = was

    return string.format("%s (%s) -> %s [%s] a %.1f tiles | theta do alvo = %d'\n%s\n" ..
                             "  ciano = silhueta do alvo, amarelo = onde caem ~96% dos tiros, por nivel de mira",
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
            draw_disc(endpoint, const.SlabSizeX / 14, SetLen(endpoint - r.from, 1000), color, 8)
        elseif r.blocker then
            DbgAddText(r.blocker, endpoint, clrMiss)
        end
    end

    return cone .. string.format("\n  cobertura: %d%% exposto (%d/%d raios, %s)", pct, n_hit, #dbg,
                                 tostring(dbg.mode))
end

---------------------------------------------------------------------------------------------------
---- VETORES DE TIRO
----
---- Rat_DbgShots(n, aim)   -- dispara n tiros de MENTIRA e desenha o agrupamento
---- Rat_DbgLastShots()     -- desenha os vetores do ultimo tiro de VERDADE
----
---- Verde = a bala cruzou o alvo. Vermelho = passou / bateu em outra coisa, e o
---- traco vai ate onde ela parou. Ciano = a silhueta. Amarelo = o circulo que
---- contem ~96% dos tiros (2.5 sigma), o mesmo do crosshair.
---------------------------------------------------------------------------------------------------

---- Monta os argumentos de LoF identicos aos que a simulacao usa em
---- Firearm:GetAttackResults, para o desenho mostrar o tiro de verdade e nao uma
---- aproximacao.
local function sim_lof_args(attacker, weapon, attack_pos, dist)
    return {
        obj = attacker,
        weapon = weapon,
        stance = attacker.stance,
        attack_pos = attack_pos,
        output_collisions = true,
        range = dist + 20 * const.SlabSizeX,
        penetration_class = weapon:GetPenetrationClass(),
        prediction = false,
        clamp_to_target = false,
        fire_relative_point_attack = false,
        can_hit_attacker = false,
        ignore_los = true,
        inside_attack_area_check = false,
        forced_hit_on_eye_contact = false,
        can_use_covers = false,
        aimIK = false,
        can_stuck_on_unit = true,
        force_hit_seen_target = false
    }
end

---- ATENCAO: consome random sincronizado (o mesmo sorteio do tiro real). Em jogo
---- solo e inofensivo; em co-op nao use durante o turno de outro jogador.
function Rat_DbgShots(count, aim, target, attacker)
    attacker = pick_attacker(attacker)
    if not attacker then
        return "sem atacante (selecione um merc)"
    end
    target = pick_target(attacker, target)
    if not target then
        return "sem alvo"
    end

    local weapon = attacker:GetActiveWeapons()
    local action = attacker:GetDefaultAttackAction("ranged")
    if not IsKindOf(weapon, "Firearm") or not action then
        return "sem arma de fogo"
    end

    count = count or 24
    aim = aim or 2

    local a = const.Combat.Aperture
    local was = a.Enabled
    a.Enabled = true

    ---- ancoras reais do engine, como a simulacao faz
    local base = GetLoFData(attacker, target, {
        obj = attacker, weapon = weapon, stance = attacker.stance,
        prediction = true, output_collisions = true, force_hit_seen_target = false
    })
    if not base or not base.lof or #base.lof == 0 then
        a.Enabled = was
        return "sem linha de tiro"
    end
    local attack_pos = base.lof[1].attack_pos
    local aim_pos
    for _, l in ipairs(base.lof) do
        if l.target_spot_group == "Torso" then
            aim_pos = l.target_pos
        end
    end
    aim_pos = aim_pos or base.lof[1].target_pos

    local cth, geo_sigma, theta = Rat_AngularCTH(attacker, target, "Torso", action, weapon, aim,
                                                 false, attacker:GetPos(), target:GetPos())
    ---- mesmo sigma que a simulacao usa: derivado do CTH final, nao da abertura crua
    local sigma = Rat_SigmaForCTH(theta, cth) or geo_sigma

    DbgClearVectors()
    DbgClearTexts()

    local dist = attack_pos:Dist(aim_pos)
    local dir = SetLen(aim_pos - attack_pos, 1000)
    draw_disc(aim_pos, MulDivRound(theta, dist, 3438), dir, clrSilh, 32)
    draw_disc(aim_pos, cone_radius(dist, MulDivRound(sigma, a.CrosshairSigmaMul or 250, 100)), dir,
              clrCone, 32)

    local lof_args = sim_lof_args(attacker, weapon, attack_pos, dist)
    local hits, parts = 0, {}
    for i = 1, count do
        local pt = Rat_ShotScatterPoint(attacker, attack_pos, aim_pos, sigma)
        lof_args.seed = attacker:Random()
        local d = GetLoFData(attacker, pt, lof_args)
        local lof = d and (d.outside_attack_area_lof or (d.lof and d.lof[1]))
        local hit, spot
        for _, h in ipairs((lof and lof.hits) or empty_table) do
            if h.obj == target then
                hit, spot = true, tostring(h.spot_group or "?")
                break
            end
        end
        local endpoint = (lof and (lof.stuck_pos or lof.lof_pos2)) or pt
        DbgAddVector(attack_pos, endpoint - attack_pos, hit and clrHit or clrMiss)
        if hit then
            hits = hits + 1
            parts[spot] = (parts[spot] or 0) + 1
            draw_disc(endpoint, const.SlabSizeX / 14, dir, clrHit, 8)
        end
    end

    a.Enabled = was

    local ps = {}
    for g, n in sorted_pairs(parts) do
        ps[#ps + 1] = string.format("%s %d%%", g, MulDivRound(n, 100, Max(1, hits)))
    end
    return string.format(
               "%s (%s) -> %s a %.1f tiles, aim %d\n" ..
                   "  CTH exibido %d%% | %d/%d acertaram (%d%%) | sigma %d'\n  %s\n" ..
                   "  verde = acertou, vermelho = errou; ciano = silhueta, amarelo = 96%% dos tiros",
               tostring(attacker.session_id), tostring(weapon.class), tostring(target.session_id),
               attacker:GetDist(target) / const.SlabSizeX, aim, cth, hits, count,
               MulDivRound(hits, 100, count), sigma, table.concat(ps, "  "))
end

---- Desenha o ataque que REALMENTE aconteceu por ultimo. Nao sorteia nada: le o
---- registro que Firearm:GetAttackResults deixa em g_RatLastSimShots.
function Rat_DbgLastShots()
    local rec = g_RatLastSimShots
    if not rec or not rec.shots or #rec.shots == 0 then
        return "nenhum tiro simulado registrado ainda (atire uma vez com A.SimulateShots = true)"
    end

    DbgClearVectors()
    DbgClearTexts()

    local lines = {}
    local hits = 0
    local dir = rec.shots[1] and rec.shots[1].target_pos and
                    SetLen(rec.shots[1].target_pos - rec.attack_pos, 1000)

    for i, sh in ipairs(rec.shots) do
        local endpoint = sh.end_pos or sh.target_pos
        local color = sh.miss and clrMiss or clrHit
        DbgAddVector(rec.attack_pos, endpoint - rec.attack_pos, color)
        if not sh.miss then
            hits = hits + 1
            if dir then
                draw_disc(endpoint, const.SlabSizeX / 14, dir, color, 8)
            end
        end
        DbgAddText(string.format("%d%s", i, sh.crit and " crit" or ""), endpoint, color)
        lines[#lines + 1] = string.format("  tiro %d | sigma %5d' | %s%s", i, sh.sigma or -1,
                                          sh.miss and "errou" or "ACERTOU",
                                          sh.crit and " (critico)" or "")
    end

    return string.format("ultimo ataque: %s -> %s | %d/%d acertaram\n%s",
                         tostring(rec.attacker and rec.attacker.session_id),
                         tostring(rec.target and rec.target.session_id), hits, #rec.shots,
                         table.concat(lines, "\n"))
end

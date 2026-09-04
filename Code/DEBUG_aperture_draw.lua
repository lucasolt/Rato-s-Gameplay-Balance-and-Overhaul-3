---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- visualizadores. Desenham no mundo o que o modelo ve; so leitura.
---- Console: Rat_DbgCover() raios de cobertura | Rat_DbgCone() cone x silhueta por mira |
---- Rat_DbgAll() os dois | Rat_DbgShots(24,2) 24 tiros de mentira | Rat_DbgLastShots(rings) ultimo
---- tiro real, rings = um anel por disparo | Rat_DbgRecoilMouse() vetores do recuo seguindo o mouse,
---- Rat_DbgRecoilMouse{shots=true} rajada sorteada de verdade | Rat_DbgRecoilShots() uma rajada so
---- (os tres de recuo aceitam overrides: {chance=0} sem controle, {chance=100} controle total,
---- {climb=N} recuo da arma, {theta=N, sigma=N} CTH sem alvo) | Rat_DbgClear().
---- Sem args: atirador = selecionado, alvo do
---- Crosshair UI ou o inimigo mais proximo. So Rat_DbgShots consome random sincronizado.
---------------------------------------------------------------------------------------------------

local clrHit = const.clrGreen
local clrMiss = const.clrRed
local clrCone = const.clrYellow or RGB(255, 220, 0)
local clrSilh = const.clrCyan
local clrAxis = const.clrWhite

---- Geometria em UI_aperture_ring.lua: o anel do jogador e estes discos sao o MESMO circulo.
local cone_radius = Rat_ConeRadius
local vz = Rat_RingValidZ

---- Disco no plano perpendicular a linha de tiro (alvo de papel de frente).
local function draw_disc(center, radius, dir, color, segments)
    local pts = Rat_RingPoints(center, radius, dir, segments or 24)
    if not pts then
        return
    end
    for i = 2, #pts do
        DbgAddSegment(pts[i - 1], pts[i], color)
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
g_RatDbgCrosshairTarget = false

local function pick_attacker(attacker)
    return attacker or SelectedObj
end

---- Ultimo inimigo mirado pela UI do Crosshair (ao vivo ou o ultimo valido); so serve se for inimigo vivo de `attacker`.
function Rat_DbgCrosshairTarget(attacker)
    local igi = GetInGameInterfaceModeDlg and GetInGameInterfaceModeDlg()
    local live = igi and igi.crosshair and igi.crosshair.context and igi.crosshair.context.target
    local t = (IsValid(live) and live) or g_RatDbgCrosshairTarget
    if IsValid(t) and not t:IsDead() and attacker ~= t and attacker:IsOnEnemySide(t) then
        return t
    end
end

local function pick_target(attacker, target)
    if target then
        return target
    end
    ---- se um merc esta selecionado, reusa o alvo do Crosshair UI antes do mais proximo
    if attacker == SelectedObj then
        local ct = Rat_DbgCrosshairTarget(attacker)
        if ct then
            return ct
        end
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

---- Raios de cobertura. Verde = chegou; vermelho = bloqueado (com nome do bloqueador). Exposto = conte os verdes.
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

    local debug_table = {}
    local pct = Rat_MeasureExposure(attacker, target, attacker:GetPos(), target:GetPos(), body_part,
                                    attacker:GetActiveWeapons(), debug_table)

    a.Enabled, a.CoverRaycast = was_en, was_ray

    DbgClearVectors()
    DbgClearTexts()

    local n_hit = 0
    for _, r in ipairs(debug_table) do
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

    ---- sem caixa de silhueta: a amostragem sai dos spots reais do corpo, os raios ja desenham o padrao

    local txt = string.format("exposto %d%%  (%d/%d raios)  [%s]", pct, n_hit, #debug_table,
                              tostring(debug_table.mode))
    if debug_table.anchor then
        DbgAddText(txt, debug_table.anchor + point(0, 0, 1200), clrAxis)
    end

    return string.format("%s -> %s (%s%s) a %.1f tiles\n  %s\n  verde = chegou, vermelho = bloqueado",
                         tostring(attacker.session_id), tostring(target.session_id),
                         tostring(target:GetHitStance()),
                         body_part and (", " .. tostring(body_part)) or "",
                         attacker:GetDist(target) / const.SlabSizeX, txt)
end

---- Cone de abertura contra silhueta. Na distancia do alvo: um circulo amarelo por nivel
---- de mira (raio do cone ali) e um ciano com a silhueta real. O alvo cabe no cone?
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

    ---- plano do alvo: no spot da parte mirada, a mesma ancora do anel do jogador
    local exposed = Rat_MeasureExposure(attacker, target, apos, tpos, body_part, weapon)
    local half_cm = Rat_TargetSilhouette(target, body_part, exposed)
    local center = Rat_RingAnchor(target, body_part) or tpos

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

    ---- Raio de ~96% dos tiros (2.5 sigma), nao 1 sigma (que so contem 39%). Mesmo
    ---- criterio do crosshair.
    local smul = a.CrosshairSigmaMul or 250
    for aim = 0, max_aim do
        ---- o cone do TIRO (residuais ja dentro), o mesmo do anel e da simulacao
        local sigma, theta, cth = Rat_AttackCone(attacker, target, action, body_part, aim, false,
                                                 apos, tpos)
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

---- Cone + raios juntos. Cone primeiro (limpa o canvas); raios redesenhados aqui, nao via Rat_DbgCover.
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
    local debug_table = {}
    local pct = Rat_MeasureExposure(attacker, target, attacker:GetPos(), target:GetPos(), body_part,
                                    attacker:GetActiveWeapons(), debug_table)
    a.Enabled, a.CoverRaycast = was_en, was_ray

    local n_hit = 0
    for _, r in ipairs(debug_table) do
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

    return cone .. string.format("\n  cobertura: %d%% exposto (%d/%d raios, %s)", pct, n_hit, #debug_table,
                                 tostring(debug_table.mode))
end

---------------------------------------------------------------------------------------------------
---- VETORES DE TIRO. Rat_DbgShots(n,aim) tiros de mentira | Rat_DbgLastShots() ultimo tiro real |
---- Rat_DbgVerifySim() debug x tiro real | Rat_DbgSilhouette() silhueta projetada real.
---- Verde = bala cruzou o alvo, vermelho = passou, ciano = silhueta, amarelo = ~96% dos tiros.
---- Reusa as funcoes de Firearm:GetAttackResults (Rat_SimPlanShots/LoFOverrides/HitSpot), nao reimplementa.
---------------------------------------------------------------------------------------------------

g_RatLastSimShots = false
---- Args de LoF: prefere replay do ultimo tiro real; senao reconstroi e avisa (fidelidade nao garantida).
local function sim_args_for(attacker, target, weapon, spot, range)
    local rec = g_RatLastSimShots
    if rec and rec.replay_args and rec.attacker == attacker and rec.target == target then
        return table.copy(rec.replay_args), "replay do ultimo tiro real"
    end
    return Rat_SimBaseArgs(attacker, target, weapon, spot, range), "args reconstruidos (nao verificado)"
end

---- Monta o ctx de simulacao do mesmo jeito que Firearm:GetAttackResults monta -- ancoras de LoF do
---- engine, ponto de mira de Rat_SimAimPos, CTH final COM residuais (o geometrico cru diverge da UI
---- e aperta o cone ~15%). Compartilhado pelos amostradores: se divergirem, o visualizador para de
---- medir o que o jogo faz. Devolve ctx, args_src, spot_pos -- ou nil e a razao.
local function sim_ctx_for(attacker, target, target_spot, aim, burst)
    local weapon = attacker:GetActiveWeapons()
    local action = attacker:GetDefaultAttackAction("ranged")
    if not IsKindOf(weapon, "Firearm") or not action then
        return nil, "sem arma de fogo"
    end

    local base = GetLoFData(attacker, target, {
        obj = attacker, weapon = weapon, stance = attacker.stance,
        prediction = true, output_collisions = true, force_hit_seen_target = false
    })
    if not base or not base.lof or #base.lof == 0 then
        return nil, "sem linha de tiro"
    end

    local attack_pos = base.lof[1].attack_pos
    local aim_pos = Rat_SimAimPos(base.lof, target_spot, base.lof[1].target_pos)
    local spot_pos = base.lof[1].target_pos
    for _, l in ipairs(base.lof) do
        if l.target_spot_group == target_spot then
            spot_pos = l.target_pos
        end
    end

    local cth_args = {target_spot_group = target_spot, aim = aim, prediction = true,
                      step_pos = attacker:GetPos(), target_pos = target:GetPos()}
    local cth_raw = attacker:CalcChanceToHit(target, action, cth_args)
    local cth = weapon:GetShotChanceToHit(cth_raw) or cth_raw

    local dist = attack_pos:Dist(aim_pos)
    local args, args_src = sim_args_for(attacker, target, weapon, target_spot,
                                        dist + 20 * const.SlabSizeX)

    return {
        attacker = attacker, target = target, action = action, weapon = weapon,
        aim = aim, opportunity_attack = false, spot = target_spot,
        attack_pos = attack_pos, aim_pos = aim_pos,
        step_pos = attacker:GetPos(), target_pos = target:GetPos(),
        cth = cth, cth_source = "GetShotChanceToHit(CalcChanceToHit)",
        ---- a rajada REAL que se quer inspecionar -- nao o numero de amostras
        num_shots = burst, args = args
    }, args_src, spot_pos
end

---- Rat_DbgShots(count, aim, spot, target, attacker, shot_idx, burst)
---- `count` = amostras independentes do mesmo tiro, nao uma rajada. Tiro inspecionado = (shot_idx, burst),
---- padrao 1 de 1. 3o tiro de uma rajada de 6: Rat_DbgShots(150, 2, nil, nil, nil, 3, 6).
---- ATENCAO: consome random sincronizado; em co-op nao use no turno de outro jogador.
function Rat_DbgShots(count, aim, target_spot, target, attacker, shot_idx, burst)
    attacker = pick_attacker(attacker)
    if not attacker then
        return "sem atacante (selecione um merc)"
    end
    target = pick_target(attacker, target)
    if not target then
        return "sem alvo"
    end
    target_spot = target_spot or g_DefaultShotBodyPart or "Torso"

    count = count or 24
    aim = aim or 2
    burst = Max(1, burst or 1)
    shot_idx = Clamp(shot_idx or 1, 1, burst)

    local a = const.Combat.Aperture
    local was = a.Enabled
    a.Enabled = true

    local ctx, args_src, spot_pos = sim_ctx_for(attacker, target, target_spot, aim, burst)
    if not ctx then
        a.Enabled = was
        return args_src
    end
    local weapon, args = ctx.weapon, ctx.args
    local attack_pos, aim_pos, cth = ctx.attack_pos, ctx.aim_pos, ctx.cth
    local dist = attack_pos:Dist(aim_pos)

    local shots = Rat_SimPlanShots(ctx)
    if not shots then
        a.Enabled = was
        return "sem sigma valido (theta = " .. tostring(ctx.theta) .. ")"
    end

    ---- o cone do tiro escolhido; as `count` amostras saem TODAS dele
    local sigma_i = shots[shot_idx].sigma

    DbgClearVectors()
    DbgClearTexts()

    local dir = SetLen(aim_pos - attack_pos, 1000)
    draw_disc(aim_pos, MulDivRound(ctx.theta, dist, 3438), dir, clrSilh, 32)
    draw_disc(aim_pos, cone_radius(dist, MulDivRound(sigma_i, a.CrosshairSigmaMul or 250, 100)),
              dir, clrCone, 32)
    ---- onde o spot cru estava, para enxergar o deslocamento do centro de mira
    if aim_pos ~= spot_pos then
        DbgAddVector(spot_pos, aim_pos - spot_pos, clrAxis)
        DbgAddText("spot", spot_pos, clrAxis)
    end

    local hits, parts = 0, {}
    for i = 1, count do
        ---- amostra COMPLETA do tiro escolhido: eixo de recuo proprio, subida rolada tiro a tiro
        ---- ate ele, e so entao a dispersao da arma. Reamostrar o eixo a cada amostra e o certo --
        ---- a nuvem que sai e a distribuicao real do tiro N, nao uma unica rajada.
        local sample = Rat_SimReplanShot(ctx, shot_idx)
        local pt = sample.target_pos
        Rat_SimLoFOverrides(args, attack_pos, attacker:Random(), args.ignore_colliders)
        local lof = Rat_SimLoF(GetLoFData(attacker, pt, args))
        local hit, spot = Rat_SimHitSpot(lof, target)
        local endpoint = (lof and (lof.stuck_pos or lof.lof_pos2)) or pt
        DbgAddVector(attack_pos, endpoint - attack_pos, hit and clrHit or clrMiss)
        if hit then
            hits = hits + 1
            local g = tostring(spot or "?")
            parts[g] = (parts[g] or 0) + 1
            draw_disc(endpoint, const.SlabSizeX / 14, dir, clrHit, 8)
        end
    end

    a.Enabled = was

    ---- por membro: n acertos | % sobre os acertos | % sobre o total de tiros
    local ps = {}
    for g, n in sorted_pairs(parts) do
        ps[#ps + 1] = string.format("    %-8s %2d  (%3d%% dos acertos | %3d%% do total)", g, n,
                                    MulDivRound(n, 100, Max(1, hits)), MulDivRound(n, 100, count))
    end
    if #ps == 0 then
        ps[1] = "    (nenhum acerto)"
    end

    local dz = (aim_pos:z() - spot_pos:z()) / 10
    return string.format(
               "%s (%s) -> %s [%s] a %.1f tiles, aim %d, alvo %s\n" ..
                   "  amostras: %d do tiro %d de %d  |  CTH %d%% (o mesmo do tiro real)\n" ..
                   "  %d/%d acertaram (%d%% do total) | %d erraram\n" ..
                   "  sigma %d' (tiro 1 = %d', subida %d'/tiro, controle %d%%)  theta %d'\n" ..
                   "  centro de mira %+dcm vs spot (AimCentroidPct %d)  |  args: %s\n" ..
                   "  distribuicao por membro:\n%s\n" ..
                   "  verde = acertou, vermelho = errou; ciano = silhueta, amarelo = 96%% dos tiros",
               tostring(attacker.session_id), tostring(weapon.class), tostring(target.session_id),
               tostring(target:GetHitStance()), attacker:GetDist(target) / const.SlabSizeX, aim,
               tostring(target_spot), count, shot_idx, burst, cth,
               hits, count, MulDivRound(hits, 100, count), count - hits,
               sigma_i, ctx.sigma, ctx.climb or 0, ctx.control_chance or 0, ctx.theta,
               dz, a.AimCentroidPct or 0, args_src, table.concat(ps, "\n"))
end

---- Anel do tiro `i` de `n`: amarelo no primeiro, vermelho no ultimo. E a leitura do recoil --
---- quanto mais longe do amarelo, mais o cone abriu.
local function recoil_ring_color(i, n)
    local t = (n > 1) and MulDivRound(i - 1, 100, n - 1) or 0
    return RGB(255 - MulDivRound(25, t, 100), 220 - MulDivRound(160, t, 100),
               MulDivRound(40, t, 100))
end

---------------------------------------------------------------------------------------------------
---- Rat_DbgBurst(bursts, burst, aim, spot, target, attacker)
---- RAJADAS inteiras, nao tiros avulsos: `bursts` rajadas de `burst` tiros, taxa de acerto por
---- INDICE de tiro. Rat_DbgShots reamostra o eixo do recuo a cada tiro; aqui cada rajada tem UM
---- eixo, como no jogo -- e a diferenca aparece na correlacao entre tiros da mesma rajada, que e
---- justamente o que a caminhada do cano introduziu.
---- 100 rajadas de 3: Rat_DbgBurst(100, 3, 1). Desenha a ULTIMA rajada, para ver um risco.
---- ATENCAO: consome random sincronizado; em co-op nao use no turno de outro jogador.
---------------------------------------------------------------------------------------------------
function Rat_DbgBurst(bursts, burst, aim, target_spot, target, attacker)
    attacker = pick_attacker(attacker)
    if not attacker then
        return "sem atacante (selecione um merc)"
    end
    target = pick_target(attacker, target)
    if not target then
        return "sem alvo"
    end
    target_spot = target_spot or g_DefaultShotBodyPart or "Torso"

    bursts = Max(1, bursts or 100)
    burst = Max(1, burst or 3)
    aim = aim or 1

    local a = const.Combat.Aperture
    local was = a.Enabled
    a.Enabled = true

    local ctx, args_src, spot_pos = sim_ctx_for(attacker, target, target_spot, aim, burst)
    if not ctx then
        a.Enabled = was
        return args_src
    end
    local args = ctx.args
    local attack_pos, aim_pos = ctx.attack_pos, ctx.aim_pos

    ---- hits[i] = acertos do tiro i somados nas rajadas; per_burst[k+1] = rajadas com k acertos
    local hits, parts, per_burst, plan, last = {}, {}, {}, nil, nil
    for i = 1, burst do
        hits[i] = 0
    end
    for k = 0, burst do
        per_burst[k + 1] = 0
    end

    for b = 1, bursts do
        ---- UM plano por rajada: um eixo de recuo e uma rolagem de controle por coice, como no tiro real
        local shots = Rat_SimPlanShots(ctx)
        if not shots then
            a.Enabled = was
            return "sem sigma valido (theta = " .. tostring(ctx.theta) .. ")"
        end
        plan = plan or shots ---- previsao: igual em toda rajada, basta guardar a primeira
        local in_burst = 0
        for i = 1, burst do
            Rat_SimLoFOverrides(args, attack_pos, attacker:Random(), args.ignore_colliders)
            local lof = Rat_SimLoF(GetLoFData(attacker, shots[i].target_pos, args))
            local hit, spot = Rat_SimHitSpot(lof, target)
            if hit then
                hits[i] = hits[i] + 1
                in_burst = in_burst + 1
                local g = tostring(spot or "?")
                parts[g] = (parts[g] or 0) + 1
            end
            if b == bursts then
                last = last or {}
                last[i] = {pt = shots[i].target_pos, hit = hit,
                           end_pos = (lof and (lof.stuck_pos or lof.lof_pos2)) or shots[i].target_pos}
            end
        end
        per_burst[in_burst + 1] = per_burst[in_burst + 1] + 1
    end

    ---- so a ULTIMA rajada e desenhada: um eixo so, para o risco ficar visivel
    DbgClearVectors()
    DbgClearTexts()
    local dist = attack_pos:Dist(aim_pos)
    local dir = SetLen(aim_pos - attack_pos, 1000)
    draw_disc(aim_pos, MulDivRound(ctx.theta, dist, 3438), dir, clrSilh, 32)
    draw_disc(aim_pos, cone_radius(dist, MulDivRound(ctx.sigma, a.CrosshairSigmaMul or 250, 100)),
              dir, clrCone, 32)
    for i, sh in ipairs(last or empty_table) do
        DbgAddVector(attack_pos, sh.end_pos - attack_pos, recoil_ring_color(i, burst))
        DbgAddText(tostring(i), sh.pt, recoil_ring_color(i, burst))
    end

    local rows, total = {}, 0
    for i = 1, burst do
        total = total + hits[i]
        rows[#rows + 1] = string.format("    %2d  |  %3d%% |  %3d%% | %5d | %5d", i,
                                        plan[i].cth or -1, MulDivRound(hits[i], 100, bursts),
                                        plan[i].mu or 0, plan[i].sigma)
    end

    local dist_rows = {}
    for k = 0, burst do
        dist_rows[#dist_rows + 1] = string.format("      %d acerto(s): %3d%%", k,
                                                  MulDivRound(per_burst[k + 1], 100, bursts))
    end
    ---- media em centesimos: a divisao inteira truncaria para 0 toda rajada que acerta menos de 1
    local avg100 = MulDivRound(total, 100, bursts)

    local ps = {}
    for g, n in sorted_pairs(parts) do
        ps[#ps + 1] = string.format("      %-10s %4d (%d%%)", g, n,
                                    MulDivRound(n, 100, Max(1, total)))
    end

    a.Enabled = was
    return string.format("%s (%s) -> %s [%s] a %.1f tiles, aim %d, alvo %s\n" ..
                             "  %d rajadas de %d  |  CTH da UI %d%%  |  args: %s\n" ..
                             "  cone %d'  subida %d'/tiro  controle %d%%  theta %d'\n" ..
                             "  tiro | prev | med  |    mu | cone\n%s\n" ..
                             "  acertos por rajada (media %d.%02d de %d; ao menos 1 em %d%%):\n%s\n" ..
                             "  distribuicao por membro:\n%s\n" ..
                             "  desenhada a ULTIMA rajada: amarelo = tiro 1, vermelho = ultimo",
                         tostring(attacker.session_id), tostring(ctx.weapon.class),
                         tostring(target.session_id), tostring(target:GetHitStance()),
                         attacker:GetDist(target) / const.SlabSizeX, aim, tostring(target_spot),
                         bursts, burst, ctx.cth, args_src,
                         ctx.sigma, ctx.climb or 0, ctx.control_chance or 0, ctx.theta,
                         table.concat(rows, "\n"),
                         avg100 / 100, avg100 % 100, burst,
                         100 - MulDivRound(per_burst[1], 100, bursts),
                         table.concat(dist_rows, "\n"), table.concat(ps, "\n"))
end

---------------------------------------------------------------------------------------------------
---- Rat_DbgSweep(target, attacker, stances, dists, azimuths, verbose)
---- Varre a GEOMETRIA REAL do alvo e resume as meias-extensoes que a tabela de silhueta precisa.
---- theta e um raio EQUIVALENTE EM AREA, e area nao preserva probabilidade de acerto sob dispersao
---- isotropica: um corpo alto e estreito tem a mesma area de um disco gordo e e bem mais dificil de
---- acertar. Trocar o circulo por extensoes por eixo exige MEDIR as extensoes.
----
---- O azimute NAO gira a unidade: gira a ORIGEM do tiro em volta dela -- mesma geometria relativa
---- sem tocar no alvo. E RELATIVO A FRENTE do alvo (0 = de frente, 90 = flanco, 180 = por tras),
---- senao a mesma coluna mediria o peito de um alvo e o flanco de outro.
---- So a postura e mutada, e volta ao fim mesmo se a varredura estourar.
----
---- Saida padrao = MEDIANA de larg/theta e alt/theta por (postura, azimute). As razoes sao estaveis
---- em distancia (medido de 6 a 50 tiles), entao distancia e ruido a agregar, nao dimensao a manter.
---- `verbose` imprime tambem cada cenario.
----
---- ATENCAO: consome random sincronizado; em co-op nao use no turno de outro jogador.
---------------------------------------------------------------------------------------------------
function Rat_DbgSweep(target, attacker, stances, dists, azimuths, verbose, spot)
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

    ---- o spot ANCORA as extensoes: mirar a cabeca move o ponto de mira ~36 cm para cima e o
    ---- corpo passa a se estender quase so para baixo. Medir a partir do Torso e usar para a
    ---- cabeca superestimava 33 pontos (53% na tela, 20% no tiro).
    spot = spot or "Torso"
    stances = stances or {"Standing", "Crouch", "Prone"}
    dists = dists or {6, 10, 15, 25}
    azimuths = azimuths or {0, 45, 90, 135, 180}

    local a = const.Combat.Aperture
    local was_enabled, was_stance = a.Enabled, target.stance
    a.Enabled = true

    local real = GetLoFData(attacker, target, {obj = attacker, weapon = weapon,
        stance = attacker.stance, prediction = true, output_collisions = true,
        force_hit_seen_target = false})
    if not real or not real.lof or #real.lof == 0 then
        a.Enabled = was_enabled
        return "sem linha de tiro para medir a altura da arma"
    end
    local gun_z = real.lof[1].attack_pos:z() - attacker:GetPos():SetTerrainZ():z()
    local tpos = target:GetPos()
    if not tpos:IsValidZ() then
        tpos = tpos:SetTerrainZ()
    end

    ---- samples[stance][az] = lista de {w, h}; fp[stance][chave] = extensoes cruas, para detectar
    ---- postura que nao chegou a colisao (linhas identicas entre posturas nao sao medida, sao bug)
    local samples, fp, raw = {}, {}, {}
    local usable, blocked, dup = 0, 0, 0

    local ok, err = pcall(function()
        for _, stance in ipairs(stances) do
            target.stance = stance
            target:SetTargetDummyFromPos(nil, nil, false)
            samples[stance], fp[stance] = {}, {}

            for _, az in ipairs(azimuths) do
                samples[stance][az] = {}
                for _, d in ipairs(dists) do
                    local du = d * const.SlabSizeX
                    ---- azimute RELATIVO ao alvo: sem somar a orientacao dele, az 0 e uma direcao
                    ---- do MUNDO e a mesma coluna mede o peito de um alvo e o flanco de outro --
                    ---- a tabela sairia embaralhada. 0 = de frente, 90 = flanco, 180 = por tras.
                    ---- angulo do DUMMY, nao da unidade: deitado, FindProneAngle encaixa o corpo
                    ---- numa grade de 45 graus e o corpo que colide fica fora do angulo da unidade.
                    local body = (target.target_dummy and target.target_dummy:GetOrientationAngle())
                                     or target:GetOrientationAngle()
                    ---- z do ALVO, nao do terreno sob o atirador. Desnivel inclina a linha de
                    ---- tiro, a inclinacao gira o plano perpendicular, e "cima/baixo" passa a
                    ---- raspar o corpo no COMPRIMENTO em vez de medir a altura: medido, o mesmo
                    ---- alvo dava baixo 130% de um lado e 287% do outro so por causa disso.
                    ---- A tabela guarda ANATOMIA; o relevo real e erro de runtime, nao dado.
                    local ap = (tpos + Rotate(point(du, 0, 0), body + az * 60)):SetZ(tpos:z() + gun_z)

                    local args = Rat_SimBaseArgs(attacker, target, weapon, spot,
                                                 du + 20 * const.SlabSizeX)
                    local seen = GetLoFData(attacker, target, {obj = attacker, weapon = weapon,
                        stance = attacker.stance, prediction = true, output_collisions = true,
                        force_hit_seen_target = false, attack_pos = ap, step_pos = ap})
                    local aim_pos = seen and seen.lof and seen.lof[1] and
                                        Rat_SimAimPos(seen.lof, spot, seen.lof[1].target_pos)
                    if aim_pos then
                        local dist = ap:Dist(aim_pos)
                        local dir = SetLen(aim_pos - ap, 1000)
                        local up = point(0, 0, 1000)
                        local perp = up - MulDivRound(dir, Dot(up, dir) / 1000, 1000)
                        if perp:Len() < 10 then
                            perp = point(-dir:y(), dir:x(), 0)
                        end

                        local function hits_at(azm, minutes)
                            local radius = MulDivRound(dist, minutes, 3438)
                            local pt = aim_pos +
                                           RotateAxis(SetLen(perp, Max(1, radius)), dir, azm * 60)
                            Rat_SimLoFOverrides(args, ap, attacker:Random(), args.ignore_colliders)
                            return (Rat_SimHitSpot(Rat_SimLoF(GetLoFData(attacker, pt, args)),
                                                   target))
                        end
                        local function edge(azm)
                            if not hits_at(azm, 5) then
                                return 0
                            end
                            local lo, hi = 5, 2000
                            if hits_at(azm, hi) then
                                return hi
                            end
                            while hi - lo > 5 do
                                local mid = (lo + hi) / 2
                                if hits_at(azm, mid) then lo = mid else hi = mid end
                            end
                            return lo
                        end

                        local theta = Rat_ThetaTarget(dist,
                                          Rat_TargetSilhouette(target, nil, 100, stance))
                        if not hits_at(0, 1) then
                            ---- origem sem linha de tiro: zero aqui nao e alvo estreito, e ausencia
                            ---- de medida, e poluiria a calibracao como se fosse dado
                            blocked = blocked + 1
                        else
                            local bu, ar, bd, al = edge(0), edge(90), edge(180), edge(270)
                            ---- SEM media: num corpo deitado o raio rasga AO LONGO num lado e
                            ---- ATRAVES no outro, e a media das duas apaga a unica coisa que
                            ---- distingue a postura. Quatro semi-extensoes, cada uma por si.
                            local w = MulDivRound(ar, 100, Max(1, theta))
                            local h = MulDivRound(al, 100, Max(1, theta))
                            local wu = MulDivRound(bu, 100, Max(1, theta))
                            local hd = MulDivRound(bd, 100, Max(1, theta))
                            local key = az .. ":" .. d
                            fp[stance][key] = bu .. "," .. bd .. "," .. ar .. "," .. al

                            ---- alguma postura ANTERIOR mediu exatamente isto? entao a mudanca de
                            ---- postura nao chegou a geometria de colisao: descartar, nao contar
                            local same
                            for _, prev in ipairs(stances) do
                                if prev == stance then
                                    break
                                end
                                if fp[prev] and fp[prev][key] == fp[stance][key] then
                                    same = prev
                                end
                            end

                            if same then
                                dup = dup + 1
                                if verbose then
                                    raw[#raw + 1] = string.format(
                                        "  %-8s | %3d | %3d | IDENTICO a %s -- descartado",
                                        stance, az, d, same)
                                end
                            else
                                usable = usable + 1
                                local s = samples[stance][az]
                                s[#s + 1] = {w = w, h = h, wu = wu, hd = hd}
                                if verbose then
                                    raw[#raw + 1] = string.format(
                                        "  %-8s | %3d | %3d | %5d | %5d %5d %5d %5d | %5d%% %5d%%",
                                        stance, az, d, theta, bu, bd, ar, al, w, h)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    target.stance = was_stance
    target:SetTargetDummyFromPos(nil, nil, false)
    a.Enabled = was_enabled
    if not ok then
        return "ERRO na varredura (estado do alvo restaurado): " .. tostring(err)
    end

    local function median(list, field)
        local v = {}
        for _, e in ipairs(list) do
            v[#v + 1] = e[field]
        end
        if #v == 0 then
            return nil
        end
        table.sort(v)
        return v[(#v + 1) / 2]
    end

    local lines = {"  postura  |  az |  n | cima  baixo   dir   esq   (% de theta)"}
    for _, stance in ipairs(stances) do
        for _, az in ipairs(azimuths) do
            local s = samples[stance] and samples[stance][az] or empty_table
            if #s > 0 then
                local cima, baixo = median(s, "wu"), median(s, "hd")
                local dir, esq = median(s, "w"), median(s, "h")
                lines[#lines + 1] = string.format("  %-8s | %3d | %2d | %4d%% %4d%% %4d%% %4d%%",
                                                  stance, az, #s, cima, baixo, dir, esq)
            end
        end
    end

    local notes = {string.format("  %d cenarios medidos, %d sem linha de tiro, %d descartados por"
                                     .. " postura identica", usable, blocked, dup)}
    if dup > 0 then
        notes[#notes + 1] = "  AVISO: linhas identicas entre posturas -- a mudanca de postura nao" ..
                                " chegou a colisao nesses casos."
    end
    if blocked > usable then
        notes[#notes + 1] = "  AVISO: maioria dos cenarios bloqueada. As medidas que sobraram sao" ..
                                " dos angulos abertos, nao uma amostra do alvo -- procure terreno limpo."
    end

    local head = "%s (%s) -> %s [postura real: %s]   varredura de geometria" ..
                     "\n  mediana em distancia, %% do raio que a tabela afirma. SEM media entre lados." ..
                     "\n  100%% = o circulo acerta aquele eixo. az = ATIRADOR relativo a FRENTE do alvo." ..
                     "\n%s\n%s%s"
    return string.format(head, tostring(attacker.session_id), tostring(weapon.class),
                         tostring(target.session_id), tostring(was_stance),
                         table.concat(lines, "\n"), table.concat(notes, "\n"),
                         verbose and ("\n\n  cenarios:\n" .. table.concat(raw, "\n")) or "")
end

---- Desenha o ultimo ataque real. Nao sorteia: le g_RatLastSimShots (gravado por
---- Firearm:GetAttackResults). `rings` = um anel por tiro em vez de um so.
function Rat_DbgLastShots(rings)
    local rec = g_RatLastSimShots
    if not rec or not rec.shots or #rec.shots == 0 then
        return "nenhum tiro simulado registrado ainda (atire uma vez com A.SimulateShots = true)"
    end

    DbgClearVectors()
    DbgClearTexts()

    local lines = {}
    local hits, crits, total, parts = 0, 0, #rec.shots, {}
    local dir = rec.shots[1] and rec.shots[1].target_pos and
                    SetLen(rec.shots[1].target_pos - rec.attack_pos, 1000)

    if rec.aim_pos and dir then
        local d = rec.attack_pos:Dist(rec.aim_pos)
        local smul = const.Combat.Aperture.CrosshairSigmaMul or 250
        draw_disc(rec.aim_pos, MulDivRound(rec.theta or 0, d, 3438), dir, clrSilh, 32)
        if rings then
            ---- sh.sigma ja vem com o recoil daquele disparo: os aneis mostram o cone abrindo
            for i, sh in ipairs(rec.shots) do
                draw_disc(rec.aim_pos, cone_radius(d, MulDivRound(sh.sigma or 0, smul, 100)), dir,
                          recoil_ring_color(i, total), 24)
            end
        else
            draw_disc(rec.aim_pos, cone_radius(d, MulDivRound(rec.sigma or 0, smul, 100)), dir,
                      clrCone, 32)
        end
    end

    for i, sh in ipairs(rec.shots) do
        local endpoint = sh.end_pos or sh.target_pos
        local color = sh.miss and clrMiss or clrHit
        DbgAddVector(rec.attack_pos, endpoint - rec.attack_pos, color)
        local spot = sh.spot and tostring(sh.spot) or "?"
        if not sh.miss then
            hits = hits + 1
            if sh.crit then
                crits = crits + 1
            end
            parts[spot] = (parts[spot] or 0) + 1
            if dir then
                draw_disc(endpoint, const.SlabSizeX / 14, dir, color, 8)
            end
        end
        DbgAddText(string.format("%d%s", i, sh.crit and " crit" or ""), endpoint, color)
        lines[#lines + 1] = string.format("  tiro %d | sigma %5d' | %s%s%s%s%s", i, sh.sigma or -1,
                                          sh.miss and "errou" or "ACERTOU",
                                          sh.miss and "" or
                                              string.format(" -> %s (crit %d%%)", spot,
                                                            sh.crit_chance or -1),
                                          sh.crit and " (critico)" or "",
                                          sh.damage and string.format("  dano %d", sh.damage) or "",
                                          ---- stray (-50% dano) em bala que cruzou o alvo = bug do leading_shot
                                          sh.stray and "  *** STRAY ***" or "")
    end

    local ps = {}
    for g, n in sorted_pairs(parts) do
        ps[#ps + 1] = string.format("    %-8s %2d  (%3d%% dos acertos | %3d%% do total)", g, n,
                                    MulDivRound(n, 100, Max(1, hits)),
                                    MulDivRound(n, 100, Max(1, total)))
    end
    if #ps == 0 then
        ps[1] = "    (nenhum acerto)"
    end

    local l = rec.lof_args or empty_table
    return string.format(
               "ultimo ataque REAL: %s (%s, %s) -> %s [%s]\n" ..
                   "  aim %s  alvo %s  |  CTH %s%%  <- %s\n" ..
                   "  theta %s'  sigma %s' (crua %s')  subida %s'/tiro (controle %s%%)  mira %s\n" ..
                   "  LoF: pen %s  range %s  ignore_los %s  clamp %s  covers %s  stuck_unit %s\n" ..
                   "       fire_rel %s  area_check %s  eye_contact %s  add_colliders %s  ignore %s\n" ..
                   "  %d/%d acertaram (%d%% do total) | %d erraram | %d criticos\n" ..
                   "  ciano = silhueta; %s\n" ..
                   "  distribuicao por membro:\n%s\n%s",
               tostring(rec.attacker and rec.attacker.session_id), tostring(rec.weapon_class),
               tostring(rec.action_id), tostring(rec.target and rec.target.session_id),
               tostring(rec.target and rec.target:GetHitStance()),
               tostring(rec.aim), tostring(rec.spot), tostring(rec.cth), tostring(rec.cth_source),
               tostring(rec.theta), tostring(rec.sigma), tostring(rec.geo_sigma),
               tostring(rec.climb), tostring(rec.control_chance), tostring(rec.aim_centroid_pct),
               tostring(l.penetration_class), tostring(l.range), tostring(l.ignore_los),
               tostring(l.clamp_to_target), tostring(l.can_use_covers),
               tostring(l.can_stuck_on_unit), tostring(l.fire_relative_point_attack),
               tostring(l.inside_attack_area_check), tostring(l.forced_hit_on_eye_contact),
               tostring(l.additional_colliders), tostring(l.n_ignore_colliders),
               hits, total, MulDivRound(hits, 100, Max(1, total)), total - hits, crits,
               rings and "um anel por tiro, amarelo (tiro 1) -> vermelho (ultimo) = recoil abrindo" or
                   "amarelo = 96% dos tiros do disparo 1 (Rat_DbgLastShots(true) = anel por tiro)",
               table.concat(ps, "\n"), table.concat(lines, "\n"))
end

---- VERIFICACAO: recalcula os insumos do ultimo tiro real pelo caminho do debug e compara campo a campo.
---- Pontos sorteados ficam de fora; compara o que DECIDE o sorteio (theta, sigma, subida, centro, origem, CTH) + args de LoF.
function Rat_DbgVerifySim()
    local rec = g_RatLastSimShots
    if not rec or not rec.shots or #rec.shots == 0 then
        return "nenhum tiro real registrado ainda (atire uma vez com A.SimulateShots = true)"
    end
    local attacker, target = rec.attacker, rec.target
    if not IsValid(attacker) or not IsValid(target) then
        return "atacante ou alvo do registro nao e mais valido"
    end

    local weapon = attacker:GetActiveWeapons()
    local action = CombatActions[rec.action_id] or attacker:GetDefaultAttackAction("ranged")

    local a = const.Combat.Aperture
    local was = a.Enabled
    a.Enabled = true

    local hard, soft, nhard, nsoft = {}, {}, 0, 0
    local function cmp(dst, name, real, mine, hard_check)
        local eq = (real == mine)
        if not eq then
            if hard_check then
                nhard = nhard + 1
            else
                nsoft = nsoft + 1
            end
        end
        dst[#dst + 1] = string.format("  %-22s %-26s %-26s %s", name, tostring(real), tostring(mine),
                                      eq and "ok" or "<<< DIFERE")
    end

    ---- BLOCO DURO: derivado so do snapshot (posicoes gravadas); divergencia aqui e bug
    local ra = rec.replay_args
    local debug_table = {}
    if ra and ra.lof and #ra.lof > 0 then
        debug_table.attack_pos = ra.lof[1].attack_pos
        debug_table.aim_pos = Rat_SimAimPos(ra.lof, rec.spot, rec.target_pos)
    end
    local _, geo_sigma, theta = Rat_AngularCTH(attacker, target, rec.spot, action, weapon, rec.aim,
                                               rec.opportunity_attack, rec.step_pos, rec.target_pos)
    debug_table.theta, debug_table.geo_sigma = theta, geo_sigma
    ---- pelo mesmo caminho do tiro real (CalcChanceToHit), nao mais invertendo o CTH final
    debug_table.sigma = Rat_AttackCone(attacker, target, action, rec.spot, rec.aim,
                                       rec.opportunity_attack, rec.step_pos, rec.target_pos) or
                            rec.geo_sigma
    local _, dbg_climb, dbg_chance = Rat_SimRecoilLadder(attacker, action, weapon, rec.sigma or 1,
                                                         rec.num_shots or 1)
    debug_table.climb, debug_table.control_chance = dbg_climb, dbg_chance

    hard[#hard + 1] = string.format("  %-22s %-26s %-26s", "campo", "tiro REAL", "caminho DEBUG")
    cmp(hard, "attack_pos", rec.attack_pos, debug_table.attack_pos, true)
    cmp(hard, "aim_pos", rec.aim_pos, debug_table.aim_pos, true)
    cmp(hard, "sigma (cone final)", rec.sigma, debug_table.sigma, true)
    cmp(hard, "subida (min/tiro)", rec.climb, debug_table.climb, true)
    cmp(hard, "controle (%)", rec.control_chance, debug_table.control_chance, true)
    cmp(hard, "theta", rec.theta, debug_table.theta, true)
    cmp(hard, "geo_sigma", rec.geo_sigma, debug_table.geo_sigma, true)

    ---- args reconstruidos: fallback de quando nao ha tiro real gravado; util saber quanto erram
    local recon = Rat_SimBaseArgs(attacker, target, weapon, rec.spot,
                                  (rec.lof_args or empty_table).range)
    local l = rec.lof_args or empty_table
    soft[#soft + 1] = string.format("  %-22s %-26s %-26s", "campo de LoF", "tiro REAL",
                                    "RECONSTRUIDO (fallback)")
    for _, k in ipairs({"penetration_class", "stance", "target_spot_group", "clamp_to_target",
                        "can_use_covers", "can_stuck_on_unit", "can_hit_attacker",
                        "force_hit_seen_target", "output_collisions", "aimIK"}) do
        cmp(soft, k, l[k], recon[k], false)
    end
    cmp(soft, "additional_colliders", l.additional_colliders,
        recon.additional_colliders and true or false, false)

    ---- BLOCO MOLE: recalculado no estado atual; diferenca e esperada se algo mudou desde o tiro
    local now_raw = attacker:CalcChanceToHit(target, action,
        {target_spot_group = rec.spot, aim = rec.aim, prediction = true,
         step_pos = attacker:GetPos(), target_pos = target:GetPos()})
    local now_cth = weapon:GetShotChanceToHit(now_raw) or now_raw
    local _, _, now_theta = Rat_AngularCTH(attacker, target, rec.spot, action, weapon, rec.aim,
                                           rec.opportunity_attack, attacker:GetPos(),
                                           target:GetPos())

    a.Enabled = was

    return string.format(
               "VERIFICACAO  %s -> %s  (args: %s)\n\n" ..
                   "[1] DERIVADO DO SNAPSHOT -- divergencia aqui e BUG de codigo\n%s\n" ..
                   "  => %s\n\n" ..
                   "[2] ARGS DE LoF: real x reconstruido -- so afeta quando NAO ha replay\n%s\n" ..
                   "  => %s\n\n" ..
                   "[3] ESTADO ATUAL DO MUNDO -- diferenca aqui e esperada se algo se moveu\n" ..
                   "  cth   no tiro %s%%   agora %s%%\n" ..
                   "  theta no tiro %s'   agora %s'\n" ..
                   "  postura do alvo no tiro: %s   agora: %s",
               tostring(attacker.session_id), tostring(target.session_id),
               ra and "replay do tiro real" or "SEM replay gravado",
               table.concat(hard, "\n"),
               nhard == 0 and "IDENTICOS: o debug simula o mesmo tiro que o jogo" or
                   (nhard .. " campo(s) divergem -- isto e bug"),
               table.concat(soft, "\n"),
               nsoft == 0 and "o fallback reproduz os args reais" or
                   (nsoft .. " campo(s) divergem nominalmente. Medido em 80 tiros, os cinco " ..
                       "campos que\n     divergem hoje (clamp_to_target, can_stuck_on_unit, " ..
                       "can_hit_attacker,\n     force_hit_seen_target, aimIK) sao INERTES quando " ..
                       "se atira num PONTO, que\n     e o caso da simulacao: 80% de acerto nos " ..
                       "tres conjuntos. Ainda assim,\n     prefira o replay -- a inercia vale " ..
                       "para este caminho, nao por principio."),
               tostring(rec.cth), tostring(now_cth), tostring(rec.theta), tostring(now_theta),
               tostring((rec.lof_args or empty_table).stance), tostring(target:GetHitStance()))
end

---- SILHUETA PROJETADA REAL. Grade 2D no plano perpendicular ao tiro, conta o que a colisao aceita
---- (penetration_class = 0). Reporta area, raio equivalente (numero de A.Silhouette) e centro real vs mirado (A.AimCentroidPct).
function Rat_DbgSilhouette(target, attacker, body_part, half_cm, steps)
    attacker = pick_attacker(attacker)
    if not attacker then
        return "sem atacante (selecione um merc)"
    end
    target = pick_target(attacker, target)
    if not target then
        return "sem alvo"
    end
    body_part = body_part or g_DefaultShotBodyPart or "Torso"
    half_cm = half_cm or 90 --- meia-largura da varredura, em cm
    steps = steps or 10 --- 10 => grade 21x21 = 441 raios

    local weapon = attacker:GetActiveWeapons()
    local base = GetLoFData(attacker, target, {
        obj = attacker, weapon = weapon, stance = attacker.stance,
        prediction = true, output_collisions = true, force_hit_seen_target = false
    })
    if not base or not base.lof or #base.lof == 0 then
        return "sem linha de tiro"
    end
    local attack_pos = base.lof[1].attack_pos
    local aim_pos = Rat_SimAimPos(base.lof, body_part, base.lof[1].target_pos)

    local dist = attack_pos:Dist(aim_pos)
    local dir = SetLen(aim_pos - attack_pos, 1000)
    local up = point(0, 0, 1000)
    local par = Dot(up, dir) / 1000
    local vert = up - MulDivRound(dir, par, 1000)
    if vert:Len() < 10 then
        vert = point(-dir:y(), dir:x(), 0)
    end
    vert = SetLen(vert, 1000)
    local horiz = SetLen(point(-dir:y(), dir:x(), 0), 1000)

    local cell = half_cm * 10 / steps --- lado da celula, em unidades do engine
    local pts, meta, n = {}, {}, 0
    for iy = -steps, steps do
        for ix = -steps, steps do
            n = n + 1
            pts[n] = aim_pos + MulDivRound(horiz, ix * cell, 1000) +
                         MulDivRound(vert, iy * cell, 1000)
            meta[n] = {x = ix, y = iy}
        end
    end

    local lof_args = {
        obj = attacker, weapon = weapon, stance = attacker.stance, attack_pos = attack_pos,
        output_collisions = true, range = dist + 20 * const.SlabSizeX,
        penetration_class = 0, prediction = true, clamp_to_target = false,
        fire_relative_point_attack = false, can_hit_attacker = false, ignore_los = true,
        inside_attack_area_check = false, forced_hit_on_eye_contact = false,
        can_use_covers = false, aimIK = false, can_stuck_on_unit = true,
        force_hit_seen_target = false, seed = 0
    }

    local data = GetLoFData(attacker, pts, lof_args)
    local hit_n, sx, sy = 0, 0, 0
    local minx, maxx, miny, maxy
    local grid = {}
    for i, d in ipairs(data or empty_table) do
        local ok = Rat_SimHitSpot(Rat_SimLoF(d), target)
        grid[i] = ok
        if ok then
            local m = meta[i]
            hit_n = hit_n + 1
            sx, sy = sx + m.x, sy + m.y
            minx = (not minx or m.x < minx) and m.x or minx
            maxx = (not maxx or m.x > maxx) and m.x or maxx
            miny = (not miny or m.y < miny) and m.y or miny
            maxy = (not maxy or m.y > maxy) and m.y or maxy
        end
    end

    if hit_n == 0 then
        return string.format("%s -> %s: nenhum raio da grade acertou (alvo totalmente ocluido?)",
                             tostring(attacker.session_id), tostring(target.session_id))
    end

    local cell_cm = half_cm / steps
    local area_cm2 = hit_n * cell_cm * cell_cm
    ---- raio equivalente: o disco de mesma AREA, que e o que theta modela
    local r_eq = Rat_ISqrt(MulDivRound(area_cm2, 100, 314)) --- sqrt(area/pi)
    local cx_cm = MulDivRound(sx, cell_cm, hit_n)
    local cy_cm = MulDivRound(sy, cell_cm, hit_n)

    ---- desenho: verde onde a colisao aceita, cruz no centro real
    DbgClearVectors()
    DbgClearTexts()
    for i, ok in pairs(grid) do
        if ok then
            DbgAddVector(pts[i], MulDivRound(dir, 200, 1000), clrHit)
        end
    end
    local centro = aim_pos + MulDivRound(horiz, cx_cm * 10, 1000) +
                       MulDivRound(vert, cy_cm * 10, 1000)
    draw_disc(centro, r_eq * 10, dir, clrCone, 32)
    DbgAddText("centro real", centro, clrCone)
    DbgAddText("mirado", aim_pos, clrAxis)

    local modelo = Rat_TargetSilhouette(target, body_part, 100)
    ---- penetration_class = 0: a grade mede silhueta E cobertura juntas -> so calibra A.Silhouette com alvo a descoberto
    local expo = Rat_MeasureExposure(attacker, target, attacker:GetPos(), target:GetPos(),
                                     body_part, weapon)
    ---- limite da varredura: se o corpo encosta na borda, a area esta truncada
    local clipped = (minx <= -steps) or (maxx >= steps) or (miny <= -steps) or (maxy >= steps)

    return string.format(
               "%s -> %s [%s] a %.1f tiles, parte %s  (grade %dx%d, celula %.1fcm)\n" ..
                   "  extensao: %d..%dcm horizontal   %d..%dcm vertical%s\n" ..
                   "  area projetada %d cm2  =>  raio equivalente %dcm\n" ..
                   "  A.Silhouette atual para esta postura: %dcm  (%+d%%)\n" ..
                   "  centro real vs ponto mirado: %+dcm lateral, %+dcm vertical\n" ..
                   "  exposicao %d%%%s\n" ..
                   "  verde = colisao aceita, amarelo = disco de area equivalente",
               tostring(attacker.session_id), tostring(target.session_id),
               tostring(target:GetHitStance()), attacker:GetDist(target) / const.SlabSizeX,
               tostring(body_part), 2 * steps + 1, 2 * steps + 1, cell_cm,
               minx * cell_cm, maxx * cell_cm, miny * cell_cm, maxy * cell_cm,
               clipped and "   *** TRUNCADO: aumente half_cm ***" or "",
               area_cm2, r_eq, modelo, MulDivRound(modelo - r_eq, 100, Max(1, r_eq)),
               cx_cm, cy_cm, expo,
               expo < 100 and "  *** NAO SERVE PARA CALIBRAR: alvo em cobertura ***" or
                   "  (a descoberto -- serve para calibrar)")
end

---- Calibracao de A.Silhouette: mede todos os inimigos e resume por postura (so 100% expostos, nao truncados).
---- Rode em varias posicoes: raio equivalente que varia com a distancia = mudanca no angulo de visada.
function Rat_DbgSilhouetteCalib(attacker, body_part)
    attacker = pick_attacker(attacker)
    if not attacker then
        return "sem atacante (selecione um merc)"
    end
    body_part = body_part or g_DefaultShotBodyPart or "Torso"

    local by_stance, lines = {}, {}
    local n_ok, n_skip = 0, 0
    for _, o in ipairs(g_Units or empty_table) do
        if o ~= attacker and not o:IsDead() and attacker:IsOnEnemySide(o) then
            local txt = Rat_DbgSilhouette(o, attacker, body_part, 120, 12)
            local r = tonumber(txt:match("raio equivalente (%d+)cm"))
            local expo = tonumber(txt:match("exposicao (%d+)%%"))
            local trunc = txt:find("TRUNCADO") and true or false
            local st = tostring(o:GetHitStance())
            local d = attacker:GetDist(o) / const.SlabSizeX
            if r and expo == 100 and not trunc then
                by_stance[st] = by_stance[st] or {}
                table.insert(by_stance[st], r)
                n_ok = n_ok + 1
                lines[#lines + 1] = string.format("  %-30s %-8s %4.1ft  r_eq %2dcm",
                                                  tostring(o.session_id):sub(-30), st, d, r)
            else
                n_skip = n_skip + 1
                lines[#lines + 1] = string.format("  %-30s %-8s %4.1ft  ignorado (%s)",
                                                  tostring(o.session_id):sub(-30), st, d,
                                                  not r and "sem raio" or
                                                      (trunc and "truncado" or
                                                          ("exposicao " .. tostring(expo) .. "%")))
            end
        end
    end

    local sum = {}
    for st, rs in sorted_pairs(by_stance) do
        local s = 0
        for _, r in ipairs(rs) do
            s = s + r
        end
        local media = s / #rs
        sum[#sum + 1] = string.format("  %-9s medido %2dcm (%d amostra%s)  |  A.Silhouette = %2dcm  (%+d%%)",
                                      st, media, #rs, #rs > 1 and "s" or "",
                                      const.Combat.Aperture.Silhouette[st] or -1,
                                      MulDivRound((const.Combat.Aperture.Silhouette[st] or 0) - media,
                                                  100, Max(1, media)))
    end
    if #sum == 0 then
        sum[1] = "  (nenhum alvo a descoberto: aproxime-se ou saia da cobertura)"
    end

    return string.format("CALIBRACAO DE SILHUETA (parte %s)  --  %d usaveis, %d ignorados\n%s\n\n" ..
                             "resumo por postura:\n%s\n\n" ..
                             "  So alvos 100%% expostos entram. Junte medidas de varias posicoes\n" ..
                             "  antes de mexer em A.Silhouette -- uma amostra so nao calibra nada.",
                         tostring(body_part), n_ok, n_skip, table.concat(lines, "\n"),
                         table.concat(sum, "\n"))
end

---------------------------------------------------------------------------------------------------
---- RECUO SOB O CURSOR. Rat_DbgRecoilMouse() liga/desliga o modo que segue o mouse;
---- Rat_DbgRecoilAt() desenha uma vez no ponto atual.
---- Mira em QUALQUER ponto -- subida e controle nao dependem do alvo, so a distancia, que o cursor
---- ja da. Havendo unidade sob o cursor entram tambem theta, o cone e o CTH por tiro.
---- Dois modos. O MODELO (Rat_DbgRecoilAt) nao consome random: em vez de sortear uma rajada,
---- desenha o leque de eixos possiveis (+/- A.RecoilWalkYaw) e a escada de mu nos tres ramos
---- deterministicos -- nunca segurou, esperado, sempre segurou. A RAJADA (Rat_DbgRecoilShots)
---- sorteia de verdade e desenha um vetor por bala; consome random sincronizado, entao no modo
---- mouse ela so e re-sorteada quando o cursor anda.
---------------------------------------------------------------------------------------------------

g_RatDbgRecoilThread = false

---- v * pct / 100 preservando o sinal: o passo segurado e negativo quando a correcao supera o residual
local function scale_pct(v, pct)
    if v >= 0 then
        return MulDivRound(v, pct, 100)
    end
    return -MulDivRound(-v, pct, 100)
end

---- Unidade sob o ponto do cursor. GetCursorPos ja encosta o ponto na malha, entao basta a
---- vizinhanca do pe da unidade mais o vao vertical do corpo.
local function unit_under(pos, attacker)
    local best, best_d
    for _, o in ipairs(g_Units or empty_table) do
        if o ~= attacker and not o:IsDead() then
            local p = vz(o:GetVisualPos())
            local d = p:Dist2D(pos)
            if d < const.SlabSizeX * 3 / 4 and abs(pos:z() - p:z()) < 3 * const.SlabSizeZ and
                (not best_d or d < best_d) then
                best, best_d = o, d
            end
        end
    end
    return best
end

---- Acao inspecionada: a do crosshair aberto (e o que o jogador esta olhando), senao o ataque padrao.
local function pick_action(attacker, action_id)
    if action_id then
        return CombatActions[action_id]
    end
    local igi = GetInGameInterfaceModeDlg and GetInGameInterfaceModeDlg()
    local ch = igi and igi.crosshair and igi.crosshair.context
    return (ch and ch.action) or attacker:GetDefaultAttackAction("ranged")
end

---------------------------------------------------------------------------------------------------
---- OVERRIDES. Substituem o que a cadeia tunada entregaria, para isolar UM lever:
----   climb   subida do cano em minutos/tiro (o recuo da arma)
----   chance  chance de segurar em % -- 0 = sem controle nenhum, 100 = segura sempre
----   control fracao do recuo NAO cancelada (0.85 tipico), mapeada por Rat_RecoilHoldChance;
----           `chance` ganha se os dois vierem
----   sigma   cone em minutos    theta  meia-largura do alvo em minutos
---- theta/sigma destravam a escada de CTH em pontos SEM alvo, onde ela nao existiria.
----
---- So estes cinco de proposito: todos sao PARAMETROS de Rat_BurstShotCTH, entao o CTH acompanha
---- o what-if. RecoilControlResidual, RecoilCorrectPct e RecoilWalkYaw ficaram de fora porque sao
---- params globais -- so dariam para sobrescrever mutando const.Combat.Aperture, e ai a escada de
---- CTH (que le o global por dentro) ignoraria o override e mostraria numero de outro cenario.
---------------------------------------------------------------------------------------------------

---- Console: as funcoes aceitam posicional OU uma tabela unica -- Rat_DbgRecoilShots{burst = 10,
---- chance = 0}. Um ponto do engine nao e tabela Lua, entao a deteccao nao confunde com `pos`.
local function is_opts(v)
    return type(v) == "table" and not IsPoint(v)
end

local function apply_over(over, climb, chance, sigma, theta)
    if not over then
        return climb, chance, sigma, theta
    end
    if over.chance then
        chance = over.chance
    elseif over.control then
        chance = Rat_RecoilHoldChance(over.control)
    end
    return over.climb or climb, chance, over.sigma or sigma, over.theta or theta
end

---- Sem esta linha um what-if passa por medicao.
local function over_line(over)
    if not over then
        return nil
    end
    local ks = {}
    for _, k in ipairs({"climb", "chance", "control", "sigma", "theta"}) do
        if over[k] then
            ks[#ks + 1] = k .. " = " .. tostring(over[k])
        end
    end
    return (#ks > 0) and ("*** OVERRIDE: " .. table.concat(ks, ", ") ..
               " -- nao e o que esta arma faz ***") or nil
end

---- Traco atravessado no eixo: marca um degrau da escada sem o peso de um disco inteiro.
local function draw_tick(pt, dir, axis, len, color)
    local h = SetLen(RotateAxis(axis, dir, 90 * 60), len)
    DbgAddSegment(pt - h, pt + h, color)
end

---- Cena comum aos dois visualizadores de recuo: quem atira, para onde, e de onde a bala sai.
---- Devolve a tabela ou nil + a razao.
local function recoil_scene(pos, burst, aim, action_id, attacker)
    attacker = pick_attacker(attacker)
    if not attacker then
        return nil, "sem atacante (selecione um merc)"
    end
    local weapon = attacker:GetActiveWeapons()
    if not IsKindOf(weapon, "Firearm") then
        return nil, "arma ativa nao e de fogo"
    end

    pos = Rat_ValidZ(pos or GetCursorPos())
    if not pos then
        return nil, "sem ponto sob o cursor"
    end

    local action = pick_action(attacker, action_id)
    if not action then
        return nil, "sem acao de ataque"
    end

    local spot = g_DefaultShotBodyPart or "Torso"
    local target = unit_under(pos, attacker)

    local base = GetLoFData(attacker, target or pos, {
        obj = attacker, weapon = weapon, stance = attacker.stance,
        prediction = true, output_collisions = true, force_hit_seen_target = false
    })
    local lof = base and base.lof
    if not lof or #lof == 0 then
        return nil, "sem linha de tiro ate o cursor"
    end
    local attack_pos = Rat_ValidZ(lof[1].attack_pos)
    ---- com alvo, o ponto de mira e o mesmo que a bala usa (Rat_SimAimPos); sem alvo, o cursor cru
    local aim_pos = target and Rat_ValidZ(Rat_SimAimPos(lof, spot, lof[1].target_pos)) or pos

    local dist = attack_pos:Dist(aim_pos)
    if dist < 1 then
        return nil, "cursor em cima do atirador"
    end

    return {
        attacker = attacker, weapon = weapon, action = action, target = target, spot = spot,
        burst = Max(2, burst or 3), aim = aim or 3,
        attack_pos = attack_pos, aim_pos = aim_pos, dist = dist,
        dir = SetLen(aim_pos - attack_pos, 1000)
    }
end

---- Rat_DbgRecoilAt(pos, burst, aim, action_id, attacker, over) ou Rat_DbgRecoilAt{burst=..., ...}
---- Devolve o resumo e um segundo valor `ok` -- o modo mouse usa `ok` para limpar quando o ponto
---- deixa de ser desenhavel, senao o desenho velho fica congelado na tela mentindo.
function Rat_DbgRecoilAt(pos, burst, aim, action_id, attacker, over)
    if is_opts(pos) then
        local o = pos
        pos, burst, aim, action_id, attacker, over = o.pos, o.burst, o.aim, o.action_id, o.attacker,
                                                     o
    end
    local sc, err = recoil_scene(pos, burst, aim, action_id, attacker)
    if not sc then
        return err
    end
    local a = const.Combat.Aperture
    local attacker, weapon, action = sc.attacker, sc.weapon, sc.action
    local target, spot = sc.target, sc.spot
    local attack_pos, aim_pos, dist, dir = sc.attack_pos, sc.aim_pos, sc.dist, sc.dir
    burst, aim = sc.burst, sc.aim

    ---- cone e CTH normalmente so existem contra um alvo -- e theta que da escala ao desvio.
    ---- Os overrides destravam os dois em qualquer ponto.
    local sigma, theta, cth = nil, nil, {}
    if target then
        sigma, theta = Rat_AttackCone(attacker, target, action, spot, aim, false, attacker:GetPos(),
                                      target:GetPos())
    end

    local climb, chance = Rat_GetRecoilClimb(attacker, action, weapon, burst)
    climb, chance, sigma, theta = apply_over(over, climb, chance, sigma, theta)

    local held = Rat_RecoilHeldStep(climb)
    local step_avg = scale_pct(climb, 100 - chance) + scale_pct(held, chance)
    local max_idx = const.Combat.MaxShotIndexForRecoilCTHLoss or 6

    if theta and theta >= 1 and sigma and sigma >= 1 then
        for i = 1, burst do
            cth[i] = Rat_BurstShotCTH(theta, sigma, i - 1, climb, chance)
        end
    end

    ---- DERIVA por ramo: so E[cos phi] do passo empurra o cano, e so ate max_idx coices.
    ---- ESPALHAMENTO: o resto do coice, que nao tem direcao preferida -- cresce com a raiz do
    ---- numero de coices e nao para no plato, porque chacoalhar nao e derivar.
    local cbar, spread = Rat_RecoilYawFactors()
    local s2bar = MulDivRound(held * held, chance, 100) +
                      MulDivRound(climb * climb, 100 - chance, 100)
    local mu_hi, mu_avg, mu_lo, band = {}, {}, {}, {}
    local h, v, l = 0, 0, 0
    for i = 1, burst do
        mu_hi[i], mu_avg[i], mu_lo[i] = h, v, l
        band[i] = Rat_ISqrt(MulDivRound((i - 1) * s2bar, spread, 1000))
        if i <= max_idx then
            h = h + MulDivRound(climb, cbar, 1000)
            v = v + MulDivRound(step_avg, cbar, 1000)
            l = l + MulDivRound(held, cbar, 1000)
        end
    end

    DbgClearVectors()
    DbgClearTexts()
    DbgAddSegment(attack_pos, aim_pos, clrAxis)

    local up = SetLen(Rat_PerpUp(dir), 1000)
    local yaw = Clamp(a.RecoilWalkYaw or 0, 0, 180) * 60

    ---- leque: a faixa de direcoes que CADA coice pode tomar (+/- RecoilWalkYaw). Nao e mais um
    ---- eixo por rajada -- e sorteado a cada coice, e e dai que sai a largura do grupo.
    local tip = cone_radius(dist, Max(mu_hi[burst], 1))
    if tip > 0 then
        DbgAddVector(aim_pos, SetLen(up, tip), clrCone)
        if yaw > 0 then
            DbgAddVector(aim_pos, SetLen(RotateAxis(up, dir, -yaw), tip), clrSilh)
            DbgAddVector(aim_pos, SetLen(RotateAxis(up, dir, yaw), tip), clrSilh)
        end
    end

    ---- silhueta do alvo: a referencia contra a qual a subida vale ou nao
    if theta and theta >= 1 then
        draw_disc(aim_pos, cone_radius(dist, theta), dir, clrSilh, 32)
    end

    ---- degraus: disco numerado na DERIVA esperada, traco nos dois extremos da deriva, e a barra
    ---- horizontal do ESPALHAMENTO (+/-1 desvio) naquela altura -- e a largura do grupo ali.
    local tick = Max(150, dist / 40)
    local lat_ax = Rat_RecoilLateralAxis(up, dir)
    local disp = sigma and cone_radius(dist, MulDivRound(sigma, a.CrosshairSigmaMul or 250, 100))
    for i = 1, burst do
        local c = recoil_ring_color(i, burst)
        local p_avg = Rat_RecoilWalkPoint(attack_pos, aim_pos, up, mu_avg[i])
        if disp and disp > 0 then
            draw_disc(p_avg, disp, dir, c, 24)
        end
        ---- os extremos sao da DERIVA; passado o plato ela para e os tres ramos ficam parados
        if i <= max_idx + 1 then
            draw_tick(Rat_RecoilWalkPoint(attack_pos, aim_pos, up, mu_hi[i]), dir, up, tick, clrMiss)
            draw_tick(Rat_RecoilWalkPoint(attack_pos, aim_pos, up, mu_lo[i]), dir, up, tick, clrHit)
        end
        if lat_ax and band[i] > 0 then
            DbgAddSegment(Rat_RecoilWalkPoint(attack_pos, aim_pos, up, mu_avg[i], lat_ax, band[i]),
                          Rat_RecoilWalkPoint(attack_pos, aim_pos, up, mu_avg[i], lat_ax, -band[i]),
                          c)
        end
        DbgAddText(tostring(i), p_avg, c)
    end

    local t10 = MulDivRound(dist, 10, const.SlabSizeX)
    local lines = {
        string.format("%s (%s) -- %s, aim %d, rajada de %d, %d.%d tiles",
                      tostring(attacker.session_id), tostring(weapon.class), tostring(action.id),
                      aim, burst, t10 / 10, t10 % 10),
        string.format(
            "subida %d'/tiro   segura %d%%   passo segurado %+d'   cano sobe ate o tiro %d",
            climb, chance, held, max_idx + 1),
        string.format(
            "mu no tiro %d:  nunca segura %d' (%dcm)   esperado %d' (%dcm)   sempre segura %d' (%dcm)",
            burst, mu_hi[burst], cone_radius(dist, mu_hi[burst]) / 10, mu_avg[burst],
            cone_radius(dist, mu_avg[burst]) / 10, mu_lo[burst],
            cone_radius(dist, mu_lo[burst]) / 10)
    }
    lines[#lines + 1] = string.format(
                            "yaw +/-%d graus por coice: so %d%% do passo vira deriva, o resto vira " ..
                                "espalhamento -- +/-%d' (%dcm) no tiro %d   |   a deriva trava no tiro %d",
                            a.RecoilWalkYaw or 0, cbar / 10, band[burst],
                            cone_radius(dist, band[burst]) / 10, burst, max_idx + 1)
    if theta and sigma then
        local cs = {}
        for i = 1, burst do
            cs[i] = tostring(cth[i] or "-")
        end
        lines[#lines + 1] = string.format("alvo %s   theta %d'   cone %d'   CTH por tiro: %s%%",
                                          target and (tostring(target.session_id) .. " [" ..
                                              tostring(target:GetHitStance()) .. "]") or
                                              "(theta de override)", theta, sigma,
                                          table.concat(cs, "/"))
    else
        lines[#lines + 1] =
            "sem unidade sob o cursor: so a geometria do recuo (passe theta e sigma para ver CTH aqui)"
    end
    lines[#lines + 1] = over_line(over)
    lines[#lines + 1] =
        "amarelo->vermelho = tiro 1..N na deriva esperada | traco vermelho nunca segura, verde sempre | " ..
            "ciano = leque de direcao do coice | barra horizontal = espalhamento (+/-1 desvio)"

    for i, s in ipairs(lines) do
        DbgAddText(s, aim_pos:SetZ(aim_pos:z() + (#lines - i + 2) * 300), clrAxis)
    end

    return table.concat(lines, "\n"), true
end

---- Rat_DbgRecoilShots(burst, aim, scatter, pos, action_id, attacker)
---- UMA rajada de verdade, sorteada com a arma e a pericia de quem esta selecionado: um vetor por
---- tiro, do cano ate onde a bala para. O tiro 1 vai EXATO no ponto apontado -- e a referencia
---- contra a qual os coices se leem; com `scatter` o cone da arma tambem entra e ele deixa de ser
---- exato (a rajada completa, como o jogo dispara). Sem alvo sob o cursor o cone e o de
---- Rat_GetAperture, sem os residuais -- que exigem alvo.
---- Aceita tambem uma tabela unica: Rat_DbgRecoilShots{burst = 10, chance = 0, scatter = true}.
---- ATENCAO: consome random sincronizado; em co-op nao use no turno de outro jogador.
function Rat_DbgRecoilShots(burst, aim, scatter, pos, action_id, attacker, over)
    if is_opts(burst) then
        local o = burst
        burst, aim, scatter, pos, action_id, attacker, over = o.burst, o.aim, o.scatter, o.pos,
                                                              o.action_id, o.attacker, o
    end
    local sc, err = recoil_scene(pos, burst, aim, action_id, attacker)
    if not sc then
        return err
    end
    local a = const.Combat.Aperture
    local was = a.Enabled
    a.Enabled = true

    local attacker, weapon, action, target = sc.attacker, sc.weapon, sc.action, sc.target
    local attack_pos, aim_pos, dist, dir = sc.attack_pos, sc.aim_pos, sc.dist, sc.dir
    burst, aim = sc.burst, sc.aim

    ---- com alvo, o cone final (residuais dentro); sem alvo, so a abertura de arma + pericia
    local sigma, theta
    if target then
        sigma, theta = Rat_AttackCone(attacker, target, action, sc.spot, aim, false,
                                      attacker:GetPos(), target:GetPos())
    end
    local cone_src = sigma and "cone final" or "abertura crua (sem residuais)"
    sigma = sigma or Rat_GetAperture(weapon, attacker, action, aim, false)

    local climb, chance = Rat_GetRecoilClimb(attacker, action, weapon, burst)
    climb, chance, sigma, theta = apply_over(over, climb, chance, sigma, theta)
    if over and over.sigma then
        cone_src = "override"
    end

    local held_step = Rat_RecoilHeldStep(climb)
    local max_idx = const.Combat.MaxShotIndexForRecoilCTHLoss or 6

    ---- UM eixo para a rajada inteira, como no tiro real: e o que faz o grupo virar risco
    local axis = Rat_RecoilWalkAxis(attacker, attack_pos, aim_pos)
    local lat_ax = Rat_RecoilLateralAxis(axis, dir)
    local args = Rat_SimBaseArgs(attacker, target, weapon, sc.spot, dist + 20 * const.SlabSizeX)

    DbgClearVectors()
    DbgClearTexts()
    if theta and theta >= 1 then
        draw_disc(aim_pos, cone_radius(dist, theta), dir, clrSilh, 32)
    end

    local cbar = Rat_RecoilYawFactors()
    local mu, lat, rows, nhit, nheld = 0, 0, {}, 0, 0
    for i = 1, burst do
        local mu_i, lat_i = mu, lat
        local aimed = Rat_RecoilWalkPoint(attack_pos, aim_pos, axis, mu, lat_ax, lat)
        if scatter and sigma and sigma >= 1 then
            aimed = Rat_ShotScatterPoint(attacker, attack_pos, aimed, sigma)
        end

        Rat_SimLoFOverrides(args, attack_pos, attacker:Random(), args.ignore_colliders)
        local lof = Rat_SimLoF(GetLoFData(attacker, aimed, args))
        local end_pos = (lof and (lof.stuck_pos or lof.lof_pos2)) or aimed

        local hit, part
        if target then
            hit, part = Rat_SimHitSpot(lof, target)
            if hit then
                nhit = nhit + 1
            end
        end

        local c = recoil_ring_color(i, burst)
        DbgAddVector(attack_pos, end_pos - attack_pos, c)
        DbgAddText(tostring(i), end_pos, target and (hit and clrHit or clrMiss) or c)

        ---- MESMA funcao que a bala usa: passado o plato so a deriva e descontada, o cano segue
        ---- sendo chacoalhado nos dois eixos.
        local dv, dl, step, held = Rat_RecoilKick(attacker, climb, chance)
        if held then
            nheld = nheld + 1
        end
        mu = mu + dv - ((i > max_idx) and MulDivRound(step, cbar, 1000) or 0)
        lat = lat + dl
        rows[#rows + 1] = string.format("    %2d  | %+6d' | %+6d' | %-12s | %s", i, mu_i, lat_i,
                                        (i > max_idx) and "so chacoalha" or
                                            (held and "segurou" or "subiu"),
                                        target and (hit and ("acerto " .. tostring(part or "?")) or
                                            "erro") or "-")
    end

    local t10 = MulDivRound(dist, 10, const.SlabSizeX)
    local lines = {
        string.format("%s (%s) -- %s, aim %d, rajada de %d, %d.%d tiles",
                      tostring(attacker.session_id), tostring(weapon.class), tostring(action.id),
                      aim, burst, t10 / 10, t10 % 10),
        string.format("subida %d'/tiro   segura %d%%   passo segurado %+d'   segurou %d de %d",
                      climb, chance, held_step, nheld, burst),
        string.format("cone %d' (%s)   %s", sigma, cone_src,
                      scatter and "dispersao LIGADA: o tiro 1 tambem sai do centro" or
                          "dispersao desligada: so o passeio do cano"),
        string.format("yaw +/-%d graus por coice (%d%% do passo vira deriva); a deriva trava no %d",
                      a.RecoilWalkYaw or 0, cbar / 10, max_idx + 1),
        "    tiro |     mu | lateral | coice        | resultado", table.concat(rows, "\n")
    }
    if target then
        lines[#lines + 1] = string.format("alvo %s [%s]   theta %d'   %d de %d acertos",
                                          tostring(target.session_id),
                                          tostring(target:GetHitStance()), theta or -1, nhit, burst)
    else
        lines[#lines + 1] = "sem unidade sob o cursor: nao ha o que acertar, so a geometria"
    end
    lines[#lines + 1] = over_line(over)

    for i, s in ipairs(lines) do
        DbgAddText(s, aim_pos:SetZ(aim_pos:z() + (#lines - i + 2) * 300), clrAxis)
    end

    a.Enabled = was
    return table.concat(lines, "\n"), true
end

---- Liga/desliga o modo que segue o mouse. Aceita tabela unica -- Rat_DbgRecoilMouse{shots = true,
---- chance = 0}. Posicional: Rat_DbgRecoilMouse(burst, aim, action_id, shots, scatter, over):
---- sem `shots` desenha o modelo deterministico, previsao pura (um raycast de LoF por quadro, o mesmo
---- que o crosshair ja faz) -- nao encosta no random. Com `shots` desenha rajadas sorteadas de
---- verdade, e ai SIM consome random sincronizado.
function Rat_DbgRecoilMouse(burst, aim, action_id, shots, scatter, over)
    if IsValidThread(g_RatDbgRecoilThread) then
        DeleteThread(g_RatDbgRecoilThread)
        g_RatDbgRecoilThread = false
        Rat_DbgClear()
        return "recuo sob o cursor: DESLIGADO"
    end
    if burst == false then
        return "recuo sob o cursor: ja estava desligado"
    end
    if is_opts(burst) then
        local o = burst
        burst, aim, action_id, shots, scatter, over = o.burst, o.aim, o.action_id, o.shots,
                                                      o.scatter, o
    end

    g_RatDbgRecoilThread = CreateRealTimeThread(function()
        ---- em modo `shots` a rajada so e re-sorteada quando o cursor anda meio tile: sortear a 10 Hz
        ---- queimaria random sincronizado a toa e o desenho piscaria em vez de poder ser lido.
        local last
        while true do
            local pos = Rat_ValidZ(GetCursorPos())
            if not shots or not last or not pos or pos:Dist(last) > const.SlabSizeX / 2 then
                local txt, ok
                if shots then
                    txt, ok = Rat_DbgRecoilShots(burst, aim, scatter, pos, action_id, nil, over)
                else
                    txt, ok = Rat_DbgRecoilAt(pos, burst, aim, action_id, nil, over)
                end
                if not ok then
                    DbgClearVectors()
                    DbgClearTexts()
                end
                last = ok and pos or nil
            end
            Sleep(100)
        end
    end)
    return shots and
               "rajada sob o cursor: LIGADA -- re-sorteia quando o cursor anda. Chame de novo para desligar." or
               "recuo sob o cursor: LIGADO -- aponte o mouse. Chame de novo para desligar."
end

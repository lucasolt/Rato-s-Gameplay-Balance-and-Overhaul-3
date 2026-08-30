---------------------------------------------------------------------------------------------------
---- COBERTURA POR SILHUETA OCLUIDA
----
---- Substitui a consulta de cobertura por voxel + escada de 3 degraus por uma
---- MEDICAO: dispara uma grade de raios contra pontos fixos do corpo do alvo e
---- conta quantos chegam. A fracao que chega e a silhueta que o atirador ve.
----
---- O que o modelo antigo jogava fora:
----   Cover.lua:283      -- low cover com alvo EM PE simplesmente nao existia
----   Unit.lua:8701      -- InterpolateCoverEffect esmaga a % numa escada: abaixo
----                         de 40 e acima de 80 tudo vira o mesmo numero
----   CTH_cover_prone.lua:2 -- e o resultado virava -35 flat, igual a 4 ou 28 tiles
----
---- Cobertura nao sabia de onde se atirava nem por qual angulo. Aqui sabe de graca:
---- atirar de cima faz os raios passarem por cima do muro, flanquear expoe mais
---- silhueta, e mirar a cabeca de quem esta atras do muro deixa de ser um
---- percentual -- os raios daquela regiao simplesmente nao chegam.
----
---- SEGURANCA DE REDE: os pontos de sondagem sao FIXOS e deterministicos. Nao
---- consomem attacker:Random, entao rodam em previsao (crosshair, IA) sem risco de
---- desync -- o aviso de SOURCE_FirearmGetAttackResults.lua:491 e sobre random
---- sincronizado, nao sobre raycast. Toda a grade vai em UMA chamada de GetLoFData
---- (a funcao aceita lista de alvos), como CalcShotVectors e GetPelletScatterData
---- ja fazem.
---------------------------------------------------------------------------------------------------

local A
local function P()
    A = A or const.Combat.Aperture
    return A
end

---------------------------------------------------------------------------------------------------
---- Cache
----
---- A IA (AIPrecalcConeTargetZones, CombatAI.lua:2040) avalia muitas posicoes por
---- turno e o crosshair reconsulta a cada frame de hover. Sem cache a sondagem
---- seria cara nos dois. A chave inclui as duas posicoes e a postura do alvo, entao
---- qualquer movimento invalida sozinho; a geracao cobre o resto (cobertura
---- destruida, mudanca de setor).
---------------------------------------------------------------------------------------------------

local exposure_cache = {}
local cache_gen = 0
local cache_count = 0
local CACHE_MAX = 4096

function Rat_InvalidateExposureCache()
    exposure_cache = {}
    cache_count = 0
    cache_gen = cache_gen + 1
end

function OnMsg.NewMap()
    Rat_InvalidateExposureCache()
end
function OnMsg.EnterSector()
    Rat_InvalidateExposureCache()
end
function OnMsg.CombatEnd()
    Rat_InvalidateExposureCache()
end
function OnMsg.TurnStart()
    Rat_InvalidateExposureCache()
end
---- cobertura destruida muda o que os raios atravessam
function OnMsg.CombatObjectDied()
    Rat_InvalidateExposureCache()
end
function OnMsg.ObjModified()
    Rat_InvalidateExposureCache()
end

---------------------------------------------------------------------------------------------------
---- Medicao
---------------------------------------------------------------------------------------------------

---- Fracao (0..100) da silhueta do alvo que o atirador enxerga a partir de
---- attacker_pos. `body_part` limita a sondagem aquela regiao do corpo.
----
---- `dbg_table`, quando presente, e uma tabela que a funcao preenche com o detalhe de cada
---- raio (origem, destino, se chegou, o que bloqueou) para o visualizador desenhar.
---- Passar `dbg_table` tambem ignora o cache e forca o caminho completo de sondagem, senao
---- nao haveria raio nenhum para mostrar quando a resposta ja estivesse memoizada.
function Rat_MeasureExposure(attacker, target, attacker_pos, target_pos, body_part, weapon, dbg_table)
    local a = P()
    if not a.Enabled or not a.CoverRaycast then
        return 100
    end
    if not IsKindOf(target, "Unit") or not IsValid(attacker) then
        return 100
    end

    attacker_pos = attacker_pos or attacker:GetPos()
    target_pos = target_pos or target:GetPos()
    if not attacker_pos or not target_pos then
        return 100
    end

    local part_id = body_part
    if type(part_id) == "table" then
        part_id = part_id.id
    end
    local head = (part_id == "Head" or part_id == "Neck")

    local stance = target:GetHitStance()
    local key = xxhash(attacker_pos, target.handle, target_pos, stance, head and 1 or 0, cache_gen)
    if not dbg_table then
        local hit = exposure_cache[key]
        if hit then
            return hit
        end
    end

    ---------------------------------------------------------------------------------------
    ---- Caminho barato para a IA.
    ----
    ---- Medido: a sondagem custa 7,3 ms por avaliacao com cache frio contra 0,94 ms
    ---- do modelo somado (com cache quente cai para 0,81, mais rapido que o baseline).
    ---- Cada posicao candidata que a IA pontua e um cache miss, entao dar raycast a
    ---- ela arriscava o orcamento inteiro do turno.
    ----
    ---- A IA usa entao o "nivel 1": a porcentagem de cobertura que o engine JA
    ---- calcula, sem passar pelo InterpolateCoverEffect. Continua sendo um ganho --
    ---- cobertura parcial passa a importar, em vez de virar a escada de 3 degraus de
    ---- Unit.lua:8701 -- so nao sabe de altura nem de angulo de ataque.
    ----
    ---- O jogador (crosshair e tiro de verdade) fica com a sondagem completa.
    ---------------------------------------------------------------------------------------
    local side = attacker.team and attacker.team.side or ''
    if a.CoverAIFallback and not dbg_table and not (side == 'player1' or side == 'player2') then
        local _, _, coverage = target:GetCoverPercentage(attacker_pos, target_pos)
        local p = Clamp(100 - (coverage or 0), 0, 100)
        if p < a.ExposureBlockedPct then
            p = 0
        end
        if cache_count < CACHE_MAX then
            exposure_cache[key] = p
            cache_count = cache_count + 1
        end
        return p
    end

    weapon = weapon or attacker:GetActiveWeapons()

    ---------------------------------------------------------------------------------------
    ---- 1) Ancoras: uma consulta normal ao engine, com a UNIDADE como alvo. Devolve
    ----    a posicao real de cada spot do corpo (presas ao esqueleto animado) e o
    ----    attack_pos real (a boca do cano, que gira conforme o alvo).
    ----
    ----    Nao dava para dispensar esta chamada: uma grade sintetica sobre uma caixa,
    ----    disparada de uma origem estimada, divergia do engine -- a 3 tiles ela via
    ----    parede onde o engine tinha linha limpa nos cinco spots.
    ---------------------------------------------------------------------------------------
    local base = GetLoFData(attacker, target, {
        obj = attacker, weapon = weapon, stance = attacker.stance,
        prediction = true, output_collisions = true,
        force_hit_seen_target = false
    })
    if not base or not base.lof or #base.lof == 0 then
        return 0
    end

    local attack_pos = base.lof[1].attack_pos
    local spots, spot_reached = {}, {}
    for _, l in ipairs(base.lof) do
        spots[l.target_spot_group] = l.target_pos
        for _, h in ipairs(l.hits or empty_table) do
            if h.obj == target then
                spot_reached[l.target_spot_group] = true
                break
            end
        end
    end

    local anchor = head and (spots.Head or spots.Neck) or (spots.Torso or base.lof[1].target_pos)
    if not anchor or not attack_pos then
        return 0
    end

    ---------------------------------------------------------------------------------------
    ---- Modo barato (padrao): a propria consulta de ancoras JA e uma sondagem de
    ---- silhueta -- cinco raios contra pontos reais do corpo (cabeca, torso, bracos,
    ---- virilha, pernas), presos ao esqueleto animado. Resolucao de 20%, mas UMA
    ---- chamada de GetLoFData em vez de duas.
    ----
    ---- Medido: a grade completa custa 13,8 ms por avaliacao com cache frio, contra
    ---- 1,23 ms do modelo somado. A IA (AIPrecalcConeTargetZones) avalia muitas
    ---- posicoes por turno, e cada posicao nova e um cache miss -- a grade sozinha
    ---- estouraria o orcamento. A grade fina fica atras de A.CoverProbeGrid.
    ---------------------------------------------------------------------------------------
    if not a.CoverProbeGrid then
        local n_spots, reached_spots = 0, 0
        if head then
            ---- cabeca/pescoco nao tem cinco amostras: usa so o proprio spot
            n_spots = 1
            reached_spots = (spot_reached.Head or spot_reached.Neck) and 1 or 0
            if dbg_table then
                dbg_table[#dbg_table + 1] = {
                    from = attack_pos, to = anchor, label = head and "Head" or "?",
                    reached = reached_spots == 1,
                    stuck = base.lof[1].stuck_pos or base.lof[1].lof_pos2
                }
            end
        else
            for _, l in ipairs(base.lof) do
                n_spots = n_spots + 1
                local ok = spot_reached[l.target_spot_group] and true or false
                if ok then
                    reached_spots = reached_spots + 1
                end
                if dbg_table then
                    local blocker
                    for _, h in ipairs(l.hits or empty_table) do
                        if h.obj ~= target then
                            blocker = h.obj and (h.obj.class or "?") or (h.terrain and "terreno")
                            break
                        end
                    end
                    dbg_table[#dbg_table + 1] = {
                        from = l.attack_pos or attack_pos, to = l.target_pos,
                        label = tostring(l.target_spot_group), reached = ok,
                        stuck = l.stuck_pos or l.lof_pos2, blocker = blocker
                    }
                end
            end
        end
        if dbg_table then
            dbg_table.mode = "5 spots do engine"
            dbg_table.anchor = anchor
            dbg_table.attack_pos = attack_pos
        end
        if n_spots == 0 then
            return 100
        end
        ---- mesma regra do modo completo: ocluido = nenhum spot alcancado
        local p = (reached_spots == 0) and 0 or
                      Max(1, MulDivRound(reached_spots, 100, n_spots))
        if cache_count < CACHE_MAX then
            exposure_cache[key] = p
            cache_count = cache_count + 1
        end
        return p
    end

    local box = a.Box[stance] or a.Box.Standing
    local halfw = head and 110 or box.halfw

    ---- base ortonormal: horizontal perpendicular a linha de tiro, e vertical
    local flat = (anchor - attack_pos):SetZ(0)
    if flat:Len() == 0 then
        return 100
    end
    local right = SetLen(point(-flat:y(), flat:x(), 0), 1000)

    ---------------------------------------------------------------------------------------
    ---- Pontos de sondagem ANCORADOS NA ANATOMIA.
    ----
    ---- A versao anterior montava uma grade 3x3 centrada no spot do Torso. Nao
    ---- funcionava: o spot do Torso nao e o centro da silhueta em nenhum dos dois
    ---- eixos. Medido contra um alvo em pe, no referencial do tiro, os spots reais
    ---- iam de lateral -8 a +185 e de vertical -575 a +373 -- enquanto a grade varria
    ---- lateral -251..+251 e vertical -314..+314, centrada em zero. A coluna da
    ---- esquerda e a linha de cima caiam fora do corpo, sempre: 5 celulas perdidas de
    ---- 9, exposicao travada em 44% para um alvo totalmente a descoberto.
    ----
    ---- Agora as amostras saem dos proprios spots que o engine devolve (cabeca,
    ---- torso, bracos, virilha, pernas), que estao presos ao esqueleto animado: cada
    ---- um vira uma linha de amostragem, com desvios laterais para varrer a largura.
    ---- Nao ha centro nem caixa para estimar, e o padrao acompanha postura, pose e
    ---- angulo de visada sozinho.
    ---------------------------------------------------------------------------------------
    local targets, n = {}, 0
    if head then
        ---- a cabeca e pequena e o spot dela E o centro da regiao: uma cruz de cinco
        ---- amostras em volta basta, e nao ha o problema de descentramento do corpo
        local hw = a.HeadProbeHalf
        for _, off in ipairs({point(0, 0, 0), MulDivRound(right, hw, 1000),
                              MulDivRound(right, -hw, 1000), point(0, 0, hw),
                              point(0, 0, -hw)}) do
            n = n + 1
            targets[n] = anchor + off
        end
    else
        for _, l in ipairs(base.lof) do
            local sp = l.target_pos
            if sp then
                for _, fx in ipairs(a.ProbeLateral) do
                    n = n + 1
                    targets[n] = sp + MulDivRound(right, MulDivRound(halfw, fx, 100), 1000)
                end
            end
        end
    end
    if n == 0 then
        return 100
    end

    local dist = attack_pos:Dist(anchor)

    ---------------------------------------------------------------------------------------
    ---- 2) A grade inteira numa chamada so, com o attack_pos que o engine devolveu.
    ----
    ---- `force_hit_seen_target` fica FALSO: o padrao do engine (UnitCaching.lua:143)
    ---- forca acerto em alvo visto, o que devolveria 100% sempre e destruiria a medicao.
    ---------------------------------------------------------------------------------------
    local lof_args = {
        obj = attacker,
        weapon = weapon,
        stance = attacker.stance,
        attack_pos = attack_pos,
        output_collisions = true,
        range = dist + 4 * const.SlabSizeX,
        seed = 0, --- deterministico: nenhum random sincronizado neste caminho
        ---- 0 = qualquer obstaculo bloqueia o raio, mesmo os que a bala atravessaria.
        ---- E o que faz cobertura PROTEGER, no espirito do -35 flat que o mod cobrava.
        ---- Com a classe real da arma, um alvo atras de uma pilha de pneus conta como
        ---- exposto (a bala passa) e quase toda cobertura do mapa deixa de valer --
        ---- a penetracao ja e tratada a parte, no dano. Ver A.CoverPenetrationClass.
        penetration_class = a.CoverPenetrationClass or 0,
        prediction = true,
        clamp_to_target = true,
        fire_relative_point_attack = false,
        extend_shot_start_to_attacker = false,
        can_hit_attacker = false,
        ignore_los = true,
        inside_attack_area_check = false,
        forced_hit_on_eye_contact = false,
        can_use_covers = false,
        emplacement_weapon = false,
        aimIK = false,
        can_stuck_on_unit = true,
        force_hit_seen_target = false
    }

    ---------------------------------------------------------------------------------------
    ---- Contagem: a exposicao e  alcancados / (alcancados + OBSTRUIDOS).
    ----
    ---- Nao dividir pelo total de raios. Um raio pode falhar por dois motivos muito
    ---- diferentes, e so um deles e cobertura:
    ----   OBSTRUIDO   -- bateu em alguma coisa ANTES do alvo. Isto e cobertura.
    ----   ERRO DE MIRA -- passou ao lado sem bater em nada. Isto e a grade sendo mais
    ----                   larga que a parte do corpo amostrada, e nao diz nada sobre
    ----                   o mapa.
    ----
    ---- Medido antes de separar os dois: um alvo em pe e totalmente a descoberto dava
    ---- 36% de exposicao, com TODOS os raios que falharam sem bloqueador nenhum -- era
    ---- so geometria de amostragem virando "cobertura". Normalizando assim, o mesmo
    ---- alvo da 100%, e o padrao de amostragem deixa de influenciar o resultado.
    ----
    ---- "Antes do alvo" e por distancia: os raios seguem 4 tiles alem do alvo, entao
    ---- um que passa ao lado e bate no chao atras dele nao pode contar como cobertura.
    ---------------------------------------------------------------------------------------
    local data = GetLoFData(attacker, targets, lof_args)
    local reached, obstructed = 0, 0
    for i, d in ipairs(data or empty_table) do
        local lof = d and (d.outside_attack_area_lof or (d.lof and d.lof[1]))
        local sample_dist = attack_pos:Dist(targets[i])
        local ok, blocker = false, nil
        for _, h in ipairs((lof and lof.hits) or empty_table) do
            if h.obj == target then
                ok = true
                break
            elseif not blocker and h.pos and attack_pos:Dist(h.pos) < sample_dist then
                blocker = h.obj and (h.obj.class or "?") or (h.terrain and "terreno")
            end
        end
        if ok then
            reached = reached + 1
        elseif blocker then
            obstructed = obstructed + 1
        end
        if dbg_table then
            dbg_table[#dbg_table + 1] = {
                from = (lof and lof.attack_pos) or attack_pos, to = targets[i],
                label = "g" .. i, reached = ok, blocker = blocker,
                stuck = lof and (lof.stuck_pos or lof.lof_pos2)
            }
        end
    end
    if dbg_table then
        dbg_table.mode = "grade 3x3"
        dbg_table.anchor = anchor
        dbg_table.attack_pos = attack_pos
        dbg_table.halfw = halfw
        dbg_table.n_samples = n
    end

    ---- Ocluido significa NENHUM raio passar. Nao usar piso percentual aqui: com 25
    ---- amostras a resolucao e 4%, e o piso de 6% zerava alvos com um raio limpo --
    ---- foi assim que um alvo com os cinco spots do engine alcancaveis aparecia com
    ---- corpo 0% e cabeca 40% ao mesmo tempo. O piso continua valendo so no caminho
    ---- barato da IA, onde a entrada e uma porcentagem e nao uma contagem.
    local sampled = reached + obstructed
    local pct
    if sampled == 0 then
        pct = 100 --- nenhum raio tocou o corpo nem foi bloqueado: nada obstruindo
    elseif reached == 0 then
        pct = 0
    else
        pct = Max(1, MulDivRound(reached, 100, sampled))
    end

    if cache_count < CACHE_MAX then
        exposure_cache[key] = pct
        cache_count = cache_count + 1
    end

    return pct
end

---------------------------------------------------------------------------------------------------
---- Diagnostico (console)
---------------------------------------------------------------------------------------------------

function Rat_ShowExposure(attacker, target)
    attacker = attacker or SelectedObj
    if not attacker then
        return "sem atacante"
    end
    local was_c, was_e = P().CoverRaycast, P().Enabled
    P().CoverRaycast, P().Enabled = true, true
    Rat_InvalidateExposureCache()

    local lines = {}
    for _, o in ipairs(g_Units or empty_table) do
        if o ~= attacker and not o:IsDead() then
            local body = Rat_MeasureExposure(attacker, o, attacker:GetPos(), o:GetPos(), nil)
            local head = Rat_MeasureExposure(attacker, o, attacker:GetPos(), o:GetPos(), "Head")
            local _, _, coverage = o:GetCoverPercentage(attacker:GetPos(), o:GetPos())
            lines[#lines + 1] = string.format("%-34s %5.1ft %-8s corpo %3d%%  cabeca %3d%%  (voxel %d%%)",
                                              tostring(o.session_id):sub(-32),
                                              attacker:GetDist(o) / const.SlabSizeX,
                                              tostring(o:GetHitStance()), body, head, coverage or 0)
        end
    end

    P().CoverRaycast, P().Enabled = was_c, was_e
    Rat_InvalidateExposureCache()
    return table.concat(lines, "\n")
end

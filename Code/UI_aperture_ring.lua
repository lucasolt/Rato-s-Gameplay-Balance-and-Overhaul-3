---------------------------------------------------------------------------------------------------
---- ANEL DE ABERTURA no mundo. Geometria compartilhada pelo crosshair (UI_aperture_crosshair) e
---- pelos visualizadores (DEBUG_aperture_draw): mesmo circulo, consumidores diferentes.
---- O anel do jogador e um Polyline de verdade, nao DbgAdd* -- estes somem na Gold Master.
---- PlaceObject("Polyline") e o que o proprio jogo usa em RangeContour e nos visuais de AOE.
---------------------------------------------------------------------------------------------------

local AppendVertex = pstr().AppendVertex

---- Classe propria em vez de Polyline cru: e o que torna a varredura de orfaos POSSIVEL e segura.
---- Varrer "Polyline" mataria junto o contorno de movimento e os visuais de AOE do jogo.
DefineClass.RatConeRing = {__parents = {const.Combat.Aperture.ConeRingParent or "Polyline"},
                           rat_shader = false, rat_depth = false}

---- Um mesh de Polyline e UMA tira continua, e a escada do recuo sao tracos soltos. Em vez de
---- amarrar tudo num traco so (ou apostar em conectores transparentes, que dependem do shader),
---- cada traco e um objeto proprio com nome. A varredura por classe ja recolhe todos.
local strokes = {} --- id -> objeto; "ring" e o anel de sempre
local last = {} --- id -> {pts, color_raw, anchor}: ultimo desenho, para o afinador reemitir a geometria

---- Mata TODO anel no mapa, inclusive os que perderam a referencia. Um reload de mod (ou de Lua)
---- re-executa este arquivo e zera `ring_obj`, mas o objeto ja colocado continua no mundo -- sem
---- isto ele fica orfao para sempre, porque ninguem mais aponta para ele.
function Rat_SweepConeRings()
    local n = 0
    MapForEach("map", "RatConeRing", function(o)
        n = n + 1
        DoneObject(o)
    end)
    strokes, last = {}, {}
    return n
end

---- 1 radiano = 3438 minutos de angulo. Raio que um cone de `minutes` cobre a `dist`.
function Rat_ConeRadius(dist, minutes)
    return MulDivRound(dist, minutes, 3438)
end

---- Z valido ANTES de qualquer matematica de vetor: GetPos() no terreno vem com Z invalido,
---- a aritmetica degrada para 2D e o anel sai deitado no chao.
function Rat_RingValidZ(pos)
    if not pos or pos:IsValidZ() then
        return pos
    end
    return pos:SetTerrainZ()
end

local function spot_loc(target, name)
    if not name then
        return
    end
    local idx = target:GetSpotBeginIndex(name)
    if idx and idx ~= -1 then
        return target:GetSpotLoc(idx)
    end
end

---- Ancora do anel: o spot do body part mirado -- o mesmo grupo que GetLoFData recebe como
---- target_spot_group, entao o anel segue a parte escolhida no crosshair. NAO passa por
---- Rat_SimAimPos: aquilo exige GetLoFData (raycast) a cada update, e a diferenca e a correcao
---- de colisao/A.AimCentroidPct -- irrelevante para onde se DESENHA um circulo.
---- Cascata de fallback igual a do engine em CrosshairUI (Torso -> Hit -> posicao visual).
function Rat_RingAnchor(target, spot)
    if not IsValid(target) then
        return
    end
    local pos = spot_loc(target, spot) or spot_loc(target, "Torso") or spot_loc(target, "Hit") or
                    target:GetVisualPos()
    return Rat_RingValidZ(pos)
end

---- Pontos de um circulo de `radius` em `center`, no plano perpendicular a `dir` (alvo de papel
---- de frente para o atirador). Laco fechado: o ultimo ponto repete o primeiro. Degenerado -> nil.
---- `radius_y` diferente de `radius` desenha ELIPSE: o cone tem eixos diferentes quando o recuo
---- herdado o alonga ou a postura o achata (Rat_ConeSigmaY). O eixo esticado e sempre o vertical
---- do plano do alvo, que e exatamente o eixo em que o recuo trabalha.
---- `radius_y_down` diferente dele desenha um OVO: os dois meios-eixos verticais sao diferentes
---- quando RecoilPersistUpBias sai de 50. O centro nao se move -- so a metade de cima cresce mais.
---- `fan` (unidades de mundo) alarga a metade de CIMA: o raio horizontal cresce com a altura ate
---- saturar em `fan_sat`, que e a mesma rampa de Rat_SeparableCTH (sigma + fan_top * min(y,sy)/sy).
---- E o que torna o anel capaz de dizer o leque -- e o que conserta a leitura: so esticar o
---- meio-eixo de cima AFILA o topo com largura constante, e ai o ovo parece mais largo embaixo.
function Rat_RingPoints(center, radius, dir, segments, radius_y, radius_y_down, fan, fan_sat)
    if not center or not radius or radius < 1 then
        return
    end
    segments = segments or const.Combat.Aperture.CrosshairRingSegments or 32
    if not dir or not dir:IsValidZ() then
        --- direcao sem Z nao define plano nenhum: o circulo sairia deitado
        dir = point(dir and dir:x() or 0, dir and dir:y() or 0, 0)
    end
    if dir:Len() == 0 then
        return
    end
    dir = SetLen(dir, 1000)

    ---- perpendicular genuino a dir: RotateAxis preserva a componente paralela e (0,0,r) cru encolheria o raio
    local up = point(0, 0, 1000)
    local par = Dot(up, dir) / 1000 --- componente de `up` ao longo de dir
    local perp = up - MulDivRound(dir, par, 1000)
    if perp:Len() < 10 then
        --- tiro quase vertical: usa a horizontal como referencia
        perp = point(-dir:y(), dir:x(), 0)
    end
    local full = 360 * 60
    local pts = {}
    radius_y_down = radius_y_down or radius_y
    fan = (fan and fan > 0) and fan or 0
    if fan == 0 and (not radius_y or (radius_y == radius and radius_y_down == radius)) then
        perp = SetLen(perp, radius)
        for i = 0, segments do
            pts[i + 1] = center + RotateAxis(perp, dir, MulDivRound(full, i, segments))
        end
        return pts
    end

    ---- eliptica: monta cada ponto pelos DOIS meios-eixos. Rodar um vetor ja esticado devolveria
    ---- o circulo de volta -- o raio tem de acompanhar o angulo, nao so a direcao.
    radius_y = radius_y or radius
    radius_y_down = radius_y_down or radius_y
    local vert = SetLen(perp, 1000)
    local lat = RotateAxis(vert, dir, 90 * 60)
    for i = 0, segments do
        local ang = MulDivRound(full, i, segments)
        local c = cos(ang)
        local cy = MulDivRound((c >= 0) and radius_y or radius_y_down, c, 4096)
        ---- so a metade de cima abre, e so ate saturar -- abaixo do centro o cone e o cone limpo
        local rx = radius
        if fan > 0 and cy > 0 then
            rx = radius + ((fan_sat and fan_sat > 0) and MulDivRound(fan, Min(cy, fan_sat), fan_sat) or
                              fan)
        end
        local cx = MulDivRound(rx, sin(ang), 4096)
        local p = center
        if cy ~= 0 then
            p = (cy > 0) and (p + SetLen(vert, cy)) or (p - SetLen(vert, -cy))
        end
        if cx ~= 0 then
            p = (cx > 0) and (p + SetLen(lat, cx)) or (p - SetLen(lat, -cx))
        end
        pts[i + 1] = p
    end
    return pts
end

---- Cria/atualiza o anel do jogador. Recria a malha em vez de mover o objeto: o raio muda a
---- cada nivel de mira, e e o mesmo custo que o jogo paga no contorno de movimento.
---- Um traco qualquer: a lista de pontos ja pronta, em mundo. Recria a malha em vez de mover o
---- objeto, pela mesma razao do anel -- a forma muda a cada update, nao so a posicao.



---- Shader/depth/cor deste traco, se houver estilo declarado em A.MeshStyle. O que ja foi
---- aplicado fica guardado no proprio objeto: SetShader escreve custom data e isto roda a cada
---- update do crosshair, entao so se paga quando algo mudou de verdade.
---- Geometria SOLIDA (fita ou regiao) precisa de topologia de triangulo -- um shader de linha nao
---- desenha nada com ela. Promove default_polyline ao shader de fita; um shader explicito e mantido.
local function solid_style(st)
    return st and (st.fill or (st.width or 0) > 0)
end

function Rat_StrokeStyle(obj, id)
    local st = (const.Combat.Aperture.MeshStyle or empty_table)[id]
    local name = (st and st.shader) or "default_polyline"
    if solid_style(st) and name == "default_polyline" then
        name = const.Combat.Aperture.StrokeMeshShader or "soft_mesh"
    end
    local depth = (st and st.depth) or false
    if obj.rat_shader == name and obj.rat_depth == depth then
        return st
    end
    local sh = ProceduralMeshShaders[name]
    if sh then
        ---- o engine assere se o depth_test contrariar o que o shader declara
        obj:SetShader(sh, (sh.depth_test == "runtime") and depth or nil)
        obj.rat_shader, obj.rat_depth = name, depth
    end
    return st
end

---- Meia-largura perpendicular ao segmento a->b no plano que encara a camera. Fallback para o plano
---- horizontal quando o segmento aponta para o olho.
local function face_offset(a, b, eye, half)
    local seg = b - a
    if seg:Len() == 0 then
        return
    end
    local n = Cross(seg, a - eye)
    if n:Len() < 1 then
        n = Cross(seg, axis_z)
    end
    if n:Len() < 1 then
        return
    end
    return SetLen(n, half)
end

---- Um quad (dois triangulos) de a a b, meia-largura `o` para cada lado, alpha `aa`/`ab` nas pontas.
local function quad(vpstr, a, b, o, r, g, bl, aa, ab)
    local ca, cb = RGBA(r, g, bl, aa), RGBA(r, g, bl, ab)
    AppendVertex(vpstr, a - o, ca)
    AppendVertex(vpstr, b - o, cb)
    AppendVertex(vpstr, a + o, ca)
    AppendVertex(vpstr, a + o, ca)
    AppendVertex(vpstr, b - o, cb)
    AppendVertex(vpstr, b + o, cb)
end

---- Fator de alpha do desbote de RAIZ: 0 na origem (pts[1]) subindo a 1 alem de `bref`. bref ja e
---- a fracao aplicada; d e a distancia do ponto a origem. Serve os dois bracos da cunha de uma vez,
---- porque os dois saem do mesmo ponto -- e o "tipFade ao contrario" que apaga so o inicio.
local function root_mul(d, bref)
    return (bref > 0 and d < bref) and MulDivRound(d, 1000, bref) or 1000
end

---- Fita ao longo de `pts`: `half` meia-largura; `alpha` alpha do nucleo; `fade`/`bfade` % do
---- comprimento que desbota na PONTA / na RAIZ (distancia da origem); `dash` traco e vao (0 = cheio).
local function ribbon(vpstr, pts, color, half, alpha, fade, dash, bfade)
    local r, g, bl = GetRGB(color)
    local eye = camera.GetEye()
    local p1 = pts[1]
    local seglen, total, far = {}, 0, 0
    for i = 2, #pts do
        seglen[i] = pts[i]:Dist(pts[i - 1])
        total = total + seglen[i]
        far = Max(far, pts[i]:Dist(p1))
    end
    if total == 0 then
        return
    end
    local fade_from = (fade > 0) and MulDivRound(total, 100 - fade, 100) or total
    local bref = (bfade and bfade > 0) and MulDivRound(far, bfade, 100) or 0
    local function alpha_at(run, p)
        local av = alpha
        if run > fade_from then
            av = MulDivRound(av, total - run, total - fade_from)
        end
        if bref > 0 then
            av = MulDivRound(av, root_mul(p:Dist(p1), bref), 1000)
        end
        return av
    end
    local run = 0
    for i = 2, #pts do
        local a, c, len = pts[i - 1], pts[i], seglen[i]
        local o = face_offset(a, c, eye, half)
        if o and len > 0 then
            if dash > 0 then
                local d, k = 0, 0
                while d < len do
                    local d2 = Min(len, d + dash)
                    if k % 2 == 0 then
                        local pa, pc = a + MulDivRound(c - a, d, len), a + MulDivRound(c - a, d2, len)
                        quad(vpstr, pa, pc, o, r, g, bl, alpha_at(run + d, pa), alpha_at(run + d2, pc))
                    end
                    d, k = d2, k + 1
                end
            else
                quad(vpstr, a, c, o, r, g, bl, alpha_at(run, a), alpha_at(run + len, c))
            end
        end
        run = run + len
    end
end

---- Regiao preenchida: leque de triangulos do 1o ponto. Descarta ocorrencias internas do 1o ponto
---- (a cunha retorna por ele) e vertices repetidos, senao o leque degenera. `bfade` desbota os
---- vertices proximos da origem, igual a fita.
local function fan(vpstr, pts, color, alpha, bfade)
    local r, g, bl = GetRGB(color)
    local poly = {pts[1]}
    for i = 2, #pts do
        local p = pts[i]
        if p ~= pts[1] and p ~= poly[#poly] then
            poly[#poly + 1] = p
        end
    end
    local far = 0
    for i = 2, #poly do
        far = Max(far, poly[i]:Dist(poly[1]))
    end
    local bref = (bfade and bfade > 0) and MulDivRound(far, bfade, 100) or 0
    local function col(p)
        return RGBA(r, g, bl,
                    bref > 0 and MulDivRound(alpha, root_mul(p:Dist(poly[1]), bref), 1000) or alpha)
    end
    for i = 3, #poly do
        AppendVertex(vpstr, poly[1], col(poly[1]))
        AppendVertex(vpstr, poly[i - 1], col(poly[i - 1]))
        AppendVertex(vpstr, poly[i], col(poly[i]))
    end
end

---- Malha de um traco a partir da lista de pontos e do estilo. Sem width nem fill e a linha 1px
---- de sempre; com qualquer um dos dois a topologia passa a triangulo (ver Rat_StrokeStyle).
function Rat_StrokeMesh(id, pts, color, st)
    local vpstr = pstr("", 1024)
    local width = (st and st.width) or 0
    local tf, bf = (st and st.tipFade) or 0, (st and st.baseFade) or 0
    if st and st.fill then
        fan(vpstr, pts, color, st.fillAlpha or 60, bf)
        ribbon(vpstr, pts, color, (width > 0) and width or 8, st.coreAlpha or 255, tf, st.dash or 0, bf)
    elseif width > 0 then
        local halo = st.halo or 0
        if halo > 0 then
            ribbon(vpstr, pts, color, width + halo, st.haloAlpha or 40, tf, st.dash or 0, bf)
        end
        ribbon(vpstr, pts, color, width, st.coreAlpha or 255, tf, st.dash or 0, bf)
    else
        for i = 1, #pts do
            AppendVertex(vpstr, pts[i], color)
        end
    end
    return vpstr
end

function Rat_ShowStroke(id, pts, color, anchor)
    if not pts or #pts < 2 then
        return Rat_HideStroke(id)
    end

    local obj = strokes[id]
    if not IsValid(obj) then
        obj = PlaceObject("RatConeRing") --- herda mfWorldSpace e o shader default_polyline
        strokes[id] = obj
    end
    local st = Rat_StrokeStyle(obj, id)
    last[id] = {pts = pts, color_raw = color, anchor = anchor}
    color = (st and st.color) or color

    obj:SetMesh(Rat_StrokeMesh(id, pts, color, st))
    obj:SetPos(anchor or pts[1]) --- so culling/ordenacao: com mfWorldSpace os vertices sao absolutos
    obj:SetVisible(true)
end

---- O ultimo desenho de um traco (ou de todos): o afinador reemitir a geometria sem esperar o
---- proximo update do crosshair -- e a unica forma de comparar duas larguras lado a lado.
function Rat_LastStroke(id)
    return id and last[id] or last
end

---- Os tracos que estao na tela AGORA, para o afinador de estilo reaplicar sem redesenhar.
function Rat_LiveStrokes()
    return strokes
end

function Rat_HideStroke(id)
    local obj = strokes[id]
    if IsValid(obj) then
        DoneObject(obj)
    end
    strokes[id], last[id] = nil, nil
end

function Rat_ShowConeRing(center, radius, dir, color, segments, radius_y, radius_y_down, fan, fan_sat)
    local pts = Rat_RingPoints(center, radius, dir, segments, radius_y, radius_y_down, fan, fan_sat)
    if not pts then
        return Rat_HideConeRing()
    end
    ---- orfao de reload: ha anel no mapa e ninguem aponta para ele. Varre antes de criar o primeiro.
    if not IsValid(strokes.ring) then
        Rat_SweepConeRings()
    end
    Rat_ShowStroke("ring", pts, color, center)
end

---- Leva TUDO junto: quem esconde o anel esta saindo do modelo, e uma escada de recuo orfa na
---- tela mentiria sobre um ataque que nao existe mais.
function Rat_HideConeRing()
    for id in pairs(strokes) do
        Rat_HideStroke(id)
    end
    strokes, last = {}, {}
end

---- O anel e um objeto de mapa: sem isto sobreviveria a troca de mapa e entraria no savegame.
---- Varre em vez de so soltar a referencia -- ao chegar aqui pode haver orfao de antes.
function OnMsg.ChangeMap()
    Rat_SweepConeRings()
end

function OnMsg.DoneMap()
    Rat_SweepConeRings()
end

---- Mapa novo / save carregado: comeca limpo, aconteca o que tiver acontecido antes.
function OnMsg.NewMapLoaded()
    Rat_SweepConeRings()
end

function OnMsg.LoadGame()
    Rat_SweepConeRings()
end

---- Reload de mod: e AQUI que nascia o orfao. O arquivo re-executa, `ring_obj` volta a nil e o
---- anel que estava na tela fica sem dono. Varre pela classe, que sobrevive ao reload.
function OnMsg.ModsReloaded()
    Rat_SweepConeRings()
end

---- Crosshair fechado por qualquer motivo (ataque, ESC, alvo morto) leva o anel junto.
---- Em ClassesBuilt: no load do arquivo a classe ainda nao existe.
function OnMsg.ClassesBuilt()
    local cls = g_Classes.CrosshairUI
    if not cls or cls.rat_ring_patched then
        return
    end
    local vanilla_on_delete = cls.OnDelete
    cls.rat_ring_patched = true
    cls.OnDelete = function(self, reason)
        Rat_HideConeRing()
        return vanilla_on_delete(self, reason)
    end
end

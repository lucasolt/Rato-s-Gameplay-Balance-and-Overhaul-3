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

---- Mata TODO anel no mapa, inclusive os que perderam a referencia. Um reload de mod (ou de Lua)
---- re-executa este arquivo e zera `ring_obj`, mas o objeto ja colocado continua no mundo -- sem
---- isto ele fica orfao para sempre, porque ninguem mais aponta para ele.
function Rat_SweepConeRings()
    local n = 0
    MapForEach("map", "RatConeRing", function(o)
        n = n + 1
        DoneObject(o)
    end)
    strokes = {}
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
function Rat_RingPoints(center, radius, dir, segments, radius_y, radius_y_down)
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
    if not radius_y or (radius_y == radius and radius_y_down == radius) then
        perp = SetLen(perp, radius)
        for i = 0, segments do
            pts[i + 1] = center + RotateAxis(perp, dir, MulDivRound(full, i, segments))
        end
        return pts
    end

    ---- eliptica: monta cada ponto pelos DOIS meios-eixos. Rodar um vetor ja esticado devolveria
    ---- o circulo de volta -- o raio tem de acompanhar o angulo, nao so a direcao.
    local vert = SetLen(perp, 1000)
    local lat = RotateAxis(vert, dir, 90 * 60)
    for i = 0, segments do
        local ang = MulDivRound(full, i, segments)
        local c = cos(ang)
        local cy = MulDivRound((c >= 0) and radius_y or radius_y_down, c, 4096)
        local cx = MulDivRound(radius, sin(ang), 4096)
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
function Rat_StrokeStyle(obj, id)
    local st = (const.Combat.Aperture.MeshStyle or empty_table)[id]
    local name = (st and st.shader) or "default_polyline"
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
    color = (st and st.color) or color

    local vpstr = pstr("", 1024)
    for i = 1, #pts do
        AppendVertex(vpstr, pts[i], color)
    end
    obj:SetMesh(vpstr)
    obj:SetPos(anchor or pts[1]) --- so culling/ordenacao: com mfWorldSpace os vertices sao absolutos
    obj:SetVisible(true)
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
    strokes[id] = nil
end

function Rat_ShowConeRing(center, radius, dir, color, segments, radius_y, radius_y_down)
    local pts = Rat_RingPoints(center, radius, dir, segments, radius_y, radius_y_down)
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
    strokes = {}
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

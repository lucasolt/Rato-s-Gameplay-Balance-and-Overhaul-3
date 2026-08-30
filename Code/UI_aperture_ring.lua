---------------------------------------------------------------------------------------------------
---- ANEL DE ABERTURA no mundo. Geometria compartilhada pelo crosshair (UI_aperture_crosshair) e
---- pelos visualizadores (DEBUG_aperture_draw): mesmo circulo, consumidores diferentes.
---- O anel do jogador e um Polyline de verdade, nao DbgAdd* -- estes somem na Gold Master.
---- PlaceObject("Polyline") e o que o proprio jogo usa em RangeContour e nos visuais de AOE.
---------------------------------------------------------------------------------------------------

local AppendVertex = pstr().AppendVertex

---- Classe propria em vez de Polyline cru: e o que torna a varredura de orfaos POSSIVEL e segura.
---- Varrer "Polyline" mataria junto o contorno de movimento e os visuais de AOE do jogo.
DefineClass.RatConeRing = {__parents = {"Polyline"}}

local ring_obj --- um anel vivo por vez (so o jogador local ve crosshair)

---- Mata TODO anel no mapa, inclusive os que perderam a referencia. Um reload de mod (ou de Lua)
---- re-executa este arquivo e zera `ring_obj`, mas o objeto ja colocado continua no mundo -- sem
---- isto ele fica orfao para sempre, porque ninguem mais aponta para ele.
function Rat_SweepConeRings()
    local n = 0
    MapForEach("map", "RatConeRing", function(o)
        n = n + 1
        DoneObject(o)
    end)
    ring_obj = nil
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
function Rat_RingPoints(center, radius, dir, segments)
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
    perp = SetLen(perp, radius)

    local full = 360 * 60
    local pts = {}
    for i = 0, segments do
        pts[i + 1] = center + RotateAxis(perp, dir, MulDivRound(full, i, segments))
    end
    return pts
end

---- Cria/atualiza o anel do jogador. Recria a malha em vez de mover o objeto: o raio muda a
---- cada nivel de mira, e e o mesmo custo que o jogo paga no contorno de movimento.
function Rat_ShowConeRing(center, radius, dir, color, segments)
    local pts = Rat_RingPoints(center, radius, dir, segments)
    if not pts then
        return Rat_HideConeRing()
    end

    local vpstr = pstr("", 1024)
    for i = 1, #pts do
        AppendVertex(vpstr, pts[i], color)
    end

    if not IsValid(ring_obj) then
        ---- se ha anel no mapa sem `ring_obj` valido, e orfao de um reload: limpa antes de criar
        Rat_SweepConeRings()
        ring_obj = PlaceObject("RatConeRing") --- herda mfWorldSpace e o shader default_polyline
    end
    ring_obj:SetMesh(vpstr)
    ring_obj:SetPos(center) --- so culling/ordenacao: com mfWorldSpace os vertices sao absolutos
    ring_obj:SetVisible(true)
end

function Rat_HideConeRing()
    if IsValid(ring_obj) then
        DoneObject(ring_obj)
    end
    ring_obj = nil
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

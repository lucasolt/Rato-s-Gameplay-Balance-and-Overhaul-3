---------------------------------------------------------------------------------------------------
---- RASTRO DOS TIROS. Desenha no mundo os disparos que a unidade selecionada ja fez: uma linha
---- por bala, da arma ate onde a bala parou. Verde acertou, vermelho tracejado errou.
---- Fonte: g_RatShotHistory, alimentado por Rat_SimSnapshot (FUNCTIONS_aperture) -- o MESMO
---- registro que Rat_DbgLastShots le, so que por unidade e guardando os N ultimos ataques.
---- Malha de Polyline como o anel de abertura (UI_aperture_ring), nao DbgAdd*: aqueles somem
---- na Gold Master e sao ferramenta de dev, isto e para o jogador.
---------------------------------------------------------------------------------------------------

---- unit -> array de records, mais novo por ultimo. Chave fraca: o rastro nao segura um morto.
g_RatShotHistory = setmetatable({}, {__mode = "k"})
g_RatShotTracesOn = false

local function P()
    return const.Combat.Aperture
end

---- Classe propria, IRMA de RatConeRing e nao filha: Rat_SweepConeRings varre por classe e
---- levaria o rastro junto toda vez que o crosshair fechasse.
DefineClass.RatShotTrace = {__parents = {"Polyline"}, rat_shader = false, rat_depth = false}

local traces = {} --- os objetos na tela agora

function Rat_SweepShotTraces()
    local n = 0
    MapForEach("map", "RatShotTrace", function(o)
        n = n + 1
        DoneObject(o)
    end)
    traces = {}
    return n
end

---- Guarda o ataque na fila da unidade. Recebe a MESMA tabela de Rat_SimSnapshot, de proposito:
---- miss/end_pos/dano so sao escritos depois, pelo laco de tiros de Firearm:GetAttackResults.
function Rat_ShotHistoryPush(rec)
    local unit = rec and rec.attacker
    if not IsValid(unit) then
        return
    end
    local q = g_RatShotHistory[unit]
    if not q then
        q = {}
        g_RatShotHistory[unit] = q
    end
    q[#q + 1] = rec
    local keep = P().ShotHistoryAttacks or 4
    while #q > keep do
        table.remove(q, 1)
    end
    if g_RatShotTracesOn then
        Rat_DrawShotTraces()
    end
end

---- Subdivide o segmento: a fita monta um quad por par de pontos e o alpha interpola nas pontas,
---- entao uma reta de 2 pontos desbotaria ao longo do tiro inteiro em vez de so na raiz.
local function trace_points(from, to, steps)
    local pts = {}
    for i = 0, steps do
        pts[i + 1] = from + MulDivRound(to - from, i, steps)
    end
    return pts
end

---- Estilo do traco com os alphas escalados por `pct` (idade do ataque). Copia rasa: A.MeshStyle
---- e config compartilhada e mexer nela aqui vazaria para o proximo desenho.
local function aged_style(obj, id, pct)
    local st = Rat_StrokeStyle(obj, id)
    if not st or pct >= 100 then
        return st
    end
    local out = table.copy(st)
    out.coreAlpha = MulDivRound(st.coreAlpha or 255, pct, 100)
    out.haloAlpha = MulDivRound(st.haloAlpha or 40, pct, 100)
    out.fillAlpha = MulDivRound(st.fillAlpha or 60, pct, 100)
    return out
end

local function show_trace(key, pts, color, id, pct)
    local obj = traces[key]
    if not IsValid(obj) then
        obj = PlaceObject("RatShotTrace")
        traces[key] = obj
    end
    local st = aged_style(obj, id, pct)
    obj:SetMesh(Rat_StrokeMesh(id, pts, (st and st.color) or color, st))
    obj:SetPos(pts[1]) --- so culling: com mfWorldSpace os vertices ja sao absolutos
    obj:SetVisible(true)
end

function Rat_HideShotTraces()
    for _, obj in pairs(traces) do
        if IsValid(obj) then
            DoneObject(obj)
        end
    end
    traces = {}
end

---- Redesenha do zero. Nao ha estado incremental: a fila muda inteira a cada ataque e a
---- geometria e barata perto de reconciliar objeto a objeto.
function Rat_DrawShotTraces(unit)
    unit = unit or SelectedObj
    Rat_HideShotTraces()
    if not g_RatShotTracesOn or not IsValid(unit) then
        return 0
    end
    local q = g_RatShotHistory[unit]
    if not q or #q == 0 then
        return 0
    end

    ---- orfao de reload de mod: ha traco no mapa e ninguem aponta para ele
    Rat_SweepShotTraces()

    local oldest = P().ShotHistoryOldPct or 35
    local n = 0
    for a, rec in ipairs(q) do
        ---- o mais novo (a == #q) fica cheio; os de tras descem ate `oldest`
        local pct = (#q > 1) and (oldest + MulDivRound(100 - oldest, a - 1, #q - 1)) or 100
        ---- Z invalido degrada a aritmetica de vetor para 2D e a linha sai deitada no chao
        local from = rec.attack_pos and Rat_RingValidZ(rec.attack_pos)
        for i, sh in ipairs(rec.shots or empty_table) do
            local to = sh.end_pos or sh.target_pos
            to = to and Rat_RingValidZ(to)
            if from and to and from:Dist(to) > 0 then
                local id = sh.miss and "shot_miss" or "shot_hit"
                local color = sh.miss and const.clrRed or const.clrGreen
                show_trace(string.format("%d_%d", a, i), trace_points(from, to, 8), color, id, pct)
                n = n + 1
            end
        end
    end
    return n
end

function Rat_ToggleShotTraces()
    g_RatShotTracesOn = not g_RatShotTracesOn
    local n = Rat_DrawShotTraces()
    return g_RatShotTracesOn, n
end

---- Selecao nova: o rastro e da unidade selecionada, entao acompanha.
function OnMsg.SelectedObjChange()
    if g_RatShotTracesOn then
        Rat_DrawShotTraces()
    end
end

function OnMsg.SelectionChange()
    if g_RatShotTracesOn then
        Rat_DrawShotTraces()
    end
end

---- O ataque so termina de preencher os records (end_pos, acerto) depois de Rat_SimSnapshot.
function OnMsg.CombatActionEnd(unit)
    if g_RatShotTracesOn and unit == SelectedObj then
        Rat_DrawShotTraces()
    end
end

---- Objeto de mapa: sem isto sobrevive a troca de mapa e entra no savegame.
function OnMsg.ChangeMap()
    g_RatShotTracesOn = false
    g_RatShotHistory = setmetatable({}, {__mode = "k"})
    Rat_SweepShotTraces()
end

function OnMsg.DoneMap()
    Rat_SweepShotTraces()
end

function OnMsg.NewMapLoaded()
    Rat_SweepShotTraces()
end

function OnMsg.LoadGame()
    g_RatShotHistory = setmetatable({}, {__mode = "k"})
    Rat_SweepShotTraces()
end

function OnMsg.ModsReloaded()
    Rat_SweepShotTraces()
end

---- Atalho. InGameInterface:OnShortcut e o funil de teclado de TODOS os modos taticos, entao
---- pega tanto em combate quanto em exploracao. Marcador na classe para o reload de mod nao
---- encadear o patch em cima de si mesmo.
if not InGameInterface.rat_shot_traces_patched then
    local vanilla_on_shortcut = InGameInterface.OnShortcut
    InGameInterface.rat_shot_traces_patched = true
    ---- assinatura do dispatcher: (shortcut, source, controller_id, repeated). `repeated` = tecla
    ---- segurada, e sem ele o rastro pisca ligando/desligando a cada repeticao do teclado.
    InGameInterface.OnShortcut = function(self, shortcut, source, controller_id, repeated, ...)
        if not repeated and shortcut == (P().ShotHistoryKey or "Ctrl-Alt-H") then
            Rat_ToggleShotTraces()
            return "break"
        end
        return vanilla_on_shortcut(self, shortcut, source, controller_id, repeated, ...)
    end
end

---------------------------------------------------------------------------------------------------
---- RASTRO DOS TIROS. Desenha no mundo os disparos que a unidade selecionada ja fez: uma linha
---- por bala, da arma ate onde a bala parou. Verde acertou, vermelho tracejado errou.
---- Fonte: g_RatShotHistory, alimentado por Rat_SimSnapshot (FUNCTIONS_aperture) -- o MESMO
---- registro que Rat_DbgLastShots le, so que por unidade e guardando os N ultimos ataques.
---- Linha estilo Pindown (CRM_VisionLinePreset + CRTrail), nao DbgAdd*: aqueles somem na
---- Gold Master e sao ferramenta de dev, isto e para o jogador.
---------------------------------------------------------------------------------------------------

---- unit -> array de records, mais novo por ultimo. Chave fraca: o rastro nao segura um morto.
g_RatShotHistory = setmetatable({}, {__mode = "k"})
g_RatShotTracesOn = false

local function P()
    return const.Combat.Aperture
end

---- Classe propria, IRMA de RatConeRing e nao filha: Rat_SweepConeRings varre por classe e
---- levaria o rastro junto toda vez que o crosshair fechasse.
---- Duas malhas: a linha estilo Pindown (Mesh + CRMaterial) e a fita antiga (Polyline). O flag
---- A.ShotTracePindown escolhe qual; ambas varridas juntas.
DefineClass.RatShotTrace = {__parents = {"Mesh"}}
DefineClass.RatShotTraceLine = {__parents = {"Polyline"}, rat_shader = false, rat_depth = false}
---- Anel de impacto: sempre Polyline, encara a camera. Ver show_mark.
DefineClass.RatShotMark = {__parents = {"Polyline"}, rat_shader = false, rat_depth = false}

local traces = {} --- os objetos na tela agora
local marks = {} --- os aneis de impacto na tela agora
local watcher = false --- clears the history when a unit in it moves

---- Part icons and numbers are UI windows, not map objects: found by flag so a mod reload leaves no orphans.
local function close_part_icons()
    local igi = GetInGameInterface()
    for i = #(igi or empty_table), 1, -1 do
        local win = igi[i]
        if win.rat_shot_icon and win.window_state ~= "destroying" then
            win:Close()
        end
    end
end

function Rat_SweepShotTraces()
    close_part_icons()
    local n = 0
    MapForEach("map", "RatShotTrace", "RatShotTraceLine", "RatShotMark", function(o)
        n = n + 1
        DoneObject(o)
    end)
    traces = {}
    marks = {}
    return n
end

---- ordinal de ataque de cada record; records com o mesmo `group` seguidos sao um ataque so
local function attack_ordinals(q)
    local ord, n = {}, 0
    for i, rec in ipairs(q) do
        if not (rec.group and i > 1 and q[i - 1].group == rec.group) then
            n = n + 1
        end
        ord[i] = n
    end
    return ord, n
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
    ---- every stop of a mobile attack runs in the same RunAndGun command thread: one attack
    if not rec.group and unit.command == "RunAndGun" then
        rec.group = CurrentThread()
    end
    q[#q + 1] = rec
    local keep = P().ShotHistoryAttacks or 1
    local ord, n = attack_ordinals(q)
    ---- descarta o ataque mais velho inteiro, nao um burst dele
    local drop = 0
    while drop < #q and ord[drop + 1] <= n - keep do
        drop = drop + 1
    end
    for _ = 1, drop do
        table.remove(q, 1)
    end
    ---- shots are not resolved yet (no end_pos/miss); CombatActionEnd draws them
    if g_RatShotTracesOn and unit == SelectedObj then
        Rat_HideShotTraces()
    end
end

---- Material da linha (A.ShotTraceStyle) por tipo, com os alphas de fill/glow escalados por
---- `pct` (idade do ataque). Clone: a base e preset compartilhado e nao pode ser mutada.
local function trace_material(kind, pct)
    local st = (P().ShotTraceStyle or empty_table)[kind] or empty_table
    local base = CRM_VisionLinePreset:GetById(st.preset or "PreparedAttack")
              or CRM_VisionLinePreset:GetById("PreparedAttack")
    local mat = base:Clone()
    local fill = st.fill_color or mat.fill_color
    local glow = st.glow_color or mat.glow_color
    if pct < 100 then
        fill = SetA(fill, MulDivRound(select(4, GetRGBA(fill)), pct, 100))
        glow = SetA(glow, MulDivRound(select(4, GetRGBA(glow)), pct, 100))
    end
    mat.fill_color = fill
    mat.glow_color = glow
    if st.fill_width then
        mat.fill_width = st.fill_width
    end
    return mat
end

local function show_trace_pindown(key, from, to, kind, pct)
    local obj = traces[key]
    if not IsKindOf(obj, "RatShotTrace") then
        if IsValid(obj) then DoneObject(obj) end
        obj = PlaceObject("RatShotTrace")
        obj:SetMeshFlags(const.mfWorldSpace)
        traces[key] = obj
    end
    local meshPtr = pstr("")
    CRTrail_AppendLineSegment(meshPtr, from, to, false, false, false)
    local mat = trace_material(kind, pct)
    mat.length = from:Dist(to)
    obj:SetCRMaterial(mat)
    obj:SetMesh(meshPtr)
    obj:SetPos(from) --- so culling: com mfWorldSpace os vertices ja sao absolutos
    obj:SetVisible(true)
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

---- Estilo da fita com os alphas escalados por `pct` (idade do ataque). Copia rasa: A.MeshStyle
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

local function show_trace_line(key, from, to, kind, pct)
    local obj = traces[key]
    if not IsKindOf(obj, "RatShotTraceLine") then
        if IsValid(obj) then DoneObject(obj) end
        obj = PlaceObject("RatShotTraceLine")
        traces[key] = obj
    end
    local id = kind == "miss" and "shot_miss" or "shot_hit"
    local color = kind == "miss" and const.clrRed or const.clrGreen
    local pts = trace_points(from, to, 8)
    local st = aged_style(obj, id, pct)
    obj:SetMesh(Rat_StrokeMesh(id, pts, (st and st.color) or color, st))
    obj:SetPos(pts[1]) --- so culling: com mfWorldSpace os vertices ja sao absolutos
    obj:SetVisible(true)
end

local function show_trace(key, from, to, kind, pct)
    if P().ShotTracePindown ~= false then
        show_trace_pindown(key, from, to, kind, pct)
    else
        show_trace_line(key, from, to, kind, pct)
    end
end

---- Anel no ponto de impacto, no plano que encara a camera (dir = olho -> ponto), para ler como
---- anel de qualquer angulo. Sempre Polyline: e pequeno e por cima de tudo, como o anel de mira.
local function show_disc(key, at, style_id, radius, color, pct)
    local obj = marks[key]
    if not IsValid(obj) then
        obj = PlaceObject("RatShotMark")
        marks[key] = obj
    end
    local pts = Rat_RingPoints(at, radius, camera.GetEye() - at, P().CrosshairRingSegments or 32)
    if not pts then
        return
    end
    local st = aged_style(obj, style_id, pct)
    obj:SetMesh(Rat_StrokeMesh(style_id, pts, (st and st.color) or color, st))
    obj:SetPos(at)
    obj:SetVisible(true)
end

---- Where the bullet stopped without damaging anything (or a record from before impacts existed).
local function show_mark(key, at, kind, pct)
    local radius = P().ShotTraceMarkRadius or 120
    if kind ~= "hit" then
        radius = MulDivRound(radius, 60, 100)
    end
    local color = kind == "miss" and const.clrRed or const.clrGreen
    if kind == "stop" then
        color = (P().ShotImpactColors or empty_table).stop or RGB(170, 170, 160)
    end
    show_disc(key, at, "shot_mark", radius, color, pct)
end

local function impact_color(imp)
    local c = P().ShotImpactColors or empty_table
    if not imp.unit then
        return c.object or RGB(200, 195, 180)
    end
    return imp.crit and (c.crit or RGB(255, 190, 40)) or c.unit or RGB(225, 55, 40)
end

---- The crosshair's own body part button: circle + part icon (2 columns, normal/rollover).
local function show_part_icon(imp, pct)
    local part = imp.part and Presets.TargetBodyPart.Default[imp.part]
    local igi = part and part.Icon and GetInGameInterface()
    if not igi or not imp.pos:IsValidZ() then
        return
    end
    local w, h = UIL.MeasureImage("UI/Hud/target_icon_circle")
    ---- attached_ui puts the box origin on the point; the negative margin centers it
    local win = XWindow:new({
        HAlign = "left", VAlign = "top", Margins = box(-w / 2, -h / 2, 0, 0),
        HandleMouse = false, UseClipBox = false, rat_shot_icon = true,
        Transparency = MulDivRound(255, 100 - pct, 100)
    }, igi)
    XImage:new({
        Image = "UI/Hud/target_icon_circle", HAlign = "center", VAlign = "center",
        UseClipBox = false, ImageColor = impact_color(imp)
    }, win)
    XImage:new({
        Image = part.Icon, Columns = 2, HAlign = "center", VAlign = "center", UseClipBox = false
    }, win)
    win:AddDynamicPosModifier({id = "attached_ui", target = imp.pos})
    win:Open()
    return true
end

local function show_impact(key, imp, pct)
    if imp.unit and P().ShotPartIcons ~= false and show_part_icon(imp, pct) then
        return
    end
    local radius = P().ShotImpactRadius or 70
    if not imp.unit or imp.graze then
        radius = MulDivRound(radius, 70, 100)
    end
    show_disc(key, imp.pos, imp.graze and "shot_mark" or "shot_impact", radius, impact_color(imp), pct)
end

---- Screen-space, right of the part icon: a world label grows and shrinks with zoom and hid behind it.
local function show_label(at, row, text, color, pct)
    local igi = GetInGameInterface()
    at = Rat_RingValidZ(at)
    if not igi or not at then
        return
    end
    local w, h = UIL.MeasureImage("UI/Hud/target_icon_circle")
    local win = XWindow:new({
        HAlign = "left", VAlign = "top", MinHeight = h, MaxHeight = h,
        Margins = box(w / 2 + (P().ShotLabelGap or 3), -h / 2 + row * h, 0, 0),
        HandleMouse = false, UseClipBox = false, rat_shot_icon = true,
        Transparency = MulDivRound(255, 100 - pct, 100)
    }, igi)
    ---- setters, not constructor props: XText only measures what SetText/SetTextStyle hand it
    local label = XText:new({Translate = false, VAlign = "center", UseClipBox = false, Clip = false}, win)
    label:SetTextStyle(P().ShotLabelStyle or "CrosshairBadgeName")
    label:SetTextColor(color)
    label:SetText(text)
    win:AddDynamicPosModifier({id = "attached_ui", target = at})
    win:Open()
end

---- One number per object per attack: a burst on one unit would stack its labels on the same spot.
local function attack_labels(a, rec, pct, stacked)
    local sums, order = {}, {}
    for _, sh in ipairs(rec.shots or empty_table) do
        for _, imp in ipairs(sh.impacts or empty_table) do
            local o = imp.obj or imp.pos
            local s = sums[o]
            if not s then
                s = {damage = 0, top = imp.pos, unit = imp.unit, crit = false}
                sums[o] = s
                order[#order + 1] = o
            end
            s.damage = s.damage + imp.damage
            s.crit = s.crit or imp.crit
            if Rat_RingValidZ(imp.pos):z() > Rat_RingValidZ(s.top):z() then
                s.top = imp.pos
            end
        end
    end
    for _, o in ipairs(order) do
        local s = sums[o]
        if s.unit or P().ShotLabelObjects then
            local n = stacked[o] or 0
            stacked[o] = n + 1
            show_label(s.top, n, tostring(s.damage), impact_color(s), pct)
        end
    end
end

function Rat_HideShotTraces()
    for _, obj in pairs(traces) do
        if IsValid(obj) then
            DoneObject(obj)
        end
    end
    for _, obj in pairs(marks) do
        if IsValid(obj) then
            DoneObject(obj)
        end
    end
    close_part_icons()
    traces = {}
    marks = {}
    if watcher and watcher ~= CurrentThread() then
        DeleteThread(watcher)
    end
    watcher = false
end

---- Positions of the shooter and every unit hit, as drawn. A stale trace points at empty floor.
local function watch_moves(unit, q)
    local units = {[unit] = unit:GetPos()}
    for _, rec in ipairs(q) do
        for _, sh in ipairs(rec.shots or empty_table) do
            for _, imp in ipairs(sh.impacts or empty_table) do
                if imp.unit and IsValid(imp.obj) then
                    units[imp.obj] = imp.obj:GetPos()
                end
            end
        end
    end
    watcher = CreateRealTimeThread(function()
        while true do
            Sleep(200)
            for u, pos in pairs(units) do
                if not IsValid(u) or u:GetPos():Dist(pos) > const.SlabSizeX / 2 then
                    g_RatShotHistory[unit] = nil
                    Rat_HideShotTraces()
                    return
                end
            end
        end
    end)
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
    local ord, attacks = attack_ordinals(q)
    for a, rec in ipairs(q) do
        ---- o ataque mais novo fica cheio; os de tras descem ate `oldest`
        local pct = (attacks > 1) and
                        (oldest + MulDivRound(100 - oldest, ord[a] - 1, attacks - 1)) or 100
        ---- Z invalido degrada a aritmetica de vetor para 2D e a linha sai deitada no chao
        local from = rec.attack_pos and Rat_RingValidZ(rec.attack_pos)
        for i, sh in ipairs(rec.shots or empty_table) do
            local to = sh.end_pos
            to = to and Rat_RingValidZ(to)
            if from and to and from:Dist(to) > 0 then
                local key, kind = string.format("%d_%d", a, i), sh.miss and "miss" or "hit"
                show_trace(key, from, to, kind, pct)
                local stop_marked = false
                for j, imp in ipairs(sh.impacts or empty_table) do
                    show_impact(key .. "_" .. j, imp, pct)
                    stop_marked = stop_marked or imp.pos:Dist(to) < (P().ShotImpactMergeDist or 300)
                end
                ---- marca o impacto: so acertos por padrao (P().ShotTraceHitMarks pode incluir erros)
                if not stop_marked and P().ShotTraceHitMarks ~= false and
                    (kind == "hit" or P().ShotTraceHitMarks == "all") then
                    show_mark(key, to, sh.impacts and "stop" or kind, pct)
                end
                n = n + 1
            end
        end
    end
    ---- newest first, so its number sits lowest on a unit hit by several attacks
    local stacked = {}
    for a = #q, 1, -1 do
        local pct = (attacks > 1) and
                        (oldest + MulDivRound(100 - oldest, ord[a] - 1, attacks - 1)) or 100
        attack_labels(a, q[a], pct, stacked)
    end
    watch_moves(unit, q)
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

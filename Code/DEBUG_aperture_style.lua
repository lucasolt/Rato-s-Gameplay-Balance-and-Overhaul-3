---------------------------------------------------------------------------------------------------
---- AFINADOR DE ESTILO dos tracos do crosshair. Tudo pelo console, ao vivo, sem reload.
----
---- O que ele afina esta em A.MeshStyle (__ApertureParams.lua), uma entrada por traco:
----     ring  -- o anel do cone
----     wedge -- a cunha do recuo herdado
----     climb -- a regua da rajada
----     fanl / fanr -- o leque dela
----
---- Comece por Rat_StyleHelp(). O ciclo de trabalho e Rat_StyleDemo() para por as tres formas na
---- tela sem precisar de crosshair aberto, Rat_StyleNext("wedge") ate gostar, e Rat_StyleDump()
---- para colar o resultado nos parametros -- senao ele morre com a sessao.
---------------------------------------------------------------------------------------------------

local ids = {"ring", "wedge", "climb", "fanl", "fanr"}

local function P()
    return const.Combat.Aperture
end

---- Depth test que ESTE shader aceita. Fora de "runtime" o engine assere, entao pedir o valor
---- errado nao daria uma tela feia, daria um assert no meio do ajuste.
local function fit_depth(name, want)
    local sh = (ProceduralMeshShaders or empty_table)[name]
    if not sh or sh.depth_test == "runtime" then
        return want and true or false
    end
    return sh.depth_test == "always"
end

local function style_of(id)
    local t = P().MeshStyle
    if not t then
        return nil
    end
    t[id] = t[id] or {shader = "default_polyline", depth = false, color = false}
    return t[id]
end

---- Nomes de shader em ordem, com o que cada um aceita de depth test. A lista sai do engine e nao
---- de uma copia: ela cresce com o jogo, e uma copia envelheceria calada.
function Rat_StyleShaders(filter)
    local out = {}
    for name, sh in sorted_pairs(ProceduralMeshShaders or empty_table) do
        if not filter or name:find(filter, 1, true) then
            out[#out + 1] = {name = name, depth = sh.depth_test}
        end
    end
    return out
end

---- Reaplica o estilo nos tracos que ja estao na tela. Sem isto so o proximo update do crosshair
---- mostraria a troca, e ai nao da para comparar duas opcoes lado a lado.
function Rat_StyleApply()
    local n = 0
    for id, obj in pairs(Rat_LiveStrokes()) do
        if IsValid(obj) then
            obj.rat_shader = false --- forca, senao o guarda de "nao mudou" engole a troca
            local rec = Rat_LastStroke(id)
            if rec then
                Rat_ShowStroke(id, rec.pts, rec.color_raw, rec.anchor) --- reemitir: width/fill/dash mudam a geometria
            else
                Rat_StrokeStyle(obj, id)
            end
            n = n + 1
        end
    end
    return n
end

local function shape_of(st)
    local s = st.fill and "fill" or (((st.width or 0) > 0) and ("fita " .. st.width) or "linha")
    return ((st.dash or 0) > 0) and (s .. " tracej") or s
end

local function apply_and_report(id)
    local st = style_of(id)
    local live = Rat_StyleApply()
    return string.format("%-6s %-12s shader %-20s depth %-5s cor %s   (%d na tela)", id,
                         shape_of(st), tostring(st.shader), tostring(st.depth),
                         st.color and string.format("%d", st.color) or "do CTH", live)
end

---- Le ou escreve o estilo de um traco. Sem argumentos, mostra todos.
---- `id` pode ser "all" para escrever em todos de uma vez.
function Rat_Style(id, shader, depth)
    if not id then
        local out = {"A.MeshStyle -- Rat_StyleHelp() para o resto"}
        for _, k in ipairs(ids) do
            local st = style_of(k)
            out[#out + 1] = string.format("  %-6s %-24s depth %-5s cor %s", k, tostring(st.shader),
                                          tostring(st.depth),
                                          st.color and tostring(st.color) or "do CTH")
        end
        return table.concat(out, "\n")
    end

    local targets = (id == "all") and ids or {id}
    if shader then
        if not (ProceduralMeshShaders or empty_table)[shader] then
            return "shader desconhecido: " .. tostring(shader) ..
                       "  -- Rat_StyleList() mostra os que existem"
        end
        for _, k in ipairs(targets) do
            local st = style_of(k)
            st.shader = shader
            st.depth = fit_depth(shader, (depth ~= nil) and depth or st.depth)
        end
    end
    local out = {}
    for _, k in ipairs(targets) do
        out[#out + 1] = apply_and_report(k)
    end
    return table.concat(out, "\n")
end

---- Anda na lista de shaders sem ter de decorar nome nenhum: e o modo de comparar de verdade,
---- chamando a mesma linha varias vezes e olhando a tela.
local function step(id, dir)
    local list = Rat_StyleShaders()
    local st = style_of(id)
    local at = 1
    for i, s in ipairs(list) do
        if s.name == st.shader then
            at = i
        end
    end
    local nxt = list[(at - 1 + dir) % #list + 1]
    st.shader = nxt.name
    st.depth = fit_depth(nxt.name, st.depth)
    return apply_and_report(id)
end

function Rat_StyleNext(id)
    return step(id or "wedge", 1)
end

function Rat_StylePrev(id)
    return step(id or "wedge", -1)
end

---- Cor fixa para o traco, ou nil para devolver o comando a cor do CTH.
---- `r` aceita OU os componentes (r, g, b[, alpha]) OU uma cor ja empacotada (const.clrRed,
---- RGB(...), RGBA(...)) -- e um numero dos dois jeitos, entao so g decide qual e.
function Rat_StyleColor(id, r, g, b, alpha)
    local st = style_of(id or "wedge")
    st.color = r and (g and RGBA(r, g, b, alpha or 255) or r) or false
    return apply_and_report(id or "wedge")
end

---- Largura da FITA (meia-largura, unidades de mundo). 0 volta a linha de 1px. `halo` e `alpha`
---- opcionais afinam o passe externo translucido e o nucleo.
function Rat_StyleWidth(id, width, halo, alpha)
    local st = style_of(id or "wedge")
    st.width = width
    if halo ~= nil then st.halo = halo end
    if alpha ~= nil then st.coreAlpha = alpha end
    return apply_and_report(id or "wedge")
end

---- Tracejado: comprimento de traco e vao. 0 volta a continuo.
function Rat_StyleDash(id, len)
    style_of(id or "fanl").dash = len
    return apply_and_report(id or "fanl")
end

---- Desbota o % final do comprimento ate transparente.
function Rat_StyleFade(id, pct)
    style_of(id or "wedge").tipFade = pct
    return apply_and_report(id or "wedge")
end

---- Preenche a regiao fechada do contorno (leque de triangulos) alem do contorno.
function Rat_StyleFill(id, on, alpha)
    local st = style_of(id or "wedge")
    st.fill = on or nil
    if alpha ~= nil then st.fillAlpha = alpha end
    return apply_and_report(id or "wedge")
end

function Rat_StyleList(filter)
    local out = {}
    for _, s in ipairs(Rat_StyleShaders(filter)) do
        out[#out + 1] = string.format("  %-24s depth_test %s", s.name, tostring(s.depth))
    end
    return #out > 0 and table.concat(out, "\n") or "nenhum shader casa com " .. tostring(filter)
end

---------------------------------------------------------------------------------------------------
---- CENA de teste. As tres formas na tela sem depender de crosshair aberto -- que e o que trava o
---- ajuste, porque o crosshair fecha assim que se abre o console.
---------------------------------------------------------------------------------------------------

---- Numeros PLAUSIVEIS, nao os do ataque de agora: a cena existe para comparar shader, e um alvo
---- que se mexe entre duas chamadas nao serve de referencia.
function Rat_StyleDemo(unit, shots)
    unit = unit or SelectedObj
    if not IsValid(unit) then
        return "sem unidade: Rat_StyleDemo(SelectedObj) com alguem selecionado"
    end
    local a = P()
    local center = Rat_RingValidZ(unit:GetVisualPos()) + point(0, 0, 1200)
    local dir = Rotate(point(4000, 0, 0), unit:GetAngle())
    local origin = center - dir
    local dist = dir:Len()

    local sigma, sy, fan = 80, 320, 240
    local spread = MulDivRound(sigma, a.CrosshairSigmaMul or 250, 100)
    local radius = Rat_ConeRadius(dist, spread)
    Rat_ShowConeRing(center, radius, dir, RGB(80, 220, 120))

    local up = SetLen(Rat_PerpUp(SetLen(dir, 1000)), 1000)
    local lat = Rat_RecoilLateralAxis(up, dir)
    local function at(dy, dx)
        return Rat_RecoilWalkPoint(origin, center, up, dy, lat, dx)
    end

    ---- a cunha, com a mesma matematica do crosshair (angular; quem converte e o `at`)
    local mul = a.CrosshairWedgeSigmaMul or 200
    local top, wide = MulDivRound(sy, mul, 100), spread + MulDivRound(fan, mul, 100)
    local tick = MulDivRound(wide - spread, a.CrosshairRecoilTickPct or 22, 100)
    Rat_ShowStroke("wedge", Rat_WedgeContour(at, spread, top, wide, tick), RGB(230, 200, 90), center)

    ---- a regua da rajada, com uma subida qualquer que cresce e um leque que abre
    shots = Max(2, shots or 5)
    local path, fl, fr = {}, {}, {}
    for i = 1, shots do
        local dy = MulDivRound(sy, i - 1, shots - 1)
        local w = spread + MulDivRound(fan, i - 1, shots - 1)
        local p = at(dy, 0)
        path[#path + 1] = p
        path[#path + 1] = at(dy, -tick)
        path[#path + 1] = at(dy, tick)
        path[#path + 1] = p
        fl[#fl + 1], fr[#fr + 1] = at(dy, -w), at(dy, w)
    end
    Rat_ShowStroke("climb", path, RGB(200, 120, 200), center)
    Rat_ShowStroke("fanl", fl, RGB(200, 120, 200), center)
    Rat_ShowStroke("fanr", fr, RGB(200, 120, 200), center)

    return string.format("cena em %s: anel r %d, cunha %d de altura, regua de %d tiros. " ..
                             "Rat_StyleNext(\"wedge\") para trocar, Rat_StyleDemoOff() para limpar.",
                         unit.session_id or unit.class, radius, MulDivRound(dist, top, 3438), shots)
end

function Rat_StyleDemoOff()
    Rat_HideConeRing()
    return "cena limpa"
end

---- O bloco pronto para colar em __ApertureParams.lua. Sem isto o ajuste morre com a sessao, que e
---- o jeito mais facil de perder meia hora de comparacao.
local dump_keys = {"shader", "depth", "color", "width", "halo", "coreAlpha", "haloAlpha", "tipFade",
                   "dash", "fill", "fillAlpha"}

function Rat_StyleDump()
    local out = {"A.MeshStyle = {"}
    for _, k in ipairs(ids) do
        local st = style_of(k)
        local parts = {}
        for _, key in ipairs(dump_keys) do
            local v = st[key]
            if v ~= nil then
                if key == "shader" then
                    v = string.format("%q", tostring(v))
                elseif key == "color" then
                    v = v and tostring(v) or "false"
                else
                    v = tostring(v)
                end
                parts[#parts + 1] = string.format("%s = %s", key, v)
            end
        end
        out[#out + 1] = string.format("    %s = {%s},", k, table.concat(parts, ", "))
    end
    out[#out + 1] = "}"
    return table.concat(out, "\n")
end

function Rat_StyleHelp()
    return table.concat({
        "AFINADOR DE ESTILO -- tracos: ring, wedge, climb, fanl, fanr",
        "",
        "  Rat_StyleDemo()                 poe as tres formas na tela (usa SelectedObj)",
        "  Rat_StyleDemoOff()              limpa",
        "",
        "  Rat_Style()                     mostra o estilo de todos",
        "  Rat_StyleNext(\"wedge\")          proximo shader; chame de novo para continuar",
        "  Rat_StylePrev(\"wedge\")          o anterior",
        "  Rat_Style(\"wedge\", \"cone\")      escolhe pelo nome",
        "  Rat_Style(\"all\", \"soft_mesh\")   todos de uma vez",
        "  Rat_Style(\"ring\", \"cone\", true) com depth test (so onde o shader deixa)",
        "  Rat_StyleColor(\"wedge\", 230, 200, 90)   cor fixa; sem argumentos volta a cor do CTH",
        "  Rat_StyleColor(\"wedge\", const.clrRed)   ou uma cor ja empacotada (RGB/RGBA/const.clr*)",
        "",
        "  Rat_StyleWidth(\"wedge\", 14, 20)  meia-largura da fita (+ halo); 0 volta a linha 1px",
        "  Rat_StyleFill(\"wedge\", true, 55) preenche a regiao (alpha 55)",
        "  Rat_StyleDash(\"fanl\", 90)        tracejado de 90; 0 continuo",
        "  Rat_StyleFade(\"fanl\", 45)        desbota os 45% finais do comprimento",
        "",
        "  Rat_StyleList()                 todos os shaders do engine",
        "  Rat_StyleList(\"line\")           so os que tem \"line\" no nome",
        "  Rat_StyleDump()                 bloco pronto para colar em __ApertureParams.lua",
        "",
        "A troca vale JA nos tracos que estao na tela, e tambem no proximo crosshair.",
        "Mas so o Dump colado nos parametros sobrevive a sessao.",
    }, "\n")
end

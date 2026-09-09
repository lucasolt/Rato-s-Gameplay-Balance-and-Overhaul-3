---------------------------------------------------------------------------------------------------
---- CROSSHAIR: o circulo de mira passa a mostrar a ABERTURA de verdade.
---- O vanilla (`idAimTarget`) so encolhe uma imagem 2D com o nivel de mira e a logica ficou pela
---- metade (ActionCameraCrosshair.lua:224-265). Aqui ele da lugar a um anel NO MUNDO, no plano do
---- alvo e perpendicular a linha de tiro -- o mesmo circulo do DEBUG_aperture_draw. Ver UI_aperture_ring.
---- Com A.Enabled = false a funcao original volta a ser chamada, sem alteracao.
---------------------------------------------------------------------------------------------------

local vanilla_update --- OnContextUpdate original do template, para o fallback
local debug = Platform.developer and Platform.rat

---------------------------------------------------------------------------------------------------
---- ESCADA DO RECUO. Duas coisas que o anel redondo nao conseguia dizer:
---- o recuo herdado do ataque anterior ALONGA o anel no eixo vertical -- o atirador reencara o
---- alvo, so que pior naquele eixo, entao a elipse fica em cima do inimigo e nao ao lado dele;
---- e a rajada ganha a regua do que o cano vai subir, uma barra por tiro, entre duas diagonais
---- simetricas. Mesmos numeros de Rat_DbgRecoilAt, sem os discos e sem a tabela.
---------------------------------------------------------------------------------------------------

---- Memo do estimador: o crosshair atualiza a cada hover de body part e a cada nivel de mira, e
---- Monte Carlo por frame nao se paga para desenhar um traco. A FORMA nao depende do alvo -- ela
---- sai so do perfil e do offset -- entao a chave nao precisa de theta nem de sigma.
local e_att, e_wep, e_act, e_aim, e_n, e_est

local function ladder_estimate(attacker, action, weapon, aim, num_shots)
    if e_att == attacker and e_wep == weapon and e_act == action and e_aim == aim and
        e_n == num_shots then
        return e_est
    end
    local prof = Rat_RecoilProfile(attacker, action, weapon, num_shots)
    ---- sem theta/sigma o estimador pula o Rice por tiro: aqui so a geometria do passeio interessa
    e_est = prof and Rat_EstimateBurst(prof, nil, nil, num_shots,
                                       const.Combat.Aperture.CrosshairRecoilSamples)
    e_att, e_wep, e_act, e_aim, e_n = attacker, weapon, action, aim, num_shots
    return e_est
end

---- Cor da escada: a MESMA do anel, so clareada. Um segundo tom diria "outra coisa" e a escada e o
---- mesmo tiro; alpha ficaria a criterio do shader do Polyline. Clareia em vez de escurecer --
---- escurecendo, o traco sumia contra o terreno e ficava mais dificil de ler que o anel.
local function tint(r, g, b)
    local pct = const.Combat.Aperture.CrosshairRecoilTintPct or 0
    local function up(c)
        return Clamp(c + MulDivRound(255 - c, pct, 100), 0, 255)
    end
    return RGB(up(r), up(g), up(b))
end

---- Tracos da rajada, em pontos de mundo. `at(dy, dx)` poe um desvio angular no plano do alvo.
---- Uma regua reta para cima com uma barra por tiro, e duas diagonais simetricas em volta dela.
----
---- RETA E SIMETRICA de proposito, e nao pelo caminho que o cano faz de verdade. O passeio tem uma
---- deriva lateral -- o coice sai a RecoilKickAngle da vertical, e a media de poucas amostras
---- treme por cima disso -- entao o traco saia torto ja com tres tiros e numa rajada de dez se
---- dobrava sobre si mesmo. Nada disso e leitura util: ninguem planeja um tiro pelo lado para o
---- qual o cano vai puxar. O que se le aqui e QUANTO, e para os lados isso e "pode ir para
---- qualquer um dos dois", que e o que duas diagonais simetricas dizem.
----
---- ALTURA = distancia media ao alvo, nao distancia do ponto medio. As duas divergem no fim de uma
---- rajada longa: mediar uma nuvem que se abre puxa o ponto medio de volta para o alvo bem mais do
---- que qualquer rajada volta. MEDIDO (AK47, 14 tiros): entre os tiros 7 e 14 o ponto medio cai de
---- 407' para 239' (-70%) e a distancia media so de 534' para 408' (-24%). O atirador retoma o
---- controle de verdade -- so que tres vezes menos. A distancia e o que o CTH sente.
----
---- LARGURA = maximo corrido do grupo. E envelope, nao serie: "ate aqui pode abrir" nao volta a
---- fechar so porque o tiro seguinte, na media, agrupa um pouco melhor. Tambem e o que impede o V
---- de estrangular no meio de uma rajada longa.
---- Sai DO ANEL, e as alturas sao o quanto a rajada afasta ALEM de onde o cano ja esta -- por isso
---- descontam o tiro 1. O anel e uma posicao de verdade, com lado e tudo; a regua e reta. Medir a
---- regua a partir do alvo deixaria as duas separadas sempre que o recuo herdado tivesse
---- componente lateral, e o desenho pareceria quebrado em vez de ser uma coisa so.
local function ladder_strokes(est, num_shots, at, tick, spread)
    local mean_dist = const.Combat.Aperture.CrosshairRecoilMeanDistance
    local function reach(i)
        return mean_dist and est.offset[i] or
                   Rat_ISqrt(est.px[i] * est.px[i] + est.py[i] * est.py[i])
    end
    local base = reach(1)
    local path, fan_l, fan_r = {}, {}, {}
    local widest, first_w, last_dy = 0, nil, 0
    for i = 1, num_shots do
        local dy = Max(0, reach(i) - base)
        widest = Max(widest, est.spread[i])
        first_w = first_w or widest
        last_dy = dy
        local p = at(dy, 0)
        ---- barra para os DOIS lados, e volta: um mesh de Polyline e uma tira so, e o retrace
        ---- repinta os mesmos pixels -- na tela e uma regua com um trinco em cada tiro. Uma barra
        ---- so para a direita ja seria um vies lateral, que e justamente o que nao se quer dizer.
        path[#path + 1] = p
        path[#path + 1] = at(dy, -tick)
        path[#path + 1] = at(dy, tick)
        path[#path + 1] = p
        fan_l[#fan_l + 1] = at(dy, -widest)
        fan_r[#fan_r + 1] = at(dy, widest)
    end

    ---- Comprimento minimo do leque. Em distancia curta o passeio inteiro cabe em poucos minutos:
    ---- o leque encolhe para dentro das barras da regua e sobra pouco tipFade para calibrar.
    ---- Prolonga a MESMA diagonal -- a reta de (0, w1) a (last_dy, widest) -- ate o piso, em vez de
    ---- subir reto: a largura verdadeira ja esta nas barras da regua, entao continuar o angulo so da
    ---- espaco ao tipFade sem afirmar largura nova. Teto de 2x na largura para o passeio quase nulo
    ---- (diagonal quase vertical) nao esparramar. Piso em % do raio do anel.
    local floor = MulDivRound(spread or 0, const.Combat.Aperture.CrosshairFanMinPct or 0, 100)
    if floor > last_dy then
        local w_ext = widest
        if last_dy > 0 and widest > first_w then
            w_ext = Min(2 * widest,
                        widest + MulDivRound(widest - first_w, floor - last_dy, last_dy))
        end
        fan_l[#fan_l + 1] = at(floor, -w_ext)
        fan_r[#fan_r + 1] = at(floor, w_ext)
    end
    return path, fan_l, fan_r
end

---- Contorno da cunha: dois bracos da MIRA (at(0,0)) ate as pontas em (top, +-wide), com trinco
---- opcional. Apagar o inicio (a cunha em cima do alvo) e trabalho do baseFade no desenho, nao da
---- geometria -- ver A.MeshStyle.wedge. Compartilhado com o afinador (Rat_StyleDemo), por isso e
---- global e recebe top/wide ja calculados.
function Rat_WedgeContour(at, top, wide, tick)
    local function arm(sign)
        local p = at(top, sign * wide)
        if tick and tick > 0 then
            return {at(0, 0), p, at(top, sign * (wide - tick)), p, at(0, 0)}
        end
        return {at(0, 0), p, at(0, 0)}
    end
    local pts = arm(-1)
    for _, p in ipairs(arm(1)) do
        pts[#pts + 1] = p
    end
    return pts
end

---- A CUNHA do recuo herdado, no mesmo idioma da V da rajada: dois tracos saindo do ponto de mira
---- para cima, abrindo. Diz as duas coisas de uma vez -- ate onde o cano pode ter subido (a altura)
---- e o quanto ele pode ter vagado de lado la em cima (a abertura), que e exatamente a cunha que
---- Rat_SeparableCTH integra e que a bala dispara.
---- Sem recuo herdado nao ha o que desenhar e os tracos somem, senao mentiriam sobre um ataque
---- que ainda nao aconteceu.
---- `spread` e o raio do anel EM MINUTOS. Tudo aqui e angular: quem converte para mundo e o
---- proprio `at` (offset_along faz dist * minutos / 3438). Passar comprimento ja convertido
---- aplicava a conversao duas vezes e a cunha saia dist/3438 vezes maior do que e.
local function persist_wedge(at, spread, sigma, sy, fan, color, anchor)
    if not sy or not fan or sy <= sigma or fan < 1 then
        return Rat_HideStroke("wedge")
    end
    local a = const.Combat.Aperture

    ---- 200%, nao os 250% do anel: aquilo e o envelope de uma Rayleigh 2D, e a altura da cunha e
    ---- UM eixo -- 2 sigma ja e 95% dele.
    local mul = a.CrosshairWedgeSigmaMul or 200
    local top = MulDivRound(sy, mul, 100)
    local wide = spread + MulDivRound(fan, mul, 100)

    ---- Teto de DESENHO. sigma_y chega a seis vezes o cone, e a ponta fiel saia do alvo, passava
    ---- por tras dos widgets do crosshair e nao dizia mais nada. Cortar calado seria mentir, entao
    ---- a convencao e o TRINCO no fim de cada braco: com trinco a cunha acaba ali, sem trinco ela
    ---- continua para cima.
    local lim = MulDivRound(spread, a.CrosshairWedgeMaxPct or 400, 100)
    local cut = top > lim
    if cut then
        wide = spread + MulDivRound(wide - spread, lim, top)
        top = lim
    end

    ---- ABERTA em cima: fechar dava uma barra atravessada bem onde esta o alvo. Os dois bracos saem
    ---- de um apex comum -- e o ponto que faz duas diagonais virarem uma regiao -- e o traco volta
    ---- por ele, porque um mesh de Polyline e uma tira continua e o retrace repinta os mesmos pixels.
    ---- Trinco no fim de cada braco quando a cunha cabe inteira; sem trinco ela continua para cima.
    local tick = cut and 0 or MulDivRound(wide - spread, a.CrosshairRecoilTickPct or 0, 100)
    Rat_ShowStroke("wedge", Rat_WedgeContour(at, top, wide, tick), color, anchor)
end

---- Sai do caminho: devolve o circulo 2D e apaga o anel do mundo.
local function fallback(self, context, ...)
    Rat_HideConeRing()
    if self.idAimTarget then
        self.idAimTarget:SetVisible(true)
    end
    return vanilla_update(self, context, ...)
end

---- Desenha o anel a partir do estado do CROSSHAIR, nao do widget: passar o mouse pelas body
---- parts chama SetSelectedPart (muda targetPart) sem disparar update de contexto nenhum.
---- false = o modelo nao se aplica aqui; o chamador volta ao circulo 2D.
function Rat_UpdateConeRing(crosshair)
    local a = const.Combat.Aperture
    if not (a and a.Enabled) or not crosshair or not crosshair.context or
        crosshair.window_state == "destroying" or crosshair.window_state == "pre-destroying" then
        return false
    end

    local c = crosshair.context
    local attacker = c.attacker
    local target = c.target

    ---- registra o alvo mirado para as funcoes de debug usarem "o ultimo do crosshair"
    if debug and IsValid(target) and IsValid(attacker) then
        g_RatDbgCrosshairTarget = target
    end

    local action = crosshair.show_data_for_action or c.action
    local weapon = attacker and action and action:GetAttackWeapons(attacker)

    if not IsValid(attacker) or not IsValid(target) or not action or
        not IsACHTActive(weapon, action, attacker) then
        return false
    end

    local aim = crosshair.aim or 0
    local part = crosshair.targetPart and crosshair.targetPart.id
    local step_pos = c.override_pos or attacker:GetPos()

    ---- UM cone so, o mesmo que Rat_SimPlanShots dispara: quem o resolve e CalcChanceToHit
    ---- (geometria + residuais ja em cone) e ele o devolve nos proprios args.
    local target_pos = target:GetPos()
    local sigma, theta, cth, sy, sy_dn, fan = Rat_AttackCone(attacker, target, action, part, aim,
                                                             false, step_pos, target_pos)
    if not sigma or not theta or theta < 1 then
        return false
    end
    local dist = step_pos:Dist(target_pos)

    ---- raio que contem ~96% dos tiros (2.5 sigma), nao 1 sigma cru -- ver A.CrosshairSigmaMul.
    local spread = MulDivRound(sigma, a.CrosshairSigmaMul, 100)

    ---- mesma escala de cor da linha Aperture no overlay (Rat_QualityColor): o anel e o texto
    ---- respondem ao mesmo numero, entao a cor quer dizer a mesma coisa nos dois.
    local cr, cg, cb = Rat_QualityColor(cth)
    local color = RGB(cr, cg, cb)

    ---- ancora no spot da parte mirada; plano perpendicular a linha de tiro. `dist` vai ate o pe
    ---- do alvo, como no CTH: a diferenca de altura nao move o raio 1 cm.
    local center = Rat_RingAnchor(target, part)
    if not center then
        return false
    end

    local origin = Rat_RingValidZ(step_pos)
    local radius = Rat_ConeRadius(dist, spread)
    local dir = center - origin

    ---- FORMA DESENHADA, independente da forma do CALCULO. Rat_ConeSigmaY nao olha
    ---- A.RecoilPersistShape: os dois meios-eixos verticais sao reais nos dois modos, entao o anel
    ---- e honesto tambem com CTH de cunha. E ele diz o LEQUE tambem: `rfan` alarga a metade de cima
    ---- com a mesma rampa que Rat_SeparableCTH integra -- cresce com a altura, satura em 1 sigma_y.
    ---- Sem isso o anel afila no topo (meio-eixo maior, largura igual) e o ovo le mais largo
    ---- EMBAIXO, que e o contrario do que o modelo diz. Ver A.CrosshairRecoilShape.
    local shape = a.CrosshairRecoilShape
    if not shape or shape == "auto" then
        shape = (a.RecoilPersistShape == "egg") and "ring" or "wedge"
    end
    local draw_wedge = (shape == "wedge" or shape == "both")
    local ry, ry_dn, rfan, rfan_sat
    if (shape == "ring" or shape == "both") and sy and sy_dn then
        local function ray(s)
            return Rat_ConeRadius(dist, MulDivRound(s, a.CrosshairSigmaMul, 100))
        end
        ry, ry_dn = ray(sy), ray(sy_dn)
        if fan and fan > 0 then
            ---- o leque escala como todo o resto (2.5 sigma); a saturacao NAO -- ela e 1 sigma_y,
            ---- que e onde o somatorio do CTH para de alargar.
            rfan, rfan_sat = ray(fan), Rat_ConeRadius(dist, sy)
        end
    end

    if not a.CrosshairRecoilLadder then
        Rat_ShowConeRing(center, radius, dir, color, nil, ry, ry_dn, rfan, rfan_sat)
        return true
    end

    local num_shots = 1
    local ok, n = pcall(weapon.GetAutofireShots, weapon, action)
    if ok and type(n) == "number" then
        num_shots = Max(1, n)
    end

    local up = SetLen(Rat_PerpUp(SetLen(dir, 1000)), 1000)
    local lat = Rat_RecoilLateralAxis(up, dir)
    local function at(dy, dx)
        return Rat_RecoilWalkPoint(origin, center, up, dy, lat, dx)
    end

    ---- o anel fica NO ALVO, so mais alto: o recuo herdado e incerteza, nao um cano parado fora
    ---- do alvo. A regua da rajada nasce dele, e dentro da rajada sim o cano anda de verdade.
    Rat_ShowConeRing(center, radius, dir, color, nil, ry, ry_dn, rfan, rfan_sat)

    local faded = tint(cr, cg, cb)
    if draw_wedge then
        persist_wedge(at, spread, sigma, sy, fan, faded, center)
    else
        Rat_HideStroke("wedge")
    end

    local est = (num_shots > 1) and ladder_estimate(attacker, action, weapon, aim, num_shots)
    if not est then
        Rat_HideStroke("climb")
        Rat_HideStroke("fanl")
        Rat_HideStroke("fanr")
        return true
    end

    local path, fan_l, fan_r = ladder_strokes(est, num_shots, at,
                                              MulDivRound(spread, a.CrosshairRecoilTickPct or 0, 100),
                                              spread)
    Rat_ShowStroke("climb", path, faded, center)
    Rat_ShowStroke("fanl", fan_l, faded, center)
    Rat_ShowStroke("fanr", fan_r, faded, center)
    return true
end

---- Rollover nas body parts so mexe em targetPart; sem isto o anel so acompanharia o clique.
function OnMsg.ClassesBuilt()
    local cls = g_Classes.CrosshairUI
    if not cls or cls.rat_ring_part_patched then
        return
    end
    local vanilla_set_part = cls.SetSelectedPart
    cls.rat_ring_part_patched = true
    cls.SetSelectedPart = function(self, part, ...)
        local res = vanilla_set_part(self, part, ...)
        Rat_UpdateConeRing(self)
        return res
    end
end

---- Acha o no cujo filho direto tem Id "idAimTarget". Busca por estrutura, nao pelo caminho fixo,
---- para nao quebrar se a Haemimont mexer no layout.
local function find_aim_circle_node(root)
    local found
    local function walk(node, depth)
        if found or depth > 14 or type(node) ~= "table" then
            return
        end
        for _, child in ipairs(node) do
            if type(child) == "table" then
                if node.OnContextUpdate and child.Id == "idAimTarget" then
                    found = node
                    return
                end
                walk(child, depth + 1)
                if found then
                    return
                end
            end
        end
    end
    walk(root, 0)
    return found
end

function Rat_PatchCrosshairAimCircle(force)
    local tpl = XTemplates and XTemplates.ActionCameraCrosshair
    if not tpl then
        return false, "XTemplates.ActionCameraCrosshair nao encontrado"
    end

    local node = find_aim_circle_node(tpl)
    if not node then
        return false, "no do idAimTarget nao encontrado no template"
    end
    if node.rat_aperture_patched and not force then
        return true, "ja aplicado"
    end

    vanilla_update = node.OnContextUpdate
    node.rat_aperture_patched = true

    node.OnContextUpdate = function(self, context, ...)
        if not Rat_UpdateConeRing(self:ResolveId("node")) then
            return fallback(self, context, ...)
        end
        self.idAimTarget:SetVisible(false) --- o anel do mundo substitui a imagem 2D
    end

    return true, "aplicado"
end

---------------------------------------------------------------------------------------------------
---- Diagnostico: que raio o anel teria no alvo, por nivel de mira
---------------------------------------------------------------------------------------------------

function Rat_ShowCrosshairScale(target, attacker)
    attacker = attacker or SelectedObj
    if not attacker then
        return "sem atacante"
    end
    if not target and attacker == SelectedObj and Rat_DbgCrosshairTarget then
        target = Rat_DbgCrosshairTarget(attacker)
    end
    if not target then
        for _, o in ipairs(g_Units or empty_table) do
            if o ~= attacker and not o:IsDead() and attacker:IsOnEnemySide(o) then
                target = o
                break
            end
        end
    end
    if not target then
        return "sem alvo"
    end

    local a = const.Combat.Aperture
    local weapon = attacker:GetActiveWeapons()
    local action = attacker:GetDefaultAttackAction("ranged")
    if not IsKindOf(weapon, "Firearm") or not action then
        return "sem arma de fogo"
    end

    local was = a.Enabled
    a.Enabled = true

    local out = {
        string.format("%s (%s) -> %s a %.1f tiles  [circulo = %.1f sigma, ~96%% dos tiros]",
                      tostring(attacker.session_id), tostring(weapon.class),
                      tostring(target.session_id),
                      attacker:GetDist(target) / const.SlabSizeX,
                      a.CrosshairSigmaMul / 100.0),
        "aim | sigma  grupo   alvo | raio cm | CTH | grupo vs alvo"
    }
    for aim = 0, 4 do
        local sigma, theta, cth = Rat_AttackCone(attacker, target, action, nil, aim, false,
                                                 attacker:GetPos(), target:GetPos())
        local dist = attacker:GetDist(target)
        local spread = MulDivRound(sigma, a.CrosshairSigmaMul, 100)
        out[#out + 1] = string.format(" %d  | %5d %6d %6d | %7d | %3d%% | %s", aim, sigma, spread,
                                      theta, Rat_ConeRadius(dist, spread) / 10, cth,
                                      (theta >= 1 and spread <= theta) and "cabe" or "transborda")
    end

    a.Enabled = was
    return table.concat(out, "\n")
end

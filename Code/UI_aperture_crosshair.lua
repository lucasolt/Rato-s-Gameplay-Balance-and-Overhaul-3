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
---- ESCADA DO RECUO. O anel sempre disse a largura do cone e nunca disse para ONDE ele aponta --
---- coisa que so passou a existir quando o cano ganhou posicao propria. Duas informacoes entram:
---- o anel vai para onde o cano ESTA (recuo herdado do ataque anterior), e a rajada ganha o
---- caminho que ele vai fazer, uma barra por tiro, entre duas diagonais que abrem com a largura
---- do grupo ali. Sao os mesmos numeros de Rat_DbgRecoilAt, sem os discos e sem a tabela.
---------------------------------------------------------------------------------------------------

---- Memo do estimador: o crosshair atualiza a cada hover de body part e a cada nivel de mira, e
---- Monte Carlo por frame nao se paga para desenhar um traco. A FORMA nao depende do alvo -- ela
---- sai so do perfil e do offset -- entao a chave nao precisa de theta nem de sigma.
local e_att, e_wep, e_act, e_aim, e_n, e_px, e_py, e_est

local function ladder_estimate(attacker, action, weapon, aim, num_shots, p0x, p0y)
    if e_att == attacker and e_wep == weapon and e_act == action and e_aim == aim and
        e_n == num_shots and e_px == p0x and e_py == p0y then
        return e_est
    end
    local prof = Rat_RecoilProfile(attacker, action, weapon, num_shots)
    ---- sem theta/sigma o estimador pula o Rice por tiro: aqui so a geometria do passeio interessa
    e_est = prof and Rat_EstimateBurst(prof, nil, nil, num_shots,
                                       const.Combat.Aperture.CrosshairRecoilSamples, nil, p0x, p0y)
    e_att, e_wep, e_act, e_aim, e_n, e_px, e_py = attacker, weapon, action, aim, num_shots, p0x, p0y
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
---- Devolve o caminho (com uma barra por tiro) e as duas diagonais do grupo.
----
---- A DIRECAO vem do ponto medio; o COMPRIMENTO, de `offset` -- a distancia media ao alvo, nao a
---- distancia do ponto medio. As duas divergem muito no fim de uma rajada longa: mediar uma nuvem
---- que se abre puxa o ponto medio de volta para o alvo mesmo quando rajada nenhuma volta.
---- MEDIDO (AK47, 14 tiros): o ponto medio vai de 407' a 239' entre os tiros 7 e 14 (-70%),
---- enquanto a distancia media so cai de 534' a 408' (-24%). O atirador REALMENTE retoma o
---- controle -- so que tres vezes menos do que o ponto medio sugere. E a distancia que o CTH
---- sente, entao e ela que o traco tem que mostrar.
local function ladder_strokes(est, num_shots, at, tick)
    local mean_dist = const.Combat.Aperture.CrosshairRecoilMeanDistance
    local path, fan_l, fan_r = {}, {}, {}
    for i = 1, num_shots do
        local dy, dx, w = est.py[i], est.px[i], est.spread[i]
        if mean_dist then
            local len = Rat_ISqrt(dx * dx + dy * dy)
            if len > 0 then
                dx, dy = MulDivRound(dx, est.offset[i], len), MulDivRound(dy, est.offset[i], len)
            else
                dy = est.offset[i] --- tiro 1 sem offset herdado: nao ha direcao, so a subida
            end
        end
        local p = at(dy, dx)
        ---- ida e volta na barra: um mesh de Polyline e uma tira so, e o retrace repinta os
        ---- mesmos pixels -- na tela e uma linha com um trinco em cada tiro.
        path[#path + 1] = p
        path[#path + 1] = at(dy, dx + tick)
        path[#path + 1] = p
        fan_l[#fan_l + 1] = at(dy, dx - w)
        fan_r[#fan_r + 1] = at(dy, dx + w)
    end
    return path, fan_l, fan_r
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
        not Rat_AngularActive(weapon, action, attacker) then
        return false
    end

    local aim = crosshair.aim or 0
    local part = crosshair.targetPart and crosshair.targetPart.id
    local step_pos = c.override_pos or attacker:GetPos()

    ---- UM cone so, o mesmo que Rat_SimPlanShots dispara: quem o resolve e CalcChanceToHit
    ---- (geometria + residuais ja em cone) e ele o devolve nos proprios args.
    local target_pos = target:GetPos()
    local sigma, theta, cth = Rat_AttackCone(attacker, target, action, part, aim, false, step_pos,
                                             target_pos)
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

    if not a.CrosshairRecoilLadder then
        Rat_ShowConeRing(center, radius, dir, color)
        return true
    end

    ---- MESMA funcao que a bala le (Rat_SimPlanShots semeia o passo com ela), e com a mesma mira:
    ---- se o anel e o tiro discordarem aqui, o anel deixa de valer alguma coisa.
    ---- centiminutos para semear o passo, minutos para desenhar: converter uma vez so aqui evita
    ---- que o anel e a escada partam de pontos com arredondamentos diferentes.
    local c0x, c0y = Rat_RecoilPersistOffset(attacker, action, weapon, aim, target)
    local p0x, p0y = MulDivRound(c0x, 1, 100), MulDivRound(c0y, 1, 100)
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

    ---- o anel vai para onde o cano ESTA: e de la que a bala sai, e um anel em cima do alvo
    ---- desenharia um cone que a arma nao tem apontada para ele.
    Rat_ShowConeRing(at(p0y, p0x), radius, dir, color)

    local est = (num_shots > 1) and
                    ladder_estimate(attacker, action, weapon, aim, num_shots, c0x, c0y)
    if not est then
        Rat_HideStroke("climb")
        Rat_HideStroke("fanl")
        Rat_HideStroke("fanr")
        return true
    end

    local faded = tint(cr, cg, cb)
    local path, fan_l, fan_r = ladder_strokes(est, num_shots, at,
                                              MulDivRound(spread, a.CrosshairRecoilTickPct or 0, 100))
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

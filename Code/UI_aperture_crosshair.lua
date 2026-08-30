---------------------------------------------------------------------------------------------------
---- CROSSHAIR: o circulo de mira passa a mostrar a ABERTURA de verdade.
---- O vanilla (`idAimTarget`) so encolhe uma imagem 2D com o nivel de mira e a logica ficou pela
---- metade (ActionCameraCrosshair.lua:224-265). Aqui ele da lugar a um anel NO MUNDO, no plano do
---- alvo e perpendicular a linha de tiro -- o mesmo circulo do DEBUG_aperture_draw. Ver UI_aperture_ring.
---- Com A.Enabled = false a funcao original volta a ser chamada, sem alteracao.
---------------------------------------------------------------------------------------------------

local vanilla_update --- OnContextUpdate original do template, para o fallback
local debug = Platform.developer and Platform.rat

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

    local cth, sigma, theta, _, _, dist = Rat_AngularCTH(attacker, target, part, action, weapon,
                                                         aim, false, step_pos, target:GetPos(), nil)

    if not sigma or not theta or theta < 1 or not dist then
        return false
    end

    ---- mesmo cone que Rat_SimPlanShots dispara: geometria corrigida pelo que entrou por mod_add
    ---- em CalcChanceToHit (recoil permanente, Dazed). Ver Rat_EffectiveSigma.
    local results = c.attackResultTable
    results = results and part and results[part]
    local cth_final = results and results.chance_to_hit
    if cth_final then
        sigma = Rat_EffectiveSigma(theta, sigma, cth_final)
        cth = cth_final
    end

    ---- raio que contem ~96% dos tiros (2.5 sigma), nao 1 sigma cru -- ver A.CrosshairSigmaMul.
    local spread = MulDivRound(sigma, a.CrosshairSigmaMul, 100)

    ---- mesma escala de cor da linha Aperture no overlay (Rat_QualityColor): o anel e o texto
    ---- respondem ao mesmo numero, entao a cor quer dizer a mesma coisa nos dois.
    local color = RGB(Rat_QualityColor(cth))

    ---- ancora no spot da parte mirada; plano perpendicular a linha de tiro. `dist` continua
    ---- vindo do CTH (medido ate o pe do alvo): a diferenca de altura nao move o raio 1 cm.
    local center = Rat_RingAnchor(target, part)
    if not center then
        return false
    end

    Rat_ShowConeRing(center, Rat_ConeRadius(dist, spread), center - Rat_RingValidZ(step_pos), color)
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
        local cth, sigma, theta, _, _, dist = Rat_AngularCTH(attacker, target, nil, action, weapon,
                                                             aim, false, attacker:GetPos(),
                                                             target:GetPos(), nil)
        local spread = MulDivRound(sigma, a.CrosshairSigmaMul, 100)
        out[#out + 1] = string.format(" %d  | %5d %6d %6d | %7d | %3d%% | %s", aim, sigma, spread,
                                      theta, Rat_ConeRadius(dist, spread) / 10, cth,
                                      (theta >= 1 and spread <= theta) and "cabe" or "transborda")
    end

    a.Enabled = was
    return table.concat(out, "\n")
end

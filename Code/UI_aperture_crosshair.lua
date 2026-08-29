---------------------------------------------------------------------------------------------------
---- CROSSHAIR: o circulo de mira passa a mostrar a ABERTURA de verdade
----
---- O vanilla ja tem o circulo (`idAimTarget`, imagem UI/Hud/target_aim) sobreposto
---- ao fundo do alvo, e ele visivelmente foi feito para representar dispersao -- mas
---- a logica ficou pela metade (ActionCameraCrosshair.lua:224-265):
----
----     local aimScale = aimMaxScale - aim * perLevel    -- 560 .. 200, linear
----
---- Ou seja, encolhe so com o NIVEL DE MIRA. Ignora distancia, arma, pericia do
---- atirador e cobertura -- e as chamadas de SetVisible ao redor estao comentadas,
---- o que confirma que o recurso foi abandonado no meio.
----
---- Com o modelo angular esse circulo tem finalmente o que mostrar: a razao entre o
---- cone da arma (sigma) e a silhueta do alvo (theta), que e exatamente a grandeza
---- de que o CTH sai. O circulo grande demais para o alvo E o motivo de errar.
----
----     escala = RefScale * sigma / theta
----
---- RefScale e a escala em que o circulo cobre a silhueta (sigma == theta). Abaixo
---- dela o cone cabe no alvo; acima, transborda. Mirar, agachar, aproximar-se ou
---- flanquear encolhem o circulo pelo mesmo motivo que sobem o CTH.
----
---- Com const.Combat.Aperture.Enabled = false o comportamento vanilla e restaurado
---- byte a byte: a funcao original fica guardada e volta a ser chamada.
---------------------------------------------------------------------------------------------------

local vanilla_update --- OnContextUpdate original do template, para o fallback

---- Acha o no do template que controla o circulo: aquele cujo filho direto tem
---- Id "idAimTarget". Procurar pela estrutura em vez de decorar o caminho
---- ([1][1][1][2][2] hoje) evita quebrar se a Haemimont mexer no layout.
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

function Rat_PatchCrosshairAimCircle()
    local tpl = XTemplates and XTemplates.ActionCameraCrosshair
    if not tpl then
        return false, "XTemplates.ActionCameraCrosshair nao encontrado"
    end

    local node = find_aim_circle_node(tpl)
    if not node then
        return false, "no do idAimTarget nao encontrado no template"
    end
    if node.rat_aperture_patched then
        return true, "ja aplicado"
    end

    vanilla_update = node.OnContextUpdate
    node.rat_aperture_patched = true

    node.OnContextUpdate = function(self, context, ...)
        local a = const.Combat.Aperture
        local crosshair = self:ResolveId("node")

        ---- desligado, ou sem o que medir: comportamento vanilla intacto
        if not (a and a.Enabled) or not crosshair or not crosshair.context then
            return vanilla_update(self, context, ...)
        end

        local c = crosshair.context
        local attacker = c.attacker
        local target = c.target
        local action = crosshair.show_data_for_action or c.action
        local weapon = attacker and action and action:GetAttackWeapons(attacker)

        if not IsValid(attacker) or not IsValid(target) or not action or
            not Rat_AngularActive(weapon, action, attacker) then
            return vanilla_update(self, context, ...)
        end

        local aim = crosshair.aim or 0
        local part = crosshair.targetPart and crosshair.targetPart.id
        local step_pos = c.override_pos or attacker:GetPos()

        local cth, sigma, theta = Rat_AngularCTH(attacker, target, part, action, weapon, aim, false,
                                                 step_pos, target:GetPos(), nil)

        if not sigma or not theta or theta < 1 then
            return vanilla_update(self, context, ...)
        end

        ---- o circulo E a razao cone/silhueta
        local scale = Clamp(MulDivRound(a.CrosshairRefScale, sigma, theta), a.CrosshairMinScale,
                            a.CrosshairMaxScale)

        ---- cor: amarelo quando este e o nivel de mira mais barato possivel,
        ---- como no vanilla; vermelho caso contrario
        local nextAimLevel = crosshair.GetNextAimLevel and crosshair:GetNextAimLevel()
        if nextAimLevel == (crosshair.minAimPossible or 0) then
            self.idAimTarget:SetImageColor(RGB(237, 184, 24))
        else
            self.idAimTarget:SetImageColor(RGB(191, 67, 77))
        end

        ---- anel mais "fechado" quando o cone ja cabe no alvo
        if scale <= a.CrosshairRefScale then
            self.idAimTarget:SetImage("UI/Hud/target_aim_small")
        elseif sigma > theta * 2 then
            self.idAimTarget:SetImage("UI/Hud/T_HUD_TargetingCircle_Inner")
        else
            self.idAimTarget:SetImage("UI/Hud/T_HUD_TargetingCircle_Inner_2")
        end

        self.idAimTarget:SetScaleModifier(point(scale, scale))
    end

    return true, "aplicado"
end

---------------------------------------------------------------------------------------------------
---- Diagnostico: que escala o circulo teria, por nivel de mira
---------------------------------------------------------------------------------------------------

function Rat_ShowCrosshairScale(target, attacker)
    attacker = attacker or SelectedObj
    if not attacker then
        return "sem atacante"
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
        string.format("%s (%s) -> %s a %.1f tiles  [ref=%d: circulo cobre a silhueta]",
                      tostring(attacker.session_id), tostring(weapon.class),
                      tostring(target.session_id),
                      attacker:GetDist(target) / const.SlabSizeX, a.CrosshairRefScale),
        "aim | cone(') alvo(') |  escala | CTH"
    }
    for aim = 0, 4 do
        local cth, sigma, theta = Rat_AngularCTH(attacker, target, nil, action, weapon, aim, false,
                                                 attacker:GetPos(), target:GetPos(), nil)
        local scale = theta >= 1 and
                          Clamp(MulDivRound(a.CrosshairRefScale, sigma, theta), a.CrosshairMinScale,
                                a.CrosshairMaxScale) or -1
        out[#out + 1] = string.format(" %d  | %6d %6d | %6d  | %3d%%", aim, sigma, theta, scale, cth)
    end

    a.Enabled = was
    return table.concat(out, "\n")
end

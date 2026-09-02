---------------------------------------------------------------------------------------------------
---- Encaramento automatico FORA do proprio turno.
----
---- Copia de Unit:SetTargetDummyFromPos (Unit.lua:5787) com UMA mudanca: o `auto_face` deixa de ser
---- `true` fixo e passa a respeitar `self.auto_face` quando a unidade nao e do time que esta jogando.
----
---- O original passa `true` cravado, o que ANULA a propriedade auto_face da propria unidade. Junto
---- com ResetIdleLookAt (Unit.lua:8055) -- que roda em VisibilityUpdate, CoversChanged,
---- UnitMovementDone, UnitDied e CombatObjectDied, para TODA unidade ciente em Idle -- o resultado e
---- que cada inimigo se re-orienta para o inimigo mais proximo (e re-roda FindProneAngle) sempre que
---- qualquer coisa se mexe no mapa.
----
---- Isso importa aqui mais do que no vanilla: neste mod a silhueta exposta e geometria de verdade,
---- entao girar a unidade muda theta, muda o CTH e muda que parte do corpo a bala encontra. Medir
---- duas vezes a mesma situacao dava numeros diferentes -- ruido que nao vem de dado nenhum.
---- Deitado e o pior caso: de frente a silhueta e curta, de lado e comprida.
----
---- const.Combat.FreezeIdleFacing = false devolve o comportamento do engine.
---------------------------------------------------------------------------------------------------

function Unit:SetTargetDummyFromPos(pos, angle, can_reposition)
    pos = pos or GetPassSlab(self) or self:GetPos()
    if not pos:IsValid() or self:IsDead() then
        return self:SetTargetDummy(false)
    end

    ---- `false` explicito, nao nil: nil cairia em self.auto_face, que e `true` por padrao em toda
    ---- unidade (Unit.lua:343) -- delegar ali nao congelaria nada.
    local auto_face = true
    if const.Combat.FreezeIdleFacing and g_Combat and g_Teams and
        self.team ~= g_Teams[g_CurrentTeam] then
        auto_face = false
    end

    local orientation_angle = self:GetPosOrientation(pos, angle, self.stance, auto_face,
                                                     can_reposition)
    local anim_style = GetAnimationStyle(self, self.cur_idle_style)
    local base_idle = anim_style and anim_style:GetMainAnim() or self:GetIdleBaseAnim()
    return self:SetTargetDummy(pos, orientation_angle, base_idle, 0)
end

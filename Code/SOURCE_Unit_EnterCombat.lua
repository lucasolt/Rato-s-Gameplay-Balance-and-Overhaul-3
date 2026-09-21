------Unit.lua
function Unit:EnterCombat()
    local wasInterruptable = self.interruptable
    if wasInterruptable then
        self:EndInterruptableMovement()
    end

    -------------
    if not self:HasStatusEffect("ManningEmplacement") and not self:HasStatusEffect("shooting_stance") then
        self:UninterruptableGoto(self:GetVisualPos())
        self:SetTargetDummyFromPos()
    end
    --------------------- 

    --[[if not self:HasStatusEffect("ManningEmplacement") and not self:HasStatusEffect("shooting_stance") then
    self:UninterruptableGoto(self:GetVisualPos())
    self:SetTargetDummyFromPos()
  end]]

    -- self:SetTargetDummyFromPos()
    self:UpdateAttachedWeapons()
    if HasPerk(self, "SharpInstincts") then
        if self.stance == "Standing" then
            self:DoChangeStance("Crouch")
        end
        self:ApplyTempHitPoints(CharacterEffectDefs.SharpInstincts:ResolveValue("tempHP"))
    end
    if self:HasStatusEffect("ManningEmplacement") and self == SelectedObj then
        self:FlushCombatCache()
        self:RecalcUIActions(true)
        ObjModified("combat_bar")
    end
    Msg("UnitEnterCombat", self)
    self.entered_combat = true
    if wasInterruptable then
        self:BeginInterruptableMovement()
    end
end

---------ok

---- Vanilla bug: Unit:HyenaCharge passes the unpaid move_ap budget (100 AP) as CombatGoto's cost_ap,
---- and CombatGoto refunds budget minus path cost, so the hyena ends the charge with ~80 extra AP.
local CombatGoto_orig = Unit.CombatGoto

function Unit:CombatGoto(action_id, ...)
    if action_id ~= "HyenaCharge" then
        return CombatGoto_orig(self, action_id, ...)
    end
    local ap = self.ActionPoints
    CombatGoto_orig(self, action_id, ...)
    if self.ActionPoints > ap then
        self.ActionPoints = ap
        Msg("UnitAPChanged", self)
        ObjModified(self)
    end
end

local original_unit_can_attack = Unit.CanAttack

function Unit:CanAttack(target, weapon, action, aim, goto_pos, skip_ap_check, is_free_aim)
    if action and action.id == "Sprint" then
        return true
    end
    ---- also gates the target lists: CombatActionGetAttackableEnemies asks CanAttack per enemy
    if target and Rat_MGConeBound(action, self) and
        not CombatActionTargetFilters.MGBurstFire(target, {self}) then
        return false, AttackDisableReasons.OutOfRange
    end
    ---- vanilla prices the default length; a player can still pick the shortest string (AI keeps its length)
    if not skip_ap_check and (g_Combat or g_StartingCombat) and Rat_IsVariableAuto(action) and
        not action.rat_num_shots and not R_IsAI(self) then
        local ok, err = original_unit_can_attack(self, target, weapon, action, aim, goto_pos, true,
                                                 is_free_aim)
        if not ok then
            return ok, err
        end
        local args = {target = target, goto_pos = goto_pos, aim = aim, num_shots = const.Combat.Autofire.MinShots}
        if not self:HasAP(action:GetAPCost(self, args), action.id, args) then
            return false, GetUnitNoApReason(self)
        end
        return ok, err
    end
    return original_unit_can_attack(self, target, weapon, action, aim, goto_pos, skip_ap_check,
                                    is_free_aim)
end

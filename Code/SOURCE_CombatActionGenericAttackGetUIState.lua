local GBO_OriginalFirearmGetBaseAttack = Firearm.GetBaseAttack

-- DoubleBarrel stays visible with slugs and precedes SingleShot in AvailableAttacks.
function Firearm:GetBaseAttack(unit, force)
    ---- the first attack is the default, OW and AI attack; autofire takes the slot of a hidden
    ---- BurstFire (no limiter) or SingleShot (auto only)
    local list = self.AvailableAttacks
    local first = list and list[1]
    if (first == "BurstFire" and not Rat_HasSelectiveBurst(self)) or
        (first == "SingleShot" and self.auto_only) then
        local auto_id = Rat_AutoAttackId(self)
        if force then
            return auto_id
        end
        local auto = CombatActions[auto_id]
        local target = auto.RequireTargets and auto:GetDefaultTarget(unit)
        if auto:GetVisibility({unit}, target) ~= "hidden" then
            return auto_id
        end
    end
    local id = GBO_OriginalFirearmGetBaseAttack(self, unit, force)
    if force or not IsSlugLoaded(self) then
        return id
    end
    local action = CombatActions[id]
    if not action or action.FiringModeMember ~= "AttackShotgun" then
        return id
    end
    local units = {unit}
    for _, alt_id in ipairs(self.AvailableAttacks) do
        local alt = CombatActions[alt_id]
        if alt and alt.FiringModeMember == "Attack" then
            local target = alt.RequireTargets and alt:GetDefaultTarget(unit)
            if alt:GetVisibility(units, target) ~= "hidden" then
                return alt_id
            end
        end
    end
    return id
end
-- local _is_attack_available_units = {}
-- local GBO_OriginalUnitGetDefaultAttackAction = Unit.GetDefaultAttackAction
-- function Unit:GetDefaultAttackAction(force_ranged, force_ungrouped, weapon, sync, ignore_stealth,
--                                      args, ui)
--     -- _is_attack_available_units[1] = self
--     local action = GBO_OriginalUnitGetDefaultAttackAction(self, force_ranged, force_ungrouped,
--                                                           weapon, sync, ignore_stealth, args, ui)
--     local isSlugLoaded = weapon and IsSlugLoaded(weapon)
--     -- if action and isSlugLoaded then
--     --     if action.id == "BuckshotBurst" then
--     --         return CombatActions["BurstFire"]
--     --     end
--     --     return CombatActions["SingleShot"]
--     -- end
--     ic(action.id)
--     return action
-- end
local GBO_Original_CombatActionGenericAttackGetUIState = CombatActionGenericAttackGetUIState

local shotgun_attacks = {"Buckshot", "BuckshotBurst", "CancelShotCone"}
local slug_attacks = {"SingleShot", "BurstFire", "CancelShot"}

function CombatActionGenericAttackGetUIState(self, units, args)
    local unit = units and units[1]
    local weapon = self:GetAttackWeapons(unit, args) or unit and unit:GetActiveWeapons()
    if weapon and IsKindOf(weapon, "Shotgun") then
        local isSlugLoaded = IsSlugLoaded(weapon)
        if table.find(shotgun_attacks, (self and self.id) or "") and isSlugLoaded then
            return "hidden"
        end

        if table.find(slug_attacks, (self and self.id) or "") and not isSlugLoaded then
            return "hidden"
        end
    end

    return GBO_Original_CombatActionGenericAttackGetUIState(self, units, args)
end

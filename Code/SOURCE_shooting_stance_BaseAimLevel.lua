-----Unit.lua
-- local original_UnitGetBaseAimLevelRange = Unit.GetBaseAimLevelRange
function Unit:GetBaseAimLevelRange(action, target)
    local min, max = ratG_original_UnitGetBaseAimLevelRange(self, action, target)
    if action and action.IsAimableAttack then
        local actionWep = action:GetAttackWeapons(self)
        if IsKindOf(actionWep, "Firearm") then
            local singleMaxActions = {
				["DualShot"] = true,
				["AutoFire"]= true,
				["GrizzlyPerk"]= true
			}

			if const.Combat.Aperture.SimulateShots then
				singleMaxActions["AutoFire"] = nil
				--singleMaxActions["GrizzlyPerk"] = nil
			end
            if singleMaxActions[action.id] then
                max = 1
            end

            if self.Mobile_aimed then
                min = 1
            end

            min = Min(max, min)
            max = Max(min, max)
        end
    end
    return min, max
end


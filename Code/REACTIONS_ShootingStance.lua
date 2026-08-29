function OnMsg.TurnEnded()
    for _, unit in ipairs(g_Units) do
        DestroyStanceConeV(unit)
    end
end

function OnMsg.CombatActionStart(unit)
    DestroyStanceConeV(unit)
end

function OnMsg.UnitStanceChanged(unit)
    if not R_IsAI(unit) and unit.stance == 'Prone' then
        unit:RemoveStatusEffect("shooting_stance")
    end
end

function OnMsg.SelectedObjChange()
    local selected = SelectedObj
    local overwatch = g_Overwatch[selected]

    for _, unit in ipairs(g_Units) do
        if unit:HasStatusEffect("shooting_stance") then
            if unit == selected then
                if unit.shooter_cone_v then
                    unit.shooter_cone_v:SetOpacity(100)
                    unit.snap_cone:SetOpacity(100)
                else
                    local weapon = unit:GetActiveWeapons()
                    if not (overwatch and overwatch.permanent) then
                        CreateStanceConeV(unit, weapon)
                    end
                end
            else
                DestroyStanceConeV(unit)
            end
        end
    end
end

function OnMsg.UnitAnyMovementStart(unit)
    local actions_that_remove = {
        Move = true,
        -- RunAndGun = true,
        -- RecklessAssault = true,
        -- MobileShot = true,
        -- HundredKnives = true,
        Sprint = true,
        InteractWith = true,
        CombatGoto = true
    }

    if actions_that_remove[unit.action_command] then
        unit:RemoveStatusEffect("shooting_stance")
    end

end

function OnMsg.UnitAnyMovementStart(unit)
	print(unit.action_command)
	if unit.action_command == "CombatGoto" then
	    unit.reserved_return_pos = nil
    end
end

function OnMsg.UnitMovementDone(unit, action_id, prev_pos)
    local actions_that_remove = {
        Move = true,
        RunAndGun = true,
        RecklessAssault = true,
        MobileShot = true,
        HundredKnives = true,
        Sprint = true
    }
    if actions_that_remove[action_id] then
        unit:RemoveStatusEffect("shooting_stance")
    end
end

function OnMsg.CombatActionEnd(unit)

    local actions_to_remove_stance = {
        "TakeCover", "LeaveEmplacement", "MGPack", "ThrowGrenade", "InteractWith", "ThrowKnife",
        "ReloadAction", "DoubleToss", "Sprint"
    }

    if g_Overwatch[unit] and g_Overwatch[unit].permanent then
        return
    end

    if table.find(actions_to_remove_stance, unit.action_command) then
        unit:RemoveStatusEffect("shooting_stance")
    end

    local weapon = unit:GetActiveWeapons()
    if weapon and IsKindOf(weapon, "BrowningM2HMG") then
        unit:AddStatusEffect("shooting_stance")
        return
    end
end

function OnMsg.OnAttack(unit, action, target, results, attack_args)

    local weapon = attack_args.weapon or unit:GetActiveWeapons()
    if not weapon or not IsKindOf(weapon, "Firearm") or not action or g_Overwatch[unit] then
        return
    end

    local aim = attack_args.aim or 0
    if aim and aim > 0 or HasPerk(unit, "shooting_stance") then
        unit:EnterShootingStance(target, attack_args)
        -- unit:SetActionCommand("ShootingStanceCommand", action.id, nil, attack_args)
    end
end

function OnMsg.CombatActionEnd(unit)

    if g_Pindown[unit] and unit.shooter_cone_v then
        DestroyStanceConeV(unit)
    end

    if g_Overwatch[unit] then
        local overwatch = g_Overwatch[unit]

        DestroyStanceConeV(unit)

        if overwatch.permanent then
            unit:AddStatusEffect("shooting_stance")
            return
        end

        local angle = g_Overwatch[unit].angle
        unit:SetOrientationAngle(angle)

        local target = g_Overwatch[unit].target_pos

        local attack_args = {target = target}
        unit:EnterShootingStance(target, attack_args)

        if not overwatch.permanent then
            if overwatch and (overwatch.num_attacks < 1) then
                unit:InterruptPreparedAttack()
            end
        end
    end
end

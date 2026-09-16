-- Mobile attacks that end braced; keyed by action_command, so MobileShot arrives as RunAndGun.
local mobile_attacks_end_in_stance = {
    RunAndGun = true,
    RecklessAssault = true,
    HundredKnives = true
}

function OnMsg.TurnEnded()
    for _, unit in ipairs(g_Units) do
        DestroyStanceConeV(unit)
    end
end

function OnMsg.CombatActionStart(unit)
    DestroyStanceConeV(unit)
    unit.aim_pos_stance = false
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

    if actions_that_remove[unit.action_command] and unit:HasStatusEffect("shooting_stance") then
        -- Clear before removal, else StatusEffectRemoved restores return_pos and CombatGoto steps back in.
        unit.return_pos_reserved = false
        unit.return_pos = false
        unit:RemoveStatusEffect("shooting_stance")
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

    -- Movement is over by now, so the stance sticks; UnitMovementDone already removed the carried one.
    local aim_pos = unit.aim_pos_stance
    unit.aim_pos_stance = false
    if mobile_attacks_end_in_stance[unit.action_command] and aim_pos and not unit:IsDead() then
        if aim_pos:Dist2D(unit:GetPos()) > const.SlabSizeX / 2 then
            unit:SetOrientationAngle(CalcOrientation(unit:GetPos(), aim_pos), 300)
        end
        unit:EnterShootingStance(aim_pos)
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

    -- Mobile attack: entering now steals the return_pos the ability needs, so only remember the target.
    if attack_args.dont_restore_aim then
        local aim_pos = IsValid(target) and target:GetPos() or IsPoint(target) and target
        unit.aim_pos_stance = aim_pos or unit.aim_pos_stance
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

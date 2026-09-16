local smooth_tf_change_duration = 1500
function Unit:Sprint(action_id, cost_ap, args)
    local action = CombatActions[action_id]
    local target = args.goto_pos
    local weapon = action:GetAttackWeapons(self)

    --[[if not weapon then
        self:GainAP(cost_ap)
        CombatActionInterruped(self)
        return
    end]]
    local aim_params = action:GetAimParams(self, weapon)
    local num_shots = aim_params.num_shots

    if self.stance ~= "Standing" then
        self:ChangeStance(action_id, 0, "Standing")
    end
    ---------
    self:AddStatusEffect("Sprinting")
    ---------
    args.prediction = false
    NetUpdateHash("RunAndGun_0", self, args)
    -- local results = action:GetActionResults(self, args)
    local action_camera = false --[[ disable action camera for now ]]
    --[[if #(results.attacks or empty_table) == 0 then
        self:GainAP(cost_ap)
        CombatActionInterruped(self)
        return
    end]]

    local pathObj, path
    self:PushDestructor(function(self)
        if pathObj then
            DoneObject(pathObj)
        end
    end)
    pathObj = CombatPath:new()

    if action_camera then
        local tf = GetTimeFactor()
        self:PushDestructor(function()
            SetTimeFactorSmooth(tf, smooth_tf_change_duration)
        end)
    end
    local base_idle = self:GetIdleBaseAnim()
    local shot_threads

    --[[local cooldown = action:ResolveValue("cooldown")
    if cooldown then
        self:SetEffectExpirationTurn(action.id, "cooldown",
                                     g_Combat.current_turn + cooldown)
    end]]
    if action_camera then
        RemoveActionCamera()
        self:PopAndCallDestructor() -- camera
    end

    -- if not at target loc, goto there (there mustn't be a target when that happens)	
    local occupiedPos = self:GetOccupiedPos()
    if self.return_pos and self.return_pos:Dist(target) < const.SlabSizeX / 2 then
        self:ReturnToCover()
    elseif self:GetDist(occupiedPos) > const.SlabSizeX / 2 and self:GetDist(target) <
        const.SlabSizeX / 2 then
        self:SetTargetDummyFromPos()
    else
        pathObj:RebuildPaths(self, aim_params.move_ap)
        path = pathObj:GetCombatPathFromPos(target)
        self:CombatGoto(action_id, 0, nil, path, true)
    end
    if shot_threads then
        Firearm:WaitFiredShots(shot_threads)
    end
    self:PopAndCallDestructor() -- pathObj 
end

DefineClass.IModeCombatSprint = {__parents = {"IModeCombatMovingAttack"}, target_as_pos = true}

function IModeCombatSprint:Confirm()
    local blackboard = self.targeting_blackboard
    if not blackboard then
        return
    end

    if self.potential_target and self.potential_target:CanBeControlled() then
        SelectObj(self.potential_target)
        return
    end

    if not self.target_path then
        if not self.target_pos then
            ReportAttackError(GetCursorPos(), AttackDisableReasons.Impassable)
        elseif IsOccupied(self.target_pos) then
            ReportAttackError(GetCursorPos(), AttackDisableReasons.Occupied)
        else
            ReportAttackError(GetCursorPos(), AttackDisableReasons.OutOfRange)
        end
        return
    end

    return IModeCombatAttackBase.Confirm(self)
end

function OnMsg.ClassesBuilt()
    PlaceObj('XTemplate', {
        group = "Zulu",
        id = "IModeCombatSprint",
        PlaceObj('XTemplateWindow', {'__class', "IModeCombatSprint"},
                 {PlaceObj('XTemplateTemplate', {'__template', "IModeCombatAttackBaseGeneric"})})
    })
end

local mobile_targeting_special_args = {
    no_ap_indicator = true,
    show_unreachable_indicator = true,
    show_stance_arrows = false,
    hide_avatar = true
}

function Sprint_Targeting_Mobile(dialog, blackboard, command, pt)

    local attacker = dialog.attacker
    local action = dialog.action

    if dialog:PlayerActionPending(attacker) then
        command = "delete"
    end

    if command == "setup" then
        dialog.args_gotopos = true
        dialog.disable_mouse_indicator = true
        local weapon = action:GetAttackWeapons(attacker)
        local aim_params = action:GetAimParams(attacker, weapon)
        if aim_params.move_ap then
            blackboard.combat_path = CombatPath:new()
            blackboard.combat_path:RebuildPaths(attacker, aim_params.move_ap, nil, "Standing", nil,
                                                nil, action.id)
            blackboard.custom_combat_path = true
        end
    end

    Targeting_Movement(dialog, blackboard, command, pt, mobile_targeting_special_args)

    local clickWillSelect = dialog.potential_target and dialog.potential_target:CanBeControlled()
    if clickWillSelect then
        SetAPIndicator(false, "unreachable")
    end

    if command == "delete" then

        if blackboard.fx_target then
            PlayFX(blackboard.fx_target_action, "end", blackboard.fx_target)
            blackboard.fx_target = false
        end
        if blackboard.combat_path then
            DoneObject(blackboard.combat_path)
            blackboard.combat_path = nil
        end
        for i, fx in ipairs(blackboard.fx_shot_lines) do
            DoneObject(fx)
        end
        blackboard.fx_shot_lines = false
        dialog.args_gotopos = false
        SetAPIndicator(false, "moving-attack")

        if IsValid(blackboard.melee_range_indicator) then
            DoneObject(blackboard.melee_range_indicator)
            blackboard.melee_range_indicator = false
        end

        for _, unit in ipairs(blackboard.melee_threats) do
            if IsValid(blackboard.melee_threats[unit]) then
                DoneObject(blackboard.melee_threats[unit])
            end
        end
        for _, unit in ipairs(g_Units) do
            unit:SetHighlightReason("melee", nil)
        end
        blackboard.melee_threats = nil
        return
    end

    local goto_pos = dialog.target_pos
    if goto_pos == blackboard.last_goto and not blackboard.stanceChanged then
        return
    end
    blackboard.last_goto = goto_pos

    -- Prevent updates while the camera is moving between targets.
    -- This allows the gamepad to cycle between targets.
    if GetUIStyleGamepad() then
        local timeSinceLastSetTarget = dialog.last_set_target_time or 0
        if RealTime() - timeSinceLastSetTarget < SnapCameraToObjInterpolationTimeDefault then
            return
        end
    end

    local shot_positions, shot_targets, shot_cth, valid_shots = {}, {}, {}, 0
    local results = dialog.action:GetActionResults(dialog.attacker,
                                                   {goto_pos = goto_pos, prediction = true})

    local movement_mode = IsKindOf(dialog, "IModeCombatMovement")

    UpdateMovementAvatar(dialog, point20, movement_mode and blackboard.fxToDoStance or "Standing",
                         "update_pos")
    SetAPIndicator(APIndicatorNoTarget, results.shot_canceling_reason or "unreachable")

    dialog.movement_mode = true
    dialog:UpdateTargetCovers("force")

    for i, fx in ipairs(blackboard.fx_shot_lines) do
        DoneObject(fx)
    end

    local fx_shot_lines = {}
    blackboard.fx_shot_lines = fx_shot_lines

    local apCost = action:GetAPCost(attacker, {goto_pos = goto_pos})

    local extraAP = false
    if blackboard.fxToDoStance and blackboard.fxToDoStance ~= attacker.stance then
        extraAP = CombatActions["Stance" .. blackboard.fxToDoStance]:GetAPCost(attacker)
        apCost = apCost + extraAP
    end

    SetAPIndicator(apCost, "moving-attack")

    ObjModified(APIndicator)
    -- Manually notify because the cost could be the same

    if GetUIStyleGamepad() and dialog.potential_target then
        dialog:SetTarget(dialog.potential_target, true)
        return
    end

    -- If more than one shot (or zero shots), it isn't clear which one we're inspecting.
    if valid_shots ~= 1 then
        dialog:SetTarget(false, true)
    end

    Sleep(50)
end

local original_Targeting_Mobile = Targeting_Mobile

function Targeting_Mobile(dialog, blackboard, command, pt)

    if dialog and dialog.class == "IModeCombatSprint" then
        Sprint_Targeting_Mobile(dialog, blackboard, command, pt)
    else
        original_Targeting_Mobile(dialog, blackboard, command, pt)
    end
end

---------------------------------------------------------------------------------------------------
---- Copy of Unit:RunAndGun (UnitActions.lua:629) with ONE change, in the tail that decides where
---- the merc finishes. Vanilla tucks him back into cover; since OnMsg.CombatActionEnd then braces
---- him, the stance would be anchored on the cover tile with the line to the target running through
---- the cover object. He now stays on the step-out tile, with the cover tile kept as the peek
---- anchor for CTH. Lives next to Unit:Sprint, the same vanilla function trimmed of its attacks.
---------------------------------------------------------------------------------------------------

function Unit:RunAndGun(action_id, cost_ap, args)
    local action = CombatActions[action_id]
    local target = args.goto_pos
    local weapon = action:GetAttackWeapons(self)
    if not weapon then
        self:GainAP(cost_ap)
        CombatActionInterruped(self)
        return
    end
    local aim_params = action:GetAimParams(self, weapon)
    local num_shots = aim_params.num_shots

    if self.stance ~= "Standing" then
        self:ChangeStance(action_id, 0, "Standing")
    end

    -- do the attack/crit rolls
    args.attack_rolls = {}
    args.crit_rolls = {}
    args.stealth_kill_rolls = {}
    for i = 1, num_shots do
        args.attack_rolls[i] = 1 + self:Random(100)
        args.crit_rolls[i] = 1 + self:Random(100)
        if action.StealthAttack then
            args.stealth_kill_rolls[i] = 1 + self:Random(100)
        end
    end
    args.prediction = false
    NetUpdateHash("RunAndGun_0", self, args)
    local results = action:GetActionResults(self, args)
    local action_camera = false --[[ disable action camera for now ]]
    if #(results.attacks or empty_table) == 0 then
        self:GainAP(cost_ap)
        CombatActionInterruped(self)
        return
    end

    local pathObj, path
    self:PushDestructor(function(self)
        if pathObj then
            DoneObject(pathObj)
        end
    end)
    pathObj = CombatPath:new()

    if action_camera then
        local tf = GetTimeFactor()
        self:PushDestructor(function()
            SetTimeFactorSmooth(tf, smooth_tf_change_duration)
        end)
    end
    local base_idle = self:GetIdleBaseAnim()
    local shot_threads
    for i, attack in ipairs(results.attacks) do
        if not self:CanUseWeapon(weapon) then -- might jam, run out of ammo, etc
            goto continue
        end
        NetUpdateHash("RunAndGun_1", self, attack.mobile_attack_pos, attack.mobile_attack_target)
        if attack.mobile_attack_pos and (not IsValidTarget(attack.mobile_attack_target) or attack.mobile_attack_target:IsIncapacitated()) then
            local enemies = table.ifilter(action:GetTargets({self}), function(idx, u) return IsValidTarget(u) and not u:IsIncapacitated() end)
            NetUpdateHash("RunAndGun_Branch_1", self, attack.mobile_attack_pos, #enemies)
            attack.mobile_attack_target = FindTargetFromPos(action_id, self, action, enemies, point(point_unpack(attack.mobile_attack_pos)), weapon)
        end
        if attack.mobile_attack_pos and IsValidTarget(attack.mobile_attack_target) then
            if action_camera and i == 1 then
                SetTimeFactorSmooth(tf/2, smooth_tf_change_duration)
            end

            -- We need to build the path outside of the function so that it
            -- doesn't refund us the ap cost difference.
            local targetPos = point(point_unpack(attack.mobile_attack_pos))
            local occupiedPos = self:GetOccupiedPos()
            if self:GetDist(occupiedPos) > const.SlabSizeX / 2 and self:GetDist(targetPos) < const.SlabSizeX / 2 then
                -- already at target position because of expose/aim
                self:SetTargetDummy(nil, nil, base_idle, 0)
            else
                pathObj:RebuildPaths(self, aim_params.move_ap)
                path = pathObj:GetCombatPathFromPos(targetPos)
                self:CombatGoto(action_id, 0, nil, path, true, i == #results.attacks and args.toDoStance)
            end

            -- recheck target, as they might have died while we were moving
            if not IsValidTarget(attack.mobile_attack_target) or attack.mobile_attack_target:IsIncapacitated() then
                local enemies = table.ifilter(action:GetTargets({self}), function(idx, u) return IsValidTarget(u) and not u:IsIncapacitated() end)
                NetUpdateHash("RunAndGun_Branch_1_1", self, attack.mobile_attack_pos, #enemies)
                attack.mobile_attack_target = FindTargetFromPos(action_id, self, action, enemies, point(point_unpack(attack.mobile_attack_pos)), weapon)
                if not IsValidTarget(attack.mobile_attack_target) then
                    goto continue
                end
            end

            if action_camera then
                if i == #results.attacks then
                    SetTimeFactorSmooth(tf, smooth_tf_change_duration)
                end
                SetActionCamera(self, attack.mobile_attack_target)
            end
            self:SetRandomAnim(base_idle)
            local atk_action = CombatActions[attack.mobile_attack_id] or action

            -- rerun simulation to account for changes happened in the meantime (broken covers, etc)
            local atk_args = {
                prediction = false,
                target = attack.mobile_attack_target,
                stance = "Standing",
                can_use_covers = i == #results.attacks,
                used_action_id = action_id, -- so that cth is calculated for the master/parent action instead of the actual attack action
            }

            NetUpdateHash("RunAndGun_2", self, atk_args.target, args.goto_pos)
            local atk_results, attack_args = atk_action:GetActionResults(self, atk_args)
            attack_args.origin_action_id = action_id
            attack_args.keep_ui_mode = true
            attack_args.unit_moved = true
            attack_args.dont_restore_aim = true
            if atk_action.id == "KnifeThrow" then
                self:ExecKnifeThrow(atk_action, cost_ap, attack_args, atk_results)
            else
                shot_threads = shot_threads or {}
                attack_args.external_wait_shots = shot_threads
                self:ExecFirearmAttacks(atk_action, cost_ap, attack_args, atk_results)
            end
        end
        ::continue::
    end

    local cooldown = action:ResolveValue("cooldown")
    if cooldown then
        self:SetEffectExpirationTurn(action.id, "cooldown", g_Combat.current_turn + cooldown)
    end
    if action_camera then
        RemoveActionCamera()
        self:PopAndCallDestructor() -- camera
    end

    -- if not at target loc, goto there (there mustn't be a target when that happens)
    local occupiedPos = self:GetOccupiedPos()
    if self.return_pos and self.aim_pos_stance then
        -- Ending braced: stay on the step-out tile, or the stance is entered facing the cover.
        self.return_pos_reserved = self.return_pos
        self.return_pos = false
        self:SetTargetDummyFromPos()
    elseif self.return_pos and self.return_pos:Dist(target) < const.SlabSizeX / 2 then
        self:ReturnToCover()
    elseif self:GetDist(occupiedPos) > const.SlabSizeX / 2 and self:GetDist(target) < const.SlabSizeX / 2 then
        self:SetTargetDummyFromPos()
    else
        pathObj:RebuildPaths(self, aim_params.move_ap)
        path = pathObj:GetCombatPathFromPos(target)
        self:CombatGoto(action_id, 0, nil, path, true)
    end
    if shot_threads then
        Firearm:WaitFiredShots(shot_threads)
    end
    self:PopAndCallDestructor() -- pathObj
end

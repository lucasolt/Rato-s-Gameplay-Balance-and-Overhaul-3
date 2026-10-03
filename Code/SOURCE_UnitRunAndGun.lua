---------------------------------------------------------------------------------------------------
---- Copy of Unit:RunAndGun (UnitActions.lua:629) with ONE change, in the tail that decides where
---- the merc finishes. Vanilla tucks him back into cover; since OnMsg.CombatActionEnd then braces
---- him, the stance would be anchored on the cover tile with the line to the target running through
---- the cover object. He now stays on the step-out tile, with the cover tile kept as the peek
---- anchor for CTH. Lives next to Unit:Sprint, the same vanilla function trimmed of its attacks.
---- Second change: target re-picks happen after the move, through Rat_MobileFreshTarget (Blind Run and Gun).
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
        ---- a fallen planned target is replaced after the move, from what the merc sees at the stop
        if attack.mobile_attack_pos then
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
                attack.mobile_attack_target = Rat_MobileFreshTarget(self, action_id, action, attack.mobile_attack_pos, weapon)
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

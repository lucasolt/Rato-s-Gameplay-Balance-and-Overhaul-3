------UnitActions.lua
function Unit:WaitAttack()
    self:UninterruptableGoto(self:GetVisualPos())
    self.rat_wait_arrived = true
    ---- vanilla returned here: the routine resumed walking before the shot, and EnterCombat snapped it back
    self:BeginInterruptableMovement()
    local deadline = GameTime() + 10000
    while self.waiting_attack and GameTime() < deadline do
        Sleep(50)
    end
    ---- the attack ends ~0.5 s before CombatStarting interrupts this command with EnterCombat
    deadline = GameTime() + 2000
    while not g_Combat and GameTime() < deadline do
        Sleep(50)
    end
end

function Unit:FirearmAttack(action_id, cost_ap, args, applied_status) -- SingleShot/DualShot
    if true then -- net debug code
        local effects = {}
        for i, effect in ipairs(self.StatusEffects) do
            effects[i] = effect.class
        end
        effects = table.concat(effects, ",")
        local target_effects = "-"
        if IsKindOf(args.target, "Unit") then
            target_effects = {}
            for i, effect in ipairs(args.target.StatusEffects) do
                target_effects[i] = effect.class
            end
            target_effects = table.concat(target_effects, ",")
        end

        NetUpdateHash("Unit:FirearmAttack", action_id, cost_ap, self, effects, args.target, target_effects)
    end -- end net debug code
    local target = args.target
    self:CallReactions("OnFirearmAttackStart", self, target, CombatActions[action_id], args)
    if IsKindOf(target, "Unit") then
        target:CallReactions("OnFirearmAttackStart", self, target, CombatActions[action_id], args)
    end
    while not args.opportunity_attack and IsKindOf(target, "Unit") and not target:IsIdleOrRunningBehavior() do
        WaitMsg("Idle", 50)
    end
    if args.replace_action then
        action_id = args.replace_action
    end

    if IsPoint(target) or IsValidTarget(target) then
        local action = CombatActions[action_id]

        if action.StealthAttack then
            args.stealth_kill_roll = 1 + self:Random(100)
        end
        args.prediction = false

        local units_waiting = {}

        self:PushDestructor(function()
            for _, unit in ipairs(units_waiting) do
                unit.waiting_attack = false
            end
        end)

        if not g_Combat and IsKindOf(target, "Unit") then
            units_waiting[1] = target
            PropagateAwareness(units_waiting)
            for _, unit in ipairs(units_waiting) do
                if unit:IsInterruptable() then
                    unit.waiting_attack = true
                    unit.rat_wait_arrived = false
                    unit:InterruptCommand("WaitAttack")
                end
            end
            ---- vanilla tested waiting_attack, already true above (IdleForcingDist needs it early), so it never waited
            repeat
                local waiting = false
                for _, unit in ipairs(units_waiting) do
                    waiting = waiting or (unit.command == "WaitAttack" and not unit.rat_wait_arrived)
                end
                if waiting then
                    Sleep(10)
                end
            until not waiting
        end

        local results, attack_args = action:GetActionResults(self, args)
        self:ExecFirearmAttacks(action, cost_ap, attack_args, results)
        self:PopAndCallDestructor()
    else
        self:GainAP(cost_ap)
        CombatActionInterruped(self)
    end
end

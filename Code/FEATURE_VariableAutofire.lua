---- Selectable-length autofire: AutoFire and MGBurstFire take args.num_shots (mouse wheel on the
---- crosshair), pay AP per extra round by weapon RPM, and low Composure can overrun the trigger.
---- BurstFire stays only on weapons with a burst limiter. Params: __AutofireParams.lua.

local function P()
    return const.Combat.Autofire
end

function Rat_IsVariableAuto(action)
    local id = action and action.id
    return id == "AutoFire" or id == "MGBurstFire"
end

---- no full auto means burst is the only automatic mode, so it stays
function Rat_HasSelectiveBurst(weapon)
    return weapon.burst_selective or weapon:HasComponent("Enable_BurstFire") or
               not weapon:CanAutofire()
end

---- attack that RunAndGun and the AI use for a short burst with this weapon
function Rat_ShortBurstAttackId(weapon)
    if weapon and IsKindOf(weapon, "Firearm") and not Rat_HasSelectiveBurst(weapon) then
        return "AutoFire"
    end
    return "BurstFire"
end

function Rat_ClampAutoShots(action, weapon, n)
    n = n or weapon:GetAutofireShots(action)
    local lo = P().MinShots
    local ammo = weapon.ammo and weapon.ammo.Amount or lo
    return Clamp(n, lo, Max(lo, ammo))
end

---- signed: BaseShots costs ShootAP, each round above or below moves it by the per-round cost
function Rat_AutoExtraAP(action, weapon, n)
    local p = P()
    n = Rat_ClampAutoShots(action, weapon, n)
    local per_round = MulDivRound(p.APPerRoundRef, p.RPMRef, Max(1, weapon.rpm or p.RPMRef))
    local extra = (n - p.BaseShots) * per_round
    return MulDivRound(extra, 1, const.Scale.AP) * const.Scale.AP
end

function Rat_AutoOverrunChance(unit)
    local p = P()
    local chance = Max(0, (p.OverrunComposureRef - rGetComposure(unit)) * p.OverrunChancePerPoint)
    for id, add in pairs(p.OverrunStatusChance) do
        if unit:HasStatusEffect(id) then
            chance = chance + add
        end
    end
    return Min(chance, p.OverrunChanceMax)
end

---- rolled only on the committed attack (prediction == false) so previews show the intended length
function Rat_AutoOverrun(unit, weapon, n)
    local chance = Rat_AutoOverrunChance(unit)
    if chance <= 0 or unit:Random(100) >= chance then
        return n
    end
    local p = P()
    local max_extra = Max(1, MulDivRound(weapon.rpm or p.RPMRef, p.OverrunRoundsPer1000RPM, 1000))
    local ammo = weapon.ammo and weapon.ammo.Amount or n
    local extra = Min(1 + unit:Random(max_extra), ammo - n)
    if extra <= 0 then
        return n
    end
    CombatLog("short", T {
        603418825527, "<name> overruns the trigger: <extra> extra rounds",
        name = unit:GetLogName(),
        extra = extra
    })
    return n + extra
end

local function variable_execute(self, units, args)
    local unit = units[1]
    local weapon = self:GetAttackWeapons(unit, args)
    args.num_shots = Rat_ClampAutoShots(self, weapon, args.num_shots)
    args.multishot = true
    local ap = self:GetAPCost(unit, args)
    NetStartCombatAction(self.id, unit, ap, args)
end

local function variable_ui_state(self, units, args)
    local state, err = CombatActionGenericAttackGetUIState(self, units, args)
    if state ~= "enabled" then
        return state, err
    end
    local weapon = self:GetAttackWeapons(units[1], args)
    if not weapon.ammo or weapon.ammo.Amount < P().MinShots then
        return "disabled", AttackDisableReasons.InsufficientAmmo
    end
    return "enabled"
end

local function variable_damage(self, unit, target, args)
    local weapon = args and args.weapon or self:GetAttackWeapons(unit, args)
    if not weapon then
        return 0
    end
    local base = unit and unit:GetBaseDamage(weapon) or weapon.Damage
    base = MulDivRound(base, Max(1, 100 + (self:ResolveValue("dmg_penalty") or 0)), 100)
    local damage = Rat_ClampAutoShots(self, weapon, args and args.num_shots) * base
    return damage, base, damage - base
end

---- after rat_combat_actions(): plain assignments, safe to re-run
function Rat_ApplyVariableAutofire()
    local auto = CombatActions.AutoFire
    local mg = CombatActions.MGBurstFire

    auto.Execute = variable_execute
    mg.Execute = variable_execute
    auto.GetActionDamage = variable_damage
    mg.GetActionDamage = variable_damage
    mg.GetUIState = variable_ui_state

    ---- one autofire per weapon: MGBurstFire keeps its identity, AutoFire yields to it
    auto.GetUIState = function(self, units, args)
        local weapon = self:GetAttackWeapons(units[1], args)
        if weapon and table.find(weapon.AvailableAttacks or empty_table, "MGBurstFire") then
            return "hidden"
        end
        return variable_ui_state(self, units, args)
    end

    auto.GetActionResults = function(self, unit, args)
        local args = table.copy(args)
        args.multishot = true
        args.weapon = self:GetAttackWeapons(unit, args)
        args.num_shots = Rat_ClampAutoShots(self, args.weapon, args.num_shots)
        if args.prediction == false then
            args.num_shots = Rat_AutoOverrun(unit, args.weapon, args.num_shots)
        end
        local suppress = args.num_shots >= P().SuppressMinShots
        if suppress then
            args.applied_status = "Suppressed"
        end
        args.damage_bonus = self:ResolveValue("dmg_penalty")
        local attack_args = unit:PrepareAttackArgs(self.id, args)
        local results = attack_args.weapon:GetAttackResults(self, attack_args)
        local target = attack_args.target
        ---- vanilla: a long burst that reaches the target suppresses it even on a miss
        if suppress and results.miss and not attack_args.stuck and IsKindOf(target, "Unit") and
            IsValidTarget(target) then
            local weapon = attack_args.weapon
            local target_dist = unit:GetDist(target)
            if target_dist <= weapon.WeaponRange * const.SlabSizeX then
                local flight_dist = 0
                for _, shot in ipairs(results.shots) do
                    for _, hit in ipairs(shot.hits) do
                        flight_dist = Max(flight_dist, shot.attack_pos:Dist(hit.pos))
                    end
                end
                if flight_dist / const.SlabSizeX >= target_dist / const.SlabSizeX - 1 then
                    results.extra_packets = results.extra_packets or {}
                    table.insert(results.extra_packets, {target = target, effects = "Suppressed"})
                end
            end
        end
        return results, attack_args
    end

    mg.GetActionResults = function(self, unit, args)
        local args = table.copy(args)
        args.weapon = args.weapon or self:GetAttackWeapons(unit, args)
        args.num_shots = Rat_ClampAutoShots(self, args.weapon, args.num_shots)
        if args.prediction == false then
            args.num_shots = Rat_AutoOverrun(unit, args.weapon, args.num_shots)
        end
        args.multishot = true
        args.damage_bonus = 0
        local attack_args = unit:PrepareAttackArgs(self.id, args)
        local results = attack_args.weapon:GetAttackResults(self, attack_args)
        return results, attack_args
    end
end

---------------------------------------------------------------------------------------------------
---- Crosshair: the selected length lives on the crosshair, per action id, for as long as it is open.
---------------------------------------------------------------------------------------------------

function Rat_CrosshairSetShots(crosshair, action, n)
    crosshair.rat_shots = crosshair.rat_shots or {}
    crosshair.rat_shots[action.id] = n
    return n
end

---- nil for fixed-length actions
function Rat_CrosshairShots(crosshair, attacker, action)
    if not Rat_IsVariableAuto(action) then
        return
    end
    local weapon = action:GetAttackWeapons(attacker)
    if not weapon then
        return
    end
    local cur = crosshair.rat_shots and crosshair.rat_shots[action.id]
    return Rat_CrosshairSetShots(crosshair, action, Rat_ClampAutoShots(action, weapon, cur))
end

---- refuses a step the unit cannot pay for at the current aim level
function Rat_CrosshairStepShots(crosshair, step)
    local ctx = crosshair.context
    local attacker, action = ctx and ctx.attacker, ctx and ctx.action
    local cur = Rat_CrosshairShots(crosshair, attacker, action)
    if not cur then
        return false
    end
    local weapon = action:GetAttackWeapons(attacker)
    local n = Rat_ClampAutoShots(action, weapon, cur + step)
    if n == cur then
        return true
    end
    if step > 0 then
        local args = {
            target = ctx.target,
            aim = crosshair.aim or 0,
            num_shots = n,
            target_spot_group = crosshair.targetPart and crosshair.targetPart.id,
            free_aim = ctx.free_aim
        }
        if action:GetUIState({attacker}, args) ~= "enabled" then
            return true
        end
    end
    Rat_CrosshairSetShots(crosshair, action, n)
    crosshair:UpdateAim()
    return true
end

local function crosshair_wheel(dlg, step)
    local crosshair = dlg.crosshair
    if not crosshair or crosshair.window_state == "destroying" or crosshair.window_state ==
        "pre-destroying" then
        return false
    end
    return Rat_CrosshairStepShots(crosshair, step)
end

function IModeCombatAttackBase:OnMouseWheelForward(...)
    if crosshair_wheel(self, 1) then
        return "break"
    end
    return IModeCommonUnitControl.OnMouseWheelForward(self, ...)
end

function IModeCombatAttackBase:OnMouseWheelBack(...)
    if crosshair_wheel(self, -1) then
        return "break"
    end
    return IModeCommonUnitControl.OnMouseWheelBack(self, ...)
end

---------------------------------------------------------------------------------------------------
---- CrosshairUI.lua: Attack built its args without num_shots. Only the args table changed.
---------------------------------------------------------------------------------------------------
function CrosshairUI:Attack()
    local selfContext = self.context
    local attacker = selfContext.attacker
    local action = selfContext.action
    local weapon = action:GetAttackWeapons(attacker)
    local target = selfContext.target
    local gotoPos = selfContext.meleeTargetPos
    local aim = self.aim

    if not IsValid(target) then
        return
    end

    if not IsKindOf(attacker, "Unit") or not attacker:CanBeControlled() or not weapon then
        return
    end

    if CombatActionCannotBeStarted(action.id, attacker) then
        return
    end

    local bodyPartArg = ""
    if IsKindOf(target, "Unit") then
        bodyPartArg = self.targetPart.id

        if bodyPartArg == "BlindFire" then
            local cachedResults = self.cached_results
            cachedResults = cachedResults[action.id]
            cachedResults = cachedResults.attackResultCalc

            local validOptions = {}
            for partName, partData in sorted_pairs(cachedResults) do
                if partName ~= "BlindFire" and partData.target_hit then
                    validOptions[#validOptions + 1] = partName
                end
            end
            if #validOptions == 0 then
                validOptions[#validOptions + 1] = g_DefaultShotBodyPart
            end
            bodyPartArg = table.rand(validOptions)
        elseif bodyPartArg == "InCover" then
            local cachedResults = self.cached_results
            cachedResults = cachedResults[action.id]
            cachedResults = cachedResults.attackResultCalc
            cachedResults = cachedResults and cachedResults["InCover"]

            local bodyPartId = cachedResults and cachedResults.actual_body_part
            if not bodyPartId then
                bodyPartId = g_DefaultShotBodyPart
            end
            bodyPartArg = bodyPartId
        end
    end

    local dialog = GetInGameInterfaceModeDlg()
    local args = {
        target = target,
        goto_pos = dialog.args_gotopos and gotoPos,
        target_spot_group = bodyPartArg,
        aim = aim,
        num_shots = Rat_CrosshairShots(self, attacker, action)
    }
    local shoot_ap = action:GetAPCost(attacker, args)
    if not attacker:UIHasAP(shoot_ap, action.id, args) then
        CombatLog("debug", T {Untranslated("Not enough action points"), attacker})
        return
    end

    local can_attack, reason = attacker:CanAttack(target, weapon, action, aim, gotoPos, nil,
                                                  selfContext.free_aim)
    if not can_attack then
        CombatLog("debug", T {Untranslated("<error><reason></error>"), reason = reason})
        return
    end

    if dialog.args_gotopos then
        assert(gotoPos)
    end

    if self.time_dilation then
        SetTimeFactor(const.DefaultTimeFactor)
        self.time_dilation = false
    end

    if self.darkness_tutorial then
        self.darkness_tutorial = false
        TutorialHintsState.InDarkness = true
    end

    args.action_override = action
    dialog.action_params = args
    local traceData = table.copy(args)
    local retVal = dialog:Confirm("crosshair")
    if retVal ~= "break" then
        traceData.action_override = traceData.action_override.id
        traceData.target = traceData.target.session_id
        traceData.response = tostring(retVal)
        print(traceData)
        CombatLog("debug", TableToLuaCode(traceData))
        assert(not "For some reason the attack didn't go through.")
    end
    self:SetVisible(false)
end

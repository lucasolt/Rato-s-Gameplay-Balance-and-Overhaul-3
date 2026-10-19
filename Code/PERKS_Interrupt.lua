---- Opportunistic Killer: +Overwatch attacks and the vanilla auto-reload, no interrupt crits.
---- Killzone (Overwatch) / Beaten Zone (ex Collateral Damage, MG setup): interrupt aim ladders by distinct target per turn; Killzone enables crits, Beaten Zone keeps object damage.

GameVar("gv_Rat_KillzoneTargets", function() return {} end)

local function IsMGSetUp(unit)
    return unit:HasStatusEffect("StationedMachineGun") or unit:HasStatusEffect("ManningEmplacement")
end

local function KillzonePerk(unit)
    return IsMGSetUp(unit) and "CollateralDamage" or "Killzone"
end

local function KillzoneTargetRank(attacker, target)
    local ranks = gv_Rat_KillzoneTargets[attacker.session_id]
    if not ranks then
        ranks = {}
        gv_Rat_KillzoneTargets[attacker.session_id] = ranks
    end
    local rank = ranks[target.session_id]
    if not rank then
        rank = #ranks + 1
        ranks[rank] = target.session_id
        ranks[target.session_id] = rank
    end
    return rank
end

function Rat_KillzoneAim(attacker, target, aim, action)
    if not HasPerk(attacker, KillzonePerk(attacker)) or not IsKindOf(target, "Unit") then
        return aim
    end
    local ladder = const.Combat.Perks.KillzoneAimByTarget
    local ladder_aim = ladder[Min(KillzoneTargetRank(attacker, target), #ladder)]
    local _, max_aim = attacker:GetBaseAimLevelRange(action, target)
    return Max(aim, Min(ladder_aim, max_aim or ladder_aim))
end

function OnMsg.CombatEnd()
    gv_Rat_KillzoneTargets = {}
end

local function KillzoneResetReaction()
    return PlaceObj('UnitReaction', {
        Event = "OnBeginTurn",
        Handler = function(self, target)
            gv_Rat_KillzoneTargets[target.session_id] = nil
        end
    })
end

RAT_BEATEN_ZONE_ICON = "Mod/cfahRED/Images/perk_BeatenZone.png"

function Rat_BeatenZoneTexts()
    local file_str = "PERKS_Interrupt.lua"
    return ratT(file_str, 483920175320, "Beaten Zone"),
           ratT(file_str, 483920175321, "<em>Machine Gun</em> <GameTerm('Interrupt')> attacks in <em>Setup</em> against the <em>first</em> enemy each turn have <em>3 aim levels</em>, against the <em>second</em> <em>2 aim levels</em>.\n\nDeal <em><percent(objectDamageMod)> Damage</em> to objects with <em>Heavy Weapons</em> and <em>Machine Guns</em>.")
end

function OnMsg.ClassesGenerate(classdefs)
    local ok = classdefs.OpportunisticKiller
    if ok then
        local reactions = ok.unit_reactions or {}
        for i = #reactions, 1, -1 do
            if reactions[i].Event == "OnCalcCritChance" then
                table.remove(reactions, i)
            end
        end
        reactions[#reactions + 1] = PlaceObj('UnitReaction', {
            Event = "OnCalcOverwatchAttacks",
            Handler = function(self, target, value, action, args)
                return value + const.Combat.Perks.OpportunisticKillerBonusAttacks
            end
        })
        ok.unit_reactions = reactions
    end

    if classdefs.Killzone then
        classdefs.Killzone.unit_reactions = {
            KillzoneResetReaction(),
            PlaceObj('UnitReaction', {
                Event = "OnCalcCritChance",
                Handler = function(self, target, attacker, attack_target, action, weapon, data)
                    ---- Overwatch only: Pin Down crits on its own (GetAttackResults), Retaliation never
                    if target == attacker and data.opportunity_attack_type == "Overwatch" and
                        not IsMGSetUp(attacker) then
                        data.opportunity_attack = false
                    end
                end
            })
        }
    end

    local bz = classdefs.CollateralDamage
    if bz then
        bz.unit_reactions = {KillzoneResetReaction()}
        ---- vanilla object branch; Weapon.lua:296 adds objectDamageMod on its own path too
        bz.unit_reactions[#bz.unit_reactions + 1] = PlaceObj('UnitReaction', {
            Event = "OnCalcDamageAndEffects",
            Handler = function(self, target, attacker, attack_target, action, weapon, attack_args, hit, data)
                if attacker ~= target or IsKindOf(attack_target, "Unit") or
                    not IsKindOf(attack_target, "CombatObject") or
                    not IsKindOfClasses(weapon, "HeavyWeapon", "MachineGun") then
                    return
                end
                local bonus = self:ResolveValue("objectDamageMod")
                data.base_damage = MulDivRound(data.base_damage, 100 + bonus, 100)
                data.breakdown[#data.breakdown + 1] = {name = self.DisplayName, value = bonus}
            end
        })
        bz.DisplayName, bz.Description = Rat_BeatenZoneTexts()
        bz.Icon = RAT_BEATEN_ZONE_ICON
    end
end

---- Vanilla copies below: only num_attacks (Killzone used to double them) and the Killzone aim differ.

function Unit:ProvokeOpportunityAttack_Pindown(obj, descr)
    self:InterruptBegin()
    LockCameraMovement("pindown")
    AdjustCombatCamera("set")
    descr = descr or g_Pindown[obj]
    obj:SetAttackReason(T(579571403585, "Pin Down"), true)

    local cmd_thread = CurrentThread() == self.command_thread
    if cmd_thread then
        self:PushDestructor(function(self)
            obj:FinishOpportunityAttack_Pindown()
        end)
    end

    local num_attacks = 1

    for i = 1, num_attacks do
        local weapon = obj:GetActiveWeapons("Firearm")
        local default_action = obj:GetDefaultAttackAction()
        if not weapon or not default_action or
            not obj:CanAttack(self, weapon, default_action, 0, nil, "skip_ap_check") then
            break
        end
        if IsValidTarget(self) then
            obj:SetCommand("PinDownAttack", self, descr.action_id, descr.target_spot_group, descr.aim)
            while not obj:IsIdleCommand() do
                WaitMsg("Idle", 100)
            end
        end
    end

    while not obj:IsIdleCommand() do
        WaitMsg("Idle")
    end
    if cmd_thread then
        self:PopDestructor()
    end
    obj:FinishOpportunityAttack_Pindown()
end

function Unit:ProvokeOpportunityAttack_Overwatch(obj, attack_args, target_dummy)
    local overwatch = g_Overwatch[obj]
    if not overwatch then
        return
    end
    overwatch.triggered_by[self.handle] = true
    CombatLog("short", T {353305209140, "<LogName> was revealed by enemy overwatch", self})
    self:RemoveStatusEffect("Hidden")
    self:InterruptBegin()

    local reason = T(484641340197, "Overwatch")
    obj:SetAttackReason(reason, true)

    local cmd_thread = CurrentThread() == self.command_thread
    if cmd_thread then
        self:PushDestructor(function(self)
            obj:FinishOpportunityAttack_Overwatch()
        end)
    end
    attack_args.aim = overwatch.aim
    attack_args.origin_action_id = overwatch.origin_action_id
    assert(attack_args.target == self)
    attack_args.target_dummy = target_dummy
    attack_args.opportunity_attack = true
    attack_args.opportunity_attack_type = "Overwatch"
    if overwatch.cone_angle > 180 * 60 then
        attack_args.circular_overwatch = true
    end
    local lof_data
    for _, data in ipairs(attack_args.lof) do
        if data.ally_hits_count == 0 and data.target_spot_group == attack_args.target_spot_group then
            lof_data = data
            break
        end
    end
    lof_data = lof_data or attack_args.lof[1]
    table.clear(attack_args.lof)
    lof_data.target_spot_group = "Torso"
    attack_args.lof[1] = lof_data
    attack_args.target_spot_group = "Torso"

    local status
    local num_attacks = 1

    for i = 1, num_attacks do
        local weapon = obj:GetActiveWeapons("Firearm")
        local default_action = obj:GetDefaultAttackAction("ranged", "ungrouped", nil, true, "ignore",
                                                          {skip_ap_check = true})
        if not weapon or not default_action or
            not obj:CanAttack(self, weapon, default_action, 0, nil, "skip_ap_check") then
            break
        end
        overwatch.action_id = default_action.id
        if IsValidTarget(self) then
            attack_args.aim = Rat_KillzoneAim(obj, self, overwatch.aim or 0, default_action)
            if IsKindOf(obj.prepared_attack_obj, "AOEActionVisuals") then
                obj.prepared_attack_obj:SetState("activate", self:GetPos())
            end
            obj:SetCommand("OpportunityAttack", default_action.id, attack_args, status)
            if attack_args.circular_overwatch and obj.combat_behavior == "OverwatchAction" then
                local shot_vector = self:GetPos() - obj:GetPos()
                local target_pos = (obj:GetPos() + SetLen(shot_vector, overwatch.dist)):SetZ(
                                       overwatch.target_pos:z())
                local args = obj.combat_behavior_params[3]
                if args then
                    args.target = target_pos
                end
            end
            while not obj:IsIdleCommand() do
                WaitMsg("Idle", 100)
            end
        end
    end

    if cmd_thread then
        self:PopDestructor()
    end
    obj:FinishOpportunityAttack_Overwatch()
end

function Unit:Retaliate(attacker, attack_reason, fnGetAttackAndWeapon)
    if not IsKindOf(attacker, "Unit") or attacker.team ~= g_Teams[g_CurrentTeam] or attacker == self then
        return false
    end
    if self:IsDead() or self:IsDowned() or not self:IsAware() or self:HasPreparedAttack() then
        return false
    end

    local retaliated = false

    local num_attacks = 1
    for i = 1, num_attacks do
        local action, weapon
        if fnGetAttackAndWeapon then
            action, weapon = fnGetAttackAndWeapon(self)
        else
            weapon = self:GetActiveWeapons("Firearm")
            if IsKindOf(weapon, "HeavyWeapon") then
                weapon = nil
            else
                action = self:GetDefaultAttackAction()
            end
        end
        if not weapon or not action or
            not self:CanAttack(attacker, weapon, action, 0, nil, "skip_ap_check") then
            break
        end

        local lof_data = GetLoFData(self, {attacker}, {action_id = action.id})
        if lof_data[1].los == 0 then
            break
        end

        if i == 1 then
            self:SetAttackReason(attack_reason, true)
            attacker:InterruptBegin()
        end
        if IsValidTarget(attacker) then
            retaliated = true
            self:QueueCommand("RetaliationAttack", attacker, false, action)
            while not self:IsIdleCommand() do
                WaitMsg("Idle")
            end
        end
    end

    ClearAITurnContours()
    g_Interrupt = true

    self:SetAttackReason()
    return retaliated
end

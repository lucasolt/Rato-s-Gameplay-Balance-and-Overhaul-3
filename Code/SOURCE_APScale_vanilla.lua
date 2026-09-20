-- Vanilla params multiplied by const.Scale.AP in code; rescaled so they stay in displayed AP (and their "<param> AP" texts stay true).
-- Only presets this mod does NOT own: our own are authored in displayed AP already.
local APScaleParams = {
    CharacterEffectDefs = {
        {"AI_AdditionalAP", "bonus"}, {"BattleFocus", "battleFocusAP"}, {"Bleeding", "APLoss"},
        {"Exhausted", "ap_loss"}, {"Throwing", "FirstThrowCostReduction"}, {"Hardened", "maxReservedAP"},
        {"HeavyWeaponsTraining", "ap_cost_reduction"}, {"HeavyWeaponsTraining", "min_ap_cost"},
        {"Heroic", "ap_gain"}, {"Inspired", "bonus"},
        {"SidneyPerk", "APBuff"}, {"Stimmed", "apGain"}, {"Suppressed", "ap_loss"}, {"Tired", "ap_loss"},
        {"WellRested", "ap_gain"}, {"YouSeeIgor", "APRestore"}, {"HawksEye", "pindownCostOverwrite"},
        {"SteadyBreathing", "freeMoveBonusAp"}, {"MinFreeMove", "minFreeMove"},
        -- Protected.max_ap_carried is owned by presets_char_effect(), which runs after this and would undo the rescale.
    },
    CombatActions = {
        {"Charge", "move_ap"}, {"HyenaCharge", "move_ap"}, {"GloryHog", "move_ap"},
    },
}

-- preset -> {param name -> authored Value} for every shadowed param.
local APScaled = setmetatable({}, weak_keys_meta)

function Rat_GetAPScaledParams(preset)
    return APScaled[preset]
end

-- Param.Value is never touched, so an editor save by any mod keeps the authored value; the scaled one lives where
-- ResolveValue finds it first and saving does not look:
-- StoreAsTable presets (CombatActions) serialize every field but Preset:ResolveValue falls back to g_PresetParamCache;
-- CharacterEffectCompositeDef reads Parameters directly, but GetProperty comes first and undeclared fields are not saved.
local function ScaleParam(preset, name)
    local param = table.find_value(preset.Parameters or empty_table, "Name", name)
    if not param or preset:GetPropertyMetadata(name) then
        return
    end
    local value = R_VanillaAPToDisplay(param.Value)
    if preset.StoreAsTable then
        g_PresetParamCache[preset] = g_PresetParamCache[preset] or {}
        g_PresetParamCache[preset][name] = value
    else
        rawset(preset, name, value)
    end
    APScaled[preset] = APScaled[preset] or {}
    APScaled[preset][name] = param.Value
end

-- Presets outside this economy author AP params in vanilla AP and multiply by const.Scale.AP where they are used.
-- Scanning their generated preset files finds those params without listing every mod here.
-- Declaring cfahRED as a dependency is what marks a mod as authored in displayed AP: our standalone mods must stay
-- playable without this one, so they keep the vanilla idiom and get rescaled like anybody else's.
local ScanGroups = {
    ModItemCharacterEffectCompositeDef = "CharacterEffectDefs",
    ModItemCombatAction = "CombatActions",
}

local function AuthoredInDisplayedAP(mod)
    if mod.id == "cfahRED" then
        return true
    end
    for _, dep in ipairs(mod.dependencies or empty_table) do
        if dep.id == "cfahRED" then
            return true
        end
    end
end

local function ScanModAPParams()
    local found = {}
    for _, mod in ipairs(ModsLoaded or empty_table) do
        if not AuthoredInDisplayedAP(mod) then
            for _, file in ipairs(mod.code or empty_table) do
                if file:find("^CharacterEffect/") or file:find("^CombatAction") then
                    local _, text = AsyncFileToString(mod.content_path .. file)
                    local group = text and ScanGroups[text:match('__generated_by_class = "([%w_]+)"') or ""]
                    local class = group and text:match("DefineClass%.([%w_]+)")
                    if class then
                        for name in text:gmatch('ResolveValue%(%s*"([%w_]+)"%s*%)%s*%*%s*const%.Scale%.AP') do
                            found[#found + 1] = { group, class, name }
                        end
                    end
                end
            end
        end
    end
    return found
end

function Rat_ApplyAPScaleParams()
    for group, list in pairs(APScaleParams) do
        local presets = _G[group]
        for _, entry in ipairs(list) do
            local preset = presets[entry[1]]
            if preset then
                ScaleParam(preset, entry[2])
            end
        end
    end
    for _, entry in ipairs(ScanModAPParams()) do
        local preset = (_G[entry[1]] or empty_table)[entry[2]]
        if preset then
            ScaleParam(preset, entry[3])
        end
    end
    -- Item APCost is a whole-AP class value consumed as APCost * const.Scale.AP.
    ForEachPreset("InventoryItemCompositeDef", function(preset)
        local class = g_Classes[preset.id]
        if class and IsKindOf(class, "MiscItemProperties") then
            local key = "APCost." .. preset.id
            local orig = ratG_APScaleOriginals[key]
            if orig == nil then
                orig = class.APCost
                ratG_APScaleOriginals[key] = orig
            end
            class.APCost = R_VanillaAPToDisplay(orig)
        end
    end)
end

function OnMsg.DataLoaded()
    Rat_ApplyAPScaleParams()
end

function OnMsg.ModsReloaded()
    Rat_ApplyAPScaleParams()
end

---------------------------------------------------------------------------------------------------
-- Unit.lua: aim cost and the heavy-rain rule were whole vanilla AP (const.Scale.AP and a literal 1000).
function Unit:GetAttackAPCost(action, weapon, action_ap_cost, aim, delta)
    if not weapon then
        return 0
    end

    local min, max = self:GetBaseAimLevelRange(action, weapon)
    aim = Clamp(aim or 0, min, max) - min
    delta = delta or 0
    local aimCost = R_VanillaAP(1)
    local rain_penalty = GameState.RainHeavy and not self.indoors
    if rain_penalty then
        aimCost = MulDivRound(aimCost, 100 + const.EnvEffects.RainAimingMultiplier, 100)
    end

    local ap = action_ap_cost or weapon.AttackAP or weapon.ShootAP or 0
    ap = ap + delta
    ap = self:CallReactions_Modify("OnCalcAPCost", ap, action, weapon, aim)

    if IsKindOf(weapon, "HeavyWeapon") then
    elseif IsKindOf(weapon, "Firearm") or IsKindOf(weapon, "Grenade") or IsKindOf(weapon, "MeleeWeapon") then
        ap = ap + aim * aimCost
    else
        ap = -1
    end

    -- legal cheat: during heavy rain last possible aim costs 1 AP regardless of the penalty
    local remainingAP = (self:GetUIActionPoints() / R_VanillaAP(1)) * R_VanillaAP(1)
    if rain_penalty and ap > remainingAP and aim > 0 then
        local diff = abs(remainingAP - ap)
        if diff < aimCost and diff >= R_VanillaAP(1) then
            ap = remainingAP
            aimCost = R_VanillaAP(1)
        end
    end

    return ap, aimCost
end

-- Unit.lua: morale and gas mask AP at turn start were whole vanilla AP.
function Unit:BeginTurn(new_turn)
    NetUpdateHash("BeginTurn_Start")
    self:SetAttackReason()
    local should_interrupt = true
    local pindown = g_Pindown[self]
    local overwatch = g_Overwatch[self]
    if pindown and IsValidTarget(pindown.target) and self:HasPindownLine(pindown.target, pindown.target_spot_group) then
        should_interrupt = false
    elseif overwatch and (overwatch.permanent or not g_Combat or overwatch.expiration_turn > g_Combat.current_turn) then
        should_interrupt = false
    elseif self.prepared_bombard_zone then
        should_interrupt = false
    end
    if new_turn and should_interrupt then
        self:InterruptPreparedAttack("begin turn")
        pindown = false
    end
    self:UpdateMeleeTrainingVisual()
    self:IsThreatened()

    if self.is_melee_aim_last_turn and IsMerc(self) then
        PlayVoiceResponse(self, "MeleeEnemiesClosing")
        self.is_melee_aim_last_turn = false
    end

    self.perks_activated = {}
    NetUpdateHash("BeginTurn_Progress")
    if new_turn then
        self:RemoveStatusEffect("FreeMove")
        if g_Overwatch[self] and not g_Overwatch[self].permanent then
            self.ActionPoints = 0
        else
            local ap = self:GetMaxActionPoints()
            ap = self:CallReactions_Modify("OnCalcStartTurnAP", ap)
            self.ActionPoints = Max(0, ap)
        end
        if g_Overwatch[self] then
            table.clear(g_Overwatch[self].triggered_by)
            if self:HasStatusEffect("ManningEmplacement") or self:HasStatusEffect("StationedMachineGun") then
                g_Overwatch[self].num_attacks = self:GetNumMGInterruptAttacks()
                self:UpdateOverwatchVisual()
            end
        end
        g_Pindown[self] = nil
        self.ui_reserved_ap = 0

        if self:GetEffectValue("missed_by_kill_shot") and not self:IsDead() and not self:IsDowned() then
            PlayVoiceResponse(self, "MissedByKillShot")
            self:SetEffectValue("missed_by_kill_shot", nil)
        end

        self:UpdateHidden()

        local voxels = self:GetVisualVoxels()
        local fire, dist = AreVoxelsInFireRange(voxels)
        if fire then
            local min, max = const.BurnDamageMin, const.BurnDamageMax
            local damage = self:RandRange(min, max)
            self:TakeDirectDamage(damage)
            if not self:IsIncapacitated() and not self:HasStatusEffect("Unconscious") and not RollSkillCheck(self, "Health") then
                self:ChangeTired(1)
            end
            if dist < const.SlabSizeX then
                self:AddStatusEffect("Burning")
            end
        end

        self.attacked_this_turn = false
        self.hit_this_turn = false
        self.wounded_this_turn = false
        NetUpdateHash("BeginTurn", self, self.using_cumbersome, HasPerk(self, "KillingWind"),
                      HasPerk(self, "Ironclad"))
        if not self.using_cumbersome or HasPerk(self, "KillingWind") then
            self:AddStatusEffect("FreeMove")
        elseif self:CanUseIroncladPerk() then
            self:AddStatusEffect("FreeMove")
            self:ConsumeAP(DivRound(self.free_move_ap, 2), "Move")
        end

        self.performed_action_this_turn = false

        Msg("UnitBeginTurn", self)
        self:CallReactions("OnBeginTurn")

        local morale = self:GetPersonalMorale()
        if morale > 0 then
            self:GainAP(R_VanillaAP(morale))
        elseif morale < 0 then
            self:ConsumeAP(Min(self.ActionPoints, R_VanillaAP(-morale)))
        end

        if self:GetItemInSlot("Head", "GasMaskBase") then
            self:ConsumeAP(R_VanillaAP(1))
        end

        if self.command == "Die" then
            SnapCameraToObj(self)
            while self.command == "Die" do
                WaitMsg("UnitDied", 20)
            end
        elseif pindown then
            pindown.target:ProvokeOpportunityAttack_Pindown(self, pindown)
        elseif self.prepared_bombard_zone then
            self:StartBombard()
        end
    end

    if self.dummy or self:IsDowned() then
        self.ActionPoints = 0
    end

    self.start_turn_pos = self:GetVisualPos()

    NetUpdateHash("BeginTurn", self, self:GetPos())

    Msg("UnitAPChanged", self)
end

-- Morale.lua: tooltip text for the morale AP above.
function CombatTeam:GetMoraleLevelAndEffectsText()
    local morale = self.morale
    local effects_text = ""
    local pchance = self:GetMoraleEffectChance("positive")
    local nchance = self:GetMoraleEffectChance("negative")
    if morale == 0 then
        effects_text = T{872793014384, "  Positive effect chance: <percent(num1)><newline>", num1 = pchance}
    elseif morale > 0 then
        effects_text = T{891625701767, "  <ap(num)> on start of turn<newline>  Positive effect chance: <percent(num1)>", num = R_VanillaAP(morale), num1 = pchance}
    else
        effects_text = T{295409017319, "  <ap(num)> on start of turn<newline>  Negative effect chance: <percent(num1)>", num = R_VanillaAP(morale), num1 = nchance}
    end
    return T{834924000608, "Team Morale: <level><newline><effects><newline><newline>The morale level of each merc is influenced by Team Morale and various individual factors. Morale <em>modifies AP</em> and can trigger positive and negative effects based on the <em>highest Leadership</em> among the mercs.", level = MoraleLevelName[morale] or morale, effects = effects_text}
end

-- ClassDef-Effects: scripted AP grants are authored in whole vanilla AP.
function UnitGrantAP:__exec(obj, context)
    if IsKindOf(obj, "Unit") and not obj:IsDead() then
        if self.ap > 0 then
            obj:GainAP(R_VanillaAP(self.ap))
        else
            obj:ConsumeAP(R_VanillaAP(self.ap))
        end
    end
end

---------------------------------------------------------------------------------------------------
-- IModeCombatCharge.lua: minDistance is a world distance that vanilla scaled by const.Scale.AP (1000 = guim).
local function combat_path_to_charge_path(path)
    local charge = {path[1]}
    local _prev = point(point_unpack(path[1]))
    for i = 2, #path - 1 do
        local _cur = point(point_unpack(path[i]))
        local _next = point(point_unpack(path[i + 1]))

        local v1, v2 = SetLen((_cur - _prev):SetZ(0), 4096), SetLen((_next - _cur):SetZ(0), 4096)
        if Dot(v1, v2) / 4096 < 4096 then
            charge[#charge + 1] = path[i]
            _prev = _cur
        end
    end
    charge[#charge + 1] = path[#path]

    return charge
end

local function GetChargeAttackCombatPath(attacker, action_id, ap)
    local attack_pos = attacker:GetPos()
    local move_modifier = attacker:GetMoveModifier()
    if not ap then
        local action = CombatActions[action_id]
        ap = action:ResolveValue("move_ap") * const.Scale.AP
    end
    if not g_ChargeAttackCombatPath or
        g_ChargeAttackCombatPath.attacker ~= attacker or
        g_ChargeAttackCombatPath.ap ~= ap or
        g_ChargeAttackCombatPath.action_id ~= action_id or
        g_ChargeAttackCombatPath.attack_pos ~= attack_pos or
        g_ChargeAttackCombatPath.move_modifier ~= move_modifier
    then
        g_ChargeAttackCombatPath = {
            attacker = attacker,
            ap = ap,
            action_id = action_id,
            attack_pos = attack_pos,
            move_modifier = move_modifier,
            combat_path = CombatPath:new()
        }
        g_ChargeAttackCombatPath.combat_path:RebuildPaths(attacker, ap)
    end
    return g_ChargeAttackCombatPath.combat_path
end

function GetChargeAttackPosition(attacker, target, ap, action_id)
    local apos = attacker:GetPos()
    local tpos = GetPassSlab(target)
    local combatPath = GetChargeAttackCombatPath(attacker, action_id)
    local atk_pos, atk_dot, atk_path, min_dist_error, not_straight_error, frontal_error
    local tiles = combatPath:GetReachableMeleeRangePositions(target, true)
    if tiles then
        local min_angle = CombatActions[action_id]:ResolveValue("minAngle") * const.Scale.deg
        local ref_dot = MulDivRound(cos(min_angle), 1000, 4096)
        local minDistance = CombatActions.Charge:ResolveValue("minDistance") * guim
        for i, tile in ipairs(tiles) do
            local path = combatPath:GetCombatPathFromPos(tile)
            local tooClose = attacker:GetDist(point_unpack(tile)) < minDistance
            if path then
                path = combat_path_to_charge_path(path)
                local pos = point(point_unpack(tile))
                local prev_pos = point(point_unpack(path[2]))
                local move_dir = SetLen2D(pos - prev_pos, guim)
                local atk_dir = SetLen2D(pos - tpos, guim)
                local dot = Dot2D(move_dir, atk_dir) / guim
                if not atk_pos or atk_dot > dot then
                    local notStraight = dot > ref_dot or (#path ~= 2 and action_id ~= "GloryHog")
                    frontal_error = dot > ref_dot
                    atk_pos, atk_dot, atk_path, min_dist_error, not_straight_error = pos, dot, path, tooClose, notStraight
                end
            end
        end
    end
    DoneObject(combatPath)
    return atk_pos, atk_path, min_dist_error, not_straight_error, frontal_error
end

---------------------------------------------------------------------------------------------------
-- Cheat.lua: the grant/remove AP cheats are authored in whole vanilla AP (menu "Grant AP 100" = 10 turns).
function NetSyncEvents.CheatGrantObjAP(unit, ap)
    unit:InterruptPreparedAttack()
    unit:GainAP(R_VanillaAP(ap))
    unit:RecalcUIActions()
end

function CheatRemoveSelectedObjAP(ap)
    CheatLog("RemoveSelectedObjAP", ap)
    if not g_Combat or not SelectedObj then
        return
    end
    SelectedObj:ConsumeAP(R_VanillaAP(ap))
end

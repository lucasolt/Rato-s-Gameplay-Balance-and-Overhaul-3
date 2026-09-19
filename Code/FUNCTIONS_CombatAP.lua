---------------------------------------------------------------------------------------------------
-- TODO: remove this "action" paramater
function Unit:GetShootingStanceAP(target, weapon, aim, action, param)
    if not IsKindOf(weapon, "Firearm") then
        return 0
    end

    if not g_Combat or g_StartingCombat or g_TestingSaveLoadSystem then
        return 0
    end

    ---------------Already in Stance
    local stance = self:HasStatusEffect("shooting_stance") or
                       self:HasStatusEffect("ManningEmplacement") or
                       self:HasStatusEffect("StationedMachineGun")
    -------------------

    local ap_stance = GetWeapon_StanceAP(self, weapon)
    local ap_hipfire = 0

    ------(hipfire) Leftover, should be removed if not reinstated
    --if aim < 1 and not (target == self:GetLastAttack()) or not target then
    --    ap_hipfire = GetHipfire_StanceAP(self, weapon)
    --end

    ------------Rotate
    local ap_rotate
    if stance then
        ap_rotate = Clamp(ShootingConeAngle(self, weapon, target), 0,
                          ap_stance + Get_AimCost(self))
    else
        ap_rotate = 0
    end

    if g_Overwatch[self] then
        local overwatch = g_Overwatch[self] or false
        if overwatch and overwatch.permanent then
            ap_rotate = 0
        end
    end
    --------------

    if param == "rotate" then
        return ap_rotate
    end

    if param == "stance" then
        return ap_stance
    end

    if stance then
        return ap_rotate
    elseif aim < 1 then
        return ap_hipfire
    end

    return ap_stance

end
---------------------------------------------------------------------------------------------------
function rat_getMobileshot_moveAP(action, unit, weapon)
    local is_sprint = (action and action.id == "Sprint")
    local base_ap = action:ResolveValue("mobile_move_ap") or 9 --is_sprint and 8 or 9
    local min_ap = action:ResolveValue("mobile_move_ap_min") or 6 --is_sprint and 7 or 6
    local weapon_multiplier = is_sprint and 0.5 or 1.5

    local stanceap = 0
    if weapon and IsKindOf(weapon, "Firearm") then

        stanceap = (GetWeapon_StanceAP(unit, weapon) / R_VanillaAP(1))

        if (weapon.LargeItem or 0) < 1 or weapon:HasComponent("no_stock") then
            stanceap = Max(0, stanceap - 1)
        end

        if not (IsKindOf(weapon, "SubmachineGun") or IsKindOf(weapon, "Pistol") or
            IsKindOf(weapon, "Revolver")) then
            stanceap = stanceap + 2
        end

        stanceap = stanceap * weapon_multiplier
    end

    local agility_scaling = Max(0, (unit.Agility - 40.0) / 10.0)
    local move_ap = Max(min_ap, cRound(base_ap * 1.00 + agility_scaling - (stanceap)))

    return move_ap
end
---------------------------------------------------------------------------------------------------
-- Modifier a component adds to `prop` on attach (mirrors FirearmBase:SetWeaponComponent: last effect wins).
local function component_stat_modifier(component_id, prop)
    local def = WeaponComponents[component_id]
    local mul, add
    for _, effect_id in ipairs(def and def.ModificationEffects or empty_table) do
        local effect = WeaponComponentEffects[effect_id]
        local param = effect and effect.StatToModify == prop and effect.Parameters and effect.Parameters[1]
        if param then
            local value = def:ResolveValue(param.Name) or effect:ResolveValue(param.Name) or 0
            local scale = effect.Scale and const.Scale[effect.Scale]
            if scale then
                value = value * scale
            end
            mul, add = 1000, 0
            if effect.ModificationType == "Add" then
                add = value
            elseif effect.ModificationType == "Multiply" then
                mul = value * 10
            elseif effect.ModificationType == "Subtract" then
                add = -value
            end
        end
    end
    return mul, add
end

-- Saves replay the params baked at attach time; rebuild APStance from the current component defs.
local function rebuild_stance_modifiers(weapon)
    local stale = {}
    for _, data in ipairs(weapon.applied_modifiers or empty_table) do
        if data.prop == "APStance" and WeaponComponents[data.id] then
            stale[#stale + 1] = data.id
        end
    end
    for _, component_id in ipairs(stale) do
        weapon:RemoveModifier(component_id, "APStance")
    end
    for _, component_id in sorted_pairs(weapon.components or empty_table) do
        local mul, add = component_stat_modifier(component_id, "APStance")
        if mul then
            weapon:AddModifier(component_id, "APStance", mul, add)
        end
    end
end

local place_inventory_item = PlaceInventoryItem

function PlaceInventoryItem(item_id, instance, ...)
    local obj = place_inventory_item(item_id, instance, ...)
    if instance and IsKindOf(obj, "FirearmBase") then
        rebuild_stance_modifiers(obj)
    end
    return obj
end

-- Raw AP; APStance and component stance params are in displayed AP. `display` skips the AI multiplier.
function GetWeapon_StanceAP(unit, weapon, display)
    if not weapon or not IsKindOf(weapon, "Firearm") then
        return 0
    end
    local raw = Cumbersome_StanceAP(unit, weapon, weapon.APStance) * const.Scale.AP

    -- Strength-conditional, so it cannot be a stat modifier.
    local modifyVal = GetComponentEffectValue(weapon, "stance_ap_inc_STR", "StanceIncreaseSTR")
    if modifyVal then
        local str_min = GetComponentEffectValue(weapon, "stance_ap_inc_STR", "STR_threshold")
        if not unit or unit.Strength < str_min then
            raw = raw + modifyVal * const.Scale.AP
        end
    end

	if IsKindOfClasses(weapon, "MachineGun", "HeavyWeapon") and HasPerk(unit, "HeavyWeaponsTraining") then
    	local effect = unit:GetStatusEffect("HeavyWeaponsTraining")
    	local reduction = effect:ResolveValue("ap_cost_reduction") * const.Scale.AP
    	local minCost = effect:ResolveValue("min_ap_cost") * const.Scale.AP
    	raw = Max(minCost, raw - reduction)
	end
    raw = Max(0, raw)

    if display then
        return raw
    end

    if R_IsAI(unit) then
        raw = MulDivRound(raw, CurrentModOptions.AIWeaponStanceMul or 100, 100)
    end

    return raw
end
---------------------------------------------------------------------------------------------------
-- cost in displayed AP; the penalty is one vanilla AP.
function Cumbersome_StanceAP(unit, weapon, cost)
    if weapon:IsCumbersome() then
        local one = R_VanillaAPToDisplay(1)
        cost = cost + one
        if unit and unit.Strength >= const.Combat.CumbersomeStanceAP_StrThreshold then
            cost = Max(one, cost - one)
        end
    end
    return cost
end
---------------------------------------------------------------------------------------------------
function GetHipfire_StanceAP(unit, weapon) ---- not used

    --[[local ap_hipfire = 1 -------------hipfire
    ap_hipfire = Cumbersome_StanceAP(unit, weapon, ap_hipfire)

    if R_IsAI(unit) then
        ap_hipfire = MulDivRound(ap_hipfire, const.Combat.AI_ShootingStanceAP_Mul or 100, 100)
    end]]

    return 0 -- ap_hipfire * const.Scale.AP
end
---------------------------------------------------------------------------------------------------
function rat_MobileAction_AP(action, unit)

    if not unit or not action then
        return 0, 0
    end

    local weapon = action:GetAttackWeapons(unit)
    local att_cost = unit:GetAttackAPCost(action, weapon, nil, 0) -- CombatActions.BurstFire.GetAPCost(self, unit, args)
    local ap_delta = rat_getDeltaAP(action, weapon)
    local cost = att_cost + ap_delta

    if rat_canBolt(weapon) then
        local unbolted_shots = action:ResolveValue("mobile_num_shots") or 3
        local cycling_ap = rat_get_manual_cyclingAP(unit, weapon, true)
        if not weapon.unbolted then
            unbolted_shots = unbolted_shots - 1
        end

        cycling_ap = MulDivRound(cycling_ap, unbolted_shots, 2)
        if cycling_ap and cycling_ap > 0 then
            cost = cost + cycling_ap
        end
    end

    local ap_extra = GetWeapon_StanceAP(unit, weapon) + Get_AimCost(unit) -- mobile_stance_ap(unit, weapon)
    local cost_aimed = cost + ap_extra

    return cost, cost_aimed
end



function rat_get_manual_cyclingAP(unit, weapon, shooting)
    local dex = 0
    local tex_perk
    if unit then
        dex = unit.Dexterity
        tex_perk = unit and HasPerk(unit, "DanceForMe") and weapon and IsKindOf(weapon, "Revolver")
    end

    local bolt_ap_manual, DASA_action_ap

    if weapon:HasComponent("DASA_action_ap") then
        DASA_action_ap = GetComponentEffectValue(weapon, "DASA_action_ap", "ap_double_action")
        bolt_ap_manual = GetComponentEffectValue(weapon, "DASA_action_ap", "ap_manual")
    else
        bolt_ap_manual = GetComponentEffectValue(weapon, "bolt_action_ap", "ap_manual")
    end

    bolt_ap_manual = bolt_ap_manual * const.Scale.AP
    DASA_action_ap = DASA_action_ap and DASA_action_ap * const.Scale.AP

    -- Linear Dexterity reduction, rounded to displayed AP.
    local dex_start, dex_full = const.Combat.BoltActionDexStart, const.Combat.BoltActionDexFull
    local dex_steps = MulDivRound(Clamp(dex - dex_start, 0, dex_full - dex_start),
                                  const.Combat.BoltActionDexMaxReduction, dex_full - dex_start)
    bolt_ap_manual = bolt_ap_manual - dex_steps * const.Scale.AP

    if tex_perk then
        bolt_ap_manual = bolt_ap_manual - R_VanillaAP(const.Combat.TexPerkCycleAPDiscount)
    end

    if DASA_action_ap and (bolt_ap_manual < DASA_action_ap) then
        DASA_action_ap = bolt_ap_manual
    end

    local shooting_ap = DASA_action_ap or bolt_ap_manual

    if shooting then
        return Max(0, shooting_ap)
    end

    return Max(0, bolt_ap_manual)
end

---------------------------------------------------------------------------------------------------
function rat_getDeltaAP(action, weapon, action_id_override)
    local base = 0
    local action_id = ''

    if action_id_override then
        base = CombatActions[action_id_override].ActionPointDelta
        action_id = action_id_override
    elseif action then
        base = action.ActionPointDelta
        action_id = action.id
    end

    if action_id == "MobileShot" then
        action_id = "SingleShot"
    end

    if action_id == "SingleShot" then
        base = base + R_VanillaAP(weapon.SingleShotCustomDeltaAP or 0)

    elseif action_id == "AutoFire" then
        base = base + R_VanillaAP(weapon.AutoFireCustomDeltaAP or 0)
    end

    return base
end
---------------------------------------------------------------------------------------------------

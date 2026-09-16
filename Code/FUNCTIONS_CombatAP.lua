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
-- Sum of a stance AP param (vanilla AP, may be fractional) over all components, as raw AP.
local function stance_component_raw(weapon, effect_id, param)
    local total = 0
    for _, component_id in pairs(weapon.components or empty_table) do
        local def = WeaponComponents[component_id]
        if def and table.find(def.ModificationEffects or empty_table, effect_id) then
            total = total + (def:ResolveValue(param) or WeaponComponentEffects[effect_id]:ResolveValue(param) or 0)
        end
    end
    return math.floor(total * const.Combat.R_VanillaAPRaw + 0.5)
end

-- Raw AP. `display` skips the AI multiplier.
function GetWeapon_StanceAP(unit, weapon, display)
    if not weapon or not IsKindOf(weapon, "Firearm") then
        return 0
    end
    -- base_: saved weapons still carry APStance modifiers from when the stance effects had StatToModify
	-- Claude, this is a bad practice. If something else modifies the property, it will silently not be applied. 
    --local cost = weapon.base_APStance
	local cost = weapon.APStance
    cost = Cumbersome_StanceAP(unit, weapon, cost)

    local modifyVal, compDef = GetComponentEffectValue(weapon, "stance_ap_inc_STR",
                                                       "StanceIncreaseSTR")

    local str_min = 0
    if modifyVal then
        str_min = GetComponentEffectValue(weapon, "stance_ap_inc_STR", "STR_threshold")
        if not unit or unit.Strength < str_min then
            cost = cost + modifyVal
        end
    end

    local raw = Max(0, R_VanillaAP(cost) + stance_component_raw(weapon, "StanceAPincrease", "APincrease") -
        stance_component_raw(weapon, "StanceAPdecrease_fraction", "APdecrease"))

    if display then
        return raw
    end

    if R_IsAI(unit) then
        raw = MulDivRound(raw, CurrentModOptions.AIWeaponStanceMul or 100, 100)
    end

    return raw
end
---------------------------------------------------------------------------------------------------
function Cumbersome_StanceAP(unit, weapon, cost)
    if weapon:IsCumbersome() then
        cost = cost + 1
        if unit and unit.Strength >= const.Combat.CumbersomeStanceAP_StrThreshold then
            cost = Max(1, cost - 1)
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

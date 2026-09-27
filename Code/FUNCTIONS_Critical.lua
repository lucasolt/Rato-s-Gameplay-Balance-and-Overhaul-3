---- merc level no longer scales crit; per-aim crit lives in CritPerAim
function UnitProperties:GetBaseCrit(weapon)
    return weapon.CritChance
end

function UnitProperties:Getbase_BaseCrit(weapon)
    return weapon.base_CritChance
end

---- hundredths of % per aim level at Hand-Eye 100; components and ammo modify CritPerAim itself
function Rat_WeaponCritPerAim(weapon, action_id)
    local per_aim = weapon.CritPerAim
    if action_id == "PinDown" then
        per_aim = per_aim + const.Combat.PindownCritPerAimLevel
    end
    return per_aim
end

function Rat_CritPerAimCrit(weapon, attacker, action_id, aim)
    if aim <= 0 then
        return 0
    end
    local hand_eye = rGetHandEyeCoordination(attacker)
    return MulDivRound(Rat_WeaponCritPerAim(weapon, action_id) * aim, hand_eye, 100 * 100)
end

local rat_autofire_crit_actions = {
    AutoFire = true,
    MGBurstFire = true,
    GrizzlyPerk = true,
    BuckshotBurst = true
}

function Rat_CritFireModeMul(action_id, weapon)
    if action_id == "RunAndGun" or action_id == "RecklessAssault" then
        action_id = Rat_ShortBurstAttackId(weapon)
    end
    if action_id == "BurstFire" then
        return weapon.BurstCritMul
    end
    if rat_autofire_crit_actions[action_id] then
        return const.Combat.AutoFireCritMul
    end
    return 100
end

function OnMsg.GatherCritChanceModifications(attacker, target, action_id, weapon, data)

    if not weapon or not IsKindOf(weapon, "Firearm") or not attacker then
        return
    end

    local aim = data.aim or 0

    local crit_chance_breakdown = {base = data.crit_chance}

    local crit_per_aim = Rat_CritPerAimCrit(weapon, attacker, action_id, aim)
    crit_chance_breakdown["per_aim"] = crit_per_aim
    data.crit_chance = data.crit_chance + crit_per_aim

    ----------- Components
    if weapon:HasComponent("pso_dragunov_scope_critical") and aim > 1 then
        local pso_bonus = const.Combat.Critical.PSOScopeCritOnAimed
        data.crit_chance = data.crit_chance + pso_bonus
        crit_chance_breakdown["PSO_scope"] = pso_bonus
    end

    if weapon:HasComponent("first_aim_crit") and aim > 0 then
        local first_aim_bonus = const.Combat.Critical.FirstAimCrit
        data.crit_chance = data.crit_chance + first_aim_bonus
        crit_chance_breakdown["first_aim_bonus"] = first_aim_bonus
    end

    if aim > 0 then
        if data.target_spot_group and data.target_spot_group == "Head" then
            local modifyVal, compDef = GetComponentEffectValue(weapon, "scout_scope_crit",
                                                               "critical_head")
            if modifyVal then
                data.crit_chance = data.crit_chance + modifyVal
                crit_chance_breakdown["scout_scope_crit"] = modifyVal
            end
        end

        if data.target_spot_group and data.target_spot_group == "Torso" then
            local modifyVal, compDef = GetComponentEffectValue(weapon, "zrak_scope_crit",
                                                               "crit_torso")
            if modifyVal then
                data.crit_chance = data.crit_chance + modifyVal
                crit_chance_breakdown["zrak_scope_crit"] = modifyVal
            end
        end
    end
    --------

    ---- flat CritChance (ammo like 5.45 tumbling) has nothing to do with the firing mode
    local mode_mul = Rat_CritFireModeMul(action_id, weapon)
    if mode_mul ~= 100 then
        local flat = weapon.CritChance
        data.crit_chance = flat + MulDivRound(data.crit_chance - flat, mode_mul, 100)
        crit_chance_breakdown["fire_mode_mul"] = mode_mul
    end

    data.crit_chance_breakdown = crit_chance_breakdown
end

function OnMsg.GatherDamageModifications(attacker, target, action_id, self, mod_attack_args,
                                         mod_hit_data, data)
    local weapon = data.weapon

    if not IsKindOf(weapon, "Firearm") then
        return
    end

    local extra_damage = weapon.CritDamage
    if extra_damage then
        data.critical_damage = data.critical_damage + extra_damage
    end
end

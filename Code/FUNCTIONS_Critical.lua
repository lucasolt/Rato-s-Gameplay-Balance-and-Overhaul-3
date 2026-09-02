---TODO: change the perk per aim
function hand_eye_crit(action_id, weapon, attacker, aim)
    if not action_id then
        return 0
    end

    -- Firearm.CritScalingFactor = 100
    -- Firearm.BustShotCritScalingFactor = 100
    -- Firearm.SingleShotCritScalingFactor = 300
    -- G36.BustShotCritScalingFactor = 250
    -- SniperRifle.SingleShotCritScalingFactor = 500

    local single_factor = 3.0
    local not_single = 1.0
    local burst_factor = not_single

    if IsKindOf(weapon, "SniperRifle") then
        single_factor = 5.0
    end

    if IsKindOf(weapon, "G36") then
        burst_factor = 3.25
    end

    local hand_eye = rGetHandEyeCoordination(attacker)

    local factor = not_single

    if action_id == "SingleShot" or action_id == "PinDown" then
        factor = single_factor
    elseif action_id == "BurstFire" then
        factor = burst_factor
    end

    local hec_factor = MulDivRound(hand_eye, factor, const.Combat.HandEyeCritScalingFactor)
    local crit_HEC = cRound(hec_factor / 100 * (0 + (aim or 0)))

    return crit_HEC
end

function OnMsg.GatherCritChanceModifications(attacker, target, action_id, weapon, data)

    if not weapon or not IsKindOf(weapon, "Firearm") or not attacker then
        return
    end

    local aim = data.aim

    -- if attacker.unit_command == "GrizzlyPerk" then
    -- action_id == "MGBurstFire"
    -- end

    if not aim then
        aim = 0
    end

    local crit_chance_breakdown = {base = data.crit_chance}

    ----------- HEC
    local crit_HEC = hand_eye_crit(action_id, weapon, attacker, aim) or 0
    crit_chance_breakdown["HEC"] = crit_HEC
    data.crit_chance = data.crit_chance + crit_HEC
    -----------

    ----------- Pindown (Sniping)
    if action_id == "PinDown" then
        local crit_pindown = const.Combat.PindownCritPerAimLevel * aim
        crit_chance_breakdown["PinDown"] = crit_pindown
        data.crit_chance = data.crit_chance + crit_pindown
    end
    -----------

    ----------- Components
    if weapon and weapon:HasComponent("critical_per_aim_scope") then
        local crit_scope_aim = const.Combat.Critical.PrismScopeCritPerAim * aim
        crit_chance_breakdown["critical_per_aim_scope"] = crit_scope_aim
        data.crit_chance = data.crit_chance + crit_scope_aim
    end

    if weapon and weapon:HasComponent("critical_per_aim_laser") then
        local laser_aim = const.Combat.Critical.LaserDotCritPerAim * aim
        laser_aim = cRound(laser_aim)
        crit_chance_breakdown["critical_per_aim_laser"] = laser_aim
        data.crit_chance = data.crit_chance + laser_aim
    end

    if weapon and weapon:HasComponent("pso_dragunov_scope_critical") and aim > 1 then
        local pso_bonus = const.Combat.Critical.PSOScopeCritOnAimed
        data.crit_chance = data.crit_chance + pso_bonus
        crit_chance_breakdown["PSO_scope"] = pso_bonus
    end

    if weapon and weapon:HasComponent("first_aim_crit") then
        if aim and aim > 0 then
            local first_aim_bonus = const.Combat.Critical.FirstAimCrit
            data.crit_chance = data.crit_chance + first_aim_bonus
            crit_chance_breakdown["first_aim_bonus"] = first_aim_bonus
        end
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

    ----------- Burst Critical Reduction
    if action_id == "BurstFire" or action_id == "AutoFire" or action_id == "RunAndGun" or action_id ==
        "MGBurstFire" or action_id == "GrizzlyPerk" or action_id == "BuckshotBurst" then

        data.crit_chance = MulDivRound(data.crit_chance, const.Combat.BurstFireCriticalChanceMul,
                                       100)
    end
    ----------

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

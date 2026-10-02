---- Copy of FindTargetFromPos (IModeCombatMovingAttack.lua:239) with a CTH floor per candidate.
---- The source tests with attack_roll = 0, a forced hit: any trajectory that reaches the target
---- passed, including AP rounds through floor slabs at 1% CTH (Run and Gun shooting downstairs).
const.Combat.MobileShotMinCTH = 2

local function EvalEnemiesFromList(action_id, attacker, args, action, enemies, atk_pos, weapon,
                                   default, max_range)
    local best_enemy, best_chance_to_hit, canceling_reason
    local min_cth = const.Combat.MobileShotMinCTH or 0
    for i, enemy in ipairs(enemies) do
        if IsValidTarget(enemy) then
            args.target = enemy
            args.step_pos = atk_pos
            local attack_args = attacker:PrepareAttackArgs(action_id, args)
            if not attack_args.stuck then
                local dist = enemy:GetDist(atk_pos)
                attack_args.range = dist + guim
                local results = weapon:GetAttackResults(default, attack_args)
                if results.target_hit and (results.chance_to_hit or 0) > min_cth and
                    (not max_range or max_range >= dist) then
                    if not results.allyHit then
                        return enemy, results.chance_to_hit
                    end
                    if not best_enemy then
                        best_enemy, best_chance_to_hit, canceling_reason = enemy,
                                                                           results.chance_to_hit,
                                                                           "ally_hit"
                    end
                end
            end
        end
    end
    if best_enemy then
        return best_enemy, best_chance_to_hit, canceling_reason
    end
    return nil, 0
end

function FindTargetFromPos(action_id, attacker, action, enemies, atk_pos, weapon, can_use_covers)
    local args = {
        obj = attacker,
        weapon = weapon,
        step_pos = atk_pos,
        stance = "Standing",
        attack_roll = 0,
        can_use_covers = can_use_covers or false,
        prediction = true
    }
    local default = attacker:GetDefaultAttackAction("ranged", nil, weapon)
    local max_range = action:GetMaxAimRange(attacker, weapon)
    if IsKindOf(weapon, "Firearm") then
        max_range = max_range or weapon.WeaponRange
        max_range = MulDivRound(max_range, 150 * const.SlabSizeX, 100)
    else
        max_range = max_range and (max_range * const.SlabSizeX)
    end
    ---- callers pass GetEnemies' cached g_UnitEnemies table; sorting it in place reorders it for everyone
    enemies = table.icopy(enemies)
    table.sort(enemies, function(a, b)
        local distA = a:GetDist(atk_pos)
        local distB = b:GetDist(atk_pos)
        if distA == distB then
            return a.handle < b.handle
        end
        return distA < distB
    end)

    local primary, secondary = {}, {}
    for _, enemy in ipairs(enemies) do
        if IsKindOf(enemy, "Unit") then
            local tbl = enemy:IsDowned() and secondary or primary
            tbl[#tbl + 1] = enemy
        end
    end

    local best_enemy, best_chance_to_hit, canceling_reason =
        EvalEnemiesFromList(action_id, attacker, args, action, primary, atk_pos, weapon, default,
                            max_range)
    if best_enemy and not canceling_reason then
        return best_enemy, best_chance_to_hit
    end
    local sec_enemy, sec_cth, sec_reason = EvalEnemiesFromList(action_id, attacker, args, action,
                                                               secondary, atk_pos, weapon, default,
                                                               max_range)
    if sec_enemy and not sec_reason then
        return sec_enemy, sec_cth
    end
    if best_enemy then
        return best_enemy, best_chance_to_hit, canceling_reason
    end
    return sec_enemy, sec_cth, sec_reason
end

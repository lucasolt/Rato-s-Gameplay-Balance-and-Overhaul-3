---- Bullet Hell as traversing autofire: the rounds are split across the visible enemies in the cone,
---- and each share is a real autofire burst at that enemy (aCTH sim, recoil, body parts, cover).
---- Every engaged enemy is Suppressed and forced prone; vanilla hit everyone in the cone as AoE.

local bh_status = {"Suppressed", "SuppressionChangeStance"}

local function valid_z(pt)
    return pt:IsValidZ() and pt or pt:SetTerrainZ()
end

---- engaged enemies with their round share, in sweep order (the vanilla fan's +half to -half)
function Rat_BulletHellTargets(unit, weapon, target_pos, step_pos, total)
    local aoe = weapon:GetAreaAttackParams("BulletHell", unit, target_pos, step_pos)
    local sp, tp = valid_z(step_pos), valid_z(target_pos)
    ---- same range the aim cone draws (Targeting_AOE_Cone)
    local range = Clamp(sp:Dist(tp), aoe.min_range * const.SlabSizeX,
                        aoe.max_range * const.SlabSizeX)
    ---- always the prediction query, so the preview and the shot engage the same list
    local objs, los = GetAreaAttackTargets(step_pos, aoe.stance or unit.stance, true, range, 0,
                                           aoe.cone_angle, target_pos, unit:GetOccupiedPos(), true)
    local list = {}
    for i, obj in ipairs(objs) do
        if IsKindOf(obj, "Unit") and obj ~= unit and not obj:IsDead() and unit:IsOnEnemySide(obj) and
            (los[i] or 0) > 0 and HasVisibilityTo(unit.team, obj) then
            list[#list + 1] = {obj = obj, dist = sp:Dist(obj:GetPos())}
        end
    end
    if #list == 0 then
        return list
    end

    ---- nearest first when the magazine can't cover everyone; the remainder goes to the nearest too
    table.sort(list, function(a, b)
        if a.dist ~= b.dist then
            return a.dist < b.dist
        end
        return a.obj.handle < b.obj.handle
    end)
    local per = Max(1, const.Combat.Autofire.BulletHellMinShotsPerTarget)
    local n = Clamp(total / per, 1, #list)
    for i = #list, n + 1, -1 do
        list[i] = nil
    end
    local base, rem = total / n, total % n
    local axis = CalcOrientation(sp, tp)
    for i, t in ipairs(list) do
        t.shots = base + (i <= rem and 1 or 0)
        t.angle = AngleDiff(CalcOrientation(sp, t.obj:GetPos()), axis)
    end
    table.sort(list, function(a, b)
        if a.angle ~= b.angle then
            return a.angle > b.angle
        end
        return a.obj.handle < b.obj.handle
    end)
    return list
end

---- no one to engage: the rounds still go downrange at max range, fanned like vanilla
local function bh_empty_cone(action, unit, args, weapon, total, main)
    local aoe = weapon:GetAreaAttackParams(action.id, unit, main.target_pos, main.step_pos)
    local fb = table.copy(args)
    fb.weapon = weapon
    fb.num_shots = total
    fb.step_pos = main.step_pos
    fb.target = main.step_pos + SetLen2D((main.target_pos - main.step_pos):SetZ(0),
                                         aoe.max_range * const.SlabSizeX)
    fb.target = valid_z(fb.target)
    fb.target_pos = nil
    local attack_args = unit:PrepareAttackArgs(action.id, fb)
    local results = weapon:GetAttackResults(action, attack_args)
    results.rat_bh_fan = true
    return results, attack_args
end

local function bh_action_results(self, unit, args)
    local weapon = args.weapon or self:GetAttackWeapons(unit, args)
    local total = Clamp(weapon.ammo.Amount, self:ResolveValue("min_ammo"),
                        self:ResolveValue("max_ammo"))
    local raw = table.copy(args)
    raw.weapon = weapon
    raw.num_shots = total
    ---- the unit faces the cone axis; per-target args ride in results.attacks_args
    local main = unit:PrepareAttackArgs(self.id, raw)
    main.target_pos = main.target_pos or raw.target:GetPos()

    local targets = Rat_BulletHellTargets(unit, weapon, main.target_pos, main.step_pos, total)
    if #targets == 0 then
        return bh_empty_cone(self, unit, raw, weapon, total, main)
    end

    local auto = CombatActions[Rat_AutoAttackId(weapon)]
    local dmg_bonus = (auto.id == "AutoFire") and auto:ResolveValue("dmg_penalty") or 0
    local prediction = main.prediction
    local fired, jammed, condition, ammo_type = weapon:PrecalcAmmoUse(unit, total, prediction)

    local attacks, attacks_args, packets = {}, {}, {}
    for i, t in ipairs(targets) do
        local sub = table.copy(raw)
        sub.target = t.obj
        sub.target_pos = nil
        sub.lof = nil
        sub.target_spot_group = nil
        sub.step_pos = main.step_pos
        sub.aim = 0
        sub.num_shots = t.shots
        sub.multishot = true
        sub.damage_bonus = dmg_bonus
        sub.rat_ammo_precalc = {
            fired = fired and t.shots or false,
            jammed = jammed,
            condition = condition,
            ammo_type = ammo_type
        }
        local sub_args = unit:PrepareAttackArgs(auto.id, sub)
        attacks[i] = weapon:GetAttackResults(auto, sub_args)
        attacks_args[i] = sub_args
        packets[i] = {target = t.obj, effects = bh_status}
        ---- a jam stops the trigger pull on the first burst
        if not fired then
            break
        end
    end

    local results = MergeAttacks(attacks, attacks_args)
    if fired then
        results.extra_packets = packets
    end
    return results, main
end

---- vanilla UnitActions.lua BulletHellOverwriteShots, kept only for the empty-cone fallback: the
---- traversing bursts are real shots and must not be rotated after their hits were resolved
function BulletHellOverwriteShots(attack)
    if not attack.rat_bh_fan then
        return
    end
    local weapon = attack.weapon
    local halfAngle = DivRound(weapon.OverwatchAngle, 2)
    local newAngle = halfAngle
    local angleStep = MulDivRound(weapon.OverwatchAngle, 2, #attack.shots)
    for _, shot in ipairs(attack.shots) do
        shot.target_pos = RotateAxis(shot.target_pos, point(0, 0, 4069), newAngle, shot.attack_pos)
        shot.stuck_pos = RotateAxis(shot.stuck_pos, point(0, 0, 4069), newAngle, shot.attack_pos)
        if abs(newAngle) >= halfAngle then
            angleStep = -angleStep
        end
        newAngle = newAngle + angleStep
    end
end

function Rat_ApplyBulletHell()
    CombatActions.BulletHell.GetActionResults = bh_action_results
    local perk = CharacterEffectDefs.BulletHell
    if perk then
        perk.Description = T(482915370264,
                             "Sweep a long <em>autofire</em> burst across every visible enemy in the cone. Each enemy takes its own share of the rounds, and all of them are <GameTerm('Suppressed')> and sent <GameTerm('Prone')>.")
    end
end

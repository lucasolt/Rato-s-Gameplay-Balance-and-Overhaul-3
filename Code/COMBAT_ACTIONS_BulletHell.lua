---- Bullet Hell as an area sweep: the rounds are spread evenly across the cone at standing-torso
---- height and fired as real simulated bullets (shooter's own cone, one continuous recoil walk).
---- Whatever unit a bullet crosses is hit as an off-part hit; no damage bonus. Everyone in the cone
---- with line of fire is Suppressed and forced prone, as in vanilla.

local bh_status = {"Suppressed", "SuppressionChangeStance"}

local function valid_z(pt)
    return pt:IsValidZ() and pt or pt:SetTerrainZ()
end

---- the cone the aim UI draws (Targeting_AOE_Cone): radius is the cursor distance, clamped
local function bh_cone(unit, weapon, target_pos, step_pos)
    local aoe = weapon:GetAreaAttackParams("BulletHell", unit, target_pos, step_pos)
    local sp, tp = valid_z(step_pos), valid_z(target_pos)
    local range = Clamp(sp:Dist(tp), aoe.min_range * const.SlabSizeX,
                        aoe.max_range * const.SlabSizeX)
    return aoe, sp, tp, range
end

---- n aim points evenly across the arc (vanilla fan order, +half to -half), over the floor there
function Rat_BulletHellSweepPoints(unit, weapon, target_pos, step_pos, n)
    local aoe, sp, tp, range = bh_cone(unit, weapon, target_pos, step_pos)
    local axis = CalcOrientation(sp, tp)
    local half = aoe.cone_angle / 2
    local height = const.Combat.Autofire.BulletHellAimHeight
    local points = {}
    for i = 1, n do
        local angle = (n > 1) and (axis + half - MulDivRound(2 * half, i - 1, n - 1)) or axis
        local p = RotateRadius(range, angle, sp)
        local floor = GetPassSlab(p)
        local z = floor and valid_z(floor):z() or terrain.GetHeight(p)
        points[i] = p:SetZ(z + height)
    end
    return points
end

---- sim_ctx planner for rat_sweep (GetAttackResults): same scatter and recoil walk as
---- Rat_SimPlanShots, but the cone is the shooter's alone -- there is no target to resolve it against
function Rat_SweepPlanShots(ctx)
    local sweep = ctx.args.rat_sweep
    local attacker, weapon = ctx.attacker, ctx.weapon
    local auto = sweep.crit_action
    local sigma = Rat_GetAperture(weapon, attacker, auto, 0, false)
    if not sigma or sigma < 1 then
        return nil
    end
    local cone = {rat_sigma = sigma, rat_vsigma = Rat_RecoilPersistSigma(attacker, auto, weapon, 0)}
    local sigma_y, sigma_y_dn = Rat_ConeSigmaY(cone)
    local fan = Rat_ConeFanX(cone)
    ctx.sigma, ctx.sigma_y, ctx.sigma_y_dn, ctx.fan, ctx.vsigma = sigma, sigma_y, sigma_y_dn, fan,
                                                                  cone.rat_vsigma

    local n = #sweep.points
    local prof = (n > 1) and Rat_RecoilProfile(attacker, auto, weapon, n) or nil
    local st = prof and Rat_RecoilState() or nil
    local rnd = function(k)
        return attacker:Random(k)
    end
    local attack_pos = Rat_ValidZ(ctx.attack_pos)
    local shots = {}
    for i = 1, n do
        local aim = Rat_ValidZ(sweep.points[i])
        local lat, mu = 0, 0
        if st then
            lat, mu = Rat_RecoilPoint(st)
            local axis = Rat_RecoilWalkAxis(attacker, attack_pos, aim)
            local lat_axis = Rat_RecoilLateralAxis(axis, SetLen(aim - attack_pos, 1000))
            aim = Rat_RecoilWalkPoint(attack_pos, aim, axis, mu, lat_axis, lat)
        end
        shots[i] = {
            sigma = sigma,
            mu = mu,
            lat = lat,
            target_pos = Rat_ShotScatterPoint(attacker, attack_pos, aim, sigma, sigma_y, sigma_y_dn,
                                              fan)
        }
        if st then
            Rat_RecoilStep(prof, st, rnd)
        end
    end
    if st then
        Rat_RecoilPersistStash(attacker, st)
    end
    ctx.recoil, ctx.num_shots, ctx.shots = prof, n, shots
    return shots
end

---- the unit the bullet reached first; it becomes that shot's target
function Rat_SweepFirstUnit(hit_data, attacker)
    local from = hit_data.attack_pos
    local best, best_d
    for _, h in ipairs(hit_data.hits or empty_table) do
        local obj = h.obj
        if IsKindOf(obj, "Unit") and obj ~= attacker and not obj:IsDead() then
            local d = (from and h.pos) and from:Dist(h.pos) or 0
            if not best or d < best_d then
                best, best_d = obj, d
            end
        end
    end
    return best
end

local function bh_action_results(self, unit, args)
    ---- the cone aim shows no damage or CTH for this action; only the committed attack resolves
    if args.prediction ~= false then
        return {}, args
    end
    local weapon = args.weapon or self:GetAttackWeapons(unit, args)
    local total = Clamp(weapon.ammo.Amount, self:ResolveValue("min_ammo"),
                        self:ResolveValue("max_ammo"))
    local raw = table.copy(args)
    raw.weapon = weapon
    raw.num_shots = total
    raw.multishot = true
    raw.damage_bonus = 0
    local attack_args = unit:PrepareAttackArgs(self.id, raw)
    local target_pos = attack_args.target_pos or raw.target:GetPos()
    attack_args.rat_sweep = {
        points = Rat_BulletHellSweepPoints(unit, weapon, target_pos, attack_args.step_pos, total),
        crit_action = CombatActions[Rat_AutoAttackId(weapon)]
    }
    local results = weapon:GetAttackResults(self, attack_args)

    if results.fired then
        local _, sp, tp, range = bh_cone(unit, weapon, target_pos, attack_args.step_pos)
        local aoe = weapon:GetAreaAttackParams(self.id, unit, target_pos, attack_args.step_pos)
        local objs, los = GetAreaAttackTargets(sp, aoe.stance or unit.stance, false, range, 0,
                                               aoe.cone_angle, tp, unit:GetOccupiedPos(), true)
        results.extra_packets = results.extra_packets or {}
        for i, obj in ipairs(objs) do
            if IsKindOf(obj, "Unit") and obj ~= unit and not obj:IsDead() and (los[i] or 0) > 0 then
                table.insert(results.extra_packets, {target = obj, effects = bh_status})
            end
        end
    end
    return results, attack_args
end

---- vanilla rotates the shots after their hits were resolved; the sweep plans real directions instead
function BulletHellOverwriteShots(attack)
end

function Rat_ApplyBulletHell()
    CombatActions.BulletHell.GetActionResults = bh_action_results
    local perk = CharacterEffectDefs.BulletHell
    if perk then
        perk.Description = T(482915370264,
                             "Sweep a long <em>autofire</em> burst evenly across the cone at torso height. Anyone the bullets cross is hit, and everyone in the cone is <GameTerm('Suppressed')> and sent <GameTerm('Prone')>.")
    end
end

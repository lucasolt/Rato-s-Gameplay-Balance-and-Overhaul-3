local debug = false

function OnMsg.ClassesGenerate()
    AppendClass.FirearmProperties = {
        properties = {
            {
                category = "Caliber",
                id = "NumPellets",
                name = "Number of Pellets",
                help = "Pellets shot in a buckshot attack",
                editor = "number",
                default = 0,
                template = true,
                min = 0,
                max = 50,
                modifiable = true
            }, {
                category = "Caliber",
                id = "VerticalPelletSpreadFactorMul",
                name = "VerticalPelletSpreadFactorMul",
                help = "VerticalPelletSpreadFactorMul",
                editor = "number",
                default = 100,
                template = true,
                min = 0,
                max = 200,
                modifiable = true
            }
        }
    }
    Shotgun.NumPellets = 10
    Shotgun.ImpactForce = -1
end

function IsSlugLoaded(weapon)
    if weapon and IsKindOf(weapon, "Shotgun") and weapon.NumPellets < 1 then
        return true
    end
    return false
end

function Firearm:GetNumPellets(unit, action_id)
    return 0
end

function Shotgun:GetNumPellets(unit, action_id)
    local action_id = action_id or ''
    local pellets = self.NumPellets or 1
    pellets = Max(1, pellets)
    local action = action_id and CombatActions[action_id]
    local mul = action and action:ResolveValue("bullets") or 1
    pellets = pellets * mul
    return pellets
end

---- Scatter geometry shared by the shot and Rat_ExpectedPelletsOnTarget: pellet offsets are drawn
---- with radius uniform in [min_offset, scatter], measured at `range` along the main pellet's line.
function Rat_PelletScatterRadii(weapon, cone_angle)
    local range = weapon.WeaponRange * const.SlabSizeX
    local min_offset = 35 * guic
    local scatter_range = 20 * const.SlabSizeX
    local scatter = Max(min_offset, MulDivRound(scatter_range, sin(cone_angle / 2),
                                                Max(1, cos(cone_angle / 2))))
    return range, min_offset, scatter
end

---------------------------------------------------------------------------------------------------
---- Expected pellets on the target per shell, x100, main pellet included, GIVEN the main pellet
---- lands on the aimed spot. Pure (no Random, no LoF), so the AI can ask it per destination.
---- Deterministic 8x4 grid over the same (theta, radius) draw as GetPelletScatterData, tested
---- against the target's angular extents (Rat_TargetExtents, cover ignored). Pellets are all or
---- nothing for slugs: parallel slugs fly together.
---------------------------------------------------------------------------------------------------
function Rat_ExpectedPelletsOnTarget(attacker, weapon, action, target, attacker_pos, spot, cone_angle)
    local pellets = weapon:GetNumPellets(attacker, action and action.id) or 0
    if pellets <= 1 or IsSlugLoaded(weapon) then
        return Max(1, pellets) * 100
    end
    attacker_pos = attacker_pos or attacker:GetPos()
    if not cone_angle then
        local aoe = weapon:GetAreaAttackParams(action.id, attacker, target:GetPos())
        cone_angle = aoe and aoe.cone_angle
    end
    local up, down, right, left = Rat_TargetExtents(attacker_pos, target, spot or "Torso", 100)
    if not up or not cone_angle then
        return pellets * 100
    end
    local range, min_offset, scatter = Rat_PelletScatterRadii(weapon, cone_angle)
    local var_offset = Max(0, scatter - min_offset)
    local vf = weapon.VerticalPelletSpreadFactorMul or 100
    local thetas, radii = 8, 4
    local inside = 0
    for ti = 0, thetas - 1 do
        local theta = MulDivRound(360 * 60, 2 * ti + 1, 2 * thetas)
        local s, c = sin(theta), cos(theta)
        for ri = 0, radii - 1 do
            local radius = min_offset + MulDivRound(var_offset, 2 * ri + 1, 2 * radii)
            local off = MulDivRound(radius, 3438, Max(1, range)) ---- arcminutes
            local dx = MulDivRound(off, s, 4096)
            local dy = MulDivRound(MulDivRound(off, c, 4096), vf, 100)
            if dx >= -left and dx <= right and dy >= -down and dy <= up then
                inside = inside + 1
            end
        end
    end
    return 100 + MulDivRound((pellets - 1) * 100, inside, thetas * radii)
end

function Firearm:GetPelletScatterData(attacker, action, attack_pos, target_pos, num_vectors,
                                      aoe_params, attack_results, shot_attack_args)

    if num_vectors < 1 then
        return {}
    end
    aoe_params = aoe_params or self:GetAreaAttackParams(action.id, attacker, target_pos)
    local dir = SetLen(target_pos - attack_pos, guim)
    local max_angle_offset = 360 * 60
    local range, min_offset, scatter = Rat_PelletScatterRadii(self, aoe_params.cone_angle)
    local var_offset = Max(0, scatter - min_offset)

    local targets = {}
    target_pos = attack_pos + SetLen(dir, range)

    --------------------------------

    local function generate_pos(theta, radius, dir, attack_pos, range, cone_edge)

        local offset = RotateAxis(point(0, 0, radius), dir, theta)
        if (self.VerticalPelletSpreadFactorMul or 100) ~= 100 then
            offset = offset:SetZ(MulDivRound(offset:z(), self.VerticalPelletSpreadFactorMul, 100))
        end
        local pt = target_pos + offset

        local test_dir = pt - attack_pos

        local end_point = attack_pos + SetLen(test_dir, range + scatter)

        if cone_edge then
            -- DbgAddCircle(pt, const.SlabSizeX / 10)
            DbgAddVector(attack_pos, end_point - attack_pos, const.clrWhite)
            -- local dbg_string = "sin: " .. string.format("%.2f", sin) .. " cos: " ..
            --                        string.format("%.2f", cos)
            local dbg_string = "{" .. string.format("%.2f", end_point:x()) .. " " ..
                                   string.format("%.2f", end_point:y()) .. " " ..
                                   string.format("%.2f", end_point:z()) .. "}"

            -- DbgAddText(dbg_string, end_point)
        end
        return end_point
    end

    for i = 1, num_vectors do
        local theta = attacker:Random(max_angle_offset)
        local radius = min_offset + attacker:Random(var_offset)
        targets[i] = generate_pos(theta, radius, dir, attack_pos, range)
        -- DbgAddVector(attack_pos, targets[i] - attack_pos, const.clrCyan)
    end

    if debug then
        local num_debug_vectors = 12
        for i = 1, num_debug_vectors do
            local theta = (max_angle_offset / num_debug_vectors) * i
            local radius = min_offset + var_offset
            local cone_edge_point = generate_pos(theta, radius, dir, attack_pos, range, true)
        end

    end
    --------------------------------

    -- local lof_params = shot_attack_args
    -- lof_params.ignore_colliders = nil

    -- lof_params.seed = attacker:Random()
    -- lof_params.range = range + scatter + guim

    local lof_args = PelletLoFArgs(attacker, attack_pos, range + scatter + guim)

    local shots_hit_data = {}

    for i, target in ipairs(targets) do
        local attack_data = GetLoFData(attacker, target, lof_args)
        local hit_data
        if attack_data then
            ----------
            if debug then
                for i, data in ipairs(attack_data) do
                    local lof_hits = data.lof and data.lof[1] and data.lof[1].hits
                    for _, hit in ipairs(lof_hits) do
                        local color = const.clrCyan
                        if (hit.obj or hit.terrain) then
                            color = IsKindOf(hit.obj, "Unit") and const.clrRed or color
                        end
                        DbgAddVector(attack_pos, hit.pos - attack_pos, color)
                    end
                end
            end
            ----------
            hit_data = PelletHitData(attack_data)
        end
        table.insert(shots_hit_data, hit_data)
    end

    return shots_hit_data
end

---- Slugs out of a multi-barrel shot: each one flies parallel to the main slug, one barrel apart.
function Firearm:GetParallelSlugData(attacker, attack_pos, main_end_pos, num_vectors, shot_args)
    if num_vectors < 1 then
        return {}
    end
    local dir = main_end_pos - attack_pos
    if dir:Len2D() < 1 then
        dir = RotateRadius(guim, attacker:GetAngle())
    end
    local spacing = (const.Weapons.DoubleBarrelSlugSpacing or 3) * guic
    local range = shot_args.range
    local shots_hit_data = {}
    for i = 1, num_vectors do
        local side = SetLen(point(-dir:y(), dir:x(), 0), spacing * i)
        local origin = attack_pos + side
        local lof_args = PelletLoFArgs(attacker, origin, range)
        ---- a slug penetrates and over-penetrates like the main shot, unlike a pellet
        lof_args.penetration_class = shot_args.penetration_class or 0
        lof_args.can_stuck_on_unit = shot_args.can_stuck_on_unit
        local attack_data = GetLoFData(attacker, origin + SetLen(dir, range), lof_args)
        shots_hit_data[i] = attack_data and PelletHitData(attack_data)
    end
    return shots_hit_data
end

function PelletHitData(attack_data)
    return attack_data.outside_attack_area_lof or attack_data.lof and attack_data.lof[1]
end

function PelletLoFArgs(attacker, attack_pos, range)
    local lof_args = {
        attack_pos = attack_pos,
        obj = attacker,
        output_collisions = true,
        range = range,
        seed = attacker:Random(),
        penetration_class = 0
    }
    lof_args.fire_relative_point_attack = false
    lof_args.clamp_to_target = true
    lof_args.extend_shot_start_to_attacker = false
    ---- vanilla's ricochet args say true; from the muzzle it lets point-blank pellets hit the shooter
    lof_args.can_hit_attacker = false
    lof_args.ignore_los = true
    lof_args.inside_attack_area_check = false
    lof_args.forced_hit_on_eye_contact = false
    lof_args.can_use_covers = false
    lof_args.emplacement_weapon = false
    lof_args.ignore_los = true
    lof_args.inside_attack_area_check = false
    lof_args.forced_hit_on_eye_contact = false
    lof_args.prediction = false
    lof_args.aimIK = false
    lof_args.can_stuck_on_unit = true
    return lof_args
end

---- Distance was 8 tiles / DoubleBarrelshotgun 

--- long barrel - -22% angle (78)
-- PelletDebugAverageValues()
-- =====  Number of shots:  10
-- Session ID: Flay
--   Average Damage: 45
--   Average Hits: 7
--   Average Bodypart Hits:
--      Torso : 5
--      Arms : 2
--      Head : 0
--
--
--- default barrel
-- PelletDebugAverageValues()
-- =====  Number of shots:  10
-- Session ID: Flay
--   Average Damage: 30
--   Average Hits: 5
--   Average Bodypart Hits:
--      Torso : 4
--      Arms : 1
--      Legs : 0
--
--
--- short barrel - 22% pellet angle inc
-- PelletDebugAverageValues()
-- =====  Number of shots:  10
-- Session ID: Flay
--   Average Damage: 25
--   Average Hits: 4
--   Average Bodypart Hits:
--      Head : 0
--      Arms : 0
--      Torso : 2
--      Legs : 1

---- Distance 12, default barrel

-- PelletDebugAverageValues()
-- =====  Number of shots:  12
-- Session ID: Flay
--   Average Damage: 17
--   Average Hits: 3
--   Average Bodypart Hits:
--      Head : 0
--      Arms : 0
--      Torso : 2
--      Legs : 0

---- distance 3

-- PelletDebugAverageValues()
-- =====  Number of shots:  10
-- Session ID: Flay
--   Average Damage: 59
--   Average Hits: 9
--   Average Bodypart Hits:
--      Torso : 9
--      Arms : 0

-- distance 10, fullchoke auto5 -- 2.80º
-- PelletDebugAverageValues()
-- =====  Number of shots:  4
-- Session ID: Flay
--   Average Damage per shot: 45
--   Average Hits per shot: 7
--   Average Bodypart Hits per shot:
--      Torso : 4
--      Arms : 2

--- no choke --- 4.67º
-- PelletDebugAverageValues()
-- =====  Number of shots:  4
-- Session ID: Flay
--   Average Damage per shot: 24
--   Average Hits per shot: 3
--   Average Bodypart Hits per shot:
--      Head : 0
--      Legs : 0
--      Arms : 0
--      Torso : 2

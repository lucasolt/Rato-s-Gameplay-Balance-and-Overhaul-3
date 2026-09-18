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

function Firearm:GetPelletScatterData(attacker, action, attack_pos, target_pos, num_vectors,
                                      aoe_params, attack_results, shot_attack_args)

    if num_vectors < 1 then
        return {}
    end
    aoe_params = aoe_params or self:GetAreaAttackParams(action.id, attacker, target_pos)
    local range = self.WeaponRange * const.SlabSizeX
    local dir = SetLen(target_pos - attack_pos, guim)

    local min_offset = 35 * guic
    ----
    local scatter_range = 20 * const.SlabSizeX -- range
    local max_angle_offset = 360 * 60
    ----
    local scatter = Max(min_offset, MulDivRound(scatter_range, sin(aoe_params.cone_angle / 2),
                                                Max(1, cos(aoe_params.cone_angle / 2))))

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

    local lof_args = {
        attack_pos = attack_pos,
        obj = attacker,
        output_collisions = true,
        range = range + scatter + guim,
        seed = attacker:Random(),
        penetration_class = 0
    }
    lof_args.fire_relative_point_attack = false
    lof_args.clamp_to_target = true
    lof_args.extend_shot_start_to_attacker = false
    lof_args.can_hit_attacker = true
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
            local lof_idx
            ---- Not sure if should check for spot group
            -- lof_idx = lof_idx or
            -- 			  table.find(attack_data.lof, "target_spot_group",
            -- 						 shot_attack_args.target_spot_group)
            hit_data = attack_data.outside_attack_area_lof or attack_data.lof and
                           attack_data.lof[lof_idx or 1]
            -- 

        end
        table.insert(shots_hit_data, hit_data)
    end

    return shots_hit_data
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

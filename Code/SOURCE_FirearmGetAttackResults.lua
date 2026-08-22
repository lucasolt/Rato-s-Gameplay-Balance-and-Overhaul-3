local compile_ignore_colliders = function(killed_colliders, colliders)
    if #(killed_colliders or empty_table) == 0 then
        return colliders
    end
    local list = table.icopy(killed_colliders)
    if IsValid(colliders) then
        table.insert_unique(list, colliders)
    else
        for _, obj in ipairs(colliders) do
            table.insert_unique(list, obj)
        end
    end
    return list
end

local find_first_hit = function(attack_results, hit_obj)
    for si, shot in ipairs(attack_results.shots) do
        for hi, hit in ipairs(shot.hits) do
            if hit.obj == hit_obj then
                return hit
            end
        end
    end
end

---- ok 1.5

function Firearm:GetAttackResults(action, attack_args)
    -- unpack some params & init default values

    local attacker = attack_args.obj
    local anim = attack_args.anim
    local prediction = attack_args.prediction
    local lof_idx = table.find(attack_args.lof, "target_spot_group",
                               attack_args.target_spot_group or "Torso")
    local lof_data = attack_args.lof and attack_args.lof[lof_idx or 1]

    local target = attack_args.target or lof_data.target_pos
    local target_pos = lof_data.target_pos or (IsValid(target) and target:GetPos())
    if not target_pos:IsValidZ() then
        target_pos = target_pos:SetTerrainZ()
    end
    local target_unit = IsKindOf(target, "Unit") and target
    local aoe_target_pos = target_unit and target_unit:GetPos() or target_pos -- target_pos is where the shot lands. For AOE attacks we want the object position.
    assert(target)
    assert(target_pos)

    local num_shots = attack_args.num_shots or 0
    local aoe_params = attack_args.aoe_params or (attack_args.aoe_action_id and
                           self:GetAreaAttackParams(attack_args.aoe_action_id, attacker,
                                                    aoe_target_pos, attack_args.step_pos))
    local consumed_ammo = attack_args.consumed_ammo
    if not consumed_ammo then
        consumed_ammo = 1
        consumed_ammo = Max(consumed_ammo, num_shots)
        consumed_ammo = Max(consumed_ammo, aoe_params and aoe_params.used_ammo or 0)
    end

    if action.id == "BulletHell" then
        target_pos = attack_args.step_pos +
                         SetLen2D((target_pos - attack_args.step_pos):SetZ(0),
                                  aoe_params.max_range * const.SlabSizeX)
        if not target_pos:IsValidZ() then
            target_pos = target_pos:SetTerrainZ()
            target = target_pos
        end
    end

    local shot_attack_args = table.copy(attack_args)
    shot_attack_args.num_shots = num_shots
    shot_attack_args.target_pos = target_pos
    shot_attack_args.target_spot_group = shot_attack_args.target_spot_group or target_unit and
                                             g_DefaultShotBodyPart
    shot_attack_args.aim = shot_attack_args.aim or 0
    shot_attack_args.damage_bonus = shot_attack_args.damage_bonus or 0
    shot_attack_args.cth_loss_per_shot = shot_attack_args.cth_loss_per_shot or 0
    shot_attack_args.stealth_kill_chance = shot_attack_args.stealth_kill_chance or 0
    shot_attack_args.stealth_bonus_crit_chance = shot_attack_args.stealth_bonus_crit_chance or 0
    shot_attack_args.prediction = prediction
    shot_attack_args.occupied_pos = shot_attack_args.occupied_pos or attacker:GetOccupiedPos()
    shot_attack_args.can_use_covers = false
    shot_attack_args.output_collisions = true
    shot_attack_args.additional_colliders = target -- Non-units (such as mines) need to be added manually.
    shot_attack_args.require_los = nil

    -----------------------------------
    if attack_args.action_id == "PinDown" then
        local _, max_aim = attack_args.obj:GetBaseAimLevelRange(CombatActions["PinDown"],
                                                                attack_args.target)
        shot_attack_args.aim = Max(shot_attack_args.aim, max_aim)
        shot_attack_args.opportunity_attack = false
    end
    -----------------------------------

    local fired, jammed, condition, ammo_type = self:PrecalcAmmoUse(attacker, consumed_ammo,
                                                                    prediction)
    if type(fired) == "number" and num_shots > 0 then
        num_shots = Min(fired, num_shots)
        shot_attack_args.num_shots = fired
    end

    local cth, baseCth, modifiers
    local cth_action = shot_attack_args.used_action_id and
                           CombatActions[shot_attack_args.used_action_id] or action
    if action.AlwaysHits then
        cth = 100
    elseif attack_args.chance_to_hit then
        cth, modifiers = attack_args.chance_to_hit, attack_args.chance_to_hit_modifiers
    else
        cth, baseCth, modifiers = attacker:CalcChanceToHit(target, cth_action, shot_attack_args)
    end

    local attack_results = {
        weapon = self,
        fired = fired,
        jammed = jammed,
        condition = condition,
        chance_to_hit = cth,
        chance_to_hit_modifiers = modifiers,
        stealth_attack = shot_attack_args.stealth_attack,
        stealth_kill_chance = shot_attack_args.stealth_kill_chance,
        attack_roll = shot_attack_args.attack_roll,
        crit_roll = shot_attack_args.crit_roll,
        ammo_type = ammo_type,
        aim = shot_attack_args.aim,
        dmg_breakdown = shot_attack_args.damage_breakdown and {} or false
    }

    attack_results.crit_chance = attacker:CalcCritChance(self, target, action, shot_attack_args,
                                                         shot_attack_args.step_pos)

    -- attack/crit rolls
    if prediction then
        if shot_attack_args.multishot then
            attack_results.attack_roll = {}
            attack_results.crit_roll = {}
            for i = 1, num_shots do
                attack_results.attack_roll[i] = 0
                attack_results.crit_roll[i] = 101
            end
        else
            attack_results.attack_roll = 0
            attack_results.crit_roll = 101
        end

        if shot_attack_args.stealth_kill_chance > 0 then
            shot_attack_args.stealth_kill_roll = 101
        end
    else
        if shot_attack_args.multishot then
            if type(attack_results.attack_roll) ~= "table" then
                attack_results.attack_roll = {}
                for i = 1, num_shots do
                    attack_results.attack_roll[i] = 1 + attacker:Random(100)
                end
            end
            if type(attack_results.crit_roll) ~= "table" then
                attack_results.crit_roll = {}
                for i = 1, num_shots do
                    attack_results.crit_roll[i] = 1 + attacker:Random(100)
                end
            end
        else
            attack_results.attack_roll = shot_attack_args.attack_roll or (1 + attacker:Random(100))
            attack_results.crit_roll = shot_attack_args.crit_roll or (1 + attacker:Random(100))
        end
        if shot_attack_args.stealth_kill_chance > 0 then
            shot_attack_args.stealth_kill_roll = shot_attack_args.stealth_kill_roll or
                                                     (1 + attacker:Random(100))
        end
    end

    -- direct shots
    local step_pos3D = shot_attack_args.step_pos:IsValidZ() and shot_attack_args.step_pos or
                           shot_attack_args.step_pos:SetTerrainZ()
    local distAttackerToTarget = step_pos3D:Dist(target_pos)
    local dispersion = self:GetMaxDispersion(distAttackerToTarget)
    local max_range = shot_attack_args.range
    local point_blank = not prediction and attacker:IsPointBlankRange(target) -- ignore this on prediction to avoid step_pos (CalcShotVectors isn't used on prediction anyway)
    if not max_range then
        max_range = Max(MulDivRound(self.WeaponRange, 150, 100), 20) * const.SlabSizeX
    end
    max_range = Max(max_range, distAttackerToTarget + const.SlabSizeX)
    if not prediction then
        max_range = Max(max_range, 100 * const.SlabSizeX)
    end
    shot_attack_args.range = max_range

    local stealth_kill
    local roll = attack_results.attack_roll
    local miss, crit
    if shot_attack_args.multishot then
        miss, crit = true, false -- initial values, actual calculation will happen below based on shot results
    else
        crit = attack_results.crit_roll <= attack_results.crit_chance
        miss = roll > attack_results.chance_to_hit
    end

    local target_hit = false
    local out_of_range = true

    local num_hits, total_damage, friendly_fire_dmg, hit_objs = 0, 0, 0, {}
    local unit_damage = {}

    if not miss and shot_attack_args.stealth_kill_chance > 0 then
        stealth_kill = shot_attack_args.stealth_kill_roll <= shot_attack_args.stealth_kill_chance
    end

    local shot_lof_data = shot_attack_args.lof and shot_attack_args.lof[1]
    attack_results.step_pos = shot_lof_data and shot_lof_data.step_pos or shot_attack_args.step_pos
    attack_results.lof_pos1 = shot_lof_data and shot_lof_data.lof_pos1 or attack_results.step_pos -- segment start point (unit center)
    attack_results.attack_pos = shot_lof_data and shot_lof_data.attack_pos or
                                    attack_results.step_pos -- weapon shot pos
    attack_results.shots = {}
    attack_results.hit_objs = hit_objs
    attack_results.stealth_kill = stealth_kill
    attack_results.clear_attacks = 0

    -- count num hits and misses and precalc shot vectors for them
    local sfHit = 0x10000
    local sfCrit = 0x20000
    local sfLeading = 0x40000
    local sfAllowGrazing = 0x80000
    local sfCthMask = 0xFF
    local sfRollMask = 0xFF00
    local sfRollOffset = 8
    local num_hits, num_misses, num_grazing = 0, 0, 0
    local shots_data = {}
    -- local graze_threshold = point_blank and 6 or 3

    ----------------------------------------
    local pellet_count = self:GetNumPellets(attacker, action and action.id) or 0
    local is_pellet_shot = pellet_count > 0 and not attack_args.prediction

    local graze_threshold = is_pellet_shot and const.Combat.PelletShotGrazeThreshold or num_shots >
                                1 and const.Combat.MultishotGrazeThreshold or
                                const.Combat.SingleShotGrazeThreshold
    local aim_cth = 0
    if num_shots > 1 and not prediction then
        local weapon = attack_args.weapon or attacker:GetActiveWeapons()

        local recoil = get_recoil(attacker, target, target_pos, action, weapon, false, num_shots) or
                           0

        for i, v in ipairs(modifiers or empty_table) do
            if v.id == "Aim" then
                aim_cth = v.value
                break
            end
        end

        shot_attack_args.cth_loss_per_shot = -recoil
    end
    ----------------------------------------------------------

    for i = 1, num_shots do
        local shot_miss, shot_crit, shot_cth
        ------------- max 6 i
        local original_cth = self:GetShotChanceToHit(attack_results.chance_to_hit) or 0
        shot_cth = original_cth - shot_attack_args.cth_loss_per_shot *
                       Min((i - 1), const.Combat.MaxShotIndexForRecoilCTHLoss)

        if i > 1 then
            shot_cth = shot_cth - aim_cth
        end
        ----------------^^

        shot_cth = attacker:CallReactions_Modify("OnCalcShotChanceToHit", shot_cth, attacker,
                                                 target, i, num_shots)

        if target_unit then
            shot_cth = target_unit:CallReactions_Modify("OnCalcShotChanceToHit", shot_cth, attacker,
                                                        target, i, num_shots)
        end

        ------
        shot_cth = Clamp(shot_cth, 0, 100)
        local min_chance = Min(const.Combat.MultishotMinCTH, original_cth)
        shot_cth = Max(shot_cth, min_chance)
        --------^^

        if shot_attack_args.multishot then
            roll = attack_results.attack_roll[i]
            shot_miss = roll > shot_cth
            shot_crit = (not shot_miss) and
                            (attack_results.crit_roll[i] <= attack_results.crit_chance)
            -- update global miss/crit for the attack
            miss = miss and shot_miss
            crit = crit or shot_crit
        else
            shot_miss = (not stealth_kill or i > 1) and roll > shot_cth
            shot_crit = crit and (i == 1)
        end
        local data = band(shot_cth, sfCthMask)
        data = bor(data, band(shift(roll, sfRollOffset), sfRollMask))
        data = bor(data, shot_miss and 0 or sfHit)
        data = bor(data, shot_crit and sfCrit or 0)
        data = bor(data, (shot_attack_args.multishot or (i == 1)) and sfLeading or 0)
        if shot_miss and shot_cth > 0 then
            local shot_graze_threshold = self:GetShotGrazeTheshold(graze_threshold)
            shot_graze_threshold = attacker:CallReactions_Modify("OnCalcShotGrazeThreshold",
                                                                 shot_graze_threshold, attacker,
                                                                 target, i, num_shots)
            if target_unit then
                shot_graze_threshold = target_unit:CallReactions_Modify("OnCalcShotGrazeThreshold",
                                                                        shot_graze_threshold,
                                                                        attacker, target, i,
                                                                        num_shots)
            end
            if roll < shot_cth + shot_graze_threshold then
                data = bor(data, sfAllowGrazing)
                num_grazing = num_grazing + 1
            end
        end
        shots_data[i] = data
        num_hits = num_hits + (shot_miss and 0 or 1)
        num_misses = num_misses + (shot_miss and 1 or 0)
        if not prediction then
            NetUpdateHash("FirearmShot", attacker, target, shot_attack_args.action_id,
                          shot_attack_args.stance, self.class, self.id,
                          self == shot_attack_args.weapon, shot_attack_args.occupied_pos,
                          shot_attack_args.step_pos, shot_attack_args.angle, shot_attack_args.anim,
                          shot_attack_args.can_use_covers, shot_attack_args.ignore_smoke,
                          shot_attack_args.penetration_class, shot_attack_args.range, shot_cth,
                          roll, shot_miss)
        end
    end

    -- burst distribution simulation
    -----
    -- local pellets_data
    -----

    local precalc_shots, anyHitsTarget
    if not prediction then
        local hit_target_pts, miss_target_pts, disp_origin, disp_dir
        local lof_data
        if shot_lof_data then
            lof_data = shot_lof_data
        else
            lof_data = {target_pos = target_pos, lof_pos1 = attack_results.lof_pos1}
        end
        for i = 1, 20 do
            hit_target_pts, miss_target_pts, anyHitsTarget, disp_origin, disp_dir =
                self:CalcShotVectors(attacker, action.id, target, shot_attack_args, lof_data,
                                     20 * guic, guim, guim, num_hits, num_misses, num_grazing)
            if (#hit_target_pts + #miss_target_pts) >= (num_hits + num_misses) then
                break
            end
        end

        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        local point_target, point_lof
        local color = const.clrWhite
        if #hit_target_pts > 0 then
            point_target, point_lof = hit_target_pts[1].target_pos, hit_target_pts[1].lof_pos1
            color = const.clrGreen
        elseif #miss_target_pts > 0 then
            point_target, point_lof = miss_target_pts[1].target_pos, miss_target_pts[1].lof_pos1
            color = const.clrRed
        else
            point_target = target_pos
        end

        if point_target then
            -- DbgAddCircle(point_target, const.SlabSizeX / 6, color)
            -- DbgAddVector(point_target, attack_results.attack_pos - point_target, color)
        end

        -- if  (self.NumPellets or 0) > 0 and not attack_args.prediction then
        --     pellets_data = self:CalcBuckshotScatter(attacker, action, attack_results.attack_pos,
        --                                             point_target,
        --                                             shot_attack_args.buckshot_scatter_fx,
        --                                             aoe_params, attack_results, shot_attack_args)

        -- end
        -----------
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        -- use old code as fallback in case all 20 tries have failed (this shouldn't really happen)	
        if (#hit_target_pts + #miss_target_pts) < (num_hits + num_misses) then
            -- assert(false, "simulated burst distribition precomputation failed, falling back to randomized miss vectors")
        else
            -- assign target points to shots based on desired outcome
            precalc_shots = {}
            --[[local lowest
			for i = 1, num_shots do
				local shot_miss = band(shots_data[i], sfHit) == 0
				local target_tbl = shot_miss and miss_target_pts or hit_target_pts
				local shot_vector = table.remove(target_tbl)
				local target_pos = shot_vector.target_pos
				precalc_shots[i] = { lof_pos1 = shot_vector.lof_pos1, attack_pos = shot_vector.attack_pos, target_pos = target_pos, shot_data = shots_data[i], shot_idx = i }
				if not lowest or (lowest:z() > target_pos:z()) then
					lowest = target_pos
				end
			end
			
			table.sort(precalc_shots, function(a, b) return a.target_pos:Dist(lowest) < b.target_pos:Dist(lowest) end)--]]
            for i = 1, num_shots do
                local shot_miss = band(shots_data[i], sfHit) == 0
                local allow_grazing = band(shots_data[i], sfAllowGrazing) ~= 0
                local shot_vector
                if shot_miss then
                    if allow_grazing then
                        local idx = table.find(hit_target_pts, "accurate", false)
                        if idx then
                            shot_vector = table.remove(hit_target_pts, idx)
                        end
                    end
                    if not shot_vector then
                        shot_vector = table.remove(miss_target_pts)
                    end
                    if not shot_vector then -- fallback
                        shot_vector = table.remove(hit_target_pts)
                    end
                else
                    local idx = table.find(hit_target_pts, "accurate", true)
                    shot_vector = table.remove(hit_target_pts, idx)
                    if not shot_vector then -- fallback
                        shot_vector = table.remove(miss_target_pts)
                    end
                end

                local shot_target_pos = shot_vector.target_pos
                local shot_attack_pos = shot_vector.attack_pos
                local t_offset = shot_target_pos - disp_origin
                precalc_shots[i] = {
                    lof_pos1 = shot_vector.lof_pos1,
                    attack_pos = shot_attack_pos,
                    target_pos = shot_target_pos,
                    shot_data = shots_data[i],
                    shot_idx = i,
                    dispersion = shot_vector.idx
                } -- Dot(t_offset, disp_dir) }
            end
            table.sort(precalc_shots, function(a, b)
                return a.dispersion < b.dispersion
            end)

        end
    end

    local misses
    local precalc_damage_data = {}
    local killed_colliders = {}

    for i = 1, num_shots do
        -- clear dead collide units
        local precalc_shot = precalc_shots and precalc_shots[i]
        local shot_data = precalc_shot and precalc_shot.shot_data or shots_data[i]

        local shot_cth, shot_miss, shot_crit, allow_grazing
        shot_cth = band(shot_data, sfCthMask)
        shot_miss = band(shot_data, sfHit) == 0
        shot_crit = band(shot_data, sfCrit) ~= 0
        allow_grazing = band(shot_data, sfAllowGrazing) ~= 0
        roll = shift(band(shot_data, sfRollMask), -sfRollOffset)
        local leading_shot = band(shots_data[i], sfLeading) ~= 0
        local dmg_target = (leading_shot and not shot_miss) and target or false

        local attack_data, miss_target_pos, hit_data
        if precalc_shot then
            shot_attack_args.attack_pos = precalc_shot.attack_pos
            shot_attack_args.seed = attacker:Random()
            shot_attack_args.ignore_los = attack_args.ignore_los
            shot_attack_args.inside_attack_area_check = attack_args.inside_attack_area_check
            shot_attack_args.forced_hit_on_eye_contact = attack_args.forced_hit_on_eye_contact
            local shot_target
            if shot_miss then
                shot_target = precalc_shot.target_pos
                miss_target_pos = precalc_shot.target_pos
                if not allow_grazing then
                    shot_attack_args.ignore_colliders =
                        compile_ignore_colliders(killed_colliders, target_unit)
                end
                shot_attack_args.ignore_los = true
                shot_attack_args.inside_attack_area_check = false
                shot_attack_args.forced_hit_on_eye_contact = false
            else
                shot_target = attack_args.target_dummy or (IsValid(target) and target) or
                                  precalc_shot.target_pos
                shot_attack_args.ignore_colliders =
                    compile_ignore_colliders(killed_colliders, attack_args.ignore_colliders)
            end
            attack_data = GetLoFData(attacker, shot_target, shot_attack_args)
        elseif shot_miss then
            if not prediction then -- don't simulate misses for prediction, dispersion uses synced random and executing it from UI code will desync		
                local lof_idx = table.find(shot_attack_args.lof, "target_spot_group",
                                           shot_attack_args.target_spot_group)
                local lof_data = shot_attack_args.outside_attack_area_lof or
                                     shot_attack_args.lof[lof_idx or 1]
                local lof_pos1 = lof_data.lof_pos1
                while not misses or (#misses.clear + #misses.obstructed == 0) do
                    misses = self:CalcMissVectors(attacker, action.id, target, lof_pos1,
                                                  lof_data.target_pos, dispersion)
                    dispersion = dispersion + 20 * guic -- try shooting wider next time to avoid infinitely retrying to find miss vectors very close to the target
                end
                miss_target_pos = self:PickMissTargetPos(attacker, misses, roll, shot_cth)
                -- extend the shot vector to the max range to make sure the bullet doesn't despawn right after passing by the missed target
                local v = miss_target_pos - lof_pos1
                miss_target_pos = lof_pos1 + SetLen(v, max_range - const.SlabSizeX)
                shot_attack_args.fire_relative_point_attack = false
                shot_attack_args.ignore_colliders =
                    compile_ignore_colliders(killed_colliders, target_unit)
                shot_attack_args.seed = attacker:Random()
                shot_attack_args.ignore_los = true
                shot_attack_args.inside_attack_area_check = false
                shot_attack_args.forced_hit_on_eye_contact = false
                attack_data = GetLoFData(attacker, miss_target_pos, shot_attack_args)
            end
        else
            shot_attack_args.fire_relative_point_attack = attack_args.fire_relative_point_attack
            shot_attack_args.ignore_colliders = compile_ignore_colliders(killed_colliders,
                                                                         attack_args.ignore_colliders)
            local target_dummy = attack_args.target_dummy or target
            shot_attack_args.seed = prediction and 0 or attacker:Random()
            shot_attack_args.ignore_los = attack_args.ignore_los
            shot_attack_args.inside_attack_area_check = attack_args.inside_attack_area_check
            shot_attack_args.forced_hit_on_eye_contact = attack_args.forced_hit_on_eye_contact
            attack_data = GetLoFData(attacker, target_dummy, shot_attack_args)
        end

        if attack_data then
            local lof_idx
            lof_idx = lof_idx or
                          table.find(attack_data.lof, "target_spot_group",
                                     shot_attack_args.target_spot_group)
            hit_data = attack_data.outside_attack_area_lof or attack_data.lof and
                           attack_data.lof[lof_idx or 1]
        else
            local lof_idx = table.find(shot_attack_args.lof, "target_spot_group",
                                       shot_attack_args.target_spot_group)
            local lof_data = shot_attack_args.outside_attack_area_lof or
                                 shot_attack_args.lof[lof_idx or 1]
            hit_data = {
                obj = attacker,
                hits = empty_table,
                target_pos = miss_target_pos or lof_data.target_pos,
                attack_pos = lof_data.attack_pos
            }
        end

        -- Only used for logging, the modifier isn't displayed anywhere as the
        -- crosshair uses another check.
        if not shot_miss and
            ((not precalc_shots and hit_data.stuck) or (precalc_shots and not anyHitsTarget)) then
            attack_results.chance_to_hit = 0
            attack_results.obstructed = true
            local mods = attack_results.chance_to_hit_modifiers or {}
            mods[#mods + 1] = {
                {id = "NoLineOfFire", name = T(604792341662, "No Line of Fire"), value = 0}
            }
        end

        -- if not shot_attack_args.lof and not aoe_params or not fired or jammed or shot_attack_args.chance_only then
        if not fired or jammed or
            (shot_attack_args.chance_only and not shot_attack_args.damage_breakdown) then
            return attack_results
        end

        hit_data.target = dmg_target

        hit_data.critical = shot_crit
        hit_data.record_breakdown = i == 1 and attack_results.dmg_breakdown or false -- Record mods of the first shot only.
        for k, v in pairs(shot_attack_args) do
            if not hit_data[k] then
                hit_data[k] = v
            end
        end

        if shot_miss and IsValid(target) then
            for _, hit in ipairs(hit_data.hits) do
                if hit.obj == target then
                    if allow_grazing then
                        hit.grazing = true
                        hit.grazed_miss = true
                    else
                        hit.stray = true
                    end
                end
            end
        end

        self:BulletCalcDamage(hit_data)

        if shot_attack_args.chance_only then
            return attack_results
        end -- Quick out to avoid calculating other shots when we only wanted the dmg breakdown.

        -- gather hit stats for logging
        local shot_target_hit = false
        for _, hit in ipairs(hit_data.hits) do
            local hit_obj = hit.obj
            if IsKindOf(hit_obj, "Unit") and not hit_obj:IsDead() then
                num_hits = num_hits + 1
                if not hit_objs[hit_obj] then
                    hit_objs[#hit_objs + 1] = hit_obj
                    hit_objs[hit_obj] = true
                end

                if hit_obj == dmg_target and hit.grazing then
                    stealth_kill = false
                    shot_attack_args.stealth_kill_roll = -100
                end

                if stealth_kill and hit_obj == dmg_target then
                    hit.damage = MulDivRound(target:GetTotalHitPoints(), 125, 100)
                    hit.stealth_kill = true
                end
                total_damage = total_damage + hit.damage
                if not attacker:IsOnEnemySide(hit_obj) then
                    friendly_fire_dmg = friendly_fire_dmg + hit.damage
                end
                unit_damage[hit_obj] = (unit_damage[hit_obj] or 0) + hit.damage
                if hit_obj == target_unit then
                    shot_target_hit = true
                end
                if shot_attack_args.stealth_bonus_crit_chance > 0 and hit.critical then
                    hit.stealth_crit = true
                end
            elseif IsKindOf(hit_obj, "Trap") then
                if hit_obj == target then
                    shot_target_hit = true
                end
            end

            -- presim damage tracking
            if IsKindOf(hit_obj, "CombatObject") then
                local dmg_data = precalc_damage_data[hit_obj] or {}
                precalc_damage_data[hit_obj] = dmg_data
                local hp, temp_hp = hit_obj:PrecalcDamageTaken(hit.damage, dmg_data.hp,
                                                               dmg_data.temp_hp)
                dmg_data.hp = hp
                dmg_data.temp_hp = temp_hp
                if hp <= 0 then
                    table.insert_unique(killed_colliders, hit_obj)
                end
            elseif IsKindOfClasses(hit_obj, "Destroyable", "Trap") then
                table.insert_unique(killed_colliders, hit_obj)
            end
        end
        target_hit = target_hit or shot_target_hit
        out_of_range = out_of_range and attack_data.outside_attack_area

        --------
        local shot = {
            miss = shot_miss,
            cth = shot_cth,
            roll = roll,
            attack_pos = hit_data.attack_pos,
            target_pos = hit_data.target_pos,
            stuck_pos = hit_data.stuck_pos or hit_data.lof_pos2,
            hits = {},
            target_hit = shot_target_hit,
            out_of_range = attack_data.outside_attack_area,
            shot_target = not shot_miss and target_unit,
            allyHit = hit_data.allyHit,
            ammo_type = ammo_type,
            clear_attacks = hit_data.clear_attacks,
            -----------------------------------------------
            pellets = {}
            -----------------------------------------------
        }
        ---------

        attack_results.shots[i] = shot

        if hit_data.allyHit then
            if attack_results.allyHit and attack_results.allyHit ~= hit_data.allyHit then
                attack_results.allyHit = "multiple"
            else
                attack_results.allyHit = hit_data.allyHit
            end
        end
        attack_results.clear_attacks = attack_results.clear_attacks + (hit_data.clear_attacks or 0)
        --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        if is_pellet_shot then
            attack_results.is_pellet_attack = true
            attack_results.shots[i].main_pellet = true
            local main_pellet_target_pos = hit_data.stuck_pos or hit_data.lof_pos2 or
                                               hit_data.target_pos
            local pellet_data = self:GetPelletScatterData(attacker, action,
                                                          attack_results.attack_pos,
                                                          main_pellet_target_pos,
                                                          (pellet_count - 1), aoe_params,
                                                          attack_results, shot_attack_args)

            for p_i, pellet_hit_data in ipairs(pellet_data) do

                p_i = p_i + 1

                ----- strays are hardcoded -50% dmg, grazes use the constant (-70% dmg)
                if IsValid(target) then
                    for _, hit in ipairs(pellet_hit_data.hits) do
                        if hit.obj and hit.obj == target then
                            if shot_miss then
                                if false then -- allow_grazing then
                                    hit.grazing = true
                                    hit.grazed_miss = true
                                else
                                    hit.stray = true
                                end
                            else
                                hit.stray = false
                            end
                        else
                            hit.stray = true
                        end
                    end
                end

                ----- So that BulletCalcDamage doesnt reset our stray definition
                ----- GetPelletScatterData uses a point as target
                pellet_hit_data.target = target

                self:BulletCalcDamage(pellet_hit_data)
                local pellet_target_hit = false
                for _, hit in ipairs(pellet_hit_data.hits) do
                    local hit_obj = hit.obj
                    if IsKindOf(hit_obj, "Unit") and not hit_obj:IsDead() then
                        num_hits = num_hits + 1
                        if not hit_objs[hit_obj] then
                            hit_objs[#hit_objs + 1] = hit_obj
                            hit_objs[hit_obj] = true
                        end

                        -- if hit_obj == dmg_target and hit.grazing then
                        --     stealth_kill = false
                        --     shot_attack_args.stealth_kill_roll = -100
                        -- end

                        -- if stealth_kill and hit_obj == dmg_target then
                        --     hit.damage = MulDivRound(target:GetTotalHitPoints(), 125, 100)
                        --     hit.stealth_kill = true
                        -- end

                        total_damage = total_damage + hit.damage
                        if not attacker:IsOnEnemySide(hit_obj) then
                            friendly_fire_dmg = friendly_fire_dmg + hit.damage
                        end
                        unit_damage[hit_obj] = (unit_damage[hit_obj] or 0) + hit.damage
                        if hit_obj == target_unit then
                            -- shot_target_hit = true
                            pellet_target_hit = true
                        end
                        if shot_attack_args.stealth_bonus_crit_chance > 0 and hit.critical then
                            hit.stealth_crit = true
                        end
                    elseif IsKindOf(hit_obj, "Trap") then
                        if hit_obj == target then
                            -- shot_target_hit = true
                            pellet_target_hit = true
                        end
                    end

                    -- presim damage tracking
                    if IsKindOf(hit_obj, "CombatObject") then
                        local dmg_data = precalc_damage_data[hit_obj] or {}
                        precalc_damage_data[hit_obj] = dmg_data
                        local hp, temp_hp = hit_obj:PrecalcDamageTaken(hit.damage, dmg_data.hp,
                                                                       dmg_data.temp_hp)
                        dmg_data.hp = hp
                        dmg_data.temp_hp = temp_hp
                        if hp <= 0 then
                            table.insert_unique(killed_colliders, hit_obj)
                        end
                    elseif IsKindOfClasses(hit_obj, "Destroyable", "Trap") then
                        table.insert_unique(killed_colliders, hit_obj)
                    end
                end

                -- out_of_range = out_of_range and attack_data.outside_attack_area

                attack_results.shots[i].pellets[p_i] = {
                    miss = shot_miss,
                    cth = shot_cth,
                    roll = roll,
                    attack_pos = pellet_hit_data.attack_pos,
                    target_pos = pellet_hit_data.target_pos,
                    stuck_pos = pellet_hit_data.stuck_pos or pellet_hit_data.lof_pos2,
                    hits = {},
                    target_hit = pellet_target_hit, -- shot_target_hit,
                    out_of_range = attack_data.outside_attack_area,
                    shot_target = not shot_miss and target_unit,
                    allyHit = pellet_hit_data.allyHit,
                    ammo_type = ammo_type,
                    clear_attacks = pellet_hit_data.clear_attacks
                }

                for _, hit in ipairs(pellet_hit_data.hits) do
                    hit.direct_shot = true
                    hit.shot_idx = i
                    -----
                    hit.pellet_idx = p_i
                    -----
                    hit.weapon = self
                    if hit.obj or hit.terrain then
                        table.insert(attack_results.shots[i].pellets[p_i].hits, hit)
                    end
                end
            end
        end
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        for _, hit in ipairs(hit_data.hits) do
            hit.direct_shot = true
            hit.shot_idx = i
            -----
            if is_pellet_shot then
                hit.pellet_idx = 1
            end
            -----
            hit.weapon = self
            if hit.obj or hit.terrain then
                table.insert(attack_results, hit) -- store in attack_results to obey the convention of returning hits in the array part of the results
                table.insert(attack_results.shots[i].hits, hit) -- also store in the shot description for convenience
            end
        end

        --------------------------------
        if is_pellet_shot then
            attack_results.shots[i].pellets[1] = shot
        end
        --------------------------------
    end

    attack_results.miss = miss
    attack_results.crit = crit

    if num_shots > 0 and IsValid(target) then
        --[[if miss == target_hit then
			DbgClearTexts()
			DbgClearVectors()
			for _, shot in ipairs(attack_results.shots) do
				DbgAddVector(shot.attack_pos, shot.target_pos - shot.attack_pos, const.clrYellow)
				DbgAddText(string.format("cth: %d, roll: %d (%s)", shot.cth, shot.roll, (shot.roll <= shot.cth) and "hit" or "miss"), shot.target_pos + point(0, 0, guim), const.clrWhite)
				for _, hit in ipairs(shot.hits) do
					DbgAddVector(hit.pos, point(0, 0, 2*guim), const.clrGreen)
				end
			end
			WaitNextFrame()
		end--]]
        -- assert(miss ~= target_hit)
    end

    -- aoe damage
    local targetHitProjectile = target_hit

    -------------------------
    if attack_results.is_pellet_attack then
        --------------------------------------
    elseif aoe_params then
        local damage_override = GetAoeDamageOverride(shot_attack_args, attacker, self,
                                                     shot_attack_args.damage_bonus)
        aoe_params.prediction = shot_attack_args.prediction
        local hits, aoe_total_damage, aoe_friendly_fire_dmg =
            GetAreaAttackResults(aoe_params, shot_attack_args.aoe_damage_bonus,
                                 shot_attack_args.applied_status, damage_override)
        attack_results.area_hits = hits
        total_damage = total_damage + aoe_total_damage
        friendly_fire_dmg = friendly_fire_dmg + aoe_friendly_fire_dmg

        for _, hit in ipairs(hits) do
            hit.weapon = self
            if IsKindOf(hit.obj, "CombatObject") and not hit.obj:IsDead() then
                if IsKindOf(hit.obj, "Unit") and hit.damage > 0 then
                    unit_damage[hit.obj] = (unit_damage[hit.obj] or 0) + hit.damage
                end
                local objIsTarget = hit.obj == target
                hit.obj_is_target = objIsTarget
                target_hit = target_hit or (objIsTarget)
                if not hit_objs[hit.obj] then
                    hit_objs[#hit_objs + 1] = hit.obj
                    hit_objs[hit.obj] = true
                    num_hits = num_hits + 1
                else
                    -- find the first hit on this target, fold the damage there, reset the damage to 0 so it doesn't get processed in FireSpread
                    local direct_hit = find_first_hit(attack_results, hit.obj)
                    if direct_hit then
                        direct_hit.damage = direct_hit.damage + hit.damage
                        hit.damage = 0
                    end
                end
            end
        end

        ----- Old vanilla
        -- if not prediction and (shot_attack_args.buckshot_scatter_fx or 0) > 0 then
        -- attack_results.cosmetic_hits = self:CalcBuckshotScatter(attacker, action,
        --                                                         attack_results.attack_pos,

        --                                                         target_pos,
        --                                                         shot_attack_args.buckshot_scatter_fx,
        --                                                         aoe_params, attack_results)
        -- end
    end

    attack_results.num_hits = num_hits
    attack_results.total_damage = total_damage
    attack_results.friendly_fire_dmg = friendly_fire_dmg
    attack_results.target_hit = target_hit
    attack_results.target_hit_projectile = targetHitProjectile
    attack_results.out_of_range = out_of_range
    attack_results.unit_damage = unit_damage
    CompileKilledUnits(attack_results)

    if not prediction then
        -- print("Firearm_GetAttackResults", attack_results.fired, attack_results.miss, attack_results.target_hit, attack_results.num_hits)
        NetUpdateHash("Firearm_GetAttackResults", attack_results.fired, attack_results.miss,
                      attack_results.target_hit, attack_results.num_hits)
        g_LastAttackResults = attack_results
    end

    return attack_results
end

---------------------------------------------------------------------------------------------------------

local t_id_table = {[604792341662] = "No Line of Fire"}

ratG_T_table['SOURCE_FirearmGetAttackResults.lua'] = t_id_table

--local original_firearmBulletCalcDamage = Firearm.BulletCalcDamage


function Firearm:BulletCalcDamage(hit_data, ricochet_idx)


	local attacker = hit_data.obj
	local target = hit_data.target
	local action = CombatActions[hit_data.action_id]
	local hits = hit_data.hits
	local record_breakdown = hit_data.record_breakdown
	local prediction = hit_data.prediction

	if not ricochet_idx then
		local dmg_mod = hit_data.damage_bonus or 0
		if type(dmg_mod) == "table" then
			dmg_mod = dmg_mod[obj]
		end
		if record_breakdown and dmg_mod then
			local name = action and action:GetActionDisplayName({attacker}) or T(328963668848, "Base")
			table.insert(record_breakdown, { name = name, value = dmg_mod })
		end
		local basedmg = attacker:GetBaseDamage(self, target, record_breakdown)
		local dmg = MulDivRound(basedmg, Max(0, 100 + (dmg_mod or 0)), 100)
		if not prediction then
			dmg = RandomizeWeaponDamage(dmg)
		end
		hit_data.damage = dmg
	end
	local target_reached
	local forced_target_hit = hit_data.forced_target_hit
	local impact_force = self:GetImpactForce()

	for idx = ricochet_idx or 1, hits and #hits or 0 do
		local hit = hits[idx]
		local stray = hit.stray
		local dmg = hit_data.damage
		local obj = hit.obj
		local is_unit
		if obj and IsKindOf(obj, "Unit") and not stray then
			is_unit = true
			stray = obj ~= target
			target_reached = target_reached or target and obj == target

			if not prediction then
				if hit_data.critical == nil and not stray then
					hit_data.target_spot_group =	hit_data.target_spot_group or hit.spot_group
					-- pass hit_data instead of attack_args, it has all the relevant data
					local critChance = attacker:CalcCritChance(self, target, action, hit_data, hit_data.step_pos)--hit_data.aim, hit_data.step_pos, hit_data.target_spot_group or hit.spot_group, action)
					local critRoll = attacker:Random(100)
					hit_data.critical = critRoll < critChance
				end
			end
			if not stray then
				hit.spot_group = hit_data.target_spot_group or hit.spot_group
			end
		end -- hits on non-units are never stray or critical

		hit.stray = stray
		hit.critical = not stray and hit_data.critical
		hit.damage = dmg

		local breakdown = obj == target and record_breakdown -- We only care about the damage breakdown on the target, not objects in the way.
		self:PrecalcDamageAndStatusEffects(attacker, obj, hit_data.step_pos, hit.damage, hit, hit_data.applied_status, hit_data, breakdown, action, prediction)

		hit.impact_force = hit.damage > 0 and impact_force + self:GetDistanceImpactForce(hit.distance) or 0

		if idx < #hits and (hit.armor_prevented or 0) > 0 and not hit.ignored then
			if not forced_target_hit or target_reached then
				local penetrated = false
				if is_unit and (not target or target_reached) then
					for item, degrade in pairs(hit.armor_decay) do
						if hit.armor_pen[item] then
							penetrated = true
							break
						end
					end
				end
				if not penetrated and not hit.ricochet then
					-- remove the rest of the hits
					for i = idx + 1, #hits do
						hits[i] = nil
					end
					hit_data.stuck_pos = hit.pos -- adjust the final impact pos of the bullet
					if hit_data.target_hit_idx and hit_data.target_hit_idx > idx then
						hit_data.target_hit_idx = nil
						hit_data.stuck = true
					end
					break
				end
			end
		end
	end
end

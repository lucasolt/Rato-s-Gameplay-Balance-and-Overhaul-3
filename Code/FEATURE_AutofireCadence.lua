---- Autofire cadence: rounds leave at the weapon's RPM instead of being squeezed into one fire anim
---- (vanilla fits every BurstFire/MGBurstFire round in a 300 ms anim). The anim loops every
---- CadenceShotsPerAnim rounds, sped up or slowed to match. Params: __AutofireParams.lua.

local rpm_paced = {AutoFire = true, MGBurstFire = true, BurstFire = true, BulletHell = true}

---- ms between rounds, or nil to keep the vanilla timing (single shots, DualShot)
function Rat_CadenceInterval(action, results)
    if not (action and rpm_paced[action.id]) or results.attacks or not results.weapon then
        return
    end
    if #(results.shots or empty_table) < 2 then
        return
    end
    local rpm = results.weapon.RPM or const.Combat.Autofire.RPMRef
    return MulDivRound(60000, 1, Max(1, rpm))
end

---- GetAnimDuration already includes the current speed modifier, so it is undone first
function Rat_CadenceAnimSpeed(unit, attack_args, interval, cur_speed)
    local p = const.Combat.Autofire
    local anim = attack_args.anim and unit:ModifyWeaponAnim(attack_args.anim)
    if not anim or not unit:HasState(anim) then
        return attack_args.anim_speed_mod or 1000
    end
    local base = MulDivRound(unit:GetAnimDuration(anim), Max(1, cur_speed), 1000)
    local speed = MulDivRound(base, 1000, p.CadenceShotsPerAnim * interval)
    return Clamp(speed, p.CadenceAnimSpeedMin, p.CadenceAnimSpeedMax)
end

---- UnitActions.lua: vanilla Unit:ExecFirearmAttacks; changed only where marked "cadence"
function Unit:ExecFirearmAttacks(action, cost_ap, attack_args, results)
	NetUpdateHash("ExecFirearmAttacks", action, cost_ap, not not g_Combat)
	local lof_idx = table.find(attack_args.lof, "target_spot_group", attack_args.target_spot_group or "Torso")
	local lof_data = attack_args.lof[lof_idx or 1]
	local target = attack_args.target
	local target_unit = IsKindOf(target, "Unit") and IsValidTarget(target) and target
	local interrupt = attack_args.interrupt
	if interrupt then
		if ActionCameraPlaying then
			RemoveActionCamera(true)
			WaitMsg("ActionCameraRemoved", 5000)
		end
		self:PushDestructor(function()
			Msg("InterruptAttackEnd") 
		end)

		Msg("InterruptAttackStart", self, target_unit, action) 
	end
	
	NetUpdateHash("ExecFirearmAttacks_After_Interrupt_Cam_Wait")
	
	results.attack_from_stealth = not not self:HasStatusEffect("Hidden")
	for _, attack in ipairs(results.attacks or {results}) do
		if attack.fired then
			self:AttackReveal(action, attack_args, results)
			break
		end
	end

	local can_provoke_opportunity_attacks = not action or (action.id ~= "CancelShot" and action.id ~= "CancelShotCone")
	if can_provoke_opportunity_attacks then
		self:ProvokeOpportunityAttacks(action, "attack interrupt")
	end
	self:PrepareToAttack(attack_args, results)
	if can_provoke_opportunity_attacks then
		self:ProvokeOpportunityAttacks(action, "attack interrupt")
	end
	local was_interruptable = self.interruptable
	if not was_interruptable then
		self:EndInterruptableMovement()
	end

	NetUpdateHash("ExecFirearmAttacks_Start_Action_Cam")
	-- camera effects
	if attack_args.opportunity_attack_type ~= "Retaliation" then
		local cinematicKill = false
		local dontPlayForLocalPlayer = false
		if g_Combat and IsEnemyKill(self, results) then
			g_Combat:CheckPendingEnd(results.killed_units)
			
			local isKillCinematic 
			isKillCinematic, dontPlayForLocalPlayer = IsEnemyKillCinematic(self, results, attack_args)
			if isKillCinematic then
				cameraTac.SetForceMaxZoom(false)
				SetAutoRemoveActionCamera(self, results.killed_units[1], nil, nil, nil, nil, nil, dontPlayForLocalPlayer)
				cinematicKill = true
			end
		elseif interrupt then -- the attack is from enemy pindown or overwatch
			--[[if self.team.side == "enemy" then
				SetAutoRemoveActionCamera(target_unit, self, 1000, true) -- todo: should this use the anim duration?
			else
				SetAutoRemoveActionCamera(self, target_unit, 1000, true)
			end--]]
		end
		if not cinematicKill and IsKindOf(target, "Unit") then
			local cinematicAttack, interpolation = IsCinematicAttack(self, results, attack_args, action)
			if cinematicAttack then
				local playerUnit = (IsKindOf(target, "Unit") and target:IsLocalPlayerTeam() and target) or (self:IsLocalPlayerTeam() and self)
				local enemyUnit = playerUnit and (playerUnit == target and self or target)
				if playerUnit and enemyUnit then
					SetAutoRemoveActionCamera(playerUnit, enemyUnit, false, false, false, interpolation and default_interpolation_time, nil, dontPlayForLocalPlayer)
				end
			end
		end
	end
	NetUpdateHash("ExecFirearmAttacks_After_Action_Cam")
	-- animspeed modifier & cmd destructor
	local asm = self:GetAnimSpeedModifier()
	local anim_speed_mod = attack_args.anim_speed_mod or 1000
	-- cadence
	local interval = Rat_CadenceInterval(action, results)
	if interval then
		anim_speed_mod = Rat_CadenceAnimSpeed(self, attack_args, interval, asm)
	end
	self:SetAnimSpeedModifier(anim_speed_mod)
	self:PushDestructor(function(self)
		self:SetAnimSpeedModifier(asm)
		if IsValid(target) and target:HasMember("session_id") then
			self.last_attack_session_id = target.session_id
		else
			self.last_attack_session_id = false
		end
		
		local cooldown = action:ResolveValue("cooldown")
		if cooldown then
			self:SetEffectExpirationTurn(action.id, "cooldown", g_Combat.current_turn + cooldown)
		end
		
		if IsValid(target) then
			ObjModified(target)
		end
		
		table.remove(g_CurrentAttackActions) -- pop the pushed attack action
	end)
	
	local ap = (cost_ap and cost_ap > 0) and cost_ap or action:GetAPCost(self, attack_args)
	table.insert(g_CurrentAttackActions, { action = action, cost_ap = ap, attack_args = attack_args, results = results })

	-- start anim, wait hit moment, apply ammo/condition results
	local 	chance_to_hit =  results.chance_to_hit
	local 	missed        =  results.miss
	local critical = results.crit
	local chance_crit = results.crit_chance
	local aim_state = self:GetStateText()
	
	local fired = false	
	if results.attacks then --- multi-weapon attacks (DualShot)
		local shots = results.attacks[1] and results.attacks[1].shots
		self:StartFireAnim(shots and shots[1], attack_args)
		for _, attack in ipairs(results.attacks) do
			attack.weapon:ApplyAmmoUse(self, attack.fired, attack.jammed, attack.condition)
			fired = fired or attack.fired
		end
	else
		self:StartFireAnim(results.shots and results.shots[1], attack_args)
		results.weapon:ApplyAmmoUse(self, results.fired, results.jammed, results.condition)
		fired = results.fired
	end
	
	if not fired then
		-- none of the weapons fired, abort
		if not was_interruptable then
			self:BeginInterruptableMovement()
		end
		Sleep(self:TimeToAnimEnd())
		self:PopAndCallDestructor()
		if interrupt then
			self:PopAndCallDestructor()
		end
		NetUpdateHash("ExecFirearmAttacks_early_out")
		return
	end

	PushUnitAlert("noise", self, results.weapon.Noise, Presets.NoiseTypes.Default.Gunshot.display_name)

	local shot_threads = {}	
	
	local attacks = results.attacks or {results}
	local attackArgs = results.attacks_args or {attack_args}
	
	if results.shots and #results.shots > 8 and g_Combat and not g_Combat:ShouldEndCombat(results.killed_units) then
		if (not results.killed_units or #results.killed_units == 1) then
			local vr = IsMerc(self) and "Autofire" or "AIAutofire"
			PlayVoiceResponse(self, vr)
		end
	end
	
	local lowChanceShot
	local base_weapon_damage = 0
	for attackIdx, attack in ipairs(attacks) do
		local attackArg = attackArgs[attackIdx]
		local fx_action = attackArg.fx_action
		if action.id == "BulletHell" then
			BulletHellOverwriteShots(attack)
		end
		local shots_per_animation = Min(3, #attack.shots)
		-- cadence
		if interval then
			shots_per_animation = Min(const.Combat.Autofire.CadenceShotsPerAnim, #attack.shots)
		elseif action.id == "BurstFire" or action.id == "MGBurstFire" then
			shots_per_animation = #attack.shots
		end
		for i, shot in ipairs(attack.shots) do
			-- shot visuals
			attack.weapon:FireBullet(self, shot, shot_threads, results, attackArg)
			if attackArg.single_fx then
				fx_action = ""
			end
			if i < #attack.shots then -- more shots to fire
				-- cadence: the restarted anim fires at once (rifle Fire anims have no hit moment)
				if interval then
					if i % shots_per_animation == 0 then
						self:StartFireAnim(attack.shots[i+1], attackArg, nil, interval)
					else
						Sleep(interval)
					end
				elseif i % shots_per_animation == 0 then
					local shotAnimDelay = attackArg.attack_anim_delay or self:TimeToAnimEnd()
					self:StartFireAnim(attack.shots[i+1], attackArg, nil, shotAnimDelay) -- fire next shot
				else
					Sleep(self:GetAnimDuration() / shots_per_animation)
				end
			elseif attackIdx < #attacks then
				Sleep(MulDivRound(self:GetAnimDuration() / shots_per_animation, 30, 100))
			end
			if IsMerc(self) and attack.target_hit then
				if attack.chance_to_hit <= 20 then
					lowChanceShot = true
				end
			end
		end
		attack.weapon:FireSpread(attack, attackArg) -- deal the area damage, if any
		base_weapon_damage = base_weapon_damage + attack.weapon.Damage
	end

	-- additional damage (e.g. from DualShot perk)
	for _, packet in ipairs(results.extra_packets) do	
		if IsValidTarget(packet.target) then
			if packet.damage then
				packet.target:TakeDirectDamage(packet.damage, false, "short", packet.message)
			end
			if packet.effects then
				packet.target:ApplyDamageAndEffects(false, false, packet)
			end
		end
	end

	-- wait end moment and restore animation
	local time_to_fire_end = self:TimeToAnimEnd()
	if not attack_args.dont_restore_aim then
		if self:CanAimIK(results.weapon) then
			local restore_aim_delay = Min(300, time_to_fire_end)
			Sleep(restore_aim_delay)
			self:SetIK("AimIK", lof_data.lof_pos2, nil, nil, 0)
			Sleep(time_to_fire_end - restore_aim_delay)
			self:SetState(aim_state, const.eKeepComponentTargets)
		else
			Sleep(time_to_fire_end)
			self:SetState(aim_state, const.eKeepComponentTargets)
		end
	end

	-- special-case: interrupt neutral units with neutral_retaliate flag attacked by player units,
	-- so they don't look ridiculous minding their own business for several more seconds until the attack resolves
	if self.team.player_team and not g_Combat then
		if IsValid(target_unit) and target_unit.team.neutral and target_unit.neutral_retaliate and not target_unit:IsIncapacitated() then
			target_unit.neutral_retal_attacked = true
			target_unit:SetBehavior()
			target_unit:SetCommand("Idle")
		end
		
		local hits = #results > 0 and results or results.area_hits
		for _, hit in ipairs(hits) do
			local unit = IsKindOf(hit.obj, "Unit") and not hit.obj:IsIncapacitated() and hit.obj
			if IsValid(unit) and unit.team.neutral and unit.neutral_retaliate then
				unit.neutral_retal_attacked = true
				unit:SetBehavior()
				unit:SetCommand("Idle")
			end
		end
	end
	
	self.interruptable = false
	self:PushDestructor(function()
		self.interruptable = was_interruptable
	end)
	
	if attack_args.external_wait_shots then
		table.iappend(attack_args.external_wait_shots, shot_threads)
	else
		Firearm:WaitFiredShots(shot_threads)
	end

	-- wait target dodge anim
	while target_unit and target_unit.command == "Dodge" do
		WaitMsg("Idle")
	end
	-- play voices
	base_weapon_damage = MulDivRound(base_weapon_damage, 120, 100)
	if attacks and next(attacks)then
		--count shots fired per team for Voice Response
		self.team.tactical_situations_vr.shotsFired = self.team.tactical_situations_vr.shotsFired and self.team.tactical_situations_vr.shotsFired + 1 or 1
		self.team.tactical_situations_vr.shotsFiredBy = self.team.tactical_situations_vr.shotsFiredBy  or {}
		self.team.tactical_situations_vr.shotsFiredBy[self.session_id] = true
		PlayVoiceResponseTacticalSituation(table.find(g_Teams, self.team), "now")
		if missed then
		
			--count missed shots per team for Voice Response
			self.team.tactical_situations_vr.missedShots = self.team.tactical_situations_vr.missedShots and self.team.tactical_situations_vr.missedShots + 1 or 1
			PlayVoiceResponseTacticalSituation(table.find(g_Teams, self.team), "now")
			
			if chance_to_hit >= 70 then
				if not target_unit or not target_unit:IsCivilian() then
					PlayVoiceResponseMissHighChance(self)
				end
			elseif target_unit and chance_to_hit>=50 and base_weapon_damage>=target_unit:GetTotalHitPoints() then
				if IsMerc(target_unit) then
					target_unit:SetEffectValue("missed_by_kill_shot", true)
				end
			end
		elseif not missed then
			if results.stealth_kill and IsMerc(self) and results.killed_units and #results.killed_units > 0 then	
				
			elseif lowChanceShot and target_unit and not self:IsOnAllySide(target_unit) and not target_unit:IsCivilian() then
				PlayVoiceResponse(self, "LowChanceShot")
			end
		end
	end
	
	for i, attack in ipairs(attacks) do
		local holdXpLog = i ~= #attacks
		self:OnAttack(action, target_unit, attack, attack_args, holdXpLog)
	end
		
	LogAttack(action, attack_args, results)
	AttackReaction(action, attack_args, results, "can retaliate")
	
	if not action or (action.id ~= "CancelShot" and action.id ~= "CancelShotCone") then
		self:ProvokeOpportunityAttacks(action, "attack reaction")
	end

	if not was_interruptable then
		self:BeginInterruptableMovement()
	end
	self:PopAndCallDestructor()
	self:PopAndCallDestructor()
	if interrupt then
		self:PopAndCallDestructor()
	end
end

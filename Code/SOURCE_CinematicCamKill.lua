
function IsEnemyKillCinematic(attacker, results, attack_args)
	local headshot = attack_args and attack_args.target_spot_group == "Head"
	local playerAttacker = attacker:IsLocalPlayerTeam()
	local pvp = IsCompetitiveGame()
	local cinematicKill = false
	local cinematicKillTracker = g_Combat.cinematic_kills_this_turn
	
	if attack_args and attack_args.gruntyPerk then
		return false
	end



	for _, unit in ipairs(results.killed_units) do
		if attacker:IsOnEnemySide(unit) then

			local killingHit = table.find_value(results, "obj", unit) or (results.area_hits and table.find_value(results.area_hits, "obj", unit))
			---
			if not results.shots[1].pellets  then
				assert(killingHit) -- Killed unit was reported, but no "attack hit" actually struck it. Spontaneous death?
			end
			---
			if headshot or not playerAttacker or pvp then
				cinematicKill = "headshot, or enemy kill"
				break
			end
			
			local anim = GetDeathBaseAnim(unit, { attacker = attacker, hit_descr = killingHit })
			if anim and (string.find(anim, "DeathSlide") or string.find(anim, "DeathBlow") or string.find(anim, "DeathWindow")) then
				cinematicKill = "slide"
				break
			elseif cinematicKillTracker and (cinematicKillTracker[attacker.session_id] or 0) < 1 and InteractionRand(100, "CinematicKill") < 10 then
				cinematicKill = "random chance"
				break
			end
		end
	end
	
	local dontPlayForLocalPlayer
	if cinematicKill then
		if cinematicKillTracker then cinematicKillTracker[attacker.session_id] = (cinematicKillTracker[attacker.session_id] or 0) + 1 end
		CinematicKillDebugPrint("cinematic kill woah!", cinematicKill)
		
		--(MP) Do not play cinematic kill if in movement or crosshair mode
		local isLocalPlayerAttacking = attacker:IsLocalPlayerControlled()
		local igi = GetInGameInterfaceModeDlg()
		local crosshair = igi and igi.crosshair
		local movement_mode = igi.movement_mode
		
		if not isLocalPlayerAttacking and (crosshair or movement_mode) then
			local crosshairTarget = crosshair and crosshair.context and crosshair.context.target
			if crosshairTarget == attack_args.target then
				crosshair:SetVisible(false) --only hide the crosshair as the Unit:Despawn function will actually close it
			end
			dontPlayForLocalPlayer = true
		end
	end
	return cinematicKill, dontPlayForLocalPlayer
end
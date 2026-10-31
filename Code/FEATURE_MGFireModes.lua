---- MG fire modes: MGs list SingleShot / BurstFire beside MGBurstFire (MG Autofire). Vanilla holds
---- only MGBurstFire to the set-up cone; every other ranged attack is held here and in
---- SOURCE_UnitCanAttack.lua. Unset MG bar entries: SOURCE_unitEnumUIactions.lua.

---- cone-aimed actions (MGSetup, MGRotate, Overwatch) aim the cone itself and stay free
function Rat_MGConeBound(action, unit)
    if not action or action.id == "MGBurstFire" or action.ActionType ~= "Ranged Attack" or
        action.AimType == "cone" then
        return false
    end
    local overwatch = g_Overwatch[unit]
    return overwatch and overwatch.permanent and
               (unit:HasStatusEffect("StationedMachineGun") or
                   unit:HasStatusEffect("ManningEmplacement")) and true or false
end

---- IModeCombatFreeAim.lua: the vanilla cone check, for the attacks it does not cover
local GBO_OriginalFreeAimOnMouseButtonDown = IModeCombatFreeAim.OnMouseButtonDown
function IModeCombatFreeAim:OnMouseButtonDown(pt, button)
    local unit = SelectedObj
    if (button == "L" or not button and GetUIStyleGamepad()) and IsValid(unit) and
        unit:CanBeControlled() and Rat_MGConeBound(self.action, unit) and
        not IsValidThread(self.real_time_threads and self.real_time_threads.move_and_attack) then
        local target = self:GetFreeAttackTarget(self.potential_target, self.attacker)
        local overwatch = g_Overwatch[unit]
        local angle = overwatch.orient or CalcOrientation(unit:GetPos(), overwatch.target_pos)
        if not CheckLOS(target, unit, overwatch.dist, unit.stance, overwatch.cone_angle, angle) then
            ReportAttackError(target or unit, AttackDisableReasons.OutOfRange)
            return
        end
    end
    return GBO_OriginalFreeAimOnMouseButtonDown(self, pt, button)
end

---- UnitCaching.lua, copied whole: the set-up branch is inline. Must load before
---- FEATURE_VariableAutofire.lua, which wraps this function.
function Unit:RecalcUIActions(force)
	local actions
	local attacks_first
	
	if self:GetBandageTarget() then
		actions = { "StopBandaging" }
	elseif self:HasStatusEffect("StationedMachineGun") or self:HasStatusEffect("ManningEmplacement") then
		actions = {}
		local action = self:GetDefaultAttackAction()
		actions[#actions + 1] = action.id
		-- GBO: a set-up MG lists every fire mode, so the firing-mode toggle can form
		attacks_first = {[action.id] = true}
		if self:HasStatusEffect("StationedMachineGun") then
			local weapon = self:GetActiveWeapons()
			for _, id in ipairs(IsKindOf(weapon, "Firearm") and weapon.AvailableAttacks or empty_table) do
				table.insert_unique(actions, id)
				attacks_first[id] = true
			end
		end
		ForEachPresetInGroup("CombatAction", "MachineGun", function(def)
			if def.id ~= "MGSetup" then
				actions[#actions + 1] = def.id
			end
		end)
		
		-- additional available actions
		actions[#actions + 1] = "Reload"
		actions[#actions + 1] = "Unjam"
	else
		actions = self:EnumUIActions() 
		if not actions then -- EnumUIActions decided to swap
			return
		end
	end
	
	-- move hidden actions to the back and mark actions visible in ui
	local ui_actions = {}
	local vis_idx = 1
	local old_actions = self.ui_actions
	self.ui_actions = ui_actions

	if actions then
		-- GBO: set up, the attacks lead the bar (the MachineGun group shares their SortKey 0)
		table.sort(actions, function(a, b)
			local actionA = CombatActions[a]
			local actionB = CombatActions[b]
			local keyA = attacks_first and attacks_first[a] and -1 or actionA.SortKey
			local keyB = attacks_first and attacks_first[b] and -1 or actionB.SortKey
			return keyA < keyB
		end)

		-- First pass, find actions which combine into firing modes.
		-- This should setup the right default attack action as well.
		local firingModes = {}
		for i = 1, #actions do
			local id = actions[i]
			local caction = CombatActions[id]
			local state = "hidden"
			
			local firingModeId = caction.FiringModeMember
			if not firingModeId then goto continue end

			if caction.ShowIn == "CombatActions" and (g_Combat or (#(Selection or empty_table) == 1 or caction.MultiSelectBehavior ~= "hidden")) then
				local target = caction.RequireTargets and caction:GetDefaultTarget(self)
				state = caction:GetVisibility({self}, target)
			end

			if state ~= "hidden" then
				if not firingModes[firingModeId] then
					firingModes[firingModeId] = {}
				end
				table.insert(firingModes[firingModeId], id)
				ui_actions[id] = state
			end

			::continue::
		end
		
		-- Check if dual shot attack mode is active.
		-- This has higher priotity because it disables other firing modes
		local dual_shot_state
		for modeName, mode in pairs(firingModes) do
			if modeName == "AttackDual" then
				for i, m in ipairs(mode) do
					if ui_actions[m] == "enabled" then
						dual_shot_state = "enabled"
					end
				end
			end
		end
		
		-- Show firing mode action only if more than one action is available.
		for modeName, mode in pairs(firingModes) do
			local defaultFireMode = mode[1]
			if #mode > 1 and (modeName ~= "AttackDual" or dual_shot_state ~= "hidden") then
				ui_actions[modeName] = "enabled"
				
				-- Weapon default
				local defaultAction = self:GetDefaultAttackAction(false, "force_ungrouped")
				if defaultAction.FiringModeMember == modeName and ui_actions[defaultAction.id] == "enabled" then
					defaultFireMode = defaultAction.id
				else
					-- First enabled.
					for i, m in ipairs(mode) do
						if ui_actions[m] == "enabled" then
							defaultFireMode = m
							break
						end
					end
				end
			else
				ui_actions[modeName] = "disabled"
			end
			
			-- When showing dual attacking hide other firing modes
			if modeName ~= "AttackDual" and dual_shot_state == "enabled" then
				ui_actions[modeName] = "hidden"
				for i, m in ipairs(mode) do
					ui_actions[m] = "hidden"
				end
			elseif dual_shot_state ~= "enabled" and modeName == "AttackDual" then
				for i, m in ipairs(mode) do
					ui_actions[m] = "hidden"
				end
			end

			mode.take_idx_from = mode[1]
			ui_actions[modeName .. "default"] = defaultFireMode
			assert(ui_actions[modeName .. "default"])	
		end

		local doubleTossCount = 0
		local grenadeModes = {}
		for i = 1, #actions do
			local id = actions[i]
			local caction = CombatActions[id]
			
			local state = "hidden"
			if caction.ShowIn == "CombatActions" or caction.ShowIn == "SignatureAbilities" then
				if ui_actions[id] then
					state = ui_actions[id]
				elseif g_Combat or (#(Selection or empty_table) == 1 or caction.MultiSelectBehavior ~= "hidden") then
					local target = caction.RequireTargets and CombatActionGetOneAttackableEnemy(caction, self)
					state = caction:GetVisibility({self}, target)
				end
			end

			-- special-case grenade throws in case multiple identical grenades are equipped
			if state ~= "hidden" then -- todo: remove this special case, make it generic, it causes issues with displaying signatures
				local action_type
				if string.match(id, "DoubleToss") then 
					action_type = "DoubleToss"
				elseif string.match(id, "ThrowGrenade") then
					action_type = "ThrowGrenade"
				end
				if action_type then
					grenadeModes[action_type] = grenadeModes[action_type] or {}
					local weapon = caction:GetAttackWeapons(self)
					if not weapon or grenadeModes[action_type][weapon.class] then
						state = "hidden"
						if action_type == "DoubleToss" then
							doubleTossCount = doubleTossCount + 1
							if doubleTossCount == 4 then
								state = "disabled"
							end
						end
					end
					if weapon then
						grenadeModes[action_type][weapon.class] = grenadeModes[action_type][weapon.class] or {}
						local equipped = self.current_weapon == "Handheld A" and (id == "ThrowGrenadeA" or  id == "ThrowGrenadeB") or
						                 self.current_weapon == "Handheld B" and (id == "ThrowGrenadeC" or  id == "ThrowGrenadeD")
						grenadeModes[action_type][weapon.class][id] = equipped
					end
				end
			end

			if state ~= "hidden" then
				local firingModeId = caction.FiringModeMember
				if firingModeId and ui_actions[firingModeId] == "enabled" then
					-- Firing mode actions are shown in the position of the first action in the mode,
					-- the mode actions themselves are not shown.
					if firingModes[firingModeId].take_idx_from == id then
						table.insert(ui_actions, vis_idx, firingModeId)
						vis_idx = vis_idx + 1
					end
				elseif CombatActions[id].group ~= "Hidden" then
					table.insert(ui_actions, vis_idx, id)
					vis_idx = vis_idx + 1
				end
				ui_actions[id] = state
			elseif caction.ShowIn ~= "Special" and not caction.ShowIn then
				ui_actions[#ui_actions + 1] = id
			end
		end
		
		--go through the grenade modes to place equipped in ui_actions with priority (to first consume from equipped nades)
		for action, _ in pairs(grenadeModes) do
			for grenadeType, _ in pairs(grenadeModes[action]) do
				for actionName, _ in pairs (grenadeModes[action][grenadeType]) do
					if grenadeModes[action][grenadeType][actionName] and not table.find(ui_actions, actionName) then
						for otherActionName, _ in pairs (grenadeModes[action][grenadeType]) do
							if table.find(ui_actions, otherActionName) then
								ui_actions[otherActionName] = nil
								ui_actions[actionName] = "enabled"
								ui_actions[table.find(ui_actions, otherActionName)] = actionName
								break
							end
						end
					end
				end
			end
		end
	end
	
	-- Put the signature ability in the 13th place always
	for i, id in ipairs(ui_actions) do 
		local caction = CombatActions[id]
		if caction.group == "SignatureAbilities" then
			if ui_actions[13] then
				-- GBO: plain swap; vanilla's remove(13) shifted a signature past slot 13, duplicating it and losing two actions
				ui_actions[i], ui_actions[13] = ui_actions[13], id
			else
				table.remove(ui_actions, i)
				if #ui_actions < 12 then
					for j = #ui_actions + 1, 12 do
						ui_actions[j] = "empty"
					end
				end
				ui_actions[13] = id
			end
			break
		end
	end
	
	if vis_idx > 14 then
		-- Remove item skills. They will be represented by ItemSkills.
		for i, itemSkill in ipairs(itemCombatSkillsList) do
			if ui_actions[itemSkill] then
				local actionIdx = table.find(ui_actions, itemSkill)
				if actionIdx then
					table.remove(ui_actions, actionIdx)
					vis_idx = vis_idx - 1
				end
			end
		end
		vis_idx = vis_idx + 1
	else
		ui_actions["ItemSkills"] = false
	end
	
	assert(vis_idx <= 14, "This unit has too many actions - they cant fit on the UI! (12)")

	if self == Selection[1] then
		local allMatch = false
		-- Verify that any actions have changed.
		if old_actions then
			allMatch = true
			for i, a in ipairs(old_actions) do
				if ui_actions[i] ~= a or old_actions[a] ~= ui_actions[a] then
					allMatch = false
					break
				end
			end
		end
		if not allMatch or force then ObjModified("combat_bar") end
	end
	return ui_actions
end

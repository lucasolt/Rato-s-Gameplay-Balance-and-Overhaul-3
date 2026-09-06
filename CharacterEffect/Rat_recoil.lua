UndefineClass('Rat_recoil')
DefineClass.Rat_recoil = {
	__parents = { "StatusEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "StatusEffect",
	msg_reactions = {
		PlaceObj('MsgActorReaction', {
			ActorParam = "unit",
			Event = "UnitMovementStart",
			Handler = function (self, unit)
				local reaction_def = (self.msg_reactions or empty_table)[1]
				if self:VerifyReaction("UnitMovementStart", reaction_def, unit, unit) then
					
				--unit:RemoveStatusEffect("Rat_recoil", "all")
				end
			end,
			HandlerCode = function (self, unit)
				
				--unit:RemoveStatusEffect("Rat_recoil", "all")
			end,
		}),
		PlaceObj('MsgActorReaction', {
			ActorParam = "unit",
			Event = "CombatActionEnd",
			Handler = function (self, unit)
				local reaction_def = (self.msg_reactions or empty_table)[2]
				if self:VerifyReaction("CombatActionEnd", reaction_def, unit, unit) then
					
				
				if unit.action_command == 'TakeCover' or unit.action_command == 'LeaveEmplacement' or unit.action_command == 'MGPack' or unit.action_command == 'ThrowGrenade' or unit.action_command == 'InteractWith' or unit.action_command == 'ThrowKnife' or unit.action_command == "ReloadAction"  or unit.action_command == "DobuleToss" then
					unit:RemoveStatusEffect("Rat_recoil", "all")
				end
				end
			end,
			HandlerCode = function (self, unit)
				
				
				if unit.action_command == 'TakeCover' or unit.action_command == 'LeaveEmplacement' or unit.action_command == 'MGPack' or unit.action_command == 'ThrowGrenade' or unit.action_command == 'InteractWith' or unit.action_command == 'ThrowKnife' or unit.action_command == "ReloadAction"  or unit.action_command == "DobuleToss" then
					unit:RemoveStatusEffect("Rat_recoil", "all")
				end
			end,
		}),
		PlaceObj('MsgActorReaction', {
			ActorParam = "unit",
			Event = "UnitEndTurn",
			Handler = function (self, unit)
				local reaction_def = (self.msg_reactions or empty_table)[3]
				if self:VerifyReaction("UnitEndTurn", reaction_def, unit, unit) then
					unit:RemoveStatusEffect("Rat_recoil", "all")
				end
			end,
			HandlerCode = function (self, unit)
				unit:RemoveStatusEffect("Rat_recoil", "all")
			end,
		}),
		PlaceObj('MsgActorReaction', {
			Event = "UnitBeginTurn",
			Handler = function (self, unit)
				local reaction_def = (self.msg_reactions or empty_table)[4]
				local actors = self:GetReactionActors("UnitBeginTurn", reaction_def, unit)
				for _, reaction_actor in ipairs(actors) do
					if self:VerifyReaction("UnitBeginTurn", reaction_def, reaction_actor, unit) then
						unit:RemoveStatusEffect("Rat_recoil", "all")
					end
				end
			end,
			HandlerCode = function (self, unit)
				unit:RemoveStatusEffect("Rat_recoil", "all")
			end,
		}),
		PlaceObj('MsgActorReaction', {
			ActorParam = "unit",
			Event = "UnitMovementDone",
			Handler = function (self, unit, action_id, prev_pos)
				local reaction_def = (self.msg_reactions or empty_table)[5]
				if self:VerifyReaction("UnitMovementDone", reaction_def, unit, unit, action_id, prev_pos) then
					local effect = unit:GetStatusEffect("Rat_recoil")
				
				
				
				local command = unit.action_command or ''
				if command == "RunAndGun" or command == "RecklessAssault" then
					unit:RemoveStatusEffect("Rat_recoil", "all")
					return
				end
				
				
				local current_pos = unit:GetPos()
				if not prev_pos or not current_pos then return end
				local dist = current_pos:Dist(prev_pos) or 0 
				local previous_dist = effect:ResolveValue("movement") or 0
				
				
				if (dist+previous_dist) >=const.SlabSizeX*3 then
					unit:RemoveStatusEffect("Rat_recoil", "all")
				else
					effect:SetParameter("movement", dist+previous_dist)
				end
				end
			end,
			HandlerCode = function (self, unit, action_id, prev_pos)
				local effect = unit:GetStatusEffect("Rat_recoil")
				
				
				
				local command = unit.action_command or ''
				if command == "RunAndGun" or command == "RecklessAssault" then
					unit:RemoveStatusEffect("Rat_recoil", "all")
					return
				end
				
				
				local current_pos = unit:GetPos()
				if not prev_pos or not current_pos then return end
				local dist = current_pos:Dist(prev_pos) or 0 
				local previous_dist = effect:ResolveValue("movement") or 0
				
				
				if (dist+previous_dist) >=const.SlabSizeX*3 then
					unit:RemoveStatusEffect("Rat_recoil", "all")
				else
					effect:SetParameter("movement", dist+previous_dist)
				end
			end,
		}),
	},
	unit_reactions = {
		PlaceObj('UnitReaction', {
			Event = "OnCalcChanceToHit",
			Handler = function (self, target, attacker, action, attack_target, weapon1, weapon2, data)
				if target == attacker and not const.Combat.Aperture.RecoilPersistOffset then
					local effect = target:GetStatusEffect("Rat_recoil")
					local target_pos =  IsValid(attack_target) and attack_target:GetPos() or attack_target
				
					local aim = data.aim or 0
					local stacks = self.stacks--effect:ResolveValue("shots_fired") or 1
				
					local recoil = get_recoil(attacker, attack_target, target_pos, action, weapon1, aim, false, stacks)
					local metaText = {}
					if recoil and aim > 0 then
						local multiplier = Min(aim,3)
						recoil = cRound(recoil * Max(0,(1 - (0.34 * multiplier))))
						local text_meta = "Aim" .. " (x" .. multiplier .. ")"
					    metaText[#metaText + 1] = T(text_meta)
					end
					if recoil > -1 then
						return
					end
					local cth_text = "Recoil (x" .. stacks.. ")"
					local recoil_cth = {id = "recoil_persistent", metaText = #metaText ~= 0 and metaText, name = T(cth_text), value = recoil}
					if data.modifiers then
						table.insert(data.modifiers, recoil_cth)
					end
					data.mod_add = data.mod_add + recoil
				end
			end,
		}),
		PlaceObj('UnitReaction', {
			Event = "OnCalcAPCost",
			Handler = function (self, target, current_ap, action, weapon, aim)
				local aim_level = Min(3,aim or 0)
				
				if aim_level < 1 then
					return
				end
				
				local aim_cost = self:ResolveValue("aim_cost") 
				local extra_cost = cRoundDown(aim_cost * aim_level) * const.Scale.AP
				
				return current_ap + extra_cost
			end,
		}),
	},
	DisplayName = T(644573309574, --[[ModItemCharacterEffectCompositeDef Rat_recoil DisplayName]] "Recoil"),
	Description = T(810661063156, --[[ModItemCharacterEffectCompositeDef Rat_recoil Description]] "Recoil accumulated from previous shots. Grants <color EmStyle>Accuracy penalty</color> to all firearm attacks. \n\nWill reach max penalty after <shots_fired_max> attacks.\n\nCan be <color EmStyle>negated by aiming up to three times</color>, but high recoil can increase the cost for doing so. Fully aimed (+3 aim level) attacks will also <color EmStyle>reset the stacks</color>. Manually cycled weapons have decreased aim cost penalty.\n\nCurrently increases aim cost - up to the third aim level - by <color EmStyle><aim_cost></color>.\n\nMoving 3 tiles, reloading, entering Overwatch or exiting Shooting Stance will remove this effect. "),
	type = "Debuff",
	lifetime = "Until End of Turn",
	Icon = "Mod/cfahRED/Images/reco10.png",
	max_stacks = 6,
	stacks = -1,
	RemoveOnEndCombat = true,
	Shown = true,
	HasFloatingText = true,
}


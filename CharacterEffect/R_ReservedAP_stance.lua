UndefineClass('R_ReservedAP_stance')
DefineClass.R_ReservedAP_stance = {
	__parents = { "CharacterEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	comment = "--- Check, I dont think this is used anymore",
	object_class = "CharacterEffect",
	unit_reactions = {
		PlaceObj('UnitReaction', {
			Event = "OnCalcStartTurnAP",
			Handler = function (self, target, value)
				
				if g_Combat or g_StartingCombat or g_TestingSaveLoadSystem then
					local ap_prev = (self:ResolveValue("ap_prev")) or 0
					local action_ap = (self:ResolveValue("action_ap_cost")) or 0
					local max_ap = (self:ResolveValue("max_ap_carried")* const.Scale.AP) or 0
					
					local extra_ap_on_turn = Min(max_ap, (ap_prev+action_ap))
					
				
					
					value = value + extra_ap_on_turn
					target:RemoveStatusEffect(self.class) -- remove immediately to unblock AP gain
				
					return value
				end
			end,
		}),
	},
	DisplayName = T(921616634109, --[[ModItemCharacterEffectCompositeDef R_ReservedAP_stance DisplayName]] "RESERVED AP"),
	OnAdded = function (self, obj)
		if g_Combat or g_StartingCombat or g_TestingSaveLoadSystem then
		
			local ap_prev = obj.ActionPoints
			self:SetParameter("ap_prev", ap_prev)
		
			if not obj.infinite_ap then
				obj.ActionPoints = 0
			end
			ObjModified(obj)
		end
	end,
}


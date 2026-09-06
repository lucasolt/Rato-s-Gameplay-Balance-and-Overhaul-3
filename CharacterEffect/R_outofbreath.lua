UndefineClass('R_outofbreath')
DefineClass.R_outofbreath = {
	__parents = { "StatusEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "StatusEffect",
	msg_reactions = {
		PlaceObj('MsgReaction', {
			Event = "GatherCTHModifications",
			Handler = function (self, attacker, cth_id, action_id, target, weapon1, weapon2, data)
				if attacker:HasStatusEffect(self.id) and cth_id == "Aim" then
					data.mod_mul = MulDivRound(data.mod_mul or 100, const.Combat.Perks.OutOfBreathAimMul, 100)
					local meta = self.DisplayName
					table.insert(data.meta_text or {}, meta)
				end
			end,
		}),
	},
	unit_reactions = {
		PlaceObj('UnitReaction', {
			Event = "OnCalcStartTurnAP",
			Handler = function (self, target, value)
				local reduc = self:ResolveValue("ap_loss") * self.stacks * const.Scale.AP
				
				return value + reduc
			end,
		}),
		PlaceObj('UnitReaction', {
			Event = "OnCalcFreeMove",
			Handler = function (self, target, data)
				local reduc= (self:ResolveValue("free_move_mul_reduction") or 50) * (self.stacks or 1)
				
				data.mul = Max(0, data.mul - reduc)
			end,
		}),
		PlaceObj('UnitReaction', {
			Event = "OnEndTurn",
			Handler = function (self, target)
				local duration = (self:ResolveValue("duration") or 1)
				duration = duration - 1
				if duration < 0 then
					target:RemoveStatusEffect(self.class, "all")
					return
				end
				
				self:SetParameter("duration", duration)
			end,
		}),
	},
	Modifiers = {},
	DisplayName = T(373983661042, --[[ModItemCharacterEffectCompositeDef R_outofbreath DisplayName]] "Out of Breath"),
	Description = T(981332796704, --[[ModItemCharacterEffectCompositeDef R_outofbreath Description]] "Penalty of <color EmStyle><ap_loss></color> per stack is applied to your maximum AP. Reduces <color EmStyle>Free Move AP</color> per stack. Normally, lasts until the end of your next turn, but low energy levels can increase the duration.\n\nDecreases the effectiveness of Aiming accuracy bonus.\n\nCurrent duration: <em><duration></em>"),
	GetDescription = function (self)
		return self.Description
	end,
	AddEffectText = T(132260163193, --[[ModItemCharacterEffectCompositeDef R_outofbreath AddEffectText]] "<color EmStyle><DisplayName></color> is out of breath"),
	OnAdded = function (self, obj)
		obj:RemoveStatusEffect("FreeMove")
		
		if (obj.Tiredness or 0) > 0 then
				local effect = obj:GetStatusEffect(self.class)
				if effect then
					effect:SetParameter("duration", obj.Tiredness + 1)
				end
		end
	end,
	type = "Debuff",
	Icon = "Mod/cfahRED/Images/out_of_breath.dds",
	max_stacks = 2,
	RemoveOnEndCombat = true,
	RemoveOnSatViewTravel = true,
	RemoveOnCampaignTimeAdvance = true,
	Shown = true,
	ShownSatelliteView = true,
	HasFloatingText = true,
}


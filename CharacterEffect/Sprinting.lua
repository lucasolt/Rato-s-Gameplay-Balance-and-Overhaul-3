UndefineClass('Sprinting')
DefineClass.Sprinting = {
	__parents = { "CharacterEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "CharacterEffect",
	unit_reactions = {
		PlaceObj('UnitReaction', {
			Event = "OnCalcChanceToHit",
			Handler = function (self, target, attacker, action, attack_target, weapon1, weapon2, data)
				if target == attack_target then
					ApplyCthModifier_Add(self, data, const.Combat.SprintingCTH)
				end
			end,
		}),
		PlaceObj('UnitReaction', {
			Event = "OnBeginTurn",
			Handler = function (self, target)
				target:RemoveStatusEffect(self.class)
			end,
		}),
		PlaceObj('UnitReaction', {
			Event = "OnCombatEnd",
			Handler = function (self, target)
				target:RemoveStatusEffect(self.class)
			end,
		}),
	},
	DisplayName = T(889022208419, --[[ModItemCharacterEffectCompositeDef Sprinting DisplayName]] "Sprinting"),
	Description = T(519374788491, --[[ModItemCharacterEffectCompositeDef Sprinting Description]] "The character is sprinting and is harder to hit."),
	Icon = "Mod/cfahRED/Images/sprint 3.dds",
	RemoveOnEndCombat = true,
	RemoveOnSatViewTravel = true,
	RemoveOnCampaignTimeAdvance = true,
	Shown = true,
	HasFloatingText = true,
}


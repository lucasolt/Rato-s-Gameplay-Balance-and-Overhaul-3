UndefineClass('Rat_Settled')
DefineClass.Rat_Settled = {
	__parents = { "StatusEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "StatusEffect",
	DisplayName = T(483920175340, --[[ModItemCharacterEffectCompositeDef Rat_Settled DisplayName]] "Settled"),
	Description = T(483920175341, --[[ModItemCharacterEffectCompositeDef Rat_Settled Description]] "In position. Each stack improves every aim level of the <color EmStyle>first attack</color> this turn (<color EmStyle>Sharpshooter</color>). Moving removes all stacks."),
	type = "Buff",
	Icon = "Mod/cfahRED/Images/status_Settled.png",
	max_stacks = 2,
	RemoveOnEndCombat = true,
	RemoveOnSatViewTravel = true,
	RemoveOnCampaignTimeAdvance = true,
	Shown = true,
}

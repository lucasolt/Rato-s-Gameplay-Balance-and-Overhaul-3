function OnMsg.ClassesGenerate()

    AppendClass.WeaponComponentSharedClass = {
        properties = {
            {
                category = "GBO",
                id = "GBO_ComponentAncestor",
                name = "Component Ancestor",
                help = "Will inherit ComponentEffects and Params, not visuals or displayname",
                editor = "text",
                default = "",
                template = true,
                modifiable = true
            },
			{
                category = "GBO",
                id = "GBO_ComponentTraits",
                name = "Component Traits",
                help = "Comma separated trait ids (GBO_COMP_TRAITS). Composed into effects and params; overrides the code side map",
                editor = "text",
                default = "",
                template = true,
                modifiable = true
            },
			{
                category = "GBO",
                id = "GBO_ComponentOverride",
                name = "Component Override",
                help = "Per-component tweak applied AFTER the traits, so a trait never clobbers it. " ..
                       "Comma separated: Param=123 sets, Param=nil removes, +EffectId forces present, " ..
                       "-EffectId forces absent. Needs at least one trait to do anything. " ..
                       "Prefer canonical param names (OverwatchAngle, not OverwatchAngleIncrease)",
                editor = "text",
                default = "",
                template = true,
                modifiable = true
            },
	}}
end
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
	}}
end
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
                id = "GBO_BarrelWeight",
                --name = "GBO_BarrelWeight",
                help = "",
                editor = "text",
                default = "",
                template = true,
                modifiable = true
            }
	}}
end
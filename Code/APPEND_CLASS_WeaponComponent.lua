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
			---- Override individual: mesmos editores de ModificationEffects e Parameters, para o
			---- ajuste de UM componente nao virar um traco novo. Entra DEPOIS dos tracos e da
			---- optica, com semantica de sobrescrita. So vale em componente que tenha traco.
			{
                category = "GBO",
                id = "GBO_OverrideEffects",
                name = "Override Effects (add)",
                help = "Effects forced PRESENT after the traits compose. Their required params must end up in the composed result -- author them in Override Params",
                editor = "preset_id_list",
                default = {},
                preset_class = "WeaponComponentEffect",
                item_default = "",
                template = true,
                modifiable = true
            },
			{
                category = "GBO",
                id = "GBO_OverrideRemoveEffects",
                name = "Override Effects (remove)",
                help = "Effects forced ABSENT after the traits compose, even when a trait asks for them",
                editor = "preset_id_list",
                default = {},
                preset_class = "WeaponComponentEffect",
                item_default = "",
                template = true,
                modifiable = true
            },
			{
                category = "GBO",
                id = "GBO_OverrideParams",
                name = "Override Params",
                help = "Params that overwrite whatever the traits produced. Number or percent picks how it is written, same as Parameters",
                editor = "nested_list",
                default = false,
                base_class = "PresetParam",
                template = true,
                modifiable = true
            },
	}}
end

---- Aviso do editor. O vanilla so olha ModificationEffects x Parameters, que num componente
---- composto estao VAZIOS na fonte -- a verdade e o resultado da composicao. Entao checa-se o
---- composto: pega todo efeito com RequiredParams e cobra o param de quem quer que o forneca
---- (traco, optica ou override). Tambem e o que pega param orfao no override.
function OnMsg.ClassesBuilt()
    local vanilla = WeaponComponent.GetWarning

    function WeaponComponent:GetWarning()
        local warn = vanilla and vanilla(self)
        if warn then
            return warn
        end

        ---- _G.X e nao rawget: rawget nao ve global neste motor. E a chamada fica solta, porque
        ---- `f and f(x)` truncaria o segundo retorno.
        local compose = _G.GBO_ComposeForWarning
        if not compose then
            return
        end
        local effects, params = compose(self.id, self)
        if not effects then
            return
        end
        for _, eff_id in ipairs(effects) do
            local eff = WeaponComponentEffects[eff_id]
            for _, name in ipairs(eff and eff.RequiredParams or empty_table) do
                if params[name] == nil then
                    return "GBO compose: missing param " .. name .. " for effect " .. eff_id
                end
            end
        end
    end
end

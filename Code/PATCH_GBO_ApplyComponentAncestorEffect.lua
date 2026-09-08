function GBO_ApplyComponentAncestorEffect()
	print("Running GBO_ApplyComponentAncestorEffect...")
	for id, eff in pairs(WeaponComponents) do
		if eff.GBO_ComponentAncestor and WeaponComponents[eff.GBO_ComponentAncestor] then
			WeaponComponents[id].ModificationEffects = table.copy(WeaponComponents[eff.GBO_ComponentAncestor].ModificationEffects)
			WeaponComponents[id].Parameters = table.copy(WeaponComponents[eff.GBO_ComponentAncestor].Parameters)
			--WeaponComponents[id].Visuals = table.copy(WeaponComponents["_Master_MagLargeFine"].Visuals)
			WeaponComponents[id]:PostLoad()
		end
	end
	print("GBO_ApplyComponentAncestorEffect done")
end
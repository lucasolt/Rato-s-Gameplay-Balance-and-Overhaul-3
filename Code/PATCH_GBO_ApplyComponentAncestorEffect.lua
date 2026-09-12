---- Heranca por copia: o descendente recebe as tabelas do ancestral inteiras. Roda DEPOIS do
---- compositor (ver GBO_GeneralComponentPatch), entao quem tem traco proprio fica de fora --
---- senao a copia sobrescrevia a composicao em silencio e o traco nao valia nada.
---- Precedencia, uma linha: TRACO ganha de ANCESTRAL.
function GBO_ApplyComponentAncestorEffect()
	print("Running GBO_ApplyComponentAncestorEffect...")
	local has_traits = _G.GBO_HasTraits
	local n, skipped = 0, 0
	for id, comp in pairs(WeaponComponents) do
		local anc = comp.GBO_ComponentAncestor
		local src = anc and anc ~= "" and WeaponComponents[anc]
		if src then
			if has_traits and has_traits(id, comp) then
				skipped = skipped + 1
			else
				comp.ModificationEffects = table.copy(src.ModificationEffects)
				comp.Parameters = table.copy(src.Parameters)
				comp:PostLoad()
				n = n + 1
			end
		end
	end
	print("GBO_ApplyComponentAncestorEffect done: " .. n .. " herdados, " .. skipped ..
	      " com traco proprio (compositor ganha)")
end

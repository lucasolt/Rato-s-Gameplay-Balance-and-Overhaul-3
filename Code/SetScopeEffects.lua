--------------------------------------------------------------------------------------------------
---- Override de opticas SO enquanto o aperture esta ligado (A.Enabled). Mexe apenas nas chaves
---- listadas por perfil; o resto do componente (custo, visuais, outros efeitos) fica intacto.
----
---- O "pristino" e HARDCODADO em RAT_SCOPE_ORIGINALS abaixo -- NAO lido do preset em runtime.
---- Motivo: WeaponComponents nao e gerado por PlaceObj de preset toda hora; e a mesma tabela viva.
---- Se o apply mutasse e o editor salvasse o mod, os valores do aperture vazariam pro items.lua.
---- Com a fonte hardcodada, apply e restore sao deterministicos e o items.lua nunca e a verdade.
----
---- Restaura: Rat_RestoreApertureItemParams(). Reaplica em armas em campo: Rat_ReapplyApertureComponents().
--------------------------------------------------------------------------------------------------

local A = const.Combat.Aperture

---- Perfis por ampliacao. Parameters = {NomeDoParam = valor_inteiro} (param % usa o inteiro cru,
---- 150 = 150%). ModificationEffects = {EffectId = true garante presente | false garante ausente}.
---- Efeito de "niveis de mira" = IncreaseMaxAimActions (param MaxAimActionsIncrease); "range" da
---- optica = IncreaseRange (param RangeIncrease).
A.ApertureMagnifications = {
	_6x = {
		Parameters = { MaxAimActionsIncrease = 3 },
		ModificationEffects = { IncreaseMaxAimActions = true, IncreaseRange = false },
	},
	_4x = {
		Parameters = { MaxAimActionsIncrease = 2 },
		ModificationEffects = { IncreaseMaxAimActions = true, IncreaseRange = false },
	},
	_2x = {
		Parameters = { MaxAimActionsIncrease = 1 },
		ModificationEffects = { BonusAccuracyWhenFullyAimed = true, IncreaseMaxAimActions = true, IncreaseRange = false, IncreaseAimAccuracy = false },
	},
	_1dot5x = {
		Parameters = { MaxAimActionsIncrease = 1 },
		ModificationEffects = { IncreaseMaxAimActions = true, IncreaseRange = false, IncreaseAimAccuracy = false },
	},
	Reflex = {}, -- nao muda nada; fica aqui so para marcar intencao
}

---- Componente -> perfil. Componente ausente daqui nao e tocado. Chute inicial de tiers:
A.ApertureComponentTier = {
	ReflexSight               = "Reflex",
	ReflexSightAdvanced       = "Reflex",
	ReflexSightAdvanced_Glock = "Reflex",
	_ReflexSIghtVigilance     = "Reflex",
	ImprovedIronsight         = "Reflex",
	G36_SCOPE                 = "_2x",
	SCOPE_G36_2               = "_2x",
	AUGScope_Default          = "_1dot5x",
	WideScope                 = "_2x",
	ScopeCOG                  = "_2x",
	ScopeCOGQuick             = "_2x",
	LROptics                  = "_4x",
	LROptics_DragunovDefault  = "_4x",
	ThermalScope              = "_4x",
	LROpticsAdvanced          = "_6x",
	PSG_DefaultScope          = "_6x",
}

---------------------------------------------------------------------------------------------------
---- PRISTINO HARDCODADO -- transcrito do items.lua (folder "Scopes"). effects em ordem de autoria,
---- params por nome. So o que o restore/apply precisa; visuais, custo e tags ficam no preset.
---------------------------------------------------------------------------------------------------
RAT_SCOPE_ORIGINALS = {
	PSG_DefaultScope = {
		effects = { "IncreaseMaxAimActions", "IncreaseRange", "ScopePenalty3", "DecreaseOverwatchAngle", "bodypart_scope" },
		params = { MaxAimActionsIncrease = 1, RangeIncrease = 16, crit = 15, OverwatchAngleDecrease = 50, APincrease = 1 },
	},
	ThermalScope = {
		effects = { "IgnoreInTheDarkWhenFullyAimed", "IgnoreCoverCtHWhenFullyAimed", "IgnoreLightOfSightWhenFullyAimed", "IgnoreGrazingHitsWhenFullyAimed", "IncreaseRange", "ScopePenalty2", "DecreaseOverwatchAngle" },
		params = { RangeIncrease = 10, OverwatchAngleDecrease = 50, APincrease = 1 },
	},
	SCOPE_G36_2 = {
		effects = { "CritBonusWhenFullyAimed", "ScopePenalty1", "IncreaseRange", "IgnoreInTheDarkWhenFullyAimed", "DecreaseOverwatchAngle", "IncreaseAimAccuracy" },
		params = { RangeIncrease = 10, AimAccuracyIncrease = 2, crit = 15, OverwatchAngleDecrease = 75 },
	},
	G36_SCOPE = {
		effects = { "CritBonusWhenFullyAimed", "ScopePenalty1", "IncreaseRange", "IgnoreInTheDarkWhenFullyAimed", "DecreaseOverwatchAngle", "IncreaseAimAccuracy" },
		params = { crit = 15, AimAccuracyIncrease = 2, RangeIncrease = 6, OverwatchAngleDecrease = 75 },
	},
	AUGScope_Default = {
		effects = { "IncreaseAimAccuracy", "IncreaseRange", "DecreaseOverwatchAngle" },
		params = { AimAccuracyIncrease = 3, RangeIncrease = 4, OverwatchAngleDecrease = 90 },
	},
	_ReflexSIghtVigilance = {
		effects = { "OpportunityAttackBonusCth", "IncreaseOverwatchAngle", "scope_snapshot", "reflex_sight_close_range", "AccuracyBonusWhenAimed" },
		params = { bonus_cth = 3, bonus_cth_interrupt = 10, OverwatchAngleIncrease = 125, Close_bonus = 5, snap_reduc = 10, RangeIncrease = 4 },
	},
	ReflexSightAdvanced_Glock = {
		effects = { "first_aim_crit", "IncreaseOverwatchAngle", "scope_snapshot", "reflex_sight_close_range", "AccuracyBonusWhenAimed" },
		params = { RangeIncrease = 2, OverwatchAngleIncrease = 115, Close_bonus = 5, bonus_cth = 3, snap_reduc = 10 },
	},
	ReflexSightAdvanced = {
		effects = { "IncreaseOverwatchAngle", "first_aim_crit", "scope_snapshot", "reflex_sight_close_range", "AccuracyBonusWhenAimed" },
		params = { RangeIncrease = 4, bonus_cth = 3, OverwatchAngleIncrease = 125, Close_bonus = 5, snap_reduc = 10 },
	},
	ReflexSight = {
		effects = { "AccuracyBonusWhenAimed", "IncreaseOverwatchAngle", "reflex_sight_close_range", "scope_snapshot" },
		params = { RangeIncrease = 2, OverwatchAngleIncrease = 115, Close_bonus = 10, bonus_cth = 3, snap_reduc = 10 },
	},
	ScopeCOG = {
		effects = { "IncreaseRange", "ScopePenalty1", "DecreaseOverwatchAngle", "critical_per_aim_scope", "IncreaseAimAccuracy" },
		params = { RangeIncrease = 6, OverwatchAngleDecrease = 90, AimAccuracyIncrease = 2 },
	},
	ScopeCOGQuick = {
		effects = { "FirstAimBonusModifier", "IncreaseRange", "ScopePenalty1", "IncreaseAimAccuracy", "scope_snapshot", "IncreaseOverwatchAngle" },
		params = { RangeIncrease = 6, AimAccuracyIncrease = 2, snap_reduc = 5, OverwatchAngleIncrease = 110 },
	},
	WideScope = {
		effects = { "OpportunityAttackBonusCth", "IncreaseRange", "ScopePenalty1", "IncreaseAimAccuracy", "scope_snapshot" },
		params = { bonus_cth_interrupt = 8, AimAccuracyIncrease = 2, RangeIncrease = 6, snap_reduc = 5 },
	},
	LROptics_DragunovDefault = {
		effects = { "IncreaseRange", "pso_dragunov_scope_critical", "ScopePenalty2", "DecreaseOverwatchAngle", "pso_dragunov_scope", "IncreaseMaxAimActions" },
		params = { crit_bonus = 15, MaxAimActionsIncrease = 1, RangeIncrease = 10, OverwatchAngleDecrease = 68, APincrease = 1 },
	},
	LROptics = {
		effects = { "IncreaseMaxAimActions", "IncreaseRange", "ScopePenalty2", "DecreaseOverwatchAngle", "sniper_aim_scope" },
		params = { MaxAimActionsIncrease = 1, RangeIncrease = 10, OverwatchAngleDecrease = 65, APincrease = 1 },
	},
	LROpticsAdvanced = {
		effects = { "IncreaseMaxAimActions", "IncreaseRange", "ScopePenalty3", "DecreaseOverwatchAngle", "sniper_adv_aim_scope" },
		params = { MaxAimActionsIncrease = 2, RangeIncrease = 16, OverwatchAngleDecrease = 50, APincrease = 1 },
	},
	ImprovedIronsight = {
		effects = { "AccuracyBonusWhenAimed" },
		params = { bonus_cth = 3 },
	},
}

---- params autorados como PresetParamPercent no items.lua (so muda o tipo do PlaceObj / a tag).
local RAT_PCT = { crit = true, crit_bonus = true, bonus_cth_interrupt = true }

---- reescreve ModificationEffects/Parameters do preset e refaz o cache de params (g_PresetParamCache
---- e o que ResolveValue le; PostLoad o reconstroi).
local function aperture_write(comp, effects, params_map)
	comp.ModificationEffects = effects

	local list = {}
	for name, value in sorted_pairs(params_map) do
		local cls = RAT_PCT[name] and 'PresetParamPercent' or 'PresetParamNumber'
		local tag = RAT_PCT[name] and ("<" .. name .. ">%") or ("<" .. name .. ">")
		list[#list + 1] = PlaceObj(cls, { 'Name', name, 'Value', value, 'Tag', tag })
	end
	comp.Parameters = list

	g_PresetParamCache[comp] = nil
	comp:PostLoad()
end

---- Escreve um id a partir do pristino hardcodado + overrides (nil = so o pristino).
local function apply_one(id, tier)
	local orig = RAT_SCOPE_ORIGINALS[id]
	local comp = WeaponComponents[id]
	if not orig then
		print("GBO aperture: sem pristino hardcodado para", id)
		return
	end
	if not comp then
		print("GBO aperture: componente inexistente", id)
		return
	end

	local eff_override = tier and tier.ModificationEffects or empty_table
	local par_override = tier and tier.Parameters or empty_table

	---- efeitos: pristino, tira os marcados false, poe os marcados true que faltam (mantem ordem)
	local effects, seen = {}, {}
	for _, e in ipairs(orig.effects) do
		if eff_override[e] ~= false then
			effects[#effects + 1] = e
			seen[e] = true
		end
	end
	for e, want in pairs(eff_override) do
		if want and not seen[e] then effects[#effects + 1] = e end
	end

	---- params: pristino + overrides do perfil
	local params = {}
	for name, value in pairs(orig.params) do params[name] = value end
	for name, value in pairs(par_override) do params[name] = value end

	aperture_write(comp, effects, params)
end

---- Volta TODA optica conhecida ao pristino hardcodado (ignora tiers).
function Rat_RestoreApertureItemParams()
	for id in pairs(RAT_SCOPE_ORIGINALS) do
		apply_one(id, nil)
	end
end

function ApplyApertureItemParams()
	if not A or not A.Enabled then
		return Rat_RestoreApertureItemParams()
	end
	for id, tier_name in pairs(A.ApertureComponentTier) do
		apply_one(id, A.ApertureMagnifications[tier_name])
	end
end

---- Empurra o override para as armas ja equipadas em campo, sem esperar UnitCreated.
function Rat_ReapplyApertureComponents()
	local n = 0
	for _, u in ipairs(g_Units or empty_table) do
		if IsValid(u) then
			for _, wslot in ipairs({ "Handheld A", "Handheld B" }) do
				for _, w in ipairs(u:GetEquippedWeapons(wslot) or empty_table) do
					if IsKindOf(w, "Firearm") and w.components then
						for cslot, cid in sorted_pairs(w.components) do
							if RAT_SCOPE_ORIGINALS[cid] and WeaponComponents[cid] then
								w:SetWeaponComponent(cslot, cid)
								n = n + 1
							end
						end
						w.rat_updated_in = nil
						ObjModified(w)
					end
				end
			end
			u.combat_cache = nil
		end
	end
	return "aperture: reaplicado em " .. n .. " componentes"
end

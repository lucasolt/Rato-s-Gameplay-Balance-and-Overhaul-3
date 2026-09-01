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

--- Refactored Scopes
---- `from` tem que cair onde ainda SOBRA gap: com acc 9 restam ~10% do gap no nivel 4 e ~2% no 5,
---- entao um bonus grande e tardio nao move nada (medido: +8 no nivel 5 = 0 tiles depois do
---- arredondamento inteiro). Os `from` batem com o texto ja escrito nos WeaponComponentEffect.
A.ComponentEffectsAimBonus = {
    {id = "pso_dragunov_scope", from = 2, acc = 2},
    {id = "sniper_aim_scope", from = 3, acc = 3},
	{id = "sniper_adv_aim_scope", from = 4, acc = 4},
    ---- Forward Grip: so o PRIMEIRO nivel -- e o "aponta rapido" dele, nao um ganho permanente.
    {id = "FirstAimBonusModifier", from = 1, to = 1, acc = 3},
	{id = "BonusAccuracyWhenFullyAimed", from = 3, to = 3, acc = 4}
}

---- A CEREJA da optica: multiplicador do PISO do cone por ampliacao (Rat_ApertureFloor). E a unica
---- coisa que move a ASSINTOTA, e a assintota e todo o cone que sobra com mira cheia. Nao mexe em
---- WeaponRange, entao alcance maximo, custo de AP, checagem de fora de alcance e IA ficam iguais:
---- e "alcance so com mira cheia". Invisivel no aim 0-1 (la o cone e ~10x o piso). MENOR = melhor.
A.ScopeFloorMul = {
	_6x = 87,
	_4x = 92,
	_2x = 96,
	_1dot5x = 98,
	Reflex = 100,
	Ironsight = 100,
}

---- Miras (AccuracyBonusWhenAimed): o `bonus_cth` autorado no componente vira multiplicador de
---- cone, aplicado uma vez com aim >= 1. false = inerte.
A.SightAimBonus = true



---- Perfis por ampliacao. Parameters = {NomeDoParam = valor_inteiro} (param % usa o inteiro cru,
---- 150 = 150%). ModificationEffects = {EffectId = true garante presente | false garante ausente}.
---- Efeito de "niveis de mira" = IncreaseMaxAimActions (param MaxAimActionsIncrease); "range" da
---- optica = IncreaseRange (param RangeIncrease).
A.ApertureMagnifications = {
	---- IncreaseAimAccuracy sai de TODAS: AimAccuracy crua e stat de arma. O que a optica da em
	---- precisao vem pelos limiares de A.ComponentEffectsAimBonus, que so valem a partir de `from`.
	_6x = {
		Parameters = { MaxAimActionsIncrease = 3 },
		ModificationEffects = { IncreaseMaxAimActions = true, IncreaseRange = false, IncreaseAimAccuracy = false },
	},
	_4x = {
		Parameters = { MaxAimActionsIncrease = 2 },
		ModificationEffects = { IncreaseMaxAimActions = true, IncreaseRange = false, IncreaseAimAccuracy = false },
	},
	_2x = {
		Parameters = { MaxAimActionsIncrease = 1 },
		ModificationEffects = { BonusAccuracyWhenFullyAimed = true, IncreaseMaxAimActions = true, IncreaseRange = false, IncreaseAimAccuracy = false },
	},
	_1dot5x = {
		Parameters = { MaxAimActionsIncrease = 1 },
		ModificationEffects = { IncreaseMaxAimActions = true, IncreaseRange = false, IncreaseAimAccuracy = false },
	},
	Reflex = {},
	Ironsight = {
		Parameters = {bonus_cth = 3},
		ModificationEffects = {AccuracyBonusWhenAimed = true},
	}, -- nao muda nada; fica aqui so para marcar intencao
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

	---- Opticas de ToG / armas modadas que ficavam de fora: continuavam dando IncreaseRange
	---- (SSG69 +16, VSS/SteyrS/PSO-1M2/m76/thermal +10, G11/GW43 +4) e nenhum nivel de mira novo.
	---- Os `_Master_*` sao os templates de onde as variantes herdam -- os dois lados precisam entrar.
	SSG69_Scope_1             = "_6x",
	_Master_SSG69_Scope_TOG   = "_6x",
	NTW_20_Scope_1            = "_6x",
	WA2000_Scope_1            = "_6x",
	VSS_Scope_1               = "_4x",
	["_Master_PSO-1M2_Scope_TOG"] = "_4x",
	SteyrS_Scope_1            = "_4x",
	_Master_SteyrS_Scope_TOG  = "_4x",
	m76_scope_1               = "_4x",
	_Master_m76_scope_TOG     = "_4x",
	ThermalScope_1            = "_4x",
	ThermalScope_2            = "_4x",
	AWP_Scope_1               = "_4x",
	GW43_Scope_1              = "_2x",
	_Master_GW43_Scope_TOG    = "_2x",
	Caws_Scope_1              = "_2x",
	G11_Rail_9                = "_2x",
	G11_Scope_1               = "_1dot5x",
	_Master_G11_Scope_1       = "_1dot5x",
	AN94_Scope_1              = "_1dot5x",
	FN2000_Scope_1            = "_1dot5x",
	G11_Rail_7                = "_1dot5x",
	TAR21_Scope_Rflx_1        = "Reflex",
	ImprovedIronsight_AR15    = "Reflex",
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

	---- Opticas de ToG / armas modadas. Lidas do processo vivo ANTES de qualquer override
	---- (nao estavam em ApertureComponentTier, entao o que estava em memoria era o pristino).
	SSG69_Scope_1 = {
		effects = { "IncreaseRange", "IncreaseMaxAimActions", "CritBonusWhenFullyAimed", "ScopePenalty3", "DecreaseOverwatchAngle" },
		params = { RangeIncrease = 16, MaxAimActionsIncrease = 1, crit = 20, OverwatchAngleDecrease = 60 },
	},
	_Master_SSG69_Scope_TOG = {
		effects = { "IncreaseRange", "IncreaseMaxAimActions", "CritBonusWhenFullyAimed", "ScopePenalty3", "DecreaseOverwatchAngle" },
		params = { RangeIncrease = 16, MaxAimActionsIncrease = 1, crit = 20, OverwatchAngleDecrease = 60 },
	},
	VSS_Scope_1 = {
		effects = { "pso_dragunov_scope", "IncreaseRange", "ScopePenalty2", "DecreaseOverwatchAngle", "StealthKillBonusPerAim", "IncreaseMaxAimActions" },
		params = { RangeIncrease = 10, OverwatchAngleDecrease = 60, APincrease = 1, stealth_kill_bonus = 6, MaxAimActionsIncrease = 1 },
	},
	["_Master_PSO-1M2_Scope_TOG"] = {
		effects = { "pso_dragunov_scope", "IncreaseRange", "ScopePenalty2", "DecreaseOverwatchAngle", "StealthKillBonusPerAim", "IncreaseMaxAimActions" },
		params = { RangeIncrease = 10, OverwatchAngleDecrease = 60, APincrease = 1, stealth_kill_bonus = 6, MaxAimActionsIncrease = 1 },
	},
	SteyrS_Scope_1 = {
		effects = { "pso_dragunov_scope", "IncreaseMaxAimActions", "ScopePenalty2", "scout_scope_crit", "IncreaseRange", "DecreaseOverwatchAngle" },
		params = { RangeIncrease = 10, OverwatchAngleDecrease = 60, APincrease = 1, MaxAimActionsIncrease = 1, critical_head = 15 },
	},
	_Master_SteyrS_Scope_TOG = {
		effects = { "pso_dragunov_scope", "IncreaseMaxAimActions", "ScopePenalty2", "scout_scope_crit", "IncreaseRange", "DecreaseOverwatchAngle" },
		params = { RangeIncrease = 10, OverwatchAngleDecrease = 60, APincrease = 1, MaxAimActionsIncrease = 1, critical_head = 15 },
	},
	m76_scope_1 = {
		effects = { "IncreaseMaxAimActions", "IncreaseRange", "DecreaseOverwatchAngle", "ScopePenalty2", "pso_dragunov_scope", "zrak_scope_crit" },
		params = { MaxAimActionsIncrease = 1, RangeIncrease = 10, OverwatchAngleDecrease = 68, crit_torso = 12 },
	},
	_Master_m76_scope_TOG = {
		effects = { "IncreaseMaxAimActions", "IncreaseRange", "DecreaseOverwatchAngle", "ScopePenalty2", "pso_dragunov_scope", "zrak_scope_crit" },
		params = { MaxAimActionsIncrease = 1, RangeIncrease = 10, OverwatchAngleDecrease = 68, crit_torso = 12 },
	},
	ThermalScope_1 = {
		effects = { "IgnoreInTheDarkWhenFullyAimed", "IgnoreCoverCtHWhenFullyAimed", "IgnoreLightOfSightWhenFullyAimed", "IgnoreGrazingHitsWhenFullyAimed", "IncreaseRange", "ScopePenalty2", "DecreaseOverwatchAngle" },
		params = { RangeIncrease = 10, OverwatchAngleDecrease = 55, APincrease = 1 },
	},
	ThermalScope_2 = {
		effects = { "IgnoreInTheDarkWhenFullyAimed", "IgnoreCoverCtHWhenFullyAimed", "IgnoreLightOfSightWhenFullyAimed", "IgnoreGrazingHitsWhenFullyAimed", "IncreaseRange", "ScopePenalty2", "DecreaseOverwatchAngle" },
		params = { RangeIncrease = 10, OverwatchAngleDecrease = 55, APincrease = 1 },
	},
	G11_Scope_1 = {
		effects = { "IncreaseRange", "AccuracyBonusWhenAimed" },
		params = { RangeIncrease = 4, bonus_cth = 10 },
	},
	_Master_G11_Scope_1 = {
		effects = { "IncreaseRange", "AccuracyBonusWhenAimed" },
		params = { RangeIncrease = 4, bonus_cth = 10 },
	},
	GW43_Scope_1 = {
		effects = { "AccuracyBonusWhenAimed", "DecreaseOverwatchAngle", "IncreaseRange" },
		params = { RangeIncrease = 4, bonus_cth = 15, OverwatchAngleDecrease = 85 },
		pct = { bonus_cth = true },
	},
	_Master_GW43_Scope_TOG = {
		effects = { "AccuracyBonusWhenAimed", "DecreaseOverwatchAngle", "IncreaseRange" },
		params = { RangeIncrease = 4, bonus_cth = 15, OverwatchAngleDecrease = 85 },
		pct = { bonus_cth = true },
	},
	AWP_Scope_1 = {
		effects = { "IncreaseAimAccuracy", "IncreaseMaxAimActions" },
		params = { AimAccuracyIncrease = 3, MaxAimActionsIncrease = 1 },
	},
	NTW_20_Scope_1 = {
		effects = { "IncreaseAimAccuracy", "IncreaseMaxAimActions" },
		params = { AimAccuracyIncrease = 3, MaxAimActionsIncrease = 1 },
	},
	WA2000_Scope_1 = {
		effects = { "IncreaseAimAccuracy", "IncreaseMaxAimActions", "CritBonusWhenFullyAimed" },
		params = { AimAccuracyIncrease = 5, MaxAimActionsIncrease = 1, crit = 5 },
	},
	Caws_Scope_1 = {
		effects = { "IncreaseAimAccuracy", "IncreaseMaxAimActions", "CritBonusWhenFullyAimed" },
		params = { AimAccuracyIncrease = 2, MaxAimActionsIncrease = 1, crit = 2 },
	},
	AN94_Scope_1 = {
		effects = { "IncreaseMaxAimActions" },
		params = { MaxAimActionsIncrease = 1 },
	},
	FN2000_Scope_1 = {
		effects = { "IncreaseMaxAimActions" },
		params = { MaxAimActionsIncrease = 1 },
	},
	G11_Rail_7 = {
		effects = { "IncreaseMaxAimActions" },
		params = { MaxAimActionsIncrease = 1 },
	},
	G11_Rail_9 = {
		effects = { "IncreaseAimAccuracy", "IncreaseMaxAimActions" },
		params = { AimAccuracyIncrease = 3, MaxAimActionsIncrease = 1 },
	},
	TAR21_Scope_Rflx_1 = {
		effects = { "IncreaseOverwatchAngle", "hipfire_dot_effect_laser", "IncreaseCritChangeScaled", "critical_per_aim_laser", "reflex_sight_close_range", "AccuracyBonusWhenAimed" },
		params = { bonus_cth = 10, OverwatchAngleIncrease = 130, Close_bonus = 5, snap_reduc = 15, CritChangeScaledIncrease = 10 },
	},
	ImprovedIronsight_AR15 = {
		effects = { "AccuracyBonusWhenAimed" },
		params = { bonus_cth = 5 },
		pct = { bonus_cth = true },
	},
}

---------------------------------------------------------------------------------------------------
---- ALCANCE DAS ARMAS no aCTH. Opticas nao dao mais WeaponRange, entao o alcance volta a ser
---- propriedade da ARMA -- e e a assintota do cone (d50 maximo = 1.545 x WeaponRange). Esticado no
---- topo da escala: +55% do que passa de 20 tiles em snipers (teto 44), +35% MG, +30% fuzil,
---- +15% SMG, 0 em pistola/revolver/escopeta. {pristino, valor_no_aCTH}.
---- SO vale com o aperture ligado; Rat_RestoreApertureItemParams devolve o pristino.
---------------------------------------------------------------------------------------------------
RAT_APERTURE_WEAPON_RANGE = {
	---- Snipers / marksman
	BarretM82                = { 40, 44},
	PSG1                     = { 34, 42},
	M24Sniper                = { 32, 39},
	SSG69_1                  = { 32, 39},
	DragunovSVD              = { 30, 36},
	Gewehr98                 = { 30, 36},
	GoldenGun                = { 30, 36},
	M76_1                    = { 30, 36},
	Gewehr43_1               = { 28, 32},
	Mosin_1                  = { 28, 32},
	SteyrScout_1             = { 28, 32},
	Winchester1894           = { 26, 29},
	Winchester_Quest         = { 26, 29},
	VSS_1                    = { 24, 26},
	Delisle_1                = { 22, 23},
	VSK94_1                  = { 22, 23},
	---- Metralhadoras
	MG58                     = { 32, 36},
	PKM_1                    = { 32, 36},
	BrowningM2HMG            = { 30, 34},
	HK21                     = { 30, 34},
	MG42                     = { 30, 34},
	FNMinimi                 = { 28, 31},
	HK23ECamo_1              = { 28, 31},
	HK23E_1                  = { 28, 31},
	RPD_1                    = { 28, 31},
	RPK74                    = { 28, 31},
	---- Fuzis de assalto
	AR10std                  = { 30, 33},
	FNFAL                    = { 30, 33},
	G3A3Green_1              = { 30, 33},
	G3A3_1                   = { 30, 33},
	Galil_FlagHill           = { 30, 33},
	M14SAW                   = { 30, 33},
	M14SAW_AUTO              = { 30, 33},
	AK74                     = { 28, 30},
	AN94_1                   = { 28, 30},
	AR15                     = { 28, 30},
	G36                      = { 28, 30},
	HK33A2_1                 = { 28, 30},
	M16A2                    = { 28, 30},
	M1Garand_2               = { 28, 30},
	A91_2                    = { 26, 28},
	AK47                     = { 26, 28},
	AUG                      = { 26, 28},
	FAMAS                    = { 26, 28},
	Galil                    = { 26, 28},
	M70_1                    = { 26, 28},
	Papovka2SKS_1            = { 26, 28},
	PapovkaSKS_1             = { 26, 28},
	RK62_1                   = { 26, 28},
	RK95_1                   = { 26, 28},
	SKS_1                    = { 26, 28},
	STG44R_1                 = { 26, 28},
	TAR21_1                  = { 26, 28},
	Type56A_1                = { 26, 28},
	Type56B_1                = { 26, 28},
	Type56C_1                = { 26, 28},
	Type56D_1                = { 26, 28},
	G11_1                    = { 24, 25},
	Groza_1                  = { 22, 23},
	---- Submetralhadoras (so as de cano longo mudam)
	HK53_1                   = { 28, 29},
	AKSU                     = { 24, 25},
	M4Commando               = { 24, 25},
}

---- params autorados como PresetParamPercent no items.lua (so muda o tipo do PlaceObj / a tag).
---- `bonus_cth` nao entra aqui: e percent em GW43/ImprovedIronsight_AR15 e number no resto, entao
---- esses tres declaram `pct` proprio na entrada de RAT_SCOPE_ORIGINALS.
local RAT_PCT = { crit = true, crit_bonus = true, bonus_cth_interrupt = true, stealth_kill_bonus = true }

---- reescreve ModificationEffects/Parameters do preset e refaz o cache de params (g_PresetParamCache
---- e o que ResolveValue le; PostLoad o reconstroi).
local function aperture_write(comp, effects, params_map, pct_map)
	comp.ModificationEffects = effects

	local list = {}
	for name, value in sorted_pairs(params_map) do
		local is_pct = (pct_map and pct_map[name]) or RAT_PCT[name]
		local cls = is_pct and 'PresetParamPercent' or 'PresetParamNumber'
		local tag = is_pct and ("<" .. name .. ">%") or ("<" .. name .. ">")
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

	aperture_write(comp, effects, params, orig.pct)
end

---- WeaponRange da classe. `idx` 1 = pristino, 2 = valor do aCTH. So escreve se o valor atual for
---- um dos dois: se PATCH_GBO_weapons mudar o pristino, avisa em vez de gravar por cima calado.
---- `base_WeaponRange` (Modifiers.lua) e quem a instancia le de fato -- mexer so em WeaponRange
---- muda a classe e nao muda arma nenhuma.
local function apply_range(idx)
	for id, pair in pairs(RAT_APERTURE_WEAPON_RANGE) do
		local cls = g_Classes[id]
		if cls then
			local cur = rawget(cls, "base_WeaponRange") or cls.WeaponRange
			if cur ~= pair[1] and cur ~= pair[2] then
				print("GBO aperture: WeaponRange inesperado em", id, cur, "-- esperava",
				      pair[1], "ou", pair[2])
			else
				cls.WeaponRange = pair[idx]
				if rawget(cls, "base_WeaponRange") ~= nil then
					cls.base_WeaponRange = pair[idx]
				end
			end
		end
	end
end

---- Volta TODA optica conhecida (e o alcance) ao pristino hardcodado (ignora tiers).
function Rat_RestoreApertureItemParams()
	for id in pairs(RAT_SCOPE_ORIGINALS) do
		apply_one(id, nil)
	end
	apply_range(1)
end

function ApplyApertureItemParams()
	local ap = const.Combat.Aperture -- sempre a tabela viva (recriada a cada reload de __ApertureParams)
	if not ap or not ap.Enabled then
		return Rat_RestoreApertureItemParams()
	end
	for id, tier_name in pairs(ap.ApertureComponentTier or empty_table) do
		apply_one(id, (ap.ApertureMagnifications or empty_table)[tier_name])
	end
	apply_range(2)
end

---- Ancora de load: garante que o override roda depois deste arquivo (e do __ApertureParams) carregar.
---- __ApertureParams tambem chama via GBO_ApplyApertureCTHMode, mas so se ApplyModOptions/DataLoaded disparar.
function OnMsg.ModsReloaded()
	ApplyApertureItemParams()
	if g_Units and #g_Units > 0 then Rat_ReapplyApertureComponents() end
end

---- Empurra o override para as armas ja equipadas em campo, sem esperar UnitCreated. Reaplica TODO
---- componente, nao so as opticas conhecidas: o valor da instancia foi calculado sobre a base
---- ANTIGA da classe, entao trocar WeaponRange exige recomputar tambem cano longo, bipe, etc.
function Rat_ReapplyApertureComponents()
	local n = 0
	for _, u in ipairs(g_Units or empty_table) do
		if IsValid(u) then
			for _, wslot in ipairs({ "Handheld A", "Handheld B" }) do
				for _, w in ipairs(u:GetEquippedWeapons(wslot) or empty_table) do
					---- a instancia guarda o WeaponRange resolvido no momento em que foi criada;
					---- trocar a base da classe nao chega ate ela sozinho.
					if IsKindOf(w, "Firearm") and RAT_APERTURE_WEAPON_RANGE[w.class] then
						local base = rawget(g_Classes[w.class], "base_WeaponRange")
						if rawget(w, "base_WeaponRange") ~= nil and base then
							w:SetBase("WeaponRange", base)
						else
							w:RestoreModifiableValue("WeaponRange")
						end
					end
					if IsKindOf(w, "Firearm") and w.components then
						for cslot, cid in sorted_pairs(w.components) do
							if WeaponComponents[cid] then
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

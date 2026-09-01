---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- parametros. CTH = razao silhueta_alvo / sigma_cone, ambas em minutos de angulo.
---- Aritmetica INTEIRA (NetUpdateHash em co-op). Inerte com A.Enabled = false.
---------------------------------------------------------------------------------------------------

const.Combat.Aperture = {}
local A = const.Combat.Aperture

---- Chave-mestra. false = comportamento antigo (modifiers legados ativos, CTH_angular inerte).
A.Enabled = true

---- Cobertura por sondagem de silhueta (FUNCTIONS_cover_silhouette.lua). Separada de A.Enabled (custo de raycast).
A.CoverRaycast = true


---------------------------------------------------------------------------------------------------
---- Marksmanship escala o cone inteiro -- x2.60 em Marks 0 .. x1.00 em Marks 100
---------------------------------------------------------------------------------------------------

A.SkillMin = 50 --100 --- multiplicador (%) em Marksmanship 100
A.SkillMaxFactor = 3
A.SkillMax = A.SkillMaxFactor * A.SkillMin --300--260 --- multiplicador (%) em Marksmanship 0



---------------------------------------------------------------------------------------------------
---- Escala base
---------------------------------------------------------------------------------------------------
---- Abertura de referencia (minutos): Marks 100, arma de referencia, sem componentes. Move TUDO.
---- Calibrado 2026-08-29 contra o CTH do modelo somado, convertido a sigma pela LUT.
A.BaseFactor = 75
A.Base = A.BaseFactor * 100 / A.SkillMin--75 --57

---- Piso mecanico do cone. Derivado do WeaponRange: silhueta de alvo em pe no alcance maximo x este %.
A.FloorPct = 55 --130 --55

---- Convergencia da mira ao piso. true = assintotico: sigma = piso + (sigma0 - piso) * decay^aim
---- (cada stat sempre rende; tiro mirado fica mais dificil no medio/longo). false = joelho duro.
A.ApertureAsymptotic = true

---- Silhueta -- raio equivalente em cm, sqrt(largura*altura)/2, medido via GetLoFData 2026-08-29
---- a ~20-25 tiles: pe 76x95 (42), agachado 59x72 (33), prone 74x51 (31), cabeca 20x22 (11).
---- Prone entra ABAIXO do medido de proposito (sonda pegou perfil; preserva o -30 flat de CTH_cover_prone.lua).

A.Silhouette = {
    Standing = 42,
    Crouch = 37,--33,
    Prone = 31 --26
}

---- Body part como % do raio da postura.
A.BodyPart = {
    Torso = 100,
    Arms = 62,
    Legs = 62,
    Groin = 55
}

---- Partes que NAO escalam com a postura: raio ABSOLUTO em cm. Cabeca mede ~22/20/19 nas 3 posturas
---- -- escala-la com o corpo tornava headshot em alvo agachado impossivel.
A.BodyPartAbsolute = {
    Head = 11,
    Neck = 11
}

---- Geometria da silhueta para a SONDAGEM DE COBERTURA: meia-largura/altura da caixa (1000 = 1 m),
---- extensao da grade fina ao redor do spot. Altura do centro nao entra (ancora nos spots do GetLoFData).

A.Box = {
    Standing = {halfw = 380, halfh = 475},
    Crouch = {halfw = 295, halfh = 360},
    Prone = {halfw = 370, halfh = 255}
}

---- Desvios LATERAIS de sondagem em % da meia-largura, por spot. 5 spots x 5 desvios = 25 raios/chamada.
---- Pontos FIXOS e deterministicos: nao consomem random, seguros em previsao e IA.
A.ProbeLateral = {-80, -40, 0, 40, 80}

---- Raio da cruz de amostragem da cabeca (110 = 11 cm). O spot E o centro dela, cruz de 5 basta.
A.HeadProbeHalf = 110

---- Grade fina = SEGUNDA chamada de GetLoFData (~10 ms frio, ~0.8 ms quente). LIGADA apesar do custo:
---- o modo barato (5 spots) e enviesado para a linha central. So o JOGADOR paga; IA usa A.CoverAIFallback.
A.CoverProbeGrid = true

---- IA usa `100 - coverage` do engine em vez de raycast (orcamento de turno). Ver FUNCTIONS_cover_silhouette.lua.
A.CoverAIFallback = true

---- Classe de penetracao dos raios de sondagem. 0 = qualquer obstaculo bloqueia (cobertura PROTEGE,
---- espirito do -35 flat antigo). A classe real da arma faria quase toda cobertura sumir.
A.CoverPenetrationClass = 2--0

---- Fracao exposta abaixo da qual o alvo conta como totalmente ocluido. So no caminho barato da IA.
A.ExposureBlockedPct = 6

---- Quanto do `tohit_mod` de TargetBodyPart ainda vale. A dificuldade geometrica ja saiu da silhueta
---- (cobrar o inteiro contaria duas vezes); o residual e o custo de ESCOLHER alvo pequeno.
A.TargetedResidualPct = 0 --35



---- AimAccuracy define quanto CADA nivel de mira FECHA o cone:
---- decay% = 100 - (DecayBase + DecayScale * AimAccuracy). AimAccuracy 3 -> 80%/nivel, 6 -> 68%, 9 -> 56%.
---- Hand-Eye Coordination (Dex+Marks) escala quanto disso o atirador COBRA (= "Aiming Rework").

A.DecayBase = 0 --8
A.DecayScale = 6--4
A.DecayMinPct = 20 --- teto de fechamento por nivel. nunca fecha mais que (100 - DecayMinPct) %

---- Opticas com LIMIAR: bonus de AimAccuracy que so vale a partir do nivel `from` (ate `to`, se
---- houver). Substitui os degraus `aim >= N` do modelo somado -- a luneta deixa de ser um degrau
---- de pontos e vira CURVA: rende pouco nos primeiros niveis e muito depois do tempo investido.
A.ComponentEffectsAimBonus = {
    {id = "pso_dragunov_scope", from = 2, acc = 2 },
    {id = "sniper_aim_scope", from = 3, acc = 3},
    {id = "sniper_adv_aim_scope", from = 4, acc = 4},
    ---- Forward Grip: so o PRIMEIRO nivel -- e o "aponta rapido" dele, nao um ganho permanente.
    {id = "FirstAimBonusModifier", from = 1, to = 1, acc = 3},
	{id = "BonusAccuracyWhenFullyAimed", from = 3, to = 3, acc = 4}
}

-------- TEMPORARY! yeah sure
A.PBAsHandlingMul = 100
--------
---- Miras (AccuracyBonusWhenAimed): o `bonus_cth` autorado no componente vira multiplicador de
---- cone, aplicado uma vez com aim >= 1. false = inerte.
A.SightAimBonus = true


A.AimDecayMuls ={
	HeavyRainAim = 120,
	Crouch = 95,
	Prone = 90,
	ProneGripPenalty = 105,
	HandgunPenalty = 150,--50 ---- 100 is disabled
	CompEffects = { -- {mul = 90, meta = "string"}
		light_stock_aim_reduce = {mul = 110}, 
		ReduceAimAccuracy = {mul = 150}
	}
}
-- TODO: reflex sight should use differnt value, as it has also the close range bonus
-- TODO: Crouch and prone should increase aim accuracy
-- TODO: Grips

---- Degrau de "arma no ombro" -- hipfire / snapshot. So ate aim 2 (aim 3+ a arma esta encostada).
---- Escala o EXCESSO, nunca o cone inteiro:
----   alargamento = 100 + (AimStep[aim] - 100) * GetWeaponHipfireOrSnapshotMul/100 * manejo/100
---- Regra GBO3: armas leves/curtas boas em SNAPSHOT (MP5 72), nao em hipfire (MP5 135).

A.AimStep = {
    [0] = 280,--380, --- hipfire: x2.80 numa arma de referencia
    [1] = 180,--180,--155, --- snapshot 1 nivel: x1.55
    [2] = 130--130--118 --- snapshot 2 niveis: x1.18
}
A.AimStepMaxLevel = 2 --- acima disso a arma esta encostada: alargamento 100

---- Manejo -> semente de `rat_aperture_snap`. OverwatchAngle so SEMEIA um valor inicial para armas
---- que nao declararam (o stat em si continua servindo rotacao/stance/AOE). Multiplicador %, MENOR = melhor.
A.UseApertureSnapHipMul = false
A.SeedOWMin = 600 --- OverwatchAngle tratado como "pesada" (Barret 545, MG42 571, PSG1 596)
A.SeedOWMax = 1500 --- OverwatchAngle tratado como "manejavel" (UZI/MP5 1410-1437)
A.SeedSnapHeavy = 125 --- multiplicador para arma pesada
A.SeedSnapHandy = 80 --- multiplicador para arma manejavel

---- LUT de Rayleigh -- P(acerto) = 1 - exp(-k^2 / 2), k = theta_alvo / sigma (dispersao radial 2D).
---- Tabulada por mil, indice = k*8 (passo 0.125), interpolada. Fora da tabela (k > 4) retorna 1000.

A.RayleighStep = 125 --- k * 1000 por entrada
A.Rayleigh = {
    [0] = 0, 8, 31, 68, 117, 177, 245, 318, 393, 469, 542, 611, 675, 733, 784, 828, 865, 896, 920,
    940, 956, 968, 977, 984, 989, 992, 995, 997, 998, 999, 999, 999, 1000
}

---------------------------------------------------------------------------------------------------
---- Limites do CTH final produzido pelo modelo geometrico
---------------------------------------------------------------------------------------------------

A.MinCTH = 1
A.MaxCTH = 97

---- Recoil: abertura do cone por tiro. excesso = RecoilGrowthBase * mod_de_recoil / 100
---- (mod vem de FUNCTIONS_recoil; ~130 MP5, ~230 AK47/MG42). Distancia entra pela geometria, ver Rat_GetRecoilConeGrowth.

A.RecoilGrowthBase = 40 -- 13
A.RecoilGrowthMax = 60 --60 --- teto do excesso por tiro (%)

---- Anel de mira: desenhado NO MUNDO com o raio real do cone (ver UI_aperture_ring.lua).
---- QUANTOS SIGMAS o anel representa. 1 sigma contem 39% dos tiros; 2.5 contem 96%.
A.CrosshairSigmaMul = 250

---- SIMULACAO DO TIRO. true = sorteia o desvio, dispara, o que acertou acertou. false = pipeline vanilla.
---- BALANCE IDENTICO (inversa da mesma LUT; 10k tiros/caso, erro <= 1 ponto); muda a CONSEQUENCIA do erro
---- (bala perdida real, body part pela geometria, rajada anda). NAO reusar GetPelletScatterData (raio
---- uniforme -> 4x generoso no tiro dificil). Consome random sincronizado: so na resolucao. Graze desligado.

A.SimulateShots = true

---- Centro de mira: quanto puxar do spot alvo para o CENTROIDE vertical dos spots do LoF (0 = spot cru).
---- "Torso" nao e o centro da silhueta (spots vao Head +33 a Legs -59, centroide -14) e Rayleigh pressupoe
---- espalhamento CENTRADO. MUDA BALANCE: grupo desce ~14cm -> mais perna/virilha. So eixo vertical, so sem parte pedida.

A.AimCentroidPct = 0 --100

---- Segmentos do anel de mira. Mais que isto nao se distingue; menos, vira poligono a queima-roupa.
A.CrosshairRingSegments = 32

---- Residuais (recoil permanente, Dazed, perks, TargetedShot, componentes) entram como
---- MULTIPLICADOR DE CONE, nao como pontos somados por cima. A traducao pontos -> cone e avaliada
---- neste CTH de referencia; theta se cancela na razao de k, entao o cone sai igual em toda parte
---- do corpo. Em CTH = ConeRefCTH o resultado bate exatamente com o modelo de pontos antigo.
A.ConeRefCTH = 80--50

---- Teto e piso do multiplicador de UM residual. Sem eles -100 pontos daria cone infinito.
A.ConeMulMin = 25
A.ConeMulMax = 1000

---- Valvula da IA em espaco de cone: o inimigo so paga esta fracao (AIpenal_reduc) do EXCESSO do
---- cone sobre A.Base. false = a IA usa o cone cru. Como desconto em pontos o cone dependia da parte.
--A.AIConeValve = true

---- SO COR, nao entra em conta nenhuma. Ancoras do gradiente de fator de cone no overlay
---- (Rat_ConeMulTag): MetaScaleWorst = vermelho cheio, 100 = ambar, MetaScaleBest = verde cheio.
---- Worst e o teto contra o qual hipfire/snapshot sao pintados, para 280 e 155 nao sairem iguais.
A.MetaScaleWorst = 300--300
A.MetaScaleBest = 60--60

---------------------------------------------------------------------------------------------------


-- TODO: Check the second property
--function OnMsg.ClassesGenerate()
--    AppendClass.Firearm = {
--        properties = {
--            ---- Multiplicador (%) do degrau de hipfire/snapshot. Menor = aponta mais rapido.
--            ---- 0 = nao declarado, semeado do OverwatchAngle em Rat_SeedApertureProperties().
--            --{id = "rat_aperture_snap", editor = "number", default = 0, no_edit = true},
--            ---- Multiplicador (%) da abertura BASE da arma, antes de mira e componentes. 100 = referencia.
--            {id = "HandlingMul", editor = "number", default = 100, no_edit = true}
--        }
--    }
--end


---------------------------------------------------------------------------------------------------
---- Override de componentes SO enquanto o aperture esta ligado (A.Enabled). Mexe apenas nas chaves
---- listadas por perfil; o resto do componente (custo, visuais, outros efeitos) fica intacto.
---- Idempotente: guarda o pristino no 1o toque e reconstroi dele a cada chamada. A.Enabled = false
---- -> restaura o pristino. Reaplicar em armas em campo: Rat_ReapplyApertureComponents().
---------------------------------------------------------------------------------------------------

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
		ModificationEffects = { IncreaseMaxAimActions = true, IncreaseRange = false },
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
	AUGScope_Default          = "_2x",
	WideScope                 = "_2x",
	ScopeCOG                  = "_4x",
	ScopeCOGQuick             = "_4x",
	LROptics                  = "_4x",
	LROptics_DragunovDefault  = "_4x",
	ThermalScope              = "_4x",
	LROpticsAdvanced          = "_6x",
	PSG_DefaultScope          = "_6x",
}

---- pristino por id: { effects = {lista de ids}, params = {Name = Value} }
local aperture_orig = {}

local function aperture_snapshot(comp, id)
	if aperture_orig[id] then return end
	local params = {}
	for _, p in ipairs(comp.Parameters or empty_table) do
		params[p.Name] = p.Value
	end
	aperture_orig[id] = { effects = table.icopy(comp.ModificationEffects or empty_table), params = params }
end

---- reescreve ModificationEffects/Parameters do preset e refaz o cache de params (g_PresetParamCache
---- e o que ResolveValue le; PostLoad o reconstroi).
local function aperture_write(comp, effects, params_map)
	comp.ModificationEffects = effects

	local list = {}
	for name, value in sorted_pairs(params_map) do
		list[#list + 1] = PlaceObj('PresetParamNumber', { 'Name', name, 'Value', value, 'Tag', "<" .. name .. ">" })
	end
	comp.Parameters = list

	g_PresetParamCache[comp] = nil
	comp:PostLoad()
end

function Rat_RestoreApertureItemParams()
	for id, snap in pairs(aperture_orig) do
		local comp = WeaponComponents[id]
		if comp then
			aperture_write(comp, table.icopy(snap.effects), snap.params)
		end
	end
end

function ApplyApertureItemParams()
	if not A or not A.Enabled then
		return Rat_RestoreApertureItemParams()
	end

	for id, tier_name in pairs(A.ApertureComponentTier) do
		local comp = WeaponComponents[id]
		if not comp then
			print("GBO aperture: componente inexistente", id)
		else
			aperture_snapshot(comp, id)
			local orig = aperture_orig[id]
			local tier = A.ApertureMagnifications[tier_name] or empty_table
			local eff_override = tier.ModificationEffects or empty_table
			local par_override = tier.Parameters or empty_table

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
							if A.ApertureComponentTier[cid] and WeaponComponents[cid] then
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
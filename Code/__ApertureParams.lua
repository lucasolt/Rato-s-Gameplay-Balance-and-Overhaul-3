---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- parametros. CTH = razao silhueta_alvo / sigma_cone, ambas em minutos de angulo.
---- Aritmetica INTEIRA (NetUpdateHash em co-op). Inerte com A.Enabled = false.
---------------------------------------------------------------------------------------------------

const.Combat.Aperture = {}
local A = const.Combat.Aperture

---- Modo de CTH. GLOBAL de proposito, FORA de const.Combat.Aperture: a tabela acima e recriada a
---- cada reload deste arquivo e o modo tem que sobreviver a isso. A opcao (CurrentModOptions) as
---- vezes ainda nao esta pronta durante o load -> cai no valor anterior, ou "aCTH" na 1a vez.
---- "aCTH" = completo (com SimulateShots) | "aCTH Lite" = sem simulacao | qualquer outro = CTH antigo.
RAT_ApertureCTHMode = (CurrentModOptions and CurrentModOptions.ApertureCTH) or RAT_ApertureCTHMode or "aCTH"

---- Unico escritor de A.Enabled / A.SimulateShots. `mode` opcional vira o novo modo. Deriva os
---- espelhos em const, limpa o combat_cache das unidades e reaplica as opticas -- idempotente.
function GBO_ApplyApertureCTHMode(mode)
	if mode then RAT_ApertureCTHMode = mode end
	local m = RAT_ApertureCTHMode
	const.Combat.Aperture.Enabled = (m == "aCTH" or m == "aCTH Lite")
	const.Combat.Aperture.SimulateShots = (m == "aCTH")
	for _, u in ipairs(g_Units or empty_table) do u.combat_cache = nil end
	if ApplyApertureItemParams then ApplyApertureItemParams() end

	if RatoTOGComponents then RatoTOGComponents() end
	print("GBO Options - CTH mode:", m, "| Enabled:", const.Combat.Aperture.Enabled,
	      "| SimulateShots:", const.Combat.Aperture.SimulateShots)
end

GBO_ApplyApertureCTHMode() -- tabela recem-recriada acima: repopula os espelhos agora

---- Reescrever os presets nao basta: a arma equipada guarda o valor calculado sobre a base ANTIGA.
---- Sem isto a arma em campo ficava com o IncreaseRange velho e sem os niveis de mira novos -- o
---- refactor de optica inteiro nao valia nada. Fica NOS HANDLERS, nunca no escopo do arquivo:
---- mexer em unidade durante o load aborta o resto deste arquivo.
local function apply_mode_and_field()
	GBO_ApplyApertureCTHMode(CurrentModOptions and CurrentModOptions.ApertureCTH)
	if Rat_ReapplyApertureComponents and g_Units and #g_Units > 0 then
		Rat_ReapplyApertureComponents()
	end
end

function OnMsg.ApplyModOptions()
	apply_mode_and_field()
end
function OnMsg.DataLoaded()
	apply_mode_and_field()
end

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
---- teto de fechamento por nivel. nunca fecha mais que (100 - DecayMinPct) %. Abaixo de 30 um
---- unico nivel com optica de limiar fecha quase todo o gap e vira degrau, nao curva.
A.DecayMinPct = 30 --20

---- Opticas com LIMIAR: bonus de AimAccuracy que so vale a partir do nivel `from` (ate `to`, se
---- houver). Substitui os degraus `aim >= N` do modelo somado -- a luneta deixa de ser um degrau
---- de pontos e vira CURVA: rende pouco nos primeiros niveis e muito depois do tempo investido.
--A.ComponentEffectsAimBonus = {
--    {id = "pso_dragunov_scope", from = 2, acc = 2 },
--    {id = "sniper_aim_scope", from = 3, acc = 3},
--    {id = "sniper_adv_aim_scope", from = 4, acc = 4},
--    ---- Forward Grip: so o PRIMEIRO nivel -- e o "aponta rapido" dele, nao um ganho permanente.
--    {id = "FirstAimBonusModifier", from = 1, to = 1, acc = 3},
--	{id = "BonusAccuracyWhenFullyAimed", from = 3, to = 3, acc = 4}
--}



---------------------------------------------------------------------------------------------------
---- MANEJO. O antigo Point Blank Accuracy (GetPBbonus, que ja soma classe + arma + componentes)
---- vira multiplicador da abertura BASE -- nao residual sobre o cone final.
----   HandlingMul = 100 - HandlingScale * GetPBbonus / 100
---- Entrar em sigma_0 e o que da a forma pretendida: o ganho e multiplicado pelo decay a cada
---- nivel, entao manejo decide o tiro rapido e SOME quando o cone converge no piso. Como residual
---- final seria um % fixo em todo nivel e a arma longa nunca ultrapassaria a curta.
A.HandlingScale = 150
A.HandlingMin = 60
A.HandlingMax = 140

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

---- O degrau NAO tem multiplicador proprio de arma: quem cumpre esse papel e wep_base_hip_mul /
---- wep_base_snapshot_mul, que ja sao stats expostos ao jogador. `ApertureSnapHipMul` foi removido.

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

--A.SimulateShots = CurrentModOptions["ApertureCTH"] == "aCTH"  and true or false

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
---- 65 e onde a escala e ~simetrica: em 80, +20 pontos valia cone 94 e -20 valia 125.
A.ConeRefCTH = 65 --80--50

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


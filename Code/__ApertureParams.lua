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
---- Escala base
---------------------------------------------------------------------------------------------------

---- Abertura de referencia (minutos): Marks 100, arma de referencia, sem componentes. Move TUDO.
---- Calibrado 2026-08-29 contra o CTH do modelo somado, convertido a sigma pela LUT.
A.Base = 75 --57

---- Piso mecanico do cone. Derivado do WeaponRange: silhueta de alvo em pe no alcance maximo x este %.
A.FloorPct = 55 --55

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
A.CoverPenetrationClass = 0

---- Fracao exposta abaixo da qual o alvo conta como totalmente ocluido. So no caminho barato da IA.
A.ExposureBlockedPct = 6

---- Quanto do `tohit_mod` de TargetBodyPart ainda vale. A dificuldade geometrica ja saiu da silhueta
---- (cobrar o inteiro contaria duas vezes); o residual e o custo de ESCOLHER alvo pequeno.
A.TargetedResidualPct = 0 --35

---------------------------------------------------------------------------------------------------
---- Marksmanship escala o cone inteiro -- x2.60 em Marks 0 .. x1.00 em Marks 100
---------------------------------------------------------------------------------------------------

A.SkillMax = 300--260 --- multiplicador (%) em Marksmanship 0
A.SkillMin = 100 --- multiplicador (%) em Marksmanship 100

---- AimAccuracy define quanto CADA nivel de mira FECHA o cone:
---- decay% = 100 - (DecayBase + DecayScale * AimAccuracy). AimAccuracy 3 -> 80%/nivel, 6 -> 68%, 9 -> 56%.
---- Hand-Eye Coordination (Dex+Marks) escala quanto disso o atirador COBRA (= "Aiming Rework").

A.DecayBase = 8 --8
A.DecayScale = 4--4
A.DecayMinPct = 40 --- teto de fechamento por nivel (nunca fecha mais que 60%)

---- Degrau de "arma no ombro" -- hipfire / snapshot. So ate aim 2 (aim 3+ a arma esta encostada).
---- Escala o EXCESSO, nunca o cone inteiro:
----   alargamento = 100 + (AimStep[aim] - 100) * GetWeaponHipfireOrSnapshotMul/100 * manejo/100
---- Regra GBO3: armas leves/curtas boas em SNAPSHOT (MP5 72), nao em hipfire (MP5 135).

A.AimStep = {
    [0] = 380, --- hipfire: x2.80 numa arma de referencia
    [1] = 180,--155, --- snapshot 1 nivel: x1.55
    [2] = 130--118 --- snapshot 2 niveis: x1.18
}
A.AimStepMaxLevel = 2 --- acima disso a arma esta encostada: alargamento 100

---- Manejo -> semente de `rat_aperture_snap`. OverwatchAngle so SEMEIA um valor inicial para armas
---- que nao declararam (o stat em si continua servindo rotacao/stance/AOE). Multiplicador %, MENOR = melhor.
A.UseHandling = true
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
A.ConeRefCTH = 50

---- Teto e piso do multiplicador de UM residual. Sem eles -100 pontos daria cone infinito.
A.ConeMulMin = 25
A.ConeMulMax = 1000

---- Valvula da IA em espaco de cone: o inimigo so paga esta fracao (AIpenal_reduc) do EXCESSO do
---- cone sobre A.Base. false = a IA usa o cone cru. Como desconto em pontos o cone dependia da parte.
A.AIConeValve = true

---- SO COR, nao entra em conta nenhuma. Fator de cone tratado como "o pior caso" no gradiente do
---- overlay: e o teto contra o qual hipfire/snapshot sao pintados, para 280 e 155 nao sairem iguais.
A.MetaScaleWorst = 350

---------------------------------------------------------------------------------------------------

function OnMsg.ClassesGenerate()
    AppendClass.Firearm = {
        properties = {
            ---- Multiplicador (%) do degrau de hipfire/snapshot. Menor = aponta mais rapido.
            ---- 0 = nao declarado, semeado do OverwatchAngle em Rat_SeedApertureProperties().
            {id = "rat_aperture_snap", editor = "number", default = 0, no_edit = true},
            ---- Multiplicador (%) da abertura BASE da arma, antes de mira e componentes. 100 = referencia.
            {id = "rat_aperture_base_mul", editor = "number", default = 100, no_edit = true}
        }
    }
end

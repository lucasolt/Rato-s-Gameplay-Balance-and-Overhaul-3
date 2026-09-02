---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- parametros. CTH = razao silhueta_alvo / sigma_cone, ambas em minutos de angulo.
---- Aritmetica INTEIRA (NetUpdateHash em co-op). Inerte com A.Enabled = false.
---------------------------------------------------------------------------------------------------

--TODO: 02/09/2026 list
--TODO: make sure AI will orient before checking for cover in LOF
--TODO: Fix target angle getting smaller when you aim
--TODO: Fix shots being too accurate? for AI? (aim is too strong)
--TODO: conversely, fix opportunity attacks, as they have no aim, never hitting.
--TODO: Tune Recoil. It should be able to hit. It should generate "compensated" positions lower too
--TODO: fix strays specially for suppression mod. check crit chance.
--TODO: Check how the aCTH deals with out of sight targets (wallbang)
--TODO: AI OVERHAUL - make sure AI will not try to shoot through the walls
--TODO: AI OVERHAUL - Enemy LastPos should generate threat. They should also try to "chase" the last pos
--TODO: General balancing - OW tuning - maybe snapshot should not scale with distance. instead it could decrease total cth by a %.. 

const.Combat.Aperture = {}
local A = const.Combat.Aperture

---- Modo de CTH. GLOBAL de proposito, FORA de const.Combat.Aperture: a tabela acima e recriada a
---- cada reload deste arquivo e o modo tem que sobreviver a isso. A opcao (CurrentModOptions) as
---- vezes ainda nao esta pronta durante o load -> cai no valor anterior, ou "aCTH" na 1a vez.
---- "aCTH" = completo (com SimulateShots) | "aCTH Lite" = sem simulacao | qualquer outro = CTH antigo.
RAT_ApertureCTHMode = (CurrentModOptions and CurrentModOptions.ApertureCTH) or RAT_ApertureCTHMode or "aCTH"

---- Componentes do ToG espelham os efeitos das opticas base: so podem ser reescritos com os presets
---- ja carregados. No load deste arquivo WeaponComponents ainda esta vazio e a chamada rebentava.
---- rawget(_G): ler um global inexistente e erro neste engine, entao nada de `if RatoTOGComponents`.
local function reapply_tog_components()
	local fn = rawget(_G, "RatoTOGComponents")
	local comps = rawget(_G, "WeaponComponents")
	if not fn or not comps or not comps.WideScope then return end
	local ok, err = pcall(fn)
	if not ok then print("GBO aperture: RatoTOGComponents falhou --", err) end
end

---- Unico escritor de A.Enabled / A.SimulateShots. `mode` opcional vira o novo modo. Deriva os
---- espelhos em const, limpa o combat_cache das unidades e reaplica as opticas -- idempotente.
function GBO_ApplyApertureCTHMode(mode)
	if mode then RAT_ApertureCTHMode = mode end
	local m = RAT_ApertureCTHMode
	const.Combat.Aperture.Enabled = (m == "aCTH" or m == "aCTH Lite")
	const.Combat.Aperture.SimulateShots = (m == "aCTH")
	for _, u in ipairs(g_Units or empty_table) do u.combat_cache = nil end
	local apply_items = rawget(_G, "ApplyApertureItemParams")
	if apply_items then apply_items() end

	---- Unidade so re-encara o inimigo mais proximo no PROPRIO turno. Ver
	---- SOURCE_UnitSetTargetDummyFromPos: sem isto a silhueta exposta muda sozinha a cada
	---- VisibilityUpdate, e com ela o CTH e a parte do corpo atingida.
	const.Combat.FreezeIdleFacing = const.Combat.Aperture.Enabled and const.Combat.Aperture.SimulateShots

	reapply_tog_components()
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

---- CTH = P(acertar o alvo), igual para tiro livre e tiro pedido: quem escolhe a cabeca nao fica
---- com CTH de cabeca, fica com o CTH do corpo e um dado a mais sobre ONDE pegou. A.BodyPart e
---- A.BodyPartAbsolute (raio por parte) sairam daqui em 2026-09-01 -- com a bala resolvida pela
---- geometria, a parte atingida ja e consequencia da trajetoria, nao de uma silhueta menor.
---- O custo de MIRAR parte pequena continua vivo em A.TargetedResidualPct.

---------------------------------------------------------------------------------------------------
---- MODELO SEPARAVEL -- a silhueta sai da CAIXA DA ANIMACAO, nao de uma tabela
----
---- theta e um raio EQUIVALENTE EM AREA, e area NAO preserva probabilidade de acerto sob dispersao
---- isotropica: um corpo alto e estreito tem a area de um disco gordo e e bem mais dificil de
---- acertar. Medido, o circulo errava +15 a +17 pontos na faixa de 50-70%.
----
---- A primeira tentativa tabelou quatro extensoes por postura x azimute, medidas com raycast
---- (Rat_DbgSweep). Nao presta como TABELA: o raycast mede a cena, nao o corpo. Basta o atirador
---- estar 80 cm acima do alvo para a linha de tiro inclinar, o plano perpendicular girar e
---- "cima/baixo" passar a raspar o corpo no comprimento -- medido, o MESMO alvo dava baixo 130%
---- de um lado e 287% do outro. Duas varreduras em cenas diferentes nao se pareciam.
----
---- GetEntityBBox devolve a caixa da animacao no frame do corpo: anatomia pura, sem terreno, sem
---- raio nenhum, em menos de 1 us. Medida: de pe 93x68x146 cm, agachado 104x67x123, deitado
---- 195x91x53. Projetar os 8 cantos no plano perpendicular da as quatro extensoes de graca, com
---- o azimute EXATO (sem interpolar) e a inclinacao real da linha de tiro incluida.

---- Ancora do ponto de mira dentro da caixa, em % de cada eixo do frame do corpo {x, y, z}.
---- Mirar a cabeca sobe a ancora ~36 cm e o corpo passa a se estender quase so para BAIXO;
---- usar a ancora do torso para todos os spots custava 33 pontos (53% na tela, 20% no tiro).
---- Deitado o eixo que separa cabeca de pes e o X (comprimento), nao o Z -- por isso {x,y,z}
---- e nao so a altura. Medido em 2026-09-02, media de 4 pontos de vista.
A.SpotAnchor = {
    Standing = {
        Head  = {78, 70, 92}, Torso = {48, 42, 69}, Arms = {56, 40, 60},
        Groin = {37, 30, 51}, Legs  = {77, 36, 30},
    },
    Crouch = {
        Head  = {76, 44, 90}, Torso = {46, 37, 60}, Arms = {65, 28, 50},
        Groin = {37, 32, 38}, Legs  = {79,  9, 42},
    },
    Prone = {
        Head  = {90, 64, 49}, Torso = {67, 55, 42}, Arms = {85, 18, -4},
        Groin = {54, 51, 61}, Legs  = {37, 14, 76},
    },
}

---- Caixa -> corpo, em %. Os cantos da caixa sao vazios: de pe ela tem 93 cm de largura e o
---- homem tem ~50. E a UNICA constante ajustavel deste caminho -- calibrada contra tiro simulado,
---- nao contra o modelo antigo. Maior = alvo maior = mais CTH.
A.BodyFill = {
    Standing = 75,
    Crouch = 84,
    Prone = 80,
}

---- Meia-faixa normal em permil: 1000 * (Phi(z) - 0.5), z = indice * NormalStep / 1000.
---- Gerada por tools/normal_band_lut.py. Cada eixo do modelo separavel e uma faixa; o par de
---- meias-faixas soma a massa entre -esq e +dir. Confere com 68/95/99.7 em k = 1, 2, 3.
A.NormalStep = 125
A.NormalBand = {
    [0] = 0, 50, 99, 146, 191, 234, 273, 309, 341, 370, 394, 415, 433, 448, 460, 470, 477, 483,
    488, 491, 494, 496, 497, 498, 499, 499, 499, 500, 500, 500, 500, 500, 500,
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
A.DecayScale = 4--4
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
A.HandlingScale = 100--150
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
    [1] = 155,--180,--155, --- snapshot 1 nivel: x1.55
    [2] = 118--130--118 --- snapshot 2 niveis: x1.18
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

---- LUT do circulo DESLOCADO -- P(acerto) quando o RECUO ja moveu o centro de mira `mu` para fora
---- do alvo. A Rayleigh acima so vale com o cano parado (mu = 0); com mu > 0 a distribuicao vira um
---- ANEL de raio mu e espessura sigma, e nenhum sigma equivalente reproduz a curva inteira -- casar
---- so o segundo momento erra ate 15 pontos no tiro 3 de uma rajada (medido). Entao tabela-se a
---- coisa certa: P(k, m) = 1 - Q1(m, k), k = theta/sigma, m = mu/sigma. Ver Rat_RiceCTH.
---- Gerada por tools/offset_circle_lut.py; a linha [0] reproduz a Rayleigh acima ao milesimo.
---- Linhas = m em passos de 0.5 (0 a 8); colunas = k em passos de 0.25 (0 a 8). Valores por mil.

A.OffsetCircleKStep = 250
A.OffsetCircleMStep = 500
A.OffsetCircle = {
    [0] = {[0] = 0, 31, 118, 245, 393, 542, 675, 784, 865, 920, 956, 977, 989, 995, 998, 999, 1000,
           1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000,
           1000, 1000},
    [1] = {[0] = 0, 27, 104, 220, 357, 499, 631, 743, 831, 895, 938, 966, 982, 991, 996, 998, 999,
           1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000,
           1000, 1000},
    [2] = {[0] = 0, 19, 73, 159, 267, 388, 512, 629, 731, 815, 879, 925, 956, 976, 987, 994, 997,
           999, 999, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000,
           1000},
    [3] = {[0] = 0, 10, 41, 92, 164, 253, 356, 466, 576, 679, 768, 841, 896, 936, 963, 979, 989,
           995, 998, 999, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000,
           1000},
    [4] = {[0] = 0, 4, 18, 43, 82, 137, 209, 297, 396, 502, 606, 702, 786, 853, 905, 941, 966, 981,
           990, 995, 998, 999, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000},
    [5] = {[0] = 0, 1, 6, 16, 33, 61, 102, 159, 232, 320, 418, 522, 623, 716, 796, 861, 910, 945,
           968, 982, 991, 996, 998, 999, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000},
    [6] = {[0] = 0, 0, 2, 5, 11, 22, 41, 70, 113, 172, 246, 334, 433, 535, 634, 725, 803, 866, 914,
           947, 969, 983, 991, 996, 998, 999, 1000, 1000, 1000, 1000, 1000, 1000, 1000},
    [7] = {[0] = 0, 0, 0, 1, 3, 6, 13, 25, 45, 76, 121, 180, 256, 344, 442, 544, 642, 732, 809,
           870, 916, 949, 970, 984, 992, 996, 998, 999, 1000, 1000, 1000, 1000, 1000},
    [8] = {[0] = 0, 0, 0, 0, 1, 1, 3, 7, 15, 28, 48, 80, 126, 187, 263, 352, 450, 551, 648, 737,
           813, 873, 918, 950, 971, 984, 992, 996, 998, 999, 1000, 1000, 1000},
    [9] = {[0] = 0, 0, 0, 0, 0, 0, 1, 2, 4, 8, 16, 29, 51, 84, 130, 191, 268, 357, 455, 556, 653,
           741, 816, 875, 920, 951, 972, 985, 992, 996, 998, 999, 1000},
    [10] = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 4, 9, 17, 30, 53, 86, 133, 195, 272, 362, 460, 560,
            657, 744, 818, 877, 921, 952, 972, 985, 992, 996, 998},
    [11] = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 4, 9, 17, 31, 54, 88, 135, 198, 276, 366,
            464, 564, 660, 747, 820, 879, 922, 953, 973, 985, 992},
    [12] = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 5, 9, 18, 32, 55, 89, 137, 201, 278,
            369, 467, 567, 663, 749, 822, 880, 923, 953, 973},
    [13] = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 5, 10, 18, 33, 56, 91, 139, 203,
            281, 371, 469, 569, 665, 751, 823, 881, 924},
    [14] = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 5, 10, 19, 33, 57, 92, 141,
            204, 283, 373, 471, 571, 667, 752, 825},
    [15] = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 5, 10, 19, 34, 58,
            93, 142, 206, 285, 375, 473, 573, 668},
    [16] = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 5, 10, 19, 34,
            58, 94, 143, 207, 286, 377, 475},
}

---------------------------------------------------------------------------------------------------
---- Limites do CTH final produzido pelo modelo geometrico
---------------------------------------------------------------------------------------------------

A.MinCTH = 1
A.MaxCTH = 97

---- Recoil: o cano SOBE, o cone nao alarga. Ver Rat_GetRecoilClimb / Rat_SimRecoilLadder.
---- subida por tiro = RecoilClimbBase * (mod / control) / 100, em MINUTOS de angulo
---- (mod/control vem de FUNCTIONS_recoil; mod ~130 MP5, ~230 AK47/MG42). A distancia entra pela
---- geometria: a mesma subida e inofensiva de perto e fatal de longe, porque theta cai com 1/d.

A.RecoilClimbBase = 80 --- minutos com mod 100 (~1.3 graus). MEDIDO no processo vivo: iguala o CTH
--- medio da rajada do modelo de growth antigo em sigma 143 (AutoFire, aim 1) nas duas silhuetas
--- testadas -- 46 vs 42 e 19 vs 19. O FORMATO muda, e e a assinatura da caminhada: o tiro 2 fica
--- mais perto (90 vs 78) e a partir do 4o a rajada ja saiu do alvo (5 vs 9). Uma arma que sobe sai;
--- um cone que so alarga nunca sai de vez.
--- Em sigma alto (hipfire, 262) o modelo novo e bem mais brando (36 vs 22): a subida do cano nao
--- depende de quao aberto o cone ja estava, e o modelo antigo cobrava o recuo em cima da propria
--- imprecisao da arma. E a unica mudanca de balance deliberada da troca.
A.RecoilClimbMax = 400 --- teto por tiro. Frouxo de proposito: o teto antigo (60%) era atingido por
--- quase toda arma automatica e achatava as diferencas que a cadeia de recoil existe para produzir.

---- Chance de o atirador SEGURAR o cano naquele tiro = 100 - control (Marks, postura, bipe, Forca,
---- perks). Media identica ao desconto deterministico antigo; o que entra e a variancia.
A.RecoilControlMax = 90 --- ninguem segura sempre
A.RecoilControlResidual = 5--15 --- % da subida que passa mesmo num tiro controlado

---- Direcao da caminhada, sorteada UMA vez por rajada: "para cima" girado por um yaw aleatorio de
---- ate +/- este angulo (graus). 0 = subida pura; 180 = eixo totalmente aleatorio, como a vanilla
---- faz em CalcShotVectors. Valores altos custam menos acerto: theta e um raio CIRCULAR equivalente
---- e a silhueta real e alta e estreita, entao andar na vertical perdoa mais que andar de lado.
A.RecoilWalkYaw = 40

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
A.ConeRefCTH = 50--65 --80--50

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


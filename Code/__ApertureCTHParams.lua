
---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- parametros. CTH = razao silhueta_alvo / sigma_cone, ambas em minutos de angulo.
---- Aritmetica INTEIRA (NetUpdateHash em co-op). Inerte com A.Enabled = false.
---------------------------------------------------------------------------------------------------



const.Combat.Aperture = const.Combat.Aperture or {}
local A = const.Combat.Aperture
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
function aCTH_base(new_base)
	A.BaseFactor = new_base
	A.Base = A.BaseFactor * 100 / A.SkillMin
	return A.Base
end

A.BaseFactor = 75--75
A.Base = A.BaseFactor * 100 / A.SkillMin--75 --57

---- Piso mecanico do cone. Derivado do WeaponRange: silhueta de alvo em pe no alcance maximo x este %.
A.FloorPct = 45 --130 --55
----------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---- Limites do CTH final produzido pelo modelo geometrico
---------------------------------------------------------------------------------------------------

A.MinCTH = 1
A.MaxCTH = 97

---------------------------------------------------------------------------------------------------
------------ AIM
---------------------------------------------------------------------------------------------------
---- Convergencia da mira ao piso. true = assintotico: sigma = piso + (sigma0 - piso) * decay^aim
---- (cada stat sempre rende; tiro mirado fica mais dificil no medio/longo). false = joelho duro.
A.ApertureAsymptotic = true

---- AimAccuracy define quanto CADA nivel de mira FECHA o cone:
---- decay% = 100 - (DecayBase + DecayScale * AimAccuracy). AimAccuracy 3 -> 80%/nivel, 6 -> 68%, 9 -> 56%.
---- Hand-Eye Coordination (Dex+Marks) escala quanto disso o atirador COBRA (= "Aiming Rework").

A.DecayBase = 0 --8
A.DecayScale = 1--6--4

-- Changes Scale of components
A.aCTHAimAccuracyScaleMul = 500

---- teto de fechamento por nivel. nunca fecha mais que (100 - DecayMinPct) %. Abaixo de 30 um
---- unico nivel com optica de limiar fecha quase todo o gap e vira degrau, nao curva.
A.DecayMinPct = 30--30 --20

---- Multiplicadores do DECAY da mira. Uma entrada por modificador, tudo declarado AQUI -- nenhum
---- deles tem bloco de codigo proprio em Rat_ApertureAimDecay. mul 100 = desligado, > 100 piora.
---- Condicoes (todas opcionais, somam-se; sem nenhuma a entrada vale sempre):
----   stance     = "Crouch"|"Prone"|"Standing"   postura do atirador
----   classes    = {"Pistol", "Revolver"}        basta UMA bater
----   component  = "component_id"                componente montado na arma
----   game_state = "RainHeavy"                   flag de GameState
----   indoors    = false                         exige estar fora de abrigo (true exige dentro)
----   cond       = function(weapon, attacker)    escape hatch, para o que nao couber acima
---- Rotulo do overlay: `meta`, T ou string crua. Sem `meta`, uma entrada com `component` usa o
---- DisplayName do proprio componente (com "(-) " quando piora); meta = false cala a entrada.
---- Ordem de aplicacao = alfabetica pela chave (sorted_pairs) para o co-op nao divergir.
A.AimDecayMuls = {
	HeavyRainAim = {mul = 120, game_state = "RainHeavy", indoors = false,
	                meta = T {901477523654, "(-) Heavy Rain"}},
	HandgunPenalty = {
		mul = 100,--150,
		classes = {"Pistol", "Revolver"}, ---- 100 is disabled
	                  meta = T {195655494642, "(-) Handgun"}},
	Crouch = {
		mul = 100,
		stance = "Crouch", --97,--95
	          meta = T {688848752517, "Crouching"}},
	Prone = {mul = 100, stance = "Prone", --95,--90
	         meta = T {271472323596, "Prone"}},
	ProneGripPenalty = {mul = 105, stance = "Prone", component = "grip_prone_penalty",
	                    meta = T {856431894569, "(-) Grip while prone"}},
	---- stocks are flat AimAccuracy penalties now: A.ComponentEffectsAimBonus
}

---- CAMUFLAGEM. Alvo camuflado e mais dificil de VER, entao encolhe a SILHUETA -- nao alarga o
---- cone e nao mexe na mira. Assim vale em todo nivel de mira (inclusive hipfire), empilha com
---- cobertura pela mesma porta (exposicao), e o produto das linhas do overlay continua fechando
---- no Total, coisa que o modelo antigo quebrava.
---- Valor = % da AREA que ainda se enxerga; entra como raiz (area -> raio), entao 60 = raio x0.77.
A.CamoExposedPct = 60 --- 100 desliga
A.CamoMeta = T {617384902551, "(-) Camouflaged"}

---- Stance flattens the cone on the VERTICAL axis, as % of sigma. See Rat_ConeSigmaY.
A.ConeStretch = {Standing = 100, Crouch = 85, Prone = 70}

---------------------------------------------------------------------------------------------------
---- Degrau de "arma no ombro" -- hipfire / snapshot. So ate aim 2 (aim 3+ a arma esta encostada).
---- Escala o EXCESSO, nunca o cone inteiro:
----   alargamento = 100 + (AimStep[aim] - 100) * GetWeaponHipfireOrSnapshotMul/100 * manejo/100
---- Regra GBO3: armas leves/curtas boas em SNAPSHOT (MP5 72), nao em hipfire (MP5 135).

A.AimStep = {
    [0] = 250,--240,--210,--280,--, --- hipfire: x2.80 numa arma de referencia
    [1] = 140,--130,--155,--130,--155,--180,--155, --- snapshot 1 nivel: x1.55
    [2] = 113--110--110,--118--130--118 --- snapshot 2 niveis: x1.18
}
A.AimStepMaxLevel = 2 --- acima disso a arma esta encostada: alargamento 100

---- Rotulo do degrau, por nivel de mira. `<pct>` recebe o alargamento que o degrau aplicou. Nivel
---- sem entrada cai no [1]; a lista e o que decide o nome, nao um if aim == 0 dentro da funcao.
A.AimStepMeta = {
    [0] = {id = 936174028553, text = "Hipfire <pct>"},
    [1] = {id = 418205963714, text = "Snapshot <pct>"}
}

---- Rotulo do piso mecanico (so aparece no modelo nao-assintotico, quando o cone bate no piso).
A.FloorMeta = T {353401714895, "Range"}

--------------------------------------------------------------------------------------------------
---------- OTHER ACCURACY MODIFIERS
--------------------------------------------------------------------------------------------------
---- Quanto do `tohit_mod` de TargetBodyPart ainda vale. A dificuldade geometrica ja saiu da silhueta
---- (cobrar o inteiro contaria duas vezes); o residual e o custo de ESCOLHER alvo pequeno.
A.TargetedResidualPct = 0 --35

---- Residuais (recoil permanente, Dazed, perks, TargetedShot, componentes) entram como
---- MULTIPLICADOR DE CONE, nao como pontos somados por cima. A traducao pontos -> cone e avaliada
---- neste CTH de referencia; theta se cancela na razao de k, entao o cone sai igual em toda parte
---- do corpo. Os pontos sao absolutos e valem sua face exata AQUI; acima deste CTH entregam
---- menos, abaixo entregam menos ainda. Em 50 bonus e penalidade saturam a mesma distancia (+-49).
A.ConeRefCTH = 50



---------------------------------------------------------------------------------------------------
---- MANEJO. O antigo Point Blank Accuracy (GetPBbonus, que ja soma classe + arma + componentes)
---- vira multiplicador da abertura BASE -- nao residual sobre o cone final.
----   HandlingMul = 100 - HandlingScale * GetPBbonus / 100
---- Entrar em sigma_0 e o que da a forma pretendida: o ganho e multiplicado pelo decay a cada
---- nivel, entao manejo decide o tiro rapido e SOME quando o cone converge no piso. Como residual
---- final seria um % fixo em todo nivel e a arma longa nunca ultrapassaria a curta.
--------------------------------------------------------------------------------------------------
A.PBHandlingScale = 80--150
A.HandlingMin = 60
A.HandlingMax = 160
A.HandlingUseBaseMul = true

---- Standing widens the cone for a heavy gun, same weigth_held_mul ladder as the recoil weight
---- penalty (RecoilHeldPivot). LIGHT by default -- LOWER slope than recoil on purpose, this is
---- aim, not muzzle control -- and it only bites past the pivot, so most guns pay nothing.
A.HandlingHeldPivot = 100--130
A.HandlingHeldSlope = 100--30 -- Mul the excess penalty


A.HandlingHeldStrRelief = 50 -- How many excess points a STR 100 merc removes. 
A.HandlingHeldStanceMul = {Standing = 100, Crouch = 60, Prone = 0}

---- Rotulo da penalidade de peso, POR POSTURA -- antes era sempre "(-) Standing", inclusive
---- agachado, onde HandlingHeldStanceMul ainda cobra 60%. Sem entrada, a postura nao rotula.
A.HandlingHeldStanceMeta = {
    Standing = T {511836641651, "(-) Standing"},
    Crouch = T {274905618332, "(-) Crouching"}
}
A.HandlingHeldLowStrMeta = T {599531270289, "(-) Low Strength"}
A.HandlingHeldMinStr = 70

---- HELD RECOIL
---- Weight above the pivot is paid in grip and force, never in kick. weigth_held_mul is
---- already authored on every weapon, so the ladder needs no per-gun data.
A.RecoilHeldPivot = 130
A.RecoilHeldSlope = 60 ---- RecoilOtherGain re-amplifies this by 2.5x into max_inc
A.RecoilHeldStrRelief = 50
A.RecoilHeldLatPct = 100
---- how much of that penalty each stance still pays: prone rests the gun, standing carries it
A.RecoilHeldStanceMul = {Standing = 100, Crouch = 60, Prone = 0}

---------------------------------------------------------------------------------------------------

---- Centro de mira: quanto puxar do spot alvo para o CENTROIDE vertical dos spots do LoF (0 = spot cru).
---- "Torso" nao e o centro da silhueta (spots vao Head +33 a Legs -59, centroide -14) e Rayleigh pressupoe
---- espalhamento CENTRADO. MUDA BALANCE: grupo desce ~14cm -> mais perna/virilha. So eixo vertical, so sem parte pedida.

A.AimCentroidPct = 100 --100



---------------------------------------------------------------------------------------------------
---- RECUO, SEGUNDA ORDEM. Ver Code/FUNCTIONS_recoil_aCTH.lua e RECOIL MODEL.md.
----
---- O cano tem POSICAO e VELOCIDADE, e o contra-esforco do atirador age na VELOCIDADE. Tudo aqui
---- esta em MINUTOS de angulo ou minutos/tiro -- a MESMA unidade de theta (torso em pe a 10 tiles
---- = 167'), entao cada limite de balance e uma comparacao direta:
----   "o tiro 2 ainda ameaca"          -> |v| depois do tiro 1 bem abaixo de theta
----   "o merc competente segura ate 4" -> |p| no tiro 4 abaixo de theta/2
----   "esse calibre e grande demais"   -> CFMax < KickMag, e a rajada foge sozinha
---------------------------------------------------------------------------------------------------

---- Coice bruto de um tiro, com gun 100. `gun` e a parte da ARMA isolada (mod / control): cano,
---- mecanismo, cartucho, componentes e deltas de rajada, invariante a postura e a pericia.
---- ~174 no MP5, ~230 no MG42/AK47, ~275 na Auto5. E uma ACELERACAO, nao um deslocamento: a
---- posicao cresce com o quadrado do numero de tiros se ninguem segurar, e por isso a escala e bem
---- menor que a do RecoilClimbBase antigo (98), que era deslocamento direto.
---- MEDIDO: 95 poe o coice do MP5 em 165'/tiro, quase o theta de um torso em pe a 10 tiles. Tem
---- de ser dessa ordem: o 2o tiro sai de `kick - cf1`, e se isso for pequeno em relacao ao cone o
---- CTH nao se mexe e o 2o tiro fica igual para todos, por mais que a pericia varie.
A.RecoilKickBase = 95

---- Direcao do coice, em graus a direita da vertical. E um TORQUE: tem lado fixo, nao e sorteado.
---- Global por enquanto; virar campo por arma exige preset no editor do jogo.
A.RecoilKickAngle = 12

---- FORCA -- o portao do calibre. Teto do contra-esforco como % do coice DESTA arma: em 130 o
---- atirador com Forca de sobra opoe 1,3x o coice e estabiliza qualquer calibre que ele aguente.
---- Nao e "o calibre e grande", e "voce tem musculo para ele": o tamanho do calibre ja esta no
---- breakpoint de Forca da arma (MP5 48, AK47 71, MG42 77, Auto5 86) e no coice bruto, que decide
---- quanto o cano passeia enquanto a pegada sobe.
A.RecoilCFHeadroom = 130

---- Afia a penalidade de Forca. `str_control` vem de GetCaliberStrRecoil em base 100 e ja e
---- relativo ao breakpoint: 100 = Forca sobrando, ~109 = em cima do breakpoint, ~171 = muito
---- abaixo. Em 200 a penalidade dobra, entao quem esta bem abaixo do breakpoint nao estabiliza.
A.RecoilStrGain = 200

---- PERICIA -- de onde sai o gradiente do 2o tiro. Quanto da pegada entra no cano por tiro, em
---- minutos/tiro, com `other_control` neutro. O coice e igual para todos (e da arma); o que muda
---- entre mercs e quanto dele ja foi cancelado quando a bala 2 sai. Tambem e o teto de `delta`,
---- entao e a escala que RecoilErrorRatio le.
A.RecoilMaxIncBase = 70

---- Estica `control` (postura, bipe, Marksmanship, perks E Forca), que so anda entre ~85 e ~109
---- no MP5. Sem ganho a diferenca de pericia no 2o tiro seria de 15% e invisivel.
---- `control` inteiro e nao so `other_control` de proposito: e assim que a Forca ACIMA do
---- breakpoint continua valendo alguma coisa em vez de virar um degrau. O peso relativo sai de
---- graca e bate com o old CTH -- la Marks 50->100 mexia a perda 14% e Forca 50->100 mexia 7%,
---- e aqui other_control anda 15% contra os 9% de str_control. Mesma proporcao de 2 para 1.
A.RecoilOtherGain = 250

---- T: em quantos tiros o atirador TENTA zerar (p, v). Ganhos do duplo polo em 1 - 1/T:
---- Kd = 2/T, Kp = 1/T^2. Manda a FORMA da queda, nao os extremos dela.
---- T pequeno de proposito. Kp = 1/T^2 e a UNICA coisa que puxa o cano de volta ao alvo; Kd = 2/T
---- so o freia. Em T = 6 o Kp fica 12x menor que o Kd, o cano para onde estiver e o modelo passa a
---- parecer compensacao contra o tiro ANTERIOR em vez de volta ao alvo original. Em 3 o retorno e
---- de verdade -- e a rajada de um merc bom se RECUPERA depois do mergulho, em vez de so cair.
A.RecoilSettleShots = 3

---- % de amortecimento critico. Em 100 a trajetoria nominal nao passa do alvo, e entao TODA
---- supercompensacao no jogo e um erro do atirador -- que e o comportamento pedido. Abaixo de 100
---- a arma oscila ate para o atirador perfeito, que e outra afirmacao (e pior) sobre o mundo.
A.RecoilDamping = 80--100

---- % da correcao TENTADA que vira erro quando accuracy = 0. Proporcional ao tamanho da correcao,
---- como no 1.13: puxar um calibre grande de volta erra mais que ajeitar um pequeno, entao a
---- dificuldade do calibre sai do mecanismo em vez de ser tunada arma a arma. Abaixo de ~100 a
---- Destreza some: o portao do calibre e deterministico e domina o ruido. Em 140 os dois convivem.
A.RecoilErrorRatio = 140

---- Piso do erro, em % de RecoilMaxIncBase. NUNCA reduzido pela pericia: e por aqui que
---- "mercs muito bons nao podem ficar PERFEITOS" fica dito, e um piso no erro e mais limpo que um
---- teto artificial no atributo. accuracy vem da Destreza crua (o unico atributo que a cadeia
---- tunada ainda nao gasta, entao nada e contado duas vezes).
---- MEDIDO: em 10 o merc completo trava e fica imune ao recuo, que e exatamente o que nao pode.
---- O piso sai de RecoilMaxIncBase (o valor NEUTRO) e nunca do `max_inc` deste merc: `max_inc` e
---- dirigido por pericia, entao escalar o piso nele faria a pericia levantar o proprio erro.
A.RecoilMinErrorPct = 25

---- Lateral sway, as % of the counter-force the shooter is applying this shot. A held muzzle is
---- held at a HEIGHT: the force opposing the kick is easy to size and hard to aim, so what is left
---- over goes sideways. Keying it on |cf| rather than on "the roll was lucky" means it appears
---- exactly for whoever is gripping hard, grows with the caliber for free, and is absent for
---- someone who is merely letting the gun climb -- he already has a different problem.
---- MEDIDO: sem isto, 15% das rajadas ficam com os 6 tiros dentro do alvo, porque o erro so
---- perturba o INCREMENTO da forca e um `cf` bem apontado no tiro 2 sobrevive ate o 6.
A.RecoilLateralPct = 40

---- firing on the move: no brace at all, and the stride throws the muzzle sideways
A.RecoilMovingCtlPct = 25
A.RecoilMovingLatPct = 50

---- Prone on a bipod: the legs stop the climb, not the yaw, so the gun sweeps sideways.
A.RecoilBipodKickYMul = 60
A.RecoilBipodLatMul = 200



----------------------------------------------------------------------------------------
---- Persitant Recoil
----------------------------------------------------------------------------------------
---- PERSISTENT RECOIL AS AN OFFSET. The muzzle keeps the position it ended at instead of the shot
---- being summarised into stacks, so a burst and a string of single shots stop being two systems:
---- what separates them is only how much recovery time passes. False restores the stacks model.
A.RecoilPersistOffset = true

---- % do cano guardado que sobrevive a UM AP gasto. DESLIGADO em 100: a mira agora tem canal
---- proprio e explicito (RecoilPersistAimMul), e ter os dois cobrava a mira duas vezes -- mirar
---- gasta AP, entao o AP ja era um multiplicador de mira disfarcado, e disfarcado e por que o
---- nivel 2 nao rendia nada visivel: quatro AP a mais a 92% cada cortam 28%, e ninguem consegue
---- ler isso na tela. Abaixo de 100 volta a valer, e ai cada AP alem do ataque (ferrolho,
---- gatilho pesado, montar a arma) compra recuperacao junto com a mira.
A.RecoilPersistRetainPerAP = 100

---- Quanto do cano guardado vira DISPERSAO VERTICAL no proximo ataque, em % -- somada em
---- quadratura ao cone (Rat_ConeSigmaY), nunca como deslocamento do ponto de mira.
A.RecoilPersistSigmaPct = 70

---- MIRA -> quanto do tremor ainda vale, por nivel. Explicito e multiplicativo, um numero por
---- linha, que e como o modelo antigo lia (`1 - 0.34 * aim`) e como da para tunar olhando.
---- Zerar no 3 casa com RecoilPersistAimReset e com o que a descricao do efeito promete.
A.RecoilPersistAimMul = {[0] = 100, [1] = 66, [2] = 33, [3] = 0}

---- TETO do alongamento, em % do proprio cone. E o analogo do max_stacks = 6 do efeito antigo:
---- o cano acumula a cada ataque e sem teto a elipse cresce ate sair da tela. Em multiplo do
---- cone e nao em minutos, senao o mesmo limite seria frouxo de perto e absurdo de longe.
---- Valvula de seguranca, NAO alavanca de balanceamento: em 500 ele mordia a cadeia de mira 0
---- ja no quarto ataque e achatava a curva que RecoilPersistSigmaPct acabou de calibrar.
A.RecoilPersistStretchMax = 700

---- VIES do tremor, em % que vai para CIMA (50 = simetrico). O recuo empurra o cano para cima,
---- entao errar por cima e o erro natural -- mas como MEDIA deslocada o modelo se inverteria de
---- novo (cone apertado centrado fora do alvo erra de proposito). Aqui o vies e de FORMA: o
---- centro continua no alvo e os dois meios-eixos verticais e que ficam diferentes, um ovo em vez
---- de elipse. A soma e preservada, entao a calibracao de RecoilPersistSigmaPct nao se mexe.
A.RecoilPersistUpBias = 80--70

---- ABERTURA LATERAL da cunha, em % do tremor, no TOPO dela. O cano sobe, e quanto mais subiu
---- mais tempo o tremor lateral teve para crescer -- entao a possibilidade nao e uma elipse, e um
---- triangulo invertido saindo do ponto de mira. E a mesma coisa que a V da rajada ja diz na tela,
---- que era o motivo de o anel eliptico contar outra historia.
---- Em 0 a cunha some e o CTH volta a ser Px(sigma) * Py(sigma_y), identico ao que era.
A.RecoilPersistFanPct = 50--150

---- FORMA do recuo herdado no MODELO. Com "egg" a abertura lateral zera (Rat_ConeFanX) e o
---- somatorio de Rat_SeparableCTH telescopa de volta para Px * Py; com "wedge" a metade de cima e
---- integrada em fatias que alargam.
----   "wedge" -- triangulo saindo do ponto de mira, no idioma da V da rajada
----   "egg"   -- elipse de dois meios-eixos, larga em cima
---- O DESENHO nao esta mais preso a isto: Rat_ConeSigmaY ignora a forma, entao os dois meios-eixos
---- verticais sao reais tambem em "wedge" e a elipse pode ser desenhada por cima dele sem mentir --
---- so nao diz o leque. Ver A.CrosshairRecoilShape em __ApertureParams.lua.
A.RecoilPersistShape = "wedge"

---- Fatias em que a faixa de CIMA e integrada. A largura muda ao longo do eixo vertical, entao
---- Px nao sai mais do somatorio -- cada fatia paga um lookup na LUT, que e tabela.
A.RecoilPersistFanSteps = 6

---- Teto do cano guardado, em coices da propria arma. Segura o ESTADO; o de cima segura o que
---- ele faz na tela. CORRECAO: o modelo antigo dava UM stack por ataque, tiro simples ou rajada
---- de dez -- o recuo da rajada era resolvido dentro dela. O max_stacks = 6 nao separava os dois,
---- so impedia o crescimento indefinido.
A.RecoilPersistCapKicks = 3

---- Nivel de mira que zera o offset, para casar com a descricao do proprio efeito.
A.RecoilPersistAimReset = 3

---------------------------------------------------------------------------------------------------
---- OFF-PART STRAY. aCTH flies the bullet, so it lands on whatever body part the trajectory crossed
---- -- often not the one aimed at. Vanilla only calls a hit "stray" when it lands on ANOTHER unit
---- (-50% dmg, no crit, no effects); hitting the wrong part of the intended target was impossible.
---- Here the wrong part is a soft stray: crit chance and the body part status effect are scaled,
---- damage is a separate knob. Untargeted shots aim Torso (g_DefaultShotBodyPart), so they pay too.
---------------------------------------------------------------------------------------------------
A.OffPartStray = true

---- Crit chance multiplier when the bullet hit a part other than the aimed one. 100 disables.
A.OffPartCritPct = 33

---- Chance (%) that the body part status effect (Inaccurate/Slowed/Suppressed) still lands on an
---- off-part hit. Ammo effects are untouched. 100 disables.
A.OffPartEffectPct = 33

---- Damage multiplier for an off-part hit, applied before armor like the vanilla stray -50%.
---- 100 = no reduction (default); 50 reproduces vanilla stray damage.
A.OffPartDamagePct = 90--100

---------------------------------------------------------------------------------------------------

---- Strings dos rotulos declarados acima (AimDecayMuls, AimStepMeta, Handling): vivem AQUI agora,
---- entao a exportacao da tabela de traducao tem de le-las daqui. Ver Code/T_ID_enforcement.lua.
local t_id_table = {
    [901477523654] = "(-) Heavy Rain",
    [195655494642] = "(-) Handgun",
    [688848752517] = "Crouching",
    [271472323596] = "Prone",
    [856431894569] = "(-) Grip while prone",
    [936174028553] = "Hipfire <pct>",
    [418205963714] = "Snapshot <pct>",
    [353401714895] = "Range",
    [511836641651] = "(-) Standing",
    [274905618332] = "(-) Crouching",
    [599531270289] = "(-) Low Strength",
    [617384902551] = "(-) Camouflaged"
}

ratG_T_table['__ApertureCTHParams.lua'] = t_id_table

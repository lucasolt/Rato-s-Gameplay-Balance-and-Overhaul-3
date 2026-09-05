
---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- parametros. CTH = razao silhueta_alvo / sigma_cone, ambas em minutos de angulo.
---- Aritmetica INTEIRA (NetUpdateHash em co-op). Inerte com A.Enabled = false.
---------------------------------------------------------------------------------------------------

--TODO: 02/09/2026 list
--TODO: make sure AI will orient before checking for cover in LOF

--TODO: Calibrar o recuo de segunda ordem. Ancorar KickBase e o mapa control -> CFMax nas duas
--TODO: linhas extremas do ladder do 1cc229c, depois conferir um calibre pesado. Ver RECOIL MODEL.md.

--TODO: Strays were fixed. Need to check if different body parts are being processed differently

--TODO: Check how the aCTH deals with out of sight targets (wallbang)
--TODO: AI OVERHAUL - make sure AI will not try to shoot through the walls
--TODO: AI OVERHAUL - Enemy LastPos should generate threat. They should also try to "chase" the last pos
--TODO: General balancing - OW tuning - maybe snapshot should not scale with distance. instead it could decrease total cth by a %.. 


--TODO: 03/09/2026

--TODO: AI OVERHAUL - check grenade distribution. Give more timed to enemies. Less frustrating but still a challenge to the player
--TODO: Debug - make a way to check recoil vectors at any time, at mouse location for example


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
A.DecayScale = 6--4
---- teto de fechamento por nivel. nunca fecha mais que (100 - DecayMinPct) %. Abaixo de 30 um
---- unico nivel com optica de limiar fecha quase todo o gap e vira degrau, nao curva.
A.DecayMinPct = 10--30 --20

A.AimDecayMuls ={
	HeavyRainAim = 120,
	Crouch = 95,
	Prone = 90,
	ProneGripPenalty = 105,
	HandgunPenalty = 150, ---- 100 is disabled
	CompEffects = { -- {mul = 90, meta = "string"}
		light_stock_aim_reduce = {mul = 110}, 
		ReduceAimAccuracy = {mul = 150} -- nostock
	}
}

---------------------------------------------------------------------------------------------------
---- Degrau de "arma no ombro" -- hipfire / snapshot. So ate aim 2 (aim 3+ a arma esta encostada).
---- Escala o EXCESSO, nunca o cone inteiro:
----   alargamento = 100 + (AimStep[aim] - 100) * GetWeaponHipfireOrSnapshotMul/100 * manejo/100
---- Regra GBO3: armas leves/curtas boas em SNAPSHOT (MP5 72), nao em hipfire (MP5 135).

A.AimStep = {
    [0] = 240,--210,--280,--, --- hipfire: x2.80 numa arma de referencia
    [1] = 130,--155,--130,--155,--180,--155, --- snapshot 1 nivel: x1.55
    [2] = 110--110,--118--130--118 --- snapshot 2 niveis: x1.18
}
A.AimStepMaxLevel = 2 --- acima disso a arma esta encostada: alargamento 100

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
A.HandlingScale = 100--150
A.HandlingMin = 60
A.HandlingMax = 140
A.HandlingUseHeavyMul = true

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

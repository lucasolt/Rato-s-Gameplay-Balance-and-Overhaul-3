---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- parametros
----
---- O CTH deixa de ser uma soma de percentuais e passa a sair da razao entre a
---- SILHUETA angular do alvo e a ABERTURA (sigma) do cone de dispersao da arma.
---- Ambas em MINUTOS de angulo -- o engine ja trabalha assim (max_angle_offset =
---- 360*60 no codigo de pellets, MGSetupConeFlat comentado como "minutes").
----
---- Aritmetica INTEIRA em todo o caminho: NetUpdateHash roda por cima disso em
---- co-op (SOURCE_FirearmGetAttackResults.lua:318 e Unit.lua:7089), e qualquer
---- float na geometria vira desync.
----
---- Nada disto faz efeito com const.Combat.Aperture.Enabled = false.
---------------------------------------------------------------------------------------------------

const.Combat.Aperture = {}
local A = const.Combat.Aperture

---- Chave-mestra. false = mod se comporta exatamente como antes (todos os
---- modifiers antigos ativos, CTH_angular inerte).
A.Enabled = false

---- Cobertura por sondagem de silhueta (FUNCTIONS_cover_silhouette.lua). Depende de
---- A.Enabled; separada porque e a parte com custo de raycast, para poder ser
---- desligada sozinha se a performance da IA nao fechar.
A.CoverRaycast = true

---------------------------------------------------------------------------------------------------
---- Escala base
---------------------------------------------------------------------------------------------------

---- Abertura de referencia, em minutos de angulo: atirador de Marksmanship 100,
---- arma de referencia (rat_aperture_base_mul 100), mira alta, sem componentes.
---- Move TUDO -- e o primeiro dial de tuning.
----
---- Calibrado (2026-08-29) contra o CTH que o modelo somado produz hoje, medido em
---- pares reais de unidades via CalcChanceToHit(chance_only) e convertido de volta
---- para sigma pela LUT de Rayleigh. O modelo atual implica:
----   Gewehr98 Marks 80 a 9.5t  -> aim0 86'  aim1 78'  aim2 53'  aim3 39'
----   DoubleBarrel Marks 70 a 10t -> aim0 296' aim1 117' aim2 89' aim3 79'
----   Gewehr98 Marks 80 a 19.9t -> aim2 34'  aim3 25'
---- (o sigma implicito ENCOLHE com a distancia porque o modelo atual e mais generoso
----  que a geometria em alcance longo -- e exatamente o que este refactor corrige)
A.Base = 57

---- Piso mecanico: por melhor que seja o atirador, o cone nao fecha alem disto.
---- Derivado do WeaponRange (a distancia em que a arma foi projetada para acertar):
---- o cone minimo e a silhueta de um alvo em pe no limite do alcance, vezes este %.
A.FloorPct = 55

---------------------------------------------------------------------------------------------------
---- Silhueta -- MEDIDA no jogo (sonda de raios via GetLoFData, 2026-08-29)
----
---- Raio equivalente em CENTIMETROS: sqrt(largura * altura) / 2, medido varrendo
---- raios a partir do ponto de mira de cada body part ate pararem de acertar a
---- unidade. Valores brutos medidos a ~20-25 tiles, alvo humano:
----   Em pe      76 x 95 cm  -> r_eq 42
----   Agachado   59 x 72 cm  -> r_eq 33
----   Prone      74 x 51 cm  -> r_eq 31  (largo de lado, mas baixo)
----   Cabeca     20 x 22 cm  -> r_eq 11  (constante nas tres posturas)
----
---- Prone entra abaixo do medido de proposito: de frente a silhueta e MUITO menor
---- que de lado, e a sonda pegou um alvo de perfil. O -30 flat que o mod cobrava
---- hoje (CTH_cover_prone.lua) e a intencao de balance a preservar.
---------------------------------------------------------------------------------------------------

A.Silhouette = {
    Standing = 42,
    Crouch = 33,
    Prone = 26
}

---- Body part como % do raio da postura.
A.BodyPart = {
    Torso = 100,
    Arms = 62,
    Legs = 62,
    Groin = 55
}

---- Partes que NAO escalam com a postura: raio equivalente ABSOLUTO em cm.
---- A sonda mediu a cabeca em 22 / 20 / 19 cm de largura em pe / agachado / prone --
---- praticamente constante. Escalar a cabeca junto com o corpo (26% de um raio que
---- cai de 42 para 26 cm) fazia o headshot ficar impossivel contra alvo agachado,
---- inclusive com mira maxima.
A.BodyPartAbsolute = {
    Head = 11,
    Neck = 11
}

---------------------------------------------------------------------------------------------------
---- Geometria da silhueta para a SONDAGEM DE COBERTURA
----
---- Meia-largura / meia-altura da caixa da silhueta, em unidades do engine
---- (1000 = 1 m), medidas com a sonda de raios. Dao a extensao da grade fina
---- (A.CoverProbeGrid) ao redor do spot de corpo que o engine devolve.
----
---- A ALTURA do centro nao entra aqui de proposito: a sondagem ancora nos spots
---- reais que o GetLoFData retorna, presos ao esqueleto animado. Estimar a altura
---- (chao + offset por postura) errava ate 0,5 m em Z e, a curta distancia, isso
---- bastava para a sonda ver parede onde o engine tinha linha limpa.
---------------------------------------------------------------------------------------------------

A.Box = {
    Standing = {halfw = 380, halfh = 475},
    Crouch = {halfw = 295, halfh = 360},
    Prone = {halfw = 370, halfh = 255}
}

---- Grade de sondagem fina: fracoes das meias-extensoes, em cada eixo. 3x3 = 9
---- raios, cada um valendo 1/9 da area. Pontos FIXOS e deterministicos: nao
---- consomem random sincronizado, entao sao seguros na previsao (crosshair) e na
---- IA -- e a distincao que torna isto viavel onde um NCTH completo nao seria.
A.ProbeGrid = {-66, 0, 66}

---- Ligar a grade fina custa uma SEGUNDA chamada de GetLoFData por avaliacao.
---- Medido com cache frio: 1,23 ms/call no modelo somado, 13,8 ms/call com a grade,
---- 1,33 ms/call com cache quente. Como a IA avalia muitas posicoes por turno e
---- cada posicao e um cache miss, o padrao e o modo barato: os cinco spots reais
---- que a consulta de ancoras ja devolve (resolucao de 20% em vez de 11%).
A.CoverProbeGrid = false

---- A IA usa `100 - coverage` (o "nivel 1": a porcentagem que o engine ja calcula,
---- sem a escada de InterpolateCoverEffect) em vez de raycast. Ver o bloco de
---- justificativa em FUNCTIONS_cover_silhouette.lua -- e o que mantem o orcamento
---- de turno da IA intacto. false = IA tambem sonda, e paga o custo.
A.CoverAIFallback = true

---- Fracao exposta abaixo da qual o alvo conta como totalmente ocluido.
A.ExposureBlockedPct = 6

---- Quanto do `tohit_mod` de TargetBodyPart ainda vale quando o modelo angular
---- esta ligado. A DIFICULDADE GEOMETRICA de acertar uma parte pequena ja saiu da
---- silhueta acima -- cobrar o tohit_mod inteiro por cima seria contar duas vezes,
---- e zerava cabeca/bracos/pernas a media distancia. O residual representa o que
---- sobra e nao e geometrico: o custo de escolher DELIBERADAMENTE um alvo pequeno,
---- que o sistema de Composure em CTH_targeted_noburst.lua ja modela.
A.TargetedResidualPct = 35

---------------------------------------------------------------------------------------------------
---- Marksmanship escala o cone inteiro
---- x2.60 em Marks 0 .. x1.00 em Marks 100
---------------------------------------------------------------------------------------------------

A.SkillMax = 260 --- multiplicador (%) em Marksmanship 0
A.SkillMin = 100 --- multiplicador (%) em Marksmanship 100

---------------------------------------------------------------------------------------------------
---- AimAccuracy define quanto CADA nivel de mira FECHA o cone
----
---- decay% = 100 - (DecayBase + DecayScale * AimAccuracy)
---- AimAccuracy 3 -> 80% do cone por nivel ; 6 -> 68% ; 9 -> 56%
----
---- Hand-Eye Coordination (Dex+Marks, rGetHandEyeCoordination) escala quanto deste
---- fechamento o atirador realmente COBRA -- e o que "Aiming Rework" ja significa
---- hoje em CTH_aim.lua:125, so que expresso no angulo em vez de em pontos.
---------------------------------------------------------------------------------------------------

A.DecayBase = 8
A.DecayScale = 4
A.DecayMinPct = 40 --- teto de fechamento por nivel (nunca fecha mais que 60%)

---------------------------------------------------------------------------------------------------
---- Degrau de "arma no ombro" -- hipfire / snapshot
----
---- Alargamento aplicado POR CIMA do decay de mira, so ate aim 2. A partir de aim 3
---- a arma esta devidamente encostada e o degrau some (o modelo antigo tambem
---- retornava cedo em `aim > 2`, CTH_hipfire_and_snapshot.lua:61).
----
---- ATENCAO (regra do GBO3): armas leves/curtas sao boas em SNAPSHOT, nao em
---- hipfire. Quem carrega essa distincao e o produto ja tunado de
---- GetWeaponHipfireOrSnapshotMul -- MEDIDO no jogo:
----     arma        hipfire(aim0)   snapshot(aim1+)
----     MP5              135              72        <- hipfire ruim, snapshot otimo
----     Gewehr98          75             187        <- o inverso
----     PSG1              80             190
----     AK47             102             129
----     MG42              94             186        <- ruim nos dois
----
---- Estes produtos NAO sao multiplicadores absolutos de cone -- sao escalas
---- RELATIVAS de penalidade ("a MP5 paga 72% da penalidade de snapshot"). Cada um
---- alimentava sua propria curva (Hipfire.MaxPenalty -123 vs Snapshot.MaxPenalty
---- -61), entao os dois vivem em escalas diferentes e nenhum e comparavel com 100.
----
---- Por isso o produto escala o EXCESSO do alargamento, nunca o cone inteiro:
----     alargamento = 100 + (AimStep[aim] - 100) * produto/100 * manejo/100
----
---- Multiplicar direto daria dois absurdos: um "72" de snapshot FECHARIA o cone
---- (a MP5 mirando 1 nivel ficaria melhor que mirando 3), e um "75" de hipfire
---- seria lido como mais preciso que um "187" de snapshot -- o oposto do que os
---- numeros significam.
----
---- Os valores abaixo sao o alargamento de uma arma de REFERENCIA (produto 100).
---------------------------------------------------------------------------------------------------

A.AimStep = {
    [0] = 280, --- hipfire: x2.80 numa arma de referencia
    [1] = 155, --- snapshot 1 nivel: x1.55
    [2] = 118 --- snapshot 2 niveis: x1.18
}
A.AimStepMaxLevel = 2 --- acima disso a arma esta encostada: alargamento 100

---------------------------------------------------------------------------------------------------
---- Manejo -> semente da propriedade nova `rat_aperture_snap`
----
---- NAO reusa OverwatchAngle como abertura: aquele stat continua existindo e
---- necessario para rotacao de arma / shooting stance / cones de AOE, e a polaridade
---- e oposta (la, maior = melhor setor coberto). O OverwatchAngle so SEMEIA um valor
---- inicial para armas que nao declararam o seu -- estimativa, para tunar depois.
----
---- Polaridade de rat_aperture_snap: multiplicador (%) sobre o degrau de
---- hipfire/snapshot. MENOR = melhor (cone abre menos ao atirar sem mira alta).
---------------------------------------------------------------------------------------------------

A.SeedOWMin = 600 --- OverwatchAngle tratado como "pesada" (Barret 545, MG42 571, PSG1 596)
A.SeedOWMax = 1500 --- OverwatchAngle tratado como "manejavel" (UZI/MP5 1410-1437)
A.SeedSnapHeavy = 125 --- multiplicador para arma pesada
A.SeedSnapHandy = 80 --- multiplicador para arma manejavel

---------------------------------------------------------------------------------------------------
---- LUT de Rayleigh -- P(acerto) = 1 - exp(-k^2 / 2), com k = theta_alvo / sigma
----
---- Rayleigh e a distribuicao correta para dispersao radial em duas dimensoes.
---- Suave e assintotica a 100%, sem o degrau duro do modelo de disco uniforme.
---- Tabulada em POR MIL, indice = k * 8 (passo de 0.125), interpolada linearmente.
---- Fora da tabela (k > 4) o retorno e 1000 por mil.
---------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------
---- Recoil: taxa de abertura do cone por tiro
----
---- excesso = RecoilGrowthBase * mod_de_recoil / 100, onde mod_de_recoil e o produto
---- ja tunado de FUNCTIONS_recoil (arma x componentes x mecanismo x calibre/Forca x
---- ROF x postura x perks). Medido: ~130 na MP5, ~230 no AK47 e na MG42.
----
---- Com RecoilGrowthBase = 13 isso da +17%/tiro na MP5 e +27%/tiro no AK47.
----
---- A distancia NAO some daqui -- ela passa a agir pela geometria: um cone mais
---- aberto custa pouco de perto (o alvo ja e maior que o cone) e muito de longe
---- (a silhueta e a restricao). Ver o bloco em Rat_GetRecoilConeGrowth.
---------------------------------------------------------------------------------------------------

A.RecoilGrowthBase = 13
A.RecoilGrowthMax = 60 --- teto do excesso por tiro (%)

---------------------------------------------------------------------------------------------------

function OnMsg.ClassesGenerate()
    AppendClass.Firearm = {
        properties = {
            ---- Multiplicador (%) do degrau de hipfire/snapshot. Menor = arma aponta
            ---- mais rapido. 0 = nao declarado, semeado do OverwatchAngle em
            ---- Rat_SeedApertureProperties().
            {id = "rat_aperture_snap", editor = "number", default = 0, no_edit = true},
            ---- Multiplicador (%) da abertura BASE da arma, antes de mira e componentes.
            ---- Precisao intrinseca. 100 = arma de referencia.
            {id = "rat_aperture_base_mul", editor = "number", default = 100, no_edit = true}
        }
    }
end

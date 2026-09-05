
const.Combat.Aperture = const.Combat.Aperture or {}
local A = const.Combat.Aperture
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

---- Cobertura por sondagem de silhueta (FUNCTIONS_cover_silhouette.lua). Separada de A.Enabled (custo de raycast).
A.CoverRaycast = true

---- Caixa -> corpo, em %. Os cantos da caixa sao vazios: de pe ela tem 93 cm de largura e o
---- homem tem ~50. E a UNICA constante ajustavel deste caminho -- calibrada contra tiro simulado,
---- nao contra o modelo antigo. Maior = alvo maior = mais CTH.
A.BodyFill = {
    Standing = 77,
    Crouch = 72,
    Prone = 56,
}

---- Meia-largura e meia-altura da CABECA, em mm de verdade. E o segundo retangulo: sem ele o
---- modelo assume largura de ombro na altura da cabeca. Nao passa por BodyFill -- a cabeca
---- preenche a propria caixa; so a cobertura a encolhe.
A.HeadHalfW = 90
A.HeadHalfH = 115

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
A.CoverPenetrationClass = 0--0

---- Fracao exposta abaixo da qual o alvo conta como totalmente ocluido. So no caminho barato da IA.
A.ExposureBlockedPct = 6

---- Silhueta -- raio equivalente em cm, sqrt(largura*altura)/2, medido via GetLoFData 2026-08-29
---- a ~20-25 tiles: pe 76x95 (42), agachado 59x72 (33), prone 74x51 (31), cabeca 20x22 (11).
---- Prone entra ABAIXO do medido de proposito (sonda pegou perfil; preserva o -30 flat de CTH_cover_prone.lua).

A.Silhouette = {
    Standing = 42,
    Crouch = 37,--33,
    Prone = 31 --26
}


---- Estimador (Rat_EstimateBurst): Monte Carlo em cima do MESMO passo que a bala usa, entao nao
---- existe segunda implementacao do recuo para divergir. Semente FIXA de proposito -- a escada
---- vira funcao determinista do perfil, nao treme entre chamadas e nao dessincroniza co-op.
---- O tiro real NAO paga isto: a escada de CTH so serve para exibir, e a bala le `p` direto.
---- MEDIDO contra 3000 rajadas do random sincronizado: 128 amostras erram 5% no |p| do 6o tiro,
---- 384 erram 1%. ~100 ms, e so ferramenta de debug chega aqui.
A.RecoilEstimateSamples = 384
A.RecoilEstimateSeed = 20260904
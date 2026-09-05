


const.Combat.Aperture = const.Combat.Aperture or {}
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

----------------
---- Visual
----------------

---- Anel de mira: desenhado NO MUNDO com o raio real do cone (ver UI_aperture_ring.lua).
---- QUANTOS SIGMAS o anel representa. 1 sigma contem 39% dos tiros; 2.5 contem 96%.
A.CrosshairSigmaMul = 250

---- Segmentos do anel de mira. Mais que isto nao se distingue; menos, vira poligono a queima-roupa.
A.CrosshairRingSegments = 32


---- Teto e piso do multiplicador de UM residual. Sem eles -100 pontos daria cone infinito.
A.ConeMulMin = 25
A.ConeMulMax = 1000

---- SO COR, nao entra em conta nenhuma. Ancoras do gradiente de fator de cone no overlay
---- (Rat_ConeMulTag): MetaScaleWorst = vermelho cheio, 100 = ambar, MetaScaleBest = verde cheio.
---- Worst e o teto contra o qual hipfire/snapshot sao pintados, para 280 e 155 nao sairem iguais.
A.MetaScaleWorst = 300--300
A.MetaScaleBest = 60--60

---------------------------------------------------------------------------------------------------


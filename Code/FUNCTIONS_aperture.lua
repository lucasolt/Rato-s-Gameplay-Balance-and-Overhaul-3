---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- funcoes puras (sem estado, sem random). Aritmetica INTEIRA. Ver __ApertureParams.lua.
---------------------------------------------------------------------------------------------------

---- Sempre a tabela viva: __ApertureParams recria const.Combat.Aperture a cada reload, cachear
---- num upvalue deixava P() preso na tabela velha.
local function P()
    return const.Combat.Aperture
end

---------------------------------------------------------------------------------------------------
---- Aritmetica
---------------------------------------------------------------------------------------------------

---- Raiz quadrada inteira (Newton). O `sqrt` do engine devolve float e nao pode entrar no NetUpdateHash.
function Rat_ISqrt(n)
    if n <= 0 then
        return 0
    end
    local x = n
    local y = (x + 1) / 2
    while y < x do
        x = y
        y = (x + n / x) / 2
    end
    return x
end

---- Meia-largura aparente do alvo, em minutos de angulo. dist em unidades do engine (10 = 1 cm).
---- Fator 34380 = 3438 min/rad com a conversao de cm embutida.
function Rat_ThetaTarget(dist, half_cm)
    if not dist or dist < 1 then
        return 100000 --- encostado
    end
    return Max(1, MulDivRound(half_cm, 34380, dist))
end

---------------------------------------------------------------------------------------------------
---- Silhueta do alvo
---------------------------------------------------------------------------------------------------

---- Raio equivalente do alvo em cm, por postura. `body_part_def` continua no perfil porque meia
---- duzia de chamadas passam a parte, mas NAO muda mais o tamanho: CTH e P(acertar o alvo), e a
---- parte atingida sai da trajetoria. exposed_pct: 0..100 nao ocluido, entra como raiz (area -> raio).
function Rat_TargetSilhouette(target, body_part_def, exposed_pct, stance_override)
    local a = P()

    local stance = stance_override
    if not stance and IsKindOf(target, "Unit") then
        stance = target:GetHitStance()
    end
    local r = a.Silhouette[stance] or a.Silhouette.Standing

    if exposed_pct and exposed_pct < 100 then
        exposed_pct = Max(0, exposed_pct)
        --- raiz de area -> raio: sqrt(pct/100) em % = sqrt(pct * 100)
        r = MulDivRound(r, Rat_ISqrt(exposed_pct * 100), 100)
    end

    return Max(1, r)
end

---- Quatro meias-extensoes do alvo vistas DESTE ponto, em minutos de angulo, mais o ponto de
---- mira, a distancia ate ele e um theta geometrico (equivalente em area) para exibicao.
----
---- Projeta os 8 cantos da caixa da animacao no plano perpendicular a linha de tiro. Isso da o
---- azimute exato e a inclinacao real de graca -- sem tabela, sem interpolar, sem raycast.
---- A ancora do spot importa mais que tudo: mirar a cabeca sobe o ponto de mira ~36 cm e o corpo
---- passa a se estender quase so para baixo. nil = alvo sem caixa (ponto, veiculo): cai no circulo.
function Rat_TargetExtents(attacker_pos, target, spot, exposed_pct, stance_override)
    local a = P()
    ---- sem Z valido a subtracao devolve ponto 2D e dir:z() vira nil no calculo do plano
    attacker_pos = Rat_ValidZ(attacker_pos)
    local o = (IsKindOf(target, "Unit") and target.target_dummy) or target
    if not IsValid(o) or not o.GetEntityBBox then
        return nil
    end
    local bb = o:GetEntityBBox()
    if not bb then
        return nil
    end

    local stance = stance_override
    if not stance and IsKindOf(target, "Unit") then
        stance = target:GetHitStance()
    end
    local part = spot
    if type(part) == "table" then
        part = part.id
    end

    local ang = o:GetOrientationAngle()
    local base = Rat_ValidZ(o:GetPos())
    local mn, mx = bb:min(), bb:max()

    ---- um canto da caixa do frame do corpo para o mundo: a caixa e alinhada aos eixos LOCAIS,
    ---- entao so a guinada roda; z nao gira.
    local function to_world(x, y, z)
        return base + Rotate(point(x, y, 0), ang) + point(0, 0, z)
    end

    ---- ponto de mira = o spot da animacao, o MESMO que a bala persegue (GetLoFData bate exato).
    ---- Nada de tabela por postura: o esqueleto ja sabe onde a cabeca esta neste frame.
    local aim
    if IsKindOf(target, "Unit") then
        local got, p = pcall(target.GetStaticSpotPos, target, part)
        if got and p then
            aim = Rat_ValidZ(p)
        end
    end
    aim = aim or to_world((mn:x() + mx:x()) / 2, (mn:y() + mx:y()) / 2,
                          (mn:z() + mx:z()) / 2)

    local dist = attacker_pos:Dist(aim)
    if dist < 1 then
        return nil
    end

    ---- eixos do plano perpendicular a linha de tiro
    local dir = SetLen(aim - attacker_pos, 1000)
    local upv = point(0, 0, 1000) - MulDivRound(dir, dir:z(), 1000)
    if upv:Len() < 10 then
        upv = point(0, 1000, 0) --- tiro na vertical: qualquer perpendicular serve
    end
    upv = SetLen(upv, 1000)
    local rgt = SetLen(Cross(dir, upv), 1000)

    local up, down, right, left = 0, 0, 0, 0
    for xi = 0, 1 do
        local cx = (xi == 0) and mn:x() or mx:x()
        for yi = 0, 1 do
            local cy = (yi == 0) and mn:y() or mx:y()
            for zi = 0, 1 do
                local v = to_world(cx, cy, (zi == 0) and mn:z() or mx:z()) - aim
                local du, dr = Dot(v, upv) / 1000, Dot(v, rgt) / 1000
                up, down = Max(up, du), Max(down, -du)
                right, left = Max(right, dr), Max(left, -dr)
            end
        end
    end

    ---- caixa -> corpo (os cantos sao vazios), e cobertura como reducao de AREA: a raiz repartida
    ---- pelos dois eixos preserva a fracao exposta que o resto do modelo ja usa.
    local expo = 100
    if exposed_pct and exposed_pct < 100 then
        expo = Rat_ISqrt(Max(0, exposed_pct) * 100)
    end
    local fill = MulDivRound(a.BodyFill[stance] or a.BodyFill.Standing, expo, 100)
    local function minutes(x)
        return Max(1, MulDivRound(MulDivRound(x, fill, 100), 3438, dist))
    end
    ---- deslocamento COM SINAL, sem piso: posicao dentro da silhueta, nao tamanho
    local function offset_min(x, scale)
        return MulDivRound(MulDivRound(x, scale, 100), 3438, dist)
    end

    ---- Segundo retangulo, SO quando se mira a cabeca. A correcao e sobre a mira cair num
    ---- apendice estreito: ai a caixa mente feio, porque supoe largura de ombro na altura da
    ---- cabeca. Mirando no tronco a caixa ja tem a largura certa e separar so tira corpo --
    ---- medido: deitado, separar no tronco da 30% onde o tiro simulado da 52%.
    ---- A cabeca e ~esferica, entao a silhueta dela quase nao muda com o angulo: tamanho
    ---- anatomico constante, encolhido so pela cobertura (BodyFill e o vazio da CAIXA, e a
    ---- cabeca preenche a dela).
    local head
    if part == "Head" and IsKindOf(target, "Unit") then
        local got, hp = pcall(target.GetStaticSpotPos, target, "Head")
        if got and hp then
            local v = Rat_ValidZ(hp) - aim
            head = { offset_min(Dot(v, upv) / 1000, fill), offset_min(Dot(v, rgt) / 1000, fill),
                     Max(1, offset_min(a.HeadHalfW, expo)), Max(1, offset_min(a.HeadHalfH, expo)) }
        end
    end
    up, down, right, left = minutes(up), minutes(down), minutes(right), minutes(left)

    ---- theta GEOMETRICO (equivalente em area) so para exibicao: nao depende de sigma, entao o
    ---- tamanho do alvo mostrado na UI para de encolher quando o jogador mira.
    local theta_geo = Max(1, Rat_ISqrt(MulDivRound(right + left, up + down, 4)))
    return up, down, right, left, theta_geo, aim, dist, head
end

---------------------------------------------------------------------------------------------------
---- Componentes da abertura
---------------------------------------------------------------------------------------------------

---- Marksmanship escala o cone inteiro. x2.60 (Marks 0) .. x1.00 (Marks 100).
function Rat_ApertureSkillMul(attacker, weapon)
    local a = P()
    local skill_name = (weapon and weapon.base_skill) or "Marksmanship"
    local skill = (attacker and attacker[skill_name]) or 50
    skill = Clamp(skill, 0, 100)
    return a.SkillMax - MulDivRound(a.SkillMax - a.SkillMin, skill, 100)
end

---- Opticas com limiar presentes NESTA arma (A.ComponentEffectsAimBonus). Resolvido uma vez por chamada:
---- HasComponent dentro do laco de niveis sai caro no caminho quente (previsao, varredura da IA).
function GetApertureAimComponentEffects(weapon)
    local a = P()
    if not IsKindOf(weapon, "Firearm") then
        return empty_table
    end
    local list, meta
    for _, eff in ipairs(a.ComponentEffectsAimBonus or empty_table) do
		--local modifyVal, compDef =GetComponentEffectValue(weapon, eff, "bonus_cth_v")
		local has, comp = weapon:HasComponent(eff.id)
        if has then
            list = list or {}
            list[#list + 1] = eff
			meta = meta or {}
			meta[#meta +1] = comp.DisplayName or ""
        end
    end
    return list or empty_table, meta or empty_table
end

---- Bonus de AimAccuracy a que ESTE nivel de mira tem direito.
function GetApertureComponentAccBonus(optics, level)
    local bonus = 0
    for _, o in ipairs(optics or empty_table) do
        if level >= o.from and (not o.to or level <= o.to) then
            bonus = bonus + o.acc
        end
    end
    return bonus
end

---- Quanto o nivel `level` de mira fecha o cone, em % (80 = 80% do anterior). AimAccuracy da o
---- teto; Hand-Eye Coordination da quanto disso o atirador cobra (a "Aiming Rework" do mod).
---- Opticas com limiar somam AimAccuracy so nos niveis a que tem direito, entao o decay VARIA
---- por nivel -- `optics` vem pronto de GetApertureAimComponentEffects para nao repetir HasComponent.




function Rat_ApertureAimDecay(weapon, attacker, level, optics)
    local a = P()

    local acc = (weapon and weapon.AimAccuracy) or 3
	local meta = {}

    acc = acc + GetApertureComponentAccBonus(optics or GetApertureAimComponentEffects(weapon), level or 1)

    ---- target camo
    --if IsKindOf(target, "Unit") then
    --    local armor = target:GetItemInSlot("Torso", "Armor")
    --    if armor and armor.Camouflage then
    --        bonus = bonus * Max(0, 100 - const.Combat.CamoAimPenalty) / 100.0 -- MulDivRound(bonus, Max(0, 100 - const.Combat.CamoAimPenalty), 100)
    --        meta[#meta + 1] =
    --            T(396692757033, "Camouflaged - aiming is less effective")
    --    end
    --end

    local decay = 100 - (a.DecayBase + a.DecayScale * acc)

	local decay_muls = const.Combat.Aperture and const.Combat.Aperture.AimDecayMuls or {}
	
	local indoors = attacker and attacker.indoors
	if GameState.RainHeavy and not indoors then
		decay = MulDivRound(decay, decay_muls.HeavyRainAim, 100)
        meta[#meta + 1] = T {901477523654, "(-) Heavy Rain"}
    end
	
	if IsKindOfClasses(weapon, "Pistol", "Revolver") 
	and decay_muls.HandgunPenalty and decay_muls.HandgunPenalty ~= 100 then
        decay = MulDivRound(decay, decay_muls.HandgunPenalty, 100)
		meta[#meta + 1] = T {195655494642, "(-) Handgun"}
    end
	
	----- Stance aim bonus
	
	if attacker then
	    if decay_muls.Crouch  and attacker.stance == "Crouch"  then
            decay = MulDivRound(decay, decay_muls.Crouch or 100, 100)
            meta[#meta + 1] = T {688848752517, "Crouching"}
        elseif decay_muls.Prone and attacker.stance == "Prone" then
            decay = MulDivRound(decay, decay_muls.Prone or 100, 100)
            meta[#meta + 1] = T {271472323596, "Prone"}
        	if decay_muls.ProneGripPenalty and weapon:HasComponent("grip_prone_penalty") then
            	decay = MulDivRound(decay, decay_muls.ProneGripPenalty or 100, 100)
				meta[#meta + 1] = T {85643189456, "(-) Grip while prone"}
			end
		end
	end




    decay = Max(a.DecayMinPct, decay)

    --- Hand-Eye Coordination (Dex+Marks): abaixo de 100 o fechamento e parcial.
    local he = 100
    if attacker and not attacker.placeholder and IsKindOf(weapon, "Firearm") then
        he = Clamp(rGetHandEyeCoordination(attacker) or 100, 10, 100)
    end
    --- decay_efetivo = 100 - (100 - decay) * he/100
    decay = 100 - MulDivRound(100 - decay, he, 100)

	
    return Clamp(decay, a.DecayMinPct, 99), meta
end

---- MANEJO -> multiplicador da abertura base. GetPBbonus ja soma classe + arma + componentes
---- (cano, bullpup, grips, handguard), entao todo componente que dava Point Blank Accuracy passa
---- a dar manejo sem nenhum trabalho por componente. MENOR = melhor.
function Rat_ApertureHandlingMul(weapon)
    local a = P()
    if not IsKindOf(weapon, "FirearmProperties") or not GetPBbonus then
        return 100
    end
    local pb = GetPBbonus(weapon) or 0
    if pb == 0 then
        return 100
    end
    return Clamp(100 - MulDivRound(a.HandlingScale or 0, pb, 100), a.HandlingMin or 60,
                 a.HandlingMax or 140)
end

---- Ampliacao da optica montada -> multiplicador do PISO (A.ScopeFloorMul). Le o tier pelo id do
---- componente ou pelo ancestral GBO (variantes ToG apontam para o componente base).
function Rat_ScopeFloorMul(weapon)
    local a = P()
    local muls = a.ScopeFloorMul
    if not muls or not IsKindOf(weapon, "Firearm") or not weapon.components then
        return 100
    end
    local tiers = a.ApertureComponentTier or empty_table
    for _, cid in sorted_pairs(weapon.components) do
        local comp = WeaponComponents[cid]
        local tier = comp and (tiers[cid] or tiers[comp.GBO_ComponentAncestor or ""])
        local mul = tier and muls[tier]
        if mul then
            return mul
        end
    end
    return 100
end

---- Piso mecanico do cone, derivado do WeaponRange -- a ASSINTOTA do tiro mirado. Opticas nao dao
---- mais WeaponRange; a "cereja" delas entra aqui, so no piso, entao e invisivel com pouca mira
---- (no aim 0 o cone e ~10x o piso) e vale tudo com mira cheia. Canos longos continuam pelo range.
function Rat_ApertureFloor(weapon)
    local a = P()
    local range = (weapon and weapon.WeaponRange) or 20
    local floor_dist = range * const.SlabSizeX
    local theta = Rat_ThetaTarget(floor_dist, a.Silhouette.Standing)
    local floor = MulDivRound(theta, a.FloorPct, 100)
    return Max(1, MulDivRound(floor, Rat_ScopeFloorMul(weapon), 100))
end

---------------------------------------------------------------------------------------------------
---- Abertura (sigma), em minutos de angulo
---------------------------------------------------------------------------------------------------


---- Retorna sigma e a lista de contribuicoes (para a UI mostrar em minutos de cone,
---- no lugar da lista aditiva de pontos percentuais que o modelo antigo exibia).
function Rat_GetAperture(weapon, attacker, action, aim, opportunity_attack)
    local a = P()
    aim = aim or 0

    local meta = {}
    local s = a.Base

    --- 1. manejo da arma (o antigo Point Blank Accuracy). Multiplica sigma_0, entao o efeito
    ---    decai a cada nivel de mira em vez de ser um desconto fixo no cone final.
    local base_mul = Rat_ApertureHandlingMul(weapon)
    if base_mul ~= 100 then
        s = MulDivRound(s, base_mul, 100)
    end

    --- 2. Marksmanship escala o cone inteiro
    local skill_mul = Rat_ApertureSkillMul(attacker, weapon)
    s = MulDivRound(s, skill_mul, 100)

    --- 3. quadro de visada da mira (AccuracyBonusWhenAimed). Antes do decay de PROPOSITO: fecha
    ---    o gap ate o piso, ou seja e ganho de velocidade de convergencia, nao assintota nova.
    local sight = 100
    if aim > 0 and a.SightAimBonus and IsKindOf(weapon, "Firearm") then
        local points, comp = GetComponentEffectValue(weapon, "AccuracyBonusWhenAimed", "bonus_cth")
        if points and points ~= 0 then
            sight = Rat_ConeMulForPoints(points)
            s = MulDivRound(s, sight, 100)
			meta[#meta + 1] = comp.DisplayName
        end
    end

    --- 4. cada nivel de mira FECHA o cone, em direcao ao piso da arma
    local comps, metaTextComps = GetApertureAimComponentEffects(weapon)
    local floor = Rat_ApertureFloor(weapon)
    ---- escada de decay: com limiar de optica cada nivel fecha um tanto diferente. Guardada
    ---- inteira para o overlay enumerar nivel a nivel (ver Rat_ConeFactors).
    local ladder = {}
	local aimMetaText
    for i = 1, aim do
        ladder[i], aimMetaText = Rat_ApertureAimDecay(weapon, attacker, i, comps)
    end
    ---- um numero so, para quem nao quer a escada: o do ULTIMO nivel aplicado
    local decay = ladder[aim]
	if not decay then
		decay, aimMetaText = Rat_ApertureAimDecay(weapon, attacker, 1, comps)
	end

    ---- cone antes de mirar: o overlay converte o decay do gap em multiplicador do cone INTEIRO
    ---- (gap_mul so faz sentido contra o piso), para que o produto das linhas feche no Total.
    local pre_aim = s

    if a.ApertureAsymptotic then
        ---- sigma = piso + (sigma0 - piso) * prod(decay_i). Converge para o piso em vez de bater
        ---- nele: cada stat sempre rende (AimAccuracy = velocidade, WeaponRange/scope = assintota).
        local gap = Max(0, s - floor)
        for i = 1, aim do
            gap = MulDivRound(gap, ladder[i], 100)
        end
        s = floor + gap
    else
        for i = 1, aim do
            s = MulDivRound(s, ladder[i], 100)
        end
    end

    --- 5. degrau de "arma no ombro" (hipfire/snapshot). GetWeaponHipfireOrSnapshotMul
    ---    escala so o EXCESSO do alargamento, nunca o cone inteiro. Ver AimStep em __ApertureParams.lua.
    local hipsnap, step = 100, 100
    if aim <= a.AimStepMaxLevel then
        if weapon and GetWeaponHipfireOrSnapshotMul then
            local m = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, true, aim)
            hipsnap = Clamp(cRound((m or 1.0) * 100), 25, 400)
        end

        local excess = (a.AimStep[aim] or 100) - 100
        if excess > 0 then
            ---- `hipsnap` ja traz wep_base_hip_mul / wep_base_snapshot_mul da arma; nao ha
            ---- segundo multiplicador de manejo aqui de proposito.
            excess = MulDivRound(excess, hipsnap, 100)
            step = 100 + excess

			local original_s_debug = s
            s = MulDivRound(s, step, 100)
            ---- o % vai no proprio rotulo: e o alargamento que ESTE degrau aplicou ao cone
            local tag = Rat_PctTagPenaltyOnly(step, a.MetaScaleWorst)
            meta[#meta + 1] = (aim == 0) and T {936174028553, "Hipfire <pct>", pct = tag} or
                                  T {418205963714, "Snapshot <pct>", pct = tag}

			--print(meta[#meta][2], "hipsnap = ", hipsnap, "excess = ", excess, "step = ", step, "s = ", s, "original = ", original_s_debug)
        end
    end

    --- 6. piso mecanico do WeaponRange (so no modelo antigo; no assintotico o piso
    ---    ja entrou como assintota no passo 4)
    if not a.ApertureAsymptotic and s < floor then
        s = floor
        meta[#meta + 1] = T(353401714895, "Range")
    end

	---- opticas (limiar), stance, handgun, grip: so mexem no DECAY, entao ficam SOB a linha Aim
	---- no overlay -- nao na linha-mestre Aperture. Ver Rat_ConeFactors / UI_aperture_breakdown.
	local aim_meta
	if aim > 0 then
		aim_meta = {}
		for _, v in ipairs(metaTextComps) do
			if v and v ~= "" then aim_meta[#aim_meta + 1] = v end
		end
		for _, v in ipairs(aimMetaText or empty_table) do
			if v and v ~= "" then aim_meta[#aim_meta + 1] = v end
		end
		if #aim_meta == 0 then aim_meta = nil end
	end

    return Max(1, s), meta, {
        base = a.Base,
        base_mul = base_mul,
        hipsnap = hipsnap,
        skill = skill_mul,
        sight = sight,
        pre_aim = pre_aim,
        decay = decay,
        decay_ladder = ladder,
        step = step,
        floor = floor,
        aim_meta = aim_meta
    }
end

---------------------------------------------------------------------------------------------------
---- Abertura -> CTH
---------------------------------------------------------------------------------------------------

---- P = 1 - exp(-k^2 / 2), k = theta/sigma. LUT interpolada, em porcento.
function Rat_RayleighCTH(theta, sigma)
    local a = P()
    if not sigma or sigma < 1 then
        return 100
    end

    local k1000 = MulDivRound(theta, 1000, sigma)
    local step = a.RayleighStep
    local idx = k1000 / step
    local last = #a.Rayleigh

    if idx >= last then
        return 100
    end

    local lo = a.Rayleigh[idx]
    local hi = a.Rayleigh[idx + 1]
    local frac = k1000 - idx * step
    local permil = lo + MulDivRound(hi - lo, frac, step)

    return MulDivRound(permil, 100, 1000)
end

---- Massa normal entre o centro e `x`, em permil (0..500). LUT interpolada, um eixo so.
local function normal_half(x, sigma)
    local a = P()
    local tbl, step = a.NormalBand, a.NormalStep
    local z = MulDivRound(x, 1000, sigma)
    local i = z / step
    if i >= #tbl then
        return 500
    end
    return tbl[i] + MulDivRound(tbl[i + 1] - tbl[i], z - i * step, step)
end

---- P = Px * Py, cada eixo a massa normal entre -esq e +dir. Substitui o circulo equivalente em
---- AREA, que nao preserva probabilidade: o mesmo sigma que da Rayleigh no raio da a normal por
---- eixo, entao nenhum numero de sigma ja tunado precisa mexer. Em porcento.
---- massa entre dois limites com sinal, nao so simetrica: e o que separa a faixa do tronco da
---- faixa da cabeca sem contar a intersecao duas vezes.
local function normal_band(lo, hi, sigma)
    if hi <= lo then
        return 0
    end
    if lo >= 0 then
        return normal_half(hi, sigma) - normal_half(lo, sigma)
    end
    if hi <= 0 then
        return normal_half(-lo, sigma) - normal_half(-hi, sigma)
    end
    return normal_half(-lo, sigma) + normal_half(hi, sigma)
end

---- DOIS retangulos empilhados, nao um. `head` = {hu, hr, hw, hh} em minutos, deslocamento do
---- centro da cabeca em relacao a mira e as meias-dimensoes dela.
----
---- A uniao continua fechada porque as duas faixas em Y sao DISJUNTAS (o tronco e cortado no
---- ombro, exatamente onde a cabeca comeca) e a largura e constante dentro de cada faixa:
----     P = Px_tronco * Py_tronco + Px_cabeca * Py_cabeca
---- Um retangulo so assumia largura de ombro na altura da cabeca -- 35% previsto contra 18%
---- medido em tiro na cabeca de alvo de pe, longe, com cone apertado.
function Rat_SeparableCTH(sigma, up, down, right, left, head)
    if not sigma or sigma < 1 then
        return 100
    end
    local body_up = up
    local p_head = 0
    if head then
        local hu, hr, hw, hh = head[1], head[2], head[3], head[4]
        ---- Separar so vale se a cabeca chega ao topo E o corpo pendura ABAIXO dela, em vez de
        ---- se espalhar ao lado. Em `ar_TakeCover_Idle` a cabeca fica encaixada entre os ombros
        ---- (o spot Torso do motor chega a ficar ACIMA do da cabeca) e deitado o corpo fica ao
        ---- lado: nos dois a caixa ja tem a largura certa e cortar o ombro comia corpo -- medido,
        ---- dava 40% onde o tiro simulado deu 69%. Agachado de verdade (`ar_Crouch_Idle`) a
        ---- cabeca sobra igual a de pe, e ai separa.
        if hu + hh >= up - hh and down > right + left then
            body_up = Min(up, hu - hh) --- o tronco comeca no ombro, abaixo da cabeca
            p_head = MulDivRound(normal_band(hr - hw, hr + hw, sigma),
                                 normal_band(hu - hh, hu + hh, sigma), 1000)
        end
    end
    local px = normal_half(right, sigma) + normal_half(left, sigma)
    local py = normal_band(-down, body_up, sigma)
    return MulDivRound(MulDivRound(px, py, 1000) + p_head, 100, 1000)
end

---- Raio EQUIVALENTE EM PROBABILIDADE: o circulo que, neste sigma, teria exatamente este CTH.
---- E o que deixa theta continuar sendo a moeda unica do resto do modelo (anel da UI, escada de
---- recuo, Rat_ConeMulForPoints) agora que a chance sai de quatro extensoes e nao de um raio.
---- Efeito colateral desejado: o circulo desenhado passa a ser o circulo HONESTO do alvo.
function Rat_ThetaEquivalent(sigma, cth)
    local k1000 = Rat_KForCTH(cth)
    if not k1000 or not sigma then
        return nil
    end
    return Max(1, MulDivRound(sigma, k1000, 1000))
end

---------------------------------------------------------------------------------------------------
---- CTH geometrico completo
---------------------------------------------------------------------------------------------------

---- Retorna cth (0..100), sigma, theta e metaText.
---- `exposed_pct` (0..100): fracao da silhueta nao ocluida por cobertura; nil = mede sozinho.
function Rat_AngularCTH(attacker, target, body_part_def, action, weapon, aim, opportunity_attack,
                        attacker_pos, target_pos, exposed_pct)
    local a = P()

    attacker_pos = attacker_pos or (attacker and attacker:GetPos())
    target_pos = target_pos or (IsPoint(target) and target) or (IsValid(target) and target:GetPos())
    if not attacker_pos or not target_pos then
        return 0
    end

    local dist = attacker_pos:Dist(target_pos)

    local sigma, meta, parts = Rat_GetAperture(weapon, attacker, action, aim, opportunity_attack)

    ---- Cobertura = silhueta menor, nao penalidade. Fracao exposta via raycast (FUNCTIONS_cover_silhouette.lua).
    if exposed_pct == nil and a.CoverRaycast then
        exposed_pct = Rat_MeasureExposure(attacker, target, attacker_pos, target_pos, body_part_def,
                                          weapon)
    end

    ---- totalmente ocluido: CTH 0 exato (AIPrecalcConeTargetZones descarta o alvo; UI mostra sem tiro).
    if exposed_pct == 0 then
        return 0, sigma, 0, meta, parts, dist, 0
    end

    local half_cm = Rat_TargetSilhouette(target, body_part_def, exposed_pct)
    local up, down, right, left, theta_geo, _, _, head =
        Rat_TargetExtents(attacker_pos, target, body_part_def, exposed_pct)

    local cth, theta
    if up then
        cth = Clamp(Rat_SeparableCTH(sigma, up, down, right, left, head), a.MinCTH, a.MaxCTH)
        theta = Rat_ThetaEquivalent(sigma, cth)
    end
    if not theta then
        ---- alvo sem caixa (ponto, veiculo, destrutivel) ou CTH fora da LUT: circulo mesmo.
        theta = Rat_ThetaTarget(dist, half_cm)
        theta_geo = theta
        cth = Clamp(Rat_RayleighCTH(theta, sigma), a.MinCTH, a.MaxCTH)
    end

    return cth, sigma, theta, meta, parts, dist, half_cm, up, down, right, left, theta_geo, head
end

---------------------------------------------------------------------------------------------------
---- SIMULACAO: onde a bala cai. Rayleigh invertida sorteia o desvio -> numero exibido e tiro
---- concordam por construcao. Nao usar o sorteio uniforme dos pellets (4x no tiro dificil).
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---- Circulo deslocado: o CTH quando o recuo ja levou o centro de mira a `mu` do alvo.
---- Rayleigh e o caso mu = 0 e continua sendo o caminho do tiro 1 -- bit a bit, para que nenhum
---- numero ja tunado se mexa. Com mu > 0 a nuvem vira anel e so a LUT 2D acerta a curva.
---------------------------------------------------------------------------------------------------
function Rat_RiceCTH(theta, sigma, mu)
    ---- mu < 0 = cano passou do alvo (supercompensacao); o que conta e a DISTANCIA ao centro
    mu = mu and abs(mu) or 0
    if mu <= 0 then
        return Rat_RayleighCTH(theta, sigma)
    end
    local a = P()
    if not sigma or sigma < 1 then
        return 100
    end

    local tbl = a.OffsetCircle
    local kstep, mstep = a.OffsetCircleKStep, a.OffsetCircleMStep
    local kmax, mmax = #tbl[0], #tbl

    ---- fora da tabela em m o alvo esta a mais de 8 sigma do cano: a cauda ja e zero na ultima
    ---- linha para todo k realista, entao o clamp nao inventa acerto nenhum.
    local ki = Clamp(MulDivRound(theta, 1000, sigma) / kstep, 0, kmax - 1)
    local mi = Clamp(MulDivRound(mu, 1000, sigma) / mstep, 0, mmax - 1)
    local kf = Clamp(MulDivRound(theta, 1000, sigma) - ki * kstep, 0, kstep)
    local mf = Clamp(MulDivRound(mu, 1000, sigma) - mi * mstep, 0, mstep)

    ---- bilinear: primeiro em k dentro de cada linha, depois entre as duas linhas
    local function at(row)
        local r = tbl[row]
        return r[ki] + MulDivRound(r[ki + 1] - r[ki], kf, kstep)
    end
    local lo, hi = at(mi), at(mi + 1)
    local permil = lo + MulDivRound(hi - lo, mf, mstep)

    return MulDivRound(permil, 100, 1000)
end

---- Coeficientes binomiais ate n = MaxShotIndexForRecoilCTHLoss (6). C[n][j + 1].
local Rat_Binomial = {
    [0] = {1}, {1, 1}, {1, 2, 1}, {1, 3, 3, 1}, {1, 4, 6, 4, 1}, {1, 5, 10, 10, 5, 1},
    {1, 6, 15, 20, 15, 6, 1}
}

---- CTH do tiro que ja levou `n` coices, cada um sorteado contra `chance` de ser segurado.
---- `mu` nao e um numero, e uma distribuicao -- com n <= 6 ela tem no maximo 7 valores, entao a
---- esperanca sai EXATA pela mistura binomial em vez de por um mu medio (que subestimaria a
---- perda: P e concava em mu no regime que interessa).
function Rat_BurstShotCTH(theta, sigma, n, climb, chance)
    if n <= 0 or not climb or climb <= 0 then
        return Rat_RayleighCTH(theta, sigma)
    end
    n = Min(n, #Rat_Binomial)

    local held = Rat_RecoilHeldStep(climb)
    local row = Rat_Binomial[n]
    local acc, wsum = 0, 0
    for j = 0, n do
        local w = row[j + 1] * 10000
        for _ = 1, j do
            w = MulDivRound(w, chance, 100)
        end
        for _ = 1, n - j do
            w = MulDivRound(w, 100 - chance, 100)
        end
        if w > 0 then
            acc = acc + w * Rat_RiceCTH(theta, sigma, j * held + (n - j) * climb)
            wsum = wsum + w
        end
    end
    return (wsum > 0) and MulDivRound(acc, 1, wsum) or 0
end

---- Inversa da LUT: k*1000 que produz exatamente `cth`. Nao depende de theta -- e o que permite
---- traduzir pontos de CTH em multiplicador de cone sem olhar para o tamanho do alvo.
function Rat_KForCTH(cth)
    local a = P()
    cth = Clamp(cth or 0, 1, 99)
    local permil = cth * 10
    local tbl, step = a.Rayleigh, a.RayleighStep

    for i = 1, #tbl do
        if tbl[i] >= permil then
            local lo, hi = tbl[i - 1], tbl[i]
            local frac = (hi > lo) and MulDivRound(permil - lo, step, hi - lo) or 0
            local k1000 = (i - 1) * step + frac
            return (k1000 >= 1) and k1000 or nil --- cone praticamente infinito
        end
    end
    return #tbl * step --- CTH altissimo: cone bem dentro do alvo
end

---- Sigma que produziria exatamente `cth` contra um alvo de meia-largura `theta`. So o caminho de
---- sanidade da LUT (Rat_DbgVerifySim); o cone de verdade vem de Rat_AttackCone, nunca da inversao.
function Rat_SigmaForCTH(theta, cth)
    if not theta or theta < 1 then
        return nil
    end
    local k1000 = Rat_KForCTH(cth)
    if not k1000 then
        return nil
    end
    return Max(1, MulDivRound(theta, 1000, k1000))
end

---- Pontos de CTH -> multiplicador de cone (%, 100 neutro, >100 abre). A moeda dos residuais.
---- Os pontos sao ABSOLUTOS: +18 leva o CTH de REFERENCIA de 50 para 68, nao uma fracao do que
---- falta. Avaliar num CTH fixo faz theta se cancelar na razao de k, e so por isso o mesmo cone
---- vale para todas as partes do corpo. Longe de ConeRefCTH a entrega diverge da face. Ver A.ConeRefCTH.
function Rat_ConeMulForPoints(points)
    local a = P()
    if not points or points == 0 then
        return 100
    end

    local ref = Clamp(a.ConeRefCTH or 50, 2, 98)
    local target = Clamp(ref + points, 1, 99)

    local k_ref, k_tgt = Rat_KForCTH(ref), Rat_KForCTH(target)
    if not k_ref or not k_tgt or k_tgt < 1 then
        return a.ConeMulMax
    end
    return Clamp(MulDivRound(k_ref, 100, k_tgt), a.ConeMulMin, a.ConeMulMax)
end

---- Cone FINAL de um ataque: geometria ja alargada/fechada pelos residuais. Quem resolve e
---- CalcChanceToHit, que devolve o cone nos proprios args -- aqui so se sonda uma vez.
function Rat_AttackCone(attacker, target, action, spot, aim, opportunity_attack, step_pos, target_pos)
    if not IsValid(attacker) or not target or not action then
        return nil
    end
    local args = {target_spot_group = spot, aim = aim or 0, prediction = true,
                  opportunity_attack = opportunity_attack,
                  step_pos = step_pos or attacker:GetPos(),
                  target_pos = target_pos or (IsPoint(target) and target) or target:GetPos()}
    local cth = attacker:CalcChanceToHit(target, action, args, "chance_only")
    return args.rat_sigma, args.rat_theta, cth
end


---- Desvio radial de UM tiro, em minutos de angulo. Consome random SINCRONIZADO,
---- entao so pode ser chamada na resolucao do tiro, nunca em previsao.
function Rat_SampleShotOffset(attacker, sigma)
    local a = P()
    if not sigma or sigma < 1 then
        return 0
    end
    local u = attacker:Random(1000)
    local T, step = a.Rayleigh, a.RayleighStep

    local k1000 = #T * step
    for i = 1, #T do
        if T[i] >= u then
            local lo, hi = T[i - 1], T[i]
            local frac = (hi > lo) and MulDivRound(u - lo, step, hi - lo) or 0
            k1000 = (i - 1) * step + frac
            break
        end
    end

    return MulDivRound(sigma, k1000, 1000)
end

---- Sem Z valido a subtracao de pontos devolve um ponto 2D e o eixo vertical some inteiro --
---- Rat_PerpUp caia no fallback horizontal sem avisar. Toda origem/alvo passa por aqui antes.
function Rat_ValidZ(p)
    if p and not p:IsValidZ() then
        return p:SetTerrainZ()
    end
    return p
end

---- Base do plano perpendicular a linha de tiro: componente VERTICAL de `up` que sobra depois de
---- tirar a paralela. Sem isto o raio efetivo encolhe com a inclinacao do tiro. `dir` ja normalizado
---- em 1000. Devolve tambem "para cima" no plano, que e a direcao que o recuo usa.
local function Rat_PerpUp(dir)
    local up = point(0, 0, 1000)
    local par = Dot(up, dir) / 1000
    local perp = up - MulDivRound(dir, par, 1000)
    if perp:Len() < 10 then
        ---- tiro na vertical: nao ha "para cima" no plano, qualquer eixo serve
        perp = point(-dir:y(), dir:x(), 0)
    end
    return perp
end

---- Desvio angular -> ponto no plano perpendicular a linha de tiro (RotateAxis, como os pellets).
function Rat_ShotScatterPoint(attacker, attack_pos, aim_pos, sigma)
    if not attack_pos or not aim_pos then
        return aim_pos
    end
    attack_pos, aim_pos = Rat_ValidZ(attack_pos), Rat_ValidZ(aim_pos)

    local dir = aim_pos - attack_pos
    local dist = dir:Len()
    if dist < 1 then
        return aim_pos
    end

    local offset_min = Rat_SampleShotOffset(attacker, sigma)
    if offset_min <= 0 then
        return aim_pos
    end
    ---- raio linear no plano do alvo: dist * angulo, com 3438 minutos por radiano
    local radius = MulDivRound(dist, offset_min, 3438)
    if radius < 1 then
        return aim_pos
    end

    dir = SetLen(dir, 1000)
    local perp = SetLen(Rat_PerpUp(dir), radius)

    return aim_pos + RotateAxis(perp, dir, attacker:Random(360 * 60))
end

---------------------------------------------------------------------------------------------------
---- RECUO: o cano sobe numa direcao e a rajada anda por ela. E a estrutura de
---- Firearm:CalcShotVectors (Weapon.lua:1612) -- UM eixo sorteado por ataque, deslocamento
---- crescente ao longo dele, dispersao redonda pequena por cima -- so que la e enfeite sobre um
---- resultado ja sorteado e aqui e a bala de verdade. Ver Rat_GetRecoilClimb.
---------------------------------------------------------------------------------------------------

---- Eixo da caminhada, sorteado UMA vez por rajada: "para cima" no plano do alvo, girado por um yaw
---- aleatorio de +/- A.RecoilWalkYaw. Consome random sincronizado -> so na resolucao.
function Rat_RecoilWalkAxis(attacker, attack_pos, aim_pos)
    local a = P()
    local dir = Rat_ValidZ(aim_pos) - Rat_ValidZ(attack_pos)
    if dir:Len() < 1 then
        return point(0, 0, 1000)
    end
    dir = SetLen(dir, 1000)

    local axis = SetLen(Rat_PerpUp(dir), 1000)
    local yaw = Clamp(a.RecoilWalkYaw or 0, 0, 180) * 60
    if yaw > 0 then
        axis = RotateAxis(axis, dir, attacker:RandRange(-yaw, yaw))
    end
    return axis
end

---- Rolagem de controle de UM tiro: o atirador segurou o cano? Consome random sincronizado.
local function Rat_RecoilHeld(attacker, chance)
    return chance > 0 and attacker:Random(100) < chance
end

---- Delta de UM tiro segurado: passa o residual e ainda PUXA de volta RecoilCorrectPct de `climb`.
---- Negativo quando a correcao supera o residual -- e por onde o mu acumulado desce e cruza zero.
---- Global porque Rat_BurstShotCTH usa o MESMO passo: se os dois lados calcularem separado,
---- previsao e bala divergem sem avisar.
function Rat_RecoilHeldStep(climb)
    local a = P()
    return MulDivRound(climb, Clamp(a.RecoilControlResidual or 0, 0, 100), 100) -
               MulDivRound(climb, Clamp(a.RecoilCorrectPct or 0, 0, 100), 100)
end

---- Um degrau da caminhada: o cano sobe `climb`, ou anda o passo segurado (que pode ser para baixo).
local function Rat_RecoilStep(attacker, mu, climb, chance)
    if Rat_RecoilHeld(attacker, chance) then
        return mu + Rat_RecoilHeldStep(climb)
    end
    return mu + climb
end

---- Ponto de mira ja deslocado pela subida acumulada `mu` (minutos). Puro: sem random.
function Rat_RecoilWalkPoint(attack_pos, aim_pos, axis, mu)
    if not mu or mu == 0 or not axis then
        return aim_pos
    end
    local dist = Rat_ValidZ(attack_pos):Dist(Rat_ValidZ(aim_pos))
    local rise = MulDivRound(dist, mu, 3438)
    ---- rise < 0 = cano abaixo da mira; SetLen nao aceita comprimento negativo
    if rise > 0 then
        return aim_pos + SetLen(axis, rise)
    elseif rise < 0 then
        return aim_pos - SetLen(axis, -rise)
    end
    return aim_pos
end

---------------------------------------------------------------------------------------------------
---- SIMULACAO: nucleo compartilhado entre o tiro real e o visualizador -- tem que ser o MESMO
---- procedimento. Garantia via Rat_SimSnapshot + Rat_DbgVerifySim (replay dos args do ultimo tiro).
---------------------------------------------------------------------------------------------------

---- Ponto de mira. O spot "Torso" nao e o centro da silhueta e Rayleigh pressupoe espalhamento
---- centrado -> desvia para o centroide vertical dos spots do LoF. A.AimCentroidPct: 0 spot .. 100
---- centroide. So eixo vertical, so sem parte do corpo pedida.
function Rat_SimAimPos(lof, spot, fallback)
    local a = P()
    local aim_pos
    for _, l in ipairs(lof or empty_table) do
        if l.target_spot_group == spot then
            aim_pos = l.target_pos
        end
    end
    aim_pos = aim_pos or (lof and lof[1] and lof[1].target_pos) or fallback
    if not aim_pos then
        return fallback
    end

    local pct = a.AimCentroidPct or 0
    local default_spot = (not spot) or spot == "Torso" or spot == g_DefaultShotBodyPart
    if pct <= 0 or not default_spot or not lof or #lof < 2 then
        return aim_pos
    end

    local sz, n = 0, 0
    for _, l in ipairs(lof) do
        if l.target_pos then
            sz = sz + l.target_pos:z()
            n = n + 1
        end
    end
    if n < 2 then
        return aim_pos
    end
    return aim_pos:SetZ(aim_pos:z() + MulDivRound(sz / n - aim_pos:z(), pct, 100))
end

---- Plano de tiro: theta, sigma, ponto sorteado de cada tiro. Consome random sincronizado,
---- so na resolucao. ctx ENTRA: attacker target action weapon aim opportunity_attack spot
---- attack_pos aim_pos step_pos target_pos cth num_shots [sigma]. ctx SAI: theta geo_sigma sigma
---- climb control_chance walk_axis shots[i] = {sigma, mu, target_pos}
function Rat_SimPlanShots(ctx)
    local _, geo_sigma, theta = Rat_AngularCTH(ctx.attacker, ctx.target, ctx.spot, ctx.action,
                                               ctx.weapon, ctx.aim or 0, ctx.opportunity_attack,
                                               ctx.step_pos, ctx.target_pos)
    ctx.theta, ctx.geo_sigma = theta, geo_sigma

    ---- o cone JA vem resolvido de CalcChanceToHit (args.rat_sigma); sem ele, sonda uma vez.
    local sigma = ctx.sigma
    if not sigma then
        sigma = Rat_AttackCone(ctx.attacker, ctx.target, ctx.action, ctx.spot, ctx.aim,
                               ctx.opportunity_attack, ctx.step_pos, ctx.target_pos)
    end
    ctx.sigma = sigma
    if not sigma or sigma < 1 then
        return nil
    end

    ---- uma so vez: o eixo do recuo, a caminhada e a dispersao tem de ver a MESMA geometria
    ctx.attack_pos, ctx.aim_pos = Rat_ValidZ(ctx.attack_pos), Rat_ValidZ(ctx.aim_pos)

    local num_shots = Max(1, ctx.num_shots or 1)
    local cth, climb, chance, sigma_disp =
        Rat_SimRecoilLadder(ctx.attacker, ctx.action, ctx.weapon, sigma, num_shots, theta)
    ctx.climb, ctx.control_chance, ctx.num_shots = climb, chance, num_shots

    ---- UM eixo para a rajada inteira: e o que faz o grupo virar risco em vez de nuvem
    local axis = (climb > 0 and num_shots > 1) and
                     Rat_RecoilWalkAxis(ctx.attacker, ctx.attack_pos, ctx.aim_pos) or nil
    ctx.walk_axis = axis

    local max_idx = const.Combat.MaxShotIndexForRecoilCTHLoss or 6

    ---- em "growth" o recuo esta NO CONE, entao a bala tem de sair do cone alargado do tiro i
    local growth_mode = (P().RecoilMode == "growth")
    ctx.sigma_disp = sigma_disp

    local shots, mu = {}, 0
    for i = 1, num_shots do
        ---- a mira do tiro i sai de onde o recuo ja deixou o cano; a dispersao continua sendo o
        ---- cone da arma, do mesmo tamanho em todos os tiros -- recuo desloca, nao espalha.
        local aim_pos = axis and Rat_RecoilWalkPoint(ctx.attack_pos, ctx.aim_pos, axis, mu) or
                            ctx.aim_pos
        local disp = growth_mode and (sigma_disp[i] or sigma) or sigma
        shots[i] = {
            ---- cone de EXIBICAO: o que daria este mesmo CTH contra este alvo. A dispersao que a
            ---- bala usa e sempre `sigma` -- o recuo esta em `mu`, nao no cone.
            sigma = sigma_disp[i] or sigma,
            cth = cth[i],
            mu = mu,
            target_pos = Rat_ShotScatterPoint(ctx.attacker, ctx.attack_pos, aim_pos, disp)
        }
        ---- o coice deste tiro so conta para o PROXIMO, e so ate max_idx (a arma reassenta)
        if axis and i <= max_idx then
            mu = Rat_RecoilStep(ctx.attacker, mu, climb, chance)
        end
    end
    ctx.shots = shots
    return shots
end

---- UMA realizacao independente do tiro `idx` da mesma rajada: eixo e rolagens de controle
---- proprios. E como o visualizador amostra a distribuicao do tiro N sem repetir a rajada inteira.
---- Exige ctx ja resolvido por Rat_SimPlanShots (sigma, climb, control_chance).
function Rat_SimReplanShot(ctx, idx)
    idx = Max(1, idx or 1)
    local climb, chance = ctx.climb or 0, ctx.control_chance or 0
    local axis = (climb > 0 and idx > 1) and
                     Rat_RecoilWalkAxis(ctx.attacker, ctx.attack_pos, ctx.aim_pos) or nil
    local max_idx = const.Combat.MaxShotIndexForRecoilCTHLoss or 6

    local mu = 0
    for i = 1, idx - 1 do
        if axis and i <= max_idx then
            mu = Rat_RecoilStep(ctx.attacker, mu, climb, chance)
        end
    end

    local aim_pos = axis and Rat_RecoilWalkPoint(ctx.attack_pos, ctx.aim_pos, axis, mu) or
                        ctx.aim_pos
    local disp = ctx.sigma
    if P().RecoilMode == "growth" and ctx.sigma_disp then
        disp = ctx.sigma_disp[idx] or disp
    end
    return {
        mu = mu,
        target_pos = Rat_ShotScatterPoint(ctx.attacker, ctx.attack_pos, aim_pos, disp)
    }
end


---- Modo "growth": o sigma de cada tiro da rajada. O recuo alarga o cone, o cano nao anda.
function Rat_SimSigmaLadder(attacker, action, weapon, sigma0, num_shots)
    num_shots = Max(1, num_shots or 1)
    local growth = (num_shots > 1) and
                       Rat_GetRecoilConeGrowth(attacker, action, weapon, num_shots) or 100
    local max_idx = const.Combat.MaxShotIndexForRecoilCTHLoss or 6
    local out, s = {}, sigma0
    for i = 1, num_shots do
        if i > 1 and (i - 1) <= max_idx then
            s = MulDivRound(s, growth, 100)
        end
        out[i] = s
    end
    return out, growth
end


---------------------------------------------------------------------------------------------------
---- Escada do recuo: o CTH de cada tiro da rajada, e o cone que o representa na UI.
----
---- O tiro i sai de um cano ja levantado `mu_i`: e uma gaussiana 2D de desvio `sigma` centrada FORA
---- do alvo, nao uma Rayleigh mais larga. Quem le isso e Rat_RiceCTH. E `mu_i` nao e um numero --
---- cada coice foi uma moeda contra a chance de controle -- entao o CTH sai da mistura binomial
---- exata (Rat_BurstShotCTH), no maximo 7 termos.
----
---- O cone continua sendo a moeda unica: `sigma_disp` e o sigma que produziria aquele mesmo CTH
---- contra este alvo (Rat_SigmaForCTH). UI, anel e bala saem todos da mesma probabilidade.
---- Sem theta so `climb` e `chance` fazem sentido -- e o que Rat_DbgVerifySim precisa.
---------------------------------------------------------------------------------------------------
function Rat_SimRecoilLadder(attacker, action, weapon, sigma0, num_shots, theta)
    num_shots = Max(1, num_shots or 1)

    ---- modo antigo: sem caminhada e sem mu -- o cone de cada tiro JA e a perda.
    if P().RecoilMode == "growth" then
        local ladder = Rat_SimSigmaLadder(attacker, action, weapon, sigma0, num_shots)
        local cth = {}
        if theta and theta >= 1 then
            for i = 1, num_shots do
                cth[i] = Rat_RayleighCTH(theta, ladder[i])
            end
        end
        return cth, 0, 0, ladder
    end

    local climb, chance = 0, 0
    if num_shots > 1 then
        climb, chance = Rat_GetRecoilClimb(attacker, action, weapon, num_shots)
    end

    local cth, sigma_disp = {}, {}
    if not theta or theta < 1 then
        return cth, climb, chance, sigma_disp
    end

    local max_idx = const.Combat.MaxShotIndexForRecoilCTHLoss or 6
    for i = 1, num_shots do
        cth[i] = Rat_BurstShotCTH(theta, sigma0, Min(i - 1, max_idx), climb, chance)
        sigma_disp[i] = Rat_SigmaForCTH(theta, Clamp(cth[i], 1, 99)) or sigma0
    end
    return cth, climb, chance, sigma_disp
end

---- Overrides EXATOS que o tiro real aplica por tiro (ramo `if sim then`). Nada alem disso.
function Rat_SimLoFOverrides(args, attack_pos, seed, ignore_colliders)
    args.attack_pos = attack_pos
    args.seed = seed
    args.fire_relative_point_attack = false
    args.ignore_colliders = ignore_colliders
    args.ignore_los = true
    args.inside_attack_area_check = false
    args.forced_hit_on_eye_contact = false
    ---- sem limpar, BulletCalcDamage (Weapon.lua:1255) troca o spot_group geometrico pelo mirado
    args.target_spot_group = nil
    return args
end

---- Extrai o LoF util de um retorno de GetLoFData, do mesmo jeito nos dois caminhos.
function Rat_SimLoF(data)
    return data and (data.outside_attack_area_lof or (data.lof and data.lof[1]))
end

---- A bala cruzou o alvo? Se sim, por onde. E o que substitui o dado: nao ha
---- "rolar parte do corpo", a parte e onde a trajetoria passou.
function Rat_SimHitSpot(lof, target)
    for _, h in ipairs((lof and lof.hits) or empty_table) do
        if h.obj == target then
            return true, h.spot_group or h.spot or false
        end
    end
    return false, nil
end

---- Registro do ataque para visualizador e comparador. Guarda todo o insumo; nao altera calculo.
function Rat_SimSnapshot(ctx)
    local args = ctx.args or empty_table
    local rec = {
        attacker = ctx.attacker, target = ctx.target,
        attack_pos = ctx.attack_pos, aim_pos = ctx.aim_pos,
        step_pos = ctx.step_pos, target_pos = ctx.target_pos,
        spot = ctx.spot, aim = ctx.aim, opportunity_attack = ctx.opportunity_attack,
        cth = ctx.cth, cth_source = ctx.cth_source,
        theta = ctx.theta, geo_sigma = ctx.geo_sigma, sigma = ctx.sigma,
        climb = ctx.climb, control_chance = ctx.control_chance, num_shots = ctx.num_shots,
        action_id = ctx.action and ctx.action.id,
        weapon_class = ctx.weapon and ctx.weapon.class,
        aim_centroid_pct = P().AimCentroidPct,
        ---- so os campos de LoF que mudam onde a bala para
        lof_args = {
            penetration_class = args.penetration_class,
            range = args.range,
            stance = args.stance,
            target_spot_group = args.target_spot_group,
            ignore_los = args.ignore_los,
            clamp_to_target = args.clamp_to_target,
            can_use_covers = args.can_use_covers,
            can_stuck_on_unit = args.can_stuck_on_unit,
            can_hit_attacker = args.can_hit_attacker,
            force_hit_seen_target = args.force_hit_seen_target,
            fire_relative_point_attack = args.fire_relative_point_attack,
            inside_attack_area_check = args.inside_attack_area_check,
            forced_hit_on_eye_contact = args.forced_hit_on_eye_contact,
            output_collisions = args.output_collisions,
            aimIK = args.aimIK,
            additional_colliders = args.additional_colliders and true or false,
            n_ignore_colliders = args.ignore_colliders and #args.ignore_colliders or 0
        },
        shots = {}
    }
    for i, s in ipairs(ctx.shots or empty_table) do
        rec.shots[i] = {target_pos = s.target_pos, sigma = s.sigma, mu = s.mu, cth = s.cth}
    end
    ---- copia dos args ANTES do laco de tiros (que os muta): permite o visualizador replay-ar o tiro real.
    rec.replay_args = ctx.args and table.copy(ctx.args) or nil
    g_RatLastSimShots = rec
    return rec
end

---- Args de LoF montados do zero, quando nao ha tiro real para replay. Aproximacao de
---- SOURCE_FirearmGetAttackResults.lua:69-84; Rat_DbgVerifySim mostra onde difere do real.
function Rat_SimBaseArgs(attacker, target, weapon, spot, range)
    return {
        obj = attacker,
        weapon = weapon,
        stance = attacker.stance,
        target = target,
        target_spot_group = spot or g_DefaultShotBodyPart,
        step_pos = attacker:GetPos(),
        occupied_pos = attacker:GetOccupiedPos(),
        prediction = false,
        output_collisions = true,
        can_use_covers = false,
        additional_colliders = target,
        require_los = nil,
        penetration_class = weapon:GetPenetrationClass(),
        range = range,
        can_stuck_on_unit = true,
        force_hit_seen_target = false,
        can_hit_attacker = false,
        clamp_to_target = false,
        aimIK = false
    }
end

---------------------------------------------------------------------------------------------------
---- Rajada: o cano sobe tiro a tiro. Devolve [i] = razao em % do CTH do tiro i contra o tiro 1
---- (aplicar como razao preserva os modifiers residuais na mesma proporcao). Le a MESMA escada que
---- Rat_SimPlanShots dispara -- se divergirem, o numero da UI para de ser o que a bala faz.
---------------------------------------------------------------------------------------------------
function Rat_GetShotConeRatios(attacker, target, body_part_def, action, weapon, aim,
                               opportunity_attack, attacker_pos, target_pos, num_shots, sigma_final)
    local a = P()
    local ratios = {}
    if not num_shots or num_shots < 2 then
        return ratios
    end
    ---- guarda aqui tambem: funcao publica, a IA pode chamar
    if not Rat_AngularActive(weapon, action, attacker) then
        return ratios
    end

    local cth1, sigma, theta = Rat_AngularCTH(attacker, target, body_part_def, action, weapon, aim,
                                              opportunity_attack, attacker_pos, target_pos, nil)
    ---- razao medida no cone que o tiro usa de verdade (residuais ja dentro), nao no geometrico
    sigma = sigma_final or sigma
    if not sigma or sigma < 1 or not theta or theta < 1 or not cth1 or cth1 <= 0 then
        return ratios
    end

    local cth, climb = Rat_SimRecoilLadder(attacker, action, weapon, sigma, num_shots, theta)
    if climb <= 0 then
        return ratios
    end

    local base = cth[1] or Rat_RayleighCTH(theta, sigma)
    if base < 1 then
        return ratios
    end

    for i = 2, num_shots do
        ratios[i] = Clamp(MulDivRound(cth[i], 100, base), 0, 100)
    end

    return ratios
end

---------------------------------------------------------------------------------------------------
---- Guarda: chamada no topo de cada modifier que o modelo angular substitui.
---- Enabled = false -> false, e o mod se comporta como antes.
---------------------------------------------------------------------------------------------------

---- Nivel de mira que a GEOMETRIA vai usar de fato. Stance/overwatch/interrupt sobem para 1
---- (a arma esta no ombro), Snipe vai ao maximo. Quem le `aim` cru fora daqui fica dessincronizado
---- do cone -- foi o que deixava o tiro de overwatch com luneta escapar da penalidade de perto.
function Rat_EffectiveAim(attacker, action, aim, opportunity_attack, target)
    aim = aim or 0
    if not attacker then
        return aim, opportunity_attack
    end

    if action and (action.id == "MGSetup" or action.id == "MGRotate") then
        return Max(aim, 1), true
    end

    if opportunity_attack or attacker:HasStatusEffect("shooting_stance") or
        attacker:HasStatusEffect("ManningEmplacement") or
        attacker:HasStatusEffect("StationedMachineGun") or (action and action.id == "Overwatch") or
        (g_Overwatch[attacker] and g_Overwatch[attacker].permanent) then
        aim = Max(1, aim)
    end

    ---- PinDown ("Snipe" no mod) atira com mira maxima.
    if action and action.id == "PinDown" then
        local _, max_aim = attacker:GetBaseAimLevelRange(action, target)
        if max_aim then
            aim = Max(aim, max_aim)
        end
    end

    return aim, opportunity_attack
end

function Rat_AngularActive(weapon, action, attacker)
    local a = P()
    if not a or not a.Enabled then
        return false
    end
    if weapon and not IsKindOf(weapon, "Firearm") then
        return false
    end
    if action and action.ActionType == "Melee Attack" then
        return false
    end
    return true
end

---------------------------------------------------------------------------------------------------
---- Ferramentas de console: Rat_SetAngularCTH(on) liga/desliga; Rat_CompareCTH(atk, alvo) compara.
---- Rat_SeedApertureProperties semeia `rat_aperture_snap` para Firearms sem o seu (ToG / Zulib).
---------------------------------------------------------------------------------------------------

function Rat_SetAngularCTH(on)
    ---- deriva Enabled, limpa cache, reescreve as opticas E reaplica nas armas em campo
    GBO_ApplyApertureCTHMode(on and "aCTH" or "old CTH")
    return "CTH angular: " .. (P().Enabled and "LIGADO" or "desligado")
end

function Rat_CompareCTH(attacker, target, max_aim)
    attacker = attacker or SelectedObj
    if not attacker then
        return "sem atacante"
    end
    if not target then
        for _, o in ipairs(g_Units or empty_table) do
            if o ~= attacker and not o:IsDead() and attacker:IsOnEnemySide(o) then
                target = o
                break
            end
        end
    end
    if not target then
        return "sem alvo"
    end

    local weapon = attacker:GetActiveWeapons()
    local action = attacker:GetDefaultAttackAction("ranged")
    if not IsKindOf(weapon, "Firearm") or not action then
        return "sem arma de fogo"
    end

    local was = P().Enabled
    local lines = {}
    local dist = attacker:GetDist(target)
    lines[#lines + 1] = string.format("%s (%s, Marks %d) -> %s [%s] a %.1f tiles",
                                      tostring(attacker.session_id), tostring(weapon.class),
                                      attacker.Marksmanship, tostring(target.session_id),
                                      tostring(target:GetHitStance()), dist / const.SlabSizeX)
    lines[#lines + 1] = "aim | somado | angular | sigma  theta"

    local args_base = {target_spot_group = "Torso", prediction = true,
                       step_pos = attacker:GetPos(), target_pos = target:GetPos()}

    for aim = 0, (max_aim or 4) do
        args_base.aim = aim

        P().Enabled = false
        local old = attacker:CalcChanceToHit(target, action, args_base, "chance_only")
        P().Enabled = true
        local new = attacker:CalcChanceToHit(target, action, args_base, "chance_only")

        ---- o cone FINAL, o mesmo que o tiro usa: CalcChanceToHit acabou de devolve-lo nos args
        local sigma, theta = args_base.rat_sigma, args_base.rat_theta
        lines[#lines + 1] = string.format(" %d  |  %3d   |   %3d   | %5d  %5d", aim, old or -1,
                                          new or -1, sigma or -1, theta or -1)
    end

    P().Enabled = was
    return table.concat(lines, "\n")
end

--function Rat_SeedApertureProperties()
--    local n = 0
--    for _, classdef in pairs(g_Classes) do
--        if type(classdef) == "table" and rawget(classdef, "OverwatchAngle") and
--            IsKindOf(classdef, "Firearm") then
--            if (rawget(classdef, "rat_aperture_snap") or 0) == 0 then
--                classdef.rat_aperture_snap = Rat_SeedSnapFromOverwatch(classdef)
--                n = n + 1
--            end
--        end
--    end
--    return n
--end

---------------------------------------------------------------------------------------------------

---- Strings que Rat_GetAperture poe no metaText do modifier Aperture (ver CTH_angular.lua).
local t_id_table = {
    [936174028553] = "Hipfire <pct>",
    [418205963714] = "Snapshot <pct>",
    [353401714895] = "Range",
    [688848752517] = "Crouching",
    [271472323596] = "Prone",
    [195655494642] = "(-) Handgun",
    [85643189456] = "(-) Grip while prone"
}

ratG_T_table['FUNCTIONS_aperture.lua'] = t_id_table

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

---- Raio equivalente do alvo em cm. body_part_def: preset, string ou nil (Torso).
---- exposed_pct: 0..100 nao ocluido, entra como raiz (area -> raio).
function Rat_TargetSilhouette(target, body_part_def, exposed_pct, stance_override)
    local a = P()

    local part_id = body_part_def
    if type(part_id) == "table" then
        part_id = part_id.id
    end

    local r
    local absolute = part_id and a.BodyPartAbsolute[part_id]
    if absolute then
        --- cabeca/pescoco: medidos constantes nas tres posturas
        r = absolute
    else
        local stance = stance_override
        if not stance and IsKindOf(target, "Unit") then
            stance = target:GetHitStance()
        end
        r = a.Silhouette[stance] or a.Silhouette.Standing

        local part = part_id and a.BodyPart[part_id]
        if part then
            r = MulDivRound(r, part, 100)
        end
    end

    if exposed_pct and exposed_pct < 100 then
        exposed_pct = Max(0, exposed_pct)
        --- raiz de area -> raio: sqrt(pct/100) em % = sqrt(pct * 100)
        r = MulDivRound(r, Rat_ISqrt(exposed_pct * 100), 100)
    end

    return Max(1, r)
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
			print("decay c", decay)
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
        local points = GetComponentEffectValue(weapon, "AccuracyBonusWhenAimed", "bonus_cth")
        if points and points ~= 0 then
            sight = Rat_ConeMulForPoints(points)
            s = MulDivRound(s, sight, 100)
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
    local theta = Rat_ThetaTarget(dist, half_cm)

    local cth = Rat_RayleighCTH(theta, sigma)
    cth = Clamp(cth, a.MinCTH, a.MaxCTH)

    return cth, sigma, theta, meta, parts, dist, half_cm
end

---------------------------------------------------------------------------------------------------
---- SIMULACAO: onde a bala cai. Rayleigh invertida sorteia o desvio -> numero exibido e tiro
---- concordam por construcao. Nao usar o sorteio uniforme dos pellets (4x no tiro dificil).
---------------------------------------------------------------------------------------------------

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
---- A leitura de sempre ("penalidade tira uma FRACAO da chance, bonus fecha parte do que falta")
---- e avaliada num CTH de REFERENCIA fixo, nao no CTH do alvo: theta se cancela na razao de k,
---- e so por isso o cone sai igual em todas as partes do corpo. Ver A.ConeRefCTH.
function Rat_ConeMulForPoints(points)
    local a = P()
    if not points or points == 0 then
        return 100
    end

    local ref = Clamp(a.ConeRefCTH or 50, 2, 98)
    local target
    if points < 0 then
        target = MulDivRound(ref, 100 + Max(points, -100), 100)
    else
        target = ref + MulDivRound(100 - ref, Min(points, 100), 100)
    end

    local k_ref, k_tgt = Rat_KForCTH(ref), Rat_KForCTH(Clamp(target, 1, 99))
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

---- Desvio angular -> ponto no plano perpendicular a linha de tiro (RotateAxis, como os pellets).
---- Parte de um vetor de fato perpendicular, senao o raio efetivo encolhe.
function Rat_ShotScatterPoint(attacker, attack_pos, aim_pos, sigma)
    if not attack_pos or not aim_pos then
        return aim_pos
    end
    if not attack_pos:IsValidZ() then
        attack_pos = attack_pos:SetTerrainZ()
    end
    if not aim_pos:IsValidZ() then
        aim_pos = aim_pos:SetTerrainZ()
    end

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
    local up = point(0, 0, 1000)
    local par = Dot(up, dir) / 1000
    local perp = up - MulDivRound(dir, par, 1000)
    if perp:Len() < 10 then
        perp = point(-dir:y(), dir:x(), 0)
    end
    perp = SetLen(perp, radius)

    return aim_pos + RotateAxis(perp, dir, attacker:Random(360 * 60))
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
---- growth shots[i] = {sigma, target_pos}
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

    local num_shots = Max(1, ctx.num_shots or 1)
    local ladder, growth = Rat_SimSigmaLadder(ctx.attacker, ctx.action, ctx.weapon, sigma, num_shots)
    ctx.growth, ctx.num_shots = growth, num_shots

    local shots = {}
    for i = 1, num_shots do
        shots[i] = {
            sigma = ladder[i],
            target_pos = Rat_ShotScatterPoint(ctx.attacker, ctx.attack_pos, ctx.aim_pos, ladder[i])
        }
    end
    ctx.shots = shots
    return shots
end

---- Escada de recuo: o sigma de cada tiro de uma rajada de `num_shots`. Separada para o
---- visualizador consultar o cone do tiro N sem disparar a rajada.
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
        growth = ctx.growth, num_shots = ctx.num_shots,
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
        rec.shots[i] = {target_pos = s.target_pos, sigma = s.sigma}
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
---- Rajada: cone abre tiro a tiro. Devolve [i] = razao em % do CTH do tiro i contra o tiro 1
---- (aplicar como razao preserva os modifiers residuais na mesma proporcao).
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

    local growth = Rat_GetRecoilConeGrowth(attacker, action, weapon, num_shots)
    if growth <= 100 then
        return ratios
    end

    local base = Rat_RayleighCTH(theta, sigma)
    if base < 1 then
        return ratios
    end

    ---- o mesmo teto de indice que o modelo somado ja usava
    local max_idx = const.Combat.MaxShotIndexForRecoilCTHLoss or 6
    local sigma_i = sigma
    for i = 2, num_shots do
        if (i - 1) <= max_idx then
            sigma_i = MulDivRound(sigma_i, growth, 100)
        end
        ratios[i] = Clamp(MulDivRound(Rat_RayleighCTH(theta, sigma_i), 100, base), 0, 100)
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

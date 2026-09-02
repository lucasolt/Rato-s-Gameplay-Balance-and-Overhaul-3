---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- o modifier e a absorcao dos residuais
----
---- O modelo entrega o CTH geometrico INTEIRO, entao este modifier devolve
----     geo - skill
---- e os modifiers que ele substitui devolvem false (guarda Rat_AngularActive).
----
---- O que sobra somando por cima -- recoil permanente, Dazed, perks, TargetedShot, efeitos de
---- componente -- NAO soma mais pontos: cada um vira multiplicador de cone (Rat_ConeAbsorb) e o
---- valor exibido passa a ser o quanto o cone alargado moveu o CTH. Assim sigma e a unica moeda:
---- o numero da UI, o anel de mira e a bala simulada saem todos do mesmo cone.
----
---- Ordem: o engine roda os presets de ChanceToHitModifier, DEPOIS os efeitos de status, DEPOIS os
---- componentes (Unit.lua:7063-7165). O modifier nao tem como ler um cone que ainda nao existe --
---- por isso quem orquestra e SOURCE_UnitCalcChanceToHit.lua: semeia o cone antes do laco e absorve
---- cada residual na ordem em que aparece. A soma dos valores exibidos telescopa no CTH final.
----
---- Com const.Combat.Aperture.Enabled = false tudo isto e inerte.
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---- Semente: geometria -> cone. `data` e o mod_data de CalcChanceToHit (a MESMA tabela do ataque
---- inteiro), entao o resultado fica memoizado nele.
---------------------------------------------------------------------------------------------------

function Rat_ResolveAngular(data)
    if data.rat_sigma or data.rat_blocked then
        return data
    end

    local a = const.Combat.Aperture
    local attacker, target = data.attacker, data.target
    local action, weapon1, weapon2 = data.action, data.weapon1, data.weapon2
    if not attacker or not target or not Rat_AngularActive(weapon1, action, attacker) then
        data.rat_blocked = true
        return data
    end

    ---- MGSetup / MGRotate / stance / overwatch / Snipe: a PREVISAO tem que medir o tiro que a arma
    ---- vai fazer de verdade -- montar a arma nao e tiro de quadril. Ver Rat_EffectiveAim.
    local aim, opportunity_attack = Rat_EffectiveAim(attacker, action, data.aim,
                                                     data.opportunity_attack, target)

    local _, sigma, theta, meta, parts, _, _, up, down, right, left, theta_geo =
        Rat_AngularCTH(attacker, target, data.target_spot_group, action, weapon1, aim,
                       opportunity_attack, data.attacker_pos, data.target_pos, nil)
    data.rat_ext_up, data.rat_ext_down, data.rat_ext_right, data.rat_ext_left = up, down, right, left
    ---- tamanho do alvo para EXIBIR: geometria pura. rat_theta e equivalente em probabilidade e
    ---- encolhe quando o cone fecha -- correto como moeda interna, absurdo como "tamanho do alvo".
    data.rat_theta_geo = theta_geo

    ---- alvo totalmente ocluido: nao ha cone que resolva, CTH 0 e nenhum residual muda isso
    if not sigma or not theta or theta < 1 then
        data.rat_blocked = true
        return data
    end

    ---- DualShot: media dos dois CONES. O modelo antigo media os dois CTH, que e a mesma ideia
    ---- uma etapa depois -- mas so o cone pode ser reaproveitado pelo anel e pela simulacao.
    if action and action.id == "DualShot" and weapon2 then
        local _, sigma2 = Rat_AngularCTH(attacker, target, data.target_spot_group, action, weapon2,
                                         aim, opportunity_attack, data.attacker_pos,
                                         data.target_pos, nil)
        if sigma2 and sigma2 > 0 then
            sigma = MulDivRound(sigma + sigma2, 100, 200)
        end
    end

    ---- IA: a mesma valvula de sempre, agora FECHANDO O CONE em vez de devolver pontos de CTH.
    ---- Em pontos a correcao dependia de theta e o cone saia diferente em cada parte do corpo.
    --local side = attacker.team and attacker.team.side or ""
    --if a.AIConeValve and not (side == "player1" or side == "player2") and sigma > a.Base then
    --    local pct = Clamp(cRound(AIpenal_reduc(attacker, 100) or 100), 0, 100)
    --    sigma = Max(1, a.Base + MulDivRound(sigma - a.Base, pct, 100))
    --end

    data.rat_theta, data.rat_meta, data.rat_parts = theta, meta, parts
    data.rat_aim, data.rat_geo_sigma, data.rat_cone_mul = aim, sigma, 100
    data.rat_sigma = sigma
    data.rat_cth = Rat_ConeCTH(data)
    return data
end

---- CTH no sigma ATUAL de `data`. As extensoes sao geometria e nao mexem quando um residual fecha
---- o cone, entao recalcular por elas e exato -- e mais barato que reabrir Rat_AngularCTH.
---- `rat_theta` sai junto porque e raio EQUIVALENTE EM PROBABILIDADE: depende do sigma.
function Rat_ConeCTH(data)
    local a = const.Combat.Aperture
    local sigma = data.rat_sigma
    local cth
    if data.rat_ext_up then
        cth = Clamp(Rat_SeparableCTH(sigma, data.rat_ext_up, data.rat_ext_down, data.rat_ext_right,
                                     data.rat_ext_left), a.MinCTH, a.MaxCTH)
        data.rat_theta = Rat_ThetaEquivalent(sigma, cth) or data.rat_theta
    else
        cth = Clamp(Rat_RayleighCTH(data.rat_theta, sigma), a.MinCTH, a.MaxCTH)
    end
    return cth
end

---------------------------------------------------------------------------------------------------
---- Absorcao: pontos de CTH de um residual -> cone. Devolve quanto o CTH andou por causa dele,
---- para o overlay continuar somando ate o numero exibido.
---------------------------------------------------------------------------------------------------

function Rat_ConeAbsorb(data, points)
    ---- multiplicador desta absorcao, para o overlay mostrar o que ESTE modificador fez ao cone
    data.rat_last_mul = 100
    if data.rat_blocked or not data.rat_sigma then
        return 0
    end
    if not points or points == 0 then
        return 0
    end

    local mul = Rat_ConeMulForPoints(points)
    if mul == 100 then
        return 0
    end
    data.rat_last_mul = mul

    local before = data.rat_cth
    data.rat_sigma = Max(1, MulDivRound(data.rat_sigma, mul, 100))
    data.rat_cone_mul = MulDivRound(data.rat_cone_mul or 100, mul, 100)
    data.rat_cth = Rat_ConeCTH(data)
    return data.rat_cth - before
end

---- Fecho: mod_add/mod_mul do fim de CalcChanceToHit (recoil permanente, Marked, Sprinting...)
---- entram pela mesma porta. mod_mul e multiplicador da CHANCE, entao vale mul - 100 em pontos.
---- `first` e o tamanho de `modifiers` antes das reacoes: as linhas que elas inseriram trazem
---- pontos crus, que nao valem mais nada -- o delta real e redistribuido entre elas.
function Rat_ConeFinish(data, base, modifiers, first)
    if not data.enabled then
        return 0
    end

    local points = (data.mod_add or 0) + ((data.mod_mul or 100) - 100)
    local delta = Rat_ConeAbsorb(data, points)

    local function mag(m)
        local v = m.value or 0
        return v < 0 and -v or v
    end

    if modifiers and first and #modifiers > first then
        local weight = 0
        for i = first + 1, #modifiers do
            weight = weight + mag(modifiers[i])
        end
        local given = 0
        for i = first + 1, #modifiers do
            local share = (weight > 0) and MulDivRound(delta, mag(modifiers[i]), weight) or 0
            if i == #modifiers then
                share = delta - given --- a sobra da divisao inteira vai toda na ultima linha
            end
            ---- cone destas linhas e APROXIMADO: mod_add/mod_mul chegam ja somados, entao cada
            ---- uma e avaliada pelos pontos crus que trouxe, nao por uma absorcao propria.
            modifiers[i].rat_mul = Rat_ConeMulForPoints(modifiers[i].value or 0)
            modifiers[i].value = share
            given = given + share
        end
    end

    return Max(0, base + delta)
end

---------------------------------------------------------------------------------------------------
---- Decomposicao do cone em linhas ESTRUTURADAS. O overlay enumera cada fator como modificador
---- proprio, com o percentual a direita, em vez de empilhar tudo no metaText da linha Aperture:
---- eles sao modificadores do cone como qualquer outro, e mereciam a mesma leitura.
---- Cada item: {name = T, tag = T ja formatado e colorido}.
---------------------------------------------------------------------------------------------------

function Rat_ConeFactors(data)
    local a = const.Combat.Aperture
    local parts, aim = data.rat_parts, data.rat_aim or 0
    local out = {}
    if not parts then
        return out
    end

    if parts.base_mul and parts.base_mul ~= 100 then
        out[#out + 1] = {name = T(268301947512, "Handling"), tag = Rat_ConeMulTag(parts.base_mul)}
    end

    ---- skill_mul vive em [SkillMin, SkillMax]: pode fechar (Marks alto, SkillMin<100) ou abrir
    if parts.skill then
        out[#out + 1] = {name = T(419573028641, "Marksmanship"),
                         tag = Rat_ConeMulTag(parts.skill)}
    end

    if parts.sight and parts.sight ~= 100 then
        out[#out + 1] = {name = T(730192846053, "Sight"), tag = Rat_ConeMulTag(parts.sight)}
    end

    ---- UMA linha de mira: o % e o efeito de TODOS os niveis juntos sobre o cone inteiro, nao o
    ---- multiplicador cru do gap (que so fecha o excesso acima do piso). Assim skill x sight x aim
    ---- x step fecha no Total. Conversao: (piso + gap*prod)/pre. Escada crua vai como sub-nota.
    local ladder = parts.decay_ladder
    if aim > 0 and ladder and ladder[1] then
        local pre = parts.pre_aim or parts.base or 1
        local flr = parts.floor or 0
        local gap0 = Max(0, pre - flr)
        local prod, sub = 100, {}
        for i = 1, aim do
            local d = ladder[i] or 100
            prod = MulDivRound(prod, d, 100)
            sub[#sub + 1] = T {603847265139, "Aim x<n> (<pct> per level)", n = i,
                               pct = Rat_ConeMulTag(d)}
        end
        local cone = a.ApertureAsymptotic and (flr + MulDivRound(gap0, prod, 100))
                        or MulDivRound(pre, prod, 100)
        local eff = (pre > 0) and MulDivRound(cone, 100, pre) or 100
        for _, m in ipairs(parts.aim_meta or empty_table) do sub[#sub + 1] = m end
        out[#out + 1] = {name = T {158426093774, "Aim <n>", n = aim},
                         tag = Rat_ConeMulTag(eff), sub = sub}
    end

    if parts.step and parts.step ~= 100 then
        out[#out + 1] = {name = (aim == 0) and T(592038471265, "Hipfire") or
                             T(837465019283, "Snapshot"),
                         tag = Rat_ConeMulTag(parts.step)}
    end

    ---- o piso nao e multiplicador -- e a assintota, em minutos. Fica indentado, como nota da
    ---- linha Aperture, em vez de fingir ser um fator na enumeracao.
    local meta = {}
    if parts.floor then
        ---- em grupo (2.5 sigma), mesma escala da linha Aperture
        meta[#meta + 1] = T {825069487351, "Range floor <f>'",
                             f = MulDivRound(parts.floor, a.CrosshairSigmaMul or 250, 100)}
    end

    ---- O QUE SOBROU no fim: sigma final sobre a abertura de referencia. Vai separado porque ja
    ---- conta os residuais, e entao so pode ser impresso DEPOIS deles. Nao e o produto das linhas
    ---- acima -- o piso entra como assintota, somando, e produto nenhum daria nisso. E medida.
    local total
    if data.rat_sigma then
        ---- ancora = A.Base (cone neutro, skill neutro): Marksmanship e um fator visivel que puxa
        ---- dali pra baixo. Assim Total = produto de todas as linhas e Total * Base = cone da bala.
        total = {name = T(604815927340, "Total"),
                 tag = Rat_ConeMulTag(MulDivRound(data.rat_sigma, 100, Max(1, a.Base)))}
    end

    return out, meta, total
end

---------------------------------------------------------------------------------------------------
---- Texto da linha Aperture. Reconstruido do zero a cada chamada: e chamado de novo no fim, ja com
---- os residuais dentro do cone, e o numero exibido tem que ser o cone que a bala usa.
---------------------------------------------------------------------------------------------------

function Rat_ConeMetaText(data)
    local a = const.Combat.Aperture
    local sigma, cth = data.rat_sigma, data.rat_cth
    ---- tamanho do alvo = GEOMETRIA. rat_theta e equivalente em probabilidade e encolhe
    ---- quando a mira fecha o cone -- certo como moeda interna, absurdo na tela: o alvo
    ---- nao fica menor porque quem atira mirou melhor.
    local theta = data.rat_theta_geo or data.rat_theta
    local parts, aim = data.rat_parts, data.rat_aim or 0

    local meta = {}
    for _, t in ipairs(data.rat_meta or empty_table) do
        meta[#meta + 1] = t
    end

    ---- De ONDE veio o cone. Substitui a lista aditiva que sumiu do overlay quando cada modifier
    ---- virou geometria. Tudo em % sobre a abertura base: MAIOR = cone mais aberto, 100 = neutro.
    ---- So entra o que nao e neutro -- na ordem de aplicacao de Rat_GetAperture.
    if parts then
        if parts.base_mul and parts.base_mul ~= 100 then
            meta[#meta + 1] = T {481920573641, "Handling <pct>", pct = Rat_ConeMulTag(parts.base_mul)}
        end
        ---- sempre visivel, ao contrario das outras: em Marks 100 o 100% verde E a informacao
        ---- ("nao ha nada a ganhar aqui"), nao um neutro para esconder.
        if parts.skill then
            ---- skill_mul vive em [SkillMin, SkillMax] e nunca desce de 100: aqui Marks so deixa
            ---- MENOS ruim, nunca ajuda. Gradiente para no ambar por isso.
            meta[#meta + 1] = T {592038174652, "Marksmanship <pct>",
                                 pct = Rat_ConeMulTag(parts.skill)}
        end
        ---- quadro de visada da mira: fator unico, so com aim >= 1 (nunca piora, por isso o PctTag
        ---- normal ja basta -- abaixo de 100 sai verde).
        if aim > 0 and parts.sight and parts.sight ~= 100 then
            meta[#meta + 1] = T {517294836150, "Sight <pct>", pct = Rat_ConeMulTag(parts.sight)}
        end
        if aim > 0 and parts.decay then
            ---- decay vive em [DecayMinPct, 100] e nunca passa de 100: mirar so ajuda, mais ou
            ---- menos. Verde = fecha o maximo que a arma permite; ambar = nao rende.
            meta[#meta + 1] = T {603847265139, "Aim x<n> (<pct> per level)", n = aim,
                                 pct = Rat_ConeMulTag(parts.decay)}
            for _, t in ipairs(parts.aim_meta or empty_table) do
                meta[#meta + 1] = t
            end
        end
        if parts.floor then
            ---- em grupo (2.5 sigma), mesma escala da linha Aperture
            meta[#meta + 1] = T {825069487351, "Range floor <f>'",
                                 f = MulDivRound(parts.floor, a.CrosshairSigmaMul or 250, 100)}
        end
    end

    ---- tudo o que entrou depois da geometria (recoil, Dazed, perks, componentes), ja em cone
    if data.rat_cone_mul and data.rat_cone_mul ~= 100 then
        meta[#meta + 1] = T {714038265194, "Modifiers <pct>", pct = Rat_ConeMulTag(data.rat_cone_mul)}
    end

    ---- cone e alvo vao no NOME (aspa simples = minuto de angulo): e a comparacao que decide o
    ---- tiro, entao fica na linha mestre; o metaText so explica de onde o cone veio. A cor e a do
    ---- CTH resultante -- a mesma do anel de mira (UI_aperture_crosshair).
    ---- Exibe o GRUPO (2.5 sigma, ~96% dos tiros -- A.CrosshairSigmaMul), nao o sigma cru: e o
    ---- mesmo raio que o anel desenha, e so contra ele "cone ~= alvo" quer dizer "acerto quase certo".
    local group = MulDivRound(sigma, a.CrosshairSigmaMul or 250, 100)
    return T {193746285017, "Aperture <cone> vs <tgt>", cone = Rat_ScaleTag(group .. "'", cth),
              tgt = Rat_ScaleTag(theta .. "'", cth)}, meta
end

---------------------------------------------------------------------------------------------------
---- O preset. SOURCE_UnitCalcChanceToHit trata dele direto (para semear o cone antes dos
---- residuais); este CalcValue e o caminho para qualquer outro chamador do pipeline vanilla.
---------------------------------------------------------------------------------------------------

function place_angular_cth()
    PlaceObj("ChanceToHitModifier", {
        CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof,
                             aim, opportunity_attack, attacker_pos, target_pos)

            if not attacker or not target or not Rat_AngularActive(weapon1, action, attacker) then
                return false, 0
            end

            local data = {attacker = attacker, target = target, target_spot_group = body_part_def,
                          action = action, weapon1 = weapon1, weapon2 = weapon2, aim = aim,
                          opportunity_attack = opportunity_attack, attacker_pos = attacker_pos,
                          target_pos = target_pos}
            Rat_ResolveAngular(data)
            if data.rat_blocked then
                return false, 0
            end

            ---- o total de CalcChanceToHit ja comeca em `skill`; devolvemos a diferenca
            local skill = attacker[weapon1.base_skill or "Marksmanship"] or 0
            local name, meta = Rat_ConeMetaText(data)
            return true, data.rat_cth - skill, name, meta
        end,
        RequireTarget = true,
        display_name = T(724418639250, "Aperture"),
        group = "Default",
        id = "RatAngularCTH"
    })
end

---------------------------------------------------------------------------------------------------

local t_id_table = {
    [724418639250] = "Aperture",
    [193746285017] = "Aperture <cone> vs <tgt>",
    [481920573641] = "Handling <pct>",
    [592038174652] = "Marksmanship <pct>",
    [517294836150] = "Sight <pct>",
    [268301947512] = "Handling",
    [419573028641] = "Marksmanship",
    [730192846053] = "Sight",
    [158426093774] = "Aim <n>",
    [592038471265] = "Hipfire",
    [837465019283] = "Snapshot",
    [604815927340] = "Total",
    [603847265139] = "Aim x<n> (<pct> per level)",
    [825069487351] = "Range floor <f>'",
    [714038265194] = "Modifiers <pct>"
}

ratG_T_table['CTH_angular.lua'] = t_id_table

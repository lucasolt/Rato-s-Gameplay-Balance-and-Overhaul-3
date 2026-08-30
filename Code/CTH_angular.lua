---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- o modifier
----
---- Entao para o total virar o CTH geometrico basta este modifier devolver
----     geo - skill
---- e os modifiers que o modelo substitui devolverem false (guarda Rat_AngularActive).
---- O que sobra somando por cima -- perks, efeitos de status, bonus de body part --
---- continua funcionando exatamente como antes, junto com GatherCTHModifications,
---- os hooks de weapon component e o NetUpdateHash de cada passo.
----
---- Com const.Combat.Aperture.Enabled = false este modifier e inerte.
---------------------------------------------------------------------------------------------------

function place_angular_cth()
    PlaceObj('ChanceToHitModifier', {
        CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof,
                             aim, opportunity_attack, attacker_pos, target_pos)

            if not Rat_AngularActive(weapon1, action, attacker) then
                return false, 0
            end
            if not attacker or not target then
                return false, 0
            end

            aim = aim or 0

            ---- MGSetup / MGRotate: a PREVISAO tem que medir o tiro que a arma vai
            ---- fazer de verdade -- montar a arma nao e tiro de quadril. Mesmo motivo
            ---- documentado em CTH_hipfire_and_snapshot.lua:26-46.
            if action and (action.id == "MGSetup" or action.id == "MGRotate") then
                aim = Max(aim, 1)
                opportunity_attack = true
            end

            if opportunity_attack or attacker:HasStatusEffect("shooting_stance") or
                attacker:HasStatusEffect("ManningEmplacement") or
                attacker:HasStatusEffect("StationedMachineGun") then
                aim = Max(1, aim)
            end

            if action and action.id == "Overwatch" then
                aim = Max(1, aim)
            end

            if g_Overwatch[attacker] and g_Overwatch[attacker].permanent then
                aim = Max(1, aim)
            end

            ---- PinDown ("Snipe" no mod) atira com mira maxima.
            if action and action.id == "PinDown" then
                local _, max_aim = attacker:GetBaseAimLevelRange(action, target)
                if max_aim then
                    aim = Max(aim, max_aim)
                end
            end

            local cth, sigma, theta, meta, parts = Rat_AngularCTH(attacker, target, body_part_def,
                                                                  action, weapon1, aim,
                                                                  opportunity_attack, attacker_pos,
                                                                  target_pos, nil)

            ---- DualShot: media geometrica das duas armas, como o modelo antigo fazia
            ---- com a media dos multiplicadores de hipfire.
            if action and action.id == "DualShot" and weapon2 then
                local cth2 = Rat_AngularCTH(attacker, target, body_part_def, action, weapon2, aim,
                                            opportunity_attack, attacker_pos, target_pos, nil)
                cth = (cth + cth2) / 2
            end

            ---- IA: a mesma valvula que todos os outros modifiers usam para nao punir
            ---- o inimigo tanto quanto o jogador.
            local side = attacker.team and attacker.team.side or ''
            if not (side == 'player1' or side == 'player2') then
                local skill_ref = attacker[weapon1.base_skill or "Marksmanship"] or 0
                local delta = cth - skill_ref
                if delta < 0 then
                    cth = skill_ref + AIpenal_reduc(attacker, delta)
                end
            end

            cth = Clamp(cth, const.Combat.Aperture.MinCTH, const.Combat.Aperture.MaxCTH)

            meta = meta or {}

            ---- De ONDE veio o cone. Substitui a lista aditiva que sumiu do overlay quando cada
            ---- modifier virou geometria. Tudo em % sobre a abertura base: MAIOR = cone mais aberto,
            ---- 100 = neutro. So entra o que nao e neutro -- na ordem de aplicacao de Rat_GetAperture.
            ---- O degrau de hipfire/snapshot sai com o proprio rotulo, la em Rat_GetAperture.
            if parts then
                if parts.base_mul and parts.base_mul ~= 100 then
                    meta[#meta + 1] = T {481920573641, "Weapon <pct>",
                                         pct = Rat_PctTag(parts.base_mul)}
                end
                ---- sempre visivel, ao contrario das outras: em Marks 100 o 100% verde E a
                ---- informacao ("nao ha nada a ganhar aqui"), nao um neutro para esconder.
                if parts.skill then
                    ---- skill_mul vive em [SkillMin, SkillMax] e nunca desce de 100: aqui Marks
                    ---- so deixa MENOS ruim, nunca ajuda. Gradiente para no ambar por isso.
                    meta[#meta + 1] = T {592038174652, "Marksmanship <pct>",
                                         pct = Rat_PctTagPenaltyOnly(parts.skill,
                                                                     const.Combat.Aperture.SkillMax)}
                end
                if aim > 0 and parts.decay then
                    ---- decay vive em [DecayMinPct, 100] e nunca passa de 100: mirar so ajuda,
                    ---- mais ou menos. Verde = fecha o maximo que a arma permite; ambar = nao rende.
                    meta[#meta + 1] = T {603847265139, "Aim x<n> (<pct> per level)", n = aim,
                                         pct = Rat_PctTagBonusOnly(parts.decay,
                                                                   const.Combat.Aperture.DecayMinPct)}
                end
                if parts.floor then
                    meta[#meta + 1] = T {825069487351, "Range floor <f>'", f = parts.floor}
                end
            end

            ---- o total de CalcChanceToHit ja comeca em `skill`; devolvemos a diferenca
            local skill = attacker[weapon1.base_skill or "Marksmanship"] or 0

            ---- cone e alvo vao no NOME do modifier (' = minuto de angulo): e a comparacao que
            ---- decide o tiro, entao fica na linha mestre; o metaText abaixo so explica o cone.
            ---- O cone e pintado pelo CTH resultante -- que E a comparacao cone vs alvo, ja
            ---- normalizada pela Rayleigh. Mesma cor que o anel de mira (UI_aperture_crosshair).
            return true, cth - skill,
                   T {193746285017, "Aperture <cone> vs <tgt>",
                      cone = Rat_ScaleTag(sigma .. "'", cth),
                      tgt = Rat_ScaleTag(theta .. "'", cth)}, meta
        end,
        RequireTarget = true,
        display_name = T(724418639250, "Aperture"),
        group = "Default",
        id = "RatAngularCTH"
    })
end

---------------------------------------------------------------------------------------------------
---- Residuais: de pontos absolutos para fracao da chance
----
---- O modelo angular entrega o CTH geometrico INTEIRO. Os modifiers que sobram
---- somando por cima (TargetedShot, _R_Mod_Setting, perks, efeitos de status,
---- component effects) foram tunados contra uma base muito mais generosa, e somam
---- em PONTOS ABSOLUTOS. Medido: headshot Gewehr98 a 21 tiles, mira maxima --
---- geometria da 29, residuais somam -32, resultado 0. O tiro sumia.
----
---- Uma penalidade percentual deveria tirar uma FRACAO da chance que existia, nao
---- um numero fixo de pontos. Entao:
----     penalidade  ->  escala por  geo/100          (proporcional a chance)
----     bonus       ->  escala por  (100-geo)/100    (proporcional ao que falta)
----
---- O gancho e Unit:GatherCTHModifications (Unit.lua:6929), que o engine ja chama
---- para CADA modifier antes de somar, e que aplica data.mod_mul no fim
---- (Unit.lua:6943). Nao precisa de override: e o mecanismo declarado para isto.
----
---- `data` e a MESMA tabela ao longo de um CalcChanceToHit inteiro, entao o CTH
---- geometrico e calculado uma vez por ataque e memoizado nela.
---------------------------------------------------------------------------------------------------

function OnMsg.GatherCTHModifications(unit, id, action_id, target, weapon1, weapon2, data)
    if not data or id == "RatAngularCTH" then
        return
    end
    if not Rat_AngularActive(weapon1 or data.weapon1, data.action, unit) then
        return
    end

    local geo = data.rat_geo
    if not geo then
        geo = Rat_AngularCTH(unit, data.target, data.target_spot_group, data.action,
                             weapon1 or data.weapon1, data.aim, data.opportunity_attack,
                             data.attacker_pos, data.target_pos, nil) or 0
        data.rat_geo = geo
    end


    local value = data.base_chance or 0
    local scale
    if value < 0 then
        scale = geo --- penalidade proporcional a chance que havia
    elseif value > 0 then
        scale = 100 - geo --- bonus proporcional ao que ainda falta
    else
        return
    end

    data.mod_mul = MulDivRound(data.mod_mul or 100, Clamp(scale, 0, 100), 100)
end

---------------------------------------------------------------------------------------------------

local t_id_table = {
    [724418639250] = "Aperture",
    [193746285017] = "Aperture <cone> vs <tgt>",
    [481920573641] = "Weapon <pct>",
    [592038174652] = "Marksmanship <pct>",
    [603847265139] = "Aim x<n> (<pct> per level)",
    [825069487351] = "Range floor <f>'"
}

ratG_T_table['CTH_angular.lua'] = t_id_table

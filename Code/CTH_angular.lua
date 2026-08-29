---------------------------------------------------------------------------------------------------
---- CTH ANGULAR -- o modifier
----
---- Estrategia HIBRIDA: nao substitui Unit:CalcChanceToHit (Unit.lua:6947). Aquela
---- funcao comeca com `base = attacker[weapon.base_skill]` (Marksmanship cru) e
---- soma o retorno de cada ChanceToHitModifier (`base = base + value`, Unit.lua:7103).
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

            local cth, sigma, theta, meta = Rat_AngularCTH(attacker, target, body_part_def, action,
                                                           weapon1, aim, opportunity_attack,
                                                           attacker_pos, target_pos, nil)

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

            ---- reporta em MINUTOS de cone -- e o que substitui a lista aditiva de
            ---- pontos percentuais na UI (ver COMPATIBILITY_DescriptiveCTH.lua).
            meta = meta or {}
            meta[#meta + 1] = T {193746285017, "Cone <cone>' vs alvo <tgt>'", cone = sigma,
                                 tgt = theta}

            ---- o total de CalcChanceToHit ja comeca em `skill`; devolvemos a diferenca
            local skill = attacker[weapon1.base_skill or "Marksmanship"] or 0

            return true, cth - skill, T(724418639250, "Aperture"), meta
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
    [193746285017] = "Cone <cone>' vs alvo <tgt>'"
}

ratG_T_table['CTH_angular.lua'] = t_id_table

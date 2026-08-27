function ow_cth()
    Presets.ChanceToHitModifier.Default["OpportunityAttack"].CalcValue = function(self, attacker,
                                                                                  target,
                                                                                  body_part_def,
                                                                                  action, weapon1,
                                                                                  weapon2, lof, aim,
                                                                                  opportunity_attack,
                                                                                  attacker_pos,
                                                                                  target_pos)
        if not opportunity_attack then
            return false, 0
        end


        --------------------------
        local reflex = rGetReflex(attacker)
        -------------------------------
        local value = 0
        local base_value = const.Combat.OWMaxDelta + cRound((const.Combat.OWMinDelta - const.Combat.OWMaxDelta) * reflex / 100.00)

        if g_Overwatch[attacker] and g_Overwatch[attacker].permanent or action and action.id ==
            "MGSetup" then
            value = value + const.Combat.MGSetupBonusInterruptAccuracy
        end

        local metaText = false
        local bonus, compDef = GetComponentEffectValue(weapon1, "OpportunityAttackBonusCth",
                                                       "bonus_cth_interrupt")
        if bonus then
            value = value + bonus
            -- metaText = compDef.DisplayName
        end

        local min_dex = 10.0
        local max_dex = 100.0
        local min_scale = const.Combat.R_MinAimScaling / 100.0
        local max_scale = const.Combat.R_MaxAimScaling / 100.0

        local scale_factor = min_scale + (max_scale - min_scale) * (reflex - min_dex) /
                                 (max_dex - min_dex)
        if scale_factor < min_scale then
            scale_factor = min_scale
        elseif scale_factor > max_scale then
            scale_factor = max_scale
        end

        value = cRound(value * scale_factor * const.Combat.R_OWMul / 100)
        value = value + base_value

        local side = attacker and attacker.team and attacker.team.side or ''
        if value and value < 0 then
            if not (side == 'player1' or side == 'player2') then
                value = AIpenal_reduc(attacker, value)
            end
        end

        return true, value, false, metaText
    end

end


function prone_cover()
    local cover = -35
    local prone = -30
    local crouch = -12

    for _, param in ipairs(Presets.ChanceToHitModifier.Default["RangeAttackTargetStanceCover"]
                               .Parameters) do
        if param.Name == 'Cover' then
            param.Value = cover
        elseif param.Name == 'PronePenalty' then
            param.Value = prone
        elseif param.Name == 'CrouchPenalty' then
            param.Value = crouch
        end

    end
    --
    g_PresetParamCache[Presets.ChanceToHitModifier.Default["RangeAttackTargetStanceCover"]]['Cover'] =
        cover

    g_PresetParamCache[Presets.ChanceToHitModifier.Default["RangeAttackTargetStanceCover"]]['PronePenalty'] =
        prone

    g_PresetParamCache[Presets.ChanceToHitModifier.Default["RangeAttackTargetStanceCover"]]['CrouchPenalty'] =
        crouch

    Presets.ChanceToHitModifier.Default["RangeAttackTargetStanceCover"].CalcValue = function(self,
                                                                                             attacker,
                                                                                             target,
                                                                                             body_part_def,
                                                                                             action,
                                                                                             weapon1,
                                                                                             weapon2,
                                                                                             lof,
                                                                                             aim,
                                                                                             opportunity_attack,
                                                                                             attacker_pos,
                                                                                             target_pos)
        if opportunity_attack or not IsKindOf(weapon1, "Firearm") or not IsKindOf(target, "Unit") then
            return false, 0
        end
        ---- CTH angular: a POSTURA do alvo deixa de ser penalidade somada e passa a
        ---- ser silhueta menor (const.Combat.Aperture.Silhouette, medida no jogo).
        ---- A COBERTURA continua percentual aqui ate a sondagem de silhueta ocluida
        ---- entrar -- por isso o guard so desliga os ramos de postura.
        local angular = Rat_AngularActive(weapon1, action, attacker)

        local target_stance = target:GetHitStance()
        if target_stance == "Prone" and not angular then
            local value = self:ResolveValue("PronePenalty")

            local max_dist = 24 * const.SlabSizeX
            local target_pos = target_pos or target:GetPos()

            local dist = attacker_pos:Dist(target_pos)

            dist = Min(max_dist, dist)

            if dist < 1.5 * const.SlabSizeX then
                return false, 0
            end

            local mul = dist * 1.00 / max_dist

            value = cRound(value * mul)
            return true, value, T(904752344471, "Target Prone"), nil, "Prone"
        end

        local cover, any, coverage
        if weapon1 then
            local ignoreCth = weapon1:HasComponent("IgnoreCoverCtHWhenFullyAimed") and
                                  IsFullyAimedAttack(aim)
            if not ignoreCth and (opportunity_attack or target:IsAware()) and
                not target:HasStatusEffect("Exposed") then
                cover, any, coverage = target:GetCoverPercentage(attacker_pos, target_pos)
            end
        end

        local melee_attack = action and action.ActionType == "Melee Attack"
        cover = not target.aim_action_id and not melee_attack and cover

        ------
        local pindown = action and action.id == "PinDown"
        ------
        if cover and not pindown then
            local name = false
            local exposed_value = self:ResolveValue("ExposedCover")
            local full_value = self:ResolveValue("Cover")

            if CheckSightCondition(attacker, target, const.usObscured) then
                exposed_value = exposed_value + const.EnvEffects.DustStormCoverCTHPenalty
                full_value = full_value + const.EnvEffects.DustStormCoverCTHPenalty
                name = T(548829641491, "Behind Cover (Dust Storm)")
            end

            local value = InterpolateCoverEffect(coverage, full_value, exposed_value)
            local metaText = false
            -- print("cover value", value)
            if value < exposed_value then
                return true, value, name, metaText, "Cover"
            end

            --------------------------------------------------------	
        else
            local target_pos = target_pos or target:GetPos()
            local target_h = target_pos:z() or target_pos:SetTerrainZ():z()
            local target_return_pos = target.return_pos_reserved or target.return_pos or false
            if target_return_pos then -----------IsValidZ() 
                target_return_pos = target_return_pos:SetZ(target_h)
            end
            local peek, any, peek_percent
            if target_return_pos then
                peek, any, peek_percent = target:GetCoverPercentage(attacker_pos, target_return_pos)
            end

            if peek_percent and peek_percent > 80 then

                local name = false
                local exposed_value = self:ResolveValue("ExposedCover")
                local full_value = self:ResolveValue("Cover")
                name = T(896586683524, "Peeking from Cover")
                if CheckSightCondition(attacker, target, const.usObscured) then
                    exposed_value = exposed_value + const.EnvEffects.DustStormCoverCTHPenalty
                    full_value = full_value + const.EnvEffects.DustStormCoverCTHPenalty
                    name = T(249585814638, "Peeking from Cover (Dust Storm)")
                end

                coverage = peek_percent - 20

                local peek_value = InterpolateCoverEffect(coverage, full_value, exposed_value)
                peek_value = MulDivRound(peek_value, 60, 100)
                local metaText = false
                return true, peek_value, name, metaText, "Cover"
            end
        end

        if target_stance == "Crouch" and not angular then
            local value = self:ResolveValue("CrouchPenalty")

            local max_dist = 26 * const.SlabSizeX
            local target_pos = target_pos or target:GetPos()
            local dist = attacker_pos:Dist(target_pos)
            dist = Min(max_dist, dist)

            if dist < 1.5 * const.SlabSizeX then
                return false, 0
            end

            local mul = dist * 1.00 / max_dist
            value = cRound(value * mul)

            return true, value, T(309253003316, "Target Crouched"), nil, "Crouch"
        end
        return false, 0
    end
end

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [904752344471] = "Target Prone",
    [548829641491] = "Behind Cover (Dust Storm)",
    [896586683524] = "Peeking from Cover",
    [249585814638] = "Peeking from Cover (Dust Storm)",
    [309253003316] = "Target Crouched"
}

ratG_T_table['CTH_cover_prone.lua'] = t_id_table

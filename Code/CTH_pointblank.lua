function point_blank_cth()
    Presets.ChanceToHitModifier.Default["PointBlank"].CalcValue =
        function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim,
                 opportunity_attack, attacker_pos, target_pos)
            ---- CTH angular: o PBbonus virou MANEJO e entra na abertura base (Rat_ApertureHandlingMul),
            ---- nao como residual sobre o cone final. A linha "Handling" do overlay vem de la.
            if Rat_AngularActive(weapon1, action, attacker) then
                return false, 0
            end

            if attacker and IsKindOf(weapon1, "FirearmProperties") then
                local pb_bonus = GetPBbonus(weapon1) or 10

                local metaText = {}
                if action and action.id == "DualShot" then
                    local pb_bonus2 = GetPBbonus(weapon2)
                    pb_bonus = cRound((pb_bonus2 + pb_bonus) / 2)
                end

                local dex = attacker.Dexterity

                local min_dex = 10.0
                local max_dex = 100.0
                local min_scale = const.Combat.R_MinAimScaling / 100.0
                local max_scale = const.Combat.R_MaxAimScaling / 100.0

                if IsKindOf(weapon1, "Firearm") then
                    dex = rGetHandEyeCoordination(attacker)
                    if dex < 70 then
                        metaText[#metaText + 1] = T(273969979692, "(-) Low Hand-Eye Coordination")
                    elseif dex > 84 then
                        metaText[#metaText + 1] = T(699324351174, "High Hand-Eye Coordination")
                    else
                        metaText[#metaText + 1] = T(983254647634, "Average Hand-Eye Coordination")
                    end
                else ----- if ever include melee, need to add MeleeProperties on the first If statement
                    if dex < 70 then
                        metaText[#metaText + 1] = T(458961115417, "(-) Low Dexterity")
                    elseif dex > 84 then
                        metaText[#metaText + 1] = T(869282891923, "High Dexterity")
                    else
                        metaText[#metaText + 1] = T(634749487718, "Average Dexterity")
                    end
                end

                local scale_factor = min_scale + (max_scale - min_scale) * (dex - min_dex) /
                                         (max_dex - min_dex)

                if scale_factor < min_scale then
                    scale_factor = min_scale
                elseif scale_factor > max_scale then
                    scale_factor = max_scale
                end

                if pb_bonus < 0 then
                    scale_factor = 1.50 - scale_factor
                end

                pb_bonus = cRound(pb_bonus * scale_factor * const.Combat.R_AimMul / 100)

                if attacker:GBO_IsPointBlankRange(target, attacker_pos) then
                    return true, pb_bonus, T(461622328882, "Point-Blank Range"),
                           #metaText ~= 0 and metaText
                else
                    local target_pos = target_pos or target:GetPos()
                    local pb_range = const.Weapons.PointBlankRange * const.SlabSizeX
                    local dist = attacker_pos:Dist(target_pos)
                    local close_range = rat_close_range()
                    if dist <= close_range then

                        local scaling_factor = (1.0 - ((dist - pb_range) * 1.00 / close_range))
                        local scaled_bonus = cRound(pb_bonus * scaling_factor)

                        if scaled_bonus > pb_bonus then
                            scaled_bonus = pb_bonus
                        elseif scaled_bonus < 0 then
                            scaled_bonus = 0
                        end

                        if scaled_bonus > 0 then
                            return true, scaled_bonus, T(974362381782, "Close Range"),
                                   #metaText ~= 0 and metaText
                        end
                    end
                end
            end

            return false, 0
        end
end

function Unit:GBO_IsPointBlankRange(target, unit_pos)
    if not IsValid(target) and not unit_pos then
        return false
    end
    return IsCloser(target, unit_pos or self, const.Weapons.PointBlankRange * const.SlabSizeX + 1)
end

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [273969979692] = "(-) Low Hand-Eye Coordination",
    [699324351174] = "High Hand-Eye Coordination",
    [983254647634] = "Average Hand-Eye Coordination",
    [458961115417] = "(-) Low Dexterity",
    [869282891923] = "High Dexterity",
    [634749487718] = "Average Dexterity",
    [461622328882] = "Point-Blank Range",
    [974362381782] = "Close Range",
	[162198456754] = "Handling"
}

ratG_T_table['CTH_pointblank.lua'] = t_id_table

PlaceObj('ChanceToHitModifier', {
    CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim,
                         opportunity_attack, attacker_pos, target_pos)
        if not attacker or not target then
            return false, 0
        end

        local rounding = true -- const.Combat.R_Round_Mul

        local penalty

        if weapon1.UnitStat == "Marksmanship" then
            ---- aCTH scales the skill term of the cone instead (Rat_ApertureSkillMul)
            if IsACHTActive(weapon1, action, attacker) then
                return false, 0
            end
            local marks = attacker.Marksmanship

            local setting = const.Combat.R_MarksMul - 100.0
            -- local penalty = MulDivRound(marks, setting, 100)
            if rounding then
                penalty = MulDivRound(marks, setting, 100)
            else
                penalty = setting * marks / 100.0
            end

            if penalty ~= 0 then
                return true, penalty, T(861991849417, "Marksmanship Multiplier")
            end
        elseif weapon1.UnitStat == "Dexterity" then
            local marks = attacker.Dexterity
            local setting = const.Combat.R_MeleeMul - 100

            if rounding then
                penalty = MulDivRound(marks, setting, 100)
            else
                penalty = setting * marks / 100.0
            end

            if penalty ~= 0 then
                return true, penalty, T(173175324694, "Dexterity Multiplier")
            end
        elseif weapon1.UnitStat == "Strength" then
            local marks = attacker.Strength
            local setting = const.Combat.R_MeleeMul - 100

            if rounding then
                penalty = MulDivRound(marks, setting, 100)
            else
                penalty = setting * marks / 100.0
            end

            if penalty ~= 0 then
                return true, penalty, T(229553716319, "Strength Multiplier")
            end
        else
            return false, 0
        end

    end,
    RequireTarget = true,
    display_name = T(247853265298, "Mod Setting"),
    group = "Default",
    id = "_R_Mod_Setting"
})

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [861991849417] = "Marksmanship Multiplier",
    [173175324694] = "Dexterity Multiplier",
    [229553716319] = "Strength Multiplier",
    [247853265298] = "Mod Setting"
}

ratG_T_table['CTH_Setting.lua'] = t_id_table

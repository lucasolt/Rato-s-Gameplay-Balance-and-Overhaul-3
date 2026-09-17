function Composure_RollSkillCheck(unit, modifier, add)
    modifier = modifier or 100
    add = add or 0
    local skill = rGetComposure(unit)
    local roll = 1 + unit:Random(100)
    local adjustRoll = GameDifficulties[Game.game_difficulty]:ResolveValue("rollSkillCheckBonus") or
                           0
    roll = roll + adjustRoll
    roll = Min(roll, 95)
    local value = MulDivRound(skill, modifier, 100) + add

    local pass = roll < value or CheatEnabled("SkillCheck")
    local t_res = pass and Untranslated("<em>Pass</em>") or Untranslated("<em>Fail</em>")

    local t_skill = "Composure"
    if modifier ~= 100 then
        if 0 < add then
            t_skill = T({
                816405633181,
                "<percent(n1)> <skill>+<n2>",
                n1 = modifier,
                n2 = add,
                skill = "Composure"
            })
        elseif add < 0 then
            t_skill = T({
                656059859333,
                "<percent(n1)> <skill><n2>",
                n1 = modifier,
                n2 = add,
                skill = "Composure"
            })
        else
            t_skill = T({
                570928040607,
                "<percent(number)> <skill>",
                number = modifier,
                skill = "Composure"
            })
        end
    elseif 0 < add then
        t_skill = T({481345361355, "<skill>+<number>", number = add, skill = "Composure"})
    elseif add < 0 then
        t_skill = T({945399039468, "<skill><number>", number = add, skill = "Composure"})
    end
    CombatLog("debug", T({
        Untranslated("<em><name><em> Skill check (Composure) <roll>/<target>: <result>"),
        name = unit:GetLogName(),
        skill = t_skill,
        roll = roll,
        target = value,
        result = t_res
    }))
    return pass
end

-------------------------

function ScaleAtribute(at, max_pen, min_pen, max_at, min_at)

    local min_at = min_at or 0
    local max_at = max_at or 100

    local old_range = max_at - min_at
    local new_range = max_pen - min_pen

    local scaled_value = (((at - max_at) * new_range) / old_range) + min_pen

    return scaled_value
end

function rat_shotgun_dmg_scale(attacker, target) ---not used
    local target = target
    local target_pos = target or target:GetPos()
    local attacker_pos = attacker:GetPos()

    local dist = attacker_pos:Dist(target_pos)
    print("dist", dist / 1200)

    local max_distance = 20.0 * const.SlabSizeX
    ---------------

    local min_angle = 2.0 * 60
    local max_angle = 16.0 * 60
    local weapon = attacker:GetActiveWeapons()
    local buck_angle = weapon.BuckshotConeAngle * 1.0 -- or 10*60
    print("angle", buck_angle)
    local angle_factor = ((buck_angle - min_angle) / (max_angle - min_angle)) + 0.2

    print("angle_factor", angle_factor)

    --------------
    local ratio = dist * 1.0 * angle_factor / max_distance

    print("ratio", ratio)

    local max_value = 120.0
    local min_value = 50.0

    local scaled_value = max_value - (max_value - min_value) * (ratio)
    scaled_value = (scaled_value > max_value) and max_value or scaled_value
    scaled_value = (scaled_value < min_value) and min_value or scaled_value

    scaled_value = scaled_value / 100
    print("sc", scaled_value)

    -- local angle_factor = ((buck_angle - min_angle) / (max_angle - min_angle)) +0.2
    -- print("buck_angle", angle_factor)

    -- scaled_value = (-45 +(scaled_value * angle_factor*2.5))/100
    print("final scale", scaled_value)
    return scaled_value
end

--------------------------------------------------------------------------------------------------- weapon stats display
function GetRecoil_mul(self)
    local weapon = self
    local attacker = false
    if self.owner then
        attacker = not gv_SatelliteView and g_Units[self.owner] or gv_UnitData[self.owner]
    else
        attacker = {}
        attacker.placeholder = true
        attacker.Marksmanship = 100
        attacker.Strength = 100 -- Recoil_StrBreakpoint(self)
    end
    local display = true
    local recoil = GetWepRecoil(weapon, attacker, display)
    local other = 1.0
    local caliber = 1.0
    if attacker then
        other = GetRecoilOther(weapon, attacker, false)
        caliber = GetCaliberStrRecoil(weapon, attacker)
    end
    recoil = recoil * other * caliber
    return string.format("%.2f", recoil)
end

function GetHipfire_mul(self)
    local weapon = self
    local attacker = false
    local action = false
    local aim = 0
    local display = true
    local hip = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, display, aim)
    return string.format("%.2f", hip)
end

function GetSnapshot_mul(self)
    local weapon = self
    local attacker = false
    local action = false
    local aim = 1
    local display = true
    local hip = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, display, aim)
    return string.format("%.2f", hip)
end

function Getangle_display(self)
    local angle = self:GetProperty("OverwatchAngle") / 60.0
    return string.format("%.2f", angle)
end

function GetPBbonus_display(self)
    local weapon = self
    local value = GetPBbonus(weapon)
    return value
end

function GetSTR_RECOIL(self)
    local weapon1 = self
    local str = Recoil_StrBreakpoint(weapon1)
    return str
end

function GetAPStance_display(self)
    local ap = self.APStance
    local unit = g_Units[self.owner] or gv_UnitData[self.owner]
    if unit then
        ap = Cumbersome_StanceAP(unit, self, ap)
    elseif self:IsCumbersome() then
        ap = ap + R_VanillaAPToDisplay(1)
    end
    return ap
end


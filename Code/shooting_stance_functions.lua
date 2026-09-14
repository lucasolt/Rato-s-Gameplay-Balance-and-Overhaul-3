function Unit:EnterShootingStance(target, args)

    local weapon = args and args.weapon or self:GetActiveWeapons()
    local target = args and args.target or target or self:GetLastAttack()

    if not weapon or not IsKindOf(weapon, "Firearm") then
        return
    end

    local target_pos = IsValid(target) and target:GetPos() or target

    if self.return_pos then
        self.return_pos_reserved = self.return_pos
        self.return_pos = false
    end

    if IsKindOf(weapon, "BrowningM2HMG") then
        self:AddStatusEffect("shooting_stance")
        return
    end

    if not self:HasStatusEffect("shooting_stance") then
        self:AddStatusEffect("shooting_stance")
    end

    local effect = self:GetStatusEffect("shooting_stance")
    PackAimPosInStanceEffect(effect, target_pos)

    CreateStanceConeV(self, weapon)
end

function Unit:ShootingStanceCommand(action_id, cost_ap, args)
    local stance_effect = self:GetStatusEffect("shooting_stance")
    local target = args and args.target or GetAimPos_ShootingStance(stance_effect)

    if not target then
        return
    end

    local orientation = CalcOrientation(self, target)
    local stance = self.stance
    local aim_state = self:GetAimAnim(stance)

    self:AnimatedRotation(orientation)
    self:SetState(aim_state, const.eKeepComponentTargets)
    ----
    local target_pos = IsValid(target) and target:GetPos() or target
    PackAimPosInStanceEffect(stance_effect, target_pos)
    ----
    Sleep(300)

    self:EnterShootingStance(target)
    -- self:SetCommand("ShootingStanceIdle")

    if not R_IsAI(self) then
        SetInGameInterfaceMode(g_Combat and "IModeCombatMovement" or "IModeExploration")
    end
end

--[[function Unit:ShootingStanceIdle()
    self:SetTargetDummy(self:GetPos(), self:GetOrientationAngle(), self:GetStateText(), 0)
    Msg("Idle", self)
    Halt()
end

function OnMsg.UnitStanceChanged(unit)
    if unit:HasStatusEffect("shooting_stance") then
        unit:SetActionCommand("ShootingStanceCommand", "Rato_StanceChanged", nil)
    end
end]]

function Unit:Reorient_ShootingStance(effect)
    local aim_pos = GetAimPos_ShootingStance(effect)
    if aim_pos then
        local angle = CalcOrientation(self:GetPos(), aim_pos)
        -- Sleep(100)
        if g_Combat then
            self:AnimatedRotation(angle)
        else
            self:SetOrientationAngle(angle)
        end
    end
end

function PackAimPosInStanceEffect(effect, pos)
    if not pos or not effect then
        return
    end

    effect:SetParameter("x", pos:x())
    effect:SetParameter("y", pos:y())
    effect:SetParameter("z", pos:z())
end

function GetAimPos_ShootingStance(effect)
    if not effect then
        return false
    end
    local x = effect:ResolveValue("x")
    local y = effect:ResolveValue("y")
    local z = effect:ResolveValue("z")

    return x and point(x, y, z)
end

function GetShootingAngleDiff(unit, weapon, target, force)
    local cone_angle = weapon.OverwatchAngle / 2
    local target_pos = IsValid(target) and target:GetPos() or target
    if force or Is_AimingAttack() then
        target_pos = target_pos or GetCursorPos(true) -- :SetZ(attacker_z)
    end

    if not target_pos then
        return 0
    end

    local target_angle = abs(unit:AngleToPoint(target_pos))

    local angle_dif = target_angle / cone_angle

    return angle_dif
end

-- Raw AP: one vanilla AP per half-cone, proportional, rounded to displayed AP.
function Rat_RotateAPFromAngle(angle, half)
    if half <= 0 then
        return 0
    end
    return MulDivRound(abs(angle), R_VanillaAP(1) / const.Scale.AP, half) * const.Scale.AP
end

-- Raw AP to rotate the shooting stance towards target.
function ShootingConeAngle(unit, weapon, target)
    local target_pos = IsValid(target) and target:GetPos() or target
    if Is_AimingAttack() then
        target_pos = target_pos or GetCursorPos(true)
    end
    if not target_pos then
        return 0
    end

    local half = weapon.OverwatchAngle / 2
    local angle = abs(unit:AngleToPoint(target_pos))
    local cost = Rat_RotateAPFromAngle(angle, half)

    if weapon:HasComponent("rotate_ap_bipod") and unit.stance == "Prone" and angle >= half then
        cost = cost + R_VanillaAP(1)
    end

    return cost
end

function DestroyStanceConeV(unit)
    if unit.shooter_cone_v then
        DoneObject(unit.shooter_cone_v)
        unit.shooter_cone_v = nil
        DoneObject(unit.snap_cone)
        unit.snap_cone = nil
    end
end

function CreateStanceConeV(unit, weapon)

    local side = unit and unit.team and unit.team.side or ''
    if not (side == 'player1' or side == 'player2') or (SelectedObj and not SelectedObj == unit) then
        return
    end

    local pos = unit:GetPos()
    local angle = unit:GetAngle()
    local weapon = weapon or unit:GetActiveWeapons()

    if weapon then
        local min_aim_range = weapon:GetOverwatchConeParam("MinRange") * const.SlabSizeX
        local max_aim_range = weapon:GetOverwatchConeParam("MaxRange") * const.SlabSizeX
        unit.properties = table.copy(g_Classes[unit.class].properties)
        local idx = table.find(unit.properties, "id", "target_dist")
        if idx then
            unit.properties[idx] = {
                category = "Emplacement",
                id = "target_dist",
                name = "Target Distance",
                editor = "number",
                scale = "m",
                min = min_aim_range,
                max = max_aim_range,
                default = max_aim_range, ----min_aim_range,
                slider = min_aim_range < max_aim_range,
                read_only = min_aim_range == max_aim_range
            }
            unit:SetProperty("target_dist", min_aim_range)
        end
    else
        unit.properties = nil
        local meta = unit:GetPropertyMetadata("target_dist")
        unit:SetProperty("target_dist", meta.default)
    end

    local cone_angle = weapon.OverwatchAngle

    local min_aim_range = weapon:GetOverwatchConeParam("MinRange") * const.SlabSizeX

    local max_aim_range = weapon:GetOverwatchConeParam("MaxRange") * const.SlabSizeX
    local distance = max_aim_range * 1.5 -- Clamp(unit.target_dist, min_aim_range, max_aim_range)
    unit.target_dist = distance
    local target = pos + Rotate(point(distance, 0, 0), angle)
    ---------------
    local step_positions, step_objs = GetStepPositionsInArea(pos, distance, 0, cone_angle, angle,
                                                             "force2d")

    step_objs = empty_table

    unit.shooter_cone_v = CreateAOETilesSector_Shooter(step_positions, step_objs, empty_table,
                                                       unit.shooter_cone_v, pos, target, 1 * guim,
                                                       distance, cone_angle,
                                                       "Overwatch4_Deployed_Ally")

    -- unit.shooter_cone_v:SetOpacity(100)

    ------------------

    ------------------------------

    cone_angle = cone_angle * 2

    if weapon then
        local min_aim_range = weapon:GetOverwatchConeParam("MinRange") * const.SlabSizeX
        local max_aim_range = weapon:GetOverwatchConeParam("MaxRange") * const.SlabSizeX
        unit.properties = table.copy(g_Classes[unit.class].properties)
        local idx = table.find(unit.properties, "id", "target_dist")
        if idx then
            unit.properties[idx] = {
                category = "Emplacement",
                id = "target_dist",
                name = "Target Distance",
                editor = "number",
                scale = "m",
                min = min_aim_range,
                max = max_aim_range,
                default = max_aim_range, ----min_aim_range,
                slider = min_aim_range < max_aim_range,
                read_only = min_aim_range == max_aim_range
            }
            unit:SetProperty("target_dist", min_aim_range)
        end
    else
        unit.properties = nil
        local meta = unit:GetPropertyMetadata("target_dist")
        unit:SetProperty("target_dist", meta.default)
    end

    local min_aim_range = weapon:GetOverwatchConeParam("MinRange") * const.SlabSizeX

    local max_aim_range = weapon:GetOverwatchConeParam("MaxRange") * const.SlabSizeX
    -------------
    local distance = max_aim_range * 1.5 -- Clamp(unit.target_dist, min_aim_range, max_aim_range)
    unit.target_dist = distance
    local target = pos + Rotate(point(distance, 0, 0), angle)
    ---------------
    local step_positions, step_objs = GetStepPositionsInArea(pos, distance, 0, cone_angle, angle,
                                                             "force2d")

    step_objs = empty_table

    unit.snap_cone = CreateAOETilesSector_Snap(step_positions, step_objs, empty_table,
                                               unit.snap_cone, pos, target, 1 * guim, distance,
                                               cone_angle, "Overwatch4_Deployed_Ally")

    if unit == SelectedObj then
        unit.snap_cone:SetOpacity(100)
        unit.shooter_cone_v:SetOpacity(100)
    else
        unit.snap_cone:SetOpacity(0)
        unit.shooter_cone_v:SetOpacity(0)
    end
    ----------------------------------

end

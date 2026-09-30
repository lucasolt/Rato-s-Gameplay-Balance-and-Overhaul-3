local GBO_originalFirearmGetAreaAttackParams = Firearm.GetAreaAttackParams

function Firearm:GetAreaAttackParams(action_id, attacker, target_pos, step_pos, stance)
    local params = GBO_originalFirearmGetAreaAttackParams(self, action_id, attacker, target_pos,
                                                          step_pos, stance)
    ----------
    if action_id == "MGSetup" or action_id == "MGRotate" then
        if params.cone_angle and params.cone_angle > 0 then
            params.cone_angle = MulDivRound(params.cone_angle, const.Combat.MGSetupConeMul, 100)
            params.cone_angle = params.cone_angle + const.Combat.MGSetupConeFlat
        end
    elseif action_id == "BulletHell" and params.cone_angle then
        params.cone_angle = const.Combat.Autofire.BulletHellConeAngle
    end
    ---------
    return params
end

function Firearm:GetOverwatchConeParam(param)
    if param == "Angle" then
        return self.OverwatchAngle
    elseif param == "MinRange" then
        -- return IsKindOfClasses(self, "Shotgun", "MachineGun") and self.WeaponRange or 2
        return IsKindOfClasses(self, "BrowningM2HMG") and self.WeaponRange or 2
    elseif param == "MaxRange" then
        -- return IsKindOfClasses(self, "Shotgun", "MachineGun") and self.WeaponRange or
        --           MulDivRound(self.WeaponRange, 75, 100)
        return IsKindOfClasses(self, "MachineGun") and self.WeaponRange or
                   MulDivRound(self.WeaponRange, 75, 100)
    end
    assert(false, string.format("unknown Overwatch parameter '%s'", param))
end


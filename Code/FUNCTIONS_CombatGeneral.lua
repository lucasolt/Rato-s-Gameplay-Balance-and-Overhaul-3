---------------------------------------------------------------------------------------------------
function OnMsg.ClassesGenerate()
    AppendClass.FirearmProperties = {
        properties = {
            {
                category = "Caliber",
                id = "WeaponClassPBbonus",
                name = "WeaponClassPBbonus",
                help = "WeaponClassPBbonus",
                editor = "number",
                default = 2,
                min = -50,
                max = 50,
                modifiable = false
            }, {
                category = "Caliber",
                id = "PBbonus_base",
                name = "Weapon PointBlank Bonus Accuracy",
                help = "Weapon PointBlank Bonus Accuracy, in addition to the weapon class bonus",
                editor = "number",
                default = 0,
                template = true,
                min = -50,
                max = 50,
                modifiable = true
            }
        }
    }
    SubmachineGun.WeaponClassPBbonus = 5
    Pistol.WeaponClassPBbonus = 5
    Revolver.WeaponClassPBbonus = 5
    Shotgun.WeaponClassPBbonus = 8
    AssaultRifle.WeaponClassPBbonus = 4

end

function GetPBbonus(weapon)
    local base = weapon.PBbonus_base
    local value = 0
    local class = weapon.WeaponClassPBbonus or 0
    local modifyVal, compDef

    if weapon.default_long_barrel then
        value = value - 5
    elseif IsKindOf(weapon, "Shotgun") then
        if weapon and weapon:HasComponent("shortbarrel") then
            value = value + 8
        elseif weapon and weapon:HasComponent("longbarrel") then
            value = value - 4
        end
    elseif IsKindOf(weapon, "SubmachineGun") then
        if weapon and weapon:HasComponent("shortbarrel") then
            value = value + 7
        elseif weapon and weapon:HasComponent("longbarrel") then
            value = value - 4
        end
    elseif IsKindOf(weapon, "Pistol") then
        if weapon and weapon:HasComponent("shortbarrel") then
            value = value + 5
        elseif weapon and weapon:HasComponent("longbarrel") then
            value = value - 3
        end
    elseif IsKindOf(weapon, "Revolver") then
        if weapon and weapon:HasComponent("shortbarrel") then
            value = value + 6
        elseif weapon and weapon:HasComponent("longbarrel") then
            value = value - 3
        end
    else
        if weapon and weapon:HasComponent("shortbarrel") then
            value = value + 6
        elseif weapon and weapon:HasComponent("longbarrel") then
            value = value - 6
        end
    end

    if weapon and weapon:HasComponent("tac_grip_PB") then
        value = value + 4
    end

    if weapon and weapon:HasComponent("vigneron_folded_PB") then
        value = value + 1
    end

    if weapon and weapon:HasComponent("bullpup") then
        value = value + 5
    end

    if weapon and weapon:HasComponent("handguard_ext") then
        modifyVal = GetComponentEffectValue(weapon, "handguard_ext", "pb_bonus_hg")
        value = value + (modifyVal or 0)
    elseif weapon and weapon:HasComponent("handguard_short") then
        modifyVal = GetComponentEffectValue(weapon, "handguard_short", "pb_bonus_hg")
        value = value + (modifyVal or 0)
    end

    value = value + base + class
    return value
end
---------------------------------------------------------------------------------------------------
function IsAimed_Mobile(self, unit, ap)
    local cost, aimed_cost = rat_MobileAction_AP(self, unit)

    if ap < aimed_cost then
        return false
    end
    return true
end
---------------------------------------------------------------------------------------------------
function hand_eye_crit(action_id, weapon, attacker, aim)
    if not action_id then
        return 0
    end

    -- Firearm.CritScalingFactor = 100
    -- Firearm.BustShotCritScalingFactor = 100
    -- Firearm.SingleShotCritScalingFactor = 300
    -- G36.BustShotCritScalingFactor = 250
    -- SniperRifle.SingleShotCritScalingFactor = 500

    local single_factor = 3.0
    local not_single = 1.0
    local burst_factor = not_single

    if IsKindOf(weapon, "SniperRifle") then
        single_factor = 5.0
    end

    if IsKindOf(weapon, "G36") then
        burst_factor = 2.5
    end

    local hand_eye = rGetHandEyeCoordination(attacker)

    local factor = not_single

    if action_id == "SingleShot" or action_id == "PinDown" then
        factor = single_factor
    elseif action_id == "BurstFire" then
        factor = burst_factor
    end

    local hec_factor = hand_eye * factor
    local crit_HEC = cRound(hec_factor / 100 * (0 + (aim or 0)))

    return crit_HEC
end
---------------------------------------------------------------------------------------------------
function Is_AimingAttack()
    local dlg = GetInGameInterfaceModeDlg()
    if IsKindOf(dlg, "IModeCombatAttackBase") then
        return true
    elseif IsKindOf(dlg, "IModeCombatAreaAim") then
        return true
    elseif IsKindOf(dlg, "IModeCombatAttack") then
        return true
    else
        return false
    end
end
---------------------------------------------------------------------------------------------------
function Get_AimCost(unit)
    local aim_cost = R_VanillaAP(1)
    local indoors = unit and unit.indoors
    if GameState.RainHeavy and not indoors then
        aim_cost = MulDivRound(aim_cost, 100 + const.EnvEffects.RainAimingMultiplier, 100)
    end
    return aim_cost
end
---------------------------------------------------------------------------------------------------
function rat_close_range()
    return ((const.Weapons.PointBlankRange * 2) + (1)) * const.SlabSizeX
end
---------------------------------------------------------------------------------------------------
function rat_get_mechanism()
    return {
        "Revolver", "Blowback", "Single_Shot", "Striker_Fired", "Short_Recoil", "Gas_Operated",
        "Recoil_Operated", "Roller_Delayed", "Break_Action", "Pump_Action", "Bolt_Action",
        "Lever_Action", ""
    }
end
---------------------------------------------------------------------------------------------------

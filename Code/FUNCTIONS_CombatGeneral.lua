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

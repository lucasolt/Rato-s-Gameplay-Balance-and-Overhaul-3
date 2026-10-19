---- Generic mag ids (loadouts, old saves) -> the per-gun component the slot actually offers.
---- 5.45 guns use the Fine pair only: their plain MagNormal/MagLarge wear the 7.62x39 mags.
RAT_MAG_COMPONENT_SWAPS = {
    HiPower = {MagLarge = "MagLarge_1", MagLargeFine = "MagLargeFine_1"},
    AK74 = {MagNormal = "MagNormalFine", MagLarge = "MagLargeFine"},
    AKSU = {MagNormal = "MagNormalFine", MagLarge = "MagLargeFine"},
    RPK74 = {MagNormal = "MagNormalFine", MagLarge = "MagNormalFine", MagLargeFine = "MagNormalFine"},
    Glock18 = {MagLarge = "MagLarge_3", MagLargeFine = "MagLargeFine_3"},
    UZI = {MagLarge = "MagLarge_4", MagLargeFine = "MagLargeFine_4"},
    MP5 = {MagLarge = "MagLarge_5", MagLargeFine = "MagLargeFine_5"},
    MP5K = {MagLarge = "MagLarge_5", MagLargeFine = "MagLargeFine_5"},
    M14SAW = {MagLarge = "MagLarge_5", MagLargeFine = "MagLargeFine_5"},
    M14SAW_AUTO = {MagLarge = "MagLarge_5", MagLargeFine = "MagLargeFine_5"},
    BarretM82 = {MagLarge = "MagLarge_5", MagLargeFine = "MagLargeFine_5"},
    AA12 = {MagLarge = "MagLarge_6", MagLargeFine = "MagLargeFine_6"},
    AUG = {MagLarge = "MagLarge_7", MagLargeFine = "MagLargeFine_7"},
    HK21 = {MagLarge = "MagLarge_8", MagLargeFine = "MagLargeFine_8"},
    G36 = {MagLarge = "MagLarge_9", MagLargeFine = "MagLargeFine_9"},
    PSG1 = {MagLarge = "MagLarge_10", MagLargeFine = "MagLargeFine_10"},
    FNMinimi = {MagLarge = "MagLarge_12", MagLargeFine = "MagLargeFine_12"}
    -- MP40 = {MagLarge = "MagLarge_11", MagLargeFine = "MagLargeFine_11"}
}

function rat_changeMag_component(unit)

    if IsMod_loaded("URkxyfE") then
        return
    end

    if not unit then
        return
    end

    local weapons = unit:GetEquippedWeapons(unit.current_weapon) or {}
    local alt_slot = unit.current_weapon == "Handheld A" and "Handheld B" or "Handheld A"

    table.iappend(weapons, unit:GetEquippedWeapons(alt_slot))

    for _, weapon in ipairs(weapons) do
        local swaps = RAT_MAG_COMPONENT_SWAPS[weapon.class]
        local target = swaps and weapon.components and swaps[weapon.components.Magazine]
        if target then
            local ammo = weapon.ammo
            weapon.ammo = false
            print("Changing magazine component for weapon:", weapon.class, "to", target)
            weapon:SetWeaponComponent("Magazine", target)

            if ammo then
                ammo.Amount = weapon.MagazineSize
                unit:ReloadWeapon(weapon, ammo, "delay fx", "ai")
            end

            ObjModified(weapon)
        end
    end
end

function OnMsg.UnitEnterCombat(unit)
    rat_changeMag_component(unit)
end

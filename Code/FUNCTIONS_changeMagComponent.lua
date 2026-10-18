function rat_changeMag_component(unit)

    if IsMod_loaded("URkxyfE") then
        return
    end

    if not unit then
        return
    end

    local weapons_list = {
        {
            "HiPower", "MagLarge_1",
            "MagLargeFine_1"
        }, {
            "RPK74", "MagNormal",
            "MagNormalFine"
        }, {
            "Glock18", "MagLarge_3",
            "MagLargeFine_3"
        },
        {
            "UZI", "MagLarge_4",
            "MagLargeFine_4"
        },
        {
            "MP5", "MagLarge_5",
            "MagLargeFine_5"
        }, {
            "MP5K", "MagLarge_5",
            "MagLargeFine_5"
        }, {
            "M14SAW", "MagLarge_5",
            "MagLargeFine_5"
        }, {
            "M14SAW_AUTO", "MagLarge_5",
            "MagLargeFine_5"
        }, {
            "BarretM82", "MagLarge_5",
            "MagLargeFine_5"
        }, {
            "AA12", "MagLarge_6",
            "MagLargeFine_6"
        },
        {
            "AUG", "MagLarge_7",
            "MagLargeFine_7"
        }, {
            "HK21", "MagLarge_8",
            "MagLargeFine_8"
        },
        {
            "G36", "MagLarge_9",
            "MagLargeFine_9"
        }, {
            "PSG1", "MagLarge_10",
            "MagLargeFine_10"
        }, {
            "FNMinimi", "MagLarge_12",
            "MagLargeFine_12"
        }
        -- ,{"MP40", "MagLarge_11", "MagLargeFine_11"}
    }

    local weapons =
        unit:GetEquippedWeapons(
            unit.current_weapon) or {}
    local alt_slot =
        unit.current_weapon ==
            "Handheld A" and
            "Handheld B" or "Handheld A"

    table.iappend(weapons,
                  unit:GetEquippedWeapons(
                      alt_slot))

    if not next(weapons) then
        return
    end

    for _, weapon in ipairs(weapons) do
        -- print(weapon.class)
        if weapon.components and
            weapon.components.Magazine then
            if weapon.components
                .Magazine == "MagLarge" then
                for _, entry in ipairs(
                                    weapons_list) do
                    if entry[1] ==
                        weapon.class then
                        local ammo =
                            weapon.ammo
                        weapon.ammo =
                            false
                        print(
                            "Changing magazine component for weapon:",
                            entry[1],
                            "to",
                            entry[2])
                        weapon:SetWeaponComponent(
                            "Magazine",
                            entry[2])

                        ammo.Amount =
                            weapon.MagazineSize
                        unit:ReloadWeapon(
                            weapon,
                            ammo,
                            "delay fx",
                            "ai")

                        ObjModified(
                            weapon)

                        -- print("reloaded")

                        break
                    end
                end
            elseif weapon.components
                .Magazine ==
                "MagLargeFine" then
                for _, entry in ipairs(
                                    weapons_list) do
                    if entry[1] ==
                        weapon.class then
                        local ammo =
                            weapon.ammo
                        weapon.ammo =
                            false
                        print(
                            "Changing magazine component for weapon:",
                            entry[1],
                            "to",
                            entry[3])
                        weapon:SetWeaponComponent(
                            "Magazine",
                            entry[3])

                        ammo.Amount =
                            weapon.MagazineSize
                        unit:ReloadWeapon(
                            weapon,
                            ammo,
                            "delay fx",
                            "ai")

                        ObjModified(
                            weapon)
                        break
                    end
                end
            end
        end
    end
end

function OnMsg.UnitEnterCombat(unit)
    rat_changeMag_component(unit)
end

local version = 360

function OnMsg.UnitEnterCombat(unit)
    -- local unit_version = unit.rat_unit_updated or 0

    -- if IsMerc(unit) or unit_version < version then
    --     GBO_ReapplyWeaponComponents(unit)
    -- end
end

function OnMsg.UnitDataCreated(unit)
    set_unit_version_update(unit)
end

function OnMsg.UnitCreated(unit)
    if not unit or not IsKindOf(unit, "Unit") or not unit:IsValid() then
        return
    end
    if not unit.unitdatadef_id then
        return
    end

    local unit_version = unit.rat_unit_updated or 0

    if IsMerc(unit) or unit_version < version then
        print("RAT MOD - updating unit:", unit.unitdatadef_id)
        ---update_components(unit)
        GBO_ReapplyWeaponComponents(unit)
    elseif R_IsAI(unit) then
        change_handgun_barrel(unit)
    end
end

function set_unit_version_update(unit)
    if not unit or not IsKindOf(unit, "Unit") or not unit:IsValid() then
        return
    end

    unit.rat_unit_updated = version
end

local force_reapply = Platform.rat and false

function GBO_ReapplyWeaponComponents(unit)
    if not unit or not IsKindOf(unit, "Unit") or not unit:IsValid() then
        return
    end

    local weapons = unit:GetEquippedWeapons(unit.current_weapon) or {}
    local alt_slot = unit.current_weapon == "Handheld A" and "Handheld B" or "Handheld A"

    table.iappend(weapons, unit:GetEquippedWeapons(alt_slot))

    if not next(weapons) then
        return
    end

    for _, weapon in ipairs(weapons) do
        local wep_version = weapon.rat_updated_in or 0
        if wep_version < version or force_reapply then
            local components = weapon.components

            for slot, component_id in sorted_pairs(components) do
                if WeaponComponents[component_id] then
                    print("RATMOD Update - Reapplying component ", component_id, " in slot ", slot,
                          " of weapon ", weapon.class, " owner: ", unit.session_id)
                    weapon:SetWeaponComponent(slot, component_id)
                end
            end
            weapon.rat_updated_in = version
        end
    end
    unit.rat_unit_updated = version
end

function update_components(unit)
    if not unit then
        return
    end

    local weapons = unit:GetEquippedWeapons(unit.current_weapon) or {}
    local alt_slot = unit.current_weapon == "Handheld A" and "Handheld B" or "Handheld A"

    table.iappend(weapons, unit:GetEquippedWeapons(alt_slot))

    if not next(weapons) then
        return
    end

    -- local bolt = {

    -- {"SteyrScout_1", "Bolt_action_scout"}
    -- {false, "Bolt_action"}

    -- }

    local function endsWithHandgun(str)
        if not str then
            return false
        end
        local suffix = "_handgun"
        return string.sub(str, -#suffix) == suffix
    end

    for _, weapon in ipairs(weapons) do
        local wep_version = weapon.rat_updated_in or 0
        if wep_version < version then
            -- print("updating weapons for unit:", unit.unitdatadef_id, "weapon:", weapon.class)
            if IsKindOf(weapon, "VSS_1") then
                weapon:SetWeaponComponent("Muzzle", "R_VSS_suppressor")
            end

            if weapon.components then

                if weapon.components.Barrel then

                    if IsKindOfClasses(weapon, "RK95_1", "RK62_1") then
                        local current_comp = weapon.components.Barrel
                        weapon:SetWeaponComponent("Barrel", current_comp)
                        ObjModified(weapon)
                    end

                    if weapon:HasComponent("longbarrel") or weapon:HasComponent("shortbarrel") then

                        local current_comp = weapon.components.Barrel

                        if IsKindOf(weapon, "SubmachineGun") and weapon.is_tog_patched then
                            print(current_comp)
                            if current_comp == "ToG_Comp_AR_Barrel_Long_1" or current_comp ==
                                "ToG_Comp_AR_Barrel_Long_2" and
                                WeaponComponents[current_comp .. "_SMG"] then

                                weapon:SetWeaponComponent("Barrel", current_comp .. "_SMG")

                                ObjModified(weapon)

                            end
                        elseif not weapon.is_vanilla_firearm then -- IsKindOfClasses(weapon, "Glock17_1", "USP_1", "VikingMP446_1", "B93R_1", "B93RR_1", "P08_1") then
                            weapon:SetWeaponComponent("Barrel", current_comp)

                        elseif IsKindOfClasses(weapon, "Pistol", "Revolver", "SubmachineGun") then

                            if current_comp == "BarrelLong_jaggerMeister" then
                                current_comp = "BarrelLong"
                            end

                            if endsWithHandgun(current_comp) then
                                weapon:SetWeaponComponent("Barrel", current_comp)
                            elseif WeaponComponents[current_comp .. "_handgun"] then
                                weapon:SetWeaponComponent("Barrel", current_comp .. "_handgun")
                            end

                        else
                            weapon:SetWeaponComponent("Barrel", current_comp)
                        end

                        ObjModified(weapon)
                    end

                end

                if weapon.components.General then
                    if weapon.components.General == "Bolt_action" then
                        if IsKindOf(weapon, "SteyrScout_1") then
                            weapon:SetWeaponComponent("General", "Bolt_action_scout")
                            ObjModified(weapon)
                        else
                            weapon:SetWeaponComponent("General", "Bolt_action")
                            ObjModified(weapon)
                        end
                    end
                end

                if IsKindOfClasses(weapon, "ColtPeacemaker", "TexRevolver", "ColtAnaconda") then

                    if IsKindOfClasses(weapon, "ColtPeacemaker") then
                        weapon:SetWeaponComponent("Trigger", "single_action")
                        ObjModified(weapon)
                    end

                    if IsKindOfClasses(weapon, "TexRevolver") then
                        weapon:SetWeaponComponent("Trigger", "single_action_tex")
                        ObjModified(weapon)
                    end

                    if IsKindOfClasses(weapon, "ColtAnaconda") then
                        weapon:SetWeaponComponent("Trigger", "SADA_action")
                        ObjModified(weapon)
                    end

                end

                if IsKindOfClasses(weapon, "Winchester1894", "Winchester_Quest") then
                    if not weapon.components.General or not weapon.components.General ==
                        "lever_action" then
                        weapon:SetWeaponComponent("General", "lever_action")
                        ObjModified(weapon)
                    end
                end
            end

            weapon.rat_updated_in = version

            -- else
            -- print("Already updated unit:", unit.unitdatadef_id, "weapon:", weapon.class)
        end

    end
    unit.rat_unit_updated = version
end

function change_handgun_barrel(unit)
    if not unit or not IsKindOf(unit, "Unit") or not unit:IsValid() then
        return
    end

    local weapons = unit:GetEquippedWeapons(unit.current_weapon) or {}
    local alt_slot = unit.current_weapon == "Handheld A" and "Handheld B" or "Handheld A"

    table.iappend(weapons, unit:GetEquippedWeapons(alt_slot))

    if not next(weapons) then
        return
    end

    local function endsWithHandgun(str)
        if not str then
            return false
        end
        local suffix = "_handgun"
        return string.sub(str, -#suffix) == suffix
    end

    for _, weapon in ipairs(weapons) do
        if weapon.is_tog_patched and IsKindOf(weapon, "SubmachineGun") then
            if weapon.components then
                if weapon.components.Barrel then
                    if weapon:HasComponent("longbarrel") or weapon:HasComponent("shortbarrel") then
                        local current_comp = weapon.components.Barrel
                        if (current_comp == "ToG_Comp_AR_Barrel_Long_1" or current_comp ==
                            "ToG_Comp_AR_Barrel_Long_2_SMG") and
                            WeaponComponents[current_comp .. "_SMG"] then
                            weapon:SetWeaponComponent("Barrel", current_comp .. "_SMG")
                            ObjModified(weapon)
                        end
                    end
                end
            end
        end
        if weapon.is_vanilla_firearm and
            IsKindOfClasses(weapon, "Pistol", "Revolver", "SubmachineGun") then
            if weapon.components then
                if weapon.components.Barrel then
                    if weapon:HasComponent("longbarrel") or weapon:HasComponent("shortbarrel") then

                        local current_comp = weapon.components.Barrel

                        if current_comp == "BarrelLong_jaggerMeister" then
                            current_comp = "BarrelLong"
                        end

                        if not endsWithHandgun(current_comp) and
                            WeaponComponents[current_comp .. "_handgun"] then
                            print("RAT MOD: updating handgun barrel component")
                            weapon:SetWeaponComponent("Barrel", current_comp .. "_handgun")
                            ObjModified(weapon)
                        end
                    end
                end
            end
        end
    end
end

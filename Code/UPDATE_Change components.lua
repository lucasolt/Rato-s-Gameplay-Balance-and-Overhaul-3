local version = 360

--function OnMsg.UnitEnterCombat(unit)
--    local unit_version = unit.rat_unit_updated or 0
--
--    if IsMerc(unit) or unit_version < version then
--        GBO_ReapplyWeaponComponents(unit)
--    end
--end

function OnMsg.UnitEnterCombat(unit)
	GBO_GeneralUnitItemUpdate(unit)
end

function OnMsg.UnitDataCreated(unit)
    set_unit_version_update(unit)
end

function OnMsg.UnitCreated(unit)
	GBO_GeneralUnitItemUpdate(unit)
end

function GBO_GeneralUnitItemUpdate(unit, no_version_handling)
    if not unit or not IsKindOf(unit, "Unit") or not unit:IsValid() then
        return
    end
    if not unit.unitdatadef_id then
        return
    end

    local unit_version = no_version_handling and -1 or unit.rat_unit_updated or 0

    if IsMerc(unit) or unit_version < version then
        print("GBO - updating unit:", unit.unitdatadef_id)
        GBO_ReapplyWeaponComponents(unit)
		GBO_ApplyDefaultSubweapon(unit)
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

local force_reapply = Platform.rat and true

local function checkAndSetComponent(weapon, slot, component_id)
	if WeaponComponents[component_id] then
		weapon:SetWeaponComponent(slot, component_id)
		return true
	end
end

-- Re-setting these unloads ammo / rebuilds the subweapon, dumping rounds into the squad bag.
local function isUnsafeToReapply(slot, component_id)
	local def = WeaponComponents[component_id]
	return slot == "Magazine" or (def and def.EnableWeapon)
end

function GBO_ReapplyWeaponComponents(unit, force)
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
        if wep_version < version or force_reapply or force then
            local components = weapon.components
            for slot, component_id in sorted_pairs(components) do
				if IsKindOf(weapon, "MP40") and slot == "Scope" and component_id == "ImprovedIronsight" then
					weapon:SetWeaponComponent("Scope", false)

				elseif IsKindOf(weapon, "AKSU") and slot == "Muzzle" and component_id == "Compensator" then
					checkAndSetComponent(weapon, "Muzzle", "Compensator_ReducedReliability")

				elseif not isUnsafeToReapply(slot, component_id) then
                    print("GBO Update - Reapplying component ", component_id, " in slot ", slot,
                          " of weapon ", weapon.class, " owner: ", unit.session_id)
                    checkAndSetComponent(weapon, slot, component_id)
                end
            end
            weapon.rat_updated_in = version
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
                            "ToG_Comp_AR_Barrel_Long_2") and
                            checkAndSetComponent(weapon, "Barrel", current_comp .. "_SMG") then
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
                            checkAndSetComponent(weapon, "Barrel", current_comp .. "_handgun") then
                            print("GBO: updating handgun barrel component")
                            ObjModified(weapon)
                        end
                    end
                end
            end
        end
    end
end

function GBO_ApplyDefaultSubweapon(unit)
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
		if IsKindOf(weapon, "A91_1") then
			if weapon.components and weapon.components.Under and weapon.components.Under ~= "A91_GrenadeLauncher"
				and checkAndSetComponent(weapon, "Under", "A91_GrenadeLauncher") then
				ObjModified(weapon)
			end
		end
	end
end
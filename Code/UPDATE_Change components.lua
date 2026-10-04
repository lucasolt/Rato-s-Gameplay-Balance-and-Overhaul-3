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

-- Component values are baked per CTH mode; an option changed outside the save leaves them stale.
local function isCTHModeStale(weapon)
    return IsKindOf(weapon, "Firearm") and weapon.rat_updated_cth_mode ~= RAT_ApertureCTHMode
end

local function hasCTHModeStaleWeapon(unit)
    for _, wslot in ipairs({"Handheld A", "Handheld B"}) do
        for _, weapon in ipairs(unit:GetEquippedWeapons(wslot) or empty_table) do
            if isCTHModeStale(weapon) then
                return true
            end
        end
    end
end

function GBO_GeneralUnitItemUpdate(unit, no_version_handling)
    if not unit or not IsKindOf(unit, "Unit") or not unit:IsValid() then
        return
    end
    if not unit.unitdatadef_id then
        return
    end

    local unit_version = no_version_handling and -1 or unit.rat_unit_updated or 0

    if IsMerc(unit) or unit_version < version or hasCTHModeStaleWeapon(unit) then
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

-- Re-sets the safe components so their modifiers come from the current (mode-composed) defs.
function Rat_RefreshCTHModeWeapon(weapon)
    for slot, component_id in sorted_pairs(weapon.components or empty_table) do
        if not isUnsafeToReapply(slot, component_id) then
            checkAndSetComponent(weapon, slot, component_id)
        end
    end
    weapon.rat_updated_cth_mode = RAT_ApertureCTHMode
    ObjModified(weapon)
end

-- Every live item, not just equipped ones: bag and stash weapons keep the modifiers baked when attached.
function GBO_RefreshCTHModeItems(force)
    local n = 0
    for _, item in pairs(g_ItemIdToItem or empty_table) do
        if IsKindOf(item, "Firearm") and not rawget(item, "is_clone") and (force or isCTHModeStale(item)) then
            Rat_RefreshCTHModeWeapon(item)
            n = n + 1
        end
    end
    return n
end

---- parts a gun no longer offers, swapped for their replacement in old saves
GBO_RetiredComponents = {
    ---- the Winchester (.44) takes the handgun barrel family
    Winchester1894 = {
        Barrel = {BarrelLong = "BarrelLong_handgun", long_barrel_light = "long_barrel_light_handgun"}
    }
}

function GBO_ReplaceRetiredComponents(weapon)
    local map = GBO_RetiredComponents[weapon.class]
    for slot, component_id in sorted_pairs(map and weapon.components or empty_table) do
        local new_id = map[slot] and map[slot][component_id]
        if new_id and checkAndSetComponent(weapon, slot, new_id) then
            print("GBO Update - replacing retired component", component_id, "with", new_id, "on", weapon.class)
            ObjModified(weapon)
        end
    end
end

function OnMsg.ZuluGameLoaded()
    for _, item in pairs(g_ItemIdToItem or empty_table) do
        if IsKindOf(item, "Firearm") and not rawget(item, "is_clone") then
            GBO_ReplaceRetiredComponents(item)
        end
    end
    GBO_RefreshCTHModeItems()
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
        if wep_version < version or isCTHModeStale(weapon) or force_reapply or force then
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
            if IsKindOf(weapon, "Firearm") then
                weapon.rat_updated_cth_mode = RAT_ApertureCTHMode
            end
            ObjModified(weapon)
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
        if IsVanillaFirearm(weapon) and
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
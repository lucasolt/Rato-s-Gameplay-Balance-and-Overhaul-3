function disable_unpatched_shop()
    print("GBO TOG PATCH - Disabling unpatched weapons in shop")
    ForEachPreset("InventoryItemCompositeDef", function(w)
        local item = g_Classes[w.id]
        if IsKindOf(item, "Katana_1") then
            w.CanAppearInShop = false
            item.CanAppearInShop = false
        end
        if IsKindOf(item, "Firearm") and not IsKindOf(item, "HeavyWeapon") then
            if not (IsVanillaFirearm(item) or item.is_tog_patched) then
                w.CanAppearInShop = false
                item.CanAppearInShop = false
            end
        end
        ------------ Disable Zulib Grenades temporarily, couldnt make them work with the GL
        if IsKindOf(item, "Ordnance") and (item.Caliber == "22mm_Nato" or item.Caliber == "22mm_WP") then
            w.CanAppearInShop = false
            item.CanAppearInShop = false
        end

        disable_44mag_inshop(item, w)
    end)

end

function disable_44mag_inshop(item, preset)
    if IsKindOf(item, "Ammo") and (item.Caliber == "44MAG") then
        preset.CanAppearInShop = false
        item.CanAppearInShop = false
    end
end

--------------------
local function IsRecipeDisabled(operation_id, item_id)
    local class = g_Classes[item_id]
    if operation_id == "CraftAmmo" then
        -- FlareAmmo is not Ammo and its caliber is not in the list
        return IsKindOf(class, "Ammo") and not table.find(ratG_UsedCalibers, class.Caliber)
    elseif operation_id == "CraftExplosives" then
        return class and (class.Caliber == "22mm_Nato" or class.Caliber == "22mm_WP")
    end
end

local function PruneDisabledRecipes(operation_id)
    local recipes = (operation_id == "CraftAmmo" and g_RecipesCraftAmmo) or
                        (operation_id == "CraftExplosives" and g_RecipesCraftExplosives)
    if type(recipes) ~= "table" then
        return
    end
    for i = #recipes, 1, -1 do
        if IsRecipeDisabled(operation_id, recipes[i].item_id) then
            table.remove(recipes, i)
        end
    end
end

-- Fill builds the list on first open, unfiltered; pruning only before Validate missed it
local original_SectorOperationFillItemsToCraft = SectorOperationFillItemsToCraft
function SectorOperationFillItemsToCraft(sector_id, operation_id, merc)
    local result = original_SectorOperationFillItemsToCraft(sector_id, operation_id, merc)
    PruneDisabledRecipes(operation_id)
    return result
end

local original_SectorOperationValidateItemsToCraft = SectorOperationValidateItemsToCraft
function SectorOperationValidateItemsToCraft(sector_id, operation_id, merc)
    original_SectorOperationValidateItemsToCraft(sector_id, operation_id, merc)
    PruneDisabledRecipes(operation_id)
end
---------------

function OnMsg.DataLoaded()
    disable_unpatched_shop()
end

function OnMsg.ModsReloaded()
    disable_unpatched_shop()
end

function IsVanillaFirearm(weapon)
    local class = weapon.class or weapon.id
    local vanilla = {
        "GoldenGun", "AK47", "AK74", "AR15", "AUG", "FAMAS", "FNFAL", "G36", "Galil", "M14SAW",
        "M14SAW_AUTO", "M16A2", "Bereta92", "ColtAnaconda", "ColtPeacemaker", "DesertEagle",
        "FlareHandgun", "Glock18", "HiPower", "TexRevolver", "BrowningM2HMG", "FNMinimi", "HK21",
        "MG42", "MG58", "RPK74", "BarretM82", "DragunovSVD", "Gewehr98", "M24Sniper", "PSG1",
        "Winchester1894", "AKSU", "M4Commando", "MP40", "MP5", "MP5K", "UZI", "AA12", "Auto5",
        "DoubleBarrelShotgun", "M41Shotgun", "Auto5_quest", "Galil_FlagHill", "LionRoar",
        "Winchester_Quest", "FlareHandgun"
    }

    for _, vanillaClass in ipairs(vanilla) do
        if class == vanillaClass then
            return true
        end
    end

    return false
end

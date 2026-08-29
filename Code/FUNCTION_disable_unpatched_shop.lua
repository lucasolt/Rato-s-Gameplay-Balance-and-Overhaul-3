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
function disable_zulib_22mm_recipes()
    local recipes = g_RecipesCraftExplosives

    local to_remove = {}
    for i, recipe in ipairs(recipes) do
        local class = g_Classes[recipe.item_id]
        if class and (class.Caliber == "22mm_Nato" or class.Caliber == "22mm_WP") then
            table.insert(to_remove, recipe)
        end
    end
    for i, remove in ipairs(to_remove) do
        table.remove_value(recipes, remove)
        -- print("GBO - removing craft recipe:", remove.item_id)
    end
end

function disable_zulib_unused_calibers_recipes()
    local recipes = g_RecipesCraftAmmo
    local to_remove = {}
    for i, recipe in ipairs(recipes) do
        local class = g_Classes[recipe.item_id]
        if class and not table.find(ratG_UsedCalibers, class.Caliber) then
            table.insert(to_remove, recipe)
        end
    end
    for i, remove in ipairs(to_remove) do
        table.remove_value(recipes, remove)
        -- print("GBO - removing craft recipe:", remove.item_id)
    end
end

local original_SectorOperationValidateItemsToCraft = SectorOperationValidateItemsToCraft
function SectorOperationValidateItemsToCraft(sector_id, operation_id, merc)
    disable_zulib_22mm_recipes()
    disable_zulib_unused_calibers_recipes()
    original_SectorOperationValidateItemsToCraft(sector_id, operation_id, merc)
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

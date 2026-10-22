function OnMsg.RevisedMagPropsAddedToFirearms()
    ---- no drum: the 75-round drum is an RPK (7.62x39) mag
    REV_SetupWeapon(RPK74, "AK545", "AK74MagazineLarge", "MagLargeFine", {"MagLargeFine", "MagNormalFine"})
    REV_SetupWeapon(AK74, "AK545", "AK74Magazine", "MagNormalFine", {"MagLargeFine", "MagNormalFine"})
    REV_SetupWeapon(M14SAW_AUTO, "M14", "M14Magazine", "MagNormal", {"MagLarge", "MagNormal"})
    ---- AK545 mags insert the Fine components; AKSU kept the plain ones, so no mag matched its slot
    REV_SetupWeapon(AKSU, "AK545", "AK74Magazine", "MagNormalFine", {"MagLargeFine", "MagNormalFine"})
    ---- the RPK drum (MagLarger) is a 7.62x39 mag; Revised Mags already has its AK47 visual
    REV_SetupWeapon(AK47, "AK762", "AK47Magazine", "MagNormal", {"MagLarge", "MagLarger", "MagNormal"})
    ---- RevMags puts the 30-round mag on MagLarge, which vanilla pairs against StockFolded (meant for the drum)
    REV_SetupWeapon(G36, "G36", "G36MagazineLarge", "MagNormal", {"MagLarger", "MagNormal", "MagQuick"})

end

function GBO_RevMag_ChangeMagazinesClasses()
    if IsMod_loaded("URkxyfE") then
        print("GBO - RevMags Detected, changing mags at ClassesGenerate hook")

        local function Rat_RevMag_changeInventoryItem(mag_id, mag, caliber, desc, platform)
            if mag then
                if platform then
                    mag.Platform = platform
                end
                mag.Caliber = caliber
                mag.AdditionalHint = T(desc)
            else
                print("GBO REV MAG compatibility error", tostring(mag_id), "not found")
            end
        end

        local change_map = {
            {"SVDMagazine", SVDMagazine, "7_62x54R", "7.62x54mmR"},

            {"AK74Magazine", AK74Magazine, "5_45x39", "5.45mm", "AK545"},
            {"AK74MagazineLarge", AK74MagazineLarge, "5_45x39", "5.45mm", "AK545"},
            {"AK47MagazineMagLarger", AK47MagazineMagLarger, "762WP", "7.62x39mm", "AK762"},

            {"DesertEagleMagazine", DesertEagleMagazine, "50AE", ".50 AE"},
            {"DesertEagleMagazineLarge", DesertEagleMagazineLarge, "50AE", ".50 AE"}
        }

        for _, change in ipairs(change_map) do
            local mag_id = change[1]
            local mag = change[2]
            local caliber = change[3]
            local desc = change[4]
            local platform = change[5]

            Rat_RevMag_changeInventoryItem(mag_id, mag, caliber, desc, platform)
        end

        G36MagazineLarge.Modification = "MagNormal"
        ---- the real RPK drum; Revised Mags ships it at 100
        AK47MagazineMagLarger.MagazineSize = 75
    end
end

function OnMsg.ClassesGenerate(classdefs)
    GBO_RevMag_ChangeMagazinesClasses()
end

---- the G36 drum (MagLarger with RevMags, MagLarge_9 without) gets the vanilla MagLarge fold block
function Rat_BlockFoldWithDrumG36(drum)
    local pair = WeaponComponentBlockPairs.G36StockAndDrumMag
    if pair then
        pair.ComponentBlockTwo = drum
        return
    end
    PlaceObj('WeaponComponentBlockPair', {
        ComponentBlockOne = "StockFolded",
        ComponentBlockTwo = drum,
        Weapon = "G36",
        group = "Z_Blockings",
        id = "G36StockAndDrumMag"
    })
end

---- mag visuals under Revised Mags: GBO_RevMagCatalog (COMPATIBILITY_RevMagCatalog.lua)
function GBO_ApplyRevMagCompatibility()
    if IsMod_loaded("URkxyfE") then
        Rat_BlockFoldWithDrumG36("MagLarger")
    else
        Rat_BlockFoldWithDrumG36("MagLarge_9")
    end
end

---- RevMags disables the Magazine slot button on DataLoaded; CommonLib's ChangeUI replaces that OnContextUpdate later (OnModLoad)
local function Rat_RevMag_lockMagazineSlot()
    if not IsMod_loaded("URkxyfE") then
        return
    end
    local found = REV_CustomSettingsUtils.XTemplate_FindElementsByProp(XTemplates.WeaponComponentWindow, 'Id', 'idCurrent')
    local element = found and found.element
    if not element or element.rat_revmag_locked then
        return
    end
    local orig = element.OnContextUpdate
    element.OnContextUpdate = function(self, context, ...)
        orig(self, context, ...)
        ---- rat_sks_internal (ToG patch): the SKS converts between its internal mag and AK mags here
        local weapon = ResolvePropObj(context)
        if context.slot and context.slot.SlotType == "Magazine" and not (weapon and weapon.rat_sks_internal) then
            self:SetEnabled(false)
        end
    end
    element.rat_revmag_locked = true
end

function OnMsg.ModsReloaded()
    GBO_ApplyRevMagCompatibility()
    Rat_RevMag_lockMagazineSlot()
end

function OnMsg.DataLoaded()
    GBO_ApplyRevMagCompatibility()
end


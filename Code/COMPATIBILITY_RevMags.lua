function OnMsg.RevisedMagPropsAddedToFirearms()
    REV_SetupWeapon(RPK74, "AK545", "AK74Magazine", "MagNormalFine",
                    {"MagLargeFine", "MagLarger", "MagNormalFine"})
    REV_SetupWeapon(AK74, "AK545", "AK74Magazine", "MagNormalFine",
                    {"MagLargeFine", "MagLarger", "MagNormalFine"})
    REV_SetupWeapon(M14SAW_AUTO, "M14", "M14Magazine", "MagNormal", {"MagLarge", "MagNormal"})

end

function GBO_RevMag_ChangeMagazinesClasses()
    if IsMod_loaded("URkxyfE") then
        print("RATMOD - RevMags Detected, changing mags at ClassesGenerate hook")

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
            {"AK47MagazineMagLarger", AK47MagazineMagLarger, "5_45x39", "5.45mm", "AK545"}

            -- {"DesertEagleMagazine", DesertEagleMagazine, "44MAG", ".44 Magnum"},
            -- {"DesertEagleMagazineLarge", DesertEagleMagazineLarge, "44MAG", ".44 Magnum"}
        }

        for _, change in ipairs(change_map) do
            local mag_id = change[1]
            local mag = change[2]
            local caliber = change[3]
            local desc = change[4]
            local platform = change[5]

            Rat_RevMag_changeInventoryItem(mag_id, mag, caliber, desc, platform)
        end
    end
end

function OnMsg.ClassesGenerate(classdefs)
    GBO_RevMag_ChangeMagazinesClasses()
end

function Rat_RevMag_changeDrumMagRPK74()
    local mag_larger = WeaponComponents["MagLarger"]
    if not mag_larger then
        return
    end

    for i, v in pairs(mag_larger.Visuals) do
        if v.ApplyTo == "AK47" then
            v.ApplyTo = "AK74"
            break
        end
    end

    local aksu_visu = PlaceObj('WeaponComponentVisual', {
        ApplyTo = "AKSU",
        Entity = "WeaponAttA_MagazineRPK74_03",
        Icon = "UI/Icons/Upgrades/RPK74_drum_magazine",
        Slot = "Magazine",
        param_bindings = false
    })

    table.insert_unique(mag_larger.Visuals, aksu_visu)

end

function Rat_RevMag_fixNormalMagRPK74()
    local mag = WeaponComponents["MagNormalFine"]
    if not mag then
        return
    end

    for i, v in pairs(mag.Visuals) do
        if v.ApplyTo == "RPK74" then
            v.Icon = 'UI/Icons/Upgrades/AK74_Bakelite_magazine'
            v.Entity = 'WeaponAttA_MagazineAK74_01'
            break
        end
    end
end

function Rat_RevMag_fixDefaultlMagG36()
    local mag = WeaponComponents["MagLarge"]
    if not mag then
        return
    end

    for i, v in pairs(mag.Visuals) do
        if v.ApplyTo == "G36" then
            v.Icon = 'UI/Icons/Upgrades/G36_magazine'
            v.Entity = 'WeaponAttA_MagazineHKG36_01'
            break
        end
    end
end

function GBO_ApplyRevMagCompatibility()
    if IsMod_loaded("URkxyfE") then
        Rat_RevMag_changeDrumMagRPK74()
        Rat_RevMag_fixNormalMagRPK74()
        Rat_RevMag_fixDefaultlMagG36()
    end
end

function OnMsg.ModsReloaded()
    GBO_ApplyRevMagCompatibility()
end

function OnMsg.DataLoaded()
    GBO_ApplyRevMagCompatibility()
end


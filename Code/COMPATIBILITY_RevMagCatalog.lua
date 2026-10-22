---- Revised Mags: one row per physical mag (gun -> Magazine component -> model). Capacity lives on the mag item.
---- The comment on each row is that mag item and its MagazineSize. Edit models here, not in _Master_Mag*.
GBO_RevMagCatalog = {
    AA12 = {
        MagNormal = {entity = "WeaponAttA_MagazineAA12_01", icon = "Mod/URkxyfE/magpictures/aa_12normal.png"}, -- AA12Magazine, 8
        MagLarge  = {entity = "WeaponAttA_MagazineAA12_02", icon = "UI/Icons/Upgrades/aa12_mag_drum"}, -- AA12MagazineLarge, 20
    },
    AK47 = {
        MagNormal = {entity = "WeaponAttA_MagazineAK47_01", icon = "UI/Icons/Upgrades/AK47_magazine"}, -- AK47Magazine, 30
        MagLarge  = {entity = "WeaponAttA_MagazineAK47_02", icon = "UI/Icons/Upgrades/expanded_AK47_magazine"}, -- AK47MagazineMagLarge, 45
        MagLarger = {entity = "WeaponAttA_MagazineRPK74_03", icon = "UI/Icons/Upgrades/RPK74_drum_magazine"}, -- AK47MagazineMagLarger, 75
    },
    AK74 = {
        MagNormalFine = {entity = "WeaponAttA_MagazineAK74_01", icon = "UI/Icons/Upgrades/AK74_Bakelite_magazine"}, -- AK74Magazine, 30
        MagLargeFine  = {entity = "WeaponAttA_MagazineAK74_02", icon = "UI/Icons/Upgrades/expanded_AK74_bakelite_magazine"}, -- AK74MagazineLarge, 45
    },
    AKSU = {
        MagNormalFine = {entity = "WeaponAttA_MagazineAKS74U_01", icon = "UI/Icons/Upgrades/AK74_Bakelite_magazine"}, -- AK74Magazine, 30
        MagLargeFine  = {entity = "WeaponAttA_MagazineAKS74U_02", icon = "UI/Icons/Upgrades/expanded_AK74_bakelite_magazine"}, -- AK74MagazineLarge, 45
    },
    AR15 = {
        MagNormal = {entity = "WeaponAttA_MagazineCAR15_02", icon = "Mod/URkxyfE/magpictures/m4_mag_normal.png"}, -- STANAGMagazine, 20
        MagLarge  = {entity = "WeaponAttA_MagazineM16_01", icon = "UI/Icons/Upgrades/m16_magazine"}, -- STANAGMagazineLarge, 30
    },
    AUG = {
        MagNormal = {entity = "WeaponAttA_MagazineSteyr_01", icon = "UI/Icons/Upgrades/steyr_AUG_magazine"}, -- AUGMagazine, 30
        MagLarge  = {entity = "WeaponAttA_MagazineSteyr_02", icon = "UI/Icons/Upgrades/expanded_steyr_AUG_magazine"}, -- AUGMagazineLarge, 42
    },
    BarretM82 = {
        MagNormal = {entity = "WeaponAttA_MagazineBarrettM82_01", icon = "Mod/URkxyfE/magpictures/M82_mag_normal.png"}, -- BarretM82Magazine, 5
        MagLarge  = {entity = "WeaponAttA_MagazineBarrettM82_02", icon = "Mod/URkxyfE/magpictures/M82_mag_large.png"}, -- BarretM82MagazineLarge, 10
    },
    Bereta92 = {
        MagNormal = {entity = "WeaponAttA_MagazineBeretta_01", icon = "UI/Icons/Upgrades/beretta_mag_normal"}, -- BerettaMagazine, 15
        MagLarge  = {entity = "WeaponAttA_MagazineBeretta_02", icon = "UI/Icons/Upgrades/beretta_mag_large"}, -- BerettaMagazineLarge, 24
    },
    DesertEagle = {
        MagNormal = {entity = "WeaponAttA_MagazineDesertEagle_01", icon = "UI/Icons/Upgrades/deserteagle_mag_normal"}, -- DesertEagleMagazine, 8
        MagLarge  = {entity = "WeaponAttA_MagazineDesertEagle_02", icon = "UI/Icons/Upgrades/desertEagle_mag_large"}, -- DesertEagleMagazineLarge, 13
    },
    DragunovSVD = {
        MagNormal = {entity = "WeaponAttA_MagazineDragunov_01", icon = "Mod/URkxyfE/magpictures/dragunov_mag_normal.png"}, -- SVDMagazine, 10
    },
    FAMAS = {
        MagNormal = {entity = "WeaponAttA_MagazineFAMAS", icon = "UI/Icons/Upgrades/expanded_FAMAS_magazine"}, -- FAMASMagazine, 25
    },
    FNFAL = {
        MagNormal = {entity = "WeaponAttA_MagazineFNFal_01", icon = "Mod/URkxyfE/magpictures/fnfal_normal.png"}, -- FNFALMagazine, 20
        MagLarge  = {entity = "WeaponAttA_MagazineFNFal_02", icon = "Mod/URkxyfE/magpictures/fnfal_expanded.png"}, -- FNFALMagazineLarge, 30
    },
    FNMinimi = {
        MagLarge  = {entity = "WeaponAttA_MagazineFNMinimi_01", icon = "UI/Icons/Upgrades/machine_gun_box_magazine"}, -- FNMinimiMagazineLarge, 100
        MagLarger = {entity = "WeaponAttA_MagazineFNMinimi_02", icon = "UI/Icons/Upgrades/fnminimi_mag_large"}, -- FNMinimiMagazineLarger, 150
    },
    G36 = {
        MagNormal = {entity = "WeaponAttA_MagazineHKG36_01", icon = "UI/Icons/Upgrades/G36_magazine"}, -- G36MagazineLarge, 30
        MagLarge  = {entity = "WeaponAttA_MagazineHKG36_01", icon = "UI/Icons/Upgrades/G36_magazine"}, -- saves from before the MagNormal switch
        MagQuick  = {entity = "WeaponAttA_MagazineHKG36_03", icon = "UI/Icons/Upgrades/quick_G36_magazine"}, -- G36MagazineQuick, 60
        MagLarger = {entity = "WeaponAttA_MagazineHKG36_02", icon = "UI/Icons/Upgrades/expanded_drum_G36_magazine"}, -- G36MagazineLarger, 100
    },
    Galil = {
        MagNormal = {entity = "WeaponAttA_MagazineGalil_01", icon = "Mod/URkxyfE/magpictures/galil_mag_normal.png"}, -- GalilMagazine, 25
        MagLarge  = {entity = "WeaponAttA_MagazineGalil_02", icon = "UI/Icons/Upgrades/galil_magazine_large"}, -- GalilMagazineLarge, 40
    },
    Galil_FlagHill = {
        MagNormal = {entity = "WeaponAttA_MagazineGalil_01", icon = "Mod/URkxyfE/magpictures/galil_mag_normal.png"}, -- GalilMagazine, 25
        MagLarge  = {entity = "WeaponAttA_MagazineGalil_02", icon = "UI/Icons/Upgrades/galil_magazine_large"}, -- GalilMagazineLarge, 40
    },
    Glock18 = {
        MagNormal = {entity = "WeaponAttA_MagazineGlock18_01", icon = "UI/Icons/Upgrades/glock_mag_normal"}, -- GlockMagazine, 15
        MagLarge  = {entity = "WeaponAttA_MagazineGlock18_02", icon = "UI/Icons/Upgrades/glock_mag_large"}, -- GlockMagazineLarge, 24
    },
    GoldenGun = {
        MagNormal = {entity = "WeaponAttA_MagazineM14_Standard", icon = "UI/Icons/Upgrades/M14_magazine"}, -- M14Magazine, 10
        MagLarge  = {entity = "WeaponAttA_MagazineM14_Extended", icon = "UI/Icons/Upgrades/expanded_M14_magazine"}, -- M14MagazineLarge, 20
    },
    HK21 = {
        MagLarge  = {entity = "WeaponAttA_MagazineHK21_01", icon = "Mod/URkxyfE/magpictures/g3_expanded.png"}, -- HKG3MagazineLarge, 20
        MagLarger = {entity = "WeaponAttA_MagazineHK21_02", icon = "UI/Icons/Upgrades/hk21_mag_large"}, -- HKG3MagazineLarger, 100
    },
    HiPower = {
        MagNormal = {entity = "WeaponAttA_MagazineBHP_01", icon = "UI/Icons/Upgrades/BHP_mag_normal"}, -- BHPMagazine, 13
        MagLarge  = {entity = "WeaponAttA_MagazineBHP_02", icon = "UI/Icons/Upgrades/BHP_mag_large"}, -- BHPMagazineLarge, 20
    },
    LionRoar = {
        MagNormal = {entity = "WeaponAttA_MagazineUzi_01", icon = "Mod/URkxyfE/magpictures/uzi_mag_normal.png"}, -- UZIMagazine, 25
        MagLarge  = {entity = "WeaponAttA_MagazineUzi_02", icon = "UI/Icons/Upgrades/uzi_mag_large"}, -- UZIMagazineLarge, 40
    },
    M14SAW = {
        MagNormal = {entity = "WeaponAttA_MagazineM14_Standard", icon = "UI/Icons/Upgrades/M14_magazine"}, -- M14Magazine, 10
        MagLarge  = {entity = "WeaponAttA_MagazineM14_Extended", icon = "UI/Icons/Upgrades/expanded_M14_magazine"}, -- M14MagazineLarge, 20
    },
    M14SAW_AUTO = {
        MagNormal = {entity = "WeaponAttA_MagazineM14_Standard", icon = "UI/Icons/Upgrades/M14_magazine"}, -- M14Magazine, 10
        MagLarge  = {entity = "WeaponAttA_MagazineM14_Extended", icon = "UI/Icons/Upgrades/expanded_M14_magazine"}, -- M14MagazineLarge, 20
    },
    M16A2 = {
        MagNormal = {entity = "WeaponAttA_MagazineCAR15_02", icon = "Mod/URkxyfE/magpictures/m4_mag_normal.png"}, -- STANAGMagazine, 20
        MagLarge  = {entity = "WeaponAttA_MagazineM16_01", icon = "UI/Icons/Upgrades/m16_magazine"}, -- STANAGMagazineLarge, 30
    },
    M24Sniper = {
        MagNormal = {entity = "WeaponAttA_MagazineM24_01"}, -- M24Sniper_Magazine, 5
        MagLarge  = {entity = "WeaponAttA_MagazineM24_02", icon = "UI/Icons/Upgrades/M14_magazine"}, -- M24Sniper_MagazineLarge, 8
    },
    M4Commando = {
        MagNormal = {entity = "WeaponAttA_MagazineCAR15_02", icon = "Mod/URkxyfE/magpictures/m4_mag_normal.png"}, -- STANAGMagazine, 20
        MagLarge  = {entity = "WeaponAttA_MagazineM16_01", icon = "UI/Icons/Upgrades/m16_magazine"}, -- STANAGMagazineLarge, 30
    },
    MP40 = {
        MagNormal = {entity = "WeaponAttA_MagazineMP40_01", icon = "Mod/URkxyfE/magpictures/MP40_mag_normal.png"}, -- MP40Magazine, 32
        MagLarge  = {entity = "WeaponAttA_MagazineMP40_02", icon = "UI/Icons/Upgrades/expanded_MP40_magazine"}, -- MP40MagazineLarge, 42
    },
    MP5 = {
        MagNormal = {entity = "WeaponAttA_MagazineMP5_01", icon = "UI/Icons/Upgrades/mp5_mag_normal"}, -- MP5Magazine, 15
        MagLarge  = {entity = "WeaponAttA_MagazineMP5_02", icon = "UI/Icons/Upgrades/mp5_mag_large"}, -- MP5MagazineLarge, 30
    },
    MP5K = {
        MagNormal = {entity = "WeaponAttA_MagazineMP5_01", icon = "UI/Icons/Upgrades/mp5_mag_normal"}, -- MP5Magazine, 15
        MagLarge  = {entity = "WeaponAttA_MagazineMP5_02", icon = "UI/Icons/Upgrades/mp5_mag_large"}, -- MP5MagazineLarge, 30
    },
    PSG1 = {
        MagNormal = {entity = "WeaponAttA_MagazinePSG_01", icon = "Mod/URkxyfE/magpictures/g3_normal.png"}, -- HKG3Magazine, 5
        MagLarge  = {entity = "WeaponAttA_MagazinePSG_02", icon = "Mod/URkxyfE/magpictures/g3_expanded.png"}, -- HKG3MagazineLarge, 20
    },
    RPK74 = {
        MagNormalFine = {entity = "WeaponAttA_MagazineAK74_01", icon = "UI/Icons/Upgrades/AK74_Bakelite_magazine"}, -- AK74Magazine, 30
        MagLargeFine  = {entity = "WeaponAttA_MagazineRPK74_01", icon = "UI/Icons/Upgrades/expanded_AK74_bakelite_magazine"}, -- AK74MagazineLarge, 45
    },
    UZI = {
        MagNormal = {entity = "WeaponAttA_MagazineUzi_01", icon = "Mod/URkxyfE/magpictures/uzi_mag_normal.png"}, -- UZIMagazine, 25
        MagLarge  = {entity = "WeaponAttA_MagazineUzi_02", icon = "UI/Icons/Upgrades/uzi_mag_large"}, -- UZIMagazineLarge, 40
    },
}

---- RatoGBOComponents swaps in the _Master_Mag* Visuals (GBO's no-RevMags meaning), so this runs after it
function GBO_RevMag_ApplyMagCatalog()
    if not IsMod_loaded("URkxyfE") then
        return
    end
    for gun, comps in pairs(GBO_RevMagCatalog) do
        for comp, row in pairs(comps) do
            local preset = WeaponComponents[comp]
            if preset then
                ---- copy: in-place edits would reach the _Master_ or Revised Mags list and the editor saves them back
                local visuals = table.icopy(preset.Visuals or empty_table)
                for i = #visuals, 1, -1 do
                    if visuals[i].ApplyTo == gun and (visuals[i].Slot or "Magazine") == "Magazine" then
                        table.remove(visuals, i)
                    end
                end
                visuals[#visuals + 1] = PlaceObj('WeaponComponentVisual', {
                    ApplyTo = gun,
                    Entity = row.entity,
                    Icon = row.icon,
                    Slot = "Magazine",
                    param_bindings = false,
                })
                preset.Visuals = visuals
            else
                print("GBO RevMag catalog: missing component", comp, "for", gun)
            end
        end
    end
end

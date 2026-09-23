---- Scopes and side devices as physical inventory items: attaching one spends the item from the
---- squad, detaching gives it back. The component system itself is untouched -- only the cost the
---- modify screen asks for changes, so nothing here can desync a weapon that is already built.
----
---- RAT_ATT_ITEMS is static on purpose: savegames store item class names, so the list of classes
---- must not depend on which mods happen to be loaded. The component -> item binding IS dynamic
---- and is rebuilt every load: another component id for the same optic (a ToG variant, an
---- _rpk_mount clone, a _Master_ template) binds by display name with no edit here.
----
---- reserved = true means the optic only reaches weapons that are neither vanilla nor
---- is_tog_patched, so it stays a plain weapon mod until that gun is patched. The class and the
---- preset are still built, so clearing the flag later needs no save migration. Rat_AttAudit()
---- recomputes the reachability from the live data and reports flags that no longer match.

RAT_ATT_ENABLED = true

---- Which component slots turn into items. Side2 and Side3 are ToG's second and third rail
---- positions: AR10std, HK33A2 and HK53 offer the same flashlight and dots there under _2 ids, and
---- leaving the slot out made those three devices free on exactly those guns.
---- Bipod and Muzzle joined later. A bipod slot that cannot be emptied and offers one component is
---- welded on, and the bayonet slots are a fold/unfold toggle of one object, so neither becomes an
---- item; both fall out of the deny rules below rather than needing a slot test.
RAT_ATT_SLOTS = {
    Scope = true,
    Side = true,
    Side2 = true,
    Side3 = true,
    Bipod = true,
    Muzzle = true
}

---- Fitting an optic you already own is the same job whatever the optic is: one skill gate, one
---- parts bill. Applied by hooking the two readers, never by writing to the component presets --
---- the editor saves live preset values back into whichever mod owns them.
RAT_ATT_DIFFICULTY = -10 -- Easy, per const.WeaponModDifficultyPresets
RAT_ATT_PARTS = 5
RAT_ATT_OLD = {} -- component id -> {cost, difficulty} the preset still declares

---- Revised Gear reads Weight and <Slot>_amount off the item; both default to nothing useful for a
---- new class (amount 0 means "fits no pocket"), so every item declares a size.
RAT_ATT_SIZES = {
    small = {Weight = 200, PocketS = 2, PocketM = 3, PocketML = 4, PocketL = 6},
    medium = {Weight = 450, PocketM = 1, PocketML = 2, PocketL = 3},
    large = {Weight = 800, PocketML = 1, PocketL = 2}
}

---- Parts back from scrapping, by size; a def's `scrap` field overrides. Kept well under
---- RAT_ATT_PARTS so buying and scrapping never beats the fitting bill. Halved below 50 condition.
RAT_ATT_SCRAP = {small = 1, medium = 2, large = 3}

---- Iron sights, rails and blank shafts stay free -- they are what a gun wears when it wears nothing.
RAT_ATT_DENY_NAMES = {
    ["Default Iron Sight"] = true,
    ["Default Ironsight"] = true,
    ["Basic Iron Sight"] = true,
    ["Ironsight"] = true,
    ["Improved Iron Sight"] = true,
    ["Improved Ironsight"] = true,
    ["Custom Rail"] = true,
    ["Picatinny Rail"] = true,
    ["Top Rail"] = true,
    ["G11 Rail"] = true,
    ["Blank Shaft"] = true,
    ["No Scope"] = true,
    ["CAWS Ironsight"] = true,
    ["Empty"] = true, -- what a Side2/Side3 rail wears when it wears nothing
    ["Default Muzzle"] = true,
    ["Default Flash Hider"] = true,
    ["Default Muzzle Brake"] = true,
    ["Default Compensator"] = true,
    ["Improvised Suppressor"] = true, -- the fallback you can always make out of parts, by design
    ["Integral Suppressor"] = true, -- built into the barrel: VSK-94, De Lisle, Steyr Scout
    ["grenade"] = true, -- the 22mm rifle grenade rides the muzzle but is ammunition
    ["Gatling-style rotating six-barrel assembly"] = true
}

---- Matched as substrings, for families the data names one way per weapon. A bayonet slot only ever
---- flips between folded and unfolded, so charging for it would make you buy your own bayonet back.
---- A deployed bipod is the same bipod: the slot flips between the two and never empties, so
---- charging would hand back an item every time a gunner put the legs down.
RAT_ATT_DENY_PATTERNS = {"Bayonet", "Fold Bipod", "Unfold Bipod"}

---- Identity overrides, for components whose display name lies about what they are. The value is
---- the item name to group under, so an unknown id falls back to the right item too.
---- The pistol reflexes carry the WeaponAttA_ScopeGlock18 model, a small unit that does not fit a
---- rifle rail, while their name is the same as the full size one.
RAT_ATT_RENAME = {
    Caws_Scope_1 = "CAWS Scope", -- a 40-part scope shipped under the ironsight's name
    ReflexSightAdvanced_Glock = "\"Assalto\" Reflex Sight 1x (Pistol)",
    RAT_TOG_Reflex_pistol = "\"Assalto\" Reflex Sight 1x (Pistol)",
    RAT_TOG_Reflex_pistol_rpk_mount = "\"Assalto\" Reflex Sight 1x (Pistol)",
    SteyrS_Muzzle_def_1 = "Integral Suppressor",
    RAT_VSK_Suppressor = "Integral Suppressor"
}

---- Muzzle devices bind by family, not by component id: every compensator id resolves to one item
---- per gun, and so does every suppressor id. A real device needs the bore AND the mount, so a
---- calibre item covers the threaded platforms and a platform item (guns) covers the devices made
---- for one gun -- pistol comps, clamp-on HK hiders, the M14's gas-lock mount.
RAT_ATT_FAMILIES = {
    compensator = {"Compensator", "G3A3_muzzle_1", "LionRoar_compensator", "RAT_TOG_CompensatorNoEntity",
                   "RAT_TOG_compensator", "RK62_Muzzle_def_1", "RK95_Muzzle_def_1", "hk23e_muzzle_1",
                   "hk33_muzzle_1", "AUGCompensator_03", "Compensator_Glock"},
    booster = {"MuzzleBooster"},
    suppressor = {"Suppressor", "RAT_TOG_suppressor", "RAT_TOG_suppressor_762", "RAT_TOG_suppressor_wp",
                  "Suppressor_Anaconda", "ToG_Shotgun_Silencer"}
}
---- Any other muzzle component with one of these display names joins the family too, the way the
---- optics bind by name: ToG ships a new id per gun (L85, M60, FN2000) for the same device.
RAT_ATT_FAMILY_NAMES = {
    ["Compensator"] = "compensator",
    ["Recoil Booster"] = "booster",
    ["Suppressor"] = "suppressor"
}

---- id: item class, frozen. comps: the ids known when this was generated; name binds the rest.
RAT_ATT_ITEMS = {
    {
        id = "RAT_Att_AWPScope",
        name = "AWP Scope",
        icon = "Mod/KKh3Yhf/Images/AWP_Scope_icon.png",
        size = "large",
        cost = 4000,
        tier = 3,
        reserved = true,
        comps = {"AWP_Scope_1"}
    },
    {
        id = "RAT_Att_AssaltoReflexSight1x",
        name = "\"Assalto\" Reflex Sight 1x",
        icon = "UI/Icons/Upgrades/scope_reflex",
        size = "medium",
        cost = 3000,
        tier = 2,
        comps = {"RAT_TOG_Reflex", "RAT_TOG_Reflex_rpk_mount", "ReflexSightAdvanced"}
    },
    {
        id = "RAT_Att_AssaltoReflexSight1xPistol",
        name = "\"Assalto\" Reflex Sight 1x (Pistol)",
        icon = "Mod/cfahRED/Images/glockRS.png",--UI/Icons/Upgrades/scope_reflex",
        size = "small",
        cost = 2000,
        tier = 1,
        comps = {"RAT_TOG_Reflex_pistol", "RAT_TOG_Reflex_pistol_rpk_mount", "ReflexSightAdvanced_Glock"}
    },
    {
        id = "RAT_Att_AutomagScope",
        name = "Automag Scope",
        icon = "Mod/KKh3Yhf/Images/Automag_Scope_icon.png",
        size = "large",
        cost = 2500,
        tier = 2,
        reserved = true,
        comps = {"Automag_Scope_1"}
    },
    {
        id = "RAT_Att_CAWSScope",
        name = "CAWS Scope",
        icon = "Mod/KKh3Yhf/Images/CAWS_Scope_icon.png",
        size = "large",
        cost = 4000,
        tier = 3,
        reserved = true,
        comps = {"Caws_Scope_1"}
    },
    {
        id = "RAT_Att_CompactReflexSight1x",
        name = "Compact Reflex Sight 1x",
        icon = "UI/Icons/Upgrades/compact_reflex_sight",
        size = "small",
        cost = 2000,
        tier = 1,
        comps = {"RAT_TOG_compactRS", "RAT_TOG_compactRS_rpk_mount", "ReflexSight"}
    },
    {
        id = "RAT_Att_CrossfireIIx4",
        name = "Crossfire II x4",
        icon = "Mod/KKh3Yhf/Images/SteyrScout_Scope.png",
        size = "large",
        cost = 3500,
        tier = 2,
        comps = {"SteyrS_Scope_1", "_Master_SteyrS_Scope_TOG"}
    },
    {
        id = "RAT_Att_DigitalScope2x",
        name = "Digital Scope 2x",
        icon = "UI/Icons/Upgrades/g36_scope_01", -- the component's own icon is the generic one; the G36 art is on its visual
        size = "medium",
        cost = 3000,
        tier = 2,
        comps = {"G36_SCOPE"}
    },
    {
        id = "RAT_Att_DigitalScope4x2x",
        name = "Digital Scope 4x/2x",
        icon = "UI/Icons/Upgrades/g36_scope_02", -- the component's own icon is the generic one; the G36 art is on its visual
        size = "large",
        cost = 5000,
        tier = 3,
        comps = {"SCOPE_G36_2"}
    },
    {
        id = "RAT_Att_Flashlight",
        name = "Flashlight",
        icon = "UI/Icons/Upgrades/side_light",
        size = "small",
        cost = 1000,
        tier = 1,
        comps = {"Flashlight", "Flashlight_Anaconda", "Flashlight_PSG_M1", "Flashlight_aa12", "RAT_TOG_flashlight", "RAT_TOG_flashlight_rpk_mount", "ToG_Flashlight_1"}
    },
    {
        id = "RAT_Att_G11ZieloptikZO1",
        name = "G11 Zieloptik ZO-1",
        icon = "Mod/KKh3Yhf/Images/G11_Scope_icon.png",
        size = "medium",
        cost = 5000,
        tier = 3,
        comps = {"G11_Scope_1"}
    },
    {
        id = "RAT_Att_HensoldtZFScope6x",
        name = "Hensoldt ZF Scope 6x",
        icon = "UI/Icons/Upgrades/custom_PSG1_scope",
        size = "large",
        cost = 5000,
        tier = 3,
        comps = {"PSG_DefaultScope", "RAT_TOG_PSGScope", "RAT_TOG_PSGScope_rpk_mount"}
    },
    {
        id = "RAT_Att_PSO1M21Scope4x",
        name = "PSO-1M2-1 Scope 4x",
        icon = "Mod/KKh3Yhf/Images/VSS_Scope_icon.png",
        size = "large",
        cost = 3500,
        tier = 2,
        comps = {"VSS_Scope_1", "_Master_PSO-1M2_Scope_TOG"}
    },
    {
        id = "RAT_Att_PSO1Scope4x",
        name = "PSO-1 Scope 4x",
        icon = "UI/Icons/Upgrades/custom_Dragunov_scope",
        size = "large",
        cost = 4000,
        tier = 2,
        comps = {"LROptics_DragunovDefault"}
    },
    {
        id = "RAT_Att_PrismScope2x",
        name = "Prism Scope 2x",
        icon = "UI/Icons/Upgrades/prism_scope",
        size = "medium",
        cost = 2500,
        tier = 2,
        comps = {"RAT_TOG_Prism", "RAT_TOG_Prism_rpk_mount", "ScopeCOG"}
    },
    {
        id = "RAT_Att_QuickPrismScope2x",
        name = "Quick Prism Scope 2x",
        icon = "UI/Icons/Upgrades/scope_thermal",
        size = "medium",
        cost = 2500,
        tier = 2,
        comps = {"RAT_TOG_ACOG", "RAT_TOG_ACOG_rpk_mount", "ScopeCOGQuick"}
    },
    {
        id = "RAT_Att_RedDot",
        name = "Red Dot",
        icon = "UI/Icons/Upgrades/side_laser", -- 7 of the 8 use this; MK23_laser_1 brings its own
        size = "small",
        cost = 1500,
        tier = 2,
        comps = {"LaserDot", "LaserDot_Anaconda", "LaserDot_PSG_M1", "LaserDot_aa12", "MK23_laser_1", "RAT_TOG_laser_dot", "RAT_TOG_laser_dot_rpk_mount", "ToG_Red_Dot_1"}
    },
    {
        id = "RAT_Att_ReflexSight",
        name = "Reflex Sight",
        icon = "Mod/KKh3Yhf/Images/MP7_reddot.png",
        size = "medium",
        cost = 3500,
        tier = 2,
        comps = {"MP7_Scope_1", "TAR21_Scope_Rflx_1"}
    },
    {
        id = "RAT_Att_SniperScope4x",
        name = "Sniper Scope 4x",
        icon = "UI/Icons/Upgrades/scope_longrange",
        size = "large",
        cost = 3000,
        tier = 2,
        comps = {"LROptics", "RAT_TOG_LRoptics", "RAT_TOG_LRoptics_rpk_mount"}
    },
    {
        id = "RAT_Att_SniperScope6x",
        name = "Sniper Scope 6x",
        icon = "UI/Icons/Upgrades/sniper_scope_x10",
        size = "large",
        cost = 4000,
        tier = 3,
        comps = {"LROpticsAdvanced", "RAT_TOG_LRoptics_advanced", "RAT_TOG_LRoptics_advanced_rpk_mount"}
    },
    {
        id = "RAT_Att_SniperScopex5",
        name = "Sniper Scope x5",
        icon = "UI/Icons/Upgrades/custom_Dragunov_scope",
        size = "large",
        cost = 2000,
        tier = 2,
        reserved = true,
        comps = {"AN94_Scope_1", "SKS_Scope"}
    },
    {
        id = "RAT_Att_SniperScopex8",
        name = "Sniper Scope x8",
        icon = "Mod/KKh3Yhf/Images/NTW20_scope.png",
        size = "large",
        cost = 3500,
        tier = 3,
        reserved = true,
        comps = {"NTW_20_Scope_1"}
    },
    {
        id = "RAT_Att_SwarovskiOptikScope15x",
        name = "Swarovski Optik Scope 1.5x",
        icon = "UI/Icons/Upgrades/custom_Steyr_AUG_scope",
        size = "medium",
        cost = 2000,
        tier = 1,
        comps = {"AUGScope_Default"}
    },
    {
        id = "RAT_Att_TacticalDevice",
        name = "Tactical Device",
        icon = "UI/Icons/Upgrades/side_laserlight",
        size = "small",
        cost = 2000,
        tier = 2,
        comps = {"FlashlightDot", "FlashlightDot_Anaconda", "FlashlightDot_PSG_M1", "FlashlightDot_aa12", "RAT_TOG_tactical_dot", "RAT_TOG_tactical_dot_rpk_mount"}
    },
    {
        id = "RAT_Att_ThermalScope4x",
        name = "Thermal Scope 4x",
        icon = "UI/Icons/Upgrades/scope_ACOG",
        size = "large",
        cost = 6000,
        tier = 3,
        comps = {"RAT_TOG_thermal", "RAT_TOG_thermal_rpk_mount", "ThermalScope", "ThermalScope_1", "ThermalScope_2"}
    },
    {
        id = "RAT_Att_UVDot",
        name = "UV Dot",
        icon = "UI/Icons/Upgrades/side_laser",
        size = "small",
        cost = 1500,
        tier = 2,
        comps = {"RAT_TOG_uv_dot", "RAT_TOG_uv_dot_rpk_mount", "ToG_UV_Dot_1", "UVDot", "UVDot_Anaconda", "UVDot_PSG_M1", "UVDot_aa12"}
    },
    {
        id = "RAT_Att_VigilanteReflexSight1x",
        name = "\"Vigilante\" Reflex Sight 1x",
        icon = "Mod/KQkEVHf/Icons/Upgrades/ToC_Scope_kentaur.png",
        size = "medium",
        cost = 3000,
        tier = 2,
        comps = {"RAT_TOG_vigilanceRS", "RAT_TOG_vigilanceRS_rpk_mount", "_ReflexSIghtVigilance"}
    },
    {
        id = "RAT_Att_VultoWideScope2x",
        name = "\"Vulto\" Wide Scope 2x",
        icon = "Mod/KKh3Yhf/Images/L85A1_scope.png",
        size = "medium",
        cost = 2500,
        tier = 2,
        comps = {"RAT_TOG_WideScope", "RAT_TOG_WideScope_rpk_mount", "WideScope"}
    },
    {
        id = "RAT_Att_WA2000Scope",
        name = "WA2000 Scope",
        icon = "Mod/KKh3Yhf/Images/WA2000_Scope_icon_1.png",
        size = "large",
        cost = 2000,
        tier = 3,
        reserved = true,
        comps = {"WA2000_Scope_1"}
    },
    {
        id = "RAT_Att_ZF4Scopex15",
        name = "ZF-4 Scope x1.5",
        icon = "Mod/KKh3Yhf/Images/G43_Scope_icon.png",
        size = "medium",
        cost = 1500,
        tier = 1,
        comps = {"GW43_Scope_1", "_Master_GW43_Scope_TOG"}
    },
    {
        id = "RAT_Att_ZF846x",
        name = "ZF 84 6x",
        icon = "Mod/KKh3Yhf/Images/SSG69_Scope_icon.png",
        size = "large",
        cost = 2000,
        tier = 3,
        comps = {"SSG69_Scope_1", "_Master_SSG69_Scope_TOG"}
    },
    {
        id = "RAT_Att_ZRAKx4Scope",
        name = "ZRAK x4 Scope",
        icon = "Mod/KKh3Yhf/Images/M76_scope.png",
        size = "large",
        cost = 2000,
        tier = 2,
        comps = {"_Master_m76_scope_TOG", "m76_scope_1"}
    },
    {
        id = "RAT_Att_Bipod",
        name = "Bipod",
        icon = "UI/Icons/Upgrades/ak47_bipod",
        size = "large",
        cost = 1500,
        tier = 1,
        comps = {"AN94_Bip_def_1", "Bipod", "Bipod_MG42", "Bipod_m82", "G11_Bipod_1", "ToG_Bipod_1", "U100_bipod_fld_1"}
    },
    ---- Compensators by calibre. model is what the gun wears, whatever its own Visuals say.
    {
        id = "RAT_Att_Compensator",
        name = "Compensator (5.56 NATO)",
        icon = "UI/Icons/Upgrades/m16_muzzle",
        size = "small",
        cost = 1500,
        tier = 1,
        family = "compensator",
        calibers = {"556", "5_7x28", "4_7x33"},
        model = "WeaponAttA_Muzzle_01"
    },
    {
        id = "RAT_Att_Compensator762",
        name = "Compensator (7.62 NATO)",
        icon = "UI/Icons/Upgrades/muzzle_fal_01",
        size = "small",
        cost = 1500,
        tier = 1,
        family = "compensator",
        calibers = {"762NATO", "308Win", "30-60"},
        model = "WeaponAttA_MuzzleFNFal"
    },
    {
        id = "RAT_Att_CompensatorAK",
        name = "Compensator (7.62x39)",
        icon = "UI/Icons/Upgrades/AK_compensator",
        size = "small",
        cost = 1500,
        tier = 1,
        family = "compensator",
        calibers = {"762WP"},
        model = "WeaponAttA_CompensatorWP"
    },
    {
        id = "RAT_Att_CompensatorAK74",
        name = "Compensator (5.45x39)",
        icon = "Mod/cfahRED/Images/545_comp.png",
        size = "small",
        cost = 1500,
        tier = 1,
        family = "compensator",
        calibers = {"5_45x39"},
        model = "WeaponAttA_MuzzleAK74"
    },
    {
        id = "RAT_Att_Compensator54R",
        name = "Compensator (7.62x54R)",
        icon = "Mod/cfahRED/Images/76254r_comp.png",
        size = "small",
        cost = 2000,
        tier = 2,
        family = "compensator",
        calibers = {"7_62x54R"},
        model = "WeaponAttA_MuzzleDragunov_01"
    },
    {
        id = "RAT_Att_CompensatorMauser",
        name = "Compensator (7.92 Mauser)",
        icon = "UI/Icons/Upgrades/muzzle_fal_01",
        size = "small",
        cost = 2000,
        tier = 1,
        family = "compensator",
        calibers = {"7_92x57", "7_92x33"},
        model = "WeaponAttA_MuzzleDragunov_01"
    },
    {
        id = "RAT_Att_Compensator9mm",
        name = "Compensator (9mm)",
        icon = "UI/Icons/Upgrades/MP5_compensator",
        size = "small",
        cost = 1500,
        tier = 1,
        family = "compensator",
        calibers = {"9mm", "380ACP", "9x18", "9x39"},
        model = "WeaponAttA_CompensatorMP5"
    },
    {
        id = "RAT_Att_Compensator45",
        name = "Compensator (.45 ACP)",
--TODO: Proper Icon
        icon = "UI/Icons/Upgrades/MP5_compensator",
        size = "small",
        cost = 1500,
        tier = 1,
        family = "compensator",
        calibers = {"45ACP"},
        model = "WeaponAttA_CompensatorHKG36_02"
    },
    {
        id = "RAT_Att_CompensatorShotgun",
        name = "Compensator (12 gauge)",
        icon = "UI/Icons/Upgrades/shotgun_compensator",
        size = "small",
        cost = 1500,
        tier = 1,
        family = "compensator",
        calibers = {"12gauge"},
        model = "WeaponAttA_CompensatorM4"
    },
    ---- Compensators made for one platform. No model keeps the gun's own; one here overrides it.
    {
        id = "RAT_Att_CompensatorHiPower",
        name = "Compensator (Hi-Power)",
        icon = "Mod/cfahRED/Images/hipower_comp.png",
        size = "small",
        cost = 2000,
        tier = 2,
        family = "compensator",
        guns = {"HiPower"}
    },
    --{
    --    id = "RAT_Att_CompensatorM1911",
    --    name = "Compensator (M1911)",
    --    icon = "UI/Icons/Upgrades/glock_compensator",
    --    size = "small",
    --    cost = 2000,
    --    tier = 2,
    --    family = "compensator",
    --    guns = {"M1911_1"},
    --    model = "WeaponAttA_CompensatorBHP"
    --},
    --{
    --    id = "RAT_Att_CompensatorP08",
    --    name = "Compensator (P08)",
    --    icon = "UI/Icons/Upgrades/glock_compensator",
    --    size = "small",
    --    cost = 2000,
    --    tier = 2,
    --    family = "compensator",
    --    guns = {"P08_1"},
    --    model = "WeaponAttA_CompensatorBHP"
    --},
    {
        id = "RAT_Att_AdvancedCompensator",
        name = "Compensator (Glock)",
        icon = "UI/Icons/Upgrades/glock_compensator",
        size = "small",
        cost = 3000,
        tier = 2,
        family = "compensator",
        guns = {"Glock17_1", "Glock18"}
    },
    {
        id = "RAT_Att_CompensatorAUG",
        name = "Compensator (AUG)",
        icon = "UI/Icons/Upgrades/muzzle_steyr_01",
        size = "small",
        cost = 3000,
        tier = 2,
        family = "compensator",
        guns = {"AUG"}
    },
    {
        id = "RAT_Att_CompensatorHK762",
        name = "Flash Hider (HK G3)",
        icon = "Mod/KKh3Yhf/Images/G3A3_muzzle_def.png",
        size = "small",
        cost = 2000,
        tier = 2,
        family = "compensator",
        guns = {"G3A3_1", "G3A3Green_1", "HK21"},
        model = "G3A3_muzzle"
    },
    {
        id = "RAT_Att_CompensatorHK556",
        name = "Flash Hider (HK33)",
        icon = "Mod/KKh3Yhf/Images/HK33_muzzle_def.png",
        size = "small",
        cost = 2000,
        tier = 2,
        family = "compensator",
        guns = {"HK33A2_1", "HK53_1", "HK23E_1", "HK23ECamo_1"}
    },
    {
        id = "RAT_Att_CompensatorM14",
        name = "Compensator (M14)",
        icon = "UI/Icons/Upgrades/muzzle_fal_01",
        size = "small",
        cost = 2000,
        tier = 2,
        family = "compensator",
        guns = {"M14SAW", "M14SAW_AUTO"}
    },
    {
        id = "RAT_Att_CompensatorBarrett",
        name = "Muzzle Brake (Barrett)",
        icon = "UI/Icons/Upgrades/m16_muzzle",
        size = "medium",
        cost = 3000,
        tier = 3,
        family = "compensator",
        guns = {"BarretM82"}
    },
    ---- Recoil boosters thread on like a compensator: NATO and AK patterns, and the M14's own.
    {
        id = "RAT_Att_RecoilBooster",
        name = "Recoil Booster (NATO)",
        icon = "UI/Icons/Upgrades/booster_NATO",
        size = "small",
        cost = 2500,
        tier = 2,
        family = "booster",
        calibers = {"556", "762NATO", "308Win", "45ACP", "9x18"},
        model = "WeaponAttA_BoosterNATO"
    },
    {
        id = "RAT_Att_RecoilBoosterAK",
        name = "Recoil Booster (AK)",
        icon = "UI/Icons/Upgrades/AK_muzzle_booster",
        size = "small",
        cost = 2500,
        tier = 2,
        family = "booster",
        calibers = {"762WP", "5_45x39"},
        model = "WeaponAttA_BoosterWP"
    },
    {
        id = "RAT_Att_RecoilBoosterM14",
        name = "Recoil Booster (M14)",
        icon = "UI/Icons/Upgrades/AR_muzzle_booster",
        size = "small",
        cost = 2500,
        tier = 2,
        family = "booster",
        guns = {"M14SAW", "M14SAW_AUTO"},
        model = "WeaponAttA_BoosterM14"
    },
    {
        id = "RAT_Att_DuckbillChoke",
        name = "Duckbill Choke",
        icon = "UI/Icons/Upgrades/duckbill_choke",
        size = "small",
        cost = 1200,
        tier = 1,
        comps = {"DuckbillChoke"}
    },
    {
        id = "RAT_Att_FullChoke",
        name = "Full Choke",
        icon = "UI/Icons/Upgrades/shotgun_full_choke",
        size = "small",
        cost = 1200,
        tier = 1,
        comps = {"FullChoke"}
    },
    ---- Suppressors by bore. types splits a calibre where a pistol can and a long gun can differ.
    {
        id = "RAT_Att_SuppressorPistol",
        name = "Suppressor (9mm Pistol)",
        icon = "UI/Icons/Upgrades/beretta_silencer",
        size = "medium",
        cost = 3000,
        tier = 1,
        family = "suppressor",
        calibers = {"9mm", "380ACP", "9x18"},
        types = {"Handgun"},
        model = "WeaponAttA_SilencerBeretta"
    },
    {
        id = "RAT_Att_SuppressorSMG9mm",
        name = "Suppressor (9mm SMG)",
        icon = "UI/Icons/Upgrades/9mm_SMG_suppressor",
        size = "large",
        cost = 3500,
        tier = 2,
        family = "suppressor",
        calibers = {"9mm", "380ACP", "9x18"},
        model = "WeaponAttA_SuppressorSMG9mm"
    },
    {
--TODO: Change to only Desert Eagle
        id = "RAT_Att_SuppressorDesertEagle",
        name = "Suppressor (.44 Pistol)",
        icon = "UI/Icons/Upgrades/deserteagle_suppressor",
        size = "medium",
        cost = 4000,
        tier = 3,
        family = "suppressor",
        calibers = {"44CAL"},
        types = {"Handgun"},
        model = "WeaponAttA_SilencerDesertEagle"
    },
    {
        id = "RAT_Att_Suppressor45SMG",
        name = "Suppressor (.45 ACP)",
        icon = "UI/Icons/Upgrades/9mm_SMG_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        family = "suppressor",
        calibers = {"45ACP"},
        types = {"SMG", "Handgun"},
        model = "WeaponAttA_SuppressorSMG9mm"
    },
    {
        id = "RAT_Att_Suppressor44Rifle",
        name = "Suppressor (.44 Rifle)",
        icon = "UI/Icons/Upgrades/762_suppressor",
        size = "large",
        cost = 4000,
        tier = 3,
        family = "suppressor",
        calibers = {"44CAL"},
        model = "WeaponAttA_Suppressor762"
    },
    {
        id = "RAT_Att_Suppressor556",
        name = "Suppressor (5.56 NATO)",
        icon = "UI/Icons/Upgrades/556_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        family = "suppressor",
        calibers = {"556", "5_7x28", "4_7x33"},
        model = "WeaponAttA_SuppressorNATO"
    },
    {
        id = "RAT_Att_Suppressor762",
        name = "Suppressor (7.62 NATO)",
        icon = "UI/Icons/Upgrades/762_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        family = "suppressor",
        calibers = {"762NATO", "308Win", "30-60"},
        model = "WeaponAttA_Suppressor762"
    },
    {
        id = "RAT_Att_SuppressorWP",
        name = "Suppressor (7.62x39)",
        icon = "UI/Icons/Upgrades/AK_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        family = "suppressor",
        calibers = {"762WP"},
        model = "WeaponAttA_SuppressorWP"
    },
    {
        id = "RAT_Att_Suppressor545",
        name = "Suppressor (5.45x39)",
        icon = "UI/Icons/Upgrades/AK_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        family = "suppressor",
        calibers = {"5_45x39"},
        model = "WeaponAttA_SuppressorWP"
    },
    {
        id = "RAT_Att_Suppressor54R",
        name = "Suppressor (7.62x54R)",
        icon = "UI/Icons/Upgrades/AK_suppressor",
        size = "large",
        cost = 4500,
        tier = 3,
        family = "suppressor",
        calibers = {"7_62x54R"},
        model = "WeaponAttA_SuppressorWP"
    },
    {
--TODO: Remove or find a model? 
        id = "RAT_Att_SuppressorMauser",
        name = "Suppressor (7.92 Mauser)",
        icon = "UI/Icons/Upgrades/762_suppressor",
        size = "large",
        cost = 4500,
        tier = 3,
        family = "suppressor",
        calibers = {"7_92x57"},
        model = "WeaponAttA_Suppressor762"
    },
    {
        id = "RAT_Att_Suppressor9x39",
        name = "Suppressor (9x39)",
        icon = "UI/Icons/Upgrades/AK_suppressor",
        size = "large",
        cost = 4500,
        tier = 3,
        family = "suppressor",
        calibers = {"9x39"},
        model = "WeaponAttA_SuppressorWP"
    },
    {
        id = "RAT_Att_Suppressor50",
        name = "Suppressor (.50 BMG)",
        icon = "UI/Icons/Upgrades/M82_suppressor",
        size = "large",
        cost = 6000,
        tier = 3,
        family = "suppressor",
        calibers = {"50BMG"},
        model = "WeaponAttA_SuppressorBarrettM82"
    },
    {
        id = "RAT_Att_SuppressorShotgun",
        name = "Suppressor (12 gauge)",
        icon = "UI/Icons/Upgrades/shotgun_suppressor",
        size = "large",
        cost = 4500,
        tier = 3,
        family = "suppressor",
        calibers = {"12gauge"},
        model = "WeaponAttA_SuppressorShotgun"
    },
    ---- the FN2000 and MP7 cans are components of their own, on guns not patched yet
    {
        id = "RAT_Att_SuppressorFN2000",
        name = "Suppressor (FN2000)",
        icon = "UI/Icons/Upgrades/556_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        reserved = true,
        comps = {"FN2000_silencer_1"}
    },
    {
        id = "RAT_Att_SuppressorMP7",
        name = "Suppressor (MP7)",
        icon = "UI/Icons/Upgrades/9mm_SMG_suppressor",
        size = "medium",
        cost = 3500,
        tier = 2,
        reserved = true,
        comps = {"MP7_Supr_1"}
    }
}

RAT_ATT_ITEM_OF = {} -- component id -> item class
RAT_ATT_FAMILY_OF = {} -- component id -> family name
RAT_ATT_FAM_GUN = {} -- family -> weapon class -> item def
RAT_ATT_FAM_CAL = {} -- family -> caliber -> item defs
RAT_ATT_UNBOUND = {} -- report only: optics in a covered slot that got no item

---- The item classes. DefineClass is gone by the time the game runs, so this only executes on a
---- real load; a hot reload of this file skips it and keeps the classes already built.
if DefineClass then
    for _, def in ipairs(RAT_ATT_ITEMS) do
        local class = {
            __parents = {"MiscItem"},
            object_class = "MiscItem",
            Icon = def.icon,
            DisplayName = Untranslated(def.name),
            DisplayNamePlural = Untranslated(def.name),
            AdditionalHint = Untranslated(
                "<bullet_point> Weapon attachment. Install it from the weapon modification screen."),
            Cost = def.cost,
            MaxStacks = 5
        }
        for k, v in pairs(RAT_ATT_SIZES[def.size]) do
            class[k == "Weight" and k or (k .. "_amount")] = v
        end
        DefineClass(def.id, class)
    end
end

local function comp_name(id, comp)
    if RAT_ATT_RENAME[id] then
        return RAT_ATT_RENAME[id]
    end
    return _InternalTranslate(comp.DisplayName or Untranslated(""))
end

local function comp_denied(name)
    if RAT_ATT_DENY_NAMES[name] then
        return true
    end
    for _, pattern in ipairs(RAT_ATT_DENY_PATTERNS) do
        if string.find(name, pattern, 1, true) then
            return true
        end
    end
end

---- The family item for this gun: a platform item naming the class wins, then a calibre item whose
---- types admit the weapon type, then an untyped one. nil leaves the device free.
function Rat_AttFamilyDef(family, weapon)
    local gun = RAT_ATT_FAM_GUN[family][weapon.class]
    if gun then
        return gun
    end
    local fallback
    for _, def in ipairs(RAT_ATT_FAM_CAL[family][weapon.Caliber or ""] or empty_table) do
        if not def.types then
            fallback = fallback or def
        elseif table.find(def.types, weapon.WeaponType) then
            return def
        end
    end
    return fallback
end

---- The item a component costs on this weapon. Only the families need the weapon; for everything
---- else the component alone decides, which is the cheap path and the common one.
function Rat_AttItemFor(cid, weapon)
    local family = RAT_ATT_FAMILY_OF[cid]
    if not family then
        return RAT_ATT_ITEM_OF[cid]
    end
    local def = weapon and Rat_AttFamilyDef(family, weapon)
    return def and def.id
end

---- The gun wears its item's model, not whatever the component's Visuals picked for it. A factory
---- default keeps its own look: that is the gun as it ships, not a device someone fitted.
function Rat_AttApplyModels(weapon, vis)
    local swapped
    for _, slot in ipairs(weapon.ComponentSlots or empty_table) do
        local cid = weapon.components[slot.SlotType]
        local family = cid and cid ~= slot.DefaultComponent and RAT_ATT_FAMILY_OF[cid]
        local def = family and Rat_AttFamilyDef(family, weapon)
        local model = def and def.model
        if model and IsValidEntity(model) then
            for _, descr in ipairs(WeaponComponents[cid].Visuals or empty_table) do
                local part = vis.parts[descr.Slot]
                if IsValid(part) and part:GetEntity() ~= model then
                    RAT_ATT_NATIVE[part] = part:GetEntity()
                    part:ChangeEntity(model)
                    swapped = true
                end
            end
        end
    end
    if swapped then
        weapon:UpdateColorMod(vis)
    end
end

---- Put back the native model first: the removal pass only deletes a part whose entity matches one
---- of the old component's Visuals, so a swapped part would outlive its component.
function Rat_AttUpdateVisualObj(self, vis)
    vis = vis or self.visual_obj
    local own = IsValid(vis) and vis.weapon == self
    if own then
        for _, part in pairs(vis.parts or empty_table) do
            if IsValid(part) and RAT_ATT_NATIVE[part] then
                part:ChangeEntity(RAT_ATT_NATIVE[part])
                RAT_ATT_NATIVE[part] = nil
            end
        end
    end
    local orig = RAT_ATT_VIS_ORIG[self.class] or FirearmBase.zz_UpdateVisualObj or FirearmBase.UpdateVisualObj
    orig(self, vis)
    if own and RAT_ATT_ENABLED then
        Rat_AttApplyModels(self, vis)
    end
end

---- Class tables are sealed at runtime (a new member asserts), so what each class had before lives
---- here. Both are captured once: a reload must recognise its own trampoline, not wrap it again.
if not RAT_ATT_VIS_ORIG then
    RAT_ATT_VIS_ORIG = {}
end
if not RAT_ATT_NATIVE then
    RAT_ATT_NATIVE = setmetatable({}, weak_keys_meta) -- swapped part -> the entity it came with
end
if not RAT_ATT_VisTrampoline then
    RAT_ATT_VisTrampoline = function(self, vis)
        return Rat_AttUpdateVisualObj(self, vis)
    end
end

---- Zulib stamps its UpdateVisualObj onto every Firearm class on ModsReloaded, so wrapping a base
---- class does nothing. Wrap each class after it, keeping whatever it had unless that was us.
function Rat_AttHookVisuals()
    for name, class in pairs(g_Classes) do
        if IsKindOf(class, "Firearm") and class.UpdateVisualObj ~= RAT_ATT_VisTrampoline then
            RAT_ATT_VIS_ORIG[name] = class.UpdateVisualObj
            class.UpdateVisualObj = RAT_ATT_VisTrampoline
        end
    end
end

---- Rebuilds component -> item. The frozen ids bind first; anything else in a covered slot binds
---- by display name, which is how the duplicated optics (ToG, _rpk_mount, _Master_) find an item.
function Rat_AttBind()
    local by_name, held_back = {}, {}
    table.clear(RAT_ATT_ITEM_OF)
    table.clear(RAT_ATT_FAMILY_OF)
    table.clear(RAT_ATT_UNBOUND)
    for family, comps in pairs(RAT_ATT_FAMILIES) do
        RAT_ATT_FAM_GUN[family] = {}
        RAT_ATT_FAM_CAL[family] = {}
        for _, cid in ipairs(comps) do
            if (WeaponComponents or empty_table)[cid] then
                RAT_ATT_FAMILY_OF[cid] = family
            end
        end
    end
    for _, def in ipairs(RAT_ATT_ITEMS) do
        if def.reserved then
            held_back[def.name] = true
            for _, cid in ipairs(def.comps) do
                held_back[cid] = true
            end
        end
    end
    for _, def in ipairs(RAT_ATT_ITEMS) do
        if def.reserved then
            goto continue
        end
        if def.family then
            for _, class in ipairs(def.guns or empty_table) do
                RAT_ATT_FAM_GUN[def.family][class] = def
            end
            for _, cal in ipairs(def.calibers or empty_table) do
                local list = RAT_ATT_FAM_CAL[def.family]
                list[cal] = list[cal] or {}
                table.insert(list[cal], def)
            end
        else
            by_name[def.name] = def.id
            for _, cid in ipairs(def.comps) do
                ---- a component listed under two items binds to whichever came last, silently
                if RAT_ATT_ITEM_OF[cid] then
                    print("Rat_Att: " .. cid .. " is listed under both " .. RAT_ATT_ITEM_OF[cid] ..
                              " and " .. def.id)
                end
                RAT_ATT_ITEM_OF[cid] = def.id
            end
        end
        ::continue::
    end

    for id, comp in pairs(WeaponComponents or empty_table) do
        if not RAT_ATT_ITEM_OF[id] and not RAT_ATT_FAMILY_OF[id] and RAT_ATT_SLOTS[comp.Slot or ""] then
            local name = comp_name(id, comp)
            if by_name[name] then
                RAT_ATT_ITEM_OF[id] = by_name[name]
            elseif comp.Slot == "Muzzle" and RAT_ATT_FAMILY_NAMES[name] and not held_back[id] then
                RAT_ATT_FAMILY_OF[id] = RAT_ATT_FAMILY_NAMES[name]
            elseif not comp_denied(name) and not held_back[name] and not held_back[id] then
                RAT_ATT_UNBOUND[#RAT_ATT_UNBOUND + 1] = id .. " (" .. name .. ")"
            end
        end
    end

    ---- a frozen id that no longer exists is dead weight, not an error: ToG may be off
    for cid in pairs(RAT_ATT_ITEM_OF) do
        if not (WeaponComponents or empty_table)[cid] then
            RAT_ATT_ITEM_OF[cid] = nil
        end
    end

    Rat_AttSnapshotCosts()
end

---- What each bound component charged before it became an item. Kept for the shop tier curve and
---- for the report; the presets themselves are never written to, so this is a record, not a backup.
function Rat_AttSnapshotCosts()
    table.clear(RAT_ATT_OLD)
    for _, bound in ipairs({RAT_ATT_ITEM_OF, RAT_ATT_FAMILY_OF}) do
        for cid in pairs(bound) do
            local comp = WeaponComponents[cid]
            RAT_ATT_OLD[cid] = {cost = comp.Cost, difficulty = comp.ModificationDifficulty}
        end
    end
end

---- Makes each item spendable by the modify screen. current/pay/restore are the same sector-wide
---- item count vanilla uses for Parts and lenses, so the squad bag and every merc in the sector count.
function Rat_AttEnsureResources()
    local list = SectorOperationResouces
    if not list then
        return
    end
    for _, def in ipairs(RAT_ATT_ITEMS) do
        if not list[def.id] and not def.reserved then
            local id = def.id
            local entry = {
                id = id,
                name = Untranslated(def.name),
                icon = def.icon,
                additional = true, -- keeps it out of the sector operations resource bar
                context = function(sector)
                    return sector
                end,
                current = function(sector)
                    if type(sector) == "string" then
                        sector = gv_Sectors[sector]
                    end
                    return sector and GetSectorOperationResource(sector, id) or 0
                end,
                pay = function(sector_id, cost)
                    PaySectorOperationResource(sector_id, id, cost)
                end,
                restore = function(merc, cost)
                    RestoreSectorOperationResource(merc, id, cost)
                end
            }
            list[#list + 1] = entry
            list[id] = entry
        end
    end
end

---- The class alone is not enough: vanilla and mods index InventoryItemDefs by item class and
---- dereference the result without checking (InventoryUI GetInventoryItemDragDropFXActor reads
---- .group on it), so every item class needs a preset too. Built here instead of in items.lua
---- because the editor must never own these.
function Rat_AttEnsureDefs()
    for _, def in ipairs(RAT_ATT_ITEMS) do
        ---- never a preset without a class behind it: PrepareShopItemsForRestock walks every preset
        ---- and reads g_Classes[preset.id] unguarded, so a half-built item takes the shop down
        if g_Classes[def.id] and not (InventoryItemDefs or empty_table)[def.id] then
            local props = {
                'Group', "Resources",
                'Id', def.id,
                'object_class', "MiscItem",
                'Icon', def.icon,
                'DisplayName', Untranslated(def.name),
                'DisplayNamePlural', Untranslated(def.name),
                'AdditionalHint', Untranslated(
                    "<bullet_point> Weapon attachment. Install it from the weapon modification screen."),
                'Cost', def.cost
            }
            for k, v in pairs(RAT_ATT_SIZES[def.size]) do
                props[#props + 1] = k == "Weight" and k or (k .. "_amount")
                props[#props + 1] = v
            end
            PlaceObj('InventoryItemCompositeDef', props)
        end
        ---- stamped every load, not only at creation, so retuning RAT_ATT_SCRAP reaches old saves
        local scrap = def.scrap or RAT_ATT_SCRAP[def.size]
        for _, target in ipairs({g_Classes[def.id] or false, (InventoryItemDefs or empty_table)[def.id] or false}) do
            if target then
                target.ScrapParts = scrap
            end
        end
    end
end

function Rat_AttSetup()
    if not RAT_ATT_ENABLED then
        return
    end
    Rat_AttBind()
    Rat_AttEnsureDefs()
    Rat_AttEnsureResources()
    Rat_AttHookVisuals()
end

function OnMsg.ModsReloaded()
    Rat_AttSetup()
end

function OnMsg.DataLoaded()
    Rat_AttSetup()
end

---- Zulib's ModsReloaded handler runs after ours and re-stamps every Firearm class; it announces
---- the end of that with this message, the first moment a wrapper sticks.
function OnMsg.zCore_SlotDepFin()
    if RAT_ATT_ENABLED then
        Rat_AttHookVisuals()
    end
end

---- SectorOperationResouces is rebuilt from a copy of the vanilla base on every ClassesBuilt, so
---- re-register at the last moment that still precedes any cost query.
function OnMsg.ModifyWeaponDialogOpened()
    Rat_AttSetup()
end

local function rat_att_afford(costs, sector)
    local can, per = true, {}
    for typ, cost in pairs(costs) do
        local preset = SectorOperationResouces and SectorOperationResouces[typ]
        local has = preset and preset.current(sector) or 0
        per[typ] = has >= cost
        if has < cost then
            can = false
        end
    end
    return can, per
end

---- Captured once at load. A hot reload finds the global already set and re-wraps the vanilla
---- function, not itself.
if not RAT_ATT_OrigGetChangesCost then
    RAT_ATT_OrigGetChangesCost = ModifyWeaponDlg.GetChangesCost
end

---- The one hook the whole feature needs: every gate in the modify screen -- the per-option price,
---- the greyed out slot, the Modify button, PayCosts -- reads this function.
function ModifyWeaponDlg:GetChangesCost(slotFilter, placedComponentOverride)
    local costs, anyChanged, canAfford, perType =
        RAT_ATT_OrigGetChangesCost(self, slotFilter, placedComponentOverride)
    if not RAT_ATT_ENABLED or not anyChanged or not self.context.weapon or not self.weaponClone then
        return costs, anyChanged, canAfford, perType
    end

    local weapon = self.context.weapon
    local components = self.weaponClone.components
    local touched = false
    for slot, itemId in pairs(weapon.components) do
        local placed = placedComponentOverride or components[slot] or ""
        if placed ~= itemId and (not slotFilter or slot == slotFilter) then
            local item = Rat_AttItemFor(placed, weapon)
            if item then
                ---- the physical part stands in for the lens/microchip the component used to ask for
                local preset = WeaponComponents[placed]
                for _, c in ipairs(preset and preset.AdditionalCosts or empty_table) do
                    if costs[c.Type] then
                        costs[c.Type] = costs[c.Type] - (c.Amount or 0)
                        if costs[c.Type] <= 0 then
                            costs[c.Type] = nil
                        end
                    end
                end
                ---- and the parts bill drops to the flat fitting fee, whatever the optic costs
                if costs.Parts then
                    costs.Parts = costs.Parts - (preset and preset.Cost or 0) + RAT_ATT_PARTS
                    if costs.Parts <= 0 then
                        costs.Parts = nil
                    end
                end
                costs[item] = (costs[item] or 0) + 1
                touched = true
            end
        end
    end
    if not touched then
        return costs, anyChanged, canAfford, perType
    end
    if CheatEnabled("FreeParts") then
        return costs, anyChanged, true, {}
    end
    canAfford, perType = rat_att_afford(costs, self.sector)
    return costs, anyChanged, canAfford, perType
end

if not RAT_ATT_OrigDifficultyParams then
    RAT_ATT_OrigDifficultyParams = ModifyWeaponDlg.GetModificationDifficultyParams
end

---- The other choke point: the roll, the "needs a better mechanic" gate and the difficulty label on
---- the option all read this one function.
function ModifyWeaponDlg:GetModificationDifficultyParams(componentToChangePreset)
    local skill, mostSkilled, difficulty, allowed =
        RAT_ATT_OrigDifficultyParams(self, componentToChangePreset)
    if not RAT_ATT_ENABLED or not skill or not componentToChangePreset then
        return skill, mostSkilled, difficulty, allowed
    end
    if not Rat_AttItemFor(componentToChangePreset.id, self.context.weapon) then
        return skill, mostSkilled, difficulty, allowed
    end
    difficulty = RAT_ATT_DIFFICULTY
    return skill, mostSkilled, difficulty, (skill - difficulty > 10)
end

---- Vanilla's restore drops the item on the floor of nowhere when the merc is full: it places the
---- item, fails to add it, and the sector fallback is commented out. So pick someone with room.
local function rat_att_sector(preferred)
    return preferred and preferred.Squad and gv_Squads[preferred.Squad] and
               gv_Squads[preferred.Squad].CurrentSector or gv_CurrentSectorId
end

local function rat_att_holder(preferred, item_id)
    local probe = PlaceInventoryItem(item_id)
    local sector = rat_att_sector(preferred)
    local candidates = {preferred}
    for _, id in ipairs(GetPlayerMercsInSector(sector) or empty_table) do
        candidates[#candidates + 1] = gv_UnitData[id]
    end
    local holder
    for _, u in ipairs(candidates) do
        if u and u.Squad and u:CanAddItem("Inventory", probe) then
            holder = u
            break
        end
    end
    DoneObject(probe)
    return holder
end

---- Detaching returns the part. Fires on replacement too, so swapping A for B pays B and refunds A.
---- A failed modification roll never reaches here, and vanilla only burns Parts on a failure, so a
---- botched install does not eat the scope.
function OnMsg.WeaponModifiedSuccess(weapon, unit, modAdded, mechanic, modSlot, oldComponent)
    if not RAT_ATT_ENABLED then
        return
    end
    local item = oldComponent and Rat_AttItemFor(oldComponent, weapon)
    if not item then
        return
    end
    local preferred = mechanic or unit
    local holder = rat_att_holder(preferred, item)
    if holder then
        RestoreSectorOperationResource(holder, item, 1)
    else
        ---- nobody has a free tile: the part goes to the sector stash instead of nowhere
        NetSyncEvent("Rat_AttStashPart", rat_att_sector(preferred), item)
    end
end

function NetSyncEvents.Rat_AttStashPart(sector_id, item_id)
    if not sector_id then
        print("Rat_Att: no sector to stash", item_id, "-- part lost")
        return
    end
    AddToSectorInventory(sector_id, {PlaceInventoryItem(item_id)})
    CombatLog("important",
              T{Untranslated("<item> went to the sector stash -- no one had room for it."),
                item = InventoryItemDefs[item_id] and InventoryItemDefs[item_id].DisplayName or
                    Untranslated(item_id)})
end

function Rat_AttReport()
    local bound = 0
    for _ in pairs(RAT_ATT_ITEM_OF) do
        bound = bound + 1
    end
    local held = {}
    for _, def in ipairs(RAT_ATT_ITEMS) do
        if def.reserved then
            held[#held + 1] = def.id
        end
    end
    print("Rat_Att: " .. #RAT_ATT_ITEMS .. " items, " .. bound .. " components bound, " .. #held ..
              " reserved")
    if #held > 0 then
        print("Rat_Att: reserved until the gun is patched: " .. table.concat(held, ", "))
    end
    local probe = RAT_ATT_ITEM_OF[next(RAT_ATT_ITEM_OF)]
    print("Rat_Att: resources registered = " ..
              tostring(probe and SectorOperationResouces and SectorOperationResouces[probe] ~= nil))
    if #RAT_ATT_UNBOUND > 0 then
        print("Rat_Att: optics with no item (" .. #RAT_ATT_UNBOUND .. "): " ..
                  table.concat(RAT_ATT_UNBOUND, ", "))
    end
end

---- How many vanilla or is_tog_patched firearms each component and each bound item reaches. Read
---- off the classes, not the presets: the component patch adds its slots to the class. free lists
---- the family devices a gun offers that resolve to no item.
local function rat_att_reach()
    local by_comp, by_item, free = {}, {}, {}
    ForEachPreset("InventoryItemCompositeDef", function(p)
        local cls = g_Classes[p.id]
        if not IsKindOf(cls, "Firearm") or not (IsVanillaFirearm(cls) or cls.is_tog_patched) then
            return
        end
        local seen = {}
        for _, slot in ipairs(cls.ComponentSlots or empty_table) do
            for _, cid in ipairs(slot.AvailableComponents or empty_table) do
                by_comp[cid] = (by_comp[cid] or 0) + 1
                local item = Rat_AttItemFor(cid, cls)
                if item and not seen[item] then
                    seen[item] = true
                    by_item[item] = (by_item[item] or 0) + 1
                elseif not item and RAT_ATT_FAMILY_OF[cid] and slot.Modifiable then
                    free[#free + 1] = p.id .. ":" .. cid
                end
            end
        end
    end)
    return by_comp, by_item, free
end

---- Recomputes which items are actually reachable and reports every reserved flag that disagrees:
---- a reserved optic whose gun is now patched, or a live item no gun can take any more.
function Rat_AttAudit()
    local by_comp, by_item, free = rat_att_reach()
    local open, shut = {}, {}
    for _, def in ipairs(RAT_ATT_ITEMS) do
        local n = by_item[def.id] or 0
        if def.reserved then
            for _, cid in ipairs(def.comps or empty_table) do
                n = n + (by_comp[cid] or 0)
            end
        end
        if def.reserved and n > 0 then
            open[#open + 1] = def.id .. " (" .. n .. " guns)"
        elseif not def.reserved and n == 0 then
            shut[#shut + 1] = def.id
        end
    end
    if #open > 0 then
        print("Rat_Att: reserved but now reachable, drop the flag: " .. table.concat(open, ", "))
    end
    if #shut > 0 then
        print("Rat_Att: sold but no patched gun takes it, reserve it: " .. table.concat(shut, ", "))
    end
    if #open == 0 and #shut == 0 then
        print("Rat_Att: every reserved flag matches the live weapon data")
    end
    if #free > 0 then
        print("Rat_Att: muzzle devices with no item for that gun (free): " .. table.concat(free, ", "))
    end
end

RAT_ATT_PREVIEW = {cases = false, i = 0}

---- Test helper: every patched gun wearing each muzzle device whose model the redirect changes, one
---- per call, read-only on the modify bench. all = true includes the ones it leaves alone.
function Rat_AttPreview(step, all)
    local p = RAT_ATT_PREVIEW
    if not p.cases or all ~= nil then
        p.cases, p.i = {}, 0
        ForEachPreset("InventoryItemCompositeDef", function(preset)
            local cls = g_Classes[preset.id]
            if not IsKindOf(cls, "Firearm") or not (IsVanillaFirearm(cls) or cls.is_tog_patched) then
                return
            end
            for _, slot in ipairs(cls.ComponentSlots or empty_table) do
                for _, cid in ipairs(slot.Modifiable and slot.AvailableComponents or empty_table) do
                    local family = RAT_ATT_FAMILY_OF[cid]
                    local def = family and cid ~= slot.DefaultComponent and Rat_AttFamilyDef(family, cls)
                    if def and (all or def.model) then
                        table.insert(p.cases, {gun = preset.id, slot = slot.SlotType, comp = cid, item = def.id})
                    end
                end
            end
        end)
        table.sort(p.cases, function(a, b)
            return a.item .. a.gun < b.item .. b.gun
        end)
    end
    if #p.cases == 0 then
        return
    end
    p.i = (p.i + (step or 1) - 1) % #p.cases + 1
    local c = p.cases[p.i]
    CloseDialog("ModifyWeaponDlg", true)
    local w = PlaceInventoryItem(c.gun)
    w:SetWeaponComponent(c.slot, c.comp)
    OpenDialog("ModifyWeaponDlg", nil, {weapon = w, slot = false, owner = false})
    print(string.format("Rat_AttPreview %d/%d: %s  %s  (%s)", p.i, #p.cases, c.gun, c.item, c.comp))
end

---- Test helper: one of every attachment to the selected merc.
function Rat_AttGiveAll(unit)
    unit = unit or SelectedObj or (Selection or empty_table)[1]
    local merc = unit and gv_UnitData[unit.session_id]
    if not merc then
        print("Rat_Att: no merc selected")
        return
    end
    for _, def in ipairs(RAT_ATT_ITEMS) do
        if not def.reserved then
            RestoreSectorOperationResource(merc, def.id, 1)
        end
    end
end

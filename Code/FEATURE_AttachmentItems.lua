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

---- The suppressor is the one muzzle device the data models as a separate tube: its Visuals pick an
---- entity per calibre family, shared by 6 to 20 guns. Compensators and bipods do the opposite --
---- 15 and 11 entities, one shaped per gun -- so those stay a single item each, the way a scope is
---- one item however its mount is drawn. Every suppressor item lists the same components and tells
---- them apart by model.
RAT_ATT_SUPPRESSOR_COMPS = {"Suppressor", "RAT_TOG_suppressor", "RAT_TOG_suppressor_762",
                            "RAT_TOG_suppressor_wp", "Suppressor_Anaconda", "ToG_Shotgun_Silencer"}

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
        icon = "UI/Icons/Upgrades/scope_reflex",
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
        cost = 1000,
        tier = 1,
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
        cost = 2000,
        tier = 1,
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
        cost = 1000,
        tier = 1,
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
        cost = 2500,
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
    {
        id = "RAT_Att_Compensator",
        name = "Compensator",
        icon = "UI/Icons/Upgrades/m16_muzzle",
        size = "small",
        cost = 1500,
        tier = 1,
        comps = {"Compensator", "G3A3_muzzle_1", "LionRoar_compensator", "RAT_TOG_CompensatorNoEntity", "RAT_TOG_compensator", "RK62_Muzzle_def_1", "RK95_Muzzle_def_1", "hk23e_muzzle_1", "hk33_muzzle_1"}
    },
    {
        id = "RAT_Att_AdvancedCompensator",
        name = "Advanced Compensator",
        icon = "UI/Icons/Upgrades/muzzle_steyr_01",
        size = "small",
        cost = 3000,
        tier = 2,
        comps = {"AUGCompensator_03", "Compensator_Glock"}
    },
    {
        id = "RAT_Att_RecoilBooster",
        name = "Recoil Booster",
        icon = "UI/Icons/Upgrades/booster_NATO",
        size = "small",
        cost = 2500,
        tier = 2,
        comps = {"MuzzleBooster"}
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
    {
        id = "RAT_Att_SuppressorPistol",
        name = "Suppressor (Pistol)",
        icon = "UI/Icons/Upgrades/beretta_silencer",
        size = "medium",
        cost = 3500,
        tier = 2,
        model = "WeaponAttA_SilencerBeretta",
        comps = RAT_ATT_SUPPRESSOR_COMPS
    },
    {
        id = "RAT_Att_SuppressorDesertEagle",
        name = "Suppressor (.44 Magnum)",
        icon = "UI/Icons/Upgrades/deserteagle_suppressor",
        size = "medium",
        cost = 4000,
        tier = 3,
        model = "WeaponAttA_SilencerDesertEagle",
        comps = RAT_ATT_SUPPRESSOR_COMPS
    },
    {
        id = "RAT_Att_SuppressorSMG9mm",
        name = "Suppressor (9mm SMG)",
        icon = "UI/Icons/Upgrades/9mm_SMG_suppressor",
        size = "large",
        cost = 3500,
        tier = 2,
        model = "WeaponAttA_SuppressorSMG9mm",
        comps = RAT_ATT_SUPPRESSOR_COMPS
    },
    {
        id = "RAT_Att_Suppressor556",
        name = "Suppressor (5.56 NATO)",
        icon = "UI/Icons/Upgrades/556_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        model = "WeaponAttA_SuppressorNATO",
        comps = RAT_ATT_SUPPRESSOR_COMPS
    },
    {
        id = "RAT_Att_Suppressor762",
        name = "Suppressor (7.62 NATO)",
        icon = "UI/Icons/Upgrades/762_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        model = "WeaponAttA_Suppressor762",
        comps = RAT_ATT_SUPPRESSOR_COMPS
    },
    {
        id = "RAT_Att_SuppressorWP",
        name = "Suppressor (Warsaw Pact)",
        icon = "UI/Icons/Upgrades/AK_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        model = "WeaponAttA_SuppressorWP",
        comps = RAT_ATT_SUPPRESSOR_COMPS
    },
    {
        id = "RAT_Att_Suppressor50",
        name = "Suppressor (.50 BMG)",
        icon = "UI/Icons/Upgrades/M82_suppressor",
        size = "large",
        cost = 6000,
        tier = 3,
        model = "WeaponAttA_SuppressorBarrettM82",
        comps = RAT_ATT_SUPPRESSOR_COMPS
    },
    {
        id = "RAT_Att_SuppressorShotgun",
        name = "Suppressor (Shotgun)",
        icon = "UI/Icons/Upgrades/shotgun_suppressor",
        size = "large",
        cost = 4500,
        tier = 3,
        model = "WeaponAttA_SuppressorShotgun",
        comps = RAT_ATT_SUPPRESSOR_COMPS
    },
    {
        id = "RAT_Att_SuppressorFN2000",
        name = "Suppressor (FN2000)",
        icon = "UI/Icons/Upgrades/556_suppressor",
        size = "large",
        cost = 4000,
        tier = 2,
        reserved = true,
        model = "FN2000_silencer",
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
        model = "MP7_Supr",
        comps = {"MP7_Supr_1"}
    }
}

RAT_ATT_ITEM_OF = {} -- component id -> item class
RAT_ATT_BY_MODEL = {} -- component id -> {visual entity -> item class}, for the model split families
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

---- Which model a component wears on this weapon. Mirrors Weapon.lua: among the visuals that Match
---- the class, the last one wins per spot, and a weapon specific one beats the generic fallback.
local function comp_model(cid, weapon_class)
    local comp = WeaponComponents[cid]
    local best = {}
    for _, descr in ipairs(comp and comp.Visuals or empty_table) do
        if descr:Match(weapon_class) then
            local prev = best[descr.Slot]
            if not prev or (prev:IsGeneric() and not descr:IsGeneric()) then
                best[descr.Slot] = descr
            end
        end
    end
    local models = RAT_ATT_BY_MODEL[cid]
    for _, descr in pairs(best) do
        if models[descr.Entity] then
            return descr.Entity
        end
    end
end

---- The item a component costs on this weapon. Only the model split families need the weapon; for
---- everything else the component alone decides, which is the cheap path and the common one.
function Rat_AttItemFor(cid, weapon)
    if not RAT_ATT_BY_MODEL[cid] then
        return RAT_ATT_ITEM_OF[cid]
    end
    local entity = weapon and comp_model(cid, weapon.class)
    return entity and RAT_ATT_BY_MODEL[cid][entity]
end

---- Rebuilds component -> item. The frozen ids bind first; anything else in a covered slot binds
---- by display name, which is how the duplicated optics (ToG, _rpk_mount, _Master_) find an item.
function Rat_AttBind()
    local by_name, held_back = {}, {}
    table.clear(RAT_ATT_ITEM_OF)
    table.clear(RAT_ATT_BY_MODEL)
    table.clear(RAT_ATT_UNBOUND)
    for _, def in ipairs(RAT_ATT_ITEMS) do
        if def.reserved then
            held_back[def.name] = true
            for _, cid in ipairs(def.comps) do
                held_back[cid] = true
            end
        end
    end
    for _, def in ipairs(RAT_ATT_ITEMS) do
        if not def.reserved then
            by_name[def.name] = def.id
            for _, cid in ipairs(def.comps) do
                if def.model then
                    RAT_ATT_BY_MODEL[cid] = RAT_ATT_BY_MODEL[cid] or {}
                    RAT_ATT_BY_MODEL[cid][def.model] = def.id
                else
                    ---- a component listed under two items binds to whichever came last, silently
                    if RAT_ATT_ITEM_OF[cid] then
                        print("Rat_Att: " .. cid .. " is listed under both " ..
                                  RAT_ATT_ITEM_OF[cid] .. " and " .. def.id)
                    end
                    RAT_ATT_ITEM_OF[cid] = def.id
                end
            end
        end
    end

    for id, comp in pairs(WeaponComponents or empty_table) do
        if not RAT_ATT_ITEM_OF[id] and not RAT_ATT_BY_MODEL[id] and RAT_ATT_SLOTS[comp.Slot or ""] then
            local name = comp_name(id, comp)
            if by_name[name] then
                RAT_ATT_ITEM_OF[id] = by_name[name]
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
    for cid in pairs(RAT_ATT_BY_MODEL) do
        if not (WeaponComponents or empty_table)[cid] then
            RAT_ATT_BY_MODEL[cid] = nil
        end
    end

    Rat_AttSnapshotCosts()
end

---- What each bound component charged before it became an item. Kept for the shop tier curve and
---- for the report; the presets themselves are never written to, so this is a record, not a backup.
function Rat_AttSnapshotCosts()
    table.clear(RAT_ATT_OLD)
    for _, bound in ipairs({RAT_ATT_ITEM_OF, RAT_ATT_BY_MODEL}) do
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
    end
end

function Rat_AttSetup()
    if not RAT_ATT_ENABLED then
        return
    end
    Rat_AttBind()
    Rat_AttEnsureDefs()
    Rat_AttEnsureResources()
end

function OnMsg.ModsReloaded()
    Rat_AttSetup()
end

function OnMsg.DataLoaded()
    Rat_AttSetup()
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

---- component id -> how many vanilla or is_tog_patched firearms offer it. Read off the classes,
---- not the presets: the component patch adds its slots to the class.
local function rat_att_reach()
    local reach = {}
    ForEachPreset("InventoryItemCompositeDef", function(p)
        local cls = g_Classes[p.id]
        if not IsKindOf(cls, "Firearm") or
            not (IsVanillaFirearm(cls) or cls.is_tog_patched) then
            return
        end
        for _, slot in ipairs(cls.ComponentSlots or empty_table) do
            for _, cid in ipairs(slot.AvailableComponents or empty_table) do
                reach[cid] = (reach[cid] or 0) + 1
            end
        end
    end)
    return reach
end

---- Recomputes which items are actually reachable and reports every reserved flag that disagrees:
---- a reserved optic whose gun is now patched, or a live item no gun can take any more.
function Rat_AttAudit()
    local reach = rat_att_reach()
    local open, shut = {}, {}
    for _, def in ipairs(RAT_ATT_ITEMS) do
        local n = 0
        for _, cid in ipairs(def.comps) do
            n = n + (reach[cid] or 0)
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

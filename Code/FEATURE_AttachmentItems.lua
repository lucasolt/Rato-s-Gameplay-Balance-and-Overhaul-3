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

---- The item hint lists the guns it fits; past this many distinct names it just says Universal.
RAT_ATT_UNIVERSAL = 20
RAT_ATT_HINT = "<bullet_point> Weapon attachment. Install it from the weapon modification screen."

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
    ["Integral Suppressor"] = true, -- built into the barrel: VSK-94, De Lisle
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
                  "Suppressor_Anaconda", "ToG_Shotgun_Silencer", "SteyrS_Muzzle_def_1"},
    ---- Removable underbarrel launchers only. Built-in ones (A91) and the fold/unfold rifle grenade
    ---- toggles (BM59, M70, PAP) stay free, like bayonets.
    grenadelauncher = {"AK47_Launcher", "GrenadeLauncher", "GrenadeLauncher_AUG", "GrenadeLauncher_Commando",
                       "GrenadeLauncher_Galil", "GrenadeLauncher_M14", "GrenadeLauncher_M16A1",
                       "G11_Grenadelauncher_1", "ToG_NatoGL"}
}

---- Families whose `any` item only reaches vanilla and is_tog_patched guns; elsewhere the part stays free.
RAT_ATT_FAM_PATCHED_ONLY = {grenadelauncher = true}

---- Components that keep their own bill and also consume an item: the AUG's long barrels carry a bipod.
RAT_ATT_EXTRA = {
    BarrelLong_AUG = "RAT_Att_Bipod",
    BarrelLongImproved_AUG = "RAT_Att_Bipod",
    long_barrel_AUG_light = "RAT_Att_Bipod"
}
---- Any other muzzle component with one of these display names joins the family too, the way the
---- optics bind by name: ToG ships a new id per gun (L85, M60, FN2000) for the same device.
RAT_ATT_FAMILY_NAMES = {
    ["Compensator"] = "compensator",
    ["Recoil Booster"] = "booster",
    ["Suppressor"] = "suppressor"
}

---- RAT_ATT_ITEMS (id frozen, comps, shop overrides) is generated from the attachments sheet into
---- FEATURE_AttachmentItemsData.lua by GBO_AttachmentsToLua.ipynb; edit the sheet, not that file.
local priceMul = 50

---- Magazines: one item per size and calibre, like the suppressors. The mag a gun ships with is part
---- of the gun and never an item. Off under Revised Mags, whose magazines are items already.
RAT_ATT_REVMAGS = "URkxyfE"
RAT_ATT_MAG_PARTS = 1
RAT_ATT_MAG_FAMILIES = {
    mag_standard = {"MagNormal"},
    mag_fine = {"MagNormalFine"},
    mag_expanded = {"MagLarge", "MagLarge_1", "MagLarge_3", "MagLarge_4", "MagLarge_5", "MagLarge_7", "MagLarge_10",
                    "A91_762_mag_ext_1", "G11_Mag_ext_1"},
    mag_ergo = {"MagLargeFine", "MagLargeFine_1", "MagLargeFine_5", "MagLargeFine_10"},
    mag_quick = {"MagQuick"},
    mag_quickexpanded = {"R_MagQuickLarge"},
    mag_drum = {"MagLarger", "MagLarge_2", "MagLarge_6", "MagLarge_8", "MagLarge_9", "MagLarge_12", "G11_Mag_ext2_1"}
}

for family, comps in pairs(RAT_ATT_MAG_FAMILIES) do
    RAT_ATT_FAMILIES[family] = comps
end

---- A live item that is switched off for this mod set: bound to nothing, never sold or registered.
function Rat_AttOff(def)
    return def.mag and IsMod_loaded(RAT_ATT_REVMAGS)
end

for i, att in ipairs(RAT_ATT_ITEMS) do
	att.cost = MulDivRound(att.cost, priceMul, 100)
end

---- Tons of Components models for the calibre items that share a vanilla model with another item.
local TOC_ICONS = "Mod/KQkEVHf/Icons/Upgrades/"
RAT_ATT_TOC_MODELS = {
    RAT_Att_Suppressor545 = {"ToC_Silencer_7", TOC_ICONS .. "ToC_Silencer_7.png"}, -- Silentium Whisper, a PBS-4
    RAT_Att_Suppressor54R = {"ToC_Silencer_6", TOC_ICONS .. "ToC_Silencer_6.png"},
    RAT_Att_Suppressor9x39 = {"ToC_Silencer_10", TOC_ICONS .. "ToC_Silencer_10.png"},
    RAT_Att_SuppressorMauser = {"ToC_Silencer_3", TOC_ICONS .. "ToC_Silencer_3.png"}, -- ToC_Silencer_4 renders as a white cube
    RAT_Att_Suppressor44Rifle = {"ToC_Silencer_9", TOC_ICONS .. "ToC_Silencer_9.png"},
    RAT_Att_Suppressor45SMG = {"ToC_Silencer_SB100", TOC_ICONS .. "ToC_Silencer_sb100.png"},
    RAT_Att_Compensator45 = {"ToC_Muzzle_3", TOC_ICONS .. "ToC_Muzzle_3.png"},
    RAT_Att_CompensatorMauser = {"ToC_Muzzle_4", TOC_ICONS .. "ToC_Muzzle_4.png"}
}

---- Runs before the classes are built, which bake the icon. Class ids stay the same either way.
function Rat_AttUseToCModels()
    if not IsMod_loaded("KQkEVHf") then
        return
    end
    for _, def in ipairs(RAT_ATT_ITEMS) do
        local toc = RAT_ATT_TOC_MODELS[def.id]
        if toc then
            def.model, def.icon = toc[1], toc[2]
        end
    end
end

Rat_AttUseToCModels()

RAT_ATT_ITEM_OF = {} -- component id -> item class
RAT_ATT_FAMILY_OF = {} -- component id -> family name
RAT_ATT_FAM_GUN = {} -- family -> weapon class -> item def
RAT_ATT_FAM_CAL = {} -- family -> caliber -> item defs
RAT_ATT_FAM_ANY = {} -- family -> item def for any gun the others miss
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
            AdditionalHint = Untranslated(RAT_ATT_HINT),
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
---- types admit the weapon type, then an untyped one, then the family's `any`. nil leaves it free.
function Rat_AttFamilyDef(family, weapon)
    if RAT_ATT_FAM_PATCHED_ONLY[family] and not (IsVanillaFirearm(weapon) or weapon.is_tog_patched) then
        return
    end
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
    return fallback or RAT_ATT_FAM_ANY[family]
end

---- The item a component costs on this weapon. Only the families need the weapon; for everything
---- else the component alone decides, which is the cheap path and the common one.
function Rat_AttItemFor(cid, weapon)
    local family = RAT_ATT_FAMILY_OF[cid]
    if not family then
        return RAT_ATT_ITEM_OF[cid]
    end
    if weapon and RAT_ATT_MAG_FAMILIES[family] then
        local slot = table.find_value(weapon.ComponentSlots or empty_table, "SlotType", "Magazine")
        if not slot or slot.DefaultComponent == cid then
            return
        end
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
                    part.rat_native = part.rat_native or part:GetEntity()
                    part.rat_offset = def.offsets and def.offsets[weapon.class]
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

---- Our wrapper -> what it wrapped. ReloadLua re-runs vanilla, so a hook usually finds a fresh
---- function; when it finds one of ours instead (hot load, repeated setup) it wraps what is under it.
---- Mod code has no `debug` library, so this table is the only way to tell a wrapper of ours.
RAT_ATT_WRAPS = setmetatable({}, weak_keys_meta)

function Rat_AttOriginal(fn)
    while RAT_ATT_WRAPS[fn] do
        fn = RAT_ATT_WRAPS[fn]
    end
    return fn
end

---- Put back the native model first: the removal pass only deletes a part whose entity matches one
---- of the old component's Visuals, so a swapped part would outlive its component.
function Rat_AttUpdateVisualObj(self, vis, orig)
    vis = vis or self.visual_obj
    local own = IsValid(vis) and vis.weapon == self
    if own then
        for _, part in pairs(vis.parts or empty_table) do
            if IsValid(part) and part.rat_native then
                part:ChangeEntity(part.rat_native)
                part.rat_native = nil
                part.rat_offset = nil
            end
        end
    end
    orig(self, vis)
    if own and RAT_ATT_ENABLED then
        Rat_AttApplyModels(self, vis)
    end
    if own then
        ApplyWeaponComponentOffset(self, vis) -- CommonLib's own wrapper is overwritten by ToG/Zulib
        ---- on top of the component's own offset, which the pass above just reset
        for _, part in pairs(vis.parts or empty_table) do
            if IsValid(part) and part.rat_offset then
                part:SetAttachOffset(part:GetAttachOffset() + part.rat_offset)
            end
        end
    end
end

---- Zulib stamps its UpdateVisualObj onto every Firearm class on ModsReloaded, so wrapping a base
---- class does nothing. Each class gets its own wrapper over whatever it had, minus any of ours.
function Rat_AttHookVisuals()
    for _, class in pairs(g_Classes) do
        if IsKindOf(class, "Firearm") then
            local orig = Rat_AttOriginal(class.UpdateVisualObj)
            class.UpdateVisualObj = function(self, vis)
                return Rat_AttUpdateVisualObj(self, vis, orig)
            end
            RAT_ATT_WRAPS[class.UpdateVisualObj] = orig
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
    table.clear(RAT_ATT_FAM_ANY)
    for family, comps in pairs(RAT_ATT_FAMILIES) do
        RAT_ATT_FAM_GUN[family] = {}
        RAT_ATT_FAM_CAL[family] = {}
        local off = RAT_ATT_MAG_FAMILIES[family] and IsMod_loaded(RAT_ATT_REVMAGS)
        for _, cid in ipairs(off and empty_table or comps) do
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
        if def.reserved or Rat_AttOff(def) then
            goto continue
        end
        if def.family then
            if def.any then
                RAT_ATT_FAM_ANY[def.family] = def
            end
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
        if not list[def.id] and not def.reserved and not Rat_AttOff(def) then
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
                'AdditionalHint', Untranslated(RAT_ATT_HINT),
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

---- Which vanilla or is_tog_patched guns take each item, and whether every one of them ships with it.
---- fits: item -> {weapon class = true}; stock: item -> true when it is the default on all of them.
function Rat_AttCompatible()
    local fits, stock = {}, {}
    ForEachPreset("InventoryItemCompositeDef", function(p)
        local cls = g_Classes[p.id]
        if not IsKindOf(cls, "Firearm") or not (IsVanillaFirearm(cls) or cls.is_tog_patched) then
            return
        end
        for _, slot in ipairs(cls.ComponentSlots or empty_table) do
            local comps = slot.AvailableComponents or empty_table
            ---- a locked slot, or one welded to its only part, takes nothing
            local fixed = not slot.Modifiable or (#comps == 1 and not slot.CanBeEmpty)
            for _, cid in ipairs(fixed and empty_table or comps) do
                local item = Rat_AttItemFor(cid, cls)
                if item then
                    fits[item] = fits[item] or {}
                    fits[item][p.id] = true
                    stock[item] = stock[item] ~= false and slot.DefaultComponent == cid
                end
            end
        end
    end)
    return fits, stock
end

---- Appends the compatible guns to each item's hint. Rebuilt every setup, so a newly patched gun shows up.
function Rat_AttEnsureHints()
    local fits = Rat_AttCompatible()
    for _, def in ipairs(RAT_ATT_ITEMS) do
        local names = {}
        for class in pairs(fits[def.id] or empty_table) do
            local name = _InternalTranslate(g_Classes[class].DisplayName or Untranslated(class))
            if not table.find(names, name) then
                names[#names + 1] = name
            end
        end
        table.sort(names)
        ---- reserved items reach no patched gun yet; no line beats "Fits: nothing"
        local list = #names > RAT_ATT_UNIVERSAL and "Universal" or table.concat(names, ", ")
        local hint = Untranslated(#names == 0 and RAT_ATT_HINT or
                                      (RAT_ATT_HINT .. "<newline><bullet_point> Fits: " .. list))
        for _, target in ipairs({g_Classes[def.id] or false, (InventoryItemDefs or empty_table)[def.id] or false}) do
            if target then
                target.AdditionalHint = hint
            end
        end
    end
end

---- Where the item replaces the model, the bench shows the item's icon: one component id serves
---- many calibres, so its own icon is right for one of them at best.
function Rat_AttComponentIcon(comp, weapon, orig)
    local family = RAT_ATT_ENABLED and weapon and comp and RAT_ATT_FAMILY_OF[comp.id]
    local slot = family and table.find_value(weapon.ComponentSlots or empty_table, "SlotType", comp.Slot)
    local def = slot and comp.id ~= slot.DefaultComponent and Rat_AttFamilyDef(family, weapon)
    if def and def.model and IsValidEntity(def.model) then
        return def.icon
    end
    return orig(comp, weapon)
end

function Rat_AttHookIcon()
    local orig = Rat_AttOriginal(GetWeaponComponentIcon)
    GetWeaponComponentIcon = function(comp, weapon)
        return Rat_AttComponentIcon(comp, weapon, orig)
    end
    RAT_ATT_WRAPS[GetWeaponComponentIcon] = orig
end

---- Lenses and chips only paid for optics and devices, which the items now replace; they become loot
---- to cash in. Bobby Ray stops stocking them, since buying one back would be a straight loss.
---- id -> Cost, which is what CashInItem pays and the menu shows.
RAT_ATT_CASHIN = {Microchip = 800, OpticalLens = 500}
RAT_ATT_CASHIN_HINT = "<bullet_point> No longer used to build weapon components. Can be cashed in."

function Rat_AttEnsureCashIn()
    for id, cost in pairs(RAT_ATT_CASHIN) do
        for _, target in ipairs({g_Classes[id] or false, (InventoryItemDefs or empty_table)[id] or false}) do
            if target then
                target.Cost = cost
                target.CanAppearInShop = false
                target.AdditionalHint = Untranslated(RAT_ATT_CASHIN_HINT)
            end
        end
    end
end

---- The CASH IN entry is gated on Valuables alone; CashInItem itself takes any item and pays its Cost.
---- ValuablesStack is left alone: lenses and chips are single items, and that entry is the stack action.
local orig_filter = Rat_AttOriginal(InvContextMenuFilter)
function InvContextMenuFilter(context, className)
    if RAT_ATT_ENABLED and className == "Valuables" and context and context.item and
        RAT_ATT_CASHIN[context.item.class] then
        return orig_filter(context, false)
    end
    return orig_filter(context, className)
end
RAT_ATT_WRAPS[InvContextMenuFilter] = orig_filter

function Rat_AttSetup()
    if not RAT_ATT_ENABLED then
        return
    end
    Rat_AttHookIcon()
    Rat_AttBind()
    Rat_AttEnsureDefs()
    Rat_AttEnsureHints()
    Rat_AttEnsureCashIn()
    Rat_AttEnsureResources()
    Rat_AttHookVisuals()
end

function OnMsg.ModsReloaded()
    Rat_AttSetup()
end

function OnMsg.DataLoaded()
    Rat_AttSetup()
end

---- A Lua reload rebuilds the classes and empties the binding tables, and fires neither of the above.
function OnMsg.AutorunEnd()
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

---- The one hook the whole feature needs: every gate in the modify screen -- the per-option price,
---- the greyed out slot, the Modify button, PayCosts -- reads this function.
local orig = Rat_AttOriginal(ModifyWeaponDlg.GetChangesCost)
function ModifyWeaponDlg:GetChangesCost(slotFilter, placedComponentOverride)
    local costs, anyChanged, canAfford, perType = orig(self, slotFilter, placedComponentOverride)
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
                    local fee = RAT_ATT_MAG_FAMILIES[RAT_ATT_FAMILY_OF[placed]] and RAT_ATT_MAG_PARTS or RAT_ATT_PARTS
                    costs.Parts = costs.Parts - (preset and preset.Cost or 0) + fee
                    if costs.Parts <= 0 then
                        costs.Parts = nil
                    end
                end
                costs[item] = (costs[item] or 0) + 1
                touched = true
            end
            ---- a swap between two bipod barrels moves the same bipod across
            local extra = RAT_ATT_EXTRA[placed]
            if extra and RAT_ATT_EXTRA[itemId] ~= extra then
                costs[extra] = (costs[extra] or 0) + 1
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
RAT_ATT_WRAPS[ModifyWeaponDlg.GetChangesCost] = orig

---- The other choke point: the roll, the "needs a better mechanic" gate and the difficulty label on
---- the option all read this one function.
local orig = Rat_AttOriginal(ModifyWeaponDlg.GetModificationDifficultyParams)
function ModifyWeaponDlg:GetModificationDifficultyParams(componentToChangePreset)
    local skill, mostSkilled, difficulty, allowed = orig(self, componentToChangePreset)
    if not RAT_ATT_ENABLED or not skill or not componentToChangePreset then
        return skill, mostSkilled, difficulty, allowed
    end
    if not Rat_AttItemFor(componentToChangePreset.id, self.context.weapon) then
        return skill, mostSkilled, difficulty, allowed
    end
    difficulty = RAT_ATT_DIFFICULTY
    return skill, mostSkilled, difficulty, (skill - difficulty > 10)
end
RAT_ATT_WRAPS[ModifyWeaponDlg.GetModificationDifficultyParams] = orig

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
    if not RAT_ATT_ENABLED or not oldComponent then
        return
    end
    local preferred = mechanic or unit
    local function give(item)
        local holder = rat_att_holder(preferred, item)
        if holder then
            RestoreSectorOperationResource(holder, item, 1)
        else
            ---- nobody has a free tile: the part goes to the sector stash instead of nowhere
            NetSyncEvent("Rat_AttStashPart", rat_att_sector(preferred), item)
        end
    end
    local item = Rat_AttItemFor(oldComponent, weapon)
    if item then
        give(item)
    end
    local extra = RAT_ATT_EXTRA[oldComponent]
    if extra then
        ---- the clone already wears the new component when this fires; the weapon may not yet
        local cabinet = GetDialog("ModifyWeaponDlg")
        local dlg = cabinet and cabinet.idModifyDialog
        local placed = dlg and dlg.weaponClone and dlg.weaponClone.components[modSlot]
        if RAT_ATT_EXTRA[placed] ~= extra then
            give(extra)
        end
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
                elseif not item and RAT_ATT_FAMILY_OF[cid] and slot.Modifiable and cid ~= slot.DefaultComponent then
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
        elseif not def.reserved and not Rat_AttOff(def) and n == 0 then
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
        print("Rat_Att: family parts with no item for that gun (free): " .. table.concat(free, ", "))
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
        if not def.reserved and not Rat_AttOff(def) then
            RestoreSectorOperationResource(merc, def.id, 1)
        end
    end
end

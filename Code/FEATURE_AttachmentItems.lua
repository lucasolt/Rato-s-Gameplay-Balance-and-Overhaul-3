---- Scopes and side devices as physical inventory items: attaching one spends the item from the
---- squad, detaching gives it back. The component system itself is untouched -- only the cost the
---- modify screen asks for changes, so nothing here can desync a weapon that is already built.
----
---- RAT_ATT_ITEMS is static on purpose: savegames store item class names, so the list of classes
---- must not depend on which mods happen to be loaded. The component -> item binding IS dynamic
---- and is rebuilt every load: another component id for the same optic (a ToG variant, an
---- _rpk_mount clone, a _Master_ template) binds by display name with no edit here.

RAT_ATT_ENABLED = true

---- Which component slots turn into items.
RAT_ATT_SLOTS = {Scope = true, Side = true}

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
    ["CAWS Ironsight"] = true
}

---- ToG ships Caws_Scope_1, a 40-part scope, under the ironsight's display name.
RAT_ATT_RENAME = {Caws_Scope_1 = "CAWS Scope"}

---- id: item class, frozen. comps: the ids known when this was generated; name binds the rest.
RAT_ATT_ITEMS = {
    {
        id = "RAT_Att_AWPScope",
        name = "AWP Scope",
        icon = "Mod/KKh3Yhf/Images/AWP_Scope_icon.png",
        cost = 4000,
        comps = {"AWP_Scope_1"}
    },
    {
        id = "RAT_Att_AssaltoReflexSight1x",
        name = "\"Assalto\" Reflex Sight 1x",
        icon = "UI/Icons/Upgrades/scope_reflex",
        cost = 3000,
        comps = {"RAT_TOG_Reflex", "RAT_TOG_Reflex_pistol", "RAT_TOG_Reflex_pistol_rpk_mount", "RAT_TOG_Reflex_rpk_mount", "ReflexSightAdvanced", "ReflexSightAdvanced_Glock"}
    },
    {
        id = "RAT_Att_AutomagScope",
        name = "Automag Scope",
        icon = "Mod/KKh3Yhf/Images/Automag_Scope_icon.png",
        cost = 2500,
        comps = {"Automag_Scope_1"}
    },
    {
        id = "RAT_Att_CAWSScope",
        name = "CAWS Scope",
        icon = "Mod/KKh3Yhf/Images/CAWS_Scope_icon.png",
        cost = 4000,
        comps = {"Caws_Scope_1"}
    },
    {
        id = "RAT_Att_CompactReflexSight1x",
        name = "Compact Reflex Sight 1x",
        icon = "UI/Icons/Upgrades/compact_reflex_sight",
        cost = 2000,
        comps = {"RAT_TOG_compactRS", "RAT_TOG_compactRS_rpk_mount", "ReflexSight"}
    },
    {
        id = "RAT_Att_CrossfireIIx4",
        name = "Crossfire II x4",
        icon = "Mod/KKh3Yhf/Images/SteyrScout_Scope.png",
        cost = 3500,
        comps = {"SteyrS_Scope_1", "_Master_SteyrS_Scope_TOG"}
    },
    {
        id = "RAT_Att_DigitalScope2x",
        name = "Digital Scope 2x",
        icon = "UI/Icons/Upgrades/prism_scope",
        cost = 3000,
        comps = {"G36_SCOPE"}
    },
    {
        id = "RAT_Att_DigitalScope4x2x",
        name = "Digital Scope 4x/2x",
        icon = "UI/Icons/Upgrades/scope_longrange",
        cost = 5000,
        comps = {"SCOPE_G36_2"}
    },
    {
        id = "RAT_Att_Flashlight",
        name = "Flashlight",
        icon = "UI/Icons/Upgrades/side_light",
        cost = 1000,
        comps = {"Flashlight", "Flashlight_Anaconda", "Flashlight_PSG_M1", "Flashlight_aa12", "RAT_TOG_flashlight", "RAT_TOG_flashlight_rpk_mount", "ToG_Flashlight_1"}
    },
    {
        id = "RAT_Att_G11ZieloptikZO1",
        name = "G11 Zieloptik ZO-1",
        icon = "Mod/KKh3Yhf/Images/G11_Scope_icon.png",
        cost = 1000,
        comps = {"G11_Scope_1"}
    },
    {
        id = "RAT_Att_HensoldtZFScope6x",
        name = "Hensoldt ZF Scope 6x",
        icon = "UI/Icons/Upgrades/custom_PSG1_scope",
        cost = 5000,
        comps = {"PSG_DefaultScope", "RAT_TOG_PSGScope", "RAT_TOG_PSGScope_rpk_mount"}
    },
    {
        id = "RAT_Att_PSO1M21Scope4x",
        name = "PSO-1M2-1 Scope 4x",
        icon = "Mod/KKh3Yhf/Images/VSS_Scope_icon.png",
        cost = 3500,
        comps = {"VSS_Scope_1", "_Master_PSO-1M2_Scope_TOG"}
    },
    {
        id = "RAT_Att_PSO1Scope4x",
        name = "PSO-1 Scope 4x",
        icon = "UI/Icons/Upgrades/custom_Dragunov_scope",
        cost = 4000,
        comps = {"LROptics_DragunovDefault"}
    },
    {
        id = "RAT_Att_PrismScope2x",
        name = "Prism Scope 2x",
        icon = "UI/Icons/Upgrades/prism_scope",
        cost = 2500,
        comps = {"RAT_TOG_Prism", "RAT_TOG_Prism_rpk_mount", "ScopeCOG"}
    },
    {
        id = "RAT_Att_QuickPrismScope2x",
        name = "Quick Prism Scope 2x",
        icon = "UI/Icons/Upgrades/scope_thermal",
        cost = 2500,
        comps = {"RAT_TOG_ACOG", "RAT_TOG_ACOG_rpk_mount", "ScopeCOGQuick"}
    },
    {
        id = "RAT_Att_RedDot",
        name = "Red Dot",
        icon = "Mod/KKh3Yhf/Images/MK23_laser.png",
        cost = 2000,
        comps = {"LaserDot", "LaserDot_Anaconda", "LaserDot_PSG_M1", "LaserDot_aa12", "MK23_laser_1", "RAT_TOG_laser_dot", "RAT_TOG_laser_dot_rpk_mount", "ToG_Red_Dot_1"}
    },
    {
        id = "RAT_Att_ReflexSight",
        name = "Reflex Sight",
        icon = "Mod/KKh3Yhf/Images/MP7_reddot.png",
        cost = 3500,
        comps = {"MP7_Scope_1", "TAR21_Scope_Rflx_1"}
    },
    {
        id = "RAT_Att_SniperScope4x",
        name = "Sniper Scope 4x",
        icon = "UI/Icons/Upgrades/scope_longrange",
        cost = 3000,
        comps = {"LROptics", "RAT_TOG_LRoptics", "RAT_TOG_LRoptics_rpk_mount"}
    },
    {
        id = "RAT_Att_SniperScope6x",
        name = "Sniper Scope 6x",
        icon = "UI/Icons/Upgrades/sniper_scope_x10",
        cost = 4000,
        comps = {"LROpticsAdvanced", "RAT_TOG_LRoptics_advanced", "RAT_TOG_LRoptics_advanced_rpk_mount"}
    },
    {
        id = "RAT_Att_SniperScopex5",
        name = "Sniper Scope x5",
        icon = "UI/Icons/Upgrades/custom_Dragunov_scope",
        cost = 2000,
        comps = {"AN94_Scope_1", "SKS_Scope"}
    },
    {
        id = "RAT_Att_SniperScopex8",
        name = "Sniper Scope x8",
        icon = "Mod/KKh3Yhf/Images/NTW20_scope.png",
        cost = 3500,
        comps = {"NTW_20_Scope_1"}
    },
    {
        id = "RAT_Att_SwarovskiOptikScope15x",
        name = "Swarovski Optik Scope 1.5x",
        icon = "UI/Icons/Upgrades/custom_Steyr_AUG_scope",
        cost = 2000,
        comps = {"AUGScope_Default"}
    },
    {
        id = "RAT_Att_TacticalDevice",
        name = "Tactical Device",
        icon = "UI/Icons/Upgrades/side_laserlight",
        cost = 2000,
        comps = {"FlashlightDot", "FlashlightDot_Anaconda", "FlashlightDot_PSG_M1", "FlashlightDot_aa12", "RAT_TOG_tactical_dot", "RAT_TOG_tactical_dot_rpk_mount"}
    },
    {
        id = "RAT_Att_ThermalScope4x",
        name = "Thermal Scope 4x",
        icon = "UI/Icons/Upgrades/scope_ACOG",
        cost = 6000,
        comps = {"RAT_TOG_thermal", "RAT_TOG_thermal_rpk_mount", "ThermalScope", "ThermalScope_1", "ThermalScope_2"}
    },
    {
        id = "RAT_Att_UVDot",
        name = "UV Dot",
        icon = "UI/Icons/Upgrades/side_laser",
        cost = 1000,
        comps = {"RAT_TOG_uv_dot", "RAT_TOG_uv_dot_rpk_mount", "ToG_UV_Dot_1", "UVDot", "UVDot_Anaconda", "UVDot_PSG_M1", "UVDot_aa12"}
    },
    {
        id = "RAT_Att_VigilanteReflexSight1x",
        name = "\"Vigilante\" Reflex Sight 1x",
        icon = "Mod/KQkEVHf/Icons/Upgrades/ToC_Scope_kentaur.png",
        cost = 3000,
        comps = {"RAT_TOG_vigilanceRS", "RAT_TOG_vigilanceRS_rpk_mount", "_ReflexSIghtVigilance"}
    },
    {
        id = "RAT_Att_VultoWideScope2x",
        name = "\"Vulto\" Wide Scope 2x",
        icon = "Mod/KKh3Yhf/Images/L85A1_scope.png",
        cost = 2500,
        comps = {"RAT_TOG_WideScope", "RAT_TOG_WideScope_rpk_mount", "WideScope"}
    },
    {
        id = "RAT_Att_WA2000Scope",
        name = "WA2000 Scope",
        icon = "Mod/KKh3Yhf/Images/WA2000_Scope_icon_1.png",
        cost = 2000,
        comps = {"WA2000_Scope_1"}
    },
    {
        id = "RAT_Att_ZF4Scopex15",
        name = "ZF-4 Scope x1.5",
        icon = "Mod/KKh3Yhf/Images/G43_Scope_icon.png",
        cost = 2500,
        comps = {"GW43_Scope_1", "_Master_GW43_Scope_TOG"}
    },
    {
        id = "RAT_Att_ZF846x",
        name = "ZF 84 6x",
        icon = "Mod/KKh3Yhf/Images/SSG69_Scope_icon.png",
        cost = 2000,
        comps = {"SSG69_Scope_1", "_Master_SSG69_Scope_TOG"}
    },
    {
        id = "RAT_Att_ZRAKx4Scope",
        name = "ZRAK x4 Scope",
        icon = "Mod/KKh3Yhf/Images/M76_scope.png",
        cost = 2000,
        comps = {"_Master_m76_scope_TOG", "m76_scope_1"}
    }
}

RAT_ATT_ITEM_OF = {} -- component id -> item class
RAT_ATT_UNBOUND = {} -- report only: optics in a covered slot that got no item

---- The item classes. DefineClass is gone by the time the game runs, so this only executes on a
---- real load; a hot reload of this file skips it and keeps the classes already built.
if DefineClass then
    for _, def in ipairs(RAT_ATT_ITEMS) do
        DefineClass(def.id, {
            __parents = {"MiscItem"},
            object_class = "MiscItem",
            Icon = def.icon,
            DisplayName = Untranslated(def.name),
            DisplayNamePlural = Untranslated(def.name),
            AdditionalHint = Untranslated(
                "<bullet_point> Weapon attachment. Install it from the weapon modification screen."),
            Cost = def.cost,
            MaxStacks = 5
        })
    end
end

local function comp_name(id, comp)
    if RAT_ATT_RENAME[id] then
        return RAT_ATT_RENAME[id]
    end
    return _InternalTranslate(comp.DisplayName or Untranslated(""))
end

---- Rebuilds component -> item. The frozen ids bind first; anything else in a covered slot binds
---- by display name, which is how the duplicated optics (ToG, _rpk_mount, _Master_) find an item.
function Rat_AttBind()
    local by_name = {}
    table.clear(RAT_ATT_ITEM_OF)
    table.clear(RAT_ATT_UNBOUND)
    for _, def in ipairs(RAT_ATT_ITEMS) do
        by_name[def.name] = def.id
        for _, cid in ipairs(def.comps) do
            RAT_ATT_ITEM_OF[cid] = def.id
        end
    end

    for id, comp in pairs(WeaponComponents or empty_table) do
        if not RAT_ATT_ITEM_OF[id] and RAT_ATT_SLOTS[comp.Slot or ""] then
            local name = comp_name(id, comp)
            if by_name[name] then
                RAT_ATT_ITEM_OF[id] = by_name[name]
            elseif not RAT_ATT_DENY_NAMES[name] then
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
end

---- Makes each item spendable by the modify screen. current/pay/restore are the same sector-wide
---- item count vanilla uses for Parts and lenses, so the squad bag and every merc in the sector count.
function Rat_AttEnsureResources()
    local list = SectorOperationResouces
    if not list then
        return
    end
    for _, def in ipairs(RAT_ATT_ITEMS) do
        if not list[def.id] then
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
        if not (InventoryItemDefs or empty_table)[def.id] then
            PlaceObj('InventoryItemCompositeDef', {
                'Group', "Resources",
                'Id', def.id,
                'object_class', "MiscItem",
                'Icon', def.icon,
                'DisplayName', Untranslated(def.name),
                'DisplayNamePlural', Untranslated(def.name),
                'AdditionalHint', Untranslated(
                    "<bullet_point> Weapon attachment. Install it from the weapon modification screen."),
                'Cost', def.cost
            })
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
            local item = RAT_ATT_ITEM_OF[placed]
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
    local item = oldComponent and RAT_ATT_ITEM_OF[oldComponent]
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
    print("Rat_Att: " .. #RAT_ATT_ITEMS .. " items, " .. bound .. " components bound")
    print("Rat_Att: resources registered = " ..
              tostring(SectorOperationResouces and SectorOperationResouces[RAT_ATT_ITEMS[1].id] ~= nil))
    if #RAT_ATT_UNBOUND > 0 then
        print("Rat_Att: optics with no item (" .. #RAT_ATT_UNBOUND .. "): " ..
                  table.concat(RAT_ATT_UNBOUND, ", "))
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
        RestoreSectorOperationResource(merc, def.id, 1)
    end
end

---- Cheats menu (in-game Esc > Cheats) entries, each inserted after a vanilla action of its section
local function AppendToggleCheat(action_id, name, cheat, after_id, section)
    if UIFindControl("IGMainActions", action_id) then
        return
    end
    local _, parent, idx = UIFindControl("IGMainActions", after_id)
    if not parent then
        return
    end
    table.insert(parent, idx + 1, PlaceObj('XTemplateAction', {
        'comment', "cheat",
        'ActionId', action_id,
        'ActionName', name,
        'ActionToolbar', "cheats",
        'ActionToolbarSection', section,
        'OnAction', function(self, host, source, ...)
            NetSyncCheatEnableIG(cheat)
            CloseMenuDialogs()
        end,
    }))
end

local function FindXtFunc(node, name)
    if type(node) ~= "table" then
        return
    end
    if rawget(node, "name") == name and node.func then
        return node
    end
    for _, child in ipairs(node) do
        local found = FindXtFunc(child, name)
        if found then
            return found
        end
    end
end

local function NotCombatMode()
    return false
end

---- The part popup is the only place that blocks modifying in combat (InventoryIsCombatMode, twice).
local function PatchModifyInCombat()
    local element = FindXtFunc(XTemplates.WeaponModChoicePopup, "ModifyPartPreview(self, partId, reason)")
    if not element or element.rat_combat_wrapped then
        return
    end
    local orig = element.func
    element:SetProperty("func", function(...)
        if not CheatEnabled("RatModifyInCombat") then
            return orig(...)
        end
        local real = InventoryIsCombatMode
        InventoryIsCombatMode = NotCombatMode
        local ok, err = pcall(orig, ...)
        InventoryIsCombatMode = real
        if not ok then
            error(err, 0)
        end
    end)
    element.rat_combat_wrapped = true
end

local function SwapEffectOn(obj, old_id, new_id)
    local effect = obj and obj:GetStatusEffect(old_id)
    if not effect then
        return false
    end
    local stacks = effect.stacks or 1
    obj:RemoveStatusEffect(old_id, "all")
    if new_id then
        obj:AddStatusEffect(new_id, stacks)
    end
    return true
end

---- Console: Rat_SwapEffect("NightOps", "Spiritual") swaps on SelectedObj, both the Unit and its gv_UnitData.
---- `who`: unit, session_id, or "all" (every unit with old_id). new_id nil only removes.
function Rat_SwapEffect(old_id, new_id, who)
    if not CharacterEffectDefs[old_id] or new_id and not CharacterEffectDefs[new_id] then
        return "unknown effect id"
    end
    local ids = {}
    if who == "all" then
        for id, ud in pairs(gv_UnitData or empty_table) do
            if ud:GetStatusEffect(old_id) then
                ids[#ids + 1] = id
            end
        end
        for _, u in ipairs(g_Units or empty_table) do
            if u:GetStatusEffect(old_id) and not table.find(ids, u.session_id) then
                ids[#ids + 1] = u.session_id
            end
        end
    else
        who = who or SelectedObj
        local id = type(who) == "string" and who or IsKindOfClasses(who, "Unit", "UnitData") and who.session_id
        if not id then
            return "no unit"
        end
        ids[1] = id
    end
    local done = {}
    for _, id in ipairs(ids) do
        local on_unit = SwapEffectOn(g_Units[id], old_id, new_id)
        local on_data = SwapEffectOn(gv_UnitData[id], old_id, new_id)
        if on_unit or on_data then
            done[#done + 1] = string.format("%s (unit %s, data %s)", id, tostring(on_unit), tostring(on_data))
            if g_Units[id] then
                ObjModified(g_Units[id])
            end
            if gv_UnitData[id] then
                ObjModified(gv_UnitData[id])
            end
        end
    end
    return #done > 0 and table.concat(done, ", ") or "nothing had " .. old_id
end

function OnMsg.ModsReloaded()
    AppendToggleCheat("idToggleRatZeroDispersion", T(482193570611, "aCTH Zero Dispersion (toggle)"), "RatZeroDispersion",
                      "idToggleAlwaysMiss", "COMBAT")
    AppendToggleCheat("idToggleRatModifyInCombat", Untranslated("Modify Weapons in Combat (toggle)"), "RatModifyInCombat",
                      "idToggleFreeParts", "GENERAL")
    PatchModifyInCombat()
end

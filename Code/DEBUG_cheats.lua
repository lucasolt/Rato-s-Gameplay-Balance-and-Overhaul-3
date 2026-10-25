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

function OnMsg.ModsReloaded()
    AppendToggleCheat("idToggleRatZeroDispersion", T(482193570611, "aCTH Zero Dispersion (toggle)"), "RatZeroDispersion",
                      "idToggleAlwaysMiss", "COMBAT")
    AppendToggleCheat("idToggleRatModifyInCombat", Untranslated("Modify Weapons in Combat (toggle)"), "RatModifyInCombat",
                      "idToggleFreeParts", "GENERAL")
    PatchModifyInCombat()
end

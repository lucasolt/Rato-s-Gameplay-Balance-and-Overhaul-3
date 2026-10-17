---- Cheats menu (in-game Esc > Cheats > COMBAT) entries for aCTH debugging
local function AppendZeroDispersionCheat()
    if UIFindControl("IGMainActions", "idToggleRatZeroDispersion") then
        return
    end
    local _, parent, idx = UIFindControl("IGMainActions", "idToggleAlwaysMiss")
    if not parent then
        return
    end
    table.insert(parent, idx + 1, PlaceObj('XTemplateAction', {
        'comment', "cheat",
        'ActionId', "idToggleRatZeroDispersion",
        'ActionName', T(482193570611, "aCTH Zero Dispersion (toggle)"),
        'ActionToolbar', "cheats",
        'ActionToolbarSection', "COMBAT",
        'OnAction', function(self, host, source, ...)
            NetSyncCheatEnableIG("RatZeroDispersion")
            CloseMenuDialogs()
        end,
    }))
end

function OnMsg.ModsReloaded()
    AppendZeroDispersionCheat()
end

---- Beaten Zone makes Strength Gold a 4-perk cell; vanilla 74 px buttons push it past the PDA edge.
---- Slots shrink uniformly so 3+3+4 fit the fixed-width grid (icon art draws at a fixed scale, so it is not cut).
local PERK_BUTTON_SIZE = 68
local PERK_BUTTON_MARGIN = 2

function Rat_PerkGridFit()
    local function walk(node)
        for _, child in ipairs(node) do
            if type(child) == "table" then
                if child.__template == "PDAPerkLevelUp" then
                    child:SetProperty("MinWidth", PERK_BUTTON_SIZE)
                    child:SetProperty("MaxWidth", PERK_BUTTON_SIZE)
                    child:SetProperty("MinHeight", PERK_BUTTON_SIZE)
                    child:SetProperty("MaxHeight", PERK_BUTTON_SIZE)
                    child:SetProperty("Margins", box(PERK_BUTTON_MARGIN, PERK_BUTTON_MARGIN, PERK_BUTTON_MARGIN,
                                                     PERK_BUTTON_MARGIN))
                end
                walk(child)
            end
        end
    end
    walk(XTemplates.PDAPerks)
end

OnMsg.ModsReloaded = Rat_PerkGridFit

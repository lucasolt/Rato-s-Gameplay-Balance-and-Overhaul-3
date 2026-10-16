---- PartsGainPct scales the Parts the player gains from scrapping, loot and salvage spots.
---- Trap disarms (1-2 parts) and refunds of sector operation costs are left alone.

function Rat_ScaleParts(n)
    return MulDivRound(n, CurrentModOptions.PartsGainPct or 100, 100)
end

---- Scaled per item, so the scrap entry in the context menu shows what will be paid.
local orig_scrap_cond = ItemWithCondition.AmountOfScrapPartsFromItem
function ItemWithCondition:AmountOfScrapPartsFromItem()
    return Rat_ScaleParts(orig_scrap_cond(self))
end

local orig_scrap = ScrapableItem.AmountOfScrapPartsFromItem
function ScrapableItem:AmountOfScrapPartsFromItem()
    return Rat_ScaleParts(orig_scrap(self))
end

local orig_loot = LootEntryInventoryItem.GenerateLoot
function LootEntryInventoryItem:GenerateLoot(looter, looted, seed, items)
    local start = #items
    orig_loot(self, looter, looted, seed, items)
    if self.item ~= "Parts" then
        return
    end
    for i = #items, start + 1, -1 do
        local amount = Rat_ScaleParts(items[i].Amount)
        if amount > 0 then
            items[i].Amount = amount
        else
            DoneObject(items[i])
            table.remove(items, i)
        end
    end
end

---- RangeGrantMarker:Grant with the amount scaled; its return value feeds the floating text.
function SalvageMarker:Grant(unit)
    self.granted = true
    local grant_amount = self.grant_item_min + InteractionRand(self.grant_item_max - self.grant_item_min, "Loot")
    grant_amount = Rat_ScaleParts(grant_amount + (self:GetItemGainModifier() / 2))
    if grant_amount <= 0 then
        return 0
    end
    local left_amount = AddItemToSquadBag(unit.Squad, self.grant_item_class, grant_amount)
    if left_amount then
        unit:AddToInventory(self.grant_item_class, left_amount)
    end
    return grant_amount
end

local file_str = 'CTH_gasmask.lua'

---- Replaces vanilla's -1 AP at turn start (removed from Unit:BeginTurn in SOURCE_APScale_vanilla.lua).
local GasMaskCTHPenalty = -6

function place_gasmask_cth()
    PlaceObj('ChanceToHitModifier', {
        CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof,
                             aim, opportunity_attack, attacker_pos, target_pos)
            if not attacker or not attacker:GetItemInSlot("Head", "GasMaskBase") then
                return false, 0
            end
            return true, GasMaskCTHPenalty
        end,
        RequireTarget = true,
        RequireActionType = "Any Ranged Attack",
        display_name = ratT(file_str, 583104726915, "Gas Mask"),
        group = "Default",
        id = "_gasmask",
    })

    local hints = {
        GasMask = ratT(file_str, 271946385027, "<bullet_point> Ranged attacks are less accurate\n<bullet_point> Protects from gas grenades and gas mortar shells\n<bullet_point> Can't be combined with weave or ceramics"),
        Gasmaskenhelm = ratT(file_str, 846215930714, "<bullet_point> Ranged attacks are less accurate\n<bullet_point> Protects from gas grenades and gas mortar shells\n<bullet_point> Can't be combined with weave or ceramics"),
    }
    for id, hint in pairs(hints) do
        ---- item instances read the generated class, not the preset
        if InventoryItemDefs[id] then
            InventoryItemDefs[id].AdditionalHint = hint
        end
        if g_Classes[id] then
            g_Classes[id].AdditionalHint = hint
        end
    end
end

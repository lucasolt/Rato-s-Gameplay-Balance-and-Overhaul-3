function gunshurt()

    local function extractNumberWithSignFromString(str)
        if not str then
            return false
        end
        local num = tonumber(string.match(str, "[+-]?%d+"))
        if num then
            return num
        else
            return false
        end
    end

    local mul = extractNumberWithSignFromString(CurrentModOptions['guns_hurt']) or 100

    ForEachPreset("InventoryItemCompositeDef", function(w)
        local item = g_Classes[w.id]
        if IsKindOf(item, "Firearm") and not IsKindOf(item, "HeavyWeapon") and item.Damage > 0 then
            local orig = ratG_GunsHurtOriginalDMGValues[item.class]
            ---- a ReloadLua rebuilds the class with fresh values; recapture instead of trusting the old snapshot
            if not orig or orig.cls ~= item then
                orig = {
                    cls = item,
                    dmg = item.Damage,
                    basedmg = item.base_Damage
                }
                ratG_GunsHurtOriginalDMGValues[item.class] = orig
            end

            item.Damage = MulDivRound(orig.dmg, mul, 100)
            item.base_Damage = MulDivRound(orig.basedmg, mul, 100)

            if Platform.developer and Platform.rat then
                print("----------")
                print("ID:", item.class)
                print("original dmg:", orig.dmg)
                print("dmg:", item.Damage)
            end
        end
    end)
end

function OnMsg.ApplyModOptions(id)

    if id ~= CurrentModId then
        return
    end

    gunshurt()
end

function OnMsg.ModsReloaded()
    gunshurt()
end

---- ReloadLua rebuilds weapon classes without firing ModsReloaded
function OnMsg.ClassesBuilt()
    gunshurt()
end

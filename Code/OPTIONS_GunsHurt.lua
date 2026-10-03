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
            if not orig then
                orig = {
                    dmg = item.Damage,
                    basedmg = item.base_Damage
                }
                ratG_GunsHurtOriginalDMGValues[item.class] = orig
            end

            ---- the caliber rule reads the current Caliber, which Zulib swaps after the build
            local caliber_dmg = Rat_IsLiveFirearm(item) and
                                    Rat_CaliberDamage(item.Caliber, item.rat_barrel_len)
            item.Damage = MulDivRound(caliber_dmg or orig.dmg, mul, 100)
            item.base_Damage = MulDivRound(caliber_dmg or orig.basedmg, mul, 100)

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

---- Zulib's ModsReloaded may run after ours; its caliber swaps change the caliber damage
function OnMsg.zulib_CoreSetupFinished()
    gunshurt()
end

---- ReloadLua rebuilds weapon classes without firing ModsReloaded; it reuses the class tables, so
---- identity can't detect a rebuild: a fresh build means fresh originals
function OnMsg.ClassesBuilt()
    table.clear(ratG_GunsHurtOriginalDMGValues)
    gunshurt()
end

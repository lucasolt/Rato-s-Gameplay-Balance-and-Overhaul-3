-- Magazine items without Revised Mags: run in a game started WITHOUT it.
-- python tools/dap_eval.py --quiet -c -f tools/mag_audit.lua  -> AppData/mag_audit.txt
if IsMod_loaded(RAT_ATT_REVMAGS) then
    return "Revised Mags is loaded: its own items replace ours, restart without it"
end
local nofam, noitem, fits = {}, {}, {}
ForEachPreset("InventoryItemCompositeDef", function(p)
    local w = g_Classes[p.id]
    if not IsKindOf(w, "Firearm") or not (IsVanillaFirearm(w) or w.is_tog_patched) then
        return
    end
    local slot = table.find_value(w.ComponentSlots or empty_table, "SlotType", "Magazine")
    local comps = slot and slot.AvailableComponents or empty_table
    if not slot or not slot.Modifiable or (#comps == 1 and not slot.CanBeEmpty) then
        return
    end
    for _, cid in ipairs(comps) do
        if cid ~= slot.DefaultComponent then
            local tag = p.id .. " [" .. tostring(w.Caliber) .. "/" .. tostring(w.WeaponType) .. "] " .. cid
            local family = RAT_ATT_FAMILY_OF[cid]
            local item = Rat_AttItemFor(cid, w)
            if not family then
                nofam[#nofam + 1] = tag
            elseif not item then
                noitem[#noitem + 1] = tag .. " -> " .. family
            else
                fits[item] = true
            end
        end
    end
end)
local unused = {}
for _, def in ipairs(RAT_ATT_ITEMS) do
    if def.mag and not fits[def.id] then
        unused[#unused + 1] = def.id
    end
end
table.sort(nofam)
table.sort(noitem)
AsyncStringToFile("AppData/mag_audit.txt",
    "== mag component in no family: free swap, parts only ==\n" .. table.concat(nofam, "\n") ..
        "\n== family has no item for this gun: free ==\n" .. table.concat(noitem, "\n") ..
        "\n== item no live gun takes: never sold ==\n" .. table.concat(unused, "\n"))
return #nofam .. " no family / " .. #noitem .. " no item / " .. #unused .. " unused -> AppData/mag_audit.txt"

---- Dev tool (not loaded by the mod): pins a copy of the current aim ring for screenshots.
---- loadfile("AppData/Mods/Rato-s-Gameplay-Balance-and-Overhaul-3/tools/pin_ring.lua")("pin" | "add" | "unpin")
---- "pin" replaces the pinned rings, "add" keeps them and pins one more.
---- The copy is a plain Polyline, so Rat_SweepConeRings ignores it; its mesh is rebuilt every
---- frame because the ribbon width faces camera.GetEye().
local mode = ...
local parent = const.Combat.Aperture.ConeRingParent or "Polyline"

local function unpin()
    local n = 0
    MapForEach("map", parent, function(o)
        if o.rat_pin then
            n = n + 1
            DeleteThread(o.rat_pin_thread)
            DoneObject(o)
        end
    end)
    return n
end

if mode == "unpin" then
    return "removed " .. unpin()
end

if mode ~= "add" then
    unpin()
end
local n = 0
for id, rec in pairs(Rat_LastStroke()) do
    local live = Rat_LiveStrokes()[id]
    if rec.pts and #rec.pts >= 2 and IsValid(live) then
        local obj = PlaceObject(parent)
        obj.rat_pin = true
        local st = Rat_StrokeStyle(obj, id)
        local color = (st and st.color) or rec.color_raw
        local pts = table.copy(rec.pts, "deep")
        obj:SetPos(rec.anchor or pts[1])
        obj:SetMesh(Rat_StrokeMesh(id, pts, color, st))
        obj:SetVisible(true)
        obj.rat_pin_thread = CreateRealTimeThread(function()
            while IsValid(obj) do
                obj:SetMesh(Rat_StrokeMesh(id, pts, color, st))
                Sleep(16)
            end
        end)
        n = n + 1
    end
end
return "pinned " .. n

---- Console tools for Code/FEATURE_MapLightBoost.lua. Load: dofile("Mod/cfahRED/tools/light_tuning.lua")
---- Settings last until the next Lua reload; make them permanent in RAT_MAP_LIGHT_BOOST.
---- rawset: console tool, runtime globals are otherwise refused.

local cfg = RAT_MAP_LIGHT_BOOST

---- pct: total visual brightness (200 = twice vanilla). radius_pct: companion reach vs the source's.
---- placed: also boost lights placed directly on the map. shadows: companions cast shadows (costly).
rawset(_G, "RatLights", function(pct, radius_pct, placed, shadows)
    cfg.pct = pct or 200
    cfg.radius_pct = radius_pct or 100
    cfg.placed = placed or false
    cfg.shadows = shadows ~= false
    local n = Rat_MapLightsRefresh()
    print(string.format("RatLights: %d sources at %d%%, radius %d%%, placed %s, shadows %s",
        n, cfg.pct, cfg.radius_pct, tostring(cfg.placed), tostring(cfg.shadows)))
end)

---- Falloff override for all companions; nil copies each source's. shape 0-255, constant -128..127.
rawset(_G, "RatLightsShape", function(shape, constant)
    cfg.shape = shape or false
    cfg.constant = constant or false
    Rat_MapLightsRefresh()
    print(string.format("RatLights: shape %s, constant %s", tostring(shape or "source"), tostring(constant or "source")))
end)

rawset(_G, "RatLightsOff", function()
    cfg.pct = 100
    Rat_MapLightsRefresh()
    print("RatLights: off")
end)

---- Sources grouped by parent, with the companion's current values
rawset(_G, "RatLightsInfo", function()
    local groups = {}
    MapForEach("map", "Light", function(l)
        if not l.rat_companion and l:IsSyncObject() then
            local p = GetTopmostParent(l)
            if IsKindOf(p, "Unit") or IsKindOf(p, "GrenadeVisual") then
                return
            end
            local extra = RatMapLightCompanions[l]
            local key = string.format("%s I%d R%d S%d C%d +I%d R%d", p == l and "(placed)" or p.class, l:GetIntensity(),
                l:GetAttenuationRadius(), l:GetAttenuationShape(), l:GetConstantIntensity(),
                IsValid(extra) and extra:GetIntensity() or 0, IsValid(extra) and extra:GetAttenuationRadius() or 0)
            groups[key] = (groups[key] or 0) + 1
        end
    end)
    for key, n in sorted_pairs(groups) do
        print(n .. "x " .. key)
    end
end)

---- Lit-voxel overlay: 1st call around the camera, 2nd whole map, 3rd off
rawset(_G, "RatLit", function()
    CycleVSDbgVisMode()
end)

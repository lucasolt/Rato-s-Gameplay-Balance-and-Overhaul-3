---- Console tools: visual-only boost of map light sources. Load: dofile("Mod/cfahRED/tools/light_tuning.lua")
---- Each source gets an unsynced companion PointLight, kept out of the stealth voxel scan.
---- rawset: console tool, runtime globals are otherwise refused.

local state = rawget(_G, "RatLightState") or {companions = {}, cfg = false, thread = false, saving = false}
rawset(_G, "RatLightState", state)

---- Only synced lights define what is lit; units and FX carry their own lights
local function is_source(l, placed)
    if not IsValid(l) or l.rat_companion or not l:IsSyncObject() then
        return false
    end
    local p = GetTopmostParent(l)
    if p == l then
        return placed
    end
    return not (IsKindOf(p, "Unit") or IsKindOf(p, "GrenadeVisual") or p.class:find("Window"))
end

local function place_companion(l, cfg)
    local extra = state.companions[l]
    if not IsValid(extra) then
        extra = PlaceObject("PointLight")
        extra.rat_companion = true
        extra:ClearEnumFlags(const.efVsPointLight | const.efVsSpotLight)
        ---- the renderer skips Lua-placed lights without it; it also makes them saved, hence the save hooks
        extra:SetGameFlags(const.gofPermanent)
        state.companions[l] = extra
    end
    local base = l:GetIntensity()
    extra:SetPos(l:GetVisualPos())
    extra:SetColor(l:GetColor())
    extra:SetIntensity(Clamp(MulDivRound(base, cfg.pct - 100, 100), 0, 255))
    extra:SetAttenuationRadius(MulDivRound(l:GetAttenuationRadius(), cfg.radius_pct, 100))
    extra:SetCastShadows(cfg.shadows)
end

local function remove_companion(l)
    local extra = state.companions[l]
    if IsValid(extra) then
        DoneObject(extra)
    end
    state.companions[l] = nil
end

local function refresh()
    local cfg = not state.saving and state.cfg
    for l in pairs(state.companions) do
        if not cfg or not is_source(l, cfg.placed) then
            remove_companion(l)
        end
    end
    if not cfg then
        return 0
    end
    local n = 0
    MapForEach("map", "Light", function(l)
        if is_source(l, cfg.placed) then
            place_companion(l, cfg)
            n = n + 1
        end
    end)
    return n
end

---- Sources come and go with the LightsOn game state
local function ensure_thread()
    if IsValidThread(state.thread) then
        return
    end
    state.thread = CreateMapRealTimeThread(function()
        while state.cfg do
            Sleep(1000)
            refresh()
        end
        state.thread = false
    end)
end

---- Hooks append on every dofile: register once, call through state
state.on_save = function(saving)
    state.saving = saving
    refresh()
end
if not state.hooked then
    state.hooked = true
    OnMsg.SaveGameStart = function() state.on_save(true) end
    OnMsg.SaveGameDone = function() state.on_save(false) end
end

---- pct: total visual brightness (200 = twice vanilla). radius_pct: companion reach vs the source's.
---- placed: also boost lights placed directly on the map. shadows: companions cast shadows (costly).
rawset(_G, "RatLights", function(pct, radius_pct, placed, shadows)
    pct = pct or 200
    if pct <= 100 then
        return RatLightsOff()
    end
    state.cfg = {pct = pct, radius_pct = radius_pct or 100, placed = placed or false, shadows = shadows ~= false}
    local n = refresh()
    ensure_thread()
    print(string.format("RatLights: %d sources at %d%%, radius %d%%, placed %s, shadows %s",
        n, pct, state.cfg.radius_pct, tostring(state.cfg.placed), tostring(state.cfg.shadows)))
end)

rawset(_G, "RatLightsOff", function()
    state.cfg = false
    refresh()
    print("RatLights: off")
end)

---- Sources grouped by parent, with the companion's current values
rawset(_G, "RatLightsInfo", function()
    local groups = {}
    MapForEach("map", "Light", function(l)
        if is_source(l, true) then
            local p = GetTopmostParent(l)
            local extra = state.companions[l]
            local key = string.format("%s I%d R%d +I%d", p == l and "(placed)" or p.class, l:GetIntensity(),
                l:GetAttenuationRadius(), IsValid(extra) and extra:GetIntensity() or 0)
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

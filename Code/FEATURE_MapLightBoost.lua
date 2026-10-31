---------------------------------------------------------------------------------------------------
---- MAP LIGHT BOOST -- visual-only brighter lamps. Console tuning: tools/light_tuning.lua
---------------------------------------------------------------------------------------------------

---- pct: total visual brightness (100 = off). radius_pct: companion reach vs the source's.
---- placed: also lights placed directly on the map. shape/constant: falloff override, false copies the source.
RAT_MAP_LIGHT_BOOST = {pct = 350, radius_pct = 100, placed = false, shadows = true, shape = false, constant = false}

---- Each source gets an unsynced companion of its own shape (PointLight or SpotLight), kept out of the stealth voxel scan
MapVar("RatMapLightCompanions", {})
local saving = false

---- Only synced lights define what is lit; units and FX carry their own lights
local function IsBoostSource(l, placed)
    if not IsValid(l) or l.rat_companion or not l:IsSyncObject() then
        return false
    end
    local p = GetTopmostParent(l)
    if p == l then
        return placed
    end
    return not (IsKindOf(p, "Unit") or IsKindOf(p, "GrenadeVisual") or p.class:find("Window"))
end

local function PlaceCompanion(l, cfg)
    local extra = RatMapLightCompanions[l]
    ---- a spot source gets a spot companion: a point one lit a full disc around a cone the voxels never see
    local class = IsKindOf(l, "SpotLight") and "SpotLight" or "PointLight"
    if IsValid(extra) and extra.class ~= class then
        DoneObject(extra)
        extra = nil
    end
    if not IsValid(extra) then
        extra = PlaceObject(class)
        extra.rat_companion = true
        extra:ClearEnumFlags(const.efVsPointLight | const.efVsSpotLight)
        ---- the renderer skips Lua-placed lights without it; it also makes them saved, hence the save hooks
        extra:SetGameFlags(const.gofPermanent)
        RatMapLightCompanions[l] = extra
    end
    extra:SetPos(l:GetVisualPos())
    extra:SetColor(l:GetColor())
    extra:SetIntensity(Clamp(MulDivRound(l:GetIntensity(), cfg.pct - 100, 100), 0, 255))
    extra:SetAttenuationRadius(MulDivRound(l:GetAttenuationRadius(), cfg.radius_pct, 100))
    extra:SetCastShadows(cfg.shadows)
    ---- PlaceObject starts at shape 0 / constant 0, the softest falloff; map lamps tune both
    extra:SetAttenuationShape(cfg.shape or l:GetAttenuationShape())
    extra:SetConstantIntensity(cfg.constant or l:GetConstantIntensity())
    if class == "SpotLight" then
        extra:SetAxis(l:GetVisualAxis())
        extra:SetAngle(l:GetVisualAngle())
        extra:SetConeInnerAngle(l:GetConeInnerAngle())
        extra:SetConeOuterAngle(l:GetConeOuterAngle())
    end
end

local function RemoveCompanion(l)
    local extra = RatMapLightCompanions[l]
    if IsValid(extra) then
        DoneObject(extra)
    end
    RatMapLightCompanions[l] = nil
end

function Rat_MapLightsRefresh()
    local cfg = RAT_MAP_LIGHT_BOOST
    local on = not saving and cfg.pct > 100
    for l in pairs(RatMapLightCompanions) do
        if not on or not IsBoostSource(l, cfg.placed) then
            RemoveCompanion(l)
        end
    end
    ---- companions orphaned by a Lua reload (MapVar reset) or saved by an older version
    local tracked = table.invert(RatMapLightCompanions)
    MapForEach("map", "PointLight", function(extra)
        if extra.rat_companion and not tracked[extra] then
            DoneObject(extra)
        end
    end)
    if not on then
        return 0
    end
    local n = 0
    MapForEach("map", "Light", function(l)
        if IsBoostSource(l, cfg.placed) then
            PlaceCompanion(l, cfg)
            n = n + 1
        end
    end)
    return n
end

function OnMsg.SaveGameStart()
    saving = true
    Rat_MapLightsRefresh()
end

function OnMsg.SaveGameDone()
    saving = false
    Rat_MapLightsRefresh()
end

---- Sources come and go with the LightsOn game state
---- the callback's return is the next sleep: the light count (often 0) spun the loading screen forever
MapRealTimeRepeat("RatMapLightBoost", 1000, function()
    Rat_MapLightsRefresh()
end)

---------------------------------------------------------------------------------------------------
---- NIGHT VISUALS -- darker night lightmodels, and the map darkens past the distance the selected
---- merc sees: a target in the dark at night, any target by day.
---------------------------------------------------------------------------------------------------

---- Auto-exposure key drop per NightDarkness step. Exposure itself is undone by auto-exposure.
RAT_NIGHT_KEY_STEP = 100000
---- Shade outside the disc: edge fade width, outer reach. Opacity is NightSightShade / DaySightShade.
---- A light inside the disc was tried first: it glints on wet ground, water and foliage.
RAT_NIGHT_SHADE_FADE = 4 * guim
RAT_NIGHT_SHADE_REACH = 200 * guim
RAT_NIGHT_SHADE_SEGMENTS = 144
---- Fine band past the radius where lit spots cut holes; beyond it the shade is one flat band
RAT_NIGHT_SHADE_FINE = 40 * guim
RAT_NIGHT_SHADE_STEP = 2 * guim
---- Hole around a lit tile / a lit visible unit: fully clear inside, fading back over `fade`
RAT_NIGHT_HOLE_TILE = {clear = guim / 2, fade = 2 * guim}
RAT_NIGHT_HOLE_UNIT = {clear = guim, fade = 2 * guim}
---- Minimum ms between rebuilds while something moves
RAT_NIGHT_REBUILD_MIN = 250

function Rat_IsNightLightmodel(lm)
    if not lm or not lm.night then
        return false
    end
    local id = (lm.id or ""):lower()
    return not id:find("sunrise") and not id:find("sunset")
end

---- Darkened copies, rebuilt when the preset table or the option changes
local night_copies = setmetatable({}, weak_keys_meta)

function Rat_NightLightmodel(lm)
    local level = GBO_Opt("NightDarkness", 8)
    if level <= 0 or LightmodelOverride or type(lm) ~= "table" or not Rat_IsNightLightmodel(lm) then
        return lm
    end
    local entry = night_copies[lm]
    if not entry or entry.level ~= level then
        local copy = setmetatable(table.raw_copy(lm), getmetatable(lm))
        copy.ae_key_bias = (lm.ae_key_bias or 0) - level * RAT_NIGHT_KEY_STEP
        entry = {level = level, copy = copy}
        night_copies[lm] = entry
    end
    return entry.copy
end

---- CurrentLightmodel keeps the preset, so GameState and lightmodel rules still read vanilla
local orig = Rat_AttOriginal(DoSetLightmodel)
function DoSetLightmodel(view, lm_buf, ...)
    return orig(view, Rat_NightLightmodel(lm_buf), ...)
end
RAT_ATT_WRAPS[DoSetLightmodel] = orig

function Rat_ReapplyNightLightmodel()
    local lm = CurrentLightmodel and CurrentLightmodel[1]
    if lm then
        DoSetLightmodel(1, lm, 0)
    end
end

---------------------------------------------------------------------------------------------------
---- Sight disc
---------------------------------------------------------------------------------------------------

local function IsNightShade()
    return GameState.Night or GameState.Underground
end

---- GetSightRadius against a dark target at night (any target by day), minus the per-target terms
---- (stealth, camo, grass, height)
function Rat_ShadeSightRadius(unit)
    local sight = unit:IsAware() and const.Combat.AwareSightRange or const.Combat.UnawareSightRange
    local modifier = 100
    if IsNightShade() then
        local dark = const.EnvEffects.DarknessSightMod
        if unit:HasNightVision() then
            dark = MulDivRound(dark, CharacterEffectDefs.NightOps:ResolveValue("night_vision_penalty_reduction"), 100)
        end
        modifier = modifier + dark
    end
    if GameState.Fog then
        modifier = modifier + const.EnvEffects.FogSightMod
    end
    if GameState.DustStorm then
        modifier = modifier + const.EnvEffects.DustStormSightMod
    end
    if GameState.FireStorm then
        modifier = modifier + const.EnvEffects.FireStormSightMod
    end
    modifier = Clamp(modifier, const.Combat.SightModMinValue, const.Combat.SightModMaxValue)
    return MulDivRound(sight, modifier, 100) * const.SlabSizeX
end

local disc_mesh = false
local disc_key = false
local disc_built_at = 0
---- Saving the mod reloads this file and drops disc_mesh: sweep the tagged orphans once per load
local orphans_swept = false

---- Shade opacity 0..255 for the current time of day
local function ShadeAlpha()
    local pct = IsNightShade() and GBO_Opt("NightSightShade", 55) or GBO_Opt("DaySightShade", 35)
    return MulDivRound(255, Clamp(pct, 0, 100), 100)
end

local function DiscUnit()
    if ShadeAlpha() <= 0 or gv_SatelliteView or IsSetpiecePlaying() then
        return
    end
    local u = SelectedObj
    if not IsKindOf(u, "Unit") or u:IsDead() or not u:IsLocalPlayerControlled() or not u:IsValidPos() then
        return
    end
    return u
end

function Rat_NightDiscRemove()
    if IsValid(disc_mesh) then
        DoneObject(disc_mesh)
    end
    disc_mesh = false
    disc_key = false
end

---------------------------------------------------------------------------------------------------
---- Holes: lit tiles around stealth lights (the voxel flag IsIlluminated reads), and visible units
---- that count as lit anyway (fire, IgnoreInTheDark weapons). Light radius is no guide to the lit
---- area: measured lit ground reaches ~60-70% of it, and nothing on floors the light can't reach.
---------------------------------------------------------------------------------------------------

---- Lit tiles per light, scanned once (~13 us per tile read); cleared when lights change
local light_tiles = setmetatable({}, weak_keys_meta)

local function LightTiles(l)
    local tiles = light_tiles[l]
    if tiles then
        return tiles
    end
    tiles = {}
    local lit_flag, tile = const.vsFlagIlluminated, const.SlabSizeX
    local p = l:GetPos()
    local cx, cy = p:x() / tile, p:y() / tile
    local n = (l.GetAttenuationRadius and l:GetAttenuationRadius() or 0) / tile + 1
    for gx = cx - n, cx + n do
        for gy = cy - n, cy + n do
            local q = GetPassSlab(point(gx * tile + tile / 2, gy * tile + tile / 2, p:z()))
            if q and band(GetVoxelStealthParams(q) or 0, lit_flag) ~= 0 then
                tiles[#tiles + 1] = q
            end
        end
    end
    light_tiles[l] = tiles
    return tiles
end

---- Stealth lights of the map, and the per-tile shade kept (0..1000) around their lit tiles.
---- Lights don't move: both are built once and dropped when lights change.
local stealth_lights = false
local lit_field = {}
---- lit_field at night, empty by day: lights reveal nothing in daylight
local active_field = empty_table
local lit_field_done = setmetatable({}, weak_keys_meta)

local function ResetLitCache()
    light_tiles = setmetatable({}, weak_keys_meta)
    stealth_lights = false
    lit_field = {}
    lit_field_done = setmetatable({}, weak_keys_meta)
    active_field = empty_table
    disc_key = false
end

OnMsg.LightsStateUpdated = ResetLitCache
OnMsg.NewMapLoaded = ResetLitCache

local function StealthLights()
    if not stealth_lights then
        stealth_lights = {}
        MapForEach("map", "Light", function(l)
            if IsLightSetupToAffectStealth(l) then
                stealth_lights[#stealth_lights + 1] = l
            end
        end)
    end
    return stealth_lights
end

local function TileKey(x, y)
    return (x / const.SlabSizeX) * 65536 + y / const.SlabSizeX
end

---- Shade kept at each tile offset from a lit tile: {key offset, keep}
local function TileHoleOffsets()
    local tile, h = const.SlabSizeX, RAT_NIGHT_HOLE_TILE
    local reach = (h.clear + h.fade) / tile + 1
    local offsets = {}
    for ox = -reach, reach do
        for oy = -reach, reach do
            local dx, dy = ox * tile, oy * tile
            local d = sqrt(dx * dx + dy * dy)
            if d < h.clear + h.fade then
                offsets[#offsets + 1] = {ox * 65536 + oy, d <= h.clear and 0 or MulDivRound(d - h.clear, 1000, h.fade)}
            end
        end
    end
    return offsets
end

---- Folds a light's lit tiles into lit_field
local function AddLightToField(l)
    if lit_field_done[l] then
        return
    end
    lit_field_done[l] = true
    local offsets = TileHoleOffsets()
    for _, t in ipairs(LightTiles(l)) do
        local base = TileKey(t:x(), t:y())
        for _, o in ipairs(offsets) do
            local key = base + o[1]
            local keep = lit_field[key]
            if not keep or o[2] < keep then
                lit_field[key] = o[2]
            end
        end
    end
end

---- Cells of NEAR mm that a hole reaches; a vertex reads its own cell only
local NEAR = 2 * guim

---- Marks the angular columns of the ring a hole can touch, so only those get fine rows
local function MarkColumns(cols, center, radius, x, y, reach)
    local dx, dy = x - center:x(), y - center:y()
    local d = sqrt(dx * dx + dy * dy)
    if d + reach < radius or d - reach > radius + RAT_NIGHT_SHADE_FINE then
        return false
    end
    local n = RAT_NIGHT_SHADE_SEGMENTS
    local col = atan(dy, dx) * n / (360 * 60)
    local span = d > 0 and reach * n / (6 * d) + 1 or n
    for c = col - span, col + span do
        cols[c % n] = true
    end
    return true
end

local function AddHole(near, x, y, hole)
    local reach = hole.clear + hole.fade
    local entry = {x, y, hole.clear, hole.fade}
    for kx = (x - reach) / NEAR, (x + reach) / NEAR do
        for ky = (y - reach) / NEAR, (y + reach) / NEAR do
            local key = kx * 65536 + ky
            local cell = near[key]
            if not cell then
                cell = {}
                near[key] = cell
            end
            cell[#cell + 1] = entry
        end
    end
end

---- 0..1000 of the shade kept at (x, y): lit field, then the unit holes in `near`
local function HoleKeep(near, x, y)
    local keep = active_field[TileKey(x, y)] or 1000
    local cell = near[(x / NEAR) * 65536 + y / NEAR]
    if not cell then
        return keep
    end
    for _, h in ipairs(cell) do
        local dx, dy = x - h[1], y - h[2]
        local d = sqrt(dx * dx + dy * dy)
        if d < h[3] + h[4] then
            keep = Min(keep, d <= h[3] and 0 or MulDivRound(d - h[3], 1000, h[4]))
        end
    end
    return keep
end

local unit_circle = false

---- Ring from the radius outwards: fades in over RAT_NIGHT_SHADE_FADE, holed in the fine band.
---- Columns without a hole skip the fine rows: one quad from the end of the fade to the far edge.
local function ShadeMesh(radius, center, near, cols, alpha)
    local n = RAT_NIGHT_SHADE_SEGMENTS
    local step = RAT_NIGHT_SHADE_STEP
    local rings = RAT_NIGHT_SHADE_FINE / step
    local fade_rows = (RAT_NIGHT_SHADE_FADE + step - 1) / step
    if not unit_circle or unit_circle.n ~= n then
        unit_circle = {n = n, x = {}, y = {}}
        for i = 0, n do
            local p = RotateRadius(4096, i * 360 * 60 / n)
            unit_circle.x[i], unit_circle.y[i] = p:x(), p:y()
        end
    end
    local ux, uy = unit_circle.x, unit_circle.y
    local cx, cy = center:x(), center:y()
    local px, py, pa = {}, {}, {}
    for k = 0, rings + 1 do
        local r = k <= rings and radius + k * step or radius + RAT_NIGHT_SHADE_FINE + RAT_NIGHT_SHADE_REACH
        local edge = Clamp(MulDivRound(r - radius, 1000, RAT_NIGHT_SHADE_FADE), 0, 1000)
        local ring_alpha = MulDivRound(alpha, edge, 1000)
        local ring_color = RGBA(0, 0, 0, ring_alpha)
        local fine = k > fade_rows and k <= rings
        local can_hole = k <= rings and edge > 0
        local row_x, row_y, row_a = {}, {}, {}
        for i = 0, n do
            local holed = cols[i % n] or cols[(i - 1) % n]
            if holed or not fine then
                local x, y = MulDivRound(ux[i], r, 4096), MulDivRound(uy[i], r, 4096)
                row_x[i], row_y[i] = x, y
                local keep = (can_hole and holed) and HoleKeep(near, cx + x, cy + y) or 1000
                row_a[i] = keep == 1000 and ring_color or RGBA(0, 0, 0, MulDivRound(ring_alpha, keep, 1000))
            end
        end
        px[k], py[k], pa[k] = row_x, row_y, row_a
    end
    local s = pstr("", n * (rings + 2) * 6 * 20)
    local function quad(k1, k2, i, j)
        local ax, ay, aa, bx, by, ba = px[k1], py[k1], pa[k1], px[k2], py[k2], pa[k2]
        s:AppendVertex(ax[i], ay[i], 0, aa[i]) s:AppendVertex(bx[i], by[i], 0, ba[i])
        s:AppendVertex(bx[j], by[j], 0, ba[j])
        s:AppendVertex(ax[i], ay[i], 0, aa[i]) s:AppendVertex(bx[j], by[j], 0, ba[j])
        s:AppendVertex(ax[j], ay[j], 0, aa[j])
    end
    for i = 0, n - 1 do
        local j = i + 1
        if cols[i] then
            for k = 0, rings do
                quad(k, k + 1, i, j)
            end
        else
            for k = 0, fade_rows - 1 do
                quad(k, k + 1, i, j)
            end
            quad(fade_rows, rings + 1, i, j)
        end
    end
    return s
end

function Rat_NightDiscUpdate()
    local u = DiscUnit()
    if not u then
        Rat_NightDiscRemove()
        return
    end
    local now = RealTime()
    local center = u:GetVisualPos()
    local radius = Rat_ShadeSightRadius(u)
    local alpha = ShadeAlpha()
    local night = IsNightShade()
    local far = radius + RAT_NIGHT_SHADE_FINE

    local sig = radius * 7 + alpha + (night and 17 or 0) + center:x() / (guim / 2) * 3 + center:y() / (guim / 2) * 5
    local units = {}
    for _, x in ipairs(g_Units) do
        ---- by day IsIlluminated is always true: every visible unit shows through
        if x ~= u and not x:IsDead() and x:GetEnumFlags(const.efVisible) ~= 0 and IsIlluminated(x) then
            local p = x:GetVisualPos()
            units[#units + 1] = p
            sig = sig + p:x() / (guim / 2) * 11 + p:y() / (guim / 2) * 13
        end
    end

    if not IsValid(disc_mesh) then
        if not orphans_swept then
            orphans_swept = true
            MapForEach("map", "Mesh", function(o)
                if o.rat_night_shade then
                    DoneObject(o)
                end
            end)
        end
        local m = PlaceObject("Mesh")
        m.rat_night_shade = true
        ---- no depth test: a flat ring at the merc's feet must still shade walls, roofs and canopies
        m:SetShader(ProceduralMeshShaders.default_mesh, false)
        disc_mesh = m
        disc_key = false
    end
    if sig == disc_key or disc_key and now - disc_built_at < RAT_NIGHT_REBUILD_MIN then
        return
    end
    disc_key, disc_built_at = sig, now

    local near, cols = {}, {}
    local tile_reach = RAT_NIGHT_HOLE_TILE.clear + RAT_NIGHT_HOLE_TILE.fade
    active_field = night and lit_field or empty_table
    for _, l in ipairs(night and StealthLights() or empty_table) do
        if IsValid(l) and IsCloser2D(l, center, far + 20 * guim) then
            AddLightToField(l)
            for _, t in ipairs(LightTiles(l)) do
                MarkColumns(cols, center, radius, t:x(), t:y(), tile_reach)
            end
        end
    end
    local unit_reach = RAT_NIGHT_HOLE_UNIT.clear + RAT_NIGHT_HOLE_UNIT.fade
    for _, p in ipairs(units) do
        if MarkColumns(cols, center, radius, p:x(), p:y(), unit_reach) then
            AddHole(near, p:x(), p:y(), RAT_NIGHT_HOLE_UNIT)
        end
    end
    disc_mesh:SetMesh(ShadeMesh(radius, center, near, cols, alpha))
    disc_mesh:SetPos(center + point(0, 0, 20))
end

MapRealTimeRepeat("RatNightDisc", 50, function()
    Rat_NightDiscUpdate()
end)

function OnMsg.ApplyModOptions(id)
    if id ~= CurrentModId then
        return
    end
    Rat_ReapplyNightLightmodel()
    Rat_NightDiscRemove()
end

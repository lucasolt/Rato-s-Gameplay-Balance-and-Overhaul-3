---------------------------------------------------------------------------------------------------
---- NIGHT VISUALS -- darker night lightmodels, and the map darkens past the distance the selected
---- merc sees: a target in the dark at night, any target by day.
---------------------------------------------------------------------------------------------------

---- Auto-exposure key drop per NightDarkness step. Exposure itself is undone by auto-exposure.
RAT_NIGHT_KEY_STEP = 100000
---- Shade outside the disc: edge fade width, outer reach. Opacity is SightShade, or WeatherShade under a tint.
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
---- Shade tint per sight-cutting weather, first match wins; black otherwise. Night keeps `night_pct` of it.
RAT_NIGHT_SHADE_TINTS = {
    {state = "FireStorm", r = 110, g = 40, b = 20},
    {state = "DustStorm", r = 150, g = 120, b = 80},
    {state = "Fog", r = 190, g = 195, b = 200},
}
RAT_NIGHT_SHADE_TINT_NIGHT_PCT = 35
---- SightShadeLOS: ms of CheckLOS per tick (~30 us per cell, one call can't be split), and columns per call
RAT_SHADE_LOS_BUDGET = 8
RAT_SHADE_LOS_BATCH = 4

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
    local level = GBO_Opt("NightDarkness", 12)
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
---- SightShadeLOS grid, its own mesh
local grid_mesh = false
local disc_key = false
local disc_built_at = 0
---- Saving the mod reloads this file and drops disc_mesh: sweep the tagged orphans once per load
local orphans_swept = false

local function ActiveTint()
    for _, t in ipairs(RAT_NIGHT_SHADE_TINTS) do
        if GameState[t.state] then
            return t
        end
    end
end

---- Shade opacity 0..255
local function ShadeAlpha()
    local pct = ActiveTint() and GBO_Opt("WeatherShade", 90) or GBO_Opt("SightShade", 90)
    return MulDivRound(255, Clamp(pct, 0, 100), 100)
end

local function ShadeTint()
    local t = ActiveTint()
    if not t then
        return 0, 0, 0
    end
    if IsNightShade() then
        local pct = RAT_NIGHT_SHADE_TINT_NIGHT_PCT
        return MulDivRound(t.r, pct, 100), MulDivRound(t.g, pct, 100), MulDivRound(t.b, pct, 100)
    end
    return t.r, t.g, t.b
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
    if IsValid(grid_mesh) then
        DoneObject(grid_mesh)
    end
    disc_mesh, grid_mesh = false, false
    disc_key = false
end

local function NewShadeMesh()
    local m = PlaceObject("Mesh")
    m.rat_night_shade = true
    ---- no depth test: a flat ring at the merc's feet must still shade walls, roofs and canopies
    m:SetShader(ProceduralMeshShaders.default_mesh, false)
    return m
end

---------------------------------------------------------------------------------------------------
---- Holes: lit tiles around stealth lights (the voxel flag IsIlluminated reads), and visible units
---- that count as lit anyway (fire, a flashlight beam on). Light radius is no guide to the lit
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

---- Lights placed or moved at runtime (weapon flashlights)
function Rat_NightShadeLightsChanged()
    ResetLitCache()
end

local function MapStealthLights()
    if not stealth_lights then
        stealth_lights = {}
        MapForEach("map", "Light", function(l)
            ---- a weapon flashlight reveals only from shooting stance (see FEATURE_WeaponFlashlight)
            local owner = l.rat_unit
            if IsLightSetupToAffectStealth(l) and (not owner or IsValid(owner) and owner:HasStatusEffect("shooting_stance")) then
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

---- 0..1000 of the shade kept at (x, y) by the unit holes in `near`
local function UnitKeep(near, x, y, keep)
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

---- Lit field, then the unit holes
local function HoleKeep(near, x, y)
    return UnitKeep(near, x, y, active_field[TileKey(x, y)] or 1000)
end

---------------------------------------------------------------------------------------------------
---- Line of sight inside the radius (SightShadeLOS). Vegetation never blocks sight in JA3 (grass only
---- shortens the range to a target standing in it), so CheckLOS alone matches what the merc sees.
---- One cell per tile along each column, filled a few columns per tick. A walking merc changes tile
---- faster than a job ends, so a job always runs out and the last built one stays drawn in place.
---------------------------------------------------------------------------------------------------
local los_job = false
local los_shown = false
local los_gen = 0

function OnMsg.NewMapLoaded()
    los_job, los_shown = false, false
end

local function LosEnabled()
    return CurrentModOptions and CurrentModOptions.SightShadeLOS
end

---- Shade kept 0..1000 per CheckLOS value: none, partial (1), full (2); partial still sees a unit there
local LOS_KEEP = {[1] = 0, [2] = 0}

local function LosStep(u, radius)
    local pos, stance = u:GetPos(), u.stance
    local job = los_job
    if not job or job.unit ~= u or job.built and (job.pos ~= pos or job.stance ~= stance or job.radius ~= radius) then
        job = {unit = u, pos = pos, z = u:GetVisualPos():z(), stance = stance, radius = radius,
               rows = Max(1, radius / const.SlabSizeX), keep = {}, col = 0}
        los_job = job
    end
    if job.done then
        return
    end
    local n = RAT_NIGHT_SHADE_SEGMENTS
    local start = GetPreciseTicks()
    while job.col < n and GetPreciseTicks() - start < RAT_SHADE_LOS_BUDGET do
        local first, last = job.col, Min(n, job.col + RAT_SHADE_LOS_BATCH) - 1
        local pts = {}
        for i = first, last do
            for j = 1, job.rows do
                local p = RotateRadius(MulDivRound(radius, j, job.rows), i * 360 * 60 / n, pos)
                pts[#pts + 1] = GetPassSlab(p) or p:SetTerrainZ()
            end
        end
        local _, vals = CheckLOS(pts, pos, -1, stance, -1, false, false)
        vals = vals or empty_table
        local k = 0
        for i = first, last do
            local col = {[0] = 0}
            for j = 1, job.rows do
                k = k + 1
                col[j] = LOS_KEEP[vals[k]] or 1000
            end
            job.keep[i] = col
        end
        job.col = last + 1
    end
    if job.col >= n then
        job.done = true
        los_gen = los_gen + 1
    end
end

local unit_circle = false

local function UnitCircle()
    local n = RAT_NIGHT_SHADE_SEGMENTS
    if not unit_circle or unit_circle.n ~= n then
        unit_circle = {n = n, x = {}, y = {}}
        for i = 0, n do
            local p = RotateRadius(4096, i * 360 * 60 / n)
            unit_circle.x[i], unit_circle.y[i] = p:x(), p:y()
        end
    end
    return unit_circle
end

---- Grid triangles of a finished job, a few columns per tick, relative to the job's tile. Static per
---- job and colour, so it lives in its own mesh and the ring rebuilds stay cheap. True when built.
local function LosBuildStep(job, alpha, cr, cg, cb)
    local color_key = ((alpha * 256 + cr) * 256 + cg) * 256 + cb
    if job.color_key ~= color_key then
        job.color_key, job.build_col, job.built = color_key, 0, false
        job.s, job.edge = pstr("", 4096), {}
    end
    if job.built then
        return true
    end
    local n, rows, radius = RAT_NIGHT_SHADE_SEGMENTS, job.rows, job.radius
    local circle = UnitCircle()
    local ux, uy = circle.x, circle.y
    local s = job.s
    local start = GetPreciseTicks()
    while job.build_col < n and GetPreciseTicks() - start < RAT_SHADE_LOS_BUDGET do
        local i = job.build_col
        local i2 = i + 1
        local ka, kb = job.keep[i], job.keep[i2 % n]
        job.edge[i] = MulDivRound(alpha, ka[rows], 1000)
        for j = 0, rows - 1 do
            local a1, a2, b1, b2 = ka[j], ka[j + 1], kb[j], kb[j + 1]
            if a1 + a2 + b1 + b2 > 0 then
                local r1, r2 = MulDivRound(radius, j, rows), MulDivRound(radius, j + 1, rows)
                local x1, y1 = MulDivRound(ux[i], r1, 4096), MulDivRound(uy[i], r1, 4096)
                local x2, y2 = MulDivRound(ux[i], r2, 4096), MulDivRound(uy[i], r2, 4096)
                local x3, y3 = MulDivRound(ux[i2], r2, 4096), MulDivRound(uy[i2], r2, 4096)
                local x4, y4 = MulDivRound(ux[i2], r1, 4096), MulDivRound(uy[i2], r1, 4096)
                local c1 = RGBA(cr, cg, cb, MulDivRound(alpha, a1, 1000))
                local c2 = RGBA(cr, cg, cb, MulDivRound(alpha, a2, 1000))
                local c3 = RGBA(cr, cg, cb, MulDivRound(alpha, b2, 1000))
                local c4 = RGBA(cr, cg, cb, MulDivRound(alpha, b1, 1000))
                s:AppendVertex(x1, y1, 0, c1) s:AppendVertex(x2, y2, 0, c2) s:AppendVertex(x3, y3, 0, c3)
                s:AppendVertex(x1, y1, 0, c1) s:AppendVertex(x3, y3, 0, c3) s:AppendVertex(x4, y4, 0, c4)
            end
        end
        job.build_col = i2
    end
    job.built = job.build_col >= n
    return job.built
end

---- Ring from the radius outwards: fades in over RAT_NIGHT_SHADE_FADE, holed in the fine band.
---- Columns without a hole skip the fine rows: one quad from the end of the fade to the far edge.
---- With a built `los` job the fade starts from the grid's edge shade, so blocked columns stay dark.
local function ShadeMesh(radius, center, near, cols, alpha, cr, cg, cb, los)
    local n = RAT_NIGHT_SHADE_SEGMENTS
    local step = RAT_NIGHT_SHADE_STEP
    local rings = RAT_NIGHT_SHADE_FINE / step
    ---- the grid already fades per tile; a 4 m fade past it would show a lit band beyond sight
    local fade = los and const.SlabSizeX or RAT_NIGHT_SHADE_FADE
    local fade_rows = (fade + step - 1) / step
    local circle = UnitCircle()
    local ux, uy = circle.x, circle.y
    local cx, cy = center:x(), center:y()
    local s = pstr("", n * (rings + 2) * 6 * 20)
    local los_edge = los and IsCloser2D(center, los.pos, guim) and los.edge
    local px, py, pa = {}, {}, {}
    for k = 0, rings + 1 do
        local r = k <= rings and radius + k * step or radius + RAT_NIGHT_SHADE_FINE + RAT_NIGHT_SHADE_REACH
        local edge = Clamp(MulDivRound(r - radius, 1000, fade), 0, 1000)
        local ring_alpha = MulDivRound(alpha, edge, 1000)
        local ring_color = RGBA(cr, cg, cb, ring_alpha)
        local fine = k > fade_rows and k <= rings
        local can_hole = k <= rings and edge > 0
        local row_x, row_y, row_a = {}, {}, {}
        for i = 0, n do
            local holed = cols[i % n] or cols[(i - 1) % n]
            if holed or not fine then
                local x, y = MulDivRound(ux[i], r, 4096), MulDivRound(uy[i], r, 4096)
                row_x[i], row_y[i] = x, y
                local keep = (can_hole and holed) and HoleKeep(near, cx + x, cy + y) or 1000
                local base = los_edge and Max(ring_alpha, los_edge[i % n]) or ring_alpha
                if base == ring_alpha and keep == 1000 then
                    row_a[i] = ring_color
                else
                    row_a[i] = RGBA(cr, cg, cb, MulDivRound(base, keep, 1000))
                end
            end
        end
        px[k], py[k], pa[k] = row_x, row_y, row_a
    end
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
    local cr, cg, cb = ShadeTint()
    local far = radius + RAT_NIGHT_SHADE_FINE

    local los
    if LosEnabled() then
        LosStep(u, radius)
        local job = los_job
        if job.done and LosBuildStep(job, alpha, cr, cg, cb) then
            los_shown = job
        end
        local shown = los_shown
        ---- another merc selected: the old ring and grid stay until the new grid is built, then both swap
        if shown and shown.unit ~= u and not job.built and IsValid(disc_mesh) then
            return
        end
        ---- a stale grid only while the merc is still inside it
        if shown and IsCloser2D(center, shown.pos, shown.radius) and LosBuildStep(shown, alpha, cr, cg, cb) then
            los = shown
        end
    end

    local sig = (los and los_gen or 0) * 29 + radius * 7 + alpha + (night and 17 or 0) + (cr * 65536 + cg * 256 + cb) * 19 + center:x() / (guim / 2) * 3 + center:y() / (guim / 2) * 5
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
        disc_mesh = NewShadeMesh()
        disc_key = false
    end
    if los then
        if not IsValid(grid_mesh) then
            grid_mesh = NewShadeMesh()
        end
        if grid_mesh.rat_job ~= los or grid_mesh.rat_color ~= los.color_key then
            grid_mesh.rat_job, grid_mesh.rat_color = los, los.color_key
            grid_mesh:SetMesh(los.s)
            grid_mesh:SetPos(los.pos:SetZ(los.z + 20))
        end
    elseif IsValid(grid_mesh) then
        DoneObject(grid_mesh)
        grid_mesh = false
    end
    if sig == disc_key or disc_key and now - disc_built_at < RAT_NIGHT_REBUILD_MIN then
        return
    end
    disc_key, disc_built_at = sig, now

    local near, cols = {}, {}
    local tile_reach = RAT_NIGHT_HOLE_TILE.clear + RAT_NIGHT_HOLE_TILE.fade
    active_field = night and lit_field or empty_table
    for _, l in ipairs(night and MapStealthLights() or empty_table) do
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
    disc_mesh:SetMesh(ShadeMesh(radius, center, near, cols, alpha, cr, cg, cb, los))
    disc_mesh:SetPos(center + point(0, 0, 20))
end

---- FX lights (flares) get their stealth twin at runtime without LightsStateUpdated
local stealth_twins = -1

MapRealTimeRepeat("RatNightDisc", 50, function()
    local n = #(StealthLights or empty_table)
    if n ~= stealth_twins then
        stealth_twins = n
        ResetLitCache()
    end
    Rat_NightDiscUpdate()
end)

function OnMsg.ApplyModOptions(id)
    if id ~= CurrentModId then
        return
    end
    Rat_ReapplyNightLightmodel()
    Rat_NightDiscRemove()
end

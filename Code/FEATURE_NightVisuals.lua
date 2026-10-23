---------------------------------------------------------------------------------------------------
---- NIGHT VISUALS -- darker night lightmodels, and the night darkens further past the distance
---- the selected merc sees a target standing in the dark.
---------------------------------------------------------------------------------------------------

---- Auto-exposure key drop per NightDarkness step. Exposure itself is undone by auto-exposure.
RAT_NIGHT_KEY_STEP = 100000
---- Shade outside the disc: alpha of the black ring, edge fade width, outer reach.
---- A light inside the disc was tried first: it glints on wet ground, water and foliage.
RAT_NIGHT_SHADE_ALPHA = 140
RAT_NIGHT_SHADE_FADE = 4 * guim
RAT_NIGHT_SHADE_REACH = 200 * guim
RAT_NIGHT_SHADE_SEGMENTS = 96

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

---- GetSightRadius against a dark target, minus the per-target terms (stealth, camo, grass, height)
function Rat_NightSightRadius(unit)
    local sight = unit:IsAware() and const.Combat.AwareSightRange or const.Combat.UnawareSightRange
    local dark = const.EnvEffects.DarknessSightMod
    if unit:HasNightVision() then
        dark = MulDivRound(dark, CharacterEffectDefs.NightOps:ResolveValue("night_vision_penalty_reduction"), 100)
    end
    local modifier = 100 + dark
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
local disc_radius = false

local function DiscUnit()
    if CurrentModOptions and CurrentModOptions.NightSightDisc == false then
        return
    end
    if not (GameState.Night or GameState.Underground) or gv_SatelliteView or IsSetpiecePlaying() then
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
    disc_radius = false
end

---- Black ring from the radius outwards, fading in over RAT_NIGHT_SHADE_FADE
local function ShadeMesh(radius)
    local n = RAT_NIGHT_SHADE_SEGMENTS
    local s = pstr("", n * 12 * 16)
    local clear, dark = RGBA(0, 0, 0, 0), RGBA(0, 0, 0, RAT_NIGHT_SHADE_ALPHA)
    local function band(r1, r2, c1, c2)
        for i = 0, n - 1 do
            local a1, a2 = i * 360 * 60 / n, (i + 1) * 360 * 60 / n
            local p1, p2 = RotateRadius(r1, a1, point30), RotateRadius(r1, a2, point30)
            local q1, q2 = RotateRadius(r2, a1, point30), RotateRadius(r2, a2, point30)
            s:AppendVertex(p1, c1) s:AppendVertex(q1, c2) s:AppendVertex(q2, c2)
            s:AppendVertex(p1, c1) s:AppendVertex(q2, c2) s:AppendVertex(p2, c1)
        end
    end
    local fade_end = radius + RAT_NIGHT_SHADE_FADE
    band(radius, fade_end, clear, dark)
    band(fade_end, fade_end + RAT_NIGHT_SHADE_REACH, dark, dark)
    return s
end

function Rat_NightDiscUpdate()
    local u = DiscUnit()
    if not u then
        Rat_NightDiscRemove()
        return
    end
    local pos = u:GetVisualPos() + point(0, 0, 20)
    if not IsValid(disc_mesh) then
        local m = PlaceObject("Mesh")
        ---- no depth test: a flat ring at the merc's feet must still shade walls, roofs and canopies
        m:SetShader(ProceduralMeshShaders.default_mesh, false)
        m:SetPos(pos)
        disc_mesh = m
        disc_radius = false
    elseif disc_mesh:GetPos() ~= pos then
        disc_mesh:SetPos(pos, 50)
    end
    local radius = Rat_NightSightRadius(u)
    if radius ~= disc_radius then
        disc_radius = radius
        disc_mesh:SetMesh(ShadeMesh(radius))
    end
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

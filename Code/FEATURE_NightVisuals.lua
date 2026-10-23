---------------------------------------------------------------------------------------------------
---- NIGHT VISUALS -- darker night lightmodels, and a softer-night disc around the selected merc
---- whose edge is how far he sees a target standing in the dark.
---------------------------------------------------------------------------------------------------

---- Auto-exposure key drop per NightDarkness step. Exposure itself is undone by auto-exposure.
RAT_NIGHT_KEY_STEP = 100000
---- Disc light: height over the merc, intensity, color. Below most canopies, so treetops stay dark.
RAT_NIGHT_DISC_HEIGHT = 12 * guim
RAT_NIGHT_DISC_INTENSITY = 20
RAT_NIGHT_DISC_COLOR = RGB(185, 200, 255)
---- Visible edge follows the inner cone angle; the outer one only softens it (degrees).
RAT_NIGHT_DISC_FEATHER = 6

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

local disc_light = false
local disc_radius = false

local function DiscUnit()
    if CurrentModOptions and CurrentModOptions.NightSightDisc == false then
        return
    end
    if SavingGame or not (GameState.Night or GameState.Underground) or gv_SatelliteView or IsSetpiecePlaying() then
        return
    end
    local u = SelectedObj
    if not IsKindOf(u, "Unit") or u:IsDead() or not u:IsLocalPlayerControlled() or not u:IsValidPos() then
        return
    end
    return u
end

function Rat_NightDiscRemove()
    if IsValid(disc_light) then
        DoneObject(disc_light)
    end
    disc_light = false
    disc_radius = false
end

function Rat_NightDiscUpdate()
    local u = DiscUnit()
    if not u then
        Rat_NightDiscRemove()
        return
    end
    local pos = u:GetVisualPos() + point(0, 0, RAT_NIGHT_DISC_HEIGHT)
    if not IsValid(disc_light) then
        local l = PlaceObject("SpotLight")
        ---- out of the voxel stealth light scan: the disc must never make anyone illuminated
        l:ClearEnumFlags(const.efVsPointLight | const.efVsSpotLight)
        l:SetCastShadows(false)
        l:SetAttenuationShape(0)
        l:SetColor(RAT_NIGHT_DISC_COLOR)
        l:SetIntensity(RAT_NIGHT_DISC_INTENSITY)
        ---- the renderer skips lights without it; removed while SavingGame so saves never hold it
        l:SetGameFlags(const.gofPermanent)
        l:SetPos(pos)
        disc_light = l
        disc_radius = false
    elseif disc_light:GetPos() ~= pos then
        disc_light:SetPos(pos, 50)
    end
    local radius = Rat_NightSightRadius(u)
    if radius ~= disc_radius then
        disc_radius = radius
        local inner = 2 * atan(radius, RAT_NIGHT_DISC_HEIGHT) / 60
        disc_light:SetConeInnerAngle(inner)
        disc_light:SetConeOuterAngle(Min(175, inner + RAT_NIGHT_DISC_FEATHER))
        disc_light:SetAttenuationRadius(2 * Max(radius, RAT_NIGHT_DISC_HEIGHT))
    end
end

MapRealTimeRepeat("RatNightDisc", 50, function()
    Rat_NightDiscUpdate()
end)

function OnMsg.SaveGameStart()
    Rat_NightDiscRemove()
end

function OnMsg.ApplyModOptions(id)
    if id ~= CurrentModId then
        return
    end
    Rat_ReapplyNightLightmodel()
    Rat_NightDiscRemove()
end

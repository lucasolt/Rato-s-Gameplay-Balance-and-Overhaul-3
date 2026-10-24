local file_str = 'FEATURE_WeaponFlashlight.lua'

---------------------------------------------------------------------------------------------------
---- WEAPON FLASHLIGHT -- the beam is on while the unit holds shooting stance at night with a
---- flashlight weapon: a rendered spotlight plus a StealthSpotLight on the same axis, so whatever
---- the beam reaches is really illuminated (sight range, darkness CTH). The wielder is lit only
---- while the beam is on; vanilla lit him all the time and gave the shooter nothing.
---------------------------------------------------------------------------------------------------

---- Gameplay reach (lit voxels, darkness CTH); aimed shots inside it ignore darkness, hip fire keeps
---- RAT_FLASHLIGHT_HIPFIRE_PCT of the penalty
RAT_FLASHLIGHT_REACH = 12 * const.SlabSizeX
RAT_FLASHLIGHT_HIPFIRE_PCT = 50
---- Visible beam only; live beams pick up changes within 100 ms
RAT_FLASHLIGHT_RENDER_REACH = 12 * const.SlabSizeX
RAT_FLASHLIGHT_INTENSITY = 30
RAT_FLASHLIGHT_COLOR = RGB(255, 245, 225)
---- Cone in degrees, both lights; the visible edge is the inner angle
RAT_FLASHLIGHT_CONE = {inner = 15, outer = 30}
---- Beam origin height and downward tilt (degrees) per stance, so the cone reaches the ground
RAT_FLASHLIGHT_POSE = {
    Standing = {height = 130 * guic, tilt = 6},
    Crouch = {height = 90 * guic, tilt = 4},
    Prone = {height = 30 * guic, tilt = 1},
}

---- Saved games must not hold the lights: own classes, swept after a load
DefineClass.RatFlashlightBeam = {__parents = {"SpotLight"}}
DefineClass.RatFlashlightStealth = {__parents = {"StealthSpotLight"}}

function Rat_FlashlightWeapon(unit)
    local _, __, weapons = unit:GetActiveWeapons()
    for _, w in ipairs(weapons) do
        if IsKindOf(w, "Firearm") and w:HasComponent("IgnoreInTheDark") then
            return w
        end
    end
end

function Rat_FlashlightOn(unit)
    return (GameState.Night or GameState.Underground) and IsValid(unit) and not unit:IsDead()
        and unit:HasStatusEffect("shooting_stance") and Rat_FlashlightWeapon(unit) and true or false
end

---- Vanilla IsIlluminated (Lua/Stealth.lua), with the flashlight clause tied to the beam being on
function IsIlluminated(target, voxels, sync, step_pos)
    if not IsValid(target) or not target:IsValidPos() then
        return
    end
    if not GameState.Night and not GameState.Underground then
        return true
    end
    local env_factors = GetVoxelStealthParams(step_pos or target)
    if env_factors ~= 0 and band(env_factors, const.vsFlagIlluminated) ~= 0 then
        return true
    end
    if IsKindOf(target, "Unit") and Rat_FlashlightOn(target) then
        return true
    end
    if next(g_DistToFire) == nil then
        return
    end
    if not voxels then
        if IsKindOf(target, "Unit") then
            voxels = step_pos and target:GetVisualVoxels(step_pos) or target:GetVisualVoxels()
        else
            local x, y, z = WorldToVoxel(target)
            voxels = {point_pack(x, y, z)}
        end
    end
    return AreVoxelsInFireRange(voxels)
end

---------------------------------------------------------------------------------------------------
---- Lights
---------------------------------------------------------------------------------------------------
local beams = setmetatable({}, weak_keys_meta)
local swept = false

local function ResetSweep()
    swept = false
end
OnMsg.NewMapLoaded = ResetSweep
OnMsg.LoadGame = ResetSweep

local function LightsChanged()
    ResetVoxelStealthParamsCache()
    if g_Combat then
        g_Combat.visibility_update_hash = false
    end
    Rat_NightShadeLightsChanged()
end

local function SetupLight(l, reach)
    l:SetColor(RAT_FLASHLIGHT_COLOR)
    l:SetIntensity(RAT_FLASHLIGHT_INTENSITY)
    l:SetAttenuationRadius(reach)
    l:SetConeInnerAngle(RAT_FLASHLIGHT_CONE.inner)
    l:SetConeOuterAngle(RAT_FLASHLIGHT_CONE.outer)
end

local function RemoveBeam(unit)
    local b = beams[unit]
    beams[unit] = nil
    for _, l in ipairs(b and {b.render, b.stealth} or empty_table) do
        if IsValid(l) then
            DoneObject(l)
        end
    end
end

function Rat_FlashlightRemoveAll()
    for unit in pairs(beams) do
        RemoveBeam(unit)
    end
    LightsChanged()
end

OnMsg.SaveGameStart = Rat_FlashlightRemoveAll

---- Origin, axis and angle toward the shooting stance aim point
local function BeamPose(unit)
    local pose = RAT_FLASHLIGHT_POSE[unit.stance] or RAT_FLASHLIGHT_POSE.Standing
    local pos = unit:GetPos()
    local aim = GetAimPos_ShootingStance(unit:GetStatusEffect("shooting_stance"))
    local yaw = aim and pos:Dist2D(aim) > 0 and CalcOrientation(pos, aim) or unit:GetAngle()
    ---- a SpotLight points down; -90 degrees about y turns it to +x, then yaw turns it to the target
    local axis, angle = ComposeRotation(axis_y, (pose.tilt - 90) * 60, axis_z, yaw)
    return pos:SetZ((pos:z() or terrain.GetHeight(pos)) + pose.height), axis, angle
end

local function SettingsKey()
    local c = RAT_FLASHLIGHT_CONE
    return string.format("%d/%d/%d/%d/%d/%d", RAT_FLASHLIGHT_REACH, RAT_FLASHLIGHT_RENDER_REACH,
                         RAT_FLASHLIGHT_INTENSITY, RAT_FLASHLIGHT_COLOR, c.inner, c.outer)
end

local function UpdateBeam(unit)
    local origin, axis, angle = BeamPose(unit)
    local key = SettingsKey()
    local b = beams[unit]
    if b and b.origin == origin and b.axis == axis and b.angle == angle and b.key == key then
        return false
    end
    if not b then
        local render = PlaceObject("RatFlashlightBeam")
        ---- out of the stealth voxel scan: the stealth twin below does that job
        render:ClearEnumFlags(const.efVsPointLight | const.efVsSpotLight)
        ---- the renderer skips Lua-placed lights without it
        render:SetGameFlags(const.gofPermanent)
        b = {render = render, stealth = PlaceObject("RatFlashlightStealth")}
        beams[unit] = b
    end
    if b.key ~= key then
        b.key = key
        SetupLight(b.render, RAT_FLASHLIGHT_RENDER_REACH)
        SetupLight(b.stealth, RAT_FLASHLIGHT_REACH)
    end
    b.origin, b.axis, b.angle = origin, axis, angle
    for _, l in ipairs{b.render, b.stealth} do
        l:SetPos(origin)
        l:SetAxisAngle(axis, angle)
    end
    ---- stealth voxels only count sync lights
    if not b.stealth:IsSyncObject() then
        b.stealth:MakeSync()
    end
    return true
end

MapGameTimeRepeat("RatFlashlights", 100, function()
    if SavingGame then
        return
    end
    local changed = false
    if not swept then
        swept = true
        MapForEach("map", "RatFlashlightBeam", DoneObject)
        MapForEach("map", "RatFlashlightStealth", DoneObject)
        beams = setmetatable({}, weak_keys_meta)
        changed = true
    end
    for unit in pairs(beams) do
        if not Rat_FlashlightOn(unit) then
            RemoveBeam(unit)
            changed = true
        end
    end
    for _, unit in ipairs(g_Units) do
        if Rat_FlashlightOn(unit) and UpdateBeam(unit) then
            changed = true
        end
    end
    if changed then
        LightsChanged()
    end
end)

---------------------------------------------------------------------------------------------------
---- Darkness CTH: a flashlight shot within reach is lit. Aimed (aim, shooting stance, interrupt):
---- no penalty, even before the beam reaches the target, so the preview matches the shot. Hip fire
---- keeps RAT_FLASHLIGHT_HIPFIRE_PCT of it.
---------------------------------------------------------------------------------------------------
local function FlashlightCovers(attacker, weapon, target, attacker_pos, target_pos)
    if not IsKindOf(attacker, "Unit") or not IsKindOf(weapon, "Firearm") or not weapon:HasComponent("IgnoreInTheDark") then
        return false
    end
    local from = attacker_pos or attacker:GetPos()
    local to = target_pos or IsValid(target) and target:GetPos() or IsPoint(target) and target
    return to and from:Dist(to) <= RAT_FLASHLIGHT_REACH
end

function Rat_PatchDarknessCTH()
    local m = Presets.ChanceToHitModifier.Default.Darkness
    if not m then
        return
    end
    local orig = Rat_AttOriginal(m.CalcValue)
    m.CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim,
                           opportunity_attack, attacker_pos, target_pos)
        local use, value, name, meta = orig(self, attacker, target, body_part_def, action, weapon1, weapon2,
                                            lof, aim, opportunity_attack, attacker_pos, target_pos)
        if not use or not FlashlightCovers(attacker, weapon1, target, attacker_pos, target_pos) then
            return use, value, name, meta
        end
        if (aim or 0) > 0 or opportunity_attack or attacker:HasStatusEffect("shooting_stance") then
            return false, 0
        end
        return true, MulDivRound(value, RAT_FLASHLIGHT_HIPFIRE_PCT, 100),
               ratT(file_str, 731905548221, "In the dark (flashlight, hip fire)"), meta
    end
    RAT_ATT_WRAPS[m.CalcValue] = orig
end

OnMsg.DataLoaded = Rat_PatchDarknessCTH

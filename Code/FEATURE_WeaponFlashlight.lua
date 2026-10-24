---------------------------------------------------------------------------------------------------
---- WEAPON FLASHLIGHT -- at night a flashlight weapon in shooting stance casts a real beam toward the
---- stance aim point: a rendered spotlight plus a StealthSpotLight, so whatever it reaches is
---- illuminated (sight range, darkness CTH). Aiming at a target (stance or not) shows the visible
---- beam on it, without the stealth light, so hovering reveals nothing. The lens glows while the
---- visible beam is on. A hip-fire shot leaves the light on until the shooter's next turn. The
---- wielder is lit only while the real beam is on; vanilla lit him always (vanilla's own TurnOn FX
---- is dead: EnableAimFX is off on Flashlight, and played by hand it shows nothing).
---------------------------------------------------------------------------------------------------

---- Gameplay reach (lit voxels, darkness CTH): any flashlight shot inside it ignores darkness
RAT_FLASHLIGHT_REACH = 12 * const.SlabSizeX
---- A hip-fire shot leaves the light on until the shooter's next turn; outside combat, this long (ms)
RAT_FLASHLIGHT_LEFT_ON_EXPLORE = 10000
---- Visible beam only; live beams pick up changes within 100 ms
RAT_FLASHLIGHT_RENDER_REACH = 12 * const.SlabSizeX
RAT_FLASHLIGHT_INTENSITY = 30
RAT_FLASHLIGHT_COLOR = RGB(255, 245, 225)
---- Cone in degrees, both lights; the visible edge is the inner angle
RAT_FLASHLIGHT_CONE = {inner = 15, outer = 30}
---- Lens glow: point light on the flashlight attachment, `offset` along its X axis
RAT_FLASHLIGHT_GLOW = {intensity = 10, radius = 40 * guic, offset = 10 * guic}
---- Beam origin height and downward tilt (degrees) per stance, so the cone reaches the ground
RAT_FLASHLIGHT_POSE = {
    Standing = {height = 130 * guic, tilt = 6},
    Crouch = {height = 90 * guic, tilt = 4},
    Prone = {height = 30 * guic, tilt = 1},
}

---- Saved games must not hold the lights: own classes, swept after a load
DefineClass.RatFlashlightBeam = {__parents = {"SpotLight"}}
DefineClass.RatFlashlightStealth = {__parents = {"StealthSpotLight"}}
DefineClass.RatFlashlightGlow = {__parents = {"PointLight"}}

function Rat_FlashlightWeapon(unit)
    local _, __, weapons = unit:GetActiveWeapons()
    for _, w in ipairs(weapons) do
        if IsKindOf(w, "Firearm") and w:HasComponent("IgnoreInTheDark") then
            return w
        end
    end
end

local LEFT_ON = "rat_flashlight_left_on"

---- true in combat (until the unit's next turn), an end GameTime outside it
function Rat_FlashlightLeftOn(unit)
    local v = unit:GetEffectValue(LEFT_ON)
    return v == true or type(v) == "number" and GameTime() < v
end

---- The real beam: shooting stance, or left on by hip fire
function Rat_FlashlightOn(unit)
    return (GameState.Night or GameState.Underground) and IsValid(unit) and not unit:IsDead()
        and (unit:HasStatusEffect("shooting_stance") or Rat_FlashlightLeftOn(unit))
        and Rat_FlashlightWeapon(unit) and true or false
end

---- Stance before the action: OnAttack is too late, shooting stance is entered in an earlier OnAttack
function OnMsg.RunCombatAction(action_id, unit)
    if IsKindOf(unit, "Unit") then
        unit.rat_flashlight_pre_stance = unit:HasStatusEffect("shooting_stance")
    end
end

function OnMsg.OnAttack(unit, action, target, results, attack_args)
    local weapon = attack_args and attack_args.weapon
    if not IsKindOf(unit, "Unit") or not (GameState.Night or GameState.Underground) or not IsKindOf(weapon, "Firearm")
        or not weapon:HasComponent("IgnoreInTheDark") then
        return
    end
    if (attack_args.aim or 0) > 0 or attack_args.opportunity_attack or unit.rat_flashlight_pre_stance then
        return
    end
    unit:SetEffectValue(LEFT_ON, g_Combat and true or GameTime() + RAT_FLASHLIGHT_LEFT_ON_EXPLORE)
end

function OnMsg.UnitBeginTurn(unit)
    unit:SetEffectValue(LEFT_ON, nil)
end

function OnMsg.CombatEnd()
    for _, unit in ipairs(g_Units) do
        if unit:GetEffectValue(LEFT_ON) == true then
            unit:SetEffectValue(LEFT_ON, GameTime() + RAT_FLASHLIGHT_LEFT_ON_EXPLORE)
        end
    end
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
---- Lights. Per unit: the visible beam and lens glow (stance or aiming), and the stealth twin
---- (stance only). Only the stealth light touches the voxel cache and visibility.
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

---- Where the player (or an attack) is aiming the unit right now
local function AimTargetPos(unit)
    local params = unit.aim_action_id and unit.aim_action_params
    local t = params and params.target
    if IsValid(t) then
        return t:GetPos()
    end
    return IsPoint(t) and t or nil
end

---- The flashlight weapon whose visible beam should be on, or nil
local function BeamWeapon(unit)
    if not (GameState.Night or GameState.Underground) or not IsValid(unit) or unit:IsDead() then
        return
    end
    if not unit:HasStatusEffect("shooting_stance") and not AimTargetPos(unit) and not Rat_FlashlightLeftOn(unit) then
        return
    end
    return Rat_FlashlightWeapon(unit)
end

---- Visual part of the flashlight attachment (vanilla playTurnOnFx lookup)
local function FlashlightPart(weapon)
    local visual = weapon.visual_obj
    local parts = visual and visual.parts
    if not parts then
        return
    end
    for _, cid in sorted_pairs(weapon.components) do
        local c = WeaponComponents[cid]
        if c and table.find(c.ModificationEffects or empty_table, "IgnoreInTheDark") then
            for _, descr in ipairs(c.Visuals or empty_table) do
                if descr:Match(weapon.class) and parts[descr.Slot] then
                    return parts[descr.Slot]
                end
            end
        end
    end
end

local function NewRenderLight(class)
    local l = PlaceObject(class)
    ---- out of the stealth voxel scan: only the stealth twin lights voxels
    l:ClearEnumFlags(const.efVsPointLight | const.efVsSpotLight)
    ---- the renderer skips Lua-placed lights without it
    l:SetGameFlags(const.gofPermanent)
    return l
end

local function SetupSpot(l, reach)
    l:SetColor(RAT_FLASHLIGHT_COLOR)
    l:SetIntensity(RAT_FLASHLIGHT_INTENSITY)
    l:SetAttenuationRadius(reach)
    l:SetConeInnerAngle(RAT_FLASHLIGHT_CONE.inner)
    l:SetConeOuterAngle(RAT_FLASHLIGHT_CONE.outer)
end

local function SetupGlow(l)
    local g = RAT_FLASHLIGHT_GLOW
    l:SetColor(RAT_FLASHLIGHT_COLOR)
    l:SetIntensity(g.intensity)
    l:SetAttenuationRadius(g.radius)
    l:SetAttachOffset(point(g.offset, 0, 0))
end

---- True when it had a stealth light
local function RemoveBeam(unit)
    local b = beams[unit]
    beams[unit] = nil
    if not b then
        return false
    end
    for _, l in ipairs{b.render, b.stealth, b.glow} do
        if IsValid(l) then
            DoneObject(l)
        end
    end
    return b.stealth and true or false
end

function Rat_FlashlightRemoveAll()
    for unit in pairs(beams) do
        RemoveBeam(unit)
    end
    LightsChanged()
end

OnMsg.SaveGameStart = Rat_FlashlightRemoveAll

---- Origin, axis and angle toward `aim` (the unit's facing without one)
local function BeamPose(unit, aim)
    local pose = RAT_FLASHLIGHT_POSE[unit.stance] or RAT_FLASHLIGHT_POSE.Standing
    local pos = unit:GetPos()
    local yaw = aim and pos:Dist2D(aim) > 0 and CalcOrientation(pos, aim) or unit:GetAngle()
    ---- a SpotLight points down; -90 degrees about y turns it to +x, then yaw turns it to the target
    local axis, angle = ComposeRotation(axis_y, (pose.tilt - 90) * 60, axis_z, yaw)
    return pos:SetZ((pos:z() or terrain.GetHeight(pos)) + pose.height), axis, angle
end

local function PlaceSpot(l, pose)
    l:SetPos(pose[1])
    l:SetAxisAngle(pose[2], pose[3])
end

local function SamePose(a, b)
    return a and b and a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

local function SettingsKey()
    local c, g = RAT_FLASHLIGHT_CONE, RAT_FLASHLIGHT_GLOW
    return string.format("%d/%d/%d/%d/%d/%d/%d/%d/%d", RAT_FLASHLIGHT_REACH, RAT_FLASHLIGHT_RENDER_REACH,
                         RAT_FLASHLIGHT_INTENSITY, RAT_FLASHLIGHT_COLOR, c.inner, c.outer, g.intensity,
                         g.radius, g.offset)
end

---- True when the stealth light was placed, moved or removed
local function UpdateBeam(unit, weapon, lit)
    local b = beams[unit]
    if not b then
        b = {}
        beams[unit] = b
    end
    local changed = false
    local key = SettingsKey()
    if not IsValid(b.render) then
        b.render, b.render_pose, b.key = NewRenderLight("RatFlashlightBeam"), false, false
    end
    if lit and not IsValid(b.stealth) then
        b.stealth, b.stealth_pose, b.key = PlaceObject("RatFlashlightStealth"), false, false
    elseif not lit and b.stealth then
        if IsValid(b.stealth) then
            DoneObject(b.stealth)
        end
        b.stealth = false
        changed = true
    end
    local part = FlashlightPart(weapon)
    if part ~= b.glow_part or not IsValid(b.glow) then
        if IsValid(b.glow) then
            DoneObject(b.glow)
        end
        b.glow, b.glow_part, b.key = false, part, false
        if part then
            b.glow = NewRenderLight("RatFlashlightGlow")
            part:Attach(b.glow)
        end
    end
    if b.key ~= key then
        b.key = key
        SetupSpot(b.render, RAT_FLASHLIGHT_RENDER_REACH)
        if b.stealth then
            SetupSpot(b.stealth, RAT_FLASHLIGHT_REACH)
            changed = true
        end
        if b.glow then
            SetupGlow(b.glow)
        end
    end
    local stance_aim = GetAimPos_ShootingStance(unit:GetStatusEffect("shooting_stance"))
    local view = {BeamPose(unit, AimTargetPos(unit) or stance_aim)}
    if not SamePose(view, b.render_pose) then
        b.render_pose = view
        PlaceSpot(b.render, view)
    end
    if b.stealth then
        local real = {BeamPose(unit, stance_aim)}
        if not SamePose(real, b.stealth_pose) then
            b.stealth_pose = real
            PlaceSpot(b.stealth, real)
            ---- stealth voxels only count sync lights
            if not b.stealth:IsSyncObject() then
                b.stealth:MakeSync()
            end
            changed = true
        end
    end
    return changed
end

MapGameTimeRepeat("RatFlashlights", 100, function()
    if SavingGame then
        return
    end
    local changed = false
    if not swept then
        swept = true
        for _, class in ipairs{"RatFlashlightBeam", "RatFlashlightStealth", "RatFlashlightGlow"} do
            MapForEach("map", class, DoneObject)
        end
        beams = setmetatable({}, weak_keys_meta)
        changed = true
    end
    for unit in pairs(beams) do
        if not BeamWeapon(unit) and RemoveBeam(unit) then
            changed = true
        end
    end
    for _, unit in ipairs(g_Units) do
        local weapon = BeamWeapon(unit)
        if weapon and UpdateBeam(unit, weapon, Rat_FlashlightOn(unit)) then
            changed = true
        end
    end
    if changed then
        LightsChanged()
    end
end)

---------------------------------------------------------------------------------------------------
---- Darkness CTH: a flashlight shot within reach is lit, even before the beam reaches the target, so
---- the preview matches the shot. Hip fire pays for it in OnAttack (light left on).
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
        return false, 0
    end
    RAT_ATT_WRAPS[m.CalcValue] = orig
end

OnMsg.DataLoaded = Rat_PatchDarknessCTH

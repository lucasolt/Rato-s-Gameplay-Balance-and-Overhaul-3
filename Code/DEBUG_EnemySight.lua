---------------------------------------------------------------------------------------------------
---- DEBUG ENEMY SIGHT -- Ctrl-Alt-V toggles. A selected or hovered non-player unit shows its sight
---- against a merc (see PickPair): red = detection zone (front half the full radius, back half 80%, as
---- the suspicion meter reads it), grey = its sight before target terms, text = the breakdown.
---------------------------------------------------------------------------------------------------

local RAT_ENEMY_SIGHT_TICK = 250
local RAT_ENEMY_SIGHT_KEY = "Ctrl-Alt-V"

local sight_thread = false
local sight_objs = {}
local sight_unit = false
local sight_merc = false
local sight_sig = false

local function ClearSightObjs()
    for _, o in ipairs(sight_objs) do
        if IsValid(o) then
            DoneObject(o)
        end
    end
    sight_objs = {}
    sight_sig = false
end

local function Tiles(v)
    return string.format("%d.%d", v / const.SlabSizeX, (v % const.SlabSizeX) * 10 / const.SlabSizeX)
end

local function Signed(v)
    return v >= 0 and ("+" .. v) or tostring(v)
end

---- Polyline around `center` with radius_fn(angle) mm, draped on the terrain like PlaceTerrainCircle
local function PlaceSightShape(center, radius_fn, color)
    local steps = 96
    local mapw, maph = terrain.GetMapSize()
    local vpstr = pstr("", 1024)
    for i = 0, steps do
        local a = MulDivRound(360 * 60, i, steps)
        local x, y = RotateRadius(radius_fn(a), a, center, true)
        vpstr:AppendVertex(Clamp(x, 0, mapw - const.HeightTileSize), Clamp(y, 0, maph - const.HeightTileSize), guim / 4, color)
    end
    local line = PlaceObject("Polyline")
    line:SetMesh(vpstr)
    line:SetPos(center)
    line:AddMeshFlags(const.mfTerrainDistorted)
    sight_objs[#sight_objs + 1] = line
end

local function AwarenessName(u)
    if u:HasStatusEffect("Surprised") then return "Surprised" end
    if u:HasStatusEffect("Suspicious") then return "Suspicious" end
    if u:HasStatusEffect("Unaware") then return "Unaware" end
    return u:IsAware() and "Aware" or "?"
end

---- Effects with an OnCalcSightModifier unit reaction (Stealthy, NaturalCamouflage, HighAlert, Suspicious)
local function SightEffects(u)
    local names = {}
    for _, eff in ipairs(u.StatusEffects or empty_table) do
        for _, r in ipairs(eff.unit_reactions or empty_table) do
            if r.Event == "OnCalcSightModifier" then
                names[#names + 1] = eff.class
                break
            end
        end
    end
    return #names > 0 and ("(" .. table.concat(names, ",") .. ")") or ""
end

---- Vanilla GetSightRadius terms one by one; the radius itself always comes from the real call
local function SightTerms(enemy, merc)
    local t = {}
    local hidden = merc:HasStatusEffect("Hidden")
    local dark = (GameState.Night or GameState.Underground) and not IsIlluminated(merc)
    t.hidden, t.dark = hidden, dark
    t.forced = enemy:CallReactions_Or("OnCheckForceMinSight", enemy, merc, nil, dark) or
        merc:CallReactions_Or("OnCheckForceMinSight", enemy, merc, nil, dark)
    t.eff_self = enemy:CallReactions_Modify("OnCalcSightModifier", 100, enemy, merc, nil, dark) - 100
    t.eff_target = merc:CallReactions_Modify("OnCalcSightModifier", 100, enemy, merc, nil, dark) - 100
    t.stealth = hidden and -Max(0, MulDivRound(merc.Agility - enemy.Wisdom, const.Combat.SightModStealthStatDiff, 100)) or 0
    t.prone = hidden and merc.stance == "Prone" and -const.Combat.SightModHiddenProne or 0
    local armor = merc:GetItemInSlot("Torso", "Armor")
    t.camo = armor and armor.Camouflage and -const.Combat.CamoSightPenalty or 0
    local env = GetVoxelStealthParams(merc) or 0
    t.grass = band(env, const.vsFlagTallGrass) ~= 0 and const.EnvEffects.BrushSightMod or 0
    local _, _, oz = merc:GetGridCoords()
    local _, _, z = enemy:GetGridCoords()
    t.height = 0
    if oz >= z + const.EnvEffects.SightHeightDiffThreshold then
        t.height = const.EnvEffects.SightHeightDiffMod
    elseif g_Exploration and oz + const.EnvEffects.SightHeightDiffThreshold < z then
        t.height = -const.EnvEffects.SightHeightDiffMod * 2
    end
    t.total = 100 + t.eff_self + t.eff_target + t.stealth + t.prone + t.camo + t.grass + t.height
    t.clamped = Clamp(t.total, const.Combat.SightModMinValue, const.Combat.SightModMaxValue)
    ---- base the modifier multiplies: our wrapper's night/weather base, Unaware cap included
    local unaware = hidden or not enemy:IsAware()
    t.base = GBO_BaseSight(enemy, nil, unaware, dark)
    t.base_raw = unaware and const.Combat.UnawareSightRange or const.Combat.AwareSightRange
    return t
end

local function SightText(enemy, merc)
    local radius = enemy:GetSightRadius(merc)
    local free = enemy:GetSightRadius()
    local dist = enemy:GetDist(merc)
    local angle = AngleDiff(CalcOrientation(enemy, merc), enemy:GetOrientationAngle())
    local behind = abs(angle) > 90 * 60
    local reach = behind and MulDivRound(radius, 80, 100) or radius
    local t = SightTerms(enemy, merc)
    local lines = {
        string.format("%s  [%s]  Wis %d  vs %s (Agi %d, %s)", _InternalTranslate(enemy:GetDisplayName()), AwarenessName(enemy),
            enemy.Wisdom, _InternalTranslate(merc:GetDisplayName()), merc.Agility, merc.stance),
        string.format("base %d tiles (raw %d%s%s)", t.base, t.base_raw, t.dark and ", dark" or "",
            (GameState.Fog or GameState.DustStorm or GameState.FireStorm) and ", weather" or ""),
        string.format("mod %d%%%s: eff %s%s/%s%s stealth %s prone %s camo %s grass %s height %s",
            t.clamped, t.clamped ~= t.total and (" (raw " .. t.total .. ")") or "",
            Signed(t.eff_self), SightEffects(enemy), Signed(t.eff_target), SightEffects(merc), Signed(t.stealth), Signed(t.prone), Signed(t.camo),
            Signed(t.grass), Signed(t.height)),
        string.format("radius %s (lit, no target terms %s)  dist %s  %s -> %s", Tiles(radius), Tiles(free), Tiles(dist),
            behind and "behind (80%)" or "front", dist <= reach and "IN" or "out"),
        string.format("sees merc %s  merc hidden %s  suspicion %d/%d%s", HasVisibilityTo(enemy, merc) and "yes" or "no",
            t.hidden and "yes" or "no", merc.suspicion or 0, SuspicionThreshold, t.forced and "  FORCED MIN" or ""),
    }
    return lines, radius, free
end

local function IsPlayerUnit(u)
    return u.team and u.team.side == "player1"
end

local function LiveUnit(u)
    return IsValid(u) and IsKindOf(u, "Unit") and not u:IsDead() and u
end

---- Enemy: a selected non-player unit, else the last one hovered. Merc: the selected one, else the
---- hovered one, else the last one, else the closest.
local function PickPair()
    local sel = LiveUnit(SelectedObj)
    local hover = LiveUnit(SelectionMouseObj())
    if sel and IsPlayerUnit(sel) then
        sight_merc = sel
    elseif sel then
        sight_unit = sel
    end
    if hover and IsPlayerUnit(hover) then
        sight_merc = hover
    elseif hover and not (sel and not IsPlayerUnit(sel)) then
        sight_unit = hover
    end
    sight_unit = LiveUnit(sight_unit)
    sight_merc = LiveUnit(sight_merc)
    if sight_unit and not sight_merc then
        local best_dist
        for _, u in ipairs(g_Units) do
            if IsPlayerUnit(u) and LiveUnit(u) and (not best_dist or IsCloser(sight_unit, u, best_dist)) then
                sight_merc, best_dist = u, sight_unit:GetDist(u)
            end
        end
    end
    return sight_unit, sight_merc
end

local function SightTick()
    local enemy, merc = PickPair()
    if not (enemy and merc) then
        ClearSightObjs()
        return
    end
    local lines, radius, free = SightText(enemy, merc)
    local pos = enemy:GetPos()
    local face = enemy:GetOrientationAngle()
    local sig = table.concat(lines, "|") .. tostring(pos) .. face
    if sig == sight_sig then
        return
    end
    ClearSightObjs()
    sight_sig = sig
    local back = MulDivRound(radius, 80, 100)
    PlaceSightShape(pos, function(a)
        return abs(AngleDiff(a, face)) > 90 * 60 and back or radius
    end, const.clrRed)
    PlaceSightShape(pos, function() return free end, RGB(160, 160, 160))
    local head = (pos:IsValidZ() and pos or pos:SetTerrainZ()) + point(0, 0, 2 * guim)
    sight_objs[#sight_objs + 1] = PlaceText(table.concat(lines, "\n"), head, const.clrWhite)
end

function Rat_ToggleEnemySight()
    if sight_thread then
        DeleteThread(sight_thread)
        sight_thread = false
        ClearSightObjs()
        print("Enemy sight debug off")
        return
    end
    sight_thread = CreateRealTimeThread(function()
        while true do
            local ok, err = pcall(SightTick)
            if not ok then
                print("Enemy sight debug:", err)
            end
            Sleep(RAT_ENEMY_SIGHT_TICK)
        end
    end)
    print("Enemy sight debug on: select or hover a unit")
end

function OnMsg.DoneMap()
    if sight_thread then
        DeleteThread(sight_thread)
        sight_thread = false
    end
    sight_objs = {}
    sight_unit = false
    sight_merc = false
    sight_sig = false
end

---- Class marker: a mod reload must not stack the patch on itself
if not InGameInterface.rat_enemy_sight_patched then
    local vanilla_on_shortcut = InGameInterface.OnShortcut
    InGameInterface.rat_enemy_sight_patched = true
    InGameInterface.OnShortcut = function(self, shortcut, source, controller_id, repeated, ...)
        if not repeated and shortcut == RAT_ENEMY_SIGHT_KEY then
            Rat_ToggleEnemySight()
            return "break"
        end
        return vanilla_on_shortcut(self, shortcut, source, controller_id, repeated, ...)
    end
end

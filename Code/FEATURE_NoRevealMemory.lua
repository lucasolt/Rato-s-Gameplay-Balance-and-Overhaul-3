---- Option NoRevealMemory: a revealed enemy stays visible only while someone actually sees him.
---- Vanilla RevealTo puts him in g_RevealedUnits, which seeds the team's visibility (Visibility.lua:600)
---- regardless of LOS, and TurnStart re-reveals whoever is in it -- one glimpse in the enemy turn kept
---- him on screen through walls for the whole next turn. The Revealed status (no Hidden this turn) stays.
local RevealTo_orig = Unit.RevealTo

function Unit:RevealTo(obj, combat)
    RevealTo_orig(self, obj, combat)
    if not CurrentModOptions.NoRevealMemory or not (combat or g_Combat) then
        return
    end
    local team = IsValid(obj) and obj.team or obj
    if not IsKindOf(team, "CombatTeam") then
        return
    end
    table.remove_value(g_RevealedUnits[team] or empty_table, self)
    local vis = g_Visibility[team]
    local flags = vis and vis[self]
    if not flags then
        return
    end
    flags = flags - band(flags, const.uvRevealed)
    if flags ~= 0 then
        vis[self] = flags
        return
    end
    vis[self] = nil
    table.remove_value(vis, self)
    InvalidateDiplomacy()
    if g_Combat then
        g_Combat:ApplyVisibility()
    end
end

---- A hidden mover is judged at his final tile (CombatGoto visibility_override) and visibility is frozen during
---- his action, so with the pre-move reveal stripped he popped in at the destination. Show him once actually seen.
local MidMoveSightInterval = 150

local function SeenMidMove(unit, team)
    local pos = unit:GetVisualPos()
    local observers, targets
    for _, observer in ipairs(team.units) do
        if not observer:IsDead() and observer:IsValidPos()
            and IsCloser(observer, pos, observer:GetSightRadius(unit, nil, pos) + 1) then
            observers = observers or {}
            targets = targets or {}
            observers[#observers + 1] = observer
            targets[#targets + 1] = pos
        end
    end
    if not observers then
        return
    end
    local any, result = CheckLOS(targets, observers)
    if not any then
        return
    end
    -- Same rule as RevealUnitBeforeMove: partial LOS counts only for a standing target.
    local standing = unit.stance == "Standing"
    for _, los in ipairs(result) do
        if los == 2 or los == 1 and standing then
            return true
        end
    end
end

local function ShowMidMove(unit, team)
    local vis = g_Visibility[team]
    if not vis then
        vis = {}
        g_Visibility[team] = vis
    end
    if not vis[unit] then
        table.insert(vis, unit)
    end
    vis[unit] = bor(vis[unit] or 0, const.uvVisible)
    InvalidateDiplomacy()
    g_Combat:ApplyVisibility()
end

function OnMsg.UnitMovementStart(unit)
    if not CurrentModOptions.NoRevealMemory or not g_Combat or unit.team.control == "UI" then
        return
    end
    CreateGameTimeThread(function()
        while IsValid(unit) and unit.in_combat_movement and g_Combat and not unit:IsDead() do
            local pending
            if not unit:HasStatusEffect("Hidden") then
                for _, team in ipairs(g_Teams) do
                    if team.control == "UI" and team ~= unit.team and not HasVisibilityTo(team, unit) then
                        if SeenMidMove(unit, team) then
                            ShowMidMove(unit, team)
                        else
                            pending = true
                        end
                    end
                end
            else
                pending = true
            end
            if not pending then
                return
            end
            Sleep(MidMoveSightInterval)
        end
    end)
end

---- Vanilla AI camera assumes a tracked unit stays revealed: RevealUnitBeforeMove queues the reveal we
---- strip, and the follow loop (CombatCamera.lua:1604) centers on group_to_follow with no sight check.
local CenterCameraOnObj_orig = CenterCameraOnObj

function CenterCameraOnObj(objs, floor, sleep_time)
    if CurrentModOptions.NoRevealMemory and g_Combat and objs then
        objs = table.ifilter(objs, function(_, obj)
            return not IsKindOf(obj, "Unit") or obj.visible
        end)
    end
    return CenterCameraOnObj_orig(objs, floor, sleep_time)
end

local StartCinematicCombatCamera_orig = StartCinematicCombatCamera

function StartCinematicCombatCamera(attacker, target)
    if CurrentModOptions.NoRevealMemory and not attacker.visible then
        return
    end
    return StartCinematicCombatCamera_orig(attacker, target)
end

local ShouldTrackMeleeCharge_orig = ShouldTrackMeleeCharge

function ShouldTrackMeleeCharge(attacker, target)
    if CurrentModOptions.NoRevealMemory and not attacker.visible then
        g_TrackingChargeAttacker = false
        return
    end
    return ShouldTrackMeleeCharge_orig(attacker, target)
end

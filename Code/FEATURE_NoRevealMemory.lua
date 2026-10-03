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

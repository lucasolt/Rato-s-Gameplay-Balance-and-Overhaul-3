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

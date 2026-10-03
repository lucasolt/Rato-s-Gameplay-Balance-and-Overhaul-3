function runandgun_cth()
    Presets.ChanceToHitModifier.Default["RunAndGun"].CalcValue =
        function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim,
                 opportunity_attack, attacker_pos, target_pos)

            if action.id ~= "RunAndGun" and action.id ~= "RecklessAssault" then
                return false, 0
            end
            if not attacker or not target then

                return false, 0
            end
            local metaText = {}

            local pb_dist = const.Weapons.PointBlankRange * const.SlabSizeX
            local dist = attacker_pos:Dist(target_pos)

            local flat_penalty = const.Combat.RunAndGunMaxPenalty

            flat_penalty = (MulDivRound(dist, flat_penalty,
                                        const.Combat.RunAndGun_MaxDistforPenalty * const.SlabSizeX))

            if flat_penalty > const.Combat.RunAndGunMaxPenalty / 2 then
                flat_penalty = const.Combat.RunAndGunMaxPenalty / 2
            elseif flat_penalty < const.Combat.RunAndGunMaxPenalty then
                flat_penalty = const.Combat.RunAndGunMaxPenalty
            end

            if dist <= pb_dist then
                flat_penalty = MulDivRound(flat_penalty, 90, 100)
            end

            local side = attacker and attacker.team and attacker.team.side or ''

            if not (side == 'player1' or side == 'player2') then
                flat_penalty = AIpenal_reduc(attacker, flat_penalty, "RunAndGun")
            end

            if flat_penalty == 0 then
                return false, 0
            end

            return true, flat_penalty, false
        end
end


---- Sight modifiers read the unit's sight from where it stands; a mobile shot is judged from its step tile.
---- Gated in Unit:CalcChanceToHit, not in CalcValue: CommonLib's ChangeProp on NoLineOfSight reapplies
---- after our DataLoaded and would undo a preset override.
local SightModifiers = {NoLineOfSight = true, SeenBySpotter = true}

function Rat_SeesFromStep(mod_id, attacker, target, attacker_pos)
    if not SightModifiers[mod_id] or not attacker_pos or not IsValid(target) or
        HasVisibilityTo(attacker, target) then
        return false
    end
    local sight = attacker:GetSightRadius(target)
    if attacker_pos:Dist2D(attacker:GetPos()) > const.SlabSizeX / 2 then
        local pos = attacker_pos:IsValidZ() and attacker_pos or attacker_pos:SetTerrainZ()
        return CheckLOS(target, pos, sight) and true or false
    end
    ---- inside a combat action his sight is frozen at where the action started (Visibility.lua:1110)
    if g_VisibilityUpdateSuspendReasons[attacker] then
        return CheckLOS(target, attacker, sight) and true or false
    end
    return false
end

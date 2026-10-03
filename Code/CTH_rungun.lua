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
local function SeesFromStep(attacker, target, attacker_pos)
    if not attacker_pos or not IsValid(target) or
        attacker_pos:Dist2D(attacker:GetPos()) <= const.SlabSizeX / 2 then
        return false
    end
    local pos = attacker_pos:IsValidZ() and attacker_pos or attacker_pos:SetTerrainZ()
    return CheckLOS(target, pos, attacker:GetSightRadius(target)) and true or false
end

function mobile_los_cth()
    local mods = Presets.ChanceToHitModifier.Default
    ---- CommonLib's version (unit sight instead of team sight), plus the step tile
    mods["NoLineOfSight"].CalcValue = function(self, attacker, target, body_part_def, action,
                                               weapon1, weapon2, lof, aim, opportunity_attack,
                                               attacker_pos, target_pos)
        if HasVisibilityTo(attacker, target) then
            return false, 0
        end
        if not IsKindOf(weapon1, "Firearm") or not attacker or not target then
            return false, 0
        end
        if SeesFromStep(attacker, target, attacker_pos) then
            return false, 0
        end
        return true, self:ResolveValue("Penalty")
    end
    ---- copy of ChanceToHitModifier.lua:693, plus the step tile
    mods["SeenBySpotter"].CalcValue = function(self, attacker, target, body_part_def, action,
                                               weapon1, weapon2, lof, aim, opportunity_attack,
                                               attacker_pos, target_pos)
        if not attacker or not target or VisibilityCheckAll(attacker, target, nil, const.uvVisible) then
            return false, 0
        end
        if not IsKindOf(weapon1, "Firearm") then
            return false, 0
        end
        if SeesFromStep(attacker, target, attacker_pos) then
            return false, 0
        end
        if not attacker.team or not VisibilityCheckAll(attacker.team, target, nil, const.uvVisible) then
            return true, self:ResolveValue("BlindFirePenalty")
        end
        return true, self:ResolveValue("SpotterPenalty"), T(431888134623, "Seen by Spotter")
    end
end

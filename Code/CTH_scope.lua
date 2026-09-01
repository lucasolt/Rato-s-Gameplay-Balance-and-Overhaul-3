-- ========== if you steal this code, rats will enter your house at night and eat all your food. written by rats ==========
function place_scope_pen_cth()
    PlaceObj('ChanceToHitModifier', {
        CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof,
                             aim, opportunity_attack, attacker_pos, target_pos)
            if not attacker or not target then
                return false, 0
            end

            ---- o mesmo aim que a geometria usa: com stance/overwatch a arma ja esta no ombro e a
            ---- luneta ja esta no olho, entao a penalidade de perto tem que valer tambem la.
            if Rat_AngularActive(weapon1, action, attacker) then
                aim = Rat_EffectiveAim(attacker, action, aim, opportunity_attack, target)
            end

            if aim < 1 then
                return false, 0
            end

            local max_dist
            local max_penalty
            local metaText = {}
            local value = 0
            local attacker_pos = attacker_pos or attacker:GetPos()
            local target_pos = target_pos or target:GetPos()
            local dist = attacker_pos:Dist(target_pos)

            local side = attacker and attacker.team and attacker.team.side or ''

            if weapon1 and weapon1:HasComponent("ScopePenalty3") then
                -- scale in the distance after point-blank range to max penalty

                max_dist = (17 * const.SlabSizeX)
                max_penalty = -55

                dist = max_dist - dist
                value = value + Min(0, MulDivRound(dist, max_penalty, max_dist))

            elseif weapon1 and weapon1:HasComponent("ScopePenalty2") then

                max_dist = (14 * const.SlabSizeX)
                max_penalty = -40

                dist = max_dist - dist
                value = value + Min(0, MulDivRound(dist, max_penalty, max_dist))

            elseif weapon1 and weapon1:HasComponent("ScopePenalty1") then

                max_dist = (7 * const.SlabSizeX)
                max_penalty = -20

                dist = max_dist - dist
                value = value + Min(0, MulDivRound(dist, max_penalty, max_dist))
            else
                return false, 0
            end

            if value == 0 then
                return false, 0
            end

            if not (side == 'player1' or side == 'player2') then
                value = AIpenal_reduc(attacker, value)
            end

            return true, value, false
        end,
        Parameters = {
            PlaceObj('PresetParamNumber', {'Name', "max_dist1", 'Value', 8, 'Tag', "<max_dist1>"}),
            PlaceObj('PresetParamNumber', {'Name', "max_dist2", 'Value', 5, 'Tag', "<max_dist2>"}),
            PlaceObj('PresetParamNumber', {'Name', "max_dist3", 'Value', 3, 'Tag', "<max_dist3>"}),
            PlaceObj('PresetParamPercent', {'Name', "base_penalty", 'Tag', "<base_penalty>%"}),
            PlaceObj('PresetParamPercent',
                     {'Name', "max_penalty1", 'Value', -60, 'Tag', "<max_penalty1>%"}),
            PlaceObj('PresetParamPercent',
                     {'Name', "max_penalty2", 'Value', -55, 'Tag', "<max_penalty2>%"}),
            PlaceObj('PresetParamPercent',
                     {'Name', "max_penalty3", 'Value', 45, 'Tag', "<max_penalty3>%"})
        },
        display_name = T(926844781722, "Scoped Close Range"),
        group = "Default",
        id = "ScopePenal"
    })

end

---------------------------------------------------------------------------------------------------------

local t_id_table = {[926844781722] = "Scoped Close Range"}

ratG_T_table['CTH_scope.lua'] = t_id_table

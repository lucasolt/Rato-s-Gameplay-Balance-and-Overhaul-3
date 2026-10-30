---- Simulated aCTH has no graze roll, so gas costs CTH (absorbed into the cone) instead of the trace grazing every hit.
function Rat_SmokeReplacesGraze(weapon, action, attacker)
    return IsACHTActive(weapon, action, attacker, true)
end

local smoke_line_height = {Standing = 130 * guic, Crouch = 70 * guic, Prone = 30 * guic}

local function line_height(obj, pos)
    local stance = IsKindOf(obj, "Unit") and obj:GetHitStance() or ""
    return pos:z() + (smoke_line_height[stance] or 100 * guic)
end

---- Distinct gas voxels crossed by the line; 0 without a lookup when the map has no gas.
function Rat_SmokeVoxelsOnLine(attacker, target, attacker_pos, target_pos)
    if next(g_SmokeObjs) == nil or not attacker_pos or not target_pos then
        return 0
    end
    attacker_pos, target_pos = Rat_ValidZ(attacker_pos), Rat_ValidZ(target_pos)
    local x1, y1 = attacker_pos:xy()
    local x2, y2 = target_pos:xy()
    local z1, z2 = line_height(attacker, attacker_pos), line_height(target, target_pos)
    local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
    local steps = Max(1, point(dx, dy, dz):Len() / (const.SlabSizeZ / 2))
    local count, last = 0, false
    for i = 0, steps do
        local packed = point_pack(WorldToVoxel(x1 + MulDivRound(dx, i, steps),
                                               y1 + MulDivRound(dy, i, steps),
                                               z1 + MulDivRound(dz, i, steps)))
        if packed ~= last then
            last = packed
            if g_SmokeObjs[packed] then
                count = count + 1
            end
        end
    end
    return count
end

function place_smoke_cth()
    PlaceObj('ChanceToHitModifier', {
        CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof,
                             aim, opportunity_attack, attacker_pos, target_pos)
            if not attacker or not weapon1 or not Rat_SmokeReplacesGraze(weapon1, action, attacker) then
                return false, 0
            end
            ---- same exemption vanilla gives ignore_smoke (Unit.lua PrepareAttackArgs)
            if IsFullyAimedAttack(aim) and weapon1:HasComponent("IgnoreGrazingHitsWhenFullyAimed") then
                return false, 0
            end
            attacker_pos = attacker_pos or attacker:GetPos()
            target_pos = target_pos or (IsValid(target) and target:GetPos())
            local n = Rat_SmokeVoxelsOnLine(attacker, target, attacker_pos, target_pos)
            if n == 0 then
                return false, 0
            end
            local ee = const.EnvEffects
            return true, Max(ee.SmokeCTHPenaltyMax, ee.SmokeCTHPenaltyPerVoxel * n)
        end,
        RequireTarget = true,
        RequireActionType = "Any Ranged Attack",
        display_name = T(736150294817, "Through Gas"),
        group = "Default",
        id = "_smoke",
    })
end

---- Fog/dust storm graze (Weapon.lua) is zeroed; a target concealed/obscured beyond 8 tiles costs CTH instead
function place_obscured_cth()
    PlaceObj('ChanceToHitModifier', {
        CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof,
                             aim, opportunity_attack, attacker_pos, target_pos)
            if not (GameState.Fog or GameState.DustStorm) or not attacker or not IsKindOf(target, "Unit") then
                return false, 0
            end
            ---- same exemption as the vanilla weather graze
            if weapon1 and IsFullyAimedAttack(aim) and weapon1:HasComponent("IgnoreGrazingHitsWhenFullyAimed") then
                return false, 0
            end
            local from = attacker_pos or attacker
            local ee = const.EnvEffects
            local value = 0
            if target:IsConcealedFrom(from) then
                value = value + ee.FogCTHPenalty
            end
            if target:IsObscuredFrom(from) then
                value = value + ee.DustStormCTHPenalty
            end
            return value ~= 0, value
        end,
        RequireTarget = true,
        RequireActionType = "Any Ranged Attack",
        display_name = T(503817264951, "Low Visibility"),
        group = "Default",
        id = "_obscured",
    })

    GameStateDefs.Fog.description = T(611482937055, "Visual range is reduced and enemies become concealed at certain distance. Ranged attacks against concealed foes are less accurate.")
    GameStateDefs.DustStorm.description = T(728390416624, "Movement costs are increased. Cover is more effective. Enemies become concealed at certain distance. Ranged attacks against concealed foes are less accurate.")
end

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [736150294817] = "Through Gas",
    [503817264951] = "Low Visibility",
    [611482937055] = "Visual range is reduced and enemies become concealed at certain distance. Ranged attacks against concealed foes are less accurate.",
    [728390416624] = "Movement costs are increased. Cover is more effective. Enemies become concealed at certain distance. Ranged attacks against concealed foes are less accurate.",
}

ratG_T_table['CTH_smoke.lua'] = t_id_table

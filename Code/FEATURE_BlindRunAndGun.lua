---- Blind Run and Gun: a mobile attack planned with no shootable visible enemy keeps its shot stops.
---- At each stop the merc fires at whoever he sees from there; nobody seen = no shot, no refund.
---- A plan with a visible target never goes blind, so its empty stops stay empty (vanilla).
---- Combat actions suspend visibility updates (Visibility.lua:1110), so sight at a stop is checked here.

---- Shot stops of CalcMobileShotAttacks (IModeCombatMovingAttack.lua:300) without the target search.
function Rat_MobileShotSlots(attacker, action, attack_pos, weapon)
    local aim_params = action:GetAimParams(attacker, weapon)
    local combat_path = CombatPath:new()
    combat_path:RebuildPaths(attacker, aim_params.move_ap, nil, "Standing", nil, nil, action.id)
    local voxel_path = combat_path:GetCombatPathFromPos(attack_pos)
    DoneObject(combat_path)
    if not voxel_path then
        return
    end
    local path = {}
    for i, voxel in ipairs(voxel_path) do
        path[i] = point(point_unpack(voxel))
    end
    local path_voxels = CalcPathVoxels(path)
    local atk_voxel = point_pack(attack_pos)
    if path_voxels[1] ~= atk_voxel then
        table.insert(path_voxels, 1, atk_voxel)
    end
    local slots = {atk_voxel}
    local num_shots = aim_params.num_shots
    local step = #path_voxels / Max(1, num_shots)
    for i = 2, num_shots do
        table.insert(slots, 1, path_voxels[1 + step * (i - 1)] or false)
    end
    for i = #slots, 1, -1 do
        if slots[i] and table.find(slots, slots[i]) ~= i then
            slots[i] = false
        end
    end
    return slots
end

local GetMobileShotResults_orig = GetMobileShotResults

function GetMobileShotResults(action, unit, args)
    local results, attack_args = GetMobileShotResults_orig(action, unit, args)
    ---- control is synced, unlike CanBeControlled; AI never plans blind
    if not args.goto_pos or results.shot_canceling_reason or not unit.team or
        unit.team.control ~= "UI" then
        return results, attack_args
    end
    for _, attack in ipairs(results.attacks or empty_table) do
        if attack.mobile_attack_pos then
            return results, attack_args
        end
    end
    local slots = Rat_MobileShotSlots(unit, action, args.goto_pos, action:GetAttackWeapons(unit))
    if not slots then
        return results, attack_args
    end
    local attack_id = args.attack_id and args.attack_id ~= action.id and args.attack_id or
                          "SingleShot"
    local attacks = {}
    for i, voxel in ipairs(slots) do
        attacks[i] = voxel and {mobile_attack_id = attack_id, mobile_attack_pos = voxel,
                                rat_blind = true} or {}
    end
    results.attacks = attacks
    results.rat_blind = true
    return results, attack_args
end

---- Target for a stop whose planned target is gone (or a blind stop): team sight plus what the
---- merc sees from where he stands now, which the frozen g_Visibility does not know yet.
function Rat_MobileFreshTarget(unit, action_id, action, pos, weapon)
    local enemies = table.ifilter(action:GetTargets({unit}), function(_, u)
        return IsValidTarget(u) and not u:IsIncapacitated()
    end)
    for _, enemy in ipairs(GetAllEnemyUnits(unit)) do
        if IsValidTarget(enemy) and not enemy:IsIncapacitated() and
            not enemy:HasStatusEffect("Hidden") and not table.find(enemies, enemy) and
            CheckLOS(enemy, unit, unit:GetSightRadius(enemy)) then
            enemies[#enemies + 1] = enemy
        end
    end
    NetUpdateHash("RunAndGun_Fresh", unit, pos, #enemies)
    local target = FindTargetFromPos(action_id, unit, action, enemies, point(point_unpack(pos)),
                                     weapon)
    ---- drawn now; the visibility update at action end settles it
    if IsValidTarget(target) and not target.visible then
        target:SetVisible(true)
    end
    return target
end

---- Preview of a blind plan: avatar, AP cost and a short line per stop along the path, no target data.
local Targeting_Mobile_orig = Targeting_Mobile

function Targeting_Mobile(dialog, blackboard, command, pt)
    Targeting_Mobile_orig(dialog, blackboard, command, pt)
    local goto_pos = dialog.target_pos
    if command == "delete" or dialog.class == "IModeCombatSprint" or not goto_pos or
        not blackboard.shot_positions then
        return
    end
    if blackboard.rat_blind_drawn == goto_pos and blackboard.fx_shot_lines then
        return
    end
    local any_pos
    for i, pos in ipairs(blackboard.shot_positions) do
        if IsValidTarget(blackboard.shot_targets and blackboard.shot_targets[i]) then
            blackboard.rat_blind_drawn = nil
            return
        end
        any_pos = any_pos or pos
    end
    if not any_pos then
        blackboard.rat_blind_drawn = nil
        return
    end
    blackboard.rat_blind_drawn = goto_pos

    local attacker, action = dialog.attacker, dialog.action
    local movement_mode = IsKindOf(dialog, "IModeCombatMovement")
    UpdateMovementAvatar(dialog, goto_pos, movement_mode and blackboard.fxToDoStance or "Standing",
                         "update_pos")
    SetAPIndicator(false, "unreachable")

    local color = Mesh.ColorFromTextStyle("LineOfFire")
    local fx_shot_lines = {}
    local prev = attacker:GetPos()
    for i, pos in ipairs(blackboard.shot_positions) do
        fx_shot_lines[i] = false
        if pos then
            local x, y, z = point_unpack(pos)
            local attack_pos = point(x, y, z or terrain.GetHeight(x, y) + dialog.fx_lof_offset)
            local dir = (attack_pos - prev):SetZ(0)
            if dir:Len() > 0 then
                fx_shot_lines[i] = AddShotVisual(nil, attack_pos,
                                                 attack_pos + SetLen(dir, 3 * const.SlabSizeX),
                                                 color)
            end
            prev = attack_pos
        end
    end
    blackboard.fx_shot_lines = fx_shot_lines

    local apCost = action:GetAPCost(attacker, {goto_pos = goto_pos})
    if blackboard.fxToDoStance and blackboard.fxToDoStance ~= attacker.stance then
        apCost = apCost + CombatActions["Stance" .. blackboard.fxToDoStance]:GetAPCost(attacker)
    end
    SetAPIndicator(apCost, "moving-attack")
    ObjModified(APIndicator)
end

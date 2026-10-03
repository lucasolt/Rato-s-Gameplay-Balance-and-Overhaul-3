---- Step-out gate (aCTH). The engine (CheckLOF) steps out of cover whenever the aimed spot's single
---- ray is blocked; aCTH scores the whole silhouette and the muzzle ring, so that step can land on a
---- worse tile (Kalyna 2026-10-03: own tile CTH 63, stepped tile 0, muzzle against a wall). Units here
---- also stay where they stepped (shooting stance), so a step-out is kept only when the own tile has no
---- shot at all and the stepped tile is strictly better.
local PrepareAttackArgs_orig = Unit.PrepareAttackArgs
---- single-target shots (Attack/AutoFire are "line", BurstFire "none"); cones and AOE keep vanilla
local gated_aim = {line = true, none = true}

local function aimed_step_pos(attack_args)
    local lof = attack_args.lof
    if not lof then
        return
    end
    local idx = table.find(lof, "target_spot_group", attack_args.target_spot_group or "Torso")
    local l = lof[idx or 1]
    return l and l.step_pos
end

function Unit:PrepareAttackArgs(action_id, args)
    local attack_args = PrepareAttackArgs_orig(self, action_id, args)
    if not args or args.step_pos or args.can_use_covers == false then
        return attack_args
    end
    local action = CombatActions[attack_args.action_id or false]
    local target = args.target
    if not action or not gated_aim[action.AimType] or not IsKindOf(target, "Unit") or
        not IsACHTActive(attack_args.weapon, action, self) then
        return attack_args
    end
    local step = aimed_step_pos(attack_args)
    ---- attack_args.step_pos is overwritten by the LoF result; this is the seed vanilla traced from
    local own = self.return_pos or self:GetOccupiedPos() or GetPassSlab(self) or self:GetPos()
    if not step or not own or IsCloser2D(step, own, const.SlabSizeX / 2) then
        return attack_args
    end

    local own_args = table.copy(args)
    own_args.can_use_covers = false
    own_args = PrepareAttackArgs_orig(self, action_id, own_args)
    ---- own_args.stuck only says the aimed spot's ray hit cover; the CTH below already prices that
    local own_cth = self:CalcChanceToHit(target, action, own_args) or 0
    if own_cth > 0 then
        return own_args
    end
    local step_cth = self:CalcChanceToHit(target, action, attack_args) or 0
    return step_cth > own_cth and attack_args or own_args
end

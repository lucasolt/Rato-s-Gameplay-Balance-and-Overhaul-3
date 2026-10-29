---- Overwatch holds fire below const.Combat.OWMinCTH (aCTH). The engine fires at the first path tile with
---- any line of fire; aCTH prices exposure, so a head sliver drew a floor-CTH shot that spent the
---- shooter's one interrupt of the move (passed_interrupts). Judged when the mover stands on the tile:
---- exposure and target size read his real skeleton, which a planned tile does not have. A held
---- shooter stays off passed_interrupts; CombatGoto drops the provoked tiles and re-checks the rest.
local function HoldsFire(target, attacker)
    local overwatch = g_Overwatch[attacker]
    if not overwatch or not IsValidTarget(target) then
        return
    end
    local action = attacker:GetDefaultAttackAction("ranged", "ungrouped", nil, true, "ignore",
                                                   {skip_ap_check = true})
    local weapon = action and action:GetAttackWeapons(attacker)
    if not weapon or not IsACHTActive(weapon, action, attacker) then
        return
    end
    ---- same args the shot gets in ProvokeOpportunityAttack_Overwatch
    local cth = attacker:CalcChanceToHit(target, action, {
        target = target,
        target_spot_group = "Torso",
        aim = Rat_KillzoneAim(attacker, target, overwatch.aim or 0, action),
        opportunity_attack = true,
        opportunity_attack_type = "Overwatch",
        step_pos = overwatch.pos,
        prediction = false,
    }, "chance_only") or 0
    if cth < const.Combat.OWMinCTH then
        CombatLog("debug", T{Untranslated("<attacker> holds overwatch fire: CTH <cth>"),
                             attacker = attacker:GetLogName(), cth = cth})
        return true
    end
end

local ProvokeFromList_orig = Unit.ProvokeOpportunityAttacksFromList

function Unit:ProvokeOpportunityAttacksFromList(list, ...)
    local filtered
    for i, data in ipairs(list) do
        local held = data[1] == "overwatch" and IsValid(data[2]) and HoldsFire(self, data[2])
        if held and not filtered then
            filtered = table.move(list, 1, i - 1, 1, {})
        elseif filtered and not held then
            filtered[#filtered + 1] = data
        end
    end
    return ProvokeFromList_orig(self, filtered or list, ...)
end

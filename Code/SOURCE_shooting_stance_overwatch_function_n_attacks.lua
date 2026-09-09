function define_getOWattacks_and_aim()
    function Unit:GetOverwatchAttacksAndAim(action, args, unit_ap)

        ---- Shooting Stance will properly modify aim num
        local aim = 0
        if self:HasStatusEffect("shooting_stance") then
            aim = 1
        end
        -------

        action = action or CombatActions.Overwatch
        local weapon, w2 = action:GetAttackWeapons(self)

        ------------ No longer used
        -- local attack = self:GetDefaultAttackAction("ranged", "ungrouped", nil, true, "ignore", {skip_ap_check = true}) --, {skip_ap_check = true}
        -- local AP_delta = attack.ActionPointDelta or 0
        ---------------------------

        unit_ap = unit_ap or g_Combat and self:GetUIActionPoints() or self:GetMaxActionPoints()
        args = table.copy(args)

        -----------------------------------------Retrieves base cost (stance) using the OW combat action
        args.action_cost_only = true
        args.ow_get_atks = false
        local cost = g_Combat and action:GetAPCost(self, args) or 0
        ------------------------------------------

        ------------------------------------------ Prepares atk number calculation by deducting stance ap if any
        local ap = unit_ap - cost
        -----------------------------------------

        -------------------------------------Retrieves attackcost using the OW combat action
        args.ow_get_atks = true
        local atk_cost = action:GetAPCost(self, args)
        --------------------------------------

        -------------------------------------Calculate attack number
        local attacks

        ------Checks if subsequent attacks should have bolting ap cost
        local w2_bolting_cost = 0
        if w2 and rat_canBolt(w2) and not w2.unbolted then
            w2_bolting_cost = rat_get_manual_cyclingAP(self, w2, true) * const.Scale.AP
        end

        local w1_bolting_cost = 0
        if rat_canBolt(weapon) and not weapon.unbolted then
            w1_bolting_cost = rat_get_manual_cyclingAP(self, weapon, true) * const.Scale.AP
        end

        ------- if the weapon is unbolted, the attack cost will automatically default to the unbolted value
        local first_shot_ap = atk_cost

        -- print("First shot ow atk cost", first_shot_ap)

        atk_cost = atk_cost + w1_bolting_cost + w2_bolting_cost

        ap = ap - first_shot_ap

        -- print("unboltable weapon ow atk cost", atk_cost)
        if not atk_cost then
            print("GBO - overwatch calc n attacks, attk cost is nil")
            atk_cost = 0
        end

        if atk_cost <= 0 then
            print("GBO - overwatch calc n attacks, attk cost is less than zero:", atk_cost, "...")
            -- print("... action:", action, "weapon", weapon)
            return 0
        else
            attacks = 1 + (ap / atk_cost)
        end

        if attacks < 1 then
            return 0
        end

        -- print("attacks", attacks)

        attacks = self:CallReactions_Modify("OnCalcOverwatchAttacks", attacks, action, args)
        -- print("number of ow attacks", attacks)
        -------------------------------------

        return attacks, aim
    end
end

define_getOWattacks_and_aim()

-- ok

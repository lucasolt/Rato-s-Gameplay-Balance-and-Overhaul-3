function rat_combat_actions()
    CombatActions.BurstFire.ActionPointDelta = 0
    CombatActions.SingleShot.ActionPointDelta = -2000
    CombatActions.AutoFire.ActionPointDelta = 4000
    CombatActions.MGBurstFire.ActionPointDelta = 1000

    CombatActions.Buckshot.ActionPointDelta = -1000
    CombatActions.BuckshotBurst.ActionPointDelta = 1000

    CombatActions.DualShot.ActionPointDelta = 0

    CombatActions.RunAndGun.ActionPointDelta = 3000
    CombatActions.MobileShot.ActionPointDelta = 0 -- 1000
    CombatActions.RecklessAssault.ActionPointDelta = 3000
    CombatActions.HundredKnives.ActionPointDelta = 3000

    CombatActions.PinDown.ActionPoints = 2000
    --------------------------------------- SingleShot
    CombatActions.SingleShot.GetAPCost = function(self, unit, args)
        local weapon1, weapon2 = self:GetAttackWeapons(unit, args)
        if unit:OutOfAmmo(weapon2) or unit:IsWeaponJammed(weapon2) then
            weapon2 = nil
        end
        if weapon1 and weapon2 then
            return -1
        end

        if not weapon1 then
            return -1
        end
        local weapon = self:GetAttackWeapons(unit, args)
        local action = self

        local ap_extra = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                  args and args.aim or 0, action) or 0

        local ap_delta = rat_getDeltaAP(action, weapon)

        local cycling_ap = 0

        if weapon.unbolted then
            cycling_ap = rat_get_manual_cyclingAP(unit, weapon, true) * const.Scale.AP
        end

        return unit:GetAttackAPCost(self, weapon1, false, args and args.aim or 0, ap_delta) +
                   ap_extra + cycling_ap or -1
    end

    CombatActions.SingleShot.GetActionResults = function(self, unit, args)
        --------------
        if unit.Mobile_aimed then
            args.aim = 1
        end
        -------------
        local attack_args = unit:PrepareAttackArgs(self.id, args)
        local results = attack_args.weapon:GetAttackResults(self, attack_args)
        return results, attack_args

    end

    CombatActions.SingleShot.GetUIState = function(self, units, args)
        local unit = units[1]
        local attackWep = self:GetAttackWeapons(unit, args)
        if not attackWep then
            return "hidden"
        end

        -------------
        if (IsKindOf(attackWep, "PapovkaSKS_1") or IsKindOf(attackWep, "Papovka2SKS_1") or
            IsKindOfClasses(attackWep, "M70_1", "M70D_1")) then
            local subwep = attackWep.subweapons
            if subwep and subwep.Mountfront then
                local mountFrontAmmo = subwep.Mountfront.ammo
                if mountFrontAmmo and mountFrontAmmo.Amount and mountFrontAmmo.Amount > 0 then
                    return "disabled", T(758325374611, "<color AmmoAPColor>Grenade loaded</color>")
                end
            end
        end
        -------------

        return CombatActionGenericAttackGetUIState(self, units, args)
    end

    CombatActions.ChangeWeapon.GetAPCost = function(self, unit, args)

        if unit:CanActivatePerk("Scoundrel") then
            return 0
        end
        local otherSet = "Handheld A"
        if unit and unit.current_weapon == "Handheld A" then
            otherSet = "Handheld B"
        end
        local weapons = unit:GetEquippedWeapons(otherSet)

        -----------------------------
        if weapons == {} then
            return 0
        end

        local ap = 0

        local free_swap = true

        for _, weapon in ipairs(weapons) do
            if IsKindOfClasses(weapon, "Firearm") then
                if IsKindOf(weapon, "HeavyWeapon") then
                    return 4 * const.Scale.AP
                end
                local ap_add = weapon.Rat_swap_ap

                if weapon:HasComponent("FreeWeaponSwap") then
                    ap_add = Max(0, ap_add - 2)
                end

                if not IsKindOfClasses(weapon, "Pistol", "Revolver") or weapon.pistol_swap then
                    free_swap = false
                end

                -- if weapon:HasComponent("Vert_grip_recoil") then
                -- if free_swap then 
                -- free_swap = false
                -- else
                -- ap_add = ap_add +1	
                -- end
                -- end

                ap = ap + ap_add
            elseif IsKindOfClasses(weapon, "MeeleWeapons") then
                if weapon.LargeItem > 0 then
                    ap = ap + 1
                end
            end
        end

        -- print("ap", ap)

        if free_swap then
            if ap < 2 then

                return 0
            end
        end

        return ap * const.Scale.AP

        -------------------------

        -- if unit:FindItemInSlot(otherSet, function(weapon) return weapon:IsWeapon() and weapon:HasComponent("FreeWeaponSwap") end) then
        -- return 0
        -- end

        -- return self.ActionPoints
    end

    CombatActions.DualShot.GetAPCost = function(self, unit, args)

        local weapon1, weapon2 = self:GetAttackWeapons(unit, args)

        if not weapon1 or not weapon2 then
            return -1
        end
        local aim = args and args.aim or 0

        local weapon = weapon1

        local action = self
        local ap_extra1 = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                   args and args.aim or 0, action)
        weapon = weapon2
        local ap_extra2 = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                   args and args.aim or 0, action)

        local ap_extra = Max(ap_extra1, ap_extra2)

        local w1attack = weapon1.AvailableAttacks[1]
        local w2attack = weapon2.AvailableAttacks[1]

        local dual_shot_id = w1attack

        if w1attack == "SingleShot" or w2attack == "SingleShot" then
            dual_shot_id = "SingleShot"
        end

        local ap1 = rat_getDeltaAP(false, weapon1, dual_shot_id) -- + weapon1.ShootAP * const.Scale.AP
        local ap2 = rat_getDeltaAP(false, weapon2, dual_shot_id) -- + weapon2.ShootAP * const.Scale.AP

        local cycling_ap1 = 0

        if weapon1.unbolted then

            cycling_ap1 = rat_get_manual_cyclingAP(unit, weapon1, true) * const.Scale.AP

        end

        local cycling_ap2 = 0

        if weapon2.unbolted then

            cycling_ap2 = rat_get_manual_cyclingAP(unit, weapon2, true) * const.Scale.AP

        end

        local cycling_total = cycling_ap2 + cycling_ap1

        local twohand_cost = 1 * const.Scale.AP

        if unit and HasPerk(unit, "Ambidextrous") then
            twohand_cost = 0
        end

        return Max(unit:GetAttackAPCost(self, weapon1, weapon1.ShootAP, aim, ap1),
                   unit:GetAttackAPCost(self, weapon2, weapon2.ShootAP, aim, ap2)) + ap_extra +
                   twohand_cost + cycling_total

    end

    --------------------------------------------- BurstFire
    CombatActions.BurstFire.Description = T(617859618521, --[[CombatAction BurstFire Description]]
                                            "Shoots <em><num> bullets</em> at the target. The accuracy of each shot is reduced by <em>Recoil</em>. Critical chance is reduced.\n\nOnly the first shot will benefit from <em>Aim</em> bonus.")
    CombatActions.BurstFire.GetUIState = function(self, units, args)
        local unit = units[1]
        local weapon = self:GetAttackWeapons(unit, args)
        local num_shots = weapon:GetAutofireShots(self)
        if not weapon.ammo or weapon.ammo.Amount < num_shots then
            return "disabled", AttackDisableReasons.InsufficientAmmo
        end

        ------------------
        local attackWep = weapon or unit:GetActiveWeapons()
        if (IsKindOf(attackWep, "PapovkaSKS_1") or IsKindOf(attackWep, "Papovka2SKS_1") or
            IsKindOfClasses(attackWep, "M70_1", "M70D_1")) then
            local subwep = attackWep.subweapons
            if subwep and subwep.Mountfront then
                local mountFrontAmmo = subwep.Mountfront.ammo
                if mountFrontAmmo and mountFrontAmmo.Amount and mountFrontAmmo.Amount > 0 then
                    return "disabled", T(163779727424, "<color AmmoAPColor>Grenade loaded</color>")
                end
            end
        end
        ---------------------

        ------------------------------
        local side = unit and unit.team and unit.team.side or ''
        local wep = unit:GetActiveWeapons()

        if IsKindOf(weapon, "AR15") and not weapon:HasComponent("Enable_BurstFire") then
            -- print("no burst")
            return "hidden" -- , T(449447625321, "<color AmmoAPColor>Semi-auto only</color>")
        end
        -------------------------------------

        return CombatActionGenericAttackGetUIState(self, units, args)
    end

    --[[CombatActions.AutoFire.GetUIState = function(self, units, args)
	
		local unit = units[1]
		-----------------------------------------
		
		local side = unit and unit.team and unit.team.side or ''
		local wep = unit:GetActiveWeapons()
		
		------------------------------
	
	
		local state, err = CombatActionGenericAttackGetUIState(self, units, args)
		
		
		if state ~= "enabled" then return state, err end

		
		local weapon = self:GetAttackWeapons(unit, args)
		local autoFire_ammo = weapon:GetAutofireShots(self)
		if not weapon.ammo or weapon.ammo.Amount < autoFire_ammo then
			return "disabled", AttackDisableReasons.InsufficientAmmo
		end
		return "enabled"
	end]]
    CombatActions.BurstFire.GetActionResults = function(self, unit, args)
        local args = table.copy(args)

        args.weapon = self:GetAttackWeapons(unit, args)
        args.num_shots = args.num_shots or args.weapon and args.weapon:GetAutofireShots(self)
        args.multishot = true
        args.damage_bonus = self:ResolveValue("dmg_penalty")

        -- args.cth_loss_per_shot = self:ResolveValue("cth_loss_per_shot")
        -----------------------------------------------
        -- local recoil = get_recoil(unit, args and args.target, self, args and args.weapon or false, args and args.aim) or 0

        -- unit.recoil = recoil
        -- if not args.prediction then

        -- args.cth_loss_per_shot = recoil 
        -- end

        --------------

        if unit.Mobile_aimed then
            args.aim = 1
        end

        -----

        local attack_args = unit:PrepareAttackArgs(self.id, args)
        local results = attack_args.weapon:GetAttackResults(self, attack_args)
        return results, attack_args

    end

    CombatActions.BurstFire.GetAPCost = function(self, unit, args)

        if self.CostBasedOnWeapon then
            local weapon = self:GetAttackWeapons(unit, args)
            local action = self
            local ap_extra = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                      args and args.aim or 0, action) or 0
            local ap_delta = rat_getDeltaAP(self, weapon)

            -- print("burst cost",(unit:GetAttackAPCost(self, weapon, nil, args and args.aim or 0) + ap_delta) + ap_extra or -1)
            return weapon and
                       (unit:GetAttackAPCost(self, weapon, nil, args and args.aim or 0) + ap_delta) +
                       ap_extra or -1
        end

        return self.ActionPoints

    end

    ---------------------------------------------------- MGBurstFire

    CombatActions.MGBurstFire.GetAPCost = function(self, unit, args)

        local weapon = self:GetAttackWeapons(unit, args)
        if not weapon then
            return -1
        end
        local action = self
        local ap_delta = rat_getDeltaAP(self, weapon)

        local ap_extra = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                  args and args.aim or 0, action) or 0

        local cost = unit:GetAttackAPCost(self, weapon, nil, args and args.aim or 0)
        cost = cost + ap_extra + ap_delta
        return cost
    end

    CombatActions.GrizzlyPerk.GetAPCost = function(self, unit, args)
        if self.CostBasedOnWeapon then
            local weapon = self:GetAttackWeapons(unit, args)
            local action = self
            local ap_extra = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                      args and args.aim or 0, action) or 0
            local ap_delta = rat_getDeltaAP(self, weapon)

            if args and args.ow_get_atks then
                ap_extra = 0
            end

            return weapon and
                       (unit:GetAttackAPCost(self, weapon, nil, args and args.aim or 0, ap_delta) +
                           ap_extra) or -1
        end
        return self.ActionPoints
    end

    CombatActions.BuckshotBurst.GetAPCost = function(self, unit, args)

        local weapon1, weapon2 = self:GetAttackWeapons(unit, args)
        if weapon1 and weapon2 then
            return -1
        end
        if not weapon1 then
            return -1
        end
        local weapon = weapon1
        local action = self
        local ap_delta = rat_getDeltaAP(self, weapon)

        local ap_extra = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                  args and args.aim or 0, action) or 0

        return (unit:GetAttackAPCost(self, weapon1, false, args and args.aim or 0) + ap_extra +
                   ap_delta) or -1
    end

    CombatActions.Buckshot.GetAPCost = function(self, unit, args)

        local weapon1, weapon2 = self:GetAttackWeapons(unit, args)
        if weapon1 and weapon2 then
            return -1
        end
        if not weapon1 then
            return -1
        end
        local weapon = weapon1
        local action = self

        local ap_extra = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                  args and args.aim or 0, action) or 0

        return unit:GetAttackAPCost(self, weapon1, false, args and args.aim or 0) + ap_extra or -1
    end

    CombatActions.DoubleBarrel.GetAPCost = function(self, unit, args)

        local weapon1, weapon2 = self:GetAttackWeapons(unit, args)
        if weapon1 and weapon2 then
            return -1
        end
        if not weapon1 then
            return -1
        end
        local weapon = weapon1
        local action = self
        local ap_extra = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                  args and args.aim or 0, action) or 0

        local cost = unit:GetAttackAPCost(self, weapon1, false, args and args.aim or 0) + ap_extra
        return cost and cost + self.ActionPoints or -1
    end

    ----------------------------- Pindown

    CombatActions.PinDown.GetUIState = function(self, units, args)

        local unit = units[1]
        local weapon = self:GetAttackWeapons(unit, args)
        if not weapon or
            (weapon.PreparedAttackType ~= "Pin Down" and weapon.PreparedAttackType ~= "Both") then
            return "hidden"
        end

        if (IsKindOf(weapon, "PapovkaSKS_1") or IsKindOf(weapon, "Papovka2SKS_1")) then
            local subwep = weapon.subweapons
            if subwep and subwep.Mountfront then
                local mountFrontAmmo = subwep.Mountfront.ammo
                if mountFrontAmmo and mountFrontAmmo.Amount and mountFrontAmmo.Amount > 0 then
                    return "disabled", T(676922692594, "<color AmmoAPColor>Grenade loaded</color>")
                end
            end
        end

        if #(self:GetTargets(units) or empty_table) == 0 then
            return "disabled", AttackDisableReasons.NoTarget
        end

        return CombatActionGenericAttackGetUIState(self, units, args)

    end

    -- CombatActions.PinDown.CostBasedOnWeapon = true

    CombatActions.PinDown.GetAPCost = function(self, unit, args)

        local weapon = self:GetAttackWeapons(unit, args)
        if not weapon or
            (weapon.PreparedAttackType ~= "Pin Down" and weapon.PreparedAttackType ~= "Both") then
            return -1
        end

        ------------
        local stance_ap = GetWeapon_StanceAP(unit, weapon) + Get_AimCost(unit)
        if HasPerk(unit, "shooting_stance") then
            stance_ap = (args and args.target and IsKindOf(args.target, "Unit")) and
                            unit:GetShootingStanceAP(args.target, weapon, 1, self) or 0
        end
        ----------------

        local ap = self.ActionPoints
        if HasPerk(unit, "HawksEye") then
            ap = ap -
                     (CharacterEffectDefs.HawksEye:ResolveValue("pindownCostOverwrite") *
                         const.Scale.AP)
        end

        ----------- "Aiming" cost 

        local aim_ap = const.Scale.AP * const.Combat.PindownAimLevelsForAPCost -- Get_AimCost(unit) * base_aim_levels
        local recoil = unit:GetStatusEffect("Rat_recoil")
        local recoil_extra_cost = 0
        if recoil then
            recoil_extra_cost = cRoundDown(recoil:ResolveValue("aim_cost") or 0 *
                                               const.Combat.PindownAimLevelsForAPCost) *
                                    const.Scale.AP
        end
        -----------

        local cycling_ap = 0
        if weapon.unbolted then
            cycling_ap = rat_get_manual_cyclingAP(unit, weapon, true) * const.Scale.AP
        end

        ap = ap + stance_ap + cycling_ap + aim_ap + recoil_extra_cost
        -- ic(ap, stance_ap, cycling_ap, aim_ap, recoil_extra_cost)
        ---------------

        return ap, ap -- Max(ap, unit:GetUIActionPoints()), ap

    end

    CombatActions.PinDown.Description = T(854982151651, --[[CombatAction PinDown Description]]
                                          "<em>Spends all AP</em>\nThe target is <em><GameTerm('Marked')></em>. At the start of next turn, shoot the target if the target is still in the line of sight. The attack will have max aim levels. Each aim level grants <bonus_crit> extra critical chance. This attack bypasses low cover, has reduced penalties to hit body parts and <em>increases the weapon's effective range by 50%</em>.\n\nSnipe requires a clear line and sight to the target.")
    CombatActions.PinDown.DisplayName = T(164165234891, --[[CombatAction PinDown DisplayName]]
                                          "Snipe")

    CombatActions.PinDown.GetActionDescription = function(self, units)
        local unit = units[1]

        local recoil = unit:GetStatusEffect("Rat_recoil")

        local descr = TranslationTable[854982151651] or
                          "<em>Spends all AP</em>\nThe target is <em><GameTerm('Marked')></em>. At the start of next turn, shoot the target if the target is still in the line of sight. The attack will have max aim levels. Each aim level grants <bonus_crit> extra critical chance. This attack bypasses low cover, has reduced penalties to hit body parts and <em>increases the weapon's effective range by 50%</em>.\n\nSnipe requires a clear line and sight to the target."
        if recoil then
            local aim_cost = recoil:ResolveValue("aim_cost") or 0
            local extra_cost = cRoundDown(aim_cost * const.Combat.PindownAimLevelsForAPCost) -- * const.Scale.AP
            if extra_cost > 0 then
                descr = descr ..
                            (TranslationTable[231988463514] or
                                "\n\n<em>Recoil</em> is increasing the AP cost by <em>") ..
                            extra_cost .. '</em>'
            end
        end

        return T {descr, bonus_crit = const.Combat.PindownCritPerAimLevel}
    end
    CombatActions.PinDown.GetActionResults = function(self, unit, args)
        local attack_args = unit:PrepareAttackArgs(self.id, args)
        -------- Moved the logic to FirearmGetAttackResults cause fuck this
        local _, max_aim = unit:GetBaseAimLevelRange(self, args.target)
        args.aim = Max(args.aim or 0, max_aim)
        --------
        local results = attack_args.weapon:GetAttackResults(self, attack_args)
        --------
        results.aim = Max(results.aim or 0, max_aim)
        --------
        return results, attack_args
    end
    -----------------------------OW	
    CombatActions.Overwatch.GetAPCost = function(self, unit, args)

        local weapon, w2 = self:GetAttackWeapons(unit, args)
        if not weapon or
            (weapon.PreparedAttackType ~= "Overwatch" and weapon.PreparedAttackType ~= "Both") then
            return -1
        end

        local attack

        if IsMod_loaded("Msdfsds3") or IsMod_loaded("SmartOverwatch") then -- SmartOverwatch override attack action ap
            attack = -- not R_IsAI(unit)and 
            SO_GetOverwatchAction(unit, weapon) or
                unit:GetDefaultAttackAction("ranged", "ungrouped")
        else
            attack = unit:GetDefaultAttackAction("ranged", "ungrouped")
        end

        local stance = 0
        local action = self
        local param

        ------------------- base cost = shooting stance
        if not HasPerk(unit, "shooting_stance") then
            param = "stance"
            stance = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                              args and args.aim or 0, action, param) or 0

            stance = stance + Get_AimCost(unit)

        else
            param = "rotate"
            stance = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                              args and args.aim or 0, action, param) or 0
        end

        -- print("ow base cost combat action", stance)
        ----------------

        stance = stance + self.ActionPoints
        -- print(stance)
        ------------------------------- atk cost
        local cycling_ap = 0

        if weapon.unbolted then
            cycling_ap = rat_get_manual_cyclingAP(unit, weapon, true) * const.Scale.AP
        end

        if w2 and w2.unbolted then
            cycling_ap = cycling_ap + rat_get_manual_cyclingAP(unit, w2, true) * const.Scale.AP
        end

        local AP_delta = rat_getDeltaAP(attack, weapon) or 0
        local atk_cost = unit:GetAttackAPCost(unit, weapon, nil, args and args.aim or 0) + AP_delta

        atk_cost = atk_cost + cycling_ap
        -- print("atk_cost combat action",atk_cost)
        -------------------------------------

        -------------------- when GetOverwatchAttacksAndAim retrives atk_cost
        if args and args.ow_get_atks then
            return atk_cost
        end

        -------------------- when GetOverwatchAttacksAndAim retrives base cost
        if args and args.action_cost_only then
            return stance
        end
        -----------------------------------

        -- print("total ow cost combat action", atk_cost +stance)

        return Max(unit:GetUIActionPoints(), atk_cost + stance), atk_cost + stance

        ----
    end

    CombatActions.Bandage.Run = function(self, unit, ap, ...)

        unit:RemoveStatusEffect("shooting_stance")
        unit:SetActionCommand("Idle")

        unit:SetActionCommand("Bandage", self.id, ap, ...)
    end

    ------------------UI STATE

    CombatActions.Overwatch.GetUIState = function(self, units, args)
        local unit = units[1]
        local cost = self:GetAPCost(unit, args)

        ----------

        local stance = 0
        -- local action = self

        --[[if not HasPerk(unit, "shooting_stance") then
			-- param = "stance"
			-- stance = unit:GetShootingStanceAP( args and args.target or false, weapon, args and args.aim or 0, action, param) or 0
			-- print(stance)
			if args then
				args.action_cost_only = true
				stance = self:GetAPCost(unit, args)
				args.action_cost_only = nil
			end
		end]]

        if cost < 0 then
            return "hidden"
        end

        if not unit:UIHasAP(cost) then
            -- if not HasPerk(unit, "shooting_stance") then
            -- stance = stance + Get_AimCost(unit)
            -- if unit:UIHasAP(stance) then

            -- return "enabled"
            -- else
            -- return "disabled", GetUnitNoApReason(unit) 
            -- end
            -- else	
            return "disabled", GetUnitNoApReason(unit)
            -- end
        else
            return "enabled"
        end

        -- local attack = unit:GetDefaultAttackAction()
        -- local state, reason = attack:GetUIState(units, args)

        -- return state, reason
        ------------------------

        --------------------------

        -- if not HasPerk(unit, "shooting_stance") then
        -- return "enabled"
        -- else
        -- return "disabled", GetUnitNoApReason(unit)
        -- end
    end

    --------------Description
    CombatActions.Overwatch.Description = T(226634284341,
                                            "<em>Spends all AP</em>. Any targets who move or shoot in the overwatch area will provoke <GameTerm('Interrupt')> <em>attacks</em>. Accuracy is influenced by the unit's <em>Reflexes</em> (Dex + Agi). The attacks will suffer increased <em>Snapshot</em> penalty.")

    CombatActions.Overwatch.GetActionDescription =
        function(self, units, args)
            local unit = units[1]
            local apply, value =
                Presets.ChanceToHitModifier.Default.OpportunityAttack:CalcValue(unit, nil, nil, nil,
                                                                                nil, nil, nil, nil,
                                                                                true)
            local total, cost = self:GetAPCost(unit)
            local attacks = 1
            local descr

            if unit and (cost or -1) >= 0 then
                attacks = unit:GetOverwatchAttacksAndAim()
            end

            descr = g_Combat and self.Description or CombatActions.ExplorationOverwatch.Description
            local description = descr
            if g_Overwatch[unit] and (g_Overwatch[unit].num_attacks or 0) > 0 then
                -- add remaining attacks text
                attacks = g_Overwatch[unit].num_attacks
                description = descr ..
                                  T {
                        133054169959,
                        "<newline><newline>Remaining attacks: <em><attacks></em>",
                        attacks = attacks
                    }
            elseif unit:UIHasAP(cost, self.id) then
                -- add max attacks text
                description = descr ..
                                  T {
                        452784485986,
                        "<newline><newline>Max attacks: <em><attacks></em>",
                        attacks = attacks
                    }
            end

            local action = unit and unit:GetDefaultAttackAction()
            if action and (action.id == "Buckshot" or action.id == "DoubleBarrel") then
                description = description .. "<newline><newline>" ..
                                  T(769183913636,
                                    "Collateral damage might hit units outside the overwatch cone.")
            end

            return description
        end

    ---------------Name

    CombatActions.Overwatch.GetActionDisplayName = function(self, units)

        local name = g_Combat and self.DisplayName or CombatActions.ExplorationOverwatch.DisplayName
        local unit = units[1]
        local attacks = unit:GetOverwatchAttacksAndAim()

        -- if attacks < 1 then
        -- if not HasPerk(unit, "shooting_stance") then
        -- name = T(415612867746, "Prepare Weapon")
        -- else
        -- name = T(769876819564, "Rotate Weapon")
        -- end	
        -- return name
        -- end

        if (name or "") == "" then
            name = Untranslated(self.id)
        end

        return name
    end

    CombatActions.MGRotate.GetAPCost = function(self, unit, args)
        if unit:HasStatusEffect("ManningEmplacement") then
            return -1
        end
        local cost_setup = CombatActions.MGSetup:GetAPCost(unit, args)

        local target = args and args.target -- or GetCursorPos(true)

        local weapon = unit:GetActiveWeapons()
        local rotate_ap = ShootingConeAngle(unit, weapon, target)

        local cost = rotate_ap * const.Scale.AP

        if cost > cost_setup then
            cost = cost_setup
        elseif cost < 1 * const.Scale.AP then
            cost = 1 * const.Scale.AP
        end
        -- cost = Clamp(cost_setup, rotate_ap)
        -- cost = Max(1, cost / const.Scale.AP) 
        return cost
    end

    CombatActions.AutoFire.CostBasedOnWeapon = true
    CombatActions.AutoFire.IsAimableAttack = true

    CombatActions.Attack.GetUIState = function(self, units, args)
        local unit = units[1]
        local weapon = self:GetAttackWeapons(unit, args)

        ---------------------------------------------------
        local attackWep = args and args.weapon or weapon or unit:GetActiveWeapons()

        if (IsKindOf(attackWep, "PapovkaSKS_1") or IsKindOf(attackWep, "Papovka2SKS_1") or
            IsKindOfClasses(attackWep, "M70_1", "M70D_1")) then

            local subwep = attackWep.subweapons

            if subwep and subwep.Mountfront then
                local mountFrontAmmo = subwep.Mountfront.ammo
                if mountFrontAmmo and mountFrontAmmo.Amount and mountFrontAmmo.Amount > 0 then
                    return "disabled", T(188987732816, "<color AmmoAPColor>Grenade loaded</color>")
                end
            end
        end
        -----------

        return CombatActionFiringMetaGetUIState(self, units, args)
    end

    -- CombatActions.AutoFire.GetUIState = function(self, units, args)

    -- local unit = units[1]
    -- local weapon = self:GetAttackWeapons(unit, args)

    ---------------------------------------------------
    -- local attackWep = args and args.weapon or weapon or unit:GetActiveWeapons()

    -- if (IsKindOf(attackWep, "PapovkaSKS_1") or IsKindOf(attackWep, "Papovka2SKS_1") or IsKindOfClasses( attackWep, "M70_1","M70D_1")) then

    -- local subwep = attackWep.subweapons

    -- if subwep and subwep.Mountfront then
    -- local mountFrontAmmo = subwep.Mountfront.ammo
    -- if mountFrontAmmo and mountFrontAmmo.Amount and mountFrontAmmo.Amount > 0 then
    -- return "disabled", T(565497791697, "<color AmmoAPColor>Grenade loaded</color>")
    -- end
    -- end
    -- end
    --------------------------------------------------

    -- local state, err = CombatActionGenericAttackGetUIState(self, units, args)
    -- if state ~= "enabled" then return state, err end

    -- local autoFire_ammo = weapon:GetAutofireShots(self)
    -- if not weapon.ammo or weapon.ammo.Amount < autoFire_ammo then
    -- return "disabled", AttackDisableReasons.InsufficientAmmo
    -- end
    -- return "enabled"
    -- end

    CombatActions.AutoFire.GetAPCost = function(self, unit, args)

        if self.CostBasedOnWeapon then
            local weapon = self:GetAttackWeapons(unit, args)
            local action = self
            local ap_extra = unit:GetShootingStanceAP(args and args.target or false, weapon,
                                                      args and args.aim or 0, action) or 0
            -- print("ap_extra", ap_extra)
            local ap_delta = rat_getDeltaAP(self, weapon)

            if args and args.ow_get_atks then
                ap_extra = 0
            end

            return weapon and
                       (unit:GetAttackAPCost(self, weapon, nil, args and args.aim or 0) + ap_delta) +
                       ap_extra or -1
        end

        return self.ActionPoints
    end

    -- CombatActions.RecklessAssault.ActionPoints = 7000

    CombatActions.RecklessAssault.GetAimParams = function(self, unit, weapon)
        if self.AimType == "cone" then
            return weapon:GetAreaAttackParams(self.id, unit)
        elseif self.AimType == "mobile" then
            local shots = (self:ResolveValue("mobile_num_shots") - 1) or 1
            if IsKindOf(weapon, "SubmachineGun") and weapon:HasComponent("Enable_RunAndGun") then
                shots = shots + 1
            elseif IsKindOf(weapon, "AssaultRifle") then
                shots = shots - 1
            end
            local move_ap = rat_getMobileshot_moveAP(self, unit, weapon) -- self:ResolveValue("mobile_move_ap")
            assert(move_ap)
            return {num_shots = shots, move_ap = move_ap * const.Scale.AP}
        elseif self.AimType == "parabola aoe" or self.AimType == "line aoe" then
            return weapon.AreaOfEffect
        end

        return 0
    end

    CombatActions.RecklessAssault.GetUIState = function(self, units, args)
        if not g_Combat then
            return "disabled", AttackDisableReasons.CombatOnly
        end

        -------------------------
        local unit = units[1]

        local actions = unit.ui_actions
        -- print("act", actions)
        -- local weapon = self:GetAttackWeapons(unit, args)
        if actions["RunAndGun"] ~= nil then
            local ui_status = actions["RunAndGun"]
            -- print("ui", ui_status)
            if ui_status and (ui_status == "Hidden" or ui_status == "disabled") then
                local p, reason = CombatActions.RunAndGun.GetUIState(self, units, args)
                return "disabled", reason
            end
        else
            return "disabled",
                   T(565263742146, "<color AmmoAPColor>Weapon not capable of burst</color>")
        end

        if unit:HasStatusEffect("R_outofbreath") then
            return "disabled", T(865874231348, "<color AmmoAPColor>Out of Breath</color>")
        end

        return CombatActionGenericAttackGetUIState(self, units, args)

    end

    CombatActions.RunAndGun.GetUIState = function(self, units, args)
        if not g_Combat then
            return "disabled", AttackDisableReasons.CombatOnly
        end

        ---------------------------------
        local unit = units[1]

        if unit:HasStatusEffect("R_outofbreath") then
            return "disabled", T(536142745929, "<color AmmoAPColor>Out of Breath</color>")
        end

        return CombatActionGenericAttackGetUIState(self, units, args)

    end

    CombatActions.RunAndGun.GetAPCost = function(self, unit, args)
        local cost, cost_aimed = rat_MobileAction_AP(self, unit)

        -- if unit:UIHasAP(cost_aimed, self.id) then
        return cost_aimed, true
        -- end

        -- return cost, false
    end

    CombatActions.RunAndGun.GetActionResults = function(self, unit, args)
        local weapon = self:GetAttackWeapons(unit)
        args.attack_id = "BurstFire"
        args.num_shots = weapon and weapon:GetAutofireShots("BurstFire") or
                             CombatActions.BurstFire:ResolveValue("num_shots")
        args.multishot = true

        ---

        local cost, aimed = self.GetAPCost(self, unit, args)

        if aimed then
            args.aim = 1
        end

        return GetMobileShotResults(self, unit, args)
    end

    CombatActions.TakeCover.ActionPoints = 3000

    -- CombatActions.RecklessAssault.Description = T(864921833364, "Make a longer <em>Run and Gun</em>, firing more shots. Move to a new position, using up to <em><DisplayMoveAP> AP</em> Smiley will be <em>Out of Breath</em> after use. Can't be used when <em>Out of Breath</em>.")
    CombatActions.SingleShot.Description = T(585854196899,
                                             "Cheap attack that conserves ammo. Has bonus critical chance based on <em>Marksmanship</em> and <em>Dexterity</em> when <em>aimed</em>.")
    -- CombatActions.RunAndGun.Description = T(614189548956, "<em>Once per turn</em>. Move to a new position, using up to <em><DisplayMoveAP> AP</em>. Fire a number of bursts during movement toward the closest enemies. Each shot suffers increased <em>Hipfire</em> and <em>Recoil</em> accuracy penalties.")
    CombatActions.AutoFire.Description = T(373274572555,
                                           "Shoots a hail of <em><bullets> bullets</em> and inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Maximum <em>aim</em> level reduced. Critical chance is reduced")
    CombatActions.DualShot.Description = T(364947777453,
                                           "The Dual Shot attack produces a Basic Attack from each gun. Maximum <em>aim</em> level is reduced. Has a penalty based on <em>Dexterity</em>.")
    CombatActions.MGSetup.Description = T(564696256945,
                                          "Focus on a cone-shaped area, immobilizing yourself and going <em>prone</em>. You can only shoot enemies inside that cone. Accuracy is increased and enemies will provoke <em>interrupt</em> attacks with actions inside the cone (even if your AP are spent). <em>Interrupt</em> attacks have bonus accuracy. Your weapon will have increased <em>Shooting Angle</em> while you are in setup.")

    CombatActions.RunAndGun.Run = function(self, unit, ap, ...)

        local IsAimed = IsAimed_Mobile(self, unit, ap)
        if IsAimed then
            unit.Mobile_aimed = true
        end

        unit:SetActionCommand("RunAndGun", self.id, ap, ...)
    end

    CombatActions.MobileShot.Run = function(self, unit, ap, ...)

        local IsAimed = IsAimed_Mobile(self, unit, ap)
        if IsAimed then
            unit.Mobile_aimed = true
        end

        unit:SetActionCommand("RunAndGun", self.id, ap, ...)

    end
    CombatActions.RecklessAssault.Run = function(self, unit, ap, ...)

        local IsAimed = IsAimed_Mobile(self, unit, ap)
        if IsAimed then
            unit.Mobile_aimed = true
        end

        unit:SetActionCommand("RecklessAssault", self.id, ap, ...)

    end

    CombatActions.RunAndGun.GetActionDescription = function(self, units)
        local description = self.Description
        local unit = units and units[1]
        if not unit then
            return self:GetActionDisplayName()
        end

        local damage, base, bonus = self:GetActionDamage(unit)
        local num_shots = self:ResolveValue("mobile_num_shots")
        local penalty = Presets.ChanceToHitModifier.Default.RunAndGun:ResolveValue("Penalty")
        -- description = T{description, damage = damage, basedamage = base, bonusdamage = bonus, num_shots = num_shots, penalty = penalty}

        ----------
        local weapon = self:GetAttackWeapons(unit) -- or unit:GetActiveWeapons()
        local DisplayMoveAP = rat_getMobileshot_moveAP(self, unit, weapon)
        local description = T(336535188124,
                              "Move to a new position, using up to <em>" .. DisplayMoveAP ..
                                  " Move AP</em>.\n\nFire a number of bursts during movement toward the closest enemies. \n\nEach shot suffers increased <em>Hipfire</em> and <em>Recoil</em> accuracy penalties.")

        --------------------------
        local args = false
        local cost, aimed = self.GetAPCost(self, unit, args)

        if aimed then
            description = T(466718396934,
                            "Move to a new position, using up to <em>" .. DisplayMoveAP ..
                                " Move AP</em>.\n\nFire a number of bursts during movement toward the closest enemies. \n\nEach shot has <em>1 aim level</em>, but <em>aim accuracy is reduced by half</em>. \n\nEach shot suffers increased <em>Snapshot</em> and <em>Recoil</em> accuracy penalties.")
        end

        description = description .. T(312473917195, "\n\nThe unit will be <em>Out of Breath</em>.")

        if unit.stance ~= "Standing" then
            description = description ..
                              T(801805830695, "<newline>You will end up in Standing stance.")
        end

        return description
    end

    CombatActions.RunAndGun.GetActionDisplayName = function(self, units)
        local name = self.DisplayName
        local unit = units[1]
        local args = false
        local cost, aimed = self.GetAPCost(self, unit, args)

        if aimed then
            name = name .. T " (Aimed)"
        end

        return name

    end

    CombatActions.MobileShot.GetAPCost = function(self, unit, args)

        -- local weapon = self:GetAttackWeapons(unit)
        -- local att_cost = unit:GetAttackAPCost(self, weapon, nil, args and args.aim or 0)--CombatActions.BurstFire.GetAPCost(self, unit, args)
        -- local ap_delta = rat_getDeltaAP(self, weapon)
        -- local cost = att_cost + ap_delta

        -- local ap_extra = mobile_stance_ap(unit, weapon)
        -- local cost_aimed = cost + ap_extra

        local cost, cost_aimed = rat_MobileAction_AP(self, unit)

        -- if unit:UIHasAP(cost_aimed, self.id) then
        return cost_aimed, true
        -- end

        -- return cost, false
    end

    CombatActions.MobileShot.GetActionResults = function(self, unit, args)
        local cost, aimed = self.GetAPCost(self, unit, args)

        if aimed then
            args.aim = 1
            -- print("RNG aim", args.aim)
        end

        return GetMobileShotResults(self, unit, args)
    end

    CombatActions.MobileShot.GetUIState = function(self, units, args)
        if not g_Combat then
            return "disabled", AttackDisableReasons.CombatOnly
        end
        ----
        local unit = units[1]
        local side = unit and unit.team and unit.team.side or ''

        local attackWep = self:GetAttackWeapons(unit, args)

        if (IsKindOf(attackWep, "PapovkaSKS_1") or IsKindOf(attackWep, "Papovka2SKS_1") or
            IsKindOfClasses(attackWep, "M70_1", "M70D_1")) then
            local subwep = attackWep.subweapons
            if subwep and subwep.Mountfront then
                local mountFrontAmmo = subwep.Mountfront.ammo
                if mountFrontAmmo and mountFrontAmmo.Amount and mountFrontAmmo.Amount > 0 then
                    return "disabled", T(359627666793, "<color AmmoAPColor>Grenade loaded</color>")
                end
            end
        end

        if unit:HasStatusEffect("R_outofbreath") then
            return "disabled", T(545341281514, "<color AmmoAPColor>Out of Breath</color>")

        end

        -------

        return CombatActionGenericAttackGetUIState(self, units, args)
    end

    CombatActions.MobileShot.GetActionDisplayName = function(self, units)
        local name = self.DisplayName
        local unit = units[1]
        local args = false
        local cost, aimed = self.GetAPCost(self, unit, args)

        if aimed then
            name = name .. T " (Aimed)"
        end

        return name

    end

    CombatActions.MobileShot.GetActionDescription = function(self, units)
        local description = self.Description
        local unit = units and units[1]
        if not unit then
            return self:GetActionDisplayName()
        end
        ----------------

        local weapon = self:GetAttackWeapons(unit) -- or unit:GetActiveWeapons()
        local DisplayMoveAP = rat_getMobileshot_moveAP(self, unit, weapon)
        -- description = T(293499216453, "<em>Once per turn</em>. Move to a new location using up to <em>" .. DisplayMoveAP .. " Move AP</em>, and then shoot the closest enemy.\n\nThe attack suffers increased <em>Hipfire</em> accuracy penalty.")	
        description = T(941284364456, "Move to a new position, using up to <em>" .. DisplayMoveAP ..
                            " Move AP</em>.\n\nFire a number of shots during movement toward the closest enemies. \n\nEach shot suffers increased <em>Hipfire</em> accuracy penalty.")
        local args = false
        local cost, aimed = self.GetAPCost(self, unit, args)

        if aimed then
            description = T(283631569874,
                            "Move to a new position, using up to <em>" .. DisplayMoveAP ..
                                " Move AP</em>.\n\nFire a number of shots during movement toward the closest enemies. \n\nEach shot has <em>1 aim level</em>, but <em>aim accuracy is reduced by half</em>. \n\nEach shot suffers increased <em>Snapshot</em> accuracy penalty.")
        end

        description = description .. T(966648741688, "\n\nThe unit will be <em>Out of Breath</em>.")
        -------

        local damage, base, bonus = self:GetActionDamage(unit)
        return T {description, damage = damage, basedamage = base, bonusdamage = bonus}

    end

    CombatActions.RecklessAssault.GetActionResults =
        function(self, unit, args)
            local weapon = self:GetAttackWeapons(unit)
            args.attack_id = "BurstFire"
            args.num_shots = weapon and weapon:GetAutofireShots("BurstFire") or
                                 CombatActions.BurstFire:ResolveValue("num_shots")
            args.multishot = true

            ---

            local cost, aimed = self.GetAPCost(self, unit, args)

            if aimed then
                args.aim = 1
                -- print("RNG aim", args.aim)
            end

            return GetMobileShotResults(self, unit, args)
        end

    CombatActions.RecklessAssault.GetActionDescription = function(self, units)

        local unit = units and units[1]
        local weapon = self:GetAttackWeapons(unit) -- or unit:GetActiveWeapons()
        local DisplayMoveAP = rat_getMobileshot_moveAP(self, unit, weapon)
        local description = T(317545478698,
                              "Make a longer <em>Run and Gun</em>, firing more shots. Move to a new position, using up to <em>" ..
                                  DisplayMoveAP ..
                                  " Move AP</em>. Smiley will be <em>Out of Breath</em> after use. Can't be used when <em>Out of Breath</em>.")

        local args = false
        local cost, aimed = self.GetAPCost(self, unit, args)

        if aimed then
            description = T(958156855386,
                            "Make a longer <em>Run and Gun</em>, firing more shots. Move to a new position, using up to <em>" ..
                                DisplayMoveAP ..
                                " Move AP</em>. Smiley will be <em>Out of Breath (2 stacks)</em> after use. Can't be used when <em>Out of Breath</em>.\n\nEach shot has <em>1 aim level</em>, but <em>aim accuracy is reduced by half</em>.")
        end

        return description

    end

    CombatActions.RecklessAssault.GetAttackWeapons =
        function(self, unit, args)
            if args and args.weapon then
                return args.weapon
            end
            local weapon = CombatActions.RunAndGun:GetAttackWeapons(unit)

            if weapon then
                return weapon
            end

            return unit:GetActiveWeapons("SubmachineGun")

        end

    CombatActions.RecklessAssault.GetAPCost = function(self, unit, args)

        local cost, cost_aimed = rat_MobileAction_AP(self, unit)
        if unit:UIHasAP(cost_aimed, self.id) then

            return cost_aimed, true
        end

        return cost, false
    end

    CombatActions.RecklessAssault.GetActionDisplayName = function(self, units)
        local name = T(891514871831, "Reckless Assault")
        local unit = units[1]
        local args = false
        local cost, aimed = self.GetAPCost(self, unit, args)

        if aimed then
            name = name .. T " (Aimed)"
        end

        return name

    end

    CombatActions.HundredKnives.GetAPCost = function(self, unit, args)
        local weapon = self:GetAttackWeapons(unit, args)
        local cost = unit:GetAttackAPCost(self, self:GetAttackWeapons(unit, args), unit.ActionPoint)
        local delta = rat_getDeltaAP(self, weapon)

        cost = cost + delta

        return cost
    end

    CombatActions.HundredKnives.GetUIState = function(self, units, args)

        local unit = units[1]
        local weapon1 = self:GetAttackWeapons(unit, args)
        if not weapon1 then
            return "disabled", AttackDisableReasons.KnifeWeapon
        end
        if not g_Combat then
            return "disabled", AttackDisableReasons.CombatOnly
        end

        ----

        if unit:HasStatusEffect("R_outofbreath") then
            return "disabled", T(956881287967, "<color AmmoAPColor>Out of Breath</color>")

        end

        -------

        return CombatActionGenericAttackGetUIState(self, units, args)

    end

    CombatActions.HundredKnives.GetAimParams = function(self, unit, weapon)
        if self.AimType == "cone" then
            return weapon:GetAreaAttackParams(self.id, unit)
        elseif self.AimType == "mobile" then
            local shots = self:ResolveValue("mobile_num_shots") or 1

            -- shots = shots + 1
            local move_ap = rat_getMobileshot_moveAP(self, unit, weapon) -- self:ResolveValue("mobile_move_ap")
            assert(move_ap)

            return {num_shots = shots, move_ap = move_ap * const.Scale.AP}
        elseif self.AimType == "parabola aoe" or self.AimType == "line aoe" then
            return weapon.AreaOfEffect
        end

        return 0

    end

    CombatActions.HundredKnives.GetActionDescription = function(self, units)

        local unit = units and units[1]
        local weapon = self:GetAttackWeapons(unit) -- or unit:GetActiveWeapons()
        local DisplayMoveAP = rat_getMobileshot_moveAP(self, unit, weapon)
        local description = T(248617882285,
                              "Move to another position using up to <em>" .. DisplayMoveAP ..
                                  " Move AP</em>, while <em>throwing knives</em> at nearby enemies.")

        description = description .. T(258829833148, "\n\nBlood will be <em>Out of Breath</em>.")

        return description

    end

    CombatActions.MobileShot.GetAimParams = function(self, unit, weapon)
        if self.AimType == "cone" then
            return weapon:GetAreaAttackParams(self.id, unit)
        elseif self.AimType == "mobile" then
            local shots = 3 -- (self:ResolveValue("mobile_num_shots")) or 1

            local move_ap = rat_getMobileshot_moveAP(self, unit, weapon) -- self:ResolveValue("mobile_move_ap")
            assert(move_ap)

            return {num_shots = shots, move_ap = move_ap * const.Scale.AP}
        elseif self.AimType == "parabola aoe" or self.AimType == "line aoe" then
            return weapon.AreaOfEffect
        end

        return 0
    end

    CombatActions.RunAndGun.GetActionDamage = function(self, unit, target, args)
        local weapon = self:GetAttackWeapons(unit, args)
        -- print(self)
        if not weapon then
            return 0
        end
        local damage = unit:GetBaseDamage(weapon)

        local num_shots = self:ResolveValue("mobile_num_shots")
        ----------------
        if IsKindOf(weapon, "SubmachineGun") and weapon:HasComponent("Enable_RunAndGun") then
            num_shots = 4
        elseif IsKindOf(weapon, "VSK94_1") then
            num_shots = 2
            if weapon:HasComponent("Enable_RunAndGun") then
                num_shots = num_shots + 1
            end
        elseif (IsKindOf(weapon, "AssaultRifle") or IsKindOf(weapon, "SniperRifle") or
            IsKindOf(weapon, "MachineGun")) then
            num_shots = 2
        end

        local num_shots_real = weapon and weapon:GetAutofireShots(self) -- or CombatActions.BurstFire:ResolveValue("num_shots")

        num_shots =
            "<style CrosshairAPTotal><color PDABrowserTextHighlight>" .. num_shots .. "X " ..
                "</color></style>"
        return T(num_shots .. num_shots_real .. "X" .. damage)

    end

    CombatActions.MobileShot.GetActionDamage = function(self, unit, target, args)
        local weapon = self:GetAttackWeapons(unit, args)

        if not weapon then
            return 0
        end
        local damage = unit:GetBaseDamage(weapon)

        local num_shots = 3

        -- local num_shots_real = weapon and weapon:GetAutofireShots(self)-- or CombatActions.BurstFire:ResolveValue("num_shots")

        num_shots =
            "<style CrosshairAPTotal><color PDABrowserTextHighlight>" .. num_shots .. "X " ..
                "</color></style>"
        return T(num_shots .. damage)

    end

    CombatActions.RunAndGun.GetAimParams = function(self, unit, weapon)
        if self.AimType == "cone" then
            return weapon:GetAreaAttackParams(self.id, unit)
        elseif self.AimType == "mobile" then
            local shots = 3 -- (self:ResolveValue("mobile_num_shots")-1) or 1

            if IsKindOf(weapon, "SubmachineGun") and weapon:HasComponent("Enable_RunAndGun") then
                -- print("sub")
                shots = shots + 1
            elseif IsKindOf(weapon, "VSK94_1") then
                shots = 2
                if weapon:HasComponent("Enable_RunAndGun") then
                    shots = shots + 1
                end
            elseif IsKindOfClasses(weapon, "AssaultRifle", "SniperRifle") then
                -- print("ar")
                shots = shots - 1
            end

            -- if weapon:HasComponent("heavy_stock_rungun") then
            -- shots = shots -1
            -- end

            -- print("here")
            local move_ap = rat_getMobileshot_moveAP(self, unit, weapon) -- self:ResolveValue("mobile_move_ap")
            assert(move_ap)
            -- self:SetParameter("DisplayMoveAP", move_ap)
            return {num_shots = shots, move_ap = move_ap * const.Scale.AP}
        elseif self.AimType == "parabola aoe" or self.AimType == "line aoe" then
            return weapon.AreaOfEffect
        end

        return 0
    end

    --[[CombatActions.MGBurstFire.GetActionDescription = function(self,units,args)
		local description = self.Description
		if (description or "") == "" then
			description = self:GetActionDisplayName()
		end

		local unit = units[1]
		local coneDescription = T{264452658232, ""}
		local interrupts_info = ""
		local overwatch = g_Overwatch[unit]
		if overwatch and overwatch.permanent then
			local attacks = overwatch.num_shots
			coneDescription = T(480046777812, " within the set cone")
			interrupts_info = T{757307734445, "<newline><newline>Remaining interrupt attacks: <interrupts>", interrupts = unit:GetNumMGInterruptAttacks()}
			--interrupts_info = T{889817517679, "<newline><newline>Remaining interrupt attacks: <interrupts>", interrupts = attacks}
		end

		return T{description, coneDescription = coneDescription, interrupts_info = interrupts_info}
	end]]

    CombatActions.MGBurstFire.GetActionDamage = function(self, unit, target, args)
        local weapon = args and args.weapon or self:GetAttackWeapons(unit, args)
        if not weapon then
            return 0
        end
        local base = unit and unit:GetBaseDamage(weapon) or weapon.Damage
        local penalty = self:ResolveValue("dmg_penalty")
        local num_shots = weapon:GetAutofireShots(self)
        base = MulDivRound(base, Max(1, 100 + penalty), 100)
        local damage = num_shots * base
        return damage, base, damage - base
    end

    CombatActions.MGBurstFire.GetActionResults = function(self, unit, args)
        local args = table.copy(args)
        args.weapon = args.weapon or self:GetAttackWeapons(unit, args)
        args.num_shots = args.num_shots or args.weapon and args.weapon:GetAutofireShots(self)
        args.multishot = true
        args.damage_bonus = 0
        -- args.cth_loss_per_shot = self:ResolveValue("cth_loss_per_shot")
        local attack_args = unit:PrepareAttackArgs(self.id, args)
        local results = attack_args.weapon:GetAttackResults(self, attack_args)
        return results, attack_args
    end

    CombatActions.MGPack.GetAPCost = function(self, unit, args)
        if unit:HasStatusEffect("ManningEmplacement") or unit.RATOAI_used_mg_setup_this_turn then
            return -1
        end
        self.ActionPoints = unit:GetAttackAPCost(self.action, self.weapon, self.ActionPoints)

        return self.ActionPoints
    end

    for _, param in ipairs(CombatActions.HundredKnives.Parameters) do
        if param.Name == 'mobile_num_shots' then
            param.Value = 3
        end
        g_PresetParamCache[CombatActions.HundredKnives]['mobile_num_shots'] = 3
    end

    for _, param in ipairs(CombatActions.RunAndGun.Parameters) do
        if param.Name == 'mobile_move_ap' then
            param.Value = 10
        end
        g_PresetParamCache[CombatActions.RunAndGun]['mobile_move_ap'] = 10
    end

    for _, param in ipairs(CombatActions.BurstFire.Parameters) do
        if param.Name == 'dmg_penalty' then
            param.Value = 0
        end
        g_PresetParamCache[CombatActions.BurstFire]['dmg_penalty'] = 0
    end

    for _, param in ipairs(CombatActions.AutoFire.Parameters) do
        if param.Name == 'dmg_penalty' then
            param.Value = 0
        end
        if param.Name == 'num_shots' then
            param.Value = 10
        end
        g_PresetParamCache[CombatActions.AutoFire]['num_shots'] = 10
        g_PresetParamCache[CombatActions.AutoFire]['dmg_penalty'] = 0
    end

    g_PresetParamCache[CombatActions.MGBurstFire]['dmg_penalty'] = 0
    g_PresetParamCache[CombatActions.MGBurstFire]['num_shots'] = 6

end

---------------------------------------------------------------------------------------------------
---- O COMPONENTE "DEITAR" DO CUSTO DO MGSETUP, EM UM LUGAR SO
----
---- Fonte unica para os dois lados que precisam desta parcela: o `GetAPCost` logo abaixo e as
---- policies de posicionamento da IA (RATOAI: AIPolicyMGSetupAP, AIPolicyMGSetupPosScore), que
---- DESCONTAM o termo medido da postura atual e RECOLOCAM o termo medido da postura do destino.
---- Enquanto a formula esteve escrita nos dois lugares ela divergiu -- e foi exatamente o
---- BUGFIX B29d do RATOAI ("a policy dizia sim e a acao dizia nao").
----
---- `from_stance` (opcional): mede a partir daquela postura em vez da atual.
---- `Unit:GetStanceToStanceAP` devolve -1 quando ja se esta nela (dai o `Max(0, ...)`) e ja
---- respeita a perk `HitTheDeck`, que zera o custo de ir para Prone.
---------------------------------------------------------------------------------------------------
function rat_MGSetup_StanceAP(unit, from_stance, ignore_free_move)
    if not unit or unit:HasStatusEffect("ManningEmplacement") then
        return 0 ---- quem esta no emplacamento nao muda de postura
    end

	----  Desabilitado pra ver se a IA usa
	--if true then
	--	return 0
	--end 

    local ap = Max(0, unit:GetStanceToStanceAP("Prone", from_stance))

    -----------------------------------------------------------------------------------------------
    ---- FREE MOVE PAGA O DEITAR -- senao "aperte prone antes" vira desconto de 2 AP.
    ----
    ---- As acoes de postura (`StanceStanding`, `StanceCrouch`, `StanceProne`, `Stance`) tem
    ---- `UseFreeMove = true` no preset. O MGSetup NAO tem -- e nao pode ganhar, porque a flag e
    ---- tudo-ou-nada: tornaria o custo INTEIRO pagavel com free move, nao so esta parcela.
    ----
    ---- Sem este desconto os dois caminhos deixaram de custar o mesmo, que era justamente o que o
    ---- bloco de baixo afirmava garantir. Com B de AP normal e 2 de free move, de pe:
    ----     deitar antes (StanceProne, free) e montar  ->  sobra B - StanceAP - 2
    ----     montar direto de pe                        ->  sobra B - StanceAP - 4
    ---- Ou seja: 2 AP de premio para quem lembrasse de apertar o botao de prone primeiro. Micro
    ---- gratuito, do tipo que o design nao deve recompensar.
    ----
    ---- NAO ha vazamento de AP. `MGSetup` e `ActionType = "Ranged Attack"`, e `Unit:ConsumeAP`
    ---- remove `FreeMove` para essa categoria; o `OnRemoved` do efeito devolve o saldo nao gasto
    ---- (`ConsumeAP(free_move_ap)`), simetrico ao `GainAP` do `OnAdded`. O pool morre no momento da
    ---- montagem de qualquer jeito -- descontar esta parcela contra ele so antecipa um gasto certo.
    ----
    ---- E pelo mesmo motivo NAO da para usar `args.goto_ap`, que seria o caminho fino (deixar o
    ---- `ConsumeAP` debitar so esta parcela do free move): aquele bloco do `ConsumeAP` roda DEPOIS
    ---- do `RemoveStatusEffect("FreeMove")`, com `free_move_ap` ja zerado. O `HasAP` concederia o
    ---- desconto e o `ConsumeAP` cobraria cheio -- pior que nao ter desconto nenhum. Descontar
    ---- aqui, como o `CombatActionMeleeGetCost` do jogo base faz com o `goto_ap` dele, e o padrao
    ---- que funciona nesta engine.
    ----
    ---- `ignore_free_move` existe para a IA: o `AIPlayAttacks` (CombatAI.lua:202) remove `FreeMove`
    ---- ANTES de escolher signature action, entao quando a IA monta a MG o pool ja e zero. As
    ---- policies dela pontuam destinos ENQUANTO o pool ainda existe, e sem esta valvula orcariam o
    ---- custo com um desconto que a execucao nao vai ter -- a assinatura exata do B29d.
    -----------------------------------------------------------------------------------------------
    if ignore_free_move then
        return ap
    end

    -----------------------------------------------------------------------------------------------
    ---- O DESCONTO E EM AP INTEIRO. `free_move_ap` e um orcamento de MOVIMENTO e vive fora da
    ---- grade: `FreeMove.OnAdded` calcula `MulDivRound(Agility - 40, const.Scale.AP, 10)`, entao
    ---- Agility 55 da 1500 -- um AP e meio. Isso e legitimo para andar, onde o custo por tile
    ---- tambem e fracionado, e nao e legitimo aqui: custo de ACAO no jogo e sempre multiplo de
    ---- `const.Scale.AP`. Descontar 1500 crus de uma parcela de 2000 devolvia 500, e o MGSetup
    ---- inteiro passava a custar 6500 -- 6,5 AP, numero que nao existe em lugar nenhum da UI.
    ----
    ---- Piso na grade, e o piso e o lado certo: com 1 de free move o desconto e 1, nunca 2. Com
    ---- os numeros medidos (custo 8, parcela de prone 2, free 1,5):
    ----     deitar na mao   -> prone custa 2, dos quais 1 de free e 1 de AP; depois monta por 6
    ----                        ============================================> 7 de AP real
    ----     montar de pe    -> 8 - 2 + (2 - 1) = 7
    ---- Sem o piso o caminho de pe sairia por 6,5, ou seja MAIS BARATO que fazer na mao -- o
    ---- pedagio invertido, que e tao ruim quanto o original.
    ----
    ---- `x % const.Scale.AP` NAO e o no-op que o CLAUDE.md do RATOAI manda desconfiar (aquele e
    ---- `x % 1` depois de divisao inteira). Aqui o modulo e 1000 e trunca de verdade.
    -----------------------------------------------------------------------------------------------
    local desconto = Min(ap, Max(0, unit.free_move_ap or 0))
    desconto = desconto - desconto % const.Scale.AP

    return Max(0, ap - desconto)
end

function rat_MGSetup_getap()
    CombatActions.MGSetup.GetAPCost = function(self, unit, args)

        local weapon = args and args.weapon or self:GetAttackWeapons(unit, args) -- unit:GetActiveWeapons()

        local ap_extra = GetWeapon_StanceAP(unit, weapon)

        --[[local base = self:ResolveValue("max_cost") * const.Scale.AP
        local min = self:ResolveValue("min_cost") * const.Scale.AP
        local min_str = self:ResolveValue("min_str")

        ic(base, min, min_str)
        base = ap_extra
        ic(base)
        local cost = base - MulDivRound(Max(0, unit.Strength - min_str), base - min, 100 - min_str)
        ic(cost)
        cost = Max(min, (cost / const.Scale.AP) * const.Scale.AP)
        ic(cost)]]

        local cost = ap_extra + (2 * const.Scale.AP)

        if HasPerk(unit, "HeavyWeaponsTraining") then
            local effect = unit:GetStatusEffect("HeavyWeaponsTraining")
            local reduction = effect:ResolveValue("ap_cost_reduction") * const.Scale.AP
            local minCost = effect:ResolveValue("min_ap_cost") * const.Scale.AP

            cost = Max(minCost, cost - reduction)

        end

        -------------------------------------------------------------------------------------------
        ---- O CUSTO DE DEITAR, QUE NUNCA FOI COBRADO DE NINGUEM
        ----
        ---- `Unit:MGSetup` (vanilla, UnitActions.lua:537) deita com `DoChangeStance("Prone")`, e
        ---- `DoChangeStance` nao debita AP -- so troca `self.stance`, animacao e target dummy.
        ---- Verificado no processo vivo: as duas funcoes sao as do jogo base, nenhum mod as
        ---- substitui. Ou seja, montar a MG sempre saiu pelo MESMO preco em qualquer postura e em
        ---- qualquer posicao, para merc e para IA.
        ----
        ---- O total pago continua o mesmo de sempre (o prone acontece uma vez so); o que muda e
        ---- que ele deixa de ser invisivel:
        ----     em pe     -> +2 AP     agachado -> +1 AP     ja deitado -> +0
        ----
        ---- Essa promessa de "o total continua o mesmo" so passou a valer de verdade quando o
        ---- free move entrou na conta: ver `rat_MGSetup_StanceAP` acima. Deitar pelo botao de
        ---- postura sempre pode ser pago com free move; deitar POR DENTRO do MGSetup nao podia, e
        ---- o caminho direto ficou 2 AP mais caro que o caminho "prone antes".
        ----
        ---- Para o jogador: motivo real para deitar antes de plantar a MG, e a arma fica um pouco
        ---- mais cara de plantar no meio de um avanco. Para a IA: e o gradiente que faltava --
        ---- `AIFindDestinations` ja desconta a mudanca de postura do `dest_ap` do destino
        ---- empacotado Prone (BUGFIX B25 do RATOAI), e ate aqui esse desconto era um custo
        ---- fantasma, porque o MGSetup cobrava o mesmo dos dois lados. Agora a conta fecha nos
        ---- dois caminhos: destino Prone paga 2 no deslocamento e 0 no setup; destino em pe paga
        ---- 0 no deslocamento e 2 no setup.
        ----
        ---- Fica DEPOIS da reducao do HeavyWeaponsTraining de proposito: a perk barateia manejo de
        ---- arma pesada, nao o ato de deitar, e assim o piso `min_ap_cost` nao engole o delta.
        ----
        ---- A parcela em si (postura de origem, guarda de emplacamento, free move) mora inteira em
        ---- `rat_MGSetup_StanceAP`, porque a IA precisa da MESMA formula para orcar o destino.
        -------------------------------------------------------------------------------------------
        cost = cost + rat_MGSetup_StanceAP(unit)

        return cost

    end
end
-- rat_combat_actions()

---------------------------------------------------------------------------------------------------------

local t_id_table = {
    [758325374611] = "<color AmmoAPColor>Grenade loaded</color>",
    [163779727424] = "<color AmmoAPColor>Grenade loaded</color>",
    [449447625321] = "<color AmmoAPColor>Semi-auto only</color>",
    [676922692594] = "<color AmmoAPColor>Grenade loaded</color>",
    [769183913636] = "Collateral damage might hit units outside the overwatch cone.",
    [415612867746] = "Prepare Weapon",
    [769876819564] = "Rotate Weapon",
    [188987732816] = "<color AmmoAPColor>Grenade loaded</color>",
    [565497791697] = "<color AmmoAPColor>Grenade loaded</color>",
    [565263742146] = "<color AmmoAPColor>Weapon not capable of burst</color>",
    [865874231348] = "<color AmmoAPColor>Out of Breath</color>",
    [536142745929] = "<color AmmoAPColor>Out of Breath</color>",
    [864921833364] = "Make a longer <em>Run and Gun</em>, firing more shots. Move to a new position, using up to <em><DisplayMoveAP> AP</em> Smiley will be <em>Out of Breath</em> after use. Can't be used when <em>Out of Breath</em>.",
    [585854196899] = "Cheap attack that conserves ammo. Has bonus critical chance based on <em>Marksmanship</em> and <em>Dexterity</em> when <em>aimed</em>.",
    [614189548956] = "<em>Once per turn</em>. Move to a new position, using up to <em><DisplayMoveAP> AP</em>. Fire a number of bursts during movement toward the closest enemies. Each shot suffers increased <em>Hipfire</em> and <em>Recoil</em> accuracy penalties.",
    [373274572555] = "Shoots a hail of <em><bullets> bullets</em> and inflict <GameTerm('Suppressed')> even on miss when the enemy is in weapon range. Has <em>recoil</em> penalty based on <em>Strength</em>. Maximum <em>aim</em> level reduced. Critical chance is reduced.",
    [364947777453] = "The Dual Shot attack produces a Basic Attack from each gun. Maximum <em>aim</em> level is reduced. Has a penalty based on <em>Dexterity</em>.",
    [564696256945] = "Focus on a cone-shaped area, immobilizing yourself and going <em>prone</em>. You can only shoot enemies inside that cone. Accuracy is increased and enemies will provoke <em>interrupt</em> attacks with actions inside the cone (even if your AP are spent). <em>Interrupt</em> attacks have bonus accuracy. Your weapon will have increased <em>Shooting Angle</em> while you are in setup.",
    [226634284341] = "<em>Spends all AP</em>. Any targets who move or shoot in the overwatch area will provoke <GameTerm('Interrupt')> <em>attacks</em>. Accuracy is influenced by the unit's <em>Reflexes</em> (Dex + Agi). The attacks will suffer increased <em>Snapshot</em> penalty.",
    [312473917195] = "\n\nThe unit will be <em>Out of Breath</em>.",
    [801805830695] = "<newline>You will end up in Standing stance.",
    [359627666793] = "<color AmmoAPColor>Grenade loaded</color>",
    [545341281514] = "<color AmmoAPColor>Out of Breath</color>",
    [966648741688] = "\n\nThe unit will be <em>Out of Breath</em>.",
    [891514871831] = "Reckless Assault",
    [956881287967] = "<color AmmoAPColor>Out of Breath</color>",
    [258829833148] = "\n\nBlood will be <em>Out of Breath</em>.",
    [480046777812] = " within the set cone",
    [617859618521] = "Shoots <em><num> bullets</em> at the target. The accuracy of each shot is reduced by <em>Recoil</em>. Critical chance is reduced.\n\nOnly the first shot will benefit from <em>Aim</em> bonus.",
    [164165234891] = "Snipe",
    [854982151651] = "<em>Spends all AP</em>\nThe target is <em><GameTerm('Marked')></em>. At the start of next turn, shoot the target if the target is still in the line of sight. The attack will have max aim levels. Each aim level grants <bonus_crit> extra critical chance. This attack bypasses low cover, has reduced penalties to hit body parts and <em>increases the weapon's effective range by 50%</em>.\n\nSnipe requires a clear line and sight to the target.",
    [231988463514] = "\n\n<em>Recoil</em> is increasing the AP cost by <em>"

}

ratG_T_table['shooting_stance_combat_actions.lua'] = t_id_table


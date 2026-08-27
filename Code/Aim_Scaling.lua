
function GetScaledAimBonus(weapon1)
		if not weapon1 then return end
		print ("oi")
		local num = 1
		local min_bonus = weapon1.AimAccuracy
		local attacker = weapon1.owner and gv_UnitData[weapon1.owner]

		local min_dex = 10.0
        local max_dex = 100.0
        local min_scale = const.Combat.R_MinAimScaling / 100.0
        local max_scale = const.Combat.R_MaxAimScaling / 100.0
		local dex = IsKindOf(weapon1, "Firearm")  and rGetHandEyeCoordination(attacker)
  
		if IsKindOf(weapon1, "Pistol") or IsKindOf(weapon1, "Revolver") then
            min_bonus = min_bonus * 0.5
		end
		local scale_factor = min_scale + (max_scale - min_scale) * (dex - min_dex) /
		                         (max_dex - min_dex)
		if scale_factor < min_scale then
		    scale_factor = min_scale
		elseif scale_factor > max_scale then
		    scale_factor = max_scale
		end
		local bonus = num * min_bonus

		            local modifyVal, compDef

            -- Forward Grip
            local modifyVal, compDef = GetComponentEffectValue(weapon1, "FirstAimBonusModifier",
                                                               "first_aim_bonus")
            if modifyVal then
                bonus = bonus + (min_bonus * 0.3) + 2.1

            end

			            local modifyVal, compDef

            -- Forward Grip
            local modifyVal, compDef = GetComponentEffectValue(weapon1, "FirstAimBonusModifier",
                                                               "first_aim_bonus")
            if modifyVal then
                bonus = bonus + (min_bonus * 0.3) + 2.1

            end
			modifyVal, compDef =
                GetComponentEffectValue(weapon1, "ReduceAimAccuracy", "cth_penalty")
            if modifyVal then
                bonus = bonus * 0.5 -- Max(1, MulDivRound(bonus, 100 - modifyVal, 100))
                
            end

            if weapon1:HasComponent("light_stock_aim_reduce") then
                bonus = bonus * 0.90 -- Max(1, MulDivRound(min_bonus, 80, 100))
                
            end
			            if IsKindOf(weapon1, "MeleeWeapon") then
                bonus = bonus * 0.5
            end
			            if num > 0 and bonus < 1 then
                bonus = num
            end
			return bonus
		end


function place_standing_penalCTH()
PlaceObj('ChanceToHitModifier', {
    CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
		if not weapon1 or not attacker or IsACHTActive(weapon1, action, attacker) then
				return false, 0
		end
		
		local penalty = 0
		if weapon1.unwieldy_weapon and attacker.stance ~= "Prone" then
			penalty = -25
		end
		
		if penalty == 0 then
			return false, 0
		end
		
		return true, penalty
	end,
    RequireTarget = true,
    display_name = T(374778916221, "Standing (Unwieldy Weapon)"),
    group = "Default",
    id = "_unwieldy_weapon",
})
end




---------------------------------------------------------------------------------------------------------

local t_id_table = {
[374778916221] = "Standing (Unwieldy Weapon)",
}

ratG_T_table['CTH_unwield_weapon.lua'] = t_id_table
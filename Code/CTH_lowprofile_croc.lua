local patched 
function GBO_changeLowProfileCTHmod(force)
	if patched and not force then return end
	local original_calc = Presets.ChanceToHitModifier.Default["LowProfile"].CalcValue
	Presets.ChanceToHitModifier.Default["LowProfile"].CalcValue = function(self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
		if Rat_AngularActive(weapon1, action, attacker) then
			return false, 0 
		end
		return original_calc(self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
	end
	patched = true
end
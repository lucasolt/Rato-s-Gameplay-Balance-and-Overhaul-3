
function autofire_range()
	Presets.ChanceToHitModifier.Default["Autofire"].CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)	
		return false, 0
	end
end




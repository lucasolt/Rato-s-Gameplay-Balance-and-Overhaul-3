-- function FirearmProperties:GetRecoil_mul()
-- local weapon = self
-- local attacker = false
-- local display = true
-- local recoil = GetWepRecoil(weapon, attacker, display) 
-- return string.format("%.2f", recoil)
-- end
-- function FirearmProperties:GetHipfire_mul()
-- local weapon = self
-- local attacker = false
-- local action = false
-- local aim = 0
-- local display = true
-- local hip = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, display, aim) 
-- return string.format("%.2f", hip)
-- end
-- function FirearmProperties:GetSnapshot_mul()
-- local weapon = self
-- local attacker = false
-- local action = false
-- local aim = 1
-- local display = true
-- local hip = GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, display, aim) 
-- return string.format("%.2f", hip)
-- end
-- function FirearmProperties:Getangle_display()
-- local angle = self:GetProperty("OverwatchAngle") / 60.0
-- return string.format("%.2f", angle)
-- end
-- function FirearmProperties:GetPBbonus_display()
-- local weapon = self
-- local value = GetPBbonus(weapon)
-- return value
-- end
-- function FirearmProperties:GetSTR_RECOIL()
-- local weapon1 = self
-- local str = Recoil_StrBreakpoint(weapon1)
-- return str
-- end
-- function FirearmProperties:GetAPStance_display()
-- local ap = self.APStance
-- local unit = g_Units[self.owner] or false
-- ap = Cumbersome_StanceAP(unit, self, ap)
-- return ap
-- end



function FirearmProperties:Getdescription_hints()

    return rat_format_hints(self)
end


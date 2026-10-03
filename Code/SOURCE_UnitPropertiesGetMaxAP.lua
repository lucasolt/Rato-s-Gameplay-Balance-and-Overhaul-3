
-----ClassDef-Zulu.generated.lua

function UnitProperties:GetMaxActionPoints()
	local level = self:GetLevel()
	--return ((3 + self:GetProperty("Agility") / 10) + (level / 3)) * const.Scale.AP
	---
	--return ((5 + (self:GetProperty("Agility") +5 ) / 14) + (level / 3) + (const.Combat.R_ExtraAP or 0)) * R_VanillaAP(1)
	local vanilla = R_VanillaAP(1)
	local ap = (5 + (const.Combat.R_ExtraAP or 0)) * vanilla
		+ MulDivRound(self:GetProperty("Agility") + 5, vanilla, 14)
		+ MulDivRound(level, vanilla, 3)
	-- Keeps vanilla-AP fractions but floors to the displayed-AP grid.
	return ap - ap % const.Scale.AP
	---
end
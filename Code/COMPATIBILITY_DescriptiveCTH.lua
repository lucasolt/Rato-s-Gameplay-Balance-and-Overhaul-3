---- Descriptive CTH (N6rmtjQ) loads after us and replaces UpdateAim, PopulateCrosshairUICth and the
---- CrosshairAttackRollover template. A mod save reruns its code (ReloadLua) firing only AutorunEnd.
local function reclaim_crosshair()
	if not IsMod_loaded("N6rmtjQ") then
		return
	end
	redefine_crosshairUI_function()
	Rat_ReclaimPopulateCth()
	recoil_template()
	Rat_PatchCrosshairApertureSection()
end

OnMsg.AutorunEnd = reclaim_crosshair
OnMsg.EnterSector = reclaim_crosshair

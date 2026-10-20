local already_placed = false

function OnMsg.EnterSector()
	-- if already_placed then
		-- print("already placed - Descriptive CTH compatibility")
	-- end
	if IsMod_loaded("N6rmtjQ") and not already_placed then
		redefine_crosshairUI_function()
		---- a Lua reload reruns its code (template + populate) without firing DataLoaded
		Rat_ReclaimPopulateCth()
		Rat_PatchCrosshairApertureSection()

		already_placed = true
		print("GBO - enabling Descriptive CTH compatibility")
	end
end

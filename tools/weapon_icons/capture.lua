-- Run by tools/capture_weapon_icons.py through dap_eval (-c); needs ModifyWeaponDlg open in the game.
-- Per class: spawn a default copy, show it exactly side-on, take four shots (gun/no gun x black/bright backdrop)
-- for difference matting, under neutral light (LUT and LightColor1..4 white). Everything is restored afterwards.
local CLASSES = { --CLASSES-- }
local OUT = "AppData/rat_icons/"

CreateRealTimeThread(function()
	local log = {}
	local cab = GetDialog("ModifyWeaponDlg")
	local d = cab and rawget(cab, "idModifyDialog")
	if not d then
		AsyncStringToFile(OUT .. "done.txt", "ERR ModifyWeaponDlg is not open")
		return
	end
	local pf, plane = rawget(cab, "prefab"), rawget(cab, "background")
	local orig_idx, orig_count = d.selectedWeapon, #d.allWeapons
	local axis, angle = g_Cabinet:GetAxis(), g_Cabinet:GetAngle()
	local plane_cm = plane:GetColorModifier()

	local lights = {}
	for _, o in ipairs(pf.objs) do
		if IsKindOf(o, "Light") then
			lights[o] = true
		end
	end
	local hidden = {}
	local ok, err = pcall(function()
		MapForEach("map", "attached", false, "CObject", nil, const.efVisible, function(o)
			if o ~= g_Cabinet and not lights[o] then
				o:ClearEnumFlags(const.efVisible)
				hidden[#hidden + 1] = o
			end
		end)
		table.change(hr, "RatIconCapture", {
			EnablePostProcVignette = 0, EnablePostProcBloom = 0, InterfaceInScreenshot = 0,
			RenderSky = 0, RenderParticles = 0, Sharpness = 0, ResolutionPercent = 100,
		})
		SetGradingLUT(1, ResourceManager.GetResourceID(GradingLUTs.Default:GetResourcePath()), 0)
		-- spotlights read the scene LightColor1..4 set by the lightmodel (warm here), not their own colour
		for i = 1, 4 do
			SetSceneParamColor(1, "LightColor" .. i, RGB(255, 255, 255), 0)
		end
		plane:SetColorModifier(RGB(255, 255, 255))

		local function shot(name)
			WaitNextFrame(12)
			Sleep(200)
			if not WriteScreenshot(OUT .. name, 1920, 1080, box(0, 0, 1920, 1080), 100, false) then
				error("WriteScreenshot failed: " .. name)
			end
			local t = now()
			repeat Sleep(20) until ScreenshotWritten() or now() - t > 5000
		end

		for _, entry in ipairs(CLASSES) do
			local name, class = entry[1], entry[2]
			local w = PlaceInventoryItem(class)
			d.allWeapons[#d.allWeapons + 1] = { weapon = w, slot = d.allWeapons[orig_idx].slot }
			d:SetWeapon(#d.allWeapons)
			Sleep(100)
			while IsValidThread(d.weaponSlideInThread) or IsValidThread(g_SetWeaponWaitThread) do Sleep(50) end
			Sleep(400)
			g_Cabinet:SetAxisAngle(axis_z, 180 * 60, 0)
			local m = d.weaponModel
			-- no shadow on the bright plane, or it would read as partial alpha
			m:ClearHierarchyEnumFlags(const.efShadow | const.efSunShadow)

			plane:ClearEnumFlags(const.efVisible)
			shot(name .. "_fg_dark.png")
			plane:SetEnumFlags(const.efVisible)
			shot(name .. "_fg_bright.png")
			m:ClearHierarchyEnumFlags(const.efVisible)
			shot(name .. "_bg_bright.png")
			plane:ClearEnumFlags(const.efVisible)
			shot(name .. "_bg_dark.png")
			m:SetHierarchyEnumFlags(const.efVisible)
			log[#log + 1] = name .. " " .. class
		end
	end)
	log[#log + 1] = "ok=" .. tostring(ok) .. " err=" .. tostring(err)

	-- restore
	plane:SetColorModifier(plane_cm)
	plane:SetEnumFlags(const.efVisible)
	local lm = LightmodelPresets.WeaponModification
	for i = 1, 4 do
		SetSceneParamColor(1, "LightColor" .. i, lm["lightcolor" .. i], 0)
	end
	SetGradingLUT(1, ResourceManager.GetResourceID(GradingLUTs[lm.grading_lut]:GetResourcePath()), 0)
	table.restore(hr, "RatIconCapture")
	for _, o in ipairs(hidden) do
		if IsValid(o) then o:SetEnumFlags(const.efVisible) end
	end
	local spawned = {}
	for i = #d.allWeapons, orig_count + 1, -1 do
		spawned[#spawned + 1] = d.allWeapons[i].weapon
		table.remove(d.allWeapons, i)
	end
	d:SetWeapon(orig_idx)
	while IsValidThread(d.weaponSlideInThread) do Sleep(50) end
	for _, w in ipairs(spawned) do
		DoneObject(w)
	end
	g_Cabinet:SetAxisAngle(axis, angle, 0)
	AsyncStringToFile(OUT .. "done.txt", table.concat(log, "\n"))
end)
return "started"

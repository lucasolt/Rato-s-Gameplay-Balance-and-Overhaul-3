-- Run by tools/capture_part_icon.py through dap_eval (-c), with the Modify Weapon screen already open.
-- Spawns JOB's gun with the component, shows it at POSE or the cabinet's current orientation, hides the gun's other
-- attaches, and shoots full / body without the part / nothing over a dark and a bright backdrop. Restores everything.
-- A hidden body hides its attaches and a detached part stops rendering, hence the three-way difference.
local JOB = {"Name", "Class", "Stock", "Component"}
local POSE = false
local CENTER = true
local OUT = "AppData/rat_part_icons/"

-- POSE {yaw, roll, spin} in degrees: roll about the barrel (X), then yaw (Z, toward the camera), then spin (Y, in
-- the picture). POSE {axis = point, angle = minutes} is an exact earlier orientation. false keeps the current one.
-- POSE.turn applies the same three on top of the current orientation, rolling about the gun's own barrel.
local function pose_axis_angle(axis, angle)
	if not POSE then
		return axis, angle
	elseif POSE.axis then
		return POSE.axis, POSE.angle
	end
	local ax, an
	if POSE.turn then
		ax, an = ComposeRotation(axis_x, POSE[2] * 60, axis, angle)
		ax, an = ComposeRotation(ax, an, axis_z, POSE[1] * 60)
	else
		ax, an = ComposeRotation(axis_x, POSE[2] * 60, axis_z, POSE[1] * 60)
	end
	return ComposeRotation(ax, an, axis_y, POSE[3] * 60)
end
local PROG = {}
local function step(s) PROG[#PROG + 1] = s AsyncStringToFile(OUT .. "progress.txt", table.concat(PROG, string.char(10))) end

CreateRealTimeThread(function()
	local log = {}
	step("start")
	local cab = GetDialog("ModifyWeaponDlg")
	local d = cab and rawget(cab, "idModifyDialog")
	if not (d and d.weaponModel) then
		AsyncStringToFile(OUT .. "done.txt", "ERR open the Modify Weapon screen first")
		return
	end
	local pf, plane = rawget(cab, "prefab"), rawget(cab, "background")
	local orig_idx, orig_count = d.selectedWeapon, #d.allWeapons
	local axis, angle = g_Cabinet:GetAxis(), g_Cabinet:GetAngle()
	local shot_axis, shot_angle = pose_axis_angle(axis, angle)
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
		table.change(hr, "RatPartIconCapture", {
			EnablePostProcVignette = 0, EnablePostProcBloom = 0, InterfaceInScreenshot = 0,
			RenderSky = 0, RenderParticles = 0, Sharpness = 0, ResolutionPercent = 100,
		})
		SetGradingLUT(1, ResourceManager.GetResourceID(GradingLUTs.Default:GetResourcePath()), 0)
		-- spotlights read the scene LightColor1..4 set by the lightmodel (warm here), not their own colour
		for i = 1, 4 do
			SetSceneParamColor(1, "LightColor" .. i, RGB(255, 255, 255), 0)
		end
		plane:SetColorModifier(RGB(255, 255, 255))
		step("setup ok")

		local function shot(name)
			WaitNextFrame(12)
			Sleep(200)
			if not WriteScreenshot(OUT .. name, 1920, 1080, box(0, 0, 1920, 1080), 100, false) then
				error("WriteScreenshot failed: " .. name)
			end
			local t = RealTime()
			repeat Sleep(20) until ScreenshotWritten() or RealTime() - t > 5000
		end

		local name, class, slot, comp = JOB[1], JOB[2], JOB[3], JOB[4]
		local w = PlaceInventoryItem(class)
		if not w then error("no weapon class " .. class) end
		w:SetWeaponComponent(slot, comp)
		if w.components[slot] ~= comp then error(comp .. " does not fit " .. class .. " " .. slot) end
		d.allWeapons[#d.allWeapons + 1] = { weapon = w, slot = d.allWeapons[orig_idx].slot }
		d:SetWeapon(#d.allWeapons)
		Sleep(100)
		local t1 = RealTime()
		while (IsValidThread(d.weaponSlideInThread) or IsValidThread(g_SetWeaponWaitThread)) and RealTime() - t1 < 5000 do
			Sleep(50)
		end
		Sleep(400)
		g_Cabinet:SetAxisAngle(shot_axis, shot_angle, 0)
		WaitNextFrame(3)
		local m = d.weaponModel
		local part = m.parts and m.parts[slot]
		if not IsValid(part) then error("no " .. slot .. " part on " .. class) end
		if CENTER then
			-- the camera has perspective: the part must sit on the pivot (screen centre), as when posed with --pivot
			local off = part:GetObjectBBox():Center() - g_Cabinet:GetVisualPos()
			m:SetAttachOffset(m:GetAttachOffset() - RotateAxis(off, shot_axis, -shot_angle))
			WaitNextFrame(3)
		end
		local others = {}
		m:ForEachAttach(function(o)
			if o ~= part then
				others[#others + 1] = o
				o:ClearEnumFlags(const.efVisible)
			end
		end)
		m:ClearHierarchyEnumFlags(const.efShadow | const.efSunShadow)
		step("shoot " .. name)
		plane:ClearEnumFlags(const.efVisible)
		shot(name .. "_full_dark.png")
		part:ClearEnumFlags(const.efVisible)
		shot(name .. "_body_dark.png")
		m:ClearEnumFlags(const.efVisible)
		shot(name .. "_none_dark.png")
		plane:SetEnumFlags(const.efVisible)
		shot(name .. "_none_bright.png")
		m:SetEnumFlags(const.efVisible)
		shot(name .. "_body_bright.png")
		part:SetEnumFlags(const.efVisible)
		shot(name .. "_full_bright.png")
		for _, o in ipairs(others) do
			if IsValid(o) then o:SetEnumFlags(const.efVisible) end
		end
		log[#log + 1] = name .. " " .. part:GetEntity() .. " --axis-angle " ..
			table.concat({shot_axis:xyz()}, " ") .. " " .. shot_angle
	end)
	log[#log + 1] = "ok=" .. tostring(ok) .. " err=" .. tostring(err)

	step("restore")
	plane:SetColorModifier(plane_cm)
	plane:SetEnumFlags(const.efVisible)
	local lm = LightmodelPresets.WeaponModification
	for i = 1, 4 do
		SetSceneParamColor(1, "LightColor" .. i, lm["lightcolor" .. i], 0)
	end
	SetGradingLUT(1, ResourceManager.GetResourceID(GradingLUTs[lm.grading_lut]:GetResourcePath()), 0)
	table.restore(hr, "RatPartIconCapture")
	for _, o in ipairs(hidden) do
		if IsValid(o) then o:SetEnumFlags(const.efVisible) end
	end
	local spawned = {}
	for i = #d.allWeapons, orig_count + 1, -1 do
		spawned[#spawned + 1] = d.allWeapons[i].weapon
		table.remove(d.allWeapons, i)
	end
	d:SetWeapon(orig_idx)
	local t2 = RealTime()
	while IsValidThread(d.weaponSlideInThread) and RealTime() - t2 < 5000 do
		Sleep(50)
	end
	for _, w in ipairs(spawned) do
		DoneObject(w)
	end
	-- a posed capture stays posed, so the screen shows what was shot
	g_Cabinet:SetAxisAngle(shot_axis, shot_angle, 0)
	AsyncStringToFile(OUT .. "done.txt", table.concat(log, string.char(10)))
end)
return "started"

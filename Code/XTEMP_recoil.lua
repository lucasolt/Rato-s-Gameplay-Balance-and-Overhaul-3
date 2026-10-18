function recoil_template()

	local new_template_recoil = 	PlaceObj('XTemplateWindow', {
			'__class', "XContextControl",
			'Id', "idContent",
			'HideOnEmpty', true,
			'FoldWhenHidden', true,
			"comment", "rat_recoil", 
			--'Padding', box(6, 6, 6, 6),
			--'Dock', "bottom",
			'MinWidth', 356,
			'LayoutMethod', "VList",
			--'Background', RGBA(52, 55, 61, 255),
			--'BackgroundRectGlowSize', 2,
			--'BackgroundRectGlowColor', RGBA(32, 35, 47, 255),
			'OnContextUpdate', function (self, context, ...)
				local control = context.control
				local crosshair = control:ResolveId("node")
				assert(IsKindOf(crosshair, "CrosshairUI"))
				
				local crosshairCtx = crosshair.context
				local unit = crosshairCtx.attacker
				local units = {unit}
				local target = crosshairCtx.target
				local action = crosshairCtx.action
				local weapon = action:GetAttackWeapons(unit)
				local targetHasBodyParts = IsKindOf(target, "Unit")
				local bodyPartId = crosshair.targetPart.id
				local attackResult = crosshairCtx.attackResultTable[bodyPartId]
				if not attackResult then
					self.idAttackInfoSection:SetVisible(false)
					self.idTextAndHint:SetVisible(false)
					return
				end
				
				-- for i, v in ipairs(attackResult) do
					-- print("v", v)
				-- end
				self.idAttackInfoSection:SetVisible(true)
				--print(attackResult[1].shot_idx)
				
				local shot_index = attackResult[1].shot_idx or 1
				if shot_index < 2 then
					self:SetVisible(false)
				end
				
				local title

				
				Rat_recoil_PopulateCrosshair(self.idHitInfo, unit, action, attackResult, target)
			end,
		}, 
		{

			PlaceObj('XTemplateWindow', {
				'LayoutMethod', "VList",
				'VAlign', "bottom",
			}, {
				PlaceObj('XTemplateWindow', {
					'Id', "idAttackInfoSection",
					--'Padding', box(14, 0, 14, 2),
					'LayoutMethod', "VList",
					'VAlign', "bottom",
					'Visible', false,
					'FoldWhenHidden', true,
					--'Background', RGBA(32, 35, 47, 255),
				}, 
				{
					
					}),
				
				PlaceObj('XTemplateWindow', {
					'__context', function (parent, context) return "g_RolloverShowMoreInfo" end,
					'__class', "XContextWindow",
					'FoldWhenHidden', true,
					'ContextUpdateOnOpen', true,
					'OnContextUpdate', function (self, context, ...)
						-- self:SetVisible(g_RolloverShowMoreInfo)
						local node = self:ResolveId("node")
						node:OnContextUpdate(node.context)
					end,
				}, {
					PlaceObj('XTemplateWindow', {
						'Id', "idHitInfo",
						'IdNode', true,
						
						-------
						'VAlign', "bottom",
						'LayoutMethod', "VList",
						'UseClipBox', false,
						'FoldWhenHidden', true,
					}, {
						PlaceObj('XTemplateWindow', {
							'Margins', box(8, 0, 0, 0),
							'MinHeight', 34,
							'UseClipBox', false,
						}, {
							PlaceObj('XTemplateWindow', {
								'__class', "XText",
								'Id', "idChanceToHit",
								'Padding', box(0, 0, 6, 0),
								'VAlign', "center",
								'Clip', false,
								'UseClipBox', false,
								'TextStyle', "PDABrowserNameSmall",
								'Translate', true,
								'TextVAlign', "center",
							}),
							}),
						PlaceObj('XTemplateWindow', {
							'Padding', box(14, 5, 14, 5),
							'UseClipBox', false,
							'Background', RGBA(32, 35, 47, 255),
						}, {
							PlaceObj('XTemplateWindow', {
								'__class', "XText",
								'Id', "idModifiers",
								'Clip', false,
								'UseClipBox', false,
								'TextStyle', "SatelliteContextMenuKeybind",
								'Translate', true,
								'TextVAlign', "center",
							}),
							}),
						}),
					}),
				}),
			
			}
			)
			




	local xt = FindXtByProp(XTemplates.CrosshairAttackRollover[1], "Id", "idContent")
	xt = FindXtByProp(xt[1], "LayoutMethod", "VList")
	local vlist 
	for i, v in ipairs(xt[1]) do
		if v.LayoutMethod == "VList" then
			vlist = v
			break
		end
	end
	
	for i, v in ipairs(vlist) do
		if i == 4 and v.comment == "rat_recoil" then
			--print("Already inserted")
			return
		end
	end
	
	-- for i = #vlist, 4, -1 do
        -- vlist[i + 1] = vlist[i]
    -- end
	table.insert(vlist, 4, new_template_recoil)
    
    -- vlist[4] = new_template_recoil
	
	
	
	
	-- for i, v in ipairs(vlist) do
		-- print(i,v)
	-- end
end



function Rat_recoil_PopulateCrosshair(win, attacker, action, attackResults, target)
	--print("atresults", attackResults)
	local weapon = action:GetAttackWeapons(attacker)
	local dontShow = action.AlwaysHits
	win:SetVisible(not dontShow)
	if dontShow or not attackResults then return end
	if Rat_ACTHRecoilPopulate(win, attacker, action, attackResults, weapon) then return end


	local num_shots = attackResults[1].shot_idx



	local target_pos = target:GetPos()
	local chanceToHit, meta_text = get_recoil(attacker, target, target_pos, action, weapon, false, num_shots, false, false, false, false, true)
	
	local function processString(input, prefix)
		
		if type(input) == "table" then
			
			-- if input[2] then
				-- input = input[1] .. input[2]
			-- else
				input = input[1]
			--end
			--print("input detablefied", input)
		end
		
		if string.sub(input, 1, #prefix) == prefix then
			return true, string.sub(input, #prefix + 1)
		else
			return false, input
		end
	end
	
	
	local modifiers = {}
	for i, meta in ipairs(meta_text) do
		--print("meta in populate", meta)

		local value = 1
		local text = meta
		local t_id
		if type(meta) == "table" then
			text = meta[2]
			t_id = meta[1]
		end


		local minus, name = processString(text, "(-) ")
		if minus then
			value = -1
		end
		--print(meta)
		modifiers[i] = {id = name .. "id", name =  name, value = value}
		
	end
	
	
	
	if CthVisible() then
		win.idChanceToHit:SetText(T{ "RECOIL PER SHOT: <right><percent(chanceToHit)>", chanceToHit = chanceToHit})
		win.idChanceToHit.parent:SetZOrder(1)
	elseif IsMod_loaded("N6rmtjQ") then
		local sign = DCth_calculateModString(chanceToHit)
		win.idChanceToHit:SetText(T{ "RECOIL PER SHOT: <right><style PDABrowserTextLightBold><value></style>", value = sign})
	else
		win.idChanceToHit:SetText(T{"RECOIL PER SHOT", chanceToHit = chanceToHit})
		win.idChanceToHit.parent:SetZOrder(0)
	end
	if not modifiers then -- Invalid weapon, or invalid target, or something else
		win:SetVisible(false)
		return
	end
	
	-- Map and concat mods
	local concatList = {}
	for i, mod in ipairs(modifiers) do
		-- print("mod", mod)
		if mod.uiHidden then goto continue end
	
		if mod.value then -- Handle missing value just in case
			local sign = ""
			if mod.value > 0 then
				sign = "<color PDASectorInfo_Green>+</color>"
			elseif mod.value < 0 then
				sign = "<color DescriptionTextRed>-</color>"
			end
			--if CthVisible() then sign = T{257328164584, "<percent(value)> ", value = mod.value} end

			concatList[#concatList + 1] = {"<name><right><style PDABrowserTextLightBold><sign></style>", name = mod.name, sign = sign}
			
		else

			concatList[#concatList + 1] = mod.name

		end
		
		if mod.metaText then
			if IsT(mod.metaText) then
				concatList[#concatList + 1] = T{399490205680, "<left> <metaText>", metaText = mod.metaText}
			else
				for i, t in ipairs(mod.metaText) do
					concatList[#concatList + 1] = T{399490205680, "<left> <metaText>", metaText = t}
				end
			end
		end
		
		::continue::
	end

	--------------------------------
	local formattedStrings = {}

	
	for _, item in ipairs(concatList) do
		local formatString = item[1]  -- Assuming the format string is the first element
		local name = item.name        -- Assuming the name is stored with the key "name"
		local sign = item.sign        -- Assuming the sign is stored with the key "sign"
		
		-- Replace placeholders in the format string with actual values
		local formattedString = name .."<right><style PDABrowserTextLightBold>" .. sign .. "</style>"--string.format(formatString, name, sign)
		
		-- Add the formatted string to the list
		table.insert(formattedStrings, formattedString)
	end

	--------------------------------

	--local concatStr = table.concat(concatList, "\n<left>")
	local concatStr = table.concat(formattedStrings, "\n<left>")
	win.idModifiers:SetVisible(true)
	win.idModifiers:SetText(Untranslated(concatStr))
end

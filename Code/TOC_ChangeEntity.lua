function rat_upd_visu()
	
	local wpc = WeaponComponents
	
	local vigi = { {"ToC_Scope_Kent6","Mod/KQkEVHf/Icons/Upgrades/ToC_Scope_kentaur.png"},{"WeaponAttA_ScopeReflex", "UI/Icons/Upgrades/scope_reflex"}}
	local wide = {{"L85A1_scopeR", "Mod/KKh3Yhf/Images/L85A1_scope.png"}, {"WeaponAttA_ScopeACOG", "UI/Icons/Upgrades/scope_thermal"}}
	local heavy_uzi_s = {{"ToC_Stock_Uzi2", "UI/Icons/Upgrades/ak74_stock_wooden"}, {"WeaponAttA_StockGalil_01", "UI/Icons/Upgrades/ak74_stock_wooden"}}
	local light_uzi_s = {{"Mac11_Stock_unfld", "Mod/KKh3Yhf/Images/Mac11_Stock_unfld.png"}, {"WeaponAttA_StockAK74_01","UI/Icons/Upgrades/ak74_stock_foldable"}}
	
	
    local chooseVisual = function(visualTable, mod)
        if IsMod_loaded(mod) then
            return visualTable[1] 
        else
            return visualTable[2] 
        end
    end
    
    local updateBlock = function(block, visualTable, mod, slot)
        if block then
            local visual = chooseVisual(visualTable, mod)
            block.Icon = visual[2]
            local visu = block.Visuals
            for i, v in ipairs(visu) do
                if (v.Entity == visualTable[1][1] or v.Entity == visualTable[2][1])  then
                    v.Entity = visual[1]
                end
            end
        end
    end
	
	--v.Slot == slot and
	
	local updateBlock_byWep = function(block, visualTable, mod, apply_to)
        if block then
            local visual = chooseVisual(visualTable, mod)
           -- block.Icon = visualTable[2][2]
            local visu = block.Visuals
            for i, v in ipairs(visu) do
                if v.ApplyTo == apply_to and (v.Entity == visualTable[1][1] or v.Entity == visualTable[2][1]) then
                    v.Entity = visual[1]
					v.Icon = visual[2]
                end
            end
        end
    end

    updateBlock(wpc._ReflexSIghtVigilance, vigi, "KQkEVHf", "Scope")
	
    updateBlock_byWep(wpc.StockHeavy, heavy_uzi_s, "KQkEVHf", "UZI" )
	
	updateBlock(wpc.RAT_TOG_vigilanceRS , vigi, "KQkEVHf", "Scope")
	updateBlock(wpc.RAT_TOG_vigilanceRS_rpk_mount , vigi, "KQkEVHf", "Scope")
	
	
	
    -- updateBlock(wpc.StockLight, light_uzi_s)
	
	
	updateBlock(wpc.WideScope, wide, "KKh3Yhf", "Scope")
	updateBlock(wpc.RAT_TOG_WideScope, wide, "KKh3Yhf", "Scope")
	updateBlock(wpc.RAT_TOG_WideScope_rpk_mount, wide, "KKh3Yhf", "Scope")
	updateBlock_byWep(wpc.StockLight, light_uzi_s, "KKh3Yhf", "UZI" )
	
end



--[[function replace_entity_Archi_mods()
	local wpc = WeaponComponents
	
	local function ent(ent) 
		return EntityData[ent] 
	end
	
	local vigi = { {"ToC_Scope_Kent6","Mod/KQkEVHf/Icons/Upgrades/ToC_Scope_kentaur.png"},{"WeaponAttA_ScopeReflex", "UI/Icons/Upgrades/scope_reflex"}}
	local wide = {{"L85A1_scopeR", "Mod/KKh3Yhf/Images/L85A1_scope.png"}, {"WeaponAttA_ScopeACOG", "UI/Icons/Upgrades/scope_thermal"}}
	local heavy_uzi_s = {{"ToC_Stock_Uzi2", "UI/Icons/Upgrades/ak74_stock_wooden"}, {"WeaponAttA_StockGalil_01", "UI/Icons/Upgrades/ak74_stock_wooden"}}
	local light_uzi_s = {{"Mac11_Stock_unfld", "Mod/KKh3Yhf/Images/Mac11_Stock_unfld.png"}, {"WeaponAttA_StockAK74_01","UI/Icons/Upgrades/ak74_stock_foldable"}}
	
	
	
	if IsMod_loaded("KQkEVHf") then
		
		print("GBO - Changing entities from TOC")
		
		if wpc._ReflexSIghtVigilance then
			wpc._ReflexSIghtVigilance.Icon = "Mod/KQkEVHf/Icons/Upgrades/ToC_Scope_kentaur.png"
			local visu = wpc._ReflexSIghtVigilance.Visuals
			for i, v in ipairs(visu) do
				if v.Slot == "Scope" then
					v.Entity = "ToC_Scope_Kent6"
				end
			end
			--print(wpc._ReflexSIghtVigilance)
		end
		
		if wpc.StockHeavy then
			local visu = wpc.StockHeavy.Visuals
			for i, v in ipairs(visu) do
				if v.ApplyTo == "UZI" and v.Slot == "Stock" then
					v.Entity = "ToC_Stock_Uzi2"
				end
			end
		end
	
		if wpc.RAT_TOG_vigilanceRS_rpk_mount then
		
			wpc.RAT_TOG_vigilanceRS_rpk_mount.Icon = "Mod/KQkEVHf/Icons/Upgrades/ToC_Scope_kentaur.png"
			local visu = wpc.RAT_TOG_vigilanceRS_rpk_mount.Visuals
			for i, v in ipairs(visu) do
				if v.Entity == "WeaponAttA_ScopeReflex" then
					v.Entity = "ToC_Scope_Kent6"
				end
			end
		end
		
		
		if wpc.RAT_TOG_vigilanceRS then
		
			wpc.RAT_TOG_vigilanceRS.Icon = "Mod/KQkEVHf/Icons/Upgrades/ToC_Scope_kentaur.png"
			local visu = wpc.RAT_TOG_vigilanceRS.Visuals
			for i, v in ipairs(visu) do
				if v.Entity == "WeaponAttA_ScopeReflex" then
					v.Entity = "ToC_Scope_Kent6"
				end
			end
		end
			--print(wpc._ReflexSIghtVigilance)
	

	end
	
	
	
	
	
	if IsMod_loaded("KKh3Yhf") then
		
		print("GBO - Changing entities from TOG")
		if wpc.WideScope then
			wpc.WideScope.Icon = "Mod/KKh3Yhf/Images/L85A1_scope.png"
			local visu = wpc.WideScope.Visuals
			for i, v in ipairs(visu) do
				if v.Slot == "Scope" then
					v.Entity = "L85A1_scopeR"
				end
			end
		end
		
		if wpc.StockLight then
			local visu = wpc.StockLight.Visuals
			for i, v in ipairs(visu) do
				if v.ApplyTo == "UZI" and v.Slot == "Stock" then
					v.Entity = "Mac11_Stock_unfld"
					v.Icon = "Mod/KKh3Yhf/Images/Mac11_Stock_unfld.png"
				end
			end
		end
		
		if wpc.RAT_TOG_WideScope then
		
			wpc.RAT_TOG_WideScope.Icon = "Mod/KKh3Yhf/Images/L85A1_scope.png"
			local visu = wpc.RAT_TOG_WideScope.Visuals
			for i, v in ipairs(visu) do
				if v.Entity == "WeaponAttA_ScopeACOG" then
					v.Entity = "L85A1_scopeR"
				end
			end
		end
		
		
		if wpc.RAT_TOG_WideScope_rpk_mount then
		
			wpc.RAT_TOG_WideScope_rpk_mount.Icon = "Mod/KKh3Yhf/Images/L85A1_scope.png"
			local visu = wpc.RAT_TOG_WideScope_rpk_mount.Visuals
			for i, v in ipairs(visu) do
				if v.Entity == "WeaponAttA_ScopeACOG" then
					v.Entity = "L85A1_scopeR"
				end
			end
		end
		
		
	end	
end]]

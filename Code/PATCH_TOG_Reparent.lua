---- ToG guns whose object_class is another gun: the class inherits that gun's patches, IsKindOf and
---- values. Re-parented before the build to the given ancestor of the donor. id = new parent class.
local RAT_TOG_REPARENT = {
	VSS_1 = "SniperRifle",
}

-- engine's ClassNonInheritableMembers + noncopyable; the global is cleared after the first build
local RAT_REPARENT_SKIP = {
	__index = true, __parents = true, __ancestors = true, __generated_by_class = true,
	NoInstances = true, class = true, __hierarchy_cache = true,
}

function OnMsg.ClassesGenerate(classdefs)
	local skip = RAT_REPARENT_SKIP
	for id, parent in pairs(RAT_TOG_REPARENT) do
		local def = classdefs[id]
		local donor = def and #def.__parents == 1 and def.__parents[1]
		local chain, name = {}, donor
		while name and name ~= parent do
			local cd = classdefs[name]
			if not cd or #cd.__parents ~= 1 then
				name = false
			else
				chain[#chain + 1] = cd
				name = cd.__parents[1]
			end
		end
		if name ~= parent then
			print("GBO TOG reparent: skipped", id, "-", parent, "is not a single-parent ancestor of", donor)
		else
			-- ToG's generator omits values equal to the donor's, so they become own values here
			for _, cd in ipairs(chain) do
				for k, v in pairs(cd) do
					if rawget(def, k) == nil and not skip[k] then
						def[k] = v
					end
				end
			end
			def.__parents = {parent}
		end
	end
end

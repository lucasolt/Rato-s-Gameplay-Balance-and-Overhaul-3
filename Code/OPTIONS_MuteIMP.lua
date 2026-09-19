local function Rat_UnitDefId(unit)
	if type(unit) == "string" then
		return unit
	elseif IsKindOf(unit, "Unit") then
		return unit.unitdatadef_id
	elseif IsKindOf(unit, "UnitData") then
		return unit.class
	elseif IsKindOf(unit, "UnitDataCompositeDef") then
		return unit.id
	end
end

local function Rat_IsMutedImp(unit)
	if not CurrentModOptions.MuteIMPVoice then
		return false
	end
	local def = UnitDataDefs[Rat_UnitDefId(unit) or false]
	return def and def.group == "IMP"
end

---- every VR path (direct, queued event groups, delayed) funnels through here
local original_PlayVoiceResponseInternal = PlayVoiceResponseInternal
function PlayVoiceResponseInternal(unit, ...)
	if Rat_IsMutedImp(unit) then
		return
	end
	return original_PlayVoiceResponseInternal(unit, ...)
end

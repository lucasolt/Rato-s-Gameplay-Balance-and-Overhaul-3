---------------------------------------------------------------------------------------------------
---- Revised Tactical Gear II wraps GetSightRadius and, for a unit with a face item, multiplies the
---- weather penalty in again: in fog with any face item (its storm branches only cover dust/fire),
---- and its goggles bonus lands on top of the already-applied penalty. Correct to what it meant:
---- weather once, rated goggles cancel their % of that storm's penalty, tanned goggles as they are.
---------------------------------------------------------------------------------------------------

local RTG_ID = "ii6mKUf"

---- Intended and applied % of RTG's extra multiplier, or nil when it is left alone
local function RtgWeatherFactors(unit)
	if GameState.Underground then
		return
	end
	local face = unit:GetItemInSlot("FaceItem")
	if not face then
		return
	end
	local env = const.EnvEffects
	local weather = 100
	if GameState.Fog then
		weather = weather + env.FogSightMod
	end
	if GameState.DustStorm then
		weather = weather + env.DustStormSightMod
	end
	if GameState.FireStorm then
		weather = weather + env.FireStormSightMod
	end
	if weather <= 0 then
		return
	end
	---- same branch order as RTG
	local storm_mod, rating
	if GameState.DustStorm and face.DustStormModifier then
		storm_mod, rating = env.DustStormSightMod, face.DustStormModifier
	elseif GameState.FireStorm and face.FireStormModifier then
		storm_mod, rating = env.FireStormSightMod, face.FireStormModifier
	elseif GameState.ClearSky and GameState.Day and not GameState.DustStorm and not GameState.FireStorm
		and not GameState.Fog and not GameState.Night and face.TannedGoggles then
		return
	end
	if not storm_mod then
		return 100, weather
	end
	local cancelled = MulDivRound(storm_mod, rating, 100)
	return MulDivRound(100, weather - cancelled, weather), 100 - cancelled
end

local rtg_sight_inner = false

function GBO_RtgSightFix(self, other, base_sight, step_pos)
	local sight, hidden, night_time = rtg_sight_inner(self, other, base_sight, step_pos)
	local intended, applied = RtgWeatherFactors(self)
	if intended and applied > 0 and intended ~= applied then
		sight = MulDivRound(sight, intended, applied)
	end
	return sight, hidden, night_time
end

---- Outermost wrap, after every mod's file-scope wrap; subclasses got a copy of the method at class build
function GBO_InstallRtgSightFix()
	if not IsMod_loaded(RTG_ID) or Unit.GetSightRadius == GBO_RtgSightFix then
		return
	end
	local inner = Unit.GetSightRadius
	rtg_sight_inner = inner
	for _, class in pairs(g_Classes) do
		if IsKindOf(class, "Unit") and class.GetSightRadius == inner then
			class.GetSightRadius = GBO_RtgSightFix
		end
	end
end

OnMsg.DataLoaded = GBO_InstallRtgSightFix
OnMsg.ModsReloaded = GBO_InstallRtgSightFix
OnMsg.AutorunEnd = GBO_InstallRtgSightFix

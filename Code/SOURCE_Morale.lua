---- Vanilla Morale.lua fixes, and one-turn Berserk / Panicked.

---- ChangeMorale passes unit.leadership (nil -> 0), so Leadership never reached the roll; read it here.
function CombatTeam:GetMoraleEffectChance(effect_type)
	local leadership = 0
	for _, unit in ipairs(self.units) do
		if not unit:IsIncapacitated() then
			leadership = Max(leadership, unit.Leadership)
		end
	end
	if effect_type == "positive" then
		return 20 * self.morale * Max(0, leadership - 50) / 50
	end
	assert(effect_type == "negative")
	return Max(0, -20 * self.morale * (50 - Max(0, leadership - 50)) / 50)
end

---- Vanilla returned the enemies left over after picking, panicking everyone but the targets.
function GetEnemyPanicTargets(team)
	local ref_unit
	for _, unit in ipairs(team.units) do
		if not unit:IsDead() then
			ref_unit = unit
			break
		end
	end
	if not ref_unit then return end

	local enemies = table.icopy(GetAllEnemyUnits(ref_unit))
	local num_targets = (team.morale < 2) and 1 or InteractionRandRange(1, 3, "Combat")
	local targets = {}
	while #enemies > 0 and #targets < num_targets do
		local unit, idx = table.interaction_rand(enemies, "Combat")
		targets[#targets + 1] = unit
		table.remove(enemies, idx)
	end
	return targets
end

local RAT_ONE_TURN_EFFECTS = {Berserk = true, Panicked = true}

---- Round in which the unit's team next ends a turn it can act in; the round advances when the player team starts.
local function Rat_NextActingTurnEnd(unit)
	local turn = g_Combat.current_turn
	if g_Teams[g_CurrentTeam] == unit.team and unit.ActionPoints > 0 then
		return turn
	end
	local eot = 1
	for i, team in ipairs(g_Teams) do
		if team.side == "player1" or team.side == "player2" then
			eot = i
			break
		end
	end
	local i = g_CurrentTeam
	for _ = 1, #g_Teams do
		i = i % #g_Teams + 1
		if i == eot then
			turn = turn + 1
		end
		if g_Teams[i] == unit.team then
			return turn
		end
	end
	return turn
end

---- "Until End of Next Turn" cost two acting turns (the +1 for non-player turns ignores whose turn it is).
function OnMsg.StatusEffectAdded(obj, id)
	if RAT_ONE_TURN_EFFECTS[id] and g_Combat and g_CurrentTeam and IsKindOf(obj, "Unit") and obj.team then
		---- SetEffectExpirationTurn keeps the larger turn, so it cannot shorten vanilla's.
		obj.effect_values = obj.effect_values or {}
		obj.effect_values[id .. ":expiration"] = Rat_NextActingTurnEnd(obj)
	end
end

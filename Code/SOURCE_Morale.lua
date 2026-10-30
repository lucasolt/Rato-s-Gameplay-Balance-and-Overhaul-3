---- Vanilla Morale.lua fixes; Heroic with its own chance and a hard-turn trigger; one-turn Berserk / Panicked.

local RAT_BERSERK_CTH = 15
local RAT_PANIC_FREE_MOVE = 5 * const.Scale.AP

---- Hard turn = % of team HP lost between the end of the player turn and its next start, + points per merc downed.
local RAT_HARD_TURN_DOWN_PTS = 20
local RAT_HARD_TURN_MIN = 20
local RAT_HARD_TURN_SLOPE = 2
local RAT_HARD_TURN_MAX = 60

MapVar("Rat_HardTurnHP", false)
MapVar("Rat_HardTurnRolled", 0)

local function Rat_TeamLeadership(team)
	local leadership = 0
	for _, unit in ipairs(team.units) do
		if not unit:IsIncapacitated() then
			leadership = Max(leadership, unit.Leadership)
		end
	end
	return leadership
end

---- Leadership only nudges Heroic: x0.8 at 0, x1.2 at 100.
local function Rat_HeroicLeadershipMul(chance, leadership)
	return MulDivRound(chance, 80 + MulDivRound(40, leadership, 100), 100)
end

---- ChangeMorale passes unit.leadership (nil -> 0), so Leadership never reached the roll; read it here.
function CombatTeam:GetMoraleEffectChance(effect_type, leadership)
	leadership = leadership or Rat_TeamLeadership(self)
	if effect_type == "positive" then
		return 20 * self.morale * Max(0, leadership - 50) / 50
	end
	assert(effect_type == "negative")
	return Max(0, -20 * self.morale * (50 - Max(0, leadership - 50)) / 50)
end

local function Rat_MoraleEffectChance(team, effect, leadership)
	if effect.id == "HeroicReversal" then
		return Rat_HeroicLeadershipMul(20 * abs(team.morale), leadership)
	end
	return team:GetMoraleEffectChance(effect.Activation, leadership)
end

---- Vanilla copy (local in Morale.lua).
local function Rat_GetMoraleEffectTarget(effect, team)
	if effect.AppliedTo == "custom" then
		return effect:GetTargetUnit(team)
	end

	local units
	if effect.AppliedTo == "teammate" then
		units = table.icopy(team.units)
	else
		units = {}
		for _, t in ipairs(g_Teams) do
			if effect.AppliedTo == "ally" and (t == team or t:IsAllySide(team)) then
				table.iappend(units, t.units)
			elseif effect.AppliedTo == "enemy" and t:IsEnemySide(team) then
				table.iappend(units, t.units)
			end
		end
	end

	units = table.ifilter(units, function(idx, unit) return not unit:IsIncapacitated() and unit.species == "Human" and unit:IsAware() end)

	if effect.AppliedTo ~= "enemy" then
		local bestMerc
		for _, unit in ipairs(units) do
			if not bestMerc then
				bestMerc = unit
			elseif effect.Activation == "positive" and bestMerc:GetPersonalMorale() < unit:GetPersonalMorale() then
				bestMerc = unit
			elseif effect.Activation == "negative" and bestMerc:GetPersonalMorale() > unit:GetPersonalMorale() then
				bestMerc = unit
			end
		end

		local morale = bestMerc and bestMerc:GetPersonalMorale()
		if morale then
			for idx, unit in ipairs(units) do
				if unit:GetPersonalMorale() ~= morale then
					table.remove(units, idx)
				end
			end
		end
	end

	if #units > 0 then
		return table.interaction_rand(units, "Combat")
	end
end

---- Vanilla copy: Leadership read correctly and the chance is per effect (dead modifier_cooldowns dropped).
function CombatTeam:ChangeMorale(delta, event)
	if not g_Combat then return end

	assert(self:IsPlayerControlled())
	self.morale = Clamp(self.morale + delta, -2, 2)

	if delta > 0 then
		for _, unit in ipairs(self.units) do
			if HasPerk(unit, "Pessimist") then
				local chance = CharacterEffectDefs.Pessimist:ResolveValue("procChance")
				local roll = InteractionRand(100, "Pessimist")
				if roll < chance then
					PlayVoiceResponse(unit, "Pessimist")
					CombatLog("important", T(877663227979, "Pessimist: Morale increase event negated"))
					return
				end
			end
		end

		CombatLog("important", T{990449238632, "<em>Morale</em> is improving and is now <em><morale_level></em> (<event>)", morale_level = MoraleLevelName[self.morale], event = event})
	else
		for _, unit in ipairs(self.units) do
			if HasPerk(unit, "Optimist") then
				local chance = CharacterEffectDefs.Optimist:ResolveValue("procChance")
				local roll = InteractionRand(100, "Optimist")
				if roll < chance then
					PlayVoiceResponse(unit, "Optimist")
					CombatLog("important", T(875387191185, "Optimist: Morale decrease event negated"))
					return
				end
			end
		end

		CombatLog("important", T{293473420725, "<em>Morale</em> is dropping and is now <em><morale_level></em> (<event>)", morale_level = MoraleLevelName[self.morale], event = Untranslated(event)})

		if self.morale <= -2 then
			PlayVoiceResponse(table.rand(self.units), "TacticalLoss")
		end
	end

	local leadership = Rat_TeamLeadership(self)

	local effect_targets = {}
	local eligible_effects = {}
	for id, effect in sorted_pairs(MoraleEffects) do
		local target

		local can_activate
		local chance = Rat_MoraleEffectChance(self, effect, leadership)
		if effect.Activation == "positive" then
			can_activate = (delta > 0 and self.morale > 0) and (InteractionRand(100, "Combat") < chance)
		elseif effect.Activation == "negative" then
			can_activate = (delta < 0 and self.morale < 0) and (InteractionRand(100, "Combat") < chance)
		end

		if can_activate and (MoraleEffectCooldown[id] or 0) < g_Combat.current_turn then
			target = Rat_GetMoraleEffectTarget(effect, self)
		end

		if target then
			effect_targets[id] = target
			eligible_effects[#eligible_effects + 1] = effect
		end
	end

	if #eligible_effects > 0 then
		local effect = table.weighted_rand(eligible_effects, "Weight", InteractionRand(1000000, "PickMoraleEffectSeed"))
		local target = effect_targets[effect.id]

		effect:Activate(target)

		local cooldown = Max(0, effect.GlobalCooldown)
		MoraleGlobalCooldown = Max(MoraleGlobalCooldown, g_Combat.current_turn + cooldown)
		if effect.Cooldown >= 0 then
			MoraleEffectCooldown[effect.id] = Max(MoraleEffectCooldown[effect.id], g_Combat.current_turn + effect.Cooldown)
		end
	end
	Msg("MoraleChange")
	ObjModified(self)
	ObjModified(Selection)
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

function OnMsg.TurnEnded(team_idx)
	local team = g_Teams[team_idx]
	if not (g_Combat and team and team.player_team) then return end
	local snapshot = {}
	for _, unit in ipairs(team.units) do
		if not unit:IsIncapacitated() then
			snapshot[unit.session_id] = {hp = unit.HitPoints, max = unit.MaxHitPoints}
		end
	end
	Rat_HardTurnHP = snapshot
end

---- Survived a hard enemy turn: roll Heroic on the steadiest merc, independent of team morale.
function OnMsg.TurnStart(team_idx)
	local team = g_Teams[team_idx]
	if not (g_Combat and team and team.player_team) then return end
	local snapshot = Rat_HardTurnHP
	Rat_HardTurnHP = false
	if not snapshot or Rat_HardTurnRolled == g_Combat.current_turn then return end
	Rat_HardTurnRolled = g_Combat.current_turn

	local lost, total, downs = 0, 0, 0
	for session_id, s in pairs(snapshot) do
		local unit = g_Units[session_id]
		total = total + s.max
		if not unit or unit:IsIncapacitated() then
			lost = lost + s.hp
			downs = downs + 1
		else
			lost = lost + Max(0, s.hp - unit.HitPoints)
		end
	end
	if total <= 0 then return end
	for _, unit in ipairs(team.units) do
		if unit:HasStatusEffect("Heroic") then return end
	end

	local hard = MulDivRound(lost, 100, total) + downs * RAT_HARD_TURN_DOWN_PTS
	local chance = Clamp((hard - RAT_HARD_TURN_MIN) * RAT_HARD_TURN_SLOPE, 0, RAT_HARD_TURN_MAX)
	chance = Rat_HeroicLeadershipMul(chance, Rat_TeamLeadership(team))
	CombatLog("debug", T{Untranslated("Hard turn <hard>: Heroic chance <chance>%"), hard = hard, chance = chance})
	if chance <= 0 or InteractionRand(100, "Heroic") >= chance then return end

	local effect = MoraleEffects.HeroicReversal
	local target = effect and effect:GetTargetUnit(team)
	if target then
		effect:Activate(target)
	end
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

---- Extra free move for the run, once per turn; FreeMove's OnRemoved takes back what is left.
local function Rat_PanicFreeMove(unit)
	if unit.rat_panic_move_turn == g_Combat.current_turn or unit:IsIncapacitated() then return end
	if not unit:HasStatusEffect("FreeMove") then
		unit:AddStatusEffect("FreeMove")
	end
	---- GainAP refuses Panicked units; the rest of it is copied here.
	unit.ActionPoints = unit.ActionPoints + RAT_PANIC_FREE_MOVE
	unit.free_move_ap = unit.free_move_ap + RAT_PANIC_FREE_MOVE
	unit.rat_panic_move_turn = g_Combat.current_turn
	CombatPathReset(unit)
	Msg("UnitAPChanged", unit)
	ObjModified(unit)
end

---- "Until End of Next Turn" cost two acting turns (the +1 for non-player turns ignores whose turn it is).
function OnMsg.StatusEffectAdded(obj, id)
	if RAT_ONE_TURN_EFFECTS[id] and g_Combat and g_CurrentTeam and IsKindOf(obj, "Unit") and obj.team then
		---- SetEffectExpirationTurn keeps the larger turn, so it cannot shorten vanilla's.
		obj.effect_values = obj.effect_values or {}
		obj.effect_values[id .. ":expiration"] = Rat_NextActingTurnEnd(obj)
		if id == "Panicked" and g_Teams[g_CurrentTeam] == obj.team and obj.ActionPoints > 0 then
			Rat_PanicFreeMove(obj)
		end
	end
end

function OnMsg.UnitBeginTurn(unit)
	if g_Combat and unit:HasStatusEffect("Panicked") then
		Rat_PanicFreeMove(unit)
	end
end

---- Hidden: no modifiers row, the Berserk unit is AI-driven anyway.
function OnMsg.ClassesGenerate(classdefs)
	local berserk = classdefs.Berserk
	if not berserk then return end
	local reactions = berserk.unit_reactions or {}
	reactions[#reactions + 1] = PlaceObj('UnitReaction', {
		Event = "OnCalcChanceToHit",
		Handler = function(self, target, attacker, action, attack_target, weapon1, weapon2, data)
			if target == attacker then
				data.mod_add = data.mod_add + RAT_BERSERK_CTH
			end
		end
	})
	berserk.unit_reactions = reactions
end

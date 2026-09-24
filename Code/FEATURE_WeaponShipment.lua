---- Weapon Shipment: rarer, fewer guns above the campaign tier (WeaponShipmentRebalance), heavier escort (WeaponShipmentEscort).

---- Gun weight % by how many tiers the gun sits above the campaign tier (index = gap).
RAT_WS_BEYOND_TIER_PCT = {25, 5}
---- WeaponShipment's share of the dynamic shipment roll, % of its preset weight.
RAT_WS_SPAWN_WEIGHT_PCT = 50
---- WeaponShipmentEscort choice -> units added, and units promoted to their _Elite variant (carrier first).
RAT_WS_ESCORT_LEVELS = {
    Vanilla = {extra = 0, elites = 0},
    Reinforced = {extra = 2, elites = 1},
    Heavy = {extra = 4, elites = 2},
    Brutal = {extra = 6, elites = 3}
}
RAT_WS_ESCORT_DEFAULT = "Reinforced"
---- Extras are taken in order, so each level is the previous one plus more.
RAT_WS_ESCORT_EXTRA = {
    "LegionGunner_Stronger",
    "LegionRaidLeader_Stronger",
    "LegionRaider_Stronger",
    "LegionGunner_Stronger",
    "LegionMedic_Stronger",
    "LegionRaider_Stronger"
}

local rat_ws_pending = false

function Rat_WSEnabled()
    return CurrentModOptions.WeaponShipmentRebalance ~= false
end

function Rat_WSEscortLevel()
    return RAT_WS_ESCORT_LEVELS[CurrentModOptions.WeaponShipmentEscort] or
               RAT_WS_ESCORT_LEVELS[RAT_WS_ESCORT_DEFAULT]
end

---- Bobby Ray's unlocked tier is the campaign's progress clock: 1 after Ernie, 2 at two mines, 3 after the flip.
function Rat_WSCampaignTier()
    return Clamp(BobbyRayShopGetUnlockedTier() or 0, 1, 3)
end

function Rat_WSGunWeight(entry, tier)
    local class = entry.item and g_Classes[entry.item]
    local gap = (class and class.Tier or 1) - tier
    if gap <= 0 then
        return entry.weight
    end
    return MulDivRound(entry.weight, RAT_WS_BEYOND_TIER_PCT[Min(gap, #RAT_WS_BEYOND_TIER_PCT)], 100)
end

---- Same roll as LootDef "random", with each gun reweighted by its tier gap.
local orig = Rat_AttOriginal(LootDef.GenerateLoot)
function LootDef:GenerateLoot(looter, looted, seed, items, modifiers, amount_modifier)
    if self.id ~= "WeaponShipment_Gun" or self.loot ~= "random" or not Rat_WSEnabled() then
        return orig(self, looter, looted, seed, items, modifiers, amount_modifier)
    end
    seed = seed or self:GenerateLootSeed(nil, looter, looted)
    NetUpdateHash("LootDef:GenerateLoot", seed)
    local tier = Rat_WSCampaignTier()
    local pool, total, none = {}, 0, 0
    for _, entry in ipairs(self) do
        if entry:TestConditions(looter, looted) then
            if entry.class == "LootEntryNoLoot" then
                none = none + entry.weight
            else
                local w = Rat_WSGunWeight(entry, tier)
                total = total + w
                pool[#pool + 1] = {entry, total}
            end
        end
    end
    local rand
    rand, seed = BraidRandom(seed, total + none)
    for _, pick in ipairs(pool) do
        if rand < pick[2] then
            return pick[1]:GenerateLoot(looter, looted, seed, items, modifiers, amount_modifier)
        end
    end
end
RAT_ATT_WRAPS[LootDef.GenerateLoot] = orig

---- Vanilla reads preset.Conditions, but the presets author EnableConditions: the $20k gate never ran.
local orig = Rat_AttOriginal(PickShipmentPreset)
function PickShipmentPreset()
    if not Rat_WSEnabled() then
        rat_ws_pending = orig()
        return rat_ws_pending
    end
    local weights = {}
    for _, group in ipairs(Presets.ShipmentSquadPreset) do
        for _, preset in ipairs(group) do
            if EvalConditionList(preset.EnableConditions) and EvalConditionList(preset.Conditions) then
                local w = preset.weight
                if preset.id == "WeaponShipment" then
                    w = MulDivRound(w, RAT_WS_SPAWN_WEIGHT_PCT, 100)
                end
                weights[#weights + 1] = {w, preset.id}
            end
        end
    end
    local id = GetWeightedRandom(weights, xxhash(Game.id, Game.CampaignTime, gv_NextSquadUniqueId))
    rat_ws_pending = id
    return id
end
RAT_ATT_WRAPS[PickShipmentPreset] = orig

---- SpawnDynamicDBSquad picks the preset, then generates the squad: the pick is handed over here.
local orig = Rat_AttOriginal(GenerateRandEnemySquadUnits)
function GenerateRandEnemySquadUnits(enemy_squad_id)
    local ids, names, sources, visuals = orig(enemy_squad_id)
    local pending = rat_ws_pending
    rat_ws_pending = false
    local preset = pending == "WeaponShipment" and ShipmentPresets[pending]
    if not preset or preset.enemy_squad_def ~= enemy_squad_id then
        return ids, names, sources, visuals
    end
    local level = Rat_WSEscortLevel()
    for i = 1, Min(level.extra, #RAT_WS_ESCORT_EXTRA) do
        if UnitDataDefs[RAT_WS_ESCORT_EXTRA[i]] then
            ids[#ids + 1] = RAT_WS_ESCORT_EXTRA[i]
            sources[#sources + 1] = 0
        end
    end
    ---- Each _Elite takes a name from a 20-name Legion pool (gv_UsedEliteNames), hence the small counts.
    local carrier = table.find(sources, EnemySquadDefs[enemy_squad_id].DiamondBriefcaseCarrier)
    local order = carrier and {carrier} or {}
    for i = 1, #ids do
        if i ~= carrier then
            order[#order + 1] = i
        end
    end
    local left = level.elites
    for _, i in ipairs(order) do
        if left <= 0 then
            break
        end
        local elite = ids[i] .. "_Elite"
        if UnitDataDefs[elite] then
            ids[i] = elite
            left = left - 1
        end
    end
    return ids, names, sources, visuals
end
RAT_ATT_WRAPS[GenerateRandEnemySquadUnits] = orig

---- Vanilla's NewDay cooldown is `last - now > 3 days`, never true. Days without a spawn after one.
RAT_WS_COOLDOWN_DAYS = 3

---- {accum, last} as they were before vanilla's NewDay ran; set only for the midnight tick.
local rat_ws_midnight = false

local function rat_ws_in_cooldown(last)
    return last > 0 and Game.CampaignTime - last < RAT_WS_COOLDOWN_DAYS * const.Scale.day
end

local orig = Rat_AttOriginal(SpawnDynamicDBSquad)
function SpawnDynamicDBSquad(...)
    if rat_ws_midnight and rat_ws_in_cooldown(rat_ws_midnight[2]) then
        return
    end
    rat_ws_pending = false
    orig(...)
    rat_ws_pending = false
end
RAT_ATT_WRAPS[SpawnDynamicDBSquad] = orig

---- NewHour fires right before NewDay in the same tick, after Guardpost's aggro spawn already ran.
function OnMsg.NewHour()
    rat_ws_midnight = Rat_WSEnabled() and Game.CampaignTime % const.Scale.day < const.Scale.min and
                          {DynamicDBSquadAccumChance or 0, DynamicDBSquadLastSpawnTime or 0}
end

---- Runs after vanilla's handler: undo the day's accumulation and the reset it did for a blocked spawn.
function OnMsg.NewDay()
    local snap = rat_ws_midnight
    rat_ws_midnight = false
    if snap and rat_ws_in_cooldown(snap[2]) then
        DynamicDBSquadAccumChance = snap[1]
        DynamicDBSquadLastSpawnTime = snap[2]
    end
end

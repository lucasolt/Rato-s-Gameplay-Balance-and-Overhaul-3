---- Weapon Shipment: rarer, fewer guns above the campaign tier, and a heavier escort.

---- Gun weight % by how many tiers the gun sits above the campaign tier (index = gap).
RAT_WS_BEYOND_TIER_PCT = {25, 5}
---- WeaponShipment's share of the dynamic shipment roll, % of its preset weight.
RAT_WS_SPAWN_WEIGHT_PCT = 50
---- Units added to the escort, by campaign tier.
RAT_WS_ESCORT_EXTRA = {
    {"LegionGunner_Stronger"},
    {"LegionGunner_Stronger", "LegionRaidLeader_Stronger"},
    {"LegionGunner_Stronger", "LegionRaidLeader_Stronger", "LegionRaider_Stronger"}
}

local rat_ws_pending = false

function Rat_WSEnabled()
    return CurrentModOptions.WeaponShipmentRebalance ~= false
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
        return orig()
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
    if not preset or preset.enemy_squad_def ~= enemy_squad_id or not Rat_WSEnabled() then
        return ids, names, sources, visuals
    end
    ---- The carrier becomes its named elite variant; only one, elite names are a finite pool.
    local carrier = table.find(sources, EnemySquadDefs[enemy_squad_id].DiamondBriefcaseCarrier)
    local elite = carrier and ids[carrier] .. "_Elite"
    if elite and UnitDataDefs[elite] then
        ids[carrier] = elite
    end
    for _, extra in ipairs(RAT_WS_ESCORT_EXTRA[Rat_WSCampaignTier()] or empty_table) do
        if UnitDataDefs[extra] then
            ids[#ids + 1] = extra
            sources[#sources + 1] = 0
        end
    end
    return ids, names, sources, visuals
end
RAT_ATT_WRAPS[GenerateRandEnemySquadUnits] = orig

local orig = Rat_AttOriginal(SpawnDynamicDBSquad)
function SpawnDynamicDBSquad(...)
    rat_ws_pending = false
    orig(...)
    rat_ws_pending = false
end
RAT_ATT_WRAPS[SpawnDynamicDBSquad] = orig

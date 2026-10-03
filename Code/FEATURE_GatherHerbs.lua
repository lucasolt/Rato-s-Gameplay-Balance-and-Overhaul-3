---- Satellite operation: one merc sweeps the sector for every HerbMarker, rolling the same check as walking past it.
---- Map objects.lua is binary and MapData.markers ships empty, so herb spots are indexed whenever a sector map is loaded.
GameVar("gv_RatHerbSpots", {})

local RAT_HERB_OP = "Rat_GatherHerbs"
local RAT_HERB_DURATION = 30 * const.Scale.min

local function rat_herb_live(sector_id)
    return sector_id == gv_CurrentSectorId and GameState.entered_sector
end

local function rat_herb_index_current()
    local sector_id = gv_CurrentSectorId
    if not sector_id or not GameState.entered_sector then
        return
    end
    local spots = {}
    MapForEach("map", "HerbMarker", function(o)
        if DifficultyToNumber(o.Difficulty) >= 0 and o:IsMarkerEnabled() then
            spots[#spots + 1] = {
                handle = o.handle,
                difficulty = o.Difficulty,
                skill = o.SkillRequired,
                item = o.grant_item_class,
                min = o.grant_item_min,
                max = o.grant_item_max,
                granted = o.granted or nil
            }
        end
    end)
    table.sortby_field(spots, "handle")
    gv_RatHerbSpots[sector_id] = #spots > 0 and spots or nil
end

function OnMsg.EnterSector()
    rat_herb_index_current()
end

---- fires from GatherSectorDynamicData while the map is still loaded, so herbs picked by hand are caught
function OnMsg.SaveDynamicData()
    rat_herb_index_current()
end

local function rat_herb_left(sector_id)
    local spots = gv_RatHerbSpots[sector_id] or empty_table
    local left = 0
    for _, spot in ipairs(spots) do
        local obj = rat_herb_live(sector_id) and HandleToObject[spot.handle]
        local granted
        if IsValid(obj) then
            granted = obj.granted
        else
            granted = spot.granted
        end
        if not granted then
            left = left + 1
        end
    end
    return left, #(spots or "")
end

---- unloaded sector: marker state lives in the serialized sector_data, keyed by handle
local function rat_herb_decode(sector)
    local code = sector.sector_data
    if not code or code == "" then
        return
    end
    local err, data = LuaCodeToTuple(code)
    if err or type(data) ~= "table" or not data.dynamic_data then
        return
    end
    local by_handle = {}
    for _, entry in ipairs(data.dynamic_data) do
        by_handle[entry.handle] = entry
    end
    return data, by_handle
end

local function rat_herb_grant(merc, sector_id, item, amount)
    local left = AddItemToSquadBag(merc.Squad, item, amount) or 0
    if left <= 0 then
        return
    end
    local stack = PlaceInventoryItem(item)
    if IsKindOf(stack, "InventoryStack") then
        stack.Amount = left
    end
    local items = {stack}
    merc:AddItemsToInventory(items)
    if #items > 0 then
        AddToSectorInventory(sector_id, items)
    end
end

local function rat_herb_gather(sector, merc)
    local sector_id = sector.Id
    local spots = gv_RatHerbSpots[sector_id]
    if not spots or not merc then
        return 0, 0, {}
    end
    local live = rat_herb_live(sector_id)
    local data, by_handle
    if not live then
        data, by_handle = rat_herb_decode(sector)
        if not data then
            return 0, 0, {}
        end
    end

    local found, missed, totals, changed = 0, 0, {}, false
    for _, spot in ipairs(spots) do
        local obj = live and HandleToObject[spot.handle]
        local state = IsValid(obj) and obj or (not live and by_handle[spot.handle])
        ---- marker never wrote dynamic data: no random offset, never touched
        if not state and not live then
            state = {handle = spot.handle}
        end
        if state and not state.granted then
            local threshold = DifficultyToNumber(spot.difficulty) + (state.additional_difficulty or 0)
            if state.activated or SkillCheck(merc, spot.skill, threshold, true) == "success" then
                local amount = spot.min + InteractionRand(spot.max - spot.min, "Loot") +
                                   (const.DifficultyToItemModifier[spot.difficulty] or 0) / 2
                totals[spot.item] = (totals[spot.item] or 0) + amount
                state.activated = true
                state.discovered = true
                state.granted = true
                spot.granted = true
                if data and not by_handle[spot.handle] then
                    data.dynamic_data[#data.dynamic_data + 1] = state
                    by_handle[spot.handle] = state
                end
                found = found + 1
                changed = true
            else
                missed = missed + 1
            end
        end
    end

    if changed and data then
        table.sortby_field(data.dynamic_data, "handle")
        sector.sector_data = tostring(TableToLuaCode(data, nil, pstr("", 1024)))
    end
    for item, amount in sorted_pairs(totals) do
        rat_herb_grant(merc, sector_id, item, amount)
    end
    return found, missed, totals
end

PlaceObj('SectorOperation', {
    Custom = false,
    GetSectorSlots = function(self, prof, sector)
        return 1
    end,
    HasOperation = function(self, sector)
        return gv_RatHerbSpots[sector.Id] ~= nil
    end,
    IsEnabled = function(self, sector)
        if rat_herb_left(sector.Id) == 0 then
            return false, T(587310042716, "No herbs left to gather.")
        end
        return true
    end,
    ---- one unit per tick: duration is fixed, skill only decides what gets found
    ProgressPerTick = function(self, merc, prediction)
        return 1
    end,
    ProgressCompleteThreshold = function(self, merc, sector, prediction)
        return Max(1, MulDivRound(RAT_HERB_DURATION, 1, const.Satellite.Tick))
    end,
    ProgressCurrent = function(self, merc, sector, prediction)
        return sector and sector.rat_herbs_progress or 0
    end,
    ModifyProgress = function(self, value, sector)
        sector.rat_herbs_progress = (sector.rat_herbs_progress or 0) + value
    end,
    OnRemoveOperation = function(self, merc)
        local sector = merc:GetSector()
        if sector and #GetOperationProfessionals(sector.Id, self.id, false, merc.session_id) == 0 then
            sector.rat_herbs_progress = 0
        end
    end,
    OnComplete = function(self, sector, mercs)
        sector.rat_herbs_progress = 0
        local merc = mercs[1]
        local found, missed, totals = rat_herb_gather(sector, merc)
        if not merc then
            return
        end
        if found == 0 then
            CombatLog("important", T{
                587310042717, "<em><Nick></em> found no <em>Herbs</em> in <SectorName(sector)>",
                Nick = merc.Nick, sector = sector
            })
            return
        end
        for item, amount in sorted_pairs(totals) do
            CombatLog("important", T{
                587310042718, "<em><Nick></em> gathered <Amount> <Item> from <Found> herb spots in <SectorName(sector)>",
                Nick = merc.Nick, Amount = amount, Item = InventoryItemDefs[item].DisplayName, Found = found,
                sector = sector
            })
        end
        if missed > 0 then
            CombatLog("important", T{
                587310042719, "<Missed> herb spots were too well hidden for <em><Nick></em>",
                Missed = missed, Nick = merc.Nick
            })
        end
    end,
    SectorOperationStats = function(self, sector, check_only)
        if check_only then
            return true
        end
        local left, total = rat_herb_left(sector.Id)
        local progress = MulDivTrunc(self:ProgressCurrent(nil, sector), 100, self:ProgressCompleteThreshold(nil, sector))
        return {
            {text = T(587310042720, "Herb spots left"), value = T{587310042721, "<left>/<total>", left = left, total = total}},
            {text = T(349715428104, "Current Progress"), value = T{257328164584, "<percent(value)>", value = progress}}
        }, progress
    end,
    Professions = {
        PlaceObj('SectorOperationProfession', {
            'id', "Herbalist",
            'display_name', T(587310042722, "Herbalist"),
            'description', T(587310042723, "The Herbalist searches the sector for medicinal herbs."),
            'display_name_all_caps', T(587310042724, "HERBALIST"),
            'display_name_plural', T(587310042725, "Herbalists"),
            'display_name_plural_all_caps', T(587310042726, "HERBALISTS"),
        }),
    },
    ShowInCombatBadge = false,
    SortKey = 25,
    description = T(587310042727, "Comb the sector for medicinal <em>Herbs</em>. The merc collects every herb spot their <em>Wisdom</em> lets them find - the same spots they would notice walking the map. Herbs already gathered are skipped."),
    display_name = T(587310042728, "Gather Herbs"),
    error_msg = T(587310042729, "<flavor>There are no herbs left to gather in this sector.</flavor>"),
    group = "Default",
    icon = "UI/SectorOperations/T_Icon_Activity_Scouting",
    id = RAT_HERB_OP,
    image = "UI/Messages/Operations/scout",
    log_msg_start = T(587310042730, "<em><mercs></em> started <em>gathering Herbs</em> in <SectorName(sector)>"),
    related_stat = "Wisdom",
    short_name = T(587310042731, "Herbs"),
    sub_title = T(587310042732, "Collect every herb your merc can find in the sector"),
})

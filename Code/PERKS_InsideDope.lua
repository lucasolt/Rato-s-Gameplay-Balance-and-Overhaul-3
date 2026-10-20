---- Inside Dope (InnerInfo, Livewire): sector Intel no longer reveals every enemy. Unseen enemies are
---- grouped into clusters, each shown as a red ring around their centroid, offset at random, with a rough count.
---- Positions are re-read at the player's turn start (exploration: every IntelPingPeriod); every visibility
---- update regroups the still-unseen enemies from their last known positions.
local file_str = "PERKS_InsideDope.lua"

local IntelPingClusterTiles = 12--9
local IntelPingOffsetTiles = 4
local IntelPingPadTiles = 1
local IntelPingMaxRadiusTiles = 8
local IntelPingPeriod = 10000
local IntelPingMaterial = "ExplodingBarrelRange_Tiles"
local IntelPingColor = RGB(220, 40, 40)
local IntelPingOpacity = 60
local IntelPingZOffset = 40 * guic
local IntelPingTextStyle = "FloatingTextError"
local IntelPingTextColor = RGBA(255, 40, 40, 200)

local intel_pings = false
local intel_epoch = false
local intel_key = false
local intel_known = {}
local intel_hidden = false

local function IntelPingTeam()
    local sector = gv_CurrentSectorId and gv_Sectors[gv_CurrentSectorId]
    if not sector or not sector.intel_discovered then
        return
    end
    local team = GetPoVTeam()
    for _, unit in ipairs(team and team.units) do
        if not unit:IsDead() and unit:HasStatusEffect("InnerInfo") then
            return team
        end
    end
end

local function IsUnseenEnemy(team, unit)
    return unit:IsValidPos() and not unit:IsDead() and team:IsEnemySide(unit.team)
               and not HasVisibilityTo(team, unit)
end

local function ClearIntelPings()
    for _, ping in ipairs(intel_pings or empty_table) do
        DoneObject(ping.mesh)
        DoneObject(ping.text)
    end
    intel_pings = false
end

local function IntelEpoch()
    if g_Combat then
        return g_Combat.current_turn or 0
    end
    return -1 - GameTime() / IntelPingPeriod
end

local function ValidZ(pos)
    return pos:IsValidZ() and pos or pos:SetTerrainZ()
end

local function KnownPos(unit)
    return intel_known[unit] or unit:GetPos()
end

---- Seen enemies update their known position; unseen ones keep the one from the last reset or sighting,
---- so regrouping during the enemy turn never tracks where they are walking.
local function UpdateKnownPositions(team, reset)
    if reset then
        intel_known = {}
    end
    for _, unit in ipairs(g_Units) do
        if unit:IsValidPos() and not unit:IsDead() and team:IsEnemySide(unit.team)
            and (reset or not intel_known[unit] or HasVisibilityTo(team, unit)) then
            intel_known[unit] = unit:GetPos()
        end
    end
end

local function UpdateCentroid(cluster)
    local x, y, z = 0, 0, 0
    for _, unit in ipairs(cluster.units) do
        local px, py, pz = ValidZ(KnownPos(unit)):xyz()
        x, y, z = x + px, y + py, z + pz
    end
    local n = #cluster.units
    cluster.centroid = point(x / n, y / n, z / n)
end

---- Merges the two clusters with the closest centroids until none are within the radius,
---- so grouping doesn't depend on g_Units order.
local function GatherClusters(team)
    local clusters = {}
    for _, unit in ipairs(g_Units) do
        if IsUnseenEnemy(team, unit) then
            local cluster = {units = {unit}}
            UpdateCentroid(cluster)
            clusters[#clusters + 1] = cluster
        end
    end
    local radius = IntelPingClusterTiles * const.SlabSizeX
    while true do
        local best, bi, bj = radius + 1
        for i = 1, #clusters - 1 do
            for j = i + 1, #clusters do
                local d = clusters[i].centroid:Dist2D(clusters[j].centroid)
                if d < best then
                    best, bi, bj = d, i, j
                end
            end
        end
        if not bi then
            return clusters
        end
        table.iappend(clusters[bi].units, clusters[bj].units)
        UpdateCentroid(clusters[bi])
        table.remove(clusters, bj)
    end
end

local function PlaceIntelPing(cluster, epoch)
    local units, centroid = cluster.units, cluster.centroid
    local n = #units
    local spread = 0
    for _, unit in ipairs(units) do
        spread = Max(spread, KnownPos(unit):Dist2D(centroid))
    end
    local handle = units[1].handle
    for _, unit in ipairs(units) do
        handle = Min(handle, unit.handle)
    end
    -- Seeded by turn so the ping holds still within a turn and can't be averaged by watching it.
    local seed = xxhash(handle, epoch)
    local angle, dist, jitter
    angle, seed = BraidRandom(seed, 360 * 60)
    local max_offset = IntelPingOffsetTiles * const.SlabSizeX
    -- sqrt of a uniform square spreads the offset evenly over the disk instead of piling it at the center.
    dist, seed = BraidRandom(seed, max_offset * max_offset + 1)
    dist = sqrt(dist)
    jitter, seed = BraidRandom(seed, 3)
    local center = centroid + Rotate(point(dist, 0, 0), angle)
    -- Guarantees only the centroid inside; edge enemies of a wide group may fall outside.
    local radius = Min((IntelPingOffsetTiles + IntelPingPadTiles) * const.SlabSizeX + spread / 2,
                       IntelPingMaxRadiusTiles * const.SlabSizeX)

    -- Same tile mesh as the exploding barrel range, without LOS shading: it is not cast from the center.
    local steps, step_objs = GetStepPositionsInArea(center, radius, 0, -1, nil, false)
    local mesh = CreateAOETilesCircle(steps, step_objs, nil, center, radius, empty_table, IntelPingMaterial)
    -- Vanilla lifts the tiles only 10 cm, so grass covers them; rebuild the vertices higher.
    local vertices = pstr("", 1024)
    AppendVerticesAOETilesMesh(vertices, steps, step_objs, empty_table, const.clrWhite, IntelPingZOffset)
    mesh:SetMesh(vertices)
    mesh:SetColorModifier(IntelPingColor)
    mesh:SetOpacity(IntelPingOpacity)

    local text = PlaceText("~" .. Max(1, n + jitter - 1), center + point(0, 0, const.SlabSizeZ))
    text:SetTextStyle(IntelPingTextStyle)
    text:SetColor(IntelPingTextColor)
    -- SetColor resets the shadow to opaque black; give it the label's alpha.
    text:SetColor2(RGBA(0, 0, 0, select(4, GetRGBA(IntelPingTextColor))))
    text:SetShadowOffset(1)
    text:SetCenter(true)
    mesh:SetVisible(not intel_hidden)
    text:SetVisible(not intel_hidden)
    return {mesh = mesh, text = text, units = units}
end

function Rat_ToggleIntelPings()
    intel_hidden = not intel_hidden
    for _, ping in ipairs(intel_pings or empty_table) do
        ping.mesh:SetVisible(not intel_hidden)
        ping.text:SetVisible(not intel_hidden)
    end
end

function OnMsg.Shortcuts(host)
    XAction:new({
        ActionId = "RatInsideDopeToggle",
        ActionName = ratT(file_str, 739104628518, "Toggle Inside Dope areas"),
        ActionShortcut = "Alt-I",
        ActionBindable = true,
        IgnoreRepeated = true,
        OnAction = function()
            Rat_ToggleIntelPings()
        end,
    }, host)
end

local function ClustersKey(clusters, epoch)
    local parts = {}
    for i, cluster in ipairs(clusters) do
        parts[i] = tostring(cluster.centroid) .. "#" .. #cluster.units
    end
    table.sort(parts)
    return tostring(epoch) .. "|" .. table.concat(parts, "|")
end

---- reset re-reads every enemy's position (turn start, exploration period); otherwise the clusters
---- are regrouped from known positions and the meshes rebuilt only if a cluster changed.
function Rat_RefreshIntelPings(reset)
    local team = IntelPingTeam()
    if not team then
        ClearIntelPings()
        intel_key = false
        return
    end
    if reset or not intel_epoch then
        intel_epoch = IntelEpoch()
        reset = true
    end
    UpdateKnownPositions(team, reset)
    local clusters = GatherClusters(team)
    local key = ClustersKey(clusters, intel_epoch)
    if key ~= intel_key or not intel_pings then
        intel_key = key
        ClearIntelPings()
        intel_pings = {}
        for _, cluster in ipairs(clusters) do
            intel_pings[#intel_pings + 1] = PlaceIntelPing(cluster, intel_epoch)
        end
    end
    return #intel_pings > 0
end

function OnMsg.TurnStart(team_idx)
    local team = g_Teams[team_idx]
    if team and team == GetPoVTeam() then
        Rat_RefreshIntelPings(true)
    end
end

function OnMsg.ExplorationTick()
    if intel_epoch ~= IntelEpoch() then
        Rat_RefreshIntelPings(true)
    end
end

function OnMsg.VisibilityUpdate()
    Rat_RefreshIntelPings()
end

function OnMsg.CombatEnd()
    ClearIntelPings()
    intel_key = false
end

function OnMsg.DoneMap()
    intel_pings = false
    intel_epoch = false
    intel_key = false
    intel_known = {}
end

function Rat_InsideDopeDescription()
    local text = "If you have <em>Intel</em> for the Sector, unseen <em>Enemies</em> show up as red <em>areas</em> on the map. In combat their intel is from the start of your turn, and the areas regroup as your mercs spot enemies.\n\nPress <em><ShortcutName('RatInsideDopeToggle')></em> to show or hide the areas."
    return ratT(file_str, 739104628517, text)
end

function OnMsg.ClassesGenerate(classdefs)
    local perk = classdefs.InnerInfo
    if not perk then
        return
    end
    local reactions = {}
    for _, reaction in ipairs(perk.unit_reactions or empty_table) do
        if reaction.Event == "OnUnitEnterMapVisual" then
            reaction.Handler = function(self, target)
                if target.HireStatus ~= "Hired" then
                    return
                end
                CreateGameTimeThread(function()
                    while GetInGameInterfaceMode() == "IModeDeployment" do
                        Sleep(20)
                    end
                    if Rat_RefreshIntelPings() then
                        Sleep(2000)
                        PlayVoiceResponse(target, "PersonalPerkSubtitled")
                    end
                end)
            end
        end
        if reaction.Event ~= "OnCheckIntelVisible" then
            reactions[#reactions + 1] = reaction
        end
    end
    perk.unit_reactions = reactions
    perk.Description = Rat_InsideDopeDescription()
end

function OnMsg.DataLoaded()
    local perk = CharacterEffectDefs.InnerInfo
    if perk then
        perk.Description = Rat_InsideDopeDescription()
    end
end

-- Revealed-only targets are gone, so the Livewire-specific "out of sight" text no longer applies.
AttackDisableReasons.NoTeamSightLivewire = AttackDisableReasons.NoTeamSight

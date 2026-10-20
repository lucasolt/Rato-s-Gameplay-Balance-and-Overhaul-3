---- Inside Dope (InnerInfo, Livewire): sector Intel no longer reveals every enemy. Unseen enemies are
---- grouped into clusters, each shown as a red ring that contains them, offset at random, with a rough count.
---- Combat refreshes at the start of the player's turn; exploration every IntelPingPeriod.
local file_str = "PERKS_InsideDope.lua"

local IntelPingClusterTiles = 6
local IntelPingOffsetTiles = 4
local IntelPingPadTiles = 1
local IntelPingPeriod = 10000
local IntelPingSegments = 32
local IntelPingColor = RGB(220, 40, 40)
local IntelPingFillAlpha = 20
local IntelPingRingAlpha = 130
local IntelPingTextStyle = "FloatingTextError"
local IntelPingTextColor = RGBA(255, 40, 40, 200)

local AppendVertex = pstr().AppendVertex
local intel_pings = false
local intel_epoch = false
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

local function GatherClusters(team)
    local clusters = {}
    local radius = IntelPingClusterTiles * const.SlabSizeX
    for _, unit in ipairs(g_Units) do
        if IsUnseenEnemy(team, unit) then
            local pos = unit:GetPos()
            local cluster
            for _, c in ipairs(clusters) do
                if IsCloser2D(c.anchor, pos, radius + 1) then
                    cluster = c
                    break
                end
            end
            if cluster then
                table.insert(cluster.units, unit)
            else
                clusters[#clusters + 1] = {anchor = pos, units = {unit}}
            end
        end
    end
    return clusters
end

local function ValidZ(pos)
    return pos:IsValidZ() and pos or pos:SetTerrainZ()
end

local function RingMesh(center, radius)
    local band = const.SlabSizeX / 8
    local vpstr = pstr("", 1024)
    local r, g, b = GetRGB(IntelPingColor)
    local fill, ring = RGBA(r, g, b, IntelPingFillAlpha), RGBA(r, g, b, IntelPingRingAlpha)
    local outer, inner = {}, {}
    for i = 0, IntelPingSegments do
        local angle = MulDivRound(i, 360 * 60, IntelPingSegments)
        outer[i] = center + Rotate(point(radius, 0, 0), angle)
        inner[i] = center + Rotate(point(radius - band, 0, 0), angle)
    end
    for i = 1, IntelPingSegments do
        AppendVertex(vpstr, center, fill)
        AppendVertex(vpstr, inner[i - 1], fill)
        AppendVertex(vpstr, inner[i], fill)
        AppendVertex(vpstr, inner[i - 1], ring)
        AppendVertex(vpstr, outer[i - 1], ring)
        AppendVertex(vpstr, outer[i], ring)
        AppendVertex(vpstr, inner[i - 1], ring)
        AppendVertex(vpstr, outer[i], ring)
        AppendVertex(vpstr, inner[i], ring)
    end
    return vpstr
end

local function PlaceIntelPing(cluster, epoch)
    local units = cluster.units
    local x, y, z = 0, 0, 0
    for _, unit in ipairs(units) do
        local px, py, pz = ValidZ(unit:GetPos()):xyz()
        x, y, z = x + px, y + py, z + pz
    end
    local n = #units
    local centroid = point(x / n, y / n, z / n)
    local spread = 0
    for _, unit in ipairs(units) do
        spread = Max(spread, unit:GetDist2D(centroid))
    end
    -- Seeded by turn so the ping holds still within a turn and can't be averaged by watching it.
    local seed = xxhash(units[1].handle, epoch)
    local angle, dist, jitter
    angle, seed = BraidRandom(seed, 360 * 60)
    local max_offset = IntelPingOffsetTiles * const.SlabSizeX
    -- sqrt of a uniform square spreads the offset evenly over the disk instead of piling it at the center.
    dist, seed = BraidRandom(seed, max_offset * max_offset + 1)
    dist = sqrt(dist)
    jitter, seed = BraidRandom(seed, 3)
    local center = centroid + Rotate(point(dist, 0, 0), angle) + point(0, 0, const.SlabSizeZ / 10)
    local radius = (IntelPingOffsetTiles + IntelPingPadTiles) * const.SlabSizeX + spread

    local mesh = PlaceObject("Mesh")
    mesh:SetMeshFlags(const.mfWorldSpace)
    local sh = ProceduralMeshShaders.default_mesh
    mesh:SetShader(sh, (sh.depth_test == "runtime") and false or nil)
    mesh:SetMesh(RingMesh(center, radius))
    mesh:SetPos(center)

    local text = PlaceText("~" .. Max(1, n + jitter - 1), center + point(0, 0, const.SlabSizeZ))
    text:SetTextStyle(IntelPingTextStyle)
    text:SetColor(IntelPingTextColor)
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

function Rat_RefreshIntelPings()
    ClearIntelPings()
    local team = IntelPingTeam()
    if not team then
        return
    end
    intel_epoch = IntelEpoch()
    intel_pings = {}
    for _, cluster in ipairs(GatherClusters(team)) do
        intel_pings[#intel_pings + 1] = PlaceIntelPing(cluster, intel_epoch)
    end
    return #intel_pings > 0
end

---- Drops a ping once every enemy in it is seen or dead; the rest stay put until the next refresh.
local function PruneIntelPings()
    local team = GetPoVTeam()
    if not intel_pings or not team then
        return
    end
    for i = #intel_pings, 1, -1 do
        local ping = intel_pings[i]
        local any = false
        for _, unit in ipairs(ping.units) do
            any = any or IsValid(unit) and IsUnseenEnemy(team, unit)
        end
        if not any then
            DoneObject(ping.mesh)
            DoneObject(ping.text)
            table.remove(intel_pings, i)
        end
    end
end

function OnMsg.TurnStart(team_idx)
    local team = g_Teams[team_idx]
    if team and team == GetPoVTeam() then
        Rat_RefreshIntelPings()
    end
end

function OnMsg.ExplorationTick()
    if intel_epoch ~= IntelEpoch() or not intel_pings then
        Rat_RefreshIntelPings()
    end
end

function OnMsg.VisibilityUpdate()
    -- After a load mid-combat nothing is built until the next player turn.
    if g_Combat and intel_pings == false then
        Rat_RefreshIntelPings()
    end
    PruneIntelPings()
end

function OnMsg.CombatEnd()
    ClearIntelPings()
end

function OnMsg.DoneMap()
    intel_pings = false
    intel_epoch = false
end

function Rat_InsideDopeDescription()
    local text = "If you have <em>Intel</em> for the Sector, unseen <em>Enemies</em> show up as red <em>areas</em> on the map with a rough count of who is inside. In combat they update at the start of your turn.\n\nPress <em><ShortcutName('RatInsideDopeToggle')></em> to show or hide the areas."
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

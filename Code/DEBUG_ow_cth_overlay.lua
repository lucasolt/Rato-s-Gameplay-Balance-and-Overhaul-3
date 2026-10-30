---- OWDebug(): toggles a per-tile CTH overlay on every active overwatch cone.
---- CTH = first shot of the interrupt attack vs the Torso of a standing unit, fully exposed, flat ground.

local enabled, last_sig, gen = false, false, 0

local function ref_target(unit)
    local ally
    for _, u in ipairs(g_Units) do
        if u ~= unit and IsValid(u) and not u:IsDead() and u:GetHitStance() == "Standing" then
            if unit:IsOnEnemySide(u) then
                return u
            end
            ally = ally or u
        end
    end
    return ally
end

---- Mirrors Rat_KillzoneAim for the first target, without registering a rank.
local function ow_aim(unit, ow, action, target)
    local aim = ow.aim or 0
    local mg = unit:HasStatusEffect("StationedMachineGun") or unit:HasStatusEffect("ManningEmplacement")
    if HasPerk(unit, mg and "BeatenZone" or "Killzone") then
        local first = const.Combat.Perks.KillzoneAimByTarget[1]
        local _, max_aim = unit:GetBaseAimLevelRange(action, target)
        aim = Max(aim, Min(first, max_aim or first))
    end
    return aim
end

---- Shooter placed `tiles` in front of the target so the box projects as a frontal silhouette.
local function cth_at(unit, target, action, aim, tiles)
    local o = target.target_dummy or target
    local tpos = Rat_ValidZ(target:GetPos())
    local vpos = tpos + Rotate(point(tiles * const.SlabSizeX, 0, 0), o:GetOrientationAngle())
    return unit:CalcChanceToHit(target, action, {target_spot_group = "Torso", aim = aim,
        opportunity_attack = true, opportunity_attack_type = "Overwatch", step_pos = vpos, prediction = true, rat_exposed = 100}, "chance_only")
end

local function cth_color(cth)
    if cth < 50 then
        return RGB(255, MulDivRound(255, cth, 50), 0)
    end
    return RGB(MulDivRound(255, 100 - cth, 50), 255, 0)
end

local function ow_action(unit, ow)
    return unit:GetDefaultAttackAction("ranged", "ungrouped", nil, true, "ignore", {skip_ap_check = true})
        or CombatActions[ow.action_id]
end

local function draw_cone(unit, ow, target, lines)
    local action = ow_action(unit, ow)
    if not action then
        return
    end
    local aim = ow_aim(unit, ow, action, target)
    local center = Rat_ValidZ(ow.pos)
    local half = ow.cone_angle / 2
    local segs = Max(4, ow.cone_angle / (5 * 60))
    local row = {}
    for tiles = 1, ow.dist / const.SlabSizeX do
        local cth = cth_at(unit, target, action, aim, tiles)
        local color = cth_color(cth)
        local r = tiles * const.SlabSizeX
        local prev
        for i = 0, segs do
            local p = center + Rotate(point(r, 0, 0), ow.angle - half + MulDivRound(ow.cone_angle, i, segs))
            p = p:SetTerrainZ(300)
            if prev then
                DbgAddSegment(prev, p, color)
            end
            prev = p
        end
        local label = (center + Rotate(point(r, 0, 0), ow.angle)):SetTerrainZ(500)
        DbgAddText(cth .. "%", label, color)
        row[#row + 1] = string.format("%d:%d", tiles, cth)
    end
    lines[#lines + 1] = string.format("%s %s %s aim %d -> %s", tostring(unit.session_id),
        tostring(unit:GetActiveWeapons() and unit:GetActiveWeapons().class), action.id,
        (Rat_EffectiveAim(unit, action, aim, true, target)),
        table.concat(row, " "))
end

local function signature()
    local t = {}
    for unit, ow in pairs(g_Overwatch) do
        if IsValid(unit) then
            local target = ref_target(unit)
            t[#t + 1] = table.concat({unit.handle, tostring(ow.pos), ow.angle, ow.dist, ow.aim or 0,
                tostring(ow.weapon_id), unit.stance, target and target.handle or 0,
                target and tostring(target:GetPos()) or ""}, ",")
        end
    end
    return table.concat(t, ";")
end

local function redraw()
    DbgClearVectors()
    DbgClearTexts()
    local lines = {}
    for unit, ow in pairs(g_Overwatch) do
        local target = IsValid(unit) and not unit:IsDead() and ref_target(unit)
        if target then
            draw_cone(unit, ow, target, lines)
        end
    end
    return lines
end

function OWDebug(on)
    if on == nil then
        on = not enabled
    end
    enabled = on
    last_sig = false
    gen = gen + 1
    local my_gen = gen
    if not on then
        DbgClearVectors()
        DbgClearTexts()
        return "OWDebug off"
    end
    local lines = redraw()
    last_sig = signature()
    CreateRealTimeThread(function()
        while gen == my_gen do
            Sleep(1000)
            local sig = gen == my_gen and signature()
            if sig and sig ~= last_sig then
                last_sig = sig
                local ok, err = pcall(redraw)
                if not ok then
                    print("OWDebug:", err)
                end
            end
        end
    end)
    return "OWDebug on\n" .. (#lines > 0 and table.concat(lines, "\n") or "no overwatch with a standing reference unit")
end

local file_str = 'DESCRIPTION_HINTS_get.lua'

---- every Hint* value with a nil unit is the gun alone: no stat bonus or penalty (the grey bracket)
local HintNoStats = {placeholder = true, Marksmanship = 0, Dexterity = 0, Agility = 0, Strength = 0}
local HintFullStats = {placeholder = true, Marksmanship = 100, Dexterity = 100, Agility = 100, Strength = 100}

---- the caliber's kick at Strength 100 belongs to the gun; only the Strength penalty above it is the merc's
local function HintRecoil(weapon, attacker)
    local comps = IsACHTActive() and Rat_RecoilComponentsACTH() or nil
    local recoil = GetWepRecoil(weapon, attacker, true, comps) * GetCaliberStrRecoil(weapon, attacker or HintFullStats)
    if attacker then
        recoil = recoil * GetRecoilOther(weapon, attacker, false, nil, comps)
    end
    return cRound(recoil * 100)
end

---- aim 0 = hipfire, 1 = snapshot; Reflexes factor mirrors CTH_hipfire_and_snapshot.lua (classic)
---- and Rat_StepAttrMul (aCTH), which both scale the same step excess the weapon mul does
local function HintHipSnap(weapon, aim, unit, acth)
    local mul = GetWeaponHipfireOrSnapshotMul(weapon, false, false, true, aim)
    if acth then
        ---- bulk (negative Handling) rides on the step under BasePrecisionModel
        local v = MulDivRound(cRound(mul * 100), Rat_HandlingBulkStepMul(weapon, unit), 1000)
        return unit and MulDivRound(v, Rat_StepAttrMul(unit, nil, aim, nil, weapon), 100) or v
    elseif unit then
        mul = mul * (1.35 - 0.70 * rGetReflex(unit) / 100)
    end
    return cRound(mul * 100)
end

---- classic Hand-Eye scale, as % (CTH_aim.lua / CTH_pointblank.lua)
local function HintHandEyeScale(unit)
    local min, max = const.Combat.R_MinAimScaling, const.Combat.R_MaxAimScaling
    return Clamp(min + MulDivRound(max - min, rGetHandEyeCoordination(unit) - 10, 90), min, max)
end

---- Hand-Eye scaling mirrors CTH_pointblank.lua; a negative bonus scales inversely there
local function HintPB(weapon, unit)
    local pb = GetPBbonus(weapon)
    if not unit then
        return pb
    end
    local scale = HintHandEyeScale(unit)
    if pb < 0 then
        scale = 150 - scale
    end
    return MulDivRound(pb, scale, 100)
end

---- TEMPORARY legacy mode: 10000 - multiplier in basis points, so higher stays better for the bar
local function HintHandling(weapon, unit)
    if const.Combat.Aperture.HandlingLegacy then
        return 10000 - Rat_HandlingBaseMul(weapon, unit)
    end
    return (Rat_HandlingEffectivePoints(weapon, unit))
end

---- per-aim-level bonus in hundredths. Classic mirrors CTH_aim.lua; aCTH mirrors Rat_ApertureAimDecay,
---- whose closing is proportional to AimAccuracy x Hand-Eye while A.DecayBase is 0
local function HintAim(weapon, unit, acth)
    local acc = weapon.AimAccuracy * 100
    if acth then
        acc = MulDivRound(acc, GetApertureComponentAccMul(GetApertureAimComponentEffects(weapon, unit), 1), 100)
        return unit and MulDivRound(acc, Clamp(rGetHandEyeCoordination(unit), 10, 100), 100) or acc
    end
    if IsKindOfClasses(weapon, "Pistol", "Revolver") then
        acc = acc / 2
    end
    if GetComponentEffectValue(weapon, "ReduceAimAccuracy", "cth_penalty") then
        acc = acc / 2
    end
    if weapon:HasComponent("light_stock_aim_reduce") then
        acc = MulDivRound(acc, 90, 100)
    end
    return MulDivRound(MulDivRound(acc, unit and HintHandEyeScale(unit) or 100, 100), const.Combat.R_AimMul, 100)
end

---- classic aim is fractional per level; aCTH's is an integer stat
local function HintAimText(v, acth)
    if acth then
        return tostring(MulDivRound(v, 1, 100))
    end
    v = MulDivRound(v, 1, 10)
    return string.format("%d.%d", v / 10, v % 10)
end

---- Accuracy chart: CTH vs a standing target by distance, one curve per aim level
local HintChartTiles = 30
local HintChartHipLabel = ratT(file_str, 731590264418, "Hip")
local HintChartAimLabel = ratT(file_str, 731590264419, "Aim <num>")
local HintChartTitle = ratT(file_str, 731590264420, "Hit chance")
local HintChartSubtitle = ratT(file_str, 731590264427, "standing target")
local HintChartRefLabel = ratT(file_str, 731590264422, "Dashed: <name>")
local HintChartMainLabel = ratT(file_str, 731590264423, "Solid: <name>")
local HintChartModdedName = ratT(file_str, 731590264428, "With changes")
local HintChartCurrentName = ratT(file_str, 731590264429, "Current")
local HintChartXUnit = ratT(file_str, 731590264445, "tiles")
local HintRecoilTitle = ratT(file_str, 731590264437, "Recoil")
local HintRecoilSubtitle = ratT(file_str, 731590264439, "<mode>: hit chance if the 1st round always hits")
local HintRecoilRoundLabel = ratT(file_str, 731590264436, "Rd <num>")
local HintAimedTitle = ratT(file_str, 731590264440, "Aimed burst")
local HintAimedSubtitle = ratT(file_str, 731590264441, "<mode>, Aim <num>: hit chance of each round")
local HintAimedLevel = 3
local HintAimedBuckets = 8
local HintRecoilBurstLabel = ratT(file_str, 731590264442, "Burst")
local HintRecoilAutoLabel = ratT(file_str, 731590264443, "Auto")
local HintRecoilShotsLabel = ratT(file_str, 731590264444, "<num> rds")
---- the legend fits about ten round labels
local HintRecoilMaxShots = 10
---- recoil chart attack, shared by every chart and kept across openings; nil length = the gun's default
local HintRecoilMode = "burst"
local HintRecoilAutoShots
local HintChartColors = {RGB(214, 82, 62), RGB(232, 156, 60), RGB(226, 210, 90), RGB(130, 200, 110),
                         RGB(90, 190, 200), RGB(150, 140, 230), RGB(220, 220, 220)}

local HintChartStanceLabels = {
    Standing = ratT(file_str, 731590264424, "Shooting standing"),
    Crouch = ratT(file_str, 731590264425, "Shooting crouched"),
    Prone = ratT(file_str, 731590264426, "Shooting prone"),
}

---- stand-in shooter: UnitData has no GetActiveWeapons (nor a stance), so it and no owner chart standing
local function HintChartShooter(weapon, owner, stance)
    local src = owner or HintFullStats
    stance = stance or owner and HintChartStanceLabels[owner.stance] and owner.stance or "Standing"
    local s = {placeholder = false, stance = stance}
    for _, k in ipairs{"Marksmanship", "Dexterity", "Agility", "Strength", "Wisdom", "Explosives"} do
        s[k] = src[k] or 100
    end
    s.GetActiveWeapons = function() return weapon end
    ---- the recoil chain reads these for dual wield; the chart is always the gun alone
    s.GetEquippedWeaponSlot = function() return false end
    s.GetEquippedWeapons = function() return {weapon} end
    s.IsMerc = function() return true end
    s.GetLevel = function() return 1 end
    s.GetStatusEffect = function(_, id) return owner and owner.GetStatusEffect and owner:GetStatusEffect(id) end
    s.HasStatusEffect = function(_, id) return owner and owner.HasStatusEffect and owner:HasStatusEffect(id) end
    return s
end

---- the bipod is a residual on the cone in CalcChanceToHit, not part of the aperture
local function HintChartBipodMul(shooter, weapon)
    local _, bipod = Presets.ChanceToHitModifier.Default.Bipod:CalcValue(shooter, nil, nil, nil, weapon)
    return Rat_ConeMulForPoints(bipod or 0)
end

local function HintChartCurves(weapon, owner, stance)
    local a = const.Combat.Aperture
    local shooter = HintChartShooter(weapon, owner, stance)
    local bipod_mul = HintChartBipodMul(shooter, weapon)
    local curves = {stance = shooter.stance}
    for aim = 0, weapon.MaxAimActions or 3 do
        local sigma = MulDivRound(Rat_GetAperture(weapon, shooter, nil, aim), bipod_mul, 100)
        local pts = {}
        for d = 0, HintChartTiles do
            local theta = Rat_ThetaTarget(d * const.SlabSizeX, a.Silhouette.Standing)
            pts[d + 1] = Clamp(Rat_RayleighCTH(theta, sigma), a.MinCTH, a.MaxCTH)
        end
        curves[#curves + 1] = pts
    end
    return curves
end

local function HintChartLines(curves, left, bottom, w, h, px, dim)
    for i, pts in ipairs(curves) do
        ---- curves.first: the round the first curve plots, so round N keeps one color across charts
        local color = HintChartColors[Min(i + (curves.first or 1) - 1, #HintChartColors)]
        if dim then
            color = InterpolateRGB(color, RGB(30, 32, 30), 35, 100)
        end
        local prev, span = nil, Max(1, #pts - 1)
        for d, cth in ipairs(pts) do
            local pt = point(left + MulDivRound(w, d - 1, span), bottom - MulDivRound(h, cth, 100))
            ---- the reference gun is dashed: every other one-tile segment
            if prev and not (dim and d % 2 == 1) then
                UIL.DrawLineAntialised(px, prev, pt, color)
            end
            prev = pt
        end
    end
end

local function HintChartDraw(win)
    local curves, ref = win.rat_curves, win.rat_ref_curves
    if not curves and not win.rat_text_only then
        return
    end
    local font = TextStyles.PDABrowserTitleSmall:GetFontIdHeightBaseline(win.scale:y())
    local small = TextStyles.InventoryRolloverPropSmall:GetFontIdHeightBaseline(win.scale:y())
    local _, sh = UIL.MeasureText("Ag", small)
    local grid, label = RGB(62, 66, 62), RGB(150, 150, 150)
    local x0, y0 = win.content_box:minxyz()
    local cw, ch = win.content_box:sizexyz()
    local lw, fh = UIL.MeasureText("100%", font)
    local left, right = x0 + lw + 6, x0 + cw - 6
    local top, bottom = y0 + fh + sh + 6, y0 + ch - ((ref or win.rat_reserve_ref) and 3 or 2) * fh - 8
    local w, h = right - left, bottom - top
    local px = Max(2, MulDivRound(win.scale:x(), 3, 1000))
    local function text(str, x, y, color, f)
        f = f or font
        local tw, th = UIL.MeasureText(str, f)
        UIL.StretchText(str, box(x, y, x + tw, y + th), f, color)
        return tw
    end

    if win.rat_tabs then
        ---- clickable titles: active lit, hovered highlighted; boxes kept for the mouse handlers
        local x, gap = x0, UIL.MeasureText("    ", font)
        win.rat_tab_boxes = {}
        for i, t in ipairs(win.rat_tabs) do
            local str = _InternalTranslate(t)
            local tw = UIL.MeasureText(str, font)
            local b = box(x - 4, y0 - 2, x + tw + 4, y0 + fh)
            win.rat_tab_boxes[i] = b
            local active, hover = i == win.rat_tab, i == win.rat_tab_hover
            if active or hover then
                UIL.DrawSolidRect(b, RGBA(255, 255, 255, hover and 30 or 14))
            end
            text(str, x, y0, active and RGB(220, 220, 220) or hover and RGB(255, 222, 120) or RGB(110, 113, 118))
            x = x + tw + gap
        end
    else
        text(_InternalTranslate(win.rat_title or HintChartTitle), x0, y0, label)
    end
    ---- the effects tab: only the tabs, the text is a child window
    if win.rat_text_only then
        return
    end
    text(_InternalTranslate(win.rat_subtitle or HintChartSubtitle), x0, y0 + fh, label, small)
    if not win.rat_hide_stance then
        local stance = _InternalTranslate(HintChartStanceLabels[curves.stance])
        local sw = UIL.MeasureText(stance, font)
        if win.rat_stance_menu then
            ---- dropdown: chevron, and a highlight on hover so it reads as clickable
            local s = fh / 4
            local sx = x0 + cw - sw - 3 * s
            win.rat_stance_box = box(sx - 4, y0 - 2, x0 + cw + 2, y0 + fh + 2)
            local color = win.rat_stance_hover and RGB(255, 222, 120) or RGB(220, 220, 220)
            UIL.DrawSolidRect(win.rat_stance_box, win.rat_stance_hover and RGBA(255, 255, 255, 30) or RGBA(255, 255, 255, 10))
            text(stance, sx, y0, color)
            local cx, cy = x0 + cw - s, y0 + fh / 2
            UIL.DrawLineAntialised(px, point(cx - s, cy - s / 2), point(cx, cy + s / 2), color)
            UIL.DrawLineAntialised(px, point(cx, cy + s / 2), point(cx + s, cy - s / 2), color)
        else
            text(stance, x0 + cw - sw, y0, RGB(220, 220, 220))
        end
    elseif win.rat_controls then
        ---- right-aligned buttons: active lit, hovered highlighted, disabled dim; entries with no key are labels
        local gap = UIL.MeasureText("  ", font)
        local x = x0 + cw
        win.rat_control_boxes = {}
        for i = #win.rat_controls, 1, -1 do
            local c = win.rat_controls[i]
            local str = _InternalTranslate(c.text)
            local tw = UIL.MeasureText(str, font)
            x = x - tw
            local live = c.key and not c.disabled
            local hover = live and i == win.rat_control_hover
            if live then
                local b = box(x - 4, y0 - 2, x + tw + 4, y0 + fh)
                win.rat_control_boxes[i] = b
                UIL.DrawSolidRect(b, RGBA(255, 255, 255, hover and 30 or c.active and 14 or 6))
            end
            local lit = c.active or not c.key or (live and c.active == nil)
            text(str, x, y0, hover and RGB(255, 222, 120) or lit and RGB(220, 220, 220) or RGB(110, 113, 118))
            x = x - gap
        end
    end
    for pct = 0, 100, 25 do
        local y = bottom - MulDivRound(h, pct, 100)
        UIL.DrawLine(point(left, y), point(right, y), grid)
        if pct % 50 == 0 then
            local str = pct .. "%"
            text(str, left - 4 - UIL.MeasureText(str, font), y - fh / 2, label)
        end
    end
    ---- x is tiles from 0 on every chart
    local span, step, base = Max(1, #curves[1] - 1), win.rat_x_step or 10, win.rat_x_base or 0
    for d = 0, span, step do
        local x = left + MulDivRound(w, d, span)
        UIL.DrawLine(point(x, top), point(x, bottom), grid)
        local str = tostring(d + base)
        text(str, x - UIL.MeasureText(str, font) / 2, bottom + 2, label)
    end
    ---- axis unit, right-aligned just before the last tick label
    local last = tostring(span - span % step + base)
    local unit = _InternalTranslate(HintChartXUnit)
    local ux = left + MulDivRound(w, span - span % step, span) - UIL.MeasureText(last, font) / 2 - 6
    text(unit, ux - UIL.MeasureText(unit, small), bottom + 2 + (fh - sh) / 2, label, small)

    if ref then
        HintChartLines(ref, left, bottom, w, h, px, true)
    end
    HintChartLines(curves, left, bottom, w, h, px)

    local x = left
    for i = 1, #curves do
        local str = win.rat_legend and _InternalTranslate(win.rat_legend[i]) or
                        i == 1 and _InternalTranslate(HintChartHipLabel) or _InternalTranslate(T{HintChartAimLabel, num = i - 1})
        x = x + text(str, x, bottom + fh + 4, HintChartColors[Min(i + (curves.first or 1) - 1, #HintChartColors)]) + 10
    end
    if ref then
        local y = bottom + 2 * fh + 6
        x = left + text(_InternalTranslate(T{HintChartMainLabel, name = win.rat_name}), left, y, label) + 14
        text(_InternalTranslate(T{HintChartRefLabel, name = win.rat_ref_name}), x, y, label)
    end
end

---- declared so the debug build's PropertyObject member assert accepts the chart state
DefineClass.RatHintChart = {
    __parents = {"XWindow"},
    rat_curves = false, rat_ref_curves = false, rat_legend = false,
    rat_name = false, rat_ref_name = false, rat_title = false, rat_subtitle = false,
    rat_reserve_ref = false, rat_x_base = false, rat_x_step = false,
    rat_stance_menu = false, rat_stance_box = false, rat_stance_hover = false, rat_hide_stance = false,
    rat_tabs = false, rat_tab = false, rat_tab_boxes = false, rat_tab_hover = false,
    rat_controls = false, rat_control_boxes = false, rat_control_hover = false, rat_recoil_shots = false,
    rat_effects = false, rat_text_only = false,
}
DefineClass.RatHintContextChart = {__parents = {"XContextWindow", "RatHintChart"}}

---- chart window; `setup(self)` fills rat_curves (and rat_ref_curves) or returns false to hide
local function HintChartWindow(id, height, margins, setup)
    return PlaceObj("XTemplateWindow", {
        "__class", "RatHintContextChart",
        "Id", id,
        "Margins", margins,
        "MinHeight", height,
        "MaxHeight", height,
        "FoldWhenHidden", true,
    }, {
        PlaceObj("XTemplateFunc", {
            "name", "Open(self)",
            "func", function(self)
                XContextWindow.Open(self)
                ---- computed once here; DrawContent runs every frame
                if not IsACHTActive() or not setup(self) then
                    self:SetVisible(false)
                end
            end,
        }),
        PlaceObj("XTemplateFunc", {
            "name", "DrawContent(self, clip_box)",
            "func", function(self, clip_box)
                HintChartDraw(self)
            end,
        }),
    })
end

local function HintChartable(weapon)
    return IsKindOf(weapon, "Firearm") and not IsKindOf(weapon, "HeavyWeapon")
end

local function HintSameComponents(a, b)
    for slot, id in pairs(a.components) do
        if (b.components[slot] or "") ~= (id or "") then
            return false
        end
    end
    for slot, id in pairs(b.components) do
        if (a.components[slot] or "") ~= (id or "") then
            return false
        end
    end
    return true
end

---- Recoil chart: with no dispersion (round 1 always hits), the share of strings whose later rounds still land
local HintRecoilSamples = 96

---- the automatic modes this gun shows: selective burst (COMBAT_ACTIONS.lua UI gate), variable autofire
local function HintRecoilModes(weapon)
    local burst = table.find(weapon.AvailableAttacks or empty_table, "BurstFire") and Rat_HasSelectiveBurst(weapon) and
                      not (IsKindOf(weapon, "AR15") and not weapon:HasComponent("Enable_BurstFire"))
    return burst and true or false, Rat_HasVariableAuto(weapon) and true or false
end

---- the chosen mode, else the other one; autofire at the chosen string length
local function HintRecoilAttack(weapon)
    local burst, auto = HintRecoilModes(weapon)
    if burst and (HintRecoilMode == "burst" or not auto) then
        local action = CombatActions.BurstFire
        return action, weapon:GetAutofireShots(action)
    elseif auto then
        local id = Rat_AutoAttackId(weapon)
        local n = Clamp(HintRecoilAutoShots or weapon:GetAutofireShots(CombatActions[id]), 2, HintRecoilMaxShots)
        return Rat_AutoFireView(n, id), n
    end
end

---- `aimed`: every round's real CTH at Aim 3 (cone included); otherwise rounds 2+ with no cone
local function HintRecoilCurves(weapon, owner, stance, aimed)
    local action, shots = HintRecoilAttack(weapon)
    if not action or (shots or 0) < 2 then
        return
    end
    local a = const.Combat.Aperture
    local shooter = HintChartShooter(weapon, owner, stance)
    local prof = Rat_RecoilProfile(shooter, action, weapon, shots)
    if not prof then
        return
    end
    ---- same seeded walks as Rat_EstimateBurst (one seed per string); per round, every string's offset
    local seed = a.RecoilEstimateSeed or 1
    local st, offs = Rat_RecoilState(), {}
    for i = 1, shots do
        offs[i] = {}
    end
    for k = 1, HintRecoilSamples do
        local rnd = BraidRandomCreate(seed + k)
        st.px, st.py, st.vx, st.vy, st.cx, st.cy, st.n = 0, 0, 0, 0, 0, 0, 0
        for i = 1, shots do
            local _, _, r = Rat_RecoilPoint(st)
            table.insert(offs[i], r)
            Rat_RecoilStep(prof, st, rnd)
        end
    end
    local curves = {stance = shooter.stance, action = action, shots = shots}
    if aimed then
        local aim = Min(HintAimedLevel, weapon.MaxAimActions or HintAimedLevel)
        local sigma = Max(1, MulDivRound(Rat_GetAperture(weapon, shooter, action, aim), HintChartBipodMul(shooter, weapon), 100))
        local follow = Rat_FollowUpConeMul(weapon, shooter, action, aim, false, nil, shots)
        local sigma_f = follow and Max(1, MulDivRound(sigma, follow, 1000)) or sigma
        curves.aim = aim
        ---- CTH is smooth in the offset: sorted bucket means stand in for the samples at a fraction of the Rice calls
        local size = HintRecoilSamples / HintAimedBuckets
        for i = 1, shots do
            local list, buckets = offs[i], {}
            table.sort(list)
            for k = 0, HintAimedBuckets - 1 do
                local sum = 0
                for j = 1, size do
                    sum = sum + list[k * size + j]
                end
                buckets[k + 1] = MulDivRound(sum, 1, size)
            end
            ---- an unmoved muzzle (round 1) needs one evaluation, not eight
            offs[i] = buckets[1] == buckets[#buckets] and {buckets[1]} or buckets
            curves[i] = {}
        end
        for d = 0, HintChartTiles do
            local theta = Rat_ThetaTarget(d * const.SlabSizeX, a.Silhouette.Standing)
            for i = 1, shots do
                local sum = 0
                for _, r in ipairs(offs[i]) do
                    sum = sum + Rat_RiceCTH(theta, i > 1 and sigma_f or sigma, r)
                end
                curves[i][d + 1] = Clamp(MulDivRound(sum, 1, #offs[i]), a.MinCTH, a.MaxCTH)
            end
        end
        return curves
    end
    curves.first = 2
    for i = 2, shots do
        curves[i - 1] = {}
    end
    for d = 0, HintChartTiles do
        local theta = Rat_ThetaTarget(d * const.SlabSizeX, a.Silhouette.Standing)
        for i = 2, shots do
            local on = 0
            for _, r in ipairs(offs[i]) do
                on = on + (r <= theta and 1 or 0)
            end
            curves[i - 1][d + 1] = MulDivRound(on, 100, HintRecoilSamples)
        end
    end
    return curves
end

---- fills a chart window with the recoil curves; false when the gun has no automatic fire
local function HintRecoilSetup(win, weapon, owner, stance, aimed)
    local curves = HintChartable(weapon) and HintRecoilCurves(weapon, owner, stance, aimed)
    if not curves then
        return false
    end
    local first = curves.first or 1
    win.rat_curves, win.rat_legend = curves, {}
    for i = first, curves.shots do
        win.rat_legend[i - first + 1] = T{HintRecoilRoundLabel, num = i}
    end
    win.rat_title = aimed and HintAimedTitle or HintRecoilTitle
    win.rat_subtitle = aimed and T{HintAimedSubtitle, mode = curves.action.DisplayName, num = curves.aim}
                           or T{HintRecoilSubtitle, mode = curves.action.DisplayName}
    return true
end

---- Shift-compare: own panel right of both rollovers, hovered gun solid and equipped gun dashed
local function HintCompareChart(dlg)
    local list, item = dlg.compare_wnd[#dlg.compare_wnd], dlg.compare_wnd.item
    if not IsACHTActive() or not list or not HintChartable(item) then
        return
    end
    local ref
    for _, o in ipairs(dlg.compare_wnd.other or empty_table) do
        ref = ref or HintChartable(o) and o
    end
    if not ref then
        return
    end
    ---- same frame as RolloverInventoryWeaponBase
    local panel = XWindow:new({
        Margins = box(10, 0, 0, 0),
        Padding = box(6, 6, 6, 6),
        VAlign = "top",
        MinWidth = 350,
        MaxWidth = 350,
        Background = RGBA(52, 55, 61, 255),
        BackgroundRectGlowSize = 2,
        BackgroundRectGlowColor = RGBA(32, 35, 47, 255),
        LayoutMethod = "VList",
        LayoutVSpacing = 10,
    }, list)
    local unit = GetInventoryUnit()
    local function chart()
        local win = RatHintChart:new({MinHeight = 290, MaxHeight = 290}, panel)
        win.DrawContent = HintChartDraw
        win.rat_name, win.rat_ref_name = item.DisplayName, ref.DisplayName
        return win
    end
    local acc = chart()
    acc.rat_curves, acc.rat_ref_curves = HintChartCurves(item, unit), HintChartCurves(ref, unit)
    ---- aimed burst below when the hovered gun has automatic fire; dashed only if the other one does too
    local recoil = HintRecoilCurves(item, unit) and chart()
    if recoil then
        HintRecoilSetup(recoil, item, unit, nil, true)
        recoil.rat_ref_curves = HintRecoilCurves(ref, unit, nil, true)
        recoil.rat_reserve_ref = true
    end
    panel:Open()
end

local function HintWrapOpenCompare()
    local path = FindXtByProp(XTemplates.Inventory, "name", "OpenCompare(self, item_wnd, item)")
    if not path then
        return
    end
    local node = path[1]
    ---- kept on the node so a Lua reload doesn't wrap the wrapper
    node.rat_vanilla_func = node.rat_vanilla_func or node.func
    local vanilla = node.rat_vanilla_func
    node.func = function(self, item_wnd, item)
        local ok = vanilla(self, item_wnd, item)
        if ok then
            HintCompareChart(self)
        end
        return ok
    end
end

---- Revised Tactical Gear II rebuilds the Inventory template in its own DataLoaded, after ours
function OnMsg.ModsReloaded()
    HintWrapOpenCompare()
end

---- modify dialog stance, kept across openings; nil follows the owner
local HintModChartStance
---- modify dialog recoil tab, kept across openings: 1 recoil alone, 2 aimed burst
local HintModRecoilTab = 2
---- modify dialog top tab, kept across openings: 1 hit chance, 2 the vanilla combined effects text
local HintModAccTab = 1
local HintModEffectsTitle = ratT(file_str, 731590264446, "Effects")
---- the vanilla "extra stat stuff" template node, spawned inside the chart on the effects tab
local HintModEffectsNode

local function HintBoxHas(b, pos)
    return b and pos:x() >= b:minx() and pos:x() <= b:maxx() and pos:y() >= b:miny() and pos:y() <= b:maxy()
end

local function HintStanceMenu(win, dlg)
    local popup = XPopup:new({
        AnchorType = "drop-right",
        Background = RGBA(32, 35, 47, 245),
        ---- a focused XControl draws these instead, and their defaults are light
        FocusedBackground = RGBA(32, 35, 47, 245),
        BorderWidth = 1,
        BorderColor = RGB(90, 94, 100),
        FocusedBorderColor = RGB(90, 94, 100),
        Padding = box(2, 2, 2, 2),
        LayoutMethod = "VList",
    }, dlg)
    popup:SetZOrder(1000)
    popup:SetAnchor(win.rat_stance_box)
    for _, stance in ipairs{"Standing", "Crouch", "Prone"} do
        XTextButton:new({
            Text = HintChartStanceLabels[stance],
            Translate = true,
            TextStyle = "PDABrowserTitleSmall",
            Padding = box(10, 4, 10, 4),
            Background = RGBA(0, 0, 0, 0),
            FocusedBackground = RGBA(0, 0, 0, 0),
            RolloverBackground = RGBA(255, 255, 255, 35),
            PressedBackground = RGBA(255, 255, 255, 60),
            OnPress = function()
                HintModChartStance = stance
                popup:Close()
                dlg:UpdateWeaponProps()
            end,
        }, popup)
    end
    popup:Open()
    popup:SetFocus()
end

---- recoil chart header: the mode switch when the gun has both, and the string length on autofire
local function HintRecoilControls(weapon)
    local burst, auto = HintRecoilModes(weapon)
    local action, shots = HintRecoilAttack(weapon)
    local is_auto = action and action.id ~= "BurstFire"
    local list = {}
    if burst and auto then
        list[#list + 1] = {text = HintRecoilBurstLabel, key = "burst", active = not is_auto}
        list[#list + 1] = {text = HintRecoilAutoLabel, key = "auto", active = is_auto}
    end
    if is_auto then
        list[#list + 1] = {text = Untranslated("-"), key = "less", disabled = shots <= 2}
        list[#list + 1] = {text = T{HintRecoilShotsLabel, num = shots}}
        list[#list + 1] = {text = Untranslated("+"), key = "more", disabled = shots >= HintRecoilMaxShots}
    end
    return #list > 0 and list or false, shots
end

local function HintRecoilControlPress(key, shots)
    if key == "burst" or key == "auto" then
        HintRecoilMode = key
    elseif key == "less" or key == "more" then
        HintRecoilAutoShots = Clamp(shots + (key == "more" and 1 or -1), 2, HintRecoilMaxShots)
    end
end

---- modify dialog charts: the clone (hovered/placed parts) solid, the real gun dashed once they differ
local function HintModifyChart(id, recoil, height)
    return PlaceObj("XTemplateWindow", {
        "__class", "RatHintChart",
        "Id", id,
        "Margins", box(0, 8, 0, 0),
        "Padding", box(8, 6, 8, 6),
        "HAlign", "right",
        "MinWidth", 480,
        "MaxWidth", 480,
        "MinHeight", height,
        "MaxHeight", height,
        "FoldWhenHidden", true,
        "HandleMouse", true,
        "Background", RGBA(32, 35, 47, 215),
    }, {
        PlaceObj("XTemplateFunc", {
            "name", "OnMouseButtonDown(self, pos, button)",
            "func", function(self, pos, button)
                if button ~= "L" then
                    return
                end
                if self.rat_stance_menu and HintBoxHas(self.rat_stance_box, pos) then
                    HintStanceMenu(self, self:ResolveId("node"):ResolveId("node"))
                    return "break"
                end
                for i, b in ipairs(self.rat_tabs and self.rat_tab_boxes or empty_table) do
                    if i ~= self.rat_tab and HintBoxHas(b, pos) then
                        if recoil then
                            HintModRecoilTab = i
                        else
                            HintModAccTab = i
                        end
                        self:UpdateValue()
                        return "break"
                    end
                end
                for i, b in pairs(self.rat_controls and self.rat_control_boxes or empty_table) do
                    if HintBoxHas(b, pos) then
                        HintRecoilControlPress(self.rat_controls[i].key, self.rat_recoil_shots)
                        self:UpdateValue()
                        return "break"
                    end
                end
            end,
        }),
        PlaceObj("XTemplateFunc", {
            "name", "OnMousePos(self, pos)",
            "func", function(self, pos)
                local hover = self.rat_stance_menu and HintBoxHas(self.rat_stance_box, pos) or false
                local tab, control = false, false
                for i, b in ipairs(self.rat_tabs and self.rat_tab_boxes or empty_table) do
                    tab = tab or i ~= self.rat_tab and HintBoxHas(b, pos) and i
                end
                for i, b in pairs(self.rat_controls and self.rat_control_boxes or empty_table) do
                    control = control or HintBoxHas(b, pos) and i
                end
                if hover ~= self.rat_stance_hover or tab ~= self.rat_tab_hover or control ~= self.rat_control_hover then
                    self.rat_stance_hover, self.rat_tab_hover, self.rat_control_hover = hover, tab, control
                    self:Invalidate()
                end
            end,
        }),
        PlaceObj("XTemplateFunc", {
            "name", "OnMouseLeft(self, pos, child)",
            "func", function(self, pos, child)
                if self.rat_stance_hover or self.rat_tab_hover or self.rat_control_hover then
                    self.rat_stance_hover, self.rat_tab_hover, self.rat_control_hover = false, false, false
                    self:Invalidate()
                end
            end,
        }),
        PlaceObj("XTemplateFunc", {
            "name", "Open(self)",
            "func", function(self)
                if not recoil and HintModEffectsNode then
                    ---- EvalElement skips the node's __condition, which hides it from the vanilla spot
                    local text = HintModEffectsNode:EvalElement(self, self.context)
                    self.rat_effects = text
                    ---- 80% of the vanilla 20px style, which has no smaller twin; margins and widths scale too
                    text:SetScaleModifier(point(800, 800))
                    text:SetMargins(box(0, 42, 0, 0))
                    text:SetMinWidth(580)
                    text:SetMaxWidth(580)
                    text:SetFoldWhenHidden(true)
                end
                XWindow.Open(self)
                ---- idWeaponProps respawns after the dialog's own UpdateWeaponProps call
                self:UpdateValue()
            end,
        }),
        PlaceObj("XTemplateFunc", {
            "name", "UpdateValue(self, anyModified)",
            "func", function(self, anyModified)
                local dlg = self:ResolveId("node"):ResolveId("node")
                local clone, real = dlg and dlg.weaponClone, dlg and dlg.context and dlg.context.weapon
                if not IsACHTActive() or not HintChartable(clone) or not real or recoil and not HintRecoilAttack(clone) then
                    self:SetVisible(false)
                    return
                end
                local id = dlg.context.owner
                local owner = id and (g_Units[id] or gv_UnitData[id])
                local differ = not HintSameComponents(clone, real)
                local stance = HintModChartStance
                if recoil then
                    local aimed = HintModRecoilTab == 2
                    self.rat_tabs, self.rat_tab = {HintRecoilTitle, HintAimedTitle}, HintModRecoilTab
                    self.rat_controls, self.rat_recoil_shots = HintRecoilControls(clone)
                    HintRecoilSetup(self, clone, owner, stance, aimed)
                    self.rat_ref_curves = differ and HintRecoilCurves(real, owner, stance, aimed) or nil
                    ---- one stance control for both charts, on the top one
                    self.rat_hide_stance = true
                else
                    local effects = self.rat_effects
                    self.rat_tabs = effects and {HintChartTitle, HintModEffectsTitle}
                    self.rat_tab = HintModAccTab
                    self.rat_text_only = effects and HintModAccTab == 2
                    if effects then
                        effects:SetVisible(self.rat_text_only)
                        ---- the text grows the panel; the plot keeps its fixed height
                        self:SetMaxHeight(self.rat_text_only and 1000000 or height)
                        if self.rat_text_only then
                            effects:UpdateValue(anyModified or effects:HasValueChanged())
                        end
                    end
                    self.rat_hide_stance = self.rat_text_only
                    if not self.rat_text_only then
                        self.rat_curves = HintChartCurves(clone, owner, stance)
                        self.rat_ref_curves = differ and HintChartCurves(real, owner, stance) or nil
                    end
                    self.rat_stance_menu = not self.rat_text_only
                end
                ---- the Solid/Dashed row keeps its space so hovering a part never resizes the plot
                self.rat_reserve_ref = true
                self.rat_name, self.rat_ref_name = HintChartModdedName, HintChartCurrentName
                self:SetVisible(true)
                self:Invalidate()
            end,
        }),
        PlaceObj("XTemplateFunc", {
            "name", "DrawContent(self, clip_box)",
            "func", function(self, clip_box)
                HintChartDraw(self)
            end,
        }),
    })
end

---- mirrors ChangeWeapon.GetAPCost for this gun alone, in displayed AP
local function HintSwapAP(weapon)
    if IsKindOf(weapon, "HeavyWeapon") then
        return MulDivRound(R_VanillaAP(4), 1, const.Scale.AP)
    end
    local ap = weapon.Rat_swap_ap or 0
    if weapon:HasComponent("FreeWeaponSwap") then
        ap = Max(0, ap - 20)
    end
    if (IsKindOfClasses(weapon, "Pistol", "Revolver") or weapon.pistol_swap) and ap < 20 then
        return 0
    end
    return ap
end

---- the weapon-only half of the fire modes' GetUIState (COMBAT_ACTIONS.lua): modes the gun lacks
local function HintAttackHidden(weapon, id)
    if not IsKindOf(weapon, "Firearm") then
        return false
    end
    if id == "BurstFire" then
        return not Rat_HasSelectiveBurst(weapon) or
                   (IsKindOf(weapon, "AR15") and not weapon:HasComponent("Enable_BurstFire"))
    elseif id == "SingleShot" then
        return weapon.AutoFireOnly
    elseif id == "MobileShot" then
        return weapon.AutoFireOnly and table.find(weapon.AvailableAttacks or empty_table, "RunAndGun")
    end
    return false
end

---- whose AP an attack is priced with: the owner, else the merc whose inventory is open.
---- GetAPCost needs a spawned Unit, so UnitData (satellite view, unit off map) gets nil
local function HintAPUnit(owner_id)
    local id = owner_id or (GetInventoryUnit() or SelectedObj or empty_table).session_id
    local unit = id and g_Units[id]
    return IsKindOf(unit, "Unit") and unit or nil
end

local HintMechanismLabel =ratT(file_str, 285374032193, "Operation")
local HintCyclingLabel = ratT(file_str, 608246246045, "Action")
local HintBurstCritLabel = ratT(file_str, 318826540130, "Selective Burst Critical Chance")
local HintAutoCritLabel = ratT(file_str, 318826540131, "Autofire Critical Chance")
local HintBurstRecoilLabel = ratT(file_str, 318826540123, "Selective Burst Recoil Penalty")
local HintAutoRecoilLabel = ratT(file_str, 318826540122, "Autofire Recoil Penalty")
local HintLongRecoilLabel = ratT(file_str, 318826540124, "Long Burst Recoil Penalty")
local HintHandlingStandLabel = ratT(file_str, 318826540125, "Standing Acc. Penalty")
local HintHandlingCrouchLabel = ratT(file_str, 318826540126, "Crouched Acc. Penalty")
---- keyed without underscores: recoil_mechanism spells "Bolt_Action", Rat_cycling "BoltAction"
local HintMechanismNames = {
    GasOperated = ratT(file_str, 541468575245, "Gas Operated"),
    RecoilOperated = ratT(file_str, 372078613063, "Recoil Operated"),
    ShortRecoil = ratT(file_str, 951379947642, "Short Recoil"),
    RollerDelayed = ratT(file_str, 545422117275, "Roller-Delayed Blowback"),
    Blowback = ratT(file_str, 248357646755, "Blowback"),
    StrikerFired = ratT(file_str, 449197275880, "Striker Fired"),
    Revolver = ratT(file_str, 203993894214, "Revolver"),
    SingleShot = ratT(file_str, 305432457434, "Single Shot"),
    BreakAction = ratT(file_str, 134961306884, "Break Action"),
    PumpAction = ratT(file_str, 248130161322, "Pump Action"),
    BoltAction = ratT(file_str, 979693802164, "Bolt Action"),
    LeverAction = ratT(file_str, 387632024720, "Lever Action"),
    SingleAction = ratT(file_str, 747722846624, "Single Action"),
    DoubleAction = ratT(file_str, 949408355343, "Double Action"),
    SADoubleAction = ratT(file_str, 285374032194, "Single/Double Action"),
    SemiAuto = ratT(file_str, 608246246046, "Semi-Automatic"),
    Auto = ratT(file_str, 541468575246, "Automatic"),
}

---- one ammo's modifiers on the gun's own value, stacked the way Firearm:Reload adds them
local function HintAmmoProp(value, ammo, prop)
    for _, mod in ipairs(ammo and ammo.Modifications or empty_table) do
        if mod.target_prop == prop then
            value = MulDivRound(value, mod.mod_mul, 1000) + mod.mod_add
        end
    end
    return value
end

local function HintAmmoPellets(w, ammo)
    local n = HintAmmoProp(w.NumPellets or 0, ammo, "NumPellets")
    return n > 1 and n or nil
end

local function HintStanceAP(weapon, unit)
    unit = unit or HintNoStats
    return MulDivRound(GetWeapon_StanceAP(unit, weapon, true), 1, const.Scale.AP) +
               MulDivRound(Get_AimCost(unit), 1, const.Scale.AP)
end

---- manual cycle AP after a shot, Dexterity-reduced; nil when the gun cycles itself.
---- double_action: firing without cycling, which rat_get_manual_cyclingAP caps at the manual cost
local function HintCycleAP(weapon, unit, double_action)
    local da = weapon:HasComponent("DASA_action_ap")
    if double_action and not da or not (da or weapon:HasComponent("bolt_action_ap")) then
        return
    end
    return MulDivRound(rat_get_manual_cyclingAP(unit, weapon, double_action), 1, const.Scale.AP)
end

local function HintCritPerAim(weapon, unit)
    return MulDivRound(Rat_WeaponCritPerAim(weapon), unit and rGetHandEyeCoordination(unit) or 100, 100)
end

local function HintHundredths(v)
    local sign = v < 0 and "-" or ""
    v = abs(v)
    return string.format("%s%d.%02d", sign, v / 100, v % 100)
end

local function HintHandlingText(v)
    if const.Combat.Aperture.HandlingLegacy then
        return HintHundredths(MulDivRound(10000 - v, 1, 100)) .. "X"
    end
    return v
end

---- value in the panel's value style, units muted like vanilla's " AP"
local function HintMulText(v, extra)
    return HintHundredths(v) .. "<style PDABrowserTitleSmall>x" .. (extra or "") .. "</style>"
end

---- the Recoil row times the fire mode's own factors in GetRecoilOther; stance left out so the hint stays put
local function HintModeRecoil(weapon, unit, delta_prop, bump)
    local net = MulDivRound(HintRecoil(weapon, unit), weapon[delta_prop] or 100, 100)
    if bump and weapon:HasComponent("recoil_bump") then
        ---- an added bump stock is priced by the aCTH table, a factory one keeps the shared value
        local acth = IsACHTActive() and not Rat_FactoryRecoilEffects(weapon).recoil_bump
        net = cRound(net * (acth and Rat_RecoilComponentsACTH() or const.Combat.Recoil.Components).RecoilBumpMul)
    end
    if unit and unit:HasStatusEffect("AutoWeapons") then
        net = cRound(net * const.Combat.Recoil.Perks.AutoWeaponsMul)
    end
    return net
end

function Rat_HasBarrelRule(weapon)
    return (weapon.rat_barrel_len or 0) > 0 and Rat_CaliberDamage(weapon.Caliber) ~= nil
end

---- bar value of each row for the preset scan, taken for the gun alone and for a stat-100 merc; `range`
---- skips the scan and `ammo` rows scan every ammo of the caliber instead of the Basic one.
---- lower = smaller is better, which only picks the gap color: bars always grow with the value, like vanilla
local HintBarRows = {
    Pellets = {ammo = HintAmmoPellets},
    Spread = {lower = true, ammo = function(w, ammo)
        return HintAmmoPellets(w, ammo) and HintAmmoProp(w.BuckshotConeAngle or 0, ammo, "BuckshotConeAngle")
    end},
    RecStr = {lower = true, range = {30, 100}},
    Penetration = {range = {0, 5}},
    StanceAP = {lower = true, value = HintStanceAP},
    CycleAP = {lower = true, value = HintCycleAP},
    ---- scan-only: double action shares the cycling bar, so its costs widen that range
    CycleDA = {into = "CycleAP", value = function(w, unit) return HintCycleAP(w, unit, true) end},
    Angle = {value = function(w) return w:GetProperty("OverwatchAngle") end},
    Reliability = {value = function(w) return w.Reliability end},
    Noise = {lower = true, value = function(w) return w.Noise end},
    ---- every ammo of the caliber, so HP/AP modifiers land inside the range
    Crit = {ammo = function(w, ammo) return HintAmmoProp(w.CritChance, ammo, "CritChance") end},
    CritPerAim = {value = HintCritPerAim},
    CritDamage = {ammo = function(w, ammo) return HintAmmoProp(w.CritDamage, ammo, "CritDamage") end},
    AimAccuracy = {value = function(w, unit) return HintAim(w, unit, IsACHTActive()) end},
    PB = {value = HintPB},
    Handling = {value = HintHandling},
    Hipfire = {lower = true, value = function(w, unit) return HintHipSnap(w, 0, unit, IsACHTActive()) end},
    Snapshot = {lower = true, value = function(w, unit) return HintHipSnap(w, 1, unit, IsACHTActive()) end},
    Recoil = {lower = true, value = HintRecoil},
    RPM = {value = function(w) return w.RPM or 0 end, applies = function(w) return Rat_HasVariableAuto(w) end},
    Barrel = {value = function(w) return Rat_EffectiveBarrelLength(w) end, applies = function(w) return Rat_HasBarrelRule(w) end},
    CaliberDamage = {ammo = function(w, ammo)
        local base = Rat_CaliberDamage(w.Caliber)
        return base and HintAmmoProp(base, ammo, "Damage")
    end},
}

---- headroom past the stock extremes, since components push values beyond them
local HintBarPadPct = 15
local HintBarRanges

---- scans every firearm preset once per session
local function GetHintBarRanges()
    if HintBarRanges then
        return HintBarRanges
    end
    local lo, hi = {}, {}
    local function widen(id, v)
        lo[id] = Min(lo[id] or v, v)
        hi[id] = Max(hi[id] or v, v)
    end
    ForEachPreset("InventoryItemCompositeDef", function(preset)
        local class = g_Classes[preset.id]
        ---- unpatched presets keep raw values and would stretch every range
        if not Rat_IsLiveFirearm(class) or IsKindOf(class, "HeavyWeapon") then
            return
        end
        local w = PlaceInventoryItem(preset.id)
        ---- ammo rows read the unloaded gun, before the Basic modifiers below
        for _, def in ipairs(w.Caliber and GetAmmosWithCaliber(w.Caliber) or empty_table) do
            for id, row in pairs(HintBarRows) do
                local v = row.ammo and row.ammo(w, g_Classes[def.id])
                if v then
                    widen(id, v)
                end
            end
        end
        ---- loaded, since caliber noise (CaliberApplyParams) lives on the ammo, not the gun
        local ammo = Rat_BasicAmmoClass(w)
        ---- same modifiers Firearm:Reload adds, without spawning ammo items
        for _, mod in ipairs(ammo and ammo.Modifications or empty_table) do
            w:AddModifier("ammo", mod.target_prop, mod.mod_mul, mod.mod_add)
        end
        for id, row in pairs(HintBarRows) do
            if row.value and (not row.applies or row.applies(w)) then
                for _, unit in ipairs{false, HintFullStats} do
                    local ok, v = pcall(row.value, w, unit or nil)
                    if ok and v then
                        widen(row.into or id, v)
                    end
                end
            end
        end
        DoneObject(w)
    end)
    HintBarRanges = {}
    for id in pairs(lo) do
        local pad = Max(1, MulDivRound(hi[id] - lo[id], HintBarPadPct, 100))
        HintBarRanges[id] = {lo[id] - pad, hi[id] + pad}
    end
    return HintBarRanges
end

---- ~150ms: run it behind the loading screen instead of on the first hover
function OnMsg.NewMapLoaded()
    GetHintBarRanges()
end

local function HintBarFrac(id, v)
    local r = HintBarRows[id] and HintBarRows[id].range or GetHintBarRanges()[id]
    if not r or not v then
        return
    end
    return Clamp(MulDivRound(v - r[1], 1000, r[2] - r[1]), 0, 1000)
end

---- 4 segment images + 3 dividers per bar from tools/gen_hint_bars.py, which holds every colour. XText
---- truncates each <image> to whole pixels, so a fixed image count keeps rows equal at any UI scale
local HintBarSeg, HintBarSegs = 10, 4
local HintBarImg = "Mod/cfahRED/Images/HintBar/"

---- ref is the gun alone. The span between it and the owner's value is red when worse, green when
---- better; solid when the owner raises the value, hatched when the owner lowers it
local function HintBar(id, v, ref)
    local fv = HintBarFrac(id, v)
    if not fv then
        return "<image " .. HintBarImg .. "blank.png 1000>"
    end
    local fr = HintBarFrac(id, ref) or fv
    local lower = HintBarRows[id].lower
    local worse = (lower and fv > fr) or (not lower and fv < fr)
    local kind = (worse and "_w" or "_b") .. (fv < fr and "h" or "s")
    local total = HintBarSeg * HintBarSegs
    local lo, hi = MulDivRound(total, Min(fv, fr), 1000), MulDivRound(total, Max(fv, fr), 1000)
    local s = ""
    for i = 0, HintBarSegs - 1 do
        local a = i * HintBarSeg
        local f = Clamp(lo - a, 0, HintBarSeg)
        local r = Clamp(hi - a, 0, HintBarSeg) - f
        s = s .. (i > 0 and "<image " .. HintBarImg .. "div.png 1000>" or "") ..
                "<image " .. HintBarImg .. "b" .. f .. "_" .. r .. (r > 0 and kind or "") .. ".png 1000>"
    end
    return s
end

---- term = {label, value, suffix, bar =, bar_v =, bar_ref =, base =}; base is the grey reference
local function HintLine(term)
    local bar_ref = term.bar_ref or (type(term.base) == "number" and term.base)
    return HintBar(term.bar, term.bar_v or term[2], bar_ref) .. "  " ..
               "<color PDABrowserFlavorMedium>" .. term[1] .. "</color>" ..
               "<color PDABrowserTextHighlight>" .. term[2] .. "</color>" .. term[3] ..
               ((term.base and term.base ~= term[2]) and ("<color PDABrowserFlavor> (" .. term.base .. term[3] .. ")</color>") or "") ..
               "\n"
end

---- caliber stats live on the ammo; an unloaded gun shows its caliber's Basic ammo values
function Rat_BasicAmmoProp(weapon, prop)
    local value = weapon[prop]
    if not IsKindOf(weapon, "Firearm") or weapon.ammo then
        return value
    end
    return HintAmmoProp(value, Rat_BasicAmmoClass(weapon), prop)
end

function Rat_DisplayPenetrationClass(weapon)
    return Clamp(Rat_BasicAmmoProp(weapon, "PenetrationClass"), 1, #PenetrationClassIds)
end

---- caliber stats, shared by the weapon rollover's ammo panel and the ammo item rollover.
---- A row reads `prop` through the ammo, or `value(item)`; `show(v)` hides it, `ammo_only` skips the gun rollover
local CaliberHintRows = {
    ---- the gun shows its own barrel-adjusted Damage; the round shows the caliber's at its reference barrel
    {tid = 531760248906, text = "Base damage: ", ammo_only = true, bar = "CaliberDamage",
     value = function(item)
         local base = Rat_CaliberDamage(item.Caliber)
         return base and HintAmmoProp(base, item, "Damage")
     end,
     note = function(item) return " @ " .. const.CaliberDamage[item.Caliber].barrel .. " mm" end},
    ---- ammo adds to the gun's class, and every gun carries the Firearm default
    {tid = 531760248907, text = "Armor penetration: ", ammo_only = true, bar = "Penetration",
     value = function(item)
         return Clamp(HintAmmoProp(Firearm.PenetrationClass, item, "PenetrationClass"), 1, #PenetrationClassIds)
     end,
     display = function(v) return _InternalTranslate(GetPenetrationClassUIText(v)) end},
    {tid = 684546854913, text = "Base critical chance: ", prop = "CritChance", suffix = "%", bar = "Crit"},
    {tid = 247182652462, text = "Extra critical damage: ", prop = "CritDamage", suffix = "%", bar = "CritDamage"},
    {tid = 158466723759, text = "Recommended Strength: ", value = function(item) return (Recoil_StrBreakpoint(item)) end,
     suffix_tid = 785975283217, suffix = " STR", bar = "RecStr"},
    ---- slugs load 0 pellets; a lone ammo item has no gun to multiply
    {tid = 719583632117, text = "Number of Pellets: ", prop = "NumPellets", suffix = "", bar = "Pellets",
     show = function(v) return v > 1 end},
}

---- a Firearm reads its loaded (or Basic) ammo on its own stats; an Ammo item shows its modifiers on a zero base
local function CaliberHintValue(item, row)
    if row.value then
        return row.value(item)
    end
    if IsKindOf(item, "Ammo") then
        return HintAmmoProp(0, item, row.prop)
    end
    return Rat_BasicAmmoProp(item, row.prop)
end

function Rat_GetCaliberHints(item)
    if not IsKindOfClasses(item, "Firearm", "Ammo") then
        return ""
    end
    local s = ""
    local is_ammo = IsKindOf(item, "Ammo")
    for _, row in ipairs(CaliberHintRows) do
        local v
        if row.ammo_only then
            v = is_ammo and CaliberHintValue(item, row)
        else
            v = CaliberHintValue(item, row) or 0
        end
        if v and (not row.show or row.show(v)) then
            local suffix = row.suffix_tid and TranslationTable[row.suffix_tid] or row.suffix or ""
            if row.note then
                suffix = suffix .. "<color PDABrowserFlavor>" .. row.note(item) .. "</color>"
            end
            s = s .. HintLine{TranslationTable[row.tid] or row.text, row.display and row.display(v) or v, suffix,
                              bar = row.bar, bar_v = v}
        end
    end
    return T{"<style CrosshairAPTotal>" .. s:sub(1, -2) .. "</style>"}
end

local function SetTemplateFunc(node, name, func)
    for _, child in ipairs(node) do
        if child.name == name then
            child.func = func
            return
        end
    end
end

local WeaponRolloverWidth = 470

---- our ToggleOptions wrapper, so a second patch run does not wrap it again
local HintToggleOptions

---- the shop grid's PEN column reads the empty gun too
local BobbyRayStoreGetStats_Firearm_vanilla = BobbyRayStoreGetStats_Firearm
function BobbyRayStoreGetStats_Firearm(item)
    local stats = BobbyRayStoreGetStats_Firearm_vanilla(item)
    for _, stat in ipairs(stats) do
        if TGetID(stat[1]) == 842354777573 then
            stat[2] = GetPenetrationClassUIText(Rat_DisplayPenetrationClass(item))
        ---- vanilla CRIT is CritChance + level-scaled CritChanceScaled, which crit no longer reads
        elseif TGetID(stat[1]) == 921500948697 then
            stat[1] = ratT(file_str, 921500948698, "CRIT/AIM")
            stat[2] = Untranslated(HintHundredths(HintCritPerAim(item)) .. "%")
        elseif TGetID(stat[1]) == 788999452116 then
            local acth = IsACHTActive()
            stat[1] = ratT(file_str, 921500948699, "AIM")
            stat[2] = Untranslated(HintAimText(HintAim(item, nil, acth), acth))
        end
    end
    return stats
end

function Rat_PatchWeaponRollover()
    ---- vanilla caps the weapon rollover at 370, which wraps every barred hint line
    local path = FindXtByProp(XTemplates.RolloverInventoryWeaponBase, "Id", "idContent")
    if path then
        path[1].MaxWidth = WeaponRolloverWidth
    end
    ---- Bobby Ray wraps the same rollover in its own 350 cap
    path = FindXtByProp(XTemplates.RolloverInventoryBobbyRay, "__template", "RolloverInventoryWeapon")
    if path then
        path[1].MaxWidth = WeaponRolloverWidth
    end
    ---- header AP: vanilla shows the raw ShootAP/AttackAP; price the default attack like the More Info list
    path = FindXtByProp(XTemplates.RolloverInventoryWeaponBase, "comment", "ap indicator")
    if path then
        local node = path[1]
        node.rat_vanilla_update = node.rat_vanilla_update or node.OnContextUpdate
        local vanilla_update = node.rat_vanilla_update
        node.OnContextUpdate = function(self, context, ...)
            local weapon = ResolvePropObj(self.context)
            local unit = IsKindOf(weapon, "Firearm") and HintAPUnit(weapon.owner)
            local action = unit and CombatActions[weapon:GetBaseAttack(unit, true)]
            local ap = action and action:GetAPCost(unit, {weapon = weapon})
            if not ap or ap == -1 then
                return vanilla_update(self, context, ...)
            end
            self:SetText(T{519320974014, "<apn(ap)> <style PDARolloverHeaderDark>AP</style>", ap = ap})
            XContextControl.OnContextUpdate(self, context)
        end
    end
    ---- header damage: vanilla reads AvailableAttacks[1], a hidden BurstFire on guns without a limiter
    path = FindXtByProp(XTemplates.RolloverInventoryWeaponBase, "comment", "dmg, crit,range")
    local node = path and path[1][1]
    if IsKindOf(node, "XTemplateForEach") then
        node.rat_vanilla_run_after = node.rat_vanilla_run_after or node.run_after
        local vanilla_run_after = node.rat_vanilla_run_after
        node.run_after = function(child, context, item, ...)
            vanilla_run_after(child, context, item, ...)
            if item.bind_to ~= "Damage" or not IsKindOf(context, "Firearm") then
                return
            end
            local action = CombatActions[context:GetBaseAttack(nil, true)]
            if not action or action.id == (context.AvailableAttacks or empty_table)[1] then
                return
            end
            child.CreatePropValText = function(self, value, scale)
                local unit = context.owner and (g_Units[context.owner] or gv_UnitData[context.owner]) or
                                 GetInventoryUnit() or SelectedObj
                if not unit then
                    local satellite = GetSatelliteDialog()
                    local squad = satellite and satellite:HasMember("selected_squad") and satellite.selected_squad
                    unit = squad and squad.units and squad.units[1] and gv_UnitData[squad.units[1]]
                end
                local dmg = 0
                if unit then
                    local total, base = action:GetActionDamage(unit, false, {weapon = context})
                    dmg = base or total
                end
                ---- default length, not the ammo-clamped one: an empty gun would read 1x
                return Untranslated(context:GetAutofireShots(action) ..
                                        "<valign bottom -3><style InventoryRolloverPropSmall>x</style><valign center>" .. dmg)
            end
        end
    end
    path = FindXtByProp(XTemplates.RolloverInventoryWeaponBase, "comment", "penetration")
    if path then
        SetTemplateFunc(path[1], "CreatePropValText(self, value, scale)", function(self, value, scale)
            local obj = ResolvePropObj(self.context)
            return GetPenetrationClassUIText(IsKindOf(obj, "Firearm") and Rat_DisplayPenetrationClass(obj) or value)
        end)
    end
    ---- caliber rows in both rollovers. Weapon: the first "ammo" block is the gun's own caliber row (the second
    ---- is the subweapon's). Ammo item: the generic rollover's "ammo" group, after vanilla's modifier list
    for _, tmpl in ipairs{XTemplates.RolloverInventoryWeaponBase, XTemplates.RolloverInventoryBase} do
        path = FindXtByProp(tmpl, "comment", "ammo")
        if path and not FindXtByProp(path[1], "Id", "idRatCaliberHints") then
            table.insert(path[1], PlaceObj("XTemplateWindow", {
                "__class", "XText",
                "Id", "idRatCaliberHints",
                "Margins", box(0, 4, 0, 0),
                "HandleMouse", false,
                "TextStyle", "InventoryRolloverHint",
                "Translate", true,
                "HideOnEmpty", true,
                "FoldWhenHidden", true,
            }, {
                PlaceObj("XTemplateFunc", {
                    "name", "Open(self)",
                    "func", function(self)
                        XText.Open(self)
                        self:SetText(Rat_GetCaliberHints(ResolvePropObj(self.context)))
                    end,
                }),
            }))
        end
    end
    ---- More Info panel: attack AP list skips hidden fire modes; swap/reload AP and mechanism below it
    path = FindXtByProp(XTemplates.InventoryRolloverInfo, "class", "XTemplateForEach")
    if path then
        local each = path[1]
        ---- kept on the node so a Lua reload doesn't wrap the wrapper
        each.rat_vanilla_condition = each.rat_vanilla_condition or each.condition
        local vanilla_condition = each.rat_vanilla_condition
        each.condition = function(parent, context, item, i)
            return vanilla_condition(parent, context, item, i) and not HintAttackHidden(ResolvePropObj(context), item)
        end
        ---- vanilla prices only an equipped gun; anything else fell back to ShootAP + ActionPointDelta
        each.rat_vanilla_run_after = each.rat_vanilla_run_after or each.run_after
        local vanilla_run_after = each.rat_vanilla_run_after
        each.run_after = function(child, context, item, i, n, last)
            vanilla_run_after(child, context, item, i, n, last)
            local weapon = ResolvePropObj(context)
            local unit = HintAPUnit(child.parent:GetContext().owner)
            local ap = unit and CombatActions[item]:GetAPCost(unit, {weapon = weapon})
            if ap and ap ~= -1 then
                child.idPropVal:SetValueText(T{499138807753, "<val><style PDABrowserTitleSmall> AP</style>",
                                               val = MulDivRound(ap, 1, const.Scale.AP)})
            end
            ---- the length that cost pays for, since the wheel changes it
            if Rat_IsVariableAuto(CombatActions[item]) and IsKindOf(weapon, "Firearm") then
                child.idPropVal:SetNameText(T{396207518843, "<action> (<num> rounds)", action = CombatActions[item].DisplayName,
                                              num = Rat_AutoPricedShots(CombatActions[item], weapon)})
            end
        end
        local old = table.find(path[2], "Id", "idRatHandlingAP")
        if old then
            table.remove(path[2], old)
        end
        local function row(id)
            return PlaceObj("XTemplateWindow", {
                "__class", "XNameValueText",
                "Id", id,
                "TextStyle", "PDABrowserTitleSmall",
                "TextStyleRight", "PDASectorInfo_SectionItem",
                "FoldWhenHidden", true,
            })
        end
        table.insert(path[2], PlaceObj("XTemplateWindow", {
            "__class", "XContextWindow",
            "Id", "idRatHandlingAP",
            "IdNode", true,
            "LayoutMethod", "VList",
            "FoldWhenHidden", true,
        }, {
            row("idSwap"),
            row("idReload"),
            row("idMechanism"),
            row("idCycling"),
            row("idBurstCrit"),
            row("idAutoCrit"),
            row("idBurstRecoil"),
            row("idAutoRecoil"),
            row("idLongRecoil"),
            row("idHandlingStand"),
            row("idHandlingCrouch"),
            PlaceObj("XTemplateFunc", {
                "name", "Open(self)",
                "func", function(self)
                    XContextWindow.Open(self)
                    local weapon = ResolvePropObj(self.context)
                    if not IsKindOf(weapon, "Firearm") then
                        self:SetVisible(false)
                        return
                    end
                    local ap = "<val><style PDABrowserTitleSmall> AP</style>"
                    self.idSwap:SetNameText(CombatActions.ChangeWeapon.DisplayName)
                    self.idSwap:SetValueText(T{499138807753, ap, val = HintSwapAP(weapon)})
                    self.idReload:SetNameText(CombatActions.Reload.DisplayName)
                    self.idReload:SetValueText(T{499138807753, ap, val = MulDivRound(weapon.ReloadAP or 0, 1, const.Scale.AP)})
                    local shown
                    for _, r in ipairs{{self.idMechanism, HintMechanismLabel, "recoil_mechanism"},
                                       {self.idCycling, HintCyclingLabel, "Rat_cycling"}} do
                        local text = HintMechanismNames[(weapon[r[3]] or ""):gsub("_", "")]
                        ---- manual actions name both the same (Bolt Action / Bolt Action)
                        r[1]:SetVisible(not not text and text ~= shown)
                        shown = text
                        r[1]:SetNameText(r[2])
                        r[1]:SetValueText(text or "")
                    end
                    local attacks = weapon.AvailableAttacks or empty_table
                    local has_burst = Rat_HasSelectiveBurst(weapon) and table.find(attacks, "BurstFire") and
                                          not HintAttackHidden(weapon, "BurstFire")
                    local owner = weapon.owner and (not gv_SatelliteView and g_Units[weapon.owner] or gv_UnitData[weapon.owner])
                    local function recoil_row(win, label, attack, delta_prop, bump)
                        local delta = weapon[delta_prop] or 100
                        return {win, label, delta ~= 100 and attack, function()
                            return HintMulText(HintModeRecoil(weapon, owner, delta_prop, bump),
                                               string.format(" (%+d%%)", delta - 100))
                        end}
                    end
                    ---- shown when the gun has a raw not-prone malus: cone multiplier after the owner's Strength, raw one faded
                    local function handling_row(win, label, stance)
                        return {win, label, IsACHTActive() and Rat_HandlingNotPronePen(weapon, nil, stance) > 0, function()
                            local raw = Rat_HandlingNotPronePen(weapon, nil, stance)
                            local pen = owner and Rat_HandlingNotPronePen(weapon, owner, stance) or raw
                            local base = pen == raw and "" or "<color PDABrowserFlavor> (" .. HintHundredths(100 + raw) .. "x)</color>"
                            return "<color PDABrowserTextHighlight>" .. HintHundredths(100 + pen) .. "</color>" ..
                                       "<style PDABrowserTitleSmall>x" .. base .. "</style>"
                        end}
                    end
                    for _, r in ipairs{
                        {self.idBurstCrit, HintBurstCritLabel, has_burst,
                         function() return HintMulText(weapon.BurstCritMul or 100) end},
                        {self.idAutoCrit, HintAutoCritLabel, Rat_HasVariableAuto(weapon),
                         function() return HintMulText(const.Combat.AutoFireCritMul) end},
                        recoil_row(self.idBurstRecoil, HintBurstRecoilLabel, has_burst, "burst_recoil_delta", true),
                        recoil_row(self.idAutoRecoil, HintAutoRecoilLabel,
                                   table.find(attacks, "AutoFire") and not HintAttackHidden(weapon, "AutoFire"),
                                   "auto_recoil_delta", true),
                        recoil_row(self.idLongRecoil, HintLongRecoilLabel, table.find(attacks, "MGBurstFire"),
                                   "long_recoil_delta"),
                        handling_row(self.idHandlingStand, HintHandlingStandLabel, "Standing"),
                        handling_row(self.idHandlingCrouch, HintHandlingCrouchLabel, "Crouch"),
                    } do
                        r[1]:SetVisible(not not r[3])
                        r[1]:SetNameText(r[2])
                        r[1]:SetValueText(r[3] and Untranslated(r[4]()) or "")
                    end
                end,
            }),
        }))
        old = table.find(path[2], "Id", "idRatAccChart")
        if old then
            table.remove(path[2], old)
        end
        table.insert(path[2], HintChartWindow("idRatAccChart", 260, box(0, 8, 0, 0), function(self)
            local weapon = ResolvePropObj(self.context)
            if not HintChartable(weapon) then
                return false
            end
            local owner = weapon.owner and (not gv_SatelliteView and g_Units[weapon.owner] or gv_UnitData[weapon.owner])
            self.rat_curves = HintChartCurves(weapon, owner)
            return true
        end))
        old = table.find(path[2], "Id", "idRatRecoilChart")
        if old then
            table.remove(path[2], old)
        end
        table.insert(path[2], HintChartWindow("idRatRecoilChart", 260, box(0, 8, 0, 0), function(self)
            local weapon = ResolvePropObj(self.context)
            local owner = weapon.owner and (not gv_SatelliteView and g_Units[weapon.owner] or gv_UnitData[weapon.owner])
            return HintRecoilSetup(self, weapon, owner, nil, true)
        end))
    end
    HintWrapOpenCompare()
    ---- More Info starts open; Insert hides it
    g_RolloverShowMoreInfo = true
    ---- More Info on a charted gun: titled with the gun, not its class, and without the class flavor text
    path = FindXtByProp(XTemplates.InventoryRolloverInfo, "Id", "idContentInfo")
    if path then
        local node = path[1]
        node.rat_vanilla_update = node.rat_vanilla_update or node.OnContextUpdate
        local vanilla = node.rat_vanilla_update
        node.OnContextUpdate = function(self, context, ...)
            vanilla(self, context, ...)
            local weapon = ResolvePropObj(context)
            if HintChartable(weapon) then
                self.idType:SetText(weapon.DisplayName)
            end
        end
    end
    path = FindXtByProp(XTemplates.InventoryRolloverInfo, "Id", "idDescription")
    if path then
        local node = path[2]
        node.FoldWhenHidden = true
        node.rat_vanilla_update = node.rat_vanilla_update or node.OnContextUpdate
        local vanilla = node.rat_vanilla_update
        node.OnContextUpdate = function(self, context, ...)
            local charted = HintChartable(ResolvePropObj(context))
            self:SetVisible(not charted)
            if not charted then
                vanilla(self, context, ...)
            end
        end
    end
    path = FindXtByProp(XTemplates.ModifyWeaponDlg, "Id", "idValue")
    if path then
        SetTemplateFunc(path[1], "Open(self)", function(self)
            XText.Open(self)
            self:SetText(GetArmorClassUIText(Rat_DisplayPenetrationClass(self.context)))
        end)
    end
    ---- both charts replace the combined component effects text (the part popup still describes each part)
    path = FindXtByProp(XTemplates.ModifyWeaponDlg, "comment", "extra stat stuff")
    if path then
        local list = path[2]
        for _, id in ipairs{"idRatModChart", "idRatModRecoil"} do
            local old = table.find(list, "Id", id)
            if old then
                table.remove(list, old)
            end
        end
        local at = table.find(list, path[1])
        table.insert(list, at, HintModifyChart("idRatModRecoil", true, 245))
        table.insert(list, at, HintModifyChart("idRatModChart", false, 245))
        HintModEffectsNode = path[1]
        path[1].__condition = function() return false end
    end
    ---- the left column's stat bars bound the part popup (see GetSafeAreaBox below)
    path = FindXtByProp(XTemplates.ModifyWeaponDlg, "MaxWidth", 500)
    if path then
        path[2].Id = "idRatLeftInfo"
    end
    ---- part popup: stay between the stat bars and the charts; when too wide, cover the bars, never the charts
    local popup = XTemplates.WeaponModChoicePopup and XTemplates.WeaponModChoicePopup[1]
    ---- long part lists (scopes) wrap into a grid narrow enough to stay off the charts. Tons of Components
    ---- also wraps them (1100 wide, from its own ToggleOptions); patching here runs after every mod's code
    if WeaponComponentWindowClass.ToggleOptions ~= HintToggleOptions then
        local base = WeaponComponentWindowClass.ToggleOptions
        HintToggleOptions = function(self, ...)
            base(self, ...)
            local popup = self:ResolveId("node").idChoicePopup
            local list = popup and rawget(popup, "idList")
            if list then
                list:SetLayoutMethod("HWrap")
                ---- centered HWrap rows skip the spacing when centering and push the last part off the popup
                list:SetHAlign("left")
                list:SetLayoutVSpacing(10)
                list:SetMaxWidth(560)
            end
        end
        WeaponComponentWindowClass.ToggleOptions = HintToggleOptions
    end
    if popup then
        ---- the popup has no GetSafeAreaBox of its own to replace
        if not table.find(popup, "name", "GetSafeAreaBox(self)") then
            table.insert(popup, PlaceObj("XTemplateFunc", {"name", "GetSafeAreaBox(self)"}))
        end
        SetTemplateFunc(popup, "GetSafeAreaBox(self)", function(self)
            local x1, y1, x2, y2 = GetSafeAreaBox()
            local cab = GetDialog("ModifyWeaponDlg")
            local dlg = cab and rawget(cab, "idModifyDialog")
            local props = dlg and rawget(dlg, "idWeaponProps")
            local chart = props and rawget(props, "idRatModChart")
            local info = dlg and rawget(dlg, "idRatLeftInfo")
            local gap = MulDivRound(20, self.scale:x(), 1000)
            if chart and chart:GetVisible() then
                x2 = Min(x2, chart.box:minx() - gap)
            end
            if info then
                x1 = Max(x1, info.box:maxx() + gap)
            end
            return x1, y1, x2, y2
        end)
    end
end

function GBO_GetDescriptionHints(self)
    local formattedString = "<style CrosshairAPTotal>"

    local owner = self.owner and (not gv_SatelliteView and g_Units[self.owner] or gv_UnitData[self.owner])

    local angularCTHActive = IsACHTActive()
    local classic_owner = not angularCTHActive and owner

    local stance_ap, crit_per_aim, recoil = HintStanceAP(self, owner), HintCritPerAim(self, owner), HintRecoil(self, owner)
    local hip, snap = HintHipSnap(self, 0, owner, angularCTHActive), HintHipSnap(self, 1, owner, angularCTHActive)
    local pb = HintPB(self, classic_owner)
    local handling = HintHandling(self, owner)
    local aim = HintAim(self, owner, angularCTHActive)
    local aim_ref = owner and HintAim(self, nil, angularCTHActive)

    local reliability_suffix = "%"
    if Platform.rat then
        local jam = self.Condition < const.Weapons.JamConditionGate and self:GetJamChance(owner or HintFullStats, self.Condition) or 0
        reliability_suffix = string.format("%% (jam %d%%)", jam)
    end

	local termList = {
	    {
	        id = "ShootingStanceCost",
	        TranslationTable[242435461626] or "Shooting Stance Cost: ",
	        stance_ap, " AP",
	        base = owner and HintStanceAP(self),
	        bar = "StanceAP",
	    },
	    {
	        id = "ShootingAngle",
	        TranslationTable[766379566745] or "Shooting Angle: ",
	        string.format("%.2f", self:GetProperty("OverwatchAngle") / 60.0), "º",
	        bar = "Angle", bar_v = self:GetProperty("OverwatchAngle"),
	    },
	    {
	        id = "Reliability",
	        TranslationTable[412593832155] or "Reliability: ",
	        self.Reliability, reliability_suffix,
	        bar = "Reliability",
	    },
	    {
	        id = "NoiseRadius",
	        TranslationTable[654134899415] or "Noise Radius: ",
	        Rat_BasicAmmoProp(self, "Noise"), " tiles",
	        bar = "Noise",
	    },
	    {
	        id = "CriticalPerAim",
	        TranslationTable[318826540117] or "Critical chance per aim: ",
	        HintHundredths(crit_per_aim), "%",
	        base = owner and HintHundredths(HintCritPerAim(self)),
	        bar = "CritPerAim", bar_v = crit_per_aim, bar_ref = owner and HintCritPerAim(self),
	    },
		{
			id = "AimAccuracy",
			TranslationTable[219437987174] or "Aim accuracy: ",
			HintAimText(aim, angularCTHActive), "",
			base = aim_ref and HintAimText(aim_ref, angularCTHActive),
			bar = "AimAccuracy", bar_v = aim, bar_ref = aim_ref,
		},
	    angularCTHActive and {
	        id = "PointBlankRangeAccuracy",
	        const.Combat.Aperture.HandlingLegacy and (TranslationTable[184329577856] or "Handling Penalty Multiplier: ") or
	            (TranslationTable[547203918664] or "Handling: "),
	        HintHandlingText(handling), "",
	        base = owner and HintHandlingText(HintHandling(self)),
	        bar = "Handling", bar_v = handling, bar_ref = owner and HintHandling(self),
	    } or {
	        id = "PointBlankRangeAccuracy",
	        TranslationTable[651371401489] or "Point Blank Range Accuracy: ",
	        pb, "%",
	        base = classic_owner and GetPBbonus(self),
	        bar = "PB",
	    },
	    {
	        id = "HipfirePenaltyMultiplier",
	        TranslationTable[852084205321] or "Hipfire Penalty Multiplier: ",
	        HintHundredths(hip), "X",
	        base = owner and HintHundredths(HintHipSnap(self, 0)),
	        bar = "Hipfire", bar_v = hip, bar_ref = owner and HintHipSnap(self, 0),
	    },
	    {
	        id = "SnapshotPenaltyMultiplier",
	        TranslationTable[258395588915] or "Snapshot Penalty Multiplier: ",
	        HintHundredths(snap), "X",
	        base = owner and HintHundredths(HintHipSnap(self, 1)),
	        bar = "Snapshot", bar_v = snap, bar_ref = owner and HintHipSnap(self, 1),
	    },
	    {
	        id = "RecoilPenaltyMultiplier",
	        TranslationTable[151451884832] or "Recoil Penalty Multiplier: ",
	        HintHundredths(recoil), "X",
	        base = owner and HintHundredths(HintRecoil(self)),
	        bar = "Recoil", bar_v = recoil, bar_ref = owner and HintRecoil(self),
	    },
	}

	local cycle_ap = HintCycleAP(self, owner)
	if cycle_ap then
		table.insert(termList, table.find(termList, "id", "ShootingStanceCost") + 1, {
			id = "CyclingCost",
			TranslationTable[573918264051] or "Cycling Cost: ",
			cycle_ap, " AP",
			base = owner and HintCycleAP(self),
			bar = "CycleAP",
		})
	end
	local da_ap = HintCycleAP(self, owner, true)
	if da_ap then
		table.insert(termList, table.find(termList, "id", "CyclingCost") + 1, {
			id = "DoubleActionCost",
			TranslationTable[524204987393] or "Double Action Cost: ",
			da_ap, " AP",
			base = owner and HintCycleAP(self, nil, true),
			bar = "CycleAP",
		})
	end

	---- barrels change the spread, so it stays with the gun; the loaded (or Basic) ammo still widens it
	if (Rat_BasicAmmoProp(self, "NumPellets") or 0) > 1 then
		local spread = Rat_BasicAmmoProp(self, "BuckshotConeAngle") or 0
		table.insert(termList, {
			id = "PelletSpreadAngle",
			TranslationTable[193184162359] or "Pellet Spread Angle: ",
			string.format("%.2f", spread / 60.0), "º",
			bar = "Spread", bar_v = spread,
		})
	end

	if Rat_HasVariableAuto(self) then
		local tenths = MulDivRound(Rat_AutoAPPerRound(self), 10, const.Scale.AP)
		table.insert(termList, {
			id = "RateOfFire",
			TranslationTable[638215904417] or "Rate of Fire: ",
			self.RPM or 0,
			string.format(" RPM (<color PDABrowserTextHighlight>%d.%d</color> ", tenths / 10, tenths % 10) ..
				_InternalTranslate(ratT(file_str, 638215904418, "AP/extra round")) .. ")" ..
				((self.BurstRPM or 0) > 0 and string.format(", %d ", self.BurstRPM) ..
					_InternalTranslate(ratT(file_str, 741352906118, "in burst")) or "") ..
				(self.AutoFireOnly and (TranslationTable[638215904419] or ", full auto only") or ""),
			bar = "RPM",
		})
	end

	---- only where length drives damage (no flare gun, no 12 gauge); grey is the stock barrel
	if Rat_HasBarrelRule(self) then
		local barrel = Rat_EffectiveBarrelLength(self)
		table.insert(termList, {
			id = "BarrelLength",
			TranslationTable[529418307726] or "Barrel Length: ",
			barrel, " mm",
			base = barrel ~= self.rat_barrel_len and self.rat_barrel_len or nil,
			---- no better/worse span: length is a trade-off
			bar = "Barrel", bar_ref = barrel,
		})
	end

	local AngularCthActiveExclusionList = {
		--PointBlankRangeAccuracy = true
	}


	for _, term in ipairs(termList) do
		if not angularCTHActive or not AngularCthActiveExclusionList[term.id] then
	    	formattedString = formattedString .. HintLine(term)
		end
	end

	formattedString = formattedString .. "</style>"

	if self:IsCumbersome() then
	    local cumbersome_text = TranslationTable[153781665575] or
	        "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Cumbersome (no Free Move)\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increases Stance AP cost by <ap> (negated by high Strength)\n"
	    -- function replacement: the AP value is not a gsub pattern
	    formattedString = formattedString .. cumbersome_text:gsub("<ap>", function() return tostring(R_VanillaAPToDisplay(1)) end)
	end

	if HintSwapAP(self) == 0 then
	    formattedString = formattedString .. (TranslationTable[731905264418] or
	        "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded")
	end

	return T {formattedString}
end



local t_id_table = {
    [153781665575] = "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Cumbersome (no Free Move)\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Increases Stance AP cost by <ap> (negated by high Strength)\n",
    [731905264418] = "\n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Swapping to this weapon is free, as long it is not dual-wielded",
    [242435461626] = "Shooting Stance Cost: ",
    [573918264051] = "Cycling Cost: ",
    [524204987393] = "Double Action Cost: ",
    [766379566745] = "Shooting Angle: ",
    [412593832155] = "Reliability: ",
    [654134899415] = "Noise Radius: ",
    [684546854913] = "Base critical chance: ",
    [318826540117] = "Critical chance per aim: ",
    [247182652462] = "Extra critical damage: ",
    [651371401489] = "Point Blank Range Accuracy: ",
    [852084205321] = "Hipfire Penalty Multiplier: ",
    [258395588915] = "Snapshot Penalty Multiplier: ",
    [151451884832] = "Recoil Penalty Multiplier: ",
    [158466723759] = "Recommended Strength: ",
    [785975283217] = " STR",
    [719583632117] = "Number of Pellets: ",
    [193184162359] = "Pellet Spread Angle: ",
	[547203918664] = "Handling: ",
	[184329577856] = "Handling Penalty Multiplier: ",
	[219437987174] = "Aim accuracy: ",
	[638215904417] = "Rate of Fire: ",
	[529418307726] = "Barrel Length: ",
	[531760248906] = "Base damage: ",
	[531760248907] = "Armor penetration: ",
	[396207518843] = "<action> (<num> rounds)",
	--[638215904418] = "AP per extra round",

}

ratG_T_table[file_str] = ratG_T_table[file_str] or {}

for id, text in pairs(t_id_table) do
    ratG_T_table[file_str][id] = text
end

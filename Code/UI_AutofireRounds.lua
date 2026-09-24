---- Crosshair strip under the range bar: one cartridge icon per round, selected bright and the
---- rest the unit can still afford shadowed, then the count. Icons: tools/gen_bullet_icons.py.

local icon_dir = "Mod/cfahRED/Images/Bullets/"
local fallback_icon = "556"

---- caliber id -> icon; aliases cover duplicate caliber presets
local caliber_icon = {
    ["9mm"] = "9mm",
    ["9x18"] = "9x18",
    ["45ACP"] = "45ACP",
    ["380ACP"] = "380ACP",
    ["44CAL"] = "44MAG",
    ["44MAG"] = "44MAG",
    ["44AMP"] = "44MAG",
    ["50AE"] = "50AE",
    ["5_7x28"] = "5_7x28",
    ["5.7x28mm"] = "5_7x28",
    ["556"] = "556",
    ["545x39"] = "545x39",
    ["5_45x39"] = "545x39",
    ["762WP"] = "762WP",
    ["762NATO"] = "762NATO",
    ["308Win"] = "308Win",
    ["762x54R"] = "762x54R",
    ["7_62x54R"] = "762x54R",
    ["50BMG"] = "50BMG",
    ["30-60"] = "30-60",
    ["20gauge"] = "20gauge",
    ["12gauge"] = "20gauge",
    ["7_92x33"] = "7_92x33",
    ["7_92x57"] = "7_92x57",
    ["792x57"] = "7_92x57",
    ["9x39"] = "9x39",
    ["4_7x33"] = "4_7x33"
}

function Rat_BulletIcon(weapon)
    return icon_dir .. (caliber_icon[weapon and weapon.Caliber] or fallback_icon) .. ".png"
end

---- largest length the unit can pay for now; AP cost is monotonic in num_shots
function Rat_CrosshairMaxShots(attacker, action, weapon, args)
    local hi = Rat_ClampAutoShots(action, weapon, max_int)
    local lo = Min(args.num_shots, hi)
    if not g_Combat then
        return hi
    end
    local probe = table.copy(args)
    probe.ap_cost_breakdown = {}
    while lo < hi do
        local mid = (lo + hi + 1) // 2
        probe.num_shots = mid
        if attacker:UIHasAP(action:GetAPCost(attacker, probe)) then
            lo = mid
        else
            hi = mid - 1
        end
    end
    return lo
end

---------------------------------------------------------------------------------------------------

DefineClass.RatBulletStrip = {
    __parents = {"XImage"},
    rat_shots = 0,
    rat_max = 0,
    MaxStripWidth = 200,
    IconGap = 1,
    ShadowColor = RGBA(200, 200, 210, 70)
}

---- the png is drawn at 2x
function RatBulletStrip:IconSize()
    local w, h = self:CalcSrcRect():sizexyz()
    return ScaleXY(self.scale, w / 2, h / 2)
end

---- icons overlap like a belt once the row would pass MaxStripWidth
function RatBulletStrip:StripWidth(w)
    local n = self.rat_max
    if n <= 0 or w <= 0 then
        return 0
    end
    local gap = ScaleXY(self.scale, self.IconGap)
    local cap = ScaleXY(self.scale, self.MaxStripWidth)
    return Min(n * w + (n - 1) * gap, Max(w, cap))
end

function RatBulletStrip:Measure(preferred_width, preferred_height)
    local w, h = self:IconSize()
    return self:StripWidth(w), h
end

function RatBulletStrip:DrawContent()
    local n = self.rat_max
    if self.Image == "" or n <= 0 then
        return
    end
    local src = self:CalcSrcRect()
    local w, h = self:IconSize()
    local b = self.content_box
    local travel = self:StripWidth(w) - w
    local y = b:maxy() - h
    for i = 1, n do
        local x = b:minx() + (n > 1 and MulDivRound(i - 1, travel, n - 1) or 0)
        local lit = i <= self.rat_shots
        local color = lit and self.ImageColor or self.ShadowColor
        UIL.DrawXImage(self.Image, sizebox(x, y, w, h), w, h, src, color, color, color, color,
                       lit and 0 or 255, self.Angle, self.FlipX, self.FlipY, self.EffectType,
                       self.EffectPixels, self.EffectColor, self.UseClipBox, self.FrameEdgeColor,
                       self.FrameLeft, self.FrameTop, self.FrameRight, self.FrameBottom)
    end
end

function RatBulletStrip:SetRounds(image, shots, max)
    if self.Image ~= image then
        self:SetImage(image)
    end
    if self.rat_shots ~= shots or self.rat_max ~= max then
        local relayout = self.rat_max ~= max
        self.rat_shots, self.rat_max = shots, max
        if relayout then
            self:InvalidateMeasure()
        end
        self:Invalidate()
    end
end

---------------------------------------------------------------------------------------------------

function Rat_UpdateCrosshairRounds(crosshair, attacker, action, args)
    local win = crosshair.idRatRounds
    if not win then
        return
    end
    local weapon = args.num_shots and action:GetAttackWeapons(attacker)
    if not weapon then
        win:SetVisible(false)
        return
    end
    local max = Rat_CrosshairMaxShots(attacker, action, weapon, args)
    win.idRatRoundsStrip:SetRounds(Rat_BulletIcon(weapon), args.num_shots, max)
    win.idRatRoundsText:SetText(tostring(args.num_shots))
    win:SetVisible(true)
end

local rounds_template = PlaceObj('XTemplateWindow', {
    'comment', "rat_autofire_rounds",
    'Id', "idRatRounds",
    'IdNode', true,
    'HAlign', "center",
    'VAlign', "bottom",
    'LayoutMethod', "HList",
    'LayoutHSpacing', 6,
    'Padding', box(8, 3, 8, 3),
    'UseClipBox', false,
    'Visible', false,
    'FoldWhenHidden', true,
    'Background', RGBA(32, 35, 47, 180)
}, {
    PlaceObj('XTemplateWindow', {
        '__class', "RatBulletStrip",
        'Id', "idRatRoundsStrip",
        'VAlign', "bottom",
        'UseClipBox', false
    }),
    PlaceObj('XTemplateWindow', {
        '__class', "XText",
        'Id', "idRatRoundsText",
        'VAlign', "center",
        'MinWidth', 24,
        'Clip', false,
        'UseClipBox', false,
        'TextStyle', "CrosshairAPCost",
        'TextHAlign', "left"
    })
})

---- goes right after the range indicator in the bottom VList
function Rat_PatchCrosshairRounds()
    local chain = FindXtByProp(XTemplates.ActionCameraCrosshair, 'Id', 'idRange')
    local vlist = chain and chain[2]
    if not vlist then
        return
    end
    for i = #vlist, 1, -1 do
        if vlist[i].comment == "rat_autofire_rounds" then
            table.remove(vlist, i)
        end
    end
    table.insert(vlist, table.find(vlist, chain[1]) + 1, rounds_template)
end

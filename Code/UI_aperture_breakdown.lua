---------------------------------------------------------------------------------------------------
---- OVERLAY DO CTH: no modelo angular o breakdown deixa de ser uma soma de pontos.
---- Sigma e a unica moeda, entao cada residual aparece como o MULTIPLICADOR DE CONE que aplicou
---- (100 = neutro, >100 abre o cone = pior, <100 fecha = melhor) -- que e o que ele de fato fez.
----
---- A linha Aperture mostra o CTH FINAL (o mesmo do topo) -- Marksmanship perde a linha de
---- pontos. Abaixo dela: uma linha por fator do cone (explicam a GEOMETRIA) e uma por residual
---- (explicam o AJUSTE), cada uma como o multiplicador de cone que aplicou. Nada soma: no
---- paradigma de sigma os fatores sao multiplicativos e o cone->CTH e nao-linear. Modificador
---- neutro some, e o metaText antigo tambem -- ele fala em pontos, moeda que aqui nao existe.
----
---- Sem a linha Aperture nos modifiers (A.Enabled = false, melee, alvo invalido) cai no vanilla.
---------------------------------------------------------------------------------------------------

---- guarda o vanilla UMA vez: recarregar o mod nao pode fazer o override chamar a si mesmo
local vanilla_populate = _G.Rat_VanillaPopulateCth or PopulateCrosshairUICth
Rat_VanillaPopulateCth = vanilla_populate

---- Sinal quando os numeros de CTH estao escondidos (opcao do jogo). Invertido em relacao ao de
---- pontos: fechar o cone e o ganho, abrir e a perda.
local function cone_sign(mul)
    if mul < 100 then
        return "<color PDASectorInfo_Green>+</color>"
    elseif mul > 100 then
        return "<color DescriptionTextRed>-</color>"
    end
    return ""
end

---- "<nome> <direita> <valor>", o mesmo formato do vanilla
local function line(name, value)
    return T {221170966425, "<name><right><style PDABrowserTextLightBold><sign></style>",
              name = name, sign = value or ""}
end

local function push_meta(out, metaText)
    if not metaText then
        return
    end
    if IsT(metaText) then
        out[#out + 1] = T {399490205680, "<left> <metaText>", metaText = metaText}
    else
        for _, t in ipairs(metaText) do
            out[#out + 1] = T {399490205680, "<left> <metaText>", metaText = t}
        end
    end
end

---- Second sub-window under ACCURACY, same shape as it: title bar + dark body
local aperture_section = PlaceObj('XTemplateWindow', {
    'comment', "rat_aperture",
    'Id', "idRatApertureSection",
    'LayoutMethod', "VList",
    'UseClipBox', false,
    'FoldWhenHidden', true,
    'Visible', false,
}, {
    PlaceObj('XTemplateWindow', {
        'Margins', box(8, 0, 0, 0),
        'MinHeight', 34,
        'UseClipBox', false,
    }, {
        PlaceObj('XTemplateWindow', {
            '__class', "XText",
            'Id', "idRatApertureHeader",
            'Padding', box(0, 0, 6, 0),
            'VAlign', "center",
            'Clip', false,
            'UseClipBox', false,
            'TextStyle', "PDABrowserNameSmall",
            'Translate', true,
            'TextVAlign', "center",
        }),
    }),
    PlaceObj('XTemplateWindow', {
        'Padding', box(14, 5, 14, 5),
        'UseClipBox', false,
        'Background', RGBA(32, 35, 47, 255),
    }, {
        PlaceObj('XTemplateWindow', {
            '__class', "XText",
            'Id', "idRatApertureMods",
            'Clip', false,
            'UseClipBox', false,
            'TextStyle', "SatelliteContextMenuKeybind",
            'Translate', true,
            'TextVAlign', "center",
        }),
    }),
})

local function under_recoil(chain)
    for i = 2, #chain do
        if chain[i].comment == "rat_recoil" then
            return true
        end
    end
end

function Rat_PatchCrosshairApertureSection()
    ---- the recoil rollover carries its own idHitInfo; patch only the vanilla one
    local function find(obj)
        local chain = FindXtByProp(obj, "Id", "idHitInfo")
        return chain and not under_recoil(chain) and chain[1]
    end
    local hit_info = find(XTemplates.CrosshairAttackRollover[1])
    if not hit_info then
        return
    end
    for i = #hit_info, 1, -1 do
        if hit_info[i].comment == "rat_aperture" then
            table.remove(hit_info, i)
        end
    end
    hit_info[#hit_info + 1] = aperture_section
end

function PopulateCrosshairUICth(win, attacker, action, attackResults)
    local section = rawget(win, "idRatApertureSection")
    if section then
        section:SetVisible(false)
    end
    local dontShow = action.AlwaysHits
    win:SetVisible(not dontShow)
    if dontShow or not attackResults then
        return
    end

    local modifiers = attackResults.chance_to_hit_modifiers
    local a = const.Combat.Aperture
    ---- a linha Aperture so existe se o modelo resolveu ESTE ataque -- e o sinal mais confiavel
    if not modifiers or not (a and a.Enabled) or not table.find(modifiers, "id", "RatAngularCTH") then
        return vanilla_populate(win, attacker, action, attackResults)
    end

    local chanceToHit = attackResults.chance_to_hit
    local visible = CthVisible()
    if visible then
        win.idChanceToHit:SetText(T {757275361770, "ACCURACY: <right><percent(chanceToHit)>",
                                     chanceToHit = chanceToHit})
        win.idChanceToHit.parent:SetZOrder(1)
    else
        win.idChanceToHit:SetText(T {906758075439, "ACCURACY", chanceToHit = chanceToHit})
        win.idChanceToHit.parent:SetZOrder(0)
    end

    ---- ACCURACY window: the comparison that IS the CTH (plus flat CTH mods); APERTURE window: what sized the cone
    local top, cone, total, cone_meta = {}, {}, nil, nil
    for _, mod in ipairs(modifiers) do
        ---- no name: the per-shot "No Line of Fire" log entry, double-wrapped by vanilla (Weapon.lua:2353)
        if not mod.uiHidden and mod.name then
            if mod.id == "RatAngularCTH" then
                ---- rat_entry.value seria "rat_cth - skill", delta sem sentido sozinho
                table.insert(top, 1, line(mod.name, visible and
                                 T {257328164584, "<percent(value)>", value = chanceToHit}))
                if mod.rat_factors and #mod.rat_factors > 0 then
                    for _, f in ipairs(mod.rat_factors) do
                        cone[#cone + 1] = line(f.name, visible and f.tag)
                        if f.sub then
                            push_meta(cone, f.sub)
                        end
                    end
                    total = mod.rat_total --- impresso no fim: ele ja conta os residuais
                    cone_meta = mod.rat_meta
                else
                    push_meta(top, mod.metaText)
                end
            elseif mod.rat_mul then
                ---- residual: so quem mexeu no cone. Sem metaText -- ele fala em pontos.
                if mod.rat_mul ~= 100 then
                    cone[#cone + 1] = line(mod.name, visible and Rat_ConeMulTag(mod.rat_mul) or
                                               cone_sign(mod.rat_mul))
                end
            elseif mod.value and not mod.id then
                ---- base de Marksmanship: ja esta no CTH da linha Aperture, sem linha propria
            else
                ---- o que nao passou pelo cone e nao e base (cheats, Out of Range, outros mods)
                top[#top + 1] = line(mod.name, visible and mod.value and
                                         T {257328164584, "<percent(value)>", value = mod.value})
            end
        end
    end

    if total then
        cone[#cone + 1] = line(total.name, visible and total.tag)
    end
    ---- piso e camuflagem nao sao multiplicadores: notas sob o Total
    push_meta(cone, cone_meta)

    win.idModifiers:SetVisible(true)
    win.idModifiers:SetText(Untranslated(table.concat(top, "\n<left>")))

    if section and #cone > 0 then
        section:SetVisible(true)
        win.idRatApertureHeader:SetText(T(615093827461, "APERTURE MODIFIERS"))
        win.idRatApertureMods:SetText(Untranslated(table.concat(cone, "\n<left>")))
    end
end

---------------------------------------------------------------------------------------------------
---- RECOIL window under aCTH: the muzzle model's three levers in minutes (Rat_RecoilProfile), the
---- recoil chain's named modifiers under the lever each one feeds, and the mean drift per shot.
---------------------------------------------------------------------------------------------------

---- Strength vs caliber -> cf_max
local hold_ids = {[285153762692] = true, [988872717528] = true}
---- stance, Marksmanship, perks -> max_inc. Everything else (gun, ammo, bipod, burst) is kick.
local correction_ids = {
    [294661659116] = true, [663793494488] = true, [869135768177] = true, [495676736357] = true,
    [889423438892] = true, [946448112577] = true, [712682745289] = true, [764956297274] = true
}

local function recoil_meta_line(m)
    local id, text = false, m
    if type(m) == "table" then
        id, text = m[1], m[2]
        if type(id) == "table" then
            id, text = id[1], id[2]
        end
    end
    text = (id and TranslationTable[id]) or text
    if type(text) ~= "string" then
        return id, nil
    end
    local neg = text:sub(1, 4) == "(-) "
    if neg then
        text = text:sub(5)
    end
    return id, T {399490205680, "<left> <metaText>", metaText = Untranslated(text .. " " ..
                 (neg and "<color DescriptionTextRed>-</color>" or "<color PDASectorInfo_Green>+</color>"))}
end

---- centiminutes -> "4.5'" / "173'": a decimal only where it is still a real share of the value
local function minutes(c)
    c = Max(0, c)
    if c >= 1000 then
        return MulDivRound(c, 1, 100) .. "'"
    end
    return string.format("%d.%d'", c // 100, (c % 100) // 10)
end

local function rgb_text(text, quality)
    local r, g, b = Rat_QualityColor(quality)
    return string.format("<color %d %d %d>%s</color>", r, g, b, text)
end

---- the weapon hint bar's segment images (DESCRIPTION_HINTS_get.lua, HintBar): 4 segments x 10 units.
---- kind nil = beige fill, "b" / "w" = solid green / red
local bar_img = "Mod/cfahRED/Images/HintBar/"
local function bar(pct, kind)
    local units = Clamp(MulDivRound(pct, 40, 100), pct > 0 and 1 or 0, 40)
    local s = ""
    for i = 0, 3 do
        local f = Clamp(units - i * 10, 0, 10)
        local file = (f == 0 or not kind) and ("b" .. f .. "_0") or ("b0_" .. f .. "_" .. kind .. "s")
        s = s .. (i > 0 and "<image " .. bar_img .. "div.png 1000>" or "") ..
                "<image " .. bar_img .. file .. ".png 1000>"
    end
    return Untranslated(s)
end

---- Per-round muzzle offsets of seeded walks, one list per round. Cached by profile identity:
---- Rat_CrosshairRecoilEstimate hands back the same table until the attack changes. One seed PER
---- WALK: with a shared stream, a longer burst shifted every later walk's draws and round 2 changed
---- color with burst length.
local walk_prof, walk_n, walk_offs
local function recoil_walk(prof, n)
    if walk_prof == prof and walk_n == n then
        return walk_offs
    end
    local a = const.Combat.Aperture
    local seed = a.RecoilEstimateSeed or 1
    local st, offs = Rat_RecoilState(), {}
    for i = 1, n do
        offs[i] = {}
    end
    for k = 1, Max(1, a.RecoilWindowSamples or 64) do
        local rnd = BraidRandomCreate(seed + k)
        st.px, st.py, st.vx, st.vy, st.cx, st.cy = 0, 0, 0, 0, 0, 0
        for i = 1, n do
            local _, _, r = Rat_RecoilPoint(st)
            offs[i][#offs[i] + 1] = r
            Rat_RecoilStep(prof, st, rnd)
        end
    end
    walk_prof, walk_n, walk_offs = prof, n, offs
    return offs
end

---- % of walks whose round still points inside the target. Recoil only: round 1 is a perfect hit and
---- the cone is left out, as in the weapon hint's recoil chart -- a weak round 1 can't hide the climb.
local function on_target(offs, theta)
    if theta <= 0 then
        return 100
    end
    local on = 0
    for _, r in ipairs(offs) do
        if r <= theta then
            on = on + 1
        end
    end
    return MulDivRound(on, 100, #offs)
end

---- one pip per round (tools/gen_recoil_pips.py)
local function share_pip(share)
    return "<image Mod/cfahRED/Images/RecoilPip/" .. (share >= 67 and "g" or share >= 34 and "a" or "r") ..
               ".png 1000>"
end

function Rat_ACTHRecoilSimple(win, entry, prof, num_shots, meta_groups)
    local offs, theta = recoil_walk(prof, num_shots), entry.rat_theta or 0
    local pips, sum = {}, 0
    for i = 1, num_shots do
        local share = on_target(offs[i], theta)
        ---- the bar is the rounds recoil can touch; round 1 would pad every burst with a free 100
        if i > 1 then
            sum = sum + share
        end
        pips[i] = share_pip(share)
    end
    local mean = sum // (num_shots - 1)

    local out = {}
    if CthVisible() then
        out[#out + 1] = line(T(902615374830, "Control"),
                             bar(mean, (mean >= 67 and "b") or (mean < 34 and "w") or nil))
        out[#out + 1] = line(T(902615374831, "Rounds"), Untranslated(table.concat(pips)))
    end
    for _, group in ipairs(meta_groups) do
        for _, l in ipairs(group) do
            out[#out + 1] = l
        end
    end
    win.idModifiers:SetVisible(true)
    win.idModifiers:SetText(Untranslated(table.concat(out, "\n<left>")))
    return true
end

function Rat_ACTHRecoilPopulate(win, attacker, action, attackResults, weapon)
    local modifiers = attackResults and attackResults.chance_to_hit_modifiers
    local entry = modifiers and table.find_value(modifiers, "id", "RatAngularCTH")
    local num_shots = #(attackResults and attackResults.shots or empty_table)
    if not entry or num_shots < 2 then
        return false
    end
    local est, prof = Rat_CrosshairRecoilEstimate(attacker, action, weapon, attackResults.aim or 0,
                                                  num_shots)
    if not est or not prof then
        return false
    end

    local visible = CthVisible()
    win.idChanceToHit:SetText(T(573019284716, "RECOIL"))
    win.idChanceToHit.parent:SetZOrder(1)

    local kick_meta, hold_meta, corr_meta = {}, {}, {}
    local _, meta = Rat_GetRecoilBaseMod(attacker, action, weapon, num_shots)
    for _, m in ipairs(meta or empty_table) do
        local id, l = recoil_meta_line(m)
        if l then
            local bucket = hold_ids[id] and hold_meta or correction_ids[id] and corr_meta or kick_meta
            bucket[#bucket + 1] = l
        end
    end

    local a = const.Combat.Aperture
    if a.RecoilWindowSimple then
        return Rat_ACTHRecoilSimple(win, entry, prof, num_shots, {kick_meta, hold_meta, corr_meta})
    end
    local bars = a.RecoilWindowBars
    ---- bipod already folded into kick_y: show the kick the step actually applies
    local kick = Rat_ISqrt(prof.kick_x * prof.kick_x + prof.kick_y * prof.kick_y)
    local kick_v, hold_v, corr_v
    if not visible then
        kick_v, hold_v, corr_v = false, false, false
    elseif bars then
        ---- centiminutes over a scale in minutes = % of the full bar
        local scale = Max(1, a.RecoilBarScaleMax or 500)
        kick_v = bar(MulDivRound(kick, 1, scale))
        ---- the caliber gate: below the kick, the climb can never be stopped
        hold_v = bar(MulDivRound(prof.cf_max, 1, scale), prof.cf_max < kick and "w" or "b")
        corr_v = bar(MulDivRound(prof.max_inc, 1, scale))
    else
        kick_v = minutes(kick)
        hold_v = Rat_ScaleTag(minutes(prof.cf_max), prof.cf_max < kick and 0 or 100)
        corr_v = minutes(prof.max_inc)
    end

    local out = {}
    local function lever(name, value, sub)
        out[#out + 1] = line(name, value)
        for _, l in ipairs(sub) do
            out[#out + 1] = l
        end
    end
    lever(T(681730492265, "Kick"), kick_v, kick_meta)
    lever(T(240917368852, "Max Correction"), hold_v, hold_meta)
    lever(T(915274036418, "Correction per Shot"), corr_v, corr_meta)

    if visible then
        ---- same colors as the simple view: % of walks still on target, cone left out
        local offs, theta = recoil_walk(prof, num_shots), entry.rat_theta or 0
        local drift = {}
        for i = 1, num_shots do
            local share = on_target(offs[i], theta)
            if bars then
                drift[i] = share_pip(share)
            else
                drift[i] = rgb_text((est.offset[i] or 0) .. "'", share)
            end
        end
        out[#out + 1] = line(T(386402917753, "Drift"), Untranslated(table.concat(drift, bars and "" or " ")))
    end

    win.idModifiers:SetVisible(true)
    win.idModifiers:SetText(Untranslated(table.concat(out, "\n<left>")))
    return true
end

local t_id_table = {
    [615093827461] = "APERTURE MODIFIERS",
    [573019284716] = "RECOIL",
    [681730492265] = "Kick",
    [240917368852] = "Max Correction",
    [915274036418] = "Correction per Shot",
    [386402917753] = "Drift",
    [902615374830] = "Control",
    [902615374831] = "Rounds"
}

ratG_T_table['UI_aperture_breakdown.lua'] = t_id_table

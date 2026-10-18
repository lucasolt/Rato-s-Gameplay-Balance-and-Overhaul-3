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
        if not mod.uiHidden then
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

local t_id_table = {
    [615093827461] = "APERTURE MODIFIERS"
}

ratG_T_table['UI_aperture_breakdown.lua'] = t_id_table

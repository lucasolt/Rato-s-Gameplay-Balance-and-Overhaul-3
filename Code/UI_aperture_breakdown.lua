---------------------------------------------------------------------------------------------------
---- OVERLAY DO CTH: no modelo angular o breakdown deixa de ser uma soma de pontos.
---- Sigma e a unica moeda, entao cada residual aparece como o MULTIPLICADOR DE CONE que aplicou
---- (100 = neutro, >100 abre o cone = pior, <100 fecha = melhor) -- que e o que ele de fato fez.
----
---- Ficam tres coisas: Marksmanship (a base em pontos), Aperture (a geometria, com a propria
---- decomposicao no metaText) e uma linha por modificador que mexeu no cone. Modificador neutro
---- some, e o metaText antigo deles tambem -- ele explica pontos, moeda que aqui nao existe mais.
----
---- Sem a linha Aperture nos modifiers (A.Enabled = false, melee, alvo invalido) cai no vanilla.
---------------------------------------------------------------------------------------------------

---- guarda o vanilla UMA vez: recarregar o mod nao pode fazer o override chamar a si mesmo
local vanilla_populate = rawget(_G, "Rat_VanillaPopulateCth") or PopulateCrosshairUICth
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

function PopulateCrosshairUICth(win, attacker, action, attackResults)
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

    local out, total = {}, nil
    for _, mod in ipairs(modifiers) do
        if not mod.uiHidden then
            if mod.id == "RatAngularCTH" then
                ---- geometria: o nome ja traz "cone vs alvo"; de onde o cone veio sai logo abaixo,
                ---- uma linha por fator, no mesmo formato dos residuais.
                out[#out + 1] = line(mod.name, visible and mod.value and
                                         T {257328164584, "<percent(value)>", value = mod.value})
                if mod.rat_factors and #mod.rat_factors > 0 then
                    for _, f in ipairs(mod.rat_factors) do
                        out[#out + 1] = line(f.name, visible and f.tag)
                    end
                    ---- o que nao e multiplicador (piso do alcance) fica indentado
                    push_meta(out, mod.rat_meta)
                    total = mod.rat_total --- impresso no fim: ele ja conta os residuais
                else
                    push_meta(out, mod.metaText)
                end
            elseif mod.rat_mul then
                ---- residual: so quem mexeu no cone. Sem metaText -- ele fala em pontos.
                if mod.rat_mul ~= 100 then
                    out[#out + 1] = line(mod.name, visible and Rat_ConeMulTag(mod.rat_mul) or
                                             cone_sign(mod.rat_mul))
                end
            else
                ---- Marksmanship e o que nao passou pelo cone (cheats, linhas de outros mods)
                out[#out + 1] = line(mod.name, visible and mod.value and
                                         T {257328164584, "<percent(value)>", value = mod.value})
            end
        end
    end

    if total then
        out[#out + 1] = line(total.name, visible and total.tag)
    end

    win.idModifiers:SetVisible(true)
    win.idModifiers:SetText(Untranslated(table.concat(out, "\n<left>")))
end

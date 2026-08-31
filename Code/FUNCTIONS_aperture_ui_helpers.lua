---- Gradiente de QUALIDADE: 0 = pior (vermelho), 100 = melhor (verde), passando por ambar.
---- Usado tanto no texto do overlay quanto no anel de mira, para os dois falarem a mesma lingua.
local function lerp(from, to, t)
    return from + MulDivRound(to - from, t, 100)
end

function Rat_QualityColor(pct)
    pct = Clamp(pct or 0, 0, 100)
    local r1, g1, b1, r2, g2, b2, t
    if pct < 50 then
        r1, g1, b1, r2, g2, b2, t = 214, 96, 82, 216, 172, 76, pct * 2
    else
        r1, g1, b1, r2, g2, b2, t = 216, 172, 76, 126, 186, 108, (pct - 50) * 2
    end
    return lerp(r1, r2, t), lerp(g1, g2, t), lerp(b1, b2, t)
end

---- Untranslated: e o jeito do engine de meter markup dentro de um arg de T. Sem ele a tag
---- de cor sairia escapada como texto literal.
function Rat_ScaleTag(text, quality_pct)
    local r, g, b = Rat_QualityColor(quality_pct)
    return Untranslated(string.format("<color %d %d %d>%s</color>", r, g, b, text))
end

---- Fator do cone com 100 NEUTRO: acima abre o cone (ruim), abaixo fecha (bom). Para fatores
---- que nao tem 100 no meio da faixa, use Rat_ScaleTag com a qualidade calculada na mao.
function Rat_PctTag(v)
    if not v then
        return Untranslated("")
    end
    if v == 100 then
        return Untranslated("100%")
    end
    return Rat_ScaleTag(v .. "%", v > 100 and 0 or 100)
end

---- Fator que NUNCA fica melhor que neutro (Marksmanship: vive em [100, SkillMax]). Verde so
---- em 100; acima disso o gradiente para no ambar, por pior que seja o `worst`. Deixar chegar
---- ao verde diria que o fator esta ajudando, quando ele so esta atrapalhando menos.
function Rat_PctTagPenaltyOnly(v, worst)
    if not v then
        return Untranslated("")
    end
    if v <= 100 then
        ---- 100 e o MELHOR caso possivel aqui, entao ganha verde -- nao e neutro como no Rat_PctTag
        return Rat_ScaleTag(v .. "%", 100)
    end
    local span = Max(1, (worst or 200) - 100)
    local quality = 50 - Clamp(MulDivRound(v - 100, 50, span), 0, 50)
    return Rat_ScaleTag(v .. "%", quality)
end

---- Espelho do anterior, para fator que NUNCA fica pior que neutro (decay da mira: vive em
---- [DecayMinPct, 100]). Vermelho nunca aparece -- mirar no pior caso so deixa de ajudar,
---- nao atrapalha. 100 = ambar ("nao rende nada"), `best` = verde.
function Rat_PctTagBonusOnly(v, best)
    if not v then
        return Untranslated("")
    end
    if v >= 100 then
        return Rat_ScaleTag(v .. "%", 50)
    end
    local span = Max(1, 100 - (best or 0))
    local quality = 50 + Clamp(MulDivRound(100 - v, 50, span), 0, 50)
    return Rat_ScaleTag(v .. "%", quality)
end

---- Fator de cone, gradiente CONTINUO dos dois lados -- a MESMA escala do snapshot, agora com
---- lado verde tambem: A.MetaScaleWorst e o vermelho cheio, 100 o ambar (neutro), A.MetaScaleBest
---- o verde cheio. Qualidade linear em cada metade. Usar onde o fator e so um multiplicador de
---- cone (Weapon, Marksmanship, Sight, cada nivel de mira, Hipfire/Snapshot, residuais, Total).
function Rat_ConeMulTag(v, best, worst)
    if not v then
        return Untranslated("")
    end
    if v == 100 then
        return Untranslated("100%")
    end
    local a = const.Combat.Aperture
    best = best or a.MetaScaleBest or 50
    worst = worst or a.MetaScaleWorst or 350
    local quality
    if v < 100 then
        local span = Max(1, 100 - best)
        quality = 50 + Clamp(MulDivRound(100 - v, 50, span), 0, 50)
    else
        local span = Max(1, worst - 100)
        quality = 50 - Clamp(MulDivRound(v - 100, 50, span), 0, 50)
    end
    return Rat_ScaleTag(v .. "%", quality)
end

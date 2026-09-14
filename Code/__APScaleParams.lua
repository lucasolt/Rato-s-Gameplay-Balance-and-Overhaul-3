-- Raw AP per displayed AP. Raw values never change; vanilla presets and the pathfinder stay at 1000 per vanilla AP.
const.Scale.AP = 100
const.Combat.R_VanillaAPRaw = 1000

-- n AP of the vanilla economy (APStance, bolt cycling, aim level) -> raw. Numbers already in displayed AP use n * const.Scale.AP.
function R_VanillaAP(n)
    return n * const.Combat.R_VanillaAPRaw
end

-- Float-safe: recoil aim cost comes in 0.5 steps.
function R_VanillaAPToDisplay(n)
    if math.type(n) == "float" then
        return n * const.Combat.R_VanillaAPRaw / const.Scale.AP
    end
    return MulDivRound(n, const.Combat.R_VanillaAPRaw, const.Scale.AP)
end

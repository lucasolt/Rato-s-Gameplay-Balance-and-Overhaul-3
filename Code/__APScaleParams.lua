-- Raw AP per displayed AP. Raw values never change; vanilla presets and the pathfinder stay at 1000 per vanilla AP.
const.Scale.AP = 100
const.Combat.R_VanillaAPRaw = 1000
-- Heavy Weapons perk: shooting stance discount for MGs/heavy weapons, in displayed AP.
const.Combat.HeavyWeaponsStanceReduction = 5
-- Carried MG attacks, in displayed AP; the Heavy Weapons perk's attack discount cancels it.
const.Combat.MGAttackAPSurcharge = 10
-- Shooting stance surcharge for a gun braced on its bipod, prone, in displayed AP.
const.Combat.BipodProneStanceAP = 5

-- n AP of the vanilla economy (APStance, bolt cycling, aim level) -> raw. Numbers already in displayed AP use n * const.Scale.AP.
function R_VanillaAP(n)
    return n * const.Combat.R_VanillaAPRaw
end

-- Float-safe: some vanilla AP params are fractional.
function R_VanillaAPToDisplay(n)
    if math.type(n) == "float" then
        return n * const.Combat.R_VanillaAPRaw / const.Scale.AP
    end
    return MulDivRound(n, const.Combat.R_VanillaAPRaw, const.Scale.AP)
end

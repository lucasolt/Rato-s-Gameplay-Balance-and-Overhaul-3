---------------------------------------------------------------------------------------------------
---- JAM AND WEAR  --  parameters for `SOURCE_ReliabilityAndJam.lua`
----
---- Reliability = resistance to jamming when dirty. Wear has its own constants and ignores it.
---- Vanilla: jam = (100 - Condition) / 4, and each round rolled > Reliability for -DegradePerShot.
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---- JAM:  jam% = (100 - Condition) * JamSlopePct/100 * (100 - Reliability) / JamRelRef
----   C70: AK47 3, FNFAL 7, G11 10   C40: AK47 6, FNFAL 13, G11 19   C20: AK47 8, FNFAL 17, G11 25
---------------------------------------------------------------------------------------------------

-- 25 reproduces vanilla's /4 at the reference Reliability.
const.Weapons.JamSlopePct = 25

-- Reliability deficit worth x1 (R70 jams like vanilla); higher compresses the spread between guns.
const.Weapons.JamRelRef = 30

-- Hard cap per attack, after rain.
const.Weapons.JamChanceMax = 30

-- Rain bonus to jam chance, in %. Own const so vanilla's RainJamChanceMod (100) stays untouched.
const.Weapons.RainJamPct = 50

-- Per-round jam: each round after the first rolls at this % of the jam chance; a jam on round k fires k-1.
-- Burst totals at a 5% chance: 3 rounds ~7%, 6 ~10%, 10 ~13%, 25 ~22%.
const.Weapons.JamExtraShotPct = 20

-- ms after the last fired round before a mid-burst jam (FX, log, text); too short and the burst masks the sound.
const.Weapons.JamFXDelay = 50

-- Volume of the guns' own jam sounds (empty_* banks, base 80, cap 300). Live: set it, then Rat_ApplyJamSoundVolume().
const.Weapons.JamSoundVolumePct = 200

-- Jams roll only below this Condition. 100 = continuous ramp (vanilla cliff was 70, ItemConditionUsed).
const.Weapons.JamConditionGate = 100

---------------------------------------------------------------------------------------------------
---- WEAR:  per attack, `rolls` tries at DegradeChancePct * ConditionDegradationRate/100 to lose
---- DegradePerShot.  rolls = 1 + (num_shots - 1) * ExtraShotDegradePct / 100
----   per round: single 0.20, 6-round burst 0.13, 10-round 0.12  (single/auto ratio ~1.6)
---------------------------------------------------------------------------------------------------

const.Weapons.DegradeChancePct = 20

-- Share of each round after the first; 100 = vanilla linear.
const.Weapons.ExtraShotDegradePct = 60

-- Rain bonus to the wear roll chance, in %. Replaces vanilla's RainConditionLossMod (100, on the loss).
const.Weapons.RainWearPct = 50

---------------------------------------------------------------------------------------------------
---- FAILED UNJAM (engine Unjam): loss = Min(Max, Max(Min, gap) / Divisor), gap = (100-C)+(100-R)-Mechanical
----   gap 15 -> 3, 30 -> 5, 36+ -> 6.  Vanilla 3/3/16 broke dirty guns in low-Mechanical hands.
---------------------------------------------------------------------------------------------------

const.Weapons.JamConditionLossMin = 3
const.Weapons.JamConditionLossDivisor = 6
const.Weapons.JamConditionLossMax = 6

-- AI gate: `const.Weapons.WearAppliesToAI` (nil = AI never jams nor wears, vanilla). Set by Rato's AI
-- Overhaul; not defaulted here because mod code doesn't load in dependency order and would overwrite it.

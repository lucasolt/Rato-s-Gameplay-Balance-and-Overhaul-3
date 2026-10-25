---------------------------------------------------------------------------------------------------
---- EMPERRAMENTO E DESGASTE  --  reescrita de `GetJamChance` e `ReliabilityCheck`
----
---- Parametros e o racional completo do redesenho estao em `__JamParams.lua`. Resumo: `Reliability`
---- deixa de ser velocidade de desgaste e vira resistencia a emperrar; o desgaste passa a ter
---- constante propria e a escalar de forma SUBLINEAR com o numero de balas.
----
---- Original: `Lua/Tactical/Weapon.lua:922` (GetJamChance) e `:934` (ReliabilityCheck).
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---- jam_chance = d * JamSlopePct/100 * (100 - Reliability) / JamRelRef * sqrt(d / JamCurveRef)
----
---- Multiplicativa e ANCORADA de proposito, em vez de somar os dois deficits: assim uma arma
---- confiavel continua confiavel mesmo bem suja (o Mosin a 96 fica em ~3% ate Condition 20), que e
---- exatamente o comportamento que se quer representar. Somar deficits faria toda arma convergir
---- para o mesmo patamar ruim conforme a condicao caisse, apagando a identidade do modelo.
----
---- O teto e aplicado DEPOIS da chuva, entao ele e um limite duro do que o jogador pode sofrer num
---- ataque -- inclusive debaixo de temporal.
---------------------------------------------------------------------------------------------------
function FirearmBase:GetJamChance(attacker, condition)
    local deficit_cond = 100 - (condition or 100)
    if deficit_cond <= 0 then
        return 0
    end

    ---- `Reliability` ausente ou 100 => deficit 0 => nunca emperra. Mesma leitura do vanilla para
    ---- itens sem a property (facas, explosivos, veiculos: todos ja vinham com 100).
    local deficit_rel = Max(0, 100 - (self.Reliability or 100))
    -- linear term x sqrt(deficit / JamCurveRef): power 1.5, equal to the linear curve at the ref
    local ref = Max(1, const.Weapons.JamCurveRef)
    local chance = MulDivRound(deficit_cond * const.Weapons.JamSlopePct * deficit_rel, sqrt(deficit_cond * 10000),
        100 * Max(1, const.Weapons.JamRelRef) * sqrt(ref * 10000))

    if (GameState.RainHeavy or GameState.RainLight) and not attacker.indoors then
        chance = MulDivRound(chance, 100 + const.Weapons.RainJamPct, 100)
    end

    return Min(chance, const.Weapons.JamChanceMax)
end

---------------------------------------------------------------------------------------------------
---- DUAS MUDANCAS DE COMPORTAMENTO ALEM DA FORMULA, ambas deliberadas:
----
---- 1. `jam_roll <= jam_chance` (o vanilla usava `<`). Com `<`, uma chance de 1% era 0% na pratica
----    -- a rolagem e `1 + Random(100)`, ou seja 1..100, e nada e menor que 1. A formula nova
----    produz justamente valores baixos (1-4%) para as armas boas, e sob o operador antigo essa
----    faixa inteira seria silenciosamente inerte.
----
---- 2. O laco de desgaste roda `balas_efetivas` vezes, nao `num_shots` vezes. Ver
----    `ExtraShotDegradePct` em `__JamParams.lua`.
----
---- CONSEQUENCIA DE SINCRONIA: o numero de chamadas a `attacker:Random` por ataque mudou. Isso
---- desloca a sequencia de RNG sincronizada, entao todos os jogadores de uma partida em rede
---- precisam da MESMA versao deste mod -- o que ja vale para qualquer mudanca de balanceamento
---- aqui, mas aqui e mais facil de esquecer porque a mudanca nao e visivel na UI.
---------------------------------------------------------------------------------------------------

function FirearmBase:GetBaseDegradePerShot()
	return MulDivRound(const.Weapons.DegradePerShot, self.ConditionDegradationRate or 100, 100)
end

-- testing: a round number forces every burst that long (player/wear-subject attacks) to jam on it
Rat_ForceJamRound = false

---- 3rd return: rounds fired before a mid-burst jam (per_round only; 0 = jammed on the first round).
---- HeavyWeapon passes jam_roll as the 3rd arg; harmless, its num_shots is 1.
function FirearmBase:ReliabilityCheck(attacker, num_shots, per_round)
    local item = self.parent_weapon or self
    local loss = const.Weapons.DegradePerShot
    -- rate and rain scale the roll, not the loss: a 1-point loss rounds any rate back to 1
    local degrade_chance = MulDivRound(const.Weapons.DegradeChancePct, item.ConditionDegradationRate or 100, 100)
    if (GameState.RainHeavy or GameState.RainLight) and not attacker.indoors then
        degrade_chance = MulDivRound(degrade_chance, 100 + const.Weapons.RainWearPct, 100)
    end
    local condition = item.Condition

    ---- termo do vanilla era `attacker.team.control ~= "AI"`, sem valvula. Ver o portao da IA em
    ---- `__JamParams.lua`.
    local player_controlled = attacker.team and attacker.team.control ~= "AI"
    local subject_to_wear = player_controlled or const.Weapons.WearAppliesToAI == true

    local jammed, jam_fired
    if not attacker.infinite_condition and attacker.team and subject_to_wear and
        not attacker:HasStatusEffect("ManningEmplacement") then
        local shots = num_shots or 1
        local jam_chance = item:GetJamChance(attacker, condition)
        local jam_roll = 1 + attacker:Random(100)
        local can_jam = item.num_safe_attacks <= 0 and condition < const.Weapons.JamConditionGate
        if Rat_ForceJamRound and per_round and shots >= Rat_ForceJamRound then
            jammed, jam_fired = true, Rat_ForceJamRound - 1
        elseif can_jam and jam_roll <= jam_chance then
            jammed, jam_fired = true, 0
        elseif can_jam and per_round and shots > 1 then
            -- per-mille: 20% of a 1-3% chance must not round to 0
            local extra_chance = MulDivRound(jam_chance * 10, const.Weapons.JamExtraShotPct, 100)
            for i = 2, shots do
                if 1 + attacker:Random(1000) <= extra_chance then
                    jammed, jam_fired = true, i - 1
                    break
                end
            end
        end

        local fired = jam_fired or shots
        if fired > 0 then
            ---- balas EFETIVAS: a primeira conta inteira, cada uma depois conta uma fracao
            local rolls = 1 + MulDivRound(fired - 1, const.Weapons.ExtraShotDegradePct, 100)
            for i = 1, rolls do
                local condition_roll = 1 + attacker:Random(100)
                if condition_roll <= degrade_chance then
                    condition = Max(0, condition - loss)
                end
            end
        end
    end
    return jammed, condition, jam_fired
end

---- Engine copy (Weapon.lua:1488) + per_round: a mid-burst jam fires the rounds before it.
function Firearm:PrecalcAmmoUse(attacker, num, prediction, per_round)
    local fired = num
    local jammed, condition, jam_fired
    if not prediction then
        local shots = (self.ammo and not attacker.infinite_ammo) and Min(num, self.ammo.Amount) or num
        jammed, condition, jam_fired = self:ReliabilityCheck(attacker, shots, per_round)
    end

    local ammo_type = self.ammo and self.ammo.class
    if (jammed and (jam_fired or 0) <= 0) or (not attacker.infinite_ammo and not self.ammo) then
        fired = false
    elseif jammed then
        fired = jam_fired
    elseif self.ammo and self.ammo.Amount < num then
        fired = self.ammo.Amount
    end

    return fired, jammed, condition, ammo_type
end

---- the WeaponJam FX banks (used by nothing else); base volume kept so reapplying doesn't compound
local jam_sounds = {"empty_machinegun", "empty_mortar", "empty_pistol", "empty_revolver", "empty_rifle",
                    "empty_rocketlauncher", "empty_shotgun", "empty_sniper", "empty_submachine"}

function Rat_ApplyJamSoundVolume()
    for _, id in ipairs(jam_sounds) do
        local preset = SoundPresets[id]
        if preset then
            preset.rat_base_volume = preset.rat_base_volume or preset.volume
            preset.volume = Min(300, MulDivRound(preset.rat_base_volume, const.Weapons.JamSoundVolumePct, 100))
            LoadSoundBank(preset)
        end
    end
end

OnMsg.DataLoaded = Rat_ApplyJamSoundVolume
OnMsg.ModsReloaded = Rat_ApplyJamSoundVolume

local jam_refund_actions ={AutoFire = true, BurstFire = true, MGBurstFire = true}

---- a jammed burst pays only for the rounds that left the barrel (a first-round jam pays a single shot)
function Rat_RefundJammedRounds(unit, action, results, attack_args, cost_ap)
    local planned = attack_args and attack_args.num_shots or 0
    if not (action and jam_refund_actions[action.id] and results.jammed and planned > 1 and (cost_ap or 0) > 0) then
        return
    end
    local weapon = results.weapon
    local fired = Max(1, results.fired or 0)
    local refund = Rat_AutoExtraAP(action, weapon, planned) - Rat_AutoExtraAP(action, weapon, fired)
    refund = Clamp(refund, 0, cost_ap)
    if refund > 0 then
        unit:GainAP(refund)
    end
end

function Rat_ApplyPendingJam(weapon)
    local unit = weapon and weapon.rat_pending_jam
    if not unit then
        return
    end
    weapon.rat_pending_jam = nil
    weapon:Jam(unit)
    Msg("InventoryChange", unit)
end

---- vanilla spends no ammo on a jammed attack; a mid-burst jam spends `fired` rounds and jams after
---- the last one (ExecFirearmAttacks), not at anim start where ApplyAmmoUse runs
local Rat_ApplyAmmoUseOrig = Firearm.ApplyAmmoUse
function Firearm:ApplyAmmoUse(attacker, fired, jammed, condition)
    if not (jammed and fired) then
        return Rat_ApplyAmmoUseOrig(self, attacker, fired, jammed, condition)
    end
    Rat_ApplyAmmoUseOrig(self, attacker, fired, false, condition)
    self.rat_pending_jam = attacker
    -- fallback for attack paths that never reach the burst-end hook
    CreateGameTimeThread(function(weapon)
        WaitMsg("CombatActionEnd", 10000)
        Rat_ApplyPendingJam(weapon)
    end, self)
end

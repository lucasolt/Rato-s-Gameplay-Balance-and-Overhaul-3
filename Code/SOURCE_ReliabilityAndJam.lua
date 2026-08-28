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
---- jam_chance = (100 - Condition) * JamSlopePct/100 * (100 - Reliability) / JamRelRef
----
---- Multiplicativa e ANCORADA de proposito, em vez de somar os dois deficits: assim uma arma
---- confiavel continua confiavel mesmo bem suja (a AK a 95 fica em ~2-3% ate Condition 20), que e
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

    local base = MulDivRound(deficit_cond, const.Weapons.JamSlopePct, 100)

    ---- `Reliability` ausente ou 100 => deficit 0 => nunca emperra. Mesma leitura do vanilla para
    ---- itens sem a property (facas, explosivos, veiculos: todos ja vinham com 100).
    local deficit_rel = Max(0, 100 - (self.Reliability or 100))
    local chance = MulDivRound(base, deficit_rel, Max(1, const.Weapons.JamRelRef))

    if (GameState.RainHeavy or GameState.RainLight) and not attacker.indoors then
        chance = MulDivRound(chance, 100 + const.EnvEffects.RainJamChanceMod, 100)
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
function FirearmBase:ReliabilityCheck(attacker, num_shots)
    local item = self.parent_weapon or self
    local loss = item:GetBaseDegradePerShot()
    if (GameState.RainHeavy or GameState.RainLight) and not attacker.indoors then
        loss = MulDivRound(loss, 100 + const.EnvEffects.RainConditionLossMod, 100)
    end
    local condition = item.Condition

    ---- termo do vanilla era `attacker.team.control ~= "AI"`, sem valvula. Ver o portao da IA em
    ---- `__JamParams.lua`.
    local player_controlled = attacker.team and attacker.team.control ~= "AI"
    local subject_to_wear = player_controlled or const.Weapons.WearAppliesToAI

    local jammed
    if not attacker.infinite_condition and attacker.team and subject_to_wear and
        not attacker:HasStatusEffect("ManningEmplacement") then
        -- jam check once per attack
        local jam_chance = item:GetJamChance(attacker, condition)
        local jam_roll = 1 + attacker:Random(100)
        if item.num_safe_attacks <= 0 and condition < const.Weapons.JamConditionGate and jam_roll <=
            jam_chance then
            jammed = true
        end

        if not jammed then
            ---- balas EFETIVAS: a primeira conta inteira, cada uma depois conta uma fracao
            local extra = Max(0, (num_shots or 1) - 1)
            local rolls = 1 + MulDivRound(extra, const.Weapons.ExtraShotDegradePct, 100)
            for i = 1, rolls do
                local condition_roll = 1 + attacker:Random(100)
                if condition_roll <= const.Weapons.DegradeChancePct then
                    condition = Max(0, condition - loss)
                end
            end
        end
    end
    return jammed, condition
end

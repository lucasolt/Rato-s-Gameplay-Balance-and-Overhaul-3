---------------------------------------------------------------------------------------------------
---- EMPERRAMENTO E DESGASTE  --  parametros
----
---- Acompanha `SOURCE_ReliabilityAndJam.lua`, que reescreve `FirearmBase:GetJamChance` e
---- `FirearmBase:ReliabilityCheck`.
----
---- O QUE MUDOU EM RELACAO AO VANILLA, em uma frase: `Reliability` deixa de ser "velocidade de
---- desgaste" e passa a ser "resistencia a emperrar com a arma suja", que e o que o nome promete ao
---- jogador. O desgaste passa a ser governado por constante propria.
----
---- O VANILLA FAZIA:
----     jam_chance = (100 - Condition) / 4                  -- Reliability AUSENTE
----     por BALA: se rolagem > Reliability entao Condition -= DegradePerShot
----
---- Consequencia daquele desenho: `Reliability` so controlava desgaste, e desgaste multiplicava
---- pelo numero de balas do ataque. Por isso os valores herdados estavam calibrados como taxa de
---- desgaste e nao como confiabilidade -- armas de tiro unico e pente pequeno (Gewehr98 25,
---- BarretM82 10, M24Sniper 44) recebiam valores baixissimos so para desgastarem alguma coisa,
---- invertendo a realidade (um ferrolho Mauser e dos mecanismos mais confiaveis que existem).
---- Ao desacoplar as duas coisas, esses valores ficam livres para significar o que dizem.
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---- JAM
---------------------------------------------------------------------------------------------------

---- Inclinacao por ponto de Condition perdido. 25 reproduz o `/4` do vanilla.
---- Sobe -> arma suja emperra mais, para TODAS as armas igualmente.
const.Weapons.JamSlopePct = 40

---- O dial que importa: o DEFICIT de Reliability que vale multiplicador x1.
----   jam_chance = base_por_condicao * (100 - Reliability) / JamRelRef
----
---- 40 significa: uma arma de Reliability 60 se comporta como o vanilla; acima disso emperra menos,
---- abaixo emperra mais. E tambem o dial de COMPRESSAO da escala -- quanto maior, menos as armas se
---- diferenciam entre si:
----     25 -> escala esticada, exige valores de Reliability na faixa 70-98 para nao saturar
----     40 -> recomendado; a faixa 62-95 rende AK ~2% e FNFAL ~11% em Condition 40
----     60 -> escala achatada, a faixa herdada 10-100 continua utilizavel sem retune
const.Weapons.JamRelRef = 20

---- Teto duro da chance de emperrar por ataque, ja com a chuva aplicada. Rede de seguranca: impede
---- que uma arma muito ruim e muito suja vire injogavel, e evita que um valor de Reliability mal
---- calibrado exploda em campo.
const.Weapons.JamChanceMax = 30

---- Piso de Condition abaixo do qual o sorteio de jam acontece. 70 e o valor do vanilla
---- (`ItemConditionUsed`), replicado aqui como constante PROPRIA de proposito: `ItemConditionUsed`
---- tambem controla o rotulo "Used" do item na UI, e mudar um nao deveria mexer no outro.
----
---- Subir para 100 remove o penhasco e faz o jam virar gradiente continuo (arma em Condition 85
---- passa a emperrar raramente em vez de nunca). Com a formula nova isso e coerente, porque a
---- chance ja tende a zero sozinha conforme a Condition sobe.
const.Weapons.JamConditionGate = 70

---------------------------------------------------------------------------------------------------
---- DESGASTE
---------------------------------------------------------------------------------------------------

---- Chance, por "bala efetiva", de perder `GetBaseDegradePerShot()` de Condition.
---- Substitui o antigo `100 - Reliability`. 25 iguala o desgaste de tiro unico de uma arma que
---- tinha Reliability 75 no desenho antigo.
const.Weapons.DegradeChancePct = 25

---- Quanto cada bala ALEM DA PRIMEIRA conta para desgaste, em %.
----     balas_efetivas = 1 + (num_shots - 1) * ExtraShotDegradePct / 100
----
---- Existe porque no vanilla o desgaste era estritamente linear no numero de balas: uma rajada de
---- 10 gastava 10x um tiro unico, o que fazia metralhadora se autodestruir. Automatica deve
---- desgastar MAIS, nao 10x mais.
----     15 -> rajada de 10 desgasta ~2x um tiro unico   (recomendado)
----     25 -> ~3x
----    100 -> comportamento linear do vanilla
const.Weapons.ExtraShotDegradePct = 40

---------------------------------------------------------------------------------------------------
---- PORTAO DA IA
----
---- No vanilla, `ReliabilityCheck` inteira estava dentro de `attacker.team.control ~= "AI"`: arma de
---- inimigo NUNCA emperrava e NUNCA perdia condicao. Nao era ausencia de mecanismo, era exclusao
---- explicita.
----
---- Default `false` = comportamento vanilla, para que o GBO3 sozinho nao mude a dificuldade sem
---- pedido. Quem liga e o *Rato's AI Overhaul* (`SOURCE_ReliabilityCheck.lua` la), que carrega
---- depois deste mod e cuja proposta declarada e justamente por a IA sob as mesmas regras do
---- jogador.
----
---- EFEITO COLATERAL A CONSIDERAR AO LIGAR: o mesmo portao governa jam E perda de Condition, entao
---- ligar faz a arma saqueada de um inimigo que lutou muito vir em condicao pior. E mudanca de
---- economia de loot, nao so de dificuldade.
---------------------------------------------------------------------------------------------------
const.Weapons.WearAppliesToAI = false

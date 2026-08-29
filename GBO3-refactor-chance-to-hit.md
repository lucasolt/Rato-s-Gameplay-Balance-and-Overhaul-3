# GBO3 · Refactor de Chance to Hit

**Modelo de Abertura**

Trocar "Marksmanship é a precisão" por "Marksmanship define um cone, e a distância decide se o alvo cabe nele". O CTH deixa de ser um número somado e passa a ser uma consequência geométrica — sem reescrever o pipeline do jogo.

*Rato's GBO3 v3.58 — 17.217 linhas em Code/ — 45 armas analisadas — Nada implementado ainda.*

---

## Diagnóstico

### De onde vem o excesso de precisão

O CTH final é a soma de `ChanceToHitModifier` independentes, resolvida em `Unit:CalcChanceToHit` e consumida em `SOURCE_FirearmGetAttackResults.lua:110`. Dois traços estruturais produzem a sensação de tiroteio curto demais:

- **Marksmanship entra cru.** No preset Accuracy a base é literalmente `weapon1.UnitStat`. Marks 100 = 100% de base, em qualquer distância. O `_R_Mod_Setting` (`CTH_Setting.lua:12`) adiciona um multiplicador global, mas ele é flat: sobe ou desce a régua inteira sem mudar o formato da curva.

- **A distância para de existir na mira alta.** As penalidades de distância vivem só no hipfire (aim 0) e no snapshot (aim 1–2), em `CTH_hipfire_and_snapshot.lua`. A partir de `aim >= 3` a função retorna cedo e nenhuma curva de distância se aplica. Um merc mirado acerta a 35 tiles com a mesma facilidade que a 5.

O resultado é o inverso da intuição do jogador: especialistas mirados acertam quase tudo em qualquer alcance, enquanto o tiro de perto — onde há poucos AP para investir em mira — é justamente o que mais erra.

---

## Viabilidade

### NCTH puro custa caro porque o pipeline é invertido

Em `SOURCE_FirearmGetAttackResults.lua:345`, `num_hits` e `num_misses` são entrada de `CalcShotVectors`, não saída. O jogo rola o dado primeiro e depois fabrica a geometria que encena o resultado já decidido — as linhas 403–426 puxam um vetor de `hit_target_pts` ou `miss_target_pts` conforme `shot_miss`. NCTH é o contrário: cone, ponto aleatório, raycast, e o que acertou acertou.

Três desenhos possíveis:

1. **Atual:** modifiers % → CTH somado → rola o dado → geometria encenada.
2. **NCTH puro:** cone de abertura → ponto no cone → raycast real → acertou ou não. Problema: UI e IA ficam sem %.
3. **Híbrido:** cone de abertura → cone vs silhueta → CTH derivado → pipeline atual intacto.

O híbrido troca só a origem do número. A partir do quarto bloco tudo é código que já existe e já está testado — dado, dano, body parts, netcode e IA seguem inalterados.

Mas a parte difícil já está escrita. O `FUNCTION_GetPelletScatterData.lua:54` é simulação balística genuína: θ aleatório, raio dentro de um cone derivado de `aoe_params.cone_angle`, vetor real, `GetLoFData` decide o que foi atingido. Zero rolagem de CTH. É o modelo de abertura do 1.13, já funcionando e já tunado empiricamente (os dados de choke e barrel nos comentários do arquivo).

### O custo do NCTH puro não está na balística — está em tudo que consome um percentual

| Consumidor | Por que quebra |
|---|---|
| UI / crosshair | Precisa do % antes do tiro. A linha 491 avisa: dispersão usa random sincronizado, rodar isso da UI causa desync |
| IA | O comentário em `CTH_hipfire_and_snapshot.lua:36` documenta o `AIPrecalcConeTargetZones` descartando alvos com CTH 0 |
| Netcode | `NetUpdateHash` nas linhas 318 e 916. Co-op é lockstep: qualquer float na geometria vira desync |
| Os 15 `CTH_*.lua` | Todos retornam ±% flat. Virariam modificadores de ângulo — é reescrever a camada onde mora todo o balance |
| Tiro em body part | Hoje se paga AP por um CTH de cabeça. Em NCTH a bala vai onde a física mandar — é problema de design, não de código |

---

## O mecanismo

### Cone contra silhueta

A abertura é um cone de dispersão com vértice na arma. O alvo tem tamanho físico constante. Conforme a distância cresce, o cone se abre e o alvo não — então a fração do cone que cai sobre o alvo despenca sozinha. Nenhuma curva precisa ser desenhada à mão.

- A 3 tiles, com cone de quadril (aim 0), o alvo é maior que o cone: ~80% de chance.
- A 25 tiles, o alvo fica menor que o cone de quadril: ~2%. Com mira alta (cone mirado, aim 4): ~86%.

Mirar não soma pontos: estreita o cone. Perto, o alvo já é maior que qualquer cone — mirar quase não muda nada. Longe, o cone é a restrição, e cada nível de mira compra alcance efetivo. É a dinâmica de gasto de AP que o refactor procura, emergindo da geometria em vez de ser tabelada.

---

## A pergunta do ângulo

### OverwatchAngle não serve como abertura — e não precisa servir

Os ângulos da shooting stance são "quanto maior melhor": definem o setor que a arma cobre antes de gastar AP rotacionando. Semanticamente é o oposto de uma abertura NCTH, onde maior significa pior. A pergunta é se dá para derivar um do outro. Não dá, e os dados do próprio arsenal mostram por quê:

| Arma | AimAccuracy | OverwatchAngle | Leitura |
|---|---|---|---|
| MG42 | 2 | 571 | Pesada, setor estreito, imprecisa |
| PSG1 | 9 | 596 | Ângulo quase idêntico, precisão no extremo oposto |
| BrowningM2HMG | 2 | 3600 | O maior setor de todos, a menor precisão |
| ColtAnaconda | 5 | 2118 | Revólver: setor largo, precisão média |

Correlações sobre 45 armas:

- AimAccuracy × OverwatchAngle: **−0,374** (fraca; o ângulo explica ~14% da variância de precisão)
- AimAccuracy × WeaponRange: **+0,410** (também fraca)
- WeaponRange × OverwatchAngle: **−0,427** (driver comum é "bulk", mas sozinho não determina precisão)

Nenhum dos três eixos é redundante. A saída é melhor que inventar um quarto stat: os três eixos já existentes ancoram pontos diferentes da mesma curva de abertura, e a polaridade "maior é melhor" do OverwatchAngle se preserva intacta.

- **OverwatchAngle → cone de quadril.** Manejo. Arma leve e curta aponta rápido: hipfire melhor. Maior continua sendo melhor.
- **AimAccuracy → redução por nível de mira.** É exatamente o que o stat já significa hoje ("quanto um nível de mira compra"), só expresso como fator multiplicativo no ângulo em vez de pontos somados.
- **WeaponRange → piso mecânico.** O cone mais fechado que a arma alcança, por melhor que seja o atirador. Dá ao stat o sentido que ele deveria ter: até onde a arma foi projetada para chegar.

Um UZI fica com hipfire ótimo e teto mirado baixo. Uma PSG1 fica com hipfire ruim e teto mirado altíssimo. A MG42 fica ruim nos dois — o que é correto: ela vence por volume, não por precisão. Toda a tabela de armas já codifica isso; nada precisa ser reescrito.

---

## Fórmula

### Aritmética inteira, em minutos de ângulo

O engine já trabalha em minutos (`max_angle_offset = 360 * 60` no código de pellets; `MGSetupConeFlat` comentado como "minutes"). Um radiano são 3438 minutos, o que dá a conversão sem trigonometria e sem float — requisito duro por causa do `NetUpdateHash`.

```lua
-- silhueta: meia-largura aparente do alvo, em minutos
local function theta_target(dist, half_cm)
    return Max(1, MulDivRound(half_cm, 3438, dist))
end

-- 1. manejo (OverwatchAngle) define o cone de quadril
local function f_handling(ow)
    local h = Clamp(MulDivRound(ow - 545, 100, 1755), 0, 100)
    return 135 - MulDivRound(55, h, 100)      -- x1.35 pesada .. x0.80 manejavel
end

-- 2. Marksmanship escala o cone inteiro
local function f_skill(marks)
    return 280 - MulDivRound(180, marks, 100)  -- x2.80 (Marks 0) .. x1.00 (Marks 100)
end

-- 3. AimAccuracy define quanto CADA nivel de mira fecha o cone
local function aim_decay(acc)
    return 100 - (8 + 4 * acc)                 -- 84% (acc 2) .. 56% (acc 9)
end

local function rat_aperture(weapon, attacker, aim)
    local s = MulDivRound(const.Combat.Aperture.HipBase, f_handling(weapon.OverwatchAngle), 100)
    s = MulDivRound(s, f_skill(attacker.Marksmanship), 100)
    for i = 1, aim do
        s = MulDivRound(s, aim_decay(weapon.AimAccuracy), 100)
    end
    -- 4. piso mecanico vindo do WeaponRange (scopes rebaixam este piso)
    local floor = MulDivRound(theta_target(weapon.WeaponRange * const.SlabSizeX, 25),
                              const.Combat.Aperture.FloorPct, 100)
    return Max(floor, s)
end
```

O CTH sai da razão entre silhueta e abertura. Uma distribuição de Rayleigh (o modelo correto para dispersão radial) dá `P = 1 − exp(−t²/2σ²)` — suave, assintótica a 100%, sem o degrau duro do modelo de disco uniforme. A exponencial vira uma LUT de ~32 entradas interpoladas: determinística, barata, sem float.

> **Calibrar antes de tunar.** Os números acima assumem `SlabSizeX ≈ 1,5 m` e torso de 25 cm de meia-largura. Não foi possível rodar o jogo para confirmar — medir `const.SlabSizeX` e o alvo real antes de levar as constantes a sério. Se o slab for diferente, `HipBase` escala junto e todas as tabelas abaixo se deslocam.

---

## Simulação

### O que a fórmula produz

Com `HipBase = 70` minutos (~1,17°), `FloorPct = 55`, atirador de Marks 85, contra torso:

| Arma | aim | 3t | 8t | 15t | 25t | 35t |
|---|---|---|---|---|---|---|
| PSG1 (sniper) | 0 | 73% | 17% | 5% | 2% | 1% |
| PSG1 | 2 | 100% | 86% | 43% | 17% | 9% |
| PSG1 | 4 | 100% | 100% | 100% | 86% | 65% |
| G36 (AR) | 0 | 80% | 20% | 6% | 2% | 1% |
| G36 | 4 | 100% | 100% | 81% | 42% | 25% |
| MP5 (SMG) | 0 | 87% | 24% | 8% | 3% | 1% |
| MP5 | 4 | 100% | 93% | 53% | 22% | 12% |
| MG42 (MG) | 0 | 72% | 16% | 5% | 2% | 1% |
| MG42 | 4 | 100% | 54% | 20% | 7% | 4% |

As três propriedades pedidas aparecem sozinhas. Perto perdoa: 72–87% mesmo sem mirar nenhum AP. Longe exige investimento: a PSG1 sai de 2% para 86% a 25 tiles só gastando mira. As classes se separam: a MP5 lidera o tiro de quadril, a PSG1 domina o alcance mirado, a MG42 é fraca nos dois eixos de precisão.

E os tiros em cabeça emergem da mesma geometria, trocando a silhueta de 25 cm por 9 cm — viáveis de perto, quase impossíveis longe sem óptica e mira alta, sem uma linha de código dedicada:

| Cabeça · Marks 85 | aim | 3t | 8t | 15t | 25t | 35t |
|---|---|---|---|---|---|---|
| PSG1 | 0 | 15% | 2% | 1% | 0% | 0% |
| PSG1 | 4 | 100% | 92% | 50% | 23% | 10% |
| MP5 | 4 | 91% | 28% | 8% | 3% | 1% |

> **Ponto de tuning em aberto.** O hipfire a 8 tiles (16–24%) provavelmente está punitivo demais para ser divertido. A queda é fisicamente correta — σ é constante em ângulo enquanto a silhueta cai com 1/d — mas essa é exatamente a faixa onde o jogador espera acertar às vezes. Amaciar via `HipBase` menor ou expoente mais suave que Rayleigh.

---

## Scopes

### O bônus de alcance vira gasto de AP

Hoje os scopes fazem duas coisas em paralelo: `RangeIncrease` e `MaxAimActionsIncrease` (o 6x dá +2, o PSO-1 e o 4x dão +1). No modelo de abertura essas duas viram a mesma coisa — alcance efetivo é consequência de cone fechado. Um cone estreito a 35 tiles é alcance.

Isso resolve o objetivo original: dá para remover o `RangeIncrease` e deixar o scope entregar alcance exclusivamente pelos níveis de mira extras. O benefício passa a ser inteiramente pago em AP, porque um nível de mira que não foi comprado não fecha cone nenhum.

> **Achado da simulação — o scope precisa de dois efeitos.** Testando a PSG1 a 35 tiles: aim 4 → 65%, aim 5 → 93%, aim 6 → 93%. O sexto nível não fez nada, porque o piso mecânico do `WeaponRange` já estava travando o cone. Níveis de mira extras só valem se houver espaço para eles trabalharem.

Ou seja, o scope tem que fazer duas coisas: `+MaxAimActions` (destrava o gasto de AP) e rebaixar o piso mecânico (dá espaço para o cone continuar fechando). Sem o segundo, o primeiro é desperdiçado — e essa é a conversão natural do `RangeIncrease` a ser removido.

O `ScopePenalty1/2/3` que já existe em `CTH_scope.lua` continua fazendo sentido e fica ainda mais coerente: a penalidade de curto alcance de uma óptica de alta magnificação vira um alargamento do cone abaixo da distância mínima do scope, em vez de um percentual solto.

---

## Recoil

### Alargar o cone em vez de subtrair pontos

Hoje o recoil vira `cth_loss_per_shot` e é subtraído linearmente por índice de tiro (`SOURCE_FirearmGetAttackResults.lua:260`), com teto em 6 tiros. É um número flat: tira os mesmos 8 pontos a 4 tiles e a 28 tiles.

No modelo de abertura o recoil faz o que fisicamente faz — abre o cone. E isso muda o comportamento de rajada de um jeito que o modelo atual não consegue expressar:

| AK47 · rajada · Marks 85 | tiro | 4t | 10t | 18t | 28t |
|---|---|---|---|---|---|
| Cone alargando 22%/tiro | 1 | 77% | 21% | 7% | 3% |
| | 3 | 51% | 11% | 3% | 1% |
| | 6 | 28% | 5% | 2% | 1% |
| Modelo atual, −8 flat/tiro | 1 | 62% | 62% | 62% | 62% |
| | 3 | 46% | 46% | 46% | 46% |
| | 6 | 22% | 22% | 22% | 22% |

A rajada de perto continua letal (77% → 28% ao longo de seis tiros) e a rajada longe morre no primeiro tiro (7% → 2%). É a separação entre fogo de supressão e fogo de precisão saindo da geometria, em vez de precisar ser tabelada por ação.

A migração é barata porque todo o recoil já é multiplicativo. `GetWepRecoil`, `GetRecoilOther` e `GetCaliberStrRecoil` encadeiam `mod = mod * ...` do começo ao fim — arma, calibre, mecanismo, ROF, postura, perks, componentes. Esse produto vira a taxa de crescimento do cone por tiro, e todos os valores relativos já tunados continuam significando a mesma coisa.

- Os breakpoints de Força por calibre sobrevivem com a mesma estrutura: passam a definir quão rápido o cone abre, não quantos pontos somem.
- O `Rat_recoil` persistente ganha sentido físico: além da sobretaxa de AP que já cobra, pode deixar o cone parcialmente aberto no início do próximo ataque — arma ainda não assentada. A sobretaxa de AP continua em cima, intacta.
- O `MultishotMinCTH = 5` deixa de ser necessário. Ele existe porque o CTH somado podia chegar a zero; a geometria nunca zera de perto sozinha.

---

## Cover

### De consulta de voxel para silhueta ocluída

Este é o maior ganho disponível, e o diagnóstico está inteiro na source vanilla. `PosGetCoverPercentageFrom` é C++ e faz uma consulta direcional por voxel — testa as quatro direções cardeais do slab procurando `coverLow`/`coverHigh` (`Lua/Tactical/Cover.lua:103`). Depois disso, duas camadas jogam fora o que sobrou de informação:

```lua
-- Lua/Tactical/Cover.lua:281 — low cover em pe simplesmente NAO EXISTE
if cover == coverLow and target_stance == "Standing" then
    cover, coverage = false, 0
end

-- Lua/Tactical/Unit.lua:8699 — e a porcentagem vira uma escada de 3 degraus
function InterpolateCoverEffect(coverage, full_value, exposed_value)
    local threshold = 40
    if coverage >= 80 then return full_value                 -- tudo igual
    elseif coverage < threshold then return exposed_value   -- tudo igual
    end
    return exposed_value + MulDivRound(full_value - exposed_value, coverage - threshold, threshold)
end
```

O engine calcula uma porcentagem de cobertura e o jogo a esmaga: abaixo de 40 e acima de 80 tudo vira o mesmo número, e o resultado final é o −35 flat do `CTH_cover_prone.lua:2`, idêntico a 4 ou a 28 tiles. Cobertura não sabe onde o corpo está, de que altura se atira, nem por qual ângulo.

No modelo de abertura, cobertura não é penalidade — é silhueta menor. E silhueta menor já é a única coisa que o modelo precisa saber.

**Exemplo ilustrativo (muro baixo, mesmo obstáculo):**
- No mesmo nível do muro: dos raios de sondagem, cerca de 2 livres e 4 bloqueados → exposto ~33%.
- De posição elevada, atirando por cima do mesmo muro: exposto ~67%.

Seis raios determinísticos contra pontos fixos da silhueta. Altura e ângulo de ataque deixam de precisar de script: a mesma cobertura vale metade quando se atira de cima, porque os raios simplesmente passam por cima do muro. Flanquear expõe mais silhueta pelo mesmo motivo.

A conversão para o CTH é uma linha: a fração exposta encolhe a silhueta angular, `theta_efetivo = theta_alvo × raiz(fracao_exposta)` — raiz porque a fração é de área e theta é um raio equivalente.

| AK47 · Marks 85 · aim 2 | exposto | 4t | 10t | 18t | 28t |
|---|---|---|---|---|---|
| Sem cobertura | 100% | 90% | 30% | 10% | 4% |
| Low cover, em pé | 60% | 74% | 19% | 6% | 2% |
| Low cover, agachado | 35% | 54% | 11% | 4% | 1% |
| Só a cabeça de fora | 15% | 28% | 5% | 1% | 1% |

Cobertura vale pouco de perto e muito de longe — a 4 tiles ela tira 16 pontos, a 10 tiles corta o CTH pela metade. É a razão pela qual avançar sob fogo é caro e vale a pena, e hoje o modelo flat não consegue dizer isso. E ficar em pé atrás de low cover deixa de valer exatamente zero, que é o comportamento mais artificial do sistema atual.

### Três níveis de fidelidade, cada um entregável sozinho

1. **Nível 1 — grátis.** Parar de passar `coverage` pelo `InterpolateCoverEffect` e usar `exposto = 100 − coverage` direto. O número já existe e já é calculado; só está sendo esmagado. Cobertura parcial passa a importar imediatamente.
2. **Nível 2 — a coisa de verdade.** Sondagem de silhueta: 6 a 9 raios em pontos fixos do corpo via `GetLoFData`, contando quantos chegam. É exatamente a máquina do `GetPelletScatterData` já escrita, usada como instrumento de medição em vez de fonte de dano.
3. **Nível 3 — cache.** Guardar o resultado por tupla `(attacker_pos, target, stance)`, invalidando em movimento, para o crosshair não re-raycastar a cada frame de hover.

> **Por que isto escapa do problema de desync.** O aviso da linha 491 ("dispersion uses synced random") é sobre random sincronizado, não sobre raycast. Raios de sondagem em pontos fixos e determinísticos não consomem random nenhum — então são seguros na previsão, onde o NCTH completo não é. Vale confirmar que `GetLoFData` não usa seed para mais nada nesse caminho, mas a distinção é o que torna o Nível 2 viável.

Dois efeitos colaterais que valem ser antecipados: o tiro em body part fica coerente de graça — mirar a cabeça de alguém cuja cabeça está atrás do muro deixa de ser um percentual, os raios daquela região simplesmente não chegam, generalizando o teste de bloqueio total que o jogo já faz. E a IA fica capaz de avaliar flanqueamento, porque a exposição passa a variar com a posição dela; é um ganho grande de comportamento e o principal risco de performance, já que o `AIPrecalcConeTargetZones` avalia muitas posições por turno. O cache do Nível 3 deixa de ser opcional aí.

---

## Migração

### Onde cada modifier existente vai parar

Os 15 arquivos `CTH_*.lua` não somem — se reclassificam em três baldes. A maioria vira multiplicador de cone, o que preserva a intenção de cada um e boa parte do tuning relativo.

- **Multiplicam o cone:** `hipfire_and_snapshot`, `bipod`, `rungun`, `held_mg`, `scope`, `2weaponfire`, e todo o `FUNCTIONS_recoil`.
- **Alteram a silhueta:** cobertura, alvo prone e agachado (partes de `cover_prone`), `SprintingCTH`. É o balde com o maior ganho — a postura do alvo passa a mudar o que está exposto, não a somar um número.
- **Continuam percentuais:** o que não é geométrico — `targeted_noburst`, bônus de perk, efeitos de status.

O `_R_Mod_Setting` pode continuar como dial global de dificuldade — só que agora escalando `f_skill` em vez de somar pontos, o que mantém a opção de mod já exposta em `CONSTANTS_mod_options.lua:36` funcionando com o mesmo significado para o jogador.

O `COMPATIBILITY_DescriptiveCTH.lua` e seu sistema de metaText precisam de atenção: não existe mais uma lista aditiva para exibir. A saída natural é reportar as contribuições em minutos de cone ("Hipfire +40′, Mira −180′"), o que na prática é mais legível que os pontos percentuais de hoje.

---

## Próximo passo

### Ordem de ataque sugerida

1. **Medir primeiro.** `const.SlabSizeX`, guim, e a silhueta real de uma unidade. Sem isso as constantes acima são chute informado.
2. **Prototipar como modifier isolado.** Um `ChanceToHitModifier` novo que retorna o CTH geométrico, com os antigos desligados por flag — fácil de comparar lado a lado e de reverter.
3. **Validar a IA cedo.** É o consumidor mais silencioso. Checar o `AIPrecalcConeTargetZones` e as signature actions antes de tunar qualquer número de balance.
4. **Cover pelo Nível 1 antes do Nível 2.** Trocar o `InterpolateCoverEffect` por `100 − coverage` é uma linha, não precisa de raycast nenhum e já mostra se a direção agrada. A sondagem de silhueta vem depois, com cache.
5. **Só então tunar.** `HipBase` e `FloorPct` movem tudo; a curva de hipfire em média distância é o primeiro alvo, e a taxa de crescimento do cone por tiro é o segundo.

Nada disso foi implementado — o repositório está intacto.

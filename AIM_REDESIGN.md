# AIM_REDESIGN.md — Mira como alcance, em vez de mira como CTH

*Direção de desenho, 2026-08-21. Não é plano de implementação — é a decisão que vem antes
dos números.*

Complementa o `DESIGN_MAP.md` (Sistemas 1, 4, 6 e 9). Este documento não redescreve os
sistemas; trata só da mudança de eixo e do que ela custa.

---

## O problema

**Mira e recoil disputam o mesmo eixo.** Os dois entram no CTH, somando e subtraindo do
mesmo número. Consequência prática: quando você sobe o recoil para tornar mira relevante
para quem usa rajada, você mexe nos dois ao mesmo tempo, e o resultado no jogo não
corresponde ao tamanho do ajuste.

Isso é o que faz a rajada parecer impossível de calibrar. Não é que os números estejam
errados — é que não existe um ponto onde uma intenção vire um número só.

Hoje há **três mecanismos** empurrando a mesma bala tardia para baixo:

1. recoil por bala (`cth_loss_per_shot`)
2. remoção do bônus de mira nas balas 2..N
3. pilhas de `Rat_recoil` entre ataques — no CTH **e** no custo de AP da mira

O (2) é o mais problemático dos três: não aparece em lugar nenhum da UI (o painel do
`XTEMP_recoil` mostra recoil, e isso não é recoil), e é plano — não diferencia arma,
calibre nem força, ao contrário do recoil.

---

## A proposta

**Cada clique de mira aumenta o alcance efetivo, em vez de dar +CTH.**

O que isso resolve, e resolve por estrutura e não por regra:

- **Mira deixa de ajudar rajada** automaticamente. O recoil já inviabiliza rajada a longa
  distância; se o prêmio de mirar é alcance, mirar uma rajada deixa de fazer sentido
  sozinho. A regra do item (2) acima **some**, porque virou consequência.
- **Os eixos se separam.** Recoil passa a ser dono sozinho do CTH da rajada. Mira passa a
  ser dona do alcance. Cada intenção ganha um botão.
- O `BurstFireCriticalChanceMul = 70` e o TODO do `__MainParams.lua:3` (*"make crit per aim
  not affect burst fire"*) deixam de ser remendos pendentes.

---

## O custo, e ele é de desenho, não de código

**Mira hoje faz dois trabalhos:**

| trabalho | vale onde | quem herda na proposta |
|---|---|---|
| "gastar AP para alcançar mais longe" | longe | **alcance** (a proposta) |
| "gastar AP para ter mais certeza" | em qualquer distância | **fica órfão** |

A 5 tiles você já está dentro do effective range. Com mira-como-alcance, mirar ali não faz
nada — e o combate próximo perde o eixo de investimento inteiro. Vira só volume e posição.

Pode ser que seja isso que se queira para CQB. Mas **essa é a decisão que precisa ser
tomada antes de tocar em qualquer componente**, porque é ela que define se scope e cano
longo continuam tendo identidade separada da mira.

### Uma casa para o órfão: crit

A infraestrutura já existe e já está calibrada: `PrismScopeCritPerAim`,
`LaserDotCritPerAim`, `PSOScopeCritOnAimed`, `FirstAimCrit`.

> **Perto você mira para critar. Longe você mira para alcançar.**

Dois payoffs distintos, nenhum deles sendo CTH cru, e o recoil segue sozinho no CTH da
rajada. E se crit é o prêmio de mirar, e mirar não ajuda rajada, então rajada não crita —
o TODO fecha por estrutura.

---

## Caminho em três degraus

Cada um testável sozinho, do mais barato para o mais caro.

### Degrau 1 — bônus de mira decai dentro do effective range

Mudança **só** no `CalcValue` do `Aim`, em `CTH_aim.lua` — que já está inteiramente
reescrito por este mod. **Nenhum componente é tocado. Nenhum rebalanceamento.**

É a metade direcional da ideia: mirar de perto passa a valer pouco, mirar longe continua
valendo. Reversível.

**Se a sensação não estiver certa, a ideia morre aqui e morre barata** — em vez de morrer
depois de mexer em 40 componentes.

### Degrau 2 — o que saiu do CTH vira crit

Recupera o eixo de investimento em CQB sem reintroduzir CTH comprável.

### Degrau 3 — revisitar componentes

Só aqui entra o rebalanceamento de verdade. E a pergunta fica mais estreita do que parece:

| componente | efeito da mudança |
|---|---|
| **Scope** | **colide** — scope e mira passam a fazer a mesma coisa |
| **Cano longo** | **colide** — idem |
| Laser | pouco afetado; relativamente mais forte (ajuda o tiro não mirado) |
| Grips, compensadores, freios, bipé | **relativamente mais fortes** — viram a identidade da rajada |
| Coronhas, canos pesados | idem |

Ou seja: o que precisa de redesenho de verdade são **scope e cano longo**. O resto se
reacomoda na direção que já se quer.

---

## O que NÃO fazer

**NCTH do JA2 1.13.** O problema dele não é a simulação — é que a superfície de
balanceamento vira contínua e acoplada, e mexer em qualquer coisa mexe em tudo. O CTH
discreto do JA3 é mais grosseiro e muito mais tunável. A direção deste documento é o
oposto: **menos acoplamento, não mais simulação.**

---

## Achados relacionados, do levantamento de hoje

- **O `Autofire` do vanilla está desligado.** `CTH_autofire_recoil.lua` substitui o
  `CalcValue` por `return false, 0`, e todo o bloco de parâmetros está comentado. A
  penalidade plana de rajada do vanilla já foi trocada pelo sistema de recoil — decisão
  coerente e já tomada, e é o precedente que torna esta proposta natural.

- **Não dá para somar o recoil no contador de CTH.** Exigiria uma conta por bala, e mostrar
  isso não cabe na UI. A estimativa atual, com o painel de recoil ao lado, é uma resposta
  razoável. Fica registrado que a alternativa foi considerada e descartada por caber, não
  por não ser desejável.

- **Restos de código enganam.** O bloco comentado de `APStance` no fim do
  `__MainParams.lua` descreve um desenho *superado* — a property existe e funciona
  (`WeaponProperties.lua:41`, lida por `GetWeapon_StanceAP`, modificável por componente).
  Ler o resto e concluir que a funcionalidade não existia custou uma recomendação errada.
  Mesmo caso em `autofire_range()`. **Código comentado que descreve desenho antigo é pior
  que código deletado: parece intenção pendente.** O git guarda; quando o registro importa,
  um comentário em prosa dizendo *"substituído por X"* serve melhor.

---

## Nota para o lado da IA

O `Rato's AI Overhaul` modela a rajada bala a bala desde o `BUGFIX (B21)`, replicando a
fórmula de `SOURCE_FirearmGetAttackResults.lua:255-279` — **inclusive a remoção do bônus
de mira nas balas 2..N**.

Se o Degrau 1 ou 2 acontecer, `RATOAI_BurstHits` e `RATOAI_AimBonus` (em
`FUNCTION_ScoreAttacksDetailed.lua`) precisam acompanhar. O `RATOAI_AimBonus` deixa de
existir, o que também remove a única avaliação de preset que o B21 acrescentou.

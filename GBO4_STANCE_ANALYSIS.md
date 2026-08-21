# GBO4_STANCE_ANALYSIS.md — Análise do Sistema de Shooting Stance
*Fase: design review para GBO4 — sem edições de código.*
*Data: 2026-04-20*

---

## 1. Como o código atual implementa entrada na stance e custo de AP

### 1.1 A função central: `GetShootingStanceAP()`

`FUNCTIONS_CombatAP.lua` define `Unit:GetShootingStanceAP(target, weapon, aim, action, param)`.
Esta função é chamada por TODOS os `GetAPCost` de ações de disparo (SingleShot, BurstFire,
MGBurstFire, AutoFire, DualShot) e pela ação `R_PrepareWeapon`. Ela devolve um custo em AP
que é somado ao custo base da ação, separado do custo de aim do engine.

**Lógica de retorno:**

```
Se (in stance OU ManningEmplacement OU StationedMachineGun):
    retorna ap_rotate = Clamp(ângulo_fora_do_cone × Scale.AP, 0, ap_stance + 1_AP)
    → 0 se target está dentro do cone; até (ap_stance + 1_AP) se fora
Senão se (aim == 0):
    retorna ap_hipfire (atualmente hardcoded em 0 — código morto)
Senão (aim >= 1, fora da stance):
    retorna ap_stance = weapon.APStance × Scale.AP (penalizado por Cumbersome, AI mul, etc.)
```

`ap_stance` é o custo de entrar na stance para atirar. Varia por arma (definido em
`PATCH_GBO_weapons.lua` como `weapon.APStance`).

### 1.2 Onde stance AP e aim AP estão fundidos vs separados

**SEPARADOS** — estão em funções distintas e somados externamente:

```
GetAPCost_de_qualquer_ação = GetAttackAPCost(engine) + GetShootingStanceAP(mod)
```

`GetAttackAPCost` (engine, `Unit.lua:7318`) calcula:
```
ap_base + (aim - min_aim) × 1_AP
```
onde `ap_base = weapon.ShootAP + delta`. O recoil hook (`OnCalcAPCost` do Rat_recoil) opera
dentro deste call, sobre o mesmo `ap` que inclui o custo de aims.

`GetShootingStanceAP` é somado DEPOIS, fora do engine, em cada `GetAPCost` do mod.

**FUNDIDOS na prática (semântica):**
O custo de entrar na stance (`ap_stance`) é cobrado na PRIMEIRA ação de disparo com
`aim >= 1` enquanto fora da stance. O engine cobra separadamente cada nível de aim
acima do mínimo. A fusão acontece no momento da cobrança: uma única ação paga
`ap_stance + aim_levels × 1_AP + attack_base` — mas os três termos têm origens distintas.

### 1.3 O mínimo forçado de aim ao entrar na stance

`CharacterEffect/shooting_stance.lua` define uma reação `OnCalcMinAimActions` que retorna
`value + 1` para o próprio portador. O engine (`Unit.lua:8317`) usa este valor como `min_aim`
em `GetBaseAimLevelRange`. Em `GetAttackAPCost`:
```lua
aim = Clamp(aim, min_aim, max_aim) - min_aim  -- só cobra acima do mínimo
```

Efeito: quando em stance, aim=1 tem custo zero de aim adicional. Aim=2 custa 1 AP extra.
O primeiro nível de aim é "gratuito" em AP enquanto na stance — o custo de entrada
(`ap_stance`) foi pago na ação anterior ou na ação atual (entrada simultânea com disparo).

### 1.4 Custo de `R_PrepareWeapon` (entrar na stance sem disparar)

```lua
-- se fora da stance:
stance = GetShootingStanceAP(aim=0, param="stance") + Get_AimCost()
       = ap_stance + 1_AP
-- se em stance (Rotate Weapon):
rotate = Max(1_AP, GetShootingStanceAP(param="stance"))
       = Max(1_AP, ap_rotate)
```

`Prepare Weapon` + `Shoot in stance` (0 aims acima do mínimo forçado):
= `(ap_stance + 1_AP)` + `(attack_base + 0)`
= `attack_base + ap_stance + 1_AP`

Shoot from scratch com aim=1 (sem usar Prepare Weapon):
= `attack_base + (1 - 0) × 1_AP + ap_stance`
= `attack_base + ap_stance + 1_AP`

**São matematicamente equivalentes.** `Prepare Weapon` é para entrar na stance sem
comprometer um alvo imediato — não há desconto de AP por usar a ação separada.

---

## 2. Como o recoil interage com a stance hoje

### 2.1 Entrada na stance

`EnterShootingStance()` (`shooting_stance_functions.lua:1`) NÃO remove o recoil ao entrar.
O recoil acumula entre disparos e permanece quando o merc entra manualmente na stance.

### 2.2 Saída da stance

`CharacterEffect/shooting_stance.lua`, reação `StatusEffectRemoved`:
```lua
if id == "shooting_stance" then
    if HasPerk(obj, "Rat_recoil") then
        obj:RemoveStatusEffect("Rat_recoil", "all")
    end
end
```
**Sair da stance limpa todo o recoil acumulado.** Isso é significativo: entrar em
overwatch (que remove a stance) reseta o recoil.

### 2.3 Recoil aumenta o custo de mirar (OnCalcAPCost)

`CharacterEffect/Rat_recoil.lua`, reação `OnCalcAPCost`:
```lua
local aim_level = Min(3, aim or 0)
if aim_level < 1 then return end  -- hipfire: sem extra
local extra_cost = floor(aim_cost × aim_level) × Scale.AP
return current_ap + extra_cost
```

Este hook é acionado DENTRO de `GetAttackAPCost()` via `CallReactions_Modify("OnCalcAPCost")`.
Portanto, recoil alto aumenta o custo de CADA NÍVEL de aim (até 3 níveis). O custo extra
de aim por recoil é separado do custo de stance — soma sobre o custo base de aiming.

### 2.4 Recoil reduz a penalidade de CTH via aim

`Rat_recoil.lua`, reação `OnCalcChanceToHit`:
```lua
local multiplier = Min(aim, 3)
recoil = cRound(recoil × Max(0, (1 - (0.34 × multiplier))))
```
Cada nível de aim reduz a penalidade de recoil no CTH em 34%. Com 3 aims: `1 - 1.02 ≈ 0`
(penalidade zerada). A redução é de CTH — não remove stacks.

### 2.5 Resumo da interação atual

| Evento | Efeito no Recoil |
|--------|-----------------|
| Entrar na stance | Nenhum |
| Sair da stance | Remove todos os stacks |
| Disparar | Acumula stacks |
| Mover 3+ tiles | Remove todos os stacks |
| Recarregar | Remove todos os stacks |
| Aim (CTH) | Reduz penalty em 34% por nível (não remove stacks) |
| Aim (AP) | Aumenta custo de AP por aim level × `aim_cost` |

---

## 3. O que precisaria mudar para o novo modelo de estados

### Definição do novo modelo
```
p-hf   : fora da stance, aim=0 → penalidade hipfire no CTH
p      : em stance, aim=0 → sem penalidade
p+1a   : em stance, aim=1 → bônus parcial de aim
p+2a   : em stance, aim=2 → bônus maior
p+3a   : em stance, aim=3 → bônus máximo
```
Snapshot deixa de existir como estado. Recoil NÃO aumenta custo de mirar.

---

### 3.1 Remover Snapshot

**Onde está:** `CTH_hipfire_and_snapshot.lua`, bloco `if aim > 0 and aim < 3 then`.

**O que acontece hoje:** se aim ∈ {1, 2} e o alvo NÃO é o último atacado e a ação não
está na lista de "sempre snapshot" (Overwatch, MobileShot, RunAndGun), o modifier retorna
`snap_penal` com nome "Snapshot".

**Mudança:** Remover completamente o bloco do Snapshot. p+1a e p+2a simplesmente não
têm penalidade adicional — o bônus de aim é proporcional.

Exceções a decidir:
- Overwatch: atualmente sempre usa snapshot (via `actions_that_use_snapshot_always`). No
  novo modelo, Overwatch em stance poderia usar o bônus do aim level da stance. Sem stance:
  poderia ter hipfire ou snapshot dependendo da decisão de design.
- MobileShot/RunAndGun: são casos especiais que merecem tratamento próprio independente
  da remoção do snapshot.

### 3.2 Permitir aim=0 em stance (estado p)

**Onde está o bloqueio atual:**

(a) `CharacterEffect/shooting_stance.lua`, reação `OnCalcMinAimActions`:
```lua
return value + 1  -- força aim mínimo = 1 em stance
```
Remover esta reação ou fazê-la retornar `value` sem modificação.

(b) `CTH_hipfire_and_snapshot.lua`, linhas que forçam aim=1 quando em stance:
```lua
if attacker:HasStatusEffect("shooting_stance") then
    aim = Max(1, aim)
end
```
Substituir por: "se em stance e aim=0, retornar 0 de penalidade" sem modificar o valor
de aim. A lógica de hipfire só deve ser ativada para p-hf (não em stance).

**Mudança resultante no AP:**
Com min_aim=0 em stance, `GetAttackAPCost` passa a cobrar `(aim - 0) × 1_AP` = aim × 1_AP.
Shooting em estado p custa `attack_base + 0 × 1_AP + ap_rotate` = `attack_base + ap_rotate`
(ap_rotate=0 se no cone). Igual ao hipfire em AP, mas sem penalidade de CTH.

Isso cria uma assimetria: p tem o mesmo custo de AP que p-hf, mas sem penalidade de CTH.
É comportamento intencional (o benefício de entrar na stance é precisamente esse).

### 3.3 Remover o custo de AP do recoil ao mirar

**Onde está:** `CharacterEffect/Rat_recoil.lua`, reação `OnCalcAPCost`.

**Mudança:** Remover inteiramente esta reação. O recoil continua causando penalidade de
CTH (reduzida por aim levels), mas não afeta custo de AP de aiming.

**Impacto secundário:** A UI mostra `aim: +X AP` no crosshair via `SOURCE_shooting_stance_crosshair_ui.lua`.
Esta string deve ser removida do display junto com a remoção da lógica.

### 3.4 Revisão do `R_PrepareWeapon` para o estado p

Atualmente `Prepare Weapon` (fora da stance) custa `ap_stance + 1_AP` — já inclui 1 aim.
No novo modelo, `Prepare Weapon` entra no estado p (stance, sem aim). O custo deve ser
apenas `ap_stance`, sem incluir o primeiro aim.

Mas `Prepare Weapon` é um CombatAction definido em `shooting_stance_prepare_weapon_action.lua`.
O seu `GetAPCost` teria que parar de somar `Get_AimCost()` quando entrando na stance:

```lua
-- atual: stance + aim_cost
-- novo:  apenas stance (sem aim cost)
```

Este é o ponto onde `p` e `p+1a` se distinguem em AP — o jogador paga 1 AP a mais para
ir de p para p+1a.

### 3.5 Resumo das mudanças no CTH hipfire/snapshot

| Condição | Comportamento atual | Comportamento novo |
|----------|--------------------|--------------------|
| aim=0, fora da stance | Hipfire penalty | Hipfire penalty (mantém) |
| aim=0, em stance | Força aim=1 artificialmente → sem penalty | Sem penalidade (estado p legítimo) |
| aim=1, fora da stance | Snapshot penalty | Snapshot eliminado → sem penalty |
| aim=1, em stance | Snapshot forçado (aim=1 desde min) → sem penalty | Sem penalidade (p+1a) |
| aim=2, qualquer | Snapshot (reduzido) | Eliminado |
| aim≥3 | Sem penalty | Sem penalty (mantém) |

---

## 4. Overrides de engine afetados e o que cada um precisaria fazer

### 4.1 `SOURCE_shooting_stance_BaseAimLevel.lua`

**O que faz hoje:** Override de `Unit:GetBaseAimLevelRange`. Limita max_aim=1 para
DualShot, AutoFire, GrizzlyPerk. Define min_aim=1 quando `self.Mobile_aimed`.

**Impacto do novo modelo:** A restrição de min_aim via `OnCalcMinAimActions` (no status
effect) é separada deste arquivo. A remoção do min_aim+1 da stance não altera este arquivo.
A limitação de `Mobile_aimed` (min=1) deve permanecer como está.

**Mudança necessária:** Nenhuma neste arquivo para o modelo básico.

### 4.2 `SOURCE_shooting_stance_aimtarget.lua`

**O que faz hoje:** Override de `Unit:AimTarget`. Bloco na linha 281 impede a rotação
animada da unidade quando em stance:
```lua
if not self:HasStatusEffect("shooting_stance") then
    -- faz rotação normal
end
```
Também define `aim_rotate_cooldown_times` mais longos por postura.

**Impacto do novo modelo:** Para o estado p (stance, aim=0), a unidade está em stance
mas ainda não apontou. A lógica de "não rotacionar" deve permanecer (é o comportamento
correto — a stance define o cone). O estado p não muda este arquivo.

**Mudança necessária:** Provavelmente nenhuma para p/p-hf. Revisar se o `idle_aiming`
path (linha 78) interfere com o estado p — o idle_aiming é ativado para MeleeAttack e
prone stance mismatches, não deve ser afetado.

### 4.3 `SOURCE_shooting_stance_ANIMchangehook.lua`

**O que faz hoje:** Override de `AnimChangeHook:SetState`. Quando em stance e a animação
nova não é "Idle", intercepta e força a animação de aim:
```lua
if shooting_stance then
    local idle = string.match(anim, "Idle")
    if not idle then return end  -- bloqueia mudança para não-idle
    -- ao receber idle: força aim anim
    self:SetState(aim_state, ...)
end
```

**Impacto do novo modelo:** O estado p (stance, aim=0) deveria exibir animação de "arma
encostada no ombro, olhando à frente" — idealmente diferente de "apontando ativamente".
O problema: o engine provavelmente não tem animação de "shouldered idle" separada de
"aim idle". A implementação depende da disponibilidade de animação.

**Opção A (simples):** Manter o comportamento atual — estado p usa a mesma aim anim
de p+1a. Visualmente idênticos, mas gameplay-mente distintos (AP e CTH diferem).

**Opção B (complexa):** Criar uma animação de "stance idle" separada e adicionar lógica
para distinguir aim=0 vs aim>0 no hook. Exige verificar `unit.aim_action_id` ou um novo
campo de estado.

**Mudança necessária para Opção A:** Nenhuma.
**Mudança necessária para Opção B:** Modificar o hook para checar nível de aim e
usar animação diferente para aim=0. Risco moderado — SetState é frequentemente chamado.

### 4.4 `SOURCE_shooting_stance__ANIM_idle.lua`

**O que faz hoje:** Override de `Unit:Idle`. Dois blocos protegem a stance de ser
interrompida pelo comportamento de idle:
1. `if self.aim_action_id and not HasCombatActionInProgress(self) and not (self:HasStatusEffect("shooting_stance")) then` — previne `AimIdle` quando em stance
2. `if not self:HasStatusEffect("shooting_stance") then AnimatedRotation(...)` — previne
   re-orientação aleatória ao ficar idle em stance

**Impacto do novo modelo:** Para o estado p (stance, aim=0), ambos os blocos devem
continuar ativos — a unidade em p não deve auto-rotacionar nem entrar em `AimIdle`
command por conta própria. Sem mudança necessária.

**Mudança necessária:** Nenhuma para o comportamento do estado p.

### 4.5 `SOURCE_shooting_stance_crosshair_ui.lua`

**O que faz hoje:** Override de `CrosshairUI:UpdateAim`. Dois blocos do mod:
1. Calcula `ap_extra` de stance e exibe separado como `"2+<AP total>"` no display
2. Calcula `aim_pen_string` do recoil (`aim: +X AP`) e exibe junto

**Impacto do novo modelo:**
- Bloco 1 (ap_extra): Permanece relevante para mostrar o custo de rotação ou de
  entrar na stance. Revisão do label pode ser necessária para clareza.
- Bloco 2 (aim_pen_string): **Deve ser removido** junto com o `OnCalcAPCost` do recoil.
  O display de "aim: +X AP" deixa de existir.

**Mudança necessária:** Remover o bloco de `aim_pen_string` (linhas ~362-374 e referências
na string de texto). Baixo risco — é display apenas.

### 4.6 `SOURCE_shooting_stance_overwatch_function_n_attacks.lua`

**O que faz hoje:** Override de `Unit:GetOverwatchAttacksAndAim`. Quando em stance,
força `aim = 1` no cálculo de ataques de overwatch.

**Impacto do novo modelo:** Se stance agora permite aim=0, um overwatch em stance poderia
teoricamente ter aim=0. Mas overwatch com aim=0 não faz sentido gameplay-mente — overwatch
é sempre uma ação "preparada". A lógica de forçar aim=1 pode permanecer ou ser ajustada
para "aim do estado atual", dependendo da decisão de design.

**Mudança necessária:** Revisão de design antes de alterar. Não é bloqueante para p/p-hf.

### 4.7 Possíveis novos overrides para o novo modelo

**Hipótese: override de `GetBaseAimLevelRange` para distinguir p/p-hf no engine**

O engine (`Unit.lua:8305`) calcula min/max via `GetBaseAimLevelRange`. Atualmente o
mod sobrescreve via `SOURCE_shooting_stance_BaseAimLevel.lua`. Para o novo modelo, o
mínimo de aim em stance deve ser 0 (não mais 1 forçado pelo `OnCalcMinAimActions` do
status effect). Remover a reação do status effect é mais limpo do que um override aqui.

**Hipótese: override de `Unit:GetAimLevelRange` ou UI de aim para indicar estado p**

A UI de mira usa `aim` como integer. Para indicar que aim=0-em-stance é diferente de
aim=0-hipfire, a distinção precisa estar em algum visual ou label — não em novo valor
de aim. Isso pode ser feito via `SOURCE_shooting_stance_crosshair_ui.lua` sem novo
override, apenas adicionando lógica condicional.

**Hipótese: override necessário para a ação de "Aim" do engine**

O engine exibe botões de aim (+1a, +2a, +3a) que custam 1 AP cada. O estado p implica
que o jogador pode disparar COM aim=0 em stance (estado válido). Isso funciona
automaticamente ao remover o `OnCalcMinAimActions` +1 — o engine já suporta aim=0.
Nenhum override adicional é necessário para esta mecânica.

---

## 5. Estimativa de complexidade: simples vs pesado

### Simples (baixo risco, impacto localizado)

| Mudança | Arquivo(s) | Por quê é simples |
|---------|-----------|-------------------|
| Remover Snapshot do CTH | `CTH_hipfire_and_snapshot.lua` | Bloco bem delimitado, retorno 0 |
| Remover `aim_cost` do recoil | `CharacterEffect/Rat_recoil.lua` | Remover 1 reação (`OnCalcAPCost`) |
| Remover display de aim_pen no crosshair | `SOURCE_shooting_stance_crosshair_ui.lua` | Só display, sem lógica de combat |
| Remover Snapshot do overwatch | `CTH_ow_cth.lua`, `CTH_hipfire_and_snapshot.lua` | Conditional já identificado |

### Moderado (requer entender 2–3 sistemas antes de editar)

| Mudança | Arquivo(s) | Por quê é moderada |
|---------|-----------|-------------------|
| Habilitar aim=0 em stance (estado p) | `CharacterEffect/shooting_stance.lua` + `CTH_hipfire_and_snapshot.lua` | Dois arquivos cooperando; testar que hipfire não aplica em p mas aplica em p-hf |
| Atualizar `R_PrepareWeapon` para custar apenas `ap_stance` (sem +1 aim) | `shooting_stance_prepare_weapon_action.lua` | Interação com custo total de disparo pós-prep; risco de desequilíbrio de AP |
| Atualizar Overwatch para novo modelo | `SOURCE_shooting_stance_overwatch_function_n_attacks.lua` + `CTH_ow_cth.lua` | Decisão de design sobre aim de overwatch em stance p |

### Complexo (risco de regressão, envolve overrides de engine)

| Mudança | Arquivo(s) | Por quê é complexa |
|---------|-----------|-------------------|
| Animação diferenciada para estado p vs p+Na | `SOURCE_shooting_stance_ANIMchangehook.lua` | Depende de animações disponíveis; SetState é crítico e chamado frequentemente |
| Garantir que Snapshot seja removido de TODAS as codepaths (Overwatch, MobileShot, RunAndGun) sem quebrar esses sistemas | Múltiplos CTH + COMBAT_ACTIONS | `actions_that_use_snapshot_always` afeta sistemas indiretamente |
| Manter recoil funcionando corretamente sem AP cost enquanto ainda reduz CTH | `CharacterEffect/Rat_recoil.lua` + sistema de CTH | A remoção do `OnCalcAPCost` é simples, mas verificar que o CTH handler sobrevive sem mudanças não esperadas exige testes exaustivos de recoil em todos os modos de fogo |

---

## Apêndice: Grafo de dependências para a refatoração da stance

```
[shooting_stance status effect]
    OnCalcMinAimActions (+1) ──────── REMOVER (para habilitar estado p)
    OnCalcStartTurnAP (carrega AP)─── MANTER
    StatusEffectRemoved (limpa recoil) MANTER

[CTH_hipfire_and_snapshot.lua]
    aim = Max(1, aim) quando em stance ─ REMOVER (bloqueia estado p)
    bloco hipfire (aim == 0) ──────────── MANTER, mas condição: NÃO em stance
    bloco snapshot (0 < aim < 3) ───────── REMOVER COMPLETAMENTE

[Rat_recoil.lua]
    OnCalcAPCost (aumenta custo de aim) ── REMOVER
    OnCalcChanceToHit (penalidade CTH) ─── MANTER

[SOURCE_shooting_stance_crosshair_ui.lua]
    ap_extra display ──────────────────── MANTER (custo de rotação)
    aim_pen_string display ────────────── REMOVER (junto com OnCalcAPCost)

[shooting_stance_prepare_weapon_action.lua]
    GetAPCost: ap_stance + AimCost ────── MUDAR PARA: ap_stance apenas

[SOURCE_shooting_stance_ANIMchangehook.lua]
    Força aim anim em stance ──────────── DECISÃO DE DESIGN: Opção A (manter) ou B (animação p separada)
```

---

*Próximo passo sugerido: confirmar as decisões de design abertas (Overwatch em estado p,
animação do estado p) antes de iniciar implementação.*


Animação: Opção A — sem trabalho extra
Overwatch: aim=0 em stance, mecânica de diferenciação por tipo de arma em aberto
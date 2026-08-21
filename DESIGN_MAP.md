# DESIGN_MAP.md — GBO3 Systems Review
*Gerado em 2026-04-20. Fase: design review (sem edições de código.)*

---

## Como ler este documento

Cada entrada cobre um sistema de gameplay (não um arquivo). A maioria dos sistemas é
implementada em múltiplos arquivos cooperando. Complexidade de manutenção mede o custo
de mudar o comportamento do sistema sem introduzir bugs — não o tamanho do código.

**Escala de complexidade:**
- `simples` — mudança isolada, sem efeitos colaterais significativos
- `moderada` — requer entender 2–4 subsistemas antes de editar com segurança
- `complexa` — mudança afeta múltiplos sistemas; risco alto de regressão silenciosa

---

## Sistema 1 — Recoil Acumulativo

**O que faz (gameplay):**
Cada disparo em um turno adiciona penalidade de acerto (`CTH`) para o próximo disparo.
A penalidade acumula como um status (até 6 stacks). Força e Marksmanship reduzem o
acúmulo. Mover 3+ tiles, recarregar ou sair da Shooting Stance reseta o efeito.
Mirar consome AP extra quando há recoil acumulado.

**Arquivos principais:**
- `Code/__RecoilParams.lua` — constantes de calibre, componentes, classes
- `Code/FUNCTIONS_recoil.lua` — cálculo central (`GetWepRecoil()`)
- `Code/_______init_globals.lua` — `ratG_recoilData` (dados por calibre)
- `CharacterEffect/Rat_recoil.lua` — efeito de status (stacks, duração, remoção)
- `Code/CTH_autofire_recoil.lua` — integração com CTH (atualmente zerado)

**Depende de:**
- Sistema de Calibres (dados de recoil por calibre)
- Weapon Properties (multiplicadores por classe e componente)
- Sistema de Componentes (grip, stock, barrel, compensador reduzem recoil)
- Shooting Stance (reset de recoil ao entrar)

**Do qual dependem:**
- Sistema de Autofire (penalidade tiro-a-tiro dentro do burst)
- CTH geral (Rat_recoil aplica penalty ao CTH base)
- Sistema de Custo de AP (aiming custa mais AP com recoil acumulado)

**Complexidade de manutenção: complexa**
— O efeito de status, os parâmetros por calibre, os multiplicadores de componente e a
integração com custo de AP estão acoplados. Mudar o teto máximo de penalidade ou o
scaling de Força afeta o feel de praticamente toda arma automática.

---

## Sistema 2 — Shooting Stance

**O que faz (gameplay):**
O merc precisa gastar AP para "encaixar" a arma no ombro antes de mirar. Isso cria
um cone de ângulo de rotação — atirar fora do cone custa AP extra. Sacar sem ter
entrado na stance aplica penalidade de Hipfire. Barrel longo e peso reduzem o ângulo.
O sistema foi inspirado no mod Wax.

**Arquivos principais:**
- `Code/shooting_stance_functions.lua` — lógica central (enter, command, AP)
- `Code/shooting_stance_aoesector_functions.lua` — visualização do cone (UI)
- `Code/SOURCE_shooting_stance_BaseAimLevel.lua` — cálculo do ângulo por peso/barrel
- `Code/SOURCE_shooting_stance_aimtarget.lua` — override de como a stance calcula alvo
- `Code/SOURCE_shooting_stance_ANIMchangehook.lua` — transições de animação
- `Code/SOURCE_shooting_stance_crosshair_ui.lua` — UI de mira
- `Code/SOURCE_shooting_stance_overwatch_function_n_attacks.lua` — overwatch em stance
- `Code/REACTIONS_ShootingStance.lua` — reações ao evento de stance
- `CharacterEffect/shooting_stance.lua` — efeito de status (removido ao mover)
- `CharacterEffect/R_ReservedAP_stance.lua` — reserva de AP enquanto em stance

**Depende de:**
- Weapon Properties (`APStance`, barrel length, peso de componentes)
- Sistema de Recoil (stance reseta recoil ao entrar)
- Sistema de Hipfire/Snapshot (hipfire se não entrar na stance)
- Sistema de Overwatch (overwatch tem comportamento especial em stance)

**Do qual dependem:**
- COMBAT_ACTIONS (todas as ações de disparo verificam custo de stance)
- Sistema de CTH — Hipfire/Snapshot (entrar ou não na stance determina qual penalty aplica)
- Sistema de AP (custo de rotação fora do cone)

**Complexidade de manutenção: complexa**
— Múltiplos arquivos `SOURCE_*` (assinaturas obrigatórias), lógica de UI, animação,
overwatch e AP cost todos entrelaçados. É o sistema com mais superfície de override
de engine. Qualquer mudança no cone ou custo de AP afeta overwatch e dual-shot.

---

## Sistema 3 — Hipfire e Snapshot

**O que faz (gameplay):**
- **Hipfire**: atirar com 0 níveis de mira aplica penalidade de acerto. Pistolas e SMGs
  têm penalidade menor por design.
- **Snapshot**: atirar com 1 nível de mira aplica penalidade menor. Se o alvo for o
  mesmo da ação anterior, a penalidade é zerada (aquisição de alvo facilitada).
  Afeta diretamente Overwatch e Mobile Attack.

**Arquivos principais:**
- `Code/__SnapshotHipfireParams.lua` — constantes por classe e componente
- `Code/CTH_hipfire_and_snapshot.lua` — aplicação ao CTH
- `Code/FUNCTIONS_hipfire.lua` — funções auxiliares

**Depende de:**
- Weapon Properties (multiplicadores de hipfire/snapshot por classe e componente)
- Shooting Stance (entrar na stance é pré-condição para evitar hipfire)
- Sistema de Overwatch (snapshot afeta precisão de overwatch)

**Do qual dependem:**
- Run-and-Gun (usa hipfire penalty como base)
- Mobile Attack (usa snapshot penalty)
- Sistema de Overwatch (penalty de snapshot afeta intercepts)

**Complexidade de manutenção: simples**
— Params centralizados em um arquivo, aplicação em CTH é isolada. Mudar valores
afeta muitas armas mas o mecanismo é direto.

---

## Sistema 4 — CTH Modular (Chance to Hit)

**O que faz (gameplay):**
A chance de acerto final é composta por múltiplos modificadores independentes aplicados
em sequência. Cada modifier tem sua própria lógica e condição de ativação. O sistema
é extensível — novos modifiers podem ser adicionados sem alterar os existentes.

**Módulos ativos:**
| Arquivo | Efeito |
|---|---|
| `CTH_aim.lua` | Bônus de mira (Hand-Eye Coordination, não só Dex) |
| `CTH_hipfire_and_snapshot.lua` | Penalidades de hipfire/snapshot |
| `CTH_scope.lua` | Penalidade de scope em alcance curto |
| `CTH_bipod.lua` | Bônus de bipod (somente prone) |
| `CTH_cover_prone.lua` | Modificadores de cobertura e postura |
| `CTH_held_mg.lua` | Penalidade de MG em uso manual |
| `CTH_2weaponfire.lua` | Penalidade de dual shot por distância/dex |
| `CTH_ow_cth.lua` | Precisão de overwatch |
| `CTH_pointblank.lua` | Bônus de ponto cego (curta distância) |
| `CTH_ranged_melee_penal.lua` | Penalidade de barrel longo em corpo a corpo |
| `CTH_rungun.lua` | Penalidade de run-and-gun por distância |
| `CTH_targeted_noburst.lua` | Bônus de targeted shot (totalmente mirado) |
| `CTH_unwield_weapon.lua` | Penalidade de arma de duas mãos sem empunhar |
| `CTH_autofire_recoil.lua` | (desativado — recoil gerenciado separadamente) |

**Depende de:**
- Quase todos os outros sistemas: cada CTH modifier lê dados de Weapon Properties,
  Unit Properties, componentes ativos, status effects, ou calibre

**Do qual dependem:**
- Todos os sistemas de ataque (qualquer disparo passa pelos CTH modifiers)

**Complexidade de manutenção: moderada**
— Cada modifier é isolado e fácil de editar individualmente. O risco está em interações
acumuladas entre modifiers (ex: hipfire + scope + run-and-gun ao mesmo tempo podem
empilhar beyond razoável). Adicionar um novo modifier é simples; remover um exige
verificar se outros dependem do valor que ele produzia.

---

## Sistema 5 — Críticos (Critical Hits)

**O que faz (gameplay):**
A chance de crítico escala com Destreza + Marksmanship (Hand-Eye Coordination).
Tiro único tem scaling muito maior que burst. Componentes (scopes, laser dots) adicionam
bônus. Pindown/Snipe garante bônus de crítico extra. O efeito se aplica via evento
`GatherCritChanceModifications`.

**Arquivos principais:**
- `Code/FUNCTIONS_Critical.lua` — lógica central e handler do evento
- `Code/__MainParams.lua` — constantes de scaling por modo de fogo
- `Code/UnitProperties.lua` — cálculo de Hand-Eye Coordination

**Depende de:**
- Unit Properties (Hand-Eye Coordination = Dex + Marks)
- Weapon Properties (componentes que dão crit bonus)
- Sistema de Autofire (modo de fogo determina o multiplier)
- Ação de Pindown/Snipe (bônus especial de crit)

**Do qual dependem:**
- Sistema de Targeted Shot (sinergiza com crit scaling)
- Calibres (5.45 tem tumbling → +crit chance; 5.56 tem fragmentation → +crit damage)

**Complexidade de manutenção: simples**
— Lógica centralizada em um arquivo, parâmetros no `__MainParams.lua`. O hook de
evento é padrão do engine.

---

## Sistema 6 — Autofire e Modos de Fogo

**O que faz (gameplay):**
- **Burst** (3 balas): modo padrão de fogo automático
- **Autofire** (10 balas): disparo sustentado, AP fixo, pode mirar uma vez
- **MG Burst** (6 balas): burst de metralhadora, Força tem mais impacto na precisão
- Todas as modalidades têm dano completo por bala (mudança central do GBO3)
- Recoil acumula bala a bala dentro do burst

**Arquivos principais:**
- `Code/SOURCE_GetAutoFireShots.lua` — contagem de balas por modo
- `Code/COMBAT_ACTIONS.lua` — AP cost e results de cada ação
- `Code/FUNCTIONS_recoil.lua` — acúmulo de recoil entre balas

**Depende de:**
- Sistema de Recoil (penalidade cresce bala a bala)
- Weapon Properties (componentes que adicionam balas extras)
- Sistema de CTH (acerto calculado por bala)
- Shooting Stance (pode mirar antes do autofire)

**Do qual dependem:**
- Sistema de Críticos (burst tem scaling de crit menor)
- Sistema de Dano (dano completo por bala é a premissa do sistema)

**Complexidade de manutenção: moderada**
— A contagem de balas é simples, mas o dano total por ação é produto de balas × dano × recoil × crit. Mudar um afeta o balanço percebido do outro.

---

## Sistema 7 — Pellets de Shotgun

**O que faz (gameplay):**
Shotguns disparam múltiplos pellets individuais, cada um com trajetória balística
própria. O padrão de dispersão é gerado matematicamente. Slug é um projétil único de
alta energia. O número de pellets e o spread dependem do calibre e componentes.

**Arquivos principais:**
- `Code/FUNCTIONS_Pellets.lua` — contagem e dados de spread
- `Code/FUNCTION_GetPelletScatterData.lua` — geração do padrão de spread
- `Code/FUNCTIONS_FirearmFirePellet.lua` — impacto de cada pellet
- `Code/SOURCE_FirearmFireBullet.lua` — override que intercepta o disparo e lança pellets
- `Code/COMBAT_ACTIONS_ShotgunRework.lua` — ações de shotgun (Buckshot, Double Barrel)

**Depende de:**
- Weapon Properties (calibre, componentes de barrel)
- Sistema de CTH (acerto por pellet)
- `SOURCE_FirearmFireBullet.lua` (override de assinatura obrigatória)

**Do qual dependem:**
- Nenhum outro sistema depende diretamente de pellets

**Complexidade de manutenção: complexa**
— O override de `FirearmFireBullet` é o ponto mais sensível: qualquer alteração pode
quebrar o disparo de todas as armas. A matemática de spread é não-trivial. Debug é
difícil (pellets são instantâneos).

---

## Sistema 8 — Calibres e Munição

**O que faz (gameplay):**
Cada calibre define propriedades intrínsecas (dano base, penetração, range). Tipos de
munição especial modificam essas propriedades:
- **AP**: menos dano crítico, mais penetração, mais recoil
- **HP**: mais dano crítico
- **Match**: mais alcance, mais mira, scaling de crit
- **Tracer**: aplica Marked e Revealed, compensa recoil mais fácil
- **Subsonic**: reduz ruído (necessário com supressor para silêncio efetivo)
- **Slug**: projétil único para shotgun
- **5.45**: efeito de tumbling (+crit chance)
- **5.56**: efeito de fragmentação (+crit damage)

**Arquivos principais:**
- `Code/__CaliberParams.lua` — tabela de modificadores por tipo de munição
- `Code/CaliberApplyParams.lua` — aplicação dos params às classes de calibre
- `Code/ZULIBCalibers_GBOconfigs.lua` — calibres adicionados pelo Zulib Weapons Core

**Depende de:**
- Zulib Weapons Core (calibres customizados)
- Sistema de Recoil (calibres têm breakpoints de Força)

**Do qual dependem:**
- Sistema de Recoil (`ratG_recoilData` indexado por calibre)
- Sistema de Críticos (calibres com efeitos especiais)
- Sistema de Stealth (Subsonic necessário para silêncio real)
- CTH (range e penetração afetam acerto indireto)

**Complexidade de manutenção: simples**
— Params centralizados, aplicação declarativa. Adicionar um calibre novo requer
entrada no `__CaliberParams.lua` e em `ZULIBCalibers_GBOconfigs.lua` se for do Zulib.

---

## Sistema 9 — Scopes e Alcance

**O que faz (gameplay):**
Scopes dão bônus de alcance significativo (5 níveis de magnificação). Scopes de alta
magnificação aplicam penalidade crescente ao atirar em alvos próximos — quanto mais
perto do alvo, maior a penalidade. A penalidade é proporcional ao bônus de alcance.

**Arquivos principais:**
- `Code/CTH_scope.lua` — penalidade de close range para scoped weapons
- `Code/PATCH_GBOComponents.lua` — valores de alcance por nível de scope

**Depende de:**
- Weapon Properties (componente de scope equipado, bônus de range)
- Sistema de CTH (penalty inserida no pipeline)

**Do qual dependem:**
- Sistema de Críticos (scopes dão bônus de crit chance)
- Ação de Snipe/Pindown (synergiza com max aim levels de scopes)

**Complexidade de manutenção: simples**
— A penalidade é uma fórmula simples aplicada a um único CTH modifier.

---

## Sistema 10 — Run-and-Gun

**O que faz (gameplay):**
Permite atirar em movimento. A penalidade de acerto escala com a distância ao alvo —
letal de perto, impreciso à distância. O alcance do movimento depende da Agilidade e
do peso/bulk da arma.

**Arquivos principais:**
- `Code/CTH_rungun.lua` — penalidade por distância
- `Code/COMBAT_ACTIONS.lua` — AP cost e range de movimento da ação
- `Code/__MainParams.lua` — constantes de distância máxima e penalidade

**Depende de:**
- Sistema de Hipfire/Snapshot (usa hipfire como base de penalidade)
- Unit Properties (Agilidade determina range de movimento)
- Weapon Properties (bulk/peso afeta range)

**Do qual dependem:**
- Nenhum sistema depende do run-and-gun como input

**Complexidade de manutenção: simples**

---

## Sistema 11 — Stealth Kill

**O que faz (gameplay):**
Matar silenciosamente é mais difícil contra inimigos alertas (80% de redução na chance).
Inimigos suspeitos têm chance intermediária. Penetração de armadura afeta a chance de
acerto certeiro.

**Arquivos principais:**
- `Code/SOURCE_stealth_calc.lua` — override de `Unit:CalcStealthKillChance()`

**Depende de:**
- Estado de alerta do inimigo (AI state)
- Sistema de Calibres (penetração)

**Do qual dependem:**
- Nenhum outro sistema GBO3 depende diretamente

**Complexidade de manutenção: simples**
— Arquivo único, override direto com lógica simples.

---

## Sistema 12 — Bolt-Action Cycling

**O que faz (gameplay):**
Armas de ferrolho exigem AP extra para ciclar após cada disparo. Dexterity alta
reduz o custo extra. Cria distinção gameplay real entre semi-auto e bolt-action.

**Arquivos principais:**
- `Code/FUNCTIONS_Boltaction.lua` — cálculo do AP extra por cycling
- `Code/COMBAT_ACTIONS.lua` — integração com o custo de AP de disparo

**Depende de:**
- Weapon Properties (flag de bolt-action, `__MainParams.lua` para threshold de Dex)
- Unit Properties (Dexterity)

**Do qual dependem:**
- Ação de Snipe/Pindown (bolt-action + snipe = combo de dano alto mas lento)

**Complexidade de manutenção: simples**

---

## Sistema 13 — Targeted Shot (Snipe/Pindown Rework)

**O que faz (gameplay):**
Rebatizado de "Snipe". Garante ataque com máximo de níveis de mira, bônus de crítico,
penalidade reduzida para acertar partes do corpo, e ignora cobertura baixa. Escala com
Composure (Marksmanship + Wisdom). Snipers têm scaling melhor. Tiro único tem melhor
scaling. Synergiza com scopes que aumentam níveis máximos de mira.

**Arquivos principais:**
- `Code/CTH_targeted_noburst.lua` — modificador de CTH (ativo somente com mira máxima)
- `Code/FUNCTIONS_Critical.lua` — bônus de crítico da ação de Snipe
- `Code/UnitProperties.lua` — cálculo de Composure

**Depende de:**
- Sistema de Críticos (bônus especial de crit)
- Sistema de Scopes (max aim levels aumentados por scope)
- Unit Properties (Composure)
- Bolt-Action Cycling (combo natural)

**Do qual dependem:**
- Nenhum outro sistema depende como input

**Complexidade de manutenção: simples**

---

## Sistema 14 — Dual Shot

**O que faz (gameplay):**
Disparar duas armas ao mesmo tempo. AP reduzido, máximo de 1 nível de mira.
Penalidade escala com distância e Dexterity do atirador.

**Arquivos principais:**
- `Code/CTH_2weaponfire.lua` — penalidade de CTH
- `Code/COMBAT_ACTIONS.lua` — AP cost e max aim

**Depende de:**
- Unit Properties (Dexterity)
- Sistema de CTH (penalty aplicada ao pipeline)

**Do qual dependem:**
- Shooting Stance (stance afeta cone de rotação para dual shot)

**Complexidade de manutenção: simples**

---

## Sistema 15 — Overwatch

**O que faz (gameplay):**
Overwatch dispara quando inimigo entra no cone de visão. MG Setup aumenta bônus de
precisão de intercept. Snapshot penalty afeta a precisão do intercept. Stance afeta
o comportamento do overwatch.

**Arquivos principais:**
- `Code/CTH_ow_cth.lua` — modificadores de CTH de overwatch
- `Code/SOURCE_shooting_stance_overwatch_function_n_attacks.lua` — overwatch em stance
- `Code/SOURCE_IsOverwatchAction.lua` — identificação da ação
- `Code/COMPATIBILITY_SmartOverwatch.lua` — integração com SmartOverwatch mod

**Depende de:**
- Sistema de Snapshot (penalidade de snapshot em intercepts)
- Sistema de Shooting Stance (stance modifica comportamento)
- Weapon Properties (MG Setup bonus)

**Do qual dependem:**
- Nenhum sistema interno depende do overwatch como input

**Complexidade de manutenção: moderada**
— A integração com SmartOverwatch adiciona superfície de compatibilidade. A interação
stance + overwatch é delicada (arquivo SOURCE_).

---

## Sistema 16 — Balanceamento de Armas (Weapon Patching)

**O que faz (gameplay):**
Define os valores base de todas as armas do jogo: dano, alcance, magazine, acerto,
AP de stance, multiplicadores de recoil/hipfire/snapshot, slots de componentes. É
o principal vetor de balance numérico do mod.

**Arquivos principais:**
- `Code/PATCH_GBO_weapons.lua` — arquivo principal (auto-gerado, grande)
- `Code/PATCH_WeaponsPresetClass.lua` — templates por classe de arma
- `Code/PATCH_GBOComponents.lua` — balance de componentes
- `Code/PATCH_CharacterEffectPresets.lua` — patching de efeitos
- `Code/PATCH_old_ammo.lua` — compatibilidade com munição legada
- `Code/Assign_magsize.lua` — tamanhos de magazine
- `Code/UPDATE_Change components.lua` — ajustes de componentes

**Depende de:**
- Zulib Weapons Core (classes e propriedades base de arma)
- Todos os sistemas (os valores aqui alimentam recoil, hipfire, scope, etc.)

**Do qual dependem:**
- Todos os sistemas (lêem propriedades definidas aqui)

**Complexidade de manutenção: moderada**
— Cada arma individual é simples de ajustar. O risco é de inconsistências entre armas
(uma classe inteira com valor errado) e conflito com patches de compatibilidade.
`PATCH_GBO_weapons.lua` sendo auto-gerado limita edição manual segura.

---

## Sistema 17 — Balanceamento de IA

**O que faz (gameplay):**
A IA recebe redução nas penalidades de CTH em dificuldades mais altas. Compensa o
fato de que jogadores humanos usam mecânicas (stance, recoil management) que a IA
não usa plenamente, mantendo o combate desafiador.

**Arquivos principais:**
- `Code/FUNCTIONS_AI_custom.lua` — `AIpenal_reduc()` por nível de dificuldade
- `Code/SOURCE_AISignatureAction_MatchUnit.lua` — ações de assinatura da IA

**Depende de:**
- Sistema de CTH (redução aplicada às penalidades)
- Configuração de dificuldade do jogo

**Do qual dependem:**
- Nenhum sistema interno

**Complexidade de manutenção: simples**

---

## Sistema 18 — Status Effects Customizados

### 18a — Rat_recoil
Acúmulo de recoil como status. Ver Sistema 1.

### 18b — Shooting Stance
Status que marca o merc como "em stance". Ver Sistema 2.

### 18c — Marked
Aplicado por tracer ammo. +10 CTH e +15 crit chance ao alvo. Dura até fim do turno.
**Complexidade: simples**

### 18d — Revealed
Aplicado por tracer ammo. Facilita acertar alvos no escuro.
**Complexidade: simples**

### 18e — Out of Breath (R_outofbreath)
Reduz AP e free move por stack. Reduz efetividade de mira. Duração escala com Tiredness.
Afeta qualquer ação que consome AP.
**Complexidade: moderada** — afeta AP pool e mira; interage com Savior Adrenaline Rush.

### 18f — Sprinting
Torna o merc mais difícil de acertar enquanto se move rápido.
**Complexidade: simples**

### 18g — Shoot-and-Move (shoot_move)
Pistolas e SMGs ganham free move após atirar. Encourage uso agressivo de armas curtas.
**Complexidade: simples**

---

## Sistema 19 — Perks Customizados

### 19a — Savior / Adrenaline Rush
Quando aliado é derrubado ou morre, o merc ganha AP bônus e free move no próximo turno.
Arquivos: `CharacterEffect/AdrenalineRush_Savior.lua`, `Code/REACTIONS.lua`
**Complexidade: simples**

### 19b — Grunty (Überraschung)
No início do combate, ataca o inimigo mais próximo com 1 nível de mira.
Só funciona com armas de fogo não-pesadas.
Arquivos: `CharacterEffect/GruntyPerk.lua`, `CharacterEffect/grunty_bonus.lua`
**Complexidade: simples**

---

## Sistema 20 — Stealth e Supressores

**O que faz (gameplay):**
Supressores cortam o raio de ruído pela metade (não eliminam). Para silêncio real,
é necessário usar munição Subsonic. Inimigos têm alcance de detecção aumentado.
Stealth kill em inimigos alertas tem chance muito reduzida.

**Arquivos principais:**
- `Code/SOURCE_stealth_calc.lua` — chance de stealth kill
- `Code/__CaliberParams.lua` — propriedade de ruído do Subsonic
- `Code/CaliberApplyParams.lua` — aplicação do modificador de ruído

**Depende de:**
- Sistema de Calibres (Subsonic)
- Estado de alerta dos inimigos

**Do qual dependem:**
- Nenhum sistema interno

**Complexidade de manutenção: simples**

---

## Sistema 21 — Mod Options (Customização do Jogador)

**O que faz (gameplay):**
Permite ao jogador ajustar parâmetros via menu de opções do jogo:
alcance de visão, dano, multiplicadores de mira/overwatch/marksmanship, ruído.
Detecta SmartOverwatch automaticamente.

**Arquivos principais:**
- `Code/CONSTANTS_mod_options.lua` — parsing e aplicação das opções
- `metadata.lua` — definição das opções disponíveis

**Depende de:**
- Todos os sistemas (opções modificam constantes lidas pelos outros sistemas)

**Do qual dependem:**
- Nenhum (ponto de entrada de configuração)

**Complexidade de manutenção: simples**
— Adicionar uma opção nova requer entrada no `metadata.lua` e leitura em
`CONSTANTS_mod_options.lua`. Risco principal: opções que interagem entre si.

---

## Sistema 22 — Compatibilidade com Outros Mods

**O que faz:**
Adapta o GBO3 para funcionar com mods externos sem conflito.

| Arquivo | Mod alvo | O que faz |
|---|---|---|
| `COMPATIBILITY_SmartOverwatch.lua` | SmartOverwatch | AP cost de MG Setup |
| `COMPATIBILITY_RevMags.lua` | Revised Mags II | Magazine sizes |
| `COMPATIBILITY_ZulibCalibersAttachOffset.lua` | Zulib Weapons Core | Attach offsets |
| `COMPATIBILITY_DescriptiveCTH.lua` | Descriptive CTH | Integração de CTH display |
| `TOC_ChangeEntity.lua` | Tons of Guns (ToG) | Visuais de scopes customizados |

**Complexidade de manutenção: moderada por arquivo**
— Cada arquivo é isolado, mas depende de APIs de mods de terceiros que podem mudar
sem aviso. `PATCH_call.lua` verifica versão do Zulib e alerta se desatualizado.

---

## Mapa de Dependências — Visão Geral

```
Mod Options ──────────────────────────────────────────────────────────────┐
                                                                           ↓
Calibres & Ammo ──────────┬──────────────────────────────────┐   Constantes globais
                           ↓                                  ↓
Weapon Patching ──────────→ Recoil ──────────────────→ CTH Pipeline ←────────┐
       ↓                   ↑  ↓                           ↑ ↑ ↑ ↑ ↑ ↑       │
Weapon Properties ─────────┘  ↓ (stacks)           Scope │ │ │ │ │ └── AI   │
       ↓                   Status: Rat_recoil   Hipfire/Snap │ │ │          │
Unit Properties ───────────────────────────────→ Aim Bonus   │ │ Overwatch  │
       ↓                                         Point-Blank  │            │
Hand-Eye / Composure ──────────────────────────→ Críticos     │            │
                                                  ↑            │            │
Shooting Stance ──────────────────────────────────┘   Run&Gun  │            │
       ↓                                                         │            │
COMBAT_ACTIONS ──────────────────────────────────────────────────┘            │
  (SingleShot, Burst, Auto, Shotgun, RunAndGun, DualShot, Snipe, Sprint)      │
       ↓                                                                       │
Shotgun Pellets ←─ SOURCE_FirearmFireBullet (override crítico) ────────────────┘

Status Effects: Marked, Revealed, Out-of-Breath, Sprinting, Shoot-and-Move
Perks: Savior, Grunty
Stealth: SOURCE_stealth_calc
Compatibility: SmartOverwatch, RevMags, Zulib, DescriptiveCTH, ToG
```

---

## Resumo de Complexidade

| Sistema | Complexidade | Principal risco de manutenção |
|---|---|---|
| Recoil Acumulativo | complexa | Calibre × componente × AP cost × status |
| Shooting Stance | complexa | Múltiplos SOURCE_ + UI + animação + overwatch |
| Shotgun Pellets | complexa | SOURCE_FirearmFireBullet (override frágil) |
| CTH Modular | moderada | Interações acumuladas entre modifiers |
| Autofire e Modos de Fogo | moderada | Dano total = balas × recoil × crit |
| Overwatch | moderada | Stance + SmartOverwatch + snapshot |
| Balanceamento de Armas | moderada | Escala (todas as armas), PATCH_GBO_weapons auto-gerado |
| Compatibilidade | moderada | APIs de terceiros podem mudar |
| Calibres e Ammo | simples | Declarativo, centralizado |
| Hipfire e Snapshot | simples | Params centralizados |
| Críticos | simples | Um arquivo, evento padrão do engine |
| Scopes | simples | Um CTH modifier |
| Run-and-Gun | simples | Um CTH modifier + COMBAT_ACTIONS |
| Stealth Kill | simples | Um arquivo SOURCE_ |
| Bolt-Action Cycling | simples | Um arquivo de funções |
| Targeted Shot (Snipe) | simples | Dois arquivos, lógica direta |
| Dual Shot | simples | Um CTH modifier |
| Balanceamento de IA | simples | Um arquivo de funções |
| Status Effects simples | simples | Cada um isolado em CharacterEffect/ |
| Perks customizados | simples | Cada um isolado em CharacterEffect/ |
| Stealth & Supressores | simples | Parametrizado nos calibres |
| Mod Options | simples | Declarativo em metadata + parsing |

---

*Próximo passo sugerido: priorizar refatoração pelos sistemas de alta complexidade
(Recoil, Shooting Stance, Pellets) e garantir cobertura de testes manuais antes.*

# GBO3 · CTH Angular — Mapa de Código

Mapa dos pontos que terão que mudar para trocar o CTH somado por um CTH derivado
de geometria (cone de abertura × silhueta). **Nada implementado.** Este documento
é para o Opus planejar a implementação; o Sonnet só levantou o terreno.

Complementa `GBO3-refactor-chance-to-hit.md` (o modelo). Onde os dois divergem,
vale o que está aqui — abaixo estão as correções que o autor pediu.

---

## Correções ao modelo original (`GBO3-refactor-chance-to-hit.md`)

| Ponto no MD original | Correção |
|---|---|
| "OverwatchAngle → cone de quadril" | **Não reusar `OverwatchAngle` diretamente.** Ele continua vivo e necessário para rotação de arma / shooting stance / cones de AOE. Criar **propriedade nova** (ex. `rat_aperture_base` ou `HandlingAperture`). Pode ser *semeada* a partir do `OverwatchAngle` no patch de armas como estimativa inicial, mas é um campo independente e com polaridade própria. |
| "Manejo → hipfire melhor" (armas leves boas no hipfire) | No GBO3 as armas leves/curtas são boas em **Snapshot**, não em Hipfire. O `class_base_snapshot_mul` de SMG é 85 e de Pistol 60 (bons), enquanto `class_base_hipfire_mul` de SMG é 120 e Pistol 145 (ruins). A abertura derivada do manejo tem que puxar o **cone de snapshot** para baixo, não o de hipfire. |
| "Cover: nível 1 (100 − coverage) antes do nível 2" | O autor prefere ir direto para **raycasting / sondagem de silhueta** (nível 2), desde que a previsão (crosshair + IA) não destrua a performance. O nível 1 pode entrar só como fallback. |
| "recoil vira −8 flat/tiro" na tabela comparativa | O recoil antigo **nunca foi flat**: `get_recoil` (`FUNCTIONS_recoil.lua:619-625`) tem rampa de distância `MulDivRound(dist, max_penalty - penalty, max_dist)` com `MaxDistforPenalty = 36` tiles. A taxa de crescimento do cone por tiro tem que **continuar crescendo com a distância**, não ser constante. |

---

## 0. Ordem de carregamento (onde plugar o novo modificador)

- [Code/OnDataLoaded.lua](Code/OnDataLoaded.lua) — `rat_apply_changes()` chama, nesta ordem, todos os construtores de `ChanceToHitModifier`:
  `aim_cth` · `two_weaponcth` · `autofire_range` · `bipod_standing` · `prone_cover` · `ow_cth` · `runandgun_cth` · `targeted_noburst` · `point_blank_cth` · `place_standing_penalCTH` · `place_ranged_melee_CTH` · `place_scope_pen_cth` · `place_hipfire_cth`.
  Roda em `OnMsg.DataLoaded`. **Aqui entra o novo `place_angular_cth()`** (ou a reescrita em bloco).
- [Code/_______init_globals.lua](Code/_______init_globals.lua) — tabelas globais (`ratG_T_table`, `ratG_recoilData`); declarar aqui LUT de Rayleigh / constantes de silhueta.
- [Code/__MainParams.lua](Code/__MainParams.lua) / [Code/__SnapshotHipfireParams.lua](Code/__SnapshotHipfireParams.lua) / [Code/__RecoilParams.lua](Code/__RecoilParams.lua) — onde declarar `const.Combat.Aperture = {...}` (HipBase, SnapBase, FloorPct, LUT).

O pipeline do engine que consome tudo isso:
- `Unit:CalcChanceToHit` — `Src/Lua/Tactical/Unit.lua:6947`. Loop `ForEachPreset("ChanceToHitModifier", ...)` em `:7065`, `base = base + value` em `:7103`. É a soma que o modelo quer substituir por um único termo geométrico. **Não precisa dar override nesta função** se o modelo híbrido for adotado (um modifier novo que retorna o CTH inteiro, com os outros desligados).

---

## 1. Núcleo: o cone de abertura e a conversão para CTH

**Arquivos novos a criar** (não existem hoje):
- `Code/CTH_angular.lua` — `f_handling`, `f_skill`, `aim_decay`, `theta_target`, `rat_aperture`, LUT Rayleigh, o `ChanceToHitModifier` "AngularCTH".
- Possivelmente `Code/FUNCTIONS_aperture.lua` — helpers consultáveis pela IA e pela UI sem efeito colateral (espelhar o padrão de `Rat_GetRecoilAimCost`).

**Propriedade nova de arma** — declarar via `AppendClass.Firearm` / `AppendClass.FirearmProperties` em `OnMsg.ClassesGenerate`, no mesmo estilo de:
- [Code/__SnapshotHipfireParams.lua:54-74](Code/__SnapshotHipfireParams.lua) (`class_base_hipfire_mul`, `class_base_snapshot_mul` + valores por classe)
- [Code/__RecoilParams.lua:38-48](Code/__RecoilParams.lua) (`class_base_recoil`)
- [Code/WeaponProperties.lua:221,288,302](Code/WeaponProperties.lua) (`wep_base_recoil_mul`, `wep_base_hip_mul`, `wep_base_snapshot_mul`)

Valores por arma: [Code/PATCH_GBO_weapons.lua](Code/PATCH_GBO_weapons.lua) — hoje seta `<Weapon>.OverwatchAngle` para as 45 armas (linhas 12–1776). O novo campo de abertura seria setado no mesmo lugar, no mesmo loop.

**Silhueta / alvo** — precisa de `const.SlabSizeX` real e meia-largura do torso/cabeça. Medir no jogo (o autor vai rodar). Sem isso as constantes são chute.

---

## 2. Hipfire / Snapshot → multiplicadores de cone

- [Code/CTH_hipfire_and_snapshot.lua](Code/CTH_hipfire_and_snapshot.lua) — `place_hipfire_cth()`, modifier `HipshotPenalty`. Hoje:
  - `dist` (linha 69), curva hipfire linear até `Hipfire.MaxDistforPenalty` (`:151-154`), curva snapshot até `Snapshot.MaxDistforPenalty` (`:196-229`), `base_penal` com rampa de distância (`:170-176`, `:221-227`).
  - **`aim > 2` retorna cedo (`:61-63`)** — é *a* razão da "distância parar de existir na mira alta". No modelo angular esse early-return some: a distância age em todos os níveis via razão silhueta/cone.
  - Ramos especiais que precisam sobreviver: `MGSetup`/`MGRotate` (`:48-51`), MG em interrupção (`:215-219`), `Overwatch`/`MobileShot`/`RunAndGun` sempre snapshot (`:53`), `DualShot` média de duas armas (`:97-104`), `GrizzlyPerk` (`:164-168`), `KnifeThrow` (`:187-193`).
- [Code/FUNCTIONS_hipfire.lua](Code/FUNCTIONS_hipfire.lua) — `GetWeaponHipfireOrSnapshotMul(weapon, attacker, action, display, aim)`. Produto multiplicativo puro: `wep_base_*_mul` × `class_base_*_mul` × componentes (laser, grips, stocks, bullpup, barril curto/longo, drum mag, choke...). **Este produto já é a "taxa de fechamento/abertura do cone" — reaproveita quase inteiro.** Só muda o consumidor: em vez de virar `penalty` %, multiplica `theta`.
  - `aim == 0` → ramo hipfire (`:17-19`, `:70-117`); `aim > 0` → ramo snapshot (`:20-23`, `:119-190`). **Manter os dois ramos, mas lembrar: no GBO3 arma leve = bom snapshot.**
- [Code/__SnapshotHipfireParams.lua](Code/__SnapshotHipfireParams.lua) — todas as constantes (`BasePenalty`, `MaxPenalty`, `MaxDistforPenalty`, `Components.*Mul`, `class_base_*_mul` por classe). Viram fatores de cone. Os `*Mul` de componente (0.90, 1.08...) **mantêm o significado**; os `MaxPenalty` (−123, −61) são substituídos pela geometria.
- [Code/CTH_targeted_noburst.lua:31-36](Code/CTH_targeted_noburst.lua) — aplica `(-) Hipfire` / `(-) Snapshot` como multiplicador no bônus de tiro alvejado. Consome o conceito de aim level, não o CTH; provavelmente **continua percentual** (balde 3 do modelo).

---

## 3. Aim → estreitar o cone (não somar pontos)

- [Code/CTH_aim.lua](Code/CTH_aim.lua) — `aim_cth()`, override de `Presets.ChanceToHitModifier.Default["Aim"].CalcValue`. É o modifier mais pesado do mod:
  - `min_bonus = weapon1.AimAccuracy` (`:68`) — vira o fator `aim_decay` (quanto cada nível fecha o cone).
  - `bonus = num * min_bonus` (`:132`) linear em aim — no modelo vira produto `theta * decay^aim`.
  - `scale_factor` por Hand-Eye Coordination (`:125-131`) — Dex+Marks baixos = menos benefício de mira. **Semanticamente encaixa perfeito**: escala o quanto o decay morde.
  - Bônus de scope por nível: PSO-1 (`:97-102`), sniper 4x (`:103-108`), sniper 6x (`:110-115`). Viram `+MaxAimActions` + rebaixamento do piso mecânico (ver §6).
  - Handgun `min_bonus * 0.5` (`:78-82`), mobile `mobile_mul` (`:90-95`), crouch/prone muls (`:202-217`), grips/sights/stocks (`:137-190`), camo (`:193-200`), heavy rain (`:256-260`), `IsFullyAimedAttack` heavy stock (`:232-239`).
  - `const.Combat.R_AimMul` (`:262`) — dial global de mod option (ver §9).
  - Retorno `num > 0` como primeiro valor: **só a 1ª bala pega mira** (`:248-254` + `SOURCE_FirearmGetAttackResults.lua:263-265`).
- [Code/Aim_Scaling.lua](Code/Aim_Scaling.lua) — `GetScaledAimBonus(weapon1)` — cópia parcial da lógica de `CTH_aim` para exibição (tem `print("oi")`, meio abandonada). Se existir consumidor, atualizar junto ou remover.
- [Code/CTH_pointblank.lua](Code/CTH_pointblank.lua) — `point_blank_cth()`, modifier `PointBlank`. Bônus que **cresce ao aproximar** e escala com Hand-Eye + `R_AimMul`. No modelo angular, perto o alvo já é maior que qualquer cone → o bônus de point-blank fica redundante ou vira um piso de CTH. Decidir: manter como percentual (balde 3) ou absorver na geometria.
- `SOURCE_shooting_stance_BaseAimLevel.lua`, `Src/.../CombatAction.lua` `GetMaxAimActions`/`GetMaxAimRange` — teto de níveis de mira; scope aumenta via `IncreaseMaxAimActions` (`Code/COMPONENT_weaponcomp_effects.lua:567-576`, `StatToModify = "MaxAimActions"`).

---

## 4. Recoil / rajada → taxa de abertura do cone por tiro

- [Code/FUNCTIONS_recoil.lua](Code/FUNCTIONS_recoil.lua) — tudo multiplicativo, migração barata:
  - `GetWepRecoil` (`:84-240`) — produto arma × classe × mecanismo × componentes. **Vira taxa de crescimento do cone.**
  - `GetCaliberStrRecoil` (`:242-290`) — breakpoint de Força por calibre, `str_mod_f ^ 1.9`, tracer/AP. Breakpoints sobrevivem: definem *quão rápido* o cone abre.
  - `GetRecoilOther` (`:292-385`) — stance, marks (`MarksmanshipMaxReduction`), perks (TakeAim, AutoWeapons), burst/auto/long deltas.
  - `get_recoil(...)` (`:502-670`) — **a rampa de distância está aqui**: `:619-625`, `max_dist = MaxDistforPenalty(36) * SlabSizeX`, `penalty = penalty + Min(-1, MulDivRound(dist, max_penalty - penalty, max_dist))`. **A taxa de abertura por tiro TEM que continuar função da distância** (correção do autor). Depois `+ flat_penalty` (`:652`), `* R_Recoil`/`* R_RecoilP` (`:665,669`), `AIpenal_reduc` (`:649`).
  - `get_recoilP_value(...)` (`:672-764`) — versão persistente, **sem** rampa de distância (usa só `param_base`). Alimenta `Rat_GetRecoilAimCost`.
  - `Rat_GetRecoilAimCost` / `Unit:ApplyPersistantRecoilEffects` (`:34-82`) — sobretaxa de AP de mira por recoil acumulado. **Independente da geometria; continua intacta.** O modelo sugere que o `Rat_recoil` persistente também possa deixar o cone parcialmente aberto no início do próximo ataque.
- [Code/SOURCE_FirearmGetAttackResults.lua](Code/SOURCE_FirearmGetAttackResults.lua) — onde o recoil é consumido hoje:
  - `:238-253` — chama `get_recoil(...)`, extrai `aim_cth` dos modifiers, seta `shot_attack_args.cth_loss_per_shot = -recoil`.
  - `:256-280` — loop por tiro: `shot_cth = original_cth - cth_loss_per_shot * Min(i-1, MaxShotIndexForRecoilCTHLoss)`; `if i > 1 then shot_cth = shot_cth - aim_cth` (2ª bala perde mira); `Clamp(0,100)`; `min_chance = Min(MultishotMinCTH, original_cth)`.
  - **No modelo angular:** cada tiro `i` recalcula CTH com `theta_i = theta_base * growth^(i-1)`, `growth` dependente da distância. O `shot_cth - aim_cth` para `i>1` sai de graça (o cone da bala 2+ não tem o decay de mira). `MultishotMinCTH` (`__MainParams.lua:18`) **deixa de ser necessário** — a geometria não zera de perto.
  - `CalcShotVectors` / `CalcMissVectors` (`Src/Lua/Tactical/Weapon.lua:1612`, `:1774`) e `GetMaxDispersion` (`:1296`) — geometria *encenada* a partir de `num_hits`/`num_misses`. No híbrido continuam iguais (consomem a decisão já tomada). Só um NCTH puro mexeria aqui.
- `CharacterEffect/Rat_recoil.lua:140`, `items.lua:567`, `Code/XTEMP_recoil.lua:183` — outros chamadores de `get_recoil` (efeito persistente, weapon comp, display). Rastrear a assinatura se mudar.
- [Code/CTH_autofire_recoil.lua](Code/CTH_autofire_recoil.lua) — `autofire_range()` hoje só faz `return false, 0` (desligado). Pode virar o lugar do termo de rajada, ou continuar morto.
- [Code/__RecoilParams.lua](Code/__RecoilParams.lua) — todas as constantes de recoil (Components, Perks, Other, breakpoints via `ratG_recoilData`). Viram fatores de taxa de cone.

---

## 5. Cover / postura → silhueta menor (raycasting)

- [Code/CTH_cover_prone.lua](Code/CTH_cover_prone.lua) — `prone_cover()`, override de `Default["RangeAttackTargetStanceCover"].CalcValue`:
  - `cover = -35`, `prone = -30`, `crouch = -12` (`:2-4`) — os flats a eliminar.
  - `target:GetCoverPercentage(attacker_pos, target_pos)` (`:69`, `:107`) → `PosGetCoverPercentageFrom` (C++, `Src/Lua/Tactical/Cover.lua:103`) — consulta direcional por voxel.
  - `InterpolateCoverEffect(coverage, full, exposed)` (`:90`, `:124`) → `Src/Lua/Tactical/Unit.lua:8699` — a escada de 3 degraus (threshold 40, ≥80) que esmaga a % de cobertura. **Substituir por `exposto = 100 − coverage` (nível 1) ou sondagem de silhueta (nível 2, preferido pelo autor).**
  - Rampa de distância para prone (`:46-59`) e crouch (`:131-146`) — já é linear na distância; no modelo vira silhueta reduzida.
  - `IgnoreCoverCtHWhenFullyAimed` (`:65`), `Exposed` status (`:68`), peek/`return_pos` (`:99-128`), dust storm (`:84-88`).
- `Src/Lua/Tactical/Cover.lua:281` (vanilla) — "low cover em pé não existe": `if cover == coverLow and target_stance == "Standing" then cover, coverage = false, 0`. Override para deixar low cover valer algo em pé.
- **Nível 2 (raycasting):** reusar a máquina de `Firearm:GetPelletScatterData` ([Code/FUNCTION_GetPelletScatterData.lua](Code/FUNCTION_GetPelletScatterData.lua)) como *instrumento de medição*: 6–9 `GetLoFData` determinísticos contra pontos fixos do corpo, contando quantos chegam. Já faz θ/raio/`RotateAxis`/`GetLoFData` sem rolar CTH.
  - **Risco de performance / desync (o ponto que o autor levantou):**
    - `SOURCE_FirearmGetAttackResults.lua:491` avisa "dispersion uses synced random, executar da UI causa desync". Raios em pontos **fixos** não consomem random → seguros na previsão. Confirmar que `GetLoFData` nesse caminho não puxa seed.
    - `NetUpdateHash` em `:318-325` e `:916-919` — qualquer float novo na geometria em partida co-op = desync. Manter aritmética inteira.
    - IA: `AIPrecalcConeTargetZones` (`Src/Lua/Tactical/CombatAI.lua:2040`) avalia muitas posições/turno; descarta alvos com `chance_to_hit == 0` (documentado em `CTH_hipfire_and_snapshot.lua:36-41`). Sondagem por posição × cache é obrigatória. Ver §7.
  - **Nível 3 (cache):** tupla `(attacker_pos, target, stance)`, invalida em movimento — para o crosshair não re-raycastar a cada frame de hover.
- [Code/__MainParams.lua:6-10](Code/__MainParams.lua) — `SprintingCTH = -10`, `CrouchAimMul`, `ProneAimMul` (mira do atacante, não silhueta do alvo — ficam).
- Silhueta por body part: tiro na cabeça = trocar meia-largura 25 cm → 9 cm. Cabeça atrás do muro: os raios daquela região não chegam → generaliza o teste de bloqueio total que o jogo já faz.

---

## 6. Scopes / componentes

- [Code/CTH_scope.lua](Code/CTH_scope.lua) — `place_scope_pen_cth()`, modifier `ScopePenal`. `ScopePenalty1/2/3` = penalidade de curto alcance de óptica de alta magnificação (`-20`/`-40`/`-55`, rampas em 7/14/17 tiles). **Vira alargamento do cone abaixo da distância mínima do scope** — coerente com o modelo, e ainda mais legível.
- `RangeIncrease` (weapon comp effect, `items.lua` várias linhas; `Code/COMPONENT_weaponcomp_effects.lua`) — no modelo angular **pode ser removido**: alcance efetivo = consequência de cone fechado. O scope entrega alcance só via `+MaxAimActions` (destrava gasto de AP) **+ rebaixar o piso mecânico do `WeaponRange`** (dá espaço pro cone continuar fechando). Sem o segundo, níveis de mira extras são desperdiçados (achado da simulação no MD).
- `IncreaseMaxAimActions` / `MaxAimActionsIncrease` (`Code/COMPONENT_weaponcomp_effects.lua:567-576`) — mantém.
- `Code/CTH_aim.lua:97-115` — bônus de scope por nível de mira (ver §3).
- [Code/CTH_bipod.lua](Code/CTH_bipod.lua) — `bipod_standing()`, modifier `Bipod`. `bipod_penalty` em pé (−5), `AccuracyBonusProne`. Vira multiplicador de cone (balde 1).
- [Code/CTH_held_mg.lua](Code/CTH_held_mg.lua) — inteiro comentado/morto. Ignorar ou reviver como fator de cone.
- `WeaponRange` como piso mecânico: `theta_target(WeaponRange * SlabSizeX, 25) * FloorPct/100`. Scopes rebaixam esse piso.

---

## 7. IA (validar cedo — consumidor mais silencioso)

Mod: `Rato's AI Overhaul` (requer GBO3, acoplamento forte). Arquivos que tocam cone / CTH:
- `Code/SOURCE_AIPrecalcConeTargetZones.lua` — override de `AIPrecalcConeTargetZones` (`Src/Lua/Tactical/CombatAI.lua:2040`). Descarta alvos com CTH 0 do cone. **Se a geometria mudar a forma da curva, revalidar os thresholds aqui.**
- `Code/SOURCE_AICalcAttacksandAim.lua`, `Code/FUNCTION_ScoreAttacksDetailed.lua`, `Code/SOURCE_AIGetAttackTargetingOptions.lua` — usam `chance_to_hit` para orçar ataques/mira.
- `Code/FUNCTION_SignaturesCustomScoring.lua`, `Code/AIACTION_PrepareWeapon.lua`, `Code/AIPOLICYPOS_MGSetupPosScore.lua` — signature actions (MGSetup etc.) dependem de CTH previsto ≠ 0.
- `Code/AIPOLICYPOS_ThreatExposure.lua`, `AIPOLICYPOS_AvoidThreatenedAreas.lua`, `SOURCE_AIPolicyHighGround.lua`, `AIPOLICYPOS_ThreatExposure` — se a silhueta ocluída passar a variar com a posição, a IA ganha avaliação de flanqueamento **de graça** — mas é o maior risco de custo (muitas posições × raycast). Cache do nível 3 deixa de ser opcional.
- `AIpenal_reduc(attacker, value, ...)` — usado em quase todo modifier (`CTH_hipfire_and_snapshot.lua:161`, `CTH_scope.lua:57`, `FUNCTIONS_recoil.lua:649`, `CTH_rungun.lua:36`, `ow_cth`, ...) para suavizar penalidades da IA. No modelo angular precisa de um equivalente que atue no `theta` (multiplicador de cone para IA).
- `PERF_PROFILING.md`, `POLICY_BUDGET.md` no AI Overhaul — orçamento de performance já documentado; medir o raycast contra ele.

---

## 8. UI / crosshair / prediction

- `Src/.../CombatActionGenericAttackGetUIState` — [Code/SOURCE_CombatActionGenericAttackGetUIState.lua](Code/SOURCE_CombatActionGenericAttackGetUIState.lua).
- [Code/SOURCE_IModeCombatAreaAim_UpdateTarget.lua](Code/SOURCE_IModeCombatAreaAim_UpdateTarget.lua), [Code/SOURCE_shooting_stance_crosshair_ui.lua](Code/SOURCE_shooting_stance_crosshair_ui.lua) — crosshair.
- O crosshair chama `CalcChanceToHit` com `prediction = true`. O caminho angular tem que ser **determinístico e barato** nesse modo (LUT, sem random, com cache).
- [Code/COMPATIBILITY_DescriptiveCTH.lua](Code/COMPATIBILITY_DescriptiveCTH.lua) — `redefine_crosshairUI_function()` para o mod Descriptive CTH (`N6rmtjQ`). Depende de uma **lista aditiva de modifiers** para exibir. Com um único termo geométrico essa lista some. Saída natural: reportar contribuições em minutos de cone ("Hipfire +40′, Mira −180′"). **Precisa de reescrita.**
- `Code/DESCRIPTION_HINTS_get.lua:59`, `Code/FUNCTIONS_custom.lua:160`, `Code/WeaponProperties_Get_functions.lua:27` — exibem `OverwatchAngle / 60` como "ângulo de rotação". Continuam usando `OverwatchAngle` (não o novo campo). Se o tooltip também quiser mostrar a abertura, adicionar linha nova.
- `ratG_T_table` (strings T por arquivo, no fim de cada `CTH_*.lua`) — atualizar/limpar conforme modifiers somem.
- `metaText` retornado por cada `CalcValue` — hoje concatenado na UI. Repensar formato.

---

## 9. Mod options (dials globais)

- [Code/CONSTANTS_mod_options.lua:40-52](Code/CONSTANTS_mod_options.lua) — `R_AimMul`, `R_MarksMul`, `R_Recoil`, `R_RecoilP` lidos de `GBOMOD_Options` via `extractNumberWithSignFromString`.
- [Code/CTH_Setting.lua](Code/CTH_Setting.lua) — modifier `_R_Mod_Setting`: hoje `MulDivRound(marks, R_MarksMul - 100, 100)` somado ao CTH (multiplicador flat da régua inteira). No modelo vira escala de `f_skill` (o cone inteiro), mantendo o mesmo significado pro jogador. Também trata `Dexterity`/`Strength` como `UnitStat` (melee) — manter.
- `metadata.lua` — declarações das mod options (NÃO editar sem instrução; mas se surgir option nova de calibração `HipBase`/`FloorPct`, é aqui).
- `recoil_persistent_aim_effect` (`FUNCTIONS_recoil.lua:39`) — option existente, continua.

---

## 10. Migração dos 15 `CTH_*.lua` — três baldes

| Balde | Arquivos / trechos | Destino |
|---|---|---|
| **Multiplicam o cone** | `CTH_hipfire_and_snapshot` + `FUNCTIONS_hipfire`, `CTH_bipod`, `CTH_rungun`, `CTH_held_mg` (morto), `CTH_scope`, `CTH_2weaponfire`, todo `FUNCTIONS_recoil`, `CTH_autofire_recoil` (morto) | fator sobre `theta` |
| **Alteram a silhueta** | `CTH_cover_prone` (cover + prone + crouch), `const.Combat.SprintingCTH`, partes de postura do alvo | reduzem meia-largura aparente |
| **Continuam percentuais** | `CTH_targeted_noburst` (bônus de composure/body part), `CTH_pointblank` (decidir), `CTH_ranged_melee_penal`, `CTH_unwield_weapon`, `CTH_ow_cth`, bônus de perk, efeitos de status | somados ao CTH derivado, como hoje |

`CTH_ranged_melee_penal.lua` (penalidade de barril longo em melee range) e `CTH_unwield_weapon.lua` (arma unwieldy em pé) são pequenos e percentuais — provavelmente balde 3, mas o de melee range poderia virar alargamento de cone a curtíssima distância.

---

## 11. Riscos / dependências transversais

- **`NetUpdateHash`** — `SOURCE_FirearmGetAttackResults.lua:318-325`, `:916-919`; `Unit.lua:7017,7089,7099,7122,7153`. Co-op é lockstep. Toda a aritmética do cone tem que ser inteira (minutos de ângulo, `MulDivRound`, `Clamp`). O engine já trabalha em minutos (`max_angle_offset = 360*60` em `FUNCTION_GetPelletScatterData.lua:16`; `MGSetupConeFlat = 180` "minutes" em `__MainParams.lua:29`).
- **`GatherCTHModifications`** (`Unit.lua:7097`) — hook por-modifier que status effects / componentes usam para injetar CTH. Um modelo de termo único tem que continuar deixando esses hooks funcionarem (balde 3).
- **`GetShotChanceToHit`** (`SOURCE_FirearmGetAttackResults.lua:259`) — override do mod? Verificar. Divide o CTH exibido em CTH por-tiro.
- **Ordem `OnDataLoaded`** — o modifier angular tem que ser colocado depois dos que ele desliga, ou desligar via flag.
- **`items.lua` NUNCA editar** (gerado). Propriedade nova de arma entra por `AppendClass` + patch em `PATCH_GBO_weapons.lua`.
- **Compatibilidades:** Descriptive CTH (§8), Revised Mags II, ToG (`Rato-s-ToG-Compatibility-Patch`), Smart Overwatch (`COMPATIBILITY_SmartOverwatch.lua`). ToG adiciona ~armas → precisam do novo campo de abertura (semear do `OverwatchAngle` no patch da ToG também).
- **`OverwatchAngle` permanece** consumido por: `shooting_stance_functions.lua:107,186` (rotação/cone visual), `SOURCE_R_GetAreaAttackParams.lua:32,39`, `SOURCE_ChangeMGSetupGetAreaParams.lua:19`, `shooting_stance_aoesector_functions.lua`, `DESCRIPTION_HINTS_get.lua:59`, `FUNCTIONS_custom.lua:160`, `COMPONENT_weaponcomp_effects.lua` (`OverwatchAngleFlat/Increase/Decrease`), `Assign_magsize.lua:84`. **Não mexer nesses.**

---

## 12. Ordem de ataque sugerida (para o Opus)

1. **Medir** `const.SlabSizeX` e a silhueta real (torso/cabeça) no jogo — bloqueia tudo.
2. Declarar propriedade de abertura nova (`AppendClass` + semear de `OverwatchAngle` em `PATCH_GBO_weapons.lua`) e `const.Combat.Aperture` + LUT Rayleigh.
3. Criar `Code/CTH_angular.lua` como **um `ChanceToHitModifier` isolado** que retorna o CTH geométrico inteiro, com os antigos (§10 balde 1 e 2) atrás de flag. Plugar em `OnDataLoaded.lua`.
4. Validar IA cedo: `SOURCE_AIPrecalcConeTargetZones.lua` + signature actions, antes de tunar número.
5. Cover: sondagem de silhueta via `GetPelletScatterData` reusado + cache `(pos,target,stance)`. Confirmar ausência de random no caminho.
6. Recoil: converter o produto de `FUNCTIONS_recoil.lua` em taxa de abertura por tiro **mantendo a rampa de distância** (`get_recoil:619-625`); reescrever o loop em `SOURCE_FirearmGetAttackResults.lua:256-280`.
7. Scopes: remover `RangeIncrease`, adicionar rebaixamento de piso mecânico.
8. UI: reescrever `COMPATIBILITY_DescriptiveCTH.lua` para reportar minutos de cone.
9. Tunar `HipBase` / `SnapBase` / `FloorPct` / taxa de crescimento por tiro.

---

## 13. Fontes vanilla (`ModTools/Src`) — o que o refactor toca

Somente leitura. O mod só consegue mexer nisto por **override em runtime**
(`Presets.X.Y.CalcValue = ...`, `AppendClass`, redefinir função global) ou
`PlaceObj` novo. As funções C++ não dá para editar — só embrulhar.

### 13.1 Pipeline de CTH

- **`Unit:CalcChanceToHit(target, action, args, chance_only)`** — `Lua/Tactical/Unit.lua:6947`.
  - Args relevantes montados em `:6980-6992`: `aim`, `opportunity_attack`, `attacker_pos` (`step_pos`/`goto_pos`/pos), `target_pos`, `target_spot_group` (default `g_DefaultShotBodyPart`).
  - Base = `self[weapon.base_skill]` cru (`:6997-7001`) — é o "Marksmanship entra cru" do diagnóstico.
  - Loop `ForEachPreset("ChanceToHitModifier", ...)` `:7065`; **`base = base + value`** `:7103` — a soma a substituir.
  - `mod:CalcValue(self, target, target_spot_group, action, weapon, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)` `:7087` — assinatura que todo `CTH_*.lua` do mod implementa.
  - `GatherCTHModifications(mod.id, value, mod_data)` `:7097` — hook por-modifier.
  - Status effects rodam `GatherCTHModifications` `:7117-7136`; weapon component effects `:7142-7166`. **Um modelo de termo único tem que continuar deixando esses dois rodarem** (balde 3).
  - `NetUpdateHash` em `:7017`, `:7089`, `:7099`, `:7122`, `:7153`, `:7163`.
  - **Decisão de arquitetura:** no híbrido, *não* dar override nesta função — plugar um `ChanceToHitModifier` novo que retorna o CTH geométrico e desligar os de balde 1/2. Um NCTH puro exigiria reescrever daqui pra baixo.
  - `chance_only` (4º arg) — caminho da IA, sem montar tabela `modifiers`.

- **Data/ChanceToHitModifier.lua** — `Data/ChanceToHitModifier.lua`, **"GENERATED ... DO NOT EDIT MANUALLY"**. ~30 blocos `PlaceObj('ChanceToHitModifier', {...})`. O mod sobrescreve `.CalcValue` em runtime (é o que `aim_cth()`, `prone_cover()` etc fazem). Os que o mod **não** toca continuam somando:
  - `"Aim"` `:3-95` — params `MinBonus`/`MinDex`/`DexScale`; `min_bonus = weapon1.AimAccuracy` `:12`; `bonus = num*min_bonus + ...` `:25`. (O mod já substitui isto inteiro em `CTH_aim.lua`.)
  - `"RangeAttackTargetStanceCover"` `:561-634` — params `Cover`, `ExposedCover`, `PronePenalty`, `CrouchPenalty`. (Mod substitui em `CTH_cover_prone.lua`.)
  - Demais IDs (`RangeAttackTargetStanding`, `ObscuredTarget`, `Flanked`, `ProneShooter`, `Wounded`, ...) — verificar quais o mod deixa vivos e decidir balde.

### 13.2 Geometria de disparo (a que o modelo quer aproveitar / não quebrar)

- **`Firearm:GetMaxDispersion(dist, mod)`** — `Lua/Tactical/Weapon.lua:1296`. **Já é uma curva de cone que abre com a distância**: parábola inteira `(-9·d²/2 /Slab + 625·d + 5460·Slab)/10000`, teto `70*guic`, mexida por `InaccurateSpreadModifier`. Consumida em `SOURCE_FirearmGetAttackResults.lua:177`. **Candidata a hook**: o cone angular pode substituir/alimentar esta função em vez de criar paralelo.
- **`Firearm:CalcShotVectors(... num_hits, num_misses, num_grazing)`** — `Weapon.lua:1612`. `num_hits/misses` são **entrada**; fabrica trajetórias. Usa `attacker:RandRange` `:1654` e `attacker:Random(dispersion)` `:1679` (RNG sincronizado). `NetUpdateHash` `:1617`. `num_vectors = 50`. No híbrido **não muda** (encena resultado já decidido).
- **`Firearm:CalcMissVectors(... dispersion)`** — `Weapon.lua:1774`. `min_offset = 35*guic`. **Vaza cover para a geometria de erro**: `:1849-1856` chama `target:GetCoverPercentage` + `InterpolateCoverEffect` e guarda `misses.cover_penalty`. Se a silhueta ocluída mudar o modelo de cover, este trecho também precisa acompanhar.
- **`GetLoFData(attacker, targets, attack_args)`** — `Lua/UI/UnitCaching.lua:108`. Entrada central de raycast. `prediction` default `true` `:126-128`; `force_hit_seen_target` `:143`; aceita **lista** de targets num call (`CalcShotVectors`/`GetPelletScatterData` já usam assim). **É o que a sondagem de silhueta (cover nível 2) chamaria em lote.** Verificar se puxa `seed`/`Random` no caminho de pontos fixos — se não, é seguro na previsão.
- **`Firearm:GetPelletScatterData`** — já mapeado no mod (`Code/FUNCTION_GetPelletScatterData.lua`), mas o padrão (θ aleatório, `RotateAxis`, `SetLen`, `GetLoFData` em lote, zero rolagem de CTH) é o template para a sondagem de silhueta determinística.

### 13.3 Cones / OverwatchAngle (permanecem — não são abertura de CTH)

- **`Firearm:GetOverwatchConeParam(param)`** — `Weapon.lua:3205`. `"Angle"` → `self.OverwatchAngle`; `"MinRange"/"MaxRange"` derivados de `WeaponRange` (Shotgun/MG usam inteiro, resto 75%).
- **`Firearm:GetAreaAttackParams` / `FillConeAttackAoeParams`** — `Weapon.lua:3216-3259`. `params.cone_angle` de `OverwatchAngle` (ou `BuckshotConeAngle`). Alimenta `AIPrecalcConeTargetZones`, pellet scatter, MGSetup. O mod já dá override parcial em `SOURCE_R_GetAreaAttackParams.lua` e `SOURCE_ChangeMGSetupGetAreaParams.lua`.
- Consumidores de `GetOverwatchConeParam`: `Data/CombatAction.lua:2900,7673,8382`, `Lua/Tactical/Emplacement.lua:168-250`. **Intactos.**

### 13.4 Cover (vanilla)

- **`GetCoverPercentage(stand_pos, attack_pos, target_stance)`** — `Lua/Tactical/Cover.lua:281`. Chama C++ `PosGetCoverPercentageFrom(stand_pos, attack_pos)` → `(cover, any, coverage)`. **A esmagada #1**: `:283-285` `if cover == coverLow and target_stance == "Standing" then cover, coverage = false, 0` (low cover em pé = zero).
- **`PosGetCoverPercentageFrom`** — **C++, não existe em Lua.** Consulta direcional por voxel. Só dá para embrulhar `GetCoverPercentage` (global) por cima.
- **`Unit:GetCoverPercentage(attackerPos, target_pos, stance)`** — `Unit.lua:7815`. Wrapper fino; retorna `false,false,0` se a unidade está se movendo em combate (`self.combat_path`).
- **`InterpolateCoverEffect(coverage, full_value, exposed_value)`** — `Unit.lua:8701`. **A esmagada #2**: `threshold = 40`; `>= 80` → `full`; `< 40` → `exposed`; entre → interpola. Função **global** → override limpo. Chamada de `CTH_cover_prone.lua:90,124` **e** `Weapon.lua:1854` (miss vectors).
- **`GetCover` / `GetCoversAt` / `GetAngleCover` / `GetHighestCover`** — `Cover.lua:96-158`. Primitivas de voxel de cobertura (up/right/down/left, `coverLow`/`coverHigh`). Insumo para um modelo de cover direcional melhor sem raycast completo.
- **`Unit:GetHitStance()`** — `Unit.lua:6204`. `AnimationStance[GetStateText()] or self.stance`. Usado por `CTH_cover_prone.lua:42` para saber a postura real do alvo.
- Body parts: `self.parts` / `HeadshotHideParts` (`Unit.lua:7836`), `target_spot_group` propagado por todo o pipeline (`Weapon.lua:1613,1974,2007,2303`...). A silhueta por região (cabeça 9 cm vs torso 25 cm) se ancora em `target_spot_group`.

### 13.5 IA (vanilla, já com override no AI Overhaul)

- **`AIPrecalcConeTargetZones(context, action_id, additional_target_pt, stance)`** — `Lua/Tactical/CombatAI.lua:2040`.
  - `weapon:GetAreaAttackParams` `:2045`; `min/max_range`, `cone_angle` `:2047-2057`.
  - `CheckLOS(units, unit, dist, nil, cone_angle, angle)` `:2075`.
  - `GetLoFData(unit, targets, {prediction=true, target_spot_group="Torso", ...})` `:2113`.
  - **`chance_to_hit = unit:CalcChanceToHit(target, action, args, "chance_only")` `:2131`; se `== 0` remove o alvo do cone `:2138-2142`.** É *o* ponto onde uma curva de CTH mais íngreme perto de zero pode fazer a IA perder cones inteiros (o comentário em `CTH_hipfire_and_snapshot.lua:36-41` documenta um caso). **Revalidar após mudar a forma da curva.**
  - Chamado de `AIActions.lua:199,812`, `UnitAwareness.lua:1090`.
- Override do mod: `Rato's AI Overhaul/Code/SOURCE_AIPrecalcConeTargetZones.lua` (+ `SOURCE_AICalcAOETargetPoints.lua`, `SOURCE_AIGetAttackTargetingOptions.lua`, `FUNCTION_ScoreAttacksDetailed.lua`).
- Perf: raycast por posição avaliada × cache `(pos,target,stance)`. `AI Overhaul/PERF_PROFILING.md` e `POLICY_BUDGET.md` têm o orçamento.

### 13.6 WeaponPropertyDef (definição dos stats)

- `Data/WeaponPropertyDef.lua`:
  - `OverwatchAngle` `:184` — "Overwatch Width". **Fica.**
  - `AimAccuracy` `:231` — "Aiming Bonus", desc *"Accuracy gained from each Aim level"*, `max_progress = 10`. Vira `aim_decay` (fator de fechamento do cone por nível).
  - `WeaponRange` `:206` — desc *"distance at which the weapon can be aimed effectively"*, `max_progress = 50`. Vira o **piso mecânico** do cone.
  - `MaxAimActions` `:173` — teto de níveis; scopes somam via `IncreaseMaxAimActions`.
- **Propriedade de abertura nova**: se quiser aparecer na UI da arma, adicionar um `PlaceObj('WeaponPropertyDef', {...})` via mod (não editar o arquivo). `bind_to` = o campo criado no `AppendClass.Firearm`.

### 13.7 Helpers de aritmética (para manter determinismo / `NetUpdateHash`)

- `MulDivRound`, `Clamp`, `Min`, `Max`, `RotateAxis`, `SetLen`, `Dot` — inteiros, seguros.
- `sin(a)` / `cos(a)` — ponto-fixo, retorno escalado (÷4096); ângulo em minutos. O modelo prefere **LUT de Rayleigh** (`P = 1 − exp(−t²/2σ²)`, ~32 entradas) para evitar trig e float.
- `attacker:Random(n)` / `attacker:RandRange(a,b)` — **RNG sincronizado**. Proibido no caminho de previsão (crosshair, IA). Sondas de silhueta em pontos fixos não usam.
- `1 radiano ≈ 3438 minutos` — conversão silhueta→ângulo sem trig (`theta_target = MulDivRound(half_cm, 3438, dist)`).
- O engine já usa minutos: `max_angle_offset = 360*60` (`FUNCTION_GetPelletScatterData.lua:16`), `MGSetupConeFlat = 180` "minutes" (`__MainParams.lua:29`).

### 13.8 Acoplamentos a vigiar (não são CTH, mas dependem de "aim level")

- `Unit:CalcCritChance` (`Weapon.lua` ~`:1249`, `:3046` headshot) — vários bônus de crit do GBO3 são "por nível de mira". Aim continua sendo inteiro (0..N), então ok — só confirmar que nada lê o *valor em pontos* do modifier `Aim` (o `SOURCE_FirearmGetAttackResults.lua:245-249` lê `v.value` do modifier `"Aim"` para descontar da 2ª bala — **isso muda** no modelo angular).
- `GetRangeAccuracy` (`SOURCE_GetRangeAccuracy.lua`, override do mod) — usa `action:GetMaxAimRange`. Parábola de precisão por distância separada do CTH; decidir se sobrevive ou é absorvida.
- `CombatAction:GetMaxAimRange` / `GetMaxAimActions` (`Data/CombatAction.lua`) — scope `MaxAimActionsIncrease` flui aqui; `PinDown` multiplica range por `PindownRangeMul`.

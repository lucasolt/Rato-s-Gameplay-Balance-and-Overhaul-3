# TODO list of 2026-09-02 — findings, fixes and plans

One section per line of the `--TODO:` block at the top of `Code/__ApertureParams.lua`.
Status is one of **DONE**, **MEASURED** (cause established, tuning is yours), **PLAN** (approach
proposed, not built), **OPEN** (not investigated).

---

## 1. AI should orient before checking cover in LoF — **PLAN**

Partly addressed already, from the other end. `SOURCE_UnitSetTargetDummyFromPos.lua` +
`const.Combat.FreezeIdleFacing` stop enemies re-orienting outside their own turn, which is what
made the same situation measure differently twice.

This matters *more* now than when you wrote the TODO: since `Rat_TargetExtents` projects the
target's animation box, the exposed silhouette is a real function of the target's facing. A
standing man is 68 cm across the chest and 93 cm across the shoulders — a ~35% swing in one axis
purely from which way he is turned.

What is left is the shooter side: the AI evaluates a firing position *before* the unit turns to
shoot, so LoF and cover are sampled at the wrong facing. Two options:

- resolve the intended facing inside the position evaluation (correct, invasive — it is in
  `AIPrecalcConeTargetZones`);
- or accept it, since the AI already uses `A.CoverAIFallback` (`GetCoverPercentage`) rather than
  raycasts, and that path is facing-independent anyway.

I would take the second unless you see the AI actually refusing good shots.

---

## 2. Target angle gets smaller when you aim — **DONE**

My bug, introduced with the separable model. `theta` became the *probability-equivalent* radius —
the circle that would give this CTH at this sigma — which is right as an internal currency and
absurd as a displayed target size: aiming shrinks sigma, so the target appeared to shrink.

Fixed by splitting the two. `data.rat_theta` stays the currency; `data.rat_theta_geo` is pure
geometry (area-equivalent radius of the projected box) and is what the `Aperture <cone> vs <tgt>`
line now shows. It does not move when you aim.

---

## 3. Aim is too strong / shots too accurate — **MEASURED**

Not a bug — it is `A.AimStep`, and the ladder shape is the problem. Measured, MD → Barry, 11
tiles, sigma by aim level:

| aim | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|-----|---|---|---|---|---|---|---|
| sigma | 412 | 137 | 114 | 100 | 99 | 98 | 97 |
| step | — | **−67%** | −17% | −12% | −1% | −1% | −1% |

Two separate faults:

- **`A.AimStep[0] = 280`** makes level 0 a cliff, not a rung. Almost the entire value of aiming
  is bought by the first level, which is why aiming "feels" mandatory and overpowered.
- **Levels 4–6 are inert.** `A.FloorPct = 55` is already reached by level 3, so the last three
  rungs buy 3% of cone between them. Seven aim levels, three of which do anything.

Levers, in order of effect: lower `A.AimStep[0]` (280 → ~180 makes hipfire bad without making it
a different game), then lower `A.FloorPct` so the top levels have somewhere to go.

Note these numbers were measured **before** the box-silhouette change and the sigma side did not
move, so the ladder shape holds; only the CTH it maps to changed.

---

## 4. Opportunity attacks never hit — **MEASURED, and milder than it looks**

`Rat_EffectiveAim` (`FUNCTIONS_aperture.lua:1148`) already promotes opportunity attacks,
overwatch, `shooting_stance`, emplacements and MG setup to `aim = max(1, aim)`. So they fire at
snapshot (`A.AimStep[1] = 155`, sigma 137), not hipfire (sigma 412).

That is ~21–23% at 11 tiles, not the ~3% that hipfire would give. Low, but not "never". If it
still feels dead in play the lever is `A.AimStep[1]`, not the opportunity path — that path is
already doing its job.

Same root cause as #3: the ladder is too steep at the bottom.

---

## 5. Tune recoil — **MEASURED, recalibration needed**

`A.RecoilClimbBase = 80` is a **stale calibration and it is mine.** I set it to reproduce the old
burst average at sigma 143 — a reference that no longer exists after the CTH change.

Measured after the change (FNFAL, aim 2, 11 tiles, 150 bursts of 3):

| shot | 1 | 2 | 3 |
|------|---|---|---|
| predicted | 28% | 10% | 0% |
| measured | 23% | 9% | 1% |

The model is accurate; the *balance* is harsh — 69% of bursts land nothing at all. Recalibrate
`RecoilClimbBase` against `Rat_DbgBurst`, never against the old model.

"Should generate compensated positions lower too": currently `Rat_RecoilWalkAxis` picks one axis
per burst and the walk is monotonic along it. A shooter who over-corrects should sometimes land
*below* the aim point. That is a small change — let the held/controlled step take a negative
sign — but it needs `A.RecoilControlResidual` re-tuned with it (you already moved it 15 → 5).

---

## 6. Strays, suppression, crit chance — **OPEN**

Not investigated. What I can see: `SOURCE_FirearmGetAttackResults.lua:673` already works around a
vanilla bug where `BulletCalcDamage` marks hits 2..N of a burst as strays (−50% damage) because
vanilla only marks the first shot as `leading_shot`. Whether the suppression mod re-triggers that
path is exactly the thing to check first.

Worth doing as its own session with a burst fired into a suppression scenario and
`Rat_DbgLastShots` read afterwards.

---

## 7. aCTH with out-of-sight targets (wallbang) — **PLAN, one risk identified**

The exposure gate is still wired: `Rat_AngularCTH` calls `Rat_MeasureExposure` and returns CTH 0
when `exposed_pct == 0`.

The risk introduced by the box model: `Rat_TargetExtents` projects the animation box **with no
visibility check of its own**. It will happily return the full silhouette of a man behind a wall.
Everything depends on the exposure gate upstream staying correct — the geometry layer no longer
provides a second opinion the way raycast-measured extents implicitly did.

Concretely: if `A.CoverRaycast` is off, or the AI's `GetCoverPercentage` fallback disagrees with
the real LoF, a wallbang target can come back with a healthy CTH. Test by putting a unit fully
behind a wall and reading `Rat_DbgShots`.

---

## 8. AI OVERHAUL — do not shoot through walls — **OPEN, other mod**

Belongs in `Rato's AI Overhaul`. Related to #7: the AI uses the cheap cover path
(`A.CoverAIFallback`), so its idea of "can I hit this" is coarser than the player's. If the AI is
taking wall shots, suspect that path first.

## 9. AI OVERHAUL — LastPos should generate threat and be chased — **OPEN, other mod**

Design work, no overlap with the aperture model.

## 10. Overwatch tuning — snapshot should not scale with distance — **PLAN**

Your proposal (flat % CTH reduction instead of distance scaling) does not fit the current model
cleanly: everything is a *cone* multiplier, and a flat CTH cut has no fixed cone equivalent —
that is exactly the trap `A.ConeRefCTH` exists to work around.

The version that fits: overwatch keeps its aim promotion but takes a **fixed cone multiplier**
instead of the snapshot step. That is distance-independent by construction, because a cone
multiplier is an angle and angles do not care about range. It is one new number.

---

## 11. Ponto de mira e silhueta — **DONE, 2026-09-02**

Descoberto ao validar contra tiro simulado: o modelo mirava num ponto que a bala nao usava.
`A.SpotAnchor` (tabela de ancora por postura, chutada) foi substituida por
`Unit:GetStaticSpotPos(spot)` — o spot da animacao, que bate **exato** com o `target_pos` do
`GetLoFData`. Custo 35 us (~3% do orcamento de `CalcChanceToHit`).

Um exemplo de por que a tabela nao tinha conserto: num alvo agachado o spot `Torso` do motor
fica **acima** do spot `Head` (635 mm vs 594 mm).

`A.BodyFill` recalibrada contra tiro simulado: **Standing 77, Crouch 75, Prone 56** (era
75/84/80). Resultado final, 250 tiros por ponto, previsto/medido no Torso:

| postura  | aim 2 | aim 4 | aim 6 |
|----------|-------|-------|-------|
| Standing | 9/12  | 32/34 | 49/46 |
| Crouch   | 14/17 | 44/45 | 63/60 |
| Prone    | 9/11  | 34/34 | 54/60 |

Erro maximo 6 pontos contra ~3 pontos de ruido amostral, sem sinal sistematico.

### Dois retangulos (2026-09-02, segunda passada)

A limitacao do retangulo unico foi corrigida: a cabeca virou um segundo retangulo. A uniao
continua fechada porque as duas faixas em Y sao disjuntas e a largura e constante dentro de cada
faixa, entao `P = Px_tronco * Py_tronco + Px_cabeca * Py_cabeca`. Nenhuma aproximacao nova.

A separacao so vale quando **se mira a cabeca E ela sai da silhueta** (`hu + hh >= up`). Medido,
tiro na cabeca, aim 6, dois retangulos / um retangulo / observado:

| pose                | 2 ret | 1 ret | medido |
|---------------------|-------|-------|--------|
| `hg_Standing_Idle`  |    26 |    35 |     22 |
| `ar_TakeCover_Idle` |    40 |    76 |     69 |
| `ar_Prone_Idle`     |    29 |    55 |     41 |

**A unidade "agachada" que eu media era `ar_TakeCover_Idle`, nao `ar_Crouch_Idle`** — achado do
Rato. Sao poses bem diferentes: caixa de 795 mm contra 1201 mm, e so na de cobertura o spot
`Torso` do motor fica ACIMA do da cabeca.

A condicao de separar tem duas partes, e o discriminador certo nao e o vao acima da cabeca (que
nao separa agachado de deitado) e sim **onde o corpo fica**. Mirando a cabeca:

| pose                | down | right+left | corpo pendura embaixo? |
|---------------------|------|------------|------------------------|
| `hg_Standing_Idle`  |  112 |         48 | sim -> separa          |
| `ar_Crouch_Idle`    |  122 |        117 | sim -> separa          |
| `ar_TakeCover_Idle` |   69 |         96 | nao -> um retangulo    |
| `ar_Prone_Idle`     |   35 |        107 | nao -> um retangulo    |

Dai `hu + hh >= up - hh and down > right + left`: a cabeca tem de chegar ao topo E o corpo tem de
pendurar abaixo dela, em vez de se espalhar ao lado. Reproduz os tres casos validados por tiro e
acerta o agachado de verdade, que o criterio antigo errava por UM minuto de arco (17 contra 18).

Resultado final, 250 tiros por celula, previsto/medido:

| postura  | Torso a4 | Torso a6 | Head a4 | Head a6 | Legs a4 | Legs a6 |
|----------|----------|----------|---------|---------|---------|---------|
| Standing |    32/30 |    49/46 |   19/17 |   26/23 |   29/30 |   43/37 |
| Crouch   |    49/51 |    68/67 |   55/53 |   76/74 |   44/49 |   57/72 |
| Prone    |    34/39 |    54/48 |   35/30 |   55/48 |   29/33 |   44/42 |

**Pendente: `A.BodyFill.Crouch = 75` foi calibrada contra `ar_TakeCover_Idle`.** `GetHitStance`
devolve `Crouch` para as duas poses, entao a mesma constante serve caixas de 795 mm e 1201 mm.
Nao da para re-calibrar contra agachado de verdade nesta cena: as unidades em `ar_Crouch_Idle`
estao todas atras de cobertura (exposicao 0-10%), e atacante INIMIGO nao simula direito
(771 -> Barry deu 0 acertos em 200 tiros com 42% previsto; 778 -> Barry cai de 19% para 15%
quando a mira sobe). Precisa de um merc agachado com linha de tiro limpa para um inimigo.

**Sobra tambem `Legs`**, e a causa e conhecida: `Legs` e o unico spot em que
`GetStaticSpotPos` NAO bate com o `target_pos` do `GetLoFData` (~55 cm de diferenca, porque tem
varios spots de perna e o motor escolhe outro). O modelo mira num ponto e a bala em outro.

---

## Also outstanding, not on your list

- `A.TargetedResidualPct = 0` means calling a head shot now costs nothing at all: same CTH as the
  torso, better hit location. That follows from the "CTH = P(hit target)" decision, but it wants
  a nonzero value or aimed head shots are strictly free.
- `APERTURE BALANCE.md` sections 1–2 are stale; see the note in that file.

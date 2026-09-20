# Which one do I use?

One question decides it: **how many components share this?**

| Many share it | It *is* this component | Same but off by a bit | Only in one CTH mode |
| --- | --- | --- | --- |
| **trait** | **base recipe** | **override** | **override block / trait `modes`** |
| `Stock.Light` in Traits | `GBO_BASE_RECIPES.WideScope` | Override Effects / Params | Override per CTH Mode |

Worked examples:

- *"This stock should act like a light stock."* → put `Stock.Light` in **Traits**. Nothing else.
- *"Like a light stock, but it also blocks full auto."* → Traits `Stock.Light`, **Override Effects (add)** `NoFullAuto`.
- *"Like a light stock, but only penalised under aCTH."* → Traits `Stock.Light`, one **Override per CTH Mode** block with Mode `aCTH`.
- *"This scope is its own thing, nothing shares it."* → a **base recipe** named after the component.
- *"This optic should behave as a 4x under aCTH."* → put `Scope._4x` in **Traits**, alone. It replaces
  any magnification `A.ScopeTraitOf` binds to that id, and the base recipe is kept.
- *"A 4x, but one less aim level."* → Traits `Scope._4x`, one **Override per CTH Mode** block with
  Mode `aCTH`, Params `MaxAimActionsIncrease = 1`. Scope rules exist only in aCTH, so tweak them there.

## Order of application

```
traits (merged) → their own modes → flat override → overwrite traits (Scope.*) → mode blocks → emit
    ^ combine          ^ replace         ^ identity       ^ the tier's rules            ^ the deviation
```

Later beats earlier. Within the mode layers the order is `GBO_ComposeModeLayers()`:
`oldCTH`, or `aCTH` then `aCTHSim` — general to specific.

## The five places, and what each is for

| Where | Kind | Holds |
| --- | --- | --- |
| `GBO_COMP_TRAITS` | code table | qualities several components share (`Barrel.Long`) |
| `GBO_BASE_RECIPES` | code table | one component's whole identity; auto-registers as the trait `Base.<id>` and auto-binds its namesake |
| `A.ScopeTraits` + `A.ScopeTraitOf` | code table | what each *magnification* does, as `overwrite` traits `Scope.<tier>` (aCTH-only, plus `floor_mul`), and the code-side id → tier binding |
| `GBO_ComponentTraits` etc. | editor property | which traits this component has, and how it deviates |
| `GBO_Override*` (flat) | editor property | **what this component is**: the identity that used to be a base recipe. Applied before the tier, so a magnification can drop from it what does not fit the mode |
| `GBO_OverrideModes` | editor property | **how it deviates** in one CTH mode. Applied last, beats everything |
| `ModificationEffects` / `Parameters` | editor property | **output**. The compositor overwrites these. Do not author them on a component that has traits |

That last row is the reason the code tables exist at all: `GBO_WriteComponent` writes those two
fields, and the editor saves them. If the truth lived in the preset, one save would bake the
composed result over its own source and the next load would compose it again.

## Precedence rules, in one place

1. **Editor property beats code map.** `GBO_ComponentTraits` on the preset wins over
   `GBO_COMPONENT_TRAITS[id]`, which wins over a base recipe's auto-bind.
2. **Trait beats ancestor.** `GBO_ComponentAncestor` copies a whole preset and runs *after* the
   compositor, so it used to overwrite compositions silently. It now skips any component the
   compositor handled.
3. **A mode block beats everything.** The flat override is only the identity, so a Scope trait
   overrides it on purpose — that is how `Scope._6x` strips `IncreaseAimAccuracy` from a scope that
   authors it. Anything meant to beat the tier goes in a mode block.

## Traps

- **Scope traits overwrite, they don't combine.** A trait with `overwrite = true` is applied after the
  merge, like the old overlay: its params replace, and `effects = {id = false}` removes an effect
  another trait added. Everything sits under `modes.aCTH`, so under oldCTH it composes to nothing.
  A Traits field holding only Scope traits keeps the code-side list (the base recipe) in front of
  them; with no code-side list the component is left alone. A dangling trait id only prints
  `GBO compose: traco inexistente` and composes without it.
- **A param is only read by the effect that declares it.** Remove the effect and the param becomes
  dead weight; add a param whose effect is missing and nothing happens. 41 of the 114 composed
  components carry at least one such param today.
- **The override needs a trait.** The compositor never touches a component without traits, so an
  override there does nothing. It prints a warning.
- **Prefer the canonical param name** (`OverwatchAngle`, not `OverwatchAngleIncrease`). The
  compositor picks the Increase/Decrease effect from which side of 100 the product lands on;
  mixing both forms on one component can emit both effects, and the engine then keeps only one.

## Migrating a hardcoded recipe to the editor

`GBO_BASE_RECIPES` is the old home of a component's identity. The identity moves into the preset's
own properties, where you can see and edit it. It does not dump the whole recipe there: it picks the
traits the component already **is** — its magnification, plus any shared trait whose effects are a
subset of the recipe — and authors only the **residual**, the part the traits do not already
produce. A scope ends up as `Scope._6x` plus the two or three things that are its own:

```
Component Traits:  Scope._6x
Override add:      CritBonusWhenFullyAimed
Override params:   crit 20, OverwatchAngle 60, MaxAimActionsIncrease 1
Override per mode: [aCTH] threshold_bonus_aim_acc = 15
```

```lua
GBO_MigrateRecipesToProperties(false)  -- dry run: prints what it would write
GBO_MigrateRecipesToProperties(true)   -- stamps Traits + the three Override fields
GBO_MigrateClearProperties()           -- undo, while nothing has been saved yet
```

Run it by hand through `dap_eval`, never from a load handler. It writes only the **input**
properties, which the compositor never overwrites; then the editor saves items.lua, and only then
may the recipe leave the code. Left out on purpose: presets of another mod (the editor would write
into their folder), vanilla presets with no ModItem to save into, and a recipe shared by more than
one component, which is a real shared trait.

A component with no trait is never touched by the compositor, so one whose identity is entirely in
its properties carries the empty trait **`Self`**.

A ToG `<weapon>_Scope_1` variant cannot hold our properties. With neither a recipe nor a tier it
falls through to the ancestor copy and inherits its master's composed result — so the master, which
we own, is the only place to edit. Verified value by value on all six pairs.

The tier trait carries what **every** scope of that magnification has — measured as the common part
of its members — so a component never repeats it. A trait is only taken automatically when its
effects are a subset of the recipe; anything looser would drag in an effect the component does not
have, and the residual cannot remove a param. To take a trait anyway, name it in
`GBO_MIGRATE_ADOPT`. Without `pure` the residual keeps behaviour identical and shows the deviation;
with `pure` the component takes the **trait's numbers**, which is a balance decision made by hand:

```lua
BarrelShort = {"Barrel.Short", pure = true},
_Master_StockLightUnfolded_TOG = {"Stock.Light", pure = true, add = {"zzStockEquipped"}},
```

Mind the reach: a `pure` adoption propagates to every descendant through `GBO_ComponentAncestor`.
The four short barrels and the ToG light stock moved 34 components, not 5.

A param with no effect that reads it stays orphaned. Canonicalising it would switch on an effect the
component never had, and an effect's absence does not prove the param is dead: the aperture reads
several by name (`bonus_cth`, `snap_reduc`, `Close_bonus`).

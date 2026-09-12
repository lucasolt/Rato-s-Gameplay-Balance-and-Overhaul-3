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

## Order of application

```
traits (merged)  →  their own modes  →  aperture overlay  →  flat override  →  mode blocks  →  emit
     ^ combine           ^ replace          ^ overwrite        ^ overwrite      ^ overwrite
```

Later beats earlier. Within the mode layers the order is `GBO_ComposeModeLayers()`:
`oldCTH`, or `aCTH` then `aCTHSim` — general to specific.

## The five places, and what each is for

| Where | Kind | Holds |
| --- | --- | --- |
| `GBO_COMP_TRAITS` | code table | qualities several components share (`Barrel.Long`) |
| `GBO_BASE_RECIPES` | code table | one component's whole identity; auto-registers as the trait `Base.<id>` and auto-binds its namesake |
| `A.ApertureMagnifications` + `ApertureComponentTier` | code table | what each *magnification* does. Keyed by tier, not by component. **Not traits** |
| `GBO_ComponentTraits` etc. | editor property | which traits this component has, and how it deviates |
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
3. **Override beats everything**, and a mode block beats the flat override.

## Traps

- **Tiers are not traits.** `Base._6x` is not a thing — magnifications are an overlay keyed by
  `ApertureComponentTier`, applied to whatever component the tier names. A dangling trait id only
  prints `GBO compose: traco inexistente` and composes without it.
- **A param is only read by the effect that declares it.** Remove the effect and the param becomes
  dead weight; add a param whose effect is missing and nothing happens. 41 of the 114 composed
  components carry at least one such param today.
- **The override needs a trait.** The compositor never touches a component without traits, so an
  override there does nothing. It prints a warning.
- **Prefer the canonical param name** (`OverwatchAngle`, not `OverwatchAngleIncrease`). The
  compositor picks the Increase/Decrease effect from which side of 100 the product lands on;
  mixing both forms on one component can emit both effects, and the engine then keeps only one.

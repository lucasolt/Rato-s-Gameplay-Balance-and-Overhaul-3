# TODO

## Reimplementation necessary
- [ ] Camouflage.
- [ ] How to deal with scopes that give bonuses to hit body parts or bypass cover?
  - Handzolt.
  - Scout Scope.
- [ ] What about grazing? Is it possible to keep it in the game?
- [ ] Grizzly Perk

## aCTH Balancing

- [ ] Stray shots should have a lower chance to inflict status effects. General inquiring about how strays are working now. Maybe be stray when hit other bodyparts of the same target? I am not even sure how the damage is being calculated right now.
- [ ] Calibrar o recuo de segunda ordem.
  - Ancorar `KickBase` e o mapa `control -> CFMax` nas duas.
  - Ver linhas extremas do ladder do `1cc229c`.
  - Depois conferir um calibre pesado.
  - Ver `RECOIL MODEL.md`.

## aCTH Possible fragilities
- [ ] Make sure AI will orient before checking for cover in LOF.
- [ ] Check how the `aCTH` deals with out-of-sight targets (wallbang).

## New mechanics intended
- [ ] Autofire shot count.
- [ ] MG Recoil/setup rework

## New mechanics (luxury)
- [ ] MG and bipods setting up on cover/crouch
- [ ] Change AP scale for more gradient AP costs, specially for stance, rotation etc
- [ ] **MEGA LUXURY** Vision cones/directional vision. Would need to make AI take this into account.
 
## Later Balancing
- [ ] Shotgun pellet balancing.
- [ ] **General balancing:** OW tuning — minor.

## AI OVERHAUL - other mod 
- [ ] **AI OVERHAUL:** Implement smoke usage.
- [ ] **AI OVERHAUL:** Make sure AI will not try to shoot through walls. (especially with aCTH)
- [ ] **AI OVERHAUL:** Enemy `LastPos` should generate threat. They should also try to "chase" the last position.
- [ ] **AI OVERHAUL:** Investigate the shot-selection threshold.
  - Currently at `1`.
  - Consider increasing it to `2`.
- [x] **AI OVERHAUL:** Check grenade distribution.
  - Give more timed grenades to enemies.
  - Less frustrating, but still a challenge to the player.
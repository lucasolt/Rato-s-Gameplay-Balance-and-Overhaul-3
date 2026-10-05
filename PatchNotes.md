# TODO

```lua
CheatAddItem("itemid")
```
## Patch Notes
```
4.00
- When set up, MGs will have lower snapshot penalty for interrupt attacks at long distances
- Setting up MG now costs more if you are not prone. This extra cost can be paid with free move ap. Base cost reduced by 1
- Components and perks effect on recoil/snapshot/hipfire and aim tweaked
- Snipe action bonus crit per aim from 5 to 4.
- Heavy rain no longer increases aim AP. Instead, it makes aiming less effective 
- Reflex sights no longer increase range
- Snapshot penalty for opportunity attacks was decreased (from extra +20% to +10%). Reflex stat scaling will grant bigger accuracy boost

- Light Stock no longer reduces aim accuracy. Increased recoil.

- Changed fog vision radius reduction. Fog no longer causes grazing hits
- Shotgun AP costs tweaked
- Other balance tweaks that I forgot


- Heavy Weapons perk now reduces Shooting Stance AP instead of Setup AP (indirectly still reduces Setup AP). 

- Grizzly new starting perk is Recoil control instead of Killing Spree
- Fixed and improved Shooting Stance animations (shoutout to @dabhand)
- Fixed bugs related to shotgun

- Gas mask reduce accuracy instead of AP
- Fixed missing property burst_recoil_delta

- Option for rebalanced weapon shipment loot AI MOD
- Fixed some bugs in weapon shipment conditions and cooldown AI MOD

- Bobby's Ray ammo distribution was improved

-- Caliber damage re-escaled --
Big calibers (7.62 and the like) have had increased damage (and recoil)
Barrel length and caliber now determines the damage of the weapon. Some calibers have length cap at which they do not increase damage anymore. Extended and short barrels dynamically change the damage now (tho mostly little changed)


-- New AP Scale -- 
- AP Scale changed. What before was 1 AP, now is 10 AP. This opens avenues to tweak ap costs in a more granular way.
- Manually cycling AP has been tweaked (it cost less). The effects from dexterity are now not in threshold steps, but instead are a smooth progression. Every point of dexterity helps (mostly)
- Components impact on shooting stance cost was changed (barrels and stock have less increase, handgun barrels have a very small change now)


- Visibility changes: 
you no longer see the enemy in your screen if no merc has vision of it (no visibility memory). Can be disabled on mod options.
Changed mobile attacks targeting aquisition, so now you can try to use it even if no target is in view but you presume there is a target. The merc will shoot if an enemy is revealed

- NEW MECHANIC: Redesigned reliability mechanics. The value will now govern the chance of jamming instead of condition degradation by shot. The formula was changed, high reliability weapons will be able to perform even when in lower condition. Suppressors now increase condition degradation rate.


-- New Mechanic: Autofire with variable bullet count --

When you use autofire, you will be able to choose the ammount of bullets you want to fire. Burst Fire action has been removed and kept only on weapons with selective fire. 
Weapons now have RPM stat, that influences how much AP each additional shot cost.

There is a chance, based on Composure (marks + wisdom) and RPM of the weapon, of shooting more bullets than intended when using autofire. You will pay the AP cost if this happens. Psycho increases the chance, Automatic Weapons perk decreases it. Tring to one tap increases the chance.

Some weapons are only capable of automatic fire. (no single shot, but you can try to onetap)

Psycho has been reworked, the chance of triggering the upgrade is now 6% instead of 3%. In case of this triggering, no extra AP is deducted. single shot becomes automatic fire with 3 shots. Selective burst becomse 2 bursts. automatic fire double bullet count, capped on 10

Muzzle booster now increases RPM slightly. Suppressors also increase RPM and no longer have the bonus dmg against flanked units. AKSU will have a reliability decrease if using a compensator (because it has no backpressure of the booster or suppressor)
Selective Burst now has better critical scaling than autofire, but less than single shot.



-- new CTH mode: aCTH --

This was created because I felt that accuracy was too high on long ranges, and just shooting first was what determined a fight result. I want it to feel more like a firefight, prolonged, suppression based (please use the Pinned Down mod).
Heavily inspired by 1.13 NuCTH. In this mode, every shot is simulated. Your accuracy will generate an aperture that denotes the possible dispersion. A shot will be randomly fired in this area. Aiming turns the dispersion tighter.
Shots can hit other body parts than what you intended. In these cases, inflicting status effect and crit have their chance lowered by 33%, and the base damage suffers 10% reduction.
Shots can hit cover. There is no more hardscripted cover. A small, thin lightpost can save you from a bullet (or your enemy). 
Expect dynamic (chaotic) results (that is the fun part!). You need to have stomach for bouts of randomness to use this mode.

(aCTH) Handling:
- new weapon stat: Handling -> is the base precision factor for every attack. Small weapons will have less penalty, but in turn have less aiming bonus. Replaces Point Blank/Close Range bonus.
- Heavy/big weapons (MGs, Barret, PSG) have worse handling if you are not prone. Some of this can be negated with high str. 

(aCTH) Recoil:
- Recoil deviation is simulated. Str controls how much you control, dexterity/marksmanship will help you get back on target.
- MGs have recoil penalty (and the aforementioned handling penalty) when firing not prone. There are no penalties to fire without setup, that is, the benefits have been all transfered to being prone or having a bipod. MG Setup is now a way to OW (with one bonus attack per turn)
- Being prone with a bipod will reduce the vertical component of recoil.


(aCTH) Aim and Sights:
- Aim accuracy scale has been changed (values will range from ~~5 to 70)
- Aim accuracy is very important to determine how well can you hit at range
- Scopes work differently, mostly increasing max aim levels. High mag scopes have more snapshot penalty, and work better with high aim accuracy weapons.
- Reflex sights have flat accuracy bonus (equally good for weapons with high or low aim accuracy)
- Weapon range now is mostly relevant to how tight you can make the dispersion. In some ways, they are a floor to dispersion and a ceiling to aim accuracy. So high range weapons will benefit more from scopes, low range will have little benefit, as you approach the floor earlier.
- Other components have been changed

(aCTH) Other stuff:
- Autofire has no cap on max aim levels
- Dual shot has max 3 aim levels, you will get no benefit from scopes or sights.
- CQC perk will reduce snapshot and hipfire penalty for firearms, instead of bonus acc at close range. Melee and thrown weapons remains the same as the original.
- when using simulated aCTH, firing through smoke no longer cause grazing, instead reducing accuracy
- when using simulated aCTH, take cover action no longer causes grazing. Can be reverted using a mod option

(aCTH) Bullet Hell action will now have simulated shots with recoil calculation
 

-- Attachments --

Scopes, sights, side attachments, muzzle attachments, bipods, GL now are inventory items that will be sold by Bobby's Ray. You can attach and dettach them from weapons. Compatibility is variable.

-- New weapon stat: Critical chance per aim
Weapons now have a state called critical chance per aim, which scales per merc hand-eye coordination (marks+dex) and is applied to each aim level (thanks captain obvious). The mechanic already existed, but now it has completely overriden the old crit scaling based on merc level. Weapons will have different values, Snipers have the most.

-- UI Improvements -- 
The UI section that displays Recoil, Snapshot etc was reworked. The displayed number is the effective value for the merc, while the grey number afterwards displays the weapon base value. Additionally, now there is a visual display in form of a bar. Green and red show the merc stats impact on the value.
-- -- -- -- -- -- -- -- -- 
```

Technical details:
changed logic that made mercs step out of cover to shoot

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
- Critical chance based on aim levels was tuned down
- Shotgun AP costs tweaked
- Other balance tweaks that I forgot

- AP Scale changed. What before was 1 AP, now is 10 AP. This opens avenues to tweak ap costs in a more granular way.
- Manually cycling AP has been tweaked (it cost less). The effects from dexterity are now not in threshold steps, but instead are a smooth progression. Every point of dexterity helps (mostly)
- Components impact on shooting stance cost was changed (barrels and stock have less increase, handgun barrels have a very small change now)

- Heavy Weapons perk now reduces Shooting Stance AP instead of Setup AP (indirectly still reduces Setup AP). 

- Grizzly new starting perk is Recoil control instead of Killing Spree
- Fixed and improved Shooting Stance animations (shoutout to @dabhand)
- Fixed bugs related to shotgun

- Fixed missing property burst_recoil_delta

- Option for rebalanced weapon shipment loot
- Fixed some bugs in weapon shipment conditions and cooldown

- Bobby's Ray ammo distribution was improved

- NEW MECHANIC: Redesigned reliability mechanics. The value will now govern the chance of jamming instead of condition degradation by shot. The formula was changed, high reliability weapons will be able to perform even when in lower condition. Suppressors now increase condition degradation rate.


-- New Mechanic: Autofire with variable bullet count --

When you use autofire, you will be able to choose the ammount of bullets you want to fire. Burst Fire action has been removed and kept only on weapons with selective fire. 
Weapons now have RPM stat, that influences how much AP each additional shot cost.
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
- Being prone with a bipod will have reduce the vertical component of recoil.


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
 

-- Attachments --

Scopes, sights, side attachments, muzzle attachments, bipods, GL now are inventory items that will be sold by Bobby's Ray. You can attach and dettach them from weapons. Compatibility is variable.

-- New weapon stat: Critical chance per aim
Weapons now have a state called critical chance per aim, which scales per merc hand-eye coordination (marks+dex) and is applied to each aim level (thanks captain obvious). The mechanic already existed, but now it has completely overriden the old crit scaling based on merc level. Weapons will have different values, Snipers have the most.

-- UI Improvements -- 
The UI section that displays Recoil, Snapshot etc was reworked. The displayed number is the effective value for the merc, while the grey number afterwards displays the weapon base value. Additionally, now there is a visual display in form of a bar. Green and red show the merc stats impact on the value.
-- -- -- -- -- -- -- -- -- 
```


GO BACK TO MG SETUP....
HWT should not decrease MG burst attack, i think



- [ ] Operation to gather herbs automatically
- [ ] Review nostock effect on aim, Its becoming hard to make nostock SMGs to have more aim than pistols...

## AI new stuff
- [ ] OW against doors
- [ ] When enemy goes out of view, he should not leave behind his position to the player


## Fire modes
- [X] Need some AP checks, so that merc can select the autofire if he can fire 2 bullets
- [ ] maybe change the effect on HK receivers for better clarity
- [ ] Implement selective burst on HK21 and other MGs that have them
- [X] Fix MG description hints not showing ROF
- [X] Recoil booster
- [X] MG 58 RPM should be adjusted
- [X] Investigate Burst fire AP or RPM
- [ ] Solve the AKSU reliability dilemma
- [X] Selective burst should have better crit scaling in general?
- [ ] psycho trait
- [ ] Mg should have a higher base cost?
## UI
- [ ] As I am introducing a lot of fractioned AP, maybe a mouseover shows how many attacks (in stance or not, aim? at a position. something to help the player process easily instead of having to mentally calculate)
- [ ] Burst weapon AP is stale number right now.
- [ ] recoil delta on actions
- [X] Caliber/ammo params should have their own section (remove critical damage and base chance from d.hints)
- [X] Aim could be scaled by merc and handgun status? in d.hints
- [X] Number of pellets to caliber section
- [X] Further details should include Ap to swap and AP to reload
- [X] Noise even when no ammo loaded
- [X] BobbyRay is showing the old crit scaling

## Housekeeping
- [X] Implement unified Component handling, with ancestor/CTH mode
	- [X] fix/unify with aCTH logic!!!
	- [X] Verify if patch called from TOG is redundant. - Its not, visual changes and foldable stock foldability
- [X] Remove unused calibers from bobbyrays list

## General
- [ ] Check unjam mechanic skill. If flat, turn into a skill check.
- [ ] Heavy rain aim acctriggering inside?

## new AP scale
- [X] Cumbersome stance ap not in scale (description hints, display only)
- [ ] Gasmask AP reduction not in scale
- [X] minor - review AP calc so it can yield less than 10 step
- [X] Morale effects using old AP scale

## Components

- [X] Take a look at the shipments. I got a tier 3 MG after 2 fights
# As inventory items

## Attachments
- [ ] Investigate Tier unlocking. Balance it
- [ ] Possibly rescale parts gained
- [ ] CUAE handling of attachments
- [ ] Spreadsheet for attachment costs
- [ ] *Find a use for Lens and Chips*  !!!
- [ ] Component icon and models from ToC for 5.45 Suppressor and 7.62x54R Suppressor, 45 acp Suppressor, 44 suppressor rifle, Mauser? What about guns that change calibers?
- [X] Barrels that change caliber now block muzzle so no incompatibility.
	- [ ] Could create custom logic for it tho.
- [X] Currently, P90 is using 5.56 suppressor and compensator - Removed from it


## Design

- [X] Change RS grading. compact -> assault compact -> assault/vulto
- [ ] Change advanced RS for pistol name
- [ ] ? Add compact Advanced (Glock RS) to rifles?
- [ ] ? Remove Vulto RS from pistols?
- [X] Remove TOG handguards (RKs done)
- [X] no interchangeable stock between RKs
- [ ] check components that make sense and remove the ones that dont. elegance first.
- [ ] ? ACOG could increase min aim level by 1 for aimed attacks.
- [X] Re-tune component AP cost now that the scale has changed
	- [X] Handgun barrels -> 3
	- [X] Light stock -> 5
	- [X] Heavy stock - unchanged
	- [X] Barrels - reduced

## Code/implementation

- [X] make components/att have rarity weight on BobbyRays
- [X] Make components scrappable
- [X] Compensator per caliber
- [X] Ak 74 bipod is not using item
- [ ] Scout suppressor should created, or use the 556 one.

## Other

- [X] See why the mag modification is available even when RevMags is loaded
- [X] Mags are bugged visually with RevMags. 
- [X] fix folded stock AP reduction (M11 was bugged)
- [X] SKS extended barrel has wrong accuracy param -- Fixed???
- [X] consider small threshold bonus for the 1.5x scopes as well


## New mechanics intended
- [X] change AP scale
	- [X] Rotation cost smooth
	- [X] Manual cycling AP cost dexterity scaling smooth
		- [X] Retune the costs of manual cycling
- [X] Autofire shot count.
- [x] MG Recoil/setup rework (needs further testing)
- [x] Crouch and prone effect on the aperture, elliptical
- [ ] rotating while prone should cost more after the initial angle



 
## TOG
# Code 
- [X] safety mechanism for discontinued guns to keep their patching, at least to not break saves (python?)

## EO
- [ ] Barry Shaped charge is too sensitive to alterations. Increase angle

## Other balancing
- [ ] shotgun pellets interaction with gunshurt option
- [ ] Shotgun pellet balancing and spread, duckbill etc.
- [ ] Slug damage?
- [ ] **General balancing:** OW tuning — minor. -> *maybe some action that costs more, tighter ow cone, 3 aim levels?*
- [X] Change Grizzly melee perk to recoil or other

## QOL
- [X] Fix Shooting Stance animation, particulary in regards to mobile attack 
- [X] Crosshair AP cost breakdown refactor, for more clear stance ap cost display
- [ ] Implement F1 "wiki"
- [X] Grazing hits due to take cover show as if they are from Fog in floating text


##### ACTH

## aCTH Possible fragilities
- [ ] Maybe handling scaling would improve acc for mercs - less random, less enemy biased
- [ ] Important: pellets can hit the shooter at adjacent range. Probably other weapons as well. Need to make sure the vector does not touch the shooter
- [ ] Enemies try to shoot thru the floor (run and gun) - see save
- [X] Changing to oldCTH does not update Aim Acc from component already applied... Investigate better way to do it
- [ ] Kalyna missed a shot in oldCTH OW, but it hit? - Investigate
- [X] In aCTH mode, Reflexes don't affect hipfire or snapshot at all, unlike classic mode. If that wasn't intended, the Reflexes factor could be applied to the hipfire/snapshot cone widening in
- [ ] see if graphic display of single shot recoil is working. POssibly review the burst too
- [ ] OW when prone agains  hyenas had abysmal CTH, even when in close range ()
	-- NO LOS STILL TRIGGERING FOR OW!
- [ ] **Make sure aCTH lite works as intended**
- [X] Check how it works agains non-humanoids
- [X] ricochets still work?
- [ ] check if ricochet damage reduction is still applying
- [X] Aim is being used in the Interrupt? shows 0 levels
- [X] Shoot from above when very close. collision is strange. See savegame
- [X] **BUG** Shotgun "killed unit was reported, but no "attack hit" actually struck it." See save Shotty Bug


## ACTH Reimplementation necessary
- [X] out of breath impact on aim
- [X] AN94 2 round burst
- [X] Snipe/Pin Down action
- [X] low profile cth mod for crocs disabled when using aCTH
- [X] Camouflage.
- [X] How to deal with scopes that give bonuses to hit body parts or bypass cover?
  - Handzolt. -- Just gave it more acc/worst snapshot
  - [ ] Thermal scope
- [X] gas, smoke, other grazing mechanics need to be changed
- [X] Grizzly Perk - **there is something in the recoil cacl, check if its enough**
- [X] CQC bonus perk?
- [X] Major Perk (Bullet hell) **important**
- [X] Spiritual Perk
- [X] MGSetup Get AP (**ended up decreasing delta by 1**)
- [X] Check if Run and Gun penalty modifier for recoil was implemented

------------------------------------------------------------------------------------------------------------------------------

## aCTH Balancing
- [ ] Scopes - turn the floor mul into a readable effect (or just turn it back into increased range?)
- [ ] Possible use the offpart minus damage only for the head... 
- [ ] Pass at Scopes. Balance the acc numbers
- [ ] Digital Scope (G36) needs some param handling in aCTH. 
- [X] Remove stray from get cover action?
- [X] Evaluate aim soft cap, to see if new values are not capped (its 70 the cap)
- [X] Pinned down mod suppression for strays
- [X] Re-scale Aim Accuracy bonus for more gradient
	- [X] UV dot
	- [X] No stock penalty should be re-scaled as handguns have changed. Decide if more range penalty or more aim penalty is appropriate
	- [X] Light stock?
	- [X] Match ammo
	- [X] grips -> its a flat attack accuracy bonus
	- [X] better handling of the component aim scaler
- [X] review the Handling while standing penalty
	- [X] Decide if Recoil while standing should use the same parameters (currently uses `weigth_held_mul`)
- [X] Stray shots should have a lower chance to inflict status effects. 
	- [X] Pellets


# Later Stuff
## aCTH Descriptions that need change
- [X] Handguns "insert key" additional hints show reduced aim acc
- [X] Take cover not grazing mod option
- [X] Smoke not grazing. Decide if LOS
- [ ] Recoil CTH UI display - currently show  -x% per shot, which worked for the old CTH. Need a new way to make the player have some idea (even tho i have the V reticle...)
- [ ] Snapshot will not reset when shooting the same target **Only at page description**
- [X] DualShot max aim = 3 instead of 1
- [X] Autofire max aim levels no longer 1
- [X] Burst shots no longer lose aim bonus (logic is different)
- [X] Camouflage effect
- [X] MG Setup and set up bonuses/held  - the bonus is actually on being prone now
- [ ] UI CTH should change in aCTH - A separate line for the actual final accuracy, that shows the aperture size vs target size. The modifiers should be like 1.2x instead of 120% (to not confuse with probability) and they should 
 


##### AI OVERHAUL


## AI OVERHAUL - other mod
- [ ] Maybe do no stat boost in hyena or MELEE Overhaul!
- [ ] Militia custom AI. Stay close, defensive
- [ ] Hyenas and other animals should not be aware of OW
- [ ] decision making logic relating to grenades-> they should not use if they are very close to another target (that could be killed or kill them)
- [ ] Pellet precalc damage rationale, does it work?
- [x] **possible BUG** - Buckshot should not degrade to single shot 
- [X] Mechanics check
- [ ] in aCTH they should try to shoot the head if its the only part out of cover

- [X] Enemy `LastPos` should generate threat. They should also try to "chase" the last position.
- [x]  Check grenade distribution.
  - Give more timed grenades to enemies.
  - Less frustrating, but still a challenge to the player.
- [X] Check recoil calc for AI when using aCTH
- [X] Fix AI trying to shoot prone when there is a very small cover in front of it, making impossible to actually hit (see savegame) **---> Done. Just have to make sure they are not losing turns because of this**
- [X] Tune `Threat Exposure`, possibly simplify
	- [X] Fix LOS 
	- [X] Fix Debug overlay not decomposing ready curve 

## AI Overhaul new stuff
- [ ] Implement smoke usage.
- [ ] Bandage
- [ ] Overwatch against last target pos when unit is hidden. also make them throw grenades at it, specially when at a rooftop




## AI Overhaul - Low priority
- [ ] Take cover action is more important, should be used
- [ ] Make sure AI will not try to shoot through walls. (especially with aCTH)
- [ ] enemy behavior under PinDown... if the attack is not very likely to hit, they should not give much fuck
- [ ] "impatience" mechanic - if they are not being shot and not hitting, they should become more agressive
- [ ] groups should be more agressive?
- [ ] **Disabled** pindown action for now
- [ ] Team based strategy. Autoweapons suppress, skirmishers focus on getting closer to kill



### No-zone

## AI Overhaul - LUXURY
- [ ] Stealth
- [ ] Out of sight score when trying to flank

## New mechanics (luxury)
- [X] **Unify all crits into Crit Scaling.** Make it be per aim, and based on HEC, not level
- [ ] bonus crit per aim only on the first shot of the burst?
- [ ] MG and bipods setting up on cover/crouch
- [ ] **MEGA LUXURY** Vision cones/directional vision. Would need to make AI take this into account.
- [ ] agility defense against melee


## low priority
- [ ] If I keep the rare calibers, need to do something about distribution
-
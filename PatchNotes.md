[h1]Patch Notes 4.00[/h1]

[hr][/hr]

[h2]New CTH mode: aCTH[/h2]

This was created because I felt that accuracy was too high at long ranges, and just shooting first was what determined the result of a fight. I want it to feel more like a firefight: prolonged and suppression based (please use the Pinned Down mod).

Heavily inspired by 1.13 NuCTH. In this mode, every shot is simulated. Your accuracy generates an aperture that denotes the possible dispersion, and the shot is fired randomly inside this area. Aiming makes the dispersion tighter.

[list]
[*]Shots can hit body parts other than the one you intended. In these cases, crit and the body part status effect have a third of their usual chance, and the head/groin damage bonus is halved.
[*]Shots can hit cover. There is no more hardscripted cover. A small, thin lightpost can save you from a bullet (or your enemy).
[/list]

Expect dynamic (chaotic) results (that is the fun part!). You need to have the stomach for bouts of randomness to use this mode.

[h3](aCTH) Handling[/h3]
[list]
[*]New weapon stat: [b]Handling[/b]. It is the base precision factor for every attack. Small weapons have less penalty, but in turn get less aiming bonus. Replaces the Point Blank/Close Range bonus.
[*]Heavy/big weapons (MGs, Barrett, PSG) have worse handling if you are not prone. Some of this can be negated with high Strength.
[/list]

[h3](aCTH) Recoil[/h3]
[list]
[*]Recoil deviation is simulated. Strength controls how much recoil you control, Dexterity/Marksmanship help you get back on target.
[*]MGs have a recoil penalty (and the aforementioned handling penalty) when firing while not prone. There are no penalties for firing without setup: the benefits have all been transferred to being prone or having a bipod. MG Setup is now a way to Overwatch (with one bonus attack per turn).
[*]Being prone with a bipod reduces the vertical component of recoil.
[/list]

[h3](aCTH) Aim and Sights[/h3]
[list]
[*]The Aim Accuracy scale has been changed (values range from ~5 to 70).
[*]Aim Accuracy is very important to determine how well you can hit at range.
[*]Scopes work differently, mostly increasing max aim levels. High magnification scopes have more snapshot penalty, and work better with high Aim Accuracy weapons.
[*]Reflex sights have a flat accuracy bonus (equally good for weapons with high or low Aim Accuracy).
[*]Weapon range is now mostly about how tight you can make the dispersion. In some ways it is a floor to dispersion and a ceiling to Aim Accuracy. High range weapons benefit more from scopes; low range weapons get little benefit, as they reach the floor earlier.
[*]Other components have been changed.
[/list]

[h3](aCTH) Other stuff[/h3]
[list]
[*]Autofire has no cap on max aim levels.
[*]Dual Shot has max 3 aim levels and gets no benefit from scopes or sights.
[*]The CQC perk reduces snapshot and hipfire penalty for firearms, instead of giving bonus accuracy at close range. Melee and thrown weapons remain the same as the original.
[*]With simulated aCTH, firing through smoke no longer causes grazing; it reduces accuracy instead.
[*]With simulated aCTH, the Take Cover action no longer causes grazing. Can be reverted with a mod option.
[*]The Bullet Hell action now has simulated shots with recoil calculation.
[/list]

[hr][/hr]

[h2]New AP Scale[/h2]
[list]
[*]AP scale changed: what used to be 1 AP is now 10 AP. This opens avenues to tweak AP costs in a more granular way.
[*]Manual cycling AP has been tweaked (it costs less). The effects of Dexterity are no longer threshold steps but a smooth progression. Every point of Dexterity helps (mostly).
[*]Component impact on Shooting Stance cost was changed (barrels and stocks increase it less, handgun barrels now have a very small effect).
[/list]

[h2]Visibility[/h2]
[list]
[*]You no longer see an enemy on screen if no merc has vision of it (no visibility memory). Can be disabled in the mod options.
[*]Changed mobile attack target acquisition: you can now use it even if no target is in view but you presume there is one. The merc will shoot if an enemy is revealed.
[/list]

[h2]Reliability[/h2]
[list]
[*]Redesigned reliability mechanics. Reliability now governs the chance of jamming instead of condition degradation per shot. The formula was changed: high reliability weapons can perform even in lower condition.
[*]Suppressors now increase the condition degradation rate.
[*]MGs have less condition degradation per shot.
[/list]

[hr][/hr]

[h2]New Mechanic: Autofire with variable bullet count[/h2]
[list]
[*]When you use autofire, you can choose the amount of bullets you want to fire. The Burst Fire action has been removed and kept only on weapons with selective fire.
[*]Weapons now have an [b]RPM[/b] stat, which influences how much AP each additional shot costs.
[*]There is a chance, based on Composure (Marksmanship + Wisdom) and the weapon's RPM, of firing more bullets than intended when using autofire. You pay the AP cost if this happens. Psycho increases the chance, the Automatic Weapons perk decreases it. Trying to one-tap increases the chance.
[*]Some weapons are only capable of automatic fire (no single shot, but you can try to one-tap).
[*]Some MGs now have Selective Burst and Single Shot.
[*]Psycho has been reworked: the chance of triggering is now 6% instead of 3%, and no extra AP is deducted when it triggers. Single shot becomes automatic fire with 3 shots, Selective Burst becomes 2 bursts, automatic fire doubles the bullet count (capped at 10).
[*]Muzzle boosters now increase RPM slightly. Suppressors also increase RPM and no longer have the bonus damage against flanked units. The AKSU gets a reliability decrease when using a compensator (it lacks the backpressure of the booster or suppressor).
[*]Selective Burst now has better critical scaling than autofire, but less than single shot.
[/list]

[hr][/hr]

[h2]Attachments[/h2]
[list]
[*]Scopes, sights, side attachments, muzzle attachments, bipods and GLs are now inventory items sold by Bobby Ray's. You can attach and detach them from weapons. Compatibility varies.
[*]If you have the Ton of Components mod enabled, the game uses models from that mod (suppressors and other muzzle attachments). Otherwise, more than one caliber will share the same visual model.
[/list]

[h2]New weapon stat: Critical Chance per Aim[/h2]
Weapons now have a stat called [b]Critical Chance per Aim[/b], which scales with the merc's Hand-Eye Coordination (Marksmanship + Dexterity) and is applied to each aim level. The mechanic already existed, but it now completely overrides the old crit scaling based on merc level. Weapons have different values; snipers have the most.

[h2]Caliber damage reworked[/h2]
[list]
[*]Big calibers (7.62 and the like) have increased damage (and recoil).
[*]Barrel length and caliber now determine the weapon's damage. Some calibers have a length cap past which damage no longer increases. Extended and short barrels now change damage dynamically (though mostly by a little).
[/list]

[hr][/hr]

[h2]Perks[/h2]
[list]
[*][b]Sharpshooter[/b]: reworked. It no longer grants extra aim levels or Marksmanship-based damage (scopes already raise max aim in aCTH). Instead it rewards a sniper that holds position:
[list]
[*]Start your turn on the tile where you started the previous one to gain a [b]Settled[/b] stack (max 2). Mercs that are already in position when combat starts begin fully Settled.
[*]Moving removes all stacks.
[*]Each stack gives [b]every aim level[/b] of your [b]first attack[/b] each turn +5 Aim Accuracy, +1% Crit Chance and +3% Crit Damage, so it scales with scopes and high aim.
[*]Does not apply to interrupt attacks (Overwatch included).
[*]Settled shows as a new status effect with its stack count.
[/list]
[*][b]Opportunistic Killer[/b]: no longer enables crits on interrupt attacks. Instead, grants 1 extra Overwatch attack. Still reloads automatically after Overwatch.
[*][b]Killzone[/b]: no longer grants a bonus attack on interrupts. Overwatch attacks against the first enemy each turn have 3 aim levels, the second 2, the rest 1. Enables crits on interrupt attacks.
[*]New Strength perk [b]Beaten Zone[/b]: MG Setup and emplacement interrupt attacks get +10 Accuracy, and the same aim levels as Killzone (no crits). [b]Collateral Damage[/b] is back to vanilla.
[*][b]Heavy Weapons[/b] now reduces Shooting Stance AP instead of Setup AP (indirectly it still reduces Setup AP).
[*]Grizzly's new starting perk is Recoil Control instead of Killing Spree.
[/list]

[h2]UI Improvements[/h2]
[list]
[*]The UI section that displays Recoil, Snapshot etc. was reworked. The displayed number is the effective value for the merc, and the grey number after it is the weapon's base value. There is also a visual bar: green and red show the impact of the merc's stats on the value.
[*]The inventory now displays accuracy and recoil graphs for weapons.
[*]Pressing F1 brings up help sections that explain the mechanics of the mod.
[/list]

[hr][/hr]

[h2]Other changes[/h2]
[list]
[*]When set up, MGs have a lower snapshot penalty for interrupt attacks at long distances.
[*]Setting up an MG now costs more if you are not prone. This extra cost can be paid with free move AP. Base cost reduced by 10.
[*]Component and perk effects on recoil/snapshot/hipfire and aim tweaked.
[*]Snipe action bonus crit per aim from 5 to 4.
[*]Heavy rain no longer increases aim AP. Instead, it makes aiming less effective.
[*]Reflex sights no longer increase range.
[*]Snapshot penalty for opportunity attacks decreased (from an extra +20% to +10%). Reflex stat scaling grants a bigger accuracy boost.
[*]Changed fog vision radius reduction. Fog no longer causes grazing hits.
[*]Shotgun AP costs tweaked.
[*]Gas masks reduce accuracy instead of AP.
[*]Bobby Ray's ammo distribution was improved.
[*]The Deagle is now .50 AE by default.
[*]Fixed and improved Shooting Stance animations (shoutout to @dabhand).
[*]Fixed bugs related to shotguns.
[*]Fixed missing property burst_recoil_delta.
[*]Changed the logic that made mercs step out of cover to shoot.
[*]Revamped mod options
[*]Other balance tweaks that I forgot.
[/list]

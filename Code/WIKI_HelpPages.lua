---- F1 Help Topics pages: PopupNotification holds the page, TutorialHint lists it in OpenHelpMenu.
local GBO_WIKI_IMAGE = "Mod/cfahRED/Images/CapaGBO.png"

GBO_WIKI_PAGES = {
    {
        id = "About",
        title = T(735216048811, "GBO: About the Mod"),
        text = T(735216048812, "<em>Rato's Gameplay Balance and Overhaul</em> reworks how firearms, aiming and combat pacing work. Fights are meant to be longer firefights, where positioning, cover and suppression matter more than simply shooting first.\n\nThese pages explain the new mechanics. Most of them can be tuned in the <em>Mod Options</em>. Pages and sections marked <em>aCTH</em>, <em>aCTH Lite</em> or <em>old CTH</em> only apply in that CTH mode; the rest apply in every mode.\n\nAbilities, perks and items that have their own description in the game are not repeated here; read their rollover text instead."),
    },
    {
        id = "CTHModes",
        title = T(735216048813, "GBO: Chance to Hit Modes"),
        text = T(735216048814, "The <em>CTH Mode</em> mod option selects how shots are resolved:\n\n<em>aCTH</em> (default): every shot is simulated. Your accuracy becomes a cone around the aim point, the bullet flies to a random point inside it, and whatever it touches first is hit.\n\n<em>aCTH Lite</em>: uses the same cone to calculate the hit chance, but the hit is decided by a dice roll, like vanilla. Bullets cannot stray into other body parts or into cover.\n\n<em>old CTH</em>: the classic system of accuracy bonuses and penalties added together. Most weapon and stat changes still apply, but the cone does not exist."),
    },
    {
        id = "Cone",
        title = T(735216048815, "GBO: The Aim Cone"),
        text = T(735216048816, "Applies to: <em>aCTH</em> and <em>aCTH Lite</em>.\n\nThe ring drawn around the target shows where your shot can land. Everything that makes you more or less accurate makes the ring smaller or larger: weapon, aim level, stance, recoil, the merc's stats and the distance.\n\nThe hit chance is the share of the ring that covers the part of the target you can actually see. A target behind cover, crouched or prone, or far away fills less of the ring.\n\n<em>aCTH only:</em> a shot can hit a <em>different body part</em> than the one aimed at. Such hits deal slightly less damage and have a lower chance to crit or inflict status effects. A miss is a real bullet, and it can hit cover, objects or other units along its path.\n\n<em>aCTH only:</em> press <em>Ctrl-Alt-H</em> to show or hide the <em>shot history</em> of the selected merc: a line for each bullet of their last attack (every shot of a mobile attack counts), from the weapon to where it stopped. Where a bullet wounded a unit, a circle shows the body part it hit, red or gold for a critical hit, with the damage of each attack above the unit. An orange mark shows damage to an object. The history clears when the merc or a unit they hit moves."),
    },
    {
        id = "Aiming",
        title = T(735216048817, "GBO: Aiming"),
        text = T(735216048818, "<em>aCTH and aCTH Lite:</em> each aim level tightens the cone. How much it tightens depends on the weapon's <em>Aim Accuracy</em> and on the merc's <em>Hand-Eye Coordination</em>.\n\nThe weapon's <em>Range</em> works as a limit on how tight the cone can get. Short-range weapons reach that limit quickly, so extra aiming does little for them. Long-range weapons keep improving with every aim level, which is why they benefit the most from scopes.\n\n<em>Old CTH:</em> each aim level adds an accuracy bonus, scaled by the merc's Hand-Eye Coordination.\n\nIn every mode, being <em>Out of Breath</em> makes aiming less effective."),
    },
    {
        id = "Handling",
        title = T(735216048819, "GBO: Handling"),
        text = T(735216048820, "Applies to: <em>aCTH</em> and <em>aCTH Lite</em>. Old CTH uses the Point Blank bonus instead.\n\n<em>Handling</em> is a weapon stat that sets the base precision of every attack, aimed or not.\n\nSmall, light weapons such as pistols and SMGs handle well and are accurate quickly, but gain less from aiming. Large weapons handle poorly and need aiming to perform.\n\nHeavy weapons (machine guns and heavy rifles) handle much worse when the shooter is <em>not prone</em>; crouching pays part of it. The heavier the weapon, the larger the penalty. <em>Strength</em> carries part of the weight, never all of it, so the heaviest weapons stay hard to use off the ground whoever holds them.\n\nThe merc's Hand-Eye Coordination scales how well a weapon's handling is used."),
    },
    {
        id = "ShootingStance",
        title = T(735216048821, "GBO: Shooting Stance"),
        text = T(735216048822, "Before the first aimed attack, a merc must bring the weapon up and enter <em>Shooting Stance</em>. This costs AP, depending on the weapon and its attachments, and grants one free aim level to every attack while it lasts.\n\nIn Shooting Stance, the merc covers an arc in front of them, the weapon's <em>Shooting Angle</em>. Turning to a target outside that arc costs extra AP.\n\nMoving, changing weapons, reloading, going prone or taking heavy damage ends the stance. Mobile attacks such as Run and Gun end with the merc already in Shooting Stance."),
    },
    {
        id = "HipfireSnapshot",
        title = T(735216048823, "GBO: Hipfire and Snapshot"),
        text = T(735216048824, "Shots fired without aiming are less accurate:\n\n<em>Hipfire</em>: firing without Shooting Stance, with no aim at all. This has the largest penalty.\n\n<em>Snapshot</em>: firing with only the first aim level, including interrupt attacks such as Overwatch and mobile attacks such as Run and Gun. The penalty is smaller.\n\nBoth penalties depend on the weapon. Big, heavy weapons and high-magnification scopes suffer the most. The merc's <em>Reflexes</em> reduce both."),
    },
    {
        id = "Scopes",
        title = T(735216048825, "GBO: Scopes and Sights"),
        text = T(735216048826, "Applies to: <em>aCTH</em> and <em>aCTH Lite</em>.\n\n<em>Scopes</em> mostly add extra aim levels, letting long-range weapons tighten their cone further. The more magnification, the worse the snapshot penalty, so powerful scopes are poor for quick shots and pair best with accurate long-range weapons.\n\n<em>Reflex and red dot sights</em> give a flat accuracy bonus that helps every weapon equally. They do not add range.\n\nSome optics have special traits, such as making the last aim level free or improving critical hits. Read the attachment's description."),
    },
    {
        id = "Recoil",
        title = T(735216048827, "GBO: Recoil"),
        text = T(735216048828, "Bigger calibers kick harder, and <em>Strength</em> decides whether a merc can hold a weapon at all.\n\n<em>Within a burst</em>\n<em>aCTH and aCTH Lite:</em> recoil is simulated. Each round kicks the weapon off target, and the following rounds start from where the muzzle ended up. <em>Marksmanship</em> brings it back on target. Firing prone with a <em>bipod</em> strongly reduces the upward kick.\n<em>Old CTH:</em> each round after the first loses accuracy.\n\n<em>Between attacks</em>\nEvery attack, even a single shot, leaves the merc with stacking <em>Recoil</em>. It lowers the accuracy of the next attacks and makes the first aim levels cost more AP.\n\nAfter a shot, aiming is less about precision and more about <em>waiting for the weapon to settle</em>: the extra aim cost is the time spent bringing it back on target. You can fire again right away, quickly but through the recoil, or pay to aim and let it settle. A fully aimed attack clears it.\n\nMoving, reloading, entering Overwatch or leaving Shooting Stance also clears it. Manually cycled weapons pay less, since cycling already gives the merc time to recover."),
    },
    {
        id = "RecoilWindow",
        title = T(735216048863, "GBO: Recoil Window"),
        text = T(735216048864, "Applies to: <em>aCTH</em> and <em>aCTH Lite</em>. Shown when aiming a burst or autofire attack. The <em>Recoil Window</em> mod option picks the view.\n\n<em>Kick per Shot</em>: how far each round throws the muzzle off target. Set by the weapon, caliber and fire mode; a prone <em>bipod</em> lowers it.\n\n<em>Max Correction</em>: how much of each kick the merc can soak up while it happens, mostly from <em>Strength</em>. The bar turns red when it is smaller than the kick: then every round climbs a little further.\n\n<em>Correction per Shot</em>: how much the merc can pull the muzzle back toward the original aim point between rounds, mostly from <em>Marksmanship</em>, plus a little from Strength above the caliber's requirement. It also adds some error of its own, which shrinks with Marksmanship.\n\n<em>Drift</em>: one square per round, how far the muzzle has wandered from the original aim point when that round fires.\n\n<em>Simple view</em>: <em>Control</em> is the average of the round squares after the first. <em>Rounds</em> shows the same squares as Drift.\n\n<em>Square colors</em>: the share of simulated bursts where that round still points at the target, counting only recoil (the first round is treated as a perfect hit). <em>Green</em> most of the time, <em>amber</em> about half, <em>red</em> rarely.\n\n<em>V reticle</em>: the line rising from the aim ring is the expected path of the muzzle during the burst, with a tick per round. The two diagonals beside it open as the group spreads. The <em>Recoil V Reticle</em> mod option turns it off."),
    },
    {
        id = "RecoilControl",
        title = T(735216048865, "GBO: Recoil Control"),
        text = T(735216048866, "Applies to: <em>aCTH</em> and <em>aCTH Lite</em>. How a merc keeps a burst on target. Terms as in the <em>GBO: Recoil Window</em> page.\n\n<em>The weapon</em> sets the <em>Kick per Shot</em>: caliber, weight and fire mode. Stats do not change it.\n\n<em>Strength</em> sets <em>Max Correction</em>. Every caliber has a Strength requirement. Below it, Max Correction is smaller than the kick, so each round climbs further than the last and the burst walks off the target however skilled the merc is. Above it, the climb can be stopped, and extra Strength keeps adding a little <em>Correction per Shot</em>.\n\n<em>Marksmanship</em> is the main source of <em>Correction per Shot</em>: how fast the merc drags the muzzle back to the aim point. It also aims every correction and sets how shaky it is. A strong merc with poor Marksmanship keeps the muzzle near the target but scatters the rounds around it: long bursts still land some hits, short ones rarely. <em>Dexterity</em> plays no part in recoil.\n\n<em>Stance and gear</em>: crouching and especially prone raise Correction per Shot. A <em>bipod</em> while prone also cuts the upward kick, except on hipfire attacks. Heavy weapons fired standing or crouched lose correction; Strength gives back part of it, never all. Machine guns hold steadier than rifles: their weight damps the shooter's own shake. Firing on the move costs correction. The <em>Recoil Management</em> and <em>Auto Weapons</em> perks raise it.\n\n<em>Examples</em> (4-round autofire, standing, torso at 10 tiles; share of bursts where rounds 1/2/3/4 still point at the target, recoil only):\n\nAK-74, Str 80, Marks 80: 100/86/32/19. Prone: 100/95/45/29.\n\nAK-74, Str 50 (below its requirement), Marks 60: 100/45/3/0. The second round may land, the rest are gone.\n\nAK-47, Str 80, Marks 80: 100/43/3/1. Same merc, heavier caliber: round 2 is a coin flip. At Str 50 and Marks 60: 100/10/0/0.\n\nMP5, Str 60: Marks 50 gives 100/39/5/1, Marks 100 gives 100/73/23/10. A strong merc gets little from a 9mm, a skilled one a lot.\n\nMG42 standing: no Strength is enough. Prone on its bipod, Str 80 and Marks 80: 100/58/31/17.\n\n<em>In short</em>: Strength decides whether the merc can hold the weapon at all, Marksmanship how many rounds stay on target once they can. Short bursts and a lower stance help everyone."),
    },
    {
        id = "Cover",
        title = T(735216048829, "GBO: Cover, Stance and Smoke"),
        text = T(735216048830, "Applies to: <em>aCTH</em> and <em>aCTH Lite</em>.\n\nThere is no fixed cover bonus: the hit chance counts only the part of the target that is actually exposed. Shooting from an angle or from higher ground exposes more of the target.\n\nA target's stance changes its silhouette. Crouching makes a target shorter, and prone makes it much smaller.\n\n<em>aCTH only:</em> cover is physical, so a bullet that would pass through a wall, crate or lamppost is stopped by it. Because of this, <em>Take Cover</em> no longer turns hits into grazes; a mod option restores the vanilla grazes. Firing through <em>smoke</em> lowers accuracy instead of causing grazing hits."),
    },
    {
        id = "Crits",
        title = T(735216048831, "GBO: Critical Hits"),
        text = T(735216048832, "Each weapon has a <em>Critical Chance per Aim</em> stat. Every aim level adds that much critical chance, scaled by the merc's Hand-Eye Coordination. Merc level no longer raises critical chance.\n\nSniper rifles have the highest value.\n\nThe firing mode also matters. Single shots keep the full bonus, selective bursts keep less, and autofire keeps the least.\n\nSome ammo and perks add <em>base critical chance</em> instead. Base critical chance does not depend on aim and is the same for every firing mode."),
    },
    {
        id = "Autofire",
        title = T(735216048833, "GBO: Autofire"),
        text = T(735216048834, "<em>Autofire</em> lets you choose how many rounds to fire. Use the <em>mouse wheel</em> on the crosshair to change the length of the burst. Each extra round costs AP based on the weapon's rate of fire (<em>RPM</em>): fast-firing weapons spend less AP per round.\n\nA merc can lose control and fire <em>more rounds than intended</em>. The extra rounds cost AP. This is more likely with low <em>Composure</em> and fast-firing weapons, and when trying to fire a single round from a full-auto weapon.\n\nThe fixed-length <em>Burst Fire</em> action remains only on weapons with a selective burst mode. Some weapons can only fire automatically."),
    },
    {
        id = "MachineGuns",
        title = T(735216048835, "GBO: Machine Guns and Bipods"),
        text = T(735216048836, "Machine guns perform best when <em>braced</em>: fired prone, resting on the bipod. Machine gun attacks also cost more AP than rifle attacks, and a long, heavy gun is slow to swing onto a target, so its snapshot penalty is larger.\n\n<em>aCTH and aCTH Lite:</em> in vanilla, MG Setup was what removed a machine gun's penalties. Here, being <em>prone</em> is enough, set up or not. A machine gun kicks less than a rifle of the same caliber and its weight steadies the shooter, so braced on its bipod it outshoots that rifle.\n\nFired while standing or crouched, a machine gun handles poorly and kicks harder, the more so the heavier it is. <em>Strength</em> carries part of the weight, never all of it: a light machine gun starts to pay off standing in the hands of a merc with about 80 Strength, while the heaviest ones stay weapons for the bipod.\n<em>Old CTH:</em> MG Autofire from a machine gun that is not set up suffers extra recoil, reduced by high Strength. MG Setup reduces recoil.\n\n<em>MG Setup</em> is a form of Overwatch. The gunner goes prone, covers a cone, and fires interrupt attacks with a reduced snapshot penalty. While set up, a machine gun can use all its fire modes, but only against targets inside the cone. Setting up costs more AP if the gunner is not already prone.\n\nA <em>bipod</em> only works when prone, where it reduces the upward kick; it never makes a prone weapon worse. It does not apply to hipfire attacks. Off the ground, the bipod makes the weapon slower to bring up and narrows its Shooting Angle."),
    },
    {
        id = "Overwatch",
        title = T(735216048861, "GBO: Overwatch and Interrupts"),
        text = T(735216048862, "Interrupt attacks, such as <em>Overwatch</em> shots, are fired at a moving target with no time to aim. They are always <em>snapshots</em>: they get the single aim level of a raised weapon, and the snapshot penalty applies. Some perks grant interrupt attacks more aim levels.\n\nOn top of that, interrupt attacks gain or lose accuracy depending on the merc's <em>Reflexes</em>: a slow merc loses accuracy, a quick one gains it. Some sights and attachments add an extra interrupt bonus, which also grows with Reflexes.\n\nThe <em>OW Bonus Multiplier</em> option scales that attachment bonus.\n\nA set-up machine gun suffers a smaller snapshot penalty on its interrupt attacks, even at long range."),
    },
    {
        id = "MobileAttacks",
        title = T(735216048837, "GBO: Mobile Attacks"),
        text = T(735216048838, "Mobile attacks, such as Run and Gun and Mobile Shot, fire while moving. Their shots are always <em>snapshots</em>.\n\n<em>Agility</em> decides how steady the merc is on the move: above 70 the shots get tighter, below 70 they get wider. A nimble merc is the one to run and gun with.\n\nThey can be planned <em>without a visible target</em>. If an enemy is revealed during the move, the merc shoots at them. If nobody shows up, the AP for the planned shots is not refunded.\n\nWhen the move ends, the merc stays in Shooting Stance, facing the last target."),
    },
    {
        id = "Shotguns",
        title = T(735216048839, "GBO: Shotguns"),
        text = T(735216048840, "Applies to: <em>aCTH</em>.\n\nEvery pellet of a shotgun blast is simulated. The spread grows with distance: up close most pellets land on the target, while at range only a few do, and stray pellets can hit other units or objects.\n\nDamage is dealt per pellet that hits. Pellets that strike other body parts are penalized less than stray rifle bullets.\n\n<em>Slugs</em> fire a single projectile and behave like a rifle bullet."),
    },
    {
        id = "Attachments",
        title = T(735216048841, "GBO: Attachments"),
        text = T(735216048842, "Scopes, sights, side devices, grips, muzzle devices, bipods and grenade launchers are <em>inventory items</em>. Attaching one at the weapon modification screen uses up the item, and removing it returns the item to your inventory.\n\nBobby Ray sells attachments on their own pages. Better optics unlock later in the campaign and are rarer.\n\nNot every attachment fits every weapon. The modification screen shows which ones fit.\n\nAttachments can no longer be crafted, so Parts have fewer uses. The <em>Parts Gain %</em> option sets how many Parts you find. Chips and lenses can be cashed in for money."),
    },
    {
        id = "Calibers",
        title = T(735216048843, "GBO: Calibers and Damage"),
        text = T(735216048844, "Damage comes from the <em>caliber</em> and the <em>barrel length</em>. Bigger calibers hit harder and kick harder. A longer barrel adds damage and a shorter one removes it, up to a limit set by each caliber.\n\nThe ammo rollover shows the caliber's base damage and the round's armor penetration.\n\nEach caliber also has its own noise range. The <em>Firearm Noise %</em> option controls this."),
    },
    {
        id = "Reliability",
        title = T(735216048845, "GBO: Reliability and Jams"),
        text = T(735216048846, "<em>Reliability</em> is the weapon's resistance to jamming. The chance to jam grows as <em>Condition</em> drops, and reliable weapons keep working even when worn.\n\nWear per shot no longer depends on Reliability. It grows with the number of rounds fired, but more slowly than one-for-one, so long bursts are not punished per bullet. Suppressors increase wear. Machine guns wear less per round."),
    },
    {
        id = "ActionPoints",
        title = T(735216048847, "GBO: Action Points"),
        text = T(735216048848, "AP are shown on a finer scale: <em>1 vanilla AP is 10 AP</em>. Costs did not grow, they are just measured more precisely, so small differences between weapons and attachments can show."),
    },
    {
        id = "Cycling",
        title = T(735216048859, "GBO: Manual Cycling"),
        text = T(735216048860, "Bolt-action and lever-action rifles and single-action revolvers must be <em>cycled</em> by hand after each shot. Until then the weapon is shown as <em>UNBOLTED</em>, <em>UNCYCLED</em> or <em>UNCOCKED</em>.\n\nClick the weapon's <em>reload button</em> to cycle it, or just attack: the cycling cost is added to the attack. Higher <em>Dexterity</em> makes cycling cheaper.\n\n<em>Double-action</em> revolvers can also fire without being cocked, for an extra attack cost.\n\nIf the merc still has the AP at the end of the turn, the weapon is cycled automatically. Weapons are also cycled when combat ends.\n\nThe time spent cycling lets the merc recover from recoil, so these weapons pay less extra aim cost from carried-over recoil."),
    },
    {
        id = "Visibility",
        title = T(735216048849, "GBO: Visibility"),
        text = T(735216048850, "In vanilla, an enemy you spotted stays visible through walls until the end of the turn.\n\nIn this mod, enemies are shown only while one of your units actually sees them, including while they move. The same rule applies to every side. Turn off the <em>No revealed-enemy memory</em> option to restore the vanilla behavior.\n\nNight sight and detection can be adjusted in the Mod Options."),
    },
    {
        id = "WeaponInfo",
        title = T(735216048851, "GBO: Weapon Info and Charts"),
        text = T(735216048852, "Weapon stats show the <em>effective value for the merc</em>, with the weapon's base value in grey after it. The bar shows how much the merc's stats help (green) or hurt (red).\n\n<em>aCTH and aCTH Lite:</em> <em>More Info</em> on a weapon shows a <em>hit chance chart</em> by distance for the merc's current stance, and a <em>recoil chart</em> for bursts. Holding <em>Shift</em> to compare two weapons draws both on the same chart. The weapon modification screen has the same charts and previews how a part would change them before you attach it."),
    },
    {
        id = "HandEye",
        title = T(735216048853, "GBO: Hand-Eye Coordination"),
        text = T(735216048854, "<em>Hand-Eye Coordination</em> is a combined attribute, made mostly of <em>Dexterity</em> and partly of <em>Marksmanship</em>.\n\nIt scales the weapon's <em>Critical Chance per Aim</em> in every mode.\n\n<em>aCTH and aCTH Lite:</em> it decides how much each aim level tightens the cone; a merc with low Hand-Eye Coordination gains less from aiming. It also scales the weapon's <em>Handling</em>: good handling helps less and bad handling hurts more when it is low.\n\n<em>Old CTH:</em> it scales the aim bonus and the weapon's Point Blank bonus."),
    },
    {
        id = "Reflexes",
        title = T(735216048855, "GBO: Reflexes"),
        text = T(735216048856, "<em>Reflexes</em> is a combined attribute, made equally of <em>Dexterity</em> and <em>Agility</em>.\n\nIt reduces the <em>Hipfire</em> and <em>Snapshot</em> penalties, so it decides how accurate quick, unaimed shots are.\n\nThis includes interrupt attacks such as <em>Overwatch</em>, which are always snapshots.\n\nFor hipfired bursts from automatic weapons and shotguns, <em>Strength</em> takes the place of Reflexes, since holding the weapon steady matters more than speed.\n\nMobile attacks add a separate <em>Agility</em> modifier on top, for shooting while on the move."),
    },
    {
        id = "Composure",
        title = T(735216048857, "GBO: Composure"),
        text = T(735216048858, "<em>Composure</em> is a combined attribute, made mostly of <em>Marksmanship</em> and partly of <em>Wisdom</em>. It measures how calm a merc stays behind the trigger.\n\nIn <em>Autofire</em>, low Composure makes a merc more likely to fire more rounds than intended.\n\nA merc in <em>Shooting Stance</em> who takes a heavy hit must pass a Composure check, or they lose the stance.\n\n<em>Old CTH:</em> it also lowers the extra penalty for aiming at a specific body part."),
    },
}

for _, page in ipairs(GBO_WIKI_PAGES) do
    local id = "GBO_Wiki_" .. page.id
    PlaceObj('PopupNotification', {
        id = id,
        group = "GBO",
        campaign = "<all>",
        Title = page.title,
        Text = page.text,
        Image = GBO_WIKI_IMAGE,
    })
    -- StartingHelp: the visibility pass lists it without popping it up.
    PlaceObj('TutorialHint', {
        id = id,
        group = "StartingHelp",
        campaign = "<all>",
        PopupId = id,
        Text = page.title,
    })
end

---- TutorialHintsState is saved per game, so pages are unlocked when the help menu lists them.
local orig_help_hints = Rat_AttOriginal(TutorialGetHelpMenuHints)
function TutorialGetHelpMenuHints()
    local state = TutorialHintsState
    if state then
        for _, page in ipairs(GBO_WIKI_PAGES) do
            local id = "GBO_Wiki_" .. page.id
            state.visible[id] = state.visible[id] or GetQuestNoteCampaignTimestamp()
        end
    end
    return orig_help_hints()
end
RAT_ATT_WRAPS[TutorialGetHelpMenuHints] = orig_help_hints

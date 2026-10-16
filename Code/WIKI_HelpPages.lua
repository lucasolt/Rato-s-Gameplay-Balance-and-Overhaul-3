---- F1 Help Topics pages: PopupNotification holds the page, TutorialHint lists it in OpenHelpMenu.
local GBO_WIKI_IMAGE = "Mod/cfahRED/Images/CapaGBO.png"

GBO_WIKI_PAGES = {
    {
        id = "About",
        title = T(735216048811, "GBO: About the Mod"),
        text = T(735216048812, "<em>Rato's Gameplay Balance and Overhaul</em> reworks how firearms, aiming and combat pacing work. Fights are meant to be longer firefights, where positioning, cover and suppression matter more than simply shooting first.\n\nThese pages explain the new mechanics. Most of them can be tuned in the <em>Mod Options</em>.\n\nAbilities, perks and items that have their own description in the game are not repeated here; read their rollover text instead."),
    },
    {
        id = "CTHModes",
        title = T(735216048813, "GBO: Chance to Hit Modes"),
        text = T(735216048814, "The <em>CTH Mode</em> mod option selects how shots are resolved:\n\n<em>aCTH</em> (default): every shot is simulated. Your accuracy becomes a cone around the aim point, the bullet flies to a random point inside it, and whatever it touches first is hit. These pages describe this mode.\n\n<em>aCTH Lite</em>: uses the same cone to calculate the hit chance, but the hit is decided by a dice roll, like vanilla. Bullets cannot stray into other body parts or into cover.\n\n<em>old CTH</em>: the classic system of accuracy bonuses and penalties added together. Most weapon and stat changes still apply, but the cone does not exist."),
    },
    {
        id = "Cone",
        title = T(735216048815, "GBO: The Aim Cone"),
        text = T(735216048816, "In aCTH, the ring drawn around the target shows where your shot can land. Everything that makes you more or less accurate makes the ring smaller or larger: weapon, aim level, stance, recoil, the merc's stats and the distance.\n\nThe hit chance is the share of the ring that covers the part of the target you can actually see. A target behind cover, crouched or prone, or far away fills less of the ring.\n\nA shot can hit a <em>different body part</em> than the one aimed at. Such hits deal slightly less damage and have a lower chance to crit or inflict status effects.\n\nA miss is a real bullet. It can hit cover, objects or other units along its path."),
    },
    {
        id = "Aiming",
        title = T(735216048817, "GBO: Aiming"),
        text = T(735216048818, "Each aim level tightens the cone. How much it tightens depends on the weapon's <em>Aim Accuracy</em> and on the merc's <em>Hand-Eye Coordination</em> (Marksmanship and Dexterity).\n\nThe weapon's <em>Range</em> works as a limit on how tight the cone can get. Short-range weapons reach that limit quickly, so extra aiming does little for them. Long-range weapons keep improving with every aim level, which is why they benefit the most from scopes.\n\nAt long distances, aiming matters far more than the merc's raw accuracy."),
    },
    {
        id = "Handling",
        title = T(735216048819, "GBO: Handling"),
        text = T(735216048820, "<em>Handling</em> is a weapon stat that sets the base precision of every attack, aimed or not. It replaces the vanilla Point Blank bonus.\n\nSmall, light weapons such as pistols and SMGs handle well and are accurate quickly, but gain less from aiming. Large weapons handle poorly and need aiming to perform.\n\nHeavy weapons (machine guns and heavy rifles) handle much worse when the shooter is <em>not prone</em>. High Strength removes part of this penalty.\n\nThe merc's Hand-Eye Coordination scales how well a weapon's handling is used."),
    },
    {
        id = "ShootingStance",
        title = T(735216048821, "GBO: Shooting Stance"),
        text = T(735216048822, "Before the first aimed attack, a merc must bring the weapon up and enter <em>Shooting Stance</em>. This costs AP, depending on the weapon and its attachments, and grants one free aim level to every attack while it lasts.\n\nIn Shooting Stance, the merc covers an arc in front of them, the weapon's <em>Shooting Angle</em>. Turning to a target outside that arc costs extra AP.\n\nMoving, changing weapons, reloading, going prone or taking heavy damage ends the stance. Mobile attacks such as Run and Gun end with the merc already in Shooting Stance."),
    },
    {
        id = "HipfireSnapshot",
        title = T(735216048823, "GBO: Hipfire and Snapshot"),
        text = T(735216048824, "Shots fired without aiming are less accurate:\n\n<em>Hipfire</em>: firing without Shooting Stance, with no aim at all. This has the largest penalty.\n\n<em>Snapshot</em>: firing with only the first aim level, including interrupt attacks such as Overwatch. The penalty is smaller.\n\nBoth penalties depend on the weapon. Big, heavy weapons and high-magnification scopes suffer the most. The merc's <em>Reflexes</em> (Dexterity and Agility) reduce both."),
    },
    {
        id = "Scopes",
        title = T(735216048825, "GBO: Scopes and Sights"),
        text = T(735216048826, "<em>Scopes</em> mostly add extra aim levels, letting long-range weapons tighten their cone further. The more magnification, the worse the snapshot penalty, so powerful scopes are poor for quick shots and pair best with accurate long-range weapons.\n\n<em>Reflex and red dot sights</em> give a flat accuracy bonus that helps every weapon equally. They do not add range.\n\nSome optics have special traits, such as making the last aim level free or improving critical hits. Read the attachment's description."),
    },
    {
        id = "Recoil",
        title = T(735216048827, "GBO: Recoil"),
        text = T(735216048828, "Recoil is simulated. Each round kicks the weapon off target, and the following rounds of a burst start from where the muzzle ended up.\n\n<em>Strength</em> controls how hard the weapon kicks. <em>Dexterity</em> and <em>Marksmanship</em> help bring it back on target. Bigger calibers kick harder.\n\nRecoil also carries over between attacks as an accuracy penalty. Aiming works it off, and a fully aimed attack clears it.\n\nFiring prone with a <em>bipod</em> strongly reduces the upward kick."),
    },
    {
        id = "Cover",
        title = T(735216048829, "GBO: Cover, Stance and Smoke"),
        text = T(735216048830, "With aCTH, cover is physical. There is no fixed cover bonus: a bullet that would pass through a wall, crate or lamppost is stopped by it. Shooting from an angle or from higher ground exposes more of the target.\n\nA target's stance changes its silhouette. Crouching makes a target shorter, and prone makes it much smaller.\n\n<em>Take Cover</em> no longer turns hits into grazes, because the cover itself already stops bullets. A mod option restores the vanilla grazes.\n\nFiring through <em>smoke</em> lowers accuracy instead of causing grazing hits. A <em>gas mask</em> also lowers the wearer's accuracy."),
    },
    {
        id = "Crits",
        title = T(735216048831, "GBO: Critical Hits"),
        text = T(735216048832, "Each weapon has a <em>Critical Chance per Aim</em> stat. Every aim level adds that much critical chance, scaled by the merc's Hand-Eye Coordination. Merc level no longer raises critical chance.\n\nSniper rifles have the highest value. Some ammo adds a flat critical chance on top.\n\nThe firing mode also matters. Single shots keep the full bonus, selective bursts keep less, and autofire keeps the least."),
    },
    {
        id = "Autofire",
        title = T(735216048833, "GBO: Autofire"),
        text = T(735216048834, "<em>Autofire</em> lets you choose how many rounds to fire. Use the <em>mouse wheel</em> on the crosshair to change the length of the burst. Each extra round costs AP based on the weapon's rate of fire (<em>RPM</em>): fast-firing weapons spend less AP per round.\n\nA merc can lose control and fire <em>more rounds than intended</em>. The extra rounds cost AP. This is more likely with low <em>Composure</em> (Marksmanship and Wisdom) and fast-firing weapons, and when trying to fire a single round from a full-auto weapon.\n\nThe fixed-length <em>Burst Fire</em> action remains only on weapons with a selective burst mode. Some weapons can only fire automatically."),
    },
    {
        id = "MachineGuns",
        title = T(735216048835, "GBO: Machine Guns and Bipods"),
        text = T(735216048836, "Machine guns are built to fire from the ground. Fired while standing or crouched, they suffer worse handling and recoil and cost more AP to fire.\n\n<em>MG Setup</em> is a form of Overwatch. The gunner goes prone, covers a cone, and fires interrupt attacks with a reduced snapshot penalty. While set up, a machine gun can use all its fire modes, but only against targets inside the cone. Setting up costs more AP if the gunner is not already prone.\n\nA <em>bipod</em> only works when prone, where it tightens the cone and reduces recoil. Off the ground, the bipod makes the weapon slower to bring up and narrows its Shooting Angle."),
    },
    {
        id = "MobileAttacks",
        title = T(735216048837, "GBO: Mobile Attacks"),
        text = T(735216048838, "Mobile attacks, such as Run and Gun and Mobile Shot, fire while moving and suffer the hipfire penalty.\n\nThey can be planned <em>without a visible target</em>. If an enemy is revealed during the move, the merc shoots at them. If nobody shows up, the AP for the planned shots is not refunded.\n\nWhen the move ends, the merc stays in Shooting Stance, facing the last target."),
    },
    {
        id = "Shotguns",
        title = T(735216048839, "GBO: Shotguns"),
        text = T(735216048840, "Every pellet of a shotgun blast is simulated. The spread grows with distance: up close most pellets land on the target, while at range only a few do, and stray pellets can hit other units or objects.\n\nDamage is dealt per pellet that hits. Pellets that strike other body parts are penalized less than stray rifle bullets.\n\n<em>Slugs</em> fire a single projectile and behave like a rifle bullet."),
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
        text = T(735216048848, "AP are shown on a finer scale: <em>1 vanilla AP is 10 AP</em>. Costs did not grow, they are just measured more precisely, so small differences between weapons and attachments can show.\n\nBolt-action and pump weapons must be <em>cycled</em> by hand after firing. Higher Dexterity makes this cheaper. If the merc has the AP at the end of the turn, the weapon is cycled automatically."),
    },
    {
        id = "Visibility",
        title = T(735216048849, "GBO: Visibility"),
        text = T(735216048850, "By default, an enemy you spotted stays visible through walls until the end of the turn, like vanilla.\n\nWith the <em>No revealed-enemy memory</em> option, enemies are shown only while one of your units actually sees them, including while they move. The same rule applies to every side.\n\nNight sight and detection can be adjusted in the Mod Options."),
    },
    {
        id = "WeaponInfo",
        title = T(735216048851, "GBO: Weapon Info and Charts"),
        text = T(735216048852, "Weapon stats show the <em>effective value for the merc</em>, with the weapon's base value in grey after it. The bar shows how much the merc's stats help (green) or hurt (red).\n\n<em>More Info</em> on a weapon shows a <em>hit chance chart</em> by distance for the merc's current stance, and a <em>recoil chart</em> for bursts. Holding <em>Shift</em> to compare two weapons draws both on the same chart.\n\nThe weapon modification screen has the same charts and previews how a part would change them before you attach it."),
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

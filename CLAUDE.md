# CLAUDE.md — Rato's Mods — Audit e Diagnóstico

## Estrutura do workspace

### Source do jogo (somente leitura — apenas referência de API)
- `C:\Steam\steamapps\common\Jagged Alliance 3\ModTools\Src`

### Bibliotecas de dependência (somente leitura — apenas referência)
- `C:\Users\Lucas\AppData\Roaming\Jagged Alliance 3\Mods\ja3_commonlib`
- `C:\Users\Lucas\AppData\Roaming\Jagged Alliance 3\Mods\Zulib Weapons Core`

### Mods do autor
- `C:\Users\Lucas\AppData\Roaming\Jagged Alliance 3\Mods\Rato-s-Gameplay-Balance-and-Overhaul-3` — foco principal
- `C:\Users\Lucas\AppData\Roaming\Jagged Alliance 3\Mods\Rato-s-Explosive-Overhaul-2.0`
- `C:\Users\Lucas\AppData\Roaming\Jagged Alliance 3\Mods\Rato-s-ToG-Compatibility-Patch---Rebalance`
- `C:\Users\Lucas\AppData\Roaming\Jagged Alliance 3\Mods\Rato's AI Overhaul`

## O que são estes mods
Conjunto de mods de balance e overhaul para Jagged Alliance 3. Modificam
comportamento de itens, efeitos de personagem, IA e mecânicas de gameplay
via sistema de override parcial do engine — não redefinem entidades inteiras,
apenas os campos que mudam.


## Descrição do mod GBO3

This mod aims to provide a balanced but very challenging experience, improving depth of gameplay, increasing lethality and incorporating some realistic mechanics. Auto fire modes have full bullet damage, and single shots have more chance of critical hit.

Please use a fresh savegame with this mod, so that the components will have their proper effects and to avoid bugs.

It is also recommended to not use an Ironman mode save

It also very important to exit the game completely after selecting all desired mods, and opening it again, to prevent bugs.


Compatibility patches:

NEW - Compatible with Revised Mags II

With ToG. Add Tons of Guns
https://steamcommunity.com/sharedfiles/filedetails/?id=3101203757

If you have ToG and ToC loaded, this mod will use some custom visuals for the added scopes. Recommended

Compatible with Descriptive CTH



Penalties can be customized in mod options

Gun overhaul overview:

Aiming Rework: Mercs with low Hand-Eye Coordination (Dex + Marks) will get less benefits from aim bonus.

Shooting Stance: you need to spend AP to shoulder your weapon to aim. This will create an angle where you can shoot more accurately. If you aim outsde the angle, you must spend AP to rotate. Unaimed shots now have Hipfire penalty. 1 aim level shots have Snapshot penalty. Component weight or barrel length can reduce shooting angle. Inspired by Wax's mod.

Weapons have rotation angles based on real life weight and barrel length.

New mechanics and components permit you to make your weapon into a hybrid: rip the stock off your rifle to make it deadly and fast at close range - like a SMG -, or mount a sniper scope and heavy barrel to have precise single headshots at a distance.

Correct magazine and expanded magazine sizes.

Weapon calibers are realistic, so two weapons with the same caliber will have very similar damage. There is room for variations depending on the class of the weapon or other aspects.

Penetration depends on the caliber.

Weapons classes were changed to dominate a specific range and have a specific function.

Ammo Overhaul:
5.45 rounds now have tumbling effect, which increase critical chance
5.56 rounds have fragmentation effect, which increase critical damage
AP rounds now have decreased critical damage and increased recoil
Match rounds have increased aim, range, and Critical Scaling
Tracer rounds apply Marked, Revealed and are easier to compensate recoil
HP rounds now have increased critical damage (instead of chance)

Gun Stats Info:

Recoil penalty determines how much accuracy degradation your burst attacks will suffer. It also influences the persistant recoil for single shots in a turn.

Hipfire penalty determines the penalty when you shoot with 0 aim levels.

Snapshot penalty determines the easiness of rapidly aquiring new targets. Will apply a penalty when shooting with less than 3 aim levels. If you are attacking the same target as your last attack, this penalty is negated. It is also important for Overwatch and Mobile attacks accuracy.
For these stats, the lower, the better.

New systems based on attributes

New multishot systems

Full damage in all forms of Automatic Fire

New recoil system :

CTH is decreased shot by shot.

Scales with Strength and Marksmanship, different scaling for calibers. All calibers have a Recoil Breakpoint in Str: if you are below this str level the penalties will be even higher per point. It also represents a flat component of the recoil, so the higher the breakpoint, the higher will be the overall penalty to hit.

Only the first bullet will benefit from Aiming bonus.

Autofire: shoots 10 bullets, has fixed AP cost, can be aimed once.

MG burst rework : Shoots 6 bullets. Strength has more impact on determining accuracy of the MG.

Run and Gun reworked: lethal at close range, has big accuracy penalty at distance. The move range depends on agility and bulk of the weapon

Pindown reworked: now it is called Snipe. Grants an attack with maximum aim levels, extra critical chance, reduced penalty to hit body parts and that bypasses low cover. Synergic with scoped weapons that have increased max aim levels.

Shotgun Pellets: Shotguns will fire individual pellets, each ballistically simulated. Added Slug shots as well.

Other changes:

Dual Fire rework: Max aim = 1, AP cost reduced. Dexterity reduces penalty. Higher penalty at distance.

Low Cover effect is increased.

Sight Radius is increased.

Shot Crit bonus: firearms have critical bonus chance that scales with Dexterity+Marksmanship. The effect is based on aim level. Single shot have significant more scaling.

Targeted shot bonus reworked: Applies when fully aimed. Scales with Composure (compost of Marksmanship and Wisdom). Snipers have better scaling. Single shot has better scaling.

Melee range shooting penalty: long barrels make it harder to hit at melee range, while short ones make it easier.

Scope and component overhaul
What really makes a sniper weapon? A precision scope.

Scopes now give a high range bonus. They come in 5 magnification scales. The higher magnification scopes now give a penalty when shooting at close range. The penalty is proportional to the bonus range, and get progressively higher the closer you are to the target.


Stealth overhaul:

Suppressors no longer completely silence your gun, they cut the noise radius by half. To effectively sneak, you need to use Subsonic ammo now, a type of bullet designed to travel slowly and be less loud.

It's harder to do a stealth kill on aware opponents.

Enemy detection range is increased.


Optional Addons (Recommended):

https://steamcommunity.com/sharedfiles/filedetails/?id=3028029624 Wounding Overhaul

https://steamcommunity.com/sharedfiles/filedetails/?id=3253652174 NEW Explosives Overhaul 2.0

https://steamcommunity.com/sharedfiles/filedetails/?id=3087514348 Cash economy customizer


Version: 3.58-12574
## Estrutura típica dos mods
- `Code/` — lógica principal em Lua
- `CharacterEffect/` — efeitos aplicados a personagens
- `InventoryItem/` — modificações de itens de inventário
- `items.lua` — gerado automaticamente pelo jogo, NUNCA editar
- `metadata.lua` — metadados do mod, não editar sem instrução explícita


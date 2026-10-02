# Commands

Every command is typed as `//gs c <command> [arguments]`, from the chat line,
a macro (`/console gs c <command>`) or a key. This page lists the commands
every job shares. Each job's own commands are on its page:
[jobs](../jobs/README.md).

`//gs c help` prints where each system's own help is (`ui help`, `warp help`,
`tb help`, `stealth help`, `cleanse help`...) and `//gs c commands` the built-in list of the
commands below, grouped. Several commands have a short alias, given in
parentheses here.

Commands are not case-sensitive for their first word (`//gs c RF` works). Their
arguments usually are not either, except `wo`: see below.

When two commands share a name, the order is: warp shortcuts and the commands
below, then the job's commands, then Mote-Include's (`cycle`, `set`,
`toggle`, `update`...), and last the dual-box alt commands.

## HUD

| Command | Effect |
|---|---|
| `ui` | Show / hide the keybind HUD |
| `ui on` / `ui off` | Show / hide |
| `ui save` (`ui s`) | Save the position (dragging alone is not saved) |
| `ui header` / `legend` / `columns` / `footer` (`h` `l` `c` `f`) | Show / hide that part |
| `ui font <name>` | Font, e.g. `Consolas` |
| `ui theme <preset>` / `ui theme list` / `ui theme toggle` / `ui theme <r> <g> <b> <a>` | Background (`bg` and `background` work too) |
| `ui order [all\|JOB] <sections>` / `ui roworder [all\|JOB] <states>` | Section / row order, this job by default ([HUD](../features/ui.md#order-of-the-sections-and-rows)) |
| `ui style` | Current look, orders included |
| `ui rollstyle` / `rollorder` / `rollremote` / `roll...` | COR roll messages ([COR](../jobs/cor/states.md#roll-messages)) |
| `ui help` | These options |

## Modes

| Command | Effect |
|---|---|
| `cyclestate <Mode>` | Next value of a mode (what the keys send) |
| `cyclestate <Mode> reverse` | Previous value |
| `cycle <Mode>` / `cycleback <Mode>` | Same, through Mote-Include (prints a chat line) |
| `set <Mode> <Value>` / `toggle <Mode>` / `reset <Mode>` / `unset <Mode>` | Mote-Include |
| `update` | Mote-Include: put your idle or engaged gear back on now (what F12 sends) |
| `am` (`automedicine`) `[on/off]` | Auto Medicine: Echo Drops / Remedy used when a debuff blocks your action. No argument (or any other word) toggles it; the value survives job changes. Its value when the game starts, and the items used, are in `_common/combat/AUTOCURE_CONFIG.lua` ([configuration](configuration.md)). An item used up that leaves the debuff on (an aura keeps it on you) is not tried again for that debuff until the debuff is gone, or 60 s at most |
| `am debuffs` | The buffs on you with their ids (the usual Paralysis is 4; 566 is very likely a geomancy aura's), and the debuffs Auto Medicine no longer uses an item on, with the seconds left |
| `combatmode` | Combat Mode on this job: status; `show` / `hide` its HUD row, key and lock; `key <key>` / `key none`; `help`. See [keybinds](keybinds.md#combat-mode-every-job) |
| `th` | Treasure Mode on this job: status; `show` / `hide`, `key <key>` / `key none`, `clear` (forget the mobs tagged), `help`. THF has it by itself; other jobs start Off and hidden. Needs `sets.TreasureHunter` in the job set file. See [keybinds](keybinds.md#treasure-mode-every-job) |

## Gear and inventory

| Command | Effect |
|---|---|
| `checksets` | Lists set items you do not have in inventory or wardrobes (`STORAGE` = in another bag, `MISSING` = nowhere) |
| `gearscan` | Reads the augments of all your gear, in every bag, and saves them (`saved/gear_augments.lua`) so the HP priority also counts the HP / MP of pieces your sets name without augments, and the HP that some pieces get from their rank (Unmoving Collar +1, Gelatinous Ring +1, War. / Kgt. Beads +2). Run it once, and again after new or upgraded gear; used from the next job load |
| `hporder` | On / off: at each gear change, a block lists the pieces that change, one per line from the first put on to the last, with the HP each gains (green +) or loses (red -) against what you wear. Stays on across job changes until you run it again |
| `wa` (`wardrobeaudit`) | Wardrobe items no set file uses; report written to `data/wardrobe_audit.txt`. Skips the `NEVER_TOUCH` wardrobes of your `WARDROBE_CONFIG.lua` and counts its `KEEP` / `NEVER_MOVE` items as used |
| `wo` (`worganize`) | Wardrobe organizer: moves the gear you use into your used bags, the rest into your other bags, and applies the placement rules of your `WARDROBE_CONFIG.lua` |
| `wo preview` | What it would move, without moving |
| `wo scan` (`scanwarp`) / `wo keep` (`kept`, `items`) | Record the warp items you own / list the items kept in the used bags beyond those your sets name |
| `wo verify` (`check`) | Report what is out of place for the loaded job; nothing moves |
| `wo alt` | Same as `wo` with every job's gear counted as used, on the `USED_WHEN_ALL` / `UNUSED_WHEN_ALL` bags of your config (your usual bags if it has none) |
| `wo global` / `wo global preview` | Same as `wo` / `wo preview` (older names) |
| `wo recover` (`unlock`) / `wo reset` | Release the slots if a run was interrupted / clear a run stuck after a crash and release the slots |
| `rf` (`refill`) | Restock consumables from the Mog Case, Sack and Satchel, put the surplus back, and the items of your other lists that this one does not name (`store_foreign`, [configuration](configuration.md#refill-job_refilllua)); also sent to your other boxes |
| `naked` (or `equip naked`) | Remove every piece. A locked slot (Combat Mode, craft, `gs disable`) keeps its piece |
| `reload` | Reload the job file |
| `ls` (`lockstyle`) | Apply the lockstyle again; also sent to your other boxes |
| `dressup` | Stop / resume unloading DressUp around the lockstyle (kept for next time) |
| `craft [variant]`, `craft off` | Crafting set from the file named in `_common/inventory/CRAFT_CONFIG.lua` (`craft_file`, default `_common/sets/craft_sets.lua`, empty until you fill it; a slot left `""` is not touched). Variants `hq`, `nq`, `success`, and one per sub-craft: `wood`, `smith`, `gold`, `cloth`, `leather`, `bone`, `alchemy`, `cook`. Also applies lockstyle 19 (`craft_lockstyle` in the same file; `false`: the job's lockstyle stays) |
| `fish` (`fishing`) | Fishing set from `_common/sets/fishing_sets.lua` (`fish_file` in the same file; empty until you fill it), lockstyle 17 (`fish_lockstyle`, `false` works the same way) |
| `uncraft` | Leave the craft / fishing set |

`wo` details: it unequips everything and locks your slots while it runs,
then releases them and sends `ls` and `rf`. Its words are lowercase only: an
unknown word (even `Preview`) runs a full organize. The bags and rules it uses come from
`_common/inventory/WARDROBE_CONFIG.lua` ([configuration](configuration.md#wardrobes-wardrobe_configlua));
with nothing set there, wardrobes 1-2 hold the loaded job's gear and your other
unlocked wardrobes the rest, and no wardrobe is protected.

## Travel

| Command | Effect |
|---|---|
| `warp` (`w`) | Warp spell if your job can cast it, else a Warp Ring |
| `w2` (`warp2`) | Warp II on yourself, else a Warp Ring |
| `ret` (`retrace`), `esc` (`escape`) | The spell only |
| `tph` `tpd` `tpm` `tpa` `tpy` `tpv` | Teleport-Holla / Dem / Mea / Altep / Yhoat / Vahzl, else the matching ring |
| `rj` `rp` `rm` | Recall-Jugner / Pashh / Meriph |
| `sd` `bt` `wd` `jn` `sb` `mh` `rb` `kz` `ng` `tv` `au` `ns` `ad` `op`... | Destination items (nation earrings, outpost rings, Adoulin rings...) |
| `<command>all`, e.g. `warpall` | The same on every GearSwap instance of this PC |
| `warp fix` | Release the ring slot and put your gear back |
| `warp help` / `warp status` | Help / state of the warp system |
| `mount` | Random mount you own, or dismount |

## Combat helpers

| Command | Effect |
|---|---|
| `waltz` | Curing Waltz on `<stpc>`: the tier comes from the missing HP of your current target when it is you or a party member, else the highest you can use. DNC main or sub. Where each tier starts: `waltz_from` in `_common/combat/TUNING.lua` ([auto-tier](../features/auto-tier-system.md)) |
| `aoewaltz` | Divine Waltz II, else Divine Waltz. DNC main or sub |
| `lightarts` / `darkarts` | Light / Dark Arts, then the Addendum on the next press. SCH main or sub (without it, your dual-box alt's command of that name if it is on SCH) |
| `aoe sneak` / `aoe invi` / `aoe erase` | The spell on the party through Light Arts and Accession (and Addendum: White for Erase) as charges allow. SCH main or sub |
| `jump` | /DRG jumps |
| `buff` (`buffs`, `buffself`, `selfbuff`, `smartbuff`) | Your self-buffs, every job: DNC main first puts up its dance and samba (see the DNC page), then your main job's list, then your subjob's (not when the subjob is disabled). The lists are `job` and `subjob` in `_common/combat/BUFF_CONFIG.lua` ([configuration](configuration.md)): by default a main job list for BLM, RDM, WHM, PLD, RUN, SCH, NIN, SAM, DRK, MNK and RNG (none for the other jobs; tiers of one buff best first, the first one available goes), and /WAR Berserk, Aggressor, Warcry; /SAM Hasso (two-handed weapon only), Third Eye; /NIN Utsusemi: Ni, else Ichi; /DNC Haste Samba (350 TP); /WHM Reraise. Buffs already up or on recast are listed in chat, what your jobs cannot use is skipped quietly; the rest goes one action after the other. A buff with less than 10 % of its time left is cast again (`refresh_below`; Stoneskin is cancelled first, Cancel addon). A debuff landing while the list runs: asleep, petrified, stunned, terrified or charmed stops the list; Paralysis is cured first (Paralyna when you can cast it now, else a Remedy) and the list goes on; Silence: Echo Drops or Remedy first, else the spells left are dropped and the abilities go on; Mute / Omerta: the spells left are dropped; Amnesia: the abilities are skipped. One cure try per debuff per press. No list for your jobs: a warning naming the file |
| (state) | Jump Auto (`JumpAuto`, **Off**, On), key `!numpad-` (Alt+Numpad-) unless your job's keybind file gives one; its HUD row and key show on /DRG only. On: a weaponskill pressed under 1000 TP is held back, Jump (then High Jump if TP is still short) goes out, then the weaponskill is sent again. Every job |
| `watchdog` | Midcast watchdog status; `on`, `off`, `buffer <s>`, `fallback <s>`, `clear`, `stats`... see [watchdog](../features/watchdog.md) |
| `debugmidcast` | Print which midcast set each spell uses (again to stop) |

## Dual-box

| Command | Effect |
|---|---|
| `alts on` / `off` / `toggle` | Automation on / off for every other character of the group |
| `alts follow` / `follow <name>` / `follow off` | Alts follow you (press again to stop) / follow that character / stop |
| `alts mirror` | Mirror request |
| `alts do <console command>` | Send any console command to every alt |
| `alts window` | Show / hide the alt window (main only) |
| `alts help` | Help of the `alts` orders |
| `main` | This character becomes the main; the others become its alts |
| `altcmds [word]` (`altlist`) | Commands the alt can do on its current job |
| `alt <name> [args]` | Run an alt command even when a local command has the same name |
| `<name>` | An alt command, when no local command has that name |
| `altsync`, `altbuffs`, `altdebug` | Alt buff reports: ask again / show / trace |
| `sortie ...` | Sortie orders: your stance for a target, and a Silmaril profile for your alt. Exists only on a character that has `_common/combat/SORTIE_CONFIG.lua` (the author's, Tetsouo's, is the example: his alt, targets, stances); without it the command says it is not set up and the help does not list it. With Tetsouo's file, on PLD it also sets Phalanx SIRD (Off for `aminon` / `aminontest`, On for every other target) and `sortie escort` turns Regen On, only with /SCH as subjob |

The boxes also send each other commands you never type: `altjobupdate`,
`requestjob`, `setalt`, `altbuff`, `altbuffsync`, `altreport`, `altmirror`,
`altlead`, `rollshow`. They are listed on the developer page
[commands-and-debug](../../dev/systems/commands-and-debug.md).

See the [dual-box guide](dualbox.md).

## Sneak and Invisible

| Command | Effect |
|---|---|
| `stealth sneak` / `invi` / `both` | Sneak / Invisible on you and on every other character of the group, each with its best way (Alt+Z / Alt+X) |
| `stealth sneak self` (`invi self`, `both self`) | You only, at once |
| `stealth check` | What the key would do now, and why; nothing is cast |
| `stealth status` | Settings and time left on each character |
| `stealth refresh <s>` / `alert <s>` / `delay <s>` | Recast below `<s>` seconds left / warn `<s>` seconds before it wears off / pause after each action |
| `stealth overwrite on` / `off`, `stealth alerts on` / `off` | Cast again whatever time is left / wear-off warnings |
| `stealth help` | Help |

See [Sneak and Invisible](stealth.md).

## Cleanse

| Command | Effect |
|---|---|
| `cleanse` | Debuffs off you and every other character of the group: each uses its own spell, else asks a partner, else an item |
| `cleanse self` | You only |
| `cleanse check` | What it would do now, per debuff; nothing is used |
| `cleanse help` | Help |

The boxes also send each other `cleanse local`, `cleanse cast` and
`cleanse report`. See [Cleanse](../features/cleanse.md), settings in
`_common/combat/CLEANSE_CONFIG.lua`.

## Temporary keys

`tb` binds a key from the chat line: `tb <key> <action> [target]`,
`tb list`, `tb del <key>`, `tb clear`, `tb help`. See
[keybinds](keybinds.md#temporary-keys-gs-c-tb).

## Information and diagnostics

`keyconflicts` (`kc`): every key conflict this job can meet, on every subjob
and partner job ([HUD](../features/ui.md#key-conflicts)).

| Command | Effect |
|---|---|
| `info <name>` | Job ability, spell or weaponskill details (`info help`) |
| `jamsg` / `spellmsg` / `wsmsg` `[full / on / off]` | How much chat abilities / spells / weaponskills print: full details, name only, or nothing; no argument = show the current mode (saved per character) |
| `syscheck` (`sc`) `[export]` | Health check of the loaded systems |
| `fulltest` (`ft`) `[export]` | Longer check (systems, modules, hooks, sets) |
| `debugsubjob` (`dsj`) | Main / sub job, levels and zone |
| `debugstate` (`ds`) | Internal counters |
| `commands` (`cmds`) | The built-in list of commands, grouped |
| `help` (`?`) | Where each system's own help is (`tb help`, `stealth help`, `combatmode help`...) |
| `dw` [`auto` \| `none` \| `haste` \| `haste2` \| `max`] | Dual Wield tier: estimated magic haste and its sources, tier, `sets.DW.<tier>` used; a word forces a tier, `auto` goes back to the estimate (`_common/combat/DW_CONFIG.lua`) |
| `belt` | Obi / Orpheus: automatic on or off, belts found, today's day and weather, what each belt adds now (`_common/combat/ELEMENTAL_BELT.lua`) |
| `atelier` / `atelier on` / `atelier off` | Write the loaded job's sets, keys, modes, macro book and lockstyle for the **Atelier** page: open `data/atelier.html` in your browser (it opens on the first character exported; the bar at the top holds the character, the job (the played ones, by role) and the subjob as menus, with the macro book, lockstyle and export date; each block of results is its own compartment with a coloured title band). On a job: sets as a list with a search box, each set shown as the game's 16 square equipment cells with the item icons (name, stats, augments on hover), its stats beside it and, under it, what the set's gear brings (every piece's stats added up from the game's descriptions and the set's augments, grouped: defense with DT+PDT and DT+MDT against the -50 % cap, attributes, combat with Haste against its 25 % gear cap, magic with Fast Cast against 80 %; a piece the set names without augments counts the ones `//gs c gearscan` read on your copy, a Path piece the stats of the rank gearscan read, Fast Cast hidden behind "Enhances \"Fast Cast\" effect" (Loquacious Earring, Prolix Ring, Orunmila's Torque) is counted; Set/latent/Unity effects are listed, not counted. Run `//gs c gearscan` after new or upgraded gear, then export again). Live link: GearSwap opens it at every load, for every character (`//gs c atelier live off` closes it for one character, `//gs c atelier live` opens it again); while the game runs, GearSwap answers the page on 127.0.0.1 (your PC only): the top bar shows "In game · PLD/DRG", the loaded job's data comes straight from the game (no export needed), and Save writes through the game and reloads GearSwap, no folder to pick. Two buttons beside "In game": Reload (`//gs reload`) and Restart the addon (`//lua r gearswap`; the page reconnects by itself, a new door may take another port). Simulate tab (live link): pick a spell, ability or weaponskill of the job; your own GearSwap plays it dry (precast, midcast, after the action) with the target (the action's own by default), status and modes you choose, and the page shows the gear of each step with the set it recognises, a table comparing the steps (HP, MP, damage taken, enmity, Fast Cast, SIRD, Cure...) with each change from the step before, the ability a helper fires first (Majesty before a Cure) and the messages your GearSwap printed. "Stats shown" picks the stats of the set stats and of the simulation. Nothing is cast, sent or worn in game; recasts are ignored unless ticked; a weaponskill is tried at 3000 TP. To unload and load GearSwap from the page as well: `//gs c atelier link` installs and loads the small AtelierLink addon (copied from `data/scripts/atelier/AtelierLink/` into Windower's `addons/AtelierLink/`; add `lua load AtelierLink` to Windower's `scripts/init.txt` to load it with the game). It keeps answering while GearSwap is unloaded: the top bar then offers Unload, and "Load GearSwap" once it is unloaded. Keys tab: click ✎ to change a key (pressed on your own keyboard, any layout), Save writes `<YourName>/saved/keybind_overrides.lua`, laid over your key files at the next load (see the keybinds guide). Trying pieces: click a slot, the drawer lists your copies the job can wear (each with its own augments and where it is: wardrobes, Mog House bags, Porter slips; grouped: the set's piece, your other sets, the rest of your bags, the pieces a set names that your bags do not hold; tick "Every item in the game" to add every other item your job can wear in that slot, best item level first, written by the export into `data/atelier/catalog.js`), click one and the slot turns blue, the set stats and your stats follow, the differences then compare to the set as written; "Copy as Lua" gives the `set_combine` to paste in your sets file, "Test in game" writes the tried pieces into `<YourName>/saved/set_overrides.lua` (laid over your set files at the next load: `//gs reload` or change job; your set files are not rewritten, "Back to the file" or deleting the file undoes it), "Undo all" puts the set back. Clicking a slot lists your pieces for the job, grouped (the set's piece, your other sets, the rest of your bags, the pieces a set names you do not hold), the closest to what the set is after first (a line at the top says what that is: for a weaponskill, its attributes, Weapon Skill Damage weighed by the share of its first hit, multi-attack, critical hits for a critical weaponskill, Attack or PDL depending on the Target window's attack cap); pieces of no use for that set (level below 99 with no item level, old armour, none of the stats it is after, or far below the best piece) are folded with their reason, never a piece that lowers damage taken or one you wear in a set of the same kind. A rank piece below its top rank (Odyssey R25 of R30) or an Ambuscade cape short of a material shows a chip: click it (or Shift+click the row) to try it at its best, hold Shift while hovering to see those stats. "Filter stats" picks the stats shown everywhere (set stats, Compare, a piece's card), their order (by group, what the set is after first, A to Z), "only what the set is after", and saves named filters. A capped stat shows the cap, its total and what goes past it (DT+PDT, DT+MDT with Shell, Haste, Fast Cast...). In the buff window, your job's abilities and your subjob's are offered by level (your subjob's level: 49, +1 per 5 Master Levels), a party WAR's Warcry (its +500 TP Bonus counts in the TP steps) and Blood Rage too; Warcry and Blood Rage overwrite each other. A weaponskill set's TP line offers the steps where your TP bonus reaches 2000 or 3000 (each says what it is on hover) and the TP the weaponskill opens with, as your GearSwap works it out. Each set has two drafts, A and B (switch with the A / B buttons; a dot marks a draft that holds pieces); "Compare" shows your file, what the game wears while testing, and each draft side by side, the pieces and gear stats that differ. "Push to GearSwap" (game running) writes the set into your set file itself: it first shows the set's lines before and after, warns about a piece not in your bags or only in a slip or Mog House bag (GearSwap equips from the inventory and wardrobes only) and about the sets built on this one that will take the pieces too; only that set's lines change, a piece your file already names through a variable (`Nyame.feet_b`) is written with it, a piece the base set already gives is left to inheritance. The file is copied to `<YourName>/saved/backups/` first, the set leaves `set_overrides.lua`, GearSwap reloads; "History" (beside Open all / Close all) lists every push and undoes one while the file is still as that push left it (`<YourName>/saved/set_push_history.lua`). Weaponskill damage and optimizer (needs the damage engine, the `atelier-engine` folder, on this PC): a weaponskill set shows its average damage (wsdist's formulas, at the TP chosen, with your ticked buffs and target), Compare shows it per column, and "Optimise this WS" looks in your bags for the best piece of every slot (weapons kept, the TP pieces of your TP config left to its rule, never written in the set): objective damage at the TP chosen, average damage from 1000 to 3000 TP, or TP return; floors DT+PDT (default -50), DT+MDT without Shell (default -21, so -50 with Shell V) and Subtle Blow; the result goes to draft B, then Compare opens. Simulate: while pieces are in test and not pushed, an action runs twice, as GearSwap wears it now and as your set files have it, with what differs. Buffs and conditions (right column, folded): food, Protect / Shell / Haste / Storm II, four songs with Songs+, two rolls with their number and Rolls+, Indi / Geo bubbles with Geomancy+, your job's and subjob's abilities (Berserk, Aggressor, Defender, Last Resort, Hasso, Swordplay, Rampart, Sentinel, Crusade, Cocoon, Haste Samba) and the target (Apex mobs, BG-Wiki reference); IzaKastra's values (wsdist buffs.py) and the Paladin guide's; your in-game measure already holds the buffs you had then, so measure without buffs. Results under your stats: Tanking (a hit, a spell and a breath of 1000 after DT / PDT / MDT with Shell, PDT II / MDT II up to -87.5 %, Magic Defense Bonus and Rampart; Enmity with its multiplier, capped at x3, and Flash CE / VE on PLD / RUN; Phalanx from your enhancing skill on PLD / RUN / RDM) and Offense (total haste: gear 25 %, magic 43.75 %, abilities 25 %; TP per hit from the weapon delay, Dual Wield and Store TP; hits to 1000 TP; attack round; hit rate against the target, capped at 99 % or 95 % with a two-handed weapon or dual wield; DA / TA / QA and critical hits). Merits tab: the general merits and the job's two groups with your levels read in game; change a level to test, it turns gold with a dot and your stats follow (Max HP / MP and STR..CHR move HP, MP, Defense and Attack, Spell Interruption Rate the SIRD), a button goes back to the game values; nothing changes in game. Weapons: the main / sub / range / ammo slots show what your weapon modes put there (a picker per weapon mode, set to the value the job loads with; PLD also offers its Hybrid mode, since `pld/combat/PLD_WEAPONS.lua` gives the stance weapon, the shield per stance and weapon and the grip of a two-handed weapon), a weaponskill's set takes the first weapon of your weapon mode that has that weaponskill's skill (Savage Blade: Naegling), a weapon set shows its own weapon, and a one-piece weapon set no mode names (a shield) fills an empty slot (by default the one your sets use most); the stats count them, PDT II / MDT II included (past the -50 % cap, up to -87.5 %). Accuracy (main hand: 0.75 x DEX + gear + the weapon skill's steps + job traits + job point gifts) and Evasion (0.5 x AGI + gear + evasion skill + traits + gifts), wsdist's formulas, are in that column too. Your stats with the set (right column on a wide screen, under the grid otherwise): HP, MP, Defense, Attack and STR to CHR as the game would show them, with the difference to what you wore; they are measured by `//gs c atelier` in game (your stats then, minus the gear you wore, plus the set's gear), so a job needs one in-game export first (`//gs c atelier on` does it at each job load); the offline export keeps the last measure; clicking a slot opens that piece's panel, hovering it shows its card: STR to CHR on one line, the other stats in two columns, each total preceded by its augment part in ◆ (the set's augments, the scanned ones, a path's rank; the rest is the game's description) and its effects ("Atonement: Enmity +100" and the like are effects of one ability, never counted); the grid marks augmented pieces with ◆ and a piece with a rank (Odyssey, Path gear: the rank `//gs c gearscan` read on your copy) with R25 and the like, the card gives its path and rank, inherited ones greyed, those put by a weapon mode with a gold edge (read from your FFXI files at export, kept in `data/atelier/icons/`) (set name or item; the matching slots are framed, arrow keys move between sets), then keys, modes, macro book and lockstyle. `on`: also after every job load (per character). Every job at once without the game: double-click `Atelier - export all jobs.bat` in the data folder (needs Python 3 and Lua 5.1; the items in your bags stay as your last in-game export saw them; the page says "offline"). One export per subjob (the modes, weapons and WS can depend on it): the page shows the last one played and lets you pick another subjob at the top (macro book, lockstyle and keys of that subjob follow). Buttons for your subjobs (macro book list, lockstyle other than the default), every other subjob in the "Others…" list; a dot marks one with its own modes or keys (PLD/SCH), the others show the main export with their own macro book and lockstyle. The offline export loads every subjob and keeps a file only for those that differ. Files: `<YourName>/saved/atelier/<JOB>_<SUB>.js` |
| `trace on` / `off` / `clear` | Record what the game returns to `<YourName>/trace.log` (keeps recording across restarts until `trace off`). Also writes each load's steps, every file loaded, every command sent, every GearSwap event and a line every second: after a game crash, the last line shows what was going on. Past 10 MB the file becomes `trace.old.log` (send both) |
| `testcolors` (`colors`) | Chat colour codes |
| `perf`, `lagdebug`, `memcheck`, `debugprecast`, `debugjobchange`, `debugupdate`, `automovedebug`, `debugwarp`, `debugmsg`, `testmsg`, `msgtests` | Developer tools, see [commands-and-debug](../../dev/systems/commands-and-debug.md) |

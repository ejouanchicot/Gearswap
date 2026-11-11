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
| `am` (`automedicine`) `[on/off]` | Auto Medicine: Echo Drops / Remedy used when a debuff blocks your action. No argument (or any other word) toggles it; the value survives job changes. Its value when the game starts is in `_common/combat/AUTO_MEDICINE_CONFIG.lua`, the items used in `_common/combat/CLEANSE_CONFIG.lua` (`items`) ([configuration](configuration.md)). An item used up that leaves the debuff on (an aura keeps it on you) is not tried again for that debuff until the debuff is gone, or 60 s at most |
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
| `wo preview` (`dry`) | What it would move, without moving |
| `wo scan` (`scanwarp`) / `wo keep` (`kept`, `items`) | Record the warp items you own / list the items kept in the used bags beyond those your sets name |
| `wo verify` (`check`) | Report what is out of place for the loaded job; nothing moves |
| `lockscan` / `lockscan stop` | Applies in turn every lockstyle set your lockstyle files name (each job's default and by-subjob sets, the craft and fishing ones), about 12 seconds a set, so that the pieces of each are written down (`<YourName>/saved/lockstyle_pieces.lua`), then puts your job's lockstyle back. The Atelier page then knows what you keep for its look. Only `/lockstyleset` is sent |
| `bags` / `bags go` / `bags stop` | Plays the tidy-up plan made in the Atelier page (the **Bags** tab > The plan > **Prepare *n* move(s) for the game**, then **Send to the game**). `bags` shows what is ready and the bags open where you stand, and moves nothing; `bags go` moves them in series of up to 30 through the inventory (as many as it has free slots for, and only items whose bag has room), each series confirmed by the game before the next; `bags stop` stops. It only moves an item from a bag to another: it never drops, sells, sends or uses anything. A worn piece, a full bag, or a Mog House bag outside the Mog House is skipped and said (a Nomad Moogle gives three of them inside its own menu only: by hand, not by this command); you must stand idle; a step the game does not confirm stops the run with the item where it was or in the inventory. Every move is written to `<YourName>/atelier/bag_moves.log` |
| `jobtest [JOB ...] [nosim]` / `jobtest stop` | In the Mog House: changes job by itself to measure how each job loads. Every job you have (or the ones named) with its usual subjob, then three subjobs on your own job, then two main job changes in a row, then back to the job you had; about 30 seconds a step. For each step: the time to load, the time the keys take to land, the checks of `fulltest`, the lockstyle applied, and every ability, weapon skill and spell of the job run through its gear rules without being done (`nosim` leaves that out). Nothing is cast and no item moves. The report goes to `<Character>/atelier/job_test.json` |
| `po` (`porter`) | After a job change, beside a Porter Moogle: runs PorterPacker for the loaded job (`//po`: the other jobs' pieces go to the moogle, this job's come out), then `wo`, the lockstyle and the refill, in one command. You are undressed meanwhile; `//po reset` stops PorterPacker. Without a Porter Moogle within reach, or without the PorterPacker addon, it runs `wo` alone. The Atelier page offers the same as a button (the **Bags** tab, "Get the job ready") when a Porter Moogle is within reach. Needs PorterPacker with its `then` option |
| `wo alt` (`kaories`) | Same as `wo` with every job's gear counted as used, on the `USED_WHEN_ALL` / `UNUSED_WHEN_ALL` bags of your config (your usual bags if it has none) |
| `wo global` / `wo global preview` (`global dry`) | Same as `wo` / `wo preview` (older names) |
| `wo recover` (`unlock`) / `wo reset` | Release the slots if a run was interrupted / clear a run stuck after a crash and release the slots |
| `rf` (`refill`) | Restock consumables from the Mog Case, Sack and Satchel, put the surplus back, and the usable items this list does not name (which ones: `store_foreign`, [configuration](configuration.md#refill-job_refilllua)); also sent to your other boxes |
| `naked` (or `equip naked`) | Remove every piece. A locked slot (Combat Mode, craft, `gs disable`) keeps its piece |
| `reload` | Reload the job file |
| `ls` (`lockstyle`) | Apply the lockstyle again; also sent to your other boxes |
| `dressup` | Stop / resume unloading DressUp around the lockstyle (kept for next time) |
| `craft [variant]`, `craft off` | Crafting set from the file named in `_common/inventory/CRAFT_CONFIG.lua` (`craft_file`, default `_common/sets/craft_sets.lua`, empty until you fill it; a slot left `""` is not touched). Variants `hq`, `nq`, `success`, and one per sub-craft: `wood`, `smith`, `gold`, `cloth`, `leather`, `bone`, `alchemy`, `cook`. Also applies lockstyle 19 (`craft_lockstyle` in the same file; `false`: the job's lockstyle stays) |
| `fish` (`fishing`) | Fishing set from `_common/sets/fishing_sets.lua` (`fish_file` in the same file; empty until you fill it), lockstyle 17 (`fish_lockstyle`, `false` works the same way) |
| `uncraft` | Leave the craft / fishing set. It is the only command that takes the craft shield off: another variant, `fish` or the same `craft` again leaves the shield you wear in place, and while a craft set is on, `wo` waits for `uncraft` |

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
| `waltz` | Curing Waltz on `<stpc>`: the tier comes from the missing HP of your current target when it is you or a party member, else the highest you can use. DNC main or sub. Where each tier starts: `waltz_from` in `_common/combat/SUBJOB_CONFIG.lua` ([auto-tier](../features/auto-tier-system.md)) |
| `aoewaltz` | Divine Waltz II, else Divine Waltz. DNC main or sub |
| `lightarts` / `darkarts` | Light / Dark Arts, then the Addendum on the next press. SCH main or sub (without it, your dual-box alt's command of that name if it is on SCH) |
| `aoe sneak` / `aoe invi` / `aoe erase` | The spell on the party through Light Arts and Accession (and Addendum: White for Erase) as charges allow. SCH main or sub |
| `jump` | /DRG jumps |
| `ja1`, `ja2`... (or `ja 1`) | The ability at that place of your list for the subjob you have now: one macro per place, whatever the subjob (`ja1` = Hasso under /SAM, Sneak Attack under /THF...). Lists by main job (or `all`), then by subjob: `abilities` in `_common/combat/SUBJOB_CONFIG.lua`, empty by default. Target `<me>` for an ability that only targets you, `<t>` otherwise, or `{name = 'Jump', target = '<bt>'}`. Nothing at that place: a warning. `ja` alone (or `ja x`) lists your abilities for the subjob you have now, numbered |
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
| `sortie ...` | Sortie orders: your stance for a target, and a Silmaril profile for your alt. Exists only on a character that has `_common/tools/SORTIE_CONFIG.lua` (the author's, Tetsouo's, is the example: his alt, targets, stances); without it the command says it is not set up and the help does not list it. With Tetsouo's file, on PLD it also sets Phalanx SIRD (Off for `aminon`, On for every other target) and `sortie escort` turns Regen On, only with /SCH as subjob |

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
| `dw` [`auto` \| `none` \| `haste` \| `haste2` \| `max`] | Dual Wield tier: estimated magic haste and its sources, the engaged mode the job took, tier, set used (`sets.DW.<tier>` or the mode's own `sets.DW.<Mode>.<tier>`); a word forces a tier, `auto` goes back to the estimate (`_common/gear/DW_CONFIG.lua`) |
| `support` [`auto` \| `solo` \| `group` \| `full` \| `trust`] | Weaponskill and engaged sets by the support in your party: the tier (Full: a GEO and a BRD or COR; Group: one of them; Solo: none; Trust: all the support there is comes from trusts), the party in your zone with their jobs, and the set versions read; a word forces a tier, `auto` goes back to the party; either re-equips at once |
| `belt` | Obi / Orpheus: automatic on or off, belts found, today's day and weather, what each belt adds now (`_common/gear/ELEMENTAL_BELT_CONFIG.lua`) |
| `dealwatch` / `dealwatch on` / `dealwatch off` | Measuring tool, **off by default**. On: each time a Corsair's Random Deal or Wild Card reaches you, a chat block lists the recast timers it gave back (by the abilities that share each timer, with the time each had left), who used it and how many timers are still waiting; also written to `logs/rolls/random_deal.log`. It reads your character only (turn it on on each box to compare) and is off again after `//lua reload gearswap` |
| `fights` / `fights on` / `fights off` / `fights reset` | Fight tracker, **off by default**. On: a chat block when a fight starts (the mob's level, from one `/check` sent 3 s after you engage, and how many you killed before) and one at each kill (time, your damage, melee and weaponskill hits, average time a kill). `fights` alone shows the session; `on` / `off` is kept for your character (`saved/fights.on`); `reset` starts a new session. Off, nothing is listened to and no `/check` is sent |
| `atelier` / `atelier on` / `atelier off` | Write the loaded job's sets, keys, modes, macro book, lockstyle, bags and measured stats for the **Atelier** page, then open `data/atelier.html` in your browser. `on`: also after every job load (per character); `off`: stop that. Everything the page shows and does: [Atelier page](../features/atelier.md) |
| `atelier live` / `atelier live off` | Open / close the page's live link for this character (GearSwap opens it at every load): while it is open, the page reads the loaded job from the game and writes through it ([live link](../features/atelier.md#with-the-game-running-live-link)) |
| `atelier link` | Install and load the AtelierLink addon (copied from `data/scripts/atelier/AtelierLink/` into Windower's `addons/AtelierLink/`), which keeps answering the page while GearSwap is unloaded; add `lua load AtelierLink` to Windower's `scripts/init.txt` to load it with the game |
| `atelier icons` | Write every equipment icon of the game at once, in the background (the page otherwise gets the icon of a piece you do not hold the first time it shows it, game running) |
| `atelier all` | Write the loaded job's export as `atelier` does (your bags, your measured stats), then ask the Atelier page open in your browser to rebuild the export of every other job from your files (the same as its **Files > Read**, every job and subjob redone). The page must be open and connected to the game; the first time, it asks for the Windower folder. It takes a few minutes. |
| `version` | The GearSwap version installed (`data/VERSION`, written by each release) |
| `upgrade` | Opens the Atelier page on its **update** screen: it shows the version installed and the latest one published on GitHub, what installing it changes, and installs it; a copy of the files it replaces is kept (`data/atelier/update_backup.json`) and one button puts them back. The game must run with AtelierLink (`//gs c atelier link` once): the page downloads, AtelierLink writes the files, then restarts GearSwap. Only the code is replaced (`shared/`, the Atelier, AtelierLink): your character folder (sets, keys, settings) is never touched. Not `update`: that word is Mote's own command, which re-equips your gear |
| `atelier tour` / `atelier tour WAR PLD` / `atelier tour stop` | In the Mog House only: change to each of your jobs in turn (or only the ones named), let GearSwap load it, write its export with your bags and measured stats, then come back to the job and subjob you had. About 15 to 20 seconds a job. Each job is taken with the subjob of its main export when it has one, else the subjob you started on. On the way, the lockstyle, the macro book and the dual-box job exchange are skipped; the last load, back on your job, is a normal one. It stops by itself if you leave the Mog House; `tour stop` stops after the job being exported. The job changes are the packet the game itself sends at the Moogle, sent by GearSwap. |
| `trace on` / `off` / `clear` | Record what the game returns to `<YourName>/logs/trace/trace.log` (keeps recording across restarts until `trace off`). Also writes each load's steps, every file loaded, every command sent, every GearSwap event and a line every second: after a game crash, the last line shows what was going on. Past 10 MB the file becomes `trace.old.log` (send both) |
| `testcolors` (`colors`) | Chat colour codes |
| `perf`, `lagdebug` (`ldb`), `memcheck` (`mem`), `debugprecast`, `debugjobchange` (`djc`), `debugupdate`, `automovedebug` (`amd`), `debugwarp`, `debugmsg`, `testmsg` (`msgtest`), `msgtests` | Developer tools, see [commands-and-debug](../../dev/systems/commands-and-debug.md) |

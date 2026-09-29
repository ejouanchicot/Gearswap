# Commands

Every command is typed as `//gs c <command> [arguments]`, from the chat line,
a macro (`/console gs c <command>`) or a key. This page lists the commands
every job shares. Each job's own commands are on its page:
[jobs](../jobs/README.md).

`//gs c help` prints where each system's own help is (`ui help`, `warp help`,
`tb help`, `stealth help`...) and `//gs c commands` the built-in list of the
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
| `am` (`automedicine`) `[on/off]` | Auto Medicine: Echo Drops / Remedy / Panacea used when a debuff blocks your action. No argument (or any other word) toggles it; the value survives job changes |
| `combatmode` | Combat Mode on this job: status; `show` / `hide` its HUD row, key and lock; `key <key>` / `key none`; `help`. See [keybinds](keybinds.md#combat-mode-every-job) |
| `th` | Treasure Mode on this job: status; `show` / `hide`, `key <key>` / `key none`, `clear` (forget the mobs tagged), `help`. THF has it by itself; other jobs start Off and hidden. Needs `sets.TreasureHunter` in the job set file. See [keybinds](keybinds.md#treasure-mode-every-job) |

## Gear and inventory

| Command | Effect |
|---|---|
| `checksets` | Lists set items you do not have in inventory or wardrobes (`STORAGE` = in another bag, `MISSING` = nowhere) |
| `wa` (`wardrobeaudit`) | Wardrobe items no set file uses; report written to `data/wardrobe_audit.txt` |
| `wo` (`worganize`) | Wardrobe organizer: moves the gear you use into the first wardrobes, the rest into overflow bags |
| `wo preview` | What it would move, without moving |
| `wo scan` (`scanwarp`) / `wo keep` (`kept`, `items`) | Record the warp items you own / list the items kept in the main bags beyond those your sets name |
| `wo verify` (`check`) | Report what is out of place for the loaded job; nothing moves |
| `wo alt` | Variant for a character with 4 wardrobes: every job's sets count, overflow goes to Sack / Case / Satchel |
| `wo global` / `wo global preview` | Same as `wo` / `wo preview` (older names) |
| `wo recover` (`unlock`) / `wo reset` | Release the slots if a run was interrupted / clear a run stuck after a crash and release the slots |
| `rf` (`refill`) | Restock consumables from the Mog Case and Mog Sack, put the surplus back; also sent to your other boxes |
| `naked` (or `equip naked`) | Remove every piece. A locked slot (Combat Mode, craft, `gs disable`) keeps its piece |
| `reload` | Reload the job file |
| `ls` (`lockstyle`) | Apply the lockstyle again; also sent to your other boxes |
| `dressup` | Stop / resume unloading DressUp around the lockstyle (kept for next time) |
| `craft [variant]`, `craft off` | Crafting set from `sets/bonecraft_sets.lua` (not in the public repository: write your own) |
| `fish` (`fishing`) | Fishing set from `sets/fishing_sets.lua` (same) |
| `uncraft` | Leave the craft / fishing set |

`wo` details: it unequips everything and locks your slots while it runs,
then releases them and sends `ls` and `rf`. Its words are lowercase only: an
unknown word (even `Preview`) runs a full organize. The bags it uses come from
`config/WARDROBE_CONFIG.lua` if you have one; otherwise wardrobes 1-2 are the
main bags and 3-6 and 8 the overflow (wardrobe 7 is never touched).

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
| `waltz` | Curing Waltz on `<stpc>`: the tier comes from the missing HP of your current target when it is you or a party member, else the highest you can use. DNC main or sub |
| `aoewaltz` | Divine Waltz II, else Divine Waltz. DNC main or sub |
| `jump` | /DRG jumps |
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
| `sortie ...` | The author's Sortie orders, written for his own pair of characters. On PLD it also sets Phalanx SIRD: Off for `aminon` / `aminontest`, On for every other target; `sortie escort` turns Regen On, only with /SCH as subjob |

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
| `dw` [`auto` \| `none` \| `haste` \| `haste2` \| `max`] | Dual Wield tier: estimated magic haste and its sources, tier, `sets.DW.<tier>` used; a word forces a tier, `auto` goes back to the estimate (`config/DW_CONFIG.lua`) |
| `belt` | Obi / Orpheus: automatic on or off, belts found, today's day and weather, what each belt adds now (`config/ELEMENTAL_BELT.lua`) |
| `trace on` / `off` / `clear` | Record what the game returns to `<YourName>/trace.log` (keeps recording across restarts until `trace off`). Also writes each load's steps, every file loaded, every command sent, every GearSwap event and a line every second: after a game crash, the last line shows what was going on. Past 10 MB the file becomes `trace.old.log` (send both) |
| `testcolors` (`colors`) | Chat colour codes |
| `perf`, `lagdebug`, `memcheck`, `debugprecast`, `debugjobchange`, `debugupdate`, `automovedebug`, `debugwarp`, `debugmsg`, `testmsg`, `msgtests` | Developer tools, see [commands-and-debug](../../dev/systems/commands-and-debug.md) |

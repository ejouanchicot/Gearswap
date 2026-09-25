# Command routing, common commands and debug tooling

Every `//gs c <words>` typed by the player, sent by a keybind, a macro, `send_command('gs c ...')` or the dual-box partner (`send <char> gs c ...`) enters the same pipe: GearSwap hands the whole string to Mote's `self_command`, Mote splits it and calls the job's `job_self_command`, and the job file decides, in a fixed order that differs slightly per job, whether the command is a watchdog, dual-box, UI, common or job-specific command. `CommonCommands` (`shared/utils/core/COMMON_COMMANDS.lua`) owns the ~75 commands that every job shares (warp shortcuts, wardrobe, refill, lockstyle, dual-box group orders, Sortie, temporary keybinds, trace, debug toggles, diagnostics). A name that nothing on the main answers goes to the dual-box alt-command system, which `CommonCommands` installs as the last lookup of Mote's `selfCommandMaps`. The diagnostic handlers live in `DEBUG_COMMANDS.lua` and the tools under `shared/utils/debug/`. This page describes the routing contract, lists every command, and documents what each debug tool measures and writes.

## Files

| Path | Lines | Role |
|---|---|---|
| `shared/utils/core/COMMON_COMMANDS.lua` | 750 | `CommonCommands`: router (`handle_command`), membership tests (`is_common_command`, `runs_locally`), gameplay/utility handlers, installs the alt-command fallback |
| `shared/utils/core/DEBUG_COMMANDS.lua` | 580 | `DebugCommands`: perf, fulltest, syscheck, lagdebug, debugsubjob, jamsg/spellmsg/wsmsg, info, debugstate, memcheck, and the six debug toggles (debugwarp, debugprecast, automovedebug, debugjobchange, debugupdate, debugmsg, moved here 2026-09-25); re-exposed on `CommonCommands` |
| `shared/utils/commands/info_command.lua` | 421 | `//gs c info <name>`: looks a JA / spell / WS up in the project databases and prints its fields |
| `shared/utils/config/config_loader.lua` | 82 | `ConfigLoader.load_ui_config(char, job)`: loads `<char>/config/UI_CONFIG.lua`, sets `_G.UIConfig` and `_G.ui_display_config` |
| `shared/utils/debug/debug_logger.lua` | 87 | `DebugLogger`: one-line flag-gated debug output through `MessageFormatter.show_debug` |
| `shared/utils/debug/full_test.lua` | 305 | `FullTest`: syscheck + module loads + `_G` hooks + `sets` structure, scored, optional file export |
| `shared/utils/debug/global_probe.lua` | 220 | `GlobalProbe`: snapshots `_G`, reports globals created afterwards, reports missing Mote hooks |
| `shared/utils/debug/lag_debugger.lua` | 523 | `LagDebugger`: event journal (frames, stalls, module loads, actions, job changes) kept on `windower._lagdebug`, exported to a file |
| `shared/utils/debug/performance_profiler.lua` | 357 | `Profiler`: load-time checkpoints for `get_sets()` and the job facades, persistent on/off switch file |
| `shared/utils/debug/system_checker.lua` | 334 | `SystemChecker`: 10 runtime health checks, scored, optional per-character export |
| `shared/utils/debug/trace_log.lua` | 127 | `TraceLog`: `//gs c trace`, appends what the game returns to `<Character>/trace.log` (added in `f3c8bee`) |
| `shared/jobs/*/functions/*_COMMANDS.lua` | 155-567 | Per-job `job_self_command`; only the routing contract is covered here (job commands belong to the job pages) |

Related files read to establish behaviour (not owned by this area): `shared/utils/core/WATCHDOG_COMMANDS.lua`, `shared/utils/core/CYCLE_HANDLER.lua`, `shared/utils/ui/UI_COMMANDS.lua`, `shared/utils/dualbox/alt_commands.lua`, `shared/utils/dualbox/alt_group.lua`, `shared/utils/dualbox/dualbox_role.lua`, `shared/utils/keybinds/temp_binds.lua`, `shared/utils/sortie/sortie_commands.lua`, `shared/utils/warp/warp_command_registry.lua`, `shared/utils/core/INIT_SYSTEMS.lua`, `shared/utils/core/module_cache.lua`, and the GearSwap engine (`../gearswap.lua`, `../refresh.lua`, `../user_functions.lua`, `../flow.lua`, `../libs/Mote-SelfCommands.lua`).

## How it works

### 1. Engine and Mote: from `//gs c` to `job_self_command`

1. GearSwap's `addon command` handler (`gearswap.lua:162-166`) takes everything after `c`, runs each word through `convert_auto_trans`/`from_shift_jis`, joins the words with single spaces and calls `equip_sets('self_command', nil, <string>)`. `equip_sets` calls the user function through `user_pcall` (`flow.lua:105`, `318-327`), which catches a Lua error inside the job's handler and re-raises it with a "GearSwap has detected an error in the user function" prefix, so it is printed and the rest of that command is skipped.
2. Mote's `self_command` (`Mote-SelfCommands.lua:9-37`) splits the string on spaces into `commandArgs`, creates `eventArgs = {handled = false}` and calls `job_self_command(commandArgs, eventArgs)`. Nothing is lower-cased by the engine or by Mote: every job file lower-cases only `cmdParams[1]`.
3. If `eventArgs.handled` is still false afterwards, Mote removes the first word and looks it up, case-sensitively, in `selfCommandMaps` (`Mote-SelfCommands.lua:454-465`: `toggle`, `cycle`, `cycleback`, `set`, `reset`, `unset`, `update`, `showtp`, `naked`, `help`, `test`). That is how `gs c update` (sent by AutoMove on each movement) and `gs c cycle X` reach Mote. Once `COMMON_COMMANDS` has loaded (on the first command of each job file load), a name missing from that table is answered by an `__index` that returns the dual-box alt's command of that name, if any (section 4).

### 2. The job-file contract

Every `[JOB]_COMMANDS.lua` defines `job_self_command(cmdParams, eventArgs)` and exports it as `_G.job_self_command`. Each one:

1. returns if `cmdParams[1]` is missing, calls its local `ensure_commands_loaded()` (lazy `require` of `COMMON_COMMANDS`, `WATCHDOG_COMMANDS`, `UI_COMMANDS`, `CYCLE_HANDLER`, `message_formatter`, `message_commands`),
2. computes `command = cmdParams[1]:lower()`,
3. tests a sequence of shared prefixes, each ending with `return`,
4. then tests its own job commands.

The common-command step has the same shape in all 16 files (BST, PUP and SMN also nil-check `CommonCommands`):

```lua
if CommonCommands.is_common_command(command) then
    local args = {}
    for i = 2, #cmdParams do table.insert(args, cmdParams[i]) end
    if CommonCommands.handle_command(command, '<JOB>', table.unpack(args)) then
        eventArgs.handled = true
    end
    return
end
```

`table.unpack` is not Lua 5.1; it comes from Windower's `libs/tables.lua:457`. With no extra arguments it is plain `unpack(t)`, which is what forwarding needs (passing only `cmdParams[1]` would drop every subcommand, e.g. `warp all`). With extra arguments it treats them as keys, not as a start index (see Gotchas).

When `handle_command` returns false the job file still returns, `eventArgs.handled` stays false and Mote tries `selfCommandMaps[cmdParams[1]]`, which finds nothing for any common name (`equip`, a failed `reload`...): the alt fallback refuses every name `CommonCommands.runs_locally` claims, so the command ends silently.

Order of the shared prefixes, per job (line numbers of the `if`):

| Job | altjobupdate / requestjob | watchdog | common | ui | debugmidcast | cyclestate | notes |
|---|---|---|---|---|---|---|---|
| BLM | 256 / 268 | 278 | 288 | 304 | 313 | 332 | |
| BRD | 167 / 179 | 273 | 281 | 187 | 248 | 267 | `forceidle` at 196 before common |
| BST | 157 / 170 | 232 | 243 | 181 | 190 | 221 | `debugprecast` at 202 overrides the common one (toggles `_G.BST_DEBUG_PRECAST`) |
| COR | 101 / 111 | 153 | 161 | 119 | 128 | 147 | |
| DNC | 71 / 83 | 91 | 99 | 112 | 121 | 140 | |
| DRK | 62 / 74 | 84 | 94 | 110 | 119 | 138 | |
| GEO | 114 / 126 | 168 | 176 | 134 | 143 | 162 | |
| PLD | 103 / 115 | 95 | 125 | 141 | 150 | 169 | |
| PUP | 151 / 161 | 211 | 222 | 172 | 181 | 200 | file is a copy of BST_COMMANDS |
| RDM | 165 / 175 | 195 | 203 | 188 | 232 | 251 | 223-226: every raw `selfCommandMaps` name falls to Mote; from 360: an unknown command is cast as a JA/WS/spell name, else left to Mote when `selfCommandMaps` (the alt fallback) answers it, else "Command not recognized" |
| RUN | 92 / 104 | 84 | 114 | 130 | 139 | 158 | |
| SAM | 57 / 69 | 79 | 89 | 105 | 114 | 133 | |
| SMN | 299 / 308 | 348 | 369 | 318 | 327 | 338 | `skillup` at 358 before common |
| THF | 77 / 89 | 103 | 111 | 124 | 133 | 152 | |
| WAR | 91 / 103 | 83 | 113 | 129 | 138 | 185 | |
| WHM | 67 / 79 | 89 | 99 | 113 | 122 | 141 | |

`altjobupdate` passes the sender's name as its 5th word (`cmdParams[6]`) to `DualBoxManager.receive_alt_job` in all 16 files (2026-09-25), so a third box's update is ignored; see [dualbox.md](dualbox.md).

Because `ui`, `watchdog`, `cyclestate`, `debugmidcast`, `altjobupdate` and `requestjob` are not common names, the different orders only matter for names that collide (see Gotchas: `perf`, `testcolors`, `debugprecast`).

### 3. `CommonCommands.handle_command(command, job_name, ...)`

`COMMON_COMMANDS.lua:462-673`.

1. Normalises its input (`466-490`): a string `command` is lower-cased and rebuilt into `cmdParams = {command, ...}`; a table is taken as `cmdParams` directly (no caller passes a table today). `args = cmdParams[2..n]`.
2. Four module commands first, each handed to its own module (`492-511`): `sortie` (`SortieCommands.handle`), `alts` / `main` / `setalt` (`AltGroup.route`), `tb` (`TempBinds.handle`), `trace` (`TraceLog.handle`).
3. Warp (`513-531`): exact match against `warp_command_registry.COMMANDS` (105 aliases), then any name ending in `all` whose base is a warp alias (`warpall`, `sdall`...). Both go to `handle_warp_commands(cmdParams)` (`428-452`), which requires `shared/utils/warp/warp_commands` and returns `WarpCommands.handle_command(cmdParams)`; on load failure it prints a module-by-module diagnostic.
4. One `if/elseif` chain for the named commands (`534-668`, table below).
5. Returns false otherwise. It never sends anything to the alt.

`is_common_command(command)` (`679-727`) repeats the same names as a hand-written `or` chain (`686-705`) and the warp exact and `all` tests (`709-724`). It does not look at the alt's config. The two lists must be kept in sync by hand: a name added to `handle_command` only is unreachable from every job file.

```mermaid
sequenceDiagram
    participant P as "Player / keybind / partner"
    participant GS as "GearSwap (gearswap.lua:162)"
    participant M as "Mote self_command"
    participant J as "job_self_command"
    participant CC as "CommonCommands"
    participant AC as "AltCommands"
    P->>GS: "//gs c wo preview"
    GS->>M: "equip_sets('self_command', 'wo preview')"
    M->>J: "cmdParams = {'wo','preview'}"
    J->>J: "dual-box / watchdog / ui prefixes (order per job)"
    J->>CC: "is_common_command('wo')"
    CC-->>J: "true"
    J->>CC: "handle_command('wo', 'WAR', 'preview')"
    alt "warp alias or *all"
        CC->>CC: "handle_warp_commands(cmdParams)"
    else "named common command"
        CC->>CC: "handler in COMMON / DEBUG_COMMANDS"
    end
    CC-->>J: "true / false"
    J-->>M: "eventArgs.handled"
    M->>M: "if not handled: selfCommandMaps[word]"
    opt "word not a Mote command"
        M->>AC: "__index: runs_locally? is_alt_command?"
        AC-->>P: "send <alt> input /ja|/ma ..."
    end
```

### 4. Alt commands and name shadowing

`AltCommands.is_alt_command(cmd)` (`shared/utils/dualbox/alt_commands.lua:436-446`) is true only on the dual-box MAIN (`_G.DualBoxConfig.enabled` and `role == 'main'`, `get_alt_name`, `106-112`) when `cmd` is a key of the alt's current main-job or subjob config: `<main char>/config/alt/<JOB>_ALT_COMMANDS.lua` merged with `<JOB>_ALT_CUSTOM.lua` (`load_job_config`, `155-258`; each file falls back to its `_master/config/alt/` template when the character has none, 2026-09-25), filtered by the level the alt reported in `_G.AltJobState`, cached per `job/sub/levels` key (`load_config`, `260-293`). Explicit forms: `//gs c altcmds [filter]` / `altlist` lists them, `//gs c alt <name> [args]` runs one and forwards every extra word (`AltCommands.handle`, `492-517`).

A bare `//gs c <name>` reaches the alt only as Mote's last lookup. At module load `COMMON_COMMANDS.lua:745-748` calls `AltCommands.install_fallback(selfCommandMaps, CommonCommands.runs_locally)` (`alt_commands.lua:519-538`), which puts an `__index` on Mote's `selfCommandMaps`. Mote reads that table only when `job_self_command` left the command unhandled (`Mote-SelfCommands.lua:26-35`), and `__index` runs only for names the table lacks, so:

- a job command always keeps its name. Names that exist both as a job command and as an alt key today (job file : alt config): `lightarts` (BLM, GEO, PLD : SCH), `darkarts` (BLM, GEO : SCH), `klimaform` (BLM : SCH), `dispel` (BLM, GEO : RDM, SCH), `entrust` (GEO : GEO), `doubleup` (COR : COR), `fandance` (DNC : DNC), `berserk`, `defender` (WAR : WAR), `thirdeye` (WAR : SAM), `marcato`, `nightingale`, `pianissimo`, `troubadour` (BRD : BRD), and RDM's table-driven `convert`, `chainspell`, `saboteur`, `composure` (RDM : RDM). They run on the main; `//gs c alt <name>` sends the alt's version;
- Mote's own commands (`update`, `cycle`, ...) are never shadowed;
- `__index` also refuses every name `CommonCommands.runs_locally(name)` claims (`COMMON_COMMANDS.lua:735-742`: common names, warp aliases and `<alias>all`, Mote's raw keys), so a common command whose handler fails does not fall through to the alt. Four alt keys are such names: `warp`, `escape`, `retrace` (BLM alt config) and `jump` (DRG alt config); they run only as `//gs c alt <name>`;
- the lookup is case-insensitive (`Haste` works), because `is_alt_command` and `execute` lower-case the name.

The table is rebuilt by Mote on every job file load, and `COMMON_COMMANDS` is required again in each new sandbox on its first command, so the fallback exists from the first command on. RDM's cast-by-name fallback leaves a name unhandled when `selfCommandMaps` answers it (`RDM_COMMANDS.lua:390-393`); the other 15 job files have no catch-all.

`altcmds` / `altlist` / bare `alt` pass `runs_locally` down to `AltCommands.list` (`alt_commands.lua:540-563`), which lists the names `runs_locally` claims apart, under a `//gs c alt <name>` line (`message_alt_commands.lua` `show_shadowed`). It cannot see job-specific commands, so a job command that shares an alt key (the list above) is still shown in the bare form although it runs on the main.

## Commands

### Common commands (`CommonCommands.handle_command`)

Arguments are passed through with their original case unless the handler lower-cases them (noted). The route column names the handler; a bare function name or line number is in `COMMON_COMMANDS.lua`.

| Command (aliases) | Args | Effect | Route |
|---|---|---|---|
| warp aliases: `w warp w2 warp2 ret retrace esc escape tph tpholla tpd tpdem tpm tpmea tpa tpaltep tpy tpyhoat tpv tpvahzl rj recjugner rp recpashh rm recmeriph sd sandoria bt bastok wd windurst jn jeuno sb selbina mh mhaura rb rabao kz kazham ng norg tv tavnazia au wg whitegate ns nashmau ad adoulin stsd stable-sd stbt stable-bt stwd stable-wd stjn stable-jn op outpost cz ceizak ys yahse hn hennetiel mm morimar mj marjami yc yorcia km kamihr wj wajaom ar arrapago pg purgonorgo rl rulude zv zvahl riv riverne yo yoran lf leafallia bh behemoth cc chocircuit pt parting cg chocogirl ld leader td tidal` | `warp status|unlock|lock|fix|test|help|ipctest`, `all` | Warp spell / item / destination; `<alias>all` or `<alias> all` broadcasts to other instances | `handle_warp_commands` -> `warp/warp_commands.lua` `WarpCommands.handle_command` |
| `sortie` | `<target>`, `escort [Indi-X]`, `off`, `judgment`, `fullcircle`, `list` | Stance for this character + Silmaril profile for the GEO alt Kaories. A mode value the job's state does not have prints a warning and the rest still runs (fixed 2026-09-25; before, a Lua error stopped the command) | `sortie/sortie_commands.lua` `SortieCommands.handle` (added in `7a833d4`) |
| `alts` | `on`, `off`, `toggle`, `follow [name|off]`, `do <command>`, `mirror`, `window` | Orders to every other member of the box group (`DualBoxConfig.group`), from either box | `dualbox/alt_group.lua` `AltGroup.route` -> `AltGroup.handle`, see [dualbox.md](dualbox.md) |
| `main` / `setalt <main>` | - / main name | `main`: this box becomes main and sends `setalt <me>` to the others; the role is saved in `<Character>/config/dualbox_role.lua`, and since 2026-09-25 also in each alt's own file when that folder is on this PC | `AltGroup.route` -> `dualbox/dualbox_role.lua` `become_main` / `become_alt` (added in `60aa138`) |
| `tb` | `[force] <key> <what>`, `<what>`, `list`, `del <key>`, `clear`, `help`, `run <key>` | Temporary keybinds. `<what>`: spell/JA/WS/item name (+ target), `//<console command>`, `/<game command>`, or anything else sent as typed | `keybinds/temp_binds.lua` `TempBinds.handle`, parsing in `temp_binds_parse.lua` (added in `7694dd3`), see [keybinds-and-custom.md](keybinds-and-custom.md) |
| `trace` | `on`, `off`, `clear`, none = status | Records what the game returns to `<Character>/trace.log` (see Debug tools) | `debug/trace_log.lua` `TraceLog.handle` (added in `f3c8bee`) |
| `naked` | - | `equip()` every slot to `empty`, prints "All slots cleared." Does not `enable` disabled slots (Mote's own `naked` did) | `handle_naked` (`335-350`) |
| `equip naked` | `naked` (case-insensitive) | Same as `naked`. `equip` alone or with any other argument prints "Usage: //gs c equip naked" and returns true (2026-09-25) | `536-540` |
| `mount` | - | Dismount if riding, else a random owned mount | `handle_mount` -> `mount/mount_manager.lua` `MountManager.toggle` |
| `reload` | - | `JobChangeManager.force_reload(player.main_job, player.sub_job or 'SAM')` -> bumps the debounce counter, `gs reload` | `handle_reload` (`44-56`) -> `core/job_change_manager.lua` `force_reload` |
| `checksets` | - | `EquipmentChecker.check_job_equipment(job_name)` | `handle_checksets` -> `equipment/equipment_checker.lua:449` |
| `wardrobeaudit` (`wa`) | - | `WardrobeAuditor.audit()` | `handle_wardrobeaudit` -> `equipment/wardrobe_auditor.lua:557` |
| `worganize` (`wo`) | `scan`/`scanwarp`, `keep`/`kept`/`items`, `verify`/`check`, `reset`, `recover`/`unlock`, `alt`/`kaories`, `global [preview|dry]`, `preview`/`dry`, none | Wardrobe organizer entry points. Arguments are compared case-sensitively; anything unrecognised (including `Preview`) runs the full `organize()`. A finished run now releases the stance slot locks it broke (Hoxne ammo, THF range; 2026-09-25) | `handle_wardrobeorganize` (`183-226`), see [wardrobe-organizer.md](wardrobe-organizer.md) |
| `refill` (`rf`) | - | `RefillManager.refill()`, then `DualBoxSyncIPC.broadcast('rf')` so the partner refills too | `handle_refill` (`234-250`) |
| `automedicine` (`am`) | `on`/`off` (lower-cased) or none = toggle | Auto use of Echo Drops / Remedy | `handle_automedicine` -> `debuff/auto_medicine.lua` `AutoMedicine.handle_command` |
| `alt`, `altcmds`, `altlist` | `alt <name> [args]`, `altcmds [filter]` | Run / list alt commands; the list puts names that run on the main under `//gs c alt <name>` | `handle_alt_command` -> `dualbox/alt_commands.lua` `AltCommands.handle` |
| `altbuff` | `<buff words...> <0/1>` | Sent by the alt to the main: record a buff going up/down | `557-563` -> `AltBuffReporter.receive` |
| `altbuffsync` | - | Sent by the main to the alt: resend every tracked buff | `564-570` -> `report_all` |
| `altsync` | - | On the main: ask the alt to resync | `571-579` -> `request_sync` |
| `altbuffs` | - | Show what the main believes about the alt's buffs | `580-586` -> `show_state` |
| `altdebug` | - | Toggle buff-report tracing (`windower._alt_buff_debug`), log to `data/altbuff_<char>.log` | `587-597` -> `alt_buff_reporter.lua:88` |
| `craft` | `[variant|off|stop|uncraft]` | Equip / leave a crafting set | `craft/craft_commands.lua:246` |
| `fish` (`fishing`) | `[variant]` | Equip fishing set | `craft_commands.lua:273` |
| `uncraft` | - | Unlock and restore gear | `craft_commands.lua:292` |
| `lockstyle` (`ls`) | - | `select_default_lockstyle()` then `DualBoxSyncIPC.broadcast('ls')` | `handle_lockstyle` (`360-377`) |
| `dressup` | - | `LockstyleManager.toggle_dressup()` (persistent) | `handle_dressup` (`386-397`) |
| `perf` | `start|on|enable`, `stop|off|disable`, `toggle`, other/none = status (lower-cased) | Profiler switch | `DEBUG_COMMANDS.lua:43` |
| `testcolors` (`colors`) | - | Prints chat colour codes 1-509 minus 10, 13, 30, 31, 253-279, 507-508, 14 per row | `handle_testcolors` (`297-329`) |
| `jump` | - | `DRGJumpManager.execute_jump()` | `handle_jump` (`62-72`) |
| `waltz` | - | DNC main or sub only; cancels Saber Dance; `WaltzManager.cast_curing_waltz('<stpc>')` | `handle_waltz` -> `handle_waltz_generic` (`80-106`) |
| `aoewaltz` | - | Same guard; `cast_divine_waltz()` | `handle_aoewaltz` |
| `debugsubjob` (`dsj`) | - | Prints main/sub job + levels, zone id/name | `DEBUG_COMMANDS.lua:135` |
| `debugwarp` | - | Toggles `windower._gs_debug.WARP`, mirrored to `_G.WARP_DEBUG` | `DEBUG_COMMANDS.lua:508` |
| `debugprecast` | - | Toggles `windower._gs_debug.PRECAST`, mirrored to `_G.PrecastDebugState` (read by `BRD_PRECAST.lua`, `RDM_PRECAST.lua`, `RUN_PRECAST.lua`). On BST the job file answers first and toggles `_G.BST_DEBUG_PRECAST` instead | `DEBUG_COMMANDS.lua:516` |
| `automovedebug` (`amd`) | - | Toggles `windower._gs_debug.AUTOMOVE`, mirrored to `_G.AUTOMOVE_DEBUG`. It has its own field because it used to be restored from `UPDATE`, which silently undid the toggle at the next job load | `DEBUG_COMMANDS.lua:532` |
| `debugjobchange` (`djc`) | - | Toggles `windower._gs_debug.JOBCHANGE`, mirrored to `_G.JOBCHANGE_DEBUG` - it has to survive the event it traces; when turning on, prints `_G.JobChangeManagerSTATE` counter/current/target | `DEBUG_COMMANDS.lua:541` |
| `debugstate` (`ds`) | - | Dumps AutoMove, JobChangeManager and UI manager counters | `DEBUG_COMMANDS.lua:260` |
| `debugupdate` | - | Toggles `windower._gs_debug.UPDATE`, copies it to `windower._gs_debug.AUTOMOVE`, mirrors both to `_G.UPDATE_DEBUG` / `_G.AUTOMOVE_DEBUG`; restored on every load by `INIT_SYSTEMS.lua:35-41` | `DEBUG_COMMANDS.lua:557` |
| `fulltest` (`ft`) | `[export]` | Runs `FullTest`, prints, optionally writes the report | `DEBUG_COMMANDS.lua:73` |
| `syscheck` (`sc`) | `[export]` | Runs `SystemChecker`, prints, optionally writes the report | `DEBUG_COMMANDS.lua:91` |
| `lagdebug` (`ldb`) | `export|exp|e`, `reset|clear|r`, `status|stat|s`, none = toggle (lower-cased) | Lag journal control | `DEBUG_COMMANDS.lua:109` |
| `jamsg` | `full|f`, `on|name|nameonly|name_only|n`, `off|disabled|disable|d`, none = show | JA message mode, saved per character | `DEBUG_COMMANDS.lua:222`, `handle_message_config_generic` (`179`) |
| `spellmsg` | same | Spell message mode (`spell_mode`, read by every spell family including Enfeebling) | `DEBUG_COMMANDS.lua:230` |
| `wsmsg` | same plus `tp|tponly|tp_only|t` (= `on`) | WS message mode | `DEBUG_COMMANDS.lua:237` |
| `info` | `<name words...>` | JA / spell / WS details | `DEBUG_COMMANDS.lua:248` -> `commands/info_command.lua` `InfoCommand.handle` |
| `debugmsg` | - | Prints `_G.MESSAGE_SETTINGS.spell_mode/ja_mode/ws_mode` | `DEBUG_COMMANDS.lua:568` |
| `testmsg` (`msgtest`) | `[job|system]` | `messages.test(filter)` | `648-654` |
| `msgtests` | - | `MessageValidator.run_all_tests()` | `655-659` |
| `memcheck` (`mem`) | ignored | `_G` survey written to a file, summary in chat | `DEBUG_COMMANDS.lua:467` |
| `commands` (`cmds`) | - | `MessageCommands.show_commands_list()` | `662-664` |
| `help` (`?`) | - | `MessageCommands.show_help()`; shadows Mote's `help` | `665-667` |
| any alt-config key no local command answers | `[args]` | Sent to the alt by Mote's `selfCommandMaps` fallback (see section 4) | `alt_commands.lua` `install_fallback` |

### Shared commands handled in the job files

| Command | Args | Effect | Handler |
|---|---|---|---|
| `altjobupdate` | `<job> <sub> [main_lvl] [sub_lvl] [sender]` | Record the alt's job (sent by the partner). An update whose sender is not this box's partner is ignored; no sender (older format) is accepted | `DualBoxManager.receive_alt_job` (every job file) |
| `requestjob` | - | Reply with this character's job | `DualBoxManager.handle_job_request` |
| `watchdog` | none = status; `on`, `off`, `toggle`, `debug`, `buffer <n>`, `fallback <n>`, `clear`, `test [spell] [id]`, `stats` | Midcast watchdog control; sets `eventArgs.handled` itself | `WATCHDOG_COMMANDS.lua:36-99` |
| `ui` | none = toggle; `h|header`, `l|legend`, `c|columns`, `f|footer`, `s|save`, `on|enable`, `off|disable`, `font <name>`, `bg|background|theme <preset|toggle|list|r g b a>`, `help|?` | Keybind HUD | `UI_COMMANDS.lua:26-94`, see [ui-overlay.md](ui-overlay.md) |
| `cyclestate` | `<StateName> [reverse|backwards|r]` (`^[%w_]+$`) | HUD visible: Mote's `handle_cycle` without its chat line (`job_state_change(description, new, old)`, then `handle_update({'auto'})`, which runs `job_update` and refreshes gear), then a HUD repaint. HUD hidden: `send_command('gs c cycle <State>[ reverse]')` so Mote prints its message | `CYCLE_HANDLER.lua:90-130` |
| `debugmidcast` | - | `MidcastManager.toggle_debug()` + confirmation | every job file, see [midcast-and-buffs.md](midcast-and-buffs.md) |

Mote-native commands that still reach Mote: `update`, `toggle`, `cycle`, `cycleback`, `set`, `reset`, `unset`, `showtp`, `test`. `naked` and `help` are answered by `CommonCommands` first. BLM answers `cycle Storm` itself (`BLM_COMMANDS.lua` `handle_blm_standard_cycles`), so that one never reaches Mote on BLM.

## Public API

### CommonCommands (`COMMON_COMMANDS.lua`, returned module, no `_G` export)

| Function | Line | Notes |
|---|---|---|
| `handle_command(command, job_name, ...)` -> boolean | 462 | Router. Callers: the 16 job files. `job_name` is used only by `reload` and `checksets` |
| `is_common_command(command)` -> boolean | 679 | Callers: the 16 job files, `runs_locally`. Common names and warp aliases only |
| `runs_locally(name)` -> boolean | 735 | True for common names, warp aliases and raw `selfCommandMaps` keys. Passed to `AltCommands.install_fallback` and `AltCommands.handle` |
| `handle_reload(job_name)` | 44 | |
| `handle_jump()` | 62 | |
| `handle_waltz()`, `handle_aoewaltz()` | 109, 115 | |
| `handle_mount()` | 123 | |
| `handle_checksets(job_name)` | 139 | |
| `handle_wardrobeaudit()` | 155 | |
| `handle_wardrobeorganize(arg, arg2)` | 183 | |
| `handle_refill()` | 234 | Broadcasts `rf` |
| `handle_automedicine(arg)` | 259 | |
| `handle_alt_command(cmd, args)` | 277 | |
| `handle_craft`, `handle_fish`, `handle_uncraft` | 288-290 | Aliases of `CraftCommands.*` |
| `handle_testcolors()` | 297 | |
| `handle_naked()` | 335 | |
| `handle_lockstyle()` | 360 | Reads global `select_default_lockstyle`; broadcasts `ls` |
| `handle_dressup()` | 386 | |
| `handle_perf`, `handle_fulltest`, `handle_syscheck`, `handle_lagdebug`, `handle_debugsubjob`, `handle_jamsg`, `handle_spellmsg`, `handle_wsmsg`, `handle_info`, `handle_debugstate`, `handle_memcheck`, `handle_debugwarp`, `handle_debugprecast`, `handle_automovedebug`, `handle_debugjobchange`, `handle_debugupdate`, `handle_debugmsg` | 404-420 | Aliases of `DebugCommands.*` |
| `handle_warp_commands(cmdParams)` | 428 | |

No `handle_*` function is called from outside `handle_command` (repo-wide grep including `Tetsouo/` and `Kaories/`).

### DebugCommands (`DEBUG_COMMANDS.lua`, returned module)

`handle_perf(action)` 43, `handle_fulltest(action)` 73, `handle_syscheck(action)` 91, `handle_lagdebug(action)` 109, `handle_debugsubjob()` 135, `handle_jamsg(mode)` 222, `handle_spellmsg(mode)` 230, `handle_wsmsg(mode)` 237, `handle_info(args)` 248, `handle_debugstate()` 260, `handle_memcheck(arg)` 467, `handle_debugwarp()` 508, `handle_debugprecast()` 516, `handle_automovedebug()` 532, `handle_debugjobchange()` 541, `handle_debugupdate()` 557, `handle_debugmsg()` 568. The five persistent toggles share the local `flip_debug(key)` (`500-504`). Only caller: `COMMON_COMMANDS.lua:404-420`.

### InfoCommand (`info_command.lua`)

`InfoCommand.handle(args)` (388): joins `args` with spaces; `search_all_databases(name)` (325) tries `DataLoader.get_ability/get_spell/get_weaponskill` with the exact name, then scans `_G.FFXI_DATA.<kind>` case-insensitively. Each `DataLoader.get_*` loads its complete database on first use (`data_loader.lua:272-300`), in the order abilities, spells, weaponskills, stopping at the first hit: an ability name loads one database, a weaponskill or unknown name loads all three, and they stay in `_G.FFXI_DATA` for the rest of the environment. Output goes through `MessageInfo` (`formatters/ui/message_info.lua`); JA recast/duration are seconds, spell recast/duration/cast time centiseconds (`format_time`). Since 2026-09-25 a spell shows Target, Magic, Tier, Jobs (one level per job) and Notes, the fields the data has; the wyvern commands are found (the loader reads the `<job>_pet_commands` files); and `sanitize_ascii` converts UTF-8 punctuation before stripping what is left.

### ConfigLoader (`config_loader.lua`)

`ConfigLoader.load_ui_config(char_name, job_name)` -> table (33). `dofile(windower.windower_path .. 'addons/GearSwap/data/' .. char_name .. '/config/UI_CONFIG.lua')` inside `pcall` (43-47); on failure a fallback table (51-59) and `MessageCore.show_config_error`. Writes `_G.UIConfig` (63) then requires `shared/config/ui_settings` and writes `_G.ui_display_config` from its getters (66-73). Callers: module level of every entry file (`_master/entry/Tetsouo_*.lua`, `_master/Kaories/entry/*.lua`, live `Tetsouo/*.lua`, `Kaories/*.lua`), e.g. `_master/entry/Tetsouo_BLM.lua:58`.

### DebugLogger (`debug_logger.lua`, returned module)

| Function | Line | Callers |
|---|---|---|
| `log(prefix, message)` | 52 | none in the repository (its last caller, `UI_CONFIG.print_config`, was removed 2026-09-25) |
| `logf(prefix, fmt, ...)` | 60 | `movement/automove.lua:253` |
| `log_if(flag_key, prefix, message)` | 72 | `job_change_manager.lua:104`, `job_sync_watchdog.lua:96`, `automove.lua:250` |
| `logf_if(flag_key, prefix, fmt, ...)` | 82 | `job_change_manager.lua:139,172,179`, `job_sync_watchdog.lua:142,155`, `automove.lua:109,240,328`, `data_loader.lua:146,218,249` |

`_if` variants read `_G[flag_key]` and return immediately when falsy; `MessageFormatter` is required on first real output (38-43). Output is `MessageFormatter.show_debug(prefix, msg)` = `MessageRenderer.send('[prefix] msg', 8)`.

### Profiler (`performance_profiler.lua`, returned module)

`enable()` 87, `disable()` 95, `toggle()` 103, `is_enabled()` 114, `status()` 119, `start(context)` 181, `mark(label)` 194, `finish()` 228, `create_timer(context)` 261, `profile_call(label, func, ...)` 312, `measure(label, block)` 337. Callers: `start/mark/finish` in every entry file's `get_sets()` (e.g. `_master/entry/Tetsouo_WAR.lua:73-138`), `create_timer` at the top of every `*_functions.lua` facade (e.g. `war_functions.lua:22`), `enable/disable/toggle/status` from `DebugCommands.handle_perf`. `profile_call` and `measure` have no caller.

### LagDebugger (`lag_debugger.lua`, `_G.LagDebugger` + returned module)

Control: `start()` 187, `stop()` 220, `toggle()` 229, `reset()` 238, `is_enabled()` 247, `status()` 252, `export()` 476, `log(type, data)` 283 (no caller), `_raw(type, data)` 265. Probes called by other systems, each a no-op unless recording: `on_automove_update` 296 (`automove.lua:256,285,358`), `on_automove_start` 314 (`automove.lua:327`), `on_automove_stop` 321 (`automove.lua:108`), `on_job_change` 329 (`job_change_manager.lua:146`), `on_cleanup` 335 (`job_change_manager.lua:103`), `on_gs_reload` 344 (`job_change_manager.lua:178`), `on_reload_complete` 353 (`INIT_SYSTEMS.lua:86`), `on_prerender_check` 362 (`_master/Tetsouo/entry/Tetsouo_BST.lua:344` and its live copy only), `on_job_update` 376 (`_master/Tetsouo/entry/Tetsouo_{WAR,BST,SMN}.lua` and their live copies only; no generic `_master/entry` template calls it).

### SystemChecker, FullTest, GlobalProbe, TraceLog

- `SystemChecker.run()` 217 -> `{session, results, score, total, passed}`; `display(report)` 257; `export(report)` 283. Callers: `DebugCommands.handle_syscheck`, `FullTest.run` (via `run_system_checks`, `full_test.lua:34`).
- `FullTest.run()` 167; `display(report)` 214; `export(report)` 250. Caller: `DebugCommands.handle_fulltest`.
- `GlobalProbe.snapshot()` 164 (caller: `INIT_SYSTEMS.lua:339-344`, 5.0 s after load); `leaks()` 174 and `missing_hooks()` 204 (callers: `system_checker.lua` `check_global_leaks` / `check_job_hooks`). Exported as `_G.GlobalProbe`.
- `TraceLog.log(tag, fmt, ...)` 78, `TraceLog.enabled()` 99, `TraceLog.handle(args)` 106. `log` is called from the HUD section toggles, `CYCLE_HANDLER`, custom states, temp binds, `message_colors`, the TP bonus and WS precast handlers, the warp item user, THF smartbuff and RDM cast-by-name; each call is a no-op while tracing is off.

## Debug tools

### SystemChecker (`//gs c syscheck [export]`)

Ten checks, each OK = 1, WARN = 0.5, FAIL = 0; score = `floor(sum/10*100)`. The header line also shows job, reload count and AutoMove sequence (`check_session`).

| Check (`system_checker.lua`) | Reads | OK / WARN / FAIL |
|---|---|---|
| AutoMove (`check_automove`, 35) | `_G.DISABLE_AUTOMOVE`, `_G.AUTOMOVE_RUNNING`, `windower._automove_seq` | disabled or running / `false` / `nil` |
| Watchdog (`check_watchdog`, 52) | `_G.MidcastWatchdog.get_stats()` | loaded / not yet loaded (it is loaded 2 s after load) |
| WarpInit (`check_warp`, 67) | `windower._warp_init_done`, else `WarpInit.is_initialized()` | flag set / not initialised / module failed |
| Hook Chain (`check_hook_chain`, 84) | `windower._hook_wraps{ability,ws,midcast}` / `windower._gs_reload_count` | every ratio in 0.5-1.1 / a ratio < 0.5 or no reload yet / a ratio > 1.1 (accumulated wrapping) |
| State.Moving (`check_state_moving`, 112) | `state.Moving` | exists / missing |
| JobChangeMgr (`check_jobchange_manager`, 120) | `_G.JobChangeManagerSTATE` | exists / - / missing |
| UI Manager (`check_ui`, 130) | `_G.ui_manager_state`, `_G.KeybindUI` | loaded / > 3 consecutive failures or not loaded |
| LagDebugger (`check_lagdebugger`, 150) | `_G.LagDebugger`, `windower._lagdebug.log` | loaded / - / missing |
| Global leaks (`check_global_leaks`, 178) | `GlobalProbe.leaks()` | none / no baseline yet / list of names |
| Job hooks (`check_job_hooks`, 198) | `GlobalProbe.missing_hooks()` | all 7 present / - / list |

Output: chat (`add_to_chat` 207, then 204 for OK and 167 for WARN and FAIL; allowed for diagnostic tools by `.claude/CODE_QUALITY.md` section 6). Export: `data/syscheck_<player.name>.txt` (`export`, 283-288), one file per character.

### FullTest (`//gs c fulltest [export]`)

Section A = the SystemChecker results; B = `pcall(require)` of 14 modules (the 9 mandatory systems + CommonCommands, MessageEngine, MessageColors, WarpInit, MidcastWatchdog, `CRITICAL_MODULES`, `full_test.lua:47-63`); C = `_G.job_update`, `job_precast`, `job_self_command` must be functions, at least one of `job_midcast`/`job_post_midcast`, count of 4 optional hooks (`run_hook_checks`); D = `sets.precast`, `sets.midcast`, `sets.idle`, `sets.engaged` non-empty tables, plus `sets.precast.WS` (`run_sets_checks`). Export: data/fulltest_report.txt (251), one file shared by all characters.

### LagDebugger (`//gs c lagdebug`)

State lives on `windower._lagdebug` (32-38), which survives `gs reload` and job changes (the `windower` seen by user code is GearSwap's `user_windower` table, created once per addon load, `user_functions.lua:418-423`). While recording:

- Module probe (`install_module_probe`, 67): replaces `_G.require` with a timing wrapper; any call taking >= 1.0 ms is logged as `MODULE_LOAD {path, ms}`. It wraps whatever `require` is current, which after `INIT_SYSTEMS.lua:53-58` is the `ModuleCache` wrapper, so cache hits stay under the threshold.
- Stall probe (`install_stall_probe`, 104): `prerender` listener; counts every frame into `S.frames` (count, total, max, 10 ms buckets capped at 200) and logs `STALL {gap_ms, last_action, last_module}` for frames >= 40 ms.
- Action probe (`install_action_probe`, 146): `action` listener; for the player's own actions records `ACTION {kind, cat}` and remembers `last_action`.
- Probes from other systems: `GS_UPDATE_SENT`, `AUTOMOVE_START/STOP`, `JOB_CHANGE`, `CLEANUP_SYSTEMS`, `GS_RELOAD_SCHEDULED`, `GS_RELOAD_COMPLETE`, `BST_PRERENDER`, `JOB_UPDATE`.

The journal is a ring buffer of 2000 entries (`_max`, 42; `table.remove(S.log, 1)` at 276). On module load with recording on, the three probes are reinstalled and `PROBES_REARMED` is logged (512-520). Export: `data/debug_lag.txt` (482) with header, frame-time statistics and histogram, a legend, and one line per event with its fields sorted; one file shared by all characters.

### Profiler (`//gs c perf`)

Switch persisted as the existence of `data/.profiler_enabled` (`STATE_FILE`, 42; `read_state` / `save_state_*`, 50-72), shared by every character; read into `_G.PERFORMANCE_PROFILING.enabled` when the module first loads in an environment (74-80). Enabling prints a reload hint (`profiler_messages.lua`: "Reload job to see timings"), since `start/mark/finish` and `create_timer` only run while a job file loads. `mark()` prints the time since the previous mark (green < 50 ms, yellow < 100, red), `finish()` the total of `get_sets()` (green < 200, yellow < 300); `create_timer(job)` returns a closure that prints per-module times inside the job facade (green < 5 ms, yellow < 10) and a `TOTAL` line. Output goes through the `PROFILER` message namespace (`shared/utils/messages/data/systems/profiler_messages.lua`).

### GlobalProbe

`snapshot()` stores the set of `_G` keys in `_G.__global_baseline`; `leaks()` returns every string key not in the baseline, not in `EXPECTED` (37-133), not starting with `__`, `job_` or `user_`, and not matching the factory patterns in `GENERATED` (139-143). `missing_hooks()` checks the seven names of `REQUIRED_HOOKS` (197-200): `job_precast`, `job_midcast`, `job_post_midcast`, `job_aftercast`, `job_status_change`, `job_buff_change`, `job_self_command`; all 16 job folders define the 7. On 2026-09-25 `EXPECTED` gained the globals created by `tb`, `trace`, `sortie`, custom states, HP priority, KeybindManager and the alt window, which syscheck used to report as leaks.

### Trace (`//gs c trace`)

`TraceLog` (`shared/utils/debug/trace_log.lua`) appends one line per `TraceLog.log(tag, fmt, ...)` call to `<windower>/addons/GearSwap/data/<Character>/trace.log`: time, `os.clock()`, main job, tag, formatted text (tables expanded one level). It exists to see the values the game really returns, which offline tests cannot show.

- On/off lives in `windower._trace_log_on` and in a marker file `<Character>/trace.on`, read once when `windower._trace_log_on` is nil. The marker makes recording survive `//lua reload gearswap`, which resets the `windower` table.
- `trace on` / `off` set both; `clear` empties the log; every form prints the state and the file path.
- It prints with `add_to_chat` directly (CODE_QUALITY section 6), so it keeps working when the message system is what is traced.
- The file grows without limit while on. A character left with the marker file keeps tracing after every restart (Kaories was, per the 2026-09-25 audit; `//gs c trace off` on that character removes it).

### memcheck, debugstate, debugsubjob

- `memcheck` (`DEBUG_COMMANDS.lua:467`): walks `_G`, groups entries by type, counts each table's direct children, sorts tables by that count, lists `package.loaded` when `package` is visible, writes `data/memcheck_<char>_<job>.txt` (`export_report`, 422-424) and prints three numbers plus the path. Project modules show up under `_G.__require_cache` (see `module_cache.lua`).
- `debugstate` (260): `_G.AUTOMOVE_RUNNING`, `windower._automove_seq`, `_G._automove_sequence`, JobChangeManager counter and lockstyle registry size, UI manager ids and failure count.
- `debugsubjob` (135): `player.main_job/_level`, `player.sub_job/_level`, `windower.ffxi.get_info().zone` and its `res.zones` name. The header comment states its purpose: checking that `sub_job_level` reads 0 in Odyssey Sheol Gaol.

## Configuration

| Read / written | Where | Default / notes |
|---|---|---|
| Warp aliases | `shared/utils/warp/warp_command_registry.lua:24-64` | Single list shared with `warp_ipc.lua` |
| Alt command definitions | `<main char>/config/alt/<JOB>_ALT_COMMANDS.lua` + `<JOB>_ALT_CUSTOM.lua` | Loaded by `alt_commands.lua` `load_job_config` with the MAIN's `player.name`; each file falls back to `_master/config/alt/` |
| Message modes | `<char>/config/message_modes.lua` via `shared/config/message_settings.lua:37-43` | Written by `jamsg/spellmsg/wsmsg`; defaults `on` (`message_settings.lua:104-106`) |
| UI config | `<char>/config/UI_CONFIG.lua` | Fallback in `config_loader.lua:51-59` |
| Profiler switch | `data/.profiler_enabled` | Absent = off |
| Trace | `<char>/trace.log`, marker `<char>/trace.on` | Absent marker = off |
| Report files written | `data/syscheck_<char>.txt`, data/fulltest_report.txt, `data/debug_lag.txt`, `data/memcheck_<char>_<job>.txt`, `data/altbuff_<char>.log` | `windower.addon_path .. 'data/'` |

## State & lifetime

- GearSwap builds a new user environment on every file load (`gs reload`, job change, `gs l`): `refresh.lua:62-183`. `_G` inside project code is that environment (`refresh.lua:149`), so every `_G.*` flag below is reset on each load. The `windower` table seen by project code is the addon-lifetime `user_windower` (`user_functions.lua:418-423`), so `windower._*` fields survive until `//lua reload gearswap`.
- On each file load GearSwap unregisters every event registered through the user `windower.register_event`/`raw_register_event` (`refresh.lua:69-71`, `user_functions.lua:254-282`) and deletes text/prim objects. Scheduled coroutines are not cancelled by the engine.
- `_G` flags toggled by commands: `WARP_DEBUG`, `PrecastDebugState`, `AUTOMOVE_DEBUG`, `JOBCHANGE_DEBUG`, `UPDATE_DEBUG`. Each is written to its own `windower._gs_debug` field by the toggle and copied back into `_G` on every load by `INIT_SYSTEMS.lua:35-41`, so all five survive a job change. `MidcastManagerDebugState` is restored from `windower._midcast_debug` the same way (`midcast_manager.lua`, see [midcast-and-buffs.md](midcast-and-buffs.md)).
- Persistent fields: `windower._gs_debug` (the five toggles), `windower._lagdebug` (journal, probe event ids), `windower._alt_buff_debug` (altdebug), `windower._trace_log_on` (trace), `windower._gs_reload_count` (incremented by `INIT_SYSTEMS.lua:44`, read by syscheck/fulltest).
- Module-level caches that die with the environment: `AltCommandsModule` (`COMMON_COMMANDS.lua:30`), `require_wrapped`/`original_require` (`lag_debugger.lua`), DebugLogger's `MessageFormatter`, Profiler's `M`.
- Events: only LagDebugger registers any (`prerender`, `action`), and only while recording; removed by `stop()` (`remove_event_probes`, 171) and re-registered on load while recording (512-520).
- Load order: job files require `COMMON_COMMANDS` lazily on their first command, which itself requires `message_commands`, `message_formatter`, `warp_command_registry`, `craft_commands` and `DEBUG_COMMANDS` at module level. `lag_debugger` is required by `INIT_SYSTEMS.lua:78-80`, after `ModuleCache.install()` and HP priority. `GlobalProbe.snapshot()` runs 5.0 s after `INIT_SYSTEMS`.

## Interactions

- Called by: every `[JOB]_COMMANDS.lua`; indirectly by AutoMove (`gs c update` passes through `is_common_command` on every movement), by the dual-box partner (`altbuff`, `altbuffsync`, `altjobupdate`, `requestjob`, `setalt`), by craft (`craft_commands.lua:173`, `craft_manager.lua:190` send `gs c rf`), by the wardrobe organizer (`lib/phases.lua:109-110` send `gs c naked`; `wardrobe_organizer.lua:161,164` send `gs c ls` and `gs c rf` after a successful run), by temporary keybinds (`gs c tb run <key>`), and by `CycleHandler` (`gs c cycle <state>`).
- Calls: warp (`warp_commands.lua`), wardrobe organizer/auditor, refill, craft, mount, DRG jump, waltz, lockstyle factory, JobChangeManager, AutoMedicine, dual-box (`alt_commands`, `alt_buff_reporter`, `alt_group`, `dualbox_role`, `dualbox_sync_ipc`), Sortie, TempBinds, TraceLog, message system (`MessageFormatter`, `MessageCommands`, `messages` API, `MessageValidator`), DataLoader.
- Sibling pages: [precast-pipeline.md](precast-pipeline.md) (`debugprecast` consumers), [midcast-and-buffs.md](midcast-and-buffs.md) (`debugmidcast`), [ui-overlay.md](ui-overlay.md) (`ui`, `cyclestate`), [dualbox.md](dualbox.md) (`alts`, `main`, `setalt`, alt commands), [keybinds-and-custom.md](keybinds-and-custom.md) (`tb`, key rules).

## Invariants & gotchas

- Only `cmdParams[1]` is lower-cased by the job files; handlers that compare arguments must lower-case them themselves (`perf`, `lagdebug`, `fulltest`, `syscheck`, `automedicine`, `jamsg`, `trace`, `tb`... do; `wo` does not).
- `table.unpack` is Windower's (`libs/tables.lua:457-470`): `table.unpack(t)` = `unpack(t)`, but `table.unpack(t, 2)` returns `t[2]` only, not `t[2..n]`.
- A common name or a warp alias (and `<alias>all`) always beats a job command checked after `is_common_command`. Before naming a new job command, grep `CommonCommands.is_common_command` and `warp_command_registry.lua`. An alt-config key never beats a job command, but a job command that returns without `eventArgs.handled = true` (WAR's `berserk` when `buff_war` is nil, `WAR_COMMANDS.lua:220-226`) falls through to Mote and so to the alt's command of that name.
- `naked` from CommonCommands does not re-enable disabled slots; slots disabled by `gs disable` keep their gear while the message says all slots were cleared. The wardrobe organizer enables slots before sending it (`wardrobe/lib/phases.lua` Phase 0).
- `refill` and `lockstyle` always broadcast to the dual-box partner, including when triggered by `send_command('gs c rf')` from craft or by the `gs c ls` / `gs c rf` the wardrobe organizer sends when it finishes.
- `debugprecast` has an effect only on BRD, RDM and RUN (the jobs that read `_G.PrecastDebugState`) and toggles a different flag on BST.
- `info` loads the complete ability, spell and weaponskill databases on first use.
- SystemChecker and FullTest print `passed` with `%d` although it can be fractional (a WARN counts 0.5), so "9/10" can accompany a 95 % score. SystemChecker colours WARN and FAIL identically (`STATUS_COLOR`, `system_checker.lua:253`).
- LagDebugger registers its probes with the user `windower.register_event`, which GearSwap wraps in `user_equip_sets` (`user_functions.lua:254-262`, `284-291`): every `prerender` and every zone `action` passes through GearSwap's `equip_sets` while recording. `raw_register_event` (used by `party_tracker.lua` and, since 2026-09-25, `warp_detector.lua`) avoids that wrapper.

## Extending

Adding a common command:

1. Add the handler (in `COMMON_COMMANDS.lua`, or in `DEBUG_COMMANDS.lua` for diagnostics and alias it at `COMMON_COMMANDS.lua:404-420`). A self-contained feature can live in its own module, routed like `sortie`, `alts`, `tb` and `trace` (`492-511`).
2. Add the `elseif cmd == ...` branch in `handle_command` and the same name(s) in the `or` chain of `is_common_command` (686-705). Missing the second step makes the command unreachable.
3. Lower-case every argument you compare; make the no-match path print usage rather than run a mutating default.
4. Check the name against job commands (`grep "command == '<name>'" shared/jobs`), warp aliases and the alt configs.
5. Add it to `MessageCommands.show_commands_list()` (`message_commands.lua:586`).
6. If it creates a global, add the name to `global_probe.lua` `EXPECTED`.

Adding a job command: put it after the common block of the job's `job_self_command`, pick a name that is not a common name, warp alias or `<alias>all`, set `eventArgs.handled = true` on every path and `return`. A name that is also a key in `<char>/config/alt/*.lua` runs locally; the alt's version stays reachable as `//gs c alt <name>`.

Adding a debug flag that must survive a job change: flip it with `flip_debug('<KEY>')` in `DEBUG_COMMANDS.lua` and restore it in `INIT_SYSTEMS.lua:35-41`, as the five existing toggles do.

## Known issues

Open:

- `wo` subcommands are case-sensitive and fall back to a full organize (`COMMON_COMMANDS.lua:190-224`).
- `show_error` called with two arguments drops the message (`DEBUG_COMMANDS.lua:483`, `:571`; `MessageStatus.show_error(message)` takes one).
- Warp load-failure diagnostic probes a moved module path, `shared/utils/messages/message_warp` (now `formatters/system/message_warp.lua`) (`COMMON_COMMANDS.lua:442`).
- Unreachable job branches shadowed by common names: WAR `perf` (`WAR_COMMANDS.lua:193-194`, now commented as unreachable), COR `testcolors`/`colors` (`COR_COMMANDS.lua:309`).
- `GlobalProbe.EXPECTED` whitelists `name` and `x` (`global_probe.lua:115,127`); nothing shows they are real globals.
- syscheck WarpInit check trusts a flag that outlives the environment (`system_checker.lua:69`).
- fulltest_report.txt and `debug_lag.txt` are shared by all characters (`full_test.lua:251`, `lag_debugger.lua:482`).
- `altcmds` cannot tell that a job command shares an alt key, so on WAR with a WAR alt it lists `berserk` in the bare form although `//gs c berserk` runs on the main (`alt_commands.lua:549-553`).
- `automedicine` and `lagdebug` treat any unrecognised argument as "toggle" (`auto_medicine.lua:162-172`, `DEBUG_COMMANDS.lua:115-124`).
- PUP first command per load errors on a missing formatter function, `MessageFormatter.error_pup_module_not_loaded`, and on a missing `shared/jobs/pup/functions/logic/` folder (`PUP_COMMANDS.lua:74-77`).
- The help screen (`MessageCommands.show_commands_list`) does not list `tb`, `trace` or `sortie`.
- `Profiler.profile_call`, `Profiler.measure`, `LagDebugger.log`, `DebugLogger.log` have no caller (`performance_profiler.lua:312,337`, `lag_debugger.lua:283`, `debug_logger.lua:52`).
- `LagDebugger.on_job_update` is wired only in the Tetsouo overlay entries `Tetsouo_{WAR,BST,SMN}.lua` (and their live copies), not in any generic `_master/entry` template.
- A `trace.on` marker left on a character keeps `trace.log` growing across restarts; nothing caps the file.

Fixed:

- `debugjobchange` (and the other toggles) lost on every file load: all five live on `windower._gs_debug` and are restored by INIT (`DEBUG_COMMANDS.lua` `flip_debug`).
- `lag_debugger.lua` comment claiming GearSwap does not unregister data-file events: rewritten (`lag_debugger.lua:105-109`).
- `sanitize_ascii` stripped non-ASCII before mapping UTF-8 punctuation (fixed 2026-09-25).
- Help screen advertised `equip` as an alias of `naked`: it now says `equip naked`, and `equip` alone prints its usage (fixed 2026-09-25).
- `spellmsg` comment saying it excludes Enfeebling (fixed).
- BRD `forceidle` comment naming the warp system as sender: it now says nothing sends it (`BRD_COMMANDS.lua:196-198`).
- `COMMON_COMMANDS.lua` at 796 lines: the six debug toggles moved to `DEBUG_COMMANDS.lua` (750 lines now, fixed 2026-09-25).

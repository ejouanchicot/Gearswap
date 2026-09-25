# Message formatters and utilities

The formatter layer turns "something happened" into coloured chat lines. It is the 34 modules under
`shared/utils/messages/formatters/` (split into `combat/`, `jobs/`, `magic/`, `system/`, `ui/`) plus the
two helpers under `shared/utils/messages/utilities/`: `roll_messages.lua` and `party_messages.lua`.
Game code reaches a formatter in one of two ways: through the facade
`shared/utils/messages/message_formatter.lua` (lazy wrappers, see [messages.md](messages.md)), or
directly with `require('shared/utils/messages/formatters/...')`. Formatters run on demand: when a
precast guard blocks an action, a JA/spell/WS hook announces an action, a `//gs c` command prints
status or help, a keybind file prints its intro, and so on. They register no events, schedule no
coroutines and bind no keys.

This page covers the formatter modules and what they expose. The pipeline beneath them (`api/messages.lua`,
`core/message_engine.lua`, `core/message_renderer.lua`, `message_core.lua`, `message_colors.lua`) is
described in [messages.md](messages.md). The template data files (`data/jobs/*`, `data/systems/*`) are
catalogued in [messages-catalog.md](messages-catalog.md).

Caller counts on this page come from a static scan of `shared/`, `_master/`, `Tetsouo/`, `Kaories/`
and the root `*.lua` files on 2026-09-18, with commented-out calls excluded and string dispatch
(`DEBUG_COMMANDS.lua` `handle_message_config_generic`) resolved by hand: of 553 public formatter
functions then, about 159 had no reachable caller. Since then `message_database` (13 functions)
was deleted (`72e135d`), BRD's two empty-bodied functions and the duplicate
`MessageWarp.show_item_equip_delay` were removed, and three modules were added
(`message_altgroup.lua`, `message_sortie.lua`, `message_tempbind.lua`, 28 functions, all with callers).
Counted again on 2026-09-25 (`grep -cE "^function [A-Za-z_]+[.:]"` over `formatters/` and
`utilities/`): **565** public functions in 36 files. The per-module "dead" lists below were not
re-resolved, only corrected where a caller or function was added or removed. File lines and
functions in the Files table were re-measured on 2026-09-25.

## Files

| Path (under `shared/utils/messages/`) | Lines | Functions | Role |
|---|---|---|---|
| `formatters/combat/message_combat.lua` | 476 | 15 | WS TP/activation, WS validation errors, range error, waltz, spell activation line (MAGIC namespace) |
| `formatters/combat/message_cooldowns.lua` | 334 | 12 (+2 exported helpers) | Cooldown lines, multi-line cooldown/TP blocks, recast helpers |
| `formatters/combat/message_ja_buffs.lua` | 220 | 13 | Generic JA activation line honouring `JA_MESSAGES_CONFIG` |
| `formatters/combat/message_weaponskill.lua` | 148 | 15 | WeaponSkillManager and TP bonus calculator debug/error lines |
| `formatters/jobs/message_blm.lua` | 311 | 23 | BLM cycles, refinement, Arts/stratagem, BLM errors |
| `formatters/jobs/message_blm_midcast.lua` | 108 | 11 | BLM midcast debug trace |
| `formatters/jobs/message_brd.lua` | 513 | 46 | BRD songs, instruments, refinement, BRD errors |
| `formatters/jobs/message_bst.lua` | 593 | 53 | BST ecosystem/broth, pet engage, ready moves, BST errors |
| `formatters/jobs/message_cor.lua` | 39 | 3 | PartyTracker load failures |
| `formatters/jobs/message_drg.lua` | 50 | 4 | DRG jump errors (no caller, see below) |
| `formatters/jobs/message_geo.lua` | 183 | 4 | Indi/Geo cast line with element colour, tier refinement |
| `formatters/jobs/message_rdm.lua` | 169 | 15 | RDM state/help/error lines, Phalanx swap |
| `formatters/jobs/message_rdm_midcast.lua` | 203 | 18 | RDM midcast debug trace |
| `formatters/jobs/message_whm.lua` | 29 | 1 | CureManager load warning (no caller) |
| `formatters/magic/message_buffs.lua` | 60 | 1 | Buff status block for smartbuff managers |
| `formatters/magic/message_debuffs.lua` | 394 | 11 | "Blocked by debuff" lines, auto-cure lines, AutoMedicine toggle |
| `formatters/magic/message_midcast.lua` | 156 | 11 | MidcastManager debug trace |
| `formatters/magic/message_precast.lua` | 135 | 7 | Precast debug trace |
| `formatters/magic/message_songs.lua` | 155 | 10 | Song messages; no caller at all |
| `formatters/system/message_altgroup.lua` | 93 | 12 | `ALTGROUP` lines: `//gs c alts`, `main` / `setalt` roles, alt window toggle |
| `formatters/system/message_equipment.lua` | 179 | 16 | `//gs c checksets` report and checker debug |
| `formatters/system/message_init.lua` | 50 | 4 | INIT_SYSTEMS module load failures |
| `formatters/system/message_sortie.lua` | 135 | 7 | `SORTIE` lines: target box, target list, alt orders, GEO escort |
| `formatters/system/message_system.lua` | 165 | 6 | Job "SYSTEM LOADED" intro box, colour test (SYSTEM namespace) |
| `formatters/system/message_tempbind.lua` | 170 | 9 | `TEMPBIND` lines: `//gs c tb` added / taken / list / help |
| `formatters/system/message_warp.lua` | 748 | 84 | Warp/teleport system: templates, status/help screens, item_user debug |
| `formatters/system/message_watchdog.lua` | 300 | 30 | Midcast watchdog status/debug/test |
| `formatters/ui/message_alt_commands.lua` | 274 | 1 | `//gs c altcmds` listing |
| `formatters/ui/message_commands.lua` | 721 | 59 | Output of common/debug commands, help and command list |
| `formatters/ui/message_dualbox.lua` | 190 | 23 | Dual-box role/job sync/status lines |
| `formatters/ui/message_info.lua` | 103 | 6 | `//gs c info <name>` screen |
| `formatters/ui/message_keybinds.lua` | 119 | 6 | Keybind list and bind errors |
| `formatters/ui/message_status.lua` | 86 | 7 | Generic error/warning/success/info, Mote state line, TP lines |
| `formatters/ui/message_ui.lua` | 191 | 10 | `//gs c ui` feedback, theme list, UI help |
| `utilities/roll_messages.lua` | 516 | 11 | COR Phantom Roll result block, bust, Double-Up, roll list |
| `utilities/party_messages.lua` | 73 | 1 | COR `//gs c party` listing |

## How it works

### Four ways a formatter writes to chat

Every formatter function ends in one of four output paths. Which one a module uses decides whether the
message passes the template engine, whether a mistake raises or prints an error line, and whether the
renderer's toggle/filter/stats apply.

```mermaid
flowchart TD
    CALLER["caller (job module, hook, command handler)"] --> FAC["MessageFormatter facade<br/>message_formatter.lua"]
    CALLER --> DIRECT["direct require of a formatter"]
    FAC --> F["formatter function"]
    DIRECT --> F
    F -->|"A: M.send / M.job"| API["api/messages.lua:53 Messages.send"]
    API -->|pcall| ENG["message_engine.lua:227 format"]
    ENG -->|"ok"| REND["message_renderer.lua:88 send(message, color)"]
    ENG -->|"error"| ERR["renderer.show_error: [MessageSystem ERROR]"]
    F -->|"B: MessageRenderer.send"| REND
    F -->|"C: MessageCore.raw / info / warning / error"| CORE["message_core.lua:75-110"]
    F -->|"D: add_to_chat"| ATC["GearSwap add_to_chat_user<br/>user_functions.lua:383"]
    REND --> ATC
    CORE --> ATC
```

**A. Templates (`M.send(namespace, key, params)` / `M.job(job, key, params)`).** Used by most modules.
`Messages.send` (`api/messages.lua:53-80`) formats inside `pcall`. The namespace picks the data file:
a three-letter upper-case namespace loads `data/jobs/<ns>_messages.lua`, anything else loads
`data/systems/<ns>_messages.lua` (`message_engine.lua:184-190`). An unknown key
(`message_engine.lua:240-245`) or a `nil` parameter (`message_engine.lua:150-155`) raises inside the
pcall and is shown as `[MessageSystem ERROR] Failed to format message NS.key: ...`
(`api/messages.lua:61-67`) instead of stopping the caller. `{name}` tokens that match a colour name in
`COLOR_CODES` (`message_engine.lua:38-68`) become colour codes; every other token is a parameter and is
inserted with `tostring` without being parsed again (`message_engine.lua:147-157`). A parameter whose
value is the text `"{green}"` therefore prints the literal text `{green}`; see Known issues.
`M.send` returns `(true, visible_length)`, which `show_activated` (`message_ja_buffs.lua:52-78`) and
`show_spell_activated` (`message_combat.lua:448-470`) pass back to their callers.

**B. `MessageRenderer.send`.** Signature `send(message, color, options)` (`message_renderer.lua:88`).
Among the formatters only `message_keybinds.lua:82` passes arguments in that order. `message_cooldowns.lua`,
`message_debuffs.lua`, `message_warp.lua`, `message_alt_commands.lua` (all `send(1, text)`) and
`message_rdm_midcast.lua` (`send(CHAT_*, text)`) pass the colour first: 108 single-line call sites
(grep, 2026-09-25). They still print
because GearSwap's `add_to_chat_user` (`GearSwap/user_functions.lua:383-399`) accepts a string first
argument: it takes that string as the text and forces colour 8. For lines that start with an inline
colour code the result looks right. The renderer's own handling is applied to the number instead: the
timestamp option would print `[hh:mm:ss] 1`, and `_stats.by_color` is keyed by the whole message text
(`message_renderer.lua:138`).

**C. `MessageCore`.** `MessageCore.raw(text)` sends on channel 001 (`message_core.lua:108-110`);
`info/success/error/warning` prefix `[MAIN/SUB]` and use colours 121/158/167 and, since 2026-09-25,
`MessageColors.WARNING` (region orange) instead of 205 for `warning` (`message_core.lua:75-100`).
Used by `roll_messages.lua`, `party_messages.lua` and `message_bst.lua` (separator only).

**D. `add_to_chat` directly.** `message_commands.lua` (169 calls), `message_ui.lua` (41),
`message_warp.lua` (38), `message_info.lua` (12), `message_equipment.lua` (8), `message_watchdog.lua`
(6), `party_messages.lua` (5), `message_system.lua` and `roll_messages.lua` (1 each) (grep,
2026-09-25). `.claude/CODE_QUALITY.md` section 6 now allows `add_to_chat` anywhere under
`shared/utils/messages/` (updated 2026-09-25). Paths B and C also end in `add_to_chat`, but path D
bypasses the renderer's toggle and filter as well.

### Namespaces used per module

| Module | Namespace(s) | Other paths |
|---|---|---|
| message_combat | `COMBAT`, `MAGIC` | none |
| message_cooldowns | `COOLDOWNS` (separator only) | B |
| message_ja_buffs | `JA_BUFFS` | none |
| message_weaponskill | `WEAPONSKILL` | none |
| message_blm / _blm_midcast | `BLM` / `BLM_MIDCAST` | none |
| message_brd | `BRD`, `MAGIC` (`show_song_cast_generic`) | none |
| message_bst | `BST` | C (separator) |
| message_cor / drg / geo / rdm / whm | `COR` / `DRG` / `GEO` / `RDM` / `WHM` | none |
| message_rdm_midcast | `RDM_MIDCAST` (separator only) | B |
| message_buffs / debuffs | `BUFFS` / `DEBUFFS` (separators) | debuffs: B |
| message_midcast / precast | `MIDCAST` / `PRECAST` | none |
| message_songs | `SONGS` | none |
| message_altgroup / sortie / tempbind | `ALTGROUP` / `SORTIE` / `TEMPBIND` | none |
| message_equipment / init | `EQUIPMENT` / `INIT` | equipment: D |
| message_system | `SYSTEM` | D (colour sample) |
| message_warp | `WARP` | B, D |
| message_watchdog | `WATCHDOG` | D (headers) |
| message_alt_commands | none | B |
| message_commands | `COMMANDS` | D |
| message_dualbox / keybinds / status / ui | `DUALBOX` / `KEYBINDS` / `STATUS` / `UI` | keybinds: B; ui: D |
| message_info | none | D |
| roll_messages / party_messages | none | C, D |

Templates that no formatter uses (static scan of `M.send`/`M.job` keys): all of `SONGS` is only
used by the dead `message_songs.lua`; `INFO` (6 keys) is unused because `message_info.lua` writes with
`add_to_chat`; `COMMANDS` `testcolors_*`, `detectregion_*`, `region_detection_failed`,
`debugsubjob_header`, `debugsubjob_instructions` and the `*_status_header` / `*_current_mode` keys are
unused because `message_commands.lua` builds those lines itself; `EQUIPMENT` `check_header_*` and
`summary_*`; `KEYBINDS keybind_line`; `SYSTEM colortest_sample`; `WATCHDOG stats_header`. The
unused `UI.separator`, `WATCHDOG.status_header` and `BRD.honor_march_locked/released` were deleted on
2026-09-25. The catalogue page owns the data side.

### Lazy loading and module identity

The facade caches each formatter in an upvalue on first call (`message_formatter.lua:21-126`). GearSwap's
`require` is `include_user` (`GearSwap/refresh.lua:132`), which never writes `package.loaded`
(`GearSwap/user_functions.lua:300-333`). `ModuleCache.install()` (`shared/utils/core/module_cache.lua:44-88`,
called at `INIT_SYSTEMS.lua:54-56`) replaces `require` on the sandbox `_G` with a caching version. A
formatter required before that point is a separate copy. None of the formatters keep state that
matters, so the only visible effect is load cost.

### Job tag

Most lines start with `[MAIN/SUB]`. `MessageCore.get_job_tag()` (`message_core.lua:56-67`) returns
`"JOB"` when `player` is nil. `message_blm.lua:19-26`, `message_brd.lua:19-26`, `message_bst.lua:22-29`,
`message_geo.lua:25-32` and `message_rdm.lua:21-28` each carry a local copy that falls back to the job's
own code instead.

### Notable formatter logic

- **Spell activation line** (`show_spell_activated`, `message_combat.lua:448-470`). Picks one of 28 `MAGIC` keys:
  `<prefix>spell_activated[_full][_target|_full_target]` where the prefix comes from the spell skill
  (`SPELL_KEY_PREFIX`, `message_combat.lua:412-419`) and the suffix from whether a description and a
  target exist (`spell_activated_key`, `:427-438`). The target is dropped when it equals `player.name`
  (`:456`). The spell name is wrapped in its element colour (`get_element_color`, `:26-42`);
  Bar-spells are coloured by the name instead of the database element (`apply_element_color`,
  `:48-98`). Targets are green for `PLAYER`/`PC`/`SELF`, pale yellow for `NPC`, pink otherwise
  (`get_target_color`, `:103-124`).
- **WS lines** (`show_ws_tp` / `show_ws_activated`, `message_combat.lua:232-279`). Three TP tiers: >= 3000 green, >= 2000 cyan, else white.
- **Cooldown line** (`show_cooldown_message`, `message_cooldowns.lua:87-147`). The colour of the action name is chosen by
  substring of `action_type` (`magic`/`spell`, `ability`/`ja`, `weapon`/`ws`, else item colour).
  `status == "Ready"` or `"Active"` replace the timer. `format_recast_duration` renders `>= 3600` as
  `1h 02m 03s`, `>= 60` as `MM:SS min`, otherwise `12.3 sec` (`format_recast_duration`, `message_cooldowns.lua:22-48`).
  `show_spell_cooldown` takes centiseconds and divides by 100 (`message_cooldowns.lua:153-156`);
  `show_ability_cooldown` takes seconds.
- **Multi-status block** (`show_multi_status`, `message_cooldowns.lua:209-256`). Entries `{type="cooldown"|"tp", name,
  value, extra, action_type}`; `tp` entries require `extra` (the needed TP). Callers
  (`thf/functions/logic/smartbuff_manager.lua`, `dnc/waltz_manager.lua` and the others listed below)
  provide it.
- **Buff block** (`show_buff_status`, `message_buffs.lua:27-54`). Statuses `active`, `ready`, `cooldown`; each line is a
  `show_cooldown_message(..., no_separators=true)` between two `BUFFS.separator` lines.
- **JA activation** (`JABuffs.show_activated`, `message_ja_buffs.lua:52-78`). Returns 0 and prints nothing when
  `JA_MESSAGES_CONFIG.is_enabled()` is false; shows the description only in `full` mode.
- **Keybind intro** (`build_and_display_intro`, `message_system.lua:79-100`). Separator width is
  `MessageCore.SEPARATOR_WIDTH` (69, `message_system.lua:23`), macrobook and lockstyle lines only when
  that info is passed (`send_intro_config`, `:31-51`), keybind count, and a UI visible/hidden line only
  when `_G.ui_display_config` exists (`send_intro_status`, `:55-75`).
- **Alt command list** (`MessageAltCommands.show_list`, `message_alt_commands.lua:252`). With no filter:
  `show_overview` (`:205`), one line per group in `GROUP_ORDER` order (`:22`) plus the path of the
  override file. With a filter: `show_filtered` (`:149`), names matching group, name or action text,
  split into "needs a target" and "on <alt>". After either view, the names that run on this character
  (a common command or warp alias of the same name) are listed apart under a `//gs c alt <name>` line
  (`show_shadowed`, `:234`).
- **GEO cast line** (`show_indi_cast` / `show_geo_cast`, `message_geo.lua:93-155`). Requires both geomancy databases at module load
  (`message_geo.lua:18-21`); a spell missing from the database prints an `M.error` line and nothing else.
  `midcast_geomancy` (`GEO_MIDCAST.lua:55-63`) only routes `Indi-` and `Geo-` spells here, so the `-ra` entries of
  `ELEMENT_COLORS` (`message_geo.lua:54-60`: `Fira`, `Blizzara`, `Aera`, `Stonera`, `Thundara`, `Watera`) are never matched by name.
- **Roll result** (`RollMessages.show_roll_result`, `roll_messages.lua:191-307`). Builds up to six lines (roll, lucky/unlucky, coverage,
  missed names, bust risk, natural 11), then frames them with a separator sized from
  `get_visual_length` minus 3, minimum 60 and, since `b6c7dc6`, at most
  `MessageCore.SEPARATOR_WIDTH` (69) (`roll_messages.lua:276-292`). Risk bands are the table
  `BUST_BANDS` (`roll_messages.lua:71-85`), first match wins. `get_visual_length` treats `0x1E` as a
  4-byte sequence (`roll_messages.lua:54-55`) while `message_commands.lua` `generate_color_code` and GearSwap
  (`helper_functions.lua:1134`) use `0x1E` plus one byte; no roll line contains `0x1E` today.
- **Alt group, Sortie and temp-bind lines** (`message_altgroup.lua`, `message_sortie.lua`,
  `message_tempbind.lua`). Template path only; the Sortie and temp-bind modules build their separator
  from `MessageCore.SEPARATOR_WIDTH`. `MessageTempBind.show_help` builds its coloured rows itself and sends each through
  the one-parameter `TEMPBIND.help_line` template.

## Public API

Signatures are as declared. "Callers" lists the files that call the function from outside the
formatter file (line numbers dropped on 2026-09-25: they drift with every edit and add nothing a
search for the function name does not give). `(dead)` means no reachable caller was found.

### Facade-only notes

- Facade keys that point to functions that do not exist: `show_convert_activated`, `show_convert_used`,
  `show_chainspell_activated`, `show_chainspell_ended`, `show_composure_activated`,
  `show_composure_active` (`message_formatter.lua:312-317`). No caller; calling one raises
  "attempt to call field ... (a nil value)".
- Name overlaps: `MessageFormatter.show_buff_status` is `MessageBuffs.show_buff_status`, not the BLM one;
  `show_doom_removed` is BRD's (RDM's is `show_rdm_doom_removed`); `show_songs_casting`, `show_song_pack`,
  `show_daurdabla_dummy`, `show_pianissimo_*`, `show_marcato_*` go to `message_brd.lua`, and the
  `show_song_*` keys go to `message_songs.lua`; BST functions are exported twice, as `show_bst_x` and
  `show_x` (`message_formatter.lua:364-478`).
- Not in the facade at all: `message_weaponskill`, `message_alt_commands`, `message_dualbox`,
  `message_altgroup`, `message_sortie`, `message_tempbind` (their callers `require` them directly).

### combat/message_combat.lua

| Function | Output | Callers |
|---|---|---|
| `show_range_error(ability, distance_info)` | `COMBAT.range_error` | `weaponskill_manager.lua` |
| `show_ws_validation_error(ws_name, reason, detail, status_ailment, detail_color_code)` | `ws_validation_error[_status\|_detail]`; last param unused | `ws_precast_handler.lua`, `weaponskill_manager.lua` |
| `show_ability_tp_error(ability_name, current_tp, required_tp, job_tag)` | `ability_tp_error` | `DNC_PRECAST.lua` |
| `show_ws_tp(ws_name, total_tp)` | `ws_tp_{ultimate,enhanced,normal}` | `hooks/init_ws_messages.lua` |
| `show_ws_activated(ws_name, description, total_tp)` | `ws_activated_*`; `description` must not be nil | `hooks/init_ws_messages.lua` |
| `show_spell_cast(spell_name)` | `spell_cast` | PLD and RUN `functions/logic/aoe_manager.lua` |
| `show_waltz_heal(waltz_name, missing_hp, extra_ability, job_tag)` | `waltz_heal_{single,aoe}[_extra]` | `dnc/waltz_manager.lua` |
| `show_spell_activated(spell_name, description, target_name, spell_skill, spell_element, target_type)` | `MAGIC.*spell_activated*`; returns visible length | `handlers/spell_message_handler.lua`, BRD `functions/logic/midcast_router.lua` |
| `show_target_error`, `show_state_change`, `show_ability_use`, `show_jump_activated`, `show_jump_chaining`, `show_jump_complete`, `show_jump_relaunch` | | (dead) |

### combat/message_cooldowns.lua

| Function | Notes | Callers |
|---|---|---|
| `show_cooldown_message(job_name, action_type, name, remaining, status, no_separators)` | core line | `message_buffs.lua`, PLD and RUN `aoe_manager.lua` |
| `show_spell_cooldown(spell_name, remaining_centiseconds, job_name)` | centiseconds | `precast/cooldown_checker.lua`, BLM `storm_manager.lua`, `refiner/recast_display.lua`, `refiner/special_handlers.lua` |
| `show_ability_cooldown(ability_name, remaining_seconds, job_name)` | seconds | `cooldown_checker.lua`, DNC `step_manager.lua`, PLD and RUN `rune_manager.lua` |
| `show_multi_status(messages, job_name)` | block | BLM `spell_refiner.lua`, `storm_manager.lua`, `recast_display.lua`, DNC and THF `smartbuff_manager.lua`, `dnc/waltz_manager.lua`, `drg/DRG_JUMP_MANAGER.lua`, `precast/tier_refiner.lua` |
| `get_ability_recast_seconds(id)` | exported helper | via facade |
| `format_recast_duration(recast)` | used internally only | |
| `show_ws_cooldown`, `show_item_recast`, `show_stratagem_cooldown`, `show_song_duration`, `show_compact_status`, `show_spell_cooldown_by_id`, `show_ability_cooldown_by_id`, `get_spell_recast_seconds` | | (dead) |

### combat/message_ja_buffs.lua

Only `show_activated(ability_name, description)` (facade `show_ja_activated`) has a caller:
`handlers/ability_message_handler.lua`. `show_active`, `show_ended`, `show_with_description`,
`show_using`, `show_using_double` (facade `show_ja_*`) and the seven BRD compatibility wrappers
(`show_soul_voice_activated` ... `show_marcato_used`, facade `*_new`) are dead.

### combat/message_weaponskill.lua

Not in the facade. `show_ws_manager_initialized`, `show_invalid_spell_parameter`,
`show_target_info_missing`, `show_missing_numeric_values`, `show_too_far`, `show_player_info_missing`,
`show_amnesia_error` are called from `weaponskill/weaponskill_manager.lua`;
`show_tp_validation_failed`, `show_tp_calculation`, `show_already_at_max`, `show_target_threshold`,
`show_gap_too_large`, `show_total_available`, `show_checking_piece`, `show_equipping_piece` from
`weaponskill/tp_bonus_calculator.lua` (loaded by `precast/tp_bonus_handler.lua`).

### jobs/*

| Module | Live (callers) | Dead |
|---|---|---|
| message_blm | `show_element_cycle`, `show_storm_cycle`, `show_tier_cycle`, `show_buffself_error` (`BLM_COMMANDS.lua`); `show_spell_refinement` (`refiner/special_handlers.lua`, `precast/tier_refiner.lua`); `show_arts_already_active`, `show_stratagem_no_charges` (`scholar/scholar_actions.lua`); `show_spell_replacement_error`, `show_spell_refinement_error`, `show_spell_recasts_error`, `show_insufficient_mp_error`, `show_breakga_blocked` (BLM refiner files) | `show_aja_cycle`, `show_buff_activated`, `show_buff_cast`, `show_magic_burst_on/off`, `show_free_nuke_on`, `show_spell_refinement_failed`, `show_mp_conservation`, `show_dark_arts_activated`, `show_buff_casting`, `show_buff_status` |
| message_blm_midcast | all 11, from `BLM_MIDCAST.lua` (as `MessageBLMMidcast`) and BLM `functions/logic/midcast_router.lua` (as `ctx.messages`) | none |
| message_brd | `show_marcato_used`, `show_pianissimo_used`, `show_ability_command`, lullaby/elegy/requiem/threnody/carol/etude casts, `show_no_*` errors (`BRD_COMMANDS.lua`); `show_pianissimo_target`, `show_instrument_locked` (`BRD_PRECAST.lua`); `show_instrument_released` (`BRD_AFTERCAST.lua`); `show_songs_casting`, `show_song_pack`, `show_dummy_casting`, `show_pack_not_found` (`song_rotation_manager.lua`); `show_daurdabla_dummy` (BRD `midcast_router.lua`); `show_song_refinement[_failed]` (`song_refinement.lua`) | 23: Soul Voice/Nightingale/Troubadour lines, `show_marcato_skip_*`, `show_honor_march_locked/released`, `show_songs_refresh`, `show_dummy_cast`, tank/healer casting/refresh and not-configured, `show_song_guidance`, `show_song_cast_generic`, `show_doom_gained/removed`, `show_no_pack_configured` |
| message_bst | ecosystem/species/broth equip (BST `functions/logic/ecosystem_manager.lua`), broth count header/line, no broths, ready-move list/use/auto lines, `show_error_*` for pet, moves, index, module (`BST_COMMANDS.lua`), pet engage/disengage (`pet_manager.lua`) | 34: all JA lines, `show_jug_equipped`, `show_broth_count_footer`, pet summoned/dismissed/charm/died/despawned, auto-engage lines, pet TP/HP status, ready-move precast/physical/magical/breath/tp_check/recast, `show_error_no_target/pet_too_far/no_jug_equipped/insufficient_hp` |
| message_cor | all 3 (`cor/functions/logic/party_tracker.lua`) | none |
| message_drg | none (`drg/DRG_JUMP_MANAGER.lua` writes the same texts with `show_error`) | all 4 |
| message_geo | all 4 (`GEO_MIDCAST.lua` `midcast_geomancy`, `geo_spell_refiner.lua`) | none |
| message_rdm | `show_element_list`, `show_storm_current`, the `*_not_configured` / `no_enspell` / `storm_requires_sch` errors (`RDM_COMMANDS.lua`); `show_phalanx_downgrade/upgrade` (`RDM_PRECAST.lua`) | `show_doom_warning`, `show_doom_removed`, `show_spell_casting` (calls commented out in `RDM_COMMANDS.lua` as duplicates of the universal spell line), `show_enspell_current`, `show_phalanx_detected` |
| message_rdm_midcast | all 18 from `RDM_MIDCAST.lua` | none |
| message_whm | none | `show_curemanager_not_loaded` |

`message_brd.show_marcato_honor_march` and `show_song_cast` had callers but empty bodies; both, their
facade lines and their calls in `BRD_COMMANDS.lua` / `BRD_PRECAST.lua` were removed on 2026-09-25.

### magic/*

| Module | Live | Dead |
|---|---|---|
| message_buffs | `show_buff_status(buffs_data, action_type)`: DNC/THF/WAR `smartbuff_manager.lua`, `buffs/self_buff_manager.lua` | none |
| message_debuffs | `show_spell/ja/ws/item_blocked`, `show_action_blocked`, `show_no_silence_cure`, `show_no_paralysis_cure` (`debuff/precast_guard.lua`); `show_silence_cure_success`, `show_paralysis_cure_success` passed as callbacks (`precast_guard.lua` `try_cure_silence` / `try_cure_paralysis`); `show_auto_medicine_toggled` (`debuff/auto_medicine.lua`) | `show_incapacitated` |
| message_midcast | debug enabled/disabled/header/step, priorities, result, equipment line (`midcast/midcast_manager.lua`) | `show_target_details_header`, `show_target_property` |
| message_precast | all 7 (`BRD_PRECAST.lua`, `BST_PRECAST.lua`, `RDM_PRECAST.lua`, `RUN_PRECAST.lua`, and `DebugCommands.handle_debugprecast` for the toggle) | none |
| message_songs | none | all 10 |

### system/*

| Module | Live | Dead |
|---|---|---|
| message_altgroup | all 12: `show_auto`, `show_follow`, `show_sent`, `show_mirror`, `show_no_alts`, `show_not_ready`, `show_no_follower`, `show_usage` (`dualbox/alt_group.lua`); `show_role_main`, `show_role_alt` (`dualbox/dualbox_role.lua`, which also calls `show_no_alts` / `show_not_ready`); `show_window`, `show_window_main_only` (`dualbox/alt_window.lua`) | none |
| message_equipment | `show_check_header/summary/error`, `show_missing_item`, `show_storage_item`, `show_no_sets_found`, checker debug lines (`equipment/equipment_checker.lua`) | `show_set_valid` |
| message_init | `show_module_load_failed(module_name, error_msg)` (`INIT_SYSTEMS.lua` and others) | `show_watchdog_load_failed`, `show_module_loaded`, `show_init_complete` |
| message_sortie | all 7: `show_target_loaded`, `show_escort`, `show_target_list`, `show_alt_off`, `show_alt_action`, `show_unknown_target` (`sortie/sortie_commands.lua`); `show_alt_escort` (`GEO_COMMANDS.lua`, `//gs c escort`) | none |
| message_system | `show_system_intro(title, keybinds, job_name)` and `show_system_intro_complete(title, keybinds, macro_info, lockstyle_info, job_name)` from `keybinds/keybind_manager.lua`, which every job's keybinds go through | `show_system_intro_with_macros`; `show_color_test_header/sample/footer` are called only from `COR_COMMANDS.lua`, which is unreachable because `testcolors` returns through `CommonCommands` first (`COR_COMMANDS.lua:161-167`) |
| message_tempbind | all 9 (`keybinds/temp_binds.lua`, `//gs c tb`) | none |
| message_warp | casting/equipping/using, level/job errors, IPC, equipment lock, status/test screens, precast FC, item cooldown lines, item_user and IPC debug (`shared/utils/warp/*`) | `show_warp_countdown`, `show_warp_unavailable`, `show_warp_no_charges`, `show_warp_recast`, `show_warp_charges_remaining`, the five `show_tele_*` equivalents, `show_status`, `show_debug_toggle` (`debugwarp` is answered by `DebugCommands.handle_debugwarp` through `COMMON_COMMANDS.lua:620-621`; the `debugwarp` branch of `WarpCommands.handle_command`, `warp_commands.lua:270`, is marked unreachable) |
| message_watchdog | status/stats/config/debug/alert/test/help (`core/midcast_watchdog.lua`, `core/WATCHDOG_COMMANDS.lua`) | `show_stopped`, `show_debug_midcast_spell` |

Several `message_warp` functions are intentionally empty ("Silent init"): `show_init_success`,
`show_commands_registered`, `show_ipc_unavailable`, `show_ipc_registered`, `show_equipment_initialized`,
`show_precast_initialized` (`message_warp.lua:268-298`, `:375`, `:489`).

### ui/*

| Module | Live | Dead |
|---|---|---|
| message_alt_commands | `show_list(alt, job, names, commands, filter, subjob, char, shadowed)` (`dualbox/alt_commands.lua` `AltCommands.list`) | none (the dead local helpers `target_note` and `job_label` are gone) |
| message_commands | colour test header/row/separator/footer (`CommonCommands.handle_testcolors`), craft (`craft/craft_commands.lua`), lockstyle/dressup (`COMMON_COMMANDS.lua`), warp load errors (`COMMON_COMMANDS.lua`), debugsubjob (`DebugCommands.handle_debugsubjob`), jamsg/spellmsg/wsmsg (string dispatch in `handle_message_config_generic`), `show_warp_debug_toggled` (`DebugCommands.handle_debugwarp`), `show_debugmidcast_toggled` (all 16 `<JOB>_COMMANDS.lua`), `show_help`, `show_commands_list` (`COMMON_COMMANDS.lua:662-666`) | `show_color_sample` and the 14 region functions `show_detect_region_header` ... `show_region_reload_required` (`message_commands.lua:134-243`) |
| message_dualbox | all 23 (`dualbox/dualbox_manager.lua`) | none |
| message_info | all 6 (`commands/info_command.lua`) | none |
| message_keybinds | `show_keybind_list`, `show_no_binds_error`, `show_bind_failed_error` (`keybinds/keybind_manager.lua`); `format_keybind_line` (`ui/UI_FORMATTER.lua`, `ui/UI_SECTIONS.lua`); `calculate_max_width` (internal) | `show_invalid_bind_error` |
| message_status | `show_error`, `show_warning`, `show_success`, `show_info` (widely), `show_state_display` (`core/state_display_override.lua`), `show_tp_ready` (`drg/DRG_JUMP_MANAGER.lua`) | `show_tp_required` |
| message_ui | all 10 (`ui/UI_COMMANDS.lua`, `ui/ui_appearance.lua`, `ui/ui_section_toggles.lua`, `ui/ui_visibility.lua`) | none |

`MessageStatus.show_error(message)` takes one argument. `DEBUG_COMMANDS.lua:483` (memcheck) and
`:571` (debugmsg) pass two, so the second (the actual reason) is dropped.

### utilities/*

| Function | Callers |
|---|---|
| `RollMessages.show_roll_result(roll_name, value_display, bonus_display, is_crooked, affected_count, total_count, lucky_num, unlucky_num, missed_names, bust_rate, job_bonus_info, roll_range)` | `cor/functions/logic/roll_tracker.lua` |
| `show_roll_bust(roll_name, bust_effect, effect_type)` | `roll_tracker.lua` |
| `show_roll_double_up_window(remaining_seconds)`, `show_roll_double_up_expired()`, `show_no_active_roll()` | `roll_tracker.lua` |
| `show_active_rolls(active_rolls)`, `show_rolls_cleared()`, `show_invalid_roll_value(roll_value)` | `COR_COMMANDS.lua` (`rolls`, `clearrolls`, `track_roll`) |
| `show_roll_natural_eleven`, `show_roll_bust_rate`, `show_roll_not_found` | (dead; `show_roll_bust_rate` repeats the `BUST_BANDS` thresholds inline, `roll_messages.lua:336-386`) |
| `PartyMessages.show_party_members(party_jobs)` | `COR_COMMANDS.lua` (`party`); expects `{[id] = {name, main_job, sub_job, main_job_level}}` as built by `party_tracker.lua` |

## Commands

Formatters handle no command themselves. These commands print through them:

| Command | Handler | Formatter |
|---|---|---|
| `//gs c commands` / `cmds`, `help` / `?` | `COMMON_COMMANDS.lua:662-666` | `message_commands.show_commands_list` / `show_help` |
| `//gs c testcolors` / `colors` | `COMMON_COMMANDS.lua:610`, `CommonCommands.handle_testcolors` | `message_commands` colour test |
| `//gs c jamsg\|spellmsg\|wsmsg [full\|on\|off]` | `DEBUG_COMMANDS.lua` `handle_message_config_generic` (`:179-217`) | `message_commands.show_<prefix>_*` by string dispatch |
| `//gs c debugsubjob` / `dsj` | `DebugCommands.handle_debugsubjob` (`DEBUG_COMMANDS.lua:135`) | `message_commands` debugsubjob block |
| `//gs c debugwarp` | `COMMON_COMMANDS.lua:620-621` -> `DebugCommands.handle_debugwarp` | `message_commands.show_warp_debug_toggled` |
| `//gs c debugprecast` | `DebugCommands.handle_debugprecast` (`DEBUG_COMMANDS.lua:516`) | `message_precast.show_debug_enabled/disabled` |
| `//gs c debugmidcast` | each `<JOB>_COMMANDS.lua` | `message_commands.show_debugmidcast_toggled` |
| `//gs c info <name>` | `DebugCommands.handle_info` (`DEBUG_COMMANDS.lua:248`) -> `commands/info_command.lua` | `message_info` |
| `//gs c checksets` | `COMMON_COMMANDS.lua:545`, `CommonCommands.handle_checksets` | `message_equipment` |
| `//gs c altcmds [filter]` | `COMMON_COMMANDS.lua:555` -> `AltCommands.list` (`alt_commands.lua:540`) | `message_alt_commands.show_list` |
| `//gs c alts ...`, `main`, `setalt` | `dualbox/alt_group.lua`, `dualbox_role.lua`, `alt_window.lua` (see [dualbox.md](dualbox.md)) | `message_altgroup` |
| `//gs c sortie ...`; `//gs c escort` (GEO) | `sortie/sortie_commands.lua`; `GEO_COMMANDS.lua` | `message_sortie` |
| `//gs c tb ...` | `keybinds/temp_binds.lua` | `message_tempbind` |
| `//gs c ui ...` | `ui/UI_COMMANDS.lua` `UICommands.handle_ui_command` | `message_ui` |
| `//gs c warp status\|test\|help\|unlock\|fix\|lock\|ipctest` | `warpcommands_handle_command_warp` (`warp/warp_commands.lua:198`) | `message_warp` |
| `//gs c watchdog [on\|off\|toggle\|debug\|buffer n\|fallback n\|clear\|test\|stats]` | `WatchdogCommands.handle_command` (`core/WATCHDOG_COMMANDS.lua:36`) | `message_watchdog` |
| `//gs c rolls`, `clearrolls`, `party`, `track_roll` (COR) | `COR_COMMANDS.lua:174-291` | `roll_messages`, `party_messages` |

## Configuration

| Source | Read by | Effect |
|---|---|---|
| `shared/config/JA_MESSAGES_CONFIG.lua` | `message_ja_buffs.lua:25-36` (pcall; fallback = always `full`) | `off` silences `show_activated`, `full` adds the description; the mode is re-read from `MessageSettings` on each call (`MessageModeConfig.create`, `shared/config/message_mode_config.lua`, since 2026-09-25) |
| `message_colors.lua` (`MessageCore.COLORS`) | every module that builds inline colours | colour numbers; `WARNING` and `get_warning_color()` are region dependent |
| `_G.LockstyleConfig.initial_load_delay` (default 8.0) | `message_system.lua:42` | delay shown in the intro lockstyle line; set by `_master/entry/*` |
| `_G.ui_display_config.enabled` | `message_system.lua:64` | UI visible/hidden line in the intro |
| `shared/data/magic/geomancy/geomancy_indi.lua`, `geomancy_geo.lua` | `message_geo.lua:18-21` at load | descriptions and elements for Indi/Geo lines |
| UI theme names | hard-coded in `message_ui.lua` (theme list) | should match the `background_presets` of `_master/config_global/UI_CONFIG.lua`, `Tetsouo/config/UI_CONFIG.lua` and `Kaories/config/UI_CONFIG.lua` (36 on 2026-09-18; not re-counted) |

Not read, but repeated as literal text: cure item names (`message_debuffs.lua:267-273, 343-347, 382`,
see `shared/config/DEBUFF_AUTOCURE_CONFIG.lua:40-52`) and the command lists in the help screens.

## State & lifetime

- No formatter registers an event, schedules a coroutine, binds a key or writes `windower.*`.
- Globals read: `player` (job tag, `message_combat.lua:456`), `_G.LockstyleConfig`,
  `_G.ui_display_config` (`message_system.lua:42,64`). `windower.ffxi.get_spell_recasts` and
  `get_ability_recasts` are read in `message_cooldowns.lua:57-78`. No formatter writes a global.
- Module-level state: the facade's upvalue caches (`message_formatter.lua:21-126`), `JAConfig` in
  `message_ja_buffs.lua:25`, the geomancy tables in `message_geo.lua:18-21`. All live in the sandbox
  and are rebuilt when GearSwap drops `user_env` on `gs reload` or a main-job change
  (see `module_cache.lua:18-25`). A subjob change is followed by a `gs reload` 0.5 s later
  (`JobChangeManager.on_job_change`), which rebuilds them too.
- The renderer's `_stats.by_color` gains one entry per distinct colour-first message (path B above)
  until the next reload.

## Interactions

- Below: [messages.md](messages.md) (API, engine, renderer, colours, facade),
  [messages-catalog.md](messages-catalog.md) (templates).
- Callers: [precast-pipeline.md](precast-pipeline.md) (PrecastGuard debuff lines, cooldown lines, WS
  validation), [midcast-and-buffs.md](midcast-and-buffs.md) (MidcastManager debug, smartbuff blocks),
  [commands-and-debug.md](commands-and-debug.md) (help, command list, jamsg/spellmsg/wsmsg, info),
  [dualbox.md](dualbox.md) (dual-box, altcmds, `alts`), [ui-overlay.md](ui-overlay.md) (`//gs c ui`),
  [keybinds-and-custom.md](keybinds-and-custom.md) (keybind intro, `//gs c tb`),
  [core-lifecycle.md](core-lifecycle.md) (INIT_SYSTEMS load failures, watchdog).
- `message_validator.lua` (`//gs c msgtests`) checks that each job formatter function exists in the
  facade under the same name (`validate_exports`, `message_validator.lua:182`). Because of the name overlaps above it
  passes BLM `show_buff_status` and RDM `show_doom_removed` although the facade key reaches another
  module, and it flags BRD `show_song_cast_generic`, which is not exported.

## Invariants & gotchas

- Colour tokens go in the template, never in a parameter. `"{green}"` passed as a value prints the
  literal text (verified by running `message_engine.lua` under Lua 5.1).
- Every placeholder in a template must be supplied and not nil, otherwise the line becomes a
  `[MessageSystem ERROR]` line. `message_precast.show_debug_step` guards `value or ""`
  (`message_precast.lua:61`); `message_midcast.show_debug_step` does not (`message_midcast.lua:59-64`),
  and all current midcast callers pass non-nil values.
- `show_spell_cooldown` wants centiseconds, `show_ability_cooldown` seconds; `show_multi_status`
  values are seconds.
- Lines that should keep their inline colours go through `MessageCore.raw` (channel 001) or a template
  with `color = 1`. Direct `add_to_chat` in these files uses channel 121 with an inline code first.
- `MessageRenderer.send` takes `(text, color)`. In the message layer only `message_keybinds.lua:82` and
  `MessageFormatter.show_debug` (`message_formatter.lua:497-501`) use that order today; outside it,
  `core/DEBUG_COMMANDS.lua` (`announce_summary`, `handle_memcheck`) does too.
- Unrecognised `//gs c warp <sub>` falls through to casting Warp (`WarpCommands.handle_command`,
  `warp_commands.lua:235`), so any help text naming a `warp` subcommand must match
  `warpcommands_handle_command_warp` (`warp_commands.lua:198`).

## Extending

To add a message:

1. Add the template to the namespace file under `data/jobs/` (three-letter job code) or
   `data/systems/` (`<namespace>_messages.lua`), with `template` and `color`. Put colours as tokens.
2. Add a function to the formatter that calls `M.send('<NS>', '<key>', {...})` (or `M.job`) and supplies
   every placeholder, converting numbers with `tostring` where the other functions do.
3. If game code should reach it through the facade, add a lazy wrapper in `message_formatter.lua` next
   to the module's block, under a name no other module already uses. For a job formatter the validator
   expects the same name as the formatter function. A system module used by one feature can also be
   required directly, as the alt-group, Sortie and temp-bind formatters are.
4. For multi-part lines with computed colours, build the string with `MessageCore.create_color_code`
   and send it with `MessageCore.raw(text)` or `MessageRenderer.send(text, 1)`.

To add a formatter module: create it under the matching `formatters/<area>/`, `return` the module
table, and add a `get_<Module>()` lazy getter in the facade if it is to be exported.

## Known issues

Re-checked on 2026-09-25. Open:

- `//gs c warp help` lists `//gs c warp debug` (`message_warp.lua:245`); that command casts Warp or uses the Warp Ring.
- 108 `MessageRenderer.send` calls pass colour and text in the wrong order (`message_cooldowns.lua:141`, `message_debuffs.lua`, `message_warp.lua`, `message_alt_commands.lua`, `message_rdm_midcast.lua:38`); RDM midcast debug lines lose their colours.
- Six facade entries point to RDM functions that do not exist (`message_formatter.lua:312-317`).
- `message_brd.show_dummy_cast` uses the missing key `BRD.dummy_cast` (`message_brd.lua:236`); its two callers in `BRD_COMMANDS.lua` are commented out.
- `message_songs.lua` has no caller; neither do the `show_song_*` and `*_new` facade keys (`message_formatter.lua:151-166`).
- Region detection functions left after the `setregion`/`detectregion` handlers were removed (`message_commands.lua:134-243`); they still print `//gs c setregion us/eu` as advice (the `message_colors.lua` header now says `setregion` is not implemented).
- About 159 formatter functions had no caller on 2026-09-18 (tables above; not re-measured).
- Colour tokens passed as parameters print literally (`message_warp.lua:454`, `message_blm.lua:196`, `message_bst.lua:282, 297, 314`); all on paths without callers today, and each function's comment now says so.
- "No cure" and AutoMedicine lines name fixed items and omit Panacea (`message_debuffs.lua:267-273, 343-347, 382`).
- The BST broth listing opens a separator block it never closes (`BST_COMMANDS.lua:123-129`).
- `MessageFormatter.show_error` called with two arguments drops the reason (`DEBUG_COMMANDS.lua:483`, `:571`).
- README describes `jamsg`/`spellmsg`/`wsmsg`/`info`/`debugmsg` wrongly (`README.md:380-387`).
- The watchdog help lists `status` (not a subcommand) and omits `toggle` (`watchdog_messages.lua:259`).
- Five local `get_job_tag` copies and four element colour maps (`message_combat.lua` `get_element_color`, `ELEMENT_COLORS` in BLM/BRD/GEO); Ice is 210 in `message_combat.lua:31` and 30 in BLM/BRD/GEO.
- Colours changed on 2026-09-25 (`MessageCore.warning` and `STATUS.warning` now region orange, one `[JOB]` label style in RDM/COMBAT/WARP templates): not yet checked in game on an EU account.

Fixed:

- `MessageWarp.show_item_equip_delay` was defined twice and the one-argument call raised: one definition left, `item_user.lua` now uses `show_item_not_ready` for the other case (`518e536`).
- `message_database` with no live caller: deleted in `72e135d`.
- Direct `add_to_chat` in formatter files not listed by `.claude/CODE_QUALITY.md` section 6: the rule now covers all of `shared/utils/messages/` (fixed 2026-09-25).
- `message_brd.show_marcato_honor_march` / `show_song_cast` with empty bodies: removed with their callers (fixed 2026-09-25).

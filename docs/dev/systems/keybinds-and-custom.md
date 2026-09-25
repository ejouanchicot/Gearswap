# Keybinds, common keys, player modes (`_CUSTOM`) and temporary binds

Four pieces decide what a key does and what extra gear goes on:

1. **KeybindManager** (`shared/utils/keybinds/keybind_manager.lua`). Every job's
   `<JOB>_KEYBINDS.lua` is a plain data file that ends with
   `return require('shared/utils/keybinds/keybind_manager').create('<JOB>', module)`.
   The factory adds the functions the entry file, the HUD and KeybindGuard call
   (`bind_all`, `refresh`, `unbind_all`, `get_active_binds`, `show_intro`, `show_binds`).
2. **Common keys** (`shared/utils/keybinds/common_keybinds.lua`). Keys every job of a
   character gets, from `<Character>/config/COMMON_KEYBINDS.lua`.
3. **Player modes and gear rules** (`shared/utils/custom/*.lua`). An optional
   `<Character>/config/<job>/<JOB>_CUSTOM.lua` adds Mote states with a key, and
   gear that goes on last, on top of what the job picked.
4. **Temporary binds** (`//gs c tb`, `shared/utils/keybinds/temp_binds.lua`). Keys
   made in game for a repetitive task, on Ctrl/Alt+F1-F8.

Two helpers sit beside them: `key_validator.lua` names keys that cannot work, and
`shared/utils/core/keybind_guard.lua` re-sends the job's binds 2 s after a load.

## Files

| Path | Role |
|---|---|
| `shared/utils/keybinds/keybind_manager.lua` | Factory `KeybindManager.create(job, module)`, `KeybindManager.bind_line(bind)` |
| `shared/utils/keybinds/key_validator.lua` | `KeyValidator.check(binds, active)`, `KeyValidator.is_valid_key(key)` |
| `shared/utils/keybinds/common_keybinds.lua` | `CommonKeybinds.load()`, `CommonKeybinds.merge_into(binds)` |
| `shared/utils/core/keybind_guard.lua` | `KeybindGuard.schedule()`: one delayed re-bind per load |
| `shared/utils/custom/custom_states.lua` | `CustomStates.load(job, binds)`, `CustomStates.install_hooks()` |
| `shared/utils/custom/custom_conditions.lua` | The `when = {...}` tests (`Conditions.holds`) |
| `shared/utils/custom/custom_guards.lua` | Moments and slots the custom gear must not touch |
| `shared/utils/custom/custom_states_validate.lua` | Plain-language checks of each `_CUSTOM` entry |
| `shared/utils/keybinds/temp_binds.lua` | `//gs c tb` subcommands and the `temp_binds.lua` file |
| `shared/utils/keybinds/temp_binds_parse.lua` | Key words, action names, targets for `tb` |
| `shared/utils/messages/formatters/system/message_tempbind.lua` | `tb` messages (`TEMPBIND` namespace) |
| `_master/config/<job>/<JOB>_KEYBINDS.lua` | Job key templates (SMN: `_master/Tetsouo/config/smn/`; overlays for Kaories COR/GEO/PLD/RDM) |
| `_master/config/<job>/<JOB>_CUSTOM.lua` | Commented, empty `_CUSTOM` templates (14 jobs; SMN and a Tetsouo WAR copy in `_master/Tetsouo/config/`) |
| `_master/config_global/COMMON_KEYBINDS.lua` | Common keys template; Kaories overlay in `_master/Kaories/config_global/` |

PUP has no `_KEYBINDS` file: `_master/config/pup/` does not exist (see [jobs/pup.md](../jobs/pup.md)).

## How it works

### Loading a job's keys

The entry file's `user_setup()` requires the keybind file after the states are
configured, keeps it in a global named `<JOB>Keybinds` and calls `bind_all()`. In
`_master/entry/Tetsouo_WAR.lua` `user_setup`:

```lua
local kb_success, keybinds = pcall(require, 'Tetsouo/config/war/WAR_KEYBINDS')
if kb_success and keybinds then
    WARKeybinds = keybinds
    WARKeybinds.bind_all()
else
    show_keybind_error(keybinds)
end
```

When the require fails, the entry prints `[<JOB>] Keybinds failed to load: <error>`,
error included (the BLM, BST, GEO, PUP, SMN and Kaories GEO entries printed no cause
before 2026-09-25).

Requiring the file runs `KeybindManager.create`, which, in this order:

1. attaches the six functions, each bound to a private `ctx = {job, module, applied}`;
2. appends the player's `_CUSTOM` keys (`add_custom_states`, under `pcall`: a broken
   custom file costs the job nothing but its custom keys, and prints
   `<JOB>_CUSTOM.lua: <error>`);
3. appends the common keys (`CommonKeybinds.merge_into`).

The HUD loads the same file a second time under another module name
(`UI_LOADER.lua` requires `config/<job>/<JOB>_KEYBINDS`, the entry requires
`<Char>/config/...`), so `create` runs twice per load. `CustomStates.load` keeps its
result in `_G._custom_state_cache` and hands the same bind entries to the second call,
so the file is read and its warnings shown once.

### Bind entries

Fields, as listed in the `keybind_manager.lua` header:

| Field | Meaning |
|---|---|
| `key` | Windower key (`^numpad1`). `""` = a HUD row only, nothing bound |
| `command` | What the key runs (see [bind_line](#what-a-key-sends-bind_line)) |
| `desc` | Label in the HUD and the chat lists |
| `state` | Mote state the HUD row displays |
| `subjob` / `exclude_subjob` | Only / never under this subjob (string or list) |
| `visible` | `function() -> boolean`, asked again on every `refresh()` |
| `alt` | `{name, job, subjob, weapon}`, each optional, a string or a list: only bound while that box of the group plays it (no `name` = the tracked partner). `weapon` is the main hand's skill (`'Sword'`, `'Great Katana'`), compared without spaces or case. Nothing known about the box yet = not bound. Added 2026-09-25 for Gab's alt keys |
| `raw` | Send `command` exactly as written |

`<module>.retired_keys` lists keys an older version of the file bound: they are
unbound on every load (PLD keeps `^numpad7`).

`get_active_binds()` keeps the entries whose `subjob`, `exclude_subjob`,
`visible` and `alt` allow them now. A `visible` function that errors counts as hidden.

### What a key sends (`bind_line`)

`KeybindManager.bind_line(bind)` turns an entry into the text after `bind <key> `:

| `command` | Sent | Example |
|---|---|---|
| `raw = true` | exactly `command` | |
| starts with `//` | `command` without the `//`: a console command of any addon | `//sm mirror` → `sm mirror` |
| starts with `/` | `input <command>`: a game command | `/p Ready!` → `input /p Ready!` |
| anything else | `gs c <command>` | `cyclestate HybridMode` → `gs c cyclestate HybridMode` |

The same function is used by `bind_all`, `refresh` and KeybindGuard, so a key laid
down by the guard sends the same line.

### `bind_all`, `refresh`, `unbind_all`

- **`bind_all(silent)`**
  1. no bind list: `show_no_binds_error`, returns false;
  2. unless `silent`, runs the key validator and prints one warning per problem as
     `<JOB> keybinds: <problem>`;
  3. builds `desired` (key → line) from the active entries; a key used twice keeps the
     **last** entry;
  4. `clear_unwanted`: unbinds every key that is in the file, in `retired_keys` or in
     `windower._keybind_manager_bound` and is not wanted now. A key about to be bound
     is **not** unbound first (a bind overwrites; see [the dead keys](#dead-keys-after-a-reload));
  5. sends `bind <key> <line>` for each wanted key and records it in
     `windower._keybind_manager_bound`;
  6. shows the intro when at least one key went down. When none did while some should
     have, prints `<JOB> keybinds: none applied - keys will not respond`.
- **`refresh()`** sends only the difference since the last `bind_all`/`refresh`
  (for `visible` and `alt` entries). A key that stays with another command is only
  re-bound, never unbound first (since 2026-09-25). PLD calls it from its state-change
  hook (`PLD_COMMANDS.lua`, after a stance change: `/SCH` Tanking hides `MainWeapon`);
  `KeybindManager.refresh_active()` calls it on the job loaded now (`_G._keybind_active`,
  the first module `create` made in the sandbox: the HUD requires the keybind file again
  and gets a second module that never laid a key) whenever `alt_states.lua` records a new job, subjob or weapon type
  for a box.
- **`unbind_all()`** runs `clear_unwanted` with nothing wanted, so it also removes
  keys another job file of this manager left down, then prints
  `<JOB> keybinds unloaded.`. Every entry file calls it from `file_unload()`.

### The key validator

`KeyValidator.check(binds, active)` returns readable lines for:

- an entry with no `key` field: `"<desc>": no key`;
- a key that is not modifiers (`^ ! @ # ~ % $`) followed by a known key name:
  `"<desc>": unknown key <key>`. Known names: letters, digits, `f1`-`f15`,
  `numpad0`-`numpad9`, `numpad* + - . /`, `numpadenter`, and the usual named keys
  (`escape`, `tab`, `enter`, arrows, `pageup`…) and punctuation;
- a key with no command: `"<desc>": key <key> has no command`;
- the same key twice **among the active entries**:
  `<key> used twice ("<desc1>" and "<desc2>")`. A file may reuse a key under two
  different subjobs.

It only warns: the bind is still sent, in case Windower knows a key name the list
does not. Windower itself never answers a `bind`, so a misspelt key is otherwise
silent.

### The intro message

`show_intro()` lists the keyed active binds under `<JOB> SYSTEM LOADED`. It also
requires the job's `<JOB>_MACROBOOK` and `<JOB>_LOCKSTYLE` modules, looking for
`get_<job>_macro_info` and `get_info`. None of the 32 wrappers returns a table, so
`show_system_intro_complete` is never reached and the intro never shows the macro
book or the lockstyle (see Known issues). The require still matters: it defines
`select_default_macro_book` / `select_default_lockstyle`, which `user_setup` calls
before the facade is loaded.

### Common keys

`CommonKeybinds.load()` does `pcall(require, 'config/COMMON_KEYBINDS')`, so it reads
the file of the character whose folder GearSwap loaded. No file, no common keys.
`merge_into(binds)` appends each common entry whose key is not already in the list,
and marks the list (`binds._common_merged`) so a second call does nothing.

Order in the final list: job keys, then `_CUSTOM` keys, then common keys. A common key
never replaces a job or custom key: it is skipped. Current common keys (Tetsouo and
Kaories are identical):

| Key | Command |
|---|---|
| `#numpad0` | `cyclestate AutoMedicine` |
| `!numpad7` | `alts follow` |
| `!numpad8` | `alts toggle` |
| `!numpad9` | `alts mirror` |

The `alts` commands order every other member of `DualBoxConfig.group` (see
[dualbox.md](dualbox.md)), so both characters carry them.

### Combat Mode (`shared/utils/core/combat_mode.lua`, 2026-09-25)

`KeybindManager.create` calls `CombatMode.attach(job, binds)` for every job. It creates
`state.CombatMode` (`Off`/`On`) when the job's STATES file has none, reuses the job's
own bind entry when there is one (BLM `^numpad8`, GEO `^numpad0`, RDM `^numpad5`, WHM
`^numpad2`) or appends `{key = '!numpad0', command = 'cyclestate CombatMode', state = 'CombatMode'}`
(`!numpad0` is free on every job's file, and in Gab's BindManager binds),
and wraps the entry's `visible` with `CombatMode.is_shown(job)`.

- **Shown** when `<Character>/config/combat_mode.lua` says so (`shown`/`hidden` by job),
  else when the job's STATES defined the state (`_G._combat_mode_native`, recorded on the
  first `attach` of the sandbox). The file also holds a key per job (`keys`), which
  replaces the entry's. `all` in any of the three tables stands for every job not
  named (`shown = {all = true}, keys = {all = '~f9'}`: Gab's Shift+F9 on all his jobs). Written by `//gs c combatmode show | hide | key <key>|none`
  (`combat_mode_commands.lua`), kept across a re-clone (`KEPT_ON_RECLONE`).
- **Lock.** `CombatMode.install_hook()` (INIT_SYSTEMS, after the custom hooks, so it runs
  first) wraps `handle_equipping_gear`: On and shown disables main, sub, range (and ammo
  on BLM and WHM) before the gear; otherwise it enables what it locked, unless a craft
  session is active. What it locked is kept in `windower._combat_mode_locked`, so the
  next job's first update frees it.
- The four jobs' own lock code (BLM/WHM `job_state_change`, RDM/GEO `job_update` in the
  entries) still runs alongside; it locks the same slots.

### Player modes and gear rules (`<JOB>_CUSTOM.lua`)

The file is `<addon>/data/<player.name>/config/<job>/<JOB>_CUSTOM.lua`, read with
`dofile` under `pcall` at every load (a `gs reload` picks up an edit). It returns a
list of entries of two kinds:

- **Mode** — `{ state = 'Name', desc, key, values = {...} | 'onoff', section, subjob,
  exclude_subjob, <Value> = { <moment> = gear, when = {...} } }`. A new state is created
  (`M(false, desc)` for `'onoff'`, else `M{description = desc, ...values}`). A state the
  job already has is reused: `values` is then ignored (with a warning) and only its gear
  blocks count, so `state = 'HybridMode'` can add pieces to the job's `PDT`. The key goes
  into the job's bind list as `cyclestate <Name>`, so the HUD, the validator and
  KeybindGuard see it like any job key.
- **Rule** — `{ when = {...}, <moment> = gear }`, no state and no key: the gear goes on
  whenever `when` holds.

A value block is matched to the state's current value case-insensitively.

**Locks** (`custom_locks.lua`, 2026-09-25). A value block may hold `lock = {slot, ...}`.
The wrapped `handle_equipping_gear` collects the slots of the active value blocks,
enables the ones it locked earlier that are no longer wanted (before the job's gear, so
the job can dress them), equips, then disables the wanted ones (after the gear, so a CP
cape can go on first). What it locked is kept in `windower._custom_locked`; the first
`CustomStates.load` of a sandbox enables it, since GearSwap keeps a disabled slot across
a job change. A weapon slot is not enabled while Combat Mode is on (`CombatMode.is_on()`). Only mode
entries lock; a `lock` in a rule is ignored. Actions do not re-check locks: a value
change goes through `handle_update`, which calls `handle_equipping_gear`.

**Moments.** `idle`, `engaged`, `weaponskill`, `ability`, `precast`, `midcast`, `all`.
A moment holds pieces `{slot = item}` or the name of an existing set (`'sets.engaged.Acc'`,
resolved from `_G` at equip time).

**Where the gear goes on.** `CustomStates.install_hooks()` runs from `INIT_SYSTEMS`
(not from `user_setup`, which Mote runs before it defines the functions below) and
wraps, once per sandbox and only when the job has entries:

| Wrapped | Moments equipped after the original |
|---|---|
| `handle_equipping_gear(status)` | `all`, then `engaged` or `idle` |
| `cleanup_precast` | weaponskill: `all`, `weaponskill`; magic: `all`, `precast`; ability: `all`, `ability`; other: `all` |
| `cleanup_midcast` | same, with `midcast` for magic (weaponskills and abilities get their precast moment again, since they go off with the midcast gear) |
| `user_buff_change` | re-runs `handle_equipping_gear` when a buff named in a `buff`/`no_buff` condition changes, outside an action, while Idle or Engaged |

Entries are equipped in file order, so a later entry wins on the same slot. Slot
locks still win, as for any `equip()`.

**`when` conditions** (`custom_conditions.lua`). Every key must hold (AND); a list
value holds if any item matches (OR). Names compare case-insensitively, and a trailing
`*` matches a prefix.

| Key | Holds when |
|---|---|
| `buff` / `no_buff` | a listed buff is active / none is (name or id) |
| `weapon` | the item in `main` (the one this action is equipping first, else the worn one), or the `MainWeapon` state's value |
| `sub`, `range`, `ammo` | the item in that slot, same lookup |
| `subjob` / `no_subjob` | current subjob |
| `mode = {State = 'Value'}` | each named state has one of the values |
| `hp_below`, `hp_above`, `mp_below`, `mp_above` | HP / MP percent |
| `tp_below`, `tp_above` | TP |
| `spell` | the action's English name |
| `skill` | the action's skill |
| `spell_type` | the action's `type` (`WhiteMagic`, `BardSong`, `WeaponSkill`, `JobAbility`…) |
| `element` | the action's element |
| `day_weather = true/false` | the action's element matches the day, or the weather |
| `target` | `self`, `other` (player or NPC), `enemy` |
| `distance_below` | distance to the action's target |
| `obi_better` / `orpheus_better` | Hachirin-no-Obi's bonus for the action's element (day ±10, weather ±10/±25, storms included) beats Orpheus's Sash's (+15 at 1 yalm, -1 per yalm, +1 from 15), or the reverse; ties go to Orpheus. `shared/utils/equipment/elemental_bonus.lua`, 2026-09-25 |
| `obi_bonus_above` | the Obi's bonus is above this many percent (for a player without Orpheus) |
| `town`, `moving`, `pet` | true / false |
| `zone` | zone name |

The action keys (`spell`, `skill`, `spell_type`, `element`, `day_weather`, `target`,
`distance_below`, `obi_better`, `orpheus_better`, `obi_bonus_above`) never hold at
idle/engaged. An action with no element (most physical weaponskills) never passes the
belt keys. An unknown key, or a test that errors,
makes the whole `when` false.

**Guards** (`custom_guards.lua`), applied automatically:

- nothing at all while Doomed, on a cancelled action, for ranged attacks, items, pet
  moves and Blood Pacts, outside Idle/Engaged, and for Paralyna while paralysed;
- these slots are left alone: Impact (body, head), Dispelga (main, sub), songs (range,
  ammo), Phantom Roll and Double-Up (rings), Call Beast and Bestial Loyalty (ammo), the
  ammo while the Hoxne stance or its Ampulla lock is on, the THF Treasure Hunter pieces
  when engaged and TH is wanted, and every slot in GearSwap's `disable_table`.

**Validation** (`custom_states_validate.lua`), printed as
`<JOB>_CUSTOM: <problem>` at load:

- **fatal, entry skipped** (` (skipped)` appended): not a `{...}` block; no `state` and no
  `when`; a state name that is not one word of letters/digits/`_`; a new state without
  `values`;
- **warnings**: `values` on an existing state; unknown field; a `lock` that is not a list,
  or names an unknown slot; a block named after a value
  the state does not have; an unknown moment; an unknown slot; a weapon slot (main, sub,
  range) in `engaged`, `weaponskill`, `ability` or `all` ("changing <slot> in combat loses
  your TP"); a gear value that is neither a table nor a set name; an unknown condition or a
  condition value of the wrong type; a `section` other than mode, spell, ability, weapon.

Keys of custom entries are not checked here: they go through the key validator with the
job's keys at `bind_all`. A custom key that is also a job key is reported as "used twice"
and the custom entry wins (it comes later in the list).

Every custom equip is written to the trace log (`CUSTOM` tag) when `//gs c trace` is on.

### Temporary binds (`//gs c tb`)

Routed by `COMMON_COMMANDS.lua` (`cmd == 'tb'`) to `TempBinds.handle(args)`.

| Command | Effect |
|---|---|
| `//gs c tb <key> <action> [target]` | bind a key |
| `//gs c tb <action> [target]` | same, on the first free key of Ctrl+F1-F8 then Alt+F1-F8 |
| `//gs c tb force <key> ...` | bind even over a key in use |
| `//gs c tb list` | what is bound |
| `//gs c tb del <key>` | unbind one |
| `//gs c tb clear` | unbind all |
| `//gs c tb help` (or `?`) | full help |

**Keys** (`Parse.key`): Windower form (`^f1`), words (`ctrl+f1`, `alt+`, `shift+`,
`win+`, `apps+`), or short letters (`cf1`, `caf1`, `cn1` = Ctrl+Numpad1). A word that
looks like a key but is not one (`ctrl+fx`, `^f13`) is reported instead of being read as
the start of the command.

**What the key sends** (`Parse.command`) differs from `bind_line` on the last case:

| Words after the key | Stored command |
|---|---|
| `//cmd ...` | the console command `cmd ...` |
| `/ma`, `/ja`, `/ws`, `/item` + name | the action, name completed from the game resources, restricted to that kind |
| any other `/cmd` | `input /cmd ...` |
| words that start with an action name | `input /ma "<Name>"` (or `/ws`, `/ja`, `/item`); spells win over the other kinds |
| anything else | sent to the console **as typed** (not `gs c`) |

Name matching slugs the text like the Shortcuts addon (case, spaces and punctuation
ignored, digits read as roman numerals), so `dia2` is Dia II. What follows the action
name is the target: `t`, `st`, `stnpc`, `bt`, `me`… become `<t>`, `<st>`…; any other word is
a name looked up at **each press** as the nearest valid mob, player or NPC of that name
within 50 yalms, and sent as its raw id (no angle brackets).

The key itself is bound to `gs c tb run <key>`: the stored command is resolved when
pressed, so the target can move or respawn.

**Checks before binding** (`taken_by`): Mote's F9-F12 block, `^-`, `^=` and `^v`
(Windower paste) are reserved; a key in the current job's active binds is reported with
its owner. `force` skips that check. A job key taken with `force` is only borrowed: the
next `bind_all` (next load) or KeybindGuard binds the job's command again.

**Storage.** `<addon>/data/<Char>/temp_binds.lua`, rewritten on every change, holds
`clock = os.clock()` and the key → command table. It is a file because `//lua r gearswap`
wipes GearSwap's memory but not Windower's binds, and `clear` must still find them.
On read, a saved clock larger than the current `os.clock()` means the game was restarted
(its binds are gone) and the list is treated as empty.

## Configuration

| File | Content |
|---|---|
| `<Char>/config/<job>/<JOB>_KEYBINDS.lua` | the job's entries, `retired_keys` |
| `<Char>/config/COMMON_KEYBINDS.lua` | `CommonKeybinds.binds`, same entry format |
| `<Char>/config/<job>/<JOB>_CUSTOM.lua` | modes and rules; the templates are fully commented and return `{}` |
| `<Char>/temp_binds.lua` | written by `tb`, not edited by hand |

### Key layout (project convention)

The layout below is the convention the job files follow today; nothing in the code
enforces it.

- Numpad keys, always with a modifier, so the bare numpad stays free for the game and
  for addons that send numpad presses. `^` = Ctrl, `!` = Alt, `@` = Win, `#` = **Apps**
  (not Shift), `~` = Shift.
- `^numpad9` is `HybridMode` on every job that has one (BRD, RDM, WHM and SMN do not bind it).
- `^numpad3` is the job's most-cycled state (WAR `WS1`, PLD/RUN `RuneMode`, THF
  `TreasureMode`, COR `QuickDraw`, BST `PetIdleMode`, BRD `MainInstrument`, WHM
  `CureMode`, SMN `AvatarFavor`…).
- `^numpad1` / `^numpad2` are the weapon slots when the job has weapon states;
  otherwise they carry job binds.
- `#numpad0` and `!numpad7`-`!numpad9` come from `COMMON_KEYBINDS`: do not reuse them in
  a job file (the job would win and the common key would vanish on that job).
- F9-F12 (with modifiers) are Mote-Include's; Ctrl/Alt+F1-F8 are `tb`'s.
- A bind change goes in the template (`_master/config/<job>/`) and in the live copy
  (`<Char>/config/<job>/`); they are separate files.

## State & lifetime

| What | Lives in | Lifetime |
|---|---|---|
| Windower binds | the engine | survive every load; removed by `unbind_all` in `file_unload`, or by the next `bind_all` |
| Keys this manager laid down | `windower._keybind_manager_bound` | survives loads, so a key removed from a file is unbound at the next load |
| Pending guard re-bind | `windower._keybind_guard_seq` | a newer load cancels the older one |
| `ctx.applied` | module local | one sandbox |
| Custom entries, watched buffs, hooks, cache | `_G._custom_state_entries`, `_custom_state_buffs`, `_custom_state_hooks`, `_custom_state_cache` | one sandbox; hooks are laid again after each load |
| Temporary binds | `<Char>/temp_binds.lua` + Windower binds | until `tb del/clear`, or the game restarts |

A subjob change reruns `user_setup()` in the same sandbox, so `bind_all` runs again
(the module is cached: no second custom read), then JobChangeManager reloads.
`unbind_all` does not touch `tb` keys unless the job file also uses them.

### Dead keys after a reload

A key could stay dead after a reload while `//gs c` still worked. The binds are sent;
they are Windower console commands, and a load sends its whole list in one burst on top
of the unbind burst of the outgoing file's `file_unload`. Two things handle it
(2026-09-22):

- `bind_all` no longer unbinds a key it is about to bind (`clear_unwanted`);
- `KeybindGuard.schedule()`, called from `INIT_SYSTEMS` on every load, re-sends the
  current job's active binds 2 s later, through `bind_line`. A load where nothing was lost
  pays a few silent commands. The coroutine checks `windower._keybind_guard_seq`, so an
  older sandbox's re-bind never lays the previous job's keys over the new ones.

## Invariants & gotchas

- A job file must end with `KeybindManager.create(...)` and be kept in the global
  `<JOB>Keybinds`: KeybindGuard and `tb`'s `taken_by` read `_G[<main_job> .. 'Keybinds']`.
- A key used twice among the active entries keeps the last one, custom keys included.
- `visible` is only re-asked by `refresh()`; a job whose `visible` depends on a state must
  call `refresh()` when that state changes, as PLD does.
- `_CUSTOM` gear is equipped after the job's logic, so it overrides it, except where a
  guard holds the slot back. A new custom state starts at its first value on every load,
  like every Mote state.
- `tb` sends unknown words to the console, while a bind entry sends them to `gs c`: the
  same text does not do the same thing in both.

## Extending

- **New job keys**: add entries to `<JOB>_KEYBINDS.lua`; keep the anchors above; load and
  read the validator warnings in chat.
- **A key that runs another addon**: `command = '//<addon command>'` (or `raw = true`).
- **A new `when` condition**: add a test to `TESTS` in `custom_conditions.lua` **and** its
  expected type to `WHEN_TYPES` in `custom_states_validate.lua` (otherwise it is reported
  as unknown), and document it in the `_CUSTOM` template header.
- **A new guarded slot**: `SLOTS_BY_SPELL` / `SLOTS_BY_TYPE` in `custom_guards.lua`.

## Known issues

- **The intro never shows the macro book or the lockstyle** (all jobs; Z2-09). The
  wrappers return nothing, so `show_intro` always takes the short branch. Open: either the
  wrappers return their info, or the dead branch goes; the require's side effect must stay.
  Owner's decision.
- **`temp_binds.lua` restart detection is partial.** The file is dropped only when the
  saved `os.clock()` is larger than the current one. If the new game session has run longer
  than the old one had when it saved, the stale list is kept: `tb list` shows keys that are
  no longer bound and the free-key search skips them. The same flaw was fixed in
  `alt_state.lua` on 2026-09-25 (timestamp compared with `os.time()`); `temp_binds.lua` was
  not changed. Not verified in game.
- **Stale comment in `keybind_guard.lua`** (`desired_binds`): says only PLD and THF filter
  by subjob and the others bind their whole list; every job now goes through
  `get_active_binds`.
- **`eventArgs.no_overlay`** is tested in `Guards.hands_off` but nothing sets it.
- The RUN HUD anchor `RuneElement` (no such state) keeps the HUD init polling for 5 s after
  each RUN load; see [ui-overlay.md](ui-overlay.md). Not a keybind issue; RUN is only
  played by a frozen clone.
- **To check in game** (2026-09-25): a failing keybind file on BLM/BST/GEO shows its error
  in `[JOB] Keybinds failed to load: ...`.

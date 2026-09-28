# Keybinds, common keys, optional states, player modes (`_CUSTOM`) and temporary binds

Six pieces decide what a key does and what extra gear goes on:

1. **KeybindManager** (`shared/utils/keybinds/keybind_manager.lua`). Every job's `<JOB>_KEYBINDS.lua` is a plain data file that ends with `return require('shared/utils/keybinds/keybind_manager').create('<JOB>', module)`. The factory attaches the functions that the entry file, the HUD and KeybindGuard call: `get_active_binds`, `bind_all`, `refresh`, `unbind_all`, `show_intro` and `show_binds`.
2. **Optional states** (`shared/utils/core/optional_state.lua`). These are modes the project adds to every job, each shown or hidden per job: Combat Mode (`combat_mode.lua`) and Treasure Mode (`treasure_hunter.lua`). `create` attaches their HUD rows and keys to each job's bind list.
3. **Common keys** (`shared/utils/keybinds/common_keybinds.lua`). Keys that every job of a character gets, from `<Character>/config/COMMON_KEYBINDS.lua`.
4. **Key conflicts** (`shared/utils/keybinds/key_conflicts.lua`). When two entries want the same key, the conflict is reported, never resolved.
5. **Player modes and gear rules** (`shared/utils/custom/*.lua`). An optional `<Character>/config/<job>/<JOB>_CUSTOM.lua` adds Mote states with a key, and gear that goes on last, over what the job picked.
6. **Temporary binds** (`//gs c tb`, `shared/utils/keybinds/temp_binds.lua`). Keys made in game for a repetitive task, on Ctrl/Alt+F1-F8.

Two helpers sit beside them: `key_validator.lua` names keys that cannot work, and `shared/utils/core/keybind_guard.lua` re-sends the job's binds 2 s after each load.

## Files

| Path | Role |
|---|---|
| `shared/utils/keybinds/keybind_manager.lua` | Factory `KeybindManager.create(job, module)`, `bind_line`, `refresh_active`, `conflict_keys`, `show_possible_conflicts`; exported as `_G.KeybindManager` |
| `shared/utils/keybinds/key_validator.lua` | `KeyValidator.check(binds)`, `KeyValidator.is_valid_key(key)` |
| `shared/utils/keybinds/key_conflicts.lua` | Two actions on one key: live conflicts (chat block, red key in the HUD) and every possible one over subjobs and partner jobs (`//gs c kc`) |
| `shared/utils/keybinds/common_keybinds.lua` | `CommonKeybinds.load()`, `CommonKeybinds.merge_into(binds)` |
| `shared/utils/keybinds/temp_binds.lua` | `//gs c tb` subcommands and the `<Character>/temp_binds.lua` file; exported as `_G.TempBinds` |
| `shared/utils/keybinds/temp_binds_parse.lua` | Key words, action names, targets for `tb` |
| `shared/utils/core/keybind_guard.lua` | `KeybindGuard.schedule()`: one delayed re-bind per load; exported as `_G.KeybindGuard` |
| `shared/utils/core/optional_state.lua` | `OptionalState.create{...}`: base of Combat Mode and Treasure Mode (settings file, shown / hidden / key per job, `attach`) |
| `shared/utils/core/optional_state_commands.lua` | `OptionalStateCommands.create{...}`: the `//gs c <mode>` handler built for each optional state |
| `shared/utils/core/combat_mode.lua` | `CombatMode`: `state.CombatMode`, weapon lock through a `handle_equipping_gear` wrapper |
| `shared/utils/core/combat_mode_commands.lua` | `//gs c combatmode`, with the settings-file header |
| `shared/utils/equipment/treasure_hunter.lua` | `TreasureHunter.optional` (Treasure Mode definition); the gear side is documented in [factories-and-helpers.md](factories-and-helpers.md#treasurehunter) |
| `shared/utils/equipment/treasure_commands.lua` | `//gs c th`, with the settings-file header |
| `shared/utils/custom/custom_states.lua` | `CustomStates.load(job, binds)`, `CustomStates.install_hooks()`; exported as `_G.CustomStates` |
| `shared/utils/custom/custom_conditions.lua` | The `when = {...}` tests (`Conditions.holds`, `Conditions.collect_buffs`, `SLOT_IDS`) |
| `shared/utils/custom/custom_guards.lua` | Moments and slots the custom gear must not touch |
| `shared/utils/custom/custom_locks.lua` | `lock = {...}` slots of a custom value |
| `shared/utils/custom/custom_states_validate.lua` | Plain-language checks of each `_CUSTOM` entry |
| `shared/utils/messages/formatters/system/message_tempbind.lua` | `tb` messages (`TEMPBIND` namespace) |
| `_master/config/<job>/<JOB>_KEYBINDS.lua` | Job key templates for 16 jobs (every job but PUP); character overlays under `_master/<Character>/config/<job>/` may replace some |
| `_master/config/<job>/<JOB>_CUSTOM.lua` | Commented, empty `_CUSTOM` templates (16 jobs, every job but PUP; the Tetsouo overlay has its own SMN and WAR copies) |
| `_master/config_global/COMMON_KEYBINDS.lua` | Common keys template; character overlays in `_master/<Character>/config_global/` |

PUP has no `_KEYBINDS` file: `_master/config/pup/` does not exist and the job does not load (see [jobs/pup.md](../jobs/pup.md)). Without a keybind file, PUP would get no common keys, no Combat Mode row and no Treasure Mode row either.

## How it works

### Loading a job's keys

The entry file's `user_setup()` requires the keybind file after the states are configured, keeps it in a global named `<JOB>Keybinds` and calls `bind_all()`. From `_master/entry/Tetsouo_WAR.lua` `user_setup`:

```lua
local kb_success, keybinds = pcall(require, 'Tetsouo/config/war/WAR_KEYBINDS')
if kb_success and keybinds then
    WARKeybinds = keybinds
    WARKeybinds.bind_all()
else
    show_keybind_error(keybinds)
end
```

When the require fails, the entry prints `[<JOB>] Keybinds failed to load: <error>`, error included. `file_unload()` calls `<JOB>Keybinds.unbind_all()`.

Requiring the file runs `KeybindManager.create(job, module)`, which does the following, in this order:

1. Builds a private `ctx = {job, module, applied = {}, api = module}`, records `module` in `_G._keybind_active` if nothing is there yet, and attaches the six functions, each bound to `ctx`.
2. `CombatMode.attach(job, module.binds)`, then `TreasureHunter.optional.attach(job, module.binds)`: the two optional states (see below).
3. Appends the player's `_CUSTOM` keys (local `add_custom_states`, under `pcall`). A broken custom file costs the job nothing but its custom keys, and prints `<JOB>_CUSTOM.lua: <error>`.
4. Appends the common keys (`CommonKeybinds.merge_into`).
5. When at least one entry has a `weapon` field, registers `AltStates.on_weapon_change('keybinds', refresh_active)` (local `watch_own_weapon`).

The HUD loads the same file a second time, under another module name: `UI_LOADER.lua` requires `config/<job>/<JOB>_KEYBINDS`, while the entry requires `<Char>/config/...`. So `create` runs twice per load. The first module stays `_G._keybind_active`: that is the module `bind_all` lays the keys with, and the one `refresh_active`, `conflict_keys` and `show_possible_conflicts` use. `CustomStates.load` keeps its result in `_G._custom_state_cache` and hands the same bind entries to the second call, so the file is read, and its warnings shown, only once. The optional states record their "native" flag on the first `attach` of the sandbox for the same reason.

### Bind entries

Fields, as listed in the `keybind_manager.lua` header:

| Field | Meaning |
|---|---|
| `key` | Windower key (`^numpad1`). `""` = a HUD row only, nothing bound |
| `command` | What the key runs (see [bind_line](#what-a-key-sends-bind_line)) |
| `desc` | Label in the HUD and the chat lists |
| `state` | Mote state the HUD row displays |
| `subjob` / `exclude_subjob` | Only / never under this subjob (string or list) |
| `visible` | `function() -> boolean`, asked again on every `refresh()`. An error counts as hidden |
| `alt` | `{name, job, subjob, weapon}`, each optional, a string or a list: only bound while that box of the group plays it (no `name` = the tracked partner). `weapon` is the box's main-hand skill (`'Sword'`, `'Great Katana'`), compared without spaces or case. Nothing known about the box yet = not bound |
| `weapon` | Skill of **this** character's main hand (`'Club'`, `'Sword'`, `'Great Katana'`, `'None'` for an empty hand), string or list, compared without spaces or case (`AltStates.own_weapon_matches`). Only bound while the main hand has that skill. The main hand is read once per `get_active_binds()` pass. A weapon-type change (packet 0x050, main slot, read 0.5 s later) calls `refresh_active()` |
| `raw` | Send `command` exactly as written |
| `override` | Common entries only: win over a job or custom entry on the same key (see [Common keys](#common-keys)) |
| `section` | HUD section hint (custom entries: `mode`, `spell`, `ability`, `weapon`) |

Set by the project, not by the file: `_common` (a common entry) and `custom` (a `_CUSTOM` entry).

`<module>.retired_keys` lists keys that an older version of the file bound. They are unbound on every load; PLD keeps `^numpad7` there.

`get_active_binds()` keeps the entries whose `subjob`, `exclude_subjob`, `weapon`, `alt` and `visible` allow them now. It then drops the common entries without `override` whose key a job or custom entry applying now also uses. It returns `active, yielded`.

### What a key sends (`bind_line`)

`KeybindManager.bind_line(bind)` turns an entry into the text that follows `bind <key> `:

| `command` | Sent | Example |
|---|---|---|
| `raw = true` | exactly `command` | |
| starts with `//` | `command` without the `//`: a console command of any addon | `//sm mirror` -> `sm mirror` |
| starts with `/` | `input <command>`: a game command | `/p Ready!` -> `input /p Ready!` |
| anything else | `gs c <command>` | `cyclestate HybridMode` -> `gs c cyclestate HybridMode` |

The same function is used by `bind_all`, `refresh` and KeybindGuard, so a key laid down by the guard sends the same line.

### `bind_all`, `refresh`, `unbind_all`

**`bind_all(silent)`**:

1. With no bind list, calls `show_no_binds_error` and returns false.
2. Unless `silent`, runs `KeyValidator.check` and prints one warning per problem as `<JOB> keybinds: <problem>`.
3. Reports live conflicts (`note_conflicts`, once per conflict per load) and redraws the HUD when the keys in conflict changed.
4. Builds `desired` (key -> line) from the active entries. A key used twice keeps the **last** entry.
5. `clear_unwanted`: unbinds every key that is not wanted now and is either in the file, in `retired_keys` or in `windower._keybind_manager_bound`. A key about to be bound is **not** unbound first: a bind overwrites (see [Dead keys after a reload](#dead-keys-after-a-reload)).
6. Sends `bind <key> <line>` for each wanted key and records it in `windower._keybind_manager_bound`.
7. Shows the intro when at least one key went down. When no key went down although some should have, prints `<JOB> keybinds: none applied - keys will not respond`.

**`refresh()`** sends only the difference since the last `bind_all` / `refresh`, for `visible`, `alt` and `weapon` entries and for optional-state changes. A key that stays but changes command is only re-bound, never unbound first. `refresh` redraws the HUD when it sent anything or the conflicts moved. Callers:

- PLD's state-change hook (`PLD_COMMANDS.lua`, after a stance change: `/SCH` Tanking hides `MainWeapon`);
- `KeybindManager.refresh_active()`, which calls `refresh` on `_G._keybind_active`. It runs whenever `alt_states.lua` records a new job, subjob or weapon type for a box, whenever this character's main hand changes weapon type (entries with `weapon`), and after every `//gs c combatmode|th show|hide|key` (`optional_state_commands.lua` `refresh`).

**`unbind_all()`** runs `clear_unwanted` with nothing wanted, so it also removes keys that another job file of this manager left down. It then prints `<JOB> keybinds unloaded.`. Every entry file calls it from `file_unload()`.

### The key validator

`KeyValidator.check(binds)` returns one readable line per problem:

- an entry with no string `key`: `"<desc>": no key`;
- a key that is not modifiers (`^ ! @ # ~ % $`) followed by a known key name: `"<desc>": unknown key <key>`. Known names are letters, digits, `f1`-`f15`, `numpad0`-`numpad9`, `numpad* + - . /`, `numpadenter`, the usual named keys (`escape`, `tab`, `enter`, arrows, `pageup`...) and punctuation;
- a key with no command: `"<desc>": key <key> has no command`.

It only warns: the bind is still sent, in case Windower knows a key name the list does not. Windower never answers a `bind`, so without this check a misspelt key fails silently. Duplicate keys are not the validator's job any more: `key_conflicts.lua` reports them.

### The intro message

`show_intro()` lists the keyed active binds under `<JOB> SYSTEM LOADED`. It also requires the job's `<JOB>_MACROBOOK` and `<JOB>_LOCKSTYLE` wrapper modules and looks for `get_<job>_macro_info` and `get_info` on them. None of the 34 wrappers returns a table with those keys (16 return nothing; BLU's return tables without them). So `show_system_intro_complete` is never reached, and the intro never shows the macro book or the lockstyle (see Known issues). The require still matters: it defines `select_default_macro_book` and `select_default_lockstyle`, which `user_setup` calls before the facade is loaded.

### Common keys

`CommonKeybinds.load()` does `pcall(require, 'config/COMMON_KEYBINDS')`, so it reads the file of the character whose folder GearSwap loaded. No file means no common keys. `merge_into(binds)` appends every common entry that has both `key` and `command`, flags it `_common`, and marks the list with `binds._common_merged`, so a second call does nothing.

The final list is ordered job keys, then the optional-state entries appended by `attach`, then `_CUSTOM` keys, then common keys. `get_active_binds` decides at each pass who gets a key:

- a common entry without `override` gives way to a job or custom entry that applies on the same key now. A common key shadowed only by a `/WAR` job key is therefore still bound under `/DRK`;
- an entry with `override = true` wins while it applies;
- among the entries that apply at once, the later one in the list is bound (`key_map` keeps the last).

Common keys of the template (`_master/config_global/COMMON_KEYBINDS.lua`):

| Key | Command | Purpose |
|---|---|---|
| `#numpad0` | `cyclestate AutoMedicine` | Automatic Echo Drops / Remedy |
| `!numpad7` | `alts follow` | Alts follow this box (toggle) |
| `!numpad8` | `alts toggle` | Alts' automation on/off |
| `!numpad9` | `alts mirror` | Alts mirror |
| `!z` | `stealth sneak` | Sneak on you and every alt |
| `!x` | `stealth invi` | Invisible on you and every alt |

The `alts` commands order every other member of `DualBoxConfig.group` (see [dualbox.md](dualbox.md)), so every character of a group carries them. A character overlay (`_master/<Character>/config_global/COMMON_KEYBINDS.lua`) replaces the whole list. Of the overlays tracked today, one has no `!z` / `!x`, and two converted from BindManager use `raw = true` entries with `alt` and `override` layers.

### Key conflicts

`key_conflicts.lua` never changes a key; it only reports. Entries fall into three kinds:

- **job**: job file, `_CUSTOM`, optional states;
- **own**: a common key without `alt`;
- **partner**: a common key with `alt`.

| Pair | Reported? |
|---|---|
| job / job, job / own, job / partner, own / partner | yes |
| own / own (a common key and its subjob version) | no, layers on purpose |
| partner / partner (layers of one partner's keys) | no |
| two entries with the same command | no, nothing is lost |

- **Live** (`KeyConflicts.live(active, yielded)`, from `bind_all` / `refresh`). One InfoBlock per new conflict and per load (tag `KEYS`, title `<JOB> key conflict`, fields Key / Bound / Does nothing, and the hint "Keys unchanged. All possible conflicts: //gs c kc"). The keys are kept in `module._conflict_keys` (`KeybindManager.conflict_keys()`), and the HUD draws them in the `conflict` colour (`UI_SECTIONS.lua` flags the row, `UI_FORMATTER.lua` colours it). `bind_all` and `refresh` redraw the HUD through `Display.update_display()` when the set of keys in conflict changes: `KeybindUI.update()` would skip it, since it redraws only when a Mote state changed.
- **Possible** (`//gs c keyconflicts`, `kc`; `KeyConflicts.possible(binds)`). Every pair of entries on one key that can apply together, over all 22 subjobs and the partner conditions (`alts_compatible`, `shared_subjobs`). `visible` conditions are assumed true. Output is grouped per key as `[subjobs] lost < winner | winner`.

### Optional states: Combat Mode and Treasure Mode

An optional state is a mode the project adds to jobs, shown or hidden per job. `OptionalState.create{id, state, description, values, file, default_key, on_attach}` returns an object with these functions:

| Function | Behaviour |
|---|---|
| `settings_path()` | `<addon>/data/<player.name>/config/<file>`, nil before the player is known |
| `settings()` | `{shown, hidden, keys}`, read once per sandbox with `dofile` (cached in `_G._<id>_settings`). Job codes are normalised by `by_job`: `thf` counts as `THF`, `ALL` as `all` |
| `is_shown(job)` | `hidden[job]` -> false; `shown[job]` or `shown.all` (unless `hidden.all`) -> true; `hidden.all` -> false; else the "native" flag: the job's own STATES file defined the state (`_G._<id>_native`, recorded on the first `attach` of the sandbox) |
| `value()` | The state's value when the job shows it, else nil |
| `entry()` | The job's bind entry for the mode (`_G._<id>_entry`) |
| `attach(job, binds)` | Records the native flag. Creates `state[<state>] = M{description, values...}` when the job has none (the first value is the default). Runs `on_attach(job)`. Reuses the job's own entry for that state or appends `{key = default_key, command = 'cyclestate <State>', ...}`. Applies `keys[job] or keys.all`. Wraps `visible` with `is_shown(job)`. Called by `KeybindManager.create` |

`OptionalStateCommands.create{optional, command, label, tag, header, status, subtitle, notes, extra, extra_rows}` returns `{handle(args)}`:

| Command | Effect |
|---|---|
| `//gs c <cmd>` | InfoBlock: Shown, the `status(job)` fields, Key |
| `//gs c <cmd> show` / `hide` | Sets `shown[job]` or `hidden[job]`; `hide` also resets the state to its first value (under `pcall`: THF has no Treasure Mode `Off`) |
| `//gs c <cmd> key <key>\|none` | Validates the key with `KeyValidator.is_valid_key`, stores it (`none` = `''`, no key) and updates the entry |
| `//gs c <cmd> help` | HelpScreen |
| other word | `extra(sub, args, job)`, else "Unknown: <sub>" |

Every change rewrites the whole settings file, starting with the mode's `header` (so the explanation in the file always comes from the code), then calls `KeybindManager.refresh_active()` and `Display.update_display()`, and sends `gs c update`.

| | Combat Mode | Treasure Mode |
|---|---|---|
| Module | `shared/utils/core/combat_mode.lua` | `shared/utils/equipment/treasure_hunter.lua` (`TreasureHunter.optional`) |
| State / values | `CombatMode`: `Off`, `On` | `TreasureMode`: `Off`, `Tag`, `Full` (THF's own STATES: `Tag`, `SATA`, `Full`) |
| Settings file | `<Character>/config/combat_mode.lua` | `<Character>/config/treasure_mode.lua` |
| Native (shown by default) | BLM, GEO, RDM, WHM | THF |
| Key when native | the job file's own entry: BLM `^numpad8`, GEO `^numpad0`, RDM `^numpad5`, WHM `^numpad2` | THF `^numpad3` |
| Default key elsewhere | `!numpad0` (free on every job file) | `!numpad.` |
| Command | `//gs c combatmode` | `//gs c th` (+ `clear`: forget the tagged mobs) |
| Effect | Weapon lock (below) | TH gear until the mob is tagged ([factories-and-helpers.md](factories-and-helpers.md#treasurehunter)) |
| Kept across a re-clone | yes (`clone_character.py` `KEPT_ON_RECLONE`) | yes |

**Combat Mode lock.** `CombatMode.install_hook()` runs from `INIT_SYSTEMS`, after the custom-state hooks, so its wrapper is the outermost and runs first. It wraps `handle_equipping_gear` and calls `CombatMode.apply()` before any gear:

- **On and shown**: disables main, sub and range, plus ammo on BLM, GEO and WHM (`SLOTS_BY_JOB`), and records the slots in `windower._combat_mode_locked`.
- **Otherwise**: enables what it locked, unless a craft session is active (`_G.CraftManager.is_active()`).

GearSwap keeps a disabled slot across a job change. So the next load's `attach` (its `on_attach`) frees what was locked, and the new job starts Off. Other users of the lock:

- `custom_locks.lua` never enables a weapon slot while Combat Mode is on;
- `spell_gear_lock.lua` opens the lock for a spell that needs a piece (Dispelga), then calls `CombatMode.apply()` again after the cast;
- BLM's `job_state_change` equips Bunzi's Rod, Ammurapi Shield and Sroda Tathlum when Combat Mode turns On (queued behind the lock);
- RDM's and BLU's set builders skip the weapon states while it is On.

### Player modes and gear rules (`<JOB>_CUSTOM.lua`)

The file is `<addon>/data/<player.name>/config/<job>/<JOB>_CUSTOM.lua`. It is read with `dofile` under `pcall` at every load, so a `gs reload` picks up an edit. It returns a list of entries of two kinds:

- **Mode**: `{ state = 'Name', desc, key, values = {...} | 'onoff', section, subjob, exclude_subjob, <Value> = { <moment> = gear, lock = {...}, when = {...} } }`.
  - A new state is created: `M(false, desc)` for `'onoff'`, else `M{description = desc, ...values}`.
  - A state the job already has is reused. `values` is then ignored (with a warning) and only its gear blocks count, so `state = 'HybridMode'` can add pieces to the job's `PDT`.
  - The key goes into the job's bind list as `cyclestate <Name>`, flagged `custom = true`, so the HUD, the validator, the conflict report and KeybindGuard all see it like any job key.
- **Rule**: `{ when = {...}, <moment> = gear }`, with no state and no key. The gear goes on whenever `when` holds.

A value block is matched to the state's current value case-insensitively.

**Locks** (`custom_locks.lua`). A value block may hold `lock = {slot, ...}`. The wrapped `handle_equipping_gear` then:

1. collects the slots of the active value blocks (`wanted_locks`);
2. enables the slots it locked earlier that are no longer wanted (`CustomLocks.release`), before the job's gear, so the job can dress them;
3. equips;
4. disables the wanted slots (`CustomLocks.apply`), after the gear, so that a CP cape, for example, can go on first.

What it locked is kept in `windower._custom_locked`. The first `CustomStates.load` of a sandbox releases it, since GearSwap keeps a disabled slot across a job change. A weapon slot is not enabled while Combat Mode is on. Only mode entries lock; a `lock` in a rule is ignored. Actions do not re-check locks: a value change goes through `handle_update`, which calls `handle_equipping_gear`.

**Moments.** `idle`, `engaged`, `weaponskill`, `ability`, `precast`, `midcast`, `all`. A moment holds pieces `{slot = item}` or the name of an existing set (`'sets.engaged.Acc'`, resolved from `_G` at equip time by `resolve_gear`).

**Where the gear goes on.** `CustomStates.install_hooks()` runs from `INIT_SYSTEMS`, not from `user_setup`: Mote runs `user_setup` before it defines the functions below. The hooks are installed once per sandbox, and only when the job has entries. They are installed after ElementalBelt, DualWield, TreasureHunter and MidcastFallback, so the custom gear goes on after all of them:

| Wrapped | Moments equipped after the original |
|---|---|
| `handle_equipping_gear(status)` | `all`, then `engaged` or `idle`; skipped when `Guards.hands_off` is true or while a COR roll holds the gear (`GearHold.active()`, `shared/utils/core/gear_hold.lua`, since 2026-09-28) |
| `cleanup_precast` | weaponskill: `all`, `weaponskill`; magic: `all`, `precast`; ability: `all`, `ability`; other: `all` |
| `cleanup_midcast` | same, with `midcast` for magic. Weaponskills and abilities get their precast moment again, since they go off with the midcast gear |
| `user_buff_change` | re-runs `handle_equipping_gear` when a buff named in a `buff` / `no_buff` condition changes, outside an action, while Idle or Engaged |

Entries are equipped in file order, so a later entry wins on the same slot. Slot locks still win, as for any `equip()`. At the end of an action, the gear goes on in this order: the set (and the midcast fallback), the Obi / Orpheus belt, Treasure Hunter, then the CUSTOM gear.

**`when` conditions** (`custom_conditions.lua`, table `TESTS`). Every key must hold (AND); a list value holds if any item matches (OR). Names compare case-insensitively, and a trailing `*` matches a prefix.

| Key | Holds when |
|---|---|
| `buff` / `no_buff` | a listed buff is active / none is (name or id) |
| `weapon` | the item in `main` (the one this action is equipping first, else the worn one), or the `MainWeapon` state's value |
| `sub`, `range`, `ammo` | the item in that slot, same lookup |
| `subjob` / `no_subjob` | current subjob |
| `mode = {State = 'Value'}` | each named state has one of the values |
| `hp_below`, `hp_above`, `mp_below`, `mp_above` | HP / MP percent |
| `tp_below`, `tp_above` | TP, read from the game (`live_tp`) |
| `spell` | the action's English name |
| `skill` | the action's skill |
| `spell_type` | the action's `type` (`WhiteMagic`, `BardSong`, `WeaponSkill`, `JobAbility`...) |
| `element` | the action's element |
| `day_weather = true/false` | the action's element matches the day, or the weather |
| `target` | `self`, `other` (player or NPC), `enemy` |
| `distance_below` | distance to the action's target |
| `obi_better` / `orpheus_better` | Hachirin-no-Obi's bonus for the action's element beats Orpheus's Sash's, or the reverse; ties go to Orpheus. Obi: day ±10, weather ±10 / ±25, storms included. Orpheus: +15 up to 1.93 yalms, +1 from 13, linear in between. Computed by `shared/utils/equipment/elemental_bonus.lua`. A belt not in the inventory or wardrobes counts as 0 (`ElementalBelt.owned`), so a rule never asks for a missing belt. `ElementalBelt` already makes this choice for every job; a CUSTOM rule runs after it and wins |
| `obi_bonus_above` | the Obi's bonus is above this many percent (for a player without Orpheus); 0 when the Obi is not owned |
| `town`, `moving`, `pet` | true / false |
| `engaged` | true = the player's status is `Engaged`, false = any other status. With `engaged = false`, a weapon slot at a combat moment is not reported by the validator |
| `zone` | zone name |

The action keys (`spell`, `skill`, `spell_type`, `element`, `day_weather`, `target`, `distance_below`, `obi_better`, `orpheus_better`, `obi_bonus_above`) never hold at idle or engaged. An action with no element, such as most physical weaponskills, never passes the belt keys. An unknown key, or a test that errors, makes the whole `when` false.

**Guards** (`custom_guards.lua`), applied automatically:

- `Guards.hands_off` puts nothing at all: while Doomed; on a cancelled action; for ranged attacks, items, pet moves and Blood Pacts; outside Idle / Engaged; and for Paralyna while paralysed.
- `Guards.blocked_slots` leaves these slots alone:
  - Impact: body, head;
  - Dispelga: main, sub;
  - songs: range, ammo;
  - Phantom Roll and Double-Up: rings;
  - Call Beast and Bestial Loyalty: ammo;
  - the ammo while the Hoxne stance or its Ampulla lock is on;
  - the Treasure Hunter pieces when engaged and TH is wanted (asked of the shared `shared/utils/equipment/treasure_hunter` module, `wants_engaged_th`);
  - every slot in GearSwap's `disable_table`.

**Validation** (`custom_states_validate.lua`, `Validate.entry(entry, states, index)`), printed at load as `<JOB>_CUSTOM: <problem>`:

- **Fatal, entry skipped** (` (skipped)` appended):
  - not a `{...}` block;
  - no `state` and no `when`;
  - a state name that is not one word of letters, digits and `_`;
  - a new state without `values`.
- **Warnings**:
  - `values` on an existing state;
  - an unknown field;
  - a `lock` that is not a list, or that names an unknown slot;
  - a block named after a value the state does not have;
  - an unknown moment or an unknown slot;
  - a weapon slot (main, sub, range) in `engaged`, `weaponskill`, `ability` or `all` ("changing <slot> in combat loses your TP"), unless the block's `when` has `engaged = false`;
  - a gear value that is neither a table nor a set name;
  - an unknown condition, or a condition value of the wrong type (`WHEN_TYPES`);
  - a `section` other than `mode`, `spell`, `ability`, `weapon`.

Keys of custom entries are not checked here: they go through the key validator and the conflict report with the job's keys, at `bind_all`. A custom key that is also a job key is reported as a conflict, and the custom entry wins because it comes later in the list.

Every custom equip is written to the trace log (`CUSTOM` tag) when `//gs c trace` is on.

### Temporary binds (`//gs c tb`)

`COMMON_COMMANDS.lua` routes `tb` to `TempBinds.handle(args)`.

| Command | Effect |
|---|---|
| `//gs c tb <key> <action> [target]` | bind a key |
| `//gs c tb <action> [target]` | same, on the first free key of Ctrl+F1-F8, then Alt+F1-F8 (`AUTO_KEYS`, local `free_key`) |
| `//gs c tb force <key> ...` | bind even over a key in use |
| `//gs c tb list` | what is bound |
| `//gs c tb del <key>` | unbind one |
| `//gs c tb clear` | unbind all |
| `//gs c tb help` (or `?`) | full help |
| `//gs c tb` | usage |
| `//gs c tb run <key>` | what the key itself sends |

**Keys** (`Parse.key`). Accepted forms: the Windower form (`^f1`), words (`ctrl+f1`, `alt+`, `shift+`, `win+`, `apps+`), or short letters (`cf1`, `caf1`, `cn1` = Ctrl+Numpad1). A word that looks like a key but is not one (`ctrl+fx`, `^f13`; `Parse.looks_like_key`) is reported instead of being read as the start of the command.

**What the key sends** (`Parse.command`). This differs from `bind_line` in the last case:

| Words after the key | Stored command |
|---|---|
| `//cmd ...` | the console command `cmd ...` |
| `/ma`, `/ja`, `/ws`, `/item` + name | the action, name completed from the game resources, restricted to that kind |
| any other `/cmd` | `input /cmd ...` |
| words that start with an action name | `input /ma "<Name>"` (or `/ws`, `/ja`, `/item`); spells win over the other kinds |
| anything else | sent to the console **as typed** (not `gs c`) |

Name matching slugs the text the way the Shortcuts addon does: case, spaces and punctuation are ignored, and digits are read as roman numerals, so `dia2` is Dia II. What follows the action name is the target:

- `t`, `st`, `stnpc`, `stpc`, `stpt`, `stal`, `bt`, `me`, `pet`, `lastst`, `ht`, `ft`, `r` become `<t>`, `<st>`...;
- any other word is a name. It is looked up at **each press** (`Parse.resolve`) as the nearest valid mob, player or NPC of that name within 50 yalms, and sent as its raw id, without angle brackets.

The key itself is bound to `gs c tb run <key>`. The stored command is resolved when the key is pressed, so the target can move or respawn.

**Checks before binding** (local `taken_by`):

- Reserved keys (`RESERVED`): Mote's F9-F12 block with every modifier, plus `^-` and `^=`, and `^v` (Windower paste).
- A key in the current job's active binds is reported with its owner. Common keys count too, since they are merged into the job's list.

`force` skips that check. A job key taken with `force` is only borrowed: the next `bind_all` (next load) or KeybindGuard binds the job's command again.

**Storage.** The binds are kept in `<addon>/data/<Char>/temp_binds.lua`, rewritten on every change. The file holds `clock = os.clock()` and the key -> command table. It is a file because `//lua r gearswap` wipes GearSwap's memory but not Windower's binds, and `clear` must still find them. On read, a saved clock larger than the current `os.clock()` means the game was restarted (its binds are gone), and the list is treated as empty. The decision is traced under `TB`.

## Keys per job

What each job's key list binds, read from the `_master` templates. `cyclestate X` is written as the state name `X`; any other command is in backquotes. A character overlay can replace a job file. Keys are Windower notation: `^` Ctrl, `!` Alt, `#` Apps, `~` Shift, `@` Win.

### Job files (`<JOB>_KEYBINDS.lua`)

| Job | Ctrl + numpad (`^`) | Apps + numpad (`#`) | Conditions |
|---|---|---|---|
| BLM | 1 SpellTier, 2 AOETier, 3 MainLightSpell, 4 MainDarkSpell, 5 MainLightAOE, 6 MainDarkAOE, 7 Storm, 8 CombatMode, 9 HybridMode, 0 MagicBurstMode | 3 SubLightSpell, 4 SubDarkSpell, 5 SubLightAOE, 6 SubDarkAOE, 7 DeathMode, 8 SneakInviAOE, 9 KlimaformAOE | |
| BLU | 1 MainWeapon, 2 SubWeapon, 3 OffenseMode, 4 IdleMode, 5 CastingMode, 6 WeaponskillMode | | |
| BRD | 1 MainWeapon, 2 SubWeapon, 3 MainInstrument, 4 IdleMode, 5 EngagedMode, 6 SongMode, 7 VictoryMarch, 8 MarcatoSong, 0 CarolElement, `.` ThrenodyElement | 1 EtudeType, 2 AutoNitro | |
| BST | 1 WeaponSet, 2 SubSet, 3 PetIdleMode, 4 AutoPetEngage, 5 `ecosystem`, 6 `species`, 9 HybridMode | | `ecosystem` / `species` are BST job commands |
| COR | 1 MainWeapon, 2 RangeWeapon, 3 QuickDraw, 4 MainRoll, 5 SubRoll, 6 LuzafRing, 9 HybridMode | | |
| DNC | 1 MainWeapon, 2 SubWeaponOverride, 3 MainStep, 4 AltStep, 5 UseAltStep, 6 ClimacticAuto, 7 JumpAuto, 8 Dance, 9 HybridMode, 0 Samba | | |
| DRK | 1 MainWeapon, 2 WeaponskillMode, 9 HybridMode | | |
| GEO | 1 SpellTier, 2 AOETier, 3 MainIndi, 4 MainGeo, 5 MainLightSpell, 6 MainDarkSpell, 7 MainLightAOE, 8 MainDarkAOE, 9 HybridMode, 0 CombatMode, `.` LuopanMode, `+` IndicolureMode | | |
| PLD | 1 MainWeapon, 2 PhalanxSIRD / Regen, 3 RuneMode / PhalanxSIRD, 4 Xp, 5 WS1, 6 WS2, 9 HybridMode | | 1 has a `visible` test (hidden in `/SCH` Tanking); 2 = PhalanxSIRD except `/SCH`, Regen on `/SCH`; 3 = RuneMode on `/RUN`, PhalanxSIRD on `/SCH`; 4 only on `/RDM`; `retired_keys = {'^numpad7'}` |
| PUP | none | | no keybind file (the job does not load) |
| RDM | 1 MainWeapon, 2 SubWeapon, 3 EnfeebleMode, 4 IdleMode, 5 CombatMode, 6 EngagedMode, 7 NukeMode, 8 NukeTier, 9 EnfeebleTier, 0 SaboteurMode, `.` EnSpell, `+` GainSpell, `-` Barspell, `*` BarAilment, `/` Spike | 1 Storm | `#numpad1` only on `/SCH` |
| RUN | 1 MainWeapon, 2 SubWeapon, 3 RuneMode, 9 HybridMode | | |
| SAM | 1 MainWeapon, 2 OffenseMode, 3 WeaponskillMode, 9 HybridMode | | |
| SMN | 1 IdleMode, 2 CastingMode, 3 AvatarFavor | | |
| THF | 1 MainWeapon, 2 SubWeapon, 3 TreasureMode, 4 `toggle AbyProc`, 5 AbyWeapon, 6 `toggle RangeLock`, 9 HybridMode | | 4 and 5 only on `/WAR`; `toggle` is Mote's command |
| WAR | 1 MainWeapon, 2 JumpAuto, 3 WS1, 4 WS2, 5 WS3, 6 WS4, 7 WS5, 9 HybridMode | | |
| WHM | 1 IdleMode, 2 CombatMode, 3 CureMode, 4 CureAutoTier, 5 AfflatusMode, 6 CastingMode | | |

### Keys added on top of the job file

| Source | Key | Jobs | Shown / bound by default |
|---|---|---|---|
| Combat Mode, native entry | BLM `^numpad8`, GEO `^numpad0`, RDM `^numpad5`, WHM `^numpad2` | BLM, GEO, RDM, WHM | yes |
| Combat Mode, added entry | `!numpad0` | the 12 other jobs with a keybind file | no: hidden until `//gs c combatmode show` (or `shown` in `combat_mode.lua`) |
| Treasure Mode, native entry | THF `^numpad3` | THF | yes |
| Treasure Mode, added entry | `!numpad.` | the 15 other jobs with a keybind file | no: hidden until `//gs c th show` |
| `COMMON_KEYBINDS` | `#numpad0`, `!numpad7`, `!numpad8`, `!numpad9`, `!z`, `!x` | every job with a keybind file | yes |
| `<JOB>_CUSTOM.lua` | the player's own | per character | yes (templates are empty) |
| Mote-Include (`Mote-Globals.lua` `global_on_load`, every job file load) | `f9` OffenseMode, `^f9` HybridMode, `!f9` RangedMode, `@f9` WeaponskillMode, `f10` DefenseMode Physical, `^f10` PhysicalDefenseMode, `!f10` Kiting, `f11` DefenseMode Magical, `^f11` CastingMode, `f12` `update user`, `^f12` IdleMode, `!f12` `reset DefenseMode`, `^-` `toggle selectnpctargets`, `^=` `cycle pctargetmode` | every job | yes (outside KeybindManager: not in the HUD, not in the conflict report) |
| `//gs c tb` | `^f1`-`^f8`, `!f1`-`!f8` by default | every job | when the player makes one |

The keys in `settings.keys` of `combat_mode.lua` / `treasure_mode.lua` replace the entry's key for that job (or `all` jobs).

### Key layout (project convention)

`.claude/rules/keybinds.md` is the rule; nothing in the code enforces it.

- Numpad keys, always with a modifier, so the bare numpad stays free for the game and for addons that send numpad presses.
- `^numpad9` is `HybridMode` on every job that has one; a job without it should leave the key empty. BRD, WHM, SMN and BLU leave it empty, but RDM puts `EnfeebleTier` there (see Known issues).
- `^numpad3` is the job's most-cycled state: WAR `WS1`, PLD/RUN `RuneMode`, THF `TreasureMode`, DNC `MainStep`, COR `QuickDraw`, BST `PetIdleMode`, BRD `MainInstrument`, RDM `EnfeebleMode`, BLM `MainLightSpell`, GEO `MainIndi`, WHM `CureMode`, SMN `AvatarFavor`, BLU `OffenseMode`, SAM `WeaponskillMode`. DRK has none.
- `^numpad1` / `^numpad2` are the weapon slots when the job has weapon states; otherwise they carry job binds.
- `#numpad0`, `!numpad7`-`!numpad9`, `!z` and `!x` come from `COMMON_KEYBINDS`; `!numpad0` and `!numpad.` are the optional states' default keys. Do not reuse them in a job file: the job key would win, and the conflict would be reported on every load.
- F9-F12 (with modifiers), `^-` and `^=` are Mote-Include's; Ctrl/Alt+F1-F8 are `tb`'s.
- A bind change goes in the template (`_master/config/<job>/`) and in the live copy (`<Char>/config/<job>/`); they are separate files.

## Public API

### KeybindManager (`keybind_manager.lua`, `_G.KeybindManager` + returned module)

| Function | Behaviour | Callers |
|---|---|---|
| `create(job, module)` -> module | Attaches the six functions, the optional states, custom and common keys, the weapon listener | the last line of every `<JOB>_KEYBINDS.lua` |
| `bind_line(bind)` -> string | Console line for an entry | `bind_all`, `refresh`, KeybindGuard |
| `conflict_keys()` -> set | Keys in conflict at the last pass of `_G._keybind_active` | HUD (`UI_SECTIONS.lua`) |
| `show_possible_conflicts()` -> boolean | `KeyConflicts.show_possible(main_job, binds)`; false when no module is loaded | `//gs c kc` |
| `refresh_active()` -> number | `refresh()` on `_G._keybind_active` | `alt_states.lua`, the weapon listener, `optional_state_commands.lua` |

Per-module functions (attached by `create`): `get_active_binds()` -> active, yielded; `bind_all(silent)` -> boolean; `refresh()` -> commands sent; `unbind_all()` -> boolean; `show_intro()`; `show_binds()` (`MessageFormatter.show_keybind_list`). Callers: entry files (`bind_all`, `unbind_all`), PLD (`refresh`), KeybindGuard and `tb` (`get_active_binds`), the HUD (`get_active_binds`).

### Other modules

| Module | Function | Behaviour |
|---|---|---|
| KeyValidator | `is_valid_key(key)` | Modifiers + known name |
| KeyValidator | `check(binds)` | List of problems |
| KeyConflicts | `counts(a, b)` | Whether two entries on one key are a conflict |
| KeyConflicts | `yields(bind)` | Common entry without `override` |
| KeyConflicts | `live(active, yielded)` | `{key, bound, lost}` per key now |
| KeyConflicts | `possible(binds)` | `{key, bound, lost, subjobs}` for every compatible pair |
| KeyConflicts | `report(job, list, told)` | InfoBlock, once per conflict per load |
| KeyConflicts | `show_possible(job, binds)` | `//gs c kc` output |
| CommonKeybinds | `load()` | `config/COMMON_KEYBINDS.binds` or `{}` |
| CommonKeybinds | `merge_into(binds)` -> number added | Appends once per list |
| KeybindGuard | `schedule()` | Re-sends the active binds of `_G[<main_job> .. 'Keybinds']` after 2.0 s, unless a newer load bumped `windower._keybind_guard_seq` |
| TempBinds | `handle(args)` -> true | `//gs c tb` |
| Parse (`temp_binds_parse.lua`) | `key(text)`, `looks_like_key(text)`, `show_key(key)`, `command(words)`, `resolve(command)`, `show_command(command)` | Parsing and display for `tb` |
| OptionalState | `create(cfg)` | See [Optional states](#optional-states-combat-mode-and-treasure-mode) |
| OptionalStateCommands | `create(cfg)` -> `{handle}` | Same |
| CombatMode | `is_on()` | `Optional.value() == 'On'` |
| CombatMode | `apply()` | Lock or free the weapon slots |
| CombatMode | `install_hook()` | Wrap `handle_equipping_gear` once per sandbox (`_G._combat_mode_hook`) |
| CombatMode | `attach`, `settings`, `settings_path`, `is_shown`, `_optional` | From the optional state |
| CustomStates | `load(job, binds)` -> count | Read, validate, create states, append keys; cached per sandbox |
| CustomStates | `install_hooks()` | See above |
| Conditions (`custom_conditions.lua`) | `holds(when, spell)`, `collect_buffs(when, into)`, `SLOT_IDS`, `TESTS` | |
| Guards (`custom_guards.lua`) | `hands_off(spell, eventArgs)`, `blocked_slots(moment, spell)`, `filter(gear, blocked)` | |
| CustomLocks | `release(wanted)`, `apply(wanted)`, `collect(block, into)` | |
| Validate (`custom_states_validate.lua`) | `entry(entry, states, index)` -> problems, fatal | |

## Configuration

| File | Content |
|---|---|
| `<Char>/config/<job>/<JOB>_KEYBINDS.lua` | the job's entries, `retired_keys` |
| `<Char>/config/COMMON_KEYBINDS.lua` | `CommonKeybinds.binds`, same entry format (+ `override`) |
| `<Char>/config/combat_mode.lua`, `treasure_mode.lua` | `{shown, hidden, keys}` per job; rewritten by the commands, header included |
| `<Char>/config/<job>/<JOB>_CUSTOM.lua` | modes and rules; the templates are fully commented and return `{}` |
| `<Char>/temp_binds.lua` | written by `tb`, not edited by hand |

## State & lifetime

| What | Lives in | Lifetime |
|---|---|---|
| Windower binds | the engine | survive every load; removed by `unbind_all` in `file_unload`, or by the next `bind_all` |
| Keys this manager laid down | `windower._keybind_manager_bound` | survives loads, so a key removed from a file is unbound at the next load |
| Pending guard re-bind | `windower._keybind_guard_seq` | a newer load cancels the older one |
| `ctx.applied`, `ctx.conflicts_told` | module local | one sandbox |
| Job module for refresh / conflicts | `_G._keybind_active` | one sandbox |
| Optional-state settings, native flag, entry | `_G._combat_mode_settings/_native/_entry`, `_G._treasure_mode_*` | one sandbox |
| Combat Mode lock | `windower._combat_mode_locked` | until freed by `apply()` or the next load's `attach` |
| Custom entries, watched buffs, hooks, cache | `_G._custom_state_entries`, `_custom_state_buffs`, `_custom_state_hooks`, `_custom_state_cache` | one sandbox; hooks are laid again after each load |
| Custom locks | `windower._custom_locked` | until released by the next load's `CustomStates.load` |
| Temporary binds | `<Char>/temp_binds.lua` + Windower binds | until `tb del` / `clear`, or the game restarts |

A subjob change reruns `user_setup()` in the same sandbox, so `bind_all` runs again (the module is cached, so custom files are not read a second time), then JobChangeManager reloads. `unbind_all` does not touch `tb` keys unless the job file also uses them.

### Dead keys after a reload

A key could stay dead after a reload while `//gs c` still worked. The binds were sent. But binds are Windower console commands, and a load sends its whole list in one burst, on top of the unbind burst from the outgoing file's `file_unload`. Two things handle it:

- `bind_all` no longer unbinds a key it is about to bind (`clear_unwanted`);
- `KeybindGuard.schedule()`, called from `INIT_SYSTEMS` on every load, re-sends the current job's active binds 2 s later, through `bind_line`. A load where nothing was lost pays a few silent commands. The coroutine checks `windower._keybind_guard_seq`, so an older sandbox's re-bind never lays the previous job's keys over the new ones.

## Invariants & gotchas

- A job file must end with `KeybindManager.create(...)`, and its module must be kept in the global `<JOB>Keybinds`: KeybindGuard and `tb`'s `taken_by` read `_G[<main_job> .. 'Keybinds']`.
- Among the active entries, a key used twice keeps the last one, custom keys included; the other is reported as a conflict.
- `visible` is only re-asked by `refresh()`. A job whose `visible` depends on a state must call `refresh()` when that state changes, as PLD does.
- `_CUSTOM` gear is equipped after the job's logic, so it overrides it, except where a guard holds the slot back. A new custom state starts at its first value on every load, like every Mote state.
- `tb` sends unknown words to the console, while a bind entry sends them to `gs c`: the same text does not do the same thing in both.
- An optional state hidden on a job keeps its HUD row and key hidden, and `value()` returns nil. For Combat Mode that means no lock; for Treasure Mode, no TH gear.

## For maintainers / AI

### Adding a key to a job

1. Edit `_master/config/<job>/<JOB>_KEYBINDS.lua` (and the live copy `<Char>/config/<job>/`). Add `{key, command, desc, state}`; follow the layout convention above.
2. Check the key against:
   - the common keys: `#numpad0`, `!numpad7`-`9`, `!z`, `!x`;
   - the optional-state defaults: `!numpad0`, `!numpad.`;
   - Mote's F9-F12, `^-` and `^=`;
   - `tb`'s Ctrl/Alt+F1-F8.
3. Reload and read the chat. The validator names a misspelt key; the conflict block names a shared key. `//gs c kc` shows the conflicts on every subjob.
4. For a state the job's STATES file does not define, add the state there first. A `cyclestate` key on a missing state prints "Unknown state".

### Adding a common key

Add it to `_master/config_global/COMMON_KEYBINDS.lua` and to the character overlays that should get it. An overlay replaces the whole list, so the new key must be copied into each overlay. Set `override = true` only if it must beat job keys.

### Adding a `when` condition

1. Add the test to `TESTS` in `custom_conditions.lua`: `function TESTS.<name>(value, spell)`.
2. Add its expected type to `WHEN_TYPES` in `custom_states_validate.lua`. Without this step, every use is reported as an unknown condition.
3. If it is an action key, make it return false when `spell` is nil.
4. If it reads a buff, have `collect_buffs` see it, so buff changes re-dress.
5. Document it in the `_CUSTOM` template headers (`_master/config/<job>/<JOB>_CUSTOM.lua`) and in this page's table.

### Adding a guarded slot or moment

- A guarded slot goes in `SLOTS_BY_SPELL` / `SLOTS_BY_TYPE` in `custom_guards.lua`.
- A new moment needs `MOMENTS` / `MOMENT_LIST` in the validator and a place in `action_moments` / `hooks.gear` in `custom_states.lua`.

### Adding a new optional state

Build it the way `treasure_hunter.lua` does:

1. `OptionalState.create{id, state, description, values, file, default_key}`;
2. call its `attach` from `KeybindManager.create`;
3. route a command through `OptionalStateCommands.create{...}` with a self-explaining `header`;
4. add the file to `KEPT_ON_RECLONE` in `clone_character.py`;
5. add the new `_G._<id>_*` names to `global_probe.lua` `EXPECTED`.

### Traps

- The keybind file is required twice per load (entry and HUD). Anything `create` does must be idempotent per sandbox: use `_G` markers, as `CustomStates.load`, `OptionalState.attach` and `merge_into` do.
- `user_setup` runs inside `include('Mote-Include.lua')`, before Mote defines `handle_equipping_gear` and `cleanup_*`. Hooks go in `INIT_SYSTEMS`, never in `user_setup`.
- Slots disabled by the project (Combat Mode, CUSTOM locks, craft) survive a job change in GearSwap. Record them on `windower` and free them at the next load.
- A job command and an alt command can share a name (see [commands-and-debug.md](commands-and-debug.md#4-alt-commands-and-name-shadowing)). A key that runs `gs c <name>` runs the job's command, not the alt's.

## Known issues

- **The intro never shows the macro book or the lockstyle** (all jobs). No wrapper returns `get_<job>_macro_info` / `get_info`, so `show_intro` always takes the short branch. Open: either the wrappers return their info, or the dead branch goes; the side effect of the require must stay.
- **`temp_binds.lua` restart detection is partial.** The file is dropped only when the saved `os.clock()` is larger than the current one. If the new game session has already run longer than the old one had when it saved, the stale list is kept: `tb list` shows keys that are no longer bound, and the free-key search skips them. Not verified in game.
- Fixed 2026-09-28: `KeybindGuard` re-sent rows with an empty key (HUD only, or `combatmode` / `th key none`) as `bind  gs c ...`; it now skips them like KeybindManager, and its header comment no longer says only PLD and THF filter their binds.
- **`eventArgs.no_overlay`** is tested in `Guards.hands_off`, but nothing sets it.
- Fixed 2026-09-28: `custom_guards.lua` asked the THF module (`shared/jobs/thf/functions/logic/treasure_hunter`, a proxy) for the TH guard on every job; it now requires the shared `shared/utils/equipment/treasure_hunter`. The idle / engaged custom gear also waits for a COR roll to land (`GearHold`).
- **RDM binds `^numpad9` to `EnfeebleTier`.** This breaks the "`^numpad9` = HybridMode or empty" convention of `.claude/rules/keybinds.md`.
- **Common keys differ between overlays.** One tracked character overlay of `COMMON_KEYBINDS.lua` has no `!z` / `!x` stealth keys.
- Fixed 2026-09-28: RUN's HUD readiness anchor was `RuneElement` (no such state, the HUD waited 5 s); it is `RuneMode`.

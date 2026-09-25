# Keybind HUD (UI overlay)

The keybind HUD is the on-screen text box that lists, for the current job, every state-cycling keybind with its key, a short description and the live value of the Mote state it cycles (for example `^numpad9  Hybrid Mode  ● PDT`). It is a single Windower `texts` object, rebuilt from three inputs: the job's keybind file (`config/<job>/<JOB>_KEYBINDS.lua`), a name-pattern classifier that sorts each bind into a section, and the live `state` table. Every job entry file creates it from `user_setup()` through `KeybindUI.smart_init()`. It is repainted from `job_update`, `job_state_change`, the `cyclestate` handler and some job commands, and a diff over all state values skips repaints that would change nothing. Position and display flags are saved per character in `data/<char>/config/ui_settings.lua`. Users control it with `//gs c ui ...`.

Scope of this page: everything under `shared/utils/ui/`, the settings store `shared/config/ui_settings.lua`, the loader `shared/utils/config/config_loader.lua` (UI part only), the override `shared/utils/core/state_display_override.lua`, and the three per-character config files (`UI_CONFIG.lua`, `UI_COLOR_CONFIG.lua`, `ui_settings.lua`).

## Files

| Path | Lines | Role |
|---|---|---|
| `shared/utils/ui/ui_style_commands.lua` | 255 | In-game look commands (`//gs c ui gap 3`, `compact`, `color`...): check, apply live, save |
| `shared/utils/ui/ui_config_writer.lua` | 160 | Saves one look option into `UI_CONFIG.lua` by rewriting its line only |
| `shared/utils/ui/ui_style.lua` | 350 | Player look options from `UI_CONFIG.lua` (`layout`, `colors`, `chat`): checked, cached per load, one warning per wrong value |
| `shared/utils/ui/UI_MANAGER.lua` | 167 | Facade. Seeds the `_G` UI globals, records the live load in `windower._ui_live_state`, loads the sub-modules and builds the `KeybindUI` table that jobs call |
| `shared/utils/ui/ui_lifecycle.lua` | 200 | `init`, `smart_init`, `safe_init`, `destroy`; creates and destroys the `texts` object |
| `shared/utils/ui/ui_update_orchestrator.lua` | 277 | `update` (repaint only when states changed), `force_reinit`, plus `schedule_update`/`needs_reinit`/`get_status`/`handle_job_configuration_change`, which nothing calls |
| `shared/utils/ui/ui_visibility.lua` | 149 | `toggle`, `show`, `hide`, `is_visible`, `enable`, `disable`, `save_position` |
| `shared/utils/ui/ui_section_toggles.lua` | 194 | Header / legend / column-header / footer toggles; moves the box by the measured height change |
| `shared/utils/ui/ui_appearance.lua` | 155 | Background preset, custom RGBA, background toggle, font |
| `shared/utils/ui/ui_display.lua` | 72 | Collects the keybinds and pushes the rendered string to the `texts` object |
| `shared/utils/ui/UI_LOADER.lua` | 145 | Loads `config/<job>/<JOB>_KEYBINDS`, has hard-coded COR/GEO fallbacks, appends the BRD song-slot rows |
| `shared/utils/ui/UI_DISPLAY_BUILDER.lua` | 328 | Sorts binds into spell / ja / weapon / mode: an explicit `bind.section` first, else substring rules on `bind.state` |
| `shared/utils/ui/UI_SECTIONS.lua` | 368 | Renders the full text in order: header, column headers, sections, footer |
| `shared/utils/ui/UI_FORMATTER.lua` | 391 | Line formatting, column widths, header/legend text, section titles |
| `shared/utils/ui/COLOR_SYSTEM.lua` | 533 | Picks the colour code for each value, with per-character overrides |
| `shared/utils/ui/ui_state_value.lua` | 129 | Reads a state's current value and all its possible values (the latter sizes the columns) |
| `shared/utils/ui/ui_state_tracker.lua` | 90 | Snapshots every state value and diffs it against the previous snapshot |
| `shared/utils/ui/ui_settings_resolver.lua` | 109 | Builds the settings table passed to `texts.new` |
| `shared/utils/ui/UI_SETTINGS.lua` | 98 | Adapter between the flat `ui_settings` store and the `keybind_saved_settings` table shape |
| `shared/utils/ui/UI_COMMANDS.lua` | 105 | `//gs c ui ...` dispatcher |
| `shared/config/ui_settings.lua` | 344 | Per-character store: `_G.UI_SETTINGS` plus file I/O (`dofile` / `io.open`) |
| `shared/utils/config/config_loader.lua` | 82 | `load_ui_config(char, job)`: `dofile` of `UI_CONFIG.lua`, then fills `_G.UIConfig` and `_G.ui_display_config` |
| `shared/utils/core/state_display_override.lua` | 46 | Replaces Mote's `display_current_state` (see Interactions) |
| `_master/config_global/UI_CONFIG.lua` | 375 | Template for `data/<char>/config/UI_CONFIG.lua` (display defaults, presets, flags) |
| `_master/config_global/UI_COLOR_CONFIG.lua` | 275 | Template for the per-character colour overrides |
| `_master/config_global/ui_settings.lua` | 36 | Starting settings for a new character (position 1600, 300, the resolver's own fallback). A re-clone keeps the character's existing file (`clone_character.py` `KEPT_ON_RECLONE`) |

## How it works

### Module instances and shared state

All sub-modules are loaded with `require`. In the GearSwap sandbox `require` is `include_user`, which never caches (`GearSwap/user_functions.lua:300-329`). The project's cache (`shared/utils/core/module_cache.lua`) is installed only when `INIT_SYSTEMS.lua` runs (`INIT_SYSTEMS.lua:53-58`), and that happens after `include('Mote-Include.lua')` in `get_sets()`. Anything required before that point, meaning module-level code and `user_setup()`, gets a fresh copy of every UI module. So the same environment usually holds two or three separate `KeybindUI` tables. They behave as one because every piece of mutable state lives on the sandbox `_G`:

| Global | Written by | Meaning |
|---|---|---|
| `_G.UIConfig` | `UI_MANAGER.lua:44-63` (stub, only if absent), `config_loader.lua:63`, entry `get_sets()` (for example `_master/entry/Tetsouo_WAR.lua:116`) | Contents of `UI_CONFIG.lua` |
| `_G.ui_display_config` | `config_loader.lua:66-73`, `UI_MANAGER.lua:79-88` (fallback), toggles | `{enabled, show_header, show_legend, show_column_headers, show_footer}`, the live display flags |
| `_G.keybind_ui_display` | `ui_lifecycle.lua:98` / `:189`, `job_change_manager.lua:87` | The `texts` object, or nil |
| `_G.keybind_ui_visible` | `UI_MANAGER.lua:71`, `ui_lifecycle.lua:99,190`, `ui_visibility.lua:67,96,105`, `job_change_manager.lua:88` | Visibility flag read by `is_visible()` (together with the display) |
| `_G.keybind_saved_settings` | `ui_lifecycle.lua:81-84`, `ui_settings_resolver.lua:51-52` | Nested copy of the store (`pos`, `bg_*`, `font_*`, flags) that the setters write back |
| `_G.ui_manager_state` | `UI_MANAGER.lua:91-118` | Cancel tokens (`smart_init_id`, `update_cancel_id`, `pending_update_id`), failure counter, `cached_states` |
| `_G.UI_SETTINGS` | `shared/config/ui_settings.lua:163-176` and every setter | Flat settings table, mirrored to disk |

Each job file load builds a new sandbox `_G` (`GearSwap/refresh.lua:83,114-146`), so all of these start empty after `gs reload` or a job change. Three values live on `windower.*` and so outlive the sandbox: `windower._ui_live_state` (the live load's `_G.ui_manager_state`, set at `UI_MANAGER.lua:124`; a coroutine scheduled by an older load compares against it and gives up), `windower._hud_virtual_y` (the unclamped Y, see Persistence) and `windower._hud_line_height` (line heights learned per font size, `ui_section_toggles.lua` `learned_heights`). Everything else persists only through the settings file.

### Initialisation (cold load, `gs reload`, main job change)

```mermaid
sequenceDiagram
    participant GS as GearSwap load_user_files
    participant Entry as Tetsouo_JOB.lua (module level)
    participant CL as config_loader
    participant Mote as Mote init_include
    participant US as user_setup
    participant LC as ui_lifecycle
    participant D as ui_display
    GS->>GS: delete every text object in __raw.text.registry
    GS->>Entry: run file in fresh user_env
    Entry->>CL: load_ui_config(char, JOB)
    CL->>CL: dofile(CHAR/config/UI_CONFIG.lua) -> _G.UIConfig
    CL->>CL: require shared/config/ui_settings (reads ui_settings.lua)
    CL->>CL: _G.ui_display_config = persisted flags
    Entry->>Mote: get_sets() -> include Mote-Include
    Mote->>US: user_setup()
    US->>US: JOBStates.configure(), JOBKeybinds.bind_all()
    US->>LC: KeybindUI.smart_init(JOB, UIConfig.init_delay)
    alt anchor state present
        LC->>LC: init()
    else anchor missing
        LC->>LC: poll every 0.2 s until ready or init_delay elapsed
    end
    LC->>LC: texts.new(create_ui_settings()) -> _G.keybind_ui_display
    LC->>D: update_display()
    LC->>LC: cached_states = capture_current_states()
```

Details:

1. `ConfigLoader.load_ui_config` (`config_loader.lua:33-76`) runs `dofile` on `<windower>/addons/GearSwap/data/<char>/config/UI_CONFIG.lua`. If that fails it substitutes a small table (`config_loader.lua:51-59`: header, legend, column headers and footer all `true`). It then fills `_G.ui_display_config` from the persisted store.
2. **Load order differs per entry file.** In `_master/entry/Tetsouo_WAR.lua:52`, `_master/entry/Tetsouo_BST.lua:29`, `_master/entry/Tetsouo_PUP.lua:34` and `_master/Tetsouo/entry/Tetsouo_SMN.lua:34` (live Tetsouo copies alike; WAR at `:51` there), `UI_MANAGER` is required at module level before `load_ui_config` (lines 59, 36, 41 and 37). In those files `UI_MANAGER.lua:44-63` finds no `_G.UIConfig`, writes a stub, and `UI_MANAGER.lua:79-88` loads `shared/config/ui_settings` against that stub. The other entry files require `UI_MANAGER` only inside `user_setup()`, after the config is loaded. See Known issues.
3. `smart_init` (`ui_lifecycle.lua:113-160`) bumps `smart_init_id`, then calls `init()` immediately if `are_states_ready()` (`ui_lifecycle.lua:33-65`). Otherwise it schedules `try_init` every 0.2 s. A newer `smart_init` (or `JobChangeManager` cleanup, `job_change_manager.lua` `cleanup_all_systems`) invalidates the pending poll, and so does a newer file load: `try_init` returns when `windower._ui_live_state` is no longer its own `_G.ui_manager_state` (fixed 2026-09-25; before, a poll left by the previous load could create a HUD that no load would ever destroy). The poll gives up waiting after `max_wait_time` (= `UIConfig.init_delay`, 5.0 in the template) and calls `init()` anyway. Anchor states per job: BRD `SongMode`, BLM `MainLightSpell`, BST `Ecosystem`, THF `TreasureMode`, WAR/PLD `HybridMode` (a Mote built-in, always present, `Mote-Include.lua:44`), DNC `MainStep`, RDM `MainLightSpell`, DRG `WeaponSet` (no DRG job exists), RUN `RuneElement` (no RUN state has that name; see Known issues), GEO `MainIndi`. Every other job counts as ready.
4. `init()` (`ui_lifecycle.lua:79-107`) loads `_G.keybind_saved_settings` once, returns early when `_G.ui_display_config.enabled` is false, and returns if a display already exists. Otherwise it builds the settings with `create_ui_settings()` (`ui_settings_resolver.lua:47-77`), which re-reads the store, calls `texts.new`, shows the object and renders once. The first render is **not** wrapped in `pcall`.

### Rendering pipeline

```mermaid
flowchart TD
    A["Display.update_display (ui_display.lua:45)"] --> B{"job == BRD?"}
    B -- yes --> B1["_G.update_brd_song_slots()"]
    B -- no --> C
    B1 --> C["get_current_job_keybinds: UI_LOADER.get_job_keybinds -> fallback -> add_job_specific_elements"]
    C --> D["UIDisplayBuilder.build_display_structure(job): same load, drop desc containing '←', classify each bind by state name"]
    D --> E["UISections.render_complete_ui"]
    E --> F["column widths from ALL possible values (get_all_state_values)"]
    F --> G["header + legend, separator, column headers"]
    G --> H["sections in order: spells, enhancing, ja, weapons, modes"]
    H --> I["footer or bottom margin"]
    I --> J["_G.keybind_ui_display:text(str)"]
```

**Keybind source** (`UI_LOADER.lua:23-49`): `require('config/<job>/<JOB>_KEYBINDS')`. GearSwap's `pathsearch` checks `data/<player.name>/` first (`GearSwap/refresh.lua:693-703`), so each character reads its own file. Every job keybind file goes through `KeybindManager.create` (see [keybinds-and-custom.md](keybinds-and-custom.md)), so every module has `get_active_binds()` and the loader uses that subjob-filtered list; the `.binds` branch only serves a file that does not. The list also carries what `KeybindManager.create` appended: the player's `<JOB>_CUSTOM.lua` states and the character's `config/COMMON_KEYBINDS.lua` keys (the `#numpad0` AutoMedicine row shown on every job comes from there). `add_job_specific_elements` (`UI_LOADER.lua:93-111`) returns a copy and, on BRD, appends five display-only rows `{key="", desc="Slot N", state="BRDSongN"}`. It copies because appending to the cached table used to add another five rows on every redraw (commit 8c83203). The keybind table is loaded twice per render, once in `ui_display.lua:28` and once in `UI_DISPLAY_BUILDER.lua:142`.

**Classification** (`UI_DISPLAY_BUILDER.lua` `categorize_keybind`). A bind with a `section` field (`mode(s)`, `spell(s)`, `ja`/`ability`/`abilities`, `weapon(s)`; custom states set it) goes to that section. Otherwise `string.find` substring matches on `bind.state` are tested in this order:

| Order | Category | Patterns |
|---|---|---|
| 1 | mode | `Mode Combat Engaged Idle Enfeeble Nuke PetIdleMode AutoPetEngage Rotation Xp PhalanxSIRD UseAltStep Auto Lock Marcato Dance Samba SneakInvi Klimaform Favor Regen` |
| 2 | spell | `Spell Element Tier Aja Storm Bar EnSpell Spike Gain Ecosystem species RuneElement Light Dark Rune BRDRotation VictoryMarch Etude QuickDraw Roll Luzaf Indi Geo AOE` |
| 3 | ja | `Step BRDSong WS` |
| 4 | weapon | `Weapon WeaponSet SubSet Proc Instrument` |
| 5 | mode (default) | anything else. An unmatched name used to fall into an "other" bucket that `extract_display_keys` had nowhere to put, so the row vanished; it now defaults to mode. Binds with no `state` (and no `section`) are still not rendered - there is no value to show. That leaves out the stateless `alts` keys of `COMMON_KEYBINDS.lua`. |

Matching is case-sensitive, and the first category that matches wins. For example `NukeTier` becomes a mode because `Nuke` is tested before `Tier`, and `KlimaformAOE` becomes a mode because `Klimaform` is tested before `AOE`. The builder stores **keys**, not binds. `render_section` (`UI_SECTIONS.lua:47-81`) walks the keybind list in file order and prints each bind whose key is in the section's key list. A list-valued `subjob` has already been filtered by `get_active_binds`; only a string `subjob` is compared with `player.sub_job` here (fixed 2026-09-25: a list used to hide the row). Rows therefore follow file order within each section, and the design depends on keys being unique within one keybind file (they are today).

The HUD each template produces (from running the real classifier over every `_master/config/*/*_KEYBINDS.lua`; the AutoMedicine row comes from `COMMON_KEYBINDS.lua`, and a character's `<JOB>_CUSTOM.lua` can add rows):

| Job | Spells section (title) | JA section (title) | Weapons | Modes | Not shown |
|---|---|---|---|---|---|
| BLM | Main/Sub Light, Dark, Light AOE, Dark AOE, SpellTier, AOETier, Storm | | | HybridMode, CombatMode, MagicBurstMode, DeathMode, SneakInviAOE, KlimaformAOE, AutoMedicine | |
| BRD | VictoryMarch, EtudeType, CarolElement, ThrenodyElement ("Song Settings") | BRDSong1-5 ("Song Slots") | MainWeapon, SubWeapon, MainInstrument | IdleMode, EngagedMode, SongMode, MarcatoSong, AutoMedicine | |
| BST | Ecosystem, species ("Pet Abilities") | | WeaponSet, SubSet | HybridMode, AutoPetEngage, PetIdleMode, AutoMedicine | |
| COR | QuickDraw, MainRoll, SubRoll, LuzafRing ("Rolls & Quick Draw") | | MainWeapon, RangeWeapon | HybridMode, AutoMedicine | |
| DNC | | MainStep, AltStep ("JA") | MainWeapon, SubWeaponOverride | HybridMode, UseAltStep, ClimacticAuto, JumpAuto, Dance, Samba, AutoMedicine | |
| DRK | | | MainWeapon | HybridMode, AutoMedicine | |
| GEO | MainIndi, MainGeo, MainLight/DarkSpell, SpellTier, MainLight/DarkAOE, AOETier | | | HybridMode, CombatMode, LuopanMode, IndicolureMode, AutoMedicine | |
| PLD | | | MainWeapon | HybridMode, Xp (/RDM), RuneMode (/RUN), SneakInviAOE (/SCH), AutoMedicine (live Tetsouo adds PhalanxSIRD) | |
| RDM | Storm (/SCH), EnSpell, GainSpell, Barspell, BarAilment, Spike | | MainWeapon, SubWeapon | EngagedMode, IdleMode, CombatMode, EnfeebleMode, NukeMode, SaboteurMode, NukeTier, AutoMedicine | |
| RUN | | | MainWeapon, SubWeapon | HybridMode, RuneMode, AutoMedicine | |
| SAM | | | MainWeapon | HybridMode, AutoMedicine | |
| THF | | | MainWeapon, SubWeapon, AbyProc (/WAR), AbyWeapon (/WAR) | HybridMode, TreasureMode, RangeLock, AutoMedicine | |
| WAR | | WS1-WS5 ("Weapon Skills") | MainWeapon | HybridMode, JumpAuto, AutoMedicine | |
| WHM | | | | CureMode, IdleMode, AfflatusMode, CureAutoTier, CombatMode, CastingMode, AutoMedicine | |
| PUP | no `config/pup/` in `_master`, so the loader returns nothing and the HUD has no rows | | | | |
| SMN (Tetsouo overlay and live only) | | | | IdleMode, CastingMode, AvatarFavor, AutoMedicine | |

**Line format** (`UI_FORMATTER.lua` `format_keybind_line`): `"  " .. key .. "    " .. desc .. "    " .. colour .. "● " .. value .. "  "`. Key and description are grey (180,180,180). Key, description and value columns are padded to the widest entry. The value column width comes from **every** possible value of every displayed state (`ui_state_value.lua` `get_all_state_values`, `UI_FORMATTER.lua` `calculate_value_column_width`), so the box keeps a fixed width when a value changes. The content width is the longest candidate line plus 2 (`UI_FORMATTER.lua` `calculate_content_width`). The layout assumes a monospace font, which is why `set_font` only accepts Consolas and Courier New.

**Value reading** (`ui_state_value.lua` `get_state_value`): `BRDSong%d` states return `.current`/`.value`, or `"Empty"`. Any missing state returns `"N/A"`. A Mote `M{}` object returns `.current` (boolean modes give `"on"`/`"off"`). A plain Lua boolean is passed through `tostring`.

**Header and footer**: `create_header` (`UI_FORMATTER.lua:90-131`) prints a black-background margin line, the centred title (`job_titles`, lines 23-37, which falls back to `"<JOB> Settings"` for DRK/SAM/WHM/PUP/SMN), an `=` separator, and when `show_legend` is set the two legend lines (`^ = Ctrl`, `! = Alt`, `@ = Windows`, `~ = Shift`). The legend is part of the header, so hiding the header also hides the legend. The footer (`UI_SECTIONS.lua` `render_commands_footer`) is a separator plus a centred `//gs c ui`.

**Colours** (`COLOR_SYSTEM.lua` `get_value_color`, through `color_from_description` and `color_from_value`), first match wins:
1. The description contains `Gain`: the stat inside the value picks an element colour (`get_gain_color`; unknown stats fall back to red).
2. The description contains `Element`, `AOE`, `Etude`, `Rune`, `Light`, `Dark`, `Aja`, `Storm` or `Quick Draw`, and the value is an exact key of that palette (`DESCRIPTION_PALETTES`). Then `Storm` goes through `get_storm_color`.
3. The description contains `Dance`: Saber Dance is fire red, Fan Dance is green.
4. The value contains `PDT MDT Normal Refresh Potency SIRD Solace Misery`: that mode's colour.
5. Spell-family probes: Bar-element, Bar-ailment (by associated element), En-spells, Spikes, Quick Draw shots.
6. Exact literals: `true/True/On/on` are green, `false/False/Off/off` red, `unknown/Unknown/N/A` grey.
7. Otherwise white.

At module load `COLOR_SYSTEM.lua:21-29` requires `<player.name>/config/UI_COLOR_CONFIG` and converts its `{r,g,b}` triples into `\cs(r,g,b)` overrides.

### Update triggers

| Trigger | Path |
|---|---|
| `job_update` (every `gs c update`, Mote `handle_cycle` and CycleHandler -> `handle_update({'auto'})`, Mote `sub_job_change` -> `send_command('gs c update')`) | every entry file, for example `_master/entry/Tetsouo_WAR.lua` `job_update`; BRD refreshes the song slots first (`_master/entry/Tetsouo_BRD.lua` `job_update`) |
| `job_state_change` | `LifecycleManager.state_change` (`shared/utils/core/lifecycle_manager.lua:85-99`, ignores `Moving`), used by BRD, BST, COR, DNC, DRK, GEO, PLD, PUP, RUN, SAM, SMN and THF (for example `shared/jobs/smn/functions/SMN_COMMANDS.lua:421`) |
| `cyclestate` keybinds while the HUD reports visible | `shared/utils/core/CYCLE_HANDLER.lua:126-128`, after the `job_update` above |
| Jobs' own `job_state_change` handlers and state-changing job commands | `BLM_COMMANDS.lua:99` (`update_ui` helper), `RDM_COMMANDS.lua:422`, `WAR_COMMANDS.lua:309`, `WHM_COMMANDS.lua:230` (all inside `job_state_change`; COR and THF go through `LifecycleManager.state_change`, `COR_COMMANDS.lua:352`, `THF_COMMANDS.lua:217`), THF `range` through `RangeLock.engage()` (`shared/jobs/thf/functions/logic/range_lock.lua:40-43`) |
| `//gs c am` (Auto Medicine) | `shared/utils/debuff/auto_medicine.lua:68-77`, only when `is_visible()` |
| BST ecosystem cycling | `shared/jobs/bst/functions/logic/ecosystem_manager.lua:56,99,151`, through `_G.KeybindUI`, which only the BST/PUP entries export (`_master/entry/Tetsouo_BST.lua:167`, cleared at `:442`) |
| UI commands | `toggle`, `show`, section toggles: these call `Display.update_display()` directly and skip the diff |

`KeybindUI.update()` (`ui_update_orchestrator.lua:45-93`):
1. No display: call `safe_init()`, which calls `init()`. With the HUD disabled, `init()` returns straight away, so this path is cheap.
2. `StateTracker.capture_current_states()` (`ui_state_tracker.lua:20-57`) turns every `_G.state` entry into a string, skipping names that start with `_`, functions and `Moving`. AutoMove flips `Moving` several times per second.
3. `have_states_changed` (`ui_state_tracker.lua:63-88`) compares the snapshot with `_G.ui_manager_state.cached_states`. An empty cache counts as changed.
4. If something changed, render under `pcall`. On success, cache the snapshot and reset `consecutive_failures`. On failure, increment the counter. Once it passes 5, every further failing update schedules `force_reinit(player.main_job, 5.0)` two seconds later (`:74-81`), with no de-duplication; the scheduled call returns when a newer load has replaced `windower._ui_live_state`.

### Persistence

```mermaid
flowchart LR
    CMD["//gs c ui ... (toggle, header, save, theme, font)"] --> KSS["_G.keybind_saved_settings (nested)"]
    KSS --> KS["KeybindSettings.save (UI_SETTINGS.lua:48)"]
    KS --> SET["UISettings.set_* x9"]
    SET --> GUS["_G.UI_SETTINGS (flat)"]
    SET --> FILE["io.open(data/PLAYER/config/ui_settings.lua, 'w')"]
    FILE -. "next load: dofile" .-> GUS
    GUS --> LOAD["KeybindSettings.load -> create_ui_settings -> texts.new"]
```

- File: `windower.addon_path .. 'data/' .. player.name .. '/config/ui_settings.lua'` (`shared/config/ui_settings.lua:85-91`). It is a `return { ... }` literal with all 19 keys, written by `save_to_file` (`shared/config/ui_settings.lua:111-156`). A write failure is reported through `MessageFormatter.show_error`.
- At module load (`shared/config/ui_settings.lua:163-176`) the file always wins. If it is missing, `_G.UI_SETTINGS` is seeded from `D = compute_defaults()` (values from `_G.UIConfig` at that moment, `shared/config/ui_settings.lua:48-75`) and written to disk immediately.
- Every `UISettings.set_*` rewrites the whole file. `KeybindSettings.save` calls up to nine setters (position, enabled, four flags, background, background visible, font), so one command can write the file nine times.
- Boolean defaults are consistent within this module. `enabled`, `show_legend`, `bg_visible` and `section_*` default to true (`~= false`); `show_header`, `show_column_headers` and `show_footer` default to false (`== true`). The same form is used in `compute_defaults`, the getters and `save_to_file`, so the 2026-05-18 P2-9 mismatch is fixed. Two other places use different defaults: the `UI_MANAGER` stub (`UI_MANAGER.lua:59-63`, nil means true) and the `config_loader` fallback (`config_loader.lua:53-58`, true).
- Position: the saved position is where the box is on screen, with no offset formula (`ui_visibility.lua` `save_position_internal`; `create_ui_settings` reads it back as is, `ui_settings_resolver.lua:54-67`). A header, legend or column-header toggle moves the box by the height it adds or removes, so the key rows stay put, and saves the new position (`ui_section_toggles.lua` `toggle_top_section`). The shift is the difference between the box's rendered height before and after; when Windower has not re-measured yet, it is the line count times a line height, corrected 0.15 s later once the text is drawn. Near the top of the screen the Y can go negative: the box is drawn at 0 and the unclamped value is kept in `windower._hud_virtual_y`, so toggling back returns the keys to the same place. Dragging with the mouse (`texts` library `draggable` flag) is **not** saved automatically; `//gs c ui s` and the section toggles save. After a reload or job change the HUD goes back to the last saved position.

### Lifecycle across events

```mermaid
stateDiagram-v2
    [*] --> Absent: new user_env (reload / job change)
    Absent --> Shown: init() with enabled=true
    Absent --> Absent: init() with enabled=false (no object created)
    Shown --> Hidden: toggle() / disable() (object kept, enabled=false persisted)
    Hidden --> Shown: toggle() / enable() / show()
    Shown --> Absent: destroy() (JCM cleanup on subjob change, force_reinit)
    Absent --> Shown: update() -> safe_init() (any repaint while absent and enabled)
    Shown --> [*]: GearSwap load_user_files deletes every registered text object
    Hidden --> [*]: GearSwap load_user_files deletes every registered text object
```

- **gs reload / main job change.** GearSwap deletes every text object created through `windower.text.create` (`GearSwap/refresh.lua:73-75`, registry kept by the override at `GearSwap/gearswap.lua:55-84`, which the `texts` library goes through). A coroutine left by the old load that would create a HUD after this point returns first, because `windower._ui_live_state` now belongs to the new load. The new environment starts with every UI global unset.
- **Subjob change** (same environment). Mote's `sub_job_change` (`Mote-Include.lua:981-990`) calls `user_setup()` (`smart_init` returns at once because a display exists), then `job_sub_job_change`, then `JobChangeManager.on_job_change`. That runs `cleanup_all_systems` (`job_change_manager.lua:69-105`), which destroys the HUD, clears `_G.keybind_ui_display`/`_G.keybind_ui_visible`, resets fields of `_G.ui_manager_state` and bumps `smart_init_id`. Mote then sends `gs c update`, whose `job_update` finds no display and recreates the HUD through `safe_init`. The debounced `gs reload` (0.5 s for a subjob change) finally replaces the whole environment.
- **Zone change, death, raise.** No UI handling. The object persists and repaints on the next update.
- **Events.** The UI modules register no Windower events. Dragging is handled by the `texts` library's own global `mouse` handler, registered once inside GearSwap.
- **Coroutines.** `smart_init.try_init` (0.2 s, cancelled by `smart_init_id` and, after a newer load, by `windower._ui_live_state`), `force_reinit.try_reinit` (0.2 s, cancelled by `update_cancel_id`), `schedule_update` (cancelled by `pending_update_id`, never called), the failure-recovery `force_reinit` (2 s, skipped after a newer load) and the section-toggle correction (0.15 s, dropped by a newer toggle or another display). All are bounded by a timeout or run once.

## Public API

### `KeybindUI` (returned by `require('shared/utils/ui/UI_MANAGER')`)

| Function | Effect | Main callers |
|---|---|---|
| `init()` | Load saved settings once; if `enabled` and no display exists, `texts.new` + show + render + seed `cached_states` | internal (`smart_init`, `safe_init`, `enable`, `force_reinit`) |
| `smart_init(job_name, max_wait_time=3)` | `init()` now, or poll every 0.2 s until the job's anchor state exists or `max_wait_time` s pass. `job_name` is unused | every entry `user_setup()` (for example `_master/entry/Tetsouo_WAR.lua:230`) |
| `safe_init()` | Record `current_job`/`current_subjob`, then `init()` if no display | `update()` |
| `destroy()` | `pcall(display:destroy())`, clear the globals and `cached_states` | `force_reinit`, `job_change_manager.lua` `cleanup_all_systems` |
| `update()` | Diff the states, repaint on change (see above) | about 40 call sites in `shared/` and `_master/` (Update triggers) |
| `force_reinit(job_name, max_wait_time=3)` | Bump `update_cancel_id`, destroy, `init()` now or poll. Returns a boolean (or `true` when async) | only the failure path of `update()` and `schedule_update` |
| `schedule_update(reason, delay=1.0)` | Debounced update, or `force_reinit` if job/subjob changed | only `handle_job_configuration_change` |
| `handle_job_configuration_change(change_data)` | Maps `change_data.type` to a delay and calls `schedule_update` | **no callers** (its header says JobChangeManager dispatches it; JobChangeManager does not) |
| `needs_reinit(job)`, `get_status()` | Diagnostics | **no callers** |
| `save_position()` | Read `display:pos()`, persist it with the display flags, confirm in chat | `//gs c ui s` |
| `toggle()` | If a display exists: flip visibility **and** persist `enabled`. Otherwise `enable()`/`disable()` | `//gs c ui` |
| `show()`, `hide()` | Visibility only, not persisted | `enable`, `disable` |
| `is_visible()` | `_G.keybind_ui_display ~= nil and _G.keybind_ui_visible == true` | `CYCLE_HANDLER.lua:113`, `auto_medicine.lua:71` |
| `enable()`, `disable()` | Set and persist `enabled`, create/show or hide | `//gs c ui on/off`, `toggle` |
| `toggle_header()`, `toggle_legend()`, `toggle_column_headers()`, `toggle_footer()` | Flip the flag, repaint, move the box by the measured height change (top sections only), persist flag and position. No-op without a display | `//gs c ui h/l/c/f` |
| `set_background_preset(name)` | Apply `UIConfig.background_presets[name]`, persist | `//gs c ui bg <name>` |
| `set_background_rgba(r,g,b,a)` | `tonumber`, clamp 0-255, apply, persist | `//gs c ui bg r g b a` |
| `toggle_background()` | Flip `_G.UIConfig.background.visible`, apply, persist `bg_visible` | `//gs c ui bg toggle` |
| `set_font(name)` | Accepts `consolas`, `courier new`, `courier`, then applies and persists | `//gs c ui font <name>` |

### Helper modules

- `UICommands.handle_ui_command(cmdParams)`, `UICommands.is_ui_command(cmd)`: called from every job's `job_self_command` (`shared/jobs/*/functions/*_COMMANDS.lua`, for example `WAR_COMMANDS.lua:129-130`).
- `KeybindLoader.get_job_keybinds(job)`, `.get_fallback_keybinds(job)`, `.add_job_specific_elements(job, binds)`: used by `ui_display.lua` and `UI_DISPLAY_BUILDER.lua`. `.config_exists(job)` and `.get_config_path(job)` have no callers and build the wrong path `config/<JOB>_KEYBINDS` (no job folder).
- `UIDisplayBuilder.build_display_structure(job)` returns `{spell_keys, ja_keys, weapon_keys, mode_keys, enhancing_keys?}`. `extract_display_keys` and `apply_job_enhancements` are only used inside it. `validate_structure` and `get_categorization_stats` have no callers.
- `UISections.render_complete_ui(ds, binds, job, get_value, get_all_values)` returns a string. The per-section `render_*_section` functions are public but only used inside the module. `validate_configuration` and `get_section_statistics` have no callers.
- `UIFormatter`: layout helpers. `calculate_header_width`, `format_empty_section`, `validate_configuration` and `get_statistics` have no callers.
- `ColorSystem.get_value_color(value, desc)` is used by `UI_FORMATTER.lua` `format_keybind_line`. `get_element_colors`, `get_stat_colors` and `add_custom_color` have no callers.
- `StateValue.get_state_value(name, key)`, `.get_all_state_values(name)`, `StateTracker.capture_current_states()`, `.have_states_changed(snapshot)`: internal.
- `UISettingsResolver.create_ui_settings()`, `.get_background_settings()`. `.default_ui_settings()` has no callers.
- `KeybindSettings.load()` and `.save(tbl)` (`UI_SETTINGS.lua`).
- `UISettings` (`shared/config/ui_settings.lua`): `get/set_position`, `get/set_enabled`, `get/set_show_header|legend|column_headers|footer`, `get/set_background`, `set_background_visible`, `get/set_font`. `get_sections` and `set_section` have no callers.
- `ConfigLoader.load_ui_config(char, job)`: every entry file.
- `StateDisplayOverride.init()`: `INIT_SYSTEMS.lua:249-256`, deferred 0.5 s.

## Commands

All are `//gs c ui <sub> ...`, routed by each job's `job_self_command` to `UICommands.handle_ui_command` (`UI_COMMANDS.lua:26-94`). The subcommand is lowercased.

| Syntax | Effect | Handler |
|---|---|---|
| `ui` | `toggle()`: hide/show and persist `enabled` | `ui_visibility.lua:65-91` |
| `ui h` / `header` | Toggle title (and legend) | `ui_section_toggles.lua:165-167` |
| `ui l` / `legend` | Toggle legend (visible only while the header is shown) | `ui_section_toggles.lua:170-172` |
| `ui c` / `columns` | Toggle the `Key / Function / Current` row | `ui_section_toggles.lua:175-177` |
| `ui f` / `footer` | Toggle footer | `ui_section_toggles.lua:180-192` |
| `ui s` / `save` | Save the current screen position and all flags | `ui_visibility.lua:55-62` |
| `ui on` / `enable`, `ui off` / `disable` | Enable/disable and persist | `ui_visibility.lua:121-146` |
| `ui font <Consolas\|Courier>` | Change font (only the first word is read, so `Courier New` is entered as `courier`) | `ui_appearance.lua` `set_font` |
| `ui bg\|background\|theme <preset>` | Apply a preset from `UIConfig.background_presets` (lowercase keys) | `ui_appearance.lua` `set_background_preset` |
| `ui bg <r> <g> <b> <a>` | Custom background | `ui_appearance.lua` `set_background_rgba` |
| `ui bg toggle` | Background on/off | `ui_appearance.lua` `toggle_background` |
| `ui bg list` | Print preset names (`MessageUI.show_theme_list`) | `message_ui.lua` `show_theme_list` |
| `ui help` / `?` | Print help. Anything else prints an error followed by the help | `message_ui.lua` `show_help` |
| `ui compact [on\|off]`, `ui separators [on\|off]` | Look switches (no value = toggle) | `ui_style_commands.lua` |
| `ui sepchar <chars>`, `ui sepcolor <1-255>` | Character and FFXI chat color of the chat separator line | `ui_style_commands.lua` |
| `ui chatwidth <20-150>` | `chat.width`: characters per chat separator line, framed blocks included | `ui_style_commands.lua` |
| `ui jobtag [on\|off]` | `chat.job_tag`: the `[RDM/DRK]` in front of chat messages | `ui_style_commands.lua` |
| `ui chatcolor <name> <1-255>` / `<name> reset` | `chat.colors`: remap a palette color or a `MessageColors` constant; the whole table is rewritten on its one line (a table spread over several lines is refused, not rewritten) | `ui_style_commands.lua`, `ui_config_writer.lua` |
| `ui gap <1-10>`, `ui valuegap <1-10>`, `ui margin <top> [bottom]`, `ui side <0-3>`, `ui padding <0-20>`, `ui keys symbols\|words`, `ui bullet <text>`, `ui order <sections...>`, `ui roworder <states...>`, `ui color <name> <r> <g> <b>` | Look options; `reset` as the value goes back to the standard value | `ui_style_commands.lua` |
| `ui style` | List the current look values and the file they are saved in | `ui_style_commands.lua`, `message_ui.lua` `show_style_list` |

The look commands check the value with `UIStyle.resolve` on a copy of the config (only problems the change adds count), change `_G.UIConfig` in place, call `UIStyle.invalidate`, re-pad the texts box and redraw through `ui_display.update_display`. They then save the value with `ui_config_writer.lua`, which rewrites only that option's line in `<char>/config/UI_CONFIG.lua` (uncommenting it, or commenting it out on `reset`), keeps the file's line endings and the column of a trailing comment, adds a missing line at the top of its block and a missing block before `return UIConfig`. A job change reloads `UI_CONFIG.lua`, so the saved value stays.

There is no `//gs c uisave` command. The comments that named one now say `//gs c ui save` in `UI_MANAGER.lua` and in the template, overlay and Tetsouo/Kaories `UI_CONFIG.lua` (fixed 2026-09-25; the frozen Hysoka and Gabvanstronger copies still say `uisave`). The help text does not list `ui font`, and "dark" and "light" in its "dark/light/blue" preset example are not preset names (`blue` is).

## Configuration

### `data/<char>/config/UI_CONFIG.lua` (template `_master/config_global/UI_CONFIG.lua`)

| Key | Template value | Read by |
|---|---|---|
| `enabled`, `show_header`, `show_legend`, `show_column_headers`, `show_footer` | true, false, true, false, false | only as `compute_defaults` input (`shared/config/ui_settings.lua:57-61`), i.e. when the settings file is missing or lacks a key. At runtime the persisted values win |
| `default_position {x,y}` | 1857, -24 | the same, defaults only |
| `text.size`, `text.font` | 10, Consolas | defaults only. `text.stroke` is passed straight to `texts.new` on every init (`ui_settings_resolver.lua:71`) |
| `background {r,g,b,a,visible}` | 15,15,35,180,true | defaults. `toggle_background` also flips `background.visible` at runtime |
| `background_presets` | 36 named presets | `UI_COMMANDS.lua:70-71`, `ui_appearance.lua` `set_background_preset` |
| `flags {draggable, bold}` | true, true | passed to `texts.new` (`ui_settings_resolver.lua:75`); the `texts` library applies both |
| `sections {spells, enhancing, job_abilities, weapons, modes}` | all true | the `render_*_section` functions of `UI_SECTIONS.lua`, through a reference captured when the module loads (`UI_SECTIONS.lua:17`) |
| `init_delay` | 5.0 | used as `smart_init`'s maximum wait (not a delay), and by BRD to schedule the song-slot refresh (`_master/entry/Tetsouo_BRD.lua` `user_setup`) |
| `layout`, `colors`, `chat` | standard look | `shared/utils/ui/ui_style.lua`, see below |
| `auto_save_position`, `auto_save_delay`, `debug`, `update_throttle` | | **nothing reads them** |
| `validate()` | | **no callers** (`print_config()` was removed 2026-09-25) |

#### Look options: `layout`, `colors`, `chat` (added 2026-09-25)

`ui_style.lua` resolves the three tables into one checked table (`UIStyle.get()`), cached per `_G.UIConfig` table, so it is re-read on each job load. A wrong value prints one chat warning per load and falls back to the standard value. With the tables absent, or holding the values the template writes, the HUD text is byte-identical to the one rendered before these options existed (checked by rendering both trees).

| Option | Effect | Applied in |
|---|---|---|
| `layout.section_order` | order of the five sections; missing ones are appended in the standard order | `UI_SECTIONS.render_complete_ui` (`SECTION_RENDERERS`) |
| `layout.compact`, `layout.column_gap`, `layout.value_gap` | compact: margins 1/2/2/1 instead of 2/4/4/2, no blank line under section titles. `column_gap` (1-10) sets the key-to-label gap, `value_gap` (1-10) the label-to-value gap, which follows `column_gap` when only that one is set. The width calculation uses the same spacing | `UI_FORMATTER` (content width, column headers, rows, section header) |
| `layout.margin_top`, `layout.margin_bottom`, `layout.margin_side`, `layout.padding` | blank lines above/below the rows (0-3; standard 1, compact 0), spaces left and right of the rows (`margin_side`, 0-3; standard 2, compact 1) and pixels of background around the text (0-20; standard 0, compact 4). The top margin is the blank line that opens the first section, replaced only when neither header nor column headers are shown. Compact, or a player-set `margin_bottom` or `margin_side`, switches the layout to exact geometry (`spacing.exact`): the final newline is dropped (the texts box draws it as an empty line, the fixed ~19 px `ui_section_toggles.lua` measured) and `calculate_content_width` counts displayed columns instead of bytes. The standard layout keeps its byte count, where the 3-byte `●` leaves 2 columns of slack on the right of the blank lines. `padding` goes to `texts.new` as the top-level `padding` (`texts.pad`), so it applies when the HUD is created | `UI_SECTIONS.render_complete_ui` (`top_margin`), `ui_settings_resolver.create_ui_settings` |
| `layout.key_style` | `'words'` shows keys through `MessageCore.convert_key_display` (`CTRL+F1`) and hides the symbol legend and the separator under it | `UI_FORMATTER`, `UI_SECTIONS` |
| `layout.bullet` | symbol before the value, or a name mapped to a WGL4 symbol (`dot` ●, `circle` ○, `square` ■, `smallsquare` ▪, `triangle` ►, `diamond` ◊, `arrow` →, `gt` >, `dash` -, `star` *, `none`). `ui bullet` accepts names only: a symbol typed in the FFXI chat line does not arrive in the HUD's encoding. The value column width counts one character per UTF-8 symbol | `UI_FORMATTER` |
| `layout.move_to_section` | state name or key -> section; checked before the bind's own `section` field and the name patterns | `UI_DISPLAY_BUILDER.categorize_keybind` |
| `layout.row_order` | state names or keys; within each section the named rows come first in that order, the rest keep the file order (stable sort on the whole list, so one list orders every section) | `UIStyle.ordered_rows`, called in `UI_SECTIONS.render_complete_ui` |
| `layout.hide_rows` | rows removed before the widths are computed; the key stays bound | `UI_SECTIONS.render_complete_ui` |
| `layout.section_titles` | replaces the title of a section for every job, BRD "Song Slots" included | `UI_FORMATTER.get_section_title` |
| `colors.*` | `{r,g,b}`: `title`, `section_title`, `key`, `description`, `value`, `legend`, `separator`, `footer`. `key` unset = same as description; `value` unset = `COLOR_SYSTEM` per-value colors | `UI_FORMATTER`, `UI_SECTIONS` footer |
| `chat.separators`, `chat.separator_char`, `chat.separator_color` | the line printed by `MessageCore.show_separator` (after spells, abilities, BST and PLD/RUN AoE messages). ASCII only: the FFXI chat does not render UTF-8 | `message_core.lua` |

The framed chat blocks draw their own lines, so `separators`, `separator_char` and `separator_color` do not reach them; `chat.width` does, because `MessageCore.SEPARATOR_WIDTH` is now read through a metatable on every use (`chat.width` or the standard `DEFAULT_SEPARATOR_WIDTH` = 69). `message_system`, `message_sortie`, `message_tempbind` and the `api/messages.lua` test command used to capture it once at load and now build their line at each use. The diagnostic tools keep their own hard-coded 69 (`wardrobe_auditor.lua`, `refill_panels.lua`, `wardrobe/lib/config.lua`): they must not depend on the message chain.

Column widths are measured on the rows a section actually draws (`shown_rows` in `UI_SECTIONS.lua`, 2026-09-25). Before, every bind of the job counted, including the stateless common keys (`config/COMMON_KEYBINDS.lua`, e.g. "Alts: follow me (toggle)") that no section shows, so the label column was as wide as a label never on screen.

### `data/<char>/config/ui_settings.lua` (auto-generated)

Keys: `pos_x, pos_y, enabled, show_header, show_legend, show_column_headers, show_footer, bg_r, bg_g, bg_b, bg_a, bg_visible, font_size, font_name, section_spells, section_enhancing, section_job_abilities, section_weapons, section_modes`. The `section_*` keys are written but never read by the renderer. `font_size` has no command. Live values differ per character. A first clone copies the template `_master/config_global/ui_settings.lua` (position 1600, 300); a re-clone copies the character's own file back from the backup (`clone_character.py` `KEPT_ON_RECLONE`, 2026-09-25).

### `data/<char>/config/UI_COLOR_CONFIG.lua`

Takes effect: `elements`, `stats`, `modes`, `special.true/false/unknown`, `spells.en`, `spells.spikes`, `spells.storms`, `jobs.quick_draw`. No effect: `bar_spells.ailment` (`COLOR_SYSTEM.lua:178` stores it in `special_colors.bar_ailment`, which nothing reads), `special.default` (the fallback is the constant `DEFAULT_COLOR`, `COLOR_SYSTEM.lua:402`), `jobs.runes` (empty). The helper functions at the bottom of the file have no callers, and `get_bar_element_color` would error because `bar_spells.element` does not exist.

### Keybind file fields read by the HUD

`key` (required, string), `desc` (required, string: `UI_DISPLAY_BUILDER.lua:127` and `UI_FORMATTER.lua` `calculate_function_column_width` call string functions on it), `state` (the Mote state name; its classification decides whether and where the row appears), `section` (optional, overrides the classification), `subjob` (optional, a string or a list). `command` is only used by `bind_all`. Binds whose `desc` contains `←` are dropped (`UI_DISPLAY_BUILDER.lua` `filter_reverse_keybinds`).

## State & lifetime

- Sandbox `_G` globals: see the table under "Module instances and shared state". Also read: `_G.state`, `player`, `_G.UPDATE_DEBUG` (restored from `windower._gs_debug` in `INIT_SYSTEMS.lua:35-41`), `_G.update_brd_song_slots` (`song_rotation_manager.lua:267`).
- `windower.*`: `_ui_live_state`, `_hud_virtual_y`, `_hud_line_height` (see Module instances). They survive job changes and `gs reload`, and are reset by `//lua reload gearswap`.
- Files: `UI_CONFIG.lua` (dofile, every load), `ui_settings.lua` (dofile at module load, rewritten on each setter), `UI_COLOR_CONFIG.lua` (require at `COLOR_SYSTEM` load), `config/<job>/<JOB>_KEYBINDS.lua` (require on each render; cached once `module_cache` is installed).
- Events: none registered. Text objects: at most one per environment (the `init()` guard on `_G.keybind_ui_display`), deleted by GearSwap on every file load.

## Interactions

- **JobChangeManager** (`shared/utils/core/job_change_manager.lua` `cleanup_all_systems`) destroys the HUD and resets UI globals on a subjob change before its debounced `gs reload`. See [core-lifecycle.md](core-lifecycle.md).
- **CycleHandler** (`shared/utils/core/CYCLE_HANDLER.lua:90-130`): when `KeybindUI.is_visible()` is true it does what Mote's `handle_cycle` does without the chat line (same `job_state_change(description, new, old)` call, then `handle_update({'auto'})`, so `job_update` repaints the HUD), then calls `KeybindUI.update()` once more. Otherwise it sends `gs c cycle <state>` so Mote prints `"<desc> is now <value>."`. The HUD is the only feedback on the silent path. `cyclestate <state> reverse` cycles backwards on both paths. See [core-lifecycle.md](core-lifecycle.md#cyclehandler-and-state-display).
- **StateDisplayOverride** (`state_display_override.lua:29-39`) replaces Mote's `display_current_state`. Mote calls that function only from `handle_update` when the argument is `user` (`Mote-SelfCommands.lua:255-257`, bound to F12 by `Mote-Globals.lua:57`), and passes no arguments. The override prints nothing while `_G.ui_display_config.enabled` is true, and otherwise prints `State: Unknown`.
- **LifecycleManager** (`lifecycle_manager.lua:85-99`) provides the `job_state_change` handler that repaints.
- **Messages**: `MessageUI` (`shared/utils/messages/formatters/ui/message_ui.lua`) and `MessageCore.show_ui_error/show_ui_info`. See [messages.md](messages.md).
- **Keybind files and job states**: see each job page, for example [../jobs/brd.md](../jobs/brd.md) and [../jobs/pld.md](../jobs/pld.md).
- **Auto Medicine** (`shared/utils/debuff/auto_medicine.lua:68-77`) repaints after `//gs c am`.

## Invariants & gotchas

- A state's **name** decides its section, and an unmatched name now defaults to mode rather than disappearing. It is still worth adding a pattern for a new state so it lands in the right section - a row under the wrong heading is merely odd, where the old silent drop cost BRD and SMN their signature `^numpad3` row for months, keys working the whole time.
- Pattern order matters: mode patterns are tested first, so a name containing `Mode`, `Auto`, `Lock`, `Idle`... is a mode even if it also contains `Spell` or `Weapon`.
- Rows are matched to sections **by key**. Two binds sharing a key in one file would appear in both sections.
- The first render inside `init()` is not protected by `pcall`. When `smart_init` runs synchronously in `user_setup()`, a render error aborts `user_setup`, and with it the rest of Mote's `init_include` and the job's `get_sets()`.
- Code that must still see the live `_G.UIConfig` when it runs has to read it at call time, as `ui_settings_resolver.lua:48`, `ui_appearance.lua` and `UI_COMMANDS.lua:70` do. `UI_SECTIONS.lua:17` captures it at load time, which on WAR/BST/PUP/SMN happens before `config_loader` has run (`UI_FORMATTER.lua` captures it too, but only the uncalled `get_statistics` reads it).
- `toggle()` does not only hide the box: it also persists `enabled=false`, so after the next load no text object is created at all.
- `update()` repaints only when some state value changed. Code that changes something the HUD shows without changing a state (for example BRD song slots) must refresh that data before calling `update()` (BRD does this in `job_update`).
- `ui_settings_resolver.lua:72` puts `padding` inside `text`, but the `texts` library reads it from the top-level `padding`, so the setting has no effect. The library default is also 0.

## Extending

- **Show a new state**: add the bind to `config/<job>/<JOB>_KEYBINDS.lua` in `_master/config/` and in the live character folders (`key`, `command = "cyclestate X"`, `desc`, `state`). Run the classifier mentally. If no pattern matches, add a pattern to the right list in `UI_DISPLAY_BUILDER.lua:24-63` (or give the bind a `section` field), and check that it does not re-classify an existing state, since substring matches are broad. Mode patterns are tested first.
- **New job**: add a keybind file and an anchor state to `are_states_ready()` (`ui_lifecycle.lua:33-65`) if the states are created after `user_setup` starts. Optionally add a title to `job_titles` (`UI_FORMATTER.lua:23-37`) and a section title case in `get_section_title` (`UI_FORMATTER.lua:191-220`). Call `KeybindUI.smart_init(JOB, UIConfig.init_delay)` from `user_setup()` after the states and keybinds, and `KeybindUI.update()` from `job_update`. Call `ConfigLoader.load_ui_config` before any module-level `require` of `UI_MANAGER`.
- **New colour rule**: extend `DESCRIPTION_PALETTES`, `MODE_SUBSTRINGS`, `SPELL_COLOR_PROBES` or `EXACT_VALUE_COLORS` (`COLOR_SYSTEM.lua:406-438`). Per-character values go in `UI_COLOR_CONFIG.lua`.
- **New `//gs c ui` subcommand**: add a branch to `UI_COMMANDS.lua:35-92` and a line to `MessageUI.show_help`.

## Known issues

Open:

- A keybind without `desc` makes the first render throw inside `user_setup()` and aborts the job load (`shared/utils/ui/ui_lifecycle.lua:103`, `shared/utils/ui/UI_DISPLAY_BUILDER.lua:127`).
- RUN's readiness anchor `RuneElement` does not exist, so the RUN HUD waits the full `init_delay` (`shared/utils/ui/ui_lifecycle.lua:58-59`). Changing it to `RuneMode` was left out on 2026-09-25 because it changes RUN's HUD timing and no maintained character plays RUN.
- WAR/BST/PUP (and SMN) require `UI_MANAGER` before `config_loader`. A missing `ui_settings.lua` is then regenerated from stub defaults, and `UI_SECTIONS` keeps the stub `UIConfig` (`shared/utils/ui/UI_MANAGER.lua:44`).
- `section_*` settings are persisted but never read, and `UIConfig.sections` is captured when the module loads (`shared/config/ui_settings.lua:322-344`, `shared/utils/ui/UI_SECTIONS.lua:17`).
- `toggle_background` flips `UIConfig.background.visible`, not the persisted `bg_visible` (`shared/utils/ui/ui_appearance.lua:100`).
- `KeybindSettings.save` rewrites the settings file up to nine times per command (`shared/utils/ui/UI_SETTINGS.lua:48-95`).
- `handle_job_configuration_change`, `schedule_update`, `needs_reinit` and `get_status` have no callers (the header now says so, `shared/utils/ui/ui_update_orchestrator.lua:11-14`).
- Several dead helpers, the RDM `enhancing_keys` that can never match, and the unreachable GEO/`result` branches (`shared/utils/ui/UI_DISPLAY_BUILDER.lua:203-204`, `shared/utils/ui/ui_state_value.lua:111-123`).
- The `display_current_state` override prints `State: Unknown` on F12 while the HUD is disabled (`shared/utils/core/state_display_override.lua:29-39`).
- `UI_CONFIG.lua` has keys nothing reads (`auto_save_position`, `auto_save_delay`, `debug`, `update_throttle`), and `validate` has no callers.
- In `UI_COLOR_CONFIG.lua`, `bar_spells.ailment` and `special.default` have no effect (`shared/utils/ui/COLOR_SYSTEM.lua:175-179`).
- The legend explains `^ ! @ ~` but not `#` (Apps), the modifier of the common `#numpad0` AutoMedicine bind (`shared/utils/ui/UI_FORMATTER.lua:122-123`).

Fixed (kept here so an audit does not re-report them):

- `is_visible()` reported true with the HUD disabled or hidden before a reload, so keybind cycling printed nothing: it now also requires the display (`518e536`).
- Header/legend/column toggles moved the box the wrong way: the shift is now measured (`518e536`).
- The saved-position Y offset (`calculate_y_offset`) is gone; the position is saved as drawn (`518e536`).
- BRD `MainInstrument` is read: `midcast_router.lua` puts the chosen instrument in the range slot for buff songs (`f413682`).
- A `subjob` list on a bind hid the row (fixed 2026-09-25).
- A `smart_init` poll or failure-recovery `force_reinit` left by an older load could create a HUD no load would destroy: both now check `windower._ui_live_state` (fixed 2026-09-25, not tested in game: it only matters when a reload lands during the poll).
- The template `ui_settings.lua` gave a new character `pos_x = 1946`, off a 1920-wide screen: now 1600, 300 (fixed 2026-09-25; still off-screen on a window 1600 pixels wide or less).
- `//gs c syscheck` reported the globals created by `tb`, `sortie`, custom states and the alts window as leaks: they are in `global_probe.lua` `EXPECTED` (fixed 2026-09-25).

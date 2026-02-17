# Configuration

All user config files are in `Tetsouo/config/` (replace `Tetsouo` with your character name). Apply changes with `//gs c reload`.

---

## Directory structure

```
Tetsouo/config/
  DUALBOX_CONFIG.lua        DualBox multi-character
  LOCKSTYLE_CONFIG.lua      Global lockstyle timing
  UI_CONFIG.lua             UI appearance and behavior
  war/
    WAR_KEYBINDS.lua
    WAR_LOCKSTYLE.lua
    WAR_MACROBOOK.lua
    WAR_STATES.lua
    WAR_TP_CONFIG.lua
  pld/
    PLD_KEYBINDS.lua
    PLD_LOCKSTYLE.lua
    PLD_MACROBOOK.lua
    PLD_BLU_MAGIC.lua
  [other jobs]/             15 jobs total
```

---

## Lockstyle

**File**: `config/[job]/[JOB]_LOCKSTYLE.lua`

```lua
local WARLockstyleConfig = {}

WARLockstyleConfig.default = 1

WARLockstyleConfig.by_subjob = {
    ['SAM'] = 1,
    ['NIN'] = 2,
    ['DNC'] = 3,
}

return WARLockstyleConfig
```

Set `default` for all subjobs, or use `by_subjob` for per-subjob overrides. Lockstyle numbers are 1-200.

### Global timing

**File**: `config/LOCKSTYLE_CONFIG.lua`

| Setting | Default | Description |
|---------|---------|-------------|
| `initial_load_delay` | 8.0s | Delay after first job load |
| `job_change_delay` | 8.0s | Delay after job change |
| `cooldown` | 15.0s | Minimum between applications |

Increase delays if lockstyle fails silently (FFXI needs character data loaded first).

---

## Macrobook

**File**: `config/[job]/[JOB]_MACROBOOK.lua`

```lua
local WARMacroConfig = {}

WARMacroConfig.default = {book = 22, page = 1}

WARMacroConfig.macrobooks = {
    ['SAM'] = {book = 22, page = 1},
    ['DRG'] = {book = 25, page = 1},
    ['DNC'] = {book = 28, page = 1},
}

return WARMacroConfig
```

---

## DualBox

**File**: `config/DUALBOX_CONFIG.lua`

| Setting | MAIN | ALT |
|---------|------|-----|
| `role` | `"main"` | `"alt"` |
| `character_name` | Your main name | Your alt name |
| `alt_character` | Alt name | (not used) |
| `main_character` | (not used) | Main name |
| `enabled` | `true` | `true` |
| `timeout` | `30` | `30` |
| `debug` | `false` | `false` |

See [DualBox Guide](dualbox.md) for full setup.

---

## UI

**File**: `config/UI_CONFIG.lua`

Position: drag and `//gs c ui save`. See [UI Guide](../features/ui.md) for all settings.

---

## Equipment sets

**File**: `shared/jobs/[job]/sets/[job]_sets.lua`

Sets are organized as `sets.precast`, `sets.midcast`, `sets.idle`, `sets.engaged` with sub-tables for modes (e.g., `sets.engaged.PDT`). Validate with `//gs c checksets`.

---

## Custom states

Add states in the job main file (`TETSOUO_[JOB].lua`):

```lua
function user_setup()
    state.MyCustomState = M{'Option1', 'Option2', 'Option3'}
end
```

Then add a keybind in `[JOB]_KEYBINDS.lua`:

```lua
{key = "!9", command = "cycle MyCustomState", desc = "My Custom", state = "MyCustomState"},
```

---

## Troubleshooting

**Changes not applying**: Run `//gs c reload`. Check for Lua syntax errors (missing commas, missing `return` at end of file). Verify file path matches exactly.

**Lockstyle not applying**: Wait 8 seconds after job change. Check `by_subjob` has the right subjob key. Manual apply: `//gs c lockstyle`.

**Macrobook not changing**: Verify book/page numbers exist in FFXI. Check subjob spelling in config.

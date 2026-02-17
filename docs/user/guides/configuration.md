# Configuration Guide

Complete configuration guide for customizing the Tetsouo GearSwap system.


---

## Table of Contents

- [Overview](#overview)
- [Configuration File Locations](#configuration-file-locations)
- [Universal Configuration](#universal-configuration)
 - [Lockstyle Configuration](#lockstyle-configuration)
 - [Macrobook Configuration](#macrobook-configuration)
 - [UI Configuration](#ui-configuration)
- [Job-Specific Configuration](#job-specific-configuration)
- [Applying Changes](#applying-changes)
- [Advanced Configuration](#advanced-configuration)

---

## Overview

All user-facing configuration files are located in `Tetsouo/config/` (or your character name), while core system logic resides in `shared/`.

**Configuration Principle:**

- Edit config files - never modify core job files
- Changes apply via `//gs c reload`
- Factory-managed systems (lockstyle, macrobook)
- Per-job and per-subjob customization

---

## Configuration File Locations

### Directory Structure

```
Tetsouo/config/
├── DUALBOX_CONFIG.lua          (DualBox multi-character settings)
├── LOCKSTYLE_CONFIG.lua        (Global lockstyle timing settings)
├── UI_CONFIG.lua               (UI appearance and behavior)
│
├── war/                        (WAR job configs)
│   ├── WAR_KEYBINDS.lua
│   ├── WAR_LOCKSTYLE.lua
│   ├── WAR_MACROBOOK.lua
│   ├── WAR_STATES.lua
│   └── WAR_TP_CONFIG.lua
│
├── pld/                        (PLD job configs)
│   ├── PLD_KEYBINDS.lua
│   ├── PLD_LOCKSTYLE.lua
│   ├── PLD_MACROBOOK.lua
│   └── PLD_BLU_MAGIC.lua
│
├── dnc/                        (DNC job configs)
│   └── ...
│
└── [other jobs]/               (15 jobs total)
```


---

## Universal Configuration

These configurations apply to **all jobs** and follow consistent patterns.

### Lockstyle Configuration

Configure lockstyle numbers (1-200) that apply automatically when changing jobs or subjobs.

#### Per-Job Config Files

All jobs follow this pattern:

```
Tetsouo/config/[job]/[JOB]_LOCKSTYLE.lua
```

**Examples:**

- `config/war/WAR_LOCKSTYLE.lua`
- `config/pld/PLD_LOCKSTYLE.lua`
- `config/dnc/DNC_LOCKSTYLE.lua`

#### Basic Structure

```lua
local WARLockstyleConfig = {}

-- Default lockstyle (fallback if no subjob match)
WARLockstyleConfig.default = 1

-- Lockstyle by subjob (optional)
WARLockstyleConfig.by_subjob = {
    ['SAM'] = 1,   -- WAR/SAM >> lockstyle 1
    ['NIN'] = 2,   -- WAR/NIN >> lockstyle 2
    ['DNC'] = 3,   -- WAR/DNC >> lockstyle 3
}

return WARLockstyleConfig
```

#### Option 1: Same Lockstyle for All Subjobs

Use one lockstyle number for all subjobs:

```lua
WARLockstyleConfig.default = 5

-- Optional: Explicitly set all subjobs to same number
WARLockstyleConfig.by_subjob = {
    ['SAM'] = 5,
    ['NIN'] = 5,
    ['DNC'] = 5,
}
```

#### Option 2: Different Lockstyles per Subjob

Customize per subjob:

```lua
WARLockstyleConfig.default = 1  -- Fallback

WARLockstyleConfig.by_subjob = {
    ['SAM'] = 6,   -- WAR/SAM >> lockstyle 6
    ['DRG'] = 5,   -- WAR/DRG >> lockstyle 5
    ['DNC'] = 7,   -- WAR/DNC >> lockstyle 7
    ['NIN'] = 4,   -- WAR/NIN >> lockstyle 4
}
```

#### Finding Your Lockstyle Number

In-game:

```bash
# Save current equipment as lockstyle
//equipviewer save 5   # Saves to slot 5

# Test lockstyle
//dressup 5            # Applies lockstyle 5
```

Use that number in your config.

#### Global Lockstyle Timing

Edit `Tetsouo/config/LOCKSTYLE_CONFIG.lua`:

```lua
local LockstyleConfig = {}

-- Delay after initial job load (seconds)
LockstyleConfig.initial_load_delay = 8.0

-- Delay after job change (seconds)
LockstyleConfig.job_change_delay = 8.0

-- Cooldown between lockstyle applications (seconds)
LockstyleConfig.cooldown = 15.0

return LockstyleConfig
```

**Why delays?**

- FFXI needs time to fully load character/gear before applying lockstyle
- Too fast = lockstyle fails silently

**Recommended values:**

- **8.0s** (default) - Safe for most systems
- **6.0s** - Faster systems/SSDs
- **10.0s** - Slower systems/HDDs

---

### Macrobook Configuration

Configure which macro book and page loads automatically based on subjob.

#### Per-Job Config Files

All jobs follow this pattern:

```
Tetsouo/config/[job]/[JOB]_MACROBOOK.lua
```

#### Basic Structure

```lua
local WARMacroConfig = {}

-- Default macrobook (fallback)
WARMacroConfig.default = {book = 22, page = 1}

-- Macrobook by subjob
WARMacroConfig.macrobooks = {
    ['SAM'] = {book = 22, page = 1},   -- WAR/SAM >> Book 22, Page 1
    ['DRG'] = {book = 25, page = 1},   -- WAR/DRG >> Book 25, Page 1
    ['DNC'] = {book = 28, page = 1},   -- WAR/DNC >> Book 28, Page 1
    ['NIN'] = {book = 22, page = 2},   -- WAR/NIN >> Book 22, Page 2
}

return WARMacroConfig
```

#### Example: Same Book, Different Pages

Organize all subjobs in one book:

```lua
WARMacroConfig.macrobooks = {
    ['SAM'] = {book = 22, page = 1},   -- Page 1
    ['DRG'] = {book = 22, page = 2},   -- Page 2
    ['DNC'] = {book = 22, page = 3},   -- Page 3
    ['NIN'] = {book = 22, page = 4},   -- Page 4
}
```

All use book 22, different pages.

#### Example: Different Books per Subjob

Separate books for different playstyles:

```lua
WARMacroConfig.macrobooks = {
    ['SAM'] = {book = 22, page = 1},   -- Melee book
    ['DRG'] = {book = 22, page = 1},   -- Melee book
    ['WHM'] = {book = 23, page = 1},   -- Support book
    ['RDM'] = {book = 23, page = 1},   -- Support book
}
```

---

### UI Configuration

Configure UI appearance, position, and behavior.

**File:** `Tetsouo/config/UI_CONFIG.lua`

```lua
local UIConfig = {}

-- UI initialization delay (seconds after job load)
UIConfig.init_delay = 5.0

-- UI appearance (in UI_MANAGER.lua, not config file)
-- Position saved via: //gs c ui save

return UIConfig
```

**UI Customization:**

- Position: Drag and `//gs c ui save`
- Appearance: See **[UI Guide](../features/ui.md)**
- Keybinds display: Auto-updated from keybind config

---

## Job-Specific Configuration

Each job has unique configuration files for job-specific features.

### WAR - Warrior

**Files:**

- `config/war/WAR_TP_CONFIG.lua` - TP bonus thresholds for WS display

```lua
local TPConfig = {}

-- TP thresholds for bonus display
TPConfig.thresholds = {
    1000,  -- Base TP
    1500,  -- Tier 1 bonus
    2000,  -- Tier 2 bonus
    2500,  -- Tier 3 bonus
    3000   -- Max TP
}

return TPConfig
```

### PLD - Paladin

**Files:**

- `config/pld/PLD_BLU_MAGIC.lua` - AOE BLU spell rotation (PLD/BLU)

```lua
local PLDBluMagic = {}

-- AOE spell rotation (sorted by enmity/sec)
PLDBluMagic.aoe_spells = {
    {name = "Geist Wall", enmity = 640, recast = 30},
    {name = "Stinking Gas", enmity = 640, recast = 37},
    {name = "Sound Blast", enmity = 320, recast = 30},
    -- ...
}

return PLDBluMagic
```

### DNC - Dancer

**Files:**

- No additional config (uses keybinds + states)

**States configured in main job file:**

```lua
state.MainStep = M{'Feather Step', 'Box Step', 'Quickstep'}
state.AltStep = M{'Box Step', 'Quickstep'}
state.ClimacticAuto = M{'On', 'Off'}
state.JumpAuto = M{'On', 'Off'}
```

### WHM - White Mage

**Files:**

- `config/whm/WHM_CURE_CONFIG.lua` - Cure auto-tier settings (if exists)

```lua
local WHMCureConfig = {}

-- Safety margin for cure tier downgrade (HP)
WHMCureConfig.safety_margin = 50

-- Minimum HP to trigger auto-tier
WHMCureConfig.min_missing_hp = 100

return WHMCureConfig
```

### BST - Beastmaster

**Files:**

- No additional config (ecosystem/species managed via commands)

**Ecosystem cycling:**

- 7 ecosystems (Arid, Terrestrial, Aquatic, Amorphs, Vermin, Lizards, Birds)
- Species per ecosystem (varies)

### RDM - Red Mage

**Files:**

- No additional config (uses keybinds + states)

**Enhancement spell states:**

```lua
state.GainSpell = M{'Gain-STR', 'Gain-DEX', ...}
state.Barspell = M{'Barfira', 'Barblizzara', ...}
state.BarAilment = M{'Baramnesia', 'Barvirus', ...}
state.Spike = M{'Blaze Spikes', 'Ice Spikes', ...}
state.Storm = M{'Firestorm', 'Hailstorm', ...}  -- RDM/SCH only
```

### Other Jobs

**COR, GEO, BRD, BLM, SAM, THF, DRK:**

- Standard configs only (keybinds, lockstyle, macrobook)
- No additional job-specific config files

---

## Applying Changes

After modifying any configuration file:

```
//gs c reload
```

**What happens:**

1. Current job unloads (keybinds unbound, UI destroyed)
2. JobChangeManager clears pending operations
3. Job reloads with new config
4. Keybinds re-bound
5. Lockstyle re-applied (after delay)
6. Macrobook re-set
7. UI re-initialized

**Immediate changes:**

- Keybinds
- States
- Commands

**Delayed changes:**

- Lockstyle (8s delay by default)
- UI (5s delay by default)

---

## Advanced Configuration

### DualBox Configuration

**File:** `Tetsouo/config/DUALBOX_CONFIG.lua`

```lua
local DualBoxConfig = {}

-- Enable/disable DualBox system
DualBoxConfig.enabled = true

-- Main character name
DualBoxConfig.main_character = "Tetsouo"

-- Alt character name
DualBoxConfig.alt_character = "Kaories"

-- Auto-request alt job on load
DualBoxConfig.auto_request = true

-- Display alt job in UI
DualBoxConfig.show_in_ui = true

return DualBoxConfig
```

**See:** [DualBox Guide](dualbox.md) for complete setup

### Custom States

Add custom states to job main file (`TETSOUO_[JOB].lua` or your character name):

```lua
function user_setup()
    -- Custom state example
    state.MyCustomState = M{'Option1', 'Option2', 'Option3'}
    state.MyCustomState:set('Option1')  -- Default value
end
```

**Then add keybind:**

```lua
-- In [JOB]_KEYBINDS.lua
{key = "!9", command = "cycle MyCustomState", desc = "My Custom", state = "MyCustomState"},
```

### Equipment Sets Organization

Equipment sets are defined in:

```
shared/jobs/[job]/sets/[job]_sets.lua
```

**Structure:**

```lua
sets.precast = {}
sets.precast.JA = {}
sets.precast.WS = {}
sets.precast.FC = {}

sets.midcast = {}
sets.midcast['Healing Magic'] = {}
sets.midcast['Enhancing Magic'] = {}

sets.idle = {}
sets.idle.Normal = {}
sets.idle.PDT = {}

sets.engaged = {}
sets.engaged.Normal = {}
sets.engaged.PDT = {}
```

**Hybrid support:**

- `sets.engaged.Normal` - Max offense
- `sets.engaged.PDT` - Physical damage reduction

**See equipment files for job-specific sets.**

---

## Troubleshooting

### Issue: "Config changes not applying"

**Solutions:**

1. **Reload system**

   ```
   //gs c reload
   ```

2. **Check file syntax**
 - Missing `return [Config]` at end
 - Lua syntax errors (missing commas, brackets)

3. **Verify file path**
 - Must be in `Tetsouo/config/[job]/`
 - File name must match exactly (case-sensitive)

### Issue: "Lockstyle not applying after subjob change"

**Solutions:**

1. **Check lockstyle config**
 - Verify subjob exists in `by_subjob` table
 - Verify lockstyle number is valid (1-200)

2. **Check timing**
 - Wait 8 seconds after subjob change
 - Increase delay if needed: `LOCKSTYLE_CONFIG.lua`

3. **Manual apply**

   ```
   //gs c lockstyle
   ```

### Issue: "Macrobook not changing"

**Solutions:**

1. **Check macrobook config**
 - Verify book/page numbers exist in FFXI
 - Check subjob spelling in config

2. **Manual set**

   ```
   /macro book 22
   /macro set 1
   ```

### Issue: "UI not showing keybinds"

**Solutions:**

1. **Verify keybind has valid state**

   ```lua
   {key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon"},
   --                                                                    ↑ must exist
   ```

2. **State must be defined in job file**

   ```lua
   state.MainWeapon = M{'Ukonvasara', 'Naegling', ...}
   ```

3. **Refresh UI**

   ```
   //gs c ui     # Toggle off
   //gs c ui     # Toggle on
   ```

---

## Configuration Best Practices

### Organization

1. **One config per concern**
 - Keybinds >> `[JOB]_KEYBINDS.lua`
 - Lockstyle >> `[JOB]_LOCKSTYLE.lua`
 - Macrobook >> `[JOB]_MACROBOOK.lua`

2. **Consistent naming**
 - Use job code in UPPERCASE: `WAR`, `PLD`, `DNC`
 - Use descriptive state names: `MainWeapon`, `HybridMode`

3. **Comment complex configs**

   ```lua
   -- WAR/SAM DPS build - Crit focused
   ['SAM'] = {book = 22, page = 1},
   ```

### Backup Before Editing

```bash
# Copy config folder before major changes
cp -r Tetsouo/config/ Tetsouo/config_backup/
```

### Test Changes

1. Edit config file
2. `//gs c reload`
3. Test functionality
4. Verify UI updates (if applicable)

---

## Quick Reference

| Config Type | File Pattern | Example |
|-------------|-------------|---------|
| **Keybinds** | `config/[job]/[JOB]_KEYBINDS.lua` | `config/war/WAR_KEYBINDS.lua` |
| **Lockstyle** | `config/[job]/[JOB]_LOCKSTYLE.lua` | `config/war/WAR_LOCKSTYLE.lua` |
| **Macrobook** | `config/[job]/[JOB]_MACROBOOK.lua` | `config/war/WAR_MACROBOOK.lua` |
| **UI** | `config/UI_CONFIG.lua` | Global UI settings |
| **DualBox** | `config/DUALBOX_CONFIG.lua` | Multi-character sync |
| **Lockstyle Timing** | `config/LOCKSTYLE_CONFIG.lua` | Global timing settings |

---

## Next Steps

- **[Keybinds Guide](keybinds.md)** - Customize keyboard shortcuts
- **[DualBox Guide](dualbox.md)** - Multi-character setup
- **[Commands Reference](commands.md)** - All available commands
- **[FAQ](../../FAQ.md)** - Common issues and solutions

---


# Keybinds Guide - Customize Your Keyboard Shortcuts

Complete guide to customizing keybinds for all 15 jobs in the Tetsouo GearSwap system.


---

## Table of Contents

- [Overview](#overview)
- [Configuration Files](#configuration-files)
- [Keybind Structure](#keybind-structure)
- [Key Format Reference](#key-format-reference)
- [Customization Examples](#customization-examples)
- [Available Commands](#available-commands)
- [Applying Changes](#applying-changes)
- [Troubleshooting](#troubleshooting)

---

## Overview

All jobs use a centralized keybind configuration system located in `Tetsouo/config/[job]/[JOB]_KEYBINDS.lua`.

**Benefits:**

- User-customizable without modifying core job files
- State-based organization (Weapon, Combat Modes, Job-Specific)
- Automatic bind/unbind with error handling
- UI integration (keybinds display automatically)

---

## Configuration Files

### Per-Job Config Paths

| Job | Configuration File |
|-----|-------------------|
| **WAR** | `Tetsouo/config/war/WAR_KEYBINDS.lua` |
| **PLD** | `Tetsouo/config/pld/PLD_KEYBINDS.lua` |
| **DNC** | `Tetsouo/config/dnc/DNC_KEYBINDS.lua` |
| **DRK** | `Tetsouo/config/drk/DRK_KEYBINDS.lua` |
| **SAM** | `Tetsouo/config/sam/SAM_KEYBINDS.lua` |
| **THF** | `Tetsouo/config/thf/THF_KEYBINDS.lua` |
| **RDM** | `Tetsouo/config/rdm/RDM_KEYBINDS.lua` |
| **WHM** | `Tetsouo/config/whm/WHM_KEYBINDS.lua` |
| **BLM** | `Tetsouo/config/blm/BLM_KEYBINDS.lua` |
| **GEO** | `Tetsouo/config/geo/GEO_KEYBINDS.lua` |
| **COR** | `Tetsouo/config/cor/COR_KEYBINDS.lua` |
| **BRD** | `Tetsouo/config/brd/BRD_KEYBINDS.lua` |
| **BST** | `Tetsouo/config/bst/BST_KEYBINDS.lua` |

**Note:** Replace `Tetsouo` with your character name if you renamed the folder.

---

## Keybind Structure

### Basic Format

All jobs use this structure:

```lua
[JOB]Keybinds.binds = {
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
}
```

### Field Explanation

| Field | Description | Example |
|-------|-------------|---------|
| `key` | Key combination to press | `"!1"` (Alt+1) |
| `command` | GearSwap command to execute | `"cycle MainWeapon"` |
| `desc` | Description (shown in UI) | `"Main Weapon"` |
| `state` | Mote state name (for display) | `"MainWeapon"` |

### Real Examples from Code

**WAR** (`WAR_KEYBINDS.lua:31-43`):

```lua
WARKeybinds.binds = {
    -- Weapon Management
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },

    -- Combat Mode Control
    { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
}
```

**DNC** (`DNC_KEYBINDS.lua:31-51`):

```lua
DNCKeybinds.binds = {
    -- Weapon Management
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    { key = "^1", command = "cycle SubWeaponOverride", desc = "Sub Override", state = "SubWeaponOverride" },

    -- Combat Mode
    { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },

    -- Step Management
    { key = "!3", command = "cycle MainStep", desc = "Main Step", state = "MainStep" },
    { key = "!4", command = "cycle AltStep", desc = "Alt Step", state = "AltStep" },
    { key = "!5", command = "cycle UseAltStep", desc = "Use Alt Step", state = "UseAltStep" },

    -- Auto-Trigger Controls
    { key = "!6", command = "cycle ClimacticAuto", desc = "Climactic Auto", state = "ClimacticAuto" },
    { key = "!7", command = "cycle JumpAuto", desc = "Jump Auto", state = "JumpAuto" },

    -- Dance Selection
    { key = "!8", command = "cycle Dance", desc = "Dance Type", state = "Dance" },
    { key = "^8", command = "dance", desc = "Activate Dance" },
}
```

**WHM** (Example):

```lua
WHMKeybinds.binds = {
    { key = "!1", command = "cycle IdleMode", desc = "Idle Mode", state = "IdleMode" },
    { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
    { key = "!3", command = "afflatus", desc = "Afflatus", state = "AfflatusMode" },
    { key = "!4", command = "cycle AfflatusMode", desc = "Afflatus Mode", state = "AfflatusMode" },
    { key = "!5", command = "cycle CureAutoTier", desc = "Cure Auto", state = "CureAutoTier" },
}
```

**BST** (Example):

```lua
BSTKeybinds.binds = {
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
    { key = "!3", command = "ecosystem", desc = "Ecosystem", state = "Ecosystem" },
    { key = "!4", command = "species", desc = "Species", state = "Species" },
    { key = "!5", command = "broth", desc = "Broth Count" },
}
```

---

## Key Format Reference

### Modifiers

| Symbol | Modifier Key |
|--------|--------------|
| `!` | **Alt** |
| `^` | **Ctrl** |
| `@` | **Windows** |
| `#` | **Shift** |

### Key Examples

| Code | Actual Key |
|------|-----------|
| `!1` | Alt+1 |
| `^1` | Ctrl+1 |
| `@1` | Windows+1 |
| `#1` | Shift+1 |
| `f1` | F1 |
| `f9` | F9 |
| `!f1` | Alt+F1 |
| `^f9` | Ctrl+F9 |
| `!a` | Alt+A |
| `^w` | Ctrl+W |

### Valid Keys

**Numbers**: `1`, `2`, `3`, ..., `0`
**Function Keys**: `f1`, `f2`, ..., `f12`
**Letters**: `a`, `b`, `c`, ..., `z` (lowercase)
**Special**: `pageup`, `pagedown`, `home`, `end`, `insert`, `delete`

---

## Customization Examples

### Example 1: Change Alt+1 to F9

**BEFORE:**

```lua
{ key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
```

**AFTER:**

```lua
{ key = "f9", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
```

### Example 2: Use Ctrl Instead of Alt

**BEFORE:**

```lua
{ key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
{ key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
```

**AFTER:**

```lua
{ key = "^1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
{ key = "^2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
```

### Example 3: Add New Keybind

```lua
WARKeybinds.binds = {
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },

    -- New keybind added
    { key = "f9", command = "cycle OffenseMode", desc = "Offense Mode", state = "OffenseMode" },
}
```

### Example 4: Remove Keybind

Simply delete or comment out the line:

```lua
WARKeybinds.binds = {
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    -- { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },  -- Disabled
}
```

---

## Available Commands

### Cycle Commands (Rotate Through Values)

```lua
command = "cycle MainWeapon"     -- Cycle through weapon options
command = "cycle HybridMode"     -- Cycle: PDT ↔ Normal
command = "cycle OffenseMode"    -- Cycle offense modes
command = "cycle DefenseMode"    -- Cycle defense modes
command = "cycle IdleMode"       -- Cycle idle modes
```

### Toggle Commands (On/Off)

```lua
command = "toggle OffenseMode"   -- Toggle Offense On/Off
command = "toggle DefenseMode"   -- Toggle Defense On/Off
command = "toggle Kiting"        -- Toggle Kiting On/Off
```

### Set Commands (Force Specific Value)

```lua
command = "set HybridMode PDT"        -- Force PDT mode
command = "set OffenseMode Normal"    -- Force Normal offense
command = "set MainWeapon Naegling"   -- Force specific weapon
```

### Job-Specific Commands

**WAR:**

```lua
command = "cycle MainWeapon"     -- Cycle weapons (Ukonvasara, Naegling, etc.)
```

**DNC:**

```lua
command = "cycle MainStep"       -- Cycle main step
command = "cycle AltStep"        -- Cycle alternate step
command = "cycle ClimacticAuto"  -- Toggle Climactic Flourish auto
command = "cycle JumpAuto"       -- Toggle Jump auto
command = "waltz"                -- Execute intelligent Waltz
command = "aoewaltz"             -- Execute Divine Waltz
```

**RDM:**

```lua
command = "cycle EnfeeblingMode" -- Potency/Skill/Duration
command = "cycle NukeMode"       -- FreeNuke/LowTierNuke/Accuracy
command = "cycle GainSpell"      -- Cycle Gain spells (F1)
command = "cycle Barspell"       -- Cycle Bar Element spells (F2)
command = "cycle BarAilment"     -- Cycle Bar Ailment spells (F3)
command = "cycle Spike"          -- Cycle Spike spells (F4)
command = "cycle Storm"          -- Cycle Storm spells (F5, RDM/SCH only)
```

**WHM:**

```lua
command = "afflatus"             -- Cast current Afflatus stance
command = "cycle AfflatusMode"   -- Solace ↔ Misery
command = "cycle CureAutoTier"   -- Toggle Cure auto-tier
```

**BST:**

```lua
command = "ecosystem"            -- Cycle ecosystems (7 types)
command = "species"              -- Cycle species for current ecosystem
command = "broth"                -- Display broth counts
command = "rdylist"              -- List Ready Moves
command = "rdymove [1-6]"        -- Execute Ready Move by index
command = "pet engage"           -- Engage pet
command = "pet disengage"        -- Disengage pet
```

**Universal (All Jobs):**

```lua
command = "reload"               -- Reload GearSwap system
command = "checksets"            -- Validate equipment
command = "lockstyle"            -- Reapply lockstyle
command = "ui"                   -- Toggle UI
command = "ui save"              -- Save UI position
command = "altjob"               -- Request alt job info (DualBox)
command = "watchdog"             -- Show watchdog status
command = "watchdog debug"       -- Toggle watchdog debug
command = "watchdog test"        -- Test watchdog detection
```

See **[Commands Reference](commands.md)** for complete command list.

---

## Applying Changes

After modifying any keybind config file:

```
//gs c reload
```

Changes apply immediately - new keybinds are active right away.

**What happens:**

1. Old keybinds unbound
2. New keybinds bound
3. UI refreshed with new keybinds
4. System confirmation message displayed

---

## UI Integration

Configured keybinds automatically appear in the UI overlay:

- **Key**: Displayed key combination (Alt+1, F9, etc.)
- **Function**: Keybind description
- **Current**: Current state value

**UI updates automatically** when you cycle/toggle states.

**Toggle UI:**

```
//gs c ui            # Show/hide
Alt+F1              # Quick toggle (default)
```

---

## Troubleshooting

### Issue: "Keybind not working"

**Solutions:**

1. **Check key format**
   - Correct: `"!1"` (Alt+1)
   - Wrong: `"alt+1"`, `"Alt+1"`, `"!one"`

2. **Reload system**

   ```
   //gs c reload
   ```

3. **Check for conflicts**
   - Key might be used by FFXI, Windower, or another addon
   - Try different key combination

4. **Verify syntax**

   ```lua
   { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
   --  ↑ comma required at end of line (except last line)
   ```

### Issue: "UI not showing keybind"

**Solutions:**

1. **Keybind must have valid `state` field**

   ```lua
   { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
   --                                                                    ↑ must match state in job file
   ```

2. **State must exist in job file**
   - Check `TETSOUO_[JOB].lua` (or your character name)
   - State must be defined in `user_setup()`:

   ```lua
   state.MainWeapon = M{...}  -- Must exist
   ```

3. **Refresh UI**

   ```
   //gs c ui     # Toggle off
   //gs c ui     # Toggle on
   ```

### Issue: "Keybind executes wrong command"

**Solutions:**

1. **Check command spelling**

   ```lua
   command = "cycle MainWeapon"    -- Correct
   command = "cycle mainweapon"    -- Wrong (case-sensitive)
   ```

2. **Verify command exists**
   - Universal commands: See `COMMON_COMMANDS.lua`
   - Job-specific: See `[JOB]_COMMANDS.lua`

3. **Check state definition**
   - State must have options defined:

   ```lua
   state.MainWeapon = M{'Ukonvasara', 'Naegling', 'Chango'}
   ```

---

## Advanced Customization

### Conditional Keybinds (Advanced)

Some jobs support subjob-conditional keybinds:

**Example from PLD** (PLD/BLU):

```lua
-- Only show AOE keybind if subjob is BLU
if player.sub_job == 'BLU' then
    table.insert(PLDKeybinds.binds, {
        key = "!4",
        command = "aoe",
        desc = "AOE BLU",
        state = nil
    })
end
```

### Dynamic Keybind Loading

Keybinds load automatically on job change via `JobChangeManager`:

- Old job keybinds unbound
- New job keybinds bound
- UI refreshed

**Manual reload:**

```lua
if [JOB]Keybinds then
    [JOB]Keybinds.unbind_all()
    [JOB]Keybinds.bind_all()
end
```

---

## Best Practices

### Organization Tips

1. **Group by category**

   ```lua
   -- Weapon Management
   { key = "!1", ... },

   -- Combat Modes
   { key = "!2", ... },

   -- Job Abilities
   { key = "!3", ... },
   ```

2. **Use consistent patterns**
   - Alt+1, Alt+2 for core states (all jobs)
   - F1-F5 for enhancement cycles (RDM)
   - Alt+3+ for job-specific features

3. **Document complex keybinds**

   ```lua
   -- Climactic Flourish auto-trigger (3+ FM, TP >= 800)
   { key = "!6", command = "cycle ClimacticAuto", desc = "Climactic Auto", state = "ClimacticAuto" },
   ```

### Avoid Common Mistakes

❌ **Don't use reserved keys**

- F12 (GearSwap update)
- F9-F11 (Mote modes)
- Ctrl+H (Windower hide)

❌ **Don't forget commas**

```lua
{ key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },  -- ← comma required
{ key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" }    -- ← no comma on last line
```

❌ **Don't use uppercase keys**

```lua
{ key = "!A", ... }  -- Wrong
{ key = "!a", ... }  -- Correct
```

---

## Next Steps

- **[Commands Reference](commands.md)** - Complete command list
- **[UI Customization](../features/ui.md)** - Customize UI appearance and position
- **[Configuration Guide](configuration.md)** - Advanced configuration options
- **[FAQ](faq.md)** - Common issues and solutions

---


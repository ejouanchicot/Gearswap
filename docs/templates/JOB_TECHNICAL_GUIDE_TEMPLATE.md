# [JOB_FULL_NAME] - GearSwap System Guide

**Job Code**: [JOB]
**System**: Tetsouo GearSwap
**Status**: ✅ Production Ready
**Version**: 1.0
**Last Updated**: [DATE]

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Keybinds](#keybinds)
3. [Commands](#commands)
4. [States & Modes](#states--modes)
5. [Equipment Sets](#equipment-sets)
6. [Configuration Files](#configuration-files)
7. [Customization](#customization)
8. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Loading the System

1. **Change to [JOB] in-game**
2. **Load GearSwap**:
   ```
   //lua load gearswap
   ```
3. **Verify loading**:
   - Look for: `[[JOB]] Functions loaded successfully`
   - Keybinds auto-loaded
   - Macrobook auto-set (Book X, Page Y)
   - Lockstyle applied after 8 seconds

### First Commands to Try

```
//gs c checksets          (validate your equipment)
//gs c ui                 (toggle keybind display)
//gs reload               (reload system)
```

### Default Setup

**On load, system automatically**:
- ✅ Loads all [JOB] keybinds
- ✅ Sets macrobook (Book X for [JOB])
- ✅ Applies lockstyle #X (after 8s delay)
- ✅ Displays UI with all keybinds (if enabled)
- ✅ Sets default states (HybridMode: PDT, etc.)

---

## ⌨️ Keybinds

### All [JOB] Keybinds

**File**: `Tetsouo/config/[job]/[JOB]_KEYBINDS.lua`

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **Alt+1** | Cycle MainWeapon | `state.MainWeapon` | [Description] |
| **Alt+2** | Cycle HybridMode | `state.HybridMode` | Toggle PDT/Normal |
| **Alt+F1** | Toggle UI | - | Show/hide keybind overlay |
| **[Add all keybinds from config file]** |

### How Keybinds Work

**Example**: Pressing `Alt+1` cycles through weapon options:
```lua
-- In KEYBINDS.lua
{key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon"}

-- System executes:
//gs c cycle MainWeapon

-- Result:
MainWeapon: Weapon1 → Weapon2 → Weapon3 → Weapon1 (loops)
```

**Modifier Keys**:
- `!` = Alt
- `^` = Ctrl
- `@` = Windows key
- `#` = Apps key

### Testing Keybinds

1. Press a keybind (e.g., `Alt+1`)
2. Check console for state change message
3. Check UI overlay updates (if enabled)
4. Watch gear swap when you perform action

---

## 📜 Commands

### Universal Commands

**These work on ALL jobs**:

| Command | Description | Example |
|---------|-------------|---------|
| `//gs c checksets` | Validate equipment | Shows missing/storage items |
| `//gs c reload` | Full system reload | Reloads all files |
| `//gs c lockstyle` | Reapply lockstyle | Manual lockstyle trigger |
| `//gs c ui` | Toggle UI overlay | Show/hide keybinds |
| `//gs c debugmidcast` | Toggle midcast debug | Show set selection logic |

### [JOB]-Specific Commands

**File**: `shared/jobs/[job]/functions/[JOB]_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
| `//gs c [command1]` | [Description] | [Example] |
| `//gs c [command2]` | [Description] | [Example] |
| **[Add all job-specific commands]** |

### Command Examples

**Example 1**: [Command name]
```
//gs c [command] [params]

→ [What happens]
→ [Result shown in console]
```

**Example 2**: [Command name]
```
//gs c [command]

→ [What happens]
```

---

## 🎛️ States & Modes

### What are States?

**States** = Configuration options you cycle through with keybinds.

**Example**:
```lua
state.HybridMode = M{'PDT', 'Normal'}  -- 2 options
-- Press Alt+2 to cycle: PDT → Normal → PDT → ...
```

### All [JOB] States

**File**: `Tetsouo/config/[job]/[JOB]_STATES.lua` (if exists, or in main file)

| State | Options | Default | Keybind | Description |
|-------|---------|---------|---------|-------------|
| **MainWeapon** | [List] | [Default] | Alt+1 | [What it does] |
| **HybridMode** | PDT, Normal | PDT | Alt+2 | Defense mode |
| **[Add all states]** |

### How States Affect Gear

**Example**: HybridMode state
```
HybridMode: PDT
→ Uses: sets.engaged.PDT (defensive melee gear)

HybridMode: Normal
→ Uses: sets.engaged.Normal (DPS melee gear)
```

**Where sets are defined**: `shared/jobs/[job]/sets/[job]_sets.lua`

### Checking Current State

**Method 1**: Look at UI overlay (if enabled)
**Method 2**: Console command:
```
//gs c state [StateName]
→ Shows current value
```

---

## 🎽 Equipment Sets

### Set File Location

**File**: `shared/jobs/[job]/sets/[job]_sets.lua`

### Set Structure

```lua
sets.precast = {}        -- Fast Cast, Job Abilities, Weaponskills
sets.midcast = {}        -- Spell/ability midcast gear
sets.idle = {}           -- Idle (not fighting)
sets.engaged = {}        -- Engaged (fighting)
```

### Main Set Categories

#### 1. **Precast Sets** (Fast Cast, JA, WS)

**Purpose**: Equipped when you START casting/using ability

```lua
-- Fast Cast (all spells)
sets.precast.FC = {
    head = "...",  -- Fast Cast gear
    -- ...
}

-- Job Abilities
sets.precast.JA['Ability Name'] = {
    -- Ability-specific gear
}

-- Weaponskills
sets.precast.WS['Weaponskill Name'] = {
    -- WS damage gear
}
```

#### 2. **Midcast Sets** (Spell Effects)

**Purpose**: Equipped DURING spell cast (when effect applies)

```lua
-- By skill
sets.midcast['Skill Name'] = {
    -- Base set for this skill
}

-- With modes (nested)
sets.midcast['Skill Name'].ModeName = {
    -- Mode-specific gear
}
```

**How MidcastManager selects sets**:
```
Priority 1: sets.midcast['Skill'].Type.Mode  (most specific)
Priority 2: sets.midcast['Skill'].Type
Priority 3: sets.midcast['Skill'].Mode
Priority 4: sets.midcast['Skill']            (guaranteed fallback)
```

#### 3. **Idle Sets** (Not Fighting)

**Purpose**: Equipped when standing/moving (not engaged)

```lua
sets.idle.Normal = {
    -- Refresh, Regen, Movement Speed
}

sets.idle.PDT = {
    -- Physical Damage Taken - (defensive)
}
```

**Auto-equipped**: System detects idle status and equips appropriate set.

#### 4. **Engaged Sets** (Fighting)

**Purpose**: Equipped when engaged in melee combat

```lua
sets.engaged.Normal = {
    -- DPS gear (Store TP, Multi-Attack, etc.)
}

sets.engaged.PDT = {
    -- Defensive melee gear
}
```

**Auto-equipped**: System detects engaged status and equips based on HybridMode state.

### Validating Your Sets

**Check what items you're missing**:
```
//gs c checksets

→ Output:
[JOB] ✅ 156/160 items validated (97.5%)

--- STORAGE ITEMS (3) ---
[STORAGE] sets.idle.PDT.body: "Item Name"

--- MISSING ITEMS (1) ---
[MISSING] sets.precast.WS['WS Name'].ring1: "Item Name"
```

**Status meanings**:
- ✅ **VALID**: Item in inventory (ready to swap)
- 🗄️ **STORAGE**: Item in mog house/sack (move to inventory if needed)
- ❌ **MISSING**: Item not found (acquire or update sets)

---

## ⚙️ Configuration Files

### File Locations

**All configs**: `Tetsouo/config/[job]/`

| File | Purpose | Contains |
|------|---------|----------|
| **[JOB]_KEYBINDS.lua** | Keybind definitions | All Alt+X keybinds |
| **[JOB]_LOCKSTYLE.lua** | Lockstyle settings | Lockstyle # per subjob |
| **[JOB]_MACROBOOK.lua** | Macrobook settings | Book/page per subjob |
| **[JOB]_STATES.lua** | State definitions | (If exists) Custom states |
| **[Add job-specific configs]** |

### Example: Keybinds Config

**File**: `Tetsouo/config/[job]/[JOB]_KEYBINDS.lua`

```lua
local [JOB]Keybinds = {}

[JOB]Keybinds.keybinds = {
    {key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon"},
    {key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode"},
    -- ... more keybinds
}

return [JOB]Keybinds
```

### Example: Lockstyle Config

**File**: `Tetsouo/config/[job]/[JOB]_LOCKSTYLE.lua`

```lua
local [JOB]LockstyleConfig = {}

[JOB]LockstyleConfig.default = 1

[JOB]LockstyleConfig.by_subjob = {
    ['SAM'] = 1,
    ['NIN'] = 2,
    ['DNC'] = 3,
}

return [JOB]LockstyleConfig
```

**How it works**:
- Job changes to [JOB]/SAM → Applies lockstyle #1
- Job changes to [JOB]/NIN → Applies lockstyle #2
- Job changes to [JOB]/DNC → Applies lockstyle #3

### Example: Macrobook Config

**File**: `Tetsouo/config/[job]/[JOB]_MACROBOOK.lua`

```lua
local [JOB]MacroConfig = {}

[JOB]MacroConfig.default = {book = 1, page = 1}

[JOB]MacroConfig.macrobooks = {
    ['SAM'] = {book = 1, page = 1},
    ['NIN'] = {book = 1, page = 2},
    ['DNC'] = {book = 1, page = 3},
}

return [JOB]MacroConfig
```

**How it works**:
- Job changes to [JOB]/SAM → Sets macrobook 1, page 1
- Job changes to [JOB]/NIN → Sets macrobook 1, page 2

---

## 🔧 Customization

### Adding a Keybind

**File**: `Tetsouo/config/[job]/[JOB]_KEYBINDS.lua`

**Example**: Add Alt+9 to cycle a new state

```lua
-- 1. Add to keybinds table
{key = "!9", command = "cycle MyNewState", desc = "My State", state = "MyNewState"},

-- 2. Define state in main file (TETSOUO_[JOB].lua or Tetsouo_[JOB].lua)
state.MyNewState = M{'Option1', 'Option2', 'Option3'}
state.MyNewState:set('Option1')  -- Set default

-- 3. Reload
//lua reload gearswap
```

### Changing a Keybind

**Change Alt+1 from "!1" to "!0"**:

```lua
-- Before:
{key = "!1", command = "cycle MainWeapon", ...}

-- After:
{key = "!0", command = "cycle MainWeapon", ...}

-- Reload:
//lua reload gearswap
```

### Modifying Equipment Sets

**File**: `shared/jobs/[job]/sets/[job]_sets.lua`

**Example**: Upgrade idle set body piece

```lua
-- Before:
sets.idle.Normal = {
    body = "Old Body Piece",
    -- ...
}

-- After:
sets.idle.Normal = {
    body = "New Body Piece",  -- Changed
    -- ...
}

-- Reload and validate:
//lua reload gearswap
//gs c checksets  → Should show new item validated
```

### Adding a New Mode to Existing State

**Example**: Add "MDT" mode to HybridMode

```lua
-- 1. In main file, update state options:
state.HybridMode:options('PDT', 'Normal', 'MDT')  -- Add MDT

-- 2. In sets file, create MDT sets:
sets.idle.MDT = {
    -- Magic Damage Taken - gear
}

sets.engaged.MDT = {
    -- MDT melee gear
}

-- 3. Reload:
//lua reload gearswap

-- 4. Press Alt+2 to cycle: PDT → Normal → MDT → PDT
```

### Changing Lockstyle

**File**: `Tetsouo/config/[job]/[JOB]_LOCKSTYLE.lua`

```lua
-- Change default lockstyle from 1 to 5:
[JOB]LockstyleConfig.default = 5  -- Changed

-- Change SAM subjob lockstyle from 1 to 10:
[JOB]LockstyleConfig.by_subjob['SAM'] = 10  -- Changed

-- Reload and reapply:
//lua reload gearswap
//gs c lockstyle  → Applies new lockstyle
```

---

## 🔍 Troubleshooting

### Issue: Keybinds Not Working

**Symptoms**: Pressing Alt+1 does nothing

**Solutions**:

1. **Check if keybinds loaded**:
   ```
   //lua reload gearswap
   → Look for: "[JOB] Keybinds loaded successfully"
   ```

2. **Check for conflicts**:
   - Another addon using same keybind?
   - Try different key (change "!1" to "!0")

3. **Manual test**:
   ```
   //gs c cycle MainWeapon  (should work if system loaded)
   ```

4. **Verify config file exists**:
   - Check: `Tetsouo/config/[job]/[JOB]_KEYBINDS.lua`

---

### Issue: Gear Not Swapping

**Symptoms**: Equipment doesn't change when casting/engaging

**Solutions**:

1. **Check Watchdog status**:
   ```
   //gs c watchdog
   → If stuck: //gs c watchdog clear
   ```

2. **Check item availability**:
   ```
   //gs c checksets
   → Look for MISSING or STORAGE items
   → Move STORAGE items to inventory
   ```

3. **Enable debug mode**:
   ```
   //gs c debugmidcast
   → Cast spell
   → Check console for set selection logic
   ```

4. **Full reload**:
   ```
   //lua reload gearswap
   ```

---

### Issue: Wrong Set Equipped

**Symptoms**: System equips wrong gear for spell/action

**Solutions**:

1. **Enable midcast debug**:
   ```
   //gs c debugmidcast
   → Cast spell
   → Console shows which set was selected and why
   ```

2. **Check state values**:
   ```
   //gs c state [StateName]
   → Verify current state is what you expect
   ```

3. **Check set exists**:
   - Open: `shared/jobs/[job]/sets/[job]_sets.lua`
   - Search for expected set name
   - If missing, MidcastManager falls back to parent set

4. **Understand fallback chain**:
   ```
   Requested: sets.midcast['Skill'].Type.Mode
   → Not found, tries: sets.midcast['Skill'].Type
   → Not found, tries: sets.midcast['Skill'].Mode
   → Not found, uses: sets.midcast['Skill'] (guaranteed)
   ```

---

### Issue: Lockstyle Not Applying

**Symptoms**: Visual appearance doesn't match lockstyle

**Solutions**:

1. **Check DressUp loaded**:
   ```
   //lua l dressup
   ```

2. **Manual reapply**:
   ```
   //gs c lockstyle
   ```

3. **Check config**:
   - File: `Tetsouo/config/[job]/[JOB]_LOCKSTYLE.lua`
   - Verify lockstyle # exists in-game (`/lockstyleset X`)

4. **Wait for delay**:
   - Initial load: 8 second delay (automatic)
   - Job change: 8 second delay (automatic)

---

### Issue: Job Change Errors

**Symptoms**: Errors when changing jobs, duplicate UI, keybinds broken

**Solutions**:

1. **Wait for debounce period**:
   - JobChangeManager has 3.0s cooldown
   - Don't spam job changes

2. **Full reload**:
   ```
   //lua unload gearswap
   //lua load gearswap
   ```

3. **Check JobChangeManager state**:
   - System auto-cancels pending operations
   - Prevents conflicts on rapid job changes

---

### Issue: Commands Not Working

**Symptoms**: `//gs c [command]` does nothing or shows error

**Solutions**:

1. **Check command exists**:
   - File: `shared/jobs/[job]/functions/[JOB]_COMMANDS.lua`
   - Or universal: `shared/utils/core/COMMON_COMMANDS.lua`

2. **Check syntax**:
   ```
   //gs c command  (correct)
   //gs command    (wrong - missing 'c')
   ```

3. **Enable debug**:
   - Check console for error messages
   - Look for typos in command name

---

### Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Toggle midcast debug (shows set selection) |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
| `//gs c checksets` | Validate all equipment |

---

## 📚 Additional Resources

### Related Documentation

- [Installation Guide](../../getting-started/installation.md)
- [Quick Start Guide](../../getting-started/quick-start.md)
- [Commands Reference](../../guides/commands.md)
- [Configuration Guide](../../guides/configuration.md)
- [Equipment Validation](../../features/equipment-validation.md)
- [MidcastManager System](../../../technical/systems/midcast-manager.md)
- [Debug Midcast Guide](../../../technical/guides/debug-midcast.md)

### System Files (Reference)

**Main file**: `TETSOUO_[JOB].lua` or `Tetsouo_[JOB].lua`
**Functions**: `shared/jobs/[job]/functions/[job]_functions.lua`
**Sets**: `shared/jobs/[job]/sets/[job]_sets.lua`
**Config**: `Tetsouo/config/[job]/`

---

## 📝 Quick Reference

```
LOAD SYSTEM:
//lua load gearswap

VALIDATE EQUIPMENT:
//gs c checksets

RELOAD SYSTEM:
//lua reload gearswap

TOGGLE UI:
//gs c ui

DEBUG MIDCAST:
//gs c debugmidcast

REAPPLY LOCKSTYLE:
//gs c lockstyle

CLEAR WATCHDOG:
//gs c watchdog clear
```

---

**Version**: 1.0
**Author**: Tetsouo GearSwap Project
**Last Updated**: [DATE]
**Status**: ✅ Production Ready

---

**Master your [JOB] GearSwap system!** ✨

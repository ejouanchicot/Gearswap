# [JOB_FULL_NAME] Guide ([JOB])

**Job Code**: [JOB]
**Type**: [Tank/Healer/DPS/Support/Hybrid]
**Difficulty**: [Easy/Medium/Hard]
**Status**: ✅ Production Ready
**Version**: 1.0
**Last Updated**: [DATE]

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Job Features](#job-features)
3. [States & Modes](#states--modes)
4. [Keybinds Reference](#keybinds-reference)
5. [Gear Sets Explained](#gear-sets-explained)
6. [Commands](#commands)
7. [Strategies & Rotations](#strategies--rotations)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Customization](#advanced-customization)

---

## 🚀 Quick Start

### First Time Setup

1. **Load the job**:

   ```
   Change to [JOB] in-game
   //lua load gearswap
   ```

2. **Verify installation**:

   ```
   //gs c checksets
   ```

   → Should show your equipment validation results

3. **Test keybinds**:
   - Press **Alt+F1** to toggle UI (see all keybinds)
   - Press **Alt+1** to cycle main weapon
   - Press **Alt+2** to cycle Hybrid Mode (PDT/Normal)

### Essential Commands

| Command | Description |
|---------|-------------|
| `//gs c reload` | Full system reload |
| `//gs c checksets` | Validate equipment |
| `//gs c lockstyle` | Reapply lockstyle |
| `//gs c ui` | Toggle UI overlay |

### Default Behavior

When you load [JOB]:

- ✅ Keybinds auto-loaded
- ✅ Macrobook auto-set (Book X, Page Y)
- ✅ Lockstyle auto-applied (after 8s delay)
- ✅ UI displays all keybinds (if enabled)
- ✅ Hybrid Mode set to PDT (defensive by default)

---

## ⚙️ Job Features

### Feature 1: [Feature Name]

**What it does**: [Brief description]

**How to use**:

```
[Command or keybind]
```

**Configuration**:

```lua
-- In Tetsouo/config/[job]/[JOB]_STATES.lua
state.FeatureName = M{
    ['description'] = 'Feature Description',
    'Option1',
    'Option2'
}
```

**Examples**:

- [Example scenario 1]
- [Example scenario 2]

---

### Feature 2: [Feature Name]

[Same structure as Feature 1]

---

## 🎛️ States & Modes

### Universal States (All Jobs)

| State | Options | Default | Keybind | Description |
|-------|---------|---------|---------|-------------|
| **MainWeapon** | [Weapon1, Weapon2, ...] | [Weapon1] | Alt+1 | Main weapon selection |
| **HybridMode** | PDT, Normal | PDT | Alt+2 | Defense mode |
| **OffenseMode** | [varies] | Normal | F9 | Offense stance |
| **DefenseMode** | [varies] | None | F10 | Defense stance |

### Job-Specific States

| State | Options | Default | Keybind | Description |
|-------|---------|---------|---------|-------------|
| **[StateName]** | [Options] | [Default] | [Key] | [Description] |

**Example configuration**:

```lua
-- In Tetsouo/config/[job]/[JOB]_STATES.lua
state.CustomMode = M{
    ['description'] = 'Custom Mode Description',
    'Mode1',  -- Description of Mode1
    'Mode2'   -- Description of Mode2
}
```

---

## ⌨️ Keybinds Reference

### Universal Keybinds (All Jobs)

| Key | Function | Description |
|-----|----------|-------------|
| **Alt+1** | Cycle Main Weapon | Switch between weapon options |
| **Alt+2** | Cycle Hybrid Mode | Toggle PDT/Normal |
| **Alt+F1** | Toggle UI | Show/hide keybind overlay |
| **F9** | Cycle Offense Mode | Change offense stance |
| **F10** | Cycle Defense Mode | Change defense stance |
| **F12** | Update Gear | Force gear refresh |

### [JOB]-Specific Keybinds

| Key | Function | Description |
|-----|----------|-------------|
| **[Key]** | [Function] | [Description] |

**Full keybind list**: See [Keybinds Guide](../../../guides/keybinds.md#[job])

---

## 🎽 Gear Sets Explained

### Precast Sets

#### Fast Cast

```lua
sets.precast.FC = {
    -- Fast Cast gear for spell casting speed
    head = "...",
    neck = "...",
    -- ...
}
```

**Purpose**: Reduce casting time
**Key stats**: Fast Cast%, Haste

#### Weaponskills

```lua
sets.precast.WS['Weaponskill Name'] = {
    -- Weaponskill-specific gear
}
```

**Purpose**: Maximize WS damage
**Key stats**: [STR/DEX/etc.], Attack, Critical Hit

---

### Midcast Sets

#### [Skill Name] (e.g., Healing Magic, Elemental Magic)

```lua
sets.midcast['Skill Name'] = {
    -- Base midcast gear
}

sets.midcast['Skill Name'].ModeOption = {
    -- Mode-specific gear
}
```

**Purpose**: [Describe purpose]
**Key stats**: [Relevant stats]
**Modes**: [List modes if applicable]

---

### Idle Sets

```lua
sets.idle.Normal = {
    -- Normal idle gear (Refresh, Regen, Movement Speed)
}

sets.idle.PDT = {
    -- PDT idle gear (Physical Damage Taken -)
}
```

**Auto-equipped**: When standing still or moving
**Modes**: Normal (default), PDT

---

### Engaged Sets

```lua
sets.engaged.Normal = {
    -- Normal melee gear (DPS focused)
}

sets.engaged.PDT = {
    -- PDT melee gear (defensive)
}
```

**Auto-equipped**: When in combat
**Modes**: Normal, PDT

---

## 📜 Commands

### Equipment Validation

```
//gs c checksets
```

**Output**:

- ✅ VALID: Item in inventory
- 🗄️ STORAGE: Item in storage (mog house, sack, etc.)
- ❌ MISSING: Item not found

### Reload System

```
//gs c reload
```

Full reload of GearSwap (reloads all files, reapplies keybinds)

### Lockstyle

```
//gs c lockstyle
```

Manually reapply lockstyle (usually auto-applied)

### [Job]-Specific Commands

| Command | Description |
|---------|-------------|
| `//gs c [command]` | [Description] |

**Full command list**: See [Commands Guide](../../../guides/commands.md#[job])

---

## 🎯 Strategies & Rotations

### Basic Combat Rotation

**Opening**:

1. [Step 1]
2. [Step 2]
3. [Step 3]

**Sustained DPS**:

- [Rotation explanation]

**Defensive Situations**:

- Switch to PDT mode (Alt+2)
- [Additional defensive actions]

---

### Advanced Strategies

#### Strategy 1: [Name]

**When to use**: [Situation]

**How**:

1. [Step 1]
2. [Step 2]

**Tips**:

- [Tip 1]
- [Tip 2]

---

#### Strategy 2: [Name]

[Same structure as Strategy 1]

---

## 🔧 Troubleshooting

### Common Issues

#### Gear Not Swapping

**Symptoms**: Equipment doesn't change when casting/fighting

**Solutions**:

1. Check Watchdog status: `//gs c watchdog`
2. If stuck, clear manually: `//gs c watchdog clear`
3. Reload: `//gs c reload`

#### Lockstyle Not Applying

**Symptoms**: Visual appearance doesn't match lockstyle

**Solutions**:

1. Ensure DressUp addon loaded: `//lua l dressup`
2. Manual reapply: `//gs c lockstyle`
3. Check config: `Tetsouo/config/[job]/[JOB]_LOCKSTYLE.lua`

#### Keybinds Not Working

**Symptoms**: Pressing keybinds does nothing

**Solutions**:

1. Reload GearSwap: `//lua reload gearswap`
2. Check keybinds loaded: Look for "[JOB] Keybinds loaded" message
3. Verify config: `Tetsouo/config/[job]/[JOB]_KEYBINDS.lua`

#### Sets Showing as MISSING

**Symptoms**: `//gs c checksets` shows items as MISSING

**Solutions**:

1. Verify items are in inventory (not storage)
2. Check item name spelling in sets
3. If intentionally not owned, this is expected (upgrade path)

---

### Debug Mode

Enable debug output for troubleshooting:

```
//gs c debugmidcast  (toggle midcast debug)
```

**Output**: Shows which sets are being selected and why

---

## 🔬 Advanced Customization

### Adding a New State

**Example**: Add a custom mode for [specific purpose]

**Step 1**: Define state in `[JOB]_STATES.lua`:

```lua
state.CustomMode = M{
    ['description'] = 'Custom Mode',
    'Option1',
    'Option2'
}
state.CustomMode:set('Option1')  -- Set default
```

**Step 2**: Create sets in `[job]_sets.lua`:

```lua
sets.midcast['Skill Name'].Option1 = {
    -- Gear for Option1
}

sets.midcast['Skill Name'].Option2 = {
    -- Gear for Option2
}
```

**Step 3**: Add keybind in `[JOB]_KEYBINDS.lua`:

```lua
{key = "!X", command = "cycle CustomMode", desc = "Custom Mode", state = "CustomMode"}
```

**Step 4**: Test:

```
//lua reload gearswap
Press Alt+X to cycle
Cast spell to verify gear changes
```

**See**: [Add New State Guide](../../../../technical/guides/add-new-state.md) for complete details

---

### Modifying Existing Sets

**File**: `shared/jobs/[job]/sets/[job]_sets.lua`

**Example**: Upgrade cure potency gear

```lua
sets.midcast['Healing Magic'] = {
    head = "Upgraded Helm",  -- Change this
    neck = "Better Neck",     -- Change this
    -- ... keep or change other pieces
}
```

**After changes**:

1. Reload: `//lua reload gearswap`
2. Validate: `//gs c checksets`
3. Test in-game

---

### Custom Commands

**File**: `shared/jobs/[job]/functions/[JOB]_COMMANDS.lua`

**Example**: Add custom command

```lua
function job_self_command(cmdParams, eventArgs)
    local command = cmdParams[1]:lower()

    -- Your custom command
    if command == 'mycommand' then
        add_to_chat(122, '[JOB] Custom command executed!')
        eventArgs.handled = true
        return
    end
end
```

**Usage**: `//gs c mycommand`

---

## 📚 Additional Resources

### Related Guides

- [Installation Guide](../../getting-started/installation.md)
- [Quick Start Guide](../../getting-started/quick-start.md)
- [Commands Reference](../../guides/commands.md)
- [Keybinds Guide](../../guides/keybinds.md)
- [Configuration Guide](../../guides/configuration.md)
- [FAQ](../../guides/faq.md)

### Technical Documentation

- [MidcastManager System](../../../technical/systems/midcast-manager.md)
- [MidcastBuilder System](../../../technical/systems/midcast-builder.md)
- [Debug Midcast Guide](../../../technical/guides/debug-midcast.md)
- [Add New State Guide](../../../technical/guides/add-new-state.md)

### Job-Specific

- [TP Bonus Reference](tp-bonus.md) (if applicable)
- [Abilities Reference](abilities.md) (if applicable)

---

## 📝 Quick Reference Card

```
ESSENTIAL KEYBINDS:
Alt+1    = Cycle Main Weapon
Alt+2    = Cycle Hybrid Mode (PDT/Normal)
Alt+F1   = Toggle UI
F12      = Update Gear

ESSENTIAL COMMANDS:
//gs c checksets   = Validate equipment
//gs c reload      = Full reload
//gs c lockstyle   = Reapply lockstyle

JOB-SPECIFIC:
[List 3-5 most important job-specific keybinds/commands]
```

---

**Version**: 1.0
**Author**: Tetsouo GearSwap Project
**Last Updated**: [DATE]
**Status**: ✅ Production Ready

---

**Happy adventuring in Vana'diel!** ✨

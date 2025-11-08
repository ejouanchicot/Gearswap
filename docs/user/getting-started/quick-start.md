# Quick Start Guide

This guide will get you up and running with the Tetsouo GearSwap system in 5 minutes.

## Basic Usage

### Job Loading

When you change jobs, GearSwap automatically:

1. Loads your job-specific configuration
2. Applies equipment sets
3. Binds keybinds
4. Sets macrobook and page
5. Applies lockstyle (after 8s delay)

**You don't need to do anything - it's fully automatic!**

### Essential Commands

```bash
//gs c checksets       # Validate your equipment
//gs c reload          # Reload GearSwap (after editing files)
//gs c lockstyle       # Manually apply lockstyle
//gs c ui hide         # Hide UI overlay
//gs c ui show         # Show UI overlay
```

## Essential Keybinds

All jobs share these core keybinds:

| Keybind | Function | Description |
|---------|----------|-------------|
| **Alt+1** | Cycle Main Weapon | Change weapon set |
| **Alt+2** | Cycle Hybrid Mode | Toggle PDT/Normal |
| **Alt+F1** | Toggle UI | Show/hide keybind overlay |
| **F9** | Cycle Offense Mode | Normal/Acc |
| **F10** | Cycle Defense Mode | Normal/PDT/MDT |
| **F11** | Cycle Casting Mode | Normal/Resistant |
| **F12** | Update Gear | Force equipment refresh |

### Job-Specific Keybinds

Each job has unique keybinds for job-specific features.

**WAR Example**:

- Alt+3: Cycle TP Mode (Attack/AccuracyMax/etc.)

**PLD Example**:

- Alt+3: Cycle Cure Mode
- Alt+4: Cycle Enmity Mode

**DNC Example**:

- Alt+W: Waltz macro
- Alt+S: Steps macro

See `../guides/keybinds.md` for complete job-specific keybind lists.

## Common Workflows

### Changing Equipment Sets

Equipment changes automatically based on:

- **Action type**: Precast (Fast Cast) >> Midcast (Potency) >> Aftercast (Idle/Engaged)
- **Player status**: Idle, Engaged, Resting
- **Active modes**: PDT, MDT, Normal, Accuracy
- **Buffs**: Auto-adjusts for active buffs

**Example Flow (Cure spell)**:

1. Start casting Cure IV
2. Precast: Fast Cast gear equipped
3. Midcast: Cure Potency gear equipped
4. Aftercast: Return to Idle or Engaged gear

**You don't need to manually swap - GearSwap handles it all!**

### Using Hybrid Modes

Hybrid modes let you balance offense and defense:

```bash
Alt+2                 # Cycle: Normal >> PDT >> Normal
```

- **Normal**: Maximum offense
- **PDT**: Physical damage reduction (engaged sets with PDT gear)

When in PDT mode, all engaged sets use defensive gear automatically.

### Validating Your Gear

Check which equipment you're missing:

```bash
//gs c checksets
```

Output example:

```
[WAR] Validating equipment sets...
[WAR] ✓ 42/44 items validated (95.5%)

[MISSING] sets.idle.PDT.body: "Sakpata's Plate"
[STORAGE] sets.precast.WS['Upheaval'].neck: "Fotia Gorget"
```

- **[MISSING]**: Item not found anywhere
- **[STORAGE]**: Item is in storage (Mog House, etc.)

## Job-Specific Quick Start

### Warrior (WAR)

**Core Commands**:

```bash
//gs c cycle MainWeapon    # Cycle weapons
//gs c cycle TPMode        # Attack/AccuracyMax/etc.
```

**Key Features**:

- Automatic TP Bonus display on WS
- Mighty Strikes detection
- Weapon-specific WS sets

### Paladin (PLD)

**Core Commands**:

```bash
//gs c cycle CureMode      # Cure gear modes
//gs c cycle EnmityMode    # Enmity on/off
//gs c bluaoe               # Cast AOE Blue Magic rotation
```

**Key Features**:

- Auto-Majesty before Cure spells
- Divine Emblem auto-trigger
- Enmity mode toggle

### Dancer (DNC)

**Core Commands**:

```bash
//gs c waltz               # Smart tier Waltz (HP-based)
//gs c aoewaltz            # AOE Waltz
```

**Key Features**:

- Automatic Waltz tier selection (HP-based)
- Climactic Flourish auto-trigger on WS
- Step/Flourish management

## Advanced Features

### Watchdog System

Protects against stuck midcast in laggy zones (Odyssey, Dynamis):

```bash
//gs c watchdog            # Show status
//gs c watchdog debug      # Toggle debug mode
//gs c watchdog test       # Test detection
```

**Automatic**: No setup needed - works in background.

### Dual-Boxing

Synchronize jobs between characters:

```bash
//gs c altjob             # Display alt character job
```

**Automatic**: Characters auto-share job info when loading.

### UI Overlay

Visual keybind reference:

```bash
//gs c ui show            # Show overlay
//gs c ui hide            # Hide overlay
//gs c ui save            # Save position
Alt+F1                    # Quick toggle
```

**Customizable**: Drag to reposition, saves automatically.

## Common Issues

### Gear not swapping after spell

**Fix**: Network lag detected - Watchdog will auto-recover after 3.5s.

### Lockstyle not applying

**Fix**:

```bash
//lua load dressup
//gs c lockstyle
```

### Keybinds not working

**Fix**:

```bash
//lua reload gearswap
```

## Next Steps

- **Commands Reference**: See `../guides/commands.md` for all commands
- **Keybinds Customization**: See `../guides/keybinds.md`
- **Configuration**: See `../guides/configuration.md` for advanced settings
- **Features**: Explore `../features/` for detailed feature documentation

## Tips

1. **Use `//gs c checksets` regularly** to verify equipment
2. **Keep DressUp addon loaded** for lockstyle functionality
3. **Press F12 after zoning** if gear looks wrong (forces update)
4. **Use debug mode sparingly**: `//gs debugmode` (very verbose)

---

**Version**: 1.0
**Last Updated**: 2025-10-26
**Supported Jobs**: WAR, PLD, DNC, DRK, SAM, THF, RDM, WHM, BLM, GEO, COR, BRD, BST

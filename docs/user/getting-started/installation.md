# Installation Guide

## Prerequisites

Before installing the Tetsouo GearSwap system, ensure you have:

1. **FFXI with Windower 4**
 - Working FFXI installation
 - Windower 4 installed and configured
 - Admin permissions for file modifications

2. **Required Windower Addons**
 - **GearSwap** (Core dependency)
 - **DressUp** (For lockstyle functionality)

3. **Optional but Recommended Addons**
 - **ConsoleBG** (Better console readability)
 - **InfoBar** (Status information)

## Installation Steps

### Step 1: Install Required Addons

Open Windower and run these commands in the FFXI chat:

```
//lua load gearswap
//lua load dressup
```

Verify they loaded successfully - you should see confirmation messages.

### Step 2: Backup Existing GearSwap Data

**IMPORTANT**: If you already have GearSwap files, back them up first!

1. Navigate to: `[Windower]/addons/GearSwap/data/`
2. Copy your existing character files to a backup folder

### Step 3: Install Tetsouo GearSwap Files

1. Extract the Tetsouo GearSwap package
2. Copy the entire contents to: `[Windower]/addons/GearSwap/data/`
3. The structure should look like:

```
[Windower]/addons/GearSwap/data/
├── [YourName]/              (Character-specific: entry files, config, sets)
├── _master/                 (Templates for new characters)
├── shared/                  (Core systems -- do not modify)
│   ├── jobs/
│   ├── utils/
│   ├── data/
│   └── hooks/
├── docs/                    (Documentation)
└── README.md
```

### Step 4: Configure Character Name

**Option A: Clone Script** (Recommended)

Use the included clone tool to generate your character files from the `_master/` templates:

```
python clone_character.py
```

Or double-click `CLONE_CHARACTER.bat`. The script uses `character_db.lua` to auto-detect which jobs a known character needs, or lets you pick manually.

**Option B: Manual Copy**

1. Copy `_master/entry/Tetsouo_WAR.lua` to `[YourName]/[YourName]_WAR.lua`
2. Copy `_master/config/war/` to `[YourName]/config/war/`
3. Copy `_master/sets/war_sets.lua` to `[YourName]/sets/war_sets.lua`
4. Edit the entry file to replace `Tetsouo` with your character name
5. Repeat for each job you want

### Step 5: Load GearSwap

1. Log into FFXI with your character
2. Change to any job (WAR, PLD, DNC, etc.)
3. Run: `//lua reload gearswap`

You should see:

```
[WAR] SYSTEM LOADED
[WAR] Keybinds loaded successfully
[WAR] Macrobook set: Book 1, Page 1
[Watchdog] Initialized
```

### Step 6: Apply Lockstyle

Lockstyle applies automatically 8 seconds after job load.

To manually trigger:

```
//gs c lockstyle
```

### Step 7: Verify Installation

Run the equipment validation command:

```
//gs c checksets
```

You should see:

```
[WAR] Validating equipment sets...
[WAR] 42/44 items validated (95.5%)
```

Items marked `[MISSING]` or `[STORAGE]` will be listed.

## Troubleshooting

### Issue: "Could not find character file"

**Solution**: Ensure your character file matches your in-game name exactly:

- File: `YOURNAME_WAR.lua`
- Character name in-game: `Yourname`

GearSwap is case-sensitive!

### Issue: "Module not found" errors

**Solution**: Verify the `shared/` folder structure is intact:

```
//lua reload gearswap
```

If errors persist, check file paths in the error message.

### Issue: Lockstyle not applying

**Solution**:

1. Verify DressUp is loaded: `//lua list`
2. Check lockstyle config: `config/[job]/[JOB]_LOCKSTYLE.lua`
3. Manually apply: `//gs c lockstyle`

### Issue: Keybinds not working

**Solution**:

1. Check keybind config: `config/[job]/[JOB]_KEYBINDS.lua`
2. Manually reload: `//lua reload gearswap`
3. Verify no keybind conflicts with other addons

## Next Steps

- **Quick Start**: See `quick-start.md` for basic usage
- **Commands**: See `../guides/commands.md` for all available commands
- **Keybinds**: See `../guides/keybinds.md` for keybind customization
- **Configuration**: See `../guides/configuration.md` for advanced settings

## Support

If you encounter issues:

1. Check the **FAQ**: `../guides/faq.md`
2. Enable debug mode: `//gs debugmode`
3. Check Windower console for error messages
4. Verify all prerequisites are met

---

**Supported Jobs**: BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, PUP, RDM, RUN, SAM, THF, WAR, WHM (15 jobs)

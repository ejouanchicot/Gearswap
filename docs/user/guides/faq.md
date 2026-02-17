# FAQ - Frequently Asked Questions

Common issues and solutions for the Tetsouo GearSwap system.


---

## Table of Contents

- [General Issues](#general-issues)
- [Installation & Loading](#installation--loading)
- [Equipment & Gear Swapping](#equipment--gear-swapping)
- [Lockstyle](#lockstyle)
- [Keybinds](#keybinds)
- [UI Issues](#ui-issues)
- [Watchdog](#watchdog)
- [Performance](#performance)

---

## General Issues

### Q: "The system doesn't load when I log in"

**Symptoms:**

- No "Job change complete" message
- Lockstyle not applied
- Macros not loaded

**Solutions:**

1. **Verify GearSwap is loaded**

   ```
   //lua list
   ```

   GearSwap should appear in the list.

2. **Load GearSwap manually**

   ```
   //lua load gearswap
   ```

3. **Check character file name**
   - File must be named exactly: `YOURNAME_WAR.lua` (or your character name)
   - Path: `addons/GearSwap/data/[YourName]/[YourName]_WAR.lua`
   - Character name is case-sensitive

4. **Check for Lua errors**
   - Look for red error messages in chat
   - Note the file name and line number

---

### Q: "I get Lua errors when loading"

**Typical error:**

```
YOURNAME_WAR.lua:47: Cannot find the include file ...
```

**Solutions:**

1. **Reload the system**

   ```
   //gs c reload
   ```

2. **Verify folder structure**

   ```
   addons/GearSwap/data/
   ├── [YourName]/           (Character folder)
   │   ├── [YourName]_WAR.lua
   │   └── config/
   └── shared/               (Core system - don't modify)
       ├── jobs/
       └── utils/
   ```

3. **Check the error line**
   - Open the file mentioned in error
   - Check line number for syntax errors

4. **Verify shared/ folder exists**
   - Core system files must be in `data/shared/`
   - Don't modify shared/ files

---

### Q: "How do I update to latest version?"

**Solutions:**

1. **Backup your config**

   ```bash
   # Copy your character folder
   cp -r [YourName]/ [YourName]_backup/
   ```

2. **Extract new version**
   - Extract to `addons/GearSwap/data/`
   - Overwrite `shared/` folder (core system)
   - **Don't overwrite** your character folder

3. **Reload**

   ```
   //lua reload gearswap
   ```

---

## Installation & Loading

### Q: "GearSwap won't load my character file"

**Solutions:**

1. **Case sensitivity**
   - File: `Tetsouo_WAR.lua`
   - Character: `Tetsouo` (exact match)

2. **Verify file location**

   ```
   addons/GearSwap/data/[YourName]/[YourName]_WAR.lua
   ```

3. **Check Windower console**
   - `//console show`
   - Look for "Cannot find file" errors

---

### Q: "Addons required?"

**Required:**

- **GearSwap** (core addon)
- **DressUp** (for lockstyle)

**Optional but Recommended:**

- **ConsoleBG** (better console readability)
- **InfoBar** (status info display)

**Load commands:**

```
//lua load gearswap
//lua load dressup
```

---

## Equipment & Gear Swapping

### Q: "Gear not swapping after spell/WS"

**Symptoms:**

- Equipment stays in midcast gear
- Doesn't return to idle/engaged

**Solutions:**

1. **Network lag detected - Watchdog protection**
   - Wait 3.5 seconds for automatic recovery
   - Watchdog will force cleanup automatically

2. **Manual force update**

   ```
   //gs c watchdog clear    # Force cleanup
   //gs c update            # Or standard update
   ```

3. **Check for errors**

   ```
   //gs debugmode           # Enable debug
   ```

   Look for errors during spell cast.

4. **Verify equipment exists**

   ```
   //gs c checksets
   ```

   Check for [MISSING] or [STORAGE] items.

---

### Q: "How do I validate my equipment?"

**Command:**

```
//gs c checksets
```

**Output:**

```
[WAR] Validating equipment sets...
[WAR] ✓ 42/44 items validated (95.5%)

[STORAGE] sets.precast.WS['Upheaval'].neck: "Fotia Gorget"
[MISSING] sets.idle.PDT.body: "Sakpata's Plate"
```

**Legend:**

- **[OK]** - Item in inventory
- **[STORAGE]** - Item in Mog House/Storage
- **[MISSING]** - Item doesn't exist

**Fix:**

- [STORAGE]: Retrieve from storage
- [MISSING]: Acquire item or remove from sets

---

### Q: "Gear swaps too slowly / Equipment flashing"

**Solutions:**

1. **Normal behavior**
   - Precast (Fast Cast) >> Midcast (Potency) >> Aftercast (Idle/Engaged)
   - This is working as intended

2. **Too many gear swaps?**
   - Simplify equipment sets
   - Remove unnecessary conditional swaps

3. **Client lag**
   - Check FPS (should be 30+)
   - Close other programs
   - Reduce FFXI graphics settings

---

## Lockstyle

### Q: "Lockstyle not applying"

**Solutions:**

1. **Verify DressUp is loaded**

   ```
   //lua list              # Check if dressup is listed
   //lua load dressup      # Load if missing
   ```

2. **Wait for delay**
   - Default: 8 seconds after job load
   - Be patient - system applies automatically

3. **Manual apply**

   ```
   //gs c lockstyle
   ```

4. **Check lockstyle number**
   - Valid range: 1-200
   - Test in-game: `//dressup [number]`

5. **Verify config**

   ```lua
   -- In config/[job]/[JOB]_LOCKSTYLE.lua
   [JOB]LockstyleConfig.default = 1  -- Must be valid number
   ```

---

### Q: "Lockstyle changes on subjob change"

**This is intentional!**

Per-subjob lockstyle is configured in:

```
config/[job]/[JOB]_LOCKSTYLE.lua
```

**Example:**

```lua
WARLockstyleConfig.by_subjob = {
    ['SAM'] = 1,   -- WAR/SAM >> lockstyle 1
    ['NIN'] = 2,   -- WAR/NIN >> lockstyle 2
}
```

**To use same lockstyle for all subjobs:**

```lua
WARLockstyleConfig.default = 5

-- Optional: Set all subjobs to same number
WARLockstyleConfig.by_subjob = {
    ['SAM'] = 5,
    ['NIN'] = 5,
    ['DNC'] = 5,
}
```

---

### Q: "Lockstyle applies too slowly"

**Solutions:**

1. **Reduce delay**
   Edit `config/LOCKSTYLE_CONFIG.lua`:

   ```lua
   LockstyleConfig.initial_load_delay = 6.0  -- Reduce from 8.0
   ```

2. **Why delays exist:**
   - FFXI needs time to load character/gear
   - Too fast = lockstyle fails silently
   - 8.0s is safe for most systems

**Recommended values:**

- **8.0s** (default) - Safe for most systems
- **6.0s** - Fast systems/SSDs
- **10.0s** - Slow systems/HDDs

---

## Keybinds

### Q: "Keybinds not working"

**Solutions:**

1. **Check key format**

   ```lua
   -- Correct
   { key = "!1", ... }   -- Alt+1
   { key = "f9", ... }   -- F9

   -- ❌ Wrong
   { key = "alt+1", ... }
   { key = "Alt+1", ... }
   ```

2. **Reload system**

   ```
   //gs c reload
   ```

3. **Check for conflicts**
   - Key may be used by FFXI/Windower/other addons
   - Try different key (F9, F10, F11)

4. **Test command manually**

   ```
   //gs c cycle HybridMode
   ```

   If works: keybind issue
   If fails: state/command issue

---

### Q: "Want to use Ctrl instead of Alt"

**Solution:**

Replace `!` with `^` in keybind config:

```lua
-- BEFORE (Alt)
{ key = "!1", command = "cycle MainWeapon", ... }

-- AFTER (Ctrl)
{ key = "^1", command = "cycle MainWeapon", ... }
```

**Modifier symbols:**

- `!` = Alt
- `^` = Ctrl
- `@` = Windows
- `#` = Shift

---

### Q: "Keybind executes wrong command"

**Solutions:**

1. **Check command spelling**

   ```lua
   command = "cycle MainWeapon"    -- Correct
   command = "cycle mainweapon"    -- ❌ Wrong (case-sensitive)
   ```

2. **Verify state exists**
   State must be defined in main job file:

   ```lua
   state.MainWeapon = M{'Ukonvasara', 'Naegling', ...}
   ```

3. **Check available commands**
   - Universal: `reload`, `checksets`, `lockstyle`, `ui`
   - Job-specific: See `[JOB]_COMMANDS.lua`

---

## UI Issues

### Q: "UI not displaying"

**Solutions:**

1. **Toggle UI**

   ```
   //gs c ui               # Toggle on/off
   Alt+F1                 # Quick toggle
   ```

2. **Verify UI enabled**
   Check `config/UI_CONFIG.lua`:

   ```lua
   UIConfig.enabled = true
   ```

3. **Reload**

   ```
   //gs c reload
   ```

4. **Check position**
   - UI may be off-screen
   - Delete `ui_position.lua` to reset
   - Reload: `//gs c reload`

---

### Q: "Keybinds not showing in UI"

**Solutions:**

1. **Keybind must have valid `state` field**

   ```lua
   { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
   --                                                                    ↑ must exist
   ```

2. **State must exist in job file**

   ```lua
   state.MainWeapon = M{...}  -- Must be defined
   ```

3. **Refresh UI**

   ```
   //gs c ui     # Toggle off
   //gs c ui     # Toggle on
   ```

---

### Q: "UI position resets every login"

**Solutions:**

1. **Save position manually**

   ```
   //gs c ui save
   ```

   Creates/updates `ui_position.lua`

2. **Verify file exists**
   Path: `addons/GearSwap/data/[YourName]/ui_position.lua`

3. **Enable auto-save** (optional)
   Edit `config/UI_CONFIG.lua`:

   ```lua
   UIConfig.auto_save_position = true
   ```

---

## Watchdog

### Q: "What is the Watchdog?"

**Answer:**

Automatic protection against "stuck midcast" caused by network packet loss.

**How it works:**

- Monitors midcast every 0.5 seconds
- If midcast stuck > 3.5 seconds >> auto-cleanup
- Forces return to idle/engaged gear
- No manual intervention needed

**See:** [Watchdog Guide](../features/watchdog.md)

---

### Q: "How to test Watchdog?"

**Command:**

```
//gs c watchdog test
```

**Expected:**

```
[Watchdog TEST] Simulating stuck midcast: Test Spell
... (wait 3.5s) ...
[Watchdog] Midcast stuck detected - recovering from: Test Spell (stuck for 3.5s)
```

---

### Q: "Watchdog cleaning up too early"

**Symptoms:**

- Cleanup during legitimate long spells

**Solutions:**

1. **Increase timeout**

   ```
   //gs c watchdog timeout 4.5
   ```

2. **Check recommended values:**
   - 3.5s (default) - Balanced
   - 3.0s - Aggressive (extreme lag)
   - 4.0s - Conservative (fewer false positives)

---

### Q: "Disable Watchdog?"

**Command:**

```
//gs c watchdog off     # Disable
//gs c watchdog on      # Re-enable
```

**Not recommended** - Watchdog protects against stuck midcast in laggy zones.

---

## Performance

### Q: "System causing lag?"

**Answer:**

System impact is negligible:

- **CPU**: ~1ms per 0.5s (Watchdog)
- **Memory**: <5KB
- **Network**: None

**If experiencing lag:**

1. Not caused by GearSwap
2. Check FFXI FPS (should be 30+)
3. Check network connection
4. Close other programs

---

### Q: "Too many messages in chat?"

**Solutions:**

1. **Disable debug mode**

   ```
   //gs debugmode          # Toggle off
   //gs c watchdog debug   # Disable watchdog debug
   ```

2. **Reduce message verbosity**
   - System messages are minimal by default
   - Debug mode is very verbose (only enable when testing)

---

## DualBox

### Q: "How to setup DualBox?"

**See:** [DualBox Guide](dualbox.md)

**Quick setup:**

1. Edit `config/DUALBOX_CONFIG.lua` on both characters
2. Set main/alt character names
3. Enable: `DualBoxConfig.enabled = true`
4. Reload both: `//gs c reload`
5. Test: `//gs c altjob` (on main character)

---

## Job-Specific Questions

### Q: "DNC - Waltz not selecting correct tier?"

**Solutions:**

1. **Check target HP**
   - System selects tier based on missing HP
   - Waltz tiers: I (<200), II (200-600), III (600-1100), IV (1100-1500), V (1500+)

2. **Manual tier**
   Use macro:

   ```
   /ja "Curing Waltz III" <stpc>
   ```

---

### Q: "BST - Ready Move system?"

**Commands:**

```
//gs c rdylist            # List available moves
//gs c rdymove [1-6]      # Execute move by index
```

**Auto-sequence:**

- Pet engaged: Uses move immediately
- Pet idle + player engaged: Fight >> Move (stays engaged)
- Pet idle + player idle: Fight >> Move >> Heel

---

### Q: "RDM - Enhancement spell cycles?"

**Commands:**

```
//gs c cycle GainSpell    # F1 - Gain spells (7 stats)
//gs c cycle Barspell     # F2 - Bar elements (6)
//gs c cycle BarAilment   # F3 - Bar ailments (8)
//gs c cycle Spike        # F4 - Spike spells (3)
//gs c cycle Storm        # F5 - Storm spells (8, RDM/SCH only)
```

**UI displays current selection** - press F1-F5 to cycle, then cast manually.

---

## Still Need Help?

### Troubleshooting Steps

1. **Check error messages**

   ```
   //gs debugmode
   ```

2. **Validate equipment**

   ```
   //gs c checksets
   ```

3. **Reload system**

   ```
   //gs c reload
   ```

4. **Test Watchdog**

   ```
   //gs c watchdog test
   ```

5. **Check Windower console**

   ```
   //console show
   ```

---

## Quick Command Reference

| Issue | Command |
|-------|---------|
| System not loading | `//lua load gearswap` |
| Reload system | `//gs c reload` |
| Validate equipment | `//gs c checksets` |
| Apply lockstyle | `//gs c lockstyle` |
| Toggle UI | `//gs c ui` |
| Test Watchdog | `//gs c watchdog test` |
| Enable debug | `//gs debugmode` |

---

## Next Steps

- **[Installation Guide](../getting-started/installation.md)** - Complete setup
- **[Quick Start](../getting-started/quick-start.md)** - 5-minute guide
- **[Commands Reference](commands.md)** - All commands
- **[Keybinds Guide](keybinds.md)** - Customize shortcuts
- **[Configuration Guide](configuration.md)** - Advanced settings

---


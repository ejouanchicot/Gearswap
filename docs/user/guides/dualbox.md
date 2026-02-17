# DualBox Guide - Multi-Character Setup

Complete guide for setting up dual-box communication between two characters.


---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start-5-minutes)
- [Detailed Setup](#detailed-setup)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)

---

## Overview

### What is DualBox?

The DualBox system allows automatic communication between two characters:

- **MAIN character** receives alt's job information
- **ALT character** sends job updates automatically
- **Communication**: Unidirectional (ALT >> MAIN only)

### Benefits

- **Auto-detect alt's job** - MAIN knows what job ALT is playing
- **Auto-load optimal macros** - MAIN switches macros based on ALT's job
- **UI display** - See alt's job in MAIN's UI (optional)
- **Zero manual updates** - Everything happens automatically

### System Requirements

- Both characters logged in simultaneously
- Windower 4.2+ on both clients
- GearSwap addon loaded on both characters

### How It Works

```
1. ALT character loads job (e.g., WHM/SCH)
   ↓
2. ALT sends job update via sendCommand
   ↓
3. MAIN receives update via command handler
   ↓
4. MAIN displays alt job in UI (optional)
   ↓
5. Updates automatically on job/subjob change
```

---

## Quick Start (5 Minutes)

### 1. Clone Alt Character (30 seconds)

**Option A: Using Clone Script**

```cmd
cd "D:\Windower Tetsouo\addons\GearSwap\data"
python clone_character.py
```

Enter alt character name when prompted: `Kaories` (or your alt name)

**Option B: Manual Copy**

```cmd
# Copy entire character folder
cp -r Tetsouo/ Kaories/

# Rename all job files
cd Kaories/
ren Tetsouo_*.lua Kaories_*.lua
```

### 2. Configure DualBox (2 minutes)

**On MAIN character** (Tetsouo):

Edit `Tetsouo/config/DUALBOX_CONFIG.lua`:

```lua
local DualBoxConfig = {}

DualBoxConfig.enabled = true
DualBoxConfig.main_character = "Tetsouo"
DualBoxConfig.alt_character = "Kaories"
DualBoxConfig.auto_request = true
DualBoxConfig.show_in_ui = true

return DualBoxConfig
```

**On ALT character** (Kaories):

Edit `Kaories/config/DUALBOX_CONFIG.lua`:

```lua
local DualBoxConfig = {}

DualBoxConfig.enabled = true
DualBoxConfig.main_character = "Tetsouo"
DualBoxConfig.alt_character = "Kaories"
DualBoxConfig.auto_request = false  -- ALT doesn't request
DualBoxConfig.show_in_ui = false     -- ALT doesn't display

return DualBoxConfig
```

### 3. Reload Both Characters (30 seconds)

**In-game (on both characters):**

```
# Main character (Tetsouo)
//gs c reload

# Alt character (Kaories)
//gs c reload
```

### 4. Test Communication (1 minute)

**On MAIN character:**

```
//gs c altjob
```

**Expected result:**

```
[DualBox] Requesting alt job info...
... (2-3 seconds) ...
[DualBox] Alt job received: WHM/SCH
```

**UI should display:**

```
Alt Job: WHM/SCH
```

**Done!** Your dual-box system is ready.

---

## Detailed Setup

### Step 1: Clone Alt Character

#### Why Clone?

Cloning creates a complete copy of your main character's setup with all job files, configs, and keybinds already configured.

#### Cloning Process

**A. Using Clone Script** (Recommended)

```cmd
cd "D:\Windower Tetsouo\addons\GearSwap\data"
python clone_character.py
```

**Input:**

```
Enter source character name: Tetsouo
Enter new character name: Kaories
```

**What Gets Cloned:**

- Copies entire character folder
- Renames all job files (`Tetsouo_*.lua` >> `Kaories_*.lua`)
- Updates all config paths in code
- Creates 13 complete job files (WAR, PLD, DNC, DRK, SAM, THF, RDM, WHM, BLM, GEO, COR, BRD, BST)

**B. Manual Cloning** (Alternative)

1. Copy folder:

   ```cmd
   xcopy /E /I Tetsouo\ Kaories\
   ```

2. Rename job files:

   ```cmd
   cd Kaories\
   ren Tetsouo_WAR.lua Kaories_WAR.lua
   ren Tetsouo_PLD.lua Kaories_PLD.lua
   ren Tetsouo_DNC.lua Kaories_DNC.lua
   # ... (repeat for all 15 jobs)
   ```

3. Update config paths in each file:
   - Find: `'Tetsouo/config/'`
   - Replace: `'Kaories/config/'`

#### Verify Clone Success

Check that folder exists:

```
addons/GearSwap/data/Kaories/
├── Kaories_WAR.lua
├── Kaories_PLD.lua
├── Kaories_DNC.lua
├── ... (other jobs)
└── config/
```

---

### Step 2: Configure DualBox

#### A. Main Character Config

**File:** `Tetsouo/config/DUALBOX_CONFIG.lua`

```lua
local DualBoxConfig = {}

-- Enable/disable DualBox system
DualBoxConfig.enabled = true

-- Main character name (the one who requests info)
DualBoxConfig.main_character = "Tetsouo"

-- Alt character name (the one who sends info)
DualBoxConfig.alt_character = "Kaories"

-- Auto-request alt job on load
DualBoxConfig.auto_request = true

-- Display alt job in UI
DualBoxConfig.show_in_ui = true

return DualBoxConfig
```

#### B. Alt Character Config

**File:** `Kaories/config/DUALBOX_CONFIG.lua`

```lua
local DualBoxConfig = {}

-- Enable/disable DualBox system
DualBoxConfig.enabled = true

-- Main character name
DualBoxConfig.main_character = "Tetsouo"

-- Alt character name (this character)
DualBoxConfig.alt_character = "Kaories"

-- ALT doesn't request info (only responds)
DualBoxConfig.auto_request = false

-- ALT doesn't need UI display
DualBoxConfig.show_in_ui = false

return DualBoxConfig
```

**Key differences:**

- **MAIN**: `auto_request = true`, `show_in_ui = true`
- **ALT**: `auto_request = false`, `show_in_ui = false`

---

### Step 3: Test Communication

#### Test 1: Manual Request

**On MAIN:**

```
//gs c altjob
```

**Expected output (MAIN):**

```
[DualBox] Requesting alt job info...
[DualBox] Alt job received: WHM/SCH
```

**Expected output (ALT):**

```
[DualBox] Sending job info to MAIN: WHM/SCH
```

#### Test 2: Automatic Updates

**On ALT:**

```
# Change job
/ja "Black Mage" <me>
```

**Expected (MAIN):**

```
[DualBox] Alt job updated: BLM/SCH
```

**UI updates automatically** to show new job.

#### Test 3: UI Display

**On MAIN:**

Check UI displays:

```
╔════════════════════════╗
║  Alt Job: WHM/SCH      ║
╚════════════════════════╝
```

---

## Usage

### Daily Workflow

1. **Log in both characters**
2. **Load GearSwap on both**

   ```
   //lua load gearswap
   ```

3. **System auto-connects** (if `auto_request = true`)

**That's it!** No manual commands needed.

### Manual Commands

| Command | Where | Description |
|---------|-------|-------------|
| `//gs c altjob` | MAIN | Request alt's current job |
| `//gs c requestjob` | ALT | Respond to MAIN's request |
| `//gs c altjobupdate [job] [subjob]` | MAIN | Receive alt job update (auto-triggered) |

**Typical usage:**

- No manual commands needed - system works automatically
- Use `//gs c altjob` only if connection fails

---

## Troubleshooting

### Issue: "Alt job not updating"

**Solutions:**

1. **Verify both characters have DualBox enabled**

   ```lua
   -- In DUALBOX_CONFIG.lua (both characters)
   DualBoxConfig.enabled = true
   ```

2. **Check character names match exactly**

   ```lua
   -- Must match FFXI character names (case-sensitive)
   DualBoxConfig.main_character = "Tetsouo"  -- Exact match
   DualBoxConfig.alt_character = "Kaories"   -- Exact match
   ```

3. **Reload both characters**

   ```
   //gs c reload   # On both MAIN and ALT
   ```

4. **Manual test**

   ```
   # On MAIN
   //gs c altjob

   # On ALT
   //gs c requestjob
   ```

---

### Issue: "UI not showing alt job"

**Solutions:**

1. **Verify UI display enabled (MAIN only)**

   ```lua
   DualBoxConfig.show_in_ui = true
   ```

2. **Refresh UI**

   ```
   //gs c ui       # Toggle off
   //gs c ui       # Toggle on
   ```

3. **Reload**

   ```
   //gs c reload
   ```

---

### Issue: "Commands not working"

**Solutions:**

1. **Check GearSwap loaded on both**

   ```
   //lua list     # Verify gearswap in list
   ```

2. **Check DualBox system loaded**

   ```
   # Should see message on load:
   [DualBox] System initialized
   ```

3. **Enable debug (MAIN)**

   ```
   //gs debugmode
   ```

   Look for errors when using `//gs c altjob`

---

### Issue: "Updates delayed"

**Normal behavior:**

- Network delay: 1-3 seconds typical
- System polls every 0.5s

**If delay > 5 seconds:**

1. **Check network latency**
2. **Reduce polling if needed** (advanced - edit DualBoxManager)
3. **Manual force update**

   ```
   //gs c altjob
   ```

---

## Advanced Configuration

### Disable DualBox System

**Temporarily:**

```
# In DUALBOX_CONFIG.lua
DualBoxConfig.enabled = false
```

**Then reload:**

```
//gs c reload
```

### Multiple Alt Characters

Currently supports **1 MAIN + 1 ALT**.

**For 3+ characters:**

- Requires custom modification (not supported out-of-box)
- Each ALT needs separate config
- MAIN can only track 1 ALT at a time

### Custom UI Position for Alt Job Display

**On MAIN:**

1. Load UI
2. Drag to desired position
3. Save:

   ```
   //gs c ui save
   ```

Alt job display position saves with UI.

---

## How It Works (Technical)

### Communication Flow

```lua
-- 1. MAIN requests (via send_command)
send_command('@input //send Kaories //gs c requestjob')

-- 2. ALT receives command (job_self_command hook)
if command == 'requestjob' then
    DualBoxManager.handle_job_request()
end

-- 3. ALT sends response
send_command('@input //send Tetsouo //gs c altjobupdate WHM SCH')

-- 4. MAIN receives update
if command == 'altjobupdate' then
    DualBoxManager.receive_alt_job(job, subjob)
end

-- 5. MAIN updates UI
UI_MANAGER.refresh_alt_job_display()
```

### Auto-Update on Job Change

```lua
-- In job_sub_job_change (ALT)
function job_sub_job_change(newSubjob, oldSubjob)
    -- Auto-send update to MAIN
    DualBoxManager.send_job_update()
end
```

---

## Best Practices

### Character Organization

**Recommended setup:**

- **MAIN**: Full gear, all jobs configured
- **ALT**: Support jobs (WHM, BRD, GEO, COR, RDM)

### Testing After Changes

After editing DualBox config:

1. Reload both: `//gs c reload`
2. Test manual: `//gs c altjob`
3. Test auto: Change ALT job

### Backup Configs

```cmd
# Backup both character configs
xcopy /E /I Tetsouo\config Tetsouo\config_backup
xcopy /E /I Kaories\config Kaories\config_backup
```

---

## Quick Reference

| Setting | MAIN | ALT |
|---------|------|-----|
| `enabled` | `true` | `true` |
| `main_character` | `"Tetsouo"` | `"Tetsouo"` |
| `alt_character` | `"Kaories"` | `"Kaories"` |
| `auto_request` | `true` | `false` |
| `show_in_ui` | `true` | `false` |

---

## Next Steps

- **[Configuration Guide](configuration.md)** - Advanced config options
- **[Commands Reference](commands.md)** - All available commands
- **[UI Guide](../features/ui.md)** - Customize UI appearance
- **[FAQ](faq.md)** - Common issues

---

**Supported**: 1 MAIN + 1 ALT character setup

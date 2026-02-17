# DualBox Guide

Setup guide for dual-box communication between two characters.

---

## Overview

The DualBox system provides automatic one-way communication from an ALT character to a MAIN character:

- MAIN receives the ALT's current job and subjob.
- ALT sends job updates automatically on every job/subjob change.
- MAIN can display the ALT's job in the UI overlay.

**Requirements**: Both characters logged in with Windower 4.2+ and GearSwap loaded.

---

## Setup

### 1. Create the Alt Character Folder

**Using the clone script** (recommended):

```cmd
cd "D:\Windower Tetsouo\addons\GearSwap\data"
python clone_character.py
```

Enter the source name (e.g., `Tetsouo`) and the new name (e.g., `Kaories`). The script copies all job files, renames them, and updates config paths.

Manual alternative: copy the character folder, rename all `Source_*.lua` files to `Alt_*.lua`, and find-replace config path references.

### 2. Configure MAIN Character

Edit `Tetsouo/config/DUALBOX_CONFIG.lua`:

```lua
local DualBoxConfig = {}

DualBoxConfig.role = "main"
DualBoxConfig.character_name = "Tetsouo"
DualBoxConfig.alt_character = "Kaories"

DualBoxConfig.enabled = true
DualBoxConfig.timeout = 30
DualBoxConfig.debug = false

return DualBoxConfig
```

### 3. Configure ALT Character

Edit `Kaories/config/DUALBOX_CONFIG.lua`:

```lua
local DualBoxConfig = {}

DualBoxConfig.role = "alt"
DualBoxConfig.character_name = "Kaories"
DualBoxConfig.main_character = "Tetsouo"

DualBoxConfig.enabled = true
DualBoxConfig.timeout = 30
DualBoxConfig.debug = false

return DualBoxConfig
```

**Key difference**: MAIN sets `role = "main"` and `alt_character`. ALT sets `role = "alt"` and `main_character`.

### 4. Reload and Test

Reload GearSwap on both characters:

```
//gs c reload
```

On the MAIN character, request the ALT's job:

```
//gs c altjob
```

Expected output:

```
[DualBox] Requesting alt job info...
[DualBox] Alt job received: WHM/SCH
```

---

## Daily Usage

1. Log in both characters and load GearSwap.
2. The system auto-connects. No manual commands needed.
3. When the ALT changes jobs, MAIN is updated automatically.

---

## Commands

| Command | Run On | Description |
|---------|--------|-------------|
| `//gs c altjob` | MAIN | Request ALT's current job |
| `//gs c requestjob` | ALT | Respond to MAIN's request (auto-triggered) |
| `//gs c altjobupdate [job] [subjob]` | MAIN | Receive job update (auto-triggered) |

In normal use, no manual commands are needed. Use `//gs c altjob` only if the connection seems stale.

---

## Configuration Reference

| Setting | MAIN | ALT |
|---------|------|-----|
| `role` | `"main"` | `"alt"` |
| `character_name` | Your main name | Your alt name |
| `alt_character` | Alt name | (not used) |
| `main_character` | (not used) | Main name |
| `enabled` | `true` | `true` |
| `timeout` | `30` | `30` |
| `debug` | `false` | `false` |

### Disabling DualBox

Set `DualBoxConfig.enabled = false` in the config file and reload (`//gs c reload`).

### Multiple Alts

The system supports 1 MAIN + 1 ALT. Multiple alts require custom modification.

### UI Position

The ALT job display is part of the main UI. Drag to position, then save with `//gs c ui save`.

---

## Troubleshooting

### ALT job not updating

1. Verify `DualBoxConfig.enabled = true` on both characters.
2. Check that character names match exactly (case-sensitive).
3. Reload both characters: `//gs c reload`.
4. Test manually: `//gs c altjob` on MAIN.

### UI not showing ALT job

1. Confirm MAIN config has `role = "main"` and `enabled = true`.
2. Toggle the UI: `//gs c ui` twice.
3. Reload: `//gs c reload`.

### Commands not working

1. Verify GearSwap is loaded on both characters (`//lua list`).
2. You should see `[DualBox] System initialized` on load.
3. Enable debug mode (`//gs debugmode`) and retry `//gs c altjob` to see error details.

### Updates delayed (more than 5 seconds)

Network delay of 1-3 seconds is normal. If consistently slow, force a manual update with `//gs c altjob`.

---

## Further Reading

- [Configuration Guide](configuration.md) - Advanced config options
- [Commands Reference](commands.md) - All available commands
- [UI Guide](../features/ui.md) - Customize UI appearance
- [FAQ](faq.md) - Common issues

---

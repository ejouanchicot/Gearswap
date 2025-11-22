# Midcast Watchdog

Automatic protection system against stuck midcast caused by network packet loss.

## Overview

The **Midcast Watchdog** is a background monitoring system that detects and automatically recovers from "stuck midcast" conditions that occur in laggy zones (Odyssey, Dynamis-Divergence, etc.).

### The Problem

In zones with network lag, FFXI can lose server packets that indicate an action has completed. This causes:

- ❌ GearSwap remains stuck in midcast gear (Cure gear, Nuke gear, WS gear)
- ❌ You must manually type `//gs c update` to unlock
- ❌ Loss of time in critical combat situations
- ❌ Potential death due to wrong defensive gear

### The Solution

The Watchdog automatically:

- ✅ Detects midcast stuck for > 3.5 seconds
- ✅ Forces automatic return to idle/engaged gear
- ✅ No manual intervention required
- ✅ Completely silent operation (no spam in console)

---

## How It Works

### Normal Spell Flow

```
1. Cast Cure IV
2. PRECAST >> Fast Cast gear
3. MIDCAST >> Cure Potency gear
4. Spell completes
5. Server sends confirmation packet ✅
6. AFTERCAST >> Return to Idle/Engaged gear
```

### Packet Loss Scenario (With Watchdog)

```
1. Cast Cure IV
2. PRECAST >> Fast Cast gear
3. MIDCAST >> Cure Potency gear
4. Spell completes
5. Server packet LOST ❌
6. GearSwap stuck in Cure gear
   ↓
7. Watchdog detects: stuck > 3.5s
   ↓
8. Watchdog forces cleanup ✅
   ↓
9. Return to Idle/Engaged gear ✅
```

### Detection Mechanism

The watchdog monitors every 0.5 seconds:

1. Tracks midcast start via `job_post_midcast()` hook
2. Tracks aftercast via `job_aftercast()` hook
3. Checks if midcast is active
4. Calculates age of current midcast
5. If age > 3.5s >> Forces cleanup + gear refresh
6. Normal aftercast automatically clears tracking

---

## Basic Usage

### Show Status

```
//gs c watchdog
```

**Output:**

```
=== Midcast Watchdog Status ===
  Enabled: true
  Debug: false
  Timeout: 3.5s
  Active: false
```

### Enable/Disable

```
//gs c watchdog on       # Enable
//gs c watchdog off      # Disable
//gs c watchdog toggle   # Toggle on/off
```

**Default:** Enabled automatically on job load

### Change Timeout

```
//gs c watchdog timeout 4    # Set to 4 seconds
//gs c watchdog timeout 3    # Set to 3 seconds (more aggressive)
```

**Recommended values:**

- **3.5s** (default) - Balanced, good for most situations
- **3.0s** - Aggressive, for extreme lag zones
- **4.0s** - Conservative, if you get false positives

---

## Debug Mode

### Enable Debug Logging

```
//gs c watchdog debug
```

Shows detailed scan information every 0.5 seconds:

**When idle:**

```
[Watchdog DEBUG] Scan: No active midcast
```

**When casting:**

```
[Watchdog DEBUG] Scan: Active midcast "Cure IV" (age: 0.52s, timeout: 3.5s)
[Watchdog DEBUG] Scan: Active midcast "Cure IV" (age: 1.02s, timeout: 3.5s)
[Watchdog DEBUG] Scan: Active midcast "Cure IV" (age: 1.52s, timeout: 3.5s)
```

**When stuck detected:**

```
[Watchdog DEBUG] Scan: Active midcast "Cure IV" (age: 3.65s, timeout: 3.5s)
[Watchdog] Midcast stuck detected - recovering from: Cure IV (stuck for 3.7s)
```

### Disable Debug Mode

```
//gs c watchdog debug    # Toggle off
```

**⚠️ Warning:** Debug mode is very verbose. Use only for testing, then disable.

---

## Test Mode

### Simulate Stuck Midcast

Test the watchdog without needing real lag:

```
//gs c watchdog test
```

**What happens:**

1. Simulates stuck midcast with fake spell
2. Blocks aftercast (like packet loss)
3. Watchdog detects and cleans up after 3.5s
4. Test mode auto-deactivates after cleanup

**Output:**

```
[Watchdog TEST] Simulating stuck midcast: Test Spell
[Watchdog TEST] Aftercast will be BLOCKED - watchdog should cleanup after 3.5s
... (3.5 seconds later) ...
[Watchdog] Midcast stuck detected - recovering from: Test Spell (stuck for 3.5s)
[Watchdog TEST] Test mode deactivated after cleanup
```

### Test with Specific Spell

```
//gs c watchdog test "Cure IV"
```

**Use case:** Verify watchdog functionality without going to laggy zones.

---

## Advanced Features

### Manual Cleanup

Force immediate cleanup of any stuck midcast:

```
//gs c watchdog clear
```

**When to use:**

- You're stuck and want immediate recovery
- Testing after configuration changes

### Show Statistics

Display detailed watchdog statistics:

```
//gs c watchdog stats
```

**Output:**

```
=== Midcast Watchdog Stats ===
  Enabled: true
  Debug: false
  Timeout: 3.5s
  Active Midcast: false
  Spell: None
  Age: 0.00s
```

**When casting:**

```
=== Midcast Watchdog Stats ===
  Enabled: true
  Debug: false
  Timeout: 3.5s
  Active Midcast: true
  Spell: Cure IV
  Age: 1.23s
```

---

## Configuration

### Default Configuration

Located in: `shared/utils/core/midcast_watchdog.lua`

```lua
-- Timeout threshold (in seconds) before forcing cleanup
local WATCHDOG_TIMEOUT = 3.5

-- Enable/disable watchdog (can be toggled via command)
local watchdog_enabled = true

-- Debug mode (shows detailed info)
local debug_enabled = false
```

### Change Default Timeout

Edit `midcast_watchdog.lua:20`:

```lua
local WATCHDOG_TIMEOUT = 3.0  -- More aggressive
```

**Note:** Changing default requires `//gs c reload` to apply.

---

## Troubleshooting

### Watchdog Not Loading

**Symptoms:**

- No "Watchdog Initialized" message on job load
- `//gs c watchdog` command not found

**Solution:**

1. Verify `INIT_SYSTEMS.lua` is included in your job file (watchdog is part of universal systems)
2. Check for Lua errors: `//gs debugmode`
3. Reload GearSwap: `//gs c reload`

### Too Many False Positives

**Symptoms:**

- Watchdog cleanup during legitimate long spells
- Cleanup happens too early

**Solution:**

1. Increase timeout: `//gs c watchdog timeout 4`
2. Check client lag (FPS issues, freezing)
3. Temporarily disable: `//gs c watchdog off`

### Watchdog Not Detecting Stuck

**Symptoms:**

- You remain stuck in midcast gear
- No cleanup after 3.5s

**Solution:**

1. Verify watchdog is enabled: `//gs c watchdog`
2. Check timeout setting (may be too long)
3. Force manual cleanup: `//gs c watchdog clear`
4. Enable debug mode to see scans: `//gs c watchdog debug`

---

## Performance

### Impact

- **CPU:** Negligible (~1ms per 0.5s scan)
- **Memory:** ~1KB
- **Network:** None

### Compatibility

- ✅ All jobs
- ✅ All subjobs
- ✅ All zones
- ✅ Compatible with all Windower addons

---

## FAQ

### Q: Do I need to enable watchdog manually?

**A:** No, it's enabled automatically when you load a job.

### Q: Will it cause lag or performance issues?

**A:** No, the watchdog uses minimal resources (scans every 0.5s, ~1ms per scan).

### Q: Can it break my gear swaps?

**A:** No, watchdog only cleans up stuck midcast and forces `//gs c update`. It's 100% safe.

### Q: What's the difference between watchdog and aftercast delay fix?

**A:** Two different fixes for two different problems:

| Fix | Problem | When |
|-----|---------|------|
| **Aftercast delay** | Gear doesn't equip after aftercast | Lag post-action |
| **Watchdog** | Aftercast never called | Packet lost |

**Both work together** - they're complementary systems.

### Q: Can I disable it if it bothers me?

**A:** Yes: `//gs c watchdog off`

### Q: How do I test if it's working?

**A:** Use test mode: `//gs c watchdog test`

---

## Command Reference

| Command | Description |
|---------|-------------|
| `//gs c watchdog` | Show status |
| `//gs c watchdog on` | Enable watchdog |
| `//gs c watchdog off` | Disable watchdog |
| `//gs c watchdog toggle` | Toggle on/off |
| `//gs c watchdog debug` | Toggle debug mode |
| `//gs c watchdog test` | Test detection |
| `//gs c watchdog stats` | Show statistics |
| `//gs c watchdog timeout [seconds]` | Set timeout |
| `//gs c watchdog clear` | Force cleanup |

---

## Version History

**Version 2.0** (2025-10-26):

- ✅ Migrated to hook-based approach (no more command_registry)
- ✅ Self-rescheduling coroutine (no spam in debugmode)
- ✅ Test mode: `//gs c watchdog test` for easy verification
- ✅ Added to all 13 jobs

**Version 1.0** (2025-10-25):

- ✅ Initial release
- ✅ Timeout 3.5s default
- ✅ Scan every 0.5s
- ✅ In-game commands
- ✅ Auto-start on job load

---

## Technical Details

For developers and advanced users:

### Hook-Based Architecture

The watchdog uses GearSwap event hooks instead of registry scanning:

```lua
function job_post_midcast(spell, action, spellMap, eventArgs)
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end
end
```

### Self-Rescheduling Coroutine

Uses Windower coroutine system (not prerender event) to avoid debugmode spam:

```lua
local function watchdog_check_and_reschedule()
    if not watchdog_timer then return end

    background_check()

    -- Reschedule next check
    coroutine.schedule(watchdog_check_and_reschedule, 0.5)
end

-- Start the loop
watchdog_timer = true
coroutine.schedule(watchdog_check_and_reschedule, 0.5)
```

### Test Mode Implementation

Test mode blocks aftercast by setting a flag:

```lua
-- In on_aftercast():
if test_mode_active then
    return  -- Block cleanup, simulating packet loss
end
```

Cleanup detection automatically disables test mode.

---

**Version**: 2.0
**Last Updated**: 2025-10-26
**Author**: Tetsouo

See also: [Test Guide](../../WATCHDOG_TEST_GUIDE.md) for complete testing procedures.

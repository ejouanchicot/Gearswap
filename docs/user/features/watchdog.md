# Midcast Watchdog

Automatic protection system against stuck midcast caused by network packet loss.

## Overview

The **Midcast Watchdog** is a background monitoring system that detects and automatically recovers from "stuck midcast" conditions that occur in laggy zones (Odyssey, Dynamis-Divergence, etc.).

### The Problem

In zones with network lag, FFXI can lose server packets that indicate an action has completed. This causes:

- GearSwap remains stuck in midcast gear (Cure gear, Nuke gear, WS gear)
- You must manually type `//gs c update` to unlock
- Loss of time in critical combat situations
- Potential death due to wrong defensive gear

### The Solution

The Watchdog automatically:

- Calculates a **dynamic timeout per spell** based on cast time, Fast Cast reduction, and a 1.5s safety buffer
- Falls back to 5.0s timeout for unknown spells
- Forces automatic return to idle/engaged gear when timeout expires
- No manual intervention required
- Completely silent operation (no spam in console)

---

## How It Works

### Normal Spell Flow

```
1. Cast Cure IV
2. PRECAST >> Fast Cast gear
3. MIDCAST >> Cure Potency gear
4. Spell completes
5. Server sends confirmation packet 
6. AFTERCAST >> Return to Idle/Engaged gear
```

### Packet Loss Scenario (With Watchdog)

```
1. Cast Cure IV (base cast time from res/spells.lua)
2. PRECAST >> Fast Cast gear
3. MIDCAST >> Cure Potency gear
4. Watchdog calculates timeout: (cast_time * (1 - FC%/100)) + 1.5s buffer
5. Spell completes
6. Server packet LOST
7. GearSwap stuck in Cure gear
   |
8. Watchdog detects: age > dynamic timeout
   |
9. Watchdog forces cleanup
   |
10. Return to Idle/Engaged gear
```

### Detection Mechanism

The watchdog monitors every 0.5 seconds:

1. Tracks midcast start via `job_post_midcast()` hook
2. On midcast start, calculates a **per-spell dynamic timeout**:
   - Looks up base cast time from `res/spells.lua` (or `cast_delay` from `res/items.lua` for items)
   - Applies Fast Cast reduction: `adjusted = base * (1 - FC%/100)` (capped at 80% FC)
   - Adds 1.5s safety buffer: `timeout = adjusted + 1.5`
   - For items: no Fast Cast reduction applied
   - For unknown spells: uses 5.0s fallback timeout
3. Tracks aftercast via `job_aftercast()` hook
4. Checks if midcast is active
5. Calculates age of current midcast
6. If age > dynamic timeout >> Forces cleanup + gear refresh
7. Normal aftercast automatically clears tracking

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
  Buffer: 1.5s
  Fallback Timeout: 5.0s
  Active: false
```

### Enable/Disable

```
//gs c watchdog on       # Enable
//gs c watchdog off      # Disable
//gs c watchdog toggle   # Toggle on/off
```

**Default:** Enabled automatically on job load

### Change Buffer

The buffer is added to the adjusted cast time to create the per-spell timeout:

```
//gs c watchdog buffer 2.0   # Set buffer to 2.0 seconds
//gs c watchdog buffer 1.0   # Set buffer to 1.0 seconds (more aggressive)
```

**Default buffer:** 1.5s (valid range: 0-10s)

### Change Fallback Timeout

The fallback timeout is used for unknown spells where cast time cannot be determined:

```
//gs c watchdog fallback 6   # Set fallback to 6 seconds
//gs c watchdog fallback 4   # Set fallback to 4 seconds
```

**Default fallback:** 5.0s (valid range: 0-30s)

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

**When casting (example: Cure IV with 40% FC, base cast 2.0s):**

```
[Watchdog DEBUG] Midcast: Cure IV (base: 2.0s, FC: 40%, adj: 1.2s, timeout: 2.7s)
[Watchdog DEBUG] Scan: Active midcast "Cure IV" (age: 0.52s, timeout: 2.7s)
[Watchdog DEBUG] Scan: Active midcast "Cure IV" (age: 1.02s, timeout: 2.7s)
```

**When stuck detected:**

```
[Watchdog DEBUG] Scan: Active midcast "Cure IV" (age: 2.85s, timeout: 2.7s)
[Watchdog] Midcast stuck detected - recovering from: Cure IV (stuck for 2.9s)
```

### Disable Debug Mode

```
//gs c watchdog debug    # Toggle off
```

** Warning:** Debug mode is very verbose. Use only for testing, then disable.

---

## Test Mode

### Simulate Stuck Midcast

Test the watchdog without needing real lag:

```
//gs c watchdog test
```

**What happens:**

1. Simulates stuck midcast with fake spell
2. Calculates timeout for the test spell (from res/spells.lua if spell ID given, or fallback 5.0s)
3. Blocks aftercast (like packet loss)
4. Watchdog detects and cleans up after the dynamic timeout expires
5. Test mode auto-deactivates after cleanup

**Output:**

```
[Watchdog TEST] Simulating stuck midcast: Test Spell
[Watchdog TEST] Using fallback timeout: 5.0s
[Watchdog TEST] Aftercast will be BLOCKED
... (timeout expires) ...
[Watchdog] Midcast stuck detected - recovering from: Test Spell
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
  Buffer: 1.5s
  Fallback Timeout: 5.0s
  Active Midcast: false
  Spell: None
  Age: 0.00s
```

**When casting (example: Cure IV with 40% FC):**

```
=== Midcast Watchdog Stats ===
  Enabled: true
  Debug: false
  Buffer: 1.5s
  Fallback Timeout: 5.0s
  Active Midcast: true
  Spell: Cure IV
  Base Cast Time: 2.00s
  Fast Cast: 40%
  Adjusted Cast Time: 1.20s
  Timeout: 2.70s
  Age: 1.23s
```

---

## Configuration

### Default Configuration

Located in: `shared/utils/core/midcast_watchdog.lua`

```lua
-- Safety buffer added to cast time (in seconds)
-- Timeout = adjusted_cast_time + WATCHDOG_BUFFER
local WATCHDOG_BUFFER = 1.5

-- Fallback timeout for unknown spells (in seconds)
local WATCHDOG_FALLBACK_TIMEOUT = 5.0

-- Fast Cast cap (80% maximum reduction per FFXI mechanics)
local FAST_CAST_CAP = 80

-- Enable/disable watchdog (can be toggled via command)
local watchdog_enabled = true

-- Debug mode (shows detailed info)
local debug_enabled = false
```

### How Timeout is Calculated

The timeout is **dynamic per spell**, not a fixed value:

```
For spells:
  timeout = base_cast_time * (1 - min(FC%, 80) / 100) + 1.5

For items (Warp Ring, etc.):
  timeout = cast_delay + 1.5  (no Fast Cast reduction)

For unknown actions:
  timeout = 5.0  (fallback)
```

**Examples:**

| Spell | Base Cast | FC% | Adjusted | Buffer | Timeout |
|-------|-----------|-----|----------|--------|---------|
| Cure IV | 2.0s | 40% | 1.2s | 1.5s | 2.7s |
| Cure VI | 3.0s | 80% | 0.6s | 1.5s | 2.1s |
| Stoneskin | 7.0s | 0% | 7.0s | 1.5s | 8.5s |
| Warp Ring | 10.0s | N/A | 10.0s | 1.5s | 11.5s |

**Note:** Fast Cast percentage is read from `state.FastCast` if defined in the job config. Changing the buffer requires `//gs c reload` or using the in-game command.

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

1. Increase buffer: `//gs c watchdog buffer 2.5` (adds more time after cast)
2. Check if `state.FastCast` is set correctly for your job (wrong FC% causes wrong timeout)
3. Check client lag (FPS issues, freezing)
4. Temporarily disable: `//gs c watchdog off`

### Watchdog Not Detecting Stuck

**Symptoms:**

- You remain stuck in midcast gear
- No cleanup after expected timeout

**Solution:**

1. Verify watchdog is enabled: `//gs c watchdog`
2. Check buffer setting (may be too high): `//gs c watchdog stats`
3. Force manual cleanup: `//gs c watchdog clear`
4. Enable debug mode to see scans: `//gs c watchdog debug`

---

## Performance

### Impact

- **CPU:** Negligible (~1ms per 0.5s scan)
- **Memory:** ~1KB
- **Network:** None

### Compatibility

- All jobs
- All subjobs
- All zones
- Compatible with all Windower addons

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
| `//gs c watchdog buffer [seconds]` | Set safety buffer (default 1.5s) |
| `//gs c watchdog fallback [seconds]` | Set fallback timeout (default 5.0s) |
| `//gs c watchdog clear` | Force cleanup |

---

## Version History

**Version 3.4** (2025-11-12):

- Refactored: DRY helpers (clear_midcast_state + get_current_cast_time)
- Dynamic per-spell timeout based on cast_time from res/spells.lua
- Fast Cast reduction applied to spell timeouts (capped at 80%)
- Item support: uses cast_delay from res/items.lua (no FC reduction)
- Configurable buffer (default 1.5s) and fallback timeout (default 5.0s)

**Version 2.0** (2025-10-26):

- Migrated to hook-based approach (no more command_registry)
- Self-rescheduling coroutine (no spam in debugmode)
- Test mode: `//gs c watchdog test` for easy verification
- Added to all 15 jobs

**Version 1.0** (2025-10-25):

- Initial release
- Fixed 3.5s timeout (replaced in v3.4 with dynamic timeout)
- Scan every 0.5s
- In-game commands
- Auto-start on job load

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

**Author**: Tetsouo

See also: [Test Guide](../features/watchdog.md) for complete testing procedures.

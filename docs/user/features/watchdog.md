# Midcast Watchdog

Automatic recovery from stuck midcast caused by network packet loss in laggy zones (Odyssey, Dynamis-Divergence, etc.).

---

## How it works

When you cast a spell, GearSwap equips midcast gear and waits for the server's completion packet to trigger aftercast. If that packet is lost, you stay stuck in midcast gear.

The watchdog calculates a **per-spell dynamic timeout** and forces gear cleanup when it expires:

```
timeout = base_cast_time * (1 - FC%/100) + 1.5s buffer
```

- Fast Cast capped at 80%
- Items (Warp Ring, etc.) use `cast_delay` with no FC reduction
- Unknown spells use 5.0s fallback timeout

| Spell | Base cast | FC% | Timeout |
|-------|-----------|-----|---------|
| Cure IV | 2.0s | 40% | 2.7s |
| Cure VI | 3.0s | 80% | 2.1s |
| Stoneskin | 7.0s | 0% | 8.5s |
| Warp Ring | 10.0s | N/A | 11.5s |

Scans every 0.5 seconds. Enabled automatically on job load.

---

## Commands

| Command | Description |
|---------|-------------|
| `watchdog` | Show status |
| `watchdog on` | Enable |
| `watchdog off` | Disable |
| `watchdog toggle` | Toggle on/off |
| `watchdog debug` | Toggle debug output (verbose, disable after testing) |
| `watchdog test` | Simulate stuck midcast |
| `watchdog stats` | Detailed statistics |
| `watchdog buffer [seconds]` | Set safety buffer (default 1.5, range 0-10) |
| `watchdog fallback [seconds]` | Set fallback timeout (default 5.0, range 0-30) |
| `watchdog clear` | Force immediate cleanup |

---

## Configuration

Source: `shared/utils/core/midcast_watchdog.lua`

| Setting | Default | Description |
|---------|---------|-------------|
| `WATCHDOG_BUFFER` | 1.5s | Added to adjusted cast time |
| `WATCHDOG_FALLBACK_TIMEOUT` | 5.0s | Used when cast time is unknown |
| `FAST_CAST_CAP` | 80% | Maximum FC reduction |

Fast Cast percentage is read from `state.FastCast` (defined per job in `[JOB]_STATES.lua`).

---

## Troubleshooting

**False positives** (cleanup during long casts): Increase buffer with `//gs c watchdog buffer 2.5`. Verify `state.FastCast` matches your actual FC%.

**Not detecting stuck casts**: Check `//gs c watchdog` shows enabled. Check buffer isn't too high. Use `//gs c watchdog clear` for immediate recovery.

**Not loading**: Watchdog initializes via `INIT_SYSTEMS.lua`. Run `//gs debugmode` to check for Lua errors, then `//gs c reload`.

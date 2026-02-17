# Job Change Manager

Automatic background system that prevents conflicts when you change jobs or subjobs.

---

## What It Does

Job Change Manager debounces rapid job and subjob changes so that only the final change takes effect. It cleans up the previous job's state (keybinds, UI, lockstyle, watchdog) before loading the new job, then triggers a GearSwap reload for a clean start.

You never interact with it directly. It runs automatically on every job or subjob change.

---

## Debounce Timing

| Change Type | Delay | Why |
|-------------|-------|-----|
| Main job change | 3.0 seconds | Full GearSwap reload needs time to initialize |
| Subjob-only change | 0.5 seconds | Lighter reload, only subjob config changes |

When you change jobs or subjobs multiple times in rapid succession, only the last change executes. All earlier pending changes are discarded.

**Example**: You change WAR/SAM to WAR/NIN to WAR/DNC within 1 second. The system waits 0.5 seconds after the last change, then reloads once with WAR/DNC.

---

## What You See

Normal job change flow:

1. Change job in-game.
2. Old job unloads (brief message).
3. New job loads with keybinds, UI, and macros.
4. Lockstyle applies after ~8 seconds.

If you change jobs or subjobs rapidly, you may see a brief pause before loading completes. This is the debounce working as intended.

---

## Troubleshooting

### Keybinds not working after job change

Wait 3-5 seconds for the debounce and reload to finish. If they still do not work:

```
//lua reload gearswap
```

### Duplicate UI windows

Toggle the UI off and on:

```
//gs c ui
//gs c ui
```

If it persists, run `//lua reload gearswap`.

### Lockstyle applies multiple times

Normal when changing jobs rapidly. The system stabilizes after the debounce period. Extra applications are harmless.

### Repeated "debouncing" messages

You are changing jobs or subjobs too quickly. Stop and wait for the debounce to complete (0.5-3.0 seconds). The final change will execute automatically.

If caused by a macro, add `/wait 1` between job change commands.

---

## Best Practices

- After changing jobs, wait for the load message before doing anything else.
- Do not run `//lua reload gearswap` during a job change; the debounce handles it.
- If something seems wrong, wait 3-5 seconds first. Most issues resolve on their own.
- As a last resort: `//lua unload gearswap` then `//lua load gearswap`.

---

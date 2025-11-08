# [JOB] - Troubleshooting

---

## ❌ Keybinds Not Working

**Symptoms**: Pressing Alt+1 does nothing

**Solutions**:

1. **Check keybinds loaded**:

   ```
   Look for: "[JOB] Keybinds loaded successfully" in console
   ```

2. **Check for conflicts**:

   ```
   //bind  # Shows all current binds
   ```

   Look for conflicts with your Alt+1, Alt+2, etc.

3. **Manual test**:

   ```
   //gs c cycle HybridMode  # Test if command system works
   ```

4. **Verify config file exists**:

   ```
   Check: Tetsouo/config/[job]/[JOB]_KEYBINDS.lua
   ```

---

## ❌ Gear Not Swapping

**Symptoms**: Equipment doesn't change when casting/engaging

**Solutions**:

1. **Check Watchdog status**:

   ```
   //gs c watchdog
   >> Should show: "Watchdog: ENABLED"
   ```

2. **Check item availability**:

   ```
   //gs c checksets
   >> Look for STORAGE or MISSING items
   ```

3. **Enable debug mode**:

   ```
   //gs c debugmidcast
   >> Cast a spell and check console output
   ```

4. **Full reload**:

   ```
   //gs reload
   ```

---

## ❌ Wrong Set Equipped

**Symptoms**: Wrong gear for spell/action

**Solutions**:

1. **Enable midcast debug**:

   ```
   //gs c debugmidcast
   >> Shows which set was selected and why
   ```

2. **Check state values**:

   ```
   //gs c state HybridMode  # Check current mode
   ```

3. **Check set exists**:
   Open `shared/jobs/[job]/sets/[job]_sets.lua` and verify the set is defined.

4. **Understand fallback chain**:
   MidcastManager tries nested sets first, then falls back to base sets.
   See [Sets](sets.md) for the full fallback priority.

---

## ❌ Lockstyle Not Applying

**Symptoms**: Character appearance doesn't change

**Solutions**:

1. **Check DressUp addon**:

   ```
   //lua l dressup
   ```

2. **Manual trigger**:

   ```
   //gs c lockstyle
   ```

3. **Check cooldown**:
   Wait 15 seconds between lockstyle changes (cooldown protection).

4. **Verify config**:
   Check `Tetsouo/config/[job]/[JOB]_LOCKSTYLE.lua` has valid lockstyle numbers.

---

## ❌ Job Change Errors

**Symptoms**: Errors when changing jobs

**Solutions**:

1. **Wait for debounce**:
   JobChangeManager has 3.0s debounce. Wait 3 seconds after job change before reloading.

2. **Manual cleanup**:

   ```
   //gs c unbind_all  # If old keybinds stuck
   //lua unload gearswap
   //lua load gearswap
   ```

3. **Check console**:
   Look for error messages and file paths that failed to load.

---

## ❌ Commands Not Working

**Symptoms**: `//gs c [command]` does nothing

**Solutions**:

1. **Check command exists**:
   See [Commands](commands.md) for valid commands.

2. **Check spelling**:
   Commands are case-sensitive. Use lowercase for most commands.

3. **Check CommonCommands**:
   Universal commands like `checksets`, `reload` work on all jobs.

4. **Check job-specific commands**:
   See `shared/jobs/[job]/functions/[JOB]_COMMANDS.lua` for job-specific commands.

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Toggle midcast debug (shows set selection) |
| `//gs c watchdog` | Check watchdog status (should be ENABLED) |
| `//gs c state [StateName]` | Show current value of a state |
| `//gs c checksets` | Validate equipment (shows VALID/STORAGE/MISSING) |
| `//gs c ui` | Toggle UI overlay (shows keybinds) |
| `//gs reload` | Full system reload |

---

## 🆘 Still Having Issues?

1. **Check error messages** in console carefully
2. **Compare with working job** (e.g., RDM, WHM)
3. **Verify file structure** matches [Configuration](configuration.md)
4. **Check for typos** in config files
5. **Reload GearSwap** after making changes

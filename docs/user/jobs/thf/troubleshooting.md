# THF - Troubleshooting

---

## ❌ Keybinds Not Working

**Symptoms**: Pressing Alt+1 does nothing

**Solutions**:

1. **Check keybinds loaded**:

   ```
   Look for: "[THF] Keybinds loaded successfully"
   ```

2. **Manual test**:

   ```
   //gs c cycle [StateName]
   ```

3. **Reload GearSwap**:

   ```
   //gs reload
   ```

---

## ❌ Gear Not Swapping

**Symptoms**: Equipment doesn't change

**Solutions**:

1. **Check Watchdog**:

   ```
   //gs c watchdog
   → Should show: "Watchdog: ENABLED"
   ```

2. **Check items**:

   ```
   //gs c checksets
   → Look for STORAGE or MISSING items
   ```

3. **Enable debug**:

   ```
   //gs c debugmidcast
   ```

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

3. **Verify config**:
   Check `Tetsouo/config/thf/THF_LOCKSTYLE.lua`

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
| `//gs c checksets` | Validate equipment |
| `//gs c ui` | Toggle UI overlay |
| `//gs reload` | Full system reload |

---

## 🆘 Still Having Issues?

1. **Check error messages** in console carefully
2. **Verify file structure** matches [Configuration](configuration.md)
3. **Reload GearSwap** after making changes

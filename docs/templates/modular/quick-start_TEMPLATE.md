# [JOB] - Quick Start Guide

## 🚀 Loading the System

1. **Change to [JOB] in-game**
2. **Load GearSwap**:

   ```
   //lua load gearswap
   ```

3. **Verify loading**:
   - Look for: `[[JOB]] Functions loaded successfully`
   - Keybinds auto-loaded
   - Macrobook set to Book [DEFAULT_BOOK], Page [DEFAULT_PAGE]
   - Lockstyle #[DEFAULT_LOCKSTYLE] applied after 8 seconds

---

## ✅ Verify System Loaded

**Check keybinds loaded**:

```
→ Console shows: "[JOB] Keybinds loaded successfully"
```

**Check UI (if enabled)**:

```
//gs c ui
→ Shows all keybinds overlay
```

**Validate equipment**:

```
//gs c checksets
→ Shows item validation (VALID/STORAGE/MISSING)
```

---

## 🎯 First Commands to Try

```
//gs c checksets          # Validate your equipment
//gs c ui                 # Toggle keybind display
//gs reload               # Reload system
```

---

## ⚙️ Default Setup

On load, system automatically:

- ✅ Loads all [JOB] keybinds ([KEYBIND_COUNT] total)
- ✅ Sets macrobook (Book [DEFAULT_BOOK], Page [DEFAULT_PAGE] for [DEFAULT_SUBJOB])
- ✅ Applies lockstyle #[DEFAULT_LOCKSTYLE] (after 8s delay)
- ✅ Displays UI with keybinds (if enabled)
- ✅ Sets default states ([DEFAULT_STATES])

---

## 📚 Next Steps

- **Learn keybinds** → [Keybinds Reference](keybinds.md)
- **Try commands** → [Commands Reference](commands.md)
- **Understand states** → [States & Modes](states.md)
- **Customize** → [Configuration](configuration.md)

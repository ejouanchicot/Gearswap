# WHM - Quick Start Guide

## 🚀 Loading the System

1. **Change to WHM in-game**
2. **Load GearSwap**:

   ```
   //lua load gearswap
   ```

3. **Verify loading**:
   - Look for: `[WHM] Functions loaded successfully`
   - Keybinds auto-loaded
   - Macrobook set to Book 1, Page 1
   - Lockstyle #3 applied after 8 seconds

---

## ✅ Verify System Loaded

**Check keybinds loaded**:

```
→ Console shows: "WHM SYSTEM LOADED"
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

- ✅ Loads all WHM keybinds (9 total)
- ✅ Sets macrobook (Book 1, Page 1 for RDM)
- ✅ Applies lockstyle #3 (after 8s delay)
- ✅ Displays UI with keybinds (if enabled)
- ✅ Sets default states:
  - OffenseMode: None
  - CastingMode: Normal
  - IdleMode: PDT
  - CureMode: Potency
  - AfflatusMode: Solace

---

## 📚 Next Steps

- **Learn keybinds** → [Keybinds Reference](keybinds.md)
- **Try commands** → [Commands Reference](commands.md)
- **Understand states** → [States & Modes](states.md)
- **Customize** → [Configuration](configuration.md)

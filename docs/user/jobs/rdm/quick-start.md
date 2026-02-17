# RDM - Quick Start Guide

## Loading the System

1. **Change to RDM in-game**
2. **Load GearSwap**:

   ```
   //lua load gearswap
   ```

3. **Verify loading**:
 - Look for: `[RDM] Functions loaded successfully`
 - Keybinds auto-loaded
 - Macrobook set to Book 1, Page 1
 - Lockstyle #1 applied after 8 seconds

---

## Verify System Loaded

**Check keybinds loaded**:

```
>> Console shows: "RDM SYSTEM LOADED"
>> Shows keybind count and macrobook info
```

**Check UI (if enabled)**:

```
//gs c ui
>> Shows all keybinds overlay
```

**Validate equipment**:

```
//gs c checksets
>> Shows item validation (VALID/STORAGE/MISSING)
```

---

## First Commands to Try

```
//gs c checksets          # Validate your equipment
//gs c ui                 # Toggle keybind display
//gs reload               # Reload system
//gs c debugmidcast       # Toggle midcast debug
```

---

## Default Setup

On load, system automatically:

- Loads all RDM keybinds (32 total)
- Sets macrobook (Book 1, Page 1 for NIN subjob)
- Applies lockstyle #1 (after 8s delay)
- Displays UI with keybinds (if enabled)
- Sets default states:
 - HybridMode: Normal
 - EngagedMode: DT
 - IdleMode: Refresh
 - EnfeebleMode: Potency
 - NukeMode: FreeNuke
 - MainWeapon: Naegling
 - SubWeapon: Genmei
 - CombatMode: Off

---

## Basic Usage

**Cycle main weapon**:

```
Press Alt+1
>> Cycles: Naegling >> Colada >> Daybreak
```

**Cycle enfeeble mode**:

```
Press Alt+5
>> Cycles: Potency >> Skill >> Duration
```

**Cast main light spell**:

```
Press Ctrl+8
>> Casts current MainLightSpell with NukeTier (e.g., Fire V)
```

**Quick convert**:

```
Press Ctrl+1
>> Casts Convert job ability
```

---

## Next Steps

- **Learn keybinds** >> [Keybinds Reference](keybinds.md)
- **Try commands** >> [Commands Reference](commands.md)
- **Understand states** >> [States & Modes](states.md)
- **Customize** >> [Configuration](configuration.md)

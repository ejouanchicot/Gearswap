# WHM - States & Modes

**Total States**: 6

---

## 📊 What are States?

States = Configuration options you cycle through with keybinds.

**Example**:

```lua
state.HybridMode = M{'PDT', 'Normal'}  -- 2 options
-- Press Alt+2 to cycle: PDT >> Normal >> PDT
```

---

## 📋 All WHM States

| State | Options | Default | Keybind | Description |
|-------|---------|---------|---------|-------------|
| **OffenseMode** | None, Melee ON | None | - | OffenseMode mode |
| **CastingMode** | Normal, Resistant | Normal | Alt+5 | CastingMode mode |
| **IdleMode** | PDT, Refresh | PDT | Alt+2 | IdleMode mode |
| **CureMode** | Potency, SIRD | Potency | Alt+1 | CureMode mode |
| **AfflatusMode** | Solace, Misery | Solace | Alt+3 | AfflatusMode mode |
| **CureAutoTier** | On, Off | On | Alt+4 | CureAutoTier mode |

---

## 🔍 Checking Current State

**Method 1**: UI overlay (if enabled)
**Method 2**: Console command:

```
//gs c state [StateName]
>> Shows current value
```

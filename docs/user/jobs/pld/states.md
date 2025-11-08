# PLD - States & Modes

**Total States**: 1

---

## 📊 What are States?

States = Configuration options you cycle through with keybinds.

**Example**:

```lua
state.HybridMode = M{'PDT', 'Normal'}  -- 2 options
-- Press Alt+2 to cycle: PDT >> Normal >> PDT
```

---

## 📋 All PLD States

| State | Options | Default | Keybind | Description |
|-------|---------|---------|---------|-------------|
| **HybridMode** | PDT, MDT | PDT | Alt+1 | HybridMode mode |

---

## 🔍 Checking Current State

**Method 1**: UI overlay (if enabled)
**Method 2**: Console command:

```
//gs c state [StateName]
>> Shows current value
```

# SAM - Keybinds Reference

**Total Keybinds**: 5
**Config File**: `Tetsouo/config/sam/SAM_KEYBINDS.lua`

---

## 📋 All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **Alt+1** | cycle MainWeapon | `state.MainWeapon` | Main Weapon |
| **Alt+2** | cycle HybridMode | `state.HybridMode` | Hybrid Mode |
| **Ctrl+[** | input /lockstyle on | - | Lockstyle On |
| **Alt+[** | input /lockstyle off | - | Lockstyle Off |
| **Ctrl+f12** | reload | - | Reload GearSwap |

---

## 🔑 Modifier Keys Reference

- `!` = Alt
- `^` = Ctrl
- `@` = Windows key
- `#` = Apps key

**Example**: `!1` = Alt+1

---

## 🧪 Testing Keybinds

1. Press a keybind (e.g., `Alt+1`)
2. Check console for state change message
3. Check UI overlay updates (if enabled)
4. Watch gear swap when performing action

**Manual test**:

```
//gs c cycle [StateName]  # Should work if system loaded
```

---

## 🔧 Customization

See [Configuration](configuration.md) for how to:

- Change keybind keys
- Add new keybinds
- Remove unused keybinds

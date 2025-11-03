# COR - Keybinds Reference

**Total Keybinds**: 8
**Config File**: `Tetsouo/config/cor/COR_KEYBINDS.lua`

---

## 📋 All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **key_combination** | gs_command | `state.state_name` | description |
| **Alt+1** | cycle MainWeapon | `state.MainWeapon` | Main Weapon |
| **Alt+2** | cycle RangeWeapon | `state.RangeWeapon` | Range Weapon |
| **Alt+3** | cycle QuickDraw | `state.QuickDraw` | Quick Draw Element |
| **Alt+4** | cycle HybridMode | `state.HybridMode` | Hybrid Mode |
| **Alt+5** | cycle MainRoll | `state.MainRoll` | Main Roll |
| **Alt+6** | cycle SubRoll | `state.SubRoll` | Sub Roll |
| **Alt+7** | cycle LuzafRing | `state.LuzafRing` | Luzaf Ring |

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

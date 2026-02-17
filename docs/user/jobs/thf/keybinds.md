# THF - Keybinds Reference

**Total Keybinds**: 6
**Config File**: `Tetsouo/config/thf/THF_KEYBINDS.lua`

---

## 📋 All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **Alt+1** | cycle MainWeapon | `state.MainWeapon` | Main Weapon |
| **Alt+2** | cycle SubWeapon | `state.SubWeapon` | Sub Weapon |
| **Alt+3** | cycle HybridMode | `state.HybridMode` | Hybrid Mode |
| **Alt+4** | cycle TreasureMode | `state.TreasureMode` | TH Mode |
| **Alt+7** | toggle RangeLock | `state.RangeLock` | Range Lock |

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

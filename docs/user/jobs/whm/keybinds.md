# WHM - Keybinds Reference

**Total Keybinds**: 9
**Config File**: `Tetsouo/config/whm/WHM_KEYBINDS.lua`

---

## 📋 All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **bind_string** | gs_command | `state.state_name` | UI_description |
| **Alt+1** | cycle CureMode | `state.CureMode` | Cure Mode |
| **Alt+2** | cycle IdleMode | `state.IdleMode` | Idle Mode |
| **Alt+3** | cycle AfflatusMode | `state.AfflatusMode` | Afflatus Mode |
| **Alt+4** | cycle CureAutoTier | `state.CureAutoTier` | Cure Auto-Tier |
| **Alt+0** | cycle CombatMode | `state.CombatMode` | Combat Mode |
| **Alt+5** | cycle CastingMode | `state.CastingMode` | Casting Mode |
| **Ctrl+[** | send input /lockstyle on | - | Lockstyle ON |
| **Alt+[** | send input /lockstyle off | - | Lockstyle OFF |

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

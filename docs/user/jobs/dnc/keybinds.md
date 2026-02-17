# DNC - Keybinds Reference

**Total Keybinds**: 11
**Config File**: `Tetsouo/config/dnc/DNC_KEYBINDS.lua`

---

## All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **Alt+1** | cycle MainWeapon | `state.MainWeapon` | Main Weapon |
| **Ctrl+1** | cycle SubWeaponOverride | `state.SubWeaponOverride` | Sub Override |
| **Alt+2** | cycle HybridMode | `state.HybridMode` | Hybrid Mode |
| **Alt+3** | cycle MainStep | `state.MainStep` | Main Step |
| **Alt+4** | cycle AltStep | `state.AltStep` | Alt Step |
| **Alt+5** | cycle UseAltStep | `state.UseAltStep` | Use Alt Step |
| **Alt+6** | cycle ClimacticAuto | `state.ClimacticAuto` | Climactic Auto |
| **Alt+7** | cycle JumpAuto | `state.JumpAuto` | Jump Auto |
| **Alt+8** | cycle Dance | `state.Dance` | Dance Type |
| **Ctrl+8** | dance | - | Activate Dance |

---

## Modifier Keys Reference

- `!` = Alt
- `^` = Ctrl
- `@` = Windows key
- `#` = Apps key

**Example**: `!1` = Alt+1

---

## Testing Keybinds

1. Press a keybind (e.g., `Alt+1`)
2. Check console for state change message
3. Check UI overlay updates (if enabled)
4. Watch gear swap when performing action

**Manual test**:

```
//gs c cycle [StateName]  # Should work if system loaded
```

---

## Customization

See [Configuration](configuration.md) for how to:

- Change keybind keys
- Add new keybinds
- Remove unused keybinds

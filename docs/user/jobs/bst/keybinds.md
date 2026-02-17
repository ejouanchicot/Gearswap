# BST - Keybinds Reference

**Total Keybinds**: 11
**Config File**: `Tetsouo/config/bst/BST_KEYBINDS.lua`

---

## All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **1** | cycle WeaponSet | `state.WeaponSet` | Main Weapon |
| **4** | cycle SubSet | `state.SubSet` | Sub/Shield |
| **5** | cycle HybridMode | `state.HybridMode` | Hybrid Mode |
| **6** | cycle AutoPetEngage | `state.AutoPetEngage` | Auto Pet Engage |
| **7** | cycle petIdleMode | `state.petIdleMode` | Pet Idle Mode |
| **Alt+5** | ecosystem | `state.ecosystem` | Cycle Ecosystem |
| **Alt+6** | species | `state.species` | Cycle Species |
| **Alt+7** | broth | - | Show Broth Count |
| **Alt+8** | pet engage | - | Engage Pet |
| **Alt+9** | pet disengage | - | Disengage Pet |

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

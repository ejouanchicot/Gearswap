# BLM - Keybinds Reference

**Total Keybinds**: 14
**Config File**: `Tetsouo/config/blm/BLM_KEYBINDS.lua`

---

## 📋 All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **key** | gs_command | `state.state_name` | description |
| **Alt+1** | cycle MainLightSpell | `state.MainLightSpell` | Main Light |
| **Alt+2** | cycle MainDarkSpell | `state.MainDarkSpell` | Main Dark |
| **Ctrl+1** | cycle SubLightSpell | `state.SubLightSpell` | Sub Light |
| **Ctrl+2** | cycle SubDarkSpell | `state.SubDarkSpell` | Sub Dark |
| **Alt+-** | cycle SpellTier | `state.SpellTier` | Spell Tier |
| **Alt+3** | cycle MainLightAOE | `state.MainLightAOE` | Light AOE |
| **Alt+4** | cycle MainDarkAOE | `state.MainDarkAOE` | Dark AOE |
| **Alt+=** | cycle AOETier | `state.AOETier` | AOE Tier |
| **Alt+0** | cycle Storm | `state.Storm` | Storm |
| **Alt+5** | cycle HybridMode | `state.HybridMode` | Hybrid Mode |
| **Alt+6** | cycle CombatMode | `state.CombatMode` | Combat Mode |
| **Alt+7** | cycle MagicBurstMode | `state.MagicBurstMode` | MB Mode |
| **Alt+8** | cycle DeathMode | `state.DeathMode` | Death Mode |

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

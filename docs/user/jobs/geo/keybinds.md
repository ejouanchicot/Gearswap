# GEO - Keybinds Reference

**Total Keybinds**: 13
**Config File**: `Tetsouo/config/geo/GEO_KEYBINDS.lua`

---

## 📋 All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **key** | gs_command | `state.state_name` | description |
| **Alt+1** | cycle MainIndi | `state.MainIndi` | Main Indi |
| **Alt+2** | cycle MainGeo | `state.MainGeo` | Main Geo |
| **Alt+3** | cycle MainLightSpell | `state.MainLightSpell` | Light Spell |
| **Alt+4** | cycle MainDarkSpell | `state.MainDarkSpell` | Dark Spell |
| **Alt+-** | cycle SpellTier | `state.SpellTier` | Spell Tier |
| **Alt+5** | cycle MainLightAOE | `state.MainLightAOE` | Light AOE |
| **Alt+6** | cycle MainDarkAOE | `state.MainDarkAOE` | Dark AOE |
| **Alt+=** | cycle AOETier | `state.AOETier` | AOE Tier |
| **Alt+7** | cycle HybridMode | `state.HybridMode` | Hybrid Mode |
| **Alt+8** | cycle CombatMode | `state.CombatMode` | Combat Mode |
| **Alt+9** | cycle LuopanMode | `state.LuopanMode` | Luopan Mode |
| **Alt+0** | cycle IndicolureMode | `state.IndicolureMode` | Indi Mode |

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

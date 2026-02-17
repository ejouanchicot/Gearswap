# BRD - Keybinds Reference

**Total Keybinds**: 23
**Config File**: `Tetsouo/config/brd/BRD_KEYBINDS.lua`

---

## All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **Alt+1** | cycle IdleMode | `state.IdleMode` | Idle Mode |
| **Alt+2** | cycle HybridMode | `state.HybridMode` | Hybrid Mode |
| **Alt+3** | cycle SongMode | `state.SongMode` | Song Pack |
| **Alt+4** | cycle MainInstrument | `state.MainInstrument` | Instrument |
| **Alt+5** | cycle VictoryMarch | `state.VictoryMarch` | Victory March Replace |
| **Alt+6** | cycle MainWeapon | `state.MainWeapon` | Main Weapon |
| **Alt+7** | cycle SubWeapon | `state.SubWeapon` | Sub Weapon |
| **Alt+8** | cycle EtudeType | `state.EtudeType` | Etude Type |
| **Alt+9** | cycle CarolElement | `state.CarolElement` | Carol Element |
| **Alt+-** | cycle ThrenodyElement | `state.ThrenodyElement` | Threnody Element |
| **Alt+=** | cycle MarcatoSong | `state.MarcatoSong` | Auto-Marcato Song |
| **Ctrl+1** | soul_voice | - | Soul Voice |
| **Ctrl+2** | nightingale | - | Nightingale |
| **Ctrl+3** | troubadour | - | Troubadour |
| **Ctrl+4** | nt | - | Nightingale+Troubadour |
| **Ctrl+5** | songs | - | Cast Song Pack |
| **Ctrl+6** | dummy | - | Cast Dummy Songs |
| **Ctrl+7** | marcato | - | Marcato |
| **Ctrl+8** | pianissimo | - | Pianissimo |
| **Ctrl+9** | threnody | - | Cast Threnody |
| **Ctrl+-** | carol | - | Cast Carol |
| **Ctrl+=** | etude | - | Cast Etude |

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

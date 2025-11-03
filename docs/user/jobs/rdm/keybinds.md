# RDM - Keybinds Reference

**Total Keybinds**: 32 (27 state cycling, 10 quick actions)
**Config File**: `Tetsouo/config/rdm/RDM_KEYBINDS.lua`

---

## 📋 All Keybinds

### Alt+ Keys (State Cycling)

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **Alt+1** | cycle MainWeapon | `state.MainWeapon` | Main Weapon (Naegling/Colada/Daybreak) |
| **Alt+2** | cycle SubWeapon | `state.SubWeapon` | Sub Weapon (Ammurapi/Genmei) |
| **Alt+3** | cycle EngagedMode | `state.EngagedMode` | Engaged Mode (DT/Acc/TP/Enspell) |
| **Alt+4** | cycle IdleMode | `state.IdleMode` | Idle Mode (Refresh/DT) |
| **Alt+5** | cycle EnfeebleMode | `state.EnfeebleMode` | Enfeeble Mode (Potency/Skill/Duration) |
| **Alt+6** | cycle NukeMode | `state.NukeMode` | Nuke Mode (FreeNuke/Magic Burst) |
| **Alt+P** | cycle SaboteurMode | `state.SaboteurMode` | Saboteur Mode (Off/On - auto-trigger) |
| **Alt+7** | cycle Enspell | `state.Enspell` | Enspell (Enfire/Enblizzard/Enaero/etc.) |
| **Alt+8** | cycle MainLightSpell | `state.MainLightSpell` | Main Light (Fire/Aero/Thunder) |
| **Alt+9** | cycle SubLightSpell | `state.SubLightSpell` | Sub Light (Fire/Aero/Thunder) |
| **Alt+-** | cycle MainDarkSpell | `state.MainDarkSpell` | Main Dark (Blizzard/Stone/Water) |
| **Alt+=** | cycle SubDarkSpell | `state.SubDarkSpell` | Sub Dark (Blizzard/Stone/Water) |
| **Alt+0** | cycle CombatMode | `state.CombatMode` | Combat Mode (Off/On - weapon lock) |

### F-Keys (Enhancement Spell Selection)

| Key | Function | State | Description |
|-----|----------|-------|-------------|
| **F1** | cycle GainSpell | `state.GainSpell` | Gain Spell (STR/DEX/VIT/AGI/INT/MND/CHR) |
| **F2** | cycle Barspell | `state.Barspell` | Bar Element (Barfira/Barblizzara/etc.) |
| **F3** | cycle BarAilment | `state.BarAilment` | Bar Ailment (Baramnesia/Barparalysis/etc.) |
| **F4** | cycle Spike | `state.Spike` | Spike (Blaze/Ice/Shock Spikes) |
| **F5** | cycle Storm | `state.Storm` | Storm (SCH subjob only) |

### Ctrl+ Keys (Quick Actions)

| Key | Function | Description |
|-----|----------|-------------|
| **Ctrl+1** | convert | Cast Convert job ability |
| **Ctrl+2** | chainspell | Cast Chainspell job ability |
| **Ctrl+3** | saboteur | Cast Saboteur job ability |
| **Ctrl+4** | composure | Cast Composure job ability |
| **Ctrl+5** | refresh | Cast Refresh on target |
| **Ctrl+6** | phalanx | Cast Phalanx on self |
| **Ctrl+7** | haste | Cast Haste on target |
| **Ctrl+8** | castlight | Cast Main Light spell with tier |
| **Ctrl+9** | castdark | Cast Main Dark spell with tier |
| **Ctrl+-** | castenspell | Cast current selected Enspell |
| **Ctrl+=** | cycle NukeTier | Nuke Tier (V/VI/IV/III/II/I) |

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
//gs c cycle MainWeapon  # Should work if system loaded
```

---

## 🔧 Customization

See [Configuration](configuration.md) for how to:

- Change keybind keys
- Add new keybinds
- Remove unused keybinds

**Example: Change Alt+1 to Alt+Q**:

```lua
-- In RDM_KEYBINDS.lua, change:
{key = "!1", command = "cycle MainWeapon", ...}
-- To:
{key = "!q", command = "cycle MainWeapon", ...}
```

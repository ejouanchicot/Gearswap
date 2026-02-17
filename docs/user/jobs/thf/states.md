# THF - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

**Config**: `Tetsouo/config/thf/THF_KEYBINDS.lua`

---

## States

### HybridMode

Controls the balance between offense and defense during melee combat.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken reduction (defensive mode) |
| `Normal` | Full offense, maximum DPS |

**Default**: `PDT`
**Keybind**: Alt+3

---

### MainWeapon

Selects the primary weapon.

| Option | Description |
|--------|-------------|
| `Vajra` | Relic dagger (best DPS) |
| `TwashtarM` | Empyrean dagger (crit build) |
| `Mpu Gandring` | REMA dagger (shared with DNC) |
| `Tauret` | High accuracy dagger |
| `Naegling` | Savage Blade sword |
| `Malevolence` | Magic damage club |
| `Dagger` | Generic dagger (for weapon sets) |

**Default**: `Vajra`
**Keybind**: Alt+1

---

### SubWeapon

Selects the offhand weapon.

| Option | Description |
|--------|-------------|
| `Centovente` | REMA dagger offhand (best) |
| `Tanmogayi` | High DPS sword offhand |
| `Kraken` | High magic damage club offhand |

**Default**: `Centovente`
**Keybind**: Alt+2

---

### TreasureMode

Controls Treasure Hunter gear application strategy.

| Option | Description |
|--------|-------------|
| `Tag` | Quick TH tag (minimal gear for speed) |
| `SATA` | SA/TA combo with TH (balanced DPS + TH) |
| `Full` | Maximum TH gear (full TH optimization) |

**Default**: `Tag`
**Keybind**: Alt+4

---

### AbyProc

Enables or disables Abyssea proc mode. When enabled, equips proc weapons instead of normal weapons. Boolean toggle state.

| Option | Description |
|--------|-------------|
| `false` | Abyssea proc mode disabled (normal weapons) |
| `true` | Abyssea proc mode enabled (proc weapons equipped) |

**Default**: `false`
**Keybind**: Alt+5 (WAR subjob only)

---

### AbyWeapon

Selects the weapon type for Abyssea procs. Only relevant when AbyProc is enabled.

| Option | Description |
|--------|-------------|
| `Dagger2` | Dagger |
| `Sword` | Sword |
| `Club` | Club |
| `Great Sword` | Great Sword |
| `Polearm` | Polearm |
| `Staff` | Staff |
| `Scythe` | Scythe |

**Default**: `Sword`
**Keybind**: Alt+6 (WAR subjob only)

---

### RangeLock

Locks ranged weapon slot (Exalted Crossbow + Acid Bolt). Enabled via `//gs c range` command which auto-equips, locks, and fires. Boolean toggle state.

| Option | Description |
|--------|-------------|
| `false` | Ranged weapons can be swapped freely |
| `true` | Ranged weapons locked |

**Default**: `false`
**Keybind**: Alt+7

---

### FastCast

Internal numeric state used by the midcast watchdog system. Represents your total Fast Cast percentage from gear and traits, used to calculate adjusted cast times. Not typically cycled manually.

| Option | Description |
|--------|-------------|
| `0` through `80` | Fast Cast percentage (increments of 10) |

**Default**: `0`

---

## Quick Reference

| State | Options | Default | Keybind |
|-------|---------|---------|---------|
| HybridMode | PDT / Normal | PDT | Alt+3 |
| MainWeapon | Vajra / TwashtarM / Mpu Gandring / Tauret / Naegling / Malevolence / Dagger | Vajra | Alt+1 |
| SubWeapon | Centovente / Tanmogayi / Kraken | Centovente | Alt+2 |
| TreasureMode | Tag / SATA / Full | Tag | Alt+4 |
| AbyProc | false / true | false | Alt+5 |
| AbyWeapon | Dagger2 / Sword / Club / Great Sword / Polearm / Staff / Scythe | Sword | Alt+6 |
| RangeLock | false / true | false | Alt+7 |
| FastCast | 0 - 80 | 0 | -- |

---

## Configuration

**Config files**: `Tetsouo/config/thf/`

| File | Purpose |
|------|---------|
| `THF_KEYBINDS.lua` | Keybind definitions |
| `THF_LOCKSTYLE.lua` | Lockstyle per subjob |
| `THF_MACROBOOK.lua` | Macrobook per subjob |
| `THF_STATES.lua` | State definitions |
| `THF_TP_CONFIG.lua` | TP and weaponskill settings |

**Lockstyle**: #1 (all subjobs)

**Macrobook**: Book 1, Page 1 (all subjobs)

See [Configuration Guide](../../guides/configuration.md) for details on customizing lockstyle, macrobook, and keybinds.

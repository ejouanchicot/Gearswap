# DRK - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

**Config**: `Tetsouo/config/drk/DRK_KEYBINDS.lua`

---

## States

### HybridMode

Controls the combat stance. Switches between damage reduction and high accuracy for evasive enemies.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken reduction (defensive mode) |
| `Accu` | High Accuracy mode (for evasive enemies) |

**Default**: `PDT`
**Keybind**: Alt+1

---

### MainWeapon

Selects the primary weapon set. Two-handed weapons pair with Utu Grip, one-handed weapons pair with Blurred Shield +1.

| Option | Description |
|--------|-------------|
| `Caladbolg` | Caladbolg (Great Sword REMA) + Utu Grip |
| `Liberator` | Liberator (Scythe Mythic) + Utu Grip |
| `Redemption` | Redemption (Scythe Empyrean) + Utu Grip |
| `Lycurgos` | Lycurgos (Great Axe) + Utu Grip |
| `Loxotic` | Loxotic Mace +1 (Club) + Blurred Shield +1 |

**Default**: `Caladbolg`
**Keybind**: Alt+2

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
| HybridMode | PDT / Accu | PDT | Alt+1 |
| MainWeapon | Caladbolg / Liberator / Redemption / Lycurgos / Loxotic | Caladbolg | Alt+2 |
| FastCast | 0 - 80 | 0 | -- |

---

## Configuration

**Config files**: `Tetsouo/config/drk/`

| File | Purpose |
|------|---------|
| `DRK_KEYBINDS.lua` | Keybind definitions |
| `DRK_LOCKSTYLE.lua` | Lockstyle per subjob |
| `DRK_MACROBOOK.lua` | Macrobook per subjob |
| `DRK_STATES.lua` | State definitions |
| `DRK_TP_CONFIG.lua` | TP and weaponskill settings |

**Lockstyle**: SAM=#1, WAR=#1, NIN=#2, DNC=#3

**Macrobook**: Book 1, Page 1 (default). SAM=Book 1/Page 1, WAR=Book 1/Page 2, NIN=Book 1/Page 3, DNC=Book 1/Page 4

See [Configuration Guide](../../guides/configuration.md) for details on customizing lockstyle, macrobook, and keybinds.

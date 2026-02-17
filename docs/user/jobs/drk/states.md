# DRK - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

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

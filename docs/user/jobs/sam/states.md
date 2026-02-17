# SAM - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

---

## States

### HybridMode

Controls the balance between offense and defense during melee combat.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken reduction (defensive mode) |
| `Normal` | Full offense, maximum DPS |

**Default**: `PDT`
**Keybind**: Alt+2

---

### MainWeapon

Selects the primary weapon set.

| Option | Description |
|--------|-------------|
| `Masamune` | Empyrean Great Katana (Aftermath: 30-50% Triple Damage) |
| `Kusanagi` | Prime Great Katana (Aftermath: Physical damage limit+, Double Attack+10%) |
| `Shining` | Shining One (Polearm - Impulse Drive +40%, Crit rate varies with TP) |
| `Dojikiri` | Dojikiri Yasutsuna (Aeonic - Store TP+10, TP Bonus+500, AM: SC/MB potency+) |
| `Soboro` | Soboro Sukehiro (Great Katana - Multi-hit) |
| `Norifusa` | Norifusa (Great Katana - Multi-hit) |

**Default**: `Masamune`
**Keybind**: Alt+1

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
| HybridMode | PDT / Normal | PDT | Alt+2 |
| MainWeapon | Masamune / Kusanagi / Shining / Dojikiri / Soboro / Norifusa | Masamune | Alt+1 |
| FastCast | 0 - 80 | 0 | -- |

# BST - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

---

## States

### AutoPetEngage

Controls whether the pet automatically engages your target when you engage.

| Option | Description |
|--------|-------------|
| `Off` | Pet must be manually commanded to engage |
| `On` | Pet auto-engages when conditions are met |

**Default**: `On`
**Keybind**: 6

---

### petIdleMode

Controls the gear priority when idle with a pet out.

| Option | Description |
|--------|-------------|
| `MasterPDT` | Prioritize master's Physical Damage Taken reduction |
| `PetPDT` | Prioritize pet's Physical Damage Taken reduction |

**Default**: `MasterPDT`
**Keybind**: 7

---

### ecosystem

Selects the ecosystem family for pet summoning (determines available species).

| Option | Description |
|--------|-------------|
| `Aquan` | Aquan family |
| `Beast` | Beast family |
| `Amorph` | Amorph family |
| `Bird` | Bird family |
| `Lizard` | Lizard family |
| `Plantoid` | Plantoid family |
| `Vermin` | Vermin family |

**Default**: `Aquan`
**Keybind**: Alt+5

Note: Cycling ecosystem dynamically rebuilds the species state with species from the selected family.

---

### petEngaged

Tracks whether the pet is currently engaged in combat. Managed automatically by the pet monitoring system; not typically cycled manually.

| Option | Description |
|--------|-------------|
| `false` | Pet is idle |
| `true` | Pet is engaged |

**Default**: `false`
**Keybind**: None

---

### WeaponSet

Selects the primary melee weapon.

| Option | Description |
|--------|-------------|
| `Aymur` | REMA axe |
| `Tauret` | Dagger |

**Default**: `Aymur`
**Keybind**: 1

---

### SubSet

Selects the offhand weapon or shield.

| Option | Description |
|--------|-------------|
| `Agwu's Axe` | Offhand axe |
| `Adapa Shield` | Shield option |
| `Diamond Aspis` | Shield option |
| `Kraken Club` | Multi-hit club |

**Default**: `Agwu's Axe`
**Keybind**: 4

---

### HybridMode

Controls the balance between damage and survivability when engaged.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken reduction for survivability |
| `Normal` | Maximum damage output |

**Default**: `PDT`
**Keybind**: 5

---

### Moving

Tracks whether the player is currently moving for movement speed gear. Managed automatically by the BST pet monitoring system's position tracking; can also be toggled manually with `//gs c toggle Moving`.

| Option | Description |
|--------|-------------|
| `false` | Standing still |
| `true` | Moving (equips movement speed gear) |

**Default**: `false`
**Keybind**: None

Note: BST disables the global AutoMove system for performance. Movement detection is handled by the BST-specific position tracker instead.

---

### FastCast

Internal numeric state used by the watchdog system to calculate cast time timeouts. Set to your total Fast Cast percentage from gear and traits. Cap is 80%.

| Option | Description |
|--------|-------------|
| `0` through `80` | Fast Cast percentage (increments of 10) |

**Default**: `0`
**Keybind**: None

---

## Quick Reference

| State | Options | Default | Keybind |
|-------|---------|---------|---------|
| WeaponSet | Aymur / Tauret | Aymur | 1 |
| SubSet | Agwu's Axe / Adapa Shield / Diamond Aspis / Kraken Club | Agwu's Axe | 4 |
| HybridMode | PDT / Normal | PDT | 5 |
| AutoPetEngage | Off / On | On | 6 |
| petIdleMode | MasterPDT / PetPDT | MasterPDT | 7 |
| ecosystem | Aquan / Beast / Amorph / Bird / Lizard / Plantoid / Vermin | Aquan | Alt+5 |
| petEngaged | false / true | false | -- |
| Moving | false / true | false | -- |
| FastCast | 0-80 (by 10) | 0 | -- |

# COR - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

---

## States

### HybridMode

Controls the balance between damage and survivability when engaged.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken -50% for survivability |
| `Normal` | Maximum DPS output |

**Default**: `PDT`
**Keybind**: Alt+4

---

### MainWeapon

Selects the primary melee weapon.

| Option | Description |
|--------|-------------|
| `Naegling` | Savage Blade sword |

**Default**: `Naegling`
**Keybind**: Alt+1

---

### RangeWeapon

Selects the ranged weapon.

| Option | Description |
|--------|-------------|
| `Anarchy` | REMA gun (best DPS) |
| `Compensator` | High-tier gun alternative |

**Default**: `Anarchy`
**Keybind**: Alt+2

---

### QuickDraw

Selects which element to use for Quick Draw shots.

| Option | Description |
|--------|-------------|
| `Light` | Light Shot (most versatile) |
| `Fire` | Fire Shot |
| `Ice` | Ice Shot |
| `Wind` | Wind Shot |
| `Earth` | Earth Shot |
| `Thunder` | Thunder Shot |
| `Water` | Water Shot |
| `Dark` | Dark Shot |

**Default**: `Light`
**Keybind**: Alt+3

---

### LuzafRing

Toggles Luzaf's Ring mode which affects Phantom Roll range.

| Option | Description |
|--------|-------------|
| `ON` | 16 yalm range (Luzaf's Ring bonus) |
| `OFF` | 8 yalm range (standard) |

**Default**: `ON`
**Keybind**: Alt+7

---

### MainRoll

Selects the primary Phantom Roll.

| Option | Description |
|--------|-------------|
| `Chaos Roll` | Attack+ |
| `Samurai Roll` | Store TP+ |
| `Hunter's Roll` | Accuracy+ |
| `Tactician's Roll` | Regain+ |
| `Allies' Roll` | Skillchain Damage+ |
| `Wizard's Roll` | MAB+ |
| `Warlock's Roll` | MACC+ |
| `Corsair's Roll` | Exp/CP+ |
| `Caster's Roll` | Fast Cast+ |
| `Courser's Roll` | Snapshot+ |
| `Blitzer's Roll` | Delay Reduction+ |
| `Fighter's Roll` | Double-Attack+ |
| `Rogue's Roll` | Crit Hit Rate+ |
| `Gallant's Roll` | PDT- |
| `Evoker's Roll` | Refresh+ |
| `Bolter's Roll` | Movement Speed+ |
| `Miser's Roll` | Save TP+ |
| `Companion's Roll` | Pet Regain/Regen+ |
| `Avenger's Roll` | Counter Rate+ |
| `Naturalist's Roll` | Enh. Magic Duration+ |

**Default**: `Chaos Roll`
**Keybind**: Alt+5

---

### SubRoll

Selects the secondary Phantom Roll.

| Option | Description |
|--------|-------------|
| `Samurai Roll` | Store TP+ |
| `Chaos Roll` | Attack+ |
| `Hunter's Roll` | Accuracy+ |
| `Tactician's Roll` | Regain+ |
| `Allies' Roll` | Skillchain Damage+ |
| `Wizard's Roll` | MAB+ |
| `Warlock's Roll` | MACC+ |
| `Corsair's Roll` | Exp/CP+ |
| `Caster's Roll` | Fast Cast+ |
| `Courser's Roll` | Snapshot+ |
| `Blitzer's Roll` | Delay Reduction+ |
| `Fighter's Roll` | Double-Attack+ |
| `Rogue's Roll` | Crit Hit Rate+ |
| `Gallant's Roll` | PDT- |
| `Evoker's Roll` | Refresh+ |
| `Bolter's Roll` | Movement Speed+ |
| `Miser's Roll` | Save TP+ |
| `Companion's Roll` | Pet Regain/Regen+ |
| `Avenger's Roll` | Counter Rate+ |
| `Naturalist's Roll` | Enh. Magic Duration+ |

**Default**: `Samurai Roll`
**Keybind**: Alt+6

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
| MainWeapon | Naegling | Naegling | Alt+1 |
| RangeWeapon | Anarchy / Compensator | Anarchy | Alt+2 |
| QuickDraw | Light / Fire / Ice / Wind / Earth / Thunder / Water / Dark | Light | Alt+3 |
| HybridMode | PDT / Normal | PDT | Alt+4 |
| MainRoll | 20 rolls (see above) | Chaos Roll | Alt+5 |
| SubRoll | 20 rolls (see above) | Samurai Roll | Alt+6 |
| LuzafRing | ON / OFF | ON | Alt+7 |
| FastCast | 0-80 (by 10) | 0 | -- |

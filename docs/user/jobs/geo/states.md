# GEO - States & Modes

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
**Keybind**: Alt+7

---

### CombatMode

Controls whether weapon slots are locked to prevent gear swaps.

| Option | Description |
|--------|-------------|
| `Off` | Weapons can swap freely |
| `On` | Main, sub, range, and ammo slots locked |

**Default**: `Off`
**Keybind**: Alt+8

---

### LuopanMode

Controls gear focus when a Luopan bubble is active.

| Option | Description |
|--------|-------------|
| `DT` | Luopan survival (PDT/MDT gear to keep bubble alive) |
| `DPS` | Damage optimization (less pet survival) |

**Default**: `DT`
**Keybind**: Alt+9

---

### MainWeapon

Selects the primary weapon (handbell).

| Option | Description |
|--------|-------------|
| `Idris` | REMA handbell |

**Default**: `Idris`
**Keybind**: None

---

### SubWeapon

Selects the offhand shield.

| Option | Description |
|--------|-------------|
| `Genmei Shield` | PDT shield |

**Default**: `Genmei Shield`
**Keybind**: None

---

### IndicolureMode

Controls whether Indi spells target self or a party member via Entrust.

| Option | Description |
|--------|-------------|
| `Self` | Indi spell applied to self |
| `Entrust` | Indi spell applied to party member (requires Entrust ability active) |

**Default**: `Self`
**Keybind**: Alt+0

---

### MainIndi

Selects the Indicolure spell to cast. Contains 29 spells covering buffs, stat boosts, and debuffs.

**Buffs (first 10)**:

| Option | Description |
|--------|-------------|
| `Indi-Haste` | Haste+ |
| `Indi-Fury` | Attack+ |
| `Indi-Precision` | Accuracy+ |
| `Indi-Refresh` | Refresh+ |
| `Indi-Barrier` | Defense+ |
| `Indi-Acumen` | MAB+ |
| `Indi-Focus` | MACC+ |
| `Indi-Voidance` | Evasion+ |
| `Indi-Attunement` | MDB+ |
| `Indi-Regen` | Regen+ |

**Stats (7)**:

| Option | Description |
|--------|-------------|
| `Indi-STR` | STR+ |
| `Indi-DEX` | DEX+ |
| `Indi-VIT` | VIT+ |
| `Indi-AGI` | AGI+ |
| `Indi-INT` | INT+ |
| `Indi-MND` | MND+ |
| `Indi-CHR` | CHR+ |

**Debuffs (12)**:

| Option | Description |
|--------|-------------|
| `Indi-Frailty` | Attack- |
| `Indi-Malaise` | MDB- |
| `Indi-Torpor` | Evasion- |
| `Indi-Slow` | Magic Haste- |
| `Indi-Languor` | Magic Attack/Defense- |
| `Indi-Paralysis` | Adds Paralysis |
| `Indi-Vex` | Magic Evasion- |
| `Indi-Wilt` | Magic Defense- |
| `Indi-Slip` | Accuracy- |
| `Indi-Fade` | Magic Accuracy- |
| `Indi-Gravity` | Movement Speed- |
| `Indi-Fend` | Physical Defense- |
| `Indi-Poison` | Adds Poison |

**Default**: `Indi-Haste`
**Keybind**: Alt+1

---

### MainGeo

Selects the Geocolure spell for the Luopan bubble. Contains 26 spells, debuffs listed first.

**Debuffs (13)**:

| Option | Description |
|--------|-------------|
| `Geo-Frailty` | Attack- |
| `Geo-Malaise` | MDB- |
| `Geo-Torpor` | Evasion- |
| `Geo-Slow` | Magic Haste- |
| `Geo-Languor` | Magic Attack/Defense- |
| `Geo-Paralysis` | Adds Paralysis |
| `Geo-Vex` | Magic Evasion- |
| `Geo-Wilt` | Physical Defense- |
| `Geo-Slip` | Accuracy- |
| `Geo-Fade` | Magic Accuracy- |
| `Geo-Gravity` | Movement Speed- |
| `Geo-Fend` | Physical Defense- |
| `Geo-Poison` | Adds Poison |

**Buffs (13)**:

| Option | Description |
|--------|-------------|
| `Geo-Haste` | Haste+ |
| `Geo-Fury` | Attack+ |
| `Geo-Precision` | Accuracy+ |
| `Geo-Barrier` | Defense+ |
| `Geo-Acumen` | MAB+ |
| `Geo-Focus` | MACC+ |
| `Geo-Voidance` | Evasion+ |
| `Geo-Attunement` | MDB+ |
| `Geo-Regen` | Regen+ |
| `Geo-STR` | STR+ |
| `Geo-DEX` | DEX+ |
| `Geo-VIT` | VIT+ |
| `Geo-AGI` | AGI+ |
| `Geo-INT` | INT+ |
| `Geo-MND` | MND+ |

**Default**: `Geo-Frailty`
**Keybind**: Alt+2

---

### MainLightSpell

Selects the light-element nuke family.

| Option | Description |
|--------|-------------|
| `Fire` | Fire-based nukes |
| `Aero` | Wind-based nukes |
| `Thunder` | Lightning-based nukes |

**Default**: `Fire`
**Keybind**: Alt+3

---

### MainDarkSpell

Selects the dark-element nuke family.

| Option | Description |
|--------|-------------|
| `Blizzard` | Ice-based nukes |
| `Stone` | Earth-based nukes |
| `Water` | Water-based nukes |

**Default**: `Blizzard`
**Keybind**: Alt+4

---

### SpellTier

Selects the nuke tier. Tier "I" casts the base spell (e.g., "Fire" not "Fire I").

| Option | Description |
|--------|-------------|
| `V` | Highest tier |
| `IV` | Tier IV |
| `III` | Tier III |
| `II` | Tier II |
| `I` | Base tier |

**Default**: `V`
**Keybind**: Alt+-

---

### MainLightAOE

Selects the light-element AOE nuke family.

| Option | Description |
|--------|-------------|
| `Fira` | Fire AOE nukes |
| `Aera` | Wind AOE nukes |
| `Thundara` | Lightning AOE nukes |

**Default**: `Fira`
**Keybind**: Alt+5

---

### MainDarkAOE

Selects the dark-element AOE nuke family.

| Option | Description |
|--------|-------------|
| `Blizzara` | Ice AOE nukes |
| `Stonera` | Earth AOE nukes |
| `Watera` | Water AOE nukes |

**Default**: `Blizzara`
**Keybind**: Alt+6

---

### AOETier

Selects the AOE nuke tier.

| Option | Description |
|--------|-------------|
| `III` | Highest tier |
| `II` | Mid tier |
| `I` | Base tier |

**Default**: `III`
**Keybind**: Alt+=

---

### FastCast

Internal numeric state used by the watchdog system to calculate cast time timeouts. Set to your total Fast Cast percentage from gear and traits. Cap is 80%.

| Option | Description |
|--------|-------------|
| `0` through `80` | Fast Cast percentage (increments of 10) |

**Default**: `80`
**Keybind**: None

---

## Quick Reference

| State | Options | Default | Keybind |
|-------|---------|---------|---------|
| MainIndi | 29 Indi spells | Indi-Haste | Alt+1 |
| MainGeo | 26 Geo spells | Geo-Frailty | Alt+2 |
| MainLightSpell | Fire / Aero / Thunder | Fire | Alt+3 |
| MainDarkSpell | Blizzard / Stone / Water | Blizzard | Alt+4 |
| MainLightAOE | Fira / Aera / Thundara | Fira | Alt+5 |
| MainDarkAOE | Blizzara / Stonera / Watera | Blizzara | Alt+6 |
| HybridMode | PDT / Normal | PDT | Alt+7 |
| CombatMode | Off / On | Off | Alt+8 |
| LuopanMode | DT / DPS | DT | Alt+9 |
| IndicolureMode | Self / Entrust | Self | Alt+0 |
| SpellTier | V / IV / III / II / I | V | Alt+- |
| AOETier | III / II / I | III | Alt+= |
| MainWeapon | Idris | Idris | -- |
| SubWeapon | Genmei Shield | Genmei Shield | -- |
| FastCast | 0-80 (by 10) | 80 | -- |

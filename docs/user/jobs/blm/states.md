# BLM - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

---

## States

### HybridMode

Controls the balance between damage and survivability when engaged.

| Option | Description |
|--------|-------------|
| `Normal` | Maximum MAB for full damage output |
| `PDT` | Physical Damage Taken -50% for survivability |

**Default**: `Normal`
**Keybind**: Alt+5

---

### CombatMode

Controls whether weapon slots are locked to prevent gear swaps.

| Option | Description |
|--------|-------------|
| `Off` | Weapons can swap freely during casting |
| `On` | Main, sub, range, and ammo slots locked |

**Default**: `Off`
**Keybind**: Alt+6

---

### MagicBurstMode

Controls whether Magic Burst potency gear is used during nukes.

| Option | Description |
|--------|-------------|
| `Off` | Normal nuke gear |
| `On` | Magic Burst potency gear |

**Default**: `On`
**Keybind**: Alt+7

---

### DeathMode

Optimizes gear for the Death spell (HP-based dark magic).

| Option | Description |
|--------|-------------|
| `Off` | Normal nuke configuration |
| `On` | Optimize for Death spell |

**Default**: `Off`
**Keybind**: Alt+8

---

### MainWeapon

Selects the primary weapon (elemental staff).

| Option | Description |
|--------|-------------|
| `Hvergelmir` | REMA staff |

**Default**: `Hvergelmir`
**Keybind**: None

---

### SubWeapon

Selects the offhand grip.

| Option | Description |
|--------|-------------|
| `Alber Strap` | MAB grip |

**Default**: `Alber Strap`
**Keybind**: None

---

### MainLightSpell

Selects the primary light-element nuke family.

| Option | Description |
|--------|-------------|
| `Fire` | Fire-based nukes |
| `Aero` | Wind-based nukes |
| `Thunder` | Lightning-based nukes |

**Default**: `Fire`
**Keybind**: Alt+1

---

### MainDarkSpell

Selects the primary dark-element nuke family.

| Option | Description |
|--------|-------------|
| `Blizzard` | Ice-based nukes |
| `Stone` | Earth-based nukes |
| `Water` | Water-based nukes |

**Default**: `Stone`
**Keybind**: Alt+2

---

### SubLightSpell

Selects the secondary light-element nuke family.

| Option | Description |
|--------|-------------|
| `Thunder` | Lightning-based nukes |
| `Fire` | Fire-based nukes |
| `Aero` | Wind-based nukes |

**Default**: `Thunder`
**Keybind**: Ctrl+1

---

### SubDarkSpell

Selects the secondary dark-element nuke family.

| Option | Description |
|--------|-------------|
| `Water` | Water-based nukes |
| `Blizzard` | Ice-based nukes |
| `Stone` | Earth-based nukes |

**Default**: `Water`
**Keybind**: Ctrl+2

---

### SpellTier

Selects the nuke tier. Tier "I" casts the base spell (e.g., "Fire" not "Fire I").

| Option | Description |
|--------|-------------|
| `VI` | Highest tier (BLM exclusive) |
| `V` | Tier V |
| `IV` | Tier IV |
| `III` | Tier III |
| `II` | Tier II |
| `I` | Base tier |

**Default**: `VI`
**Keybind**: Alt+-

---

### MainLightAOE

Selects the light-element AOE nuke family.

| Option | Description |
|--------|-------------|
| `Firaga` | Fire AOE nukes |
| `Aeroga` | Wind AOE nukes |
| `Thundaga` | Lightning AOE nukes |

**Default**: `Firaga`
**Keybind**: Alt+3

---

### MainDarkAOE

Selects the dark-element AOE nuke family.

| Option | Description |
|--------|-------------|
| `Blizzaga` | Ice AOE nukes |
| `Stonega` | Earth AOE nukes |
| `Waterga` | Water AOE nukes |

**Default**: `Stonega`
**Keybind**: Alt+4

---

### AOETier

Selects the AOE nuke tier. Aja = highest tier (-ja spells). Refinement chain: Firaja >> Firaga III >> Firaga II >> Firaga I.

| Option | Description |
|--------|-------------|
| `Aja` | Top tier: -ja spells (Firaja, Stoneja, etc.) |
| `III` | High tier: -ga III spells |
| `II` | Mid tier: -ga II spells |
| `I` | Base tier: -ga I spells |

**Default**: `Aja`
**Keybind**: Alt+=

---

### Storm

Selects which Storm spell to cast (requires SCH subjob).

| Option | Description |
|--------|-------------|
| `Firestorm` | Fire affinity |
| `Sandstorm` | Earth affinity |
| `Thunderstorm` | Lightning affinity |
| `Hailstorm` | Ice affinity |
| `Rainstorm` | Water affinity |
| `Windstorm` | Wind affinity |
| `Voidstorm` | Dark affinity |
| `Aurorastorm` | Light affinity |

**Default**: `Firestorm`
**Keybind**: Alt+0

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
| HybridMode | Normal / PDT | Normal | Alt+5 |
| CombatMode | Off / On | Off | Alt+6 |
| MagicBurstMode | Off / On | On | Alt+7 |
| DeathMode | Off / On | Off | Alt+8 |
| MainWeapon | Hvergelmir | Hvergelmir | -- |
| SubWeapon | Alber Strap | Alber Strap | -- |
| MainLightSpell | Fire / Aero / Thunder | Fire | Alt+1 |
| MainDarkSpell | Blizzard / Stone / Water | Stone | Alt+2 |
| SubLightSpell | Thunder / Fire / Aero | Thunder | Ctrl+1 |
| SubDarkSpell | Water / Blizzard / Stone | Water | Ctrl+2 |
| SpellTier | VI / V / IV / III / II / I | VI | Alt+- |
| MainLightAOE | Firaga / Aeroga / Thundaga | Firaga | Alt+3 |
| MainDarkAOE | Blizzaga / Stonega / Waterga | Stonega | Alt+4 |
| AOETier | Aja / III / II / I | Aja | Alt+= |
| Storm | 8 storm spells | Firestorm | Alt+0 |
| FastCast | 0-80 (by 10) | 80 | -- |

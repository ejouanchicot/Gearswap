# RDM - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

**Config**: `Tetsouo/config/rdm/RDM_KEYBINDS.lua`

---

## States

### HybridMode

Controls the balance between damage and survivability when engaged.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken -50% for survivability |
| `Normal` | Maximum DPS output |

**Default**: `Normal`
**Keybind**: None (Mote-Include default: F9)

---

### EngagedMode

Controls melee combat gear focus when engaged.

| Option | Description |
|--------|-------------|
| `DT` | Damage Taken reduction |
| `Acc` | Accuracy focus for high evasion targets |
| `TP` | TP gain focus (Store TP, Dual Wield) |
| `Enspell` | Enspell damage focus |

**Default**: `DT`
**Keybind**: Numpad 3

---

### IdleMode

Controls idle gear focus when not engaged.

| Option | Description |
|--------|-------------|
| `Refresh` | MP Refresh gear |
| `DT` | Damage Taken reduction |

**Default**: `Refresh`
**Keybind**: Numpad 4

---

### MainWeapon

Selects the primary weapon.

| Option | Description |
|--------|-------------|
| `Naegling` | Savage Blade sword |
| `Colada` | Enspell sword |
| `Daybreak` | Magic nuke weapon |

**Default**: `Naegling`
**Keybind**: Numpad 1

---

### SubWeapon

Selects the offhand weapon or shield.

| Option | Description |
|--------|-------------|
| `Ammurapi` | Ammurapi Shield |
| `Genmei` | Genmei Shield |
| `Malevolence` | Malevolence sword |

**Default**: `Genmei`
**Keybind**: Numpad 2

---

### CombatMode

Controls whether weapon slots are locked to prevent gear swaps.

| Option | Description |
|--------|-------------|
| `Off` | Weapons can swap freely |
| `On` | Main, sub, and range slots locked |

**Default**: `Off`
**Keybind**: Numpad 5

---

### EnfeebleMode

Controls enfeebling magic gear priority.

| Option | Description |
|--------|-------------|
| `Potency` | Max potency (MND/INT focus) |
| `Skill` | Enfeebling Skill+ gear |
| `Duration` | Duration+ gear |

**Default**: `Potency`
**Keybind**: Numpad 6

---

### NukeMode

Controls elemental magic gear strategy.

| Option | Description |
|--------|-------------|
| `FreeNuke` | High-tier nuke gear (default) |
| `Magic Burst` | Magic Burst potency focus |

**Default**: `FreeNuke`
**Keybind**: Numpad 7

---

### SaboteurMode

Controls automatic Saboteur usage before enfeebling spells.

| Option | Description |
|--------|-------------|
| `Off` | Manual Saboteur usage |
| `On` | Auto-Saboteur before enfeebles |

**Default**: `Off`
**Keybind**: Numpad 8

---

### NukeTier

Selects the nuke tier. Tier "I" casts the base spell (e.g., "Fire" not "Fire I").

| Option | Description |
|--------|-------------|
| `V` | Highest tier |
| `IV` | Tier IV |
| `III` | Tier III |
| `II` | Tier II |
| `I` | Base tier |

**Default**: `V`
**Keybind**: Numpad 9

---

### MainLightSpell

Selects the primary light-element nuke family.

| Option | Description |
|--------|-------------|
| `Fire` | Fire-based nukes |
| `Aero` | Wind-based nukes |
| `Thunder` | Lightning-based nukes |

**Default**: `Fire`
**Keybind**: None

---

### SubLightSpell

Selects the secondary light-element nuke family.

| Option | Description |
|--------|-------------|
| `Fire` | Fire-based nukes |
| `Aero` | Wind-based nukes |
| `Thunder` | Lightning-based nukes |

**Default**: `Thunder`
**Keybind**: None

---

### MainDarkSpell

Selects the primary dark-element nuke family.

| Option | Description |
|--------|-------------|
| `Blizzard` | Ice-based nukes |
| `Stone` | Earth-based nukes |
| `Water` | Water-based nukes |

**Default**: `Blizzard`
**Keybind**: None

---

### SubDarkSpell

Selects the secondary dark-element nuke family.

| Option | Description |
|--------|-------------|
| `Blizzard` | Ice-based nukes |
| `Stone` | Earth-based nukes |
| `Water` | Water-based nukes |

**Default**: `Stone`
**Keybind**: None

---

### EnSpell

Selects the weapon enchantment spell.

| Option | Description |
|--------|-------------|
| `Enfire` | Fire damage on melee |
| `Enblizzard` | Ice damage on melee |
| `Enaero` | Wind damage on melee |
| `Enstone` | Earth damage on melee |
| `Enthunder` | Lightning damage on melee |
| `Enwater` | Water damage on melee |

**Default**: `Enfire`
**Keybind**: Alt+Numpad 1

---

### GainSpell

Selects the stat buff spell.

| Option | Description |
|--------|-------------|
| `Gain-STR` | Strength boost |
| `Gain-DEX` | Dexterity boost |
| `Gain-VIT` | Vitality boost |
| `Gain-AGI` | Agility boost |
| `Gain-INT` | Intelligence boost |
| `Gain-MND` | Mind boost |
| `Gain-CHR` | Charisma boost |

**Default**: `Gain-STR`
**Keybind**: Alt+Numpad 2

---

### Barspell

Selects the elemental resistance buff spell.

| Option | Description |
|--------|-------------|
| `Barfire` | Fire resistance |
| `Barblizzard` | Ice resistance |
| `Baraero` | Wind resistance |
| `Barstone` | Earth resistance |
| `Barthunder` | Lightning resistance |
| `Barwater` | Water resistance |

**Default**: `Barfire`
**Keybind**: Alt+Numpad 3

---

### BarAilment

Selects the ailment resistance buff spell.

| Option | Description |
|--------|-------------|
| `Baramnesia` | Amnesia resistance |
| `Barparalyze` | Paralysis resistance |
| `Barsilence` | Silence resistance |
| `Barpetrify` | Petrification resistance |
| `Barpoison` | Poison resistance |
| `Barblind` | Blindness resistance |
| `Barsleep` | Sleep resistance |
| `Barvirus` | Virus resistance |

**Default**: `Baramnesia`
**Keybind**: Alt+Numpad 4

---

### Spike

Selects the damage reflection spell.

| Option | Description |
|--------|-------------|
| `Blaze Spikes` | Fire damage reflection |
| `Ice Spikes` | Ice damage reflection (with paralyze proc) |
| `Shock Spikes` | Lightning damage reflection (with stun proc) |

**Default**: `Blaze Spikes`
**Keybind**: Alt+Numpad 5

---

### Storm (Conditional - SCH subjob only)

Selects which Storm spell to cast. This state only exists when your subjob is SCH. It is automatically created when changing to SCH and destroyed when changing away.

| Option | Description |
|--------|-------------|
| `Firestorm` | Fire affinity |
| `Hailstorm` | Ice affinity |
| `Windstorm` | Wind affinity |
| `Sandstorm` | Earth affinity |
| `Thunderstorm` | Lightning affinity |
| `Rainstorm` | Water affinity |
| `Aurorastorm` | Light affinity |
| `Voidstorm` | Dark affinity |

**Default**: `Firestorm`
**Keybind**: Numpad 0

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
| MainWeapon | Naegling / Colada / Daybreak | Naegling | Numpad 1 |
| SubWeapon | Ammurapi / Genmei / Malevolence | Genmei | Numpad 2 |
| EngagedMode | DT / Acc / TP / Enspell | DT | Numpad 3 |
| IdleMode | Refresh / DT | Refresh | Numpad 4 |
| CombatMode | Off / On | Off | Numpad 5 |
| EnfeebleMode | Potency / Skill / Duration | Potency | Numpad 6 |
| NukeMode | FreeNuke / Magic Burst | FreeNuke | Numpad 7 |
| SaboteurMode | Off / On | Off | Numpad 8 |
| NukeTier | V / IV / III / II / I | V | Numpad 9 |
| Storm | 8 storm spells (SCH only) | Firestorm | Numpad 0 |
| EnSpell | Enfire / Enblizzard / Enaero / Enstone / Enthunder / Enwater | Enfire | Alt+Numpad 1 |
| GainSpell | 7 Gain spells | Gain-STR | Alt+Numpad 2 |
| Barspell | 6 Bar-element spells | Barfire | Alt+Numpad 3 |
| BarAilment | 8 Bar-ailment spells | Baramnesia | Alt+Numpad 4 |
| Spike | Blaze / Ice / Shock Spikes | Blaze Spikes | Alt+Numpad 5 |
| HybridMode | PDT / Normal | Normal | F9 |
| MainLightSpell | Fire / Aero / Thunder | Fire | -- |
| SubLightSpell | Fire / Aero / Thunder | Thunder | -- |
| MainDarkSpell | Blizzard / Stone / Water | Blizzard | -- |
| SubDarkSpell | Blizzard / Stone / Water | Stone | -- |
| FastCast | 0-80 (by 10) | 80 | -- |

---

## Configuration

**Config files**: `Tetsouo/config/rdm/`

| File | Purpose |
|------|---------|
| `RDM_KEYBINDS.lua` | Keybind definitions |
| `RDM_LOCKSTYLE.lua` | Lockstyle per subjob |
| `RDM_MACROBOOK.lua` | Macrobook per subjob |
| `RDM_STATES.lua` | State definitions |
| `RDM_TP_CONFIG.lua` | TP and weaponskill settings |
| `RDM_SABOTEUR_CONFIG.lua` | Saboteur auto-trigger settings |

**Lockstyle**: NIN=#1, WHM=#2, BLM=#3, SCH=#4, DNC=#5

**Macrobook**: Book 2, Page 1 (all subjobs)

See [Configuration Guide](../../guides/configuration.md) for details on customizing lockstyle, macrobook, and keybinds.

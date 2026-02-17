# WHM - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

**Config**: `Tetsouo/config/whm/WHM_KEYBINDS.lua`

---

## States

### OffenseMode

Controls whether the character engages in melee combat. When set to Melee ON, weapons are locked to prevent accidental swaps.

| Option | Description |
|--------|-------------|
| `None` | No melee, focus on healing and casting |
| `Melee ON` | Enable melee mode (locks weapons) |

**Default**: `None`

---

### CastingMode

Controls spell accuracy gear selection. Use Resistant for enemies with high magic evasion.

| Option | Description |
|--------|-------------|
| `Normal` | Standard casting gear |
| `Resistant` | Magic accuracy focused gear (for resistant enemies) |

**Default**: `Normal`
**Keybind**: Alt+5

---

### IdleMode

Controls gear worn when not engaged in combat or casting.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken reduction (defensive idle) |
| `Refresh` | MP recovery priority (for safe areas) |

**Default**: `PDT`
**Keybind**: Alt+2

---

### CureMode

Controls cure spell optimization. Switches between maximum potency and spell interruption resistance.

| Option | Description |
|--------|-------------|
| `Potency` | Maximum cure potency (for safe casting) |
| `SIRD` | Spell Interruption Rate Down (for casting under attack) |

**Default**: `Potency`
**Keybind**: Alt+1

---

### AfflatusMode

Selects the active Afflatus stance. The `//gs c afflatus` command auto-casts the current stance.

| Option | Description |
|--------|-------------|
| `Solace` | Cure focus (Stoneskin on Cure, Bar-spell MDB, Sacrifice 7 effects) |
| `Misery` | Damage focus (Cura boost, Banish boost, Esuna 2 effects, Auspice Enlight) |

**Default**: `Solace`
**Keybind**: Alt+3

---

### CureAutoTier

Controls automatic Cure tier downgrade based on target HP missing. When on, casting a high-tier cure on a nearly-full target will automatically downgrade to a lower tier to save MP.

| Option | Description |
|--------|-------------|
| `On` | Auto-downgrade Cure tier based on target HP missing (MP efficient) |
| `Off` | Always use the Cure tier you manually selected |

**Default**: `On`
**Keybind**: Alt+4

---

### CombatMode

Controls weapon locking during combat. When on, main/sub/range/ammo slots stay equipped and are not swapped by gear sets.

| Option | Description |
|--------|-------------|
| `Off` | Weapons can swap freely (for casting builds) |
| `On` | Weapons locked (prevents accidental swaps during melee) |

**Default**: `Off`
**Keybind**: Alt+0

---

### FastCast

Internal numeric state used by the midcast watchdog system. Represents your total Fast Cast percentage from gear and traits, used to calculate adjusted cast times. Not typically cycled manually.

| Option | Description |
|--------|-------------|
| `0` through `80` | Fast Cast percentage (increments of 10) |

**Default**: `80`

---

## Quick Reference

| State | Options | Default | Keybind |
|-------|---------|---------|---------|
| OffenseMode | None / Melee ON | None | -- |
| CastingMode | Normal / Resistant | Normal | Alt+5 |
| IdleMode | PDT / Refresh | PDT | Alt+2 |
| CureMode | Potency / SIRD | Potency | Alt+1 |
| AfflatusMode | Solace / Misery | Solace | Alt+3 |
| CureAutoTier | On / Off | On | Alt+4 |
| CombatMode | Off / On | Off | Alt+0 |
| FastCast | 0 - 80 | 80 | -- |

---

## Configuration

**Config files**: `Tetsouo/config/whm/`

| File | Purpose |
|------|---------|
| `WHM_KEYBINDS.lua` | Keybind definitions |
| `WHM_LOCKSTYLE.lua` | Lockstyle per subjob |
| `WHM_MACROBOOK.lua` | Macrobook per subjob |
| `WHM_STATES.lua` | State definitions |
| `WHM_TP_CONFIG.lua` | TP and weaponskill settings |
| `WHM_CURE_CONFIG.lua` | Cure tier and potency settings |

**Lockstyle**: #3 (all subjobs)

**Macrobook**: Book 11, Page 1 (default). RDM=Book 11/Page 1, SCH=Book 11/Page 2, BLM=Book 11/Page 3, BLU=Book 11/Page 4, GEO=Book 11/Page 5

See [Configuration Guide](../../guides/configuration.md) for details on customizing lockstyle, macrobook, and keybinds.

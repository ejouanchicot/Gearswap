# WAR - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

**Config**: `Tetsouo/config/war/WAR_KEYBINDS.lua`

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

Selects the primary weapon set. Sub weapon and ammo are automatically paired based on the selected main weapon.

| Option | Description |
|--------|-------------|
| `Ukonvasara` | Relic Great Axe (Aftermath: TP reduction, best for AM3) |
| `Naegling` | Savage Blade sword (1H with shield for Fencer TP bonus) |
| `NaeglingKC` | Naegling + Kraken Club (multi-attack focus) |
| `Shining` | Shining One (Great Sword) |
| `Chango` | Empyrean Great Axe (Aftermath: Multi-Attack, +500 TP bonus) |
| `Ikenga` | Ikenga's Axe (1H option) |
| `Loxotic` | Loxotic Mace (1H option) |

**Default**: `Ukonvasara`
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
| MainWeapon | Ukonvasara / Naegling / NaeglingKC / Shining / Chango / Ikenga / Loxotic | Ukonvasara | Alt+1 |
| FastCast | 0 - 80 | 0 | -- |

---

## Configuration

**Config files**: `Tetsouo/config/war/`

| File | Purpose |
|------|---------|
| `WAR_KEYBINDS.lua` | Keybind definitions |
| `WAR_LOCKSTYLE.lua` | Lockstyle per subjob |
| `WAR_MACROBOOK.lua` | Macrobook per subjob |
| `WAR_STATES.lua` | State definitions |
| `WAR_TP_CONFIG.lua` | TP and weaponskill settings |

**Lockstyle**: #4 (all subjobs)

**Macrobook**: Book 22, Page 1 (default). SAM=Book 22/Page 1, DRG=Book 25/Page 1, DNC=Book 28/Page 1

See [Configuration Guide](../../guides/configuration.md) for details on customizing lockstyle, macrobook, and keybinds.

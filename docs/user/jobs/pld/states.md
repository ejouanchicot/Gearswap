# PLD - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

**Config**: `Tetsouo/config/pld/PLD_KEYBINDS.lua`

---

## States

### HybridMode

Controls the defensive stance for tanking. Determines which damage reduction set to use while engaged.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken reduction (for physical enemies) |
| `MDT` | Magic Damage Taken reduction (for magical enemies) |

**Default**: `PDT`
**Keybind**: Alt+1

---

### MainWeapon

Selects the primary weapon set.

| Option | Description |
|--------|-------------|
| `Burtgang` | Relic sword (ultimate tank weapon) |
| `BurtgangKC` | Burtgang + Kraken Club (DNC subjob multi-attack) |
| `Naegling` | Savage Blade sword |
| `Shining` | Shining One (Great Sword) |
| `Malevo` | Malevolence (Club) |

**Default**: `Burtgang`
**Keybind**: Alt+2

---

### Xp

Controls Phalanx optimization when using RDM subjob. Switches between Spell Interruption Rate Down and enhancing potency gear.

| Option | Description |
|--------|-------------|
| `Off` | Phalanx with Potency (enhancing skill/duration, endgame) |
| `On` | Phalanx with SIRD (Spell Interruption Rate Down, for XP/low level) |

**Default**: `Off`
**Keybind**: Alt+4 (RDM subjob only)

---

### RuneMode

Selects which rune to use when running RUN as a subjob. Each rune provides resistance to the opposing element.

| Option | Description |
|--------|-------------|
| `Ignis` | Fire rune (Ice resistance) |
| `Gelus` | Ice rune (Wind resistance) |
| `Flabra` | Wind rune (Earth resistance) |
| `Tellus` | Earth rune (Lightning resistance) |
| `Sulpor` | Lightning rune (Water resistance) |
| `Unda` | Water rune (Fire resistance) |
| `Lux` | Light rune (Dark resistance) |
| `Tenebrae` | Dark rune (Light resistance) |

**Default**: `Ignis`
**Keybind**: Alt+5 (RUN subjob only)

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
| HybridMode | PDT / MDT | PDT | Alt+1 |
| MainWeapon | Burtgang / BurtgangKC / Naegling / Shining / Malevo | Burtgang | Alt+2 |
| Xp | Off / On | Off | Alt+4 |
| RuneMode | Ignis / Gelus / Flabra / Tellus / Sulpor / Unda / Lux / Tenebrae | Ignis | Alt+5 |
| FastCast | 0 - 80 | 80 | -- |

---

## Configuration

**Config files**: `Tetsouo/config/pld/`

| File | Purpose |
|------|---------|
| `PLD_KEYBINDS.lua` | Keybind definitions |
| `PLD_LOCKSTYLE.lua` | Lockstyle per subjob |
| `PLD_MACROBOOK.lua` | Macrobook per subjob |
| `PLD_STATES.lua` | State definitions |
| `PLD_TP_CONFIG.lua` | TP and weaponskill settings |
| `PLD_BLU_MAGIC.lua` | BLU subjob spell configuration |

**Lockstyle**: #3 (all subjobs)

**Macrobook**: Book 15, Page 1 (default). RUN=Book 15/Page 1, BLU=Book 18/Page 1, RDM=Book 20/Page 1

See [Configuration Guide](../../guides/configuration.md) for details on customizing lockstyle, macrobook, and keybinds.

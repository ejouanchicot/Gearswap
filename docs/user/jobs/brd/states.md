# BRD - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

**Config**: `Tetsouo/config/brd/BRD_KEYBINDS.lua`

---

## States

### IdleMode

Controls idle gear focus when not engaged.

| Option | Description |
|--------|-------------|
| `Refresh` | MP Refresh gear (Fili +3) |
| `DT` | Damage Taken reduction (Nyame) |
| `Regen` | HP Regen gear (Nyame) |

**Default**: `DT`
**Keybind**: Alt+1

---

### EngagedMode

Controls melee combat gear focus when engaged.

| Option | Description |
|--------|-------------|
| `STP` | Store TP focus |
| `Acc` | Accuracy for high evasion targets |
| `DT` | Damage Taken reduction |
| `SB` | Subtle Blow (reduce enemy TP gain) |

**Default**: `STP`
**Keybind**: Alt+2

---

### SongMode

Selects a pre-configured song rotation pack. Each pack defines which songs to cast automatically.

| Option | Description |
|--------|-------------|
| `Dirge` | Honor + Min5/4 + Dirge |
| `March` | Honor + Min5/4 + Victory + Scherzo |
| `Madrigal` | Honor + Min5/4 + Madrigal + Victory |
| `Minne` | Honor + Min5/4 + Minne + Victory |
| `Etude` | Honor + Min5/4 + Etude + Victory |
| `Tank` | Victory + Minne + Ballad rotation (for tanks) |
| `Healer` | Victory + Minne + Ballad rotation (for healers) |
| `Carol` | Honor + Min5/4 + Carol + Victory |
| `Scherzo` | Honor + Min5/4 + Scherzo + Victory |
| `Arebati` | Honor + Min5/4 + Scherzo + Victory |
| `Ngai` | Honor + Minuet 5 + Water Carol II + Minne 5 + Scherzo |

**Default**: `Ngai`
**Keybind**: Alt+3

---

### MainInstrument

Selects which instrument to use for songs.

| Option | Description |
|--------|-------------|
| `Gjallarhorn` | REMA horn (best song potency) |
| `Daurdabla` | Dummy songs instrument |
| `Marsyas` | Alternative horn |

**Default**: `Gjallarhorn`
**Keybind**: Alt+4

---

### VictoryMarch

Controls what replaces Victory March when Haste is capped.

| Option | Description |
|--------|-------------|
| `Madrigal` | Replace with Blade Madrigal |
| `Minuet` | Replace with Minuet |
| `None` | Keep Victory March |

**Default**: `Madrigal`
**Keybind**: Alt+5

---

### MainWeapon

Selects the primary melee weapon.

| Option | Description |
|--------|-------------|
| `Naegling` | Savage Blade sword |
| `Twashtar` | Dagger |
| `Carnwenhan` | REMA dagger |
| `Mpu Gandring` | Dagger |

**Default**: `Mpu Gandring`
**Keybind**: Alt+6

---

### SubWeapon

Selects the offhand weapon or shield.

| Option | Description |
|--------|-------------|
| `Kraken` | Kraken Club |
| `Demersal` | Demersal Degen |
| `Genmei` | Genmei Shield |
| `Centovente` | Centovente |

**Default**: `Genmei`
**Keybind**: Alt+7

---

### EtudeType

Selects which stat buff Etude provides.

| Option | Description |
|--------|-------------|
| `STR` | Strength |
| `DEX` | Dexterity |
| `VIT` | Vitality |
| `AGI` | Agility |
| `INT` | Intelligence |
| `MND` | Mind |
| `CHR` | Charisma |

**Default**: `STR`
**Keybind**: Alt+8

---

### CarolElement

Selects which element Carol provides resistance to.

| Option | Description |
|--------|-------------|
| `Fire` | Fire resistance |
| `Ice` | Ice resistance |
| `Wind` | Wind resistance |
| `Earth` | Earth resistance |
| `Thunder` | Thunder resistance |
| `Water` | Water resistance |

**Default**: `Fire`
**Keybind**: Alt+9

---

### ThrenodyElement

Selects which element Threnody debuffs resistance for.

| Option | Description |
|--------|-------------|
| `Fire` | Fire resistance down |
| `Ice` | Ice resistance down |
| `Wind` | Wind resistance down |
| `Earth` | Earth resistance down |
| `Lightning` | Lightning resistance down |
| `Water` | Water resistance down |
| `Light` | Light resistance down |
| `Dark` | Dark resistance down |

**Default**: `Fire`
**Keybind**: Alt+-

---

### MarcatoSong

Controls automatic Marcato usage before specific songs.

| Option | Description |
|--------|-------------|
| `HonorMarch` | Auto-Marcato for Honor March with Nitro |
| `AriaPassion` | Auto-Marcato for Aria of Passion with Nitro |
| `Off` | Disable auto-Marcato |

**Default**: `HonorMarch`
**Keybind**: Alt+=

---

### BRDSong1 through BRDSong5

Display-only states showing the current song rotation slots. Automatically updated when SongMode changes. Not user-cyclable.

**Default**: `Empty`
**Keybind**: None

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
| IdleMode | Refresh / DT / Regen | DT | Alt+1 |
| EngagedMode | STP / Acc / DT / SB | STP | Alt+2 |
| SongMode | Dirge / March / Madrigal / Minne / Etude / Tank / Healer / Carol / Scherzo / Arebati / Ngai | Ngai | Alt+3 |
| MainInstrument | Gjallarhorn / Daurdabla / Marsyas | Gjallarhorn | Alt+4 |
| VictoryMarch | Madrigal / Minuet / None | Madrigal | Alt+5 |
| MainWeapon | Naegling / Twashtar / Carnwenhan / Mpu Gandring | Mpu Gandring | Alt+6 |
| SubWeapon | Kraken / Demersal / Genmei / Centovente | Genmei | Alt+7 |
| EtudeType | STR / DEX / VIT / AGI / INT / MND / CHR | STR | Alt+8 |
| CarolElement | Fire / Ice / Wind / Earth / Thunder / Water | Fire | Alt+9 |
| ThrenodyElement | Fire / Ice / Wind / Earth / Lightning / Water / Light / Dark | Fire | Alt+- |
| MarcatoSong | HonorMarch / AriaPassion / Off | HonorMarch | Alt+= |
| FastCast | 0-80 (by 10) | 80 | -- |

---

## Configuration

**Config files**: `Tetsouo/config/brd/`

| File | Purpose |
|------|---------|
| `BRD_KEYBINDS.lua` | Keybind definitions |
| `BRD_LOCKSTYLE.lua` | Lockstyle per subjob |
| `BRD_MACROBOOK.lua` | Macrobook per subjob |
| `BRD_STATES.lua` | State definitions |
| `BRD_TP_CONFIG.lua` | TP and weaponskill settings |
| `BRD_SONG_CONFIG.lua` | Song rotation configuration |
| `BRD_TIMING_CONFIG.lua` | Song timing settings |

**Lockstyle**: #7 (all subjobs)

**Macrobook**: Book 40, Page 1 (default). WHM=Book 40/Page 1, RDM=Book 36/Page 1, NIN=Book 36/Page 1, DNC=Book 36/Page 1

See [Configuration Guide](../../guides/configuration.md) for details on customizing lockstyle, macrobook, and keybinds.

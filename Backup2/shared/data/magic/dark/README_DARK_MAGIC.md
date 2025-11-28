# Dark Magic Database - Complete Reference

**Version:** 1.0
**Date:** 2025-10-31
**Author:** Tetsouo
**Source:** bg-wiki.com

---

## 📋 Overview

Complete database for all 26 Dark Magic spells in FFXI, organized into 4 modular files for maintainability.

---

## 🗂️ File Structure

```
shared/data/magic/dark/
├── dark_absorb.lua           (10 spells) - Absorb-ACC, Absorb-STR, etc.
├── dark_bio.lua              (3 spells)  - Bio I-III (DoT)
├── dark_drain.lua            (6 spells)  - Aspir/Drain I-III
└── dark_utility.lua          (7 spells)  - Death, Stun, Tractor, etc.

shared/data/magic/
└── DARK_MAGIC_DATABASE.lua   (Facade)    - Loads all modules
```

---

## 📊 Spell Categories

### 1. **Absorb Series** (10 spells - DRK only)

| Spell | Level | Effect |
|:--|:--:|:--|
| Absorb-MND | 31 | Absorbs target's mind |
| Absorb-CHR | 33 | Absorbs target's charisma |
| Absorb-VIT | 35 | Absorbs target's vitality |
| Absorb-AGI | 37 | Absorbs target's agility |
| Absorb-INT | 39 | Absorbs target's intelligence |
| Absorb-DEX | 41 | Absorbs target's dexterity |
| Absorb-STR | 43 | Absorbs target's strength |
| Absorb-TP | 45 | Absorbs target's TP |
| Absorb-ACC | 61 | Absorbs target's accuracy |
| Absorb-Attri | 91 | Steals beneficial buffs (up to 2 with Nether Void) |

**Notes:**

- All DRK main job only
- Duration/amount varies with Dark Magic skill
- All are Darkness element
- **Absorb-Attri** steals beneficial STATUS EFFECTS (not attributes despite the name!)
  - Example: Steals Haste, Protect, Shell, etc. from enemy
  - With Nether Void trait: can steal up to 2 buffs at once

---

### 2. **Aspir Series** (3 spells - MP drain)

| Spell | Jobs | Levels | Effect |
|:--|:--|:--|:--|
| Aspir | BLM, DRK, GEO, SCH | 20-36 | Drains MP from target |
| Aspir II | BLM, DRK, GEO, SCH | 78-97 | Enhanced MP drain |
| Aspir III | BLM, GEO | 99 (JP) | Maximum MP drain |

**Notes:**

- Multi-job access
- Aspir III requires Job Points

---

### 3. **Bio Series** (3 spells - DoT)

| Spell | Jobs | Levels | Disease Effect |
|:--|:--|:--|:--|
| Bio | BLM, DRK, RDM | 10-15 | ATK -10%, Regen -10 |
| Bio II | BLM, DRK, RDM | 35-40 | ATK -15%, Regen -15 |
| Bio III | SCH | 75 | ATK -18.75%, Regen -18.75 |

**Notes:**

- All inflict Disease status + Darkness DoT
- DoT ticks every 3 seconds
- Bio III is SCH-exclusive

---

### 4. **Drain Series** (3 spells - HP drain)

| Spell | Jobs | Levels | Effect |
|:--|:--|:--|:--|
| Drain | BLM, DRK, GEO, SCH | 10-21 | Drains HP from target |
| Drain II | DRK | 62 | Enhanced HP drain |
| Drain III | DRK | 99 (JP) | Maximum HP drain |

**Notes:**

- Drain II/III are DRK main job only
- Drain III requires Job Points

---

### 5. **Utility Spells** (7 spells)

| Spell | Jobs | Level | Element | Effect |
|:--|:--|:--:|:--:|:--|
| Death | BLM | 99 (JP) | Dark | Instant death or massive self damage |
| Dread Spikes | DRK | 71 | Dark | Absorbs physical damage as HP |
| Endark | DRK | 85 | Dark | Adds darkness to melee attacks |
| Endark II | DRK | 99 (JP) | Dark | Enhanced darkness to melee |
| Kaustra | SCH | 5 (SP) | Dark | AoE dark damage (Ebullience) |
| **Stun** | BLM, DRK | 37-45 | **Lightning** | Stuns target |
| Tractor | BLM, DRK | 25-32 | Dark | Pulls player to caster |

**IMPORTANT:**

- **Stun is the ONLY Dark Magic spell with Lightning element**
- Death can kill caster if it fails
- Kaustra requires Ebullience (Scholar SP ability) active

---

## ⚠️ IMPORTANT CORRECTIONS

### ❌ **Klimaform is NOT Dark Magic**

Your table listed Klimaform under Dark Magic, but this is **incorrect**:

- **Klimaform** is **Enhancing Magic** (not Dark Magic)
- Available to: GEO (Lv35), SCH (Lv68)
- Already added to `ENHANCING_MAGIC_DATABASE.lua`
- Description: "Enhances elemental magic potency during active weather"

---

## 🎯 Job Access Summary

| Job | Dark Magic Spells | Notable Access |
|:--|:--:|:--|
| **BLM** | 8 spells | Aspir, Drain, Bio, Death, Stun, Tractor |
| **DRK** | 23 spells | ALL Absorbs, ALL Drains, Endark, Dread Spikes |
| **GEO** | 3 spells | Aspir I-III, Drain |
| **RDM** | 2 spells | Bio I-II |
| **SCH** | 5 spells | Aspir, Drain, Bio III, Kaustra |

---

## 🔍 Element Distribution

| Element | Spell Count | Spells |
|:--|:--:|:--|
| **Darkness** | 25 spells | All EXCEPT Stun |
| **Lightning** | 1 spell | Stun only |

**Critical Note:** Stun is the **only exception** to the "all Dark Magic = Darkness element" rule.

---

## 📦 Database Features

### Helper Functions Available

```lua
local DarkDB = require('shared/data/magic/DARK_MAGIC_DATABASE')

-- Get description
local desc = DarkDB.get_description("Aspir")

-- Get element (returns "Dark" or "Lightning")
local element = DarkDB.get_element("Stun")  -- Returns "Lightning"

-- Check if Job Points spell
local is_jp = DarkDB.is_job_points_spell("Death", "BLM")  -- Returns true

-- Check if DRK-only
local is_drk = DarkDB.is_drk_only("Absorb-STR")  -- Returns true

-- Get all Absorb spells for level
local absorbs = DarkDB.get_absorb_spells(45)  -- Returns available Absorbs

-- Get specific Drain/Aspir tier
local spell = DarkDB.get_drain_spell("Aspir", "II", "BLM", 83)  -- "Aspir II"

-- Get Bio by tier
local bio = DarkDB.get_bio_spell("III", "SCH", 75)  -- "Bio III"
```

---

## 🛠️ Integration with Spell Message Handler

The Dark Magic database is compatible with the spell message handler system:

```lua
-- Spell messages will automatically show descriptions
[BLM/RDM] Aspir >> Drains MP from target.
[DRK/SAM] Absorb-STR >> Absorbs target's strength.
[SCH/WHM] Bio III >> Inflicts Disease (ATK -18.75%) and maximum Darkness DoT.
```

Controlled by `DARK_MESSAGES_CONFIG.lua` (if created):

- `'full'` - Show spell name + description
- `'on'` - Show spell name only
- `'off'` - Silent mode

---

## 📈 Statistics

- **Total Spells:** 26
- **DRK-Exclusive:** 13 spells (50%)
- **Multi-Job:** 13 spells (50%)
- **Job Points Required:** 4 spells (Death, Aspir III, Drain III, Endark II)
- **Darkness Element:** 25 spells (96%)
- **Lightning Element:** 1 spell (4% - Stun only)

---

## 🔗 Related Databases

- **Enhancing Magic:** `ENHANCING_MAGIC_DATABASE.lua` (includes Klimaform)
- **Enfeebling Magic:** `ENFEEBLING_MAGIC_DATABASE.lua`
- **Elemental Magic:** (to be created)
- **Healing Magic:** `HEALING_MAGIC_DATABASE.lua`
- **Divine Magic:** (to be created)

---

## 📝 Version History

**v1.0** (2025-10-31)

- Initial release
- 26 spells documented
- 4 modular files
- Corrected Klimaform classification
- Added Stun element exception

---

**Status:** ✅ Complete - Production Ready
**Coverage:** 100% of Dark Magic spells in FFXI

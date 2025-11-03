# Weapon Skills Database System

**Version:** 1.0
**Date:** 2025-10-29
**Author:** Tetsouo

---

## 📋 Overview

Universal weapon skills database system for displaying WS descriptions in-game (like JA messages). Follows the same auto-merge pattern as UNIVERSAL_JA_DATABASE.

**Pattern:**

1. Individual weapon databases maintained separately (easy editing)
2. Universal database auto-merges all at runtime
3. PRECAST modules use universal database (main weapon + swap weapons)

---

## 🏗️ Architecture

```
shared/data/weaponskills/
├── UNIVERSAL_WS_DATABASE.lua          ← Auto-merge all weapons
├── GREAT_AXE_WS_DATABASE.lua         ← 15 weaponskills
├── GREAT_SWORD_WS_DATABASE.lua       ← Future
├── DAGGER_WS_DATABASE.lua            ← Future
└── [WEAPON_TYPE]_WS_DATABASE.lua     ← Future
```

### Auto-Merge System

UNIVERSAL_WS_DATABASE.lua automatically merges all weapon databases:

```lua
local weapon_types = {
    'GREAT_AXE'  -- 15 weaponskills
    -- Future: 'GREAT_SWORD', 'DAGGER', 'CLUB', 'STAFF', etc.
}

for _, weapon_type in ipairs(weapon_types) do
    local success, weapon_db = pcall(require, 'shared/data/weaponskills/' .. weapon_type .. '_WS_DATABASE')
    if success and weapon_db then
        for ws_name, ws_data in pairs(weapon_db) do
            ws_data.weapon_type = weapon_type
            UNIVERSAL_WS_DB[ws_name] = ws_data
        end
    end
end
```

**Silently fails** if weapon database doesn't exist yet (incremental addition).

---

## 📊 Database Structure

### Standard WS Entry

```lua
['Upheaval'] = {
    description = "4-hit, VIT-based power",     -- PRIMARY: For in-game message
    skill_level = 357,                          -- Weapon skill requirement
    job_levels = {WAR = 90, DRK = 95, RUN = 94}, -- Job level requirements
    stat_modifiers = "73~85% VIT (merit ranks)", -- Attack calculation
    sc_properties = {'Fusion', 'Compression'},  -- Skillchain properties
    requires_quest = true,                      -- Quest requirement
    quest_name = "Martial Mastery",             -- Quest name
    requires_merit = true,                      -- Merit requirement
    merit_ranks = 5,                            -- Merit ranks needed
    special_weapons = nil,                      -- Standard quest WS
    aeonic_weapons = {                          -- Aeonic-specific bonuses
        {weapon = "Chango", level = 90, bonus = "Adds Light SC property"}
    },
    element = nil,                              -- Elemental damage (if any)
    notes = "4 hits, fTP 1.0/3.5/6.5, Light SC with Aeonic AM only"
}
```

### Special Weapons Structure

For WS requiring specific weapons (Relic/Mythic/Empyrean/Prime):

```lua
special_weapons = {
    {weapon = "Bravura", level = 75, type = "Relic", aftermath = true},
    {weapon = "Abaddon Killer", level = 75, type = "Relic", aftermath = true},
    {weapon = "Barbarus Bhuj", level = 85, type = "Quest"}
}
```

**Fields:**

- `weapon` (string): Weapon name
- `level` (number): Level required to use WS
- `type` (string): Weapon type (Relic/Mythic/Empyrean/Aeonic/Prime/Quest)
- `bonus` (string, optional): Special bonus (e.g., "+30% dmg")
- `aftermath` (boolean, optional): Has aftermath effect
- `jobs` (table, optional): Job restrictions (e.g., {"DRK", "RUN"})

### Multiple Access Paths

Some WS accessible via multiple weapons at different levels:

```lua
['Metatron Torment'] = {
    description = "Relic WS, -20% dmg taken AM",
    special_weapons = {
        {weapon = "Bravura", level = 75, type = "Relic", aftermath = true},
        {weapon = "Abaddon Killer", level = 75, type = "Relic", aftermath = true},
        {weapon = "Barbarus Bhuj", level = 85, type = "Quest"}
    }
}
```

Player can use via Bravura@75 OR Barbarus Bhuj@85.

---

## 🎮 In-Game Usage

### Integration (PRECAST Module)

```lua
-- Load universal WS database
local WS_DB = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

function job_precast(spell, action, spellMap, eventArgs)
    -- Display WS message (AFTER JA messages, BEFORE WS validation)
    if spell.type == 'WeaponSkill' and WS_DB[spell.english] then
        MessageFormatter.show_ws_activated(spell.english, WS_DB[spell.english].description)
    end
end
```

### Message Format

```
[WAR/SAM] [Upheaval] -> 4-hit, VIT-based power
```

**Colors:**

- `[WAR/SAM]` - Cyan (JOB_TAG)
- `[Upheaval]` - Yellow (WS)
- `->` - Gray (SEPARATOR)
- `4-hit, VIT-based power` - Gray (SEPARATOR)

Same format as JA messages for consistency.

### TP Display (Separate System)

TP amount displayed separately via existing `show_ws_tp()` function:

```
[Upheaval] (1250 TP)
```

**Color gradient:**

- 1000-1999 TP: White (Normal)
- 2000-2999 TP: Cyan (Enhanced)
- 3000+ TP: Green (Ultimate)

Called via `TPBonusHandler.apply_and_display()` in `job_post_precast()`.

---

## 📝 Current Weapons

### Great Axe (15 WS)

**Jobs:** WAR (A+, 424 cap), DRK (B-, 388 cap), RUN (B, 398 cap)

**Categories:**

- **Basic WS (7):** Shield Break, Iron Tempest, Sturmwind, Armor Break, Keen Edge, Weapon Break, Raging Rush
- **Advanced WS (3):** Full Break, Steel Cyclone, Fell Cleave
- **Merit/Quest WS (1):** Upheaval
- **Relic/Mythic/Empyrean (4):** Metatron Torment, Ukko's Fury, King's Justice, Disaster

**Special Cases:**

- **Raging Rush:** WAR-only WS (requires main job)
- **Upheaval:** Merit WS (requires quest + 5 merit ranks, Light SC with Aeonic AM only)
- **Disaster:** Prime WS (aftermath in Sortie only)

---

## 🛠️ Adding New Weapons

### Step 1: Create Weapon Database

```lua
// Create: shared/data/weaponskills/[WEAPON_TYPE]_WS_DATABASE.lua

---============================================================================
--- [Weapon Type] Weapon Skills Database
---============================================================================
--- @file [WEAPON_TYPE]_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0
--- @date [DATE]
---============================================================================

local [WEAPON_TYPE]_WS = {
    ['WS Name'] = {
        description = "Short description for in-game",
        skill_level = 100,
        job_levels = {JOB = 50},
        stat_modifiers = "60% STR",
        sc_properties = {'Fusion'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "Additional info"
    }
}

return [WEAPON_TYPE]_WS
```

### Step 2: Add to UNIVERSAL_WS_DATABASE

```lua
// Edit: shared/data/weaponskills/UNIVERSAL_WS_DATABASE.lua

local weapon_types = {
    'GREAT_AXE',
    '[WEAPON_TYPE]'  -- Add new weapon type
}
```

### Step 3: Integrate in PRECAST

Already automatic - PRECAST modules use UNIVERSAL_WS_DATABASE which auto-merges all weapons.

### Step 4: Test In-Game

```
1. Load job that uses weapon type
2. Use weaponskill
3. Verify message displays: [JOB/SUBJOB] [WS_NAME] -> Description
4. Verify TP displays: [WS_NAME] (1250 TP)
```

---

## 📚 Data Sources

**Primary:** bg-wiki.com

**URL Pattern:** `https://www.bg-wiki.com/ffxi/[WS_Name]`

**Example:** https://www.bg-wiki.com/ffxi/Upheaval

---

## 🔧 Database Purpose

**PRIMARY USE:** Display WS descriptions in-game (like JA messages)

**SECONDARY USE:** Documentation/reference for:

- Job level requirements
- Stat modifiers
- Skillchain properties
- Special weapon requirements
- Quest/merit requirements

**NOT USED FOR:** Validation of WS access (game already handles this)

---

## ✅ Standards

### Description Field (CRITICAL)

**Format:** Short, concise, action-focused

**Good:**

- "4-hit, VIT-based power"
- "Relic WS, -20% dmg taken AM"
- "AoE damage, radius varies"

**Bad:**

- "Delivers a powerful four-hit attack that scales with Vitality" (too long)
- "Upheaval" (too short, not descriptive)

### ASCII-Only Formatting

FFXI chat doesn't support Unicode/emojis.

**Use:**

- Brackets: `[WS_NAME]`
- ASCII arrow: `->`
- Standard punctuation: `,` `.` `-` `/`

**Don't Use:**

- Emojis: ⚔ ✨ 💥
- Unicode arrows: → ⇒
- Special characters: • ★ ◆

### Special Weapons Documentation

**Be explicit** about weapon requirements and levels:

```lua
special_weapons = {
    {weapon = "Bravura", level = 75, type = "Relic", aftermath = true},
    {weapon = "Barbarus Bhuj", level = 85, type = "Quest"}
}
```

Not:

```lua
special_weapon = "Bravura (Relic), Barbarus Bhuj"  -- Too vague
```

### Aeonic Aftermath Special Cases

If WS changes properties with Aeonic aftermath:

```lua
sc_properties = {'Fusion', 'Compression'},  -- Base properties only
aeonic_weapons = {
    {weapon = "Chango", level = 90, bonus = "Adds Light SC property"}
},
notes = "Light SC with Aeonic AM only"
```

---

## 🐛 Debugging

### WS Message Not Displaying

**Check:**

1. WS exists in database: `WS_DB['WS Name']`
2. MessageFormatter loaded: `local MessageFormatter = require(...)`
3. Integration correct: `if spell.type == 'WeaponSkill' and WS_DB[spell.english]`
4. Message function exposed: `MessageFormatter.show_ws_activated` exists

### Wrong Colors

**Standard colors (message_combat.lua):**

- JOB_TAG: Cyan (Colors.JOB_TAG)
- WS: Yellow (Colors.WS)
- SEPARATOR: Gray (Colors.SEPARATOR)
- Description: Gray (Colors.SEPARATOR) - NOT cyan

### ASCII Characters Breaking

Use only ASCII characters. Test in-game chat before committing.

---

## 📋 Future Weapons

### Planned

- **Great Sword** (~15 WS)
- **Dagger** (~15 WS)
- **Club** (~12 WS)
- **Staff** (~10 WS)
- **Katana** (~15 WS)
- **Scythe** (~12 WS)
- **Polearm** (~15 WS)
- **Sword** (~15 WS)
- **Hand-to-Hand** (~15 WS)
- **Archery/Marksmanship** (~12 WS each)

### Estimated Total

~180-200 weaponskills across all weapon types.

---

## 🎯 Related Systems

- **UNIVERSAL_JA_DATABASE:** Job abilities database (same pattern)
- **MessageFormatter:** Message display system
- **TPBonusHandler:** TP bonus calculation and display
- **WeaponSkillManager:** WS range validation

---

**Version:** 1.0
**Status:** Production-Ready (Great Axe complete)
**Next:** Great Sword, Dagger, Club, etc.

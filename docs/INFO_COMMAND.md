# Info Command - Universal Database Query System

**Version:** 1.0
**Date:** 2025-11-04
**Command:** `//gs c info <name>`

---

## Overview

Universal command to display detailed information for Job Abilities, Spells, and Weaponskills from the shared databases. Works for ALL jobs and formats output with proper color codes (ASCII-safe for FFXI chat).

---

## Usage

```
//gs c info <name>
```

**Examples:**

```bash
//gs c info Last Resort       # Job Ability (DRK)
//gs c info Haste             # Spell (RDM/WHM)
//gs c info Torcleaver        # Weaponskill (Great Axe)
//gs c info Blood Weapon      # Multi-word names supported
//gs c info Cure III          # Spell with tier
```

---

## Features

### **Universal Search**

- Searches across ALL databases automatically
- Works for any job/subjob combination
- No job-specific configuration needed

### **Data Sources**

1. **Job Abilities:** `shared/data/job_abilities/` (300+ abilities from 21 jobs)
2. **Spells:** `shared/data/magic/` (1,100+ spells from 6 skill + 8 job databases)
3. **Weaponskills:** `shared/data/weaponskills/` (212 weaponskills from 13 weapon types)

### **Formatted Output**

- Color-coded display using message system colors
- ASCII-safe text (FFXI chat compatible)
- Fields displayed only if data exists (no empty fields)
- Proper sanitization of special characters

### **Lazy Loading**

- Databases load on-demand (first use)
- No startup lag
- Data cached for subsequent queries

---

## Output Format

### Job Ability Display

```
=== Job Ability Information ===
Name: Last Resort
  Type: Job Ability
  Description: ATK/ACC+25%, DEF/EVA-25% (3min)
  Recast: 300
  Duration: 180
  Job: DRK
  Level: 1
```

**Fields Shown:**

- **Type:** Ability type (Job Ability, Pet Command, etc.)
- **Description:** What the ability does
- **Recast:** Recast time in seconds
- **Duration:** Effect duration in seconds
- **Effect:** Additional effect details
- **Range:** Ability range
- **Radius:** AoE radius if applicable
- **Cost:** TP/MP cost if applicable
- **Job:** Job that can use this
- **Level:** Level required
- **Category:** Internal category

### Spell Display

```
=== Spell Information ===
Name: Haste
  Type: Enhancing
  Category: Enhancing
  Description: Haste +15% (3min)
  Effect: Increases attack/cast speed
  Duration: 180
  Cast Time: 1.5
  Recast: 20
  MP Cost: 40
  Range: 21
  Target: Ally
  Element: Wind
  Skill: Enhancing Magic
  Job: WHM/RDM
  Level: 40/48
```

**Fields Shown:**

- **Type:** Spell type (Enfeebling, Enhancing, Healing, etc.)
- **Category:** Spell category
- **Description:** What the spell does
- **Effect:** Detailed effect information
- **Duration:** Effect duration in seconds
- **Cast Time:** Base cast time in seconds
- **Recast:** Recast time in seconds
- **MP Cost:** MP required to cast
- **Range:** Spell range (yalms)
- **Target:** Target type (Self, Ally, Enemy, AoE)
- **Element:** Elemental affinity
- **Skill:** Magic skill used
- **Job:** Jobs that can cast
- **Level:** Level required per job

### Weaponskill Display

```
=== Weaponskill Information ===
Name: Torcleaver
  Type: Physical
  Description: 4-hit Great Axe WS, Light+Fusion
  Skill Chain: Light, Fusion
  Element: Light
  Damage Type: Slashing
  TP Modifier: fTP scales with TP
  FTP: 1.0/3.0/5.5
  Range: Melee
  Weapon Type: Great Axe
  Primary Mod: VIT 80%
  Secondary Mod: STR 80%
```

**Fields Shown:**

- **Type:** WS type (Physical, Magical, Hybrid)
- **Description:** What the WS does
- **Skill Chain:** Skillchain properties
- **Element:** Elemental affinity
- **Damage Type:** Physical damage type
- **TP Modifier:** How TP affects damage
- **FTP:** fTP values at 1000/2000/3000 TP
- **Range:** WS range
- **Weapon Type:** Required weapon
- **Primary/Secondary/Tertiary Mod:** Stat modifiers

---

## Color Codes

**Headers:**

- Cyan (207): Section headers
- Yellow (50): Job Abilities
- Cyan (205): Spells
- Yellow (50): Weaponskills

**Fields:**

- Gray (160): Field labels
- Various colors for values based on data type:
 - Info (158): General information
 - Success (158): Positive effects
 - Warning (57/206): Costs/penalties
 - Cooldown (125): Recast timers
 - Spell (205): Spell-specific data

---

## Error Messages

### Not Found

```
[INFO] Not found: Invalid Name
[INFO] Searched: Job Abilities, Spells, Weaponskills
```

**Possible Reasons:**

- Typo in name
- Ability/Spell/WS doesn't exist in databases
- Database not loaded (check for errors)

### Usage Error

```
[INFO] Usage: //gs c info <name>
[INFO] Example: //gs c info Last Resort
[INFO] Example: //gs c info Haste
[INFO] Example: //gs c info Torcleaver
```

**Shown when:** Command called without arguments

---

## Technical Details

### Search Order

1. **Job Abilities Database**
 - Checks `DataLoader.get_ability(name)`
 - Sources from all 21 job databases
 - Returns immediately if found

2. **Spell Database**
 - Checks `DataLoader.get_spell(name)`
 - Sources from 6 skill + 8 job databases
 - Returns immediately if found

3. **Weaponskill Database**
 - Checks `DataLoader.get_weaponskill(name)`
 - Sources from 13 weapon type databases
 - Returns immediately if found

### Text Sanitization

All output is sanitized for FFXI chat (ASCII only):

```lua
-- Removes non-ASCII characters (keep only 32-126)
text = text:gsub("[^\32-\126]", "")

-- Converts common Unicode to ASCII equivalents
"'" >> "'" (smart quote to regular)
""" >> '"' (smart double quotes)
"—" >> "-" (em/en dash to hyphen)
"…" >> "..." (ellipsis to three dots)
```

### Data Structure

**Job Abilities:**

```lua
{
    description = "ATK/ACC+25%, DEF/EVA-25% (3min)",
    level = 1,
    recast = 300,
    duration = 180,
    job = "DRK",
    type = "Job Ability"
}
```

**Spells:**

```lua
{
    description = "Haste +15% (3min)",
    category = "Enhancing",
    type = "Enhancing",
    cast_time = 1.5,
    recast = 20,
    mp_cost = 40,
    duration = 180,
    range = 21,
    target = "Ally",
    element = "Wind",
    skill = "Enhancing Magic",
    job = "WHM/RDM",
    level = "40/48"
}
```

**Weaponskills:**

```lua
{
    description = "4-hit Great Axe WS, Light+Fusion",
    type = "Physical",
    skillchain = "Light, Fusion",
    element = "Light",
    damage_type = "Slashing",
    tp_modifier = "fTP scales with TP",
    ftp = "1.0/3.0/5.5",
    range = "Melee",
    weapon = "Great Axe",
    primary_mod = "VIT 80%",
    secondary_mod = "STR 80%"
}
```

---

## Integration

### Files Created

**New Module:**

- `shared/utils/commands/info_command.lua` (360 lines)

### Files Modified

**Command Handler:**

- `shared/utils/core/COMMON_COMMANDS.lua`
 - Added `handle_info()` function
 - Added routing in `handle_command()`
 - Added to `is_common_command()` check

### Dependencies

**Required Modules:**

- `shared/utils/data/data_loader.lua` - Data access layer
- `shared/utils/messages/message_core.lua` - Color utilities
- `shared/utils/messages/message_colors.lua` - Color definitions

**Data Sources:**

- `shared/data/job_abilities/` - JA databases
- `shared/data/magic/` - Spell databases
- `shared/data/weaponskills/` - WS databases

---

## Performance

### Startup Impact

 **Zero startup lag** - Command loads on first use only

### First Query

- Loads `info_command.lua` module (~10ms)
- Loads required databases via DataLoader (50-300ms depending on type)
- Displays formatted output

### Subsequent Queries

- Module already loaded (instant)
- Databases cached in `_G.FFXI_DATA` (instant)
- Only formatting cost (~1-2ms)

### Memory Usage

- Module: ~15KB
- Cached databases loaded as needed:
 - Job Abilities: ~50KB (300+ abilities)
 - Spells: ~200KB (1,100+ spells)
 - Weaponskills: ~80KB (212 weaponskills)

---

## Examples

### Job Ability Examples

```bash
# DRK Abilities
//gs c info Last Resort
//gs c info Blood Weapon
//gs c info Dark Seal

# WAR Abilities
//gs c info Berserk
//gs c info Warcry
//gs c info Mighty Strikes

# PLD Abilities
//gs c info Sentinel
//gs c info Rampart
//gs c info Invincible
```

### Spell Examples

```bash
# Enhancing
//gs c info Haste
//gs c info Refresh
//gs c info Protect V

# Enfeebling
//gs c info Dia III
//gs c info Slow II
//gs c info Paralyze

# Healing
//gs c info Cure IV
//gs c info Curaga III

# Elemental
//gs c info Fire IV
//gs c info Blizzard VI

# BRD Songs
//gs c info Victory March
//gs c info Minuet V
```

### Weaponskill Examples

```bash
# Great Axe
//gs c info Torcleaver
//gs c info Steel Cyclone

# Great Sword
//gs c info Scourge
//gs c info Ground Strike

# Great Katana
//gs c info Tachi: Fudo
//gs c info Tachi: Shoha

# H2H
//gs c info Victory Smite
//gs c info Shijin Spiral
```

---

## Limitations

### Case Sensitivity

- Names are case-sensitive
- Use exact spelling: "Last Resort" not "last resort"

### Multi-word Names

- Spaces must be included: "Last Resort" not "LastResort"
- System automatically joins arguments: `info Last Resort` = "Last Resort"

### Partial Matches

- No partial matching (yet)
- Must type full name
- Future: Could add fuzzy search

### Missing Data

- Only displays fields that exist in database
- Some older abilities may have limited data
- WS fTP values may be approximate

---

## Future Enhancements

### Potential Features

1. **Fuzzy Search:** Match partial names
2. **Aliases:** Support common abbreviations
3. **Related Items:** Show similar abilities/spells
4. **Comparison:** Compare multiple items
5. **Search by Category:** List all spells of a type
6. **Export:** Save query results to file

### Database Improvements

1. Add missing fields to older entries
2. Verify all numerical values
3. Add more descriptive text
4. Include potency values where available

---

## Status

 **COMPLETE** - Info command fully functional and integrated

**Tested:**

- Job Abilities from multiple jobs
- Spells from all categories
- Weaponskills from various weapon types
- Multi-word names
- Error handling
- Color formatting
- ASCII sanitization

**Ready for use in all character files**

# Job Ability Database System

## Overview

Centralized database system for Job Ability descriptions used across all job PRECAST modules. Provides consistent, maintainable ability messaging following the same architecture as `SPELL_DATABASE` modules.

## Architecture

```
shared/data/job_abilities/
├── UNIVERSAL_JA_DATABASE.lua  # AUTO-MERGED universal database (all jobs)
├── BLM_JA_DATABASE.lua        # Black Mage
├── BLU_JA_DATABASE.lua        # Blue Mage
├── BRD_JA_DATABASE.lua        # Bard
├── BST_JA_DATABASE.lua        # Beastmaster
├── COR_JA_DATABASE.lua        # Corsair
├── DNC_JA_DATABASE.lua        # Dancer
├── DRG_JA_DATABASE.lua        # Dragoon
├── DRK_JA_DATABASE.lua        # Dark Knight
├── GEO_JA_DATABASE.lua        # Geomancer
├── MNK_JA_DATABASE.lua        # Monk
├── NIN_JA_DATABASE.lua        # Ninja
├── PLD_JA_DATABASE.lua        # Paladin
├── PUP_JA_DATABASE.lua        # Puppetmaster
├── RDM_JA_DATABASE.lua        # Red Mage
├── RNG_JA_DATABASE.lua        # Ranger
├── RUN_JA_DATABASE.lua        # Rune Fencer
├── SAM_JA_DATABASE.lua        # Samurai
├── SCH_JA_DATABASE.lua        # Scholar
├── THF_JA_DATABASE.lua        # Thief
├── WAR_JA_DATABASE.lua        # Warrior
├── WHM_JA_DATABASE.lua        # White Mage
└── README.md                  # This file
```

**Total**: 300+ abilities across 21 jobs, auto-merged into universal database

## Usage Pattern

### Universal Database (RECOMMENDED)

**All PRECAST modules use the universal database for main + subjob support.**

```lua
-- shared/jobs/job/functions/JOB_PRECAST.lua

-- Load universal database (supports main job + subjob abilities)
local JA_DB = require('shared/data/job_abilities/UNIVERSAL_JA_DATABASE')

function job_precast(spell, action, spellMap, eventArgs)
    -- ... debuff guard, cooldown check ...

    -- ==========================================================================
    -- JOB ABILITIES MESSAGES (universal - supports main + subjob)
    -- ==========================================================================
    if spell.type == 'JobAbility' and JA_DB[spell.english] then
        MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english])
    end

    -- ... rest of precast logic ...
end
```

**Example**: WAR/SAM will display messages for both WAR abilities (Berserk, Warcry) AND SAM abilities (Third Eye, Hasso) because UNIVERSAL_JA_DATABASE contains all 140 abilities.

### Individual Database Structure

**Individual databases are maintained separately for easy editing:**

```lua
-- shared/data/job_abilities/JOB_JA_DATABASE.lua
local JOB_JA_DATABASE = {
    ['Ability Name'] = "Brief description (max ~50 chars)",
    ['Another Ability'] = "Description here",
    -- ...
}

return JOB_JA_DATABASE
```

### Auto-Merge Mechanism

**UNIVERSAL_JA_DATABASE.lua automatically merges all individual databases at runtime:**

```lua
local UNIVERSAL_JA_DB = {}

local jobs = {
    'BLM', 'BRD', 'COR', 'DNC', 'DRG', 'DRK',
    'GEO', 'PLD', 'SAM', 'THF', 'WAR', 'WHM'
}

for _, job in ipairs(jobs) do
    local success, job_db = pcall(require, 'shared/data/job_abilities/' .. job .. '_JA_DATABASE')
    if success and job_db then
        for ability_name, description in pairs(job_db) do
            UNIVERSAL_JA_DB[ability_name] = description
        end
    end
end

return UNIVERSAL_JA_DB
```

**Benefits**:

- **Subjob Support**: WAR/SAM sees both WAR and SAM abilities
- **Easy Maintenance**: Edit individual databases, universal auto-updates
- **Safe Loading**: Uses pcall() to gracefully handle missing databases

## Description Guidelines

1. **Length**: Keep descriptions under 50 characters to avoid line wrapping in FFXI chat
2. **Clarity**: Be concise but precise
3. **Format**: Use symbols (`+`, `-`, `%`, `>>`) for brevity
4. **Decay**: Use `decay to` for abilities with progressive effects (e.g., "Physical damage -90% decay to -50%")
5. **Consistency**: Match existing database style

### Good Examples

```lua
['Sentinel'] = "Physical damage -90% decay to -50%, +enmity"  -- Shows progression
['Berserk'] = "Attack +25%, defense -25%"                      -- Clear trade-off
['Steal'] = "Steal items from enemy"                           -- Simple, direct
['Feint'] = "Enemy evasion -150 decay to -50"                  -- Progressive debuff
```

### Bad Examples

```lua
['Sentinel'] = "Reduces physical damage taken and increases enmity"  -- Too long
['Berserk'] = "+25% ATK, -25% DEF"                                   -- Inconsistent abbreviations
['Steal'] = "You can steal things"                                   -- Vague
```

## Adding New Abilities

1. Add entry to appropriate **individual** `JOB_JA_DATABASE.lua`:

   ```lua
   ['New Ability'] = "Brief description here"
   ```

2. **No changes needed** to UNIVERSAL_JA_DATABASE.lua - auto-merges at runtime

3. **No changes needed** to PRECAST modules - already using universal database

4. Reload GearSwap in-game (`//lua reload gearswap`)

5. Test in-game to verify description length and accuracy

**Example**: Adding new WAR ability

```lua
-- Edit: shared/data/job_abilities/WAR_JA_DATABASE.lua
['New Ability'] = "Brief description"

-- UNIVERSAL_JA_DATABASE automatically includes it
-- WAR_PRECAST.lua automatically displays it
-- Any job with /WAR subjob also sees it
```

## Benefits

- **Separation of Concerns**: Data separated from logic
- **Easy Maintenance**: Update descriptions in individual databases, universal auto-updates
- **Subjob Support**: WAR/SAM displays both WAR and SAM abilities automatically
- **Reusability**: Other modules can query ability descriptions
- **Consistency**: Matches existing `SPELL_DATABASE` architecture (individual + universal pattern)
- **Scalability**: Easy to add new jobs/abilities (edit individual database only)
- **Code Reduction**: ~200 lines of hardcoded if/elseif >> ~30 lines across 12 jobs (85% reduction)
- **Safe Loading**: pcall() ensures missing databases don't break system

## Related Systems

- **SPELL_DATABASE**: `shared/data/magic/JOB_SPELL_DATABASE.lua`
- **MessageFormatter**: `shared/utils/messages/message_formatter.lua`
- **PRECAST Modules**: `shared/jobs/*/functions/*_PRECAST.lua`

## Version History

- **1.0** (2025-10-29): Initial creation with 10 individual databases
- **2.0** (2025-10-29): Added UNIVERSAL_JA_DATABASE with auto-merge pattern for subjob support
- **2.1** (2025-10-29): Added DRG_JA_DATABASE
- **2.2** (2025-10-29): Added DNC_JA_DATABASE
- **3.0** (2025-11-01): Expanded to 21 jobs (added BLU, BST, MNK, NIN, PUP, RNG, RUN, SCH) - 300+ abilities

---

**Maintainer**: Tetsouo
**Last Updated**: 2025-11-01

## Technical Notes

### Why Universal + Individual Pattern?

Following the same architecture as `SPELL_DATABASE`:

1. **Individual databases** remain for easy editing (one file per job, ~10-15 abilities each)
2. **Universal database** auto-merges all at runtime for subjob support
3. **PRECAST modules** use only universal database (main + subjob abilities)

### Performance

- Auto-merge happens once at module load time (negligible overhead)
- Runtime lookups are O(1) hash table access
- No performance difference vs hardcoded if/elseif blocks

### Adding New Jobs

To add a new job (e.g., NIN):

1. Create `shared/data/job_abilities/NIN_JA_DATABASE.lua`
2. Add 'NIN' to jobs table in `UNIVERSAL_JA_DATABASE.lua`
3. All PRECAST modules automatically support NIN abilities

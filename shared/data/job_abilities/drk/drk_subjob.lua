---============================================================================
--- DRK Job Abilities - Sub-Job Accessible Module
---============================================================================
--- Dark Knight abilities accessible as subjob (5 total)
---
--- Contents:
---   - Arcane Circle (Lv5) - Party resistance vs Arcana
---   - Last Resort (Lv15) - ATK up, DEF down
---   - Weapon Bash (Lv20) - Stun attack
---   - Souleater (Lv30) - HP to damage conversion
---   - Consume Mana (Lv55) - MP to damage (Master Job Only)
---
--- @file drk_subjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @updated 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Dark_Knight
---============================================================================

local DRK_SUBJOB = {}

DRK_SUBJOB.abilities = {
    ['Arcane Circle'] = {
        description = 'ATK/DEF+ vs Arcana (party AoE)',
        level = 5,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Last Resort'] = {
        description = 'ATK+25% DEF-25% (3min)',
        level = 15,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Weapon Bash'] = {
        description = 'Stun attack',
        level = 20,
        recast = 300,  -- 5 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Souleater'] = {
        description = 'HP → damage, ACC+25 (1min)',
        level = 30,
        recast = 360,  -- 6 minutes
        main_job_only = false,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Consume Mana'] = {
        description = 'All MP → damage (1 per 10 MP)',
        level = 55,
        recast = 180,  -- 3 minutes
        main_job_only = false,  -- Requires Master Levels for subjob
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DRK_SUBJOB

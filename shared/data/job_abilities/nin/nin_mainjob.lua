---============================================================================
--- NIN Job Abilities - Main Job Only Module
---============================================================================
--- Ninja abilities restricted to main job (5 total)
---
--- Contents:
---   - Yonin (Lv40) - +Enmity/EVA, -ACC (5min)
---   - Innin (Lv40) - -Enmity/EVA, +Ninjutsu/Crit from behind (5min)
---   - Sange (Lv75 Merit) - Daken 100%, consume shuriken
---   - Futae (Lv77) - Next elemental ninjutsu +50% (2 tools)
---   - Issekigan (Lv95) - Parry rate+, enmity on parry
---
--- @file nin_mainjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Ninja
---============================================================================

local NIN_MAINJOB = {}

NIN_MAINJOB.abilities = {
    ['Yonin'] = {
        description = '+Enmity/EVA, -ACC (5min)',
        level = 40,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Innin'] = {
        description = '-Enmity/EVA, +Ninjutsu/Crit from behind (5min)',
        level = 40,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Sange'] = {
        description = 'Daken 100%, consume shuriken',
        level = 75,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Futae'] = {
        description = 'Next elemental ninjutsu +50% (2 tools)',
        level = 77,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Issekigan'] = {
        description = 'Parry rate+, enmity on parry',
        level = 95,
        recast = 300,  -- 5 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 1200
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return NIN_MAINJOB

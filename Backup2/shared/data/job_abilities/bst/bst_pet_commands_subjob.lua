---============================================================================
--- BST Pet Commands - Sub-Job Accessible Module
---============================================================================
--- Beastmaster pet commands accessible as subjob (5 total)
---
--- Contents:
---   - Fight (Lv1) - Pet attacks target
---   - Heel (Lv10) - Pet returns to master
---   - Stay (Lv15) - Pet holds position
---   - Sic (Lv25) - Pet uses random TP move
---   - Leave (Lv35) - Dismiss pet
---
--- @file bst_pet_commands_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Beastmaster
---============================================================================

local BST_PET_COMMANDS_SUBJOB = {}

BST_PET_COMMANDS_SUBJOB.abilities = {
    ['Fight'] = {
        description             = 'Pet attacks target',
        level                   = 1,
        recast                  = 0,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Heel'] = {
        description             = 'Pet returns to master',
        level                   = 10,
        recast                  = 0,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Stay'] = {
        description             = 'Pet holds position',
        level                   = 15,
        recast                  = 0,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Sic'] = {
        description             = 'Pet uses random TP move',
        level                   = 25,
        recast                  = 90,  -- 90s (base)
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Leave'] = {
        description             = 'Dismiss pet',
        level                   = 35,
        recast                  = 0,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BST_PET_COMMANDS_SUBJOB

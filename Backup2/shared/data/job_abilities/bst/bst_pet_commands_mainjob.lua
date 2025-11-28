---============================================================================
--- BST Pet Commands - Main Job Only Module
---============================================================================
--- Beastmaster pet commands restricted to main job (4 total)
---
--- Contents:
---   - Ready (Lv25) - Pet uses selected TP move (charge system)
---   - Snarl (Lv45) - Transfer 99% enmity to pet
---   - Spur (Lv83) - Pet Store TP +20
---   - Run Wild (Lv93) - Pet stats +25%, pet vanishes after
---
--- @file bst_pet_commands_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Beastmaster
---============================================================================

local BST_PET_COMMANDS_MAINJOB = {}

BST_PET_COMMANDS_MAINJOB.abilities = {
    ['Ready'] = {
        description             = 'Pet uses selected TP move (charge system)',
        level                   = 25,
        recast                  = 30,  -- 30s per charge (base)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Snarl'] = {
        description             = 'Transfer 99% enmity to pet',
        level                   = 45,
        recast                  = 30,  -- 30s
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Spur'] = {
        description             = 'Pet Store TP +20',
        level                   = 83,
        recast                  = 180,  -- 3min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Run Wild'] = {
        description             = 'Pet stats +25%, pet vanishes after',
        level                   = 93,
        recast                  = 900,  -- 15min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BST_PET_COMMANDS_MAINJOB

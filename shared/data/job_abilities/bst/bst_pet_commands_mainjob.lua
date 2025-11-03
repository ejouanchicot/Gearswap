---============================================================================
--- BST Pet Commands - Main Job Only Module
---============================================================================
--- Beastmaster pet commands restricted to main job (4 total)
---
--- Contents:
---   - Ready (Lv25) - Pet uses selected TP move (charge system)
---   - Snarl (Lv45) - Transfer 99% enmity to pet
---   - Spur (Lv83) - Pet Store TP +20 (90s)
---   - Run Wild (Lv93) - Pet stats +25%, pet vanishes after (5min)
---
--- @file bst_pet_commands_mainjob.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Beastmaster
---============================================================================

local BST_PET_COMMANDS_MAINJOB = {}

BST_PET_COMMANDS_MAINJOB.abilities = {
    ['Ready'] = {
        description = 'Pet uses selected TP move (charge system)',
        level = 25,
        recast = 30,  -- 30 seconds per charge (base)
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Snarl'] = {
        description = 'Transfer 99% enmity to pet',
        level = 45,
        recast = 30,  -- 30 seconds
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Spur'] = {
        description = 'Pet Store TP +20 (90s)',
        level = 83,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Run Wild'] = {
        description = 'Pet stats +25%, pet vanishes after (5min)',
        level = 93,
        recast = 900,  -- 15 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BST_PET_COMMANDS_MAINJOB

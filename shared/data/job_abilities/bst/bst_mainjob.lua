---============================================================================
--- BST Job Abilities - Main Job Only Module
---============================================================================
--- Beastmaster abilities restricted to main job (2 total)
---
--- Contents:
---   - Feral Howl (Lv75 Merit) - Terrorize target
---   - Killer Instinct (Lv75 Merit) - Grant pet's killer trait to party
---
--- @file bst_mainjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Beastmaster
---============================================================================

local BST_MAINJOB = {}

BST_MAINJOB.abilities = {
    ['Feral Howl'] = {
        description             = 'Terrorize target',
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Killer Instinct'] = {
        description             = "Grant pet's killer trait to party",
        level                   = 75,
        recast                  = 300,  -- 5min
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BST_MAINJOB

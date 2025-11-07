---============================================================================
--- BST Job Abilities - SP Abilities Module
---============================================================================
--- Beastmaster special abilities (2 SP total)
---
--- Contents:
---   - Familiar (SP1, Lv1) - Pet powers enhanced (30min)
---   - Unleash (SP2, Lv96) - Charm 95% success, no recast Sic/Ready (1min)
---
--- @file bst_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Beastmaster
--- @source https://www.bg-wiki.com/ffxi/Familiar
--- @source https://www.bg-wiki.com/ffxi/Unleash
---============================================================================

local BST_SP = {}

BST_SP.abilities = {
    ['Familiar'] = {
        description             = "Pet powers enhanced (30min)",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Unleash'] = {
        description             = "Charm 95% success, Sic/Ready no recast (1min)",
        level                   = 96,
        recast                  = 3600,  -- 1hr (SP2)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BST_SP

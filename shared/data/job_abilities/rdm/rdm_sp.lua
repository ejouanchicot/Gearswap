---============================================================================
--- RDM Job Abilities - SP Abilities Module
---============================================================================
--- Red Mage special abilities (2 SP total)
---
--- Contents:
---   - Chainspell (SP1, Lv1) - Rapid spellcasting (1min)
---   - Stymie (SP2, Lv96) - Next enfeebling 100% MACC (1min)
---
--- @file rdm_sp.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Red_Mage
--- @source https://www.bg-wiki.com/ffxi/Chainspell
--- @source https://www.bg-wiki.com/ffxi/Stymie
---============================================================================

local RDM_SP = {}

RDM_SP.abilities = {
    ['Chainspell'] = {
        description             = "Rapid spellcasting (1min)",
        level                   = 1,
        recast                  = 3600,  -- 1hr (SP1)
        main_job_only           = true,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    },
    ['Stymie'] = {
        description             = "Next enfeebling 100% MACC (1min)",
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

return RDM_SP

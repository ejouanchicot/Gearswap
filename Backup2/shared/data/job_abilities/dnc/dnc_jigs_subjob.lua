---============================================================================
--- DNC Job Abilities - Jigs (Sub-Job Accessible)
---============================================================================
--- Dancer jigs accessible as subjob (1 jig, Lv25)
---
--- @file dnc_jigs_subjob.lua
--- @author Tetsouo
--- @version 1.1 - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Dancer
---============================================================================

local DNC_JIGS_SUBJOB = {}

DNC_JIGS_SUBJOB.abilities = {
    ['Spectral Jig'] = {
        description             = "Sneak + Invisible",
        level                   = 25,
        recast                  = 30,
        main_job_only           = false,
        cumulative_enmity       = 0,
        volatile_enmity         = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNC_JIGS_SUBJOB

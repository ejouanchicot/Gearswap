---============================================================================
--- THF Macrobook Configuration - Macro Book & Page Assignment
---============================================================================
--- Defines macro book and page selections for Thief job with subjob-specific
--- assignments.
---
--- Features:
---   • Solo configurations: Playing THF alone
---   • Dual-boxing configurations: Playing THF with an alt character
---   • Subjob-specific macro book and page assignments
---   • Default fallback for unconfigured subjobs
---   • Easy customization without modifying core job files
---   • Automatic application via MacrobookManager factory
---
--- Usage:
---   • Each subjob can have unique book/page combination
---   • Default fallback ensures all subjobs have valid macro setup
---   • Book/page values correspond to in-game macro system
---
--- Dependencies:
---   • MacrobookManager (factory that uses this configuration)
---
--- @file    config/thf/THF_MACROBOOK.lua
--- @author  Kaories
--- @version 2.0 - Dual-boxing support
--- @date    Created: 2025-10-06 | Updated: 2025-10-22
---============================================================================

local THFMacroConfig = {}

-- Default macro book (used if subjob not configured)
THFMacroConfig.default = { book = 1, page = 1 }

-- Macrobooks per subjob
THFMacroConfig.solo = {
    ['DNC'] = { book = 1, page = 1 },  -- THF/DNC → Book 23, Page 1
    ['NIN'] = { book = 1, page = 1 },  -- THF/NIN → Book 23, Page 2
    ['WAR'] = { book = 1, page = 1 },  -- THF/WAR → Book 23, Page 3

    -- Default fallback
    ['default'] = { book = 1, page = 1 }
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing THF + Alt)
---============================================================================

THFMacroConfig.dualbox = {
    -- Kaories playing RDM
    ['RDM'] = {
        ['WAR'] = {book = 1, page = 1}, -- THF/WAR + RDM alt
        ['DNC'] = {book = 1, page = 1}, -- THF/DNC + RDM alt
        ['NIN'] = {book = 1, page = 1}, -- THF/NIN + RDM alt
    },

    -- Kaories playing GEO
    ['GEO'] = {
        ['WAR'] = {book = 2, page = 1}, -- THF/WAR + GEO alt
        ['DNC'] = {book = 2, page = 1}, -- THF/DNC + GEO alt
        ['NIN'] = {book = 2, page = 1}, -- THF/NIN + GEO alt
    },

    -- Kaories playing COR
    ['COR'] = {
        ['WAR'] = {book = 3, page = 1}, -- THF/WAR + COR alt
        ['DNC'] = {book = 3, page = 1}, -- THF/DNC + COR alt
        ['NIN'] = {book = 3, page = 1}, -- THF/NIN + COR alt
    }
}

return THFMacroConfig

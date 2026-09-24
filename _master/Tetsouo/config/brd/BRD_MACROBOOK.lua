---============================================================================
--- BRD Macrobook Configuration
---============================================================================
--- Defines macrobook and page assignments for Bard job, per subjob and
--- per dual-box alt job.
---
--- @file Tetsouo/config/brd/BRD_MACROBOOK.lua
--- @author Tetsouo
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-13 | Updated: 2025-10-22
---============================================================================

local BRDMacroConfig = {}

-- Default macrobook (used if no subjob config)
BRDMacroConfig.default = {book = 40, page = 1}

-- Macrobook per subjob; unlisted subjobs use the default
BRDMacroConfig.solo = {
    ['DNC'] = {book = 7, page = 1}, -- Bard/Dancer (steps + songs)
    ['SCH'] = {book = 8, page = 1}, -- Bard/Scholar
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing BRD + Alt)
--- Structure: dualbox[ALT_JOB][YOUR_SUBJOB] = {book, page}, used while the
--- alt is online on ALT_JOB; otherwise the solo table applies.
---============================================================================

BRDMacroConfig.dualbox = {
    ['GEO'] = {
        ['SCH'] = {book = 8, page = 8},
        ['DNC'] = {book = 7, page = 8},
    },
    ['COR'] = {
        ['SCH'] = {book = 8, page = 5},
        ['DNC'] = {book = 7, page = 5}
    },
}

return BRDMacroConfig

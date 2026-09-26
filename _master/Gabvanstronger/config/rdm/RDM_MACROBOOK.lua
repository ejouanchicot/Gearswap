---============================================================================
--- RDM Macrobook - Gabvanstronger (BindManager: book 3; page by subjob)
---============================================================================
--- From his BindManager macrobooks.lua (Gabvanstronger.RDM): book 3 page 1,
--- the subjob changing only the page (NIN 2, SCH 3, BLM 4, DRK 2, WHM 1).
---
--- @file    config/rdm/RDM_MACROBOOK.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local RDMMacroConfig = {}

-- Default macrobook settings (used if no subjob match)
RDMMacroConfig.default = {book = 3, page = 1}

-- Macrobook settings per subjob
RDMMacroConfig.solo = {
    ['NIN'] = {book = 3, page = 2},
    ['SCH'] = {book = 3, page = 3},
    ['BLM'] = {book = 3, page = 4},
    ['DRK'] = {book = 3, page = 2},
    ['WHM'] = {book = 3, page = 1},
}

RDMMacroConfig.dualbox = {}

return RDMMacroConfig

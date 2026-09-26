---============================================================================
--- THF Macrobook - Gabvanstronger (BindManager: book 6; page by subjob)
---============================================================================
--- From his BindManager macrobooks.lua (Gabvanstronger.THF): book 6 page 1,
--- the subjob changing only the page (DNC 2, WAR 3, NIN 4).
---
--- @file    config/thf/THF_MACROBOOK.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

local THFMacroConfig = {}

-- Default macrobook settings (used if no subjob match)
THFMacroConfig.default = {book = 6, page = 1}

-- Macrobook settings per subjob
THFMacroConfig.solo = {
    ['DNC'] = {book = 6, page = 2},
    ['WAR'] = {book = 6, page = 3},
    ['NIN'] = {book = 6, page = 4},
}

THFMacroConfig.dualbox = {}

return THFMacroConfig

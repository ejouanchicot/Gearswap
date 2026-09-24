---============================================================================
--- BST Macrobook Configuration
---============================================================================
--- Macro book configuration for Beastmaster job (per subjob).
--- Used by MacrobookManager factory.
---
--- @file Tetsouo/config/bst/BST_MACROBOOK.lua
--- @author Tetsouo
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-17 | Updated: 2025-10-22
---============================================================================

local BSTMacroConfig = {}

---============================================================================
--- MACRO CONFIGURATION
---============================================================================

--- Default macro book and page (used if no subjob-specific config)
BSTMacroConfig.default = {
    book = 12,
    page = 1
}

--- Macro books per subjob (optional)
--- Format: ['SUBJOB_CODE'] = {book = number, page = number}
BSTMacroConfig.solo = {
    ['SAM'] = {book = 11, page = 1},
    ['NIN'] = {book = 11, page = 1},
    ['DNC'] = {book = 11, page = 1},
    ['WHM'] = {book = 11, page = 1},
    ['RDM'] = {book = 11, page = 1},
    ['BLU'] = {book = 11, page = 1}
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing BST + Alt)
---============================================================================
--- Structure: dualbox[ALT_JOB][SUBJOB] = {book, page}
--- Example: dualbox['GEO']['SAM'] = BST/SAM macros optimized for playing with GEO alt
---
--- Used while the alt is online on ALT_JOB; otherwise the solo table applies.
---============================================================================

BSTMacroConfig.dualbox = {
    ['RDM'] = {
        ['DNC'] = {book = 11, page = 1}
    },
    ['COR'] = {
        ['DNC'] = {book = 11, page = 4}
    },
    ['GEO'] = {
        ['DNC'] = {book = 11, page = 8}
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return BSTMacroConfig

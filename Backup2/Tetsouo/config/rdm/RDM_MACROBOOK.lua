---============================================================================
--- RDM Macrobook Configuration
---============================================================================
--- Defines macrobook pages for Red Mage based on subjob.
---
--- @file config/rdm/RDM_MACROBOOK.lua
--- @author Tetsouo
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-12 | Updated: 2025-10-22
---============================================================================

local RDMMacroConfig = {}

-- Default macrobook settings (used if no subjob match)
RDMMacroConfig.default = {book = 2, page = 1}

-- Macrobook settings per subjob
RDMMacroConfig.solo = {
    ['NIN'] = {book = 2, page = 1},  -- RDM/NIN - Dualwield melee
    ['WHM'] = {book = 2, page = 1},  -- RDM/WHM - Support/healing
    ['BLM'] = {book = 2, page = 1},  -- RDM/BLM - Nuking
    ['SCH'] = {book = 2, page = 1},  -- RDM/SCH - Hybrid magic
    ['DNC'] = {book = 2, page = 1},  -- RDM/DNC - Melee/support
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing RDM + Alt)
---============================================================================

RDMMacroConfig.dualbox = {
    -- Uncomment to add dual-boxing configurations
    -- ['GEO'] = {
    --     ['NIN'] = { book = XX, page = 1 },
    --     ['WHM'] = { book = XX, page = 2 },
    -- },
    --
    -- ['COR'] = {
    --     ['NIN'] = { book = XX, page = 1 },
    -- },
}

return RDMMacroConfig

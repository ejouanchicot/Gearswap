---============================================================================
--- COR Macrobook Configuration
---============================================================================
--- User-configurable macro book settings for Corsair job.
--- Configure different macro books/pages by subjob or role.
---
--- @file config/cor/COR_MACROBOOK.lua
--- @author Typioni
--- @version 2.0 - Dual-boxing support
--- @date Created: 2025-10-07 | Updated: 2025-10-22
---============================================================================

local CORMacroConfig = {}

---============================================================================
---============================================================================
--- SOLO CONFIGURATION (Playing COR alone)
---============================================================================
---============================================================================

-- Default macrobook (used if no subjob-specific macrobook is defined)
CORMacroConfig.default = { book = 3, page = 1 }

-- Macrobook by subjob (OPTIONAL)
-- Format: ['SUBJOB'] = { book = X, page = Y }
CORMacroConfig.solo = {
    -- Examples:
    ['DNC'] = { book = 3, page = 1 },  -- COR/DNC
    ['NIN'] = { book = 3, page = 1 },  -- COR/NIN
    ['WAR'] = { book = 3, page = 1 },  -- COR/WAR
    ['SAM'] = { book = 3, page = 1 },  -- COR/SAM
}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing COR + Alt)
---============================================================================

CORMacroConfig.dualbox = {
    -- Uncomment to add dual-boxing configurations
    -- ['GEO'] = {
    --     ['DNC'] = { book = XX, page = 1 },
    --     ['NIN'] = { book = XX, page = 2 },
    -- },
    --
    -- ['WHM'] = {
    --     ['DNC'] = { book = XX, page = 1 },
    -- },
}

---============================================================================
--- HELPER FUNCTION - DO NOT MODIFY
---============================================================================

--- Get macrobook for current subjob
--- @param subjob string Current subjob (DNC, NIN, etc.)
--- @return table Macrobook configuration {book, page}
function CORMacroConfig.get_macrobook(subjob)
    -- Check if subjob-specific macrobook exists
    if CORMacroConfig.solo and CORMacroConfig.solo[subjob] then
        return CORMacroConfig.solo[subjob]
    end

    -- Fallback to default
    return CORMacroConfig.default
end

return CORMacroConfig

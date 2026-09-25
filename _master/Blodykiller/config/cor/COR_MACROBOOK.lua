---============================================================================
--- COR Macrobook - Blodykiller (BindManager: book 2, page 1)
---============================================================================
--- @file    config/cor/COR_MACROBOOK.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local CORMacroConfig = {}

---============================================================================
---============================================================================
--- SOLO CONFIGURATION (Playing COR alone)
---============================================================================
---============================================================================

-- Default macrobook (used if no subjob-specific macrobook is defined)
CORMacroConfig.default = { book = 2, page = 1 }

-- Macrobook by subjob (OPTIONAL)
-- Format: ['SUBJOB'] = { book = X, page = Y }
CORMacroConfig.solo = {}

---============================================================================
--- DUAL-BOXING CONFIGURATION (Playing COR + Alt)
--- Structure: dualbox[ALT_JOB][YOUR_SUBJOB] = {book, page}, used while the
--- alt is online on ALT_JOB; otherwise the solo table applies.
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
--- HELPER FUNCTION (not called: MacrobookManager reads .solo/.default directly)
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

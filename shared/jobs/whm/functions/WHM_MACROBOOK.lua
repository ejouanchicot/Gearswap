---============================================================================
--- WHM Macrobook Module - Factory Pattern Implementation
---============================================================================
--- Uses MacrobookManager factory to provide centralized macrobook management.
--- Eliminates code duplication and ensures consistency across all jobs.
---
--- Configuration loaded from: config/whm/WHM_MACROBOOK.lua
---
--- @file WHM_MACROBOOK.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
--- @requires shared/utils/macrobook/macrobook_manager
---============================================================================

local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create macrobook functions using factory pattern
return MacrobookManager.create(
    'WHM',                              -- job_code
    'config/whm/WHM_MACROBOOK',        -- config_path
    'RDM',                              -- default_subjob
    11,                                  -- default_book (from Timara: book 11)
    1                                    -- default_page (from Timara: page 1)
)

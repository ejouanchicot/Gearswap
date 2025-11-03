---============================================================================
--- BRD Macrobook Module - Factory Pattern
---============================================================================
--- Applies macrobook using centralized MacrobookManager factory.
--- Macrobook varies by subjob (WHM, RDM, NIN, etc.)
---
--- @file jobs/brd/functions/BRD_MACROBOOK.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

-- Load macrobook factory
local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create BRD macrobook module using factory
return MacrobookManager.create(
    'BRD', -- job_code
    'config/brd/BRD_MACROBOOK', -- config_path
    'WHM', -- default_subjob
    1, -- default_book
    1 -- default_page
)

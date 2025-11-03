---============================================================================
--- SAM Macrobook Module - Factory Usage
---============================================================================
--- Uses MacrobookManager factory to handle macro book operations.
--- @file SAM_MACROBOOK.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

return MacrobookManager.create(
    'SAM',                          -- job_code
    'config/sam/SAM_MACROBOOK',     -- config_path
    'WAR',                          -- default_subjob
    2,                              -- default_book
    1                               -- default_page
)

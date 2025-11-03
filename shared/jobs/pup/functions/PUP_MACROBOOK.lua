---============================================================================
--- PUP Macrobook Module - Macro Book Management (Factory Pattern)
---============================================================================
--- Handles macro book selection and management for Beastmaster job.
--- Uses centralized MacrobookManager factory for consistent behavior.
---
--- Configuration:
---   • Macro definitions: config/pup/PUP_MACROBOOK.lua
---   • Default book: 1, page: 1
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    jobs/pup/functions/PUP_MACROBOOK.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-17
--- @requires utils/macrobook/macrobook_manager
---============================================================================
local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create PUP macrobook module using factory
-- Exports: select_default_macro_book()
return MacrobookManager.create(
    'PUP',                        -- job_code
    'config/pup/PUP_MACROBOOK',   -- config_path
    'SAM',                        -- default_subjob
    1,                            -- default_book
    1                             -- default_page
)

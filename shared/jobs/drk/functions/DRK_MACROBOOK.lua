---============================================================================
--- DRK Macrobook Module - Macro Book Management (Factory Pattern)
---============================================================================
--- Handles macro book selection and management for Dark Knight job.
--- Uses centralized MacrobookManager factory for consistent behavior.
---
--- Configuration:
---   • Macro definitions: config/drk/DRK_MACROBOOK.lua
---   • Default book: 1, page: 1
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    DRK_MACROBOOK.lua
--- @author  Tetsouo
--- @version 1.0.0 - Factory Pattern
--- @date    Created: 2025-10-23
--- @requires utils/macrobook/macrobook_manager
---============================================================================
local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create DRK macrobook module using factory
-- Exports: select_default_macro_book()
return MacrobookManager.create(
    'DRK',                          -- job_code
    'config/drk/DRK_MACROBOOK',     -- config_path
    'SAM',                          -- default_subjob
    1,                              -- default_book
    1                               -- default_page
)

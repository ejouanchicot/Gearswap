---============================================================================
--- BST Macrobook Module - Macro Book Management (Factory Pattern)
---============================================================================
--- Handles macro book selection and management for Beastmaster job.
--- Uses centralized MacrobookManager factory for consistent behavior.
---
--- Configuration:
---   • Macro definitions: config/bst/BST_MACROBOOK.lua
---   • Default book: 1, page: 1
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    jobs/bst/functions/BST_MACROBOOK.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-17
--- @requires utils/macrobook/macrobook_manager
---============================================================================
local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create BST macrobook module using factory
-- Exports: select_default_macro_book()
return MacrobookManager.create(
    'BST',                        -- job_code
    'config/bst/BST_MACROBOOK',   -- config_path
    'SAM',                        -- default_subjob
    1,                            -- default_book
    1                             -- default_page
)

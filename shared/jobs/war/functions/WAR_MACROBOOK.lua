---============================================================================
--- WAR Macrobook Module - Macro Book Management (Factory Pattern)
---============================================================================
--- Handles macro book selection and management for Warrior job.
--- Uses centralized MacrobookManager factory for consistent behavior.
---
--- Configuration:
---   • Macro definitions: config/war/WAR_MACROBOOK.lua
---   • Default book: 22, page: 1
---   • Default subjob: SAM
---   • Automatic subjob-based selection
---
--- @file    jobs/war/functions/WAR_MACROBOOK.lua
--- @author  Tetsouo
--- @version 2.0 - Factory Pattern
--- @date    Created: 2025-09-29
--- @requires utils/macrobook/macrobook_manager
---============================================================================
local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create WAR macrobook module using factory
-- Exports: select_default_macro_book()
return MacrobookManager.create('WAR', -- job_code
'config/war/WAR_MACROBOOK', -- config_path
'SAM', -- default_subjob
22, -- default_book
1 -- default_page
)

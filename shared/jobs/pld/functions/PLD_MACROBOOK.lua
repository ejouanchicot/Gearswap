---============================================================================
--- PLD Macrobook Module - Macro Book Management (Factory Pattern)
---============================================================================
--- Handles macro book selection and management for Paladin job.
--- Uses centralized MacrobookManager factory for consistent behavior.
---
--- Configuration:
---   • Macro definitions: config/pld/PLD_MACROBOOK.lua
---   • Default book: 14, page: 1
---   • Default subjob: RUN
---   • Automatic subjob-based selection
---
--- @file    jobs/pld/functions/PLD_MACROBOOK.lua
--- @author  Tetsouo
--- @version 2.0.0 - Factory Pattern
--- @date    Created: 2025-10-03
--- @requires utils/macrobook/macrobook_manager
---============================================================================
local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create PLD macrobook module using factory
-- Exports: select_default_macro_book()
return MacrobookManager.create('PLD', -- job_code
'config/pld/PLD_MACROBOOK', -- config_path
'RUN', -- default_subjob
14, -- default_book
1 -- default_page
)

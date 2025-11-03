---============================================================================
--- BLM Macrobook Module - Macro Book Management for Black Mage
---============================================================================
--- Handles macro book selection and management for Black Mage job.
--- Uses centralized MacrobookManager factory pattern.
---
--- @file jobs/blm/functions/BLM_MACROBOOK.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
--- @requires utils/macrobook/macrobook_manager
---============================================================================

local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create BLM macrobook module using factory
return MacrobookManager.create(
    'BLM',                          -- job_code
    'config/blm/BLM_MACROBOOK',    -- config_path
    'SCH',                          -- default_subjob (BLM/SCH common)
    1,                              -- default_book
    1                               -- default_page
)

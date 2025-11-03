---============================================================================
--- DNC Macrobook Module - Macro Book Management for Dancer
---============================================================================
--- Handles macro book selection and management for Dancer job.
--- Now uses centralized MacrobookManager factory pattern.
---
--- @file jobs/dnc/functions/DNC_MACROBOOK.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-10-04
--- @requires utils/macrobook/macrobook_manager
---============================================================================

local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create DNC macrobook module using factory
return MacrobookManager.create(
    'DNC',                          -- job_code
    'config/dnc/DNC_MACROBOOK',    -- config_path
    'NIN',                          -- default_subjob
    25,                             -- default_book
    1                               -- default_page
)

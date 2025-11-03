---============================================================================
--- COR Macrobook Module - Macro Book Management for Corsair
---============================================================================
--- Handles macro book selection and management for Corsair job.
--- Uses centralized MacrobookManager factory pattern.
---
--- @file jobs/cor/functions/COR_MACROBOOK.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-07
--- @requires utils/macrobook/macrobook_manager
---============================================================================

local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create COR macrobook module using factory
return MacrobookManager.create(
    'COR',                          -- job_code
    'config/cor/COR_MACROBOOK',    -- config_path
    'DNC',                          -- default_subjob
    1,                              -- default_book
    1                               -- default_page
)

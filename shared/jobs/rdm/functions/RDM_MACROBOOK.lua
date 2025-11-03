---============================================================================
--- RDM Macrobook Module - Macro Book Management for Red Mage
---============================================================================
--- Handles macro book selection and management for Red Mage job.
--- Uses centralized MacrobookManager factory pattern.
---
--- @file jobs/rdm/functions/RDM_MACROBOOK.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
--- @requires utils/macrobook/macrobook_manager
---============================================================================

local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create RDM macrobook module using factory
return MacrobookManager.create(
    'RDM',                          -- job_code
    'config/rdm/RDM_MACROBOOK',    -- config_path
    'NIN',                          -- default_subjob (RDM/NIN common)
    1,                              -- default_book
    1                               -- default_page
)

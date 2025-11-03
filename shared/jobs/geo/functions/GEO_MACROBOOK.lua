---============================================================================
--- GEO Macrobook Module - Macro Book Management for Geomancer
---============================================================================
--- Handles macro book selection and management for Geomancer job.
--- Uses centralized MacrobookManager factory pattern.
---
--- @file jobs/geo/functions/GEO_MACROBOOK.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-09
--- @requires utils/macrobook/macrobook_manager
---============================================================================

local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create GEO macrobook module using factory
return MacrobookManager.create(
    'GEO',                          -- job_code
    'config/geo/GEO_MACROBOOK',    -- config_path
    'WHM',                          -- default_subjob (GEO/WHM common)
    1,                              -- default_book
    1                               -- default_page
)

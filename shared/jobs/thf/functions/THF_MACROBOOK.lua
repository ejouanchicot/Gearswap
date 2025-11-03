---============================================================================
--- THF Macrobook Module - Macro Book Management (Factory Pattern)
---============================================================================
--- Handles macro book and page selection for Thief job using the centralized
--- MacrobookManager factory.
---
--- Features:
---   • Default macro book (23) and page (1)
---   • Subjob-specific book/page overrides (configured in THF_MACROBOOK.lua)
---   • Automatic subjob detection and application
---   • Fallback to default if subjob not configured
---   • Factory pattern (zero duplication across jobs)
---
--- Dependencies:
---   • MacrobookManager (centralized factory)
---   • config/thf/THF_MACROBOOK.lua (macrobook configuration)
---
--- @file    jobs/thf/functions/THF_MACROBOOK.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local MacrobookManager = require('shared/utils/macrobook/macrobook_manager')

-- Create THF macrobook module using factory
return MacrobookManager.create(
    'THF',                          -- job_code
    'config/thf/THF_MACROBOOK',    -- config_path
    'DNC',                          -- default_subjob
    23,                             -- default_book
    1                               -- default_page
)

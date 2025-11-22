---============================================================================
--- BRD Macrobook Module - Macro Book Management (Factory Pattern)
---============================================================================
--- Handles macro book selection and management for Bard job.
--- Uses centralized MacrobookManager factory for consistent behavior.
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Module created on first function call (saves ~45ms at startup)
---
--- Configuration:
---   • Macro definitions: config/brd/BRD_MACROBOOK.lua
---   • Default book: 1, page: 1
---   • Default subjob: WHM
---   • Automatic subjob-based selection
---
--- @file    jobs/brd/functions/BRD_MACROBOOK.lua
--- @author  Tetsouo
--- @version 2.1 - Lazy Loading for performance
--- @date    Created: 2025-10-13 | Updated: 2025-11-15
--- @requires utils/macrobook/macrobook_manager
---============================================================================

-- Lazy loading: Module created on first use
local MacrobookManager = nil
local macrobook_module = nil

local function get_macrobook_module()
    if not macrobook_module then
        if not MacrobookManager then
            MacrobookManager = require('shared/utils/macrobook/macrobook_manager')
        end
        macrobook_module = MacrobookManager.create(
            'BRD',                      -- job_code
            'config/brd/BRD_MACROBOOK', -- config_path
            'WHM',                      -- default_subjob
            1,                          -- default_book
            1                           -- default_page
        )
    end
    return macrobook_module
end

-- Export select_default_macro_book() to global scope
function select_default_macro_book()
    return get_macrobook_module().select_default_macro_book()
end

_G.select_default_macro_book = select_default_macro_book

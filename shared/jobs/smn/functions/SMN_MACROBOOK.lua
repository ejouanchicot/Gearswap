---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Macrobook Module - Factory-backed macrobook management
---  ═══════════════════════════════════════════════════════════════════════════
---   Uses centralized MacrobookManager factory for consistent behavior.
---   Lazy-loaded: module created on first function call.
---
---   @file    shared/jobs/smn/functions/SMN_MACROBOOK.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

local MacrobookManager = nil
local macrobook_module = nil

local function get_macrobook_module()
    if not macrobook_module then
        if not MacrobookManager then
            MacrobookManager = require('shared/utils/macrobook/macrobook_manager')
        end
        macrobook_module = MacrobookManager.create(
            'SMN',                       -- job_code
            'config/smn/SMN_MACROBOOK',  -- config_path
            'WHM',                       -- default_subjob
            1,                           -- default_book
            1                            -- default_page
        )
    end
    return macrobook_module
end

function select_default_macro_book()
    return get_macrobook_module().select_default_macro_book()
end

_G.select_default_macro_book = select_default_macro_book

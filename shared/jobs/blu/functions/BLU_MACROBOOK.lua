---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Macrobook Module - Macro Book Management (Factory Pattern)
---  ═══════════════════════════════════════════════════════════════════════════
---   MacrobookManager factory, built on first call.
---
---   @file    shared/jobs/blu/functions/BLU_MACROBOOK.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---   @requires shared/utils/macrobook/macrobook_manager
---  ═══════════════════════════════════════════════════════════════════════════

local MacrobookManager = nil
local macrobook_module = nil

local function get_macrobook_module()
    if not macrobook_module then
        MacrobookManager = MacrobookManager or require('shared/utils/macrobook/macrobook_manager')
        macrobook_module = MacrobookManager.create(
            'BLU',                       -- job_code
            'config/blu/BLU_MACROBOOK',  -- config_path
            'WAR',                       -- default_subjob
            1,                           -- default_book
            1                            -- default_page
        )
    end
    return macrobook_module
end

--- Select the macro book / page of the current subjob
function select_default_macro_book()
    return get_macrobook_module().select_default_macro_book()
end

_G.select_default_macro_book = select_default_macro_book

return { select_default_macro_book = select_default_macro_book }

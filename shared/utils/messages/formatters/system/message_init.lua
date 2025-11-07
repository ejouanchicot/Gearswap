---============================================================================
--- Init Message Formatter - Module Initialization Messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_init.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageInit = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- MODULE INITIALIZATION MESSAGES
---============================================================================

--- Show system module failed to load error
--- @param module_name string Name of the module (e.g., 'Watchdog', 'Warp System', 'AutoMove')
--- @param error_msg any Error message or object
function MessageInit.show_module_load_failed(module_name, error_msg)
    M.send('INIT', 'module_load_failed', {
        module_name = module_name,
        error_msg = tostring(error_msg)
    })
end

--- Show watchdog failed to load (backward compatibility with INIT_WATCHDOG.lua)
--- @param error_msg any Error message or object
function MessageInit.show_watchdog_load_failed(error_msg)
    M.send('INIT', 'watchdog_load_failed', {error_msg = tostring(error_msg)})
end

--- Show system module loaded successfully
--- @param module_name string Name of the module
function MessageInit.show_module_loaded(module_name)
    M.send('INIT', 'module_loaded', {module_name = module_name})
end

--- Show system initialization complete
function MessageInit.show_init_complete()
    M.send('INIT', 'init_complete')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageInit

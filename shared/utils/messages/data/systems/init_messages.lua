---============================================================================
--- INIT Message Data - Module Initialization Messages
---============================================================================
--- Pure data file for module initialization and loading messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/systems/init_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- MODULE INITIALIZATION MESSAGES
    ---========================================================================

    module_load_failed = {
        template = "{red}[Init] {module_name} not available: {error_msg}",
        color = 167
    },

    watchdog_load_failed = {
        template = "{red}[Watchdog] Failed to load: {error_msg}",
        color = 167
    },

    module_loaded = {
        template = "{green}[Init] {module_name} loaded successfully",
        color = 158
    },

    init_complete = {
        template = "{green}[Init] All systems initialized",
        color = 158
    },
}

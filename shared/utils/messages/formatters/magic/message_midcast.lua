---============================================================================
--- Midcast Message Formatter - MidcastManager Debug Messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_midcast.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageMidcast = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- DEBUG MODE MESSAGES
---============================================================================

--- Show debug mode enabled message
function MessageMidcast.show_debug_enabled()
    M.send('MIDCAST', 'debug_enabled_separator')
    M.send('MIDCAST', 'debug_enabled_title')
    M.send('MIDCAST', 'debug_enabled_separator')
end

--- Show debug mode disabled message
function MessageMidcast.show_debug_disabled()
    M.send('MIDCAST', 'debug_disabled')
end

---============================================================================
--- DEBUG LOGGING MESSAGES
---============================================================================

--- Show debug log message
--- @param message string Debug message
--- @param color number|nil Chat color (ignored in new system, kept for compatibility)
function MessageMidcast.show_debug_log(message, color)
    M.send('MIDCAST', 'debug_log', {message = message})
end

--- Show debug header
--- @param message string Header message
function MessageMidcast.show_debug_header(message)
    M.send('MIDCAST', 'debug_header_separator')
    M.send('MIDCAST', 'debug_header_title', {message = message})
    M.send('MIDCAST', 'debug_header_separator')
end

--- Show debug step
--- @param step number Step number
--- @param message string Step message
--- @param result string|nil Result (OK/FAIL/WARN)
function MessageMidcast.show_debug_step(step, message, result)
    if result then
        M.send('MIDCAST', 'debug_step_result', {
            step = tostring(step),
            message = message,
            result = result
        })
    else
        M.send('MIDCAST', 'debug_step', {
            step = tostring(step),
            message = message
        })
    end
end

--- Show set validation result
--- @param set_name string Set name/path
--- @param exists boolean Whether set exists
function MessageMidcast.show_debug_set(set_name, exists)
    local template_key = exists and 'debug_set_exists' or 'debug_set_missing'
    M.send('MIDCAST', template_key, {set_name = set_name})
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageMidcast

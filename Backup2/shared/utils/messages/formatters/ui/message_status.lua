---============================================================================
--- Status Message Formatter - Status Messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_status.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageStatus = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- BASIC STATUS MESSAGES
---============================================================================

--- Show error message
--- @param message string Error message text
function MessageStatus.show_error(message)
    M.send('STATUS', 'error', {message = message})
end

--- Show warning message
--- @param message string Warning message text
function MessageStatus.show_warning(message)
    M.send('STATUS', 'warning', {message = message})
end

--- Show success message
--- @param message string Success message text
function MessageStatus.show_success(message)
    M.send('STATUS', 'success', {message = message})
end

--- Show info message
--- @param message string Info message text
function MessageStatus.show_info(message)
    M.send('STATUS', 'info', {message = message})
end

---============================================================================
--- TP STATUS MESSAGES
---============================================================================

--- Show TP ready message
--- @param job string Job abbreviation (e.g., "SAM")
--- @param tp_value number TP threshold reached
function MessageStatus.show_tp_ready(job, tp_value)
    M.send('STATUS', 'tp_ready', {
        job = job,
        tp_value = tostring(tp_value)
    })
end

--- Show TP required message
--- @param job string Job abbreviation (e.g., "SAM")
--- @param ability string Ability name
--- @param current_tp number Current TP
--- @param required_tp number Required TP
function MessageStatus.show_tp_required(job, ability, current_tp, required_tp)
    M.send('STATUS', 'tp_required', {
        job = job,
        ability = ability,
        current_tp = tostring(current_tp),
        required_tp = tostring(required_tp)
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageStatus

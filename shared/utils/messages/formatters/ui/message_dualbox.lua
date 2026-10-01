---============================================================================
--- Dualbox Message Formatter - Dual-Boxing System Messages
---============================================================================
--- Templates: data/systems/dualbox_messages.lua.
---
--- @file    shared/utils/messages/formatters/ui/message_dualbox.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageDualbox = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- INITIALIZATION MESSAGES
---============================================================================

--- Show config loaded message
--- @param config_path string Path to config file
function MessageDualbox.show_config_loaded(config_path)
    M.send('DUALBOX', 'config_loaded', {config_path = config_path})
end

--- Show role message
--- @param role string Role (ALT or MAIN)
function MessageDualbox.show_role(role)
    M.send('DUALBOX', 'role', {role = role})
end

--- Show ALT character info
--- @param this_char string This character name
--- @param target_char string Target MAIN character name
function MessageDualbox.show_alt_info(this_char, target_char)
    M.send('DUALBOX', 'alt_info_this', {this_char = this_char})
    M.send('DUALBOX', 'alt_info_target', {target_char = target_char})
end

--- Show MAIN character info
--- @param this_char string This character name
--- @param target_char string Target ALT character name
function MessageDualbox.show_main_info(this_char, target_char)
    M.send('DUALBOX', 'main_info_this', {this_char = this_char})
    M.send('DUALBOX', 'main_info_target', {target_char = target_char})
end

--- Show config not found warning
--- @param config_path string Path where config was expected
function MessageDualbox.show_config_not_found(config_path)
    M.send('DUALBOX', 'config_not_found', {config_path = config_path})
end

--- Show ALT role detected message
function MessageDualbox.show_alt_role_detected()
    M.send('DUALBOX', 'alt_role_detected')
end

--- Show MAIN role detected message
function MessageDualbox.show_main_role_detected()
    M.send('DUALBOX', 'main_role_detected')
end

---============================================================================
--- COMMUNICATION MESSAGES
---============================================================================

--- Show job update sent message
--- @param target_name string Target character name
--- @param main_job string Main job
--- @param sub_job string Sub job
function MessageDualbox.show_job_update_sent(target_name, main_job, sub_job)
    M.send('DUALBOX', 'job_update_sent', {
        target_name = target_name,
        main_job = main_job,
        sub_job = sub_job
    })
end

--- Show job request received message
--- @param target_name string Requesting character name
function MessageDualbox.show_job_request_received(target_name)
    M.send('DUALBOX', 'job_request_received', {target_name = target_name})
end

--- Show job request sending message
--- @param target_name string Target character name
function MessageDualbox.show_requesting_job(target_name)
    M.send('DUALBOX', 'requesting_job', {target_name = target_name})
end

--- Show job update received message
--- @param role string Role (ALT/Main)
--- @param main_job string Main job
--- @param sub_job string Sub job
function MessageDualbox.show_job_update_received(role, main_job, sub_job)
    M.send('DUALBOX', 'job_update_received', {
        role = role,
        main_job = main_job,
        sub_job = sub_job
    })
end

--- Show reloading macrobook message
function MessageDualbox.show_reloading_macrobook()
    M.send('DUALBOX', 'reloading_macrobook')
end

---============================================================================
--- ERROR MESSAGES
---============================================================================

--- Show target character error
function MessageDualbox.show_target_error()
    M.send('DUALBOX', 'target_error')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageDualbox

---============================================================================
--- Dualbox Message Formatter - Dual-Boxing System Messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_dualbox.lua
--- @author  Tetsouo
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

--- Show not initialized error
function MessageDualbox.show_not_initialized()
    M.send('DUALBOX', 'not_initialized')
end

---============================================================================
--- STATUS DISPLAY
---============================================================================

--- Show status header
function MessageDualbox.show_status_header()
    M.send('DUALBOX', 'status_header')
end

--- Show status role line
--- @param role string Role (ALT or MAIN)
function MessageDualbox.show_status_role(role)
    M.send('DUALBOX', 'status_role', {role = role})
end

--- Show status ALT character info
--- @param this_char string This character name
--- @param target_char string Target MAIN character name
function MessageDualbox.show_status_alt_info(this_char, target_char)
    M.send('DUALBOX', 'status_alt_this', {this_char = this_char})
    M.send('DUALBOX', 'status_alt_target', {target_char = target_char})
end

--- Show status MAIN character info
--- @param this_char string This character name
--- @param target_char string Target ALT character name
function MessageDualbox.show_status_main_info(this_char, target_char)
    M.send('DUALBOX', 'status_main_this', {this_char = this_char})
    M.send('DUALBOX', 'status_main_target', {target_char = target_char})
end

--- Show status enabled line
--- @param enabled boolean Enabled state
function MessageDualbox.show_status_enabled(enabled)
    M.send('DUALBOX', 'status_enabled', {enabled = tostring(enabled)})
end

--- Show status ALT online line
--- @param online boolean Online state
function MessageDualbox.show_status_alt_online(online)
    M.send('DUALBOX', 'status_alt_online', {online = tostring(online)})
end

--- Show status ALT job line
--- @param job string Main job
--- @param subjob string Sub job
function MessageDualbox.show_status_alt_job(job, subjob)
    M.send('DUALBOX', 'status_alt_job', {
        job = job,
        subjob = subjob
    })
end

--- Show status last update line
--- @param seconds number Seconds since last update
function MessageDualbox.show_status_last_update(seconds)
    M.send('DUALBOX', 'status_last_update', {seconds = tostring(seconds)})
end

--- Show status footer
function MessageDualbox.show_status_footer()
    M.send('DUALBOX', 'status_footer')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageDualbox

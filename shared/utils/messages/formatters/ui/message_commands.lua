---============================================================================
--- Commands Message Formatter - Centralized Command Messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_commands.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageCommands = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- TESTCOLORS COMMAND
---============================================================================

function MessageCommands.show_color_test_header()
    M.send('COMMANDS', 'testcolors_header')
end

function MessageCommands.show_color_sample(code)
    local color_code = string.char(0x1F, code)
    local sample_text = color_code .. string.format("%03d - Sample Text", code)
    M.send('COMMANDS', 'testcolors_sample', {sample = sample_text})
end

function MessageCommands.show_color_test_footer()
    M.send('COMMANDS', 'testcolors_footer')
end

---============================================================================
--- DETECTREGION COMMAND
---============================================================================

function MessageCommands.show_detect_region_header()
    M.send('COMMANDS', 'detectregion_header')
end

function MessageCommands.show_windower_info_header()
    M.send('COMMANDS', 'windower_info_header')
end

function MessageCommands.show_windower_info_field(key, value)
    M.send('COMMANDS', 'windower_info_field', {key = key, value = value})
end

function MessageCommands.show_detection_results_header()
    M.send('COMMANDS', 'detection_results_header')
end

function MessageCommands.show_region_detected(region, method, orange_code)
    M.send('COMMANDS', 'region_detected', {
        region = region,
        method = method,
        orange_code = orange_code
    })
end

function MessageCommands.show_region_detection_failed()
    M.send('COMMANDS', 'region_detection_failed')
end

function MessageCommands.show_detect_region_footer()
    M.send('COMMANDS', 'detectregion_footer')
end

function MessageCommands.show_region_saved()
    M.send('COMMANDS', 'region_saved')
end

---============================================================================
--- SETREGION COMMAND
---============================================================================

function MessageCommands.show_setregion_usage()
    M.send('COMMANDS', 'setregion_usage')
end

function MessageCommands.show_region_set_us()
    M.send('COMMANDS', 'region_set_us')
end

function MessageCommands.show_region_set_eu()
    M.send('COMMANDS', 'region_set_eu')
end

function MessageCommands.show_region_set_jp()
    M.send('COMMANDS', 'region_set_jp')
end

function MessageCommands.show_invalid_region(region)
    M.send('COMMANDS', 'invalid_region', {region = region})
end

function MessageCommands.show_region_reload_required()
    M.send('COMMANDS', 'region_reload_required')
end

---============================================================================
--- LOCKSTYLE COMMAND
---============================================================================

function MessageCommands.show_lockstyle_reapplying()
    M.send('COMMANDS', 'lockstyle_reapplying')
end

---============================================================================
--- WARP ERROR MESSAGES
---============================================================================

function MessageCommands.show_warp_error_header()
    M.send('COMMANDS', 'warp_error_header')
end

function MessageCommands.show_warp_error(error_msg)
    M.send('COMMANDS', 'warp_error', {error = tostring(error_msg)})
end

function MessageCommands.show_warp_error_footer()
    M.send('COMMANDS', 'warp_error_footer')
end

function MessageCommands.show_warp_testing_modules()
    M.send('COMMANDS', 'warp_testing_modules')
end

function MessageCommands.show_warp_module_test(module_name, success, error_msg)
    local status = success and '✓ OK' or ('✗ ' .. tostring(error_msg))
    M.send('COMMANDS', 'warp_module_test', {
        module = module_name,
        status = status
    })
end

---============================================================================
--- DEBUGSUBJOB COMMAND
---============================================================================

function MessageCommands.show_debugsubjob_header()
    M.send('COMMANDS', 'debugsubjob_header')
end

function MessageCommands.show_debugsubjob_no_player()
    M.send('COMMANDS', 'debugsubjob_no_player')
end

function MessageCommands.show_main_job_info(job, level)
    M.send('COMMANDS', 'main_job_info', {job = tostring(job), level = tostring(level)})
end

function MessageCommands.show_sub_job_info(job, level)
    M.send('COMMANDS', 'sub_job_info', {job = tostring(job), level = tostring(level)})
end

function MessageCommands.show_zone_info_header()
    M.send('COMMANDS', 'zone_info_header')
end

function MessageCommands.show_zone_id(zone_id)
    M.send('COMMANDS', 'zone_id', {zone_id = tostring(zone_id)})
end

function MessageCommands.show_zone_name(zone_name)
    M.send('COMMANDS', 'zone_name', {zone_name = tostring(zone_name)})
end

function MessageCommands.show_zone_info_unavailable()
    M.send('COMMANDS', 'zone_info_unavailable')
end

function MessageCommands.show_debugsubjob_instructions()
    M.send('COMMANDS', 'debugsubjob_instructions')
end

---============================================================================
--- JAMSG COMMAND
---============================================================================

function MessageCommands.show_jamsg_config_error()
    M.send('COMMANDS', 'jamsg_config_error')
end

function MessageCommands.show_jamsg_status_header()
    M.send('COMMANDS', 'jamsg_status_header')
end

function MessageCommands.show_jamsg_current_mode(mode)
    M.send('COMMANDS', 'jamsg_current_mode', {mode = mode})
end

function MessageCommands.show_jamsg_invalid_mode(mode)
    M.send('COMMANDS', 'jamsg_invalid_mode', {mode = mode})
end

function MessageCommands.show_jamsg_mode_changed(mode)
    -- Select template based on mode
    local key = 'jamsg_mode_changed_' .. mode
    M.send('COMMANDS', key)
end

function MessageCommands.show_jamsg_set_failed()
    M.send('COMMANDS', 'jamsg_set_failed')
end

---============================================================================
--- SPELLMSG COMMAND
---============================================================================

function MessageCommands.show_spellmsg_config_error()
    M.send('COMMANDS', 'spellmsg_config_error')
end

function MessageCommands.show_spellmsg_status_header()
    M.send('COMMANDS', 'spellmsg_status_header')
end

function MessageCommands.show_spellmsg_current_mode(mode)
    M.send('COMMANDS', 'spellmsg_current_mode', {mode = mode})
end

function MessageCommands.show_spellmsg_invalid_mode(mode)
    M.send('COMMANDS', 'spellmsg_invalid_mode', {mode = mode})
end

function MessageCommands.show_spellmsg_mode_changed(mode)
    -- Select template based on mode
    local key = 'spellmsg_mode_changed_' .. mode
    M.send('COMMANDS', key)
end

function MessageCommands.show_spellmsg_set_failed()
    M.send('COMMANDS', 'spellmsg_set_failed')
end

---============================================================================
--- DEBUGWARP COMMAND
---============================================================================

function MessageCommands.show_warp_debug_toggled(enabled)
    local status = enabled and 'ENABLED' or 'DISABLED'
    M.send('COMMANDS', 'warp_debug_toggled', {status = status})
end

---============================================================================
--- DEBUGMIDCAST COMMAND
---============================================================================

function MessageCommands.show_debugmidcast_toggled(job_name, debug_state)
    M.send('COMMANDS', 'debugmidcast_toggled', {
        job = job_name,
        debug_state = tostring(debug_state)
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageCommands

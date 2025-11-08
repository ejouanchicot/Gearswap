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
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "FFXI Color Code Test (001-255)")
    add_to_chat(121, gray .. separator)
end

function MessageCommands.show_color_sample(code)
    local color_code = string.char(0x1F, code)
    local sample_text = color_code .. string.format("%03d - Sample Text", code)
    M.send('COMMANDS', 'testcolors_sample', {sample = sample_text})
end

function MessageCommands.show_color_sample_row(code1, code2, code3, code4, code5, code6, code7, code8, code9, code10, code11, code12, code13, code14)
    -- Build 14 samples per line (compact format for FFXI chat)
    -- Each sample: "001" = 3 chars, 14 samples + separators = ~68 chars total (under 74 char limit)
    local samples = {}
    local gray_separator = string.char(0x1F, 8) .. " | "  -- Gray color code + pipe separator

    for _, code in ipairs({code1, code2, code3, code4, code5, code6, code7, code8, code9, code10, code11, code12, code13, code14}) do
        if code and code <= 255 and code ~= 253 then  -- Skip 253 (known FFXI unsupported code)
            -- IMPORTANT: Each entry needs its own color code inline
            local color_code = string.char(0x1F, code)
            local sample = color_code .. string.format("%03d", code)
            table.insert(samples, sample)
        end
    end

    -- Join with gray pipe separator between entries
    local row_text = table.concat(samples, gray_separator)
    M.send('COMMANDS', 'testcolors_sample', {sample = row_text})
end

function MessageCommands.show_color_test_separator()
    local gray = string.char(0x1F, 160)
    add_to_chat(121, gray .. string.rep("=", 74))
end

function MessageCommands.show_color_test_footer()
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "Color test complete!")
    add_to_chat(121, gray .. separator)
end

---============================================================================
--- DETECTREGION COMMAND
---============================================================================

function MessageCommands.show_detect_region_header()
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "FFXI Region Auto-Detection")
    add_to_chat(121, gray .. separator)
end

function MessageCommands.show_windower_info_header()
    M.send('COMMANDS', 'windower_info_header')
end

function MessageCommands.show_windower_info_field(key, value)
    M.send('COMMANDS', 'windower_info_field', {key = key, value = value})
end

function MessageCommands.show_detection_results_header()
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, " ")  -- Blank line
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "DETECTION RESULTS:")
    add_to_chat(121, gray .. separator)
end

function MessageCommands.show_region_detected(region, method, orange_code)
    M.send('COMMANDS', 'region_detected', {
        region = region,
        method = method,
        orange_code = orange_code
    })
end

function MessageCommands.show_region_detection_failed()
    local red = string.char(0x1F, 167)
    local blue = string.char(0x1F, 122)
    local orange = string.char(0x1F, 57)
    local yellow = string.char(0x1F, 50)
    local rose = string.char(0x1F, 2)
    local white = string.char(0x1F, 1)

    -- Use channel 121 with inline color codes
    add_to_chat(121, red .. "Region: AUTO-DETECTION FAILED")
    add_to_chat(121, " ")
    add_to_chat(121, yellow .. "MANUAL TEST:")
    add_to_chat(121, blue .. "Look at the line below:")
    add_to_chat(121, orange .. "Code 057" .. white .. " SAMPLE - Is this " .. orange .. "ORANGE" .. white .. " or " .. white .. "WHITE" .. white .. "?")
    add_to_chat(121, " ")
    add_to_chat(121, blue .. "If " .. orange .. "ORANGE" .. blue .. " = US (use code " .. orange .. "057" .. blue .. ")")
    add_to_chat(121, blue .. "If WHITE/NO COLOR = EU (use code " .. rose .. "002 - Rose" .. blue .. ")")
    add_to_chat(121, " ")
    add_to_chat(121, blue .. "To set manually:")
    add_to_chat(121, blue .. "  //gs c setregion us")
    add_to_chat(121, blue .. "  //gs c setregion eu")
end

function MessageCommands.show_detect_region_footer()
    local gray = string.char(0x1F, 160)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
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
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "[JA_MSG] Current Display Mode")
    add_to_chat(121, gray .. separator)
end

function MessageCommands.show_jamsg_current_mode(mode)
    local gray = string.char(0x1F, 160)
    local green = string.char(0x1F, 158)
    local cyan = string.char(0x1F, 122)
    local yellow = string.char(0x1F, 50)
    local white = string.char(0x1F, 1)
    local separator = string.rep("=", 74)

    add_to_chat(121, green .. "Mode: " .. yellow .. mode)
    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Available modes:")
    add_to_chat(121, yellow .. "  full" .. gray .. "(Show name + description)")
    add_to_chat(121, yellow .. "  on" .. gray .. "(Show name only)")
    add_to_chat(121, yellow .. "  off" .. gray .. "(Disable all messages)")
    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Usage: " .. white .. "//gs c jamsg <full | on | off>")
    add_to_chat(121, gray .. separator)
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
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "[SPELL_MSG] Current Display Mode")
    add_to_chat(121, gray .. separator)
end

function MessageCommands.show_spellmsg_current_mode(mode)
    local gray = string.char(0x1F, 160)
    local green = string.char(0x1F, 158)
    local cyan = string.char(0x1F, 122)
    local yellow = string.char(0x1F, 50)
    local white = string.char(0x1F, 1)
    local separator = string.rep("=", 74)

    add_to_chat(121, green .. "Mode: " .. yellow .. mode)
    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Available modes:")
    add_to_chat(121, yellow .. "  full" .. gray .. "(Show name + description)")
    add_to_chat(121, yellow .. "  on" .. gray .. "(Show name only)")
    add_to_chat(121, yellow .. "  off" .. gray .. "(Disable all messages)")
    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "Usage: " .. white .. "//gs c spellmsg <full | on | off>")
    add_to_chat(121, gray .. separator)
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

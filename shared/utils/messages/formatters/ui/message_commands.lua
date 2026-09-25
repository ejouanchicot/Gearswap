---============================================================================
--- Commands Message Formatter - Centralized Command Messages
---============================================================================
--- Output of the common //gs c commands. Short lines use the COMMANDS
--- templates (data/systems/commands_messages.lua); multi-line screens (help,
--- commands list, color test, mode status) are built here with add_to_chat,
--- this module being a last rendering level (CODE_QUALITY §6).
---
--- @file    shared/utils/messages/formatters/ui/message_commands.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageCommands = {}
local MessageCore = require('shared/utils/messages/message_core')
local ChatPalette = require('shared/utils/messages/chat_palette')
local M = require('shared/utils/messages/api/messages')
local MessageColors = require('shared/utils/messages/message_colors')

---============================================================================
--- TESTCOLORS COMMAND
---============================================================================

--- Generate FFXI color code using dual-prefix system
--- Codes 1-255:   string.char(0x1F, code)
--- Codes 256-509: string.char(0x1E, code - 254)
--- @param code number Color code (1-509)
--- @return string Color escape sequence
local function generate_color_code(code)
    if code <= 255 then
        return string.char(0x1F, code)
    else
        -- Codes 256-509 use 0x1E prefix with offset
        local offset_code = code - 254
        -- Code 258 (offset 4) can bug chatlog, use 3 instead
        if offset_code == 4 then offset_code = 3 end
        return string.char(0x1E, offset_code)
    end
end

--- Header of //gs c testcolors (separator, title, separator)
function MessageCommands.show_color_test_header()
    local gray = ChatPalette.tag('gray')
    local yellow = ChatPalette.tag('yellow')
    local separator = string.rep("=", MessageCore.SEPARATOR_WIDTH)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "FFXI Color Code Test (001-509) - Dual Prefix System")
    add_to_chat(121, gray .. separator)
end

--- One color sample line (codes 1-255 only)
--- @param code number Color code
function MessageCommands.show_color_sample(code)
    local color_code = string.char(0x1F, code)
    local sample_text = color_code .. string.format("%03d - Sample Text", code)
    M.send('COMMANDS', 'testcolors_sample', {sample = sample_text})
end

--- Up to 14 color codes on one line, each in its own color (1-509)
--- @param code1 number First code; code2..code14 follow, nil entries are skipped
function MessageCommands.show_color_sample_row(code1, code2, code3, code4, code5, code6, code7, code8, code9, code10, code11, code12, code13, code14)
    -- Build up to 14 samples per line (compact format for FFXI chat)
    -- Each sample is 3 digits and entries are joined by " | ": 14 codes make 81
    -- visible characters, wider than the separator line.
    -- NOTE: Problematic codes are filtered out before calling this function
    local samples = {}
    local gray_separator = ChatPalette.tag('darkgray') .. " | "  -- Gray color code + pipe separator

    for _, code in ipairs({code1, code2, code3, code4, code5, code6, code7, code8, code9, code10, code11, code12, code13, code14}) do
        if code and code >= 1 and code <= 509 then
            -- Display code with its actual color using dual-prefix system
            local color_code = generate_color_code(code)
            local sample = color_code .. string.format("%03d", code)
            table.insert(samples, sample)
        end
    end

    -- Join with gray pipe separator between entries
    local row_text = table.concat(samples, gray_separator)
    M.send('COMMANDS', 'testcolors_sample', {sample = row_text})
end

--- Gray separator line between testcolors rows
function MessageCommands.show_color_test_separator()
    local gray = ChatPalette.tag('gray')
    add_to_chat(121, gray .. string.rep("=", MessageCore.SEPARATOR_WIDTH))
end

--- Footer of //gs c testcolors
function MessageCommands.show_color_test_footer()
    local gray = ChatPalette.tag('gray')
    local yellow = ChatPalette.tag('yellow')
    local separator = string.rep("=", MessageCore.SEPARATOR_WIDTH)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "Color test complete!")
    add_to_chat(121, gray .. separator)
end

---============================================================================
--- CRAFT COMMAND
---============================================================================

--- Display "Equipping <description> (<count> pieces)..." line.
--- @param description string Set description (e.g. "Bonecraft HQ").
--- @param count number Piece count being equipped.
function MessageCommands.show_craft_equipping(description, count)
    local gray   = ChatPalette.tag('gray')
    local cyan   = string.char(0x1F, 121)
    local green  = ChatPalette.tag('green')
    local yellow = ChatPalette.tag('yellow')
    add_to_chat(121, gray .. '[' .. cyan .. 'Craft' .. gray .. '] ' ..
        yellow .. 'Equipping ' .. green .. description ..
        gray .. ' (' .. count .. ' pieces)...')
end

--- Display "<description> ready - slots locked." line shown 2s after equip.
--- @param description string Set description (e.g. "Bonecraft HQ").
function MessageCommands.show_craft_ready(description)
    local gray   = ChatPalette.tag('gray')
    local cyan   = string.char(0x1F, 121)
    local green  = ChatPalette.tag('green')
    local yellow = ChatPalette.tag('yellow')
    add_to_chat(121, gray .. '[' .. cyan .. 'Craft' .. gray .. '] ' ..
        green .. description ..
        gray .. ' ready - slots locked. Run ' ..
        yellow .. '//gs c uncraft' .. gray .. ' when done.')
end

---============================================================================
--- DETECTREGION COMMAND
---============================================================================

--- Show the COMMANDS.windower_info_header message
function MessageCommands.show_windower_info_header()
    M.send('COMMANDS', 'windower_info_header')
end

--- @param key string Field name
--- @param value any Field value
function MessageCommands.show_windower_info_field(key, value)
    M.send('COMMANDS', 'windower_info_field', {key = key, value = value})
end

---============================================================================
--- SETREGION COMMAND
---============================================================================

---============================================================================
--- LOCKSTYLE COMMAND
---============================================================================

--- Show the COMMANDS.lockstyle_reapplying message
function MessageCommands.show_lockstyle_reapplying()
    M.send('COMMANDS', 'lockstyle_reapplying')
end

---============================================================================
--- DRESSUP TOGGLE COMMAND
---============================================================================

--- @param enabled boolean New DressUp management state
function MessageCommands.show_dressup_toggled(enabled)
    local status = enabled and "ON" or "OFF"
    local color = enabled and MessageColors.SUCCESS or MessageColors.WARNING
    local desc = enabled and "(will cycle DressUp on lockstyle)" or "(lockstyle only, no DressUp)"
    local color_code = string.char(0x1F, color)
    local gray = ChatPalette.tag('gray')
    add_to_chat(121, color_code .. "[DressUp] " .. gray .. "Management: " .. color_code .. status .. " " .. gray .. desc)
end

---============================================================================
--- WARP ERROR MESSAGES
---============================================================================

--- Show the COMMANDS.warp_error_header message
function MessageCommands.show_warp_error_header()
    M.send('COMMANDS', 'warp_error_header')
end

--- @param error_msg any Error to show
function MessageCommands.show_warp_error(error_msg)
    M.send('COMMANDS', 'warp_error', {error = tostring(error_msg)})
end

--- Show the COMMANDS.warp_error_footer message
function MessageCommands.show_warp_error_footer()
    M.send('COMMANDS', 'warp_error_footer')
end

--- Show the COMMANDS.warp_testing_modules message
function MessageCommands.show_warp_testing_modules()
    M.send('COMMANDS', 'warp_testing_modules')
end

--- @param module_name string Module tested
--- @param success boolean Whether it loaded
--- @param error_msg any Error when it did not
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

--- Header of //gs c debugsubjob
function MessageCommands.show_debugsubjob_header()
    local gray = ChatPalette.tag('gray')
    local yellow = ChatPalette.tag('yellow')
    local separator = string.rep("=", MessageCore.SEPARATOR_WIDTH)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "[DEBUG] Subjob Detection")
    add_to_chat(121, gray .. separator)
end

--- Show the COMMANDS.debugsubjob_no_player message
function MessageCommands.show_debugsubjob_no_player()
    M.send('COMMANDS', 'debugsubjob_no_player')
end

--- @param job string Main job
--- @param level number Main job level
function MessageCommands.show_main_job_info(job, level)
    M.send('COMMANDS', 'main_job_info', {job = tostring(job), level = tostring(level)})
end

--- @param job string Sub job
--- @param level number Sub job level
function MessageCommands.show_sub_job_info(job, level)
    M.send('COMMANDS', 'sub_job_info', {job = tostring(job), level = tostring(level)})
end

--- Show the COMMANDS.zone_info_header message
function MessageCommands.show_zone_info_header()
    M.send('COMMANDS', 'zone_info_header')
end

--- @param zone_id number Zone id
function MessageCommands.show_zone_id(zone_id)
    M.send('COMMANDS', 'zone_id', {zone_id = tostring(zone_id)})
end

--- @param zone_name string Zone name
function MessageCommands.show_zone_name(zone_name)
    M.send('COMMANDS', 'zone_name', {zone_name = tostring(zone_name)})
end

--- Show the COMMANDS.zone_info_unavailable message
function MessageCommands.show_zone_info_unavailable()
    M.send('COMMANDS', 'zone_info_unavailable')
end

--- Closing separator of //gs c debugsubjob
function MessageCommands.show_debugsubjob_instructions()
    local gray = ChatPalette.tag('gray')
    local separator = string.rep("=", MessageCore.SEPARATOR_WIDTH)
    add_to_chat(121, gray .. separator)
end

---============================================================================
--- JAMSG COMMAND
---============================================================================

--- Show the COMMANDS.jamsg_config_error message
function MessageCommands.show_jamsg_config_error()
    M.send('COMMANDS', 'jamsg_config_error')
end

--- @param mode string Mode as typed
function MessageCommands.show_jamsg_invalid_mode(mode)
    M.send('COMMANDS', 'jamsg_invalid_mode', {mode = mode})
end

--- @param mode string New mode: 'full', 'on' or 'off' (selects the template)
function MessageCommands.show_jamsg_mode_changed(mode)
    local key = 'jamsg_mode_changed_' .. mode
    M.send('COMMANDS', key)
end

--- Show the COMMANDS.jamsg_set_failed message
function MessageCommands.show_jamsg_set_failed()
    M.send('COMMANDS', 'jamsg_set_failed')
end

--- //gs c jamsg / spellmsg / wsmsg with no argument: modes and current one.
local MESSAGE_MODE_HELP = {
    ja = {command = 'jamsg', title = 'JA MESSAGES', full = 'Name + description', on = 'Name only'},
    spell = {command = 'spellmsg', title = 'SPELL MESSAGES', full = 'Name + description', on = 'Name only',
        note = 'All spells: Enhancing, Enfeebling...'},
    ws = {command = 'wsmsg', title = 'WS MESSAGES', full = 'Name + description + TP', on = 'Name + TP only',
        alias = 'tp = on'},
}

--- Help screen of one message display mode, in the look of //gs c commands.
--- @param msg_type string 'ja', 'spell' or 'ws'
--- @param mode string Current mode ('full', 'on' or 'off')
function MessageCommands.show_message_mode_help(msg_type, mode)
    local h = MESSAGE_MODE_HELP[msg_type]
    if not h then return end
    local cmd = '//gs c ' .. h.command .. ' '
    local notes = {'Short: f = full, n = on, d = off' .. (h.alias and (', ' .. h.alias) or '') .. '.'}
    if h.note then table.insert(notes, 1, h.note) end
    require('shared/utils/messages/help_screen').show({
        title = h.title, subtitle = 'current mode: ' .. tostring(mode),
        groups = {{title = 'MODES', rows = {
            {cmd, 'full', h.full},
            {cmd, 'on', h.on},
            {cmd, 'off', 'No message'},
        }}},
        notes = notes,
    })
end

---============================================================================
--- SPELLMSG COMMAND
---============================================================================

--- Show the COMMANDS.spellmsg_config_error message
function MessageCommands.show_spellmsg_config_error()
    M.send('COMMANDS', 'spellmsg_config_error')
end

--- @param mode string Mode as typed
function MessageCommands.show_spellmsg_invalid_mode(mode)
    M.send('COMMANDS', 'spellmsg_invalid_mode', {mode = mode})
end

--- @param mode string New mode: 'full', 'on' or 'off' (selects the template)
function MessageCommands.show_spellmsg_mode_changed(mode)
    local key = 'spellmsg_mode_changed_' .. mode
    M.send('COMMANDS', key)
end

--- Show the COMMANDS.spellmsg_set_failed message
function MessageCommands.show_spellmsg_set_failed()
    M.send('COMMANDS', 'spellmsg_set_failed')
end

---============================================================================
--- WSMSG COMMAND
---============================================================================

--- Show the COMMANDS.wsmsg_config_error message
function MessageCommands.show_wsmsg_config_error()
    M.send('COMMANDS', 'wsmsg_config_error')
end

--- @param mode string Mode as typed
function MessageCommands.show_wsmsg_invalid_mode(mode)
    M.send('COMMANDS', 'wsmsg_invalid_mode', {mode = mode})
end

--- @param mode string New mode: 'full', 'on' or 'off' (selects the template)
function MessageCommands.show_wsmsg_mode_changed(mode)
    local key = 'wsmsg_mode_changed_' .. mode
    M.send('COMMANDS', key)
end

--- Show the COMMANDS.wsmsg_set_failed message
function MessageCommands.show_wsmsg_set_failed()
    M.send('COMMANDS', 'wsmsg_set_failed')
end

---============================================================================
--- DEBUGWARP COMMAND
---============================================================================

--- @param enabled boolean New warp debug state
function MessageCommands.show_warp_debug_toggled(enabled)
    local status = enabled and 'ENABLED' or 'DISABLED'
    M.send('COMMANDS', 'warp_debug_toggled', {status = status})
end

---============================================================================
--- DEBUGMIDCAST COMMAND
---============================================================================

--- @param job_name string Job tag
--- @param debug_state boolean New midcast debug state
function MessageCommands.show_debugmidcast_toggled(job_name, debug_state)
    M.send('COMMANDS', 'debugmidcast_toggled', {
        job = job_name,
        debug_state = tostring(debug_state)
    })
end

---============================================================================
--- HELP DISPLAY
---============================================================================

--- //gs c help: where every help is (HelpScreen, the look of every help).
local QUICK_HELP = {
    title = 'GEARSWAP HELP', subtitle = 'Quick reference',
    groups = {
        {rows = {
            {'//gs c help | ?', '', 'This screen'},
            {'//gs c commands | cmds', '', 'Every universal command'},
        }},
        {title = 'HELP OF EACH SYSTEM', note = '<system> help', rows = {
            {'//gs c ui help', '', 'HUD and chat look'},
            {'//gs c warp help', '', 'Warp, teleports, destinations'},
            {'//gs c tb help', '', 'Temporary keys'},
            {'//gs c combatmode help', '', 'Weapon lock, per job'},
            {'//gs c alts help', '', 'Orders to the other boxes'},
            {'//gs c altcmds help', '', "The alt's commands"},
            {'//gs c sortie help', '', 'Sortie targets'},
            {'//gs c watchdog help', '', 'Stuck midcast recovery'},
            {'//gs c info help', '', 'Spell / ability / WS details'},
        }},
    },
    notes = {'Most commands have a short alias (shown after |).'},
}

--- Display the quick help (//gs c help)
function MessageCommands.show_help()
    require('shared/utils/messages/help_screen').show(QUICK_HELP)
end

--- //gs c commands: every universal command, grouped.
local COMMANDS_HELP = {
    title = 'COMMON COMMANDS', subtitle = 'Available on every job',
    groups = {
        {title = 'SYSTEM', rows = {
            {'//gs c reload', '', 'Force job reload'},
            {'//gs c checksets', '', 'Validate equipment sets'},
            {'//gs c lockstyle | ls', '', 'Reapply lockstyle'},
            {'//gs c dressup', '', 'Toggle DressUp management'},
            {'//gs c naked | equip naked', '', 'Strip all equipment'},
            {'//gs c mount', '', 'Toggle mount (random owned)'},
            {'//gs c tb ', '<key> <what>', 'Temporary key (tb help)'},
            {'//gs c combatmode ', 'show | hide', 'Weapon lock on this job'},
        }},
        {title = 'EQUIPMENT & INVENTORY', rows = {
            {'//gs c wardrobeaudit | wa', '', 'Audit wardrobe across jobs'},
            {'//gs c worganize | wo', '', 'Organize wardrobes by job'},
            {'//gs c worganize alt', '', 'Alt mode (4 wardrobes)'},
            {'//gs c refill | rf', '', 'Consumables from Case/Sack'},
            {'//gs c automedicine | am', '', 'Toggle auto Echo Drops/Remedy'},
        }},
        {title = 'DUAL-BOX', rows = {
            {'//gs c altcmds', '', 'What the alt can do now'},
            {'//gs c alt ', '<name>', 'Run an alt command explicitly'},
            {'//gs c ', '<name>', 'Short form (haste, chaos...)'},
            {'//gs c alts ', '<cmd>', 'Every alt (alts help)'},
            {'//gs c main', '', 'I am the main, the others alts'},
            {'//gs c altsync', '', 'Ask the alt to resend its buffs'},
            {'//gs c altbuffs', '', "What the main knows of alt buffs"},
            {'//gs c sortie ', '<target>', 'Sortie setup (sortie help)'},
        }},
        {title = 'CRAFT & FISH', rows = {
            {'//gs c craft', '', 'Craft mode (locks weapon slots)'},
            {'//gs c fish | fishing', '', 'Fish mode'},
            {'//gs c uncraft', '', 'Exit craft/fish mode'},
        }},
        {title = 'UI / INTERFACE', note = 'ui help for all', rows = {
            {'//gs c ui', '', 'Show / hide the HUD'},
            {'//gs c ui save', '', 'Save HUD position'},
            {'//gs c ui ', 'h|l|c|f', 'Header/legend/columns/footer'},
            {'//gs c ui ', 'on|off', 'Enable / disable the HUD'},
            {'//gs c ui theme ', '<name|list>', 'Background theme'},
            {'//gs c ui font ', '<name>', 'Change font'},
            {'//gs c ui style', '', 'Current HUD and chat look'},
        }},
        {title = 'MESSAGES', rows = {
            {'//gs c jamsg ', '<full|on|off>', 'Job ability messages'},
            {'//gs c spellmsg ', '<full|on|off>', 'Spell messages'},
            {'//gs c wsmsg ', '<full|on|off>', 'Weapon skill messages'},
            {'//gs c testcolors | colors', '', 'Test FFXI color codes'},
        }},
        {title = 'INFO & DEBUG', rows = {
            {'//gs c info ', '<name>', 'Spell / JA / WS details'},
            {'//gs c debugsubjob | dsj', '', 'Show subjob detection'},
            {'//gs c debugprecast', '', 'Toggle precast debug'},
            {'//gs c debugmidcast', '', 'Toggle midcast debug'},
            {'//gs c debugwarp', '', 'Toggle warp debug'},
            {'//gs c debugmsg', '', 'Message settings'},
            {'//gs c debugstate | ds', '', 'Global debug state'},
            {'//gs c debugupdate', '', 'Toggle update flow trace'},
            {'//gs c debugjobchange | djc', '', 'Toggle job change debug'},
            {'//gs c automovedebug | amd', '', 'Toggle AutoMove debug'},
            {'//gs c altdebug', '', 'Trace alt buff reporting'},
            {'//gs c trace', '', 'Record game data to trace.log'},
            {'//gs c watchdog', '', 'Midcast watchdog (watchdog help)'},
        }},
        {title = 'SUBJOB ABILITIES', rows = {
            {'//gs c jump', '', 'High Jump (DRG sub)'},
            {'//gs c waltz', '', 'Curing Waltz III <stpc> (DNC sub)'},
            {'//gs c aoewaltz', '', 'Divine Waltz <me> (DNC sub)'},
        }},
        {title = 'WARP', note = '50+ commands, warp help', rows = {
            {'//gs c warp status', '', 'Warp lock status'},
            {'//gs c w | w2 | ret', '', 'Warp, Warp II, Retrace'},
            {'//gs c sd | bt | wd | jn', '', "Towns (and more: warp help)"},
        }},
        {title = 'PERFORMANCE & TESTING', rows = {
            {'//gs c perf ', '[start|stop]', 'Performance profiler'},
            {'//gs c fulltest | ft', '', 'Full in-game test suite'},
            {'//gs c syscheck | sc', '', 'System health check'},
            {'//gs c lagdebug | ldb', '', 'Lag debugger'},
            {'//gs c memcheck | mem ', '[gc]', 'GearSwap Lua RAM usage'},
            {'//gs c msgtests', '', 'Validate message system'},
        }},
    },
}

--- Display the list of universal commands (//gs c commands)
function MessageCommands.show_commands_list()
    require('shared/utils/messages/help_screen').show(COMMANDS_HELP)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageCommands

---============================================================================
--- Message System - System intro and status messages
---============================================================================
--- Job-load block (macro book, lockstyle, keybind count, HUD state, an
--- InfoBlock) and
--- a color test (called from COR_COMMANDS). Templates: data/systems/system_messages.lua.
---
--- @file    shared/utils/messages/formatters/system/message_system.lua
--- @author  Tetsouo
--- @version 3.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageSystem = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- INTERNAL HELPERS
---============================================================================

--- The fields that depend on what the job was given: its macro book and its
--- lockstyle. Either is skipped when the job passed nothing for it.
--- @param fields table List being built
--- @param macro_info table|nil {book, page}
--- @param lockstyle_info table|nil {style}
local function add_config_fields(fields, macro_info, lockstyle_info)
    if macro_info and macro_info.book and macro_info.page then
        fields[#fields + 1] = {'Macrobook', ('Book %s, set %s'):format(macro_info.book, macro_info.page)}
    end
    if lockstyle_info and lockstyle_info.style then
        local delay = _G.LockstyleConfig and _G.LockstyleConfig.initial_load_delay or 8.0
        fields[#fields + 1] = {'Lockstyle', ('Set %s (in %.1f s)'):format(lockstyle_info.style, delay)}
    end
end

--- How many keys are bound, and whether the HUD is up.
--- No ui_display_config at all means the UI was never set up, which is not the
--- same as it being hidden - that case says nothing rather than "hidden".
local function add_status_fields(fields, keybind_count)
    if keybind_count > 0 then
        fields[#fields + 1] = {'Keybinds', keybind_count .. ' loaded'}
    end
    local ui_enabled = _G.ui_display_config and _G.ui_display_config.enabled
    if ui_enabled ~= nil then
        fields[#fields + 1] = {'HUD', (ui_enabled and 'Visible' or 'Hidden') .. ' (//gs c ui)',
            ui_enabled and 'good' or 'dim'}
    end
end

--- Job-load block ("WAR :: System loaded"), a data block like every other.
--- @param title string "WAR SYSTEM LOADED": the first word is the block tag
--- @param keybinds table Array of keybind objects
--- @param macro_info table|nil
--- @param lockstyle_info table|nil
local function build_and_display_intro(title, keybinds, macro_info, lockstyle_info)
    local keybind_count = 0
    for _ in pairs(keybinds or {}) do keybind_count = keybind_count + 1 end

    local tag, rest = tostring(title):match('^(%S+)%s+(.+)$')
    rest = rest and (rest:sub(1, 1):upper() .. rest:sub(2):lower()) or nil
    local fields = {}
    add_config_fields(fields, macro_info, lockstyle_info)
    add_status_fields(fields, keybind_count)
    require('shared/utils/messages/info_block').show({
        tag = tag or tostring(title), title = rest or 'Loaded', fields = fields,
    })
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Display a system intro with centered title and keybinds
--- @param title string System title (e.g., "WAR SYSTEM LOADED")
--- @param keybinds table Array of keybind objects with 'key' and 'desc' fields
--- @param job_name string Not used (the intro carries no job tag)
function MessageSystem.show_system_intro(title, keybinds, job_name)
    build_and_display_intro(title, keybinds, nil, nil)
end

--- Display a system intro with centered title, keybinds, and macro book info
--- @param title string System title (e.g., "WAR SYSTEM LOADED")
--- @param keybinds table Array of keybind objects with 'key' and 'desc' fields
--- @param macro_info table Optional macro info {book, page, subjob}
--- @param job_name string Not used (the intro carries no job tag)
function MessageSystem.show_system_intro_with_macros(title, keybinds, macro_info, job_name)
    build_and_display_intro(title, keybinds, macro_info, nil)
end

--- Display a system intro with centered title, keybinds, macro book and lockstyle info
--- @param title string System title (e.g., "WAR SYSTEM LOADED")
--- @param keybinds table Array of keybind objects with 'key' and 'desc' fields
--- @param macro_info table Optional macro info {book, page, subjob}
--- @param lockstyle_info table Optional lockstyle info {style, enabled, subjob}
--- @param job_name string Not used (the intro carries no job tag)
function MessageSystem.show_system_intro_complete(title, keybinds, macro_info, lockstyle_info, job_name)
    build_and_display_intro(title, keybinds, macro_info, lockstyle_info)
end

---============================================================================
--- COLOR TEST MESSAGES (Debug Utility)
---============================================================================

--- Display color test header
function MessageSystem.show_color_test_header()
    M.send('SYSTEM', 'colortest_header_separator')
    M.send('SYSTEM', 'colortest_header_title')
    M.send('SYSTEM', 'colortest_header_separator')
end

--- Display color test sample for a specific code
--- @param code number Color code (1-255)
function MessageSystem.show_color_test_sample(code)
    local color_code = string.char(0x1F, code)
    local sample_text = color_code .. string.format("%03d - Sample Text", code)

    -- Direct add_to_chat to preserve inline color codes (channel 121 preserves colors)
    add_to_chat(121, sample_text)
end

--- Display color test footer
function MessageSystem.show_color_test_footer()
    M.send('SYSTEM', 'colortest_footer_separator')
    M.send('SYSTEM', 'colortest_footer_complete')
    M.send('SYSTEM', 'colortest_footer_separator')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageSystem

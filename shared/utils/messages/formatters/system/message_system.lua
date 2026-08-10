---============================================================================
--- Message System - System intro and status messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_system.lua
--- @author  Tetsouo
--- @version 3.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageSystem = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')
local MessageKeybinds = require('shared/utils/messages/formatters/ui/message_keybinds')
local Colors = MessageCore.COLORS

---============================================================================
--- INTERNAL HELPERS
---============================================================================

--- Calculate content width including keybinds, macros, and lockstyle
--- @param keybinds table Array of keybind objects
--- @param macro_info table Optional macro info {book, page, subjob}
--- @param lockstyle_info table Optional lockstyle info {style, enabled, subjob}
--- @param job_name string Job name for macro/lockstyle display
--- @return number Maximum content width
local function calculate_content_width(keybinds, macro_info, lockstyle_info, job_name)
    local content_width = MessageKeybinds.calculate_max_width(keybinds)

    -- Include macro line length if provided
    if macro_info and macro_info.book and macro_info.page then
        local macro_text = string.format("[MacroBook] %s Book %d Page %d",
            job_name or "JOB", macro_info.book, macro_info.page)
        content_width = math.max(content_width, string.len(macro_text))
    end

    -- Include lockstyle line length if provided
    if lockstyle_info and lockstyle_info.style then
        local lockstyle_text = string.format("[Lockstyle] %s Style %d (%s)",
            job_name or "JOB", lockstyle_info.style,
            lockstyle_info.enabled and "Enabled" or "Disabled")
        content_width = math.max(content_width, string.len(lockstyle_text))
    end

    return content_width
end

-- The intro box is a fixed width. An earlier version measured the longest line
-- and sized the box to it; that measuring code was still running, still
-- building every line a second time to do it, and its result was never read.
local SEPARATOR_LENGTH = 74

--- The lines that depend on what the job was given: its macro book and its
--- lockstyle. Either is skipped when the job passed nothing for it.
local function send_intro_config(macro_info, lockstyle_info, key_color, desc_color)
    if macro_info and macro_info.book and macro_info.page then
        M.send('SYSTEM', 'intro_macrobook', {
            key_color = key_color,
            desc_color = desc_color,
            book = tostring(macro_info.book),
            page = tostring(macro_info.page)
        })
    end

    if lockstyle_info and lockstyle_info.style then
        local lockstyle_delay = _G.LockstyleConfig and _G.LockstyleConfig.initial_load_delay or 8.0
        M.send('SYSTEM', 'intro_lockstyle', {
            key_color = key_color,
            desc_color = desc_color,
            style = tostring(lockstyle_info.style),
            delay = string.format("%.1f", lockstyle_delay)
        })
    end
end

--- How many keys are bound, and whether the HUD is up.
--- No ui_display_config at all means the UI was never set up, which is not the
--- same as it being hidden - that case says nothing rather than "hidden".
local function send_intro_status(keybind_count, key_color, desc_color)
    if keybind_count > 0 then
        M.send('SYSTEM', 'intro_keybinds', {
            key_color = key_color,
            desc_color = desc_color,
            count = tostring(keybind_count)
        })
    end

    local ui_enabled = _G.ui_display_config and _G.ui_display_config.enabled
    if ui_enabled ~= nil then
        M.send('SYSTEM', ui_enabled and 'intro_ui_visible' or 'intro_ui_hidden', {
            key_color = key_color,
            desc_color = desc_color
        })
    end
end

--- Build system intro with all optional components
--- @param title string System title
--- @param keybinds table Array of keybind objects
--- @param macro_info table Optional macro info
--- @param lockstyle_info table Optional lockstyle info
--- @param _job_name string Optional job tag (unused: the intro carries no job tag)
local function build_and_display_intro(title, keybinds, macro_info, lockstyle_info, _job_name)
    local key_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
    local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)

    local keybind_count = 0
    if keybinds then
        for _ in pairs(keybinds) do
            keybind_count = keybind_count + 1
        end
    end

    local separator_line = string.rep("=", SEPARATOR_LENGTH)

    M.send('SYSTEM', 'intro_header_separator', {separator = separator_line})
    M.send('SYSTEM', 'intro_header_title', {title = title})
    M.send('SYSTEM', 'intro_header_separator', {separator = separator_line})

    send_intro_config(macro_info, lockstyle_info, key_color, desc_color)
    send_intro_status(keybind_count, key_color, desc_color)

    M.send('SYSTEM', 'intro_footer_separator', {separator = separator_line})
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Display a system intro with centered title and keybinds
--- @param title string System title (e.g., "WAR SYSTEM LOADED")
--- @param keybinds table Array of keybind objects with 'key' and 'desc' fields
--- @param job_name string Optional job name (auto-detected if nil)
function MessageSystem.show_system_intro(title, keybinds, job_name)
    build_and_display_intro(title, keybinds, nil, nil, job_name)
end

--- Display a system intro with centered title, keybinds, and macro book info
--- @param title string System title (e.g., "WAR SYSTEM LOADED")
--- @param keybinds table Array of keybind objects with 'key' and 'desc' fields
--- @param macro_info table Optional macro info {book, page, subjob}
--- @param job_name string Optional job name (auto-detected if nil)
function MessageSystem.show_system_intro_with_macros(title, keybinds, macro_info, job_name)
    build_and_display_intro(title, keybinds, macro_info, nil, job_name)
end

--- Display a system intro with centered title, keybinds, macro book and lockstyle info
--- @param title string System title (e.g., "WAR SYSTEM LOADED")
--- @param keybinds table Array of keybind objects with 'key' and 'desc' fields
--- @param macro_info table Optional macro info {book, page, subjob}
--- @param lockstyle_info table Optional lockstyle info {style, enabled, subjob}
--- @param job_name string Optional job name (auto-detected if nil)
function MessageSystem.show_system_intro_complete(title, keybinds, macro_info, lockstyle_info, job_name)
    build_and_display_intro(title, keybinds, macro_info, lockstyle_info, job_name)
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

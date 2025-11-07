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

--- Helper function to calculate visible length (strip color codes)
--- @param text string Text with color codes
--- @return number Visible length without color codes
local function calculate_visible_length(text)
    -- Strip FFXI color codes (\x1F + 1 byte = 2 bytes total)
    local visible_text = text:gsub(string.char(0x1F) .. ".", "")
    return #visible_text
end

--- Build a formatted message string without displaying it (for length calculation)
--- @param namespace string Message namespace
--- @param key string Message key
--- @param params table Message parameters
--- @return string Formatted message with color codes
local function build_message_string(namespace, key, params)
    local MessageEngine = require('shared/utils/messages/core/message_engine')
    local ok, message, color = pcall(function()
        return MessageEngine.format(namespace, key, params)
    end)

    if ok then
        return message
    else
        return ""
    end
end

--- Build system intro with all optional components (DYNAMIC SEPARATOR VERSION)
--- Calculates separator length from longest visible line + 3 characters
--- @param title string System title
--- @param keybinds table Array of keybind objects
--- @param macro_info table Optional macro info
--- @param lockstyle_info table Optional lockstyle info
--- @param job_name string Optional job tag (auto-detected if nil)
local function build_and_display_intro(title, keybinds, macro_info, lockstyle_info, job_name)
    -- Auto-detect job tag if not provided (e.g., "WAR/SAM", "PLD/BLU")
    job_name = job_name or MessageCore.get_job_tag()

    -- Color codes for info lines
    local key_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
    local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)

    -- Count keybinds
    local keybind_count = 0
    if keybinds then
        for _ in pairs(keybinds) do
            keybind_count = keybind_count + 1
        end
    end

    -- Build all message strings to calculate their visible lengths
    local messages = {}

    -- Title line (includes padding: "  {title}")
    local title_msg = build_message_string('SYSTEM', 'intro_header_title', {title = title})
    table.insert(messages, title_msg)

    -- Macro info line
    if macro_info and macro_info.book and macro_info.page then
        local macro_msg = build_message_string('SYSTEM', 'intro_macrobook', {
            key_color = key_color,
            desc_color = desc_color,
            book = tostring(macro_info.book),
            page = tostring(macro_info.page)
        })
        table.insert(messages, macro_msg)
    end

    -- Lockstyle info line
    if lockstyle_info and lockstyle_info.style then
        local lockstyle_delay = _G.LockstyleConfig and _G.LockstyleConfig.initial_load_delay or 8.0
        local lockstyle_msg = build_message_string('SYSTEM', 'intro_lockstyle', {
            key_color = key_color,
            desc_color = desc_color,
            style = tostring(lockstyle_info.style),
            delay = string.format("%.1f", lockstyle_delay)
        })
        table.insert(messages, lockstyle_msg)
    end

    -- Keybind count line
    if keybind_count > 0 then
        local keybind_msg = build_message_string('SYSTEM', 'intro_keybinds', {
            key_color = key_color,
            desc_color = desc_color,
            count = tostring(keybind_count)
        })
        table.insert(messages, keybind_msg)
    end

    -- UI status line
    local ui_enabled = _G.ui_display_config and _G.ui_display_config.enabled
    if ui_enabled ~= nil then
        local template_key = ui_enabled and 'intro_ui_visible' or 'intro_ui_hidden'
        local ui_msg = build_message_string('SYSTEM', template_key, {
            key_color = key_color,
            desc_color = desc_color
        })
        table.insert(messages, ui_msg)
    end

    -- Fixed separator length (always 74 characters)
    local separator_length = 74
    local separator_line = string.rep("=", separator_length)

    -- Display intro with dynamic separator
    M.send('SYSTEM', 'intro_header_separator', {separator = separator_line})
    M.send('SYSTEM', 'intro_header_title', {title = title})
    M.send('SYSTEM', 'intro_header_separator', {separator = separator_line})

    -- Display macro info if provided
    if macro_info and macro_info.book and macro_info.page then
        M.send('SYSTEM', 'intro_macrobook', {
            key_color = key_color,
            desc_color = desc_color,
            book = tostring(macro_info.book),
            page = tostring(macro_info.page)
        })
    end

    -- Display lockstyle info if provided
    if lockstyle_info and lockstyle_info.style then
        local lockstyle_delay = _G.LockstyleConfig and _G.LockstyleConfig.initial_load_delay or 8.0
        M.send('SYSTEM', 'intro_lockstyle', {
            key_color = key_color,
            desc_color = desc_color,
            style = tostring(lockstyle_info.style),
            delay = string.format("%.1f", lockstyle_delay)
        })
    end

    -- Display keybind count
    if keybind_count > 0 then
        M.send('SYSTEM', 'intro_keybinds', {
            key_color = key_color,
            desc_color = desc_color,
            count = tostring(keybind_count)
        })
    end

    -- Display UI status
    if ui_enabled ~= nil then
        local template_key = ui_enabled and 'intro_ui_visible' or 'intro_ui_hidden'
        M.send('SYSTEM', template_key, {
            key_color = key_color,
            desc_color = desc_color
        })
    end

    -- Display footer separator
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

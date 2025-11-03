---============================================================================
--- Message System - System intro and status messages
---============================================================================
--- @file utils/message_system.lua
--- @author Tetsouo
--- @version 2.0
--- @date Updated: 2025-10-02 - Refactored to eliminate code duplication
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS
local MessageKeybinds = require('shared/utils/messages/message_keybinds')
local MessageSystem = {}

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

--- Build system intro with all optional components
--- @param title string System title
--- @param keybinds table Array of keybind objects
--- @param macro_info table Optional macro info
--- @param lockstyle_info table Optional lockstyle info
--- @param job_name string Optional job tag (auto-detected if nil)
local function build_and_display_intro(title, keybinds, macro_info, lockstyle_info, job_name)
    -- Auto-detect job tag if not provided (e.g., "WAR/SAM", "PLD/BLU")
    job_name = job_name or MessageCore.get_job_tag()

    -- Calculate total width
    local content_width = calculate_content_width(keybinds, macro_info, lockstyle_info, job_name)
    local title_with_spaces = " " .. title .. " "
    local separator_width = math.max(content_width + 4, string.len(title_with_spaces) + 8)
    local separator_line = string.rep("=", separator_width)

    -- Build centered title line
    local title_total_width = separator_width - 2
    local padding_total = title_total_width - string.len(title_with_spaces)
    local padding_left = math.floor(padding_total / 2)
    local padding_right = padding_total - padding_left
    local title_line = string.rep("=", padding_left) .. title_with_spaces .. string.rep("=", padding_right)

    -- Display header
    add_to_chat(Colors.SYSTEM_LOADED, separator_line)
    add_to_chat(Colors.SYSTEM_LOADED, title_line)
    add_to_chat(Colors.SYSTEM_LOADED, separator_line)

    -- Display keybinds
    for _, bind in pairs(keybinds) do
        local formatted_line = MessageKeybinds.format_keybind_line(bind.key, bind.desc)
        add_to_chat(001, formatted_line)
    end

    -- Display macro info if provided
    if macro_info and macro_info.book and macro_info.page then
        local macro_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
        local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)
        local macro_line = string.format("%s[MacroBook]%s %s Book %d Page %d",
            macro_color, desc_color, job_name,
            macro_info.book, macro_info.page)
        add_to_chat(001, macro_line)
    end

    -- Display lockstyle info if provided
    if lockstyle_info and lockstyle_info.style then
        local lockstyle_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
        local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)
        local status = lockstyle_info.enabled and "Enabled" or "Disabled"
        local lockstyle_line = string.format("%s[Lockstyle]%s %s Style %d (%s)",
            lockstyle_color, desc_color, job_name, lockstyle_info.style, status)
        add_to_chat(001, lockstyle_line)
    end

    -- Display footer
    add_to_chat(Colors.SYSTEM_LOADED, separator_line)
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
    local separator = '========================================'
    add_to_chat(159, separator)
    add_to_chat(159, '[COR] FFXI Color Code Test (001-255)')
    add_to_chat(159, separator)
end

--- Display color test sample for a specific code
--- @param code number Color code (1-255)
function MessageSystem.show_color_test_sample(code)
    local color_code = string.char(0x1F, code)
    local sample_text = color_code .. string.format("%03d - Sample Text", code)
    add_to_chat(121, sample_text)  -- Use channel 121 to preserve inline colors
end

--- Display color test footer
function MessageSystem.show_color_test_footer()
    local separator = '========================================'
    add_to_chat(159, separator)
    add_to_chat(159, '[COR] Color test complete!')
    add_to_chat(159, separator)
end

return MessageSystem

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

--- Build system intro with all optional components (SHORT VERSION)
--- @param title string System title
--- @param keybinds table Array of keybind objects
--- @param macro_info table Optional macro info
--- @param lockstyle_info table Optional lockstyle info
--- @param job_name string Optional job tag (auto-detected if nil)
local function build_and_display_intro(title, keybinds, macro_info, lockstyle_info, job_name)
    -- Auto-detect job tag if not provided (e.g., "WAR/SAM", "PLD/BLU")
    job_name = job_name or MessageCore.get_job_tag()

    -- Calculate width based on longest info line
    local max_width = string.len(title) + 4
    local separator_line = string.rep("=", max_width)

    -- Count keybinds
    local keybind_count = 0
    if keybinds then
        for _ in pairs(keybinds) do
            keybind_count = keybind_count + 1
        end
    end

    -- Display header
    add_to_chat(Colors.SYSTEM_LOADED, separator_line)
    add_to_chat(Colors.SYSTEM_LOADED, "  " .. title)
    add_to_chat(Colors.SYSTEM_LOADED, separator_line)

    -- Display macro info if provided
    if macro_info and macro_info.book and macro_info.page then
        local macro_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
        local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)
        local macro_line = string.format("%sMacrobook:%s Book %d | Set %d",
            macro_color, desc_color,
            macro_info.book, macro_info.page)
        add_to_chat(001, macro_line)
    end

    -- Display lockstyle info if provided
    if lockstyle_info and lockstyle_info.style then
        local lockstyle_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
        local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)
        local lockstyle_delay = _G.LockstyleConfig and _G.LockstyleConfig.initial_load_delay or 8.0
        local lockstyle_line = string.format("%sLockstyle:%s Set %d (applying in %.1fs...)",
            lockstyle_color, desc_color, lockstyle_info.style, lockstyle_delay)
        add_to_chat(001, lockstyle_line)
    end

    -- Display keybind count
    if keybind_count > 0 then
        local kb_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
        local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)
        local kb_line = string.format("%sKeybinds:%s %d loaded",
            kb_color, desc_color, keybind_count)
        add_to_chat(001, kb_line)
    end

    -- Display UI status
    local ui_enabled = _G.ui_display_config and _G.ui_display_config.enabled
    if ui_enabled ~= nil then
        local ui_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
        local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)
        local ui_status = ui_enabled and "Visible" or "Hidden"
        local ui_line = string.format("%sUI:%s %s (toggle with //gs c ui)",
            ui_color, desc_color, ui_status)
        add_to_chat(001, ui_line)
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

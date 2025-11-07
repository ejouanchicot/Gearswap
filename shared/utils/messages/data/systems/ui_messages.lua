---============================================================================
--- UI Message Data - UI Control Messages
---============================================================================
--- Pure data file for UI control and status messages
--- Used by new message system (api/messages.lua)
---
--- NOTE: Complex multi-line help menus are dynamically built
---       This template file contains simple UI status messages only
---
--- @file data/systems/ui_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- UI TOGGLE MESSAGES
    ---========================================================================

    toggle = {
        template = "{cyan}[UI]{gray} {component}: {status_color}{status}",
        color = 1
    },

    enabled = {
        template = "{cyan}[UI]{gray} UI {green}Enabled",
        color = 1
    },

    disabled = {
        template = "{cyan}[UI]{gray} UI {gray}Disabled",
        color = 1
    },

    ---========================================================================
    --- UI POSITION MESSAGES
    ---========================================================================

    position_saved = {
        template = "{cyan}[UI]{gray} Settings saved: {green}Position ({x}, {y}) + Display states",
        color = 1
    },

    position_save_failed = {
        template = "{cyan}[UI]{gray} {red}Failed to save position",
        color = 1
    },

    ---========================================================================
    --- UI ERROR MESSAGES
    ---========================================================================

    error = {
        template = "{cyan}[UI ERROR]{gray} {red}{error_text}",
        color = 1
    },

    ---========================================================================
    --- BACKGROUND MESSAGES
    ---========================================================================

    background_preset = {
        template = "{cyan}[UI]{gray} Background preset: {green}{preset_name} {gray}(RGBA: {r},{g},{b},{a})",
        color = 1
    },

    background_rgba = {
        template = "{cyan}[UI]{gray} Background set: {green}RGBA({r},{g},{b},{a})",
        color = 1
    },

    ---========================================================================
    --- SEPARATOR
    ---========================================================================

    separator = {
        template = "{cyan}============================",
        color = 1
    },
}

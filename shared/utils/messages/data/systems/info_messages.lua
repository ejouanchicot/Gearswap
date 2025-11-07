---============================================================================
--- INFO Message Data - Info Command Messages
---============================================================================
--- Pure data file for info command messages (JA/Spell/WS display)
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/info_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- INFO DISPLAY MESSAGES
    ---========================================================================

    entity_header = {
        template = "{lightblue}=== {header} ===",
        color = 1
    },

    entity_name = {
        template = "{color_name}Name: {white}{name}",
        color = 1
    },

    entity_field = {
        template = "{line}",
        color = 1
    },

    entity_footer = {
        template = "{gray}========================================",
        color = 1
    },

    ---========================================================================
    --- INFO COMMAND ERROR MESSAGES
    ---========================================================================

    usage = {
        template = "{red}[INFO] Usage: //gs c info <name>\n{red}[INFO] Example: //gs c info Last Resort\n{red}[INFO] Example: //gs c info Haste\n{red}[INFO] Example: //gs c info Torcleaver",
        color = 167
    },

    not_found = {
        template = "{red}[INFO] Not found: {name}\n{red}[INFO] Searched: Job Abilities, Spells, Weaponskills",
        color = 167
    },
}

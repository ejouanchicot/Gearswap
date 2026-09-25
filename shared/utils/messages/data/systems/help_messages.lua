---============================================================================
--- HELP Message Data - the look of every help screen
---============================================================================
--- Pure data file for shared/utils/messages/help_screen.lua. Every help
--- screen of the project (//gs c help, tb help, ui help, warp help...) is
--- built from these lines, so they all look like //gs c commands:
---
---   (blank)
---   ===================================  mustard
---    TITLE - subtitle                    gold, gray
---   ===================================
---   (blank)
---   >> GROUP (note)                      amber, gray
---      //gs c cmd <param> ...... what     aqua, mustard, darkgray, white
---   (blank)
---      note                               gray
---   ===================================
---   (blank)
---
--- One template per line: a colour code does not survive the chat wrapping
--- a long line. The colour names are ChatPalette's (the player can remap
--- them with //gs c ui chatcolor).
---
--- @file shared/utils/messages/data/systems/help_messages.lua
--- @author Tetsouo
--- @date Created: 2026-09-25
---============================================================================

return {
    blank = {
        template = " ",
        color = 121
    },

    separator = {
        template = "{mustard}{separator}",
        color = 121
    },

    title = {
        template = "{gold} {title}",
        color = 121
    },

    title_subtitle = {
        template = "{gold} {title}{gray} - {subtitle}",
        color = 121
    },

    group = {
        template = "{amber}>> {title}",
        color = 121
    },

    group_note = {
        template = "{amber}>> {title}{gray} ({note})",
        color = 121
    },

    --- Command, placeholders, dot leader, description.
    row = {
        template = "{aqua}   {command}{mustard}{params}{darkgray} {dots} {white}{description}",
        color = 121
    },

    --- Rest of a description too long for one line, under its column.
    row_more = {
        template = "{white}{indent}{description}",
        color = 121
    },

    --- A command alone (an example line), with or without placeholders.
    row_command = {
        template = "{aqua}   {command}",
        color = 121
    },

    row_command_params = {
        template = "{aqua}   {command}{mustard}{params}",
        color = 121
    },

    note = {
        template = "{gray}   {text}",
        color = 121
    },
}

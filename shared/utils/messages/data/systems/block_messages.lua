---============================================================================
--- BLOCK Message Data - the look of every data block
---============================================================================
--- Pure data file for shared/utils/messages/info_block.lua. Status, stats,
--- detail cards and lists are built from these lines, so they all look like
--- the Sortie messages validated in game:
---
---   =====================================  gray
---     TAG :: title                          lightblue, gray, white
---   =====================================
---   Label    : value                        lightblue, gray, white
---   Enabled  : ON                           green / red OFF
---   =====================================
---
--- One template per line: a colour code does not survive the chat wrapping
--- a long line. The colour names are ChatPalette's.
---
--- @file shared/utils/messages/data/systems/block_messages.lua
--- @author Tetsouo
--- @date Created: 2026-09-25
---============================================================================

return {
    separator = {
        template = "{gray}{separator}",
        color = 160
    },

    title = {
        template = "{lightblue}  {tag} {gray}:: {white}{title}",
        color = 1
    },

    --- Value kinds: plain (white), good (green), bad (red), warn (orange),
    --- spell (spell colour), dim (gray), on / off.
    field = {
        template = "{lightblue}{label}{gray} : {white}{value}",
        color = 1
    },

    field_good = {
        template = "{lightblue}{label}{gray} : {green}{value}",
        color = 1
    },

    field_bad = {
        template = "{lightblue}{label}{gray} : {red}{value}",
        color = 1
    },

    field_warn = {
        template = "{lightblue}{label}{gray} : {orange}{value}",
        color = 1
    },

    field_spell = {
        template = "{lightblue}{label}{gray} : {spellcolor}{value}",
        color = 1
    },

    field_dim = {
        template = "{lightblue}{label}{gray} : {value}",
        color = 1
    },

    field_on = {
        template = "{lightblue}{label}{gray} : {green}ON",
        color = 1
    },

    field_off = {
        template = "{lightblue}{label}{gray} : {red}OFF",
        color = 1
    },

    --- A line of the block that is not a field (a list entry, a remark).
    text = {
        template = "{white}{text}",
        color = 1
    },

    text_dim = {
        template = "{gray}{text}",
        color = 1
    },

    text_bad = {
        template = "{red}{text}",
        color = 1
    },
}

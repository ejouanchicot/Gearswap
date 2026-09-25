---============================================================================
--- SORTIE Message Data - Sortie commands (main + GEO alt driven by Silmaril)
---============================================================================
--- Pure data file for //gs c sortie ... and the GEO alt's //gs c escort.
--- Used by the message API (api/messages.lua) through formatters/system/message_sortie.lua
---
--- Long messages are blocks: separator, title, one "Label : value" line per
--- field, separator. One template per line, because a colour code does not
--- survive the chat wrapping a long line.
---
--- Colours: titles and labels light blue, names white, spells cyan, job
--- abilities yellow, ON green / OFF red, separators gray.
---
--- @file shared/utils/messages/data/systems/sortie_messages.lua
--- @author Tetsouo
--- @date Created: 2026-09-24
---============================================================================

return {
    ---========================================================================
    --- BLOCK PARTS (//gs c sortie <target>, escort, list)
    ---========================================================================

    separator = {
        template = "{gray}{separator}",
        color = 160
    },

    --- Block title, e.g. "SORTIE :: Degei (Melee)".
    title = {
        template = "{lightblue}  SORTIE {gray}:: {white}{title}",
        color = 1
    },

    --- Field whose value is a name or a description.
    field = {
        template = "{lightblue}{label}{gray} : {white}{value}",
        color = 1
    },

    --- Field whose value is a spell.
    field_spell = {
        template = "{lightblue}{label}{gray} : {spellcolor}{value}",
        color = 1
    },

    --- Field saying the alt's automation is running.
    field_on = {
        template = "{lightblue}{label}{gray} : {green}ON",
        color = 1
    },

    --- Field saying the alt's automation is stopped.
    field_stopped = {
        template = "{lightblue}{label}{gray} : {red}OFF",
        color = 1
    },

    --- One line of the target list: name, aliases, Indi- and setup.
    list_entry = {
        template = "{white}{name}{gray}{aliases} : {spellcolor}{indi}{gray}, {summary}",
        color = 1
    },

    --- Last line of the target list: the orders that are not targets.
    list_orders = {
        template = "{lightblue}Orders{gray} : {white}escort{gray} [Indi-X], {white}off{gray}, {white}judgment{gray}, {white}fullcircle",
        color = 1
    },

    ---========================================================================
    --- ONE-LINE MESSAGES
    ---========================================================================

    --- The alt's automation was stopped.
    alt_off = {
        template = "{gray}[{lightblue}SORTIE{gray}] {lightblue}{alt} {red}OFF",
        color = 1
    },

    --- The alt was told to use a job ability or weaponskill.
    alt_action = {
        template = "{gray}[{lightblue}SORTIE{gray}] {lightblue}{alt}{gray} > {yellow}{action}",
        color = 1
    },

    --- Unknown target name.
    unknown_target = {
        template = "{gray}[{lightblue}SORTIE{gray}] {red}Unknown target {white}{name}{gray} (//gs c sortie list)",
        color = 1
    },

    ---========================================================================
    --- GEO ALT (//gs c escort ...)
    ---========================================================================

    --- Escort received by the alt: what it casts and when it follows.
    alt_escort = {
        template = "{gray}[{lightblue}ESCORT{gray}] {full_circle}{spellcolor}{indi}{gray}, {follow}",
        color = 1
    },
}

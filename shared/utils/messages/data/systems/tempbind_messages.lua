---============================================================================
--- TEMPBIND Message Data - //gs c tb (temporary keybinds)
---============================================================================
--- Pure data file, used through formatters/system/message_tempbind.lua.
--- Keys light blue, commands white, problems red, separators gray.
---
--- @file shared/utils/messages/data/systems/tempbind_messages.lua
--- @author Tetsouo
--- @date Created: 2026-09-24
---============================================================================

return {
    separator = { template = "{gray}{separator}", color = 160 },
    title = { template = "{lightblue}  TEMP BINDS {gray}:: {white}{title}", color = 1 },
    row = { template = "{lightblue}{key}{gray} : {white}{command}", color = 1 },
    -- Help screen: lines arrive pre-coloured with the //gs c help palette
    -- (message_commands.show_commands_list), which the engine tags lack.
    help_line = { template = "{text}", color = 1 },

    added = { template = "{gray}[{lightblue}TB{gray}] {lightblue}{key}{gray} > {white}{command}", color = 1 },
    taken = { template = "{gray}[{lightblue}TB{gray}] {red}{key} is already used by {white}{owner}", color = 1 },
    taken_hint = { template = "{gray}     another key, or no key, or: tb force {key_raw} ...", color = 1 },
    problem = { template = "{gray}[{lightblue}TB{gray}] {red}{text}", color = 1 },
    unknown = { template = "{gray}[{lightblue}TB{gray}] {white}{key}{gray}: no temporary bind", color = 1 },
    not_found = { template = "{gray}[{lightblue}TB{gray}] {white}{name}{red} not found nearby", color = 1 },
    removed = { template = "{gray}[{lightblue}TB{gray}] {lightblue}{key}{gray} removed", color = 1 },
    cleared = { template = "{gray}[{lightblue}TB{gray}] {white}{count}{gray} temporary bind(s) removed", color = 1 },
}

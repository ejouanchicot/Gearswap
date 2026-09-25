---============================================================================
--- Info Message Formatter - Centralized Info Command Messages
---============================================================================
--- Provides formatted messages for the info command (JA/Spell/WS display).
--- Handles all info-related output including headers, fields, and errors.
--- The card is an InfoBlock, the usage a HelpScreen, not found a template.
---
--- @file    shared/utils/messages/formatters/ui/message_info.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageInfo = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local M = require('shared/utils/messages/api/messages')

---============================================================================
--- INFO DISPLAY MESSAGES
---============================================================================

--- One entity card (//gs c info <name>), as a data block.
--- @param name string Entity name
--- @param kind string "Job ability", "Spell" or "Weapon skill"
--- @param fields table {{label, value, kind}, ...} (empty fields already left out)
function MessageInfo.show_entity(name, kind, fields)
    table.insert(fields, 1, {'Kind', kind})
    require('shared/utils/messages/info_block').show({tag = 'INFO', title = name, fields = fields})
end

---============================================================================
--- INFO COMMAND ERROR MESSAGES
---============================================================================

--- Show info usage help
function MessageInfo.show_usage()
    require('shared/utils/messages/help_screen').show({
        title = 'INFO', subtitle = 'Spell, ability or weapon skill details',
        groups = {
            {title = 'COMMAND', rows = {
                {'//gs c info ', '<name>', 'Show its details'},
            }},
            {title = 'EXAMPLES', rows = {
                {'//gs c info Last Resort'},
                {'//gs c info Haste'},
                {'//gs c info Torcleaver'},
            }},
        },
    })
end

--- Show info not found error
--- @param name string Entity name that was not found
function MessageInfo.show_not_found(name)
    M.send('INFO', 'not_found', {name = name})
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageInfo

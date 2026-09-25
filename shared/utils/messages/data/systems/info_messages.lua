---============================================================================
--- INFO Message Data - Info Command Messages
---============================================================================
--- Pure data file for info command messages (JA/Spell/WS display)
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/systems/info_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- INFO DISPLAY MESSAGES
    ---========================================================================

    ---========================================================================
    --- INFO COMMAND ERROR MESSAGES
    ---========================================================================

    not_found = {
        template = "{red}[INFO] Not found: {name}\n{red}[INFO] Searched: Job Abilities, Spells, Weaponskills",
        color = 167
    },
}

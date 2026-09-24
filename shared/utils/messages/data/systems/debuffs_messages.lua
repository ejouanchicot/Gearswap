---============================================================================
--- DEBUFFS Message Data - Debuff Blocking Messages
---============================================================================
--- Pure data file for debuff status ailment blocking messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- NOTE: Most debuff messages are dynamically built with inline color codes
---       due to complex conditional logic. This template file only contains
---       the separator pattern.
---
--- @file shared/utils/messages/data/systems/debuffs_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- SEPARATOR
    ---========================================================================

    separator = {
        template = "{gray}==================================================",
        color = 1
    },
}

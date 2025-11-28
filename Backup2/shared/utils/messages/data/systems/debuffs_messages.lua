---============================================================================
--- DEBUFFS Message Data - Debuff Blocking Messages
---============================================================================
--- Pure data file for debuff status ailment blocking messages
--- Used by new message system (api/messages.lua)
---
--- NOTE: Most debuff messages are dynamically built with inline color codes
---       due to complex conditional logic. This template file only contains
---       the separator pattern.
---
--- @file data/systems/debuffs_messages.lua
--- @author Tetsouo
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

---============================================================================
--- COOLDOWNS Message Data - Cooldown Display Messages
---============================================================================
--- Pure data file for cooldown and recast timing messages
--- Used by new message system (api/messages.lua)
---
--- NOTE: Most cooldown messages are dynamically built with inline color codes
---       due to complex conditional logic. This template file only contains
---       simple separator patterns.
---
--- @file data/systems/cooldowns_messages.lua
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

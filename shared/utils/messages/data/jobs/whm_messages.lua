---============================================================================
--- WHM Message Data - White Mage Messages
---============================================================================
--- Pure data file for WHM job messages
--- Used by new message system (api/messages.lua)
---
--- @file data/jobs/whm_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- MODULE LOAD WARNINGS
    ---========================================================================

    curemanager_not_loaded = {
        template = "{red}[WHM] WARNING: CureManager not loaded - auto-tier Cure disabled",
        color = 1
    }
}

---============================================================================
--- WHM Message Data - White Mage Messages
---============================================================================
--- Pure data file for WHM job messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/jobs/whm_messages.lua
--- @author Tetsouo
--- @version 1.0
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

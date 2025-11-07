---============================================================================
--- COR Message Data - Corsair Messages
---============================================================================
--- Pure data file for COR job messages
--- Used by new message system (api/messages.lua)
---
--- @file data/jobs/cor_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- PARTYTRACKER MODULE ERRORS
    ---========================================================================

    rolltracker_load_failed = {
        template = "{red}[COR PartyTracker] WARNING: Failed to load RollTracker - roll detection disabled!",
        color = 1
    },

    packets_load_failed = {
        template = "{red}[COR PartyTracker] ERROR: Failed to load packets library - party job detection disabled!",
        color = 1
    },

    resources_load_failed = {
        template = "{red}[COR PartyTracker] ERROR: Failed to load resources library - party job detection disabled!",
        color = 1
    }
}

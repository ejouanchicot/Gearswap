---============================================================================
--- COR Message Data - Corsair Messages
---============================================================================
--- Pure data file for COR job messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/jobs/cor_messages.lua
--- @author Tetsouo
--- @version 1.0
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

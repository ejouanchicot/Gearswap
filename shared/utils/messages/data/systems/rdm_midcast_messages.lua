---============================================================================
--- RDM_MIDCAST Message Data - RDM Midcast Debug Messages
---============================================================================
--- Pure data file for RDM midcast debug messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- NOTE: Most RDM midcast messages are dynamically built with multi-line output
---       This template file contains only simple separator patterns
---
--- @file shared/utils/messages/data/systems/rdm_midcast_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- SEPARATOR
    ---========================================================================

    separator = {
        template = "{gray}=====================================================================",
        color = 8
    },
}

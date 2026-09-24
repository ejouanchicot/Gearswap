---============================================================================
--- RUN Message Data - Rune Fencer Messages
---============================================================================
--- Pure data file for RUN job messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/jobs/run_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-12
---============================================================================

return {
    ---========================================================================
    --- BUFF EXPIRATION WARNINGS
    ---========================================================================

    -- Valiance expired (critical defensive buff)
    valiance_expired = {
        template = "{red}==========================================================================\n{red}                     [{yellow}WARNING{red}]{white} VALIANCE OFF {red}[{yellow}WARNING{red}]\n{red}==========================================================================",
        color = 1  -- Base color (inline colors handle the rest)
    },

    -- Vallation expired (critical defensive buff)
    vallation_expired = {
        template = "{red}==========================================================================\n{red}                     [{yellow}WARNING{red}]{white} VALLATION OFF {red}[{yellow}WARNING{red}]\n{red}==========================================================================",
        color = 1  -- Base color (inline colors handle the rest)
    }
}

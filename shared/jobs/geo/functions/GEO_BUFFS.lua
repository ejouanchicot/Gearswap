---============================================================================
--- GEO Buffs Module - Buff Change Handling
---============================================================================
--- Handles buff gain/loss events for Geomancer job.
--- Manages buff-specific gear swaps (Doom, etc.).
---
--- @file GEO_BUFFS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-09
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- BUFF HOOKS
---============================================================================

function job_buff_change(buff, gain, eventArgs)
    -- Doom: HIGHEST PRIORITY - Must override everything
    if buff == 'doom' then
        local is_doomed = buffactive['doom']

        if is_doomed then
            equip(sets.buff.Doom)
            -- Disable slots to prevent other gear swaps from overwriting Doom gear
            disable('neck', 'ring1', 'ring2', 'waist')
            MessageFormatter.show_warning("DOOM detected! Equipping Doom gear.")
        else
            -- Enable slots before restoring gear
            enable('neck', 'ring1', 'ring2', 'waist')
            handle_equipping_gear(player.status)
            MessageFormatter.show_success("Doom removed.")
        end
        return  -- Stop processing - Doom takes absolute priority
    end

    -- GEO-SPECIFIC BUFF CHANGE LOGIC

    -- Entrust buff
    if buff == "Entrust" and gain then
        -- Entrust active - next Indi spell can be cast on party member
        -- Visual indicator could be added here
    end
end
---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_buff_change = job_buff_change

-- Export module
local GEO_BUFFS = {}
GEO_BUFFS.job_buff_change = job_buff_change

return GEO_BUFFS

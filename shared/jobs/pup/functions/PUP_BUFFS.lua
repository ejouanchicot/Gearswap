---============================================================================
--- PUP Buffs Module - Buff Change Handling
---============================================================================
--- Handles buff gain/loss events for Beastmaster.
---
--- @file jobs/pup/functions/PUP_BUFFS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- BUFF CHANGE HOOK
---============================================================================

--- Called when buff is gained or lost
---
--- @param buff string Buff name
--- @param gain boolean True if buff gained, false if lost
--- @return void
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

    -- No PUP-specific buff logic required currently
    -- Mote-Include handles standard buff changes (Haste, Slow, etc.)
end
---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_buff_change = job_buff_change

-- Export as module
return {
    job_buff_change = job_buff_change
}

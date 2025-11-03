---============================================================================
--- RUN Buff Management Module - Buff Change Handling & Automation
---============================================================================
--- Handles Rune Fencer buff events and automatic gear adjustments:
---   • Cover buff activation/deactivation
---   • Doom detection and resistance gear
---   • Automatic gear swapping on buff changes
---   • Status restoration when buffs expire
---
--- @file    jobs/run/functions/RUN_BUFFS.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-03
--- @requires Tetsouo architecture
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Message formatter for buff notifications
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- BUFF CHANGE HOOK
---============================================================================

--- Called when buffs are gained or lost
--- Handles automatic gear swapping for Cover and Doom buffs.
---
--- @param buff string Buff name (e.g., "Cover", "Doom")
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

    -- Cover: Equip special Cover gear (tank damage for party member)
    if buff == 'Cover' then
        if gain then
            equip(sets.buff.Cover)
        else
            -- Return to normal gear when Cover expires
            handle_equipping_gear(player.status)
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_buff_change = job_buff_change

-- Export as module (for future require() usage)
return {
    job_buff_change = job_buff_change
}

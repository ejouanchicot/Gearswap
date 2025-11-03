---============================================================================
--- DRK Buff Management Module - Buff Change Handling & Automation
---============================================================================
--- Handles Dark Knight buff events and automatic gear adjustments:
---   • Last Resort buff activation/deactivation
---   • Souleater buff management
---   • Doom detection and resistance gear
---   • Automatic gear swapping on buff changes
---   • Status restoration when buffs expire
---
--- @file    DRK_BUFFS.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-23
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
--- Handles automatic gear swapping and pending flag cleanup for DRK buffs.
---
--- @param buff string Buff name (e.g., "Last Resort", "Doom")
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

    -- Dark Seal: Equipment adjustments + pending flag cleanup
    if buff == 'Dark Seal' then
        if gain then
            -- Buff gained - clear pending flag (buff now in buffactive)
            _G.drk_dark_seal_pending = false
            -- Equipment update for Dark Seal engaged set
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        else
            -- Buff lost - clear pending flag and update equipment
            _G.drk_dark_seal_pending = false
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
    end

    -- Nether Void: Equipment adjustments + pending flag cleanup
    if buff == 'Nether Void' then
        if gain then
            -- Buff gained - clear pending flag (buff now in buffactive)
            _G.drk_nether_void_pending = false
            -- Equipment update for Nether Void engaged set
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        else
            -- Buff lost - clear pending flag and update equipment
            _G.drk_nether_void_pending = false
            if not midaction() then
                handle_equipping_gear(player.status)
            end
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

---============================================================================
--- THF Buff Management Module - Buff Change Handling
---============================================================================
--- Handles buff gain/loss events for Thief job.
---
--- Features:
---   • Sneak Attack buff tracking (gain/loss + pending flag management)
---   • Trick Attack buff tracking (gain/loss + pending flag management)
---   • Aftermath Lv.3 detection (REMA weapon bonus)
---   • Automatic gear refresh on buff changes
---   • Future: Treasure Hunter level tracking
---
--- Dependencies:
---   • Mote-Include (provides base buff change handling)
---   • handle_equipping_gear (Mote function for gear refresh)
---
--- @file    jobs/thf/functions/THF_BUFFS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- BUFF HOOKS
---============================================================================

--- Called when buffs are gained or lost
--- @param buff string Buff name
--- @param gain boolean True if gained, false if lost
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

    -- Detect Aftermath Lv.3 changes and refresh engaged set
    if buff == "Aftermath: Lv.3" then
        -- Force refresh of engaged set to apply PDTAFM3 or revert to normal set
        handle_equipping_gear(player.status)
    end

    -- Handle SA/TA buff changes
    if buff == 'Sneak Attack' then
        if gain then
            -- Buff gained - clear pending flag (buff now in buffactive)
            _G.thf_sa_pending = false
            -- Equipment update for engaged SA set
            -- WS precast uses pending flag to detect SA before it's in buffactive
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        else
            -- Buff lost - clear pending flag and update equipment
            _G.thf_sa_pending = false
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
    elseif buff == 'Trick Attack' then
        if gain then
            -- Buff gained - clear pending flag (buff now in buffactive)
            _G.thf_ta_pending = false
            -- Equipment update for engaged TA set
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        else
            -- Buff lost - clear pending flag and update equipment
            _G.thf_ta_pending = false
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
    end

    -- Future: TH level detection and tracking
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make functions available globally for GearSwap
_G.job_buff_change = job_buff_change

-- Also export as module
local THF_BUFFS = {}
THF_BUFFS.job_buff_change = job_buff_change

return THF_BUFFS

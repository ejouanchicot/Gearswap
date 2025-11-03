---============================================================================
--- RDM Buffs Module - Buff Change Management
---============================================================================
--- Handles buff gain/loss for Red Mage job.
--- Tracks important buffs: Chainspell, Saboteur, Enspells, Composure, etc.
---
--- @file RDM_BUFFS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

--- Handle buff change events
--- @param buff string Buff name
--- @param gain boolean True if buff gained, false if lost
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

    -- Track Chainspell buff (fast cast burst mode)
    if buff == "Chainspell" then
        if gain then
            -- Message already shown in PRECAST (more descriptive)
            -- MessageFormatter.show_ja_activated("Chainspell", "Rapid casting, zero recast")
        else
            MessageFormatter.show_ja_ended("Chainspell")
        end
    end

    -- Track Composure buff - DISABLED (message already shown in PRECAST)
    --[[
    if buff == "Composure" then
        if gain then
            -- Message already shown in PRECAST (more descriptive)
        end
    end
    ]]

    -- Track Convert buff - DISABLED (message already shown in PRECAST)
    --[[
    if buff == "Convert" then
        if gain then
            -- Message already shown in PRECAST (more descriptive)
        end
    end
    ]]
end

-- Export to global scope
_G.job_buff_change = job_buff_change

-- Export module
local RDM_BUFFS = {}
RDM_BUFFS.job_buff_change = job_buff_change

return RDM_BUFFS

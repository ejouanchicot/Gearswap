---============================================================================
--- BLM Buffs Module - Buff Change Handling
---============================================================================
--- Handles buff gain/loss events for Black Mage job.
--- Tracks buffs like Manawall, Manafont, Elemental Seal.
---
--- @file BLM_BUFFS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
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

    -- BLM-SPECIFIC BUFF CHANGE LOGIC

    -- Manawall buff
    if buff == 'Manawall' then
        if gain then
            -- Manawall active - use defensive gear
        else
            -- Manawall ended
        end
    end

    -- Manafont buff
    if buff == 'Manafont' then
        if gain then
            -- Manafont active - fast casting mode
        else
            -- Manafont ended
        end
    end

    -- Elemental Seal buff
    if buff == 'Elemental Seal' then
        if gain then
            -- Elemental Seal active - accuracy boost for magic
        else
            -- Elemental Seal ended
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_buff_change = job_buff_change

-- Export module
local BLM_BUFFS = {}
BLM_BUFFS.job_buff_change = job_buff_change

return BLM_BUFFS

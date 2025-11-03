---============================================================================
--- BRD Buffs Module - Buff Change Management
---============================================================================
--- Handles buff gain/loss for Bard job.
--- Tracks important buffs: Soul Voice, Nightingale, Troubadour, Pianissimo, etc.
--- Integrates with Song Tracker for bullet-proof song detection.
---
--- @file BRD_BUFFS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

-- Load message formatter for BRD messages
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

    -- Track Soul Voice buff (song power boost)
    -- DISABLED: Soul Voice message (activation)
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- "ended" messages still handled here (buff system doesn't duplicate these)
    if buff == 'Soul Voice' then
        if gain then
            -- DISABLED: Universal system handles activation
            -- MessageFormatter.show_ja_activated("Soul Voice", "Song power boost!")
        else
            MessageFormatter.show_ja_ended("Soul Voice")
        end
    end

    -- Track Nightingale buff (casting time reduction)
    -- DISABLED: Message already shown in PRECAST (more descriptive)
    -- Showing "active" here would be redundant
    --[[
    if buff == 'Nightingale' then
        if gain then
            MessageFormatter.show_ja_active("Nightingale")
        end
    end
    ]]

    -- Track Troubadour buff (song duration extension)
    -- DISABLED: Message already shown in PRECAST (more descriptive)
    -- Showing "active" here would be redundant
    --[[
    if buff == 'Troubadour' then
        if gain then
            MessageFormatter.show_ja_active("Troubadour")
        end
    end
    ]]
end

-- Export to global scope
_G.job_buff_change = job_buff_change

-- Export module
local BRD_BUFFS = {}
BRD_BUFFS.job_buff_change = job_buff_change

return BRD_BUFFS

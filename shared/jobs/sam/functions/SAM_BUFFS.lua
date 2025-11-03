---============================================================================
--- SAM Buffs Module - Buff Change Handling
---============================================================================
--- @file SAM_BUFFS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')

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

    -- Track SAM-specific buffs in state
    if state and state.Buff and state.Buff[buff] ~= nil then
        state.Buff[buff] = gain
        handle_equipping_gear(player.status)
    end

    -- Hasso OFF warning (from Timara: audio + message)
    if buff == 'Hasso' and not gain then
        MessageFormatter.show_warning('==================Hasso OFF==================!', 'SAM')

        -- Play Hasso OFF sound (if file exists)
        local sound_path = windower.windower_path .. 'addons/GearSwap/data/sounds/hasso.wav'
        local sound_file = io.open(sound_path, "r")
        if sound_file then
            sound_file:close()
            windower.play_sound(sound_path)
        end
    end

    -- Aftermath Lv.3 tracking with countdown timers (from Timara)
    if buff == 'Aftermath: Lv.3' then
        if gain then
            -- AM3 gained: Create 180s timer with countdowns at 60s, 30s, 10s
            MessageFormatter.show_success('Aftermath Lv.3 active!', 'SAM')
            send_command('timers create "Aftermath: Lv.3" 180 down')
            send_command('wait 120;input /echo Aftermath: Lv.3 [WEARING OFF IN 60 SEC.]')
            send_command('wait 150;input /echo Aftermath: Lv.3 [WEARING OFF IN 30 SEC.]')
            send_command('wait 170;input /echo Aftermath: Lv.3 [WEARING OFF IN 10 SEC.]')
        else
            -- AM3 lost: Delete timer
            MessageFormatter.show_warning('==========AM3: [OFF]==========', 'SAM')
            send_command('timers delete "Aftermath: Lv.3"')
        end
    end
end
---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_buff_change = job_buff_change

local SAM_BUFFS = {}
SAM_BUFFS.job_buff_change = job_buff_change

return SAM_BUFFS

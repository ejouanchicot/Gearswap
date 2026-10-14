--============================================================================
-- CastHold - LOCAL ADDITION, not part of the original addon
--============================================================================
-- No movement while the character casts a spell.
--
-- The desktop program stops sending run orders once it knows the character
-- casts (Combat "Allow Interruptions" and Fast Follow "Interrupt" unticked),
-- but it never sends a stop, and it only knows on the game's answer. A run
-- order sent just before keeps the character running for up to 2 seconds
-- (Moving.lua: "no input after 2 sec so stop"): the spell is interrupted.
--
-- This file wraps two of the addon's functions, nothing of the addon's own
-- files is changed:
--   input_message  a spell sent by the program: stop now, hold HOLD_ON_SEND
--   movement       does nothing while a hold runs
-- and reads the character's own cast packets: a cast that starts holds for
-- its cast time, a cast that ends or is interrupted lets go.
--
-- After an addon update: put this file back in lib/ and the line
--   require 'lib./CastHold'
-- back at the end of the addon's main file (install.py does both).
--============================================================================

do
    local HOLD_ON_SEND = 1.5     -- seconds, until the game answers that the cast started
    local AFTER_CAST = 0.5       -- seconds added to a spell's cast time
    local CAST_START, CAST_INTERRUPTED = 24931, 28787

    local res = require('resources')
    local hold_until = 0

    local function hold(seconds)
        hold_until = os.clock() + seconds
        if seconds > 0 then player_run(false) end
    end

    local addon_movement = movement
    function movement()
        if os.clock() < hold_until then return end
        return addon_movement()
    end

    local addon_input = input_message
    function input_message(type, ...)
        if type == 'Magic' then hold(HOLD_ON_SEND) end
        return addon_input(type, ...)
    end

    -- this character's id, kept: the action packets of the whole zone come here
    local my_id = nil
    local function forget() my_id = nil end
    windower.register_event('login', forget)
    windower.register_event('logout', forget)

    windower.register_event('incoming chunk', function(id, data)
        if id ~= 0x028 then return end
        if not my_id then
            local me = windower.ffxi.get_player()
            my_id = me and me.id
            if not my_id then return end
        end
        if data:unpack('I', 6) ~= my_id then return end
        local act = windower.packets.parse_action(data)
        if not act then return end
        if act.category == 4 or (act.category == 8 and act.param == CAST_INTERRUPTED) then
            hold(0)
        elseif act.category == 8 and act.param == CAST_START then
            local action = act.targets and act.targets[1] and act.targets[1].actions and act.targets[1].actions[1]
            local spell = action and res.spells[action.param]
            hold((spell and spell.cast_time or 3) + AFTER_CAST)
        end
    end)
end

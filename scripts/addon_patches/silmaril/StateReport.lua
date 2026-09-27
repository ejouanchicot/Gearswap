--============================================================================
-- StateReport - LOCAL ADDITION, not part of the original addon
--============================================================================
-- Tells the GearSwap of every box when this box's automation state changes
-- (actions on/off, follow and its leader, mirror) and how a mirror is going
-- (step, NPC, results), whatever sent the order:
-- a key, a //sm command typed by hand, a macro or the desktop program. The
-- main's alt window shows that real state instead of the last order it sent.
--
-- The state is polled rather than hooked: some of it is written straight to
-- the addon's locals (Mirror.lua turns mirror_on off after a single mirror),
-- which a wrapped setter would miss.
--
--   //sm report   send the current state now (GearSwap asks at each load)
--
-- It also hides the addon's own boxes (HIDE_ADDON_BOXES below): the alt
-- window shows their content.
--
-- After an addon update: put this file back in lib/ and the line
--   require 'lib./StateReport'
-- back at the end of the addon's main file.
--
-- Needs the "send" addon, as the GearSwap box group already does.
--============================================================================

do
    local POLL_EVERY = 0.5 -- seconds
    local last_sent = nil

    -- The character's name, read once: get_player() builds a large table
    -- (buffs, skills...) and the mirror check runs every frame.
    local my_name = nil
    local function name()
        if not my_name then
            local player = windower.ffxi.get_player()
            my_name = player and player.name or nil
        end
        return my_name
    end
    windower.register_event('login', function() my_name = nil end)
    windower.register_event('logout', function() my_name = nil end)

    -- "<name> <on|off> <leader|off> <on|off>"
    local function current(name)
        local leader = 'off'
        if get_following() then
            local target = get_fast_follow_target()
            leader = (target and target.name) or 'on'
        end
        return string.format('%s %s %s %s', name,
            get_enabled() and 'on' or 'off', leader,
            get_mirror_on() and 'on' or 'off')
    end

    local function report(force)
        local me = name()
        if not me then return end
        local state = current(me)
        if not force and state == last_sent then return end
        last_sent = state
        windower.send_command('send @all gs c altreport ' .. state)
    end

    -- Mirror progress, as the addon's own boxes show it: the step of this
    -- box ("Recording" on the one that records, "Injecting ... (2 of 5)" /
    -- "Trading..." on the ones that replay) with the NPC, then the results
    -- the desktop program sends back. Spaces become "_" so each field stays
    -- one word on the command line.
    local last_phase = nil

    local function word(text)
        text = tostring(text or ''):gsub('%s+', '_')
        return text ~= '' and text or '-'
    end

    local function report_phase()
        local me = name()
        if not me then return end
        local phase = '-'
        if get_mirroring() or get_injecting() then
            local target = get_mirror_target()
            phase = word(get_mirroring_state()) .. ' ' .. word(target and target.name)
        end
        local line = me .. ' phase ' .. phase
        if line == last_phase then return end
        last_phase = line
        windower.send_command('send @all gs c altmirror ' .. line)
    end

    -- "Name,Status|Name,Status", sent each time the program updates them.
    -- Wrapping the global works: Connection.lua looks it up at each call.
    local original_results = mirror_results
    mirror_results = function(param)
        original_results(param)
        pcall(function()
            local me = name()
            if me and param then
                windower.send_command('send @all gs c altmirror ' .. me .. ' results ' .. word(param))
            end
        end)
    end

    local function tick()
        pcall(report, false) -- an error must not stop the loop
        coroutine.schedule(tick, POLL_EVERY)
    end

    -- Mirror steps can last less than the poll: checked every frame (three
    -- getters and a string compare; a command goes out only on a change).
    windower.register_event('prerender', function()
        pcall(report_phase)
    end)

    -- The addon's own boxes (status box at the top, "Mirroring Actions",
    -- "Mirroring Results") are replaced by a box that draws nothing: the
    -- GearSwap alt window shows the same. Set to false to get them back.
    local HIDE_ADDON_BOXES = true

    if HIDE_ADDON_BOXES then
        local blank = setmetatable({}, {__index = function() return function() end end})
        for _, pair in ipairs({
            {get_sm_window, set_sm_window},
            {get_npc_window, set_npc_window},
            {get_result_window, set_result_window},
        }) do
            pcall(function() -- a failure here must not stop the addon loading
                local box = pair[1]()
                if box then box:hide() end
                pair[2](blank)
            end)
        end
    end

    windower.register_event('addon command', function(input)
        if input and input:lower() == 'report' then
            last_phase = nil
            report(true)
        end
    end)

    coroutine.schedule(tick, POLL_EVERY)
end

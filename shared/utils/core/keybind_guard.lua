---  ═══════════════════════════════════════════════════════════════════════════
---   Keybind Guard - re-assert the job's keys shortly after a load
---  ═══════════════════════════════════════════════════════════════════════════
---   A bind that never takes effect is invisible. The job loads, //gs c answers,
---   the HUD shows the row, and only the key is dead - which is what made this
---   take so long to pin down. It was confirmed on PLD: with ^numpad9 unbound,
---   `//gs c cyclestate HybridMode` still cycled the state, so GearSwap was
---   fine and the bind alone was missing.
---
---   The commands are sent; they do not always land. Every bind goes out as a
---   console command through Windower's queue, and a load fires the whole list
---   in one burst - on top of the unbind burst the outgoing job file just
---   queued from its own file_unload. Ordering between a dying sandbox's
---   commands and the new one's is not ours to control: it lives in Hook.dll.
---
---   So rather than try to win that race, this re-sends the binds once the
---   console has gone quiet. Binding an already-bound key overwrites it, so a
---   load where nothing was lost pays a few silent commands and changes
---   nothing.
---
---   @file    shared/utils/core/keybind_guard.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-22
---  ═══════════════════════════════════════════════════════════════════════════

local KeybindGuard = {}

--- Long enough for the load's own burst, and the outgoing job's, to have been
--- processed. Short enough that a key is never dead for long.
local REASSERT_DELAY = 2.0

--- Invalidates a pending re-assert when another load starts. Kept on
--- `windower`, which outlives the sandbox: after a job change the scheduled
--- coroutine of the previous environment still runs, and would otherwise lay
--- down the previous job's keys over the new ones.
windower._keybind_guard_seq = windower._keybind_guard_seq or 0

--- The binds the job wants down right now.
--- PLD and THF filter theirs by subjob through get_active_binds(); the others
--- bind their whole list. Asking in that order gives each job the same answer
--- its own bind_all() would.
--- @param keybinds table The job's keybind module
--- @return table|nil List of {key, command} entries
local function desired_binds(keybinds)
    if type(keybinds.get_active_binds) == 'function' then
        local ok, list = pcall(keybinds.get_active_binds)
        if ok and type(list) == 'table' then
            return list
        end
    end
    if type(keybinds.binds) == 'table' then
        return keybinds.binds
    end
    return nil
end

--- Schedule one silent re-assert of the current job's keybinds.
--- Called from INIT_SYSTEMS, which runs after Mote has already run user_setup()
--- and therefore after bind_all().
--- @return void
function KeybindGuard.schedule()
    windower._keybind_guard_seq = windower._keybind_guard_seq + 1
    local my_seq = windower._keybind_guard_seq

    coroutine.schedule(function()
        if my_seq ~= windower._keybind_guard_seq then
            return
        end

        local job = player and player.main_job
        if not job then
            return
        end

        local keybinds = _G[job .. 'Keybinds']
        if type(keybinds) ~= 'table' then
            return
        end

        local list = desired_binds(keybinds)
        if not list then
            return
        end

        for _, bind in ipairs(list) do
            if bind.key and bind.command then
                local KM = rawget(_G, 'KeybindManager')
                local line = KM and KM.bind_line(bind) or ('gs c ' .. bind.command)
                pcall(send_command, 'bind ' .. bind.key .. ' ' .. line)
            end
        end
    end, REASSERT_DELAY)
end

_G.KeybindGuard = KeybindGuard

return KeybindGuard

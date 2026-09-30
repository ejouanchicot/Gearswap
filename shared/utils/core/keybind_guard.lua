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
---   Since 2026-09-30 only the keys the load actually sent are re-sent (the
---   others were already down and untouched), through the paced queue
---   (command_queue.lua), after it has emptied.
---
---   @file    shared/utils/core/keybind_guard.lua
---   @author  ejouanchicot
---   @version 1.1
---   @date    Created: 2026-09-22 | Updated: 2026-09-30
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

--- Send again the keys this load sent (KeybindManager records them), once
--- the paced queue has gone quiet. Keys a load did not touch were already
--- down and are left alone: re-sending every key was a burst of its own.
--- @param my_seq number Guard generation that scheduled this
local function reassert(my_seq)
    if my_seq ~= windower._keybind_guard_seq then return end
    local Queue = require('shared/utils/core/command_queue')
    if Queue.pending() > 0 then
        coroutine.schedule(function() reassert(my_seq) end, 1.0)
        return
    end
    for key, line in pairs(windower._keybind_sent_this_load or {}) do
        -- The key may have been unbound or re-bound since: only what is still
        -- recorded as down, with this command, goes out again.
        local down = windower._keybind_manager_bound or {}
        if down[key] == line then Queue.push(key, 'bind ' .. key .. ' ' .. line) end
    end
    windower._keybind_sent_this_load = {}
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

        reassert(my_seq)
    end, REASSERT_DELAY)
end

_G.KeybindGuard = KeybindGuard

return KeybindGuard

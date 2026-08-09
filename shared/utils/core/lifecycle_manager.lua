---  ═══════════════════════════════════════════════════════════════════════════
---   Lifecycle Manager - the handlers every job shares
---  ═══════════════════════════════════════════════════════════════════════════
---   status_change, buff_change, aftercast and state_change were written out
---   once per job and were identical in 39 files: the same DoomManager call,
---   the same watchdog tick, the same UI refresh, under a different comment.
---   Changing that behaviour meant editing it 13 times and hoping.
---
---   Each builder returns a handler and takes an optional `extra` callback, so
---   a job that later needs something of its own adds it without leaving the
---   factory - which is what made the per-job copies pile up to begin with.
---
---   The caller still assigns and exports the global itself. Mote looks these
---   up by name, and keeping the export where the reader can see it is worth
---   more than the two lines it costs.
---
---   @file    shared/utils/core/lifecycle_manager.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-09
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = {}

local DoomManager = nil

--- Load DoomManager on first use rather than at file load.
local function doom()
    if not DoomManager then
        DoomManager = require('shared/utils/debuff/doom_manager')
    end
    return DoomManager
end

--- Status handler: unlocks Doom slots so a raise does not leave them stuck.
--- @param extra function|nil Job-specific logic, run after the shared part
--- @return function Handler for _G.job_status_change
function LifecycleManager.status_change(extra)
    return function(newStatus, oldStatus, eventArgs)
        doom().handle_status_change(newStatus, oldStatus)
        if extra then
            extra(newStatus, oldStatus, eventArgs)
        end
    end
end

--- Buff handler: Doom takes priority and stops the chain when it applies.
--- @param extra function|nil Job-specific logic, skipped when Doom handled it
--- @return function Handler for _G.job_buff_change
function LifecycleManager.buff_change(extra)
    return function(buff, gain, eventArgs)
        if doom().handle_buff_change(buff, gain) then
            return
        end
        if extra then
            extra(buff, gain, eventArgs)
        end
    end
end

--- Aftercast handler: ticks the watchdog so a lost packet still recovers.
---
--- No `gs c update` here. Mote's status_change plus the watchdog already
--- refresh the gear, and the forced update was removed in 2026-06 after being
--- validated in Odyssey and Sortie.
--- @param extra function|nil Job-specific logic, run after the shared part
--- @return function Handler for _G.job_aftercast
function LifecycleManager.aftercast(extra)
    return function(spell, action, spellMap, eventArgs)
        if _G.MidcastWatchdog then
            _G.MidcastWatchdog.on_aftercast()
        end
        if extra then
            extra(spell, action, spellMap, eventArgs)
        end
    end
end

--- State handler: repaints the keybind HUD when a Mote state changes.
---
--- Moving is excluded on purpose. AutoMove drives it several times a second
--- and repainting the HUD on each one is the cost this guard exists to avoid.
--- @param extra function|nil Job-specific logic, run after the shared part
--- @return function Handler for _G.job_state_change
function LifecycleManager.state_change(extra)
    return function(stateField, newValue, oldValue)
        if stateField == 'Moving' then
            return
        end

        local ok, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ok and KeybindUI then
            KeybindUI.update()
        end

        if extra then
            extra(stateField, newValue, oldValue)
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.LifecycleManager = LifecycleManager

return LifecycleManager

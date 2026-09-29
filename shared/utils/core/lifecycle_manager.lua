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
---   @author  ejouanchicot
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

-- Seconds after an engage / disengage held back during an action before the
-- status gear goes on anyway, in case the action never reported its end.
local STATUS_FALLBACK = 3

--- An engage or disengage that lands during an action (a Phantom Roll, a
--- spell): Mote would put the engaged / idle set on at once, over the
--- action's gear, and the roll would go out with the wrong neck. Hold it
--- back: aftercast equips the set of the status in force by then. If the
--- action never reports its end, the status set goes on a few seconds later.
--- @param newStatus string
--- @param eventArgs table Mote event args
local function hold_during_action(newStatus, eventArgs)
    if eventArgs.handled then return end
    if newStatus ~= 'Idle' and newStatus ~= 'Engaged' then return end
    if not (type(midaction) == 'function' and midaction()) then return end
    eventArgs.handled = true
    -- `gs c update` rather than handle_equipping_gear: equip() only fills
    -- GearSwap's list, sent at the end of an event, and a scheduled function
    -- runs outside one (the next event would empty the list unsent).
    coroutine.schedule(function()
        if midaction() or not player or player.status ~= newStatus then return end
        send_command('gs c update')
    end, STATUS_FALLBACK)
end

--- Status handler: unlocks Doom slots so a raise does not leave them stuck,
--- and holds the engaged / idle set back while an action is under way.
--- @param extra function|nil Job-specific logic, run after the shared part
--- @return function Handler for _G.job_status_change
function LifecycleManager.status_change(extra)
    return function(newStatus, oldStatus, eventArgs)
        doom().handle_status_change(newStatus, oldStatus)
        if extra then
            extra(newStatus, oldStatus, eventArgs)
        end
        hold_during_action(newStatus, eventArgs)
    end
end

--- Buffs whose gain or loss swaps the idle / engaged set (sets.engaged.AM3,
--- PDTAFM3..., PUP's sets.buff.Overdrive layer).
local GEAR_BUFFS = {['Aftermath: Lv.3'] = true, ['Overdrive'] = true, ['Spirit Surge'] = true}

--- Rebuild the gear once GearSwap has stored a buff change that swaps sets.
---
--- Inside buff_change, buffactive still holds the OLD buffs: GearSwap
--- refreshes its globals before storing the new list (packet_parsing.lua,
--- 0x063). A rebuild there reads the state before the change, so a gained
--- Aftermath got no AM3 set and a lost one put it back on. `gs c update` a
--- moment later is a new event, which refreshes buffactive first. Skipped under
--- Doom (Doom gear first) and during an action (its aftercast rebuilds).
--- @param buff string Buff name from buff_change
--- @return boolean True when an update was scheduled
function LifecycleManager.refresh_after_buff(buff)
    if not GEAR_BUFFS[buff] or (buffactive and buffactive['doom']) then
        return false
    end
    coroutine.schedule(function()
        if type(midaction) == 'function' and midaction() then return end
        send_command('gs c update')
    end, 0.1)
    return true
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

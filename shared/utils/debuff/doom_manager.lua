---============================================================================
--- Doom Manager - Centralized Doom Debuff Handling
---============================================================================
--- Handles Doom debuff detection, gear swapping, and slot locking/unlocking.
--- Prevents gear swap conflicts and handles death/raise edge cases.
---
--- Features:
---   • Automatic Doom gear equipping when Doom is detected
---   • Locks 4 critical slots (neck, ring1, ring2, waist) during Doom
---   • Unlocks slots automatically when Doom is removed
---   • Safety unlock when player dies (prevents stuck locked slots after raise)
---   • Centralized logic shared by every job that wires it (see callers)
---   • Integrates with MessageFormatter for user feedback
---
--- Usage (in job_buff_change):
---   ```lua
---   local DoomManager = require('shared/utils/debuff/doom_manager')
---
---   function job_buff_change(buff, gain, eventArgs)
---       if DoomManager.handle_buff_change(buff, gain) then
---           return -- Doom handled, stop processing
---       end
---       -- Rest of job-specific buff logic...
---   end
---   ```
---
--- Usage (in job_status_change):
---   ```lua
---   local DoomManager = require('shared/utils/debuff/doom_manager')
---
---   function job_status_change(newStatus, oldStatus, eventArgs)
---       DoomManager.handle_status_change(newStatus, oldStatus)
---       -- Rest of job-specific status logic...
---   end
---   ```
---
--- @file    shared/utils/debuff/doom_manager.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-11-14
--- @requires MessageFormatter
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- MODULE INITIALIZATION
---============================================================================

local DoomManager = {}

---============================================================================
--- CORE FUNCTIONS
---============================================================================

--- Handles Doom buff change events
--- Automatically equips Doom resistance gear and locks slots when Doom is detected.
--- Unlocks slots and restores normal gear when Doom is removed.
---
--- @param buff string Buff name
--- @param gain boolean True if buff gained, false if lost
--- @return boolean True if Doom was handled (caller should return), false otherwise
function DoomManager.handle_buff_change(buff, gain)
    if buff ~= 'doom' then
        return false
    end

    -- Check buffactive (source of truth) instead of 'gain' parameter
    -- This prevents edge cases where 'gain' is incorrect
    local is_doomed = buffactive['doom']

    if is_doomed then
        if not sets.buff or not sets.buff.Doom then
            MessageFormatter.show_error("ERROR: sets.buff.Doom not defined! Cannot equip Doom gear.")
            return true -- Still return true to prevent other processing
        end

        equip(sets.buff.Doom)

        -- Lock AFTER equipping (equip() honours the disable table): without the
        -- lock, the next midcast/aftercast/idle swap would overwrite the Doom gear.
        disable('neck', 'ring1', 'ring2', 'waist')

        MessageFormatter.show_warning("DOOM detected! Equipping Doom gear.")
    else
        -- Unlock first: equip() skips disabled slots, so re-equipping before
        -- enable() would leave the Doom pieces on.
        enable('neck', 'ring1', 'ring2', 'waist')

        -- Restore appropriate gear based on current status
        -- handle_equipping_gear is defined in Mote-Include and handles idle/engaged/resting
        if handle_equipping_gear then
            handle_equipping_gear(player.status)
        end

        MessageFormatter.show_success("Doom removed.")
    end

    return true
end

--- Handles status change events (Idle/Engaged/Resting/Dead)
--- Safety unlock: If player dies with Doom, slots remain locked after raise.
--- This function automatically unlocks Doom slots when transitioning from Dead status.
---
--- @param newStatus string New status ("Idle", "Engaged", "Resting", "Dead")
--- @param oldStatus string Previous status
function DoomManager.handle_status_change(newStatus, oldStatus)
    -- EDGE CASE FIX: Player died with Doom active
    -- Problem: When player dies, buffs are cleared but disable() persists
    -- Result: After raise, slots are still locked but Doom is gone
    -- Solution: Always unlock Doom slots when transitioning from Dead status

    if newStatus == 'Dead' then
        enable('neck', 'ring1', 'ring2', 'waist')
        return
    end

    -- If player was dead and is now alive (raise/homepoint)
    if oldStatus == 'Dead' and newStatus ~= 'Dead' then
        enable('neck', 'ring1', 'ring2', 'waist')

        if not buffactive['doom'] then
            if handle_equipping_gear then
                handle_equipping_gear(newStatus)
            end
        end
    end
end

--- Validates that Doom set is properly configured
--- Checks if sets.buff.Doom exists and is not empty
---
--- @return boolean True if Doom set is valid, false otherwise
function DoomManager.validate_doom_set()
    if not sets or not sets.buff or not sets.buff.Doom then
        return false
    end

    local has_gear = false
    for slot, item in pairs(sets.buff.Doom) do
        has_gear = true
        break
    end

    return has_gear
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return DoomManager

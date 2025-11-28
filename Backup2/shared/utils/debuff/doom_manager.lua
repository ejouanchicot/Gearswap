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
---   • Centralized logic - no code duplication across 15 jobs
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
--- CONSTANTS
---============================================================================

-- Slots that must be locked when Doom is active
-- These slots contain Doom resistance/removal gear
local DOOM_SLOTS = {'neck', 'ring1', 'ring2', 'waist'}

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
    -- Only handle 'doom' buff
    if buff ~= 'doom' then
        return false
    end

    -- Check buffactive (source of truth) instead of 'gain' parameter
    -- This prevents edge cases where 'gain' is incorrect
    local is_doomed = buffactive['doom']

    if is_doomed then
        -- DOOM DETECTED: Equip resistance gear and lock slots

        -- Validate that Doom set exists
        if not sets.buff or not sets.buff.Doom then
            MessageFormatter.show_error("ERROR: sets.buff.Doom not defined! Cannot equip Doom gear.")
            return true -- Still return true to prevent other processing
        end

        -- Equip Doom resistance/removal gear
        equip(sets.buff.Doom)

        -- Lock critical slots to prevent other gear swaps from overwriting Doom gear
        -- This is CRITICAL - without locking, midcast/aftercast/idle will overwrite
        disable('neck', 'ring1', 'ring2', 'waist')

        -- User feedback
        MessageFormatter.show_warning("DOOM detected! Equipping Doom gear.")
    else
        -- DOOM REMOVED: Unlock slots and restore normal gear

        -- Unlock slots first (order matters!)
        enable('neck', 'ring1', 'ring2', 'waist')

        -- Restore appropriate gear based on current status
        -- handle_equipping_gear is defined in Mote-Include and handles idle/engaged/resting
        if handle_equipping_gear then
            handle_equipping_gear(player.status)
        end

        -- User feedback
        MessageFormatter.show_success("Doom removed.")
    end

    -- Return true to signal that Doom was handled
    -- Caller should return immediately to prevent other buff processing
    return true
end

--- Handles status change events (Idle/Engaged/Resting/Dead)
--- Safety unlock: If player dies with Doom, slots remain locked after raise.
--- This function automatically unlocks Doom slots when transitioning from Dead status.
---
--- @param newStatus string New status ("Idle", "Engaged", "Resting", "Dead")
--- @param oldStatus string Previous status
--- @return void
function DoomManager.handle_status_change(newStatus, oldStatus)
    -- EDGE CASE FIX: Player died with Doom active
    -- Problem: When player dies, buffs are cleared but disable() persists
    -- Result: After raise, slots are still locked but Doom is gone
    -- Solution: Always unlock Doom slots when transitioning from Dead status

    -- If player just died, unlock slots (prevents stuck locks)
    if newStatus == 'Dead' then
        -- Player just died - unlock Doom slots immediately
        -- This prevents slots from staying locked after raise
        enable('neck', 'ring1', 'ring2', 'waist')
        -- No message needed (player is dead, won't see it anyway)
        return
    end

    -- If player was dead and is now alive (raise/homepoint)
    if oldStatus == 'Dead' and newStatus ~= 'Dead' then
        -- Safety unlock: Ensure Doom slots are not stuck locked
        enable('neck', 'ring1', 'ring2', 'waist')

        -- Restore appropriate gear for new status
        -- Only restore if Doom is not currently active
        if not buffactive['doom'] then
            if handle_equipping_gear then
                handle_equipping_gear(newStatus)
            end
        end
        -- No message needed (silent safety operation)
    end
end

--- Checks if Doom slots are currently locked
--- Useful for debugging or conditional logic in jobs
---
--- @return boolean True if Doom slots are locked, false otherwise
function DoomManager.is_doom_locked()
    -- Try to enable neck slot
    -- If it was already enabled, returns true (slot was NOT disabled)
    -- If it was disabled, enables it and returns false
    -- We immediately disable again to restore state
    local was_enabled = enable('neck')
    if not was_enabled then
        disable('neck') -- Restore disabled state
    end
    return not was_enabled
end

--- Validates that Doom set is properly configured
--- Checks if sets.buff.Doom exists and is not empty
---
--- @return boolean True if Doom set is valid, false otherwise
function DoomManager.validate_doom_set()
    if not sets or not sets.buff or not sets.buff.Doom then
        return false
    end

    -- Check if set is not empty (has at least one piece of gear)
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

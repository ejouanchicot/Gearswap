---  ═══════════════════════════════════════════════════════════════════════════
---   Ampulla Lock - ammo slot held on Hoxne Ampulla for the Hoxne stance
---  ═══════════════════════════════════════════════════════════════════════════
---   The Hoxne Ampulla is an ammo-slot item with a single charge and a 60s
---   recast: it has to stay equipped to be usable. Every set names its own
---   ammo, so idling, engaging, weaponskilling or casting would swap it out
---   within a second of equipping it.
---
---   The Hoxne stance (HybridMode 'Hoxne', used by PLD and WAR) therefore
---   locks the ammo slot. It has its own engaged build (sets.engaged.Hoxne);
---   elsewhere it wears what the other stances wear, minus this slot.
---
---   The job's SetBuilder is what puts the Ampulla on: it names the piece in
---   the Hoxne idle and engaged sets, so the handle_update that follows a
---   stance change wears it. This module only closes the slot afterwards,
---   which is what keeps the weaponskill, midcast and precast sets - none of
---   them built by SetBuilder - from taking it back.
---
---   Wiring, for each job that has the stance:
---     • job_state_change on HybridMode  -> AmpullaLock.apply(new_value)
---     • entry user_setup                -> AmpullaLock.apply(current value)
---     • entry file_unload (first thing) -> AmpullaLock.release()
---
---   It closes the slot on the Ampulla or not at all: it reads the ammo slot
---   until the piece is there rather than assuming a delay was enough. A lock
---   that shut on the wrong ammo would hold it for the whole stance without
---   saying anything.
---
---   It deliberately does not equip anything itself. equip() writes into
---   equip_list, and flow.lua clears equip_list at the top of every equip_sets
---   cycle, so an equip() issued from a scheduled callback - outside any cycle
---   - is dropped before it can be sent.
---
---   GearSwap keeps slot locks in its own table, which outlives the job file:
---   a lock left in place survives gs reload, subjob and main job changes,
---   while state.HybridMode goes back to its default on every load. The lock is
---   therefore recorded in the sandbox and released by the entry file, both on
---   file_unload and on the way back up in user_setup.
---
---   @file    shared/utils/equipment/ampulla_lock.lua
---   @author  Tetsouo
---   @version 1.1 - Shared by PLD and WAR
---   @date    Created: 2026-09-20 | Updated: 2026-09-23
---  ═══════════════════════════════════════════════════════════════════════════

local AmpullaLock = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

local AMPULLA = 'Hoxne Ampulla'
local HOXNE_MODE = 'Hoxne'

--- How often to check whether the Ampulla is actually worn yet.
--- A state change runs job_state_change and THEN handle_update (cycle_handler,
--- and Mote's handle_cycle does the same), so the Ampulla is not on when this
--- module is called - handle_update is what wears it, a moment later. Freezing
--- before that locks whatever ammo the previous stance had on, and the slot can
--- no longer receive the Ampulla: equip() is set_merge(true, ...) and set_merge
--- sends a disabled slot to not_sent_out_equip instead of wearing it
--- (helper_functions.lua). That was the first version's bug.
---
--- Waiting a fixed delay only made that rare. Reading the slot makes it
--- impossible: the lock closes on the Ampulla or it does not close at all.
local POLL_INTERVAL = 0.5

--- How long to keep checking before giving up and leaving the slot open.
local POLL_TIMEOUT = 5.0

--- Invalidates a pending lock when the stance is left before it fires.
--- Without it, leaving Hoxne while a check is still pending would still be
--- caught by the scheduled disable, freezing the ammo the next stance had just
--- equipped.
local lock_sequence = 0

--- The ammo currently worn, or nil when it cannot be read.
--- @return string|nil
local function worn_ammo()
    return player and player.equipment and player.equipment.ammo
end

--- Report that the stance could not take hold.
--- @param reason string What was worn instead
--- @return void
local function warn_not_worn(reason)
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter then
        MessageFormatter.show_warning(
            ('Hoxne: ammo left unlocked, %s is worn instead of %s'):format(reason, AMPULLA))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SLOT LOCK
---  ═══════════════════════════════════════════════════════════════════════════

--- Lock or unlock the ammo slot, and record which.
--- @param locked boolean True to lock, false to unlock
--- @return void
function AmpullaLock.set_slot(locked)
    if locked then
        disable('ammo')
    else
        enable('ammo')
    end
    _G.ampulla_ammo_locked = locked
end

--- Close the slot once the Ampulla is actually worn, or not at all.
--- @param deadline number os.clock() value past which we give up
--- @param my_sequence number Generation this attempt belongs to
--- @return void
local lock_when_worn
lock_when_worn = function(deadline, my_sequence)
    if my_sequence ~= lock_sequence then
        return
    end

    if worn_ammo() == AMPULLA then
        AmpullaLock.set_slot(true)
        return
    end

    if os.clock() >= deadline then
        -- Leaving the slot open is the safe failure: a lock closed on the
        -- wrong ammo would hold it for the whole stance, silently.
        warn_not_worn(tostring(worn_ammo() or 'nothing'))
        return
    end

    coroutine.schedule(function()
        lock_when_worn(deadline, my_sequence)
    end, POLL_INTERVAL)
end

--- Freeze the ammo slot once the stance's gear has settled on the Ampulla.
--- @return void
function AmpullaLock.engage()
    lock_sequence = lock_sequence + 1
    local my_sequence = lock_sequence

    -- Unlock first: the slot has to be open for the update that follows to
    -- reach it, and re-entering the stance under an existing lock would
    -- otherwise keep whatever the slot already holds.
    AmpullaLock.set_slot(false)

    lock_when_worn(os.clock() + POLL_TIMEOUT, my_sequence)
end

--- Release the lock this module placed, if any.
--- Safe to call when nothing is locked; a pending lock is cancelled too.
--- @return void
function AmpullaLock.release()
    lock_sequence = lock_sequence + 1
    if _G.ampulla_ammo_locked then
        AmpullaLock.set_slot(false)
    end
end

--- Bring the lock in line with a HybridMode value.
--- @param mode string HybridMode value the stance is moving to
--- @return void
function AmpullaLock.apply(mode)
    if mode == HOXNE_MODE then
        AmpullaLock.engage()
    else
        AmpullaLock.release()
    end
end

return AmpullaLock

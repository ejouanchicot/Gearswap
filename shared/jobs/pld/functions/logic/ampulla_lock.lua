---  ═══════════════════════════════════════════════════════════════════════════
---   Ampulla Lock - ammo slot held on Hoxne Ampulla for the Hoxne stance
---  ═══════════════════════════════════════════════════════════════════════════
---   The Hoxne Ampulla is an ammo-slot item with a single charge and a 60s
---   recast: it has to stay equipped to be usable. Every PLD set names its own
---   ammo, so idling, engaging, weaponskilling or casting would swap it out
---   within a second of equipping it.
---
---   The Hoxne stance therefore locks the ammo slot. It has its own engaged
---   build (sets.engaged.Hoxne), the Ampulla's charge supplying the Double
---   Attack the DPS stance buys with gear; elsewhere - idling, casting - it
---   wears what the other stances wear, minus this slot.
---
---   SetBuilder is what puts the Ampulla on: it names the piece in the Hoxne
---   idle and engaged sets, so the handle_update that follows a stance change
---   wears it. This module only closes the slot afterwards, which is what
---   keeps the weaponskill, midcast and precast sets - none of them built by
---   SetBuilder - from taking it back.
---
---   It deliberately does not equip anything itself. equip() writes into
---   equip_list, and flow.lua clears equip_list at the top of every equip_sets
---   cycle, so an equip() issued from a scheduled callback - outside any cycle
---   - is dropped before it can be sent.
---
---   GearSwap keeps slot locks in its own table, which outlives the job file:
---   a lock left in place survives gs reload, subjob and main job changes,
---   while state.HybridMode goes back to Tanking on every load. The lock is
---   therefore recorded in the sandbox and released by the entry file, both on
---   file_unload and on the way back up in user_setup.
---
---   @file    shared/jobs/pld/functions/logic/ampulla_lock.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-20
---  ═══════════════════════════════════════════════════════════════════════════

local AmpullaLock = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

local HOXNE_MODE = 'Hoxne'

--- How long to wait before freezing the slot.
--- A state change runs job_state_change and THEN handle_update (cycle_handler,
--- and Mote's handle_cycle does the same), so the Ampulla is not on yet when
--- this module is called - handle_update is what wears it, a moment later.
--- Freezing before that locks whatever ammo the previous stance had on, and
--- the slot can no longer receive the Ampulla: equip() is set_merge(true, ...)
--- and set_merge sends a disabled slot to not_sent_out_equip instead of
--- wearing it (helper_functions.lua). That was the first version's bug.
local LOCK_DELAY = 1.0

--- Invalidates a pending lock when the stance is left before it fires.
--- Without it, leaving Hoxne inside LOCK_DELAY would still be caught by the
--- scheduled disable, freezing the ammo the next stance had just equipped.
local lock_sequence = 0

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
    _G.pld_ammo_locked = locked
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

    coroutine.schedule(function()
        if my_sequence ~= lock_sequence then
            return
        end
        AmpullaLock.set_slot(true)
    end, LOCK_DELAY)
end

--- Release the lock this module placed, if any.
--- Safe to call when nothing is locked; a pending lock is cancelled too.
--- @return void
function AmpullaLock.release()
    lock_sequence = lock_sequence + 1
    if _G.pld_ammo_locked then
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

---  ═══════════════════════════════════════════════════════════════════════════
---   Ampulla Lock - ammo slot held on Hoxne Ampulla for the Hoxne stance
---  ═══════════════════════════════════════════════════════════════════════════
---   The Hoxne Ampulla is an ammo-slot item with a single charge and a 60s
---   recast: it has to stay equipped to be usable. Every PLD set names its own
---   ammo, so idling, engaging, weaponskilling or casting would swap it out
---   within a second of equipping it.
---
---   The Hoxne stance therefore locks the ammo slot. Gear from the Engaged
---   stance is worn everywhere else - the two stances differ by this lock and
---   nothing more.
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

local AMPULLA = 'Hoxne Ampulla'
local HOXNE_MODE = 'Hoxne'

--- Delay between equipping the Ampulla and freezing the slot.
--- disable() filters the slot out when the equipment packet is built, so a
--- disable issued in the same tick as the equip would drop the equip itself
--- and freeze whatever ammo was already worn.
local LOCK_DELAY = 1.0

--- Invalidates a pending lock when the stance is left inside LOCK_DELAY.
--- Without it, leaving Hoxne right after entering it would still be caught by
--- the scheduled disable, locking the ammo the next stance had just equipped.
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

--- Equip the Ampulla, then freeze the ammo slot on it.
--- @return void
function AmpullaLock.engage()
    lock_sequence = lock_sequence + 1
    local my_sequence = lock_sequence

    -- Unlock first: re-entering the stance while a lock is up would otherwise
    -- keep whatever the slot already holds and never reach the Ampulla.
    AmpullaLock.set_slot(false)
    equip({ammo = AMPULLA})

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

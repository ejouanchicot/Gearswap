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
---   Two things put the Ampulla on, and both are needed. SetBuilder names it
---   in the idle and engaged sets, which is what survives every later update;
---   this module equips it once on entering the stance, for the sets
---   SetBuilder never builds, and then closes the slot so the weaponskill and
---   midcast sets cannot take it back.
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

--- How long to wait before putting the Ampulla on.
--- A state change runs job_state_change and THEN handle_update (cycle_handler,
--- and Mote's handle_cycle does the same), so anything equipped from the state
--- hook is immediately overwritten by the set handle_update re-dresses us in.
--- Waiting lets that pass first; SetBuilder.apply_mode_ammo has already put the
--- Ampulla in that set, so this is a second chance rather than the only one.
local EQUIP_DELAY = 0.5

--- How long to wait after that before freezing the slot.
--- equip() is set_merge(true, ...) and set_merge sends any disabled slot to
--- not_sent_out_equip instead of wearing it (helper_functions.lua), so the
--- piece has to be on before the slot closes. Freezing too early locks
--- whatever ammo was already worn - which is the bug this delay exists for.
local LOCK_DELAY = 0.5

--- Invalidates a pending equip or lock when the stance is left before they
--- fire. Without it, leaving Hoxne inside the delays would still be caught by
--- the scheduled steps, putting the Ampulla back on and locking the ammo the
--- next stance had just equipped.
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

--- Equip the Ampulla once the stance's own gear has settled, then freeze the
--- ammo slot on it.
--- @return void
function AmpullaLock.engage()
    lock_sequence = lock_sequence + 1
    local my_sequence = lock_sequence

    -- Unlock first: the slot has to be open for the Ampulla to reach it, and
    -- re-entering the stance under an existing lock would otherwise keep
    -- whatever the slot already holds.
    AmpullaLock.set_slot(false)

    coroutine.schedule(function()
        if my_sequence ~= lock_sequence then
            return
        end
        equip({ammo = AMPULLA})

        coroutine.schedule(function()
            if my_sequence ~= lock_sequence then
                return
            end
            AmpullaLock.set_slot(true)
        end, LOCK_DELAY)
    end, EQUIP_DELAY)
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

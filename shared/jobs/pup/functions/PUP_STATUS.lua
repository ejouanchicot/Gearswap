---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Status Module - Player and Automaton Status Changes
---  ═══════════════════════════════════════════════════════════════════════════
---   • job_status_change: the shared LifecycleManager handler (Doom slots,
---     engage / disengage held back during an action).
---   • job_pet_change: a new automaton sets PetMode from its head (forced),
---     and the pet WS poll starts. Mote puts the gear on afterwards.
---   • job_pet_status_change: Mote equips nothing when the automaton engages
---     or disengages; the pet layers depend on it (sets.idle.Pet.Engaged,
---     sets.engaged.Pet), so the gear is put on here, unless an action of
---     the player or the pet is under way (its aftercast does it).
---
---   @file    shared/jobs/pup/functions/PUP_STATUS.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')
local Automaton = require('shared/jobs/pup/functions/logic/automaton')
local PetWS = require('shared/jobs/pup/functions/logic/pet_ws')

job_status_change = LifecycleManager.status_change()

--- Pet gained or lost (Mote-Include, before its own gear refresh).
--- @param pet_info table The pet
--- @param gain boolean True when gained
--- @param eventArgs table Mote event args
function job_pet_change(pet_info, gain, eventArgs)
    if gain then
        Automaton.refresh_mode(true)
    end
    PetWS.ensure_running()
end

--- Automaton status changed (Mote-Include, which equips nothing itself).
--- @param newStatus string
--- @param oldStatus string
--- @param eventArgs table Mote event args
function job_pet_status_change(newStatus, oldStatus, eventArgs)
    if not midaction() and not pet_midaction() then
        handle_equipping_gear(player.status)
    end
    PetWS.ensure_running()
end

_G.job_status_change = job_status_change
_G.job_pet_change = job_pet_change
_G.job_pet_status_change = job_pet_status_change

return {
    job_status_change = job_status_change,
    job_pet_change = job_pet_change,
    job_pet_status_change = job_pet_status_change,
}

---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Pet WS - automaton weaponskill gear, and the poll that times it
---  ═══════════════════════════════════════════════════════════════════════════
---   An automaton weaponskill is reported to GearSwap (pet_midcast) as it
---   goes off: gear put on then is too late. So the gear goes on BEFORE: while
---   Pet WS is On, the automaton fights and its TP is at least
---   PUPTPConfig.pet_ws_tp (1000 by default), the set builder lays
---   sets.midcast.Pet.WeaponSkill[PetMode] (or .WeaponSkill) on top of the
---   idle / engaged set.
---
---   The automaton's TP crossing that line is no GearSwap event, so a light
---   poll watches it: every 0.5 s, only while a pet is out, Pet WS is On and
---   PUP is the main job, it works out "is WS gear due" and sends
---   `gs c update` only when the answer flips (never during an action: the
---   next tick tries again). A coroutine, not a prerender listener: a
---   listener from a job file costs a full gear evaluation per frame.
---
---   The loop dies with its generation (windower._pup_pet_ws_seq, which
---   outlives the sandbox): a reload, a job change or stop() bumps it, and a
---   coroutine of an older generation returns at its next tick.
---
---   @file    shared/jobs/pup/functions/logic/pet_ws.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local PetWS = {}

local Automaton = require('shared/jobs/pup/functions/logic/automaton')

local INTERVAL = 0.5
local DEFAULT_TP = 1000

-- A new sandbox (this file loaded again) ends every loop of the previous one
windower._pup_pet_ws_seq = (windower._pup_pet_ws_seq or 0) + 1

local running = false
local last_due = false

---  ═══════════════════════════════════════════════════════════════════════════
---   THE ANSWER
---  ═══════════════════════════════════════════════════════════════════════════

--- Automaton TP from which the WS gear goes on (PUP_TP_CONFIG.pet_ws_tp).
--- @return number
function PetWS.threshold()
    local config = rawget(_G, 'PUPTPConfig')
    return (type(config) == 'table' and tonumber(config.pet_ws_tp)) or DEFAULT_TP
end

--- @return boolean True when the Pet WS mode is On
function PetWS.enabled()
    return state ~= nil and state.PetWS ~= nil and state.PetWS.value == 'On'
end

--- Whether the automaton weaponskill gear is due now.
--- @return boolean
function PetWS.is_due()
    if not PetWS.enabled() or not Automaton.is_engaged() then return false end
    return Automaton.tp() >= PetWS.threshold()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   THE POLL
---  ═══════════════════════════════════════════════════════════════════════════

--- @return boolean True while PUP is the main job (read from the game)
local function on_pup()
    local ok, me = pcall(windower.ffxi.get_player)
    return ok and type(me) == 'table' and me.main_job == 'PUP'
end

--- @return boolean True while the poll has something to watch
local function should_run()
    return PetWS.enabled() and Automaton.is_out() and on_pup()
end

--- @return boolean True during an action of the player or the pet
local function busy()
    return (type(midaction) == 'function' and midaction())
        or (type(pet_midaction) == 'function' and pet_midaction())
end

--- One poll step; schedules the next while the generation is current.
--- @param generation number
local function tick(generation)
    if windower._pup_pet_ws_seq ~= generation then return end
    if not should_run() then
        running = false
        return
    end
    local due = PetWS.is_due()
    if due ~= last_due and not busy() then
        last_due = due
        send_command('gs c update')
    end
    coroutine.schedule(function() tick(generation) end, INTERVAL)
end

--- Start the poll if it has something to watch and is not running yet.
--- Safe to call on every update, pet change and pet status change.
function PetWS.ensure_running()
    if running or not should_run() then return end
    running = true
    last_due = PetWS.is_due()
    local generation = windower._pup_pet_ws_seq
    coroutine.schedule(function() tick(generation) end, INTERVAL)
end

--- End the poll (file unload).
function PetWS.stop()
    windower._pup_pet_ws_seq = (windower._pup_pet_ws_seq or 0) + 1
    running = false
end

return PetWS

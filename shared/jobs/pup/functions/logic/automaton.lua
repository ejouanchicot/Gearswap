---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Automaton - what the automaton is and what it is doing
---  ═══════════════════════════════════════════════════════════════════════════
---   Everything here reads the game directly, never GearSwap's `pet` copy:
---   that copy is only refreshed at the start of a GearSwap event, and the
---   pet WS poll (logic/pet_ws.lua) runs in a coroutine, outside any event.
---   Reading the same sources from the set builder keeps the poll and the
---   gear it asks for in agreement.
---
---   • Out / fighting: windower.ffxi.get_mob_by_target('pet'); the mob's
---     status is a number there (1 = Engaged).
---   • TP: gearswap._ExtraData.pet.tp, which GearSwap writes from the pet
---     status packets (0x067 / 0x068) as they arrive, 0-3000. GearSwap's
---     pet.tp is the same number copied at the last event: the fallback.
---   • Head / frame: windower.ffxi.get_mjob_data() (item ids, named through
---     res.items), only while PUP is the main job; GearSwap's pet.head /
---     pet.frame as the fallback.
---
---   PetMode (config/pup/PUP_STATES.lua) follows the head: set again when a
---   new automaton comes out (force) or when the head / frame read differs
---   from the last detection. A value cycled by hand therefore holds until
---   one of those happens.
---
---   @file    shared/jobs/pup/functions/logic/automaton.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Automaton = {}

local STATUS_ENGAGED = 1

--- Automaton head -> PetMode value
Automaton.HEAD_MODES = {
    ['Harlequin Head'] = 'Melee',
    ['Valoredge Head'] = 'Tank',
    ['Sharpshot Head'] = 'Ranged',
    ['Stormwaker Head'] = 'Magic',
    ['Soulsoother Head'] = 'Heal',
    ['Spiritreaver Head'] = 'Nuke',
}

--- Frame -> PetMode value, used only when the head is not one of the above
Automaton.FRAME_MODES = {
    ['Harlequin Frame'] = 'Melee',
    ['Valoredge Frame'] = 'Tank',
    ['Sharpshot Frame'] = 'Ranged',
    ['Stormwaker Frame'] = 'Magic',
}

-- Head and frame of the last detection (module-local: a reload resets the
-- states anyway, so the next job_update detects again)
local last_seen = nil

---  ═══════════════════════════════════════════════════════════════════════════
---   LIVE READS
---  ═══════════════════════════════════════════════════════════════════════════

--- The automaton's mob, read from the game now.
--- @return table|nil
local function pet_mob()
    local ffxi = windower and windower.ffxi
    if not (ffxi and ffxi.get_mob_by_target) then return nil end
    local ok, mob = pcall(ffxi.get_mob_by_target, 'pet')
    if ok and type(mob) == 'table' then return mob end
    return nil
end

--- @return boolean True while a pet is out
function Automaton.is_out()
    return pet_mob() ~= nil
end

--- @return boolean True while the pet is out and fighting
function Automaton.is_engaged()
    local mob = pet_mob()
    if not mob then return false end
    return mob.status == STATUS_ENGAGED or mob.status == 'Engaged'
end

--- The pet's TP (0-3000), or 0 without a pet.
--- @return number
function Automaton.tp()
    if not pet_mob() then return 0 end
    local gs = rawget(_G, 'gearswap')
    local extra = type(gs) == 'table' and type(gs._ExtraData) == 'table' and gs._ExtraData.pet
    if type(extra) == 'table' and tonumber(extra.tp) then
        return tonumber(extra.tp)
    end
    return (pet and tonumber(pet.tp)) or 0
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HEAD AND FRAME
---  ═══════════════════════════════════════════════════════════════════════════

--- Item name of an id, or nil.
--- @param id number|nil
--- @return string|nil
local function item_name(id)
    if not id or id == 0 then return nil end
    local ok, res = pcall(require, 'resources')
    local item = ok and res and res.items and res.items[id]
    return item and (item.english or item.en) or nil
end

--- The automaton's head and frame names (nil when unknown).
--- @return string|nil head
--- @return string|nil frame
function Automaton.parts()
    local me = windower and windower.ffxi and windower.ffxi.get_player and windower.ffxi.get_player()
    if me and me.main_job == 'PUP' and windower.ffxi.get_mjob_data then
        local ok, data = pcall(windower.ffxi.get_mjob_data)
        if ok and type(data) == 'table' and data.head then
            return item_name(data.head), item_name(data.frame)
        end
    end
    if pet and type(pet.head) == 'string' then
        return pet.head, pet.frame
    end
    return nil, nil
end

--- PetMode value for a head and frame: the head decides, the frame when the
--- head is not a known one.
--- @param head string|nil
--- @param frame string|nil
--- @return string|nil
function Automaton.mode_for(head, frame)
    return Automaton.HEAD_MODES[head] or Automaton.FRAME_MODES[frame]
end

--- Set state.PetMode from the automaton, when forced or when its head /
--- frame changed since the last detection.
--- @param force boolean|nil True on a new automaton (pet gained)
--- @return string|nil mode Detected mode
--- @return boolean changed True when state.PetMode was set
function Automaton.refresh_mode(force)
    local head, frame = Automaton.parts()
    local mode = Automaton.mode_for(head, frame)
    if not mode or not (state and state.PetMode) then return mode, false end
    local seen = tostring(head) .. '|' .. tostring(frame)
    if not force and seen == last_seen then return mode, false end
    last_seen = seen
    if state.PetMode.value == mode then return mode, false end
    state.PetMode:set(mode)
    return mode, true
end

return Automaton

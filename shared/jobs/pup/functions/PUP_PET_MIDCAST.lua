---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Pet Midcast Module - the automaton's own actions
---  ═══════════════════════════════════════════════════════════════════════════
---   GearSwap calls pet_midcast when the automaton starts an action.
---
---   Spells (action_type Magic): Mote's default_pet_midcast picks the set,
---   nothing to add. It walks sets.midcast.Pet by spell name, spell map
---   (Cure...), skill ('Healing Magic', 'Elemental Magic', 'Enfeebling
---   Magic', 'Enhancing Magic', 'Dark Magic'), then refines by CastingMode.
---
---   Weaponskills (any other action): sets.midcast.Pet['<name>'] when it
---   exists (left to Mote's walk), else sets.midcast.Pet.WeaponSkill[PetMode]
---   or sets.midcast.Pet.WeaponSkill. By then the WS gear is normally on
---   already: the pet WS poll lays it before the TP is spent
---   (logic/pet_ws.lua), because this event comes too late for most
---   weaponskills. Mote's pet_aftercast puts the idle / engaged gear back.
---
---   @file    shared/jobs/pup/functions/PUP_PET_MIDCAST.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

--- The automaton WS set, by PetMode when defined.
--- @return table|nil
local function pet_ws_set()
    local ws = sets.midcast and sets.midcast.Pet and sets.midcast.Pet.WeaponSkill
    if not ws then return nil end
    local mode = state.PetMode and state.PetMode.current
    if mode and type(ws[mode]) == 'table' then return ws[mode] end
    return ws
end

--- Pet midcast hook (Mote-Include).
--- @param spell table The automaton's action
--- @param action string 'pet_midcast'
--- @param spellMap string|nil Mote spell map
--- @param eventArgs table Mote event args (handled skips Mote's default)
function job_pet_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Magic' then return end
    local pet_sets = sets.midcast and sets.midcast.Pet
    if pet_sets and pet_sets[spell.english] then return end
    local set = pet_ws_set()
    if set then
        equip(set)
        eventArgs.handled = true
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_pet_midcast = job_pet_midcast

return {
    job_pet_midcast = job_pet_midcast,
}

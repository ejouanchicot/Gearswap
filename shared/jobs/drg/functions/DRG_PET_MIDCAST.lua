---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Pet Midcast Module - the wyvern's breaths
---  ═══════════════════════════════════════════════════════════════════════════
---   GearSwap calls pet_midcast on the pet's "readies" action packet
---   (categories 7, 8, 9, 12 in its triggers.lua). "Enhances Breath" gear
---   counts when worn as the breath goes off, so a reported breath wears:
---     Healing Breath I-IV            sets.midcast.HealingBreath
---     Flame / Frost / Gust / Sand /  sets.midcast.ElementalBreath
---     Lightning / Hydro Breath
---   Anything else the wyvern does is left to Mote (sets.midcast.Pet...,
---   none in the template). Mote's pet_aftercast puts the idle / engaged
---   gear back.
---
---   @file    shared/jobs/drg/functions/DRG_PET_MIDCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Wyvern = require('shared/jobs/drg/functions/logic/wyvern')

--- Pet midcast hook (Mote-Include).
--- @param spell table The wyvern's action
--- @param action string 'pet_midcast'
--- @param spellMap string|nil Mote spell map
--- @param eventArgs table Mote event args (handled skips Mote's default)
function job_pet_midcast(spell, action, spellMap, eventArgs)
    local set = Wyvern.breath_set(spell and spell.english)
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

---  ═══════════════════════════════════════════════════════════════════════════
---   Enmity Override - Sortie Maximum Enmity Routing (PLD)
---  ═══════════════════════════════════════════════════════════════════════════
---   While HybridMode is on 'Sortie', whatever would have worn
---   sets.FullEnmity wears sets.EnmityMax instead. Spells swap to it whole;
---   abilities keep their own pieces and only gain what EnmityMax adds.
---
---   sets.EnmityMax differs from sets.FullEnmity by owning the sub slot: in
---   Sortie the shield is part of the enmity build, not left to whatever the
---   engaged set holds. It owns no main slot - a main hand change zeroes TP.
---
---   Scope - exactly what wore sets.FullEnmity:
---   • Job abilities  -> all of them; every PLD JA set is FullEnmity-based
---                      (weaponskills excluded, Atonement keeps FullEnmity)
---   • Spells         -> those whose midcast set IS sets.FullEnmity
---
---   @file    shared/jobs/pld/functions/logic/enmity_override.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2026-09-07
---  ═══════════════════════════════════════════════════════════════════════════
local EnmityOverride = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

local SORTIE_MODE = 'Sortie'

---  ═══════════════════════════════════════════════════════════════════════════
---   INTERNAL
---  ═══════════════════════════════════════════════════════════════════════════

---   Whether the Sortie enmity override is currently in effect
---   @return boolean True when HybridMode is Sortie and sets.EnmityMax exists
local function is_active()
    if not (state.HybridMode and state.HybridMode.value == SORTIE_MODE) then
        return false
    end
    return sets and sets.EnmityMax ~= nil
end

---   Whether a spell's midcast set IS sets.FullEnmity
---   Identity, not a hand-kept spell list: the sets file assigns the very same
---   table (sets.midcast['Flash'] = sets.FullEnmity), so a spell added or
---   removed there is followed here with no code change. Spells on their own
---   set - the SIRD ones, the cures, Phalanx - never match, and keep it.
---   @param spell table Spell data from GearSwap
---   @return boolean True if the spell would wear sets.FullEnmity
local function uses_full_enmity(spell)
    if not (sets.FullEnmity and sets.midcast) then
        return false
    end

    -- Plain == , not rawequal: the sandbox has no rawequal, and these sets carry
    -- no metatable, so == is the identity test anyway.
    -- Name wins over skill in MidcastManager's fallback chain, so a named set
    -- settles the question on its own.
    local by_name = sets.midcast[spell.english] or sets.midcast[spell.name]
    if by_name then
        return by_name == sets.FullEnmity
    end

    local by_skill = spell.skill and sets.midcast[spell.skill]
    return by_skill ~= nil and by_skill == sets.FullEnmity
end

---   Item name in a slot, whether written as a string or as {name = ...}
---   @param item string|table|nil Slot value from a set
---   @return string|nil Item name
local function item_name(item)
    if type(item) == 'table' then
        return item.name
    end
    return item
end

---   What sets.EnmityMax adds on top of sets.FullEnmity (today: the shield)
---   Both go through set_combine first so their slot names match (GearSwap
---   normalises slot aliases there).
---   @return table Slots to lay over an ability's own set
local function enmity_max_extra()
    local base = set_combine(sets.FullEnmity or {})
    local extra = {}
    for slot, item in pairs(set_combine(sets.EnmityMax)) do
        if item_name(base[slot]) ~= item_name(item) then
            extra[slot] = item
        end
    end
    return extra
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

---   Dress a job ability in maximum enmity gear (call from job_post_precast)
---   Weaponskills share action_type 'Ability' and are deliberately skipped:
---   they keep their own damage sets, and their main hand must not move.
---   @param spell table Spell/ability data from GearSwap
---   @return boolean True if sets.EnmityMax was equipped
function EnmityOverride.apply_precast(spell)
    if not spell or not is_active() then
        return false
    end
    if spell.action_type ~= 'Ability' or spell.type == 'WeaponSkill' then
        return false
    end

    -- Mote's default precast has already equipped the ability's own set,
    -- built on sets.FullEnmity with its specific piece (Sentinel's feet,
    -- Rampart's head...). Equipping all of sets.EnmityMax here replaced those
    -- pieces; laying only what it adds keeps them.
    equip(enmity_max_extra())
    return true
end

---   Dress a spell in maximum enmity gear (call from job_post_midcast)
---   Only the spells that wear sets.FullEnmity are swapped - Flash and
---   Jettatura in the template, plus Crusade in the live sets. The SIRD spells
---   keep their own set: max enmity is worth nothing on a cast that gets
---   interrupted.
---   @param spell table Spell data from GearSwap
---   @return boolean True if sets.EnmityMax was equipped
function EnmityOverride.apply_midcast(spell)
    if not spell or not is_active() then
        return false
    end
    if spell.action_type ~= 'Magic' or not uses_full_enmity(spell) then
        return false
    end

    equip(sets.EnmityMax)
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return EnmityOverride

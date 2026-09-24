---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Pet Precast Module - Pet Ability Precast Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Precast gear for BST-style pet abilities (Reward, Killer Instinct, Spur,
---   Ready moves). NOTE: no engine or Mote code calls job_pet_precast, so this
---   hook never runs.
---
---   @file    shared/jobs/pup/functions/PUP_PET_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-18
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   PET PRECAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Equip the precast set for a pet ability (Reward, Killer Instinct, Spur, Ready moves)
---   @param spell table Spell/ability data
function job_pet_precast(spell)
    local name = spell.name
    local set

    -- ══════════════════════════════════════════════════════════════════════════
    -- SPECIAL PET ABILITIES
    -- ══════════════════════════════════════════════════════════════════════════

    if name == 'Reward' then
        -- Reward set (Pet Food Theta equipped)
        set = sets.precast.JA['Reward']

    elseif name == 'Killer Instinct' then
        set = sets.precast.JA['Killer Instinct']

    elseif name == 'Spur' then
        set = sets.precast.JA['Spur']

    -- ══════════════════════════════════════════════════════════════════════════
    -- READY MOVES (Default handling)
    -- ══════════════════════════════════════════════════════════════════════════
    elseif player.status ~= 'Engaged' then
        -- Player idle - use Misc Idle set
        set = sets.precast.JA['Misc Idle']
    else
        -- Player engaged - use Default set
        set = sets.precast.JA['Default']
    end

    -- Equip set if found
    if set then
        equip(set)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_pet_precast = job_pet_precast

-- Module table for require() compatibility (parity with _G export above)
return {
    job_pet_precast = job_pet_precast,
}

---  ═══════════════════════════════════════════════════════════════════════════
---   BST Pet Midcast Module - Ready Move Midcast Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast gear for Ready Moves (pet TP moves).
---   This is a SPECIAL hook called ONLY for pet abilities during midcast.
---
---   @file    shared/jobs/bst/functions/BST_PET_MIDCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-18
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

-- Ready move categorizer
local success_rmc, ReadyMoveCategorizer = pcall(require, 'shared/jobs/bst/functions/logic/ready_move_categorizer')
if not success_rmc then
    ReadyMoveCategorizer = nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PET MIDCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Called during pet ability midcast (specifically for Ready Moves)
---   @param spell table Spell/ability data
---   @return void
function job_pet_midcast(spell)
    -- ══════════════════════════════════════════════════════════════════════════
    -- READY MOVES - KEEP PRECAST SET (Ready Recast gear)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Ready Recast bonus (like Fast Cast) requires the gear to stay equipped
    -- during the ENTIRE cast (precast + midcast). Do NOT swap to pet damage
    -- gear until aftercast (after the recast timer is set).

    -- For ALL pet abilities: keep the precast set (Sic). The pet damage gear
    -- is equipped in job_aftercast. eventArgs.handled is not set, so Mote's
    -- default_pet_midcast still runs and equips sets.midcast.Pet if the sets
    -- file defines one.

    return  -- Exit without changing gear
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_pet_midcast = job_pet_midcast

-- Module table for require() compatibility (parity with _G export above)
return {
    job_pet_midcast = job_pet_midcast,
}


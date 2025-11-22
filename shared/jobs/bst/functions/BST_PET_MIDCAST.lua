---============================================================================
--- BST Pet Midcast Module - Ready Move Midcast Handling
---============================================================================
--- Handles midcast gear for Ready Moves (pet TP moves).
--- This is a SPECIAL hook called ONLY for pet abilities during midcast.
---
--- @file jobs/bst/functions/BST_PET_MIDCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-18
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Ready move categorizer
local success_rmc, ReadyMoveCategorizer = pcall(require, 'shared/jobs/bst/functions/logic/ready_move_categorizer')
if not success_rmc then
    ReadyMoveCategorizer = nil
end

---============================================================================
--- PET MIDCAST HOOK
---============================================================================

-- Debug helper
-- Debug helperlocal function show_equipment_pet_mid(label)    if not _G.BST_DEBUG_PRECAST then return end    -- Lazy load MessageFormatter if needed    local MessageFormatter = require('shared/utils/messages/message_formatter')    local eq = player.equipment    MessageFormatter.show_debug('PET_MIDCAST', '========================================================')    MessageFormatter.show_debug('PET_MIDCAST', label)    MessageFormatter.show_debug('PET_MIDCAST', '--------------------------------------------------------')    MessageFormatter.show_debug('PET_MIDCAST', '  main: ' .. (eq.main or 'empty'))    MessageFormatter.show_debug('PET_MIDCAST', '  hands: ' .. (eq.hands or 'empty'))    MessageFormatter.show_debug('PET_MIDCAST', '  legs: ' .. (eq.legs or 'empty'))    MessageFormatter.show_debug('PET_MIDCAST', '========================================================')end

--- Called during pet ability midcast (specifically for Ready Moves)
--- @param spell table Spell/ability data
--- @return void
function job_pet_midcast(spell)
    -- ==========================================================================
    -- READY MOVES - KEEP PRECAST SET (Ready Recast gear)
    -- ==========================================================================
    -- Ready Recast bonus (like Fast Cast) requires the gear to stay equipped
    -- during the ENTIRE cast (precast + midcast). Do NOT swap to pet damage
    -- gear until aftercast (after the recast timer is set).

    -- For ALL pet abilities: Keep precast set (Gleti's Breeches)
    -- The pet damage gear will be equipped in job_aftercast

    return  -- Exit without changing gear
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_pet_midcast = job_pet_midcast

-- Export as module
return {
    job_pet_midcast = job_pet_midcast
}

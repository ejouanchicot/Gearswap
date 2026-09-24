---  ═══════════════════════════════════════════════════════════════════════════
---   BST Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles aftercast logic for Beastmaster:
---   • Ready moves: equip the pet damage set for the move's category
---   • Pet summon / Ready move: start the entry file's pet monitor (2 s later)
---   Mote-Include returns to idle/engaged gear otherwise.
---
---   @file    shared/jobs/bst/functions/BST_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-17
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

-- Pet manager: nothing in this file calls it any more (its only user, a
-- post-command monitor helper, had no caller and was removed). The require
-- is kept so the module keeps loading at the same point.
local success_pm, PetManager = pcall(require, 'shared/jobs/bst/functions/logic/pet_manager')
if not success_pm then
    PetManager = nil
end

-- Ready move categorizer (for pet damage gear selection)
local ReadyMoveCategorizer = nil
local success_rmc
success_rmc, ReadyMoveCategorizer = pcall(require, 'shared/jobs/bst/functions/logic/ready_move_categorizer')
if not success_rmc then
    ReadyMoveCategorizer = nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Called after spell/ability completes
---   Ready moves get the pet damage set; everything else is left to Mote
---
---   @param spell table Spell/ability data
---   @param action table Action information (not used)
---   @param spellMap string Spell mapping (not used)
---   @param eventArgs table Event arguments (handled set after a Ready move)
---   @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- READY MOVES - Swap to pet damage gear (recast already captured in PRECAST)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Detect on spell.type == 'Monster' and recompute the category here rather
    -- than reading the fields BST_PRECAST put on the spell.
    -- A refused or interrupted move gets no pet aftercast, so the pet set
    -- would stay on: let Mote re-equip instead.
    if spell.type == 'Monster' and not spell.interrupted and ReadyMoveCategorizer then
        -- Recalculate category (spell properties from precast don't persist to aftercast)
        local category = ReadyMoveCategorizer.get_category(spell.name)

        if category and category ~= 'Default' then
            local player_engaged = (player and player.status == 'Engaged')
            local use_ww = player_engaged

            local set = nil

            if category == 'Physical' then
                set = use_ww and sets.midcast.pet_physical_moves_ww or sets.midcast.pet_physical_moves
            elseif category == 'PhysicalMulti' then
                set = use_ww and sets.midcast.pet_physicalMulti_moves_ww or sets.midcast.pet_physicalMulti_moves
            elseif category == 'MagicAtk' then
                set = use_ww and sets.midcast.pet_magicAtk_moves_ww or sets.midcast.pet_magicAtk_moves
            elseif category == 'MagicAcc' then
                set = use_ww and sets.midcast.pet_magicAcc_moves_ww or sets.midcast.pet_magicAcc_moves
            end

            if set then
                equip(set)
            end

            eventArgs.handled = true
            return
        end
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- PET SUMMON DETECTION (Start background monitoring)
    -- ══════════════════════════════════════════════════════════════════════════
    if spell.type == 'Monster' or spell.english == 'Call Beast' or spell.english == 'Bestial Loyalty' then
        -- Pet summon detected - start smart background monitoring
        if _G.start_pet_monitoring then
            coroutine.schedule(function()
                _G.start_pet_monitoring()
            end, 2.0)  -- Wait 2s for pet to fully spawn
        end
    end

    -- No forced 'gs c update' here: it caused lag spikes after each action,
    -- and Mote-Include returns to idle/engaged by itself.
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast


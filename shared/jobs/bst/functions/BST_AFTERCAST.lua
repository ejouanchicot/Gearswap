---============================================================================
--- BST Aftercast Module - Post-Action Cleanup
---============================================================================
--- Handles aftercast logic for Beastmaster:
---   • Return to idle or engaged gear after action completes
---
--- @file jobs/bst/functions/BST_AFTERCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Pet manager (for pet status monitoring)
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

---============================================================================
--- TEMPORARY PET MONITORING (after pet commands)
---============================================================================

--- Monitor pet status multiple times after pet command (Fight, Heel, etc.)
--- Checks 10 times over 5 seconds, then stops (event-driven, not constant polling)
---
--- @param checks_remaining number Number of checks remaining
--- @return void
local function monitor_pet_after_command(checks_remaining)
    if not PetManager or checks_remaining <= 0 then
        return
    end

    -- Check current pet status
    local status_changed = PetManager.monitor_pet_status()

    -- If status changed, stop monitoring (mission accomplished)
    if status_changed then
        return
    end

    -- Schedule next check (0.5s later)
    coroutine.schedule(function()
        monitor_pet_after_command(checks_remaining - 1)
    end, 0.5)
end

---============================================================================
--- AFTERCAST HOOK
---============================================================================

--- Called after spell/ability completes
--- Returns to idle or engaged gear based on player status
---
--- @param spell table Spell/ability data
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping (not used)
--- @param eventArgs table Event arguments (not used)
--- @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- ==========================================================================
    -- READY MOVES - Swap to pet damage gear (recast already captured in PRECAST)
    -- ==========================================================================
    -- Use spell.type == 'Monster' like reference BST.lua (custom properties don't persist)
    if spell.type == 'Monster' and ReadyMoveCategorizer then
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

    -- No unlock needed - main weapon was already unlocked at start of midcast

    -- ==========================================================================
    -- PET SUMMON DETECTION (Start background monitoring)
    -- ==========================================================================
    if spell.type == 'Monster' or spell.english == 'Call Beast' or spell.english == 'Bestial Loyalty' then
        -- Pet summon detected - start smart background monitoring
        if _G.start_pet_monitoring then
            coroutine.schedule(function()
                _G.start_pet_monitoring()
            end, 2.0)  -- Wait 2s for pet to fully spawn
        end
    end

    -- ==========================================================================
    -- PET COMMAND MONITORING (Fight, Heel, etc.)
    -- ==========================================================================
    -- DISABLED: Background monitoring in Tetsouo_BST.lua handles this now
    -- (checks every 1 second continuously - no need for temporary monitoring)
    --
    -- if PetManager and spell.type == 'PetCommand' then
    --     coroutine.schedule(function()
    --         monitor_pet_after_command(10)
    --     end, 0.5)
    -- end

    -- No other BST-specific aftercast logic required
    -- Mote-Include handles return to idle/engaged automatically

    -- REMOVED: gs c update (causait des lags après chaque action)
    -- GearSwap gère déjà le refresh automatiquement via status_change
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast

-- Export as module
return {
    job_aftercast = job_aftercast
}

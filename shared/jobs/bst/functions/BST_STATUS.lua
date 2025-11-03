---============================================================================
--- BST Status Module - Status Change Handling
---============================================================================
--- Handles status changes (Idle, Engaged, Dead, etc.) for Beastmaster.
--- Monitors pet engagement and triggers auto-engage if conditions met.
---
--- @file jobs/bst/functions/BST_STATUS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Pet manager (for auto-engage)
local success_pm, PetManager = pcall(require, 'shared/jobs/bst/functions/logic/pet_manager')
if not success_pm then
    MessageFormatter.error_bst_module_not_loaded('PetManager')
    PetManager = nil
end

---============================================================================
--- STATUS CHANGE HOOK
---============================================================================

--- Called when player status changes (Idle → Engaged, Engaged → Idle, etc.)
--- Triggers pet auto-engage when player engages
---
--- @param newStatus string New status ("Idle", "Engaged", "Dead", etc.)
--- @param oldStatus string Old status
--- @param eventArgs table Event arguments (not used)
--- @return void
function job_status_change(newStatus, oldStatus, eventArgs)

    ---========================================================================
    --- PET AUTO-ENGAGE (when player engages)
    ---========================================================================

    if newStatus == 'Engaged' and oldStatus ~= 'Engaged' then
        -- Player just engaged - check if pet should auto-engage
        if PetManager then
            coroutine.schedule(function()
                PetManager.check_and_engage_pet(_G.pet)
            end, 1.0) -- 1.0s delay to ensure pet data is loaded
        end
    end

    ---========================================================================
    --- PET STATUS MONITORING
    ---========================================================================

    -- Monitor pet status (update petEngaged state if needed)
    if newStatus == 'Engaged' or newStatus == 'Idle' then
        if PetManager then
            coroutine.schedule(function()
                PetManager.monitor_pet_status()
            end, 0.1)
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_status_change = job_status_change

-- Export as module
return {
    job_status_change = job_status_change
}

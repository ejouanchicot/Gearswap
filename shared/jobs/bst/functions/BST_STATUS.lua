---  ═══════════════════════════════════════════════════════════════════════════
---   BST Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Status change hook, built by LifecycleManager (unlocks Doom slots so a
---   raise does not leave them stuck).
---
---   @file    shared/jobs/bst/functions/BST_STATUS.lua
---   @author  ejouanchicot
---   @version 1.2 - Added DoomManager safety unlock
---   @date    Updated: 2025-11-14
---  ═══════════════════════════════════════════════════════════════════════════

--- BST adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to status_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_status_change = LifecycleManager.status_change()

--- A pet comes out: its family and what it beats / what beats it, in the chat (ecosystem_manager.lua).
--- Mote's own pet_change goes on (eventArgs left as it is).
--- @param pet table GearSwap's pet
--- @param gain boolean True when the pet appears
function job_pet_change(pet, gain)
    if not gain or not pet or not pet.name then return end
    local ok, Eco = pcall(require, 'shared/jobs/bst/functions/logic/ecosystem_manager')
    if not ok or not Eco then return end
    local eco, shown = Eco.ecosystem_of(pet.name)
    if eco then Eco.show_correlation(eco, shown) end
end

-- Export to global scope
_G.job_status_change = job_status_change
_G.job_pet_change = job_pet_change

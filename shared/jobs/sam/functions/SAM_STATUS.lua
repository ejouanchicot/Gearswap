---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Status change handler: the shared LifecycleManager one (unlocks Doom
---   slots so a raise does not leave them stuck), plus Hasso on engaging when
---   the character turned it on (config/AUTO_ABILITIES.lua).
---
---   @file    shared/jobs/sam/functions/SAM_STATUS.lua
---   @author  Tetsouo
---   @version 1.2 - Added DoomManager safety unlock
---   @date    Updated: 2025-11-14
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

--- Hasso on engaging, when config/AUTO_ABILITIES.lua sets sam_hasso: not
--- over Hasso or Seigan, and only once its recast is ready.
--- @param newStatus string
local function auto_hasso(newStatus)
    if newStatus ~= 'Engaged' then return end
    if not require('shared/utils/core/auto_options').on('sam_hasso') then return end
    if buffactive['Hasso'] or buffactive['Seigan'] then return end
    if require('shared/utils/precast/ability_helper').is_ability_ready('Hasso') then
        send_command('input /ja "Hasso" <me>')
    end
end

job_status_change = LifecycleManager.status_change(auto_hasso)

-- Export to global scope
_G.job_status_change = job_status_change

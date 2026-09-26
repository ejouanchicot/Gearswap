---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Status change handler: the shared LifecycleManager one (unlocks Doom
---   slots so a raise does not leave them stuck).
---
---   @file    shared/jobs/blu/functions/BLU_STATUS.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

--- BLU adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to status_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_status_change = LifecycleManager.status_change()

_G.job_status_change = job_status_change

return { job_status_change = job_status_change }

---  ═══════════════════════════════════════════════════════════════════════════
---   RUN Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Status change handler: the shared LifecycleManager one (unlocks Doom
---   slots so a raise does not leave them stuck).
---
---   @file    shared/jobs/run/functions/RUN_STATUS.lua
---   @author  Tetsouo
---   @version 1.2 - Added DoomManager safety unlock
---   @date    Updated: 2025-11-14
---  ═══════════════════════════════════════════════════════════════════════════

--- RUN adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to status_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_status_change = LifecycleManager.status_change()

-- Export to global scope
_G.job_status_change = job_status_change

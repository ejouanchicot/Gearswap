---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Status change hook (Idle, Engaged, Resting, Dead...). Delegates to the
---   shared LifecycleManager handler, which unlocks Doom slots after a raise.
---
---   @file    shared/jobs/geo/functions/GEO_STATUS.lua
---   @author  Tetsouo
---   @version 1.2 - Added DoomManager safety unlock
---   @date    Created: 2025-11-03 | Updated: 2025-11-14
---  ═══════════════════════════════════════════════════════════════════════════

--- GEO adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to status_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_status_change = LifecycleManager.status_change()

-- Export to global scope
_G.job_status_change = job_status_change

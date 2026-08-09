---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles status changes (Idle, Engaged, Resting, Dead, etc.)
---
---   @file    shared/jobs/geo/functions/GEO_STATUS.lua
---   @author  Tetsouo
---   @version 1.2 - Added DoomManager safety unlock
---   @date    Updated: 2025-11-14
---  ═══════════════════════════════════════════════════════════════════════════

--- GEO adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to status_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_status_change = LifecycleManager.status_change()

-- Export to global scope
_G.job_status_change = job_status_change

---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Status Module - Player Status Changes
---  ═══════════════════════════════════════════════════════════════════════════
---   The shared LifecycleManager handler: Doom slots, engage / disengage
---   held back during an action.
---
---   @file    shared/jobs/sch/functions/SCH_STATUS.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_status_change = LifecycleManager.status_change()

_G.job_status_change = job_status_change

return { job_status_change = job_status_change }

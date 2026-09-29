---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Status Module - Player Status Changes
---  ═══════════════════════════════════════════════════════════════════════════
---   The shared LifecycleManager handler: Doom slots, engage / disengage held
---   back during an action (a ranged attack in flight keeps its gear).
---
---   @file    shared/jobs/rng/functions/RNG_STATUS.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

--- RNG adds nothing of its own: the shared handler is the whole behaviour.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_status_change = LifecycleManager.status_change()

_G.job_status_change = job_status_change

return { job_status_change = job_status_change }

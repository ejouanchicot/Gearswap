---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Status Module - Player Status Changes
---  ═══════════════════════════════════════════════════════════════════════════
---   job_status_change: the shared LifecycleManager handler (Doom slots,
---   engage / disengage held back during an action).
---
---   The wyvern needs no hook here: Mote's pet_change equips the idle /
---   engaged gear when the wyvern comes or goes (the wyvern layer follows),
---   and nothing DRG wears depends on the wyvern's own status.
---
---   @file    shared/jobs/drg/functions/DRG_STATUS.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_status_change = LifecycleManager.status_change()

_G.job_status_change = job_status_change

return { job_status_change = job_status_change }

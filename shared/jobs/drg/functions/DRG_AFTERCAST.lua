---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   Aftercast hook. Mote puts idle/engaged gear back on its own; the shared
---   LifecycleManager handler only ticks the watchdog.
---
---   @file    shared/jobs/drg/functions/DRG_AFTERCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

--- DRG adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to aftercast() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_aftercast = LifecycleManager.aftercast()

_G.job_aftercast = job_aftercast

return { job_aftercast = job_aftercast }

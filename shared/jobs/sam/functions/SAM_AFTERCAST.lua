---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Aftercast Module - Aftercast Logic
---  ═══════════════════════════════════════════════════════════════════════════
---   @file    SAM_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-21
---  ═══════════════════════════════════════════════════════════════════════════

--- SAM adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to aftercast() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_aftercast = LifecycleManager.aftercast()

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_aftercast = job_aftercast

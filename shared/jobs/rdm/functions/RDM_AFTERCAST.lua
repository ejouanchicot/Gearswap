---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles gear return after actions complete (return to idle/engaged).
---
---   @file    shared/jobs/rdm/functions/RDM_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.1 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

--- RDM adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to aftercast() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_aftercast = LifecycleManager.aftercast()

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export to global scope (used by Mote-Include via include())
_G.job_aftercast = job_aftercast

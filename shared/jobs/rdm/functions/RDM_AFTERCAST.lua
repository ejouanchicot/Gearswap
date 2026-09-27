---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   Aftercast hook. Mote puts idle/engaged gear back on its own; the shared
---   LifecycleManager handler only ticks the watchdog.
---
---   @file    shared/jobs/rdm/functions/RDM_AFTERCAST.lua
---   @author  ejouanchicot
---   @version 1.1 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

--- RDM adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to aftercast() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

-- A spell that needed a piece (Dispelga: Daybreak) gives the weapon back
job_aftercast = LifecycleManager.aftercast(function()
    require('shared/utils/equipment/spell_gear_lock').release()
end)

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export to global scope (used by Mote-Include via include())
_G.job_aftercast = job_aftercast

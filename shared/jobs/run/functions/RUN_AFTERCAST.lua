---  ═══════════════════════════════════════════════════════════════════════════
---   RUN Aftercast Module - Aftercast Hooks
---  ═══════════════════════════════════════════════════════════════════════════
---   job_aftercast is the shared LifecycleManager handler (watchdog tick);
---   Mote-Include re-equips idle/engaged gear afterwards.
---
---   @file    shared/jobs/run/functions/RUN_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-03
---  ═══════════════════════════════════════════════════════════════════════════

--- RUN adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to aftercast() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_aftercast = LifecycleManager.aftercast()

---  ═══════════════════════════════════════════════════════════════════════════
---   POST-AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Called after aftercast set selection. Empty: RUN has no adjustment here.
---   @param spell     table  Spell/ability data
---   @param action    string Action type (not used)
---   @param spellMap  string Spell mapping (not used)
---   @param eventArgs table  Event arguments (not used)
---   @return void
function job_post_aftercast(spell, action, spellMap, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast
_G.job_post_aftercast = job_post_aftercast

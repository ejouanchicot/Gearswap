---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Aftercast Module - Post-Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Aftercast hook for Paladin, built by the shared LifecycleManager.
---
---   @file    shared/jobs/pld/functions/PLD_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-11-03
---  ═══════════════════════════════════════════════════════════════════════════

--- PLD adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to aftercast() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_aftercast = LifecycleManager.aftercast()

---  ═══════════════════════════════════════════════════════════════════════════
---   POST-AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Called after aftercast set selection for additional adjustments
---   @param spell     table  Spell/ability data
---   @param action    string Action type (not used)
---   @param spellMap  string Spell mapping (not used)
---   @param eventArgs table  Event arguments (not used)
function job_post_aftercast(spell, action, spellMap, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast
_G.job_post_aftercast = job_post_aftercast

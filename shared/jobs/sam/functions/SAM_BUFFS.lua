---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Buff gain/loss handler: the shared LifecycleManager one (Doom handling).
---
---   @file    shared/jobs/sam/functions/SAM_BUFFS.lua
---   @author  ejouanchicot
---   @version 1.1 - Removed dead code + refactored header
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

--- SAM adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to buff_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

-- Aftermath Lv.3: rebuild so sets.engaged.AM3 goes on or off
job_buff_change = LifecycleManager.buff_change(function(buff)
    LifecycleManager.refresh_after_buff(buff)
end)

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

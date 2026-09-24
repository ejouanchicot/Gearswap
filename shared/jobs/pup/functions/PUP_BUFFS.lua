---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Buff gain/loss hook. Only the shared LifecycleManager handler runs (Doom);
---   PUP has no buff-specific logic of its own.
---
---   @file    shared/jobs/pup/functions/PUP_BUFFS.lua
---   @author  Tetsouo
---   @version 1.1 - Removed dead code + refactored header
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

--- PUP adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to buff_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_buff_change = LifecycleManager.buff_change()

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

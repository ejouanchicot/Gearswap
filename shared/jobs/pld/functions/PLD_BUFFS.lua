---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Buff gain/loss hook. Delegates to the shared LifecycleManager handler
---   (Doom handling).
---
---   @file    shared/jobs/pld/functions/PLD_BUFFS.lua
---   @author  Tetsouo
---   @version 1.1 - Removed dead code + refactored header
---   @date    Created: 2025-11-03 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

--- PLD adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to buff_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_buff_change = LifecycleManager.buff_change()

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

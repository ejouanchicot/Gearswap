---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles job-specific buff gain/loss events (Doom, Chainspell, etc.).
---
---   @file    shared/jobs/rdm/functions/RDM_BUFFS.lua
---   @author  Tetsouo
---   @version 1.1 - Removed dead code + refactored header
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

--- RDM adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to buff_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_buff_change = LifecycleManager.buff_change()

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

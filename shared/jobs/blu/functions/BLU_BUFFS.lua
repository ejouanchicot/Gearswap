---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Buff gain/loss hook: the shared LifecycleManager handler (Doom). The
---   Blue Magic buffs (Chain Affinity, Burst Affinity, Efflux...) need
---   nothing here: BLU_MIDCAST reads buffactive when the spell goes off.
---
---   @file    shared/jobs/blu/functions/BLU_BUFFS.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

--- BLU adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to buff_change() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_buff_change = LifecycleManager.buff_change()

_G.job_buff_change = job_buff_change

return { job_buff_change = job_buff_change }

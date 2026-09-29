---  ═══════════════════════════════════════════════════════════════════════════
---   MNK Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   The shared LifecycleManager handler (Doom first), then
---   refresh_after_buff: Impetus, Footwork, Hundred Fists or Counterstance
---   coming or going rebuilds the idle / engaged set a moment later, once
---   buffactive holds the change, so its sets.buff layer goes on or comes
---   off (logic/buff_layers.lua).
---
---   @file    shared/jobs/mnk/functions/MNK_BUFFS.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_buff_change = LifecycleManager.buff_change(function(buff, gain, eventArgs)
    LifecycleManager.refresh_after_buff(buff)
end)

_G.job_buff_change = job_buff_change

return { job_buff_change = job_buff_change }

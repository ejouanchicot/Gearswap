---  ═══════════════════════════════════════════════════════════════════════════
---   NIN Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   The shared LifecycleManager handler (Doom first), then
---   refresh_after_buff: Yonin, Innin, Sange or Issekigan coming or going
---   rebuilds the engaged set a moment later, once buffactive holds the
---   change, so its sets.buff layer goes on or comes off
---   (logic/set_builder.lua). Futae needs nothing here: NIN_MIDCAST reads
---   buffactive when the spell goes off.
---
---   @file    shared/jobs/nin/functions/NIN_BUFFS.lua
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

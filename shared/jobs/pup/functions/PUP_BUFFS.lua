---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   The shared LifecycleManager handler (Doom first), then
---   refresh_after_buff: Overdrive coming or going rebuilds the idle /
---   engaged set a moment later, once buffactive holds the change, so
---   sets.buff.Overdrive goes on or comes off.
---
---   @file    shared/jobs/pup/functions/PUP_BUFFS.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_buff_change = LifecycleManager.buff_change(function(buff, gain, eventArgs)
    LifecycleManager.refresh_after_buff(buff)
end)

_G.job_buff_change = job_buff_change

return { job_buff_change = job_buff_change }

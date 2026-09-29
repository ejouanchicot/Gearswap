---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   The shared LifecycleManager handler (Doom first). No Ranger buff swaps
---   the idle or engaged set: the ranged buffs (Barrage, Double Shot,
---   Velocity Shot...) only change the gear of the shot itself, read live
---   at precast / midcast (logic/ranged.lua), so nothing is rebuilt here and
---   none of them is in LifecycleManager's GEAR_BUFFS.
---
---   @file    shared/jobs/rng/functions/RNG_BUFFS.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_buff_change = LifecycleManager.buff_change()

_G.job_buff_change = job_buff_change

return { job_buff_change = job_buff_change }

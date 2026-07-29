---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Aftercast Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Returns to idle or engaged gear after an action completes. Lets
---   Mote-Include's default handling do the work; this hook only notifies the
---   watchdog and lets DoomManager unlock slots on death.
---
---   @file    shared/jobs/smn/functions/SMN_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

function job_aftercast(spell, action, spellMap, eventArgs)
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end
    -- Mote-Include handles idle/engaged restoration automatically.
end

_G.job_aftercast = job_aftercast

return {
    job_aftercast = job_aftercast,
}

---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Aftercast Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Returns to idle or engaged gear after an action completes. Lets
---   Mote-Include's default handling do the work; this hook only notifies the
---   watchdog (same body as LifecycleManager.aftercast()).
---
---   @file    shared/jobs/smn/functions/SMN_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

--- Aftercast hook: ticks the midcast watchdog.
--- @param spell table Spell/ability data
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end
end

_G.job_aftercast = job_aftercast

return {
    job_aftercast = job_aftercast,
}

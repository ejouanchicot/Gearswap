---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Aftercast Module - Aftercast Logic
---  ═══════════════════════════════════════════════════════════════════════════
---   @file    SAM_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-21
---  ═══════════════════════════════════════════════════════════════════════════

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- SAM-specific aftercast logic

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_aftercast = job_aftercast

---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles aftercast logic for Black Mage job.
---   Returns to idle/engaged gear after spell completes.
---
---   @file    BLM_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-15
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- Clear Impact body lock flag (like BRD clears Marsyas lock)
    if spell.english == 'Impact' then
        _G.casting_impact = nil
        _G.impact_body = nil
    end

    -- BLM-SPECIFIC AFTERCAST LOGIC
    -- Currently none - Mote handles return to idle/engaged automatically

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_aftercast = job_aftercast


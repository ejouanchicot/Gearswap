---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles aftercast logic for Puppetmaster:
---   • Return to idle or engaged gear after action completes
---
---   @file    jobs/pup/functions/PUP_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-17
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Called after spell/ability completes
---   Returns to idle or engaged gear based on player status
---
---   @param spell table Spell/ability data
---   @param action string Action type (not used)
---   @param spellMap string Spell mapping (not used)
---   @param eventArgs table Event arguments (not used)
---   @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- No PUP-specific aftercast logic required
    -- Mote-Include handles return to idle/engaged automatically

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast

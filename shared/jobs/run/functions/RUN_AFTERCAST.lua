---  ═══════════════════════════════════════════════════════════════════════════
---   RUN Aftercast Module - Aftercast Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all aftercast actions for Rune Fencer job:
---   • Return to appropriate gear sets after actions
---   • Post-weaponskill equipment swaps
---   • Post-ability cleanup
---
---   @file    jobs/run/functions/RUN_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2025-10-03
---   @requires Tetsouo architecture
---  ═══════════════════════════════════════════════════════════════════════════
---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════
---   Called after action completes
---   Mote-Include automatically handles returning to idle/engaged sets.
---   RUN currently doesn't need custom aftercast logic.
---
---   @param spell     table  Spell/ability data
---   @param action    string Action type (not used)
---   @param spellMap  string Spell mapping (not used)
---   @param eventArgs table  Event arguments (not used)
---   @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---  ═══════════════════════════════════════════════════════════════════════════
---   POST-AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

---   Called after aftercast set selection for additional adjustments
---   @param spell     table  Spell/ability data
---   @param action    string Action type (not used)
---   @param spellMap  string Spell mapping (not used)
---   @param eventArgs table  Event arguments (not used)
---   @return void
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- RUN-specific post-aftercast adjustments
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast
_G.job_post_aftercast = job_post_aftercast

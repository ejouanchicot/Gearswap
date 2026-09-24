---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Aftercast Module - Aftercast Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   job_aftercast is empty: Mote-Include returns to idle/engaged gear.
---
---   @file    shared/jobs/war/functions/WAR_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-09-29
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════
---   Called after action completes
---   Mote-Include automatically handles returning to idle/engaged sets.
---   WAR currently doesn't need custom aftercast logic.
---
---   @param spell     table  Spell/ability data
---   @param action    string Action type (not used)
---   @param spellMap  string Spell mapping (not used)
---   @param eventArgs table  Event arguments (not used)
---   @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Gear refresh is left to Mote. The forced 'gs c update' here was
    -- redundant (removed 2026-06-09, validated in-game on WAR in Odyssey +
    -- Sortie). Unlike most jobs, WAR does not notify MidcastWatchdog, neither
    -- here nor in WAR_MIDCAST.
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast


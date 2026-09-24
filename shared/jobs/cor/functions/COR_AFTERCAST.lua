---  ═══════════════════════════════════════════════════════════════════════════
---   COR Aftercast Module - Post-Action Gear Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Aftercast hook for Corsair: stops the midcast watchdog and opens a bullet
---   pouch when the stack runs low after a ranged attack. Mote returns to
---   idle/engaged gear by itself.
---
---   @file    shared/jobs/cor/functions/COR_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-07
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Called after action completes
---   @param spell table Spell/ability data
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- Auto-open a bullet pouch when the stack runs low after a ranged attack.
    local ok, QuiverManager = pcall(require, 'shared/utils/inventory/quiver_manager')
    if ok and QuiverManager then
        QuiverManager.after_ranged_attack(spell, 'Bronze Bullet', 'Brz. Bull. Pouch', 15)
    end

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---   Called after aftercast gear is equipped (empty)
---   @param spell table Spell/ability data
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   @return void
function job_post_aftercast(spell, action, spellMap, eventArgs)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_aftercast = job_aftercast
_G.job_post_aftercast = job_post_aftercast


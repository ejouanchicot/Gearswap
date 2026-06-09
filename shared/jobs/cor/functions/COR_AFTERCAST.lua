---  ═══════════════════════════════════════════════════════════════════════════
---   COR Aftercast Module - Post-Action Gear Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles aftercast gear restoration for Corsair job.
---   Returns to appropriate idle/engaged gear after actions complete.
---
---   @file    COR_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-07
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Called after action completes
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- COR-specific aftercast logic
    -- Crooked Cards is now tracked via timestamp in PRECAST
    -- Weapons are automatically reapplied via customize_idle_set and customize_melee_set
    -- No manual intervention needed here

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---   Called after aftercast gear is equipped
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   @return void
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- COR-specific post-aftercast adjustments
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_aftercast = job_aftercast
_G.job_post_aftercast = job_post_aftercast


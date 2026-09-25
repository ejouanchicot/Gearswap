---  ═══════════════════════════════════════════════════════════════════════════
---   THF Aftercast Module - Aftercast Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles post-action cleanup and returns to appropriate idle/engaged gear.
---
---   Features:
---   • MidcastWatchdog tick
---   • SA/TA pending flag kept when the ability went off, lowered when refused
---     (_G.thf_sa_pending, _G.thf_ta_pending)
---   • Acid Bolt quiver auto-open after a ranged attack (QuiverManager)
---
---   Dependencies:
---   • Mote-Include (handles actual idle/engaged gear swap)
---
---   @file    shared/jobs/thf/functions/THF_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════

local SATA_PENDING_FLAGS = {
    ['Sneak Attack'] = 'thf_sa_pending',
    ['Trick Attack'] = 'thf_ta_pending',
}

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Called after action completes
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- Track SA/TA usage for immediate gear application (before buff appears in buffactive).
    -- Precast already raised the flag; an SA/TA the server refuses comes back
    -- here interrupted, and must lower it or the SA/TA gear stays on.
    local pending_flag = SATA_PENDING_FLAGS[spell.english]
    if spell.type == 'JobAbility' and pending_flag then
        _G[pending_flag] = not spell.interrupted
    end

    -- Auto-open Acid Bolt quiver when stack runs low after a ranged attack.
    local ok, QuiverManager = pcall(require, 'shared/utils/inventory/quiver_manager')
    if ok and QuiverManager then
        QuiverManager.after_ranged_attack(spell, 'Acid Bolt', 'Ac. Bolt Quiver', 5)
    end

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_aftercast = job_aftercast

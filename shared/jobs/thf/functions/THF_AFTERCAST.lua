---  ═══════════════════════════════════════════════════════════════════════════
---   THF Aftercast Module - Aftercast Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles post-action cleanup and returns to appropriate idle/engaged gear.
---
---   Features:
---   • Return to idle/engaged gear after actions complete
---   • SA/TA pending flag tracking (before buff appears in buffactive)
---   • Clean transition from precast >> midcast >> aftercast
---   • Global state management (_G.thf_sa_pending, _G.thf_ta_pending)
---
---   Dependencies:
---   • Mote-Include (handles actual idle/engaged gear swap)
---   • set_builder logic (constructs dynamic idle/engaged sets)
---
---   @file    jobs/thf/functions/THF_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════

-- Track recent SA/TA usage (persist until buff detected or consumed)
if not _G.thf_sa_pending then
    _G.thf_sa_pending = false
end

if not _G.thf_ta_pending then
    _G.thf_ta_pending = false
end

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

    -- Track SA/TA usage for immediate gear application (before buff appears in buffactive)
    if spell.type == 'JobAbility' and not spell.interrupted then
        if spell.english == 'Sneak Attack' then
            _G.thf_sa_pending = true
        elseif spell.english == 'Trick Attack' then
            _G.thf_ta_pending = true
        end
    end

    -- Auto-open Acid Bolt quiver when stack runs low after a ranged attack.
    -- Delayed slightly so FFXI has decremented the ammo count before we read it.
    if spell.type == 'RangedAttack' and not spell.interrupted then
        coroutine.schedule(function()
            local ok, QuiverManager = pcall(require, 'shared/utils/inventory/quiver_manager')
            if ok and QuiverManager then
                QuiverManager.check_and_refill('Acid Bolt', 'Ac. Bolt Quiver', 5)
            end
        end, 1.0)
    end

    -- Gear refresh is handled by Mote (status_change) + MidcastWatchdog (packet
    -- loss). The forced 'gs c update' here was redundant (removed 2026-06-09,
    -- validated in-game on WAR in Odyssey + Sortie).
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_aftercast = job_aftercast

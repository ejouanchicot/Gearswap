---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Aftercast Module - Aftercast Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all aftercast actions for Dark Knight job:
---   • Return to appropriate gear sets after actions
---   • Post-weaponskill equipment swaps
---   • Post-ability cleanup
---   • Buff pending flag confirmation
---
---   @file    DRK_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2025-10-23
---   @requires Tetsouo architecture, drk_buff_anticipation
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════
-- DRK buff anticipation loaded on first aftercast
local DRKBuffAnticipation = nil
local module_initialized = false

local function ensure_module_loaded()
    if not module_initialized then
        local ok, mod = pcall(require, 'shared/jobs/drk/functions/logic/drk_buff_anticipation')
        if ok then
            DRKBuffAnticipation = mod
        end
        module_initialized = true
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════
---   Called after action completes
---   Confirms pending flags for JA buffs (if not interrupted)
---
---   @param spell     table  Spell/ability data
---   @param action    string Action type (not used)
---   @param spellMap  string Spell mapping (not used)
---   @param eventArgs table  Event arguments (not used)
---   @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Lazy load DRK buff anticipation on first use
    ensure_module_loaded()
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- Confirm or withdraw the pending flags precast raised. An interrupted JA
    -- never grants the buff, so no buff_change will come to lower the flag -
    -- this is the only chance to do it.
    if spell.type == 'JobAbility' then
        if spell.name == 'Dark Seal' then
            _G.drk_dark_seal_pending = not spell.interrupted
        elseif spell.name == 'Nether Void' then
            _G.drk_nether_void_pending = not spell.interrupted
        end
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
    -- DRK-specific post-aftercast adjustments
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast
_G.job_post_aftercast = job_post_aftercast


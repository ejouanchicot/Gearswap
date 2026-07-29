---  ═══════════════════════════════════════════════════════════════════════════
---   THF Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles job-specific buff gain/loss events (Doom, Chainspell, etc.).
---
---   @file    shared/jobs/thf/functions/THF_BUFFS.lua
---   @author  Tetsouo
---   @version 1.1 - Removed dead code + refactored header
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local DoomManager = nil

local function ensure_managers_loaded()
    if not DoomManager then
        DoomManager = require('shared/utils/debuff/doom_manager')
    end
end

---   Handle buff change events
---   @param buff string Buff name
---   @param gain boolean True if buff gained, false if lost
function job_buff_change(buff, gain, eventArgs)
    -- Lazy load managers on first buff change
    ensure_managers_loaded()

    -- Doom handling (centralized)
    if DoomManager.handle_buff_change(buff, gain) then
        return -- Doom handled, stop processing
    end

    -- SA/TA pending bridge lifecycle: the pending flag only exists to cover the
    -- server lag before the buff appears in buffactive. Once the buff change
    -- fires (gain = buffactive now carries it; loss = consumed/expired), the
    -- bridge is no longer needed. Clearing on loss prevents a stale flag from
    -- sticking the SA/TA "waiting" set on forever when the buff is consumed by a
    -- melee round instead of a weaponskill.
    --
    -- CRITICAL: Mote-Include's buff_change() does NOT re-equip gear (unlike
    -- status_change/pet_change). So after the buff is lost, the SA/TA overlay
    -- (sets.buff['...'] applied by SetBuilder.apply_sata_buff) stays equipped
    -- until the next gear-triggering event. We must force a gear refresh here so
    -- the engaged overlay re-evaluates (buffactive now cleared + pending cleared
    -- => overlay removed). Only on loss, and only while engaged (overlay is
    -- engaged-only). Schedule slightly delayed so buffactive is fully updated.
    if buff == 'Sneak Attack' or buff == 'Trick Attack' then
        if buff == 'Sneak Attack' then
            _G.thf_sa_pending = false
        else
            _G.thf_ta_pending = false
        end

        if not gain and player and player.status == 'Engaged' then
            coroutine.schedule(function()
                send_command('gs c update')
            end, 0.1)
        end
    end
end

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

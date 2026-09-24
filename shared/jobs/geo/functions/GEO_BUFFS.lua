---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles buff gain/loss events: dual-box buff reporting, Doom, and the
---   Entrust pending flag.
---
---   @file    shared/jobs/geo/functions/GEO_BUFFS.lua
---   @author  Tetsouo
---   @version 1.1 - Removed dead code + refactored header
---   @date    Created: 2025-11-03 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local DoomManager = nil
local AltBuffReporter = nil

local function ensure_managers_loaded()
    if not DoomManager then
        DoomManager = require('shared/utils/debuff/doom_manager')
        AltBuffReporter = require('shared/utils/dualbox/alt_buff_reporter')
    end
end

---   Handle buff change events
---   @param buff string Buff name
---   @param gain boolean True if buff gained, false if lost
---   @param eventArgs table Event arguments (unused)
function job_buff_change(buff, gain, eventArgs)
    ensure_managers_loaded()

    -- Tell the main about tracked buffs (Entrust). No-op unless this character
    -- is the dual-box ALT, so it costs nothing on a solo GEO.
    AltBuffReporter.report(buff, gain)

    if DoomManager.handle_buff_change(buff, gain) then
        return -- Doom handled, stop processing
    end

    -- Entrust expires if it is never spent. Aftercast only lowers the pending
    -- flag once an Indi- consumes it, so without this an expired Entrust left
    -- the flag raised and the next Indi- went out in the Entrust set.
    if buff == 'Entrust' and not gain then
        _G.geo_entrust_pending = false
    end
end

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

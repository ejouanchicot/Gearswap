---  ═══════════════════════════════════════════════════════════════════════════
---   COR Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles job-specific buff gain/loss events (Doom, Chainspell, etc.).
---
---   @file    shared/jobs/cor/functions/COR_BUFFS.lua
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

--- Handle buff change events
--- @param buff string Buff name
--- @param gain boolean True if buff gained, false if lost
function job_buff_change(buff, gain, eventArgs)
    -- Lazy load managers on first buff change
    ensure_managers_loaded()

    -- Doom handling (centralized)
    if DoomManager.handle_buff_change(buff, gain) then
        return -- Doom handled, stop processing
    end

    -- COR-specific buff change logic can be added here
end

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

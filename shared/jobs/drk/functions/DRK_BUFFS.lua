---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles buff gain/loss events: Doom, Dark Seal / Nether Void pending
---   flags, and an engaged gear refresh on Aftermath: Lv.3.
---
---   @file    shared/jobs/drk/functions/DRK_BUFFS.lua
---   @author  Tetsouo
---   @version 1.1 - Removed dead code + refactored header
---   @date    Created: 2025-10-23 | Updated: 2025-11-12
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
---   @param eventArgs table Event arguments
function job_buff_change(buff, gain, eventArgs)
    ensure_managers_loaded()

    if DoomManager.handle_buff_change(buff, gain) then
        return -- Doom handled, stop processing
    end

    -- Dark Seal and Nether Void are single-charge buffs, consumed by the next
    -- dark spell. Precast raises a pending flag so the gear is right before
    -- buffactive catches up; the buff going away is what consumption looks
    -- like, and is the only moment the flag can be lowered. Without this it
    -- stayed raised for the rest of the session and every later Absorb, Drain
    -- and Aspir kept applying the variant set.
    if not gain then
        if buff == 'Dark Seal' then
            _G.drk_dark_seal_pending = false
        elseif buff == 'Nether Void' then
            _G.drk_nether_void_pending = false
        end
    end

    -- Aftermath Lv.3: Refresh engaged set to apply/remove AM3 gear (Liberator)
    -- BUT: If Doom is active, don't change gear (Doom priority)
    if buff == "Aftermath: Lv.3" then
        if not buffactive['doom'] then
            handle_equipping_gear(player.status)
        end
    end
end

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

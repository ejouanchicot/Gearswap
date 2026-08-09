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

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

--- Retire a Phantom Roll once its buff drops.
---
--- The roll tracker has no other way to learn a roll wore off - a bust and a
--- third roll remove their own entries, but plain expiry has no event of its
--- own. Without this the active list keeps claiming rolls that ended minutes
--- ago, and the next cast of one is read as a Double-Up of a corpse.
--- @param buff string Buff name from res.buffs
--- @param gain boolean True on gain, false on loss
local function retire_lost_roll(buff, gain)
    -- Plain sub rather than :endswith - that one comes from Windower's strings
    -- library, which GearSwap does not load.
    if gain or buff:sub(-5) ~= ' Roll' then
        return
    end

    local ok, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
    if ok and RollTracker and RollTracker.on_roll_buff_lost then
        RollTracker.on_roll_buff_lost(buff)
    end
end

job_buff_change = LifecycleManager.buff_change(retire_lost_roll)

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

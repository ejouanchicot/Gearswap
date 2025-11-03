---============================================================================
--- BRD Aftercast Module - Post-Action Cleanup
---============================================================================
--- Handles aftercast behavior for Bard job.
--- Returns to idle/engaged sets after songs/spells complete.
---
--- @file BRD_AFTERCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

-- Load message formatter for BRD messages
local MessageFormatter = require('shared/utils/messages/message_formatter')

--- Handle post-action cleanup
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- Clear Honor March protection flag after ANY action completes
    -- (Prevents flag from staying stuck if spell interrupted or error occurred)
    if _G.casting_honor_march then
        _G.casting_honor_march = nil
        if spell.type == 'BardSong' and spell.english == 'Honor March' then
            MessageFormatter.show_honor_march_released()
        end
    end

    -- CRITICAL FIX: Force gear refresh after songs/spells/WS
    -- BRD uses direct equip() calls in midcast which can block Mote's auto-return
    -- This ensures we ALWAYS return to idle/engaged gear correctly after action completes
    if not spell.interrupted then
        -- Use coroutine to delay gear refresh slightly (avoid race condition with lag)
        -- This ensures Mote has finished processing before we force refresh
        coroutine.schedule(function()
            -- Force GearSwap to re-evaluate current status and equip proper set
            -- This is the standard way to refresh gear (used by AutoMove, PetManager)
            send_command('gs c update')
        end, 0.1)  -- 100ms delay to handle lag/latency
    end
end

-- Export to global scope
_G.job_aftercast = job_aftercast

-- Export module
local BRD_AFTERCAST = {}
BRD_AFTERCAST.job_aftercast = job_aftercast

return BRD_AFTERCAST

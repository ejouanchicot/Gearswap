---============================================================================
--- COR Buffs Module - Buff Change Management
---============================================================================
--- Handles buff gain/loss for Corsair job.
--- Triggers gear changes or actions based on buff status.
--- Tracks Phantom Roll buffs for smart roll system.
---
--- @file COR_BUFFS.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-10-07
--- @date Updated: 2025-10-08 - Added roll tracking
---============================================================================

-- Load message formatter for buff display
local message_buffs_loaded = pcall(require, 'shared/utils/messages/message_buffs')
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load roll tracker for phantom roll detection
local roll_tracker_loaded, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
if not roll_tracker_loaded then
    RollTracker = nil
end

---============================================================================
--- BUFF CHANGE HOOKS
---============================================================================

-- Initialize Crooked Cards timestamp tracker
if not _G.cor_crooked_timestamp then
    _G.cor_crooked_timestamp = nil
end

-- Initialize party job tracking (for job bonus detection)
if not _G.cor_party_jobs then
    _G.cor_party_jobs = {}
end

if not _G.cor_party_state then
    _G.cor_party_state = {
        zone_id = 0,
        party_count = 0
    }
end

--- Called when buff is gained or lost
--- @param buff string Buff name
--- @param gain boolean True if buff gained, false if lost
--- @return void
function job_buff_change(buff, gain, eventArgs)
    -- Doom: HIGHEST PRIORITY - Must override everything
    if buff == 'doom' then
        local is_doomed = buffactive['doom']

        if is_doomed then
            equip(sets.buff.Doom)
            -- Disable slots to prevent other gear swaps from overwriting Doom gear
            disable('neck', 'ring1', 'ring2', 'waist')
            MessageFormatter.show_warning("DOOM detected! Equipping Doom gear.")
        else
            -- Enable slots before restoring gear
            enable('neck', 'ring1', 'ring2', 'waist')
            handle_equipping_gear(player.status)
            MessageFormatter.show_success("Doom removed.")
        end
        return  -- Stop processing - Doom takes absolute priority
    end

    -- COR-specific buff change logic

    -- Crooked Cards tracking is now done via timestamp in PRECAST/roll_tracker
    -- No need to track buff changes here

    -- Track Phantom Roll buffs (auto-detection when roll buff appears)
    if RollTracker and buff:match(' Roll$') then
        if gain then
            -- Check if we have a pending roll value from the action packet
            if _G.cor_pending_roll_value then
                local roll_value = _G.cor_pending_roll_value
                local roll_name = buff

                -- Clear pending value
                _G.cor_pending_roll_value = nil
                _G.cor_pending_roll_timestamp = nil

                -- Trigger full roll tracking with both name and value
                RollTracker.on_roll_cast(roll_name, roll_value)
            else
                -- Fallback to old method
                RollTracker.on_roll_buff_gained(buff)
            end
        else
            -- Roll buff lost - remove from active rolls
            if buff:match('XI$') then
                RollTracker.clear_natural_eleven()
            end

            -- Remove roll from active list (this also removes the has_crooked flag)
            if _G.cor_active_rolls then
                for i = #_G.cor_active_rolls, 1, -1 do
                    if _G.cor_active_rolls[i].name == buff then
                        table.remove(_G.cor_active_rolls, i)
                        break
                    end
                end
            end
        end
    end

    -- Handle important buff changes
    if buff == "Triple Shot" then
        -- Handle Triple Shot buff
        if gain then
            -- Triple Shot activated
        end
    elseif buff == "Flurry" or buff == "Flurry II" then
        -- Handle Flurry buffs (affects snapshot/rapid shot)
        if gain then
            -- Recalculate ranged gear
        end
    end
end
---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_buff_change = job_buff_change

-- Export module
local COR_BUFFS = {}
COR_BUFFS.job_buff_change = job_buff_change

return COR_BUFFS

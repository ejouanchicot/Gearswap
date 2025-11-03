---============================================================================
--- DNC Buff Management Module
---============================================================================
--- Handles Dancer job ability automation and subjob buff coordination with
--- intelligent buff management for Samba/Step tracking.
---
--- Features:
---   • Saber Dance buff tracking (-50% DW, forces engaged set refresh)
---   • Fan Dance buff tracking (20% DT, forces engaged set refresh)
---   • Doom detection and resistance gear
---   • Climactic Flourish timestamp tracking (instant detection)
---   • Samba/Step buff monitoring
---   • Subjob buff automation (SmartbuffManager integration)
---   • Sequential casting to avoid conflicts
---   • Flourish duration tracking
---
--- Dependencies:
---   • SmartbuffManager (logic) - subjob buff automation
---
--- @file    jobs/dnc/functions/DNC_BUFFS.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-04
--- @date    Updated: 2025-10-06
---============================================================================

-- Load DNC logic modules
local SmartbuffManager = require('shared/jobs/dnc/functions/logic/smartbuff_manager')
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Initialize Climactic Flourish timestamp tracker
if not _G.dnc_climactic_timestamp then
    _G.dnc_climactic_timestamp = nil
end

---============================================================================
--- BUFF CHANGE HOOKS
---============================================================================

--- Called when buffs are gained or lost
--- @param buff string Buff name
--- @param gain boolean True if gained, false if lost
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

    -- Saber Dance buff change: refresh engaged set
    -- Saber Dance reduces DW requirement by 50%, changes gear strategy completely
    if buff == 'Saber Dance' then
        -- Force engaged set refresh when Saber Dance is gained or lost
        handle_equipping_gear(player.status)
    end

    -- Fan Dance buff change: refresh engaged set
    -- Fan Dance provides 20% DT, allowing us to swap between FanDance and PDT sets
    if buff == 'Fan Dance' then
        -- Force engaged set refresh when Fan Dance is gained or lost
        if state.HybridMode and state.HybridMode.current == 'PDT' then
            handle_equipping_gear(player.status)
        end
    end
end

---============================================================================
--- SMARTBUFF AUTOMATION
---============================================================================

--- Applies subjob-specific buffs automatically for DNC
--- Detects current subjob and activates appropriate abilities
--- @return boolean Success status
function apply_smartbuff()
    return SmartbuffManager.apply()
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make functions available globally for GearSwap
_G.job_buff_change = job_buff_change
_G.apply_smartbuff = apply_smartbuff

-- Also export as module for potential future use
local DNC_BUFFS = {}
DNC_BUFFS.job_buff_change = job_buff_change
DNC_BUFFS.apply_smartbuff = apply_smartbuff

return DNC_BUFFS

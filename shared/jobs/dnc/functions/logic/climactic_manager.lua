---============================================================================
--- Climactic Flourish Auto-Trigger Manager (Logic Module)
---============================================================================
--- Automatically triggers Climactic Flourish before configured weaponskills
--- when conditions are met.
---
--- Features:
---   • Auto-trigger Climactic Flourish before configured WS (Rudra's, Ruthless, Shark Bite)
---   • Condition checks (TP >= 1000, target HP > 25%, 3+ Finishing Moves)
---   • User toggle support (state.ClimacticAuto On/Off)
---   • Optimized 1s delay (down from 2s for faster execution)
---   • AbilityHelper integration for centralized ability triggering
---   • DNCWSConfig integration for WS whitelist
---
--- Performance:
---   • Climactic >> WS total time: ~1.3s (1s ability delay + 0.3s stability)
---
--- @file    jobs/dnc/functions/logic/climactic_manager.lua
--- @author  Tetsouo
--- @version 1.1 - Optimized Timing
--- @date    Created: 2025-10-06
--- @date    Updated: 2025-10-10 (Optimized delay: 2s>>1s)
---============================================================================

local ClimaticManager = {}

-- Load dependencies
local AbilityHelper = require('shared/utils/precast/ability_helper')
local DNCWSConfig = _G.DNCWSConfig or {}  -- Loaded from character main file

---============================================================================
--- AUTO-TRIGGER LOGIC
---============================================================================

--- Auto-trigger Climactic Flourish before configured weaponskills
--- @param spell table Weaponskill spell object
--- @param eventArgs table Event arguments for cancellation
function ClimaticManager.auto_trigger(spell, eventArgs)
    -- Only process weaponskills
    if spell.type ~= 'WeaponSkill' then
        return
    end

    -- Check if auto-trigger is enabled (state.ClimacticAuto)
    if state and state.ClimacticAuto and state.ClimacticAuto.value == 'Off' then
        return  -- Auto-trigger disabled by user
    end

    -- Check conditions: TP >= min_tp, target HP > min_hpp, 3+ Finishing Moves
    -- Note: Lag causes GearSwap to see 800-950 TP when user launches at 1000 TP
    if player.tp >= DNCWSConfig.min_tp and
        player.target and player.target.hpp and player.target.hpp > DNCWSConfig.min_target_hpp and
        (buffactive['Finishing Move (3+)'] or buffactive['Finishing Move (6+)']) then
        -- Check if this WS is configured to auto-trigger Climactic Flourish
        if DNCWSConfig.should_use_climactic(spell.name) then
            -- Use centralized ability helper (1s delay before WS - optimized from 2s)
            AbilityHelper.try_ability_ws(spell, eventArgs, 'Climactic Flourish', 1)
        end
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return ClimaticManager

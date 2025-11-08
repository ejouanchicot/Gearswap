---============================================================================
--- DNC Weaponskill Configuration
---============================================================================
--- Defines which weaponskills should auto-trigger Climactic Flourish and other
--- WS-specific behaviors for Dancer job.
---
--- Features:
---   • Climactic Flourish automation for configured weaponskills
---   • Minimum TP threshold for auto-trigger (1000 TP default)
---   • Minimum target HP% threshold (25% default - prevents waste on dying mobs)
---   • WS whitelist system (Rudra's Storm, Ruthless Stroke, Shark Bite)
---   • Helper function to check if WS should trigger Climactic
---
--- @file    config/dnc/DNC_WS_CONFIG.lua
--- @author  Morphetrix
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local DNCWSConfig = {}

---============================================================================
--- CLIMACTIC FLOURISH AUTOMATION
---============================================================================

--- List of weaponskills that should auto-trigger Climactic Flourish
--- when conditions are met (TP >= 900, target HP > 25%, 3+ Finishing Moves)
DNCWSConfig.climactic_ws = {
    "Rudra's Storm",
    "Ruthless Stroke",
    "Shark Bite"
}

---============================================================================
--- CONDITIONS FOR AUTO-TRIGGER
---============================================================================

--- Minimum TP required to auto-trigger Climactic Flourish
--- Note: Lag causes GearSwap to see 800-950 TP when user launches at 1000 TP
DNCWSConfig.min_tp = 1000

--- Minimum target HP% to auto-trigger Climactic Flourish
--- Prevents wasting Climactic Flourish on nearly dead mobs
DNCWSConfig.min_target_hpp = 25

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if a weaponskill should auto-trigger Climactic Flourish
--- @param ws_name string The weaponskill name
--- @return boolean True if WS should auto-trigger Climactic
function DNCWSConfig.should_use_climactic(ws_name)
    if not ws_name then return false end

    for _, ws in ipairs(DNCWSConfig.climactic_ws) do
        if ws == ws_name then
            return true
        end
    end

    return false
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return DNCWSConfig

---============================================================================
--- DNC Weaponskill Configuration
---============================================================================
--- Defines which weaponskills should auto-trigger Climactic Flourish and other
--- WS-specific behaviors for Dancer job.
---
--- Features:
---   • Climactic Flourish automation for configured weaponskills
---   • Minimum TP threshold for auto-trigger (1000 TP, see min_tp)
---   • Minimum target HP% threshold (25% default - prevents waste on dying mobs)
---   • WS whitelist system (Rudra's Storm, Ruthless Stroke, Shark Bite)
---   • Helper function to check if WS should trigger Climactic
---
--- @file    config/dnc/DNC_WS_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

local DNCWSConfig = {}

---============================================================================
--- CLIMACTIC FLOURISH AUTOMATION
---============================================================================

--- List of weaponskills that should auto-trigger Climactic Flourish
--- when conditions are met (TP >= min_tp, target HP > 25%, 3+ Finishing Moves)
DNCWSConfig.climactic_ws = {
    "Rudra's Storm",
    "Ruthless Stroke",
    "Shark Bite"
}

---============================================================================
--- CONDITIONS FOR AUTO-TRIGGER
---============================================================================

--- Minimum TP required to auto-trigger Climactic Flourish. The TP is read
--- live from the game; below 1000 the weaponskill itself cannot go, so a
--- lower value counts as 1000. Raise it (e.g. 2000) to keep Climactic for
--- bigger weaponskills.
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

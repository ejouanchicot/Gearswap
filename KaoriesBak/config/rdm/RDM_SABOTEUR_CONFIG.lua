---============================================================================
--- RDM Saboteur Configuration - Auto-Trigger Spell List
---============================================================================
--- Defines which enfeebling spells should auto-trigger Saboteur before cast.
--- User can customize this list without modifying core code.
---
--- @file config/rdm/RDM_SABOTEUR_CONFIG.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-24
---============================================================================

local RDMSaboteurConfig = {}

---============================================================================
--- SABOTEUR AUTO-TRIGGER SPELL LIST
---============================================================================
--- Spells in this list will auto-trigger Saboteur when SaboteurMode = 'On'
---
--- Saboteur Effect: +5 enfeebling potency/duration (60s duration, 5min cooldown)
---
--- Default spells:
---   • Distract III - Red Magic tier III (very potent, Saboteur maximizes effect)
---   • Gravity II - High resist rate, needs Saboteur for reliability
---============================================================================

RDMSaboteurConfig.auto_trigger_spells = {
    ['Distract III'] = true,
    ['Gravity II'] = true,
}

---============================================================================
--- SABOTEUR TIMING CONFIGURATION
---============================================================================

-- Wait time between Saboteur activation and spell cast (seconds)
-- Default: 2s (same as PLD Majesty, DNC Climactic)
RDMSaboteurConfig.wait_time = 2

return RDMSaboteurConfig

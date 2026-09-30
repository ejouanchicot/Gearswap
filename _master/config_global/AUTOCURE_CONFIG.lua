---============================================================================
--- Auto Medicine - the items used on a blocking debuff
---============================================================================
--- When Silence or Paralysis blocks an action, Auto Medicine uses a cure
--- item first (the Auto Medicine key / //gs c am turns it on and off).
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default. An item is its name, tried
--- in this order.
---
--- @file _common/combat/AUTOCURE_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    -- Silence: cured before a spell
    auto_cure_silence = true,
    silence_cure_items = {'Echo Drops', 'Remedy'},

    -- Paralysis: cured before a job ability (a weaponskill goes through as is)
    auto_cure_paralysis = true,
    paralysis_cure_items = {'Remedy', 'Panacea'},

    -- Auto Medicine when the game starts: 'On' or 'Off' (after that, a job
    -- change keeps what you set)
    auto_medicine_start = 'On',
}

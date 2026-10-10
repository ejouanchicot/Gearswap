---============================================================================
--- Auto Medicine - the items used on a blocking debuff
---============================================================================
--- When Silence or Paralysis blocks an action, Auto Medicine uses a cure
--- item first (the Auto Medicine key / //gs c am turns it on and off).
--- Which items: CLEANSE_CONFIG.lua, same folder (`items`).
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default.
---
--- @file _common/combat/AUTO_MEDICINE_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    -- The items used are those of CLEANSE_CONFIG.lua (same folder), `items`
    -- silence and paralysis: one list for Auto Medicine and //gs c cleanse.

    -- Silence: cured before a spell
    auto_cure_silence = true,

    -- Paralysis: cured before a job ability (a weaponskill goes through as is)
    auto_cure_paralysis = true,

    -- No item left: ask the other box, if it may have the spell (Paralyna,
    -- Silena), to cast it on you. Your action does not wait for it
    ask_partner = true,

    -- Auto Medicine when the game starts: 'On' or 'Off' (after that, a job
    -- change keeps what you set)
    auto_medicine_start = 'On',
}

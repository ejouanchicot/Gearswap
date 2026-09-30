---============================================================================
--- Auto Medicine - the items used on a blocking debuff
---============================================================================
--- When Silence or Paralysis blocks an action, Auto Medicine uses a cure
--- item first (the Auto Medicine key / //gs c am turns it on and off).
--- Every line is a comment: the shared defaults apply (shown here). Uncomment
--- what you want to change; an item is its name, tried in this order.
---
--- @file _common/combat/AUTOCURE_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    -- Silence: cured before a spell
    -- auto_cure_silence = true,
    -- silence_cure_items = {'Echo Drops', 'Remedy'},

    -- Paralysis: cured before an ability or a weaponskill
    -- auto_cure_paralysis = true,
    -- paralysis_cure_items = {'Remedy', 'Panacea'},

    -- Auto Medicine when the game starts: 'On' or 'Off' (after that, a job
    -- change keeps what you set)
    -- auto_medicine_start = 'On',
}

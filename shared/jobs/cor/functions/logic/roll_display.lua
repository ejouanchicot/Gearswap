---  ═══════════════════════════════════════════════════════════════════════════
---   COR Roll Display - the roll result and Double-Up window messages
---  ═══════════════════════════════════════════════════════════════════════════
---   Turns what the roll tracker worked out into chat messages, on this box
---   and, for an alt, on the main (dualbox/roll_share.lua).
---
---   @file    shared/jobs/cor/functions/logic/roll_display.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local RollDisplay = {}

local RollData = require('shared/jobs/cor/functions/logic/roll_data')
local RollParty = require('shared/jobs/cor/functions/logic/roll_party')
local MessageFormatter = require('shared/utils/messages/message_formatter')

---   Display roll result with all details
---   @param roll_name string Name of the roll
---   @param roll_value number Value rolled
---   @param final_bonus number Final bonus value
---   @param effect_type string Type of effect
---   @param is_lucky boolean If lucky number
---   @param is_unlucky boolean If unlucky number
---   @param is_natural_eleven boolean If natural 11
---   @param bust_rate number Bust rate percentage
---   @param job_bonus_info string|nil Job code if job bonus active (e.g., "RNG")
---   @param is_crooked boolean If Crooked Cards buff active
---   @param missed_names table Array of player names who missed the roll
function RollDisplay.display_roll_result(roll_name, roll_value, final_bonus, effect_type, is_lucky, is_unlucky, is_natural_eleven, bust_rate, job_bonus_info, is_crooked, missed_names)
    -- Format roll value with Lucky/Unlucky status (ASCII only)
    local value_display = tostring(roll_value)
    if is_lucky then
        value_display = value_display .. ' LUCKY!'
    elseif is_unlucky then
        value_display = value_display .. ' (unlucky)'
    end

    -- Format bonus display with proper sign
    local bonus_display = string.format("%+g%s", final_bonus, effect_type)

    -- Party member count stored by on_roll_cast (recounted on every cast)
    local affected_count = _G.cor_last_roll.affected_count
    local total_count = _G.cor_last_roll.total_count

    -- Get lucky/unlucky numbers for Snake Eye decision
    local roll_data = RollData.get_roll(roll_name)
    local lucky_num = roll_data and roll_data.lucky or nil
    local unlucky_num = roll_data and roll_data.unlucky or nil

    local roll_range = RollParty.roll_range()

    -- Main roll message with bust rate integrated (Natural 11 message now integrated inside)
    MessageFormatter.show_roll_result(roll_name, value_display, bonus_display, is_crooked, affected_count, total_count, lucky_num, unlucky_num, missed_names, bust_rate, job_bonus_info, roll_range)
    -- Same message on the main when this box is an alt (dualbox/roll_share.lua)
    pcall(function() require('shared/utils/dualbox/roll_share').result(roll_name, value_display, bonus_display, is_crooked, affected_count, total_count, lucky_num, unlucky_num, missed_names, bust_rate, job_bonus_info, roll_range) end)
end

---   Display Double-Up window status
---   Called by //gs c doubleup (du)
function RollDisplay.display_double_up_status()
    if not _G.cor_last_roll.name or not _G.cor_last_roll.timestamp then
        MessageFormatter.show_no_active_roll()
        return
    end

    local elapsed = os.time() - _G.cor_last_roll.timestamp
    local remaining = 45 - elapsed

    if remaining > 0 then
        MessageFormatter.show_roll_double_up_window(remaining)
    else
        MessageFormatter.show_roll_double_up_expired()
    end
end

return RollDisplay

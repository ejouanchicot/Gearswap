---============================================================================
--- Roll Messages Module - Phantom Roll Message Formatting
---============================================================================
--- Provides formatted messages for Corsair Phantom Roll system:
--- - Roll results with value and bonus
--- - Natural 11 special messages
--- - Bust warnings and effects
--- - Bust rate calculations
--- - Double-Up window status
---
--- @file utils/messages/roll_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-08
---============================================================================

local RollMessages = {}

-- Load message core for formatting
local MessageCore = require('shared/utils/messages/message_core')

-- Windower chars for special characters (circled numbers ①②③④⑤⑥⑦⑧⑨⑩⑪)
-- Embedded directly to avoid path issues with require('chat.chars')
local chars = {
    circle1 =     string.char(0x87, 0x40),
    circle2 =     string.char(0x87, 0x41),
    circle3 =     string.char(0x87, 0x42),
    circle4 =     string.char(0x87, 0x43),
    circle5 =     string.char(0x87, 0x44),
    circle6 =     string.char(0x87, 0x45),
    circle7 =     string.char(0x87, 0x46),
    circle8 =     string.char(0x87, 0x47),
    circle9 =     string.char(0x87, 0x48),
    circle10 =    string.char(0x87, 0x49),
    circle11 =    string.char(0x87, 0x4A),
    implies =     string.char(0x81, 0xC3),
    hline =       string.char(0x84, 0x92),
}

---============================================================================
--- ROLL RESULT MESSAGES
---============================================================================

--- Display roll result with value and bonus (new multi-line format)
--- @param roll_name string Name of the roll (e.g., "Fighter's Roll")
--- @param value_display string Formatted value (e.g., "7" or "11 LUCKY!")
--- @param bonus_display string Formatted bonus (e.g., "+5% Double-Attack")
--- @param is_crooked boolean If Crooked Cards buff active
--- @param affected_count number Number of party members with the buff
--- @param total_count number Total party members
--- @param lucky_num number Lucky number for this roll
--- @param unlucky_num number|table Unlucky number(s) for this roll
--- @param missed_names table|nil Array of player names who missed the roll
--- @param bust_rate number Bust rate percentage for next Double-Up
--- @param job_bonus_info string|nil Job code if job bonus active (e.g., "DNC")
--- @param roll_range number|nil Roll range in yalms (8 without Luzaf, 16 with Luzaf)
function RollMessages.show_roll_result(roll_name, value_display, bonus_display, is_crooked, affected_count, total_count, lucky_num, unlucky_num, missed_names, bust_rate, job_bonus_info, roll_range)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)      -- Cyan
    local roll_color = MessageCore.create_color_code(MessageCore.COLORS.JA)         -- Yellow
    local white_color = MessageCore.create_color_code(001)                          -- White
    local bonus_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)   -- Green
    local separator_color = MessageCore.create_color_code(MessageCore.COLORS.SEPARATOR) -- Gray

    -- Extract just the number from value_display (e.g., "11 LUCKY!" -> 11)
    local roll_value = tonumber(value_display:match("%d+"))

    -- Get circled number character (①②③④⑤⑥⑦⑧⑨⑩⑪)
    local circled_num = roll_value and chars['circle' .. roll_value] or tostring(roll_value or "?")

    -- Check if LUCKY or unlucky
    local is_lucky = value_display:match("LUCKY")
    local is_unlucky = value_display:match("unlucky")
    local luck_text = ""
    local luck_color = white_color
    local number_color = white_color  -- Color for the circled number

    if is_lucky or roll_value == 11 then
        luck_text = is_lucky and " (LUCKY!)" or ""
        luck_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)  -- Green
        number_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)  -- Green circled number
    elseif is_unlucky then
        luck_text = " (unlucky)"
        luck_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)  -- Red
        number_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)  -- Red circled number
    end

    -- Crooked Cards indicator
    local crooked_text = ""
    if is_crooked then
        local crooked_color = MessageCore.create_color_code(207)  -- Magenta/Pink for visibility
        crooked_text = crooked_color .. " [CROOKED +20%]" .. white_color
    end

    -- Helper function to calculate visual length (excluding color codes)
    local function get_visual_length(text)
        -- Count only visible characters, not color codes or special chars
        local count = 0
        local i = 1
        while i <= #text do
            local byte = text:byte(i)
            -- Skip Windower color codes
            if byte == 0x1E then
                i = i + 4  -- \x1E + 3 bytes
            elseif byte == 0x1F then
                i = i + 2  -- \x1F + 1 byte
            -- Skip multi-byte UTF-8 sequences (circled numbers, etc.)
            elseif byte == 0x87 or byte == 0x81 or byte == 0x84 then
                i = i + 2  -- 2-byte sequence
                count = count + 1
            else
                i = i + 1
                count = count + 1
            end
        end
        return count
    end

    -- Build all lines first to calculate max length
    local lines = {}

    -- Line 1: Roll with effect (compact format)
    -- Format: [COR/DNC] Dancer's Roll 11 / +33.6 Regen / [+DNC] [Crooked +20%]
    local separator_slash = white_color .. " / "

    -- Job bonus part (separate from bonus_display)
    local job_bonus_text = ""
    if job_bonus_info then
        job_bonus_text = separator_slash .. bonus_color .. "[+" .. job_bonus_info .. "]"
    end

    local line1 = job_color .. "[" .. job_tag .. "]" .. white_color .. " " ..
                  roll_color .. roll_name .. " " ..
                  number_color .. circled_num ..
                  separator_slash ..
                  bonus_color .. bonus_display ..
                  job_bonus_text ..
                  crooked_text

    table.insert(lines, line1)

    -- Line 2: Lucky/Unlucky on same line
    local lucky_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)  -- Green
    local unlucky_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)  -- Red

    local lucky_part = ""
    local unlucky_part = ""

    if lucky_num then
        lucky_part = white_color .. "[Lucky: " .. lucky_color .. lucky_num .. white_color .. "]"
    end

    if unlucky_num then
        if type(unlucky_num) == "table" then
            local unlucky_str = table.concat(unlucky_num, ", ")
            unlucky_part = white_color .. "[Unlucky: " .. unlucky_color .. unlucky_str .. white_color .. "]"
        else
            unlucky_part = white_color .. "[Unlucky: " .. unlucky_color .. unlucky_num .. white_color .. "]"
        end
    end

    if lucky_part ~= "" or unlucky_part ~= "" then
        local separator_lucky = (lucky_part ~= "" and unlucky_part ~= "") and (white_color .. " / ") or ""
        local line2 = white_color .. "  - " .. lucky_part .. separator_lucky .. unlucky_part
        table.insert(lines, line2)
    end

    -- Line 3: Affected
    if affected_count and total_count and total_count > 0 then
        local coverage_color = white_color
        if affected_count == total_count then
            coverage_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)  -- Green (all members)
        elseif affected_count >= total_count * 0.75 then
            coverage_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)  -- Cyan (most members)
        elseif affected_count < total_count * 0.5 then
            coverage_color = MessageCore.create_color_code(MessageCore.COLORS.get_warning_color())  -- Orange/Rose (less than half)
        end

        local line3 = white_color .. "  - Affected: " .. coverage_color .. affected_count .. "/" .. total_count .. white_color .. " party members"
        table.insert(lines, line3)

        -- Line 4: Missed (NO dash, just indentation)
        if missed_names and #missed_names > 0 then
            local missed_name_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)     -- Red names
            local gray_color = MessageCore.create_color_code(MessageCore.COLORS.SEPARATOR)        -- Gray explanation

            -- Use roll_range parameter or default to 16y (with Luzaf)
            local range_text = roll_range and string.format("%dy", roll_range) or "16y"
            local missed_line = white_color .. "  Missed " .. gray_color .. "(out of range >" .. range_text .. ")" .. white_color .. ": "

            for i, name in ipairs(missed_names) do
                missed_line = missed_line .. missed_name_color .. name
                if i < #missed_names then
                    missed_line = missed_line .. white_color .. ", "
                end
            end

            table.insert(lines, missed_line)
        end
    end

    -- Line 5: Bust rate (with dash)
    if bust_rate then
        -- Color code AND risk text based on level
        local risk_color, risk_text
        if bust_rate >= 100 then
            risk_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
            risk_text = "GUARANTEED BUST"
        elseif bust_rate >= 83.3 then
            risk_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
            risk_text = "EXTREME DANGER"
        elseif bust_rate >= 66.6 then
            risk_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
            risk_text = "HIGH RISK"
        elseif bust_rate >= 50 then
            risk_color = MessageCore.create_color_code(MessageCore.COLORS.get_warning_color())
            risk_text = "MODERATE RISK"
        elseif bust_rate >= 33.3 then
            risk_color = MessageCore.create_color_code(MessageCore.COLORS.get_warning_color())
            risk_text = "LOW RISK"
        elseif bust_rate >= 16.6 then
            risk_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)
            risk_text = "VERY LOW RISK"
        elseif bust_rate > 0 then
            risk_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
            risk_text = "SAFE"
        else
            risk_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
            risk_text = "NO RISK"
        end

        local bust_line = white_color .. "  - Bust: " .. risk_color .. string.format("%.1f%%", bust_rate) .. " " .. white_color .. "(" .. risk_text .. ")"
        table.insert(lines, bust_line)
    end

    -- Line 6: Natural 11 special benefits (if roll value is 11)
    if roll_value == 11 then
        local success_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
        local natural11_line = white_color .. "  " .. success_color .. "11!" .. white_color .. " Reset / 30s Recast / Bust Immunity"
        table.insert(lines, natural11_line)
    end

    -- Calculate max visual length
    local max_length = 0
    for _, line in ipairs(lines) do
        local len = get_visual_length(line)
        if len > max_length then
            max_length = len
        end
    end

    -- Adjust for console display (separator seems 2-3 chars too long)
    max_length = max_length - 3

    -- Ensure minimum separator length
    if max_length < 60 then
        max_length = 60
    end

    -- Create dynamic separator
    local separator = string.rep("=", max_length)

    -- Display opening separator
    add_to_chat(001, separator_color .. separator)

    -- Display all lines
    for _, line in ipairs(lines) do
        add_to_chat(001, line)
    end

    -- Display closing separator
    add_to_chat(001, separator_color .. separator)
end

--- Display Natural 11 special benefits (simple one-line format)
--- Shows instant recast reset, 30s recast, and bust debuff immunity
--- NOTE: Immunity = NO BUST DEBUFF if you bust (you can still bust but no penalty)
--- Benefits only apply if NO Bust debuff is currently active
--- Benefits persist as long as ANY 11 roll remains active
function RollMessages.show_roll_natural_eleven()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)     -- Cyan tag
    local success_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS) -- Green
    local white_color = MessageCore.create_color_code(001)                          -- White

    -- Simple one-line message: [COR/DNC] 11! Reset / 30s Recast / Bust Immunity
    local message = string.format(
        "%s[%s]%s %s11!%s Reset / 30s Recast / Bust Immunity",
        job_color, job_tag,
        white_color,
        success_color,
        white_color
    )

    add_to_chat(001, message)
end

--- Display bust rate warning (integrated in multi-line format)
--- @param bust_rate number Bust rate percentage
function RollMessages.show_roll_bust_rate(bust_rate)
    local white_color = MessageCore.create_color_code(001)
    local separator_color = MessageCore.create_color_code(MessageCore.COLORS.SEPARATOR) -- Gray

    -- Color code AND risk text based on level (adjusted for realistic danger)
    local risk_color, risk_text
    if bust_rate >= 100 then
        -- 100% = 6/6 bust (impossible to not bust)
        risk_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
        risk_text = "GUARANTEED BUST"
    elseif bust_rate >= 83.3 then
        -- 83.3% = 5/6 bust (only 1 safe number)
        risk_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
        risk_text = "EXTREME DANGER"
    elseif bust_rate >= 66.6 then
        -- 66.7% = 4/6 bust (only 2 safe numbers)
        risk_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
        risk_text = "HIGH RISK"
    elseif bust_rate >= 50 then
        -- 50% = 3/6 bust (half safe, half bust)
        risk_color = MessageCore.create_color_code(MessageCore.COLORS.get_warning_color())
        risk_text = "MODERATE RISK"
    elseif bust_rate >= 33.3 then
        -- 33.3% = 2/6 bust (4 safe numbers)
        risk_color = MessageCore.create_color_code(MessageCore.COLORS.get_warning_color())
        risk_text = "LOW RISK"
    elseif bust_rate >= 16.6 then
        -- 16.7% = 1/6 bust (5 safe numbers)
        risk_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)
        risk_text = "VERY LOW RISK"
    elseif bust_rate > 0 then
        risk_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
        risk_text = "SAFE"
    else
        -- 0% = 0/6 bust (no risk)
        risk_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
        risk_text = "NO RISK"
    end

    -- Display bust line
    add_to_chat(001, string.format(
        "%sBust: %s%.1f%% %s(%s)",
        white_color,
        risk_color, bust_rate,
        white_color, risk_text
    ))

    -- Final separator (gray, matching opening separator)
    local separator = string.rep("=", 48)
    add_to_chat(001, separator_color .. separator)
end

---============================================================================
--- BUST MESSAGES
---============================================================================

--- Display bust message with effect (simple one-line format)
--- @param roll_name string Name of the roll that busted
--- @param bust_effect string Bust effect value (e.g., "-4")
--- @param effect_type string Type of effect (e.g., "% Double-Attack")
function RollMessages.show_roll_bust(roll_name, bust_effect, effect_type)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)   -- Cyan tag
    local error_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)   -- Red BUST
    local roll_color = MessageCore.create_color_code(MessageCore.COLORS.JA)       -- Yellow roll name
    local white_color = MessageCore.create_color_code(001)                        -- White text

    -- Use WARNING color (region-specific: US=057 orange, EU=002 rose)
    -- Get warning color dynamically (config/REGION_CONFIG.lua or manual override)
    local warning_code = MessageCore.COLORS.get_warning_color()
    local warning_color = MessageCore.create_color_code(warning_code)

    -- Simple one-line message: [COR/DNC] BUST! Fighter's Roll / Penalty: -4 Regen
    -- Build message piece by piece with explicit color codes
    local message = job_color .. "[" .. job_tag .. "]" ..
                    white_color .. " " ..
                    error_color .. "BUST!" ..
                    white_color .. " " ..
                    roll_color .. roll_name ..
                    white_color .. " / " ..
                    warning_color .. "Penalty: " .. bust_effect .. effect_type

    add_to_chat(121, message)  -- Use channel 121 instead of 001 to preserve inline colors
end

---============================================================================
--- DOUBLE-UP MESSAGES
---============================================================================

--- Display Double-Up window remaining time
--- @param remaining_seconds number Seconds remaining in 45s window
function RollMessages.show_roll_double_up_window(remaining_seconds)
    local message = string.format(
        "Double-Up window: %ds remaining",
        remaining_seconds
    )
    MessageCore.info(message)
end

--- Display Double-Up window expired message
function RollMessages.show_roll_double_up_expired()
    MessageCore.warning("Double-Up window expired (>45s)")
end

--- Display no active roll for Double-Up message
function RollMessages.show_no_active_roll()
    MessageCore.warning("No active roll to Double-Up")
end

---============================================================================
--- ROLL STATE MESSAGES
---============================================================================

--- Display active rolls summary
--- @param active_rolls table Array of active roll data
function RollMessages.show_active_rolls(active_rolls)
    if not active_rolls or #active_rolls == 0 then
        MessageCore.info("No active rolls")
        return
    end

    local job_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)
    local header_color = MessageCore.create_color_code(MessageCore.COLORS.JA)
    local white_color = MessageCore.create_color_code(001)
    local number_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
    local gray_color = MessageCore.create_color_code(MessageCore.COLORS.SEPARATOR)

    -- Header
    local job_tag = MessageCore.get_job_tag()
    add_to_chat(001, string.format("%s[%s]%s Active Rolls (%s%d%s):",
        job_color, job_tag,
        white_color,
        number_color, #active_rolls, white_color))

    -- List each roll
    for i, roll in ipairs(active_rolls) do
        local formatted_message = string.format(
            "  %s[%d]%s %s%s%s = %s%d",
            gray_color, i,
            white_color,
            header_color, roll.name,
            white_color,
            number_color, roll.value
        )
        add_to_chat(001, formatted_message)
    end
end

--- Display roll state cleared message
function RollMessages.show_rolls_cleared()
    MessageCore.info("All roll tracking cleared")
end

---============================================================================
--- ERROR MESSAGES
---============================================================================

--- Display roll not found error
--- @param roll_name string Name of the roll
function RollMessages.show_roll_not_found(roll_name)
    local message = string.format(
        "Unknown roll: %s",
        roll_name
    )
    MessageCore.error(message)
end

--- Display invalid roll value error
--- @param roll_value number Invalid roll value
function RollMessages.show_invalid_roll_value(roll_value)
    local message = string.format(
        "Invalid roll value: %d (must be 1-12)",
        roll_value
    )
    MessageCore.error(message)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return RollMessages

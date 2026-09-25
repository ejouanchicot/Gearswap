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
--- @file shared/utils/messages/utilities/roll_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-08
---============================================================================

local RollMessages = {}

local MessageCore = require('shared/utils/messages/message_core')
local ChatPalette = require('shared/utils/messages/chat_palette')

--- "[COR/DNC]" in the job color then `after` (white + " "), or only the
--- white color when the player turned the job tag off.
--- @param job_color string
--- @param white_color string
--- @return string
local function tag_prefix(job_color, white_color)
    if MessageCore.job_prefix() == "" then return white_color end
    return job_color .. "[" .. MessageCore.get_job_tag() .. "]" .. white_color .. " "
end

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

--- Visible width of a line, ignoring what the console does not draw.
---
--- Windower colour codes and the circled digits are bytes in the string that
--- occupy no column, so counting #text would size the separator far too wide.
--- @param text string Line with colour codes embedded
--- @return number Number of characters actually drawn
local function get_visual_length(text)
    local count = 0
    local i = 1
    while i <= #text do
        local byte = text:byte(i)
        if byte == 0x1E then
            i = i + 4  -- \x1E + 3 bytes
        elseif byte == 0x1F then
            i = i + 2  -- \x1F + 1 byte
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

--- Bust risk bands, highest first. The first band the rate reaches wins, so
--- the order here is the rule - it is not a list that can be sorted.
local BUST_BANDS = {
    { at = 100,  color = 'ERROR',   text = 'GUARANTEED BUST' },
    { at = 83.3, color = 'ERROR',   text = 'EXTREME DANGER' },
    { at = 66.6, color = 'ERROR',   text = 'HIGH RISK' },
    { at = 50,   color = 'WARNING', text = 'MODERATE RISK' },
    { at = 33.3, color = 'WARNING', text = 'LOW RISK' },
    { at = 16.6, color = 'JOB_TAG', text = 'VERY LOW RISK' },
    -- `above` and not `at`: any bust chance at all is SAFE rather than NO RISK,
    -- however small. A threshold of 0.01 would have relabelled a 0.005% roll.
    { at = 0,    color = 'SUCCESS', text = 'SAFE', above = true },
    -- -inf, so the table is total: the original's `else` caught every
    -- remaining value including a negative rate, and a band list that
    -- stopped at zero would have returned nothing at all.
    { at = -math.huge, color = 'SUCCESS', text = 'NO RISK' },
}

--- Colour and wording for a bust percentage.
--- @param bust_rate number Percentage chance the next Double-Up busts
--- @return string colour code, string risk wording
local function bust_risk_style(bust_rate)
    for _, band in ipairs(BUST_BANDS) do
        local hit = band.above and bust_rate > band.at or
                    (not band.above and bust_rate >= band.at)
        if hit then
            local color = band.color == 'WARNING'
                          and MessageCore.COLORS.get_warning_color()
                          or MessageCore.COLORS[band.color]
            return MessageCore.create_color_code(color), band.text
        end
    end
    return MessageCore.create_color_code(MessageCore.COLORS.SUCCESS), 'NO RISK'
end

--- The Lucky / Unlucky line, or nothing when the roll has neither.
--- @param white string White colour code, reused as the separator colour
--- @param lucky_num number|nil The lucky number for this roll
--- @param unlucky_num number|table|nil The unlucky number, or several
--- @return string|nil The line
local function build_luck_line(white, lucky_num, unlucky_num)
    local lucky_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
    local unlucky_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)

    local lucky_part, unlucky_part = "", ""

    if lucky_num then
        lucky_part = white .. "[Lucky: " .. lucky_color .. lucky_num .. white .. "]"
    end

    if unlucky_num then
        local text = (type(unlucky_num) == "table")
                     and table.concat(unlucky_num, ", ") or unlucky_num
        unlucky_part = white .. "[Unlucky: " .. unlucky_color .. text .. white .. "]"
    end

    if lucky_part == "" and unlucky_part == "" then
        return nil
    end

    local separator = (lucky_part ~= "" and unlucky_part ~= "") and (white .. " / ") or ""
    return white .. "  - " .. lucky_part .. separator .. unlucky_part
end

--- How much of the party the roll reached, and who it missed.
---
--- The colour is the warning: green for everyone, cyan for most, orange once
--- fewer than half are covered, which is the point at which the roll is
--- worth doing again from somewhere else.
--- @return table Zero, one or two lines
local function build_coverage_lines(white, affected_count, total_count, missed_names, roll_range)
    if not (affected_count and total_count and total_count > 0) then
        return {}
    end

    local coverage_color = white
    if affected_count == total_count then
        coverage_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
    elseif affected_count >= total_count * 0.75 then
        coverage_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)
    elseif affected_count < total_count * 0.5 then
        coverage_color = MessageCore.create_color_code(MessageCore.COLORS.get_warning_color())
    end

    local lines = {
        white .. "  - Affected: " .. coverage_color .. affected_count .. "/" ..
        total_count .. white .. " party members"
    }

    if missed_names and #missed_names > 0 then
        local name_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
        local gray = MessageCore.create_color_code(MessageCore.COLORS.SEPARATOR)
        -- 16y is the range with Luzaf's Ring, which is the usual case.
        local range_text = roll_range and string.format("%dy", roll_range) or "16y"

        local missed = white .. "  Missed " .. gray .. "(out of range >" ..
                       range_text .. ")" .. white .. ": "
        for i, name in ipairs(missed_names) do
            missed = missed .. name_color .. name
            if i < #missed_names then
                missed = missed .. white .. ", "
            end
        end
        table.insert(lines, missed)
    end

    return lines
end

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
    local job_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)
    local roll_color = MessageCore.create_color_code(MessageCore.COLORS.JA)
    local white_color = ChatPalette.tag('white')
    local bonus_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
    local separator_color = MessageCore.create_color_code(MessageCore.COLORS.SEPARATOR)

    -- Extract just the number from value_display (e.g., "11 LUCKY!" >> 11)
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
        local crooked_color = ChatPalette.tag('lightblue')  -- Magenta/Pink for visibility
        crooked_text = crooked_color .. " [CROOKED +20%]" .. white_color
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

    local line1 = tag_prefix(job_color, white_color) ..
                roll_color .. roll_name .. " " ..
                number_color .. circled_num ..
                separator_slash ..
                bonus_color .. bonus_display ..
                job_bonus_text ..
                crooked_text

    table.insert(lines, line1)

    local luck_line = build_luck_line(white_color, lucky_num, unlucky_num)
    if luck_line then
        table.insert(lines, luck_line)
    end

    for _, line in ipairs(build_coverage_lines(white_color, affected_count,
                                               total_count, missed_names, roll_range)) do
        table.insert(lines, line)
    end

    -- Bust rate line
    if bust_rate then
        local risk_color, risk_text = bust_risk_style(bust_rate)
        local bust_line = white_color .. "  - Bust: " .. risk_color .. string.format("%.1f%%", bust_rate) .. " " .. white_color .. "(" .. risk_text .. ")"
        table.insert(lines, bust_line)
    end

    -- Natural 11 line
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
    max_length = math.min(max_length, MessageCore.SEPARATOR_WIDTH)

    -- Create dynamic separator
    local separator = string.rep("=", max_length)

    -- Display opening separator
    MessageCore.raw(separator_color .. separator)

    -- Display all lines
    for _, line in ipairs(lines) do
        MessageCore.raw(line)
    end

    -- Display closing separator
    MessageCore.raw(separator_color .. separator)
end

--- Display Natural 11 special benefits (simple one-line format). No caller:
--- show_roll_result prints the same line itself.
--- Shows instant recast reset, 30s recast, and bust debuff immunity
--- NOTE: Immunity = NO BUST DEBUFF if you bust (you can still bust but no penalty)
--- Benefits only apply if NO Bust debuff is currently active
--- Benefits persist as long as ANY 11 roll remains active
function RollMessages.show_roll_natural_eleven()
    local job_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)
    local success_color = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS)
    local white_color = ChatPalette.tag('white')

    -- Simple one-line message: [COR/DNC] 11! Reset / 30s Recast / Bust Immunity
    local message = string.format(
        "%s%s11!%s Reset / 30s Recast / Bust Immunity",
        tag_prefix(job_color, white_color),
        success_color,
        white_color
    )

    MessageCore.raw(message)
end

---============================================================================
--- BUST MESSAGES
---============================================================================

--- Display bust message with effect (simple one-line format)
--- @param roll_name string Name of the roll that busted
--- @param bust_effect string Bust effect value (e.g., "-4")
--- @param effect_type string Type of effect (e.g., "% Double-Attack")
function RollMessages.show_roll_bust(roll_name, bust_effect, effect_type)
    local job_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
    local roll_color = MessageCore.create_color_code(MessageCore.COLORS.JA)
    local white_color = ChatPalette.tag('white')

    -- Region-specific orange, read at call time (see message_colors.lua)
    local warning_code = MessageCore.COLORS.get_warning_color()
    local warning_color = MessageCore.create_color_code(warning_code)

    -- Simple one-line message: [COR/DNC] BUST! Fighter's Roll / Penalty: -4 Regen
    -- Build message piece by piece with explicit color codes
    local message = tag_prefix(job_color, white_color) ..
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
    local fields = {}
    for _, roll in ipairs(active_rolls) do
        -- nil after a reload when the value was not seen (see sync_with_buffs)
        if roll.value then
            fields[#fields + 1] = {roll.name, roll.value, 'good'}
        else
            fields[#fields + 1] = {roll.name, '? (cast before the reload)', 'dim'}
        end
    end
    require('shared/utils/messages/info_block').show({
        tag = 'COR', title = ('Active rolls (%d)'):format(#active_rolls), fields = fields,
    })
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

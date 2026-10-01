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
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2025-10-08
---============================================================================

local RollMessages = {}

local MessageCore = require('shared/utils/messages/message_core')
local ChatPalette = require('shared/utils/messages/chat_palette')

--- "[COR/DNC]" in the job color then `after` (white + " "), or only the
--- white color when the player turned the job tag off. A roll shown for
--- another box (roll_share.lua) always carries its caster: "[Kaories COR]".
--- @param job_color string
--- @param white_color string
--- @param source string|nil Caster of a roll made on another box
--- @return string
local function tag_prefix(job_color, white_color, source)
    if source and source ~= "" then return job_color .. "[" .. source .. "]" .. white_color .. " " end
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

--- The last color code in `text` (0x1F + 1 byte, 0x1E + 3 bytes), or nil.
local function last_color_code(text)
    local code, i = nil, 1
    while i <= #text do
        local byte = text:byte(i)
        if byte == 0x1F then
            code = text:sub(i, i + 1)
            i = i + 2
        elseif byte == 0x1E then
            code = text:sub(i, i + 3)
            i = i + 4
        else
            i = i + 1
        end
    end
    return code
end

local WRAP_INDENT = "    "

--- A line cut at spaces to `width`; a continuation line is indented and
--- starts with the color in force where the cut was made.
--- @param line string
--- @param width number
--- @return table Lines
local function wrap_words(line, width)
    if get_visual_length(line) <= width then return {line} end
    local out, current, done = {}, nil, ""
    for word in (line .. " "):gmatch("(.-) ") do
        if current == nil then
            current = word
        elseif word ~= "" and get_visual_length(current .. " " .. word) > width
                and get_visual_length((current:gsub("^%s+", ""))) > 0 then
            out[#out + 1] = current
            done = done .. current
            current = WRAP_INDENT .. (last_color_code(done) or "") .. word
        else
            current = current .. " " .. word
        end
    end
    out[#out + 1] = current
    return out
end

--- A roll line fitted to the chat width in use (UI_CONFIG chat.width,
--- //gs c ui chatwidth). The cuts fall between the details (" / ", which
--- the line break replaces), each detail staying whole; only a detail wider
--- than the chat is cut at spaces.
--- @param line string
--- @return table Lines
local function fit(line)
    local width = MessageCore.SEPARATOR_WIDTH
    if get_visual_length(line) <= width then return {line} end
    local parts, start = {}, 1
    while true do
        local a, b = line:find(" / ", start, true)
        if not a then parts[#parts + 1] = line:sub(start) break end
        parts[#parts + 1] = line:sub(start, a - 1)
        start = b + 1
    end
    local lines, current, done = {}, parts[1], ""
    for k = 2, #parts do
        if get_visual_length(current .. " / " .. parts[k]) > width then
            lines[#lines + 1] = current
            done = done .. current
            current = WRAP_INDENT .. (last_color_code(done) or "") .. parts[k]
        else
            current = current .. " / " .. parts[k]
        end
    end
    lines[#lines + 1] = current
    local out = {}
    for _, l in ipairs(lines) do
        for _, piece in ipairs(wrap_words(l, width)) do out[#out + 1] = piece end
    end
    return out
end

--- Send lines to the chat, each fitted to the chat width.
local function print_fitted(lines)
    for _, line in ipairs(lines) do
        for _, part in ipairs(fit(line)) do MessageCore.raw(part) end
    end
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

--- The Lucky / Unlucky line, or nothing when the roll has neither: plain
--- words, only the numbers in color.
--- @param white string White colour code
--- @param lucky_num number|nil The lucky number for this roll
--- @param unlucky_num number|table|nil The unlucky number, or several
--- @return string|nil The line
local function build_luck_line(white, lucky_num, unlucky_num)
    if not (lucky_num or unlucky_num) then return nil end
    local parts = {}
    if lucky_num then
        parts[#parts + 1] = white .. "Lucky " .. MessageCore.create_color_code(MessageCore.COLORS.SUCCESS) .. lucky_num
    end
    if unlucky_num then
        local text = (type(unlucky_num) == "table") and table.concat(unlucky_num, ", ") or unlucky_num
        parts[#parts + 1] = white .. "Unlucky " .. MessageCore.create_color_code(MessageCore.COLORS.ERROR) .. text
    end
    return white .. "  - " .. table.concat(parts, white .. " / ")
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

--- The player's roll display options (UI_CONFIG.lua `rolls`, //gs c ui roll*).
--- @param source string|nil Caster when the roll comes from another box
--- @return string|nil style 'full' / 'compact' / 'line', nil = not shown
--- @return table options {lucky, party, bust, eleven}
local function roll_view(source)
    local ok, UIStyle = pcall(require, 'shared/utils/ui/ui_style')
    local rolls = ok and UIStyle.get().rolls or {}
    local style = rolls.style or 'full'
    if source and source ~= "" and rolls.remote_style and rolls.remote_style ~= 'same' then
        style = rolls.remote_style
    end
    if style == 'off' then return nil, rolls end
    return style, rolls
end

--- Everything the three styles draw from, computed once.
local function roll_context(roll_name, value_display, bonus_display, is_crooked, source)
    local c = {
        white = ChatPalette.tag('white'),
        green = MessageCore.create_color_code(MessageCore.COLORS.SUCCESS),
        red = MessageCore.create_color_code(MessageCore.COLORS.ERROR),
        roll_color = MessageCore.create_color_code(MessageCore.COLORS.JA),
        roll_name = roll_name, bonus = bonus_display, crooked = is_crooked,
    }
    c.tag = tag_prefix(MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG), c.white, source)
    c.value = tonumber(value_display:match("%d+"))
    c.circled = c.value and chars['circle' .. c.value] or tostring(c.value or "?")
    c.lucky = value_display:match("LUCKY") ~= nil
    c.unlucky = value_display:match("unlucky") ~= nil
    c.number_color = (c.lucky or c.value == 11) and c.green or (c.unlucky and c.red or c.white)
    return c
end

--- Line 1 of the full style: roll, number, bonus, job bonus, Crooked.
local function full_head(c, job_bonus_info)
    local slash = c.white .. " / "
    local line = c.tag .. c.roll_color .. c.roll_name .. " " .. c.number_color .. c.circled ..
                 slash .. c.green .. c.bonus
    if job_bonus_info then line = line .. slash .. c.green .. "[+" .. job_bonus_info .. "]" end
    if c.crooked then line = line .. ChatPalette.tag('lightblue') .. " [CROOKED +20%]" .. c.white end
    return line
end

local DEFAULT_ORDER = {'party', 'lucky', 'eleven', 'bust'}

--- The details in the player's order (UI_CONFIG rolls.order, //gs c ui
--- rollorder), each turned on or off by its own switch.
--- @param opts table Resolved rolls options
--- @return table Detail names to show, in order
local function detail_order(opts)
    local shown = {}
    for _, name in ipairs(opts.order or DEFAULT_ORDER) do
        if opts[name] ~= false then shown[#shown + 1] = name end
    end
    return shown
end

--- The full style's lines: the roll, then each detail's lines in order.
local function full_lines(c, r, opts)
    local risk_color = r.bust_rate and bust_risk_style(r.bust_rate)
    local builders = {
        lucky = function() return {build_luck_line(c.white, r.lucky, r.unlucky)} end,
        party = function() return build_coverage_lines(c.white, r.affected, r.total, r.missed, r.range) end,
        eleven = function()
            return {c.value == 11 and (c.white .. "  " .. c.green .. "11!" .. c.white ..
                " Reset / 30s Recast / Bust Immunity") or nil}
        end,
        -- The rate's color says the risk (green safe ... red high)
        bust = function()
            return {r.bust_rate and (c.white .. "  - Bust: " .. risk_color .. string.format("%.1f%%", r.bust_rate)) or nil}
        end,
    }
    local lines = {full_head(c, r.job_bonus)}
    for _, name in ipairs(detail_order(opts)) do
        for _, line in ipairs(builders[name]()) do lines[#lines + 1] = line end
    end
    return lines
end

--- "PT 3/4" (party members hit / party size), with the missed players
--- when asked; nil when turned off.
local function party_part(c, r, opts, with_names)
    if opts.party == false or not (r.affected and r.total and r.total > 0) then return nil end
    local color = r.affected == r.total and c.green or c.white
    local text = "PT " .. color .. r.affected .. "/" .. r.total .. c.white
    if with_names and r.missed and #r.missed > 0 then
        text = text .. " (missed: " .. c.red .. table.concat(r.missed, ", ") .. c.white .. ")"
    end
    return text
end

--- "Bust 12.5%", the rate in its risk color; nil when turned off or unknown.
local function bust_part(c, r, opts)
    if opts.bust == false or not r.bust_rate then return nil end
    local risk_color = bust_risk_style(r.bust_rate)
    return "Bust " .. risk_color .. string.format("%.1f%%", r.bust_rate) .. c.white
end

--- "L4 U8": white letters, the numbers in green / red; nil when turned off
--- or the roll has neither.
local function luck_part(c, r, opts)
    if opts.lucky == false or not (r.lucky or r.unlucky) then return nil end
    local unlucky = type(r.unlucky) == "table" and table.concat(r.unlucky, ",") or r.unlucky
    local text = r.lucky and (c.white .. "L" .. c.green .. r.lucky) or ""
    if unlucky then text = text .. (text ~= "" and " " or "") .. c.white .. "U" .. c.red .. unlucky end
    return text .. c.white
end

--- The compact (`compact` true) or one-line details, in the player's
--- order, joined with " / ". The one-line style never shows the bust risk.
local function short_details(c, r, opts, compact)
    local parts = {}
    for _, name in ipairs(detail_order(opts)) do
        local text
        if name == 'party' then text = party_part(c, r, opts, compact)
        elseif name == 'lucky' then text = luck_part(c, r, opts)
        elseif name == 'eleven' and c.value == 11 then
            text = c.green .. (compact and "11! bust immune" or "11!") .. c.white
        elseif name == 'bust' and compact then text = bust_part(c, r, opts)
        end
        if text then parts[#parts + 1] = text end
    end
    return table.concat(parts, " / ")
end

--- The compact style: roll and bonus, then one line of details, the bust
--- risk last.
local function compact_lines(c, r, opts)
    -- Lucky / unlucky show in the number's color only (green / red)
    local head = c.tag .. c.roll_color .. c.roll_name .. " " .. c.number_color .. c.circled ..
                 c.white .. " / " .. c.green .. c.bonus
    if r.job_bonus then head = head .. " [+" .. r.job_bonus .. "]" end
    if c.crooked then head = head .. ChatPalette.tag('lightblue') .. " [CC]" end
    local details = short_details(c, r, opts, true)
    local lines = {head}
    if details ~= "" then lines[2] = c.white .. "  " .. details end
    return lines
end

--- The one-line style: roll, bonus, then the details in the player's
--- order. No bust risk: the line stays short enough to read at a glance.
local function one_line(c, r, opts)
    local line = c.tag .. c.roll_color .. c.roll_name .. " " .. c.number_color .. c.circled ..
                 " " .. c.green .. c.bonus .. c.white
    if c.crooked then line = line .. ChatPalette.tag('lightblue') .. " [CC]" .. c.white end
    local details = short_details(c, r, opts, false)
    if details ~= "" then line = line .. " / " .. details end
    return line
end

--- The full style between two separators sized to its longest line.
local function print_framed(lines)
    local width = 0
    for _, line in ipairs(lines) do width = math.max(width, get_visual_length(line)) end
    width = math.min(math.max(width - 3, 60), MessageCore.SEPARATOR_WIDTH)
    local separator = MessageCore.create_color_code(MessageCore.COLORS.SEPARATOR) .. string.rep("=", width)
    MessageCore.raw(separator)
    print_fitted(lines)
    MessageCore.raw(separator)
end

--- Display a roll result in the player's roll style (UI_CONFIG `rolls`):
--- full (framed block), compact (two lines) or one line; each detail can be
--- turned off. A roll from another box uses `remote_style` and may be off.
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
--- @param source string|nil Caster when the roll was made on another box ("Kaories COR")
function RollMessages.show_roll_result(roll_name, value_display, bonus_display, is_crooked, affected_count, total_count, lucky_num, unlucky_num, missed_names, bust_rate, job_bonus_info, roll_range, source)
    local style, opts = roll_view(source)
    if not style then return end
    local c = roll_context(roll_name, value_display, bonus_display, is_crooked, source)
    local r = {affected = affected_count, total = total_count, lucky = lucky_num, unlucky = unlucky_num,
               missed = missed_names, bust_rate = bust_rate, job_bonus = job_bonus_info, range = roll_range}
    if style == 'compact' then
        print_fitted(compact_lines(c, r, opts))
    elseif style == 'line' then
        print_fitted({one_line(c, r, opts)})
    else
        print_framed(full_lines(c, r, opts))
    end
end

---============================================================================
--- BUST MESSAGES
---============================================================================

--- Display bust message with effect (simple one-line format)
--- @param roll_name string Name of the roll that busted
--- @param bust_effect string Bust effect value (e.g., "-4")
--- @param effect_type string Type of effect (e.g., "% Double-Attack")
--- @param source string|nil Caster when the roll was made on another box
function RollMessages.show_roll_bust(roll_name, bust_effect, effect_type, source)
    if not roll_view(source) then return end
    local job_color = MessageCore.create_color_code(MessageCore.COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(MessageCore.COLORS.ERROR)
    local roll_color = MessageCore.create_color_code(MessageCore.COLORS.JA)
    local white_color = ChatPalette.tag('white')

    -- Region-specific orange, read at call time (see message_colors.lua)
    local warning_code = MessageCore.COLORS.get_warning_color()
    local warning_color = MessageCore.create_color_code(warning_code)

    -- Simple one-line message: [COR/DNC] BUST! Fighter's Roll / Penalty: -4 Regen
    -- Build message piece by piece with explicit color codes
    local message = tag_prefix(job_color, white_color, source) ..
                    error_color .. "BUST!" ..
                    white_color .. " " ..
                    roll_color .. roll_name ..
                    white_color .. " / " ..
                    warning_color .. "Penalty: " .. bust_effect .. effect_type

    -- Channel 121 instead of 001 to preserve inline colors
    for _, part in ipairs(fit(message)) do add_to_chat(121, part) end
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

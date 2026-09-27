---============================================================================
--- Roll Share - a COR alt's roll messages shown on the main too
---============================================================================
--- When this box is an alt playing COR, each roll result and bust it shows
--- is sent to the main box (`send <main> gs c rollshow <kind> <fields>`),
--- which prints the very same message through roll_messages.lua, tagged
--- with the caster ("[Kaories COR]") instead of the main's own job.
---
--- Sent only when this box is an alt (DualBoxConfig.role) and the main has
--- reported its job through our system (alt_states.lua): a main still on
--- another GearSwap would get a command it does not know.
---
--- Fields are hex-encoded: roll names hold spaces and apostrophes, and an
--- empty field is sent as "-" so the word count never shifts.
---
--- @file    shared/utils/dualbox/roll_share.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-27
---============================================================================

local RollShare = {}

local function hex(value)
    local text = value == nil and '' or tostring(value)
    if text == '' then return '-' end
    return (text:gsub('.', function(c) return ('%02x'):format(c:byte()) end))
end

local function unhex(word)
    if word == nil or word == '-' then return '' end
    return (word:gsub('%x%x', function(x) return string.char(tonumber(x, 16)) end))
end

--- "a,b" from a list, the value itself otherwise.
local function joined(value)
    if type(value) ~= 'table' then return value end
    local out = {}
    for _, v in ipairs(value) do out[#out + 1] = tostring(v) end
    return table.concat(out, ',')
end

--- The main box to send to, or nil (not an alt, or main not on our system).
local function main_box()
    local cfg = rawget(_G, 'DualBoxConfig')
    if type(cfg) ~= 'table' or cfg.enabled == false or cfg.role ~= 'alt' then return nil end
    local main = cfg.main_character
    if type(main) ~= 'string' or main == '' then return nil end
    local ok, AltStates = pcall(require, 'shared/utils/dualbox/alt_states')
    if not (ok and AltStates and AltStates.get and AltStates.get(main)) then return nil end
    return main
end

--- Send one message to the main.
--- @param kind string 'result' or 'bust'
--- @param fields table Values in order (n = count, holes allowed)
local function send(kind, fields)
    local main = main_box()
    if not main or not player then return end
    local words = {kind, hex(player.name .. ' ' .. tostring(player.main_job))}
    for i = 1, fields.n do words[#words + 1] = hex(joined(fields[i])) end
    send_command(('send %s gs c rollshow %s'):format(main, table.concat(words, ' ')))
end

--- A roll result, same arguments as RollMessages.show_roll_result.
function RollShare.result(roll_name, value_display, bonus_display, is_crooked, affected_count, total_count,
                          lucky_num, unlucky_num, missed_names, bust_rate, job_bonus_info, roll_range)
    send('result', {n = 12, roll_name, value_display, bonus_display, is_crooked and '1' or '',
        affected_count, total_count, lucky_num, unlucky_num, missed_names, bust_rate, job_bonus_info, roll_range})
end

--- A bust, same arguments as RollMessages.show_roll_bust.
function RollShare.bust(roll_name, bust_effect, effect_type)
    send('bust', {n = 3, roll_name, bust_effect, effect_type})
end

--- "5" -> 5, "4,8" -> {4, 8}, "" -> nil.
local function numbers(text)
    if text == '' then return nil end
    if not text:find(',') then return tonumber(text) end
    local out = {}
    for part in text:gmatch('[^,]+') do out[#out + 1] = tonumber(part) end
    return out
end

local function names(text)
    local out = {}
    for part in text:gmatch('[^,]+') do out[#out + 1] = part end
    return out
end

--- //gs c rollshow <kind> <source> <fields...>, from the COR box.
--- @param args table Words after "rollshow"
function RollShare.receive(args)
    local kind, source = args[1], unhex(args[2])
    local f = {}
    for i = 3, #args do f[#f + 1] = unhex(args[i]) end
    local RollMessages = require('shared/utils/messages/utilities/roll_messages')
    if kind == 'result' and #f >= 12 then
        RollMessages.show_roll_result(f[1], f[2], f[3], f[4] == '1', tonumber(f[5]), tonumber(f[6]),
            tonumber(f[7]), numbers(f[8]), names(f[9]), tonumber(f[10]), f[11] ~= '' and f[11] or nil,
            tonumber(f[12]), source)
    elseif kind == 'bust' and #f >= 3 then
        RollMessages.show_roll_bust(f[1], f[2], f[3], source)
    end
end

return RollShare

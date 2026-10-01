---============================================================================
--- Buff Timers - time left on this character's buffs, and their full length
---============================================================================
--- The game sends this character's buffs with their end times in packet
--- 0x063, order 9 (libs/packets/fields.lua: Buffs at 0x08, 32 shorts; Time
--- at 0x48, 32 ints, in 1/60 s since 2002-01-01 JST, wrapping every 2^32/60
--- s, about 2.27 years). read() decodes it (stealth_timers.lua uses it too).
---
--- The full length of a buff is not in the packet: it is taken when the buff
--- appears, or when its end time jumps forward (recast), as end - now. So the
--- part left (fraction_left) is known from the first cast seen. The lengths
--- are saved (saved/buff_timers.lua), so a reload keeps them; a buff cast
--- while GearSwap was not running counts from the moment it is first seen.
--- Used by //gs c buff to recast a buff whose time left is under
--- BUFF_CONFIG.lua refresh_below (percent).
---
--- @file shared/utils/buffs/buff_timers.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01 (packet reading from stealth_timers.lua)
---============================================================================

local BuffTimers = {}

local EPOCH = 1009810800            -- 2002-01-01 JST, the game's time origin
local WRAP = 0x100000000 / 60       -- seconds before the counter wraps
--- An end time later than the known one by more than this: a recast.
local RENEWED = 3

local function u16(data, at) return data:byte(at) + data:byte(at + 1) * 256 end
local function u32(data, at)
    return data:byte(at) + data:byte(at + 1) * 0x100 + data:byte(at + 2) * 0x10000
        + data:byte(at + 3) * 0x1000000
end

--- os.time() of a buff's end: the wrap count is the one that puts it nearest
--- to now (a buff lasts hours at most, a wrap is 2.27 years).
local function end_time(raw)
    local base = EPOCH + raw / 60
    local wraps = math.floor((os.time() - base) / WRAP + 0.5)
    return math.floor(base + wraps * WRAP)
end

--- The buffs of packet 0x063 order 9.
--- @param data string Packet
--- @return table list of {id, finish} (finish: os.time() of the end)
function BuffTimers.read(data)
    local out = {}
    if #data < 0x48 + 32 * 4 then return out end
    for i = 0, 31 do
        local id = u16(data, 9 + i * 2)
        if id ~= 0 and id ~= 255 then
            out[#out + 1] = {id = id, finish = end_time(u32(data, 73 + i * 4))}
        end
    end
    return out
end

local SAVE_FILE = 'buff_timers.lua'

local function save_path()
    local ok, path = pcall(function()
        return require('shared/utils/core/char_paths').writable('saved', SAVE_FILE)
    end)
    return ok and path or nil
end

--- The lengths are also saved in <Character>/saved/buff_timers.lua: after a
--- //lua reload gearswap (windower.* is reset) a buff already up would
--- otherwise get as length the time it has left, and be recast late. Seen in
--- play: Refresh III of 23:25 not recast at 1:28 left (10 % is 2:20).
local function load_saved()
    local path = save_path()
    local ok, saved = pcall(function() return path and windower.file_exists(path) and dofile(path) end)
    local known, now = {}, os.time()
    for id, e in pairs(ok and type(saved) == 'table' and saved or {}) do
        if type(e) == 'table' and tonumber(e.finish) and tonumber(e.full) and e.finish > now then
            known[tonumber(id)] = {finish = e.finish, full = e.full}
        end
    end
    return known
end

local function save(known)
    local path = save_path()
    local file = path and io.open(path, 'w')
    if not file then return end
    local lines = {}
    for id, e in pairs(known) do
        lines[#lines + 1] = ('    [%d] = {finish = %d, full = %d},'):format(id, e.finish, e.full)
    end
    file:write('-- Own buffs: end time and full length, written by buff_timers.lua\nreturn {\n'
        .. table.concat(lines, '\n') .. '\n}\n')
    file:close()
end

--- id -> {finish, full}, on windower (survives a job change), and in the
--- saved file (survives //lua reload gearswap).
local function store()
    windower._buff_timers = windower._buff_timers or load_saved()
    return windower._buff_timers
end

local function on_buffs(data)
    local now = os.time()
    local seen, known, changed = {}, store(), false
    for _, buff in ipairs(BuffTimers.read(data)) do
        local finish = buff.finish
        -- the latest end when one id is there several times
        if not seen[buff.id] or finish > seen[buff.id] then seen[buff.id] = finish end
    end
    for id, finish in pairs(seen) do
        local entry = known[id]
        if not entry or finish > entry.finish + RENEWED then
            known[id] = {finish = finish, full = math.max(1, finish - now)}
            changed = true
        else
            entry.finish = finish
        end
    end
    for id in pairs(known) do
        if not seen[id] then known[id] = nil; changed = true end
    end
    if changed then save(known) end
end

--- Seconds left on a buff, or nil when unknown.
--- @param id number Buff id (res/buffs.lua)
--- @return number|nil
function BuffTimers.left(id)
    local entry = id and store()[id]
    if not entry then return nil end
    return math.max(0, entry.finish - os.time())
end

--- Part of the buff left, 0 to 1, or nil when unknown.
--- @param id number Buff id
--- @return number|nil
function BuffTimers.fraction_left(id)
    local entry = id and store()[id]
    if not entry then return nil end
    return math.max(0, entry.finish - os.time()) / entry.full
end

--- Start the packet listener, once per load (a raw event: a plain one from a
--- job file runs GearSwap's refresh on every packet).
function BuffTimers.start()
    if rawget(_G, '_buff_timers_listener') then return end
    _G._buff_timers_listener = windower.raw_register_event('incoming chunk', function(id, data)
        if id == 0x063 and data:byte(5) == 9 then pcall(on_buffs, data) end
    end)
end

return BuffTimers

---============================================================================
--- Stealth Timers - time left on Sneak / Invisible, here and on the alts
---============================================================================
--- The game sends this character's buffs with their end times in packet
--- 0x063, order 9 (libs/packets/fields.lua: Buffs at 0x08, 32 shorts; Time
--- at 0x48, 32 ints, in 1/60 s since 2002-01-01 JST, wrapping every 2^32/60
--- s, about 2.27 years). Only one's own buffs come with a time: each box
--- reads its own and sends the end times to the rest of the group
--- (`//gs c stealth time <name> <sneak end> <invi end>`, os.time() values,
--- 0 = none).
---
--- A one-second loop warns before a buff wears off (settings: alerts,
--- alert_before) and redraws the alt window while a timer runs.
---
--- @file shared/utils/stealth/stealth_timers.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

local StealthTimers = {}

local BUFF_IDS = {sneak = 71, invi = 69}
local LABELS = {sneak = 'Sneak', invi = 'Invisible'}
local EPOCH = 1009810800            -- 2002-01-01 JST, the game's time origin
local WRAP = 0x100000000 / 60       -- seconds before the counter wraps

---============================================================================
--- STORE (on windower: survives a GearSwap reload)
---============================================================================

--- End times per character: store[name:lower()] = {name, sneak, invi}.
local function store()
    windower._stealth_timers = windower._stealth_timers or {}
    return windower._stealth_timers
end

local function me()
    return player and player.name
end

--- Seconds left on a buff of `name` (this character when nil), or nil when
--- no end time is known.
--- @param kind string 'sneak' or 'invi'
--- @param name string|nil Character
--- @return number|nil
function StealthTimers.left(kind, name)
    local entry = store()[(name or me() or ''):lower()]
    local finish = entry and entry[kind]
    if not finish or finish == 0 then return nil end
    local left = finish - os.time()
    return left > 0 and left or nil
end

--- "4:12", or "-" when nothing is known.
--- @param seconds number|nil
--- @return string
function StealthTimers.format(seconds)
    if not seconds then return '-' end
    return ('%d:%02d'):format(math.floor(seconds / 60), math.floor(seconds % 60))
end

---============================================================================
--- PACKET 0x063 ORDER 9
---============================================================================

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

--- Sneak and Invisible end times read from the packet (0 = not up).
local function read_packet(data)
    local found = {sneak = 0, invi = 0}
    if #data < 0x48 + 32 * 4 then return found end
    for i = 0, 31 do
        local buff = u16(data, 9 + i * 2)
        for kind, id in pairs(BUFF_IDS) do
            if buff == id then found[kind] = end_time(u32(data, 73 + i * 4)) end
        end
    end
    return found
end

--- Tell the other boxes of the group.
local function broadcast(entry)
    local ok, AltGroup = pcall(require, 'shared/utils/dualbox/alt_group')
    if not (ok and AltGroup) then return end
    for _, name in ipairs(AltGroup.get_alts()) do
        send_command(('send %s gs c stealth time %s %d %d'):format(name, entry.name, entry.sneak, entry.invi))
    end
end

local function on_buffs(data)
    local name = me()
    if not name then return end
    local found = read_packet(data)
    local entry = store()[name:lower()] or {name = name, sneak = 0, invi = 0}
    if entry.sneak == found.sneak and entry.invi == found.invi then return end
    entry.sneak, entry.invi = found.sneak, found.invi
    store()[name:lower()] = entry
    broadcast(entry)
end

--- //gs c stealth time <name> <sneak end> <invi end>, from another box.
--- @param args table Words after "time"
function StealthTimers.receive(args)
    local name, sneak, invi = args[1], tonumber(args[2]), tonumber(args[3])
    if not (name and sneak and invi) then return end
    store()[name:lower()] = {name = name, sneak = sneak, invi = invi}
end

---============================================================================
--- WEAR-OFF WARNING AND WINDOW REFRESH
---============================================================================

local function alert(entry, kind, left)
    local ok, Msg = pcall(require, 'shared/utils/messages/formatters/system/message_stealth')
    if not (ok and Msg) then return end
    local who = (entry.name:lower() == (me() or ''):lower()) and nil or entry.name
    Msg.show_wearing_off(who, LABELS[kind], left)
end

local function tick_once()
    local Config = require('shared/utils/stealth/stealth_config')
    local settings = Config.get()
    local warned = windower._stealth_warned or {}
    windower._stealth_warned = warned
    local running = false
    for key, entry in pairs(store()) do
        for kind in pairs(BUFF_IDS) do
            local left = StealthTimers.left(kind, entry.name)
            local tag = key .. kind .. tostring(entry[kind])
            if left then
                running = true
                if settings.alerts and left <= settings.alert_before and not warned[tag] then
                    warned[tag] = true
                    alert(entry, kind, left)
                end
            end
        end
    end
    if running then
        local ok, AltWindow = pcall(require, 'shared/utils/dualbox/alt_window')
        if ok and AltWindow then AltWindow.refresh() end
    end
end

--- Start the packet listener and the one-second loop, once per load.
--- The listener is a raw event: a plain one from a job file runs GearSwap's
--- refresh_globals and equip_sets on every packet. The loop of an older
--- load stops when a newer one starts (generation on `windower`).
function StealthTimers.start()
    if rawget(_G, '_stealth_listener') then return end
    _G._stealth_listener = windower.raw_register_event('incoming chunk', function(id, data)
        if id == 0x063 and data:byte(5) == 9 then pcall(on_buffs, data) end
    end)
    windower._stealth_gen = (windower._stealth_gen or 0) + 1
    local gen = windower._stealth_gen
    local function tick()
        if gen ~= windower._stealth_gen then return end
        pcall(tick_once)
        coroutine.schedule(tick, 1)
    end
    coroutine.schedule(tick, 1)
end

return StealthTimers

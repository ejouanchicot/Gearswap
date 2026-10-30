---============================================================================
--- Item Icons - the game's own 32x32 item icons, for the Atelier page
---============================================================================
--- Reads an item's icon from the FFXI DAT files and writes it as a 32-bit BMP
--- with alpha, which browsers show as is: data/atelier/icons/<id>.bmp, and the
--- same bytes as text, data/atelier/icons/<id>.js (the page's HD icons). The
--- icon is the one the game's equipment window shows; nothing is downloaded.
---
--- DAT layout (one 0x1400-byte record per item, icon at 0x2BD: a 256-colour
--- palette then 32x32 palette indices, every byte bit-rotated) as read by the
--- icon_extractor of the EquipViewer addon (Rubenator, BSD-3-Clause),
--- addons/equipviewer/icon_extractor.lua.
---
--- @file    shared/utils/atelier/item_icons.lua
--- @author  ejouanchicot
--- @version 1.1
--- @date    Created: 2026-10-01
---============================================================================

local ItemIcons = {}

-- Item id ranges and the DAT holding their records (path under ROM, first id of the file)
local DATS = {
    {min = 0x0001, max = 0x0FFF, dat = '118/106', first = 0x0000},
    {min = 0x1000, max = 0x1FFF, dat = '118/107', first = 0x1000},
    {min = 0x2000, max = 0x21FF, dat = '118/110', first = 0x2000},
    {min = 0x2200, max = 0x27FF, dat = '301/115', first = 0x2200},
    {min = 0x2800, max = 0x3FFF, dat = '118/109', first = 0x2800},
    {min = 0x4000, max = 0x59FF, dat = '118/108', first = 0x4000},
    {min = 0x5A00, max = 0x6FFF, dat = '286/73', first = 0x5A00},
    {min = 0x7000, max = 0x73FF, dat = '217/21', first = 0x7000},
    {min = 0x7400, max = 0x77FF, dat = '288/80', first = 0x7400},
}
local RECORD, ICON_AT = 0x1400, 0x2BD

-- BMP header: BITMAPV4, 32x32, 32 bpp, BI_BITFIELDS with an alpha mask
local HEADER = 'BM' .. '\122\16\0\0' .. '\0\0\0\0' .. '\122\0\0\0'
    .. '\108\0\0\0' .. '\32\0\0\0' .. '\32\0\0\0' .. '\1\0' .. '\32\0' .. '\3\0\0\0' .. '\0\16\0\0'
    .. string.rep('\0', 16)
    .. '\0\0\255\0' .. '\0\255\0\0' .. '\255\0\0\0' .. '\0\0\0\255'
    .. 'sRGB' .. string.rep('\0', 48)

-- Bytes are stored rotated by 3 bits; alpha is stored halved
local DECODE, DECODE_ALPHA = {}, {}
for i = 0, 255 do
    local n = (i % 0x20) * 8 + math.floor(i / 0x20)
    DECODE[string.char(i)] = string.char(n)
    DECODE_ALPHA[string.char(i)] = string.char(math.min(n * 2, 255))
end

local function dat_of(id)
    for _, d in ipairs(DATS) do
        if id >= d.min and id <= d.max then return d end
    end
end

--- The BMP bytes of one item's icon, or nil.
local function read_icon(id)
    local d = dat_of(id)
    local root = windower and windower.ffxi_path
    if not d or not root then return nil end
    local file = io.open(root .. '/ROM/' .. d.dat .. '.DAT', 'rb')
    if not file then return nil end
    file:seek('set', (id - d.first) * RECORD + ICON_AT)
    local data = file:read(0x800)
    file:close()
    if not data or #data < 0x800 then return nil end
    local colour = {}
    for i = 0, 255 do
        local p = i * 4 + 1
        local a, b, c, al = data:sub(p, p), data:sub(p + 1, p + 1), data:sub(p + 2, p + 2), data:sub(p + 3, p + 3)
        colour[i] = DECODE[a] .. DECODE[b] .. DECODE[c] .. DECODE_ALPHA[al]
    end
    -- pixel bytes are rotated palette indices
    local pixels = data:sub(0x401, 0x800):gsub('.', function(ch) return colour[DECODE[ch]:byte()] end)
    return HEADER .. pixels
end

local B64 = {}
for i = 0, 63 do
    B64[i] = ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'):sub(i + 1, i + 1)
end

--- Base64 of a string (about 0.6 ms for an icon in Lua 5.1).
local function base64(s)
    local out, n, len = {}, 0, #s
    for i = 1, len - 2, 3 do
        local a, b, c = s:byte(i, i + 2)
        local v = a * 65536 + b * 256 + c
        n = n + 1
        out[n] = B64[math.floor(v / 262144)] .. B64[math.floor(v / 4096) % 64] .. B64[math.floor(v / 64) % 64] .. B64[v % 64]
    end
    local rest = len % 3
    if rest > 0 then
        local a, b = s:byte(len - rest + 1, len)
        local v = a * 65536 + (b or 0) * 256
        n = n + 1
        out[n] = B64[math.floor(v / 262144)] .. B64[math.floor(v / 4096) % 64] .. (rest == 2 and B64[math.floor(v / 64) % 64] or '=') .. '='
    end
    return table.concat(out)
end

--- A file written under another name, then renamed: a run stopped half way
--- leaves no empty file (an empty <id>.bmp counted as there and was never
--- written again). True when written.
local function write_file(path, bytes)
    local file = io.open(path .. '.tmp', 'wb')
    if not file then return false end
    file:write(bytes)
    file:close()
    os.remove(path)
    return os.rename(path .. '.tmp', path) and true or false
end

--- One item's icon written to the folder; true when it was. Twice: <id>.bmp,
--- the image the page shows at once, and <id>.js, the same bytes as text that a
--- page opened from the disk may read (it may not read an image's pixels): the
--- page makes its HD icon from it (atelier/app/js/icon_cache.js). A .bmp
--- already there is kept.
local function write_one(id, folder, have_bmp)
    local bmp = read_icon(id)
    if not bmp then return false end
    if not have_bmp and not write_file(folder .. id .. '.bmp', bmp) then return false end
    return write_file(folder .. id .. '.js', ('ATELIER_ICON(%d,"%s")\n'):format(id, base64(bmp)))
end

--- The icon file names already in the folder.
local function on_disk(folder)
    windower.create_dir(folder)
    local have = {}
    for _, name in ipairs(windower.get_dir(folder) or {}) do have[name] = true end
    return have
end

-- Icons written a step, and the pause between steps: the game never stalls (about 50 ms of work every 0.1 s: an icon
-- is about 6 ms in game with its .js, measured 2026-10-30 in the trace, 25 a step froze 150 ms), every equipment icon
-- in about 5 minutes. SYNC: the icons a call writes at once, the rest in the background; all at once where nothing can
-- wait (the offline export, no coroutine.schedule)
local CHUNK, PAUSE, SYNC = 8, 0.1, 8

--- A line in the trace (//gs c trace: shared/utils/debug/trace_log.lua), when it loads (not outside the game).
local function trace(fmt, ...)
    local ok, TraceLog = pcall(require, 'shared/utils/debug/trace_log')
    if ok and type(TraceLog) == 'table' and TraceLog.log then pcall(TraceLog.log, 'ICONS', fmt, ...) end
end

--- The icons a call left, written in the background: the list is kept on windower, so that a GearSwap reload keeps it
--- (the loop of the older load stops at its next step, the token) and a new call adds to it.
local function write_rest(folder, have, ids)
    local rest = windower._atelier_icon_rest
    if not rest or rest.folder ~= folder then rest = {folder = folder, ids = {}, seen = {}} end
    for _, id in ipairs(ids) do
        if not rest.seen[id] then rest.seen[id] = true; rest.ids[#rest.ids + 1] = id end
    end
    windower._atelier_icon_rest = rest
    local token = (rest.token or 0) + 1
    rest.token = token
    local function step()
        if rest.token ~= token or windower._atelier_icon_rest ~= rest then return end
        local t, written = os.clock(), 0
        for _ = 1, CHUNK do
            local id = table.remove(rest.ids, 1)
            if not id then break end
            rest.seen[id] = nil
            -- one broken icon never ends the loop (an error here would leave the rest to the next call)
            local ok, done = true, false
            if not have[id .. '.js'] then ok, done = pcall(write_one, id, folder, have[id .. '.bmp']) end
            if ok and done then
                have[id .. '.bmp'], have[id .. '.js'] = true, true
                written = written + 1
            end
        end
        trace('background: %d written in %.0f ms, %d left', written, (os.clock() - t) * 1000, #rest.ids)
        if #rest.ids > 0 then coroutine.schedule(step, PAUSE) end
    end
    coroutine.schedule(step, PAUSE)
    return #rest.ids
end

--- Write the icons of these item ids that are not on the disk yet (an icon
--- whose .js is missing is written again: an icon from before 2026-10-30):
--- SYNC of them at once, the others in the background.
--- @param ids table List of item ids
--- @param folder string Absolute folder, ending with '/'
--- @return number written now, number left to the background
function ItemIcons.write_missing(ids, folder)
    local t0 = os.clock()
    local have, written, tried, later = on_disk(folder), 0, 0, {}
    local listed = os.clock()
    local can_wait = type(coroutine.schedule) == 'function'
    for _, id in ipairs(ids) do
        if not have[id .. '.js'] then
            if can_wait and tried >= SYNC then
                later[#later + 1] = id
            else
                tried = tried + 1
                if write_one(id, folder, have[id .. '.bmp']) then
                    have[id .. '.bmp'], have[id .. '.js'] = true, true
                    written = written + 1
                end
            end
        end
    end
    local queued = #later > 0 and write_rest(folder, have, later) or 0
    trace('%d asked: folder listed in %.0f ms, %d written in %.0f ms, %d to the background', #ids, (listed - t0) * 1000,
        written, (os.clock() - listed) * 1000, queued)
    return written, queued
end

--- Every equipment icon of the game (armour and weapons of res.items) not on the disk yet, a few at a
--- time; say(kind, a, b) tells the chat: 'start' (to write, total), 'progress' (done, total), 'done'
--- (written). A second call while one runs stops the first (windower._atelier_icons, a token).
--- @param folder string Absolute folder, ending with '/'
--- @param say function
function ItemIcons.extract_all(folder, say)
    local gs = rawget(_G, 'gearswap')
    local resources = rawget(_G, 'res') or (gs and gs.res)
    if not (resources and resources.items) then return say('start', 0, 0) end
    local have, todo, total = on_disk(folder), {}, 0
    for id, item in pairs(resources.items) do
        if type(item) == 'table' and (item.category == 'Armor' or item.category == 'Weapon') then
            total = total + 1
            if not have[id .. '.js'] then todo[#todo + 1] = id end
        end
    end
    table.sort(todo)
    local token = (windower._atelier_icons or 0) + 1
    windower._atelier_icons = token
    say('start', #todo, total)
    if #todo == 0 then return end
    local at, written = 1, 0
    local function step()
        if windower._atelier_icons ~= token then return end
        for k = at, math.min(at + CHUNK - 1, #todo) do
            if write_one(todo[k], folder, have[todo[k] .. '.bmp']) then written = written + 1 end
        end
        local before = at
        at = at + CHUNK
        trace('every icon: %d / %d', math.min(at - 1, #todo), #todo)
        if at > #todo then return say('done', written) end
        if math.floor(at / 1000) > math.floor(before / 1000) then say('progress', at - 1, #todo) end
        coroutine.schedule(step, PAUSE)
    end
    coroutine.schedule(step, PAUSE)
end

return ItemIcons

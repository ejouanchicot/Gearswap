---============================================================================
--- Item Icons - the game's own 32x32 item icons, for the Atelier page
---============================================================================
--- Reads an item's icon from the FFXI DAT files and writes it as a 32-bit BMP
--- with alpha, which browsers show as is: data/atelier/icons/<id>.bmp. The
--- icon is the one the game's equipment window shows; nothing is downloaded.
---
--- DAT layout (one 0x1400-byte record per item, icon at 0x2BD: a 256-colour
--- palette then 32x32 palette indices, every byte bit-rotated) as read by the
--- icon_extractor of the EquipViewer addon (Rubenator, BSD-3-Clause),
--- addons/equipviewer/icon_extractor.lua.
---
--- @file    shared/utils/atelier/item_icons.lua
--- @author  ejouanchicot
--- @version 1.0
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

--- One item's icon written to the folder; true when it was.
local function write_one(id, folder)
    local bmp = read_icon(id)
    local file = bmp and io.open(folder .. id .. '.bmp', 'wb')
    if not file then return false end
    file:write(bmp)
    file:close()
    return true
end

--- The icon file names already in the folder.
local function on_disk(folder)
    windower.create_dir(folder)
    local have = {}
    for _, name in ipairs(windower.get_dir(folder) or {}) do have[name] = true end
    return have
end

--- Write the icons of these item ids that are not on the disk yet.
--- @param ids table List of item ids
--- @param folder string Absolute folder, ending with '/'
--- @return number written
function ItemIcons.write_missing(ids, folder)
    local have, written = on_disk(folder), 0
    for _, id in ipairs(ids) do
        if not have[id .. '.bmp'] and write_one(id, folder) then
            have[id .. '.bmp'] = true
            written = written + 1
        end
    end
    return written
end

-- Icons written a call, and the pause between calls: the game never stalls (about 60 ms of work
-- every 0.1 s), every equipment icon in about 40 seconds
local CHUNK, PAUSE = 40, 0.1

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
            if not have[id .. '.bmp'] then todo[#todo + 1] = id end
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
            if write_one(todo[k], folder) then written = written + 1 end
        end
        local before = at
        at = at + CHUNK
        if at > #todo then return say('done', written) end
        if math.floor(at / 1000) > math.floor(before / 1000) then say('progress', at - 1, #todo) end
        coroutine.schedule(step, PAUSE)
    end
    coroutine.schedule(step, PAUSE)
end

return ItemIcons

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

--- Write the icons of these item ids that are not on the disk yet.
--- @param ids table List of item ids
--- @param folder string Absolute folder, ending with '/'
--- @return number written
function ItemIcons.write_missing(ids, folder)
    windower.create_dir(folder)
    local have = {}
    for _, name in ipairs(windower.get_dir(folder) or {}) do have[name] = true end
    local written = 0
    for _, id in ipairs(ids) do
        local name = id .. '.bmp'
        if not have[name] then
            local bmp = read_icon(id)
            local file = bmp and io.open(folder .. name, 'wb')
            if file then
                file:write(bmp)
                file:close()
                have[name] = true
                written = written + 1
            end
        end
    end
    return written
end

return ItemIcons

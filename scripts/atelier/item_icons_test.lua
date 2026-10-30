---============================================================================
--- Test of the item icons written for the Atelier (shared/utils/atelier/item_icons.lua)
---============================================================================
--- Each icon is written twice: <id>.bmp and <id>.js (ATELIER_ICON(id, "<the
--- same bytes in base64>"), the page's HD icons); a .bmp already there is kept
--- and gets its .js; a call writes 8 icons at once and leaves the others to
--- the background, which a GearSwap reload keeps (the older loop stops, the
--- newer one writes them all); without coroutine.schedule (the offline export)
--- every icon is written at once. Needs the game's DAT files (the FFXI folder
--- in FFXI_PATH, else the Steam one): without them the test says it was skipped.
---
--- Run from data/: lua5.1 scripts/atelier/item_icons_test.lua
---
--- @file scripts/atelier/item_icons_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-30
---============================================================================

package.path = './?.lua;' .. package.path

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

local FFXI = os.getenv('FFXI_PATH') or 'D:/Steam/steamapps/common/FFXIPAL/SquareEnix/FINAL FANTASY XI'
local probe = io.open(FFXI .. '/ROM/118/106.DAT', 'rb')
if not probe then print('skipped: no FFXI DAT files (set FFXI_PATH)') return end
probe:close()

-- a scratch folder, listed by the test itself (the module asks windower for it)
local folder = os.tmpname():gsub('\\', '/'):gsub('[^/]*$', '') .. 'item_icons_test_' .. os.time() .. '/'
os.execute('mkdir "' .. folder:gsub('/', '\\') .. '" 2>nul')
local function listing()
    local list, h = {}, io.popen('dir /b "' .. folder:gsub('/', '\\') .. '" 2>nul')
    for line in h:lines() do list[#list + 1] = line end
    h:close()
    return list
end
local scheduled = {}
windower = {ffxi_path = FFXI, create_dir = function() end, get_dir = listing}
local function load_module()
    package.loaded['shared/utils/atelier/item_icons'] = nil
    return require('shared/utils/atelier/item_icons')
end
local function read(path) local f = io.open(path, 'rb'); if not f then return nil end local s = f:read('*a'); f:close(); return s end
local function exists(path) local f = io.open(path, 'rb'); if f then f:close() end return f ~= nil end

-- base64 read back by hand, to compare the .js with the .bmp
local B = {}
for i, c in ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'):gmatch('()(.)') do B[c] = i - 1 end
local function unbase64(s)
    local out = {}
    for quad in s:gmatch('....') do
        local a, b, c, d = B[quad:sub(1, 1)], B[quad:sub(2, 2)], B[quad:sub(3, 3)], B[quad:sub(4, 4)]
        local v = a * 262144 + b * 4096 + (c or 0) * 64 + (d or 0)
        out[#out + 1] = string.char(math.floor(v / 65536))
        if c then out[#out + 1] = string.char(math.floor(v / 256) % 256) end
        if d then out[#out + 1] = string.char(v % 256) end
    end
    return table.concat(out)
end
local function js_matches(id)
    local js, bmp = read(folder .. id .. '.js'), read(folder .. id .. '.bmp')
    local n, data = (js or ''):match('^ATELIER_ICON%((%d+),"([%w+/=]+)"%)\n$')
    return bmp ~= nil and tonumber(n) == id and unbase64(data) == bmp
end

-- equipment ids that have an icon in the DATs (Bronze Sword and the like: low ids of 118/106)
local ids = {}
for id = 16385, 16385 + 69 do ids[#ids + 1] = id end

-- 1. offline (no coroutine.schedule): all at once
coroutine.schedule = nil
local Icons = load_module()
local now, later = Icons.write_missing({ids[1], ids[2], ids[3]}, folder)
check('offline: all written at once', now, 3)
check('offline: nothing left', later, 0)
for k = 1, 3 do check('offline: .js = .bmp ' .. ids[k], js_matches(ids[k]), true) end

-- 2. a .bmp from before (no .js): kept, its .js written (this .bmp is changed on purpose: left out at the end)
os.remove(folder .. ids[1] .. '.js')
local f = io.open(folder .. ids[1] .. '.bmp', 'ab'); f:write('KEPT'); f:close()
now = Icons.write_missing({ids[1]}, folder)
check('old .bmp: its .js written', now, 1)
check('old .bmp: kept as it was', read(folder .. ids[1] .. '.bmp'):sub(-4), 'KEPT')
check('a second call writes nothing', (Icons.write_missing({ids[2], ids[3]}, folder)), 0)

-- 3. in game: 20 at once, the rest in the background
coroutine.schedule = function(fn) scheduled[#scheduled + 1] = fn end
local rest = {}
for k = 4, 60 do rest[#rest + 1] = ids[k] end
now, later = Icons.write_missing(rest, folder)
check('in game: 8 at once', now, 8)
check('in game: the others left', later, 49)
check('the 9th not yet written', exists(folder .. ids[12] .. '.js'), false)
-- one background step (8), then a GearSwap reload: a new module adds ids, the older loop stops
table.remove(scheduled, 1)()
Icons = load_module()
local more = {}
for k = 55, 70 do more[#more + 1] = ids[k] end
Icons.write_missing(more, folder)
local steps = 0
while #scheduled > 0 and steps < 50 do table.remove(scheduled, 1)(); steps = steps + 1 end
local all = true
for k = 2, 70 do if not js_matches(ids[k]) then all = false; print('missing or wrong: ' .. ids[k]) end end
check('every icon written once the background is done, each .js = its .bmp', all, true)
local tmp = 0
for _, name in ipairs(listing()) do if name:match('%.tmp$') then tmp = tmp + 1 end end
check('no .tmp left', tmp, 0)

for _, name in ipairs(listing()) do os.remove(folder .. name) end
os.execute('rmdir "' .. folder:gsub('/', '\\') .. '" 2>nul')
print(('%d checks, %d failed'):format(done, failed))
if failed > 0 then os.exit(1) end

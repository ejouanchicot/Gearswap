---============================================================================
--- Atelier offline export - write item icons outside the game
---============================================================================
--- The icons of these item ids, read from the FFXI files by
--- shared/utils/atelier/item_icons.lua (those already on the disk are kept).
---
---   lua5.1 write_icons.lua <ffxi_path> <icons folder/> <id> [<id> ...]
---
--- @file    scripts/atelier/write_icons.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-01
---============================================================================

local DATA = arg[0]:gsub('\\', '/'):match('^(.*)/scripts/atelier/[^/]*$') or '.'
package.path = DATA .. '/?.lua;' .. package.path

local function win(p) return (p:gsub('/', '\\')) end
windower = {
    ffxi_path = arg[1],
    create_dir = function(p) os.execute('mkdir "' .. win(p) .. '" 2>nul') end,
    get_dir = function(p)
        local list = {}
        local h = io.popen('dir /b "' .. win(p) .. '" 2>nul')
        if h then for line in h:lines() do list[#list + 1] = line end h:close() end
        return list
    end,
}

local ids = {}
for i = 3, #arg do ids[#ids + 1] = tonumber(arg[i]) end
local folder = arg[2]:gsub('\\', '/')
print(('%d icons written'):format(require('shared/utils/atelier/item_icons').write_missing(ids, folder)))

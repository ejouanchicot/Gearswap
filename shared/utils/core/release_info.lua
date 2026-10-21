---============================================================================
--- Release Info - the installed version, and the way to update it
---============================================================================
--- //gs c version   the version installed (data/VERSION, written by a release)
--- //gs c upgrade   opens the Atelier page on its update screen: the page reads the
---                  latest release on GitHub, downloads the files that changed and
---                  asks AtelierLink to restart GearSwap (atelier/app/js/update.js)
---
--- GearSwap downloads nothing itself: the browser checks GitHub's certificate,
--- Windower's Lua does not (verify = "none" in addons/libs/ssl/https.lua).
--- The page is opened with #update; Windows may drop that part of a file
--- address, so data/atelier/update_ask.js also tells the page, which opens its
--- update screen when that file is younger than ASK_SECONDS.
---
--- @file    shared/utils/core/release_info.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-21
---============================================================================

local ReleaseInfo = {}

local ASK_SECONDS = 120

local function data_path(rel)
    return windower.addon_path .. 'data/' .. rel
end

--- The installed version, or nil when data/VERSION is missing (a folder older than the first release).
--- @return string|nil
function ReleaseInfo.version()
    local f = io.open(data_path('VERSION'), 'r')
    if not f then return nil end
    local v = f:read('*l')
    f:close()
    return v and v:match('^%s*(.-)%s*$') or nil
end

-- file:///D:/Windower%20Tetsouo/addons/GearSwap/data/atelier.html#update
local function page_url()
    local path = data_path('atelier.html'):gsub('\\', '/'):gsub(' ', '%%20')
    return 'file:///' .. path:gsub('^/+', '') .. '#update'
end

local function write_ask()
    local f = io.open(data_path('atelier/update_ask.js'), 'w')
    if not f then return end
    f:write(('window.ATELIER_UPDATE_ASK = {at: %d, within: %d};\n'):format(os.time(), ASK_SECONDS))
    f:close()
end

--- //gs c version and //gs c upgrade (not "update": Mote's own command, which re-equips the gear).
--- @param cmd string 'version' or 'upgrade'
--- @return boolean true (the command is handled)
function ReleaseInfo.handle(cmd)
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local v = ReleaseInfo.version()
    if cmd == 'version' then
        MessageFormatter.show_info(('GearSwap version %s. //gs c upgrade looks for a newer one.'):format(v or '(none: older than the first release)'))
        return true
    end
    write_ask()
    if type(windower.open_url) ~= 'function' then
        MessageFormatter.show_info('Update: open data/atelier.html in Chrome or Edge, its update screen opens by itself.')
        return true
    end
    windower.open_url(page_url())
    MessageFormatter.show_info(('Update: the Atelier page opens (Chrome or Edge). Installed: %s.'):format(v or 'none'))
    return true
end

_G.ReleaseInfo = ReleaseInfo
return ReleaseInfo

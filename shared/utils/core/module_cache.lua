---  ═══════════════════════════════════════════════════════════════════════════
---   Module Cache - make require() actually cache
---  ═══════════════════════════════════════════════════════════════════════════
---   In the GearSwap sandbox `require` is not Lua's require: refresh.lua aliases
---   it to `include_user`, which reads package.loaded but NEVER writes to it
---   (user_functions.lua:300). Only Windower's own libs are in there, so every
---   require of a project module falls through to a full disk read, a loadfile
---   compile and a fresh execution - every single call.
---
---   Measured in game with //gs c lagdebug: 300 module loads for 54 distinct
---   modules in 34 seconds, 1180ms of load time of which 1018ms (86%) was
---   re-running modules already in memory. UI_SETTINGS alone loaded 37 times.
---
---   That is what makes the project's own lazy-loading convention backfire:
---   `local X = require(...)` inside a function is documented as the cheap
---   option, and without a cache it is the expensive one.
---
---   LIFETIME - why the cache lives on the sandbox _G and nowhere else:
---   include_user does `setfenv(f, user_env)`, so a loaded module is bound to
---   the user_env it was compiled against. GearSwap drops user_env on every
---   reload and job change (refresh.lua:83). A cache in the windower table
---   would outlive that and hand the new job modules closed over the old
---   player/sets/state. On the sandbox _G it dies with the environment it
---   belongs to, which is exactly right - and it is also why GearSwap not
---   caching is defensible rather than simply a bug.
---
---   `include()` is deliberately left alone. It is the same underlying function
---   but it is used for set files, which are meant to re-execute.
---
---   @file    shared/utils/core/module_cache.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-08-09
---  ═══════════════════════════════════════════════════════════════════════════

local ModuleCache = {}

-- Lets a module that legitimately returns nil be remembered as loaded, instead
-- of being re-run forever because "no value" reads the same as "not cached".
local CACHED_NIL = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CHARACTER FILES - a broken one is named, then treated as missing
---  ═══════════════════════════════════════════════════════════════════════════
---   A player edits the files of data/<Character>/ by hand. Before, one typo in
---   any of them stopped the whole load, and the error often named the file that
---   USED it (war_sets.lua:94 'Rings' a nil value) instead of the broken one
---   (rings.lua). Now a character file that errors, is empty or returns
---   something else than a table is reported in red, with its path and line,
---   and require() gives nil: what callers already get for a missing file
---   (CharPaths.optional), so an optional file falls back to its defaults.
---   A file the job cannot do without (its sets, its states) still stops the
---   load, but the line just above names the real culprit.
---   Checked outside the game: python scripts/loadcheck/check_load.py (broken files).

--- Lowercased "<character>/" prefix of the files of the one playing, or nil.
local function char_prefix()
    local p = rawget(_G, 'player')
    local name = type(p) == 'table' and p.name
    return type(name) == 'string' and name ~= '' and (name:lower() .. '/') or nil
end

--- True when a file's text holds only blanks and comments: an emptied file.
local function blank_text(text)
    return not (text or ''):gsub('%-%-%[(=*)%[.-%]%1%]', ''):gsub('%-%-[^\n]*', ''):find('%S')
end

--- True when the required file (path relative to data/, no .lua) is an emptied one.
local function is_blank(path)
    local base = windower and windower.addon_path
    local f = base and io.open(base .. 'data/' .. path .. '.lua', 'rb')
    if not f then return false end
    local text = f:read('*a')
    f:close()
    return blank_text(text)
end

--- Say in chat which character file is broken and why.
--- The message system may itself be what fails to load: then plain chat (CODE_QUALITY §6, fallback).
local function report(path, why)
    local text = ('%s.lua is broken (%s): loaded without it, fix the file then //lua reload gearswap')
        :format(path, why)
    local ok = pcall(function() require('shared/utils/messages/message_formatter').show_error(text) end)
    if not ok then
        add_to_chat(167, '[GearSwap] ' .. text)
    end
    local list = rawget(_G, '__char_file_errors') or {}
    list[#list + 1] = {path = path, why = why}
    _G.__char_file_errors = list
end

--- Read a character settings file run with dofile (no require: absolute path, re-read on purpose).
--- A broken one is reported like a required one. Files the game writes (saved/) do not use this:
--- a broken one there is simply rewritten, the player never edits it.
--- @param path string|nil Absolute path
--- @param label string Name shown to the player (e.g. 'Tetsouo/_common/travel/STEALTH_CONFIG')
--- @return table|nil The file's table, nil when missing or broken
function ModuleCache.read_char_file(path, label)
    local f = path and io.open(path, 'rb')
    if not f then return nil end
    local text = f:read('*a') or ''
    f:close()
    local ok, result = pcall(dofile, path)
    if not ok then
        local line, why = tostring(result):match(':(%d+): ([^\n]*)$')
        report(label, line and ('line ' .. line .. ': ' .. why) or tostring(result))
        return nil
    end
    if type(result) ~= 'table' then
        report(label, blank_text(text) and 'it is empty' or ('it returns a ' .. type(result) .. ', a table { ... } was expected'))
        return nil
    end
    return result
end

--- Load a character file through the original require, never letting it stop the load.
local function load_char_file(original, path)
    local ok, result = pcall(original, path)
    if not ok then
        local msg = tostring(result)
        -- a missing file is not a broken one: callers probe with pcall(require) (CharPaths.load)
        if msg:find('Cannot find the include file', 1, true) then error(result, 0) end
        local line, why = msg:match(':(%d+): ([^\n]*)$')
        report(path, line and ('line ' .. line .. ': ' .. why) or msg)
        return nil
    end
    if result ~= nil and type(result) ~= 'table' then
        report(path, 'it returns a ' .. type(result) .. ', a table { ... } was expected')
        return nil
    end
    if result == nil and is_blank(path) then
        report(path, 'it is empty')
    end
    return result
end

--- Replace require with a caching version, once per sandbox.
--- @return boolean True when the cache was installed by this call
function ModuleCache.install()
    if rawget(_G, '__require_cache_installed') then
        return false
    end

    local original = rawget(_G, 'require')
    if type(original) ~= 'function' then
        return false
    end

    local cache = {}
    _G.__require_cache = cache
    _G.__require_cache_installed = true
    _G.__require_cache_stats = { hits = 0, loads = 0 }
    local stats = _G.__require_cache_stats

    _G.require = function(path, ...)
        -- include_user's second parameter loads the file into a caller-supplied
        -- table, which is a different result each time. Never serve that from
        -- cache; hand it straight through.
        if type(path) ~= 'string' or select('#', ...) > 0 then
            return original(path, ...)
        end

        -- include_user lowercases before its own lookup, so match that or the
        -- same module under two spellings would be loaded twice.
        local key = path:lower()

        local hit = cache[key]
        if hit ~= nil then
            stats.hits = stats.hits + 1
            if hit == CACHED_NIL then
                return nil
            end
            return hit
        end

        -- //gs c trace names each module read from disk (trace_hooks.lua)
        local on_miss = rawget(_G, '__require_miss_hook')
        if on_miss then on_miss(path) end

        local prefix = char_prefix()
        local result
        if prefix and key:sub(1, #prefix) == prefix then
            result = load_char_file(original, path)
        else
            result = original(path)
        end
        stats.loads = stats.loads + 1
        cache[key] = (result == nil) and CACHED_NIL or result
        return result
    end

    -- this file was loaded by the uncached require: the next require of it is a hit, not a second copy
    ModuleCache.remember('shared/utils/core/module_cache', ModuleCache)
    return true
end

--- Record a module loaded before the cache was installed, so its next require is a hit.
--- @param path string require() name
--- @param module any What that require returned
function ModuleCache.remember(path, module)
    local cache = rawget(_G, '__require_cache')
    if cache and module ~= nil and cache[path:lower()] == nil then
        cache[path:lower()] = module
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.ModuleCache = ModuleCache

return ModuleCache

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
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-09
---  ═══════════════════════════════════════════════════════════════════════════

local ModuleCache = {}

-- Lets a module that legitimately returns nil be remembered as loaded, instead
-- of being re-run forever because "no value" reads the same as "not cached".
local CACHED_NIL = {}

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

        local result = original(path)
        stats.loads = stats.loads + 1
        cache[key] = (result == nil) and CACHED_NIL or result
        return result
    end

    return true
end

--- How the cache is doing, for //gs c syscheck and friends.
--- @return number hits, number loads, number cached_modules
function ModuleCache.stats()
    local stats = rawget(_G, '__require_cache_stats') or { hits = 0, loads = 0 }
    local cache = rawget(_G, '__require_cache') or {}
    local n = 0
    for _ in pairs(cache) do n = n + 1 end
    return stats.hits, stats.loads, n
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.ModuleCache = ModuleCache

return ModuleCache

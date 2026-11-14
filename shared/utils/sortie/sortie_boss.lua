---============================================================================
--- Sortie Boss - is the boss around the one this command is for?
---============================================================================
--- //gs c sortie <target> is refused when it would run on the wrong boss
--- (2026-11-13: `aminon fight` pressed on Triboulex walked Kaories off and threw
--- Bolster away there):
---   a target load (prep or profile): refused while ANOTHER known boss is in
---     combat around and this target's own boss is not (a prep pressed before
---     the pull, nobody fighting yet, still goes);
---   `<target> fight`: refused unless this target's own boss is around, alive.
--- The boss of a command: SORTIE_CONFIG `bosses[typed name]`, else
--- `bosses[target key]`, else the target's `mob`. No boss known: no check.
--- Anything unreadable (no mob array) lets the command go: never blocked by a
--- failed check.
---
--- @file    shared/utils/sortie/sortie_boss.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-14
---============================================================================

local SortieBoss = {}

--- Yalms around this character a boss is looked for (squared, as mob.distance).
local RANGE_SQ = 50 * 50

local function around(mob)
    return mob and mob.valid_target ~= false and (mob.hpp or 0) > 0 and (mob.distance or math.huge) <= RANGE_SQ
end

--- The living monsters around, by name: {name = {fought = bool}}.
--- @return table|nil nil when the game cannot be read
local function scan()
    local ok, mobs = pcall(function() return windower.ffxi.get_mob_array() end)
    if not (ok and type(mobs) == 'table') then return nil end
    local seen = {}
    for _, mob in pairs(mobs) do
        if type(mob) == 'table' and mob.spawn_type == 16 and mob.name and around(mob) then   -- 16: a monster
            local entry = seen[mob.name] or {fought = false}
            entry.fought = entry.fought or (mob.claim_id or 0) ~= 0
            seen[mob.name] = entry
        end
    end
    return seen
end

--- The boss this command is for.
--- @param cfg table Sortie config
--- @param name string Target as typed
--- @param key string Target key (after aliases)
--- @param target table cfg.targets[key]
--- @return string|nil
function SortieBoss.boss_of(cfg, name, key, target)
    local bosses = cfg.bosses or {}
    return bosses[name] or bosses[key] or target.mob
end

--- Why this command must not go, nil when it may.
--- @param cfg table Sortie config
--- @param name string Target as typed
--- @param key string Target key
--- @param target table cfg.targets[key]
--- @param phase string|nil 'fight', or nil for a load
--- @return string|nil Refusal shown to the player
function SortieBoss.refusal(cfg, name, key, target, phase)
    local own = SortieBoss.boss_of(cfg, name, key, target)
    if not own then return nil end
    local seen = scan()
    if not seen then return nil end
    if phase == 'fight' then
        if seen[own] then return nil end
        return ('%s is not here: %s fight not started'):format(own, name)
    end
    if seen[own] and seen[own].fought then return nil end
    for _, boss in pairs(cfg.bosses or {}) do
        if boss ~= own and seen[boss] and seen[boss].fought then
            return ('%s is being fought, not %s: %s not loaded'):format(boss, own, name)
        end
    end
    return nil
end

_G.SortieBoss = SortieBoss
return SortieBoss

---============================================================================
--- Game Facts - what the game already knows about the character
---============================================================================
--- A TP config used to ask the player for things the game holds: merit
--- levels, job point gifts, a piece owned. A setting left on 'auto' reads
--- them here (<job>/combat/<JOB>_TP_CONFIG.lua: savagery_merits,
--- has_agoge_mask, fencer_jp_gifts); a number or true/false typed by the
--- player still wins.
---
--- Every answer is nil when the game cannot tell (outside the game, before
--- the character is known): the caller picks its own fallback.
---
--- @file    shared/utils/weaponskill/game_facts.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11
---============================================================================

local GameFacts = {}

-- Fencer's TP Bonus from job point gifts: {job points spent, TP Bonus added}.
-- BG-Wiki, the Gifts tables of the Warrior and Beastmaster pages, read 2026-10-11
-- (230 in all for both, as the Fencer page says).
local FENCER_GIFTS = {
    WAR = {{80, 50}, {405, 50}, {980, 60}, {1805, 70}},
    BST = {{150, 50}, {500, 50}, {1125, 60}, {2000, 70}},
}

-- the bags are not read again on every weaponskill
local OWNS_TTL = 60
local owns_cache = {}

local function game_player()
    local info = windower.ffxi.get_player and windower.ffxi.get_player()
    return type(info) == 'table' and info or nil
end

--- A merit's level, by the game's own key ('savagery').
--- @param key string
--- @return number|nil
function GameFacts.merit(key)
    local info = game_player()
    local merits = info and type(info.merits) == 'table' and info.merits or nil
    return merits and tonumber(merits[key]) or nil
end

--- Job points spent on a job.
--- @param job string Three letters ('WAR')
--- @return number|nil
function GameFacts.jp_spent(job)
    local info = game_player()
    local points = info and type(info.job_points) == 'table' and info.job_points[job:lower()] or nil
    return type(points) == 'table' and tonumber(points.jp_spent) or nil
end

--- The TP Bonus the job's gifts add to Fencer.
--- @param job string 'WAR' or 'BST'
--- @return number|nil Nil when the job has no such gift or the points cannot be read
function GameFacts.fencer_gift_tp(job)
    local steps, spent = FENCER_GIFTS[job], GameFacts.jp_spent(job)
    if not (steps and spent) then return nil end
    local total = 0
    for _, step in ipairs(steps) do
        if spent >= step[1] then total = total + step[2] end
    end
    return total
end

local function bag_holds(bag, items, prefix)
    if type(bag) ~= 'table' then return false end
    for _, entry in pairs(bag) do
        local info = type(entry) == 'table' and entry.id and entry.id > 0 and items[entry.id]
        if info and info.en and info.en:sub(1, #prefix) == prefix then return true end
    end
    return false
end

--- Whether a bag holds an item whose name starts with `prefix`
--- ('Agoge Mask' finds every version of it).
--- @param prefix string
--- @return boolean|nil
function GameFacts.owns(prefix)
    local cached = owns_cache[prefix]
    if cached and os.clock() - cached.at < OWNS_TTL then return cached.found end
    local ok, res = pcall(require, 'resources')
    local bags = windower.ffxi.get_items and windower.ffxi.get_items()
    if not (ok and res and res.items and type(bags) == 'table') then return nil end
    local found = false
    for _, bag in pairs(bags) do
        found = found or bag_holds(bag, res.items, prefix)
    end
    owns_cache[prefix] = {at = os.clock(), found = found}
    return found
end

return GameFacts

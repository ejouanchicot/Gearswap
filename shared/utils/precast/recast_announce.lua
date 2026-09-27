---============================================================================
--- Recast Announce - a party message when an action is refused on recast
---============================================================================
--- CooldownChecker cancels an ability or spell still on recast and shows the
--- time left in this character's chat. A character can also tell the party,
--- per action, in its config/RECAST_CONFIG.lua:
---
---   RECAST_CONFIG.party_announce = {
---       ['Phantom Roll'] = true,                          -- default text
---       ['Provoke'] = 'Provoke in <recast=Provoke>',     -- own text
---   }
---   RECAST_CONFIG.party_announce_every = 1               -- anti-spam, seconds
---
--- The key is the ability or spell name, or the name of a recast several
--- abilities share (every roll is on the "Phantom Roll" recast). The text is
--- sent with /p; the game itself replaces <recast=Name> with the time left,
--- and {action} becomes the action tried ("Bolter's Roll"):
---   ['Phantom Roll'] = '{action} : roll ready in <recast=Phantom Roll>',
--- true sends "<key> ready in <recast=<key>>". Nothing is sent for a key not
--- listed, or again for the same key within party_announce_every seconds.
---
--- @file    shared/utils/precast/recast_announce.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

local RecastAnnounce = {}

local DEFAULT_EVERY = 1

local function config()
    return rawget(_G, 'RECAST_CONFIG') or {}
end

--- Name of an ability recast shared by several abilities ("Phantom Roll").
--- @param recast_id number|nil
--- @return string|nil
local function recast_name(recast_id)
    if not recast_id then return nil end
    local gs = rawget(_G, 'gearswap')
    local resources = rawget(_G, 'res') or (gs and gs.res)
    local ok, entry = pcall(function() return resources.ability_recasts[recast_id] end)
    return ok and entry and entry.en or nil
end

--- The configured key and text for this action, or nil.
--- @param spell table
--- @param recast_id number|nil Ability recast id (nil for a spell)
--- @return string|nil key, string|nil text
local function entry_for(spell, recast_id)
    local list = config().party_announce
    if type(list) ~= 'table' then return nil end
    local keys = {spell.english, spell.name, recast_name(recast_id)}
    for i = 1, 3 do
        local key = keys[i]
        local value = key and list[key]
        if value == true then
            return key, ('%s ready in <recast=%s>'):format(key, key)
        elseif type(value) == 'string' and value ~= '' then
            return key, value
        end
    end
    return nil
end

--- Tell the party this action is on recast, if the character asked for it.
--- Called by CooldownChecker when it cancels the action.
--- @param spell table
--- @param recast_id number|nil Ability recast id (nil for a spell)
function RecastAnnounce.on_refused(spell, recast_id)
    local key, text = entry_for(spell, recast_id)
    if not key then return end
    local every = tonumber(config().party_announce_every) or DEFAULT_EVERY
    local last = windower._recast_announce_last or {}
    windower._recast_announce_last = last
    if last[key] and os.clock() - last[key] < every then return end
    last[key] = os.clock()
    local action = spell.english or spell.name or key
    send_command('input /p ' .. text:gsub('{action}', function() return action end))
end

return RecastAnnounce

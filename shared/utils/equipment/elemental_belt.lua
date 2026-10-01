---============================================================================
--- Elemental Belt - Hachirin-no-Obi or Orpheus's Sash, picked on its own
---============================================================================
--- Both belts raise elemental damage and share the waist, so one is chosen
--- per action (ElementalBonus computes what each adds):
---   Orpheus's Sash   by distance: +15 up to 1.93 yalms, +1 from 13 yalms;
---   Hachirin-no-Obi  by day and weather: +10 day, +10 / +25 weather (SCH
---                    storms included), added up, and the same as a penalty
---                    on the opposing element.
--- The best one goes on when its bonus reaches min_bonus (5 by default);
--- below that, the set's own belt stays. Only a belt this character has in
--- its inventory or wardrobes is considered.
---
--- Which actions: weaponskills of WEAPONSKILLS and Quick Draw at the end of
--- the precast (the precast of a spell is its Fast Cast set, left alone);
--- damaging spells at the end of the midcast: Elemental Magic but the damage
--- over time ones, Banish / Holy, elemental ninjutsu, Blue Magic of a
--- Magical category. Installed on Mote's cleanup_precast / cleanup_midcast,
--- so every job has it without a line in its own files.
---
--- Settings (optional file <Character>/_common/combat/ELEMENTAL_BELT.lua):
---   return { enabled = true, min_bonus = 5 }
--- //gs c belt shows the state, the belts found and today's bonuses.
---
--- @file    shared/utils/equipment/elemental_belt.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

local ElementalBelt = {}

local OBI = 'Hachirin-no-Obi'
local ORPHEUS = "Orpheus's Sash"
local DEFAULTS = {enabled = true, min_bonus = 5}
local EQUIP_BAGS = {0, 8, 10, 11, 12, 13, 14, 15, 16}
local OWNED_REFRESH = 60   -- seconds before the bags are read again

--- Magical and hybrid weaponskills (the elemental part benefits)
local WEAPONSKILLS = {
    ['Gust Slash'] = true, ['Cyclone'] = true, ['Aeolian Edge'] = true,
    ['Burning Blade'] = true, ['Red Lotus Blade'] = true, ['Shining Blade'] = true,
    ['Seraph Blade'] = true, ['Sanguine Blade'] = true,
    ['Frostbite'] = true, ['Freezebite'] = true, ['Herculean Slash'] = true,
    ['Cloudsplitter'] = true, ['Primal Rend'] = true,
    ['Shadow of Death'] = true, ['Dark Harvest'] = true, ['Infernal Scythe'] = true,
    ['Thunder Thrust'] = true, ['Raiden Thrust'] = true,
    ['Blade: Teki'] = true, ['Blade: To'] = true, ['Blade: Chi'] = true,
    ['Blade: Ei'] = true, ['Blade: Yu'] = true,
    ['Tachi: Goten'] = true, ['Tachi: Kagero'] = true, ['Tachi: Jinpu'] = true,
    ['Tachi: Koki'] = true,
    ['Shining Strike'] = true, ['Seraph Strike'] = true, ['Flash Nova'] = true,
    ['Rock Crusher'] = true, ['Earth Crusher'] = true, ['Starburst'] = true,
    ['Sunburst'] = true, ['Cataclysm'] = true, ['Vidohunir'] = true,
    ['Garland of Bliss'] = true, ['Omniscience'] = true,
    ['Flaming Arrow'] = true, ['Trueflight'] = true,
    ['Hot Shot'] = true, ['Wildfire'] = true, ['Leaden Salute'] = true,
}

--- Elemental Magic that deals damage over time, not a hit: no belt
local DOTS = {Burn = true, Frost = true, Choke = true, Rasp = true, Shock = true, Drown = true}

--- Quick Draw that deals no damage
local NO_DAMAGE_SHOTS = {['Light Shot'] = true, ['Dark Shot'] = true}

---============================================================================
--- SETTINGS AND BELTS OWNED
---============================================================================

--- The character's settings, read once per load.
function ElementalBelt.settings()
    local cached = rawget(_G, '_elemental_belt_settings')
    if cached then return cached end
    local settings = {enabled = DEFAULTS.enabled, min_bonus = DEFAULTS.min_bonus}
    local path = player and player.name and require('shared/utils/core/char_paths').file('common', 'ELEMENTAL_BELT.lua')
    local file = path and io.open(path, 'r')
    if file then
        file:close()
        local ok, loaded = pcall(dofile, path)
        if ok and type(loaded) == 'table' then
            if loaded.enabled ~= nil then settings.enabled = loaded.enabled == true end
            settings.min_bonus = tonumber(loaded.min_bonus) or settings.min_bonus
        end
    end
    _G._elemental_belt_settings = settings
    return settings
end

--- {[OBI] = bool, [ORPHEUS] = bool}: what the equippable bags hold (cached).
function ElementalBelt.owned()
    local cache = rawget(_G, '_elemental_belt_owned')
    if cache and os.clock() - cache.at < OWNED_REFRESH then return cache.found end
    local gs = rawget(_G, 'gearswap')
    local resources = rawget(_G, 'res') or (gs and gs.res)
    local items = resources and resources.items
    local found = {}
    for _, bag in ipairs(items and EQUIP_BAGS or {}) do
        local ok, content = pcall(windower.ffxi.get_items, bag)
        for _, item in ipairs(ok and type(content) == 'table' and content or {}) do
            local data = type(item) == 'table' and item.id and item.id > 0 and items[item.id]
            if data and (data.en == OBI or data.en == ORPHEUS) then found[data.en] = true end
        end
    end
    _G._elemental_belt_owned = {at = os.clock(), found = found}
    return found
end

---============================================================================
--- DECISION
---============================================================================

--- Whether an action deals elemental damage a belt raises.
--- @param spell table
--- @param phase string 'precast' or 'midcast'
--- @return boolean
function ElementalBelt.applies(spell, phase)
    if not (spell and spell.element) then return false end
    if phase == 'precast' then
        if spell.type == 'WeaponSkill' then return WEAPONSKILLS[spell.english] == true end
        return spell.type == 'CorsairShot' and not NO_DAMAGE_SHOTS[spell.english]
    end
    local name, skill = spell.english or '', spell.skill
    if skill == 'Elemental Magic' then return not DOTS[name] end
    if skill == 'Divine Magic' then return name:find('^Banish') ~= nil or name:find('^Holy') ~= nil end
    if skill == 'Ninjutsu' then
        return name:find('^%a+ton: ') ~= nil and (name:find(': Ichi$') or name:find(': Ni$') or name:find(': San$')) ~= nil
    end
    if skill == 'Blue Magic' then
        local ok, SpellMap = pcall(require, 'shared/jobs/blu/functions/logic/spell_map')
        local category = ok and SpellMap and SpellMap.category(name)
        return type(category) == 'string' and category:find('^Magical') ~= nil
    end
    return false
end

--- The belt to wear for this action and its bonus, or nil.
--- @param spell table
--- @return string|nil belt, number|nil bonus, number obi, number orpheus
function ElementalBelt.choose(spell)
    local Bonus = require('shared/utils/equipment/elemental_bonus')
    local obi, orpheus = Bonus.for_action(spell)
    local owned, min_bonus = ElementalBelt.owned(), ElementalBelt.settings().min_bonus
    local best, value = nil, 0
    if owned[OBI] and obi >= min_bonus then best, value = OBI, obi end
    if owned[ORPHEUS] and orpheus >= min_bonus and orpheus > value then best, value = ORPHEUS, orpheus end
    return best, best and value or nil, obi, orpheus
end

--- Put the chosen belt on over the set Mote and the job laid.
--- @param spell table
--- @param phase string 'precast' or 'midcast'
--- @param eventArgs table|nil Mote event args (nothing when cancelled)
function ElementalBelt.apply(spell, phase, eventArgs)
    if eventArgs and eventArgs.cancel then return end
    if not ElementalBelt.settings().enabled then return end
    if not ElementalBelt.applies(spell, phase) then return end
    local belt, bonus, obi, orpheus = ElementalBelt.choose(spell)
    if belt then equip({waist = belt}) end
    local ok, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok and Trace then
        Trace.log('BELT', '%s (%s): obi %+d, orpheus %+d -> %s', spell.english, tostring(spell.element),
            obi, orpheus, belt and ('%s +%d'):format(belt, bonus) or 'set belt kept')
    end
end

local ELEMENTS = {'Fire', 'Ice', 'Wind', 'Earth', 'Lightning', 'Water', 'Light', 'Dark'}

--- //gs c belt: state, belts found, day / weather and each element's bonus.
--- @return boolean true (command handled)
function ElementalBelt.show_status()
    local Bonus = require('shared/utils/equipment/elemental_bonus')
    local settings, owned = ElementalBelt.settings(), ElementalBelt.owned()
    _G._elemental_belt_owned = nil  -- read the bags again on the next action
    local obi_line = {}
    for _, element in ipairs(ELEMENTS) do
        local value = Bonus.obi(element)
        if value ~= 0 then obi_line[#obi_line + 1] = ('%s %+d'):format(element, value) end
    end
    local target = windower.ffxi.get_mob_by_target('t')
    local distance = target and target.distance and math.sqrt(target.distance)
    local weather = world and world.weather_element
        and ('%s (%s)'):format(world.weather_element, (world.weather_intensity or 0) >= 2 and 'double' or 'single')
    local fields = {
        {'Auto belt', settings.enabled and 'ON' or 'OFF', settings.enabled and 'good' or 'bad'},
        {'Minimum bonus', ('%d %%'):format(settings.min_bonus)},
        {'Hachirin-no-Obi', owned[OBI] and 'found' or 'not in inventory / wardrobes', owned[OBI] and 'good' or 'warn'},
        {"Orpheus's Sash", owned[ORPHEUS] and 'found' or 'not in inventory / wardrobes', owned[ORPHEUS] and 'good' or 'warn'},
        {'Day / weather', ('%s / %s'):format(tostring(world and world.day_element), weather or 'none')},
        {'Obi now', #obi_line > 0 and table.concat(obi_line, ', ') or 'nothing (no day / weather match)'},
        {'Orpheus now', distance and ('%+d at %.1f y (target)'):format(Bonus.orpheus(distance), distance) or 'no target'},
    }
    require('shared/utils/messages/info_block').show({tag = 'BELT', title = 'Obi / Orpheus', fields = fields})
    return true
end

--- Wrap Mote's cleanup_precast / cleanup_midcast once per sandbox.
function ElementalBelt.install()
    if rawget(_G, '_elemental_belt_installed') then return end
    local pre, mid = rawget(_G, 'cleanup_precast'), rawget(_G, 'cleanup_midcast')
    if type(pre) ~= 'function' or type(mid) ~= 'function' then return end
    _G._elemental_belt_installed = true
    _G.cleanup_precast = function(spell, spellMap, eventArgs)
        pcall(ElementalBelt.apply, spell, 'precast', eventArgs)
        return pre(spell, spellMap, eventArgs)
    end
    _G.cleanup_midcast = function(spell, spellMap, eventArgs)
        pcall(ElementalBelt.apply, spell, 'midcast', eventArgs)
        return mid(spell, spellMap, eventArgs)
    end
end

return ElementalBelt

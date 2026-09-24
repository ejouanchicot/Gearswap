---============================================================================
--- Custom Conditions - the `when = {...}` tests of <JOB>_CUSTOM.lua
---============================================================================
--- Every key listed in a `when` must hold for the gear to go on (AND).
--- A key given a list holds when any item of the list matches (OR).
---
---   buff / no_buff         buff active / none of them active (name or id)
---   weapon / sub / range / ammo
---                          item in that slot, the one being equipped by
---                          this very action first; `weapon` also matches
---                          the job's weapon choice (state MainWeapon)
---   subjob / no_subjob     current subjob
---   mode = {HybridMode = 'PDT'}   a state's current value (list = any)
---   hp_below / hp_above / mp_below / mp_above   percent
---   tp_below / tp_above    TP
---   spell                  action name; 'Cure*' = starts with "Cure"
---   skill                  'Enfeebling Magic', 'Singing', ...
---   spell_type             'WhiteMagic', 'BardSong', 'WeaponSkill', 'JobAbility', ...
---   element                spell element ('Fire', ...)
---   day_weather = true     spell element matches the day or the weather
---   target                 'self', 'other' (another player), 'enemy'
---   distance_below         yalms to the action's target
---   town / moving / pet    true or false
---   zone                   zone name
---
--- Spell keys never hold at idle/engaged (no action then).
---
--- @file    shared/utils/custom/custom_conditions.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-24
---============================================================================

local Conditions = {}

--- GearSwap slot name -> slot id (statics.lua:148-176), aliases included.
Conditions.SLOT_IDS = {
    main = 0, sub = 1, range = 2, ranged = 2, ammo = 3, head = 4, body = 5, hands = 6,
    legs = 7, feet = 8, neck = 9, waist = 10, ear1 = 11, ear2 = 12, left_ear = 11,
    right_ear = 12, learring = 11, rearring = 12, lear = 11, rear = 12, left_ring = 13,
    right_ring = 14, lring = 13, rring = 14, ring1 = 13, ring2 = 14, back = 15,
}

---============================================================================
--- HELPERS
---============================================================================

local function as_list(v)
    return type(v) == 'table' and v or {v}
end

local function lower(v)
    return tostring(v):lower()
end

--- Name of an item as a set holds it (string or {name = ...}).
local function item_name(item)
    if type(item) == 'table' then return item.name end
    return item
end

--- `text` equals `pattern`, case-insensitive; a trailing * matches a prefix.
local function name_matches(text, pattern)
    if not text then return false end
    local t, p = lower(text), lower(pattern)
    if p:sub(-1) == '*' then
        return t:sub(1, #p - 1) == p:sub(1, -2)
    end
    return t == p
end

local function any_matches(text, patterns)
    for _, p in ipairs(as_list(patterns)) do
        if name_matches(text, p) then return true end
    end
    return false
end

local function buff_active(buff)
    return buffactive ~= nil and buffactive[type(buff) == 'string' and buff:lower() or buff] ~= nil
end

--- Item in a slot: queued by this action first, then worn.
local function slot_item(slot)
    local queued = gearswap and gearswap.equip_list and gearswap.equip_list[slot]
    if queued then return item_name(queued) end
    return player and player.equipment and player.equipment[slot]
end

local function in_town()
    local ok, Base = pcall(require, 'shared/utils/set_building/base_set_builder')
    return ok and type(Base) == 'table' and Base.is_in_town and Base.is_in_town() or false
end

local function is_moving()
    return state and state.Moving and tostring(state.Moving.value) == 'true' or false
end

---============================================================================
--- TESTS (key -> function(expected, spell) -> boolean)
---============================================================================

local TESTS = {}

function TESTS.buff(v)
    for _, b in ipairs(as_list(v)) do if buff_active(b) then return true end end
    return false
end
function TESTS.no_buff(v) return not TESTS.buff(v) end

function TESTS.weapon(v)
    if any_matches(slot_item('main'), v) then return true end
    return state and state.MainWeapon and any_matches(state.MainWeapon.current, v) or false
end
function TESTS.sub(v) return any_matches(slot_item('sub'), v) end
function TESTS.range(v) return any_matches(slot_item('range'), v) end
function TESTS.ammo(v) return any_matches(slot_item('ammo'), v) end

function TESTS.subjob(v) return player ~= nil and any_matches(player.sub_job, v) end
function TESTS.no_subjob(v) return not TESTS.subjob(v) end

function TESTS.mode(v)
    for name, wanted in pairs(v) do
        local m = state and state[name]
        if not m or not any_matches(m.current, wanted) then return false end
    end
    return true
end

function TESTS.hp_below(v) return player ~= nil and (player.hpp or 100) < v end
function TESTS.hp_above(v) return player ~= nil and (player.hpp or 0) > v end
function TESTS.mp_below(v) return player ~= nil and (player.mpp or 100) < v end
function TESTS.mp_above(v) return player ~= nil and (player.mpp or 0) > v end
function TESTS.tp_below(v) return player ~= nil and (player.tp or 0) < v end
function TESTS.tp_above(v) return player ~= nil and (player.tp or 0) > v end

function TESTS.spell(v, spell) return spell ~= nil and any_matches(spell.english, v) end
function TESTS.skill(v, spell) return spell ~= nil and any_matches(spell.skill, v) end
function TESTS.spell_type(v, spell) return spell ~= nil and any_matches(spell.type, v) end
function TESTS.element(v, spell) return spell ~= nil and any_matches(spell.element, v) end

function TESTS.day_weather(v, spell)
    if not spell or not spell.element or not world then return false end
    local e = spell.element
    local hit = world.day_element == e
        or (world.weather_element == e and (world.weather_intensity or 1) > 0)
    return hit == (v == true)
end

function TESTS.target(v, spell)
    local t = spell and spell.target
    if not t then return false end
    local kind = (t.type == 'SELF') and 'self' or (t.type == 'MONSTER' and 'enemy')
        or ((t.type == 'PLAYER' or t.type == 'NPC') and 'other') or lower(t.type)
    return any_matches(kind, v)
end

function TESTS.distance_below(v, spell)
    local t = spell and spell.target
    return t ~= nil and t.distance ~= nil and t.distance < v
end

function TESTS.town(v) return in_town() == (v == true) end
function TESTS.moving(v) return is_moving() == (v == true) end
function TESTS.pet(v) return ((pet ~= nil and pet.isvalid) == true) == (v == true) end
function TESTS.zone(v) return world ~= nil and any_matches(world.area, v) end

Conditions.KEYS = TESTS

---============================================================================
--- PUBLIC API
---============================================================================

--- Whether every test of `when` holds.
--- @param when table|nil Condition table (nil = always)
--- @param spell table|nil The action, when there is one
--- @return boolean
function Conditions.holds(when, spell)
    if when == nil then return true end
    for key, expected in pairs(when) do
        local test = TESTS[key]
        if not test then return false end
        local ok, result = pcall(test, expected, spell)
        if not ok or not result then return false end
    end
    return true
end

--- Buff names/ids a `when` watches (lower-cased names), added to `into`.
--- @param when table|nil
--- @param into table Set, filled in
function Conditions.collect_buffs(when, into)
    if type(when) ~= 'table' then return end
    for _, key in ipairs({'buff', 'no_buff'}) do
        if when[key] ~= nil then
            for _, b in ipairs(as_list(when[key])) do
                into[type(b) == 'string' and b:lower() or b] = true
            end
        end
    end
end

return Conditions

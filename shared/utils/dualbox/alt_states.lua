---============================================================================
--- Alt States - job, subjob and weapon of every other box of the group
---============================================================================
--- _G.AltJobState holds one box, the tracked partner of DUALBOX_CONFIG.lua.
--- A main with several alts also needs to know what each of them plays, and
--- with which weapon type: a key can depend on it (keybind entries with an
--- `alt` condition, see keybind_manager.lua). Every altjobupdate is recorded
--- here by sender name, whoever sent it.
---
--- The weapon travels as its skill name without spaces ("Sword", "Dagger",
--- "GreatKatana", "None"): a console argument cannot hold a space. Conditions
--- are compared without spaces or case, so 'Great Katana' matches too.
---
--- Sending side: watch_weapon() listens for the main hand changing (packet
--- 0x050) and reports it, so the main learns of a weapon swap without a job
--- change. The same listener serves this character's own keys: a keybind
--- entry with a `weapon` field (keybind_manager.lua) is refreshed through
--- on_weapon_change() when the main hand changes weapon type.
---
--- @file shared/utils/dualbox/alt_states.lua
--- @author Tetsouo
--- @version 1.1
--- @date Created: 2026-09-25 | Updated: 2026-09-26 (own weapon listeners)
---============================================================================

local AltStates = {}

local EQUIP_PACKET = 0x050
local MAIN_SLOT = 0
local WEAPON_SETTLE_DELAY = 0.5

--- Lower case, spaces removed: 'Great Katana' and 'GreatKatana' are one value.
--- @param value any
--- @return string|nil
local function normalize(value)
    if type(value) ~= 'string' then return nil end
    return (value:gsub('%s', '')):lower()
end

--- True when `rule` (string or list) names `value`.
--- @param rule string|table
--- @param value string|nil
--- @return boolean
local function names(rule, value)
    local wanted = normalize(value)
    if not wanted then return false end
    if type(rule) == 'table' then
        for _, entry in ipairs(rule) do
            if normalize(entry) == wanted then return true end
        end
        return false
    end
    return normalize(rule) == wanted
end

local function states()
    _G.AltStates = _G.AltStates or {}
    return _G.AltStates
end

---============================================================================
--- SENDING SIDE
---============================================================================

--- Skill name of the weapon in this character's main hand, spaces removed.
--- @return string "Sword", "GreatKatana"... or "None"
function AltStates.weapon_skill()
    local items = windower.ffxi.get_items()
    local equipment = items and items.equipment
    if not equipment or not equipment.main or equipment.main == 0 then return 'None' end
    local item = windower.ffxi.get_items(equipment.main_bag, equipment.main)
    local ok, res = pcall(require, 'resources')
    local info = ok and res and item and item.id and res.items[item.id]
    local skill = info and info.skill and res.skills[info.skill]
    if not skill or not skill.en then return 'None' end
    return (skill.en:gsub('%s', ''))
end

--- The listeners and the one packet hook of this load. Kept on the sandbox
--- _G, not in this module: user_setup can require the module before the
--- module cache exists, and two copies must still share one hook.
--- @return table {listeners = {key -> function}, registered = boolean}
local function weapon_watch()
    local watch = rawget(_G, '_own_weapon_watch')
    if not watch then
        watch = {listeners = {}, registered = false}
        _G._own_weapon_watch = watch
    end
    return watch
end

--- Call every listener, each under pcall: one failing never stops the others.
local function notify(watch)
    for _, listener in pairs(watch.listeners) do
        pcall(listener)
    end
end

--- Call `listener` when this character's main hand changes weapon type.
--- One packet hook per load (the sandbox drops it on the next load); a
--- second call with the same key replaces that listener.
--- @param key string Who listens ('dualbox', 'keybinds')
--- @param listener function Called with no argument
function AltStates.on_weapon_change(key, listener)
    local watch = weapon_watch()
    watch.listeners[key] = listener
    if watch.registered or not windower.raw_register_event then return end
    watch.registered = true
    watch.last = AltStates.weapon_skill()
    local pending = 0
    windower.raw_register_event('incoming chunk', function(id, original)
        if id ~= EQUIP_PACKET or original:byte(6) ~= MAIN_SLOT then return end
        pending = pending + 1
        local mine = pending
        -- The item list lags the packet: read it once the swap has settled
        coroutine.schedule(function()
            if mine ~= pending then return end
            local now = AltStates.weapon_skill()
            if now ~= watch.last then
                watch.last = now
                notify(watch)
            end
        end, WEAPON_SETTLE_DELAY)
    end)
end

--- Call `report` when the main hand changes weapon type (dual-box report).
--- @param report function Called with no argument
function AltStates.watch_weapon(report)
    AltStates.on_weapon_change('dualbox', report)
end

--- Whether a keybind `weapon` rule (string or list) names a weapon skill.
--- Compared without spaces or case: 'Great Katana' matches "GreatKatana".
--- @param rule string|table
--- @param skill string|nil Skill to test; nil = this character's main hand now
--- @return boolean
function AltStates.own_weapon_matches(rule, skill)
    return names(rule, skill or AltStates.weapon_skill())
end

---============================================================================
--- RECEIVING SIDE
---============================================================================

--- Store what `sender` reported. A change of job, subjob or weapon refreshes
--- the keys that depend on it.
--- @param sender string
--- @param job string
--- @param subjob string
--- @param weapon string|nil Nil from a box that does not send it
function AltStates.record(sender, job, subjob, weapon)
    if type(sender) ~= 'string' or sender == '' then return end
    local key = sender:lower()
    local previous = states()[key]
    states()[key] = {name = sender, job = job, subjob = subjob, weapon = weapon, last_update = os.time()}
    if previous and previous.job == job and previous.subjob == subjob and previous.weapon == weapon then
        return
    end
    local ok, KeybindManager = pcall(require, 'shared/utils/keybinds/keybind_manager')
    if ok and KeybindManager and KeybindManager.refresh_active then
        pcall(KeybindManager.refresh_active)
    end
end

--- What a box last reported.
--- @param name string|nil Box name; nil = the tracked partner (_G.AltJobState)
--- @return table|nil {name, job, subjob, weapon, last_update}
function AltStates.get(name)
    if name == nil then return _G.AltJobState end
    return states()[name:lower()]
end

--- Whether a keybind `alt` condition holds. Every field is optional and takes
--- a string or a list: {name = 'Blodykiller', job = 'BRD', subjob = {'WHM', 'RDM'},
--- weapon = 'Dagger'}. Nothing known about that box yet = false.
--- @param condition table
--- @return boolean
function AltStates.matches(condition)
    local state = AltStates.get(condition.name)
    if not state or not state.job then return false end
    if condition.job and not names(condition.job, state.job) then return false end
    if condition.subjob and not names(condition.subjob, state.subjob) then return false end
    if condition.weapon and not names(condition.weapon, state.weapon) then return false end
    return true
end

return AltStates

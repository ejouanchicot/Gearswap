---============================================================================
--- Treasure Hunter - TreasureMode on every job, mob tagging
---============================================================================
--- The TH level a mob keeps is the gear worn when one of your actions lands
--- on it: one action "tags" it, then the normal gear can come back. Modes:
---   Off   nothing (the default on every job but THF)
---   Tag   sets.TreasureHunter until the target is tagged: on the engaged
---         set, and on an action against a mob not tagged yet (weaponskill,
---         job ability, spell, ranged attack)
---   Full  sets.TreasureHunter on the engaged set at all times, and on the
---         actions against a mob not tagged yet
---   SATA  THF only (its own STATES file): Tag + the SA/TA overlays, which
---         the THF set builder handles (shared/jobs/thf/.../treasure_hunter)
---
--- A mob is tagged by any action of yours that lists it as a target
--- (melee, ranged, weaponskill, spell, job ability); tags are forgotten when
--- the mob dies, on zoning, or after 3 minutes without any action from or on
--- it (a respawn under the same id is tagged again).
---
--- TreasureMode is an optional state (optional_state.lua): THF defines it in
--- its STATES file and shows it; any other job gets it Off, its HUD row and
--- key hidden until //gs c th show (saved in config/treasure_mode.lua). A job
--- without sets.TreasureHunter gets no TH gear whatever the mode.
---
--- Gear order: the engaged overlay wraps handle_equipping_gear after the
--- Dual Wield tiers, the action overlay wraps cleanup_precast /
--- cleanup_midcast after the Obi / Orpheus belt: TH wins over both (it is
--- worn once per mob), the player's CUSTOM gear still goes on last. THF
--- builds its engaged TH itself (SATA): _G._treasure_engaged_by_job is then
--- a function giving the job's SA/TA + TH layer, which the engaged wrapper
--- lays after the Dual Wield pieces instead of sets.TreasureHunter.
---
--- @file    shared/utils/equipment/treasure_hunter.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2026-09-19 (THF) | Shared: 2026-09-28
---============================================================================

local TreasureHunter = {}

local FORGET_AFTER = 180
local STATUS_ENGAGED = 1

-- 0x029 action messages: "<actor> defeats <target>", "<target> falls to the ground"
local DEATH_MESSAGES = {[6] = true, [20] = true}

-- Own action categories that hit a target: melee, ranged, weaponskill,
-- spell finished, job ability, unblinkable job ability, step / flourish
local TAGGING_CATEGORIES = {[1] = true, [2] = true, [3] = true, [4] = true, [6] = true, [14] = true, [15] = true}

TreasureHunter.optional = require('shared/utils/core/optional_state').create({
    id = 'treasure_mode', state = 'TreasureMode', description = 'Treasure Mode',
    values = {'Off', 'Tag', 'Full'}, file = 'treasure_mode.lua', default_key = '!numpad.',
})

---============================================================================
--- STATE
---============================================================================

--- Tag table and flags, on the sandbox so every copy of this module reads
--- the same one: {tagged = {[mob_id] = last_seen}, overlay_on = bool, listening = bool}.
local function data()
    if not rawget(_G, '_treasure') then
        _G._treasure = {tagged = {}, overlay_on = false, listening = false}
    end
    return _G._treasure
end

--- The mode when the job shows it and it is not Off, else nil.
--- @return string|nil 'Tag', 'Full' or 'SATA'
function TreasureHunter.mode()
    local value = TreasureHunter.optional.value()
    if value == nil or value == 'Off' then return nil end
    return value
end

local function current_target_id()
    local mob = windower.ffxi.get_mob_by_target('t')
    return mob and mob.id
end

--- Whether a mob is tagged.
--- @param id number|nil Mob id
function TreasureHunter.is_tagged(id)
    return id ~= nil and data().tagged[id] ~= nil
end

---============================================================================
--- GEAR
---============================================================================

--- Whether the engaged set should carry sets.TreasureHunter right now.
--- @return boolean
function TreasureHunter.wants_engaged_th()
    if not sets or not sets.TreasureHunter then return false end
    local current_mode = TreasureHunter.mode()
    if current_mode == 'Full' then return true end
    if current_mode == 'Tag' or current_mode == 'SATA' then
        local id = current_target_id()
        return id ~= nil and not TreasureHunter.is_tagged(id)
    end
    return false
end

--- Overlay sets.TreasureHunter on an engaged set when the mode asks for it.
--- @param result table Engaged set being built
--- @return table Engaged set, with TH gear when wanted
function TreasureHunter.apply_engaged(result)
    local on = TreasureHunter.wants_engaged_th()
    data().overlay_on = on
    if on then return set_combine(result, sets.TreasureHunter) end
    return result
end

--- Whether an action goes against a mob not tagged yet, with a TH mode on.
--- @param spell table
--- @param phase string 'precast' or 'midcast'
--- @return boolean
local function action_wants_th(spell, phase)
    if not (sets and sets.TreasureHunter and TreasureHunter.mode()) then return false end
    local target = spell and spell.target
    if not (target and target.type == 'MONSTER' and target.id) then return false end
    if TreasureHunter.is_tagged(target.id) then return false end
    if phase == 'precast' then
        return spell.type == 'WeaponSkill' or spell.action_type == 'Ability'
    end
    return spell.action_type == 'Magic' or spell.action_type == 'Ranged Attack'
end

---============================================================================
--- TAG TRACKING
---============================================================================

local function refresh_gear()
    -- The aftercast of the action in progress rebuilds the engaged set anyway.
    if midaction and midaction() then return end
    send_command('gs c update')
end

--- Tag the mobs one of our actions hit; drop TH once the current target is.
local function on_own_action(act, now)
    local d = data()
    local current = current_target_id()
    local tagged_current = false
    for _, target in ipairs(act.targets) do
        local mob = windower.ffxi.get_mob_by_id(target.id)
        if mob and mob.is_npc then
            if target.id == current and d.tagged[target.id] == nil then tagged_current = true end
            d.tagged[target.id] = now
        end
    end
    if tagged_current and d.overlay_on and TreasureHunter.mode() ~= 'Full' then refresh_gear() end
end

--- Keep tagged mobs alive while they act or are acted on.
local function touch_tagged(act, now)
    local tagged = data().tagged
    if tagged[act.actor_id] then
        tagged[act.actor_id] = now
        return
    end
    for _, target in ipairs(act.targets) do
        if tagged[target.id] then tagged[target.id] = now end
    end
end

local function forget_stale(now)
    local tagged = data().tagged
    for id, last_seen in pairs(tagged) do
        if now - last_seen > FORGET_AFTER then tagged[id] = nil end
    end
end

local function on_action(act)
    if not act or not act.targets or not TreasureHunter.mode() then return end
    local now = os.time()
    if player and act.actor_id == player.id then
        if TAGGING_CATEGORIES[act.category] then on_own_action(act, now) end
    else
        touch_tagged(act, now)
    end
    forget_stale(now)
end

local function on_incoming_chunk(id, original)
    if id ~= 0x029 then return end
    local tagged = data().tagged
    local target_id = original:unpack('I', 0x09)
    if tagged[target_id] and DEATH_MESSAGES[original:unpack('H', 0x19) % 32768] then
        tagged[target_id] = nil
    end
end

local function on_target_change()
    local p = windower.ffxi.get_player()
    if not p or p.status ~= STATUS_ENGAGED then return end
    if TreasureHunter.wants_engaged_th() ~= data().overlay_on then refresh_gear() end
end

local function on_zone_change()
    data().tagged = {}
end

---============================================================================
--- INSTALL
---============================================================================

--- Register the tag tracking events, once per load (raw events: a plain one
--- from a job file runs GearSwap's refresh on every packet).
function TreasureHunter.init()
    local d = data()
    if d.listening then return end
    d.listening = true
    windower.raw_register_event('action', function(act) pcall(on_action, act) end)
    windower.raw_register_event('incoming chunk', function(id, original) pcall(on_incoming_chunk, id, original) end)
    windower.raw_register_event('target change', function() pcall(on_target_change) end)
    windower.raw_register_event('zone change', function() pcall(on_zone_change) end)
end

--- Engaged overlay, laid after the Dual Wield pieces: the job's own layer
--- when it builds its engaged TH itself (THF: SA/TA + TH), else
--- sets.TreasureHunter when the mode wants it.
function TreasureHunter.lay_engaged()
    local by_job = rawget(_G, '_treasure_engaged_by_job')
    if type(by_job) == 'function' then
        local layer = by_job()
        if layer and next(layer) then equip(layer) end
        return
    end
    if by_job then return end
    local on = TreasureHunter.wants_engaged_th()
    data().overlay_on = on
    if on then equip(sets.TreasureHunter) end
end

--- Wrap handle_equipping_gear (engaged overlay) and cleanup_precast /
--- cleanup_midcast (action overlay), once per sandbox, and start tracking.
--- Called from INIT_SYSTEMS after the Dual Wield and Obi / Orpheus hooks.
function TreasureHunter.install()
    if rawget(_G, '_treasure_installed') then return end
    local gear, pre, mid = rawget(_G, 'handle_equipping_gear'), rawget(_G, 'cleanup_precast'), rawget(_G, 'cleanup_midcast')
    if type(gear) ~= 'function' or type(pre) ~= 'function' or type(mid) ~= 'function' then return end
    _G._treasure_installed = true
    TreasureHunter.init()
    _G.handle_equipping_gear = function(status, pet_status)
        local result = gear(status, pet_status)
        -- A COR roll holds the gear until it lands (gear_hold.lua)
        if (status or (player and player.status)) == 'Engaged'
           and not require('shared/utils/core/gear_hold').active() then
            pcall(TreasureHunter.lay_engaged)
        end
        return result
    end
    local function action_hook(orig, phase)
        return function(spell, spellMap, eventArgs)
            local result = orig(spell, spellMap, eventArgs)
            if not (eventArgs and eventArgs.cancel) and action_wants_th(spell, phase) then
                equip(sets.TreasureHunter)
            end
            return result
        end
    end
    _G.cleanup_precast = action_hook(pre, 'precast')
    _G.cleanup_midcast = action_hook(mid, 'midcast')
end

---============================================================================
--- STATUS
---============================================================================

--- Fields for //gs c th.
--- @return table InfoBlock fields
function TreasureHunter.status_fields()
    local count, current = 0, current_target_id()
    for _ in pairs(data().tagged) do count = count + 1 end
    return {
        {'Mode', TreasureHunter.mode() or 'Off'},
        {'sets.TreasureHunter', sets and sets.TreasureHunter and 'found' or 'none on this job',
            sets and sets.TreasureHunter and 'good' or 'warn'},
        {'Mobs tagged', tostring(count)},
        {'Current target', current and (TreasureHunter.is_tagged(current) and 'tagged' or 'not tagged') or 'none'},
    }
end

--- Forget every tag (//gs c th clear).
function TreasureHunter.clear()
    data().tagged = {}
end

return TreasureHunter

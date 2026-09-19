---  ═══════════════════════════════════════════════════════════════════════════
---   Treasure Hunter - TreasureMode gear and mob tagging (Logic Module)
---  ═══════════════════════════════════════════════════════════════════════════
---   Puts the TreasureHunter sets on the engaged set according to
---   state.TreasureMode, with the modes of Mote-TreasureHunter:
---     • Tag  - sets.TreasureHunter on the engaged set until one of our melee
---              rounds lands on the current target, then normal gear again.
---     • SATA - Tag, plus the SA/TA engaged overlay uses sets.TreasureHunterSA,
---              sets.TreasureHunterTA or sets.TreasureHunterSATA.
---     • Full - sets.TreasureHunter on the engaged set at all times, plus the
---              SATA overlay.
---
---   Unlike Mote-TreasureHunter it never locks slots: GearSwap keeps slot
---   locks across job files, so a lock still held at a reload would outlive
---   the job. TH is part of the engaged set instead, rebuilt on every
---   re-equip, and a `gs c update` is sent when the current target's tag
---   state changes.
---
---   Tagged mobs are kept per sandbox (lost on reload) and forgotten when they
---   die, on zoning, or after 3 minutes without any action from or on them, as
---   Mote-TreasureHunter does, so a mob that respawns under the same id is
---   tagged again.
---
---   @file    shared/jobs/thf/functions/logic/treasure_hunter.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-19
---  ═══════════════════════════════════════════════════════════════════════════

local TreasureHunter = {}

local FORGET_AFTER = 180

-- 0x029 action messages: "<actor> defeats <target>", "<target> falls to the ground"
local DEATH_MESSAGES = { [6] = true, [20] = true }

local CATEGORY_MELEE = 1
local STATUS_ENGAGED = 1

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE
---  ═══════════════════════════════════════════════════════════════════════════

--- Tag table and flags, on the sandbox so every loaded copy of this module
--- (hooks and event handlers) reads the same one.
--- @return table { tagged = {[mob_id] = last_seen}, overlay_on = bool, listening = bool }
local function data()
    if not _G.thf_treasure then
        _G.thf_treasure = { tagged = {}, overlay_on = false, listening = false }
    end
    return _G.thf_treasure
end

local function mode()
    return state and state.TreasureMode and state.TreasureMode.value
end

local function current_target_id()
    local mob = windower.ffxi.get_mob_by_target('t')
    return mob and mob.id
end

---  ═══════════════════════════════════════════════════════════════════════════
---   GEAR
---  ═══════════════════════════════════════════════════════════════════════════

--- Whether the engaged set should carry sets.TreasureHunter right now.
--- @return boolean
function TreasureHunter.wants_engaged_th()
    if not sets or not sets.TreasureHunter then
        return false
    end

    local current_mode = mode()
    if current_mode == 'Full' then
        return true
    end
    if current_mode == 'Tag' or current_mode == 'SATA' then
        local id = current_target_id()
        return id ~= nil and data().tagged[id] == nil
    end
    return false
end

--- Overlay sets.TreasureHunter on an engaged set when the mode asks for it.
--- @param result table Engaged set being built
--- @return table Engaged set, with TH gear when wanted
function TreasureHunter.apply_engaged(result)
    local on = TreasureHunter.wants_engaged_th()
    data().overlay_on = on
    if on then
        return set_combine(result, sets.TreasureHunter)
    end
    return result
end

--- TreasureHunter version of the SA/TA engaged overlay, in SATA and Full.
--- @param has_sa boolean Sneak Attack up or pending
--- @param has_ta boolean Trick Attack up or pending
--- @return table|nil Set to overlay, or nil to keep the sets.buff overlay
function TreasureHunter.sata_overlay(has_sa, has_ta)
    local current_mode = mode()
    if (current_mode ~= 'SATA' and current_mode ~= 'Full') or not sets then
        return nil
    end

    if has_sa and has_ta then
        return sets.TreasureHunterSATA
    elseif has_sa then
        return sets.TreasureHunterSA
    elseif has_ta then
        return sets.TreasureHunterTA
    end
    return nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   TAG TRACKING
---  ═══════════════════════════════════════════════════════════════════════════

local function refresh_gear()
    -- The aftercast of the action in progress rebuilds the engaged set anyway.
    if midaction and midaction() then
        return
    end
    send_command('gs c update')
end

--- Tag the targets of one of our melee rounds; drop TH once the current
--- target is tagged.
--- @param act table Action packet
--- @param now number os.time()
local function on_own_melee(act, now)
    local d = data()
    local current = current_target_id()
    local tagged_current = false

    for _, target in ipairs(act.targets) do
        if target.id == current and d.tagged[target.id] == nil then
            tagged_current = true
        end
        d.tagged[target.id] = now
    end

    if tagged_current and d.overlay_on and mode() ~= 'Full' then
        refresh_gear()
    end
end

--- Keep tagged mobs alive while they act or are acted on.
--- @param act table Action packet
--- @param now number os.time()
local function touch_tagged(act, now)
    local tagged = data().tagged
    if tagged[act.actor_id] then
        tagged[act.actor_id] = now
        return
    end
    for _, target in ipairs(act.targets) do
        if tagged[target.id] then
            tagged[target.id] = now
        end
    end
end

local function forget_stale(now)
    local tagged = data().tagged
    for id, last_seen in pairs(tagged) do
        if now - last_seen > FORGET_AFTER then
            tagged[id] = nil
        end
    end
end

local function on_action(act)
    if not act or not act.targets or not mode() then
        return
    end

    local now = os.time()
    if player and act.actor_id == player.id then
        if act.category == CATEGORY_MELEE then
            on_own_melee(act, now)
        end
    else
        touch_tagged(act, now)
    end
    forget_stale(now)
end

local function on_incoming_chunk(id, original)
    if id ~= 0x029 then
        return
    end

    local tagged = data().tagged
    local target_id = original:unpack('I', 0x09)
    if tagged[target_id] and DEATH_MESSAGES[original:unpack('H', 0x19) % 32768] then
        tagged[target_id] = nil
    end
end

local function on_target_change()
    local p = windower.ffxi.get_player()
    if not p or p.status ~= STATUS_ENGAGED then
        return
    end
    if TreasureHunter.wants_engaged_th() ~= data().overlay_on then
        refresh_gear()
    end
end

local function on_zone_change()
    data().tagged = {}
end

---  ═══════════════════════════════════════════════════════════════════════════
---   INIT
---  ═══════════════════════════════════════════════════════════════════════════

--- Register the tag tracking events. GearSwap removes events registered from
--- a job file on every load, so this runs once per load (from the facade).
function TreasureHunter.init()
    local d = data()
    if d.listening then
        return
    end
    d.listening = true

    windower.raw_register_event('action', on_action)
    windower.raw_register_event('incoming chunk', on_incoming_chunk)
    windower.raw_register_event('target change', on_target_change)
    windower.raw_register_event('zone change', on_zone_change)
end

return TreasureHunter

---============================================================================
--- Combat Mode - weapon lock available on every job
---============================================================================
--- state.CombatMode (Off / On). On keeps the weapons where they are: main,
--- sub and range are disabled (plus ammo on BLM, GEO and WHM), so a spell or a
--- set never swaps them and the TP stays. Off gives them back to the job.
--- When the player's set file defines sets.CombatMode, turning On puts it on
--- first, then locks (e.g. the nuking weapons on BLM).
---
--- Shown or hidden per job (row in the HUD, key, lock), saved per character
--- in <Character>/_common/keys/combat_mode.lua by //gs c combatmode
--- (combat_mode_commands.lua):
---   return { shown = {WAR = true}, hidden = {GEO = true}, keys = {WAR = '!numpad0'} }
--- `all` stands for every job not named: shown = {all = true},
--- keys = {all = '~f9'} (a job's own line wins).
--- A job not named there shows it when its own STATES file defines
--- CombatMode (BLM, GEO, RDM, WHM), keeping the key its keybind file gives;
--- the other jobs get Alt+Numpad0 once shown.
---
--- The lock is laid by one wrapper of handle_equipping_gear (every update),
--- and released while a craft session holds the gear. GearSwap keeps a
--- disabled slot across a job change: what this module locked is recorded on
--- `windower` and freed when the next job loads (attach), before its gear.
---
--- @file    shared/utils/core/combat_mode.lua
--- @author  ejouanchicot
--- @version 1.1 - shown / hidden / keys on optional_state.lua
--- @date    Created: 2026-09-25
---============================================================================

local CombatMode = {}

local DEFAULT_SLOTS = {'main', 'sub', 'range'}

-- Key of a job whose keybind file has no Combat Mode entry: free on every
-- job of the project (the jobs that had one keep theirs).
local DEFAULT_KEY = '!numpad0'
local SLOTS_BY_JOB = {
    BLM = {'main', 'sub', 'range', 'ammo'},
    GEO = {'main', 'sub', 'range', 'ammo'},
    WHM = {'main', 'sub', 'range', 'ammo'},
}

local unpack_list = table.unpack or unpack


---============================================================================
--- SETTINGS (shown / hidden / keys per job: optional_state.lua)
---============================================================================

local function craft_active()
    local craft = rawget(_G, 'CraftManager')
    return craft and craft.is_active and craft.is_active() or false
end

local Optional = require('shared/utils/core/optional_state').create({
    id = 'combat_mode', state = 'CombatMode', description = 'Combat Mode',
    values = {'Off', 'On'}, file = 'combat_mode.lua', default_key = DEFAULT_KEY,
    -- A job change keeps GearSwap's disabled slots; this job starts Off.
    -- The other locks' owners free their slots in file_unload and every
    -- state starts Off again, so their records go too.
    on_attach = function()
        if windower._combat_mode_locked and not craft_active() then
            enable(unpack_list(windower._combat_mode_locked))
            windower._combat_mode_locked = nil
        end
        windower._weapon_locks = {}
        -- The first update decides: a job loaded with Combat Mode On locks
        -- the weapon states' weapons (apply)
        windower._combat_mode_loading = true
        -- Counted so a lock scheduled by the previous job file (a pending
        -- Ampulla check) can tell it no longer belongs to the loaded job
        windower._weapon_lock_gen = (windower._weapon_lock_gen or 0) + 1
    end,
})

CombatMode._optional = Optional
CombatMode.settings_path = Optional.settings_path
CombatMode.settings = Optional.settings
CombatMode.is_shown = Optional.is_shown

--- Whether the weapons are locked now.
--- @return boolean
function CombatMode.is_on()
    return Optional.value() == 'On'
end

---============================================================================
--- LOCK
---============================================================================

local function slots()
    return SLOTS_BY_JOB[player and player.main_job] or DEFAULT_SLOTS
end

--- Slot locks other than Combat Mode's, owner -> slots: WHM Melee ON, THF
--- RangeLock, the Hoxne Ampulla. Kept on windower: the disabled slots outlive
--- a reload, so must the record. Laid again after the gear of every update
--- (reassert_holds): `gs enable all` (//po, //gs c wo) frees every slot while
--- the owner's state still says On.
--- @return table
local function other_locks()
    windower._weapon_locks = windower._weapon_locks or {}
    return windower._weapon_locks
end

--- Record that `owner` keeps `slot_list` locked: Combat Mode turning Off
--- then leaves those slots locked, and every update locks them again. The
--- owner disables them itself the first time.
--- @param owner string e.g. 'whm_melee'
--- @param slot_list table e.g. {'main', 'sub', 'range'}
function CombatMode.hold(owner, slot_list)
    other_locks()[owner] = slot_list
end

--- Forget `owner`'s lock (the owner enables its slots itself).
--- @param owner string
function CombatMode.release(owner)
    other_locks()[owner] = nil
end

--- `slot_list` minus the slots another lock still holds.
--- @param slot_list table
--- @return table
local function not_held_elsewhere(slot_list)
    local held = {}
    for _, owned in pairs(other_locks()) do
        for _, slot in ipairs(owned) do held[slot] = true end
    end
    local free = {}
    for _, slot in ipairs(slot_list) do
        if not held[slot] then free[#free + 1] = slot end
    end
    return free
end

--- The weapon states the jobs lay their weapons from.
local WEAPON_STATES = {'MainWeapon', 'SubWeapon', 'RangeWeapon', 'WeaponSet', 'SubSet'}

--- The player's weapon choice now, as one comparable string.
--- @return string
local function weapon_choice()
    local parts = {}
    for _, name in ipairs(WEAPON_STATES) do
        local mode = state and rawget(state, name)
        parts[#parts + 1] = mode and tostring(mode.current) or '-'
    end
    return table.concat(parts, '|')
end

--- Put sets.CombatMode on (when the set file has one), then lock. equip()
--- only diverts an item whose slot is ALREADY disabled (GearSwap
--- helper_functions.lua), so those pieces stay queued and the lock holds them.
--- @param dress boolean Put sets.CombatMode on first
local function lock(dress)
    local combat_set = rawget(_G, 'sets') and sets.CombatMode
    if dress and type(combat_set) == 'table' and not craft_active() then
        equip(combat_set)
    end
    disable(unpack_list(slots()))
    windower._combat_mode_locked = slots()
    windower._combat_mode_choice = weapon_choice()
end

--- Nothing in the main hand: something undressed the player behind the lock
--- (//po and //gs c wo strip through the client, then `gs enable all`).
--- @return boolean
local function weapons_stripped()
    local worn = player and player.equipment
    return worn ~= nil and (worn.main == nil or worn.main == 'empty')
end

--- After the job's gear: dress and lock (first lock, new weapon choice, or
--- weapons stripped).
local function lock_after_gear()
    lock(true)
end

--- Lock or free the weapon slots to match the state. The lock holds the
--- weapons of the player's weapon states (then sets.CombatMode on top), so it
--- waits for the job's gear of the same update - the caller runs the returned
--- function after it - whenever what it would hold is not that:
---   - a job loaded with Combat Mode already On (locking before the gear
---     pinned whatever was worn, e.g. the shield of the previous subjob after
---     a change to /NIN). Turned On by the player, it locks what is worn
---     instead: weapons put on by hand, then Combat Mode On, stay;
---   - a weapon state changed since the lock (the new choice goes on; spell
---     sets stay kept off as before);
---   - the weapons were stripped (//po): locking would pin empty hands.
--- @return function|nil To run once the job's gear is queued
function CombatMode.apply()
    if CombatMode.is_on() then
        if weapons_stripped() then
            return lock_after_gear
        end
        if not windower._combat_mode_locked then
            if windower._combat_mode_loading then
                windower._combat_mode_loading = nil
                return lock_after_gear
            end
            lock(true)
            return nil
        end
        if windower._combat_mode_choice ~= weapon_choice() and not craft_active() then
            enable(unpack_list(not_held_elsewhere(windower._combat_mode_locked)))
            return lock_after_gear
        end
        lock(false)
        return nil
    end

    windower._combat_mode_loading = nil
    if windower._combat_mode_locked and not craft_active() then
        -- A slot another lock holds (WHM Melee ON) stays locked
        enable(unpack_list(not_held_elsewhere(windower._combat_mode_locked)))
        windower._combat_mode_locked = nil
    end
end

--- Lay every hold() lock again, after the job's gear so a slot emptied by a
--- strip gets its piece first (equip() queues, a later disable() keeps it).
--- Not during a craft session, which owns the gear.
local function reassert_holds()
    if craft_active() then return end
    for _, owned in pairs(other_locks()) do
        disable(unpack_list(owned))
    end
end

--- Wrap handle_equipping_gear once per sandbox: the lock follows every
--- update (a cyclestate, a status change, a reload). Called from INIT_SYSTEMS,
--- after Mote has defined the function.
function CombatMode.install_hook()
    local orig = rawget(_G, 'handle_equipping_gear')
    if not orig or rawget(_G, '_combat_mode_hook') == orig then return end
    local hook = function(status, pet_status)
        local after_gear = CombatMode.apply()
        local result = orig(status, pet_status)
        if after_gear then after_gear() end
        reassert_holds()
        return result
    end
    _G.handle_equipping_gear = hook
    _G._combat_mode_hook = hook
end

---============================================================================
--- KEYBINDS
---============================================================================

--- Give the job its Combat Mode row (optional_state.lua). Called by
--- KeybindManager.create.
CombatMode.attach = Optional.attach

return CombatMode

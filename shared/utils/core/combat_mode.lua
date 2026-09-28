---============================================================================
--- Combat Mode - weapon lock available on every job
---============================================================================
--- state.CombatMode (Off / On). On keeps the weapons where they are: main,
--- sub and range are disabled (plus ammo on BLM, GEO and WHM), so a spell or a
--- set never swaps them and the TP stays. Off gives them back to the job.
---
--- Shown or hidden per job (row in the HUD, key, lock), saved per character
--- in <Character>/config/combat_mode.lua by //gs c combatmode
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
    -- A job change keeps GearSwap's disabled slots; this job starts Off
    on_attach = function()
        if windower._combat_mode_locked and not craft_active() then
            enable(unpack_list(windower._combat_mode_locked))
            windower._combat_mode_locked = nil
        end
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

--- Lock or free the weapon slots to match the state.
function CombatMode.apply()
    if CombatMode.is_on() then
        disable(unpack_list(slots()))
        windower._combat_mode_locked = slots()
    elseif windower._combat_mode_locked and not craft_active() then
        enable(unpack_list(windower._combat_mode_locked))
        windower._combat_mode_locked = nil
    end
end

--- Wrap handle_equipping_gear once per sandbox: the lock follows every
--- update (a cyclestate, a status change, a reload). Called from INIT_SYSTEMS,
--- after Mote has defined the function.
function CombatMode.install_hook()
    local orig = rawget(_G, 'handle_equipping_gear')
    if not orig or rawget(_G, '_combat_mode_hook') == orig then return end
    local hook = function(status, pet_status)
        CombatMode.apply()
        return orig(status, pet_status)
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

---============================================================================
--- Combat Mode - weapon lock available on every job
---============================================================================
--- state.CombatMode (Off / On). On keeps the weapons where they are: main,
--- sub and range are disabled (plus ammo on BLM and WHM), so a spell or a
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
--- `windower` and freed by the next job if its CombatMode is not On.
---
--- @file    shared/utils/core/combat_mode.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local CombatMode = {}

local DEFAULT_SLOTS = {'main', 'sub', 'range'}

-- Key of a job whose keybind file has no Combat Mode entry: free on every
-- job of the project (the jobs that had one keep theirs).
local DEFAULT_KEY = '!numpad0'
local SLOTS_BY_JOB = {
    BLM = {'main', 'sub', 'range', 'ammo'},
    WHM = {'main', 'sub', 'range', 'ammo'},
}

local unpack_list = table.unpack or unpack

-- Settings, native flag and entry live on the sandbox _G, not in locals:
-- user_setup requires this module before the module cache exists, so two
-- requires can give two copies.

---============================================================================
--- SETTINGS
---============================================================================

--- Path of the character's settings file.
--- @return string|nil
function CombatMode.settings_path()
    if not (player and player.name and windower and windower.addon_path) then return nil end
    return ('%sdata/%s/config/combat_mode.lua'):format(windower.addon_path, player.name)
end

--- The character's settings, read once per load.
--- @return table {shown, hidden, keys}
function CombatMode.settings()
    if rawget(_G, '_combat_mode_settings') then return _G._combat_mode_settings end
    local loaded = nil
    local path = CombatMode.settings_path()
    local file = path and io.open(path, 'r')
    if file then
        file:close()
        local ok, data = pcall(dofile, path)
        if ok and type(data) == 'table' then loaded = data end
    end
    loaded = loaded or {}
    _G._combat_mode_settings = {shown = loaded.shown or {}, hidden = loaded.hidden or {}, keys = loaded.keys or {}}
    return _G._combat_mode_settings
end

--- Whether the job shows Combat Mode.
--- @param job string|nil Job code (default: current main job)
--- @return boolean
function CombatMode.is_shown(job)
    job = job or (player and player.main_job)
    local s = CombatMode.settings()
    if s.hidden[job] then return false end
    if s.shown[job] or (s.shown.all and not s.hidden.all) then return true end
    if s.hidden.all then return false end
    return rawget(_G, '_combat_mode_native') == true
end

--- Whether the weapons are locked now.
--- @return boolean
function CombatMode.is_on()
    local mode = state and rawget(state, 'CombatMode')
    return mode ~= nil and tostring(mode.value) == 'On' and CombatMode.is_shown()
end

---============================================================================
--- LOCK
---============================================================================

local function slots()
    return SLOTS_BY_JOB[player and player.main_job] or DEFAULT_SLOTS
end

local function craft_active()
    local craft = rawget(_G, 'CraftManager')
    return craft and craft.is_active and craft.is_active() or false
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

--- Give the job its Combat Mode row: the job's own entry when it has one,
--- else a new one. Creates the state when the job has none. Called by
--- KeybindManager.create.
--- @param job string Job code
--- @param binds table The job's bind list
function CombatMode.attach(job, binds)
    -- The HUD requires the keybind file a second time: by then the state
    -- below exists, so the first answer is the one kept.
    if rawget(_G, '_combat_mode_native') == nil then
        _G._combat_mode_native = rawget(state, 'CombatMode') ~= nil
    end
    if not rawget(state, 'CombatMode') then
        state.CombatMode = M{['description'] = 'Combat Mode', 'Off', 'On'}
    end
    local entry = nil
    for _, bind in ipairs(binds) do
        if bind.state == 'CombatMode' then entry = bind break end
    end
    if not entry then
        entry = {key = DEFAULT_KEY, command = 'cyclestate CombatMode', desc = 'Combat Mode', state = 'CombatMode'}
        binds[#binds + 1] = entry
    end
    local keys = CombatMode.settings().keys
    local key = keys[job] or keys.all
    if key then entry.key = key end
    local own_visible = entry.visible
    entry.visible = function()
        if not CombatMode.is_shown(job) then return false end
        return own_visible == nil or own_visible()
    end
    _G._combat_mode_entry = entry
end

return CombatMode

---============================================================================
--- Optional State - a mode the GearSwap adds to jobs, shown or hidden per job
---============================================================================
--- Combat Mode and Treasure Mode work the same way: a Mote state the project
--- adds to every job (when the job's own STATES file does not define it), a
--- row in the HUD and a key, shown or hidden per job, saved per character in
--- <Character>/saved/<file> (combat_mode.lua, treasure_mode.lua):
---   return { shown = {WAR = true}, hidden = {GEO = true}, keys = {WAR = '!numpad0'} }
--- `all` stands for every job not named (a job's own line wins). A job not
--- named shows it when its own STATES file defines the state ("native").
---
--- create{...} returns the object each mode is built on:
---   id           short name for the sandbox fields (_<id>_settings...)
---   state        Mote state name ('CombatMode')
---   description  its description ('Combat Mode')
---   values       its values, the first is the default ({'Off', 'On'})
---   file         settings file name ('combat_mode.lua')
---   default_key  key given to a job whose keybind file has no entry
---   on_attach    optional function(job) run when a job attaches
---
--- Settings, native flag and entry live on the sandbox _G, not in locals:
--- user_setup requires these modules before the module cache exists, so two
--- requires can give two copies.
---
--- @file    shared/utils/core/optional_state.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28 (from combat_mode.lua)
---============================================================================

local OptionalState = {}

--- A {JOB = value} table with its job codes in capitals ("thf" -> THF,
--- "ALL" -> all): a job typed in lower case by hand still counts.
local function by_job(t)
    local out = {}
    for job, value in pairs(type(t) == 'table' and t or {}) do
        local name = tostring(job)
        out[name:lower() == 'all' and 'all' or name:upper()] = value
    end
    return out
end

--- Build the object of one optional state.
--- @param cfg table See the file header
--- @return table
function OptionalState.create(cfg)
    local S = {cfg = cfg}
    local settings_key = '_' .. cfg.id .. '_settings'
    local native_key = '_' .. cfg.id .. '_native'
    local entry_key = '_' .. cfg.id .. '_entry'

    --- Path of the character's settings file, or nil before the player is known.
    function S.settings_path()
        if not (player and player.name and windower and windower.addon_path) then return nil end
        return require('shared/utils/core/char_paths').writable('saved', cfg.file)
    end

    --- Where the settings are now: saved/, or the place of before (a folder not tidied since
    --- 2026-10-10 has the file in _common/keys/; it goes to saved/ the next time it is written).
    function S.read_path()
        if not (player and player.name and windower and windower.addon_path) then return nil end
        return require('shared/utils/core/char_paths').file('saved', cfg.file)
    end

    --- The character's settings, read once per load: {shown, hidden, keys}.
    function S.settings()
        local cached = rawget(_G, settings_key)
        if cached then return cached end
        local loaded = nil
        local path = S.read_path()
        local file = path and io.open(path, 'r')
        if file then
            file:close()
            local ok, data = pcall(dofile, path)
            if ok and type(data) == 'table' then loaded = data end
        end
        loaded = loaded or {}
        local settings = {shown = by_job(loaded.shown), hidden = by_job(loaded.hidden), keys = by_job(loaded.keys)}
        _G[settings_key] = settings
        return settings
    end

    --- Whether the job shows the mode.
    --- @param job string|nil Job code (default: current main job)
    --- @return boolean
    function S.is_shown(job)
        job = job or (player and player.main_job)
        local s = S.settings()
        if s.hidden[job] then return false end
        if s.shown[job] or (s.shown.all and not s.hidden.all) then return true end
        if s.hidden.all then return false end
        return rawget(_G, native_key) == true
    end

    --- The state's current value when the job shows it, else nil.
    --- @return string|nil
    function S.value()
        local mode = state and rawget(state, cfg.state)
        if mode == nil or not S.is_shown() then return nil end
        return tostring(mode.value)
    end

    --- The job's keybind entry for the mode (after attach).
    function S.entry()
        return rawget(_G, entry_key)
    end

    --- Give the job its row: the job's own entry when it has one, else a new
    --- one. Creates the state when the job has none. Called by
    --- KeybindManager.create.
    --- @param job string Job code
    --- @param binds table The job's bind list
    function S.attach(job, binds)
        -- The HUD requires the keybind file a second time: by then the state
        -- below exists, so the first answer is the one kept.
        if rawget(_G, native_key) == nil then
            _G[native_key] = rawget(state, cfg.state) ~= nil
        end
        if not rawget(state, cfg.state) then
            local mode = {['description'] = cfg.description}
            for i, v in ipairs(cfg.values) do mode[i] = v end
            state[cfg.state] = M(mode)
        end
        if cfg.on_attach then cfg.on_attach(job) end
        local entry = nil
        for _, bind in ipairs(binds) do
            if bind.state == cfg.state then entry = bind break end
        end
        if not entry then
            entry = {key = cfg.default_key, command = 'cyclestate ' .. cfg.state,
                desc = cfg.description, state = cfg.state}
            binds[#binds + 1] = entry
        end
        local keys = S.settings().keys
        local key = keys[job] or keys.all
        if key then entry.key = key end
        local own_visible = entry.visible
        entry.visible = function()
            if not S.is_shown(job) then return false end
            return own_visible == nil or own_visible()
        end
        _G[entry_key] = entry
    end

    return S
end

return OptionalState

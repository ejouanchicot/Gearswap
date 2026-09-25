---============================================================================
--- Keybind Manager - one engine for every job's keybinds
---============================================================================
--- A job's keybind file only lists its keys; this factory gives it the
--- functions every caller already uses (entry point, HUD, KeybindGuard,
--- state hooks): get_active_binds, bind_all, refresh, unbind_all, show_intro,
--- show_binds. Same names and behaviour as the hand-written copies it
--- replaces, so a job can move over without any caller changing.
---
--- Bind entry fields:
---   key            Windower key ("^numpad1"); "" = HUD row only, nothing bound
---   command        gs c command sent by the key ("cyclestate MainWeapon")
---   desc           Label in the HUD and the chat lists
---   state          Mote state the row displays
---   subjob         Only bound under this subjob (string or list)
---   exclude_subjob Never bound under this subjob (string or list)
---   visible        function() -> boolean, asked again on every refresh()
---   alt            Only bound while another box of the group plays this:
---                  {name =, job =, subjob =, weapon =}, each optional, a
---                  string or a list; no name = the tracked partner. Checked
---                  again whenever a box reports a new job or weapon type
---                  (shared/utils/dualbox/alt_states.lua)
---
--- Keys that must be cleared on load although no entry names them any more
--- go in <module>.retired_keys. Keys this manager bound itself are cleared
--- anyway: what it lays down is recorded on `windower`, which outlives the
--- sandbox, so a key removed from the file is unbound on the next load.
---
--- @file    shared/utils/keybinds/keybind_manager.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-24
---============================================================================

local KeybindManager = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')
local KeyValidator = require('shared/utils/keybinds/key_validator')

--- Keys laid down by this manager, key -> command. Kept on `windower`: a
--- job file's own memory dies with its sandbox, the Windower binds do not.
local function bound_keys()
    windower._keybind_manager_bound = windower._keybind_manager_bound or {}
    return windower._keybind_manager_bound
end

---============================================================================
--- HELPERS
---============================================================================

--- True when `rule` (string, list or nil) names `subjob`.
--- @param rule string|table|nil
--- @param subjob string|nil
--- @return boolean
local function names_subjob(rule, subjob)
    if type(rule) == 'table' then
        for _, value in ipairs(rule) do
            if value == subjob then return true end
        end
        return false
    end
    return rule ~= nil and rule == subjob
end

--- Whether a bind applies with the current subjob and state.
--- @param bind table
--- @return boolean
local function applies(bind)
    local subjob = player and player.sub_job or nil
    if bind.subjob and not names_subjob(bind.subjob, subjob) then return false end
    if bind.exclude_subjob and names_subjob(bind.exclude_subjob, subjob) then return false end
    if type(bind.alt) == 'table' then
        local ok, AltStates = pcall(require, 'shared/utils/dualbox/alt_states')
        if not ok or not AltStates.matches(bind.alt) then return false end
    end
    if type(bind.visible) == 'function' then
        local ok, shown = pcall(bind.visible)
        return ok and shown ~= false and shown ~= nil
    end
    return true
end

--- What the key runs:
---   "//sm mirror"   console command of any addon (the // is dropped)
---   "/p hello"      game chat command, sent with input
---   raw = true      the command exactly as written
---   anything else   gs c <command>
--- @param bind table Bind entry
--- @return string
function KeybindManager.bind_line(bind)
    local command = bind.command
    if bind.raw then
        return command
    end
    if command:sub(1, 2) == '//' then
        return command:sub(3)
    end
    if command:sub(1, 1) == '/' then
        return 'input ' .. command
    end
    return 'gs c ' .. command
end

--- key -> console line for the binds that lay down a key.
--- @param binds table List of bind entries
--- @return table
local function key_map(binds)
    local map = {}
    for _, bind in ipairs(binds) do
        if bind.key and bind.key ~= '' and bind.command then
            map[bind.key] = KeybindManager.bind_line(bind)
        end
    end
    return map
end

local function send_bind(key, line)
    return pcall(send_command, 'bind ' .. key .. ' ' .. line)
end

local function send_unbind(key)
    pcall(send_command, 'unbind ' .. key)
end

---============================================================================
--- OPERATIONS (ctx = {job, module, applied, api})
---============================================================================

local function get_active_binds(ctx)
    local active = {}
    for _, bind in ipairs(ctx.module.binds or {}) do
        if applies(bind) then active[#active + 1] = bind end
    end
    return active
end

--- Unbind what is down but no longer wanted. The keys about to be bound are
--- left alone: a bind overwrites, and unbinding first opened the window in
--- which ^numpad9 went dead after a reload (see keybind_guard.lua).
local function clear_unwanted(ctx, desired)
    local stale = {}
    for _, bind in ipairs(ctx.module.binds or {}) do
        if bind.key and bind.key ~= '' then stale[bind.key] = true end
    end
    for _, key in ipairs(ctx.module.retired_keys or {}) do stale[key] = true end
    for key in pairs(bound_keys()) do stale[key] = true end
    for key in pairs(stale) do
        if not desired[key] then
            send_unbind(key)
            bound_keys()[key] = nil
        end
    end
end

--- Bind the keyed entries of `active`, in file order.
--- @return number Keys bound
local function lay_down(active, desired)
    local bound = 0
    for _, b in ipairs(active) do
        local line = b.command and KeybindManager.bind_line(b)
        if line and desired[b.key] == line then
            local ok, err = send_bind(b.key, line)
            if ok then
                bound = bound + 1
                bound_keys()[b.key] = line
            else
                MessageFormatter.show_bind_failed_error(b.key, tostring(err or 'Command execution failed'))
            end
        end
    end
    return bound
end

--- Bind every applicable key.
--- @param silent boolean|nil Skip the intro message
--- @return boolean True if at least one key was bound
local function bind_all(ctx, silent)
    if not ctx.module.binds or #ctx.module.binds == 0 then
        MessageFormatter.show_no_binds_error(ctx.job)
        return false
    end
    local active = get_active_binds(ctx)
    if not silent then
        for _, problem in ipairs(KeyValidator.check(ctx.module.binds, active)) do
            MessageFormatter.show_warning(ctx.job .. ' keybinds: ' .. problem)
        end
    end
    local desired = key_map(active)
    clear_unwanted(ctx, desired)
    local bound = lay_down(active, desired)
    ctx.applied = desired
    if bound > 0 then
        if not silent then ctx.api.show_intro() end
        return true
    end
    -- Zero keys down while some apply: every send failed. Silence here is
    -- what made dead keys hard to chase.
    if next(desired) then
        MessageFormatter.show_error(('%s keybinds: none applied - keys will not respond'):format(ctx.job))
    end
    return false
end

--- Send only what changed since the last bind_all/refresh: a `visible` bind
--- can come and go while the job stays the same.
--- @return number Commands sent
local function refresh(ctx)
    local desired = key_map(get_active_binds(ctx))
    local sent = 0
    for key in pairs(ctx.applied) do
        -- A key that stays, with another command, is only re-bound below:
        -- unbinding first leaves it dead in between (see clear_unwanted)
        if desired[key] == nil then
            send_unbind(key)
            bound_keys()[key] = nil
            sent = sent + 1
        end
    end
    for key, command in pairs(desired) do
        if ctx.applied[key] ~= command then
            send_bind(key, command)
            bound_keys()[key] = command
            sent = sent + 1
        end
    end
    ctx.applied = desired
    return sent
end

--- Unbind every key of this job, and whatever this manager left down.
--- @return boolean
local function unbind_all(ctx)
    if not ctx.module.binds then return false end
    clear_unwanted(ctx, {})
    ctx.applied = {}
    MessageFormatter.show_success(ctx.job .. ' keybinds unloaded.')
    return true
end

--- Job intro: bound keys count, macrobook and lockstyle info.
--- Requiring the job's MACROBOOK/LOCKSTYLE modules here also defines their
--- globals, which the entry points' user_setup relies on.
local function show_intro(ctx)
    local jl = ctx.job:lower()
    local macro_info, lockstyle_info
    local ok_m, macrobook = pcall(require, 'shared/jobs/' .. jl .. '/functions/' .. ctx.job .. '_MACROBOOK')
    local get_macro = ok_m and type(macrobook) == 'table' and macrobook['get_' .. jl .. '_macro_info']
    if get_macro then macro_info = get_macro() end
    local ok_l, lockstyle = pcall(require, 'shared/jobs/' .. jl .. '/functions/' .. ctx.job .. '_LOCKSTYLE')
    if ok_l and type(lockstyle) == 'table' and lockstyle.get_info then lockstyle_info = lockstyle.get_info() end

    local keyed = {}
    for _, bind in ipairs(get_active_binds(ctx)) do
        if bind.key and bind.key ~= '' then keyed[#keyed + 1] = bind end
    end
    local title = ctx.job .. ' SYSTEM LOADED'
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete(title, keyed, macro_info, lockstyle_info)
    else
        MessageFormatter.show_system_intro(title, keyed)
    end
end

local function show_binds(ctx)
    MessageFormatter.show_keybind_list(ctx.job .. ' Keybinds', get_active_binds(ctx))
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Append the player's own states and keys (<JOB>_CUSTOM.lua, see
--- shared/utils/custom/custom_states.lua). Guarded: a broken custom file
--- must never cost the job its regular keys.
--- @param job string
--- @param module table
local function add_custom_states(job, module)
    if type(module.binds) ~= 'table' then return end
    local ok, CustomStates = pcall(require, 'shared/utils/custom/custom_states')
    if not ok or type(CustomStates) ~= 'table' then return end
    local loaded, err = pcall(CustomStates.load, job, module.binds)
    if not loaded then
        MessageFormatter.show_error(job .. '_CUSTOM.lua: ' .. tostring(err))
    end
end

--- Give a job's keybind module its functions.
--- @param job string Job code ("PLD")
--- @param module table Holds .binds and optionally .retired_keys
--- @return table The same module, with get_active_binds, bind_all, refresh,
---   unbind_all, show_intro and show_binds attached, and the player's custom
---   keys, then the character's common keys (config/COMMON_KEYBINDS.lua),
---   appended to .binds
function KeybindManager.create(job, module)
    local ctx = {job = job, module = module, applied = {}, api = module}
    KeybindManager.active = module
    local function bind(fn) return function(...) return fn(ctx, ...) end end
    module.get_active_binds = bind(get_active_binds)
    module.bind_all = bind(bind_all)
    module.refresh = bind(refresh)
    module.unbind_all = bind(unbind_all)
    module.show_intro = bind(show_intro)
    module.show_binds = bind(show_binds)
    add_custom_states(job, module)
    local ok, CommonKeybinds = pcall(require, 'shared/utils/keybinds/common_keybinds')
    if ok and CommonKeybinds then
        CommonKeybinds.merge_into(module.binds)
    end
    return module
end

--- Refresh the keys of the job loaded now (see the `alt` field): what
--- another box plays changes without this job's own state changing.
--- @return number Commands sent (0 when no job module is loaded)
function KeybindManager.refresh_active()
    local module = KeybindManager.active
    if module and module.refresh then return module.refresh() end
    return 0
end

_G.KeybindManager = KeybindManager

return KeybindManager

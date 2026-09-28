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
---   weapon         Only bound while THIS character's main hand is of this
---                  weapon skill: 'Club', 'Sword', 'Great Katana' (string or
---                  list; spaces and case ignored, as for `alt`). An empty
---                  main hand is 'None'. Checked again when the main hand
---                  changes weapon type: the keys refresh by themselves
---                  (BindManager's per-weapon layers). An entry without the
---                  field is not affected, and no listener is laid unless
---                  one entry of the job uses it.
---
--- Keys that must be cleared on load although no entry names them any more
--- go in <module>.retired_keys. Keys this manager bound itself are cleared
--- anyway: what it lays down is recorded on `windower`, which outlives the
--- sandbox, so a key removed from the file is unbound on the next load.
---
--- @file    shared/utils/keybinds/keybind_manager.lua
--- @author  ejouanchicot
--- @version 1.2
--- @date    Created: 2026-09-24 | Updated: 2026-09-27 (key conflicts)
---============================================================================

local KeybindManager = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')
local KeyValidator = require('shared/utils/keybinds/key_validator')
local KeyConflicts = require('shared/utils/keybinds/key_conflicts')

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

--- Whether a `weapon` rule names the main hand now. The main hand is read
--- once per pass (memo): reading it lists the inventory.
--- @param rule string|table
--- @param memo table Per-pass cache ({weapon = skill})
--- @return boolean
local function wields(rule, memo)
    local ok, AltStates = pcall(require, 'shared/utils/dualbox/alt_states')
    if not ok or type(AltStates) ~= 'table' or not AltStates.own_weapon_matches then return false end
    if memo.weapon == nil then
        local read, skill = pcall(AltStates.weapon_skill)
        memo.weapon = read and skill or 'None'
    end
    return AltStates.own_weapon_matches(rule, memo.weapon)
end

--- Whether a bind applies with the current subjob, weapon and state.
--- @param bind table
--- @param memo table Per-pass cache shared by the binds of one pass
--- @return boolean
local function applies(bind, memo)
    local subjob = player and player.sub_job or nil
    if bind.subjob and not names_subjob(bind.subjob, subjob) then return false end
    if bind.exclude_subjob and names_subjob(bind.exclude_subjob, subjob) then return false end
    if bind.weapon ~= nil and not wields(bind.weapon, memo) then return false end
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

--- The entries that apply now, minus the common ones that give way to a
--- job or custom key applying on the same key.
--- @return table active, table yielded
local function get_active_binds(ctx)
    local applying, memo, own_keys = {}, {}, {}
    for _, bind in ipairs(ctx.module.binds or {}) do
        if applies(bind, memo) then
            applying[#applying + 1] = bind
            if not bind._common and bind.key then own_keys[bind.key] = true end
        end
    end
    local active, yielded = {}, {}
    for _, bind in ipairs(applying) do
        if KeyConflicts.yields(bind) and own_keys[bind.key] then
            yielded[#yielded + 1] = bind
        else
            active[#active + 1] = bind
        end
    end
    return active, yielded
end

--- Tell the conflicts of this pass (once per load each) and keep their keys
--- for the HUD, which draws them in the conflict color.
--- @return boolean True when the set of keys in conflict changed
local function note_conflicts(ctx, active, yielded)
    local list = KeyConflicts.live(active, yielded)
    ctx.conflicts_told = ctx.conflicts_told or {}
    KeyConflicts.report(ctx.job, list, ctx.conflicts_told)
    local keys, before, changed = {}, ctx.module._conflict_keys or {}, false
    for _, c in ipairs(list) do
        keys[c.key] = true
        if not before[c.key] then changed = true end
    end
    for key in pairs(before) do
        if not keys[key] then changed = true end
    end
    ctx.module._conflict_keys = keys
    return changed
end

--- Redraw the HUD now. KeybindUI.update() redraws only when a Mote state
--- changed, and a key conflict is not a state: without this the red key
--- appeared at the next state change.
local function redraw_hud()
    if not rawget(_G, 'keybind_ui_display') then return end
    local ok, Display = pcall(require, 'shared/utils/ui/ui_display')
    if ok and Display and Display.update_display then pcall(Display.update_display) end
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
    local active, yielded = get_active_binds(ctx)
    if not silent then
        for _, problem in ipairs(KeyValidator.check(ctx.module.binds)) do
            MessageFormatter.show_warning(ctx.job .. ' keybinds: ' .. problem)
        end
    end
    if note_conflicts(ctx, active, yielded) then redraw_hud() end
    local desired = key_map(active)
    clear_unwanted(ctx, desired)
    local bound = lay_down(active, desired)
    ctx.applied = desired
    require('shared/utils/debug/trace_log').log('LOAD', 'keys %s: %d bound', ctx.job, bound)
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
    local active, yielded = get_active_binds(ctx)
    local conflicts_moved = note_conflicts(ctx, active, yielded)
    local desired = key_map(active)
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
    -- A partner's job or a Combat Mode change moved keys or conflicts: the
    -- HUD rows and their red keys follow at once
    if sent > 0 or conflicts_moved then redraw_hud() end
    return sent
end

--- Unbind every key of this job, and whatever this manager left down.
--- @return boolean
local function unbind_all(ctx)
    if not ctx.module.binds then return false end
    require('shared/utils/debug/trace_log').log('LOAD', 'keys %s: unbind all', ctx.job)
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

--- Refresh the job's keys when the main hand changes weapon type, when one
--- of its entries has a `weapon` field. Nothing is laid otherwise.
--- @param binds table|nil The job's bind list, common keys included
local function watch_own_weapon(binds)
    local wanted = false
    for _, bind in ipairs(binds or {}) do
        if bind.weapon ~= nil then wanted = true break end
    end
    if not wanted then return end
    local ok, AltStates = pcall(require, 'shared/utils/dualbox/alt_states')
    if ok and type(AltStates) == 'table' and AltStates.on_weapon_change then
        AltStates.on_weapon_change('keybinds', function() KeybindManager.refresh_active() end)
    end
end

--- Give a job's keybind module its functions.
--- @param job string Job code ("PLD")
--- @param module table Holds .binds and optionally .retired_keys
--- @return table The same module, with get_active_binds, bind_all, refresh,
---   unbind_all, show_intro and show_binds attached, its Combat Mode row
---   (shared/utils/core/combat_mode.lua), and the player's custom
---   keys, then the character's common keys (config/COMMON_KEYBINDS.lua),
---   appended to .binds
function KeybindManager.create(job, module)
    local ctx = {job = job, module = module, applied = {}, api = module}
    -- The HUD requires the keybind file again, making a second module: the
    -- first one is the job's, the one bind_all lays the keys with.
    if rawget(_G, '_keybind_active') == nil then _G._keybind_active = module end
    local function bind(fn) return function(...) return fn(ctx, ...) end end
    module.get_active_binds = bind(get_active_binds)
    module.bind_all = bind(bind_all)
    module.refresh = bind(refresh)
    module.unbind_all = bind(unbind_all)
    module.show_intro = bind(show_intro)
    module.show_binds = bind(show_binds)
    if type(module.binds) == 'table' then
        local ok_c, CombatMode = pcall(require, 'shared/utils/core/combat_mode')
        if ok_c and CombatMode then CombatMode.attach(job, module.binds) end
        -- Treasure Mode: THF's own, Off and hidden on the other jobs
        local ok_t, TreasureHunter = pcall(require, 'shared/utils/equipment/treasure_hunter')
        if ok_t and TreasureHunter then TreasureHunter.optional.attach(job, module.binds) end
    end
    add_custom_states(job, module)
    local ok, CommonKeybinds = pcall(require, 'shared/utils/keybinds/common_keybinds')
    if ok and CommonKeybinds then
        CommonKeybinds.merge_into(module.binds)
    end
    watch_own_weapon(module.binds)
    -- A row without desc (a hand-written keybind or CUSTOM file) made the
    -- HUD's first render raise and abort the job load: name it after its
    -- state, else its command.
    for _, b in ipairs(type(module.binds) == 'table' and module.binds or {}) do
        if type(b) == 'table' and type(b.desc) ~= 'string' then
            b.desc = tostring(b.state or b.command or b.key or '?')
        end
    end
    return module
end

--- Keys in conflict at the last bind_all / refresh of the job loaded now
--- (shared/utils/keybinds/key_conflicts.lua), for the HUD.
--- @return table Set: key -> true
function KeybindManager.conflict_keys()
    local module = rawget(_G, '_keybind_active')
    return module and module._conflict_keys or {}
end

--- //gs c keyconflicts: every conflict the loaded job's keys can run into,
--- over all subjobs and partner jobs.
--- @return boolean False when no job keys are loaded
function KeybindManager.show_possible_conflicts()
    local module = rawget(_G, '_keybind_active')
    if not (module and module.binds) then return false end
    KeyConflicts.show_possible(player and player.main_job or '?', module.binds)
    return true
end

--- Refresh the keys of the job loaded now (see the `alt` field, Combat
--- Mode): what another box plays changes without this job's own state
--- changing.
--- @return number Commands sent (0 when no job module is loaded)
function KeybindManager.refresh_active()
    local module = rawget(_G, '_keybind_active')
    if module and module.refresh then return module.refresh() end
    return 0
end

_G.KeybindManager = KeybindManager

return KeybindManager

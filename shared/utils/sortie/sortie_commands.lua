---============================================================================
--- Sortie Commands - one GearSwap command per Sortie target
---============================================================================
--- //gs c sortie <target> puts this character in the stance the target needs,
--- then tells the alt which Silmaril profile to load and starts it. Silmaril
--- runs the fight from there; the per-target settings live in its profiles.
---
--- Everything personal (the alt, the profile folder, the stances, the
--- targets, the orders) is in the character's _common/combat/
--- SORTIE_CONFIG.lua (see Tetsouo's for every key). A character without that
--- file has no sortie command: it answers "not set up" and is hidden from
--- the help (SortieCommands.available). Its `by_job` gives another main job
--- its own way (DNC: another profile folder for the alt, other stances).
---
--- Commands:
---   //gs c sortie <target>          stance + alt profile (targets of the config)
---   //gs c sortie escort [Indi-X]   alt stops Silmaril, dismisses its luopan
---                                   if any, casts the Indi (default
---                                   Indi-Regen) and follows this character
---   //gs c sortie off               alt stops Silmaril
---   //gs c sortie judgment          alt weaponskills the party's battle target
---   //gs c sortie fullcircle        alt dismisses its luopan
---   //gs c sortie list              list the targets
---
--- @file    shared/utils/sortie/sortie_commands.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-24
---============================================================================

local SortieCommands = {}

---============================================================================
--- CONFIG
---============================================================================

--- The config as the current main job uses it: by_job[<MAIN>] replaces the
--- keys it names, its `targets` replacing only the targets of the same name.
--- A copy: the module require() keeps is never changed.
--- @param cfg table SORTIE_CONFIG
--- @return table
local function for_job(cfg)
    local job = player and player.main_job
    local over = job and type(cfg.by_job) == 'table' and cfg.by_job[job]
    if type(over) ~= 'table' then return cfg end
    local out = {}
    for k, v in pairs(cfg) do out[k] = v end
    for k, v in pairs(over) do
        if k == 'targets' and type(v) == 'table' then
            local targets = {}
            for name, target in pairs(cfg.targets) do targets[name] = target end
            for name, target in pairs(v) do targets[name] = target end
            out.targets = targets
        else
            out[k] = v
        end
    end
    return out
end

--- The character's SORTIE_CONFIG.lua for its current main job, or nil.
--- @return table|nil
local function config()
    local ok, cfg = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'SORTIE_CONFIG')
    end)
    return (ok and type(cfg) == 'table' and type(cfg.targets) == 'table') and for_job(cfg) or nil
end

--- True when the character has a Sortie config (the help shows the command).
--- @return boolean
function SortieCommands.available()
    return config() ~= nil
end

---============================================================================
--- HELPERS
---============================================================================

local MessageSortie = nil

--- Sortie message formatter, loaded on first use.
--- @return table|nil
local function messages()
    if not MessageSortie then
        local ok, mod = pcall(require, 'shared/utils/messages/formatters/system/message_sortie')
        MessageSortie = ok and mod or nil
    end
    return MessageSortie
end

--- This character's name, for messages and the alt's follow.
--- @return string
local function me()
    return player and player.name or ''
end

--- Send a command to the alt's console.
--- @param cfg table Sortie config
--- @param command string
local function to_alt(cfg, command)
    send_command('send ' .. cfg.alt .. ' ' .. command)
end

--- Tell the alt window what was just ordered (on / follow).
--- @param changes table Fields of AltGroup.state()
local function note(changes)
    local ok, AltGroup = pcall(require, 'shared/utils/dualbox/alt_group')
    if ok and AltGroup then AltGroup.note(changes) end
end

--- One entry per target, sorted by name, with the aliases that share it.
--- @param cfg table Sortie config
--- @return table Array of {name, aliases, indi, summary}
local function list_entries(cfg)
    local entries = {}
    for name, target in pairs(cfg.targets) do
        local aliases = {}
        for alias, key in pairs(cfg.aliases or {}) do
            if key == name then aliases[#aliases + 1] = alias end
        end
        table.sort(aliases)
        entries[#entries + 1] = {
            name = name, aliases = table.concat(aliases, ', '),
            indi = target.indi, summary = target.summary,
        }
    end
    table.sort(entries, function(a, b) return a.name < b.name end)
    return entries
end

--- Set this character's states the way `gs c set` does, minus Mote's
--- "<state> is now <value>." chat line: the HUD already shows them.
--- An unknown state falls back to `gs c set` so its error still shows.
--- @param settings table Array of "<state> <value>" strings
local function set_states(settings)
    local changed = false
    for _, setting in ipairs(settings) do
        local field, value = setting:match('^(%S+)%s+(.+)$')
        local state_var = field and get_state and get_state(field)
        if state_var then
            local old = state_var.value
            -- Modes.set raises on a value the job does not list (a stance
            -- only PLD/SCH has); skip that one and still brief the alt.
            if pcall(state_var.set, state_var, value) then
                if job_state_change then
                    job_state_change(state_var.description or field, state_var.value, old)
                end
                changed = true
            else
                local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
                if ok and MessageFormatter then
                    MessageFormatter.show_warning(('Sortie: %s has no %s value here'):format(field, value))
                end
            end
        else
            send_command('gs c set ' .. setting)
        end
    end
    if changed and handle_update then handle_update({'auto'}) end
end

--- Set the states of a list the job has, silently skipping the others.
--- @param settings table Array of "<state> <value>" strings
local function set_known_states(settings)
    local known = {}
    for _, setting in ipairs(settings) do
        local field = setting:match('^(%S+)')
        if field and state and rawget(state, field) then known[#known + 1] = setting end
    end
    if #known > 0 then set_states(known) end
end

--- The per-target states: the config's target_states, a target's own
--- `states` replacing the same state.
--- @return table Array of "<state> <value>"
local function target_states(cfg, target)
    local order, value = {}, {}
    for _, list in ipairs({cfg.target_states or {}, target.states or {}}) do
        for _, setting in ipairs(list) do
            local field, v = setting:match('^(%S+)%s+(.+)$')
            if field then
                if value[field] == nil then order[#order + 1] = field end
                value[field] = v
            end
        end
    end
    local out = {}
    for _, field in ipairs(order) do out[#out + 1] = field .. ' ' .. value[field] end
    return out
end

---============================================================================
--- ACTIONS
---============================================================================

--- Stance for this character, profile for the alt, Silmaril on.
--- @param cfg table Sortie config
--- @param name string Target as typed
--- @return boolean handled
local function engage_target(cfg, name)
    local key = (cfg.aliases or {})[name] or name
    local target = cfg.targets[key]
    if not target then
        if messages() then messages().show_unknown_target(name) end
        return true
    end
    set_states((cfg.stances or {})[target.stance] or {})
    -- Only the states this job has: set_states would otherwise send
    -- `gs c set` and print Mote's unknown-state error.
    set_known_states(target_states(cfg, target))
    to_alt(cfg, 'sm load ' .. (cfg.profile_root or '') .. target.profile)
    to_alt(cfg, 'sm follow off')
    to_alt(cfg, 'sm on')
    note({on = true, follow = false})
    if target.indi then to_alt(cfg, '/ma "' .. target.indi .. '" <me>') end
    if messages() then
        local shown = key ~= name
            and (name:sub(1, 1):upper() .. name:sub(2) .. ' (' .. target.profile .. ')')
            or target.profile
        messages().show_target_loaded(shown, cfg.alt, target.indi, target.summary)
    end
    return true
end

--- Escort: alt stops Silmaril, casts an Indi (its GearSwap dismisses the
--- luopan first only when there is one) and follows this character.
--- @param cfg table Sortie config
--- @param args table Words after "escort"
--- @return boolean handled
local function escort(cfg, args)
    local settings = cfg.escort or {}
    local indi = args[1] or settings.indi or 'Indi-Regen'
    -- States per subjob (PLD's Regen mode is a /SCH mode, hidden on the
    -- other subjobs: turned On there it would dress the idle set out of sight)
    local by_sub = settings.states and player and settings.states[player.sub_job]
    if by_sub then set_states(by_sub) end
    to_alt(cfg, 'sm off')
    note({on = false, follow = me()})
    -- The alt starts following only once its Indi- is cast: moving would
    -- interrupt it. Its escort command schedules the follow itself.
    to_alt(cfg, 'gs c escort ' .. indi .. ' ' .. me())
    if messages() then messages().show_escort(cfg.alt, indi, me()) end
    return true
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Handle //gs c sortie ...
--- @param args table Words after "sortie"
--- @return boolean handled
function SortieCommands.handle(args)
    local cfg = config()
    if not cfg then
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_warning('sortie: not set up for this character (_common/combat/SORTIE_CONFIG.lua)')
        end
        return true
    end
    cfg.alt = cfg.alt or ''
    local sub = args[1] and args[1]:lower() or 'list'
    local rest = {}
    for i = 2, #args do rest[#rest + 1] = args[i] end

    local orders = cfg.orders or {}
    if sub == 'list' then
        if messages() then messages().show_target_list(list_entries(cfg)) end
        return true
    elseif sub == 'help' then
        if messages() then messages().show_help(list_entries(cfg), cfg.alt) end
        return true
    elseif sub == 'escort' then
        return escort(cfg, rest)
    elseif orders[sub] then
        local order = orders[sub]
        to_alt(cfg, order.command)
        if order.command == 'sm off' then note({on = false}) end
        if messages() then
            if order.action then messages().show_alt_action(cfg.alt, order.action) else messages().show_alt_off(cfg.alt) end
        end
        return true
    end
    return engage_target(cfg, sub)
end

_G.SortieCommands = SortieCommands

return SortieCommands

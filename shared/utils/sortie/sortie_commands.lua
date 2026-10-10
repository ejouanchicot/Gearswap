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
---   //gs c sortie escort [Indi-X]   alt (stopped, or on its escort profile) dismisses its luopan
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

--- This character's stance and states for a target.
--- @param cfg table Sortie config
--- @param target table Entry of cfg.targets
local function take_stance(cfg, target)
    -- Combat Mode (the weapon lock) goes last: the stance's weapon and the target's shield go on first, then it holds
    -- them; set with them, it would hold the weapons worn before (shared/utils/core/combat_mode.lua)
    local lock
    local function without_lock(list)
        local out = {}
        for _, setting in ipairs(list) do
            if setting:match('^CombatMode%s') then lock = setting else out[#out + 1] = setting end
        end
        return out
    end
    set_states(without_lock((cfg.stances or {})[target.stance] or {}))
    -- Only the states this job has: set_states would otherwise send
    -- `gs c set` and print Mote's unknown-state error.
    set_known_states(without_lock(target_states(cfg, target)))
    if lock and state and rawget(state, 'CombatMode') then
        local ok, CombatMode = pcall(require, 'shared/utils/core/combat_mode')
        if ok and lock:match('On$') and state.CombatMode.value ~= 'On' then CombatMode.lock_after_gear() end
        set_known_states({lock})
    end
end

--- Seconds between Full Circle and the spell that follows it.
local AFTER_FULL_CIRCLE = 1.5

--- Indi- of the profile the alt runs, as far as this module knows: nil after a reload, or once an Indi- was cast
--- by hand without a profile (escort without `escort.profile`, or with an Indi- typed).
local profile_indi = nil

--- True when Silmaril looks after the Indi- itself. It casts a profile's Indi- when its name differs from the
--- previous profile's, never from the Indi- actually up: so only with an escort profile (every Indi- then comes
--- from a profile) and once this module knows which profile runs.
--- @param cfg table Sortie config
--- @return boolean
local function indi_by_bot(cfg)
    return (cfg.escort or {}).profile ~= nil and profile_indi ~= nil
end

--- The alt loads a profile and starts it. Its Indi- is cast by hand only when Silmaril cannot be trusted to
--- (indi_by_bot).
--- @param cfg table Sortie config
--- @param profile string Folder under cfg.profile_root
--- @param indi string|nil The profile's Indi-
local function load_profile(cfg, profile, indi)
    to_alt(cfg, 'sm load ' .. (cfg.profile_root or '') .. profile)
    to_alt(cfg, 'sm follow off')
    to_alt(cfg, 'sm on')
    note({on = true, follow = false})
    if indi and not indi_by_bot(cfg) then to_alt(cfg, '/ma "' .. indi .. '" <me>') end
    profile_indi = indi
end

--- A target with a `prep` profile, once the fight starts (`sortie <target>
--- fight`, sent by the trigger of the prep profile: SORTIE_CONFIG.lua). The
--- alt is stopped (the prep profile would cast its Geo- again), dismisses
--- the prep luopan (a profile never casts a Geo- while one is out), then
--- loads the fight profile like any other load, once Full Circle has gone
--- through (sent with it, the spell is refused).
--- This character's stance is left as it is.
--- @param cfg table Sortie config
--- @param target table Entry of cfg.targets
local function start_fight(cfg, target)
    to_alt(cfg, 'sm off')
    to_alt(cfg, '/ja "Full Circle" <me>')
    coroutine.schedule(function() load_profile(cfg, target.profile, target.indi) end, AFTER_FULL_CIRCLE)
    if messages() then
        messages().show_target_loaded(target.profile, cfg.alt, target.indi, target.summary)
    end
end

--- Stance for this character, profile for the alt, Silmaril on. A target
--- with a `prep` profile loads that one first; `fight` as second word moves
--- on to its own profile.
--- @param cfg table Sortie config
--- @param name string Target as typed
--- @param phase string|nil 'fight', or nil
--- @return boolean handled
local function engage_target(cfg, name, phase)
    local key = (cfg.aliases or {})[name] or name
    local target = cfg.targets[key]
    if not target then
        if messages() then messages().show_unknown_target(name) end
        return true
    end
    if phase == 'fight' then
        if target.prep then start_fight(cfg, target) end
        return true
    end
    take_stance(cfg, target)
    local step = target.prep or target
    load_profile(cfg, step.profile, step.indi)
    if messages() then
        local shown = key ~= name
            and (name:sub(1, 1):upper() .. name:sub(2) .. ' (' .. step.profile .. ')')
            or step.profile
        messages().show_target_loaded(shown, cfg.alt, step.indi, step.summary)
    end
    return true
end

--- Escort with `escort.profile`: the alt dismisses its luopan, loads that profile (Silmaril casts its Indi- and
--- keeps it up, nothing else) and follows this character. Already on that profile, it only follows.
--- @param cfg table Sortie config
--- @param settings table cfg.escort
--- @param indi string The profile's Indi-
local function escort_profile(cfg, settings, indi)
    if profile_indi == indi then
        to_alt(cfg, 'sm follow ' .. me())
    else
        -- Stopped first: the fight profile would cast over Full Circle. The alt's escort command loads the profile
        -- once the luopan is gone, and follows once the Indi- is cast.
        to_alt(cfg, 'sm off')
        to_alt(cfg, 'gs c escort ' .. indi .. ' ' .. me() .. ' ' .. (cfg.profile_root or '') .. settings.profile)
    end
    note({on = true, follow = me()})
    profile_indi = indi
end

--- Escort: the alt puts up an Indi- (its GearSwap dismisses the luopan first
--- only when there is one) and follows this character. With `escort.profile`
--- Silmaril casts that Indi- from the profile; without it, for an Indi- typed
--- after the command, or when this module does not know which profile runs,
--- Silmaril is stopped and the Indi- is cast by hand.
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
    if settings.profile and not args[1] and indi_by_bot(cfg) then
        escort_profile(cfg, settings, indi)
    else
        to_alt(cfg, 'sm off')
        note({on = false, follow = me()})
        -- The alt starts following only once its Indi- is cast: moving would
        -- interrupt it. Its escort command schedules the follow itself.
        to_alt(cfg, 'gs c escort ' .. indi .. ' ' .. me())
        profile_indi = nil
    end
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
            MessageFormatter.show_warning('sortie: not set up for this character (_common/tools/SORTIE_CONFIG.lua)')
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
    return engage_target(cfg, sub, rest[1] and rest[1]:lower())
end

_G.SortieCommands = SortieCommands

return SortieCommands

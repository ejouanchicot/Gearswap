---  ═══════════════════════════════════════════════════════════════════════════
---   Alt Commands - Drive the dual-box alt from the main character
---  ═══════════════════════════════════════════════════════════════════════════
---   Turns a short command typed on the MAIN into a full action performed by
---   the ALT, on the target the MAIN already has:
---
---     //gs c haste   ->  send Kaories input /ma "Haste II" <laststid>
---
---   One line, sent immediately. The `send` addon rewrites `<...id>` into a
---   numeric mob id on THIS client before transmitting, so the alt receives a
---   plain id and never needs the target selected on its own side.
---
---   Targeting is the player's job, not this module's: target the mob, or
---   `/ta <stpc>` an ally to set `lastst`, then fire the command. Nothing is
---   deferred and no event listener is involved.
---
---   Which commands exist is data, not code: each alt job has its own config
---   at `<Character>/config/alt/<JOB>_ALT_COMMANDS.lua`. The config for the
---   job the alt is currently on is the one that answers - swap the alt from
---   COR to RDM and the command set follows automatically.
---
---   @file    shared/utils/dualbox/alt_commands.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-07
---  ═══════════════════════════════════════════════════════════════════════════

local AltCommands = {}

local MessageFormatter = nil
local function messages()
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
    return MessageFormatter
end

--- Log what actually goes out, when `//gs c altdebug` is on.
--- Without this the main's trace shows what it decided but not what it sent,
--- which leaves "did the alt even get the order?" unanswerable.
--- @param cmd string Command name typed by the player
--- @param wire string Exact text handed to send_command
local function trace_sent(cmd, wire)
    local ok, AltBuffReporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
    if ok and AltBuffReporter and AltBuffReporter.trace then
        AltBuffReporter.trace(string.format('//gs c %s  ->  %s', cmd, wire))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   TARGETING
---  ═══════════════════════════════════════════════════════════════════════════

--- Targets that mean something on YOUR screen. They go out as `<...id>`, which
--- the `send` addon rewrites into a numeric mob id on this client, so the alt
--- acts on the entity you are pointing at.
---
--- `lastst` is the default and covers everything: /ta <stpc>, <stnpc> and
--- <stal> all feed the same last-subtarget slot, whatever the entity type.
--- The others stay available for anyone who wants them.
local SHARED_TARGETS = {
    lastst = true, t = true, bt = true, ft = true, scan = true,
}

--- Targets that mean "the alt itself". These must NOT be resolved here: the
--- `send` addon only rewrites `<...id>`, so a literal `<me>` reaches the alt
--- intact and resolves to the alt. Sending `<meid>` instead would resolve to
--- the MAIN's id and aim every self-buff at the wrong character.
local ALT_SIDE_TARGETS = {
    me = '<me>', pet = '<pet>',
}

-- There is deliberately NO cursor mode here.
--
-- GearSwap cannot open a subtarget cursor and wait for it: `input /ta <stal>`
-- returns immediately, and while the cursor is open the game already reports
-- the highlighted entity as the current target - so any polling fires on the
-- first entry the cursor lands on instead of the one you confirm.
--
-- FFXI itself does the waiting, inside a macro. Put the selection on its own
-- line and the next line does not run until you confirm:
--
--     /target <stal>
--     /console gs c indifury
--
-- By then `lastst` holds your pick, so `target = 'lastst'` is all a command
-- needs. This is the same approach the SubTarget addon uses.

--- Command verb per action type.
local ACTION_VERBS = {
    ma = '/ma', ja = '/ja', ws = '/ws', so = '/so',
    item = '/item', pet = '/pet', ra = '/ra',
}

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIG LOADING
---  ═══════════════════════════════════════════════════════════════════════════

-- Cached per job pair, since resolving a config means a require() and a walk
-- over its entries.
local cache = { key = nil, commands = nil }

--- Name of the alt character this main drives.
--- @return string|nil Alt character name, nil when dual-boxing is off
local function get_alt_name()
    local cfg = _G.DualBoxConfig
    if not cfg or not cfg.enabled or cfg.role ~= 'main' then
        return nil
    end
    return cfg.alt_character or cfg.alt_name
end

--- What the alt is playing, and at what level.
---
--- Reads `_G.AltJobState` directly instead of DualBoxManager.get_alt_job():
--- that helper returns nil once the state is older than DualBoxConfig.timeout
--- (30s), but `last_update` is only written on a job CHANGE - so half a minute
--- later it reports the alt as offline forever. That freshness rule exists to
--- grey out the UI; gating commands on it killed them 30s in.
--- @return string|nil job, string|nil subjob, number main_level, number sub_level
local function get_alt_jobs()
    local s = _G.AltJobState
    if not s then
        return nil, nil, 0, 0
    end
    return s.job, s.subjob, s.main_level or 0, s.sub_level or 0
end

--- Pick the highest tier the alt is actually high enough to cast.
---
--- A spell the alt has not learned is not "on recast" - the client simply
--- refuses the command, silently. So the tier has to be chosen here, from the
--- level the alt reported, before anything goes out.
--- @param entry table Command definition carrying a `tiers` list
--- @param level number Level of the job this entry belongs to
--- @return string|nil Spell name, nil when even the base tier is out of reach
local function tier_for_level(entry, level)
    local best, best_level = nil, -1
    for _, t in ipairs(entry.tiers) do
        local need = t.level or 1
        if need <= level and need > best_level then
            best, best_level = t.spell, need
        end
    end
    return best
end

--- Load one job's command table.
--- @param job string Job code
--- @param level number Level the alt has in that job
--- @param source string 'main' or 'sub', recorded on each entry
--- @return table|nil Commands keyed by lowercase name
local function load_job_config(job, level, source)
    if not job or job == '' or job == 'NON' then
        return nil
    end

    local char = (player and player.name) or 'Tetsouo'
    local base = char .. '/config/alt/' .. job:upper()

    local ok, loaded = pcall(require, base .. '_ALT_COMMANDS')
    if not ok or type(loaded) ~= 'table' or type(loaded.commands) ~= 'table' then
        return nil
    end

    -- Merge the hand-written file over the generated one. _ALT_COMMANDS is
    -- rebuilt from game data and any edit to it would be lost; _ALT_CUSTOM is
    -- yours and never regenerated. An entry set to false there removes the
    -- generated command instead of replacing it.
    local merged = {}
    for name, entry in pairs(loaded.commands) do
        merged[name] = entry
    end

    local ok_custom, custom = pcall(require, base .. '_ALT_CUSTOM')
    if ok_custom and type(custom) == 'table' and type(custom.commands) == 'table' then
        for name, entry in pairs(custom.commands) do
            merged[name] = entry or nil
        end
    end

    local out = {}
    for name, entry in pairs(merged) do
        local usable = true

        -- A tiered entry resolves against the level; drop it when nothing in
        -- the chain is reachable (common for a subjob).
        if entry.tiers then
            local spell = tier_for_level(entry, level)
            if spell then
                local copy = {}
                for k, v in pairs(entry) do copy[k] = v end
                copy.spell = spell
                copy.tiers = nil
                entry = copy
            else
                usable = false
            end
        elseif entry.level and entry.level > level then
            usable = false
        end

        if usable then
            entry.source = source
            entry.source_job = job:upper()
            out[name:lower()] = entry
        end
    end
    return out
end

--- Commands available right now: the alt's main job, plus its subjob.
---
--- Both are loaded because a subjob is a real spell list - a GEO/RDM can still
--- Haste and Dia, just at lower tiers. The main wins a name clash, since that
--- is the job whose full kit you asked for.
--- @return table|nil commands, string|nil job
local function load_config()
    local job, subjob, main_level, sub_level = get_alt_jobs()
    if not job then
        return nil, nil
    end

    local key = table.concat({ job, subjob or '-', main_level, sub_level }, '/')
    if cache.key == key then
        return cache.commands, job
    end

    local commands = {}

    -- Sub first, main second: the main overwrites on a name clash.
    local sub_cmds = load_job_config(subjob, sub_level, 'sub')
    if sub_cmds then
        for name, e in pairs(sub_cmds) do commands[name] = e end
    end

    local main_cmds = load_job_config(job, main_level, 'main')
    if main_cmds then
        for name, e in pairs(main_cmds) do commands[name] = e end
    end

    if not next(commands) then
        commands = nil
    end

    cache.key = key
    cache.commands = commands
    return commands, job
end

--- Drop the cached table so the next lookup re-reads the file.
function AltCommands.clear_cache()
    cache.key = nil
    cache.commands = nil
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ACTION BUILDING
---  ═══════════════════════════════════════════════════════════════════════════

--- Resolve the action name, which may be fixed, taken from one of the main's
--- own states, or computed by a function in the config.
--- @param entry table Command definition
--- @param args table Extra words typed after the command
--- @return string|nil Action name, nil when it cannot be resolved
local function resolve_name(entry, args)
    if type(entry.spell) == 'function' then
        local ok, result = pcall(entry.spell, args)
        return ok and result or nil
    end

    if entry.spell_from_state then
        local st = _G.state and state[entry.spell_from_state]
        if st and st.value then
            return tostring(st.value)
        end
        return entry.fallback
    end

    return entry.spell
end

--- Turn a config target into the token that goes out on the wire.
--- A target may be a function, evaluated at command time - that is how a GEO
--- Indi- switches from `me` to `lastst` while the alt holds Entrust.
--- @param target string|function|nil Target from the config
--- @return string|nil Token, or nil when the target is not valid
function AltCommands.token_for(target)
    if type(target) == 'function' then
        local ok, resolved = pcall(target)
        target = ok and resolved or nil
    end

    if type(target) ~= 'string' then
        return nil
    end
    local t = target:lower()
    if ALT_SIDE_TARGETS[t] then
        return ALT_SIDE_TARGETS[t]
    end
    if SHARED_TARGETS[t] then
        return '<' .. t .. 'id>'
    end
    return nil
end

--- Build the `input /ma "Name"` part of one step.
--- @param step table Step definition
--- @param name string Resolved action name
--- @return string Command text without the target
local function build_action(step, name)
    if step.action == 'raw' then
        return name
    end
    local verb = ACTION_VERBS[step.action or 'ma'] or '/ma'
    return string.format('input %s "%s"', verb, name)
end

--- Wrap one step in its own `send`. Every step needs its own send: a `;` after
--- the first one would run on THIS client instead of reaching the alt.
--- @param step table Step definition
--- @param name string Resolved action name
--- @param alt string Alt character name
--- @param default_token string Token used when the step sets no target
--- @return string Command text for this step
local function build_step(step, name, alt, default_token)
    local token = default_token
    if step.target then
        token = AltCommands.token_for(step.target) or token
    end
    return string.format('send %s %s %s', alt, build_action(step, name), token)
end

--- Apply an entry's declared effect on the alt's buff state.
--- Lets a command say "this grants Entrust" / "this eats Entrust" so the main
--- stays right even when the alt is not reporting.
--- @param entry table Command definition
local function apply_buff_effects(entry)
    if not entry.sets_alt_buff and not entry.consumes_alt_buff then
        return
    end

    local ok, AltBuffReporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
    if not ok or not AltBuffReporter then
        return
    end

    if entry.sets_alt_buff then
        AltBuffReporter.assume(entry.sets_alt_buff, entry.alt_buff_duration)
    end
    if entry.consumes_alt_buff then
        AltBuffReporter.consume(entry.consumes_alt_buff)
    end

    -- Ask the alt what actually happened. Sending `/ja "Entrust"` is not the
    -- same as landing it - the alt may be paralysed, mid-cast or on recast -
    -- so a moment later we replace our guess with its real buff list.
    if entry.sync_after then
        coroutine.schedule(function()
            AltBuffReporter.request_sync()
        end, entry.sync_after)
    end
end

--- Build the full command to hand to send_command.
--- @param entry table Command definition
--- @param alt string Alt character name
--- @param args table Extra words typed after the command
--- @param token string Target token or raw id shared by the steps
--- @return string|nil Command text, nil when an action cannot resolve
local function build_command(entry, alt, args, token)
    local steps = entry.chain or { entry }
    local parts = {}

    for _, step in ipairs(steps) do
        local name = resolve_name(step, args)
        if not name then
            return nil
        end
        parts[#parts + 1] = build_step(step, name, alt, token)
    end

    return table.concat(parts, '; wait ' .. (entry.step_delay or 2) .. '; ')
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- Is this a command the alt's current job defines?
--- @param cmd string Command name typed by the player
--- @return boolean True when the command exists in the active config
function AltCommands.is_alt_command(cmd)
    if not cmd or not get_alt_name() then
        return false
    end
    local commands = load_config()
    return commands ~= nil and commands[cmd:lower()] ~= nil
end

--- Run an alt command: resolve the action, target it, send it.
--- @param cmd string Command name
--- @param args table Extra words typed after the command
--- @return boolean True when a command was sent
function AltCommands.execute(cmd, args)
    local alt = get_alt_name()
    if not alt then
        messages().show_error('Alt commands need dual-boxing enabled on this character.')
        return false
    end

    local commands, job = load_config()
    if not commands then
        messages().show_error('No alt command config for ' .. tostring(job or 'offline alt') .. '.')
        return false
    end

    local entry = commands[cmd:lower()]
    if not entry then
        return false
    end

    args = args or {}

    local token = AltCommands.token_for(entry.target or 'lastst')
    if not token then
        messages().show_error('Unknown target "' .. tostring(entry.target) .. '" for ' .. cmd .. '.')
        return false
    end

    local command = build_command(entry, alt, args, token)
    if not command then
        messages().show_error('Cannot build "' .. cmd .. '": check its spell.')
        return false
    end

    send_command(command)
    trace_sent(cmd, command)
    apply_buff_effects(entry)
    return true
end

--- Entry point used by CommonCommands: routes `alt`, `altcmds` and the bare
--- short forms to the right place.
--- @param cmd string Command name typed by the player
--- @param args table Arguments after the command
--- @return boolean True when something was handled
function AltCommands.handle(cmd, args)
    args = args or {}

    if cmd == 'altcmds' or cmd == 'altlist' then
        return AltCommands.list(args[1])
    end

    if cmd == 'alt' then
        if not args[1] then
            return AltCommands.list()
        end
        return AltCommands.execute(args[1], { table.unpack(args, 2) })
    end

    return AltCommands.execute(cmd, args)
end

--- Show every command the alt's current job offers.
--- @return boolean True when a list was displayed
function AltCommands.list(filter)
    local alt = get_alt_name()
    local commands, job = load_config()

    if not alt or not commands then
        messages().show_error('No alt commands available (alt offline or no config).')
        return false
    end

    local names = {}
    for name in pairs(commands) do
        names[#names + 1] = name
    end
    table.sort(names)

    local MessageAlt = require('shared/utils/messages/formatters/ui/message_alt_commands')
    local _, subjob = get_alt_jobs()
    MessageAlt.show_list(alt, job, names, commands, filter, subjob)
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.AltCommands = AltCommands

return AltCommands

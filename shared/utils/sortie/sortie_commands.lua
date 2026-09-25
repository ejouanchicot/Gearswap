---============================================================================
--- Sortie Commands - one GearSwap command per Sortie target
---============================================================================
--- //gs c sortie <target> puts this character in the stance the target needs,
--- then tells the GEO alt which Silmaril profile to load and starts it.
--- Silmaril runs the fight from there (bubbles, BoG, Entrust, positioning,
--- weaponskill); the per-target settings live in its profiles under
--- Settings/Kaories/Sortie/GEO/.
---
--- Commands:
---   //gs c sortie <target>          stance + alt profile (see TARGETS)
---   //gs c sortie escort [Indi-X]   alt stops Silmaril, dismisses its luopan
---                                   if any, casts the Indi (default
---                                   Indi-Regen) and follows this character
---   //gs c sortie off               alt stops Silmaril
---   //gs c sortie judgment          alt weaponskills the party's battle target
---   //gs c sortie fullcircle        alt dismisses its luopan
---   //gs c sortie list              list the targets
---
--- @file    shared/utils/sortie/sortie_commands.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-24
---============================================================================

local SortieCommands = {}

---============================================================================
--- DATA
---============================================================================

--- The GEO alt driven by Silmaril, and where its Sortie profiles live
--- (relative to Windower/Settings, the path `sm load` expects).
local ALT = 'Kaories'
local PROFILE_ROOT = 'Kaories/Sortie/GEO/'

--- This character's stances, as "<state> <value>" pairs.
local STANCES = {
    dps  = {'HybridMode DPS', 'Regen Off', 'MainWeapon Naegling'},
    tank = {'HybridMode Tanking', 'Regen Off'},
}

--- Target -> Silmaril profile of the alt, its Indi- (must match the one set
--- in that profile), this character's stance, and the summary shown.
--- The Indi- is cast on load because Silmaril only recasts one when the new
--- profile's Indi- differs from the previous profile's, not from the one
--- actually up: Farm -> escort (Indi-Regen) -> Farm left Indi-Regen running
--- until it was 30 s from expiring.
local TARGETS = {
    farm       = {profile = 'Farm',       indi = 'Indi-Acumen',  stance = 'dps',  summary = 'Geo-Malaise'},
    umbril     = {profile = 'Umbril',     indi = 'Indi-Fury',    stance = 'dps',  summary = 'Geo-Frailty, no JA'},
    melee      = {profile = 'Melee',      indi = 'Indi-Fury',    stance = 'dps',  summary = 'Geo-Frailty'},
    triboulex  = {profile = 'Triboulex',  indi = 'Indi-Fury',    stance = 'dps',  summary = 'Geo-Frailty + BoG'},
    leshonn    = {profile = 'Leshonn',    indi = 'Indi-Frailty', stance = 'tank', summary = 'Geo-Gravity + BoG, Entrust Fury'},
    gartell    = {profile = 'Gartell',    indi = 'Indi-Frailty', stance = 'tank', summary = 'Geo-Gravity + BoG, Entrust Precision'},
    aita       = {profile = 'Aita',       indi = 'Indi-Frailty', stance = 'tank', summary = 'Geo-Gravity + BoG, Entrust Fury'},
    aminon     = {profile = 'Aminon',     indi = 'Indi-Fury',    stance = 'tank', summary = 'Geo-Frailty + BoG behind (Hysoka engaged), Judgment'},
    aminontest = {profile = 'AminonTest', indi = 'Indi-Fury',    stance = 'tank', summary = 'test on Vampire Leech (Tetsouo engaged)'},
}

--- Bosses fought exactly the same way share one profile.
local ALIASES = {degei = 'melee', skomora = 'melee', ghatjot = 'melee', dhartok = 'melee'}

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
--- @param command string
local function to_alt(command)
    send_command('send ' .. ALT .. ' ' .. command)
end

--- Tell the alt window what was just ordered (on / follow).
--- @param changes table Fields of AltGroup.state()
local function note(changes)
    local ok, AltGroup = pcall(require, 'shared/utils/dualbox/alt_group')
    if ok and AltGroup then AltGroup.note(changes) end
end

--- One entry per target, sorted by name, with the aliases that share it.
--- @return table Array of {name, aliases, indi, summary}
local function list_entries()
    local entries = {}
    for name, target in pairs(TARGETS) do
        local aliases = {}
        for alias, key in pairs(ALIASES) do
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

---============================================================================
--- ACTIONS
---============================================================================

--- Stance for this character, profile for the alt, Silmaril on.
--- @param name string Target as typed
--- @return boolean handled
local function engage_target(name)
    local key = ALIASES[name] or name
    local target = TARGETS[key]
    if not target then
        if messages() then messages().show_unknown_target(name) end
        return true
    end
    set_states(STANCES[target.stance])
    to_alt('sm load ' .. PROFILE_ROOT .. target.profile)
    to_alt('sm follow off')
    to_alt('sm on')
    note({on = true, follow = false})
    to_alt('/ma "' .. target.indi .. '" <me>')
    if messages() then
        local shown = key ~= name
            and (name:sub(1, 1):upper() .. name:sub(2) .. ' (' .. target.profile .. ')')
            or target.profile
        messages().show_target_loaded(shown, ALT, target.indi, target.summary)
    end
    return true
end

--- Escort: alt stops Silmaril, casts an Indi (its GearSwap dismisses the
--- luopan first only when there is one) and follows this character.
--- @param args table Words after "escort"
--- @return boolean handled
local function escort(args)
    local indi = args[1] or 'Indi-Regen'
    set_states({'Regen on'})
    to_alt('sm off')
    note({on = false, follow = me()})
    -- The alt starts following only once its Indi- is cast: moving would
    -- interrupt it. Its escort command schedules the follow itself.
    to_alt('gs c escort ' .. indi .. ' ' .. me())
    if messages() then messages().show_escort(ALT, indi, me()) end
    return true
end

--- One-shot orders for the alt: console command and the action shown
--- (nil action = Silmaril OFF message).
local SIMPLE = {
    off        = {command = 'sm off'},
    judgment   = {command = '/ws "Judgment" <bt>',    action = 'Judgment'},
    fullcircle = {command = '/ja "Full Circle" <me>', action = 'Full Circle'},
}

---============================================================================
--- PUBLIC API
---============================================================================

--- Handle //gs c sortie ...
--- @param args table Words after "sortie"
--- @return boolean handled
function SortieCommands.handle(args)
    local sub = args[1] and args[1]:lower() or 'list'
    local rest = {}
    for i = 2, #args do rest[#rest + 1] = args[i] end

    if sub == 'list' then
        if messages() then messages().show_target_list(list_entries()) end
        return true
    elseif sub == 'help' then
        if messages() then messages().show_help(list_entries(), ALT) end
        return true
    elseif sub == 'escort' then
        return escort(rest)
    elseif SIMPLE[sub] then
        local order = SIMPLE[sub]
        to_alt(order.command)
        if order.command == 'sm off' then note({on = false}) end
        if messages() then
            if order.action then messages().show_alt_action(ALT, order.action) else messages().show_alt_off(ALT) end
        end
        return true
    end
    return engage_target(sub)
end

_G.SortieCommands = SortieCommands

return SortieCommands

---============================================================================
--- Stealth - Sneak / Invisible on every character of the box group
---============================================================================
---   //gs c stealth sneak | invi | both    this character and the others
---   //gs c stealth sneak | invi | both self   this character only, at once:
---                  no other box, no Accession claim, nobody asked
---   //gs c stealth status                 settings and time left
---   //gs c stealth check                  what the key would do now, and why
---   //gs c stealth refresh <s> | alert <s> | overwrite on|off | alerts on|off
---                  | delay <s>
---
--- A Scholar able to cover the whole group with Accession does it at once
--- for everyone and tells the others (stealth_aoe.lua); a box that cannot
--- waits half a second for such a claim (none when no other box has
--- Scholar) before going its own way.
--- Otherwise each box handles itself: the key sends `stealth <kind> local`
--- to the other boxes, and each picks its own best way (stealth_methods.lua):
---   Spectral Jig > spell on itself > ninjutsu > Silent Oil / Prism Powder >
---   Evanessence > a partner that has the spell casts it on this character
--- (`stealth cast <kind> <name>` to the other boxes).
---
--- A buff with more than `refresh_below` seconds left is not cast again,
--- unless `overwrite` is on. One still up is cancelled before the new one
--- (`cancel <buff>`, Cancel addon): a Sneak or Invisible already on blocks
--- the new cast. A box covered by another's Accession cancels its own. Spectral Jig gives both buffs, so it is skipped
--- only when both have that much left. Actions go out one after the other,
--- each given its cast time plus `delay` seconds (queue on `windower`, a
--- newer load drops an older queue).
---
--- @file shared/utils/stealth/stealth.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

local Stealth = {}

local Methods = require('shared/utils/stealth/stealth_methods')
local Timers = require('shared/utils/stealth/stealth_timers')
local Config = require('shared/utils/stealth/stealth_config')
local Aoe = require('shared/utils/stealth/stealth_aoe')
local ActionQueue = require('shared/utils/core/action_queue')

local KINDS = {sneak = true, invi = true}
local PENDING_FOR = 12  -- seconds a buff just asked for counts as coming
local CLAIM_WAIT = 0.5  -- seconds for another box's Accession claim to arrive

local function msg()
    local ok, m = pcall(require, 'shared/utils/messages/formatters/system/message_stealth')
    return ok and m or nil
end

local function others()
    local ok, AltGroup = pcall(require, 'shared/utils/dualbox/alt_group')
    return ok and AltGroup and AltGroup.get_alts() or {}
end

---============================================================================
--- ACTION QUEUE
---============================================================================

--- Longest wait after an action, used only when the game never says it
--- ended: its base cast time plus the `delay` setting (Fast Cast is not
--- counted, so this is on the safe side).
local function wait_after(kind, name)
    return Methods.cast_time(name) + Config.get().delay
end

--- Add an action to this character's queue (shared with //gs c cleanse:
--- shared/utils/core/action_queue.lua), `delay` seconds after each action.
local function push(command, wait)
    ActionQueue.push(command, wait, {delay = Config.get().delay, tag = 'STEALTH'})
end

---============================================================================
--- WHAT THIS CHARACTER NEEDS
---============================================================================

local function pending()
    windower._stealth_pending = windower._stealth_pending or {}
    return windower._stealth_pending
end

local function mark_pending(kind)
    pending()[kind] = os.clock() + PENDING_FOR
end

local BUFF_IDS = {sneak = 71, invi = 69}

--- Whether the buff is on this character now, read from the game: in a
--- scheduled function GearSwap's buffactive can lag behind.
local function is_up(kind)
    local p = windower.ffxi.get_player()
    for _, id in ipairs(p and p.buffs or {}) do
        if id == BUFF_IDS[kind] then return true end
    end
    return false
end

--- A Sneak or Invisible still up blocks a new one, which then does nothing:
--- cancel it first (the Cancel addon's `cancel <buff>`).
local function cancel_if_up(kind)
    if is_up(kind) then push('cancel ' .. Methods.BY_BUFF[kind].buff, 0.5) end
end

--- Whether `kind` should be cast: overwrite, or nothing up, or less than
--- refresh_below left; a buff asked for a moment ago counts as up.
--- Buffs to recast although still up, until os.clock() (see keep_invisible).
local forced = {}

local function needs(kind)
    if (pending()[kind] or 0) > os.clock() then return false end
    if (forced[kind] or 0) > os.clock() then return true end
    local settings = Config.get()
    if settings.overwrite then return true end
    local left = Timers.left(kind)
    if left then return left < settings.refresh_below end
    return not is_up(kind)
end

--- One line per decision in the trace (//gs c trace on).
local FORCE_WINDOW = 10   -- seconds the "recast Invisible anyway" lasts

local function trace(fmt, ...)
    local ok, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok and Trace then Trace.log('STEALTH', fmt, ...) end
end

--- Any action a character makes (spell, item, ability) breaks its own
--- Invisible. Asked for Sneak while Invisible is up, this box would lose it
--- right after: ask for both, Sneak first, and recast Invisible even though
--- it still has time left.
--- @param kinds table 'sneak' / 'invi', in order
--- @return table kinds
local function keep_invisible(kinds)
    local wants_sneak = false
    for _, kind in ipairs(kinds) do
        if kind == 'sneak' then wants_sneak = true end
    end
    if not (wants_sneak and needs('sneak') and is_up('invi')) then return kinds end
    forced.invi = os.clock() + FORCE_WINDOW
    trace('invi: up, recast after sneak (an action breaks it)')
    return {'sneak', 'invi'}
end

--- This character's own best way for one buff (Methods.best_own). Returns
--- true when something went out.
local function use_own(kind)
    local way = Methods.best_own(kind)
    if not way then return false end
    local other = kind == 'sneak' and 'invi' or 'sneak'
    cancel_if_up(kind)
    if way.both then cancel_if_up(other) end
    local command = way.how == 'item' and 'input /item "%s" <me>' or 'input /ma "%s" <me>'
    push(command:format(way.name), wait_after(way.how, way.name))
    mark_pending(kind)
    if way.both then mark_pending(other) end
    trace('%s: own %s', kind, way.name)
    return true
end

--- This character's part for the kinds asked (a list of 'sneak' / 'invi').
--- `alone`: nothing asked of the other boxes when it has no way of its own.
local function handle_self(kinds, alone)
    local wanted = {}
    for _, kind in ipairs(kinds) do
        if needs(kind) then wanted[#wanted + 1] = kind
        else
            trace('%s: skipped, %s', kind, Timers.left(kind) and (Timers.format(Timers.left(kind)) .. ' left') or 'up, time unknown')
            if msg() then msg().show_skipped(Methods.BY_BUFF[kind].buff, Timers.format(Timers.left(kind))) end
        end
    end
    if #wanted == 0 then return end
    -- A dancer only ever uses Spectral Jig: on recast, nothing else (no
    -- oil, powder or spell), it is used again on the next press once ready
    if Methods.has_jig() and not Methods.can_jig() then
        trace('%s: Spectral Jig on recast, %ds', table.concat(wanted, '+'), Methods.jig_recast())
        if msg() then msg().show_jig_recast(Timers.format(Methods.jig_recast())) end
        return
    end
    if Methods.can_jig() then
        cancel_if_up('sneak')
        cancel_if_up('invi')
        push('input /ja "Spectral Jig" <me>', wait_after('ja', 'Spectral Jig'))
        mark_pending('sneak')
        mark_pending('invi')
        trace('%s: Spectral Jig', table.concat(wanted, '+'))
        return
    end
    for _, kind in ipairs(wanted) do
        if not needs(kind) then
            -- an item giving both already covered it
        elseif not use_own(kind) then
            if alone then
                if msg() then msg().show_no_way(Methods.BY_BUFF[kind].buff) end
                return
            end
            cancel_if_up(kind)
            trace('%s: no way of its own, asked the others', kind)
            for _, name in ipairs(others()) do
                send_command(('send %s gs c stealth cast %s %s'):format(name, kind, player.name))
            end
            if msg() then msg().show_asked(Methods.BY_BUFF[kind].buff) end
        end
    end
end

--- `stealth cast <kind> <name>`: a partner has no way of its own.
local function cast_for(kind, name)
    if not (KINDS[kind] and name) then return end
    local spell = Methods.BY_BUFF[kind].spell
    if not Methods.has_spell(kind) then return end
    push(('input /ma "%s" %s'):format(spell, name), wait_after('ma', spell))
end

---============================================================================
--- ONE SCHOLAR FOR THE WHOLE GROUP (stealth_aoe.lua)
---============================================================================

--- Accession + the spell through the Scholar chain, queued like any action.
local function cast_aoe(kind)
    local spell = Methods.BY_BUFF[kind].spell
    cancel_if_up(kind)
    push(function()
        require('shared/utils/scholar/scholar_actions').cast_with_stratagems(spell, nil)
    end, Aoe.chain_time(wait_after('ma', spell)))
    mark_pending(kind)
end

--- The kinds still open once every claim had time to arrive: those another
--- box claimed are covered (its own buff cancelled first), the rest go the
--- usual way.
local function decide(kinds)
    local rest = {}
    for _, kind in ipairs(kinds) do
        local winner = Aoe.winner(kind)
        Aoe.clear(kind)
        if winner and winner:lower() ~= player.name:lower() then
            -- before the Scholar's chain (Arts, Accession) reaches its cast
            cancel_if_up(kind)
            mark_pending(kind)
            trace('%s: covered by %s', kind, winner)
            if msg() then msg().show_covered(Methods.BY_BUFF[kind].buff, winner) end
        else
            rest[#rest + 1] = kind
        end
    end
    if #rest > 0 then handle_self(rest) end
end

--- True when every other box's jobs are known (dual-box job exchange) and
--- none has Scholar: no claim can come, so there is nothing to wait for.
local function nobody_else_scholar(names)
    local ok, AltStates = pcall(require, 'shared/utils/dualbox/alt_states')
    if not (ok and AltStates) then return false end
    for _, name in ipairs(names) do
        local st = AltStates.get(name)
        if not (st and st.job) then return false end
        if st.job == 'SCH' or st.subjob == 'SCH' then return false end
    end
    return true
end

--- This character's part of a key press. What it can cover for the whole
--- group, and needs itself, goes at once. Needing it itself is what stops a
--- second press from spending another stratagem when a member was out of
--- reach: the Scholar is covered by then, claims nothing, and that member,
--- still without the buff, gets it its own way: claimed (the claim reaches the others before the
--- relayed key, so they stand back) and cast; what another box already
--- claimed is covered at once. The rest waits CLAIM_WAIT for a claim.
local function request(kinds)
    local names = others()
    local waiting = {}
    local covering = {}
    for _, kind in ipairs(Aoe.coverable(kinds, names)) do covering[kind] = true end
    for _, kind in ipairs(kinds) do
        local other = Aoe.winner(kind)
        if other and other:lower() ~= player.name:lower() then
            decide({kind})
        elseif covering[kind] and needs(kind) then
            Aoe.trace_distances(names)
            trace('%s: Accession for the group', kind)
            for _, name in ipairs(names) do
                send_command(('send %s gs c stealth claim %s %s'):format(name, kind, player.name))
            end
            cast_aoe(kind)
        else
            waiting[#waiting + 1] = kind
        end
    end
    if #waiting == 0 then return end
    if nobody_else_scholar(names) then
        decide(waiting)
    else
        coroutine.schedule(function() decide(waiting) end, CLAIM_WAIT)
    end
end

---============================================================================
--- SETTINGS AND STATUS
---============================================================================

local function set_setting(key, word)
    local default = Config.DEFAULTS[key]
    local value
    if type(default) == 'boolean' then
        if word == 'on' then value = true elseif word == 'off' then value = false end
    else
        value = tonumber(word)
    end
    if value == nil then
        if msg() then msg().show_usage() end
        return
    end
    local saved = Config.set(key, value)
    if msg() then msg().show_setting(key, value, saved) end
end

local function show_status()
    local ok, InfoBlock = pcall(require, 'shared/utils/messages/info_block')
    if not (ok and InfoBlock) then return end
    local settings = Config.get()
    local fields = {
        {'Refresh below', settings.refresh_below .. ' s'},
        {'Alert before', settings.alert_before .. ' s'},
        {'Overwrite', settings.overwrite},
        {'Alerts', settings.alerts},
        {'Delay', settings.delay .. ' s after each action'},
    }
    local names = {player and player.name}
    for _, name in ipairs(others()) do names[#names + 1] = name end
    for _, name in ipairs(names) do
        fields[#fields + 1] = {name, ('Sneak %s  Invi %s'):format(
            Timers.format(Timers.left('sneak', name)), Timers.format(Timers.left('invi', name)))}
    end
    InfoBlock.show({tag = 'STEALTH', title = 'Sneak / Invisible', fields = fields})
end

---============================================================================
--- CHECK: what the key would do now, without doing it
---============================================================================

--- The action the key would take for `kind` on this character.
local function planned(kind, covering)
    if not needs(kind) then
        local left = Timers.left(kind)
        return left and ('nothing, %s left'):format(Timers.format(left)) or 'nothing, up (time unknown)', 'dim'
    end
    if covering[kind] then return 'Accession for the group', 'good' end
    if Methods.has_jig() then
        local wait = Methods.jig_recast()
        if wait > 0 then return ('Spectral Jig in %s (nothing else)'):format(Timers.format(wait)), 'warn' end
        return 'Spectral Jig', 'good'
    end
    local way = Methods.best_own(kind)
    if way then return way.name, 'good' end
    return 'none of its own: asks the others', 'warn'
end

--- Why Accession is or is not possible.
local function accession_text(status)
    if not status.scholar then return 'no (no Scholar)', 'dim' end
    if not status.allowed then return 'no (SneakInviAOE Off)', 'dim' end
    if status.charges < 1 then return 'no (no stratagem charge)', 'warn' end
    return ('yes (%d charge%s)'):format(status.charges, status.charges > 1 and 's' or ''), 'good'
end

--- //gs c stealth check
local function show_check()
    local ok, InfoBlock = pcall(require, 'shared/utils/messages/info_block')
    if not (ok and InfoBlock) then return end
    local names = others()
    local covering = {}
    for _, kind in ipairs(Aoe.coverable({'sneak', 'invi'}, names)) do covering[kind] = true end
    local settings = Config.get()
    local jobs = ('%s/%s'):format(tostring(player.main_job), tostring(player.sub_job or '-'))
    local fields = {{'Jobs', jobs}}
    for _, kind in ipairs({'sneak', 'invi'}) do
        local label = Methods.BY_BUFF[kind].buff
        local left = Timers.left(kind)
        local up = left and Timers.format(left) or (is_up(kind) and 'up (time unknown)' or 'not up')
        fields[#fields + 1] = {label, up}
        local action, tone = planned(kind, covering)
        fields[#fields + 1] = {'  key would', action, tone}
    end
    local accession, tone = accession_text(Aoe.status())
    fields[#fields + 1] = {'Accession', accession, tone}
    for _, name in ipairs(names) do
        local d = Aoe.distance(name)
        fields[#fields + 1] = {name, ('%s · Sneak %s · Invi %s'):format(
            d and ('%.1f yalms'):format(d) or 'not in zone',
            Timers.format(Timers.left('sneak', name)), Timers.format(Timers.left('invi', name)))}
    end
    fields[#fields + 1] = {'Settings', ('refresh %ds · overwrite %s · delay %gs'):format(
        settings.refresh_below, settings.overwrite and 'on' or 'off', settings.delay)}
    InfoBlock.show({tag = 'STEALTH', title = 'Check (nothing is cast)', fields = fields})
end

---============================================================================
--- COMMAND
---============================================================================

local SETTINGS = {refresh = 'refresh_below', alert = 'alert_before', overwrite = 'overwrite',
                  alerts = 'alerts', delay = 'delay'}

--- //gs c stealth ...
--- @param args table Words after "stealth"
--- @return boolean handled
function Stealth.handle(args)
    local sub = args[1] and args[1]:lower() or 'status'
    if sub == 'sneak' or sub == 'invi' or sub == 'both' then
        local kinds = keep_invisible(sub == 'both' and {'sneak', 'invi'} or {sub})
        local flag = args[2] and args[2]:lower()
        if flag == 'self' then
            handle_self(kinds, true)
            return true
        end
        request(kinds)
        if flag ~= 'local' then
            for _, name in ipairs(others()) do
                send_command(('send %s gs c stealth %s local'):format(name, sub))
            end
        end
    elseif sub == 'claim' then
        if KINDS[args[2] and args[2]:lower()] then Aoe.record(args[2]:lower(), args[3]) end
    elseif sub == 'cast' then
        cast_for(args[2] and args[2]:lower(), args[3])
    elseif sub == 'time' then
        Timers.receive({args[2], args[3], args[4]})
    elseif SETTINGS[sub] then
        set_setting(SETTINGS[sub], args[2] and args[2]:lower())
    elseif sub == 'status' then
        show_status()
    elseif sub == 'check' then
        show_check()
    elseif msg() then
        msg().show_usage()
    end
    return true
end

return Stealth

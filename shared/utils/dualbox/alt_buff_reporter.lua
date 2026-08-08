---  ═══════════════════════════════════════════════════════════════════════════
---   Alt Buff Reporter - the ALT tells the MAIN which buffs it holds
---  ═══════════════════════════════════════════════════════════════════════════
---   The main cannot read an alt's buffs: they only arrive in the 0x076 party
---   packet, and parsing that needs a permanent `incoming chunk` listener - the
---   kind that piles up one per job change in the GearSwap sandbox.
---
---   So the alt reports instead, the same way it already reports its job:
---
---     ALT gains Entrust  ->  send Tetsouo gs c altbuff Entrust 1
---     MAIN receives      ->  _G.AltBuffState['Entrust'] = true
---
---   Only buffs in TRACKED are reported, so this stays quiet during a fight
---   instead of broadcasting every Regen tick.
---
---   Read it from an alt command config with:
---     (_G.AltBuffState or {})['Entrust']
---
---   @file    shared/utils/dualbox/alt_buff_reporter.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-08
---  ═══════════════════════════════════════════════════════════════════════════

local AltBuffReporter = {}

--- Buffs worth telling the main about, keyed by the name GearSwap reports.
--- Add an entry here to make a buff visible to the alt command configs.
local TRACKED = {
    ['Entrust'] = true,          -- GEO: redirects the next Indi- onto an ally
    ['Composure'] = true,        -- RDM: extends enhancing duration on others
    ["Bolter's Roll"] = true,    -- COR
}

---  ═══════════════════════════════════════════════════════════════════════════
---   ALT SIDE - report
---  ═══════════════════════════════════════════════════════════════════════════

--- Is the tracing toggle on? Kept on `windower` so it survives job changes.
--- @return boolean
local function debugging()
    return windower._alt_buff_debug == true
end

--- Where this character's trace is written.
--- One file per character so both sides of a dual-box can be read side by side.
--- @return string Absolute path
local function log_path()
    local who = (player and player.name) or 'unknown'
    return windower.addon_path .. 'data/altbuff_' .. who .. '.log'
end

--- Print a tracing line when `//gs c altdebug` is on, and append it to the log.
--- The file matters more than the chat line: the alt's chat lives in another
--- window, and the log can be read after the fact.
--- @param msg string
local function trace(msg)
    if not debugging() then
        return
    end

    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter then
        MessageFormatter.show_debug('ALTBUFF', msg)
    end

    local fh = io.open(log_path(), 'a')
    if fh then
        fh:write(string.format('[%s] %s\n', os.date('%H:%M:%S'), msg))
        fh:close()
    end
end

--- Write a tracing line from another module (alt_commands logs its sends here
--- so both sides of a dual-box end up in one file per character).
--- @param msg string
function AltBuffReporter.trace(msg)
    trace(msg)
end

--- Toggle tracing, truncating the log when it is turned on.
--- @return boolean New state
--- @return string Path of the log file
function AltBuffReporter.toggle_debug()
    windower._alt_buff_debug = not debugging()

    if windower._alt_buff_debug then
        local fh = io.open(log_path(), 'w')
        if fh then
            fh:write(string.format('=== altbuff trace - %s (%s/%s) - %s ===\n',
                (player and player.name) or '?',
                (player and player.main_job) or '?',
                (player and player.sub_job) or '?',
                os.date('%Y-%m-%d %H:%M:%S')))
            fh:write(string.format('role=%s enabled=%s reporting_seen=%s\n',
                tostring(_G.DualBoxConfig and _G.DualBoxConfig.role),
                tostring(_G.DualBoxConfig and _G.DualBoxConfig.enabled),
                tostring(windower._alt_buff_reporting)))
            fh:close()
        end
    end

    return windower._alt_buff_debug, log_path()
end

--- Tell the main a tracked buff was gained or lost.
--- No-op unless this character is the dual-box ALT, so it is safe to call from
--- any job's buff_change without guarding at the call site.
--- @param buff string Buff name as reported by GearSwap
--- @param gained boolean True on gain, false on loss
--- @return boolean True if something was sent
function AltBuffReporter.report(buff, gained)
    if not buff then
        return false
    end

    if not TRACKED[buff] then
        -- Traced anyway: seeing untracked buffs proves buff_change fires at all,
        -- which is the first thing to check when nothing reaches the main.
        trace(string.format('buff_change %s %s - not tracked, ignored',
            buff, gained and 'gained' or 'lost'))
        return false
    end

    local cfg = _G.DualBoxConfig
    if not cfg or not cfg.enabled or cfg.role ~= 'alt' then
        trace(string.format('%s %s - not sending (role=%s, enabled=%s)',
            buff, gained and 'gained' or 'lost',
            tostring(cfg and cfg.role), tostring(cfg and cfg.enabled)))
        return false
    end

    local main = cfg.main_character or cfg.main_name
    if not main then
        trace(buff .. ' - no main character configured, cannot send')
        return false
    end

    trace(string.format('sending %s=%s to %s', buff, gained and 1 or 0, main))

    -- No quotes around the name: Mote splits `gs c` arguments on plain spaces
    -- (Mote-SelfCommands.lua:12) and does NOT strip quotes, so "Entrust" would
    -- arrive as a key that still has its quote characters. The receiving side
    -- rebuilds multi-word names by joining everything before the value.
    send_command(string.format('send %s gs c altbuff %s %s', main, buff, gained and 1 or 0))
    return true
end

--- Report the state of every tracked buff, up or down.
---
--- Reporting the DOWN ones matters as much as the up ones: without it the main
--- keeps believing in a buff that lapsed while it was not listening.
--- Called on load, on job change, and on demand via `//gs c altsync`.
--- @return number How many buffs were reported
function AltBuffReporter.report_all()
    if not buffactive then
        return 0
    end

    local count = 0
    for buff in pairs(TRACKED) do
        -- buffactive returns a count or `false`, never nil-vs-value, so coerce.
        local up = buffactive[buff] and true or false
        if AltBuffReporter.report(buff, up) then
            count = count + 1
        end
    end
    return count
end

--- Ask the alt to resend everything it holds.
--- Run on the MAIN; the alt answers with one altbuff per tracked buff.
--- @return boolean True if the request was sent
function AltBuffReporter.request_sync()
    local cfg = _G.DualBoxConfig
    if not cfg or not cfg.enabled or cfg.role ~= 'main' then
        return false
    end

    local alt = cfg.alt_character or cfg.alt_name
    if not alt then
        return false
    end

    send_command('send ' .. alt .. ' gs c altbuffsync')
    trace('asked ' .. alt .. ' to resync its buffs')
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN SIDE - receive
---  ═══════════════════════════════════════════════════════════════════════════

--- Store a buff update sent by the alt.
--- Takes the raw argument list because a buff name can contain spaces and Mote
--- splits on spaces: the last word is the value, everything before it is the
--- name. Stray quotes are stripped so a hand-typed command works too.
--- @param args table Arguments after `altbuff`, e.g. {'Bolter\'s', 'Roll', '1'}
--- @return boolean True if a buff was recorded
function AltBuffReporter.receive(args)
    if type(args) ~= 'table' or #args < 2 then
        trace('altbuff arrived but malformed: ' ..
            (type(args) == 'table' and ('{' .. table.concat(args, ', ') .. '}') or type(args)))
        return false
    end

    local value = args[#args]
    local buff = table.concat(args, ' ', 1, #args - 1):gsub('"', '')

    if buff == '' then
        return false
    end

    local up = (value == '1' or value == 'true')

    _G.AltBuffState = _G.AltBuffState or {}
    _G.AltBuffState[buff] = up

    -- A real report always beats a guess, so drop any expiry attached to it.
    if _G.AltBuffExpiry then
        _G.AltBuffExpiry[buff] = nil
    end

    -- Once the alt has reported even once, it is clearly running this module.
    -- From then on its silence is meaningful - see `assume`.
    windower._alt_buff_reporting = true

    trace(string.format('received %s = %s', buff, up and 'UP' or 'down'))
    return true
end

--- Print what the main currently believes about the alt's buffs.
--- Diagnostic for `//gs c altbuffs`.
function AltBuffReporter.show_state()
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local state = _G.AltBuffState

    MessageFormatter.show_debug('ALT', string.format('alt reporting: %s   tracing: %s',
        windower._alt_buff_reporting and 'YES (its buffs are authoritative)'
                                      or 'never seen (falling back to guesses)',
        debugging() and 'on' or 'off'))

    if not state or next(state) == nil then
        MessageFormatter.show_debug('ALT', 'No buff known yet.')
        return
    end

    for buff, up in pairs(state) do
        local expires = _G.AltBuffExpiry and _G.AltBuffExpiry[buff]
        local suffix = ''
        if expires then
            suffix = string.format(' (guessed, %ds left)', math.max(0, math.floor(expires - os.clock())))
        end
        MessageFormatter.show_debug('ALT', string.format('%s = %s%s',
            buff, up and 'UP' or 'down', suffix))
    end
end

--- Record a buff the MAIN just asked for, as a fallback only.
---
--- Sending `/ja "Entrust"` does not mean the alt got it: it may be paralysed,
--- mid-cast, or on recast. So this guess is used ONLY while the alt has never
--- reported anything - which means it is not running this module and silence
--- tells us nothing. As soon as one real report has arrived, the alt's own
--- buffs are authoritative and a failed Entrust correctly leaves the state off.
---
--- The expiry is a second safety net for the no-reporting case.
--- @param buff string Buff name
--- @param seconds number|nil Assume it lapses after this long (nil = no expiry)
--- @return boolean True if the guess was recorded
function AltBuffReporter.assume(buff, seconds)
    if not buff then
        return false
    end

    if windower._alt_buff_reporting then
        trace(string.format('%s not assumed - the alt reports for real', buff))
        return false
    end

    _G.AltBuffState = _G.AltBuffState or {}
    _G.AltBuffState[buff] = true

    _G.AltBuffExpiry = _G.AltBuffExpiry or {}
    _G.AltBuffExpiry[buff] = seconds and (os.clock() + seconds) or nil

    trace(string.format('%s assumed for %ss (alt never reported)', buff, tostring(seconds)))
    return true
end

--- Clear a buff the MAIN just consumed (an Indi- eats Entrust).
--- @param buff string Buff name
function AltBuffReporter.consume(buff)
    if not buff then
        return
    end
    if _G.AltBuffState then
        _G.AltBuffState[buff] = false
    end
    if _G.AltBuffExpiry then
        _G.AltBuffExpiry[buff] = nil
    end
end

--- Is a buff currently up on the alt?
--- Honours the expiry set by `assume`, so a guess that was never confirmed
--- stops being believed instead of latching on.
--- @param buff string Buff name
--- @return boolean
function AltBuffReporter.active(buff)
    if not _G.AltBuffState or _G.AltBuffState[buff] ~= true then
        return false
    end

    local expires = _G.AltBuffExpiry and _G.AltBuffExpiry[buff]
    if expires and os.clock() > expires then
        _G.AltBuffState[buff] = false
        _G.AltBuffExpiry[buff] = nil
        return false
    end

    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.AltBuffReporter = AltBuffReporter

return AltBuffReporter

---============================================================================
--- Ability Queue - one job ability at a time, in a gap left by the bot
---============================================================================
--- Part of AbilityHelper (AbilityHelper.queue). For a character driven by a bot
--- (Silmaril) while this code sends job abilities of its own: the two never knew
--- what the other did, and the game refused one or the other (message 88).
--- Seen in the traces of 2026-11-13/14 (Kaories GEO): four Ecliptic Attrition
--- refused 0-2.5 s after one of the bot's spells; the bot's Last Resort refused
--- 0.7 s after ours; Blaze of Glory sent three times in 2 s on Leshonn.
---
---   queue(ability, opts)  One at a time, by rank (Full Circle > Bolster > Blaze
---                         of Glory > Ecliptic Attrition), never twice the same.
---                         Sent once the bot leaves a gap: no spell under way,
---                         3.5 s after the last spell, 1.5 s after the last job
---                         ability (the bot's too). Checked after it went; sent
---                         again when refused. Dropped when `wanted` stops
---                         holding or after 20 s of waiting.
---   hold_check(spell)     For 1.5 s after one of ours went, a spell reaching the
---                         precast is cancelled (the bot sends it again), so it
---                         does not cut ours. Never Stun, never a spell let
---                         through by allow_next (this code's own recasts).
---   note_end(spell)       From the aftercast: when a spell / an ability ended.
---
--- Times live on `windower` (they outlive a GearSwap load); the queued abilities
--- do not: their checks belong to the load that queued them, and a newer load
--- drops them (windower._load_gen).
---
--- @file    shared/utils/precast/ability_queue.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-14
---============================================================================

local AbilityQueue = {}

local SPELL_GAP = 3.5      -- after a spell ends: a job ability sooner is refused (traces 2026-11-13/14)
local ABILITY_GAP = 1.5    -- after a job ability: the game's own delay between two
local HOLD = 1.5           -- the bot's spells cancelled this long after one of ours went
local CONFIRM = 1.0        -- after sending: time for the recast or the buff to show
local LOOK = 0.5           -- how often a waiting step looks again
local WAIT_MAX = 20        -- seconds an ability waits for its turn and its gap before it is dropped
local TRIES = 3            -- sends of one ability before it is called refused
local ALLOW_FOR = 6        -- seconds an allow_next stays good

--- Order when several wait: lower first. Anything else goes after.
local RANK = {['Full Circle'] = 1, ['Bolster'] = 2, ['Blaze of Glory'] = 3, ['Widened Compass'] = 3,
    ['Ecliptic Attrition'] = 4}

--- Spells never held back.
local NEVER_HELD = {['Stun'] = true}

local items = {}          -- this load's queue
local running = false
local last_look = -math.huge   -- when the queue last looked: a chain silent longer than STALE died
local STALE = 3

local function now() return os.clock() end

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('JA', fmt, unpack(args)) end)
end

local function helper() return require('shared/utils/precast/ability_helper') end

--- A spell under way, or the gap after the last spell / ability not over yet.
--- @return string|nil Why it is busy
function AbilityQueue.busy()
    local t = now()
    local casting = rawget(_G, 'midaction')
    if casting and casting() then return 'casting' end
    if t - (windower._jaq_spell_end or -math.huge) < SPELL_GAP then return 'spell gap' end
    if t - (windower._jaq_ability_end or -math.huge) < ABILITY_GAP then return 'ability gap' end
    return nil
end

local function remove(item, why)
    for i, it in ipairs(items) do
        if it == item then table.remove(items, i) break end
    end
    trace('%s %s', item.ability, why)
    if item.on_end then pcall(item.on_end, why) end
end

local function first()
    table.sort(items, function(a, b)
        if a.rank ~= b.rank then return a.rank < b.rank end
        return a.seq < b.seq
    end)
    return items[1]
end

local step

local function later(delay, gen)
    coroutine.schedule(function() step(gen) end, delay)
end

--- One look at the queue: drop what no longer applies, then the first ability waits, goes, or is checked.
local function look(gen)
    for i = #items, 1, -1 do
        local it = items[i]
        local ok, want = pcall(it.wanted)
        if not ok or not want then remove(it, 'dropped: no longer wanted') end
    end
    local it = first()
    if not it then running = false return end
    local t = now()
    if it.sent_at then
        if t - it.sent_at < CONFIRM then return later(it.sent_at + CONFIRM - t, gen) end
        local ok, did = pcall(it.done)
        if ok and did then remove(it, 'went through') return later(0, gen) end
        if it.tries >= TRIES then remove(it, 'refused ' .. it.tries .. ' times') return later(0, gen) end
        it.sent_at = nil          -- refused: waits for a gap again
    end
    if t > it.deadline then remove(it, 'dropped: no gap within ' .. WAIT_MAX .. ' s') return later(0, gen) end
    local why = AbilityQueue.busy()
    if why then return later(LOOK, gen) end
    -- still wanted but not sendable yet (Ecliptic Attrition before its luopan shows)
    if it.can_send then
        local ok, can = pcall(it.can_send)
        if not (ok and can) then return later(LOOK, gen) end
    end
    if not helper().is_ability_ready(it.ability) then
        -- sent before and on recast now: the game took it, its effect only came late (Blaze of Glory's buff
        -- 1.15 s after, in game 2026-11-14)
        remove(it, it.tries > 0 and 'went through (on recast)' or 'dropped: on recast')
        return later(0, gen)
    end
    it.tries, it.sent_at = it.tries + 1, t
    windower._jaq_hold_until = t + HOLD
    trace('%s sent (try %d)', it.ability, it.tries)
    send_command('input /ja "' .. it.ability .. '" <me>')
    later(CONFIRM, gen)
end

--- A look that fails (a game read during a zone change...) must not kill the chain: the abilities would stay
--- queued, and a Full Circle waiting there cancels the bot's every Geo- (geo_auto_abilities.lua). It looks
--- again a bit later; the 20 s limit still drops them (pre-run review 2026-11-14).
step = function(gen)
    if gen ~= windower._load_gen then running = false return end
    last_look = now()
    local ok, err = pcall(look, gen)
    if not ok then
        trace('look failed: %s', tostring(err))
        later(LOOK, gen)
    end
end

local seq = 0

--- Queue a job ability on this character.
--- @param ability string
--- @param opts table|nil {wanted = fn -> bool (still needed), done = fn -> bool (it went through),
---   can_send = fn -> bool (sent only once true, waited for while wanted), on_end = fn(why) (once, whatever
---   the outcome), rank = number}
--- @return boolean False when that ability is already queued or already done
function AbilityQueue.queue(ability, opts)
    opts = opts or {}
    local done = opts.done or function() return not helper().is_ability_ready(ability) end
    for _, it in ipairs(items) do
        if it.ability == ability then
            trace('%s already queued', ability)
            return false
        end
    end
    local ok, did = pcall(done)
    if ok and did then
        trace('%s already done', ability)
        if opts.on_end then pcall(opts.on_end, 'already done') end
        return false
    end
    seq = seq + 1
    items[#items + 1] = {ability = ability, wanted = opts.wanted or function() return true end, done = done,
        on_end = opts.on_end, can_send = opts.can_send, rank = opts.rank or RANK[ability] or 5, seq = seq, tries = 0,
        deadline = now() + WAIT_MAX}
    trace('%s queued', ability)
    if not running or now() - last_look > STALE then
        running, last_look = true, now()
        later(0, windower._load_gen)
    end
    return true
end

--- Whether that ability waits in the queue.
--- @param ability string
--- @return boolean
function AbilityQueue.queued(ability)
    -- past its 20 s an ability no longer counts, even before a look drops it
    for _, it in ipairs(items) do if it.ability == ability and now() <= it.deadline then return true end end
    return false
end

--- Drop every queued ability.
--- @param why string|nil For the trace
function AbilityQueue.cancel_all(why)
    for i = #items, 1, -1 do remove(items[i], 'dropped: ' .. (why or 'cancelled')) end
end

--- One of our abilities sent outside the queue (a precast chain): the bot's spells are held the same way.
--- @param ability string
function AbilityQueue.sent_outside(ability)
    windower._jaq_hold_until = now() + HOLD
    trace('%s sent outside the queue', ability)
end

--- The next precast of this spell goes through the hold (this code's own recast of it).
--- @param spell_name string
function AbilityQueue.allow_next(spell_name)
    windower._jaq_allow = {spell = spell_name, expires = now() + ALLOW_FOR}
end

--- Precast: a spell inside the hold after one of our abilities is cancelled (the bot sends it again).
--- @param spell table GearSwap spell
--- @param eventArgs table
--- @return boolean True when cancelled
function AbilityQueue.hold_check(spell, eventArgs)
    if spell.action_type ~= 'Magic' then return false end
    local t = now()
    local allow = windower._jaq_allow
    if allow and allow.spell == spell.english and t < allow.expires then
        windower._jaq_allow = nil
        return false
    end
    if t >= (windower._jaq_hold_until or -math.huge) or NEVER_HELD[spell.english] then return false end
    eventArgs.cancel = true
    -- once per spell and hold: a bot sending it again at every frame must not fill the trace
    local logged = windower._jaq_held_logged or {}
    windower._jaq_held_logged = logged
    if logged[spell.english] ~= windower._jaq_hold_until then
        logged[spell.english] = windower._jaq_hold_until
        trace('%s held back (%.1f s left)', tostring(spell.english), windower._jaq_hold_until - t)
    end
    return true
end

--- Aftercast: when this spell or ability ended (the gaps count from there).
--- @param spell table GearSwap spell
function AbilityQueue.note_end(spell)
    if spell.action_type == 'Magic' then
        -- a spell cancelled in its precast (held back, refused) never started: no gap after it
        if spell.interrupted then return end
        windower._jaq_spell_end = now()
    elseif spell.action_type == 'Ability' then
        windower._jaq_ability_end = now()
    end
end

return AbilityQueue

---============================================================================
--- Ability Helper - Auto-Ability Execution Functions
---============================================================================
--- Fires a job ability before a spell or weaponskill, then sends the action
--- once the ability has taken effect.
---   try_ability / try_ability_smart / try_ability_ws - precast auto-trigger
---       (PLD Divine Emblem / Majesty, RDM Saboteur, DNC Climactic Flourish)
---   follow_up / follow_up_or_abort - "ability, then action" chains used by
---       BLM, BRD, DNC, GEO, SAM and the Scholar helpers
---
--- @file    shared/utils/precast/ability_helper.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-05
---============================================================================

local AbilityHelper = {}

-- Set by each job entry point before the job modules load; read once, when
-- this module is first required.
local RECAST_CONFIG = _G.RECAST_CONFIG or {}

--- @param recast number Remaining recast in seconds
--- @return boolean True if ready (RECAST_CONFIG tolerance, else < 1 second)
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        return (recast < 1)  -- Fallback: 1 second tolerance
    end
end

-- Memoization cache for ability lookups.
-- res.job_abilities:with('en', name) is an O(N) scan over ~700 abilities.
-- Each ability name is queried multiple times per WS/precast cycle, so caching
-- the result eliminates the bulk of the cost. The resource DB never changes at
-- runtime, so we never need to invalidate.
local ability_cache = {}

local function get_ability_data(ability_name)
    local cached = ability_cache[ability_name]
    if cached ~= nil then
        return cached or nil  -- false = "looked up, not found"
    end
    local res = require('resources')
    local data = res.job_abilities:with('en', ability_name)
    ability_cache[ability_name] = data or false
    return data
end

--- Check whether the player currently has access to the ability.
--- Reads the same list GearSwap filters outgoing /ja commands against, so it
--- follows job, subjob, level sync and job points.
--- @param ability_name string Ability name (English)
--- @return boolean True if the ability is in the player's current ability list
function AbilityHelper.can_use_ability(ability_name)
    local ability_data = get_ability_data(ability_name)
    if not ability_data then return false end

    local abilities = windower.ffxi.get_abilities()
    local known = abilities and abilities.job_abilities
    if not known then return false end

    for key, value in pairs(known) do
        if value == ability_data.id or (key == ability_data.id and value == true) then
            return true
        end
    end
    return false
end

--- Check whether the ability's recast is ready (RECAST_CONFIG tolerance).
--- @param ability_name string Ability name (English)
--- @return boolean True if ready; false if unknown or on cooldown
function AbilityHelper.is_ability_ready(ability_name)
    local ability_data = get_ability_data(ability_name)
    if not ability_data then return false end

    local ability_recasts = windower.ffxi.get_ability_recasts()
    local recast_id = ability_data.recast_id or ability_data.id
    local cooldown = ability_recasts[recast_id] or 0
    return is_recast_ready(cooldown)
end

--- @param buff_name string Buff name
--- @return boolean True if the buff is active
function AbilityHelper.is_buff_active(buff_name)
    return buffactive[buff_name] or false
end

--- How often the pending follow-up re-reads the game state.
local POLL_INTERVAL = 0.3

--- How long to let the job ability register on its recast before concluding
--- that the game refused it. A refused ability leaves its recast untouched.
local JA_REGISTER_WINDOW = 1.0

local shared_recast_cache = {}

--- Whether an ability owns its recast, or shares it with others.
---
--- The stratagems chained through this helper - Accession, Manifestation and
--- both Addendums - report recast 231, the charge pool every stratagem shares.
--- For them a recast still ready says only that a charge is left, never that
--- this ability failed to fire, so the "never fired" shortcut below must not
--- be applied.
--- @param ability_name string
--- @return boolean True when the recast is shared with another ability
local function has_shared_recast(ability_name)
    local cached = shared_recast_cache[ability_name]
    if cached ~= nil then
        return cached
    end

    local data = get_ability_data(ability_name)
    if not data then
        shared_recast_cache[ability_name] = false
        return false
    end

    local recast_id = data.recast_id or data.id
    local res = require('resources')
    local count = 0
    for _, ability in pairs(res.job_abilities) do
        if type(ability) == 'table' and (ability.recast_id or ability.id) == recast_id then
            count = count + 1
        end
    end

    shared_recast_cache[ability_name] = count > 1
    return shared_recast_cache[ability_name]
end

--- How long past the caller's wait_time to keep waiting for the buff.
--- Only reached when the ability fired but its buff is slow to appear.
local FOLLOW_UP_GRACE = 3.0

--- Invalidates a pending follow-up when another one is started.
--- Kept on `windower`, which outlives the sandbox: a gs reload would otherwise
--- leave an orphaned follow-up believing it is still current.
windower._ability_follow_seq = windower._ability_follow_seq or 0

--- Send the follow-up action once the ability has actually taken effect.
---
--- The old form was `input /ja X; wait N; input /ma Y`, a Windower chain that
--- never looks back: an ability refused during an action lock left the spell
--- to fire without it. Worse, the caller has already run cancel_spell(), so
--- the follow-up is the ONLY thing that will cast - dropping it would leave
--- the player with nothing at all.
---
--- So the follow-up always goes out. What changed is when:
---   • buff up            -> immediately, usually sooner than the old delay
---   • ability never fired -> as soon as that is provable, sooner than before
---   • buff slow          -> once it lands, up to wait_time + grace
---
--- @param ability_name string Ability whose buff we are waiting on
--- @param follow_command string|function Command to send, or a function to run
--- @param wait_time number Caller's original delay, used as the soft deadline
function AbilityHelper.follow_up(ability_name, follow_command, wait_time)
    local function act()
        if type(follow_command) == 'function' then
            follow_command()
        else
            send_command(follow_command)
        end
    end

    windower._ability_follow_seq = windower._ability_follow_seq + 1
    local my_seq = windower._ability_follow_seq

    local started = os.clock()
    local deadline = started + wait_time + FOLLOW_UP_GRACE

    local poll
    poll = function()
        if my_seq ~= windower._ability_follow_seq then
            return
        end

        local now = os.clock()

        -- The buff is up: the ability did its job, go.
        if AbilityHelper.is_buff_active(ability_name) then
            act()
            return
        end

        -- Still off cooldown after long enough to have registered means the
        -- game never accepted it. Nothing more to wait for. Skipped for the
        -- stratagems, whose recast counts charges rather than this one use.
        if now - started >= JA_REGISTER_WINDOW
            and not has_shared_recast(ability_name)
            and AbilityHelper.is_ability_ready(ability_name) then
            act()
            return
        end

        if now >= deadline then
            act()
            return
        end

        coroutine.schedule(poll, POLL_INTERVAL)
    end

    poll()
end

--- Send the follow-up only if the ability landed, and say so when it did not.
---
--- The sibling of follow_up, for the opposite situation. follow_up is for a
--- caller that has already run cancel_spell(): the player's action is gone, so
--- the follow-up has to go out regardless. Use this one when nothing was
--- cancelled and the follow-up alone would be wrong - an Indi- meant for an
--- ally is useless without Entrust, an AoE Sneak becomes a single-target one
--- without Accession. There, casting anyway spends a cast on the wrong thing.
---
--- @param ability_name string Ability whose buff we are waiting on
--- @param follow_command string|function Command to send, or a function to run
--- @param wait_time number Soft deadline before giving up
--- @param on_abort function|nil Run when we give up - for callers holding a
---        flag that the cancelled action's aftercast would otherwise clear
function AbilityHelper.follow_up_or_abort(ability_name, follow_command, wait_time, on_abort)
    local function act()
        if type(follow_command) == 'function' then
            follow_command()
        else
            send_command(follow_command)
        end
    end

    local function give_up(reason)
        if on_abort then
            on_abort()
        end
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_warning(
                ('Cancelled: %s %s'):format(ability_name, reason))
        end
    end

    windower._ability_follow_seq = windower._ability_follow_seq + 1
    local my_seq = windower._ability_follow_seq

    local started = os.clock()
    local deadline = started + (wait_time or 2) + FOLLOW_UP_GRACE

    local poll
    poll = function()
        if my_seq ~= windower._ability_follow_seq then
            return
        end

        if AbilityHelper.is_buff_active(ability_name) then
            act()
            return
        end

        local now = os.clock()

        if now - started >= JA_REGISTER_WINDOW
            and not has_shared_recast(ability_name)
            and AbilityHelper.is_ability_ready(ability_name) then
            give_up('was refused')
            return
        end

        if now >= deadline then
            give_up('never came up')
            return
        end

        coroutine.schedule(poll, POLL_INTERVAL)
    end

    poll()
end

--- Extra time the replay marker outlives the follow-up's own deadline, so the
--- last poll step (POLL_INTERVAL) cannot land after the marker has expired.
local REPLAY_MARGIN = 1.0

--- Whether this action is the one follow_up is re-sending after an ability
--- attempt. Consumes the marker when it matches.
---
--- A refused ability leaves its recast ready and its buff absent, so without
--- this the re-sent action would try the ability again, be cancelled again,
--- and loop for as long as the refusal lasts. The marker lives on `windower`
--- because the follow-up coroutine outlives a gs reload, and so must the
--- memory of what it is re-sending.
--- @param spell table Spell or weaponskill object from GearSwap
--- @return boolean True when the ability must not be tried for this action
local function is_replay(spell)
    local marker = windower._ability_replay
    if not marker then return false end
    if os.clock() >= marker.expires then
        windower._ability_replay = nil
        return false
    end
    if marker.action ~= spell.name then return false end
    windower._ability_replay = nil
    return true
end

--- Whether job abilities are blocked by a debuff PrecastGuard cannot cure.
--- Paralysis is left out: the guard answers it on the ability itself with a
--- Remedy or Panacea, so the ability still gets its one attempt.
--- @return boolean True under Amnesia, Impairment or a debuff blocking everything
local function ja_blocked_without_cure()
    local ok, DebuffChecker = pcall(require, 'shared/utils/debuff/debuff_checker')
    if not ok or not DebuffChecker then return false end
    local blocked, _, message = DebuffChecker.check_ja_blocked()
    return blocked and message ~= 'Paralyzed'
end

--- @param spell table Spell or weaponskill object from GearSwap
--- @param ability_name string Ability to fire first
--- @return boolean True when the ability may be attempted for this action
local function may_try(spell, ability_name)
    if is_replay(spell) then return false end
    if ja_blocked_without_cure() then return false end
    return AbilityHelper.can_use_ability(ability_name)
end

--- Cancel the action, fire the ability, and hand the action to follow_up.
--- @param spell table Spell or weaponskill object from GearSwap
--- @param eventArgs table Event args (handled is set)
--- @param ability_name string Ability to fire first
--- @param wait_time number Soft delay before the action
--- @param replay_command string Command that re-sends the action
local function fire_then_replay(spell, eventArgs, ability_name, wait_time, replay_command)
    eventArgs.handled = true
    cancel_spell()
    send_command(string.format('input /ja "%s" <me>', ability_name))
    windower._ability_replay = {
        action = spell.name,
        expires = os.clock() + wait_time + FOLLOW_UP_GRACE + REPLAY_MARGIN,
    }
    AbilityHelper.follow_up(ability_name, replay_command, wait_time)
end

--- Cancel the spell, fire the ability, then recast the spell once the
--- ability's buff is up (see follow_up). No-op when the ability is not
--- available, on cooldown, or its buff is already active. The ability is
--- tried at most once per spell: the recast sent by follow_up goes out as is.
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (handled is set when the ability fires)
--- @param ability_name string Ability to fire first
--- @param wait_time number|nil Soft delay before the spell (default 2)
function AbilityHelper.try_ability(spell, eventArgs, ability_name, wait_time)
    wait_time = wait_time or 2
    if not may_try(spell, ability_name) then return end

    if AbilityHelper.is_ability_ready(ability_name) and not AbilityHelper.is_buff_active(ability_name) then
        fire_then_replay(spell, eventArgs, ability_name, wait_time,
            string.format('input /ma "%s" %s', spell.name, spell.target.id))
    end
end

--- Same outcome as try_ability; checks the buff before reading the recast.
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (handled is set when the ability fires)
--- @param ability_name string Ability to fire first
--- @param wait_time number|nil Soft delay before the spell (default 2)
function AbilityHelper.try_ability_smart(spell, eventArgs, ability_name, wait_time)
    wait_time = wait_time or 2
    if not may_try(spell, ability_name) then return end
    if AbilityHelper.is_buff_active(ability_name) then return end

    if AbilityHelper.is_ability_ready(ability_name) then
        fire_then_replay(spell, eventArgs, ability_name, wait_time,
            string.format('input /ma "%s" %s', spell.name, spell.target.id))
    end
end

--- Weaponskill variant: cancel the WS, fire the ability, then resend the WS
--- on <t> once the ability's buff is up.
--- @param spell table Weaponskill object from GearSwap
--- @param eventArgs table Event args (handled and cancel are set when it fires)
--- @param ability_name string Ability to fire first
--- @param wait_time number|nil Soft delay before the WS (default 2)
function AbilityHelper.try_ability_ws(spell, eventArgs, ability_name, wait_time)
    wait_time = wait_time or 2
    if not may_try(spell, ability_name) then return end

    if AbilityHelper.is_ability_ready(ability_name) and not AbilityHelper.is_buff_active(ability_name) then
        eventArgs.cancel = true  -- the WS is resent by follow_up after the ability
        fire_then_replay(spell, eventArgs, ability_name, wait_time,
            string.format('input /ws "%s" <t>', spell.name))
    end
end

return AbilityHelper

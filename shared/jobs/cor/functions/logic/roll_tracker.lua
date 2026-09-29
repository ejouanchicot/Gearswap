---  ═══════════════════════════════════════════════════════════════════════════
---   COR Roll Tracker - Smart Roll Tracking and Display
---  ═══════════════════════════════════════════════════════════════════════════
---   Tracks Phantom Rolls cast by the player and provides intelligent feedback:
---   - Receives rolls from PartyTracker's action listener (on_roll_cast)
---   - Calculates exact bonuses including gear/job bonuses and Crooked Cards
---   - Reads the party job cache that PartyTracker fills from 0xDD/0xDF
---   - Displays Lucky/Unlucky status with formatted messages
---   - Flags a Natural 11 in the result message
---   - Double-Up window status (45 seconds, //gs c doubleup)
---   - Bust rate of the next Double-Up
---   - Non-cumulative Phantom Roll +X gear (only highest bonus applies)
---   - Job bonus: COR main/sub, the dual-box partner, or a party member's
---     main job (a Tricorne proc is not counted, see roll_has_job_bonus)
---
---   @file    shared/jobs/cor/functions/logic/roll_tracker.lua
---   @author  ejouanchicot
---   @version 1.3
---   @date    Created: 2025-10-08
---   @date    Updated: 2025-10-09 - Added automatic party job detection
---   @date    Updated: 2026-09-29 - Party side moved to roll_party.lua,
---            messages to roll_display.lua
---   @requires roll_data, roll_party, roll_display, MessageFormatter
---  ═══════════════════════════════════════════════════════════════════════════

local RollTracker = {}

-- Load dependencies
local RollData = require('shared/jobs/cor/functions/logic/roll_data')
local MessageFormatter = require('shared/utils/messages/message_formatter')
local RollParty = require('shared/jobs/cor/functions/logic/roll_party')
local RollDisplay = require('shared/jobs/cor/functions/logic/roll_display')

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE TRACKING
---  ═══════════════════════════════════════════════════════════════════════════

-- Active rolls (up to 2 max - FFXI hard limit)
if not _G.cor_active_rolls then
    _G.cor_active_rolls = {}
end

-- Last roll data (for Double-Up)
if not _G.cor_last_roll then
    _G.cor_last_roll = {
        name = nil,
        value = nil,
        timestamp = nil,
        affected_count = nil,  -- Party members affected (recounted on every cast)
        total_count = nil,     -- Total party members (recounted on every cast)
        missed_names = nil      -- Names of party members who missed the roll
    }
end

-- Natural 11 tracking
if not _G.cor_natural_eleven_active then
    _G.cor_natural_eleven_active = false
end

-- Duplicate prevention for roll messages (Windower action event fires multiple times)
if not _G.cor_last_roll_display then
    _G.cor_last_roll_display = {
        name = nil,
        value = nil,
        timestamp = nil
    }
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ROLL DETECTION (Packet Parsing)
---  ═══════════════════════════════════════════════════════════════════════════

--- Last value seen of each roll, kept on `windower`: it outlives a gs reload
--- and a job change, where _G.cor_active_rolls does not (cleanup() empties
--- it on purpose at every COR load). A //lua reload still loses it.
--- @return table roll name -> {value, timestamp, has_crooked}
local function saved_rolls()
    windower._cor_roll_values = windower._cor_roll_values or {}
    return windower._cor_roll_values
end

--- Longest a roll can last (5 min base, lengthened by gear), in seconds. A
--- saved value older than this belongs to an earlier cast of that roll.
local ROLL_MAX_DURATION = 600

--- Names of the rolls the player wears now, from buffactive's buff ids.
--- @return table roll name -> true
local function worn_rolls()
    local ok, res = pcall(require, 'resources')
    local worn = {}
    if not ok or not res or not res.buffs then return worn end
    for key in pairs(buffactive or {}) do
        local buff = type(key) == 'number' and res.buffs[key]
        if buff and buff.en and buff.en:find(' Roll$') then worn[buff.en] = true end
    end
    return worn
end

--- Rebuild the active roll list from the roll buffs the player wears.
---
--- After a reload the list starts empty although rolls may still be up: the
--- tracker only learns a roll when it sees it cast. The buffs say which rolls
--- run; the value comes back from saved_rolls() when it is recent, else it is
--- unknown (nil). Entries whose buff is gone are dropped.
function RollTracker.sync_with_buffs()
    local worn = worn_rolls()
    local listed = {}
    for i = #_G.cor_active_rolls, 1, -1 do
        local name = _G.cor_active_rolls[i].name
        if worn[name] then listed[name] = true else table.remove(_G.cor_active_rolls, i) end
    end
    for name in pairs(worn) do
        if not listed[name] then
            local saved = saved_rolls()[name]
            local recent = saved and saved.timestamp and (os.time() - saved.timestamp) <= ROLL_MAX_DURATION
            table.insert(_G.cor_active_rolls, {
                name = name,
                value = recent and saved.value or nil,
                timestamp = recent and saved.timestamp or nil,
                has_crooked = recent and saved.has_crooked or false,
            })
        end
    end
end

---   A roll's buff has dropped, so the roll is gone
---
---   Nothing else removes an entry: a bust discards its own roll, and a third
---   roll pushes out the oldest, but a roll that simply wears off used to stay
---   listed forever. Dropping it here is what makes "lost" mean lost - the
---   Crooked flag goes with the entry, so the next cast of that roll starts
---   clean instead of inheriting from the instance that expired.
---
---   buff_change hands over the name from res.buffs, which is the roll's own
---   name, so no mapping is needed.
---   @param buff_name string Buff that was lost
---   @return boolean True when a roll was removed
function RollTracker.on_roll_buff_lost(buff_name)
    for i, roll in ipairs(_G.cor_active_rolls) do
        if roll.name == buff_name then
            table.remove(_G.cor_active_rolls, i)
            return true
        end
    end
    return false
end

--- Is the job this roll favours actually in the party?
---
--- The Tricorne proc is deliberately not counted: there is no way to detect
--- whether it fired, so the message only claims a job bonus when the job is
--- really there. The game applies the proc regardless.
--- @param roll_data table Roll definition carrying job_bonus
--- @return boolean
local function roll_has_job_bonus(roll_data)
    return RollTracker.is_job_in_party_zone(roll_data.job_bonus[1]) and true or false
end

--- Does the roll's own record carry Crooked? See crooked_applies for why the
--- record, and not buffactive, is what remembers.
--- @param roll_name string Roll being cast
--- @return boolean
local function roll_already_crooked(roll_name)
    for _, roll in ipairs(_G.cor_active_rolls) do
        if roll.name == roll_name and roll.has_crooked then
            return true
        end
    end
    return false
end

--- Has this exact roll and value just been reported?
---
--- Windower's action event fires more than once for a single roll, so without
--- this the same result prints two or three times. 500ms is long enough to
--- swallow the repeats and short enough that a real Double-Up, which cannot
--- come that fast, still gets through.
--- @return boolean
local function is_duplicate_report(roll_name, roll_value, current_time)
    local last = _G.cor_last_roll_display
    return last.name == roll_name
        and last.value == roll_value
        and last.timestamp ~= nil
        and (current_time - last.timestamp) < 0.5
end

--- Is this roll already running, so this cast is a Double-Up of it?
---
--- The action packet cannot tell the two apart - a Double-Up arrives as the
--- roll it doubles - but the game itself settles it: a roll cannot be re-cast
--- while it is still up. So the roll's buff being on the player means this
--- cast can only be a Double-Up.
---
--- The buff is the authority on whether the roll is up; the active list only
--- remembers what it was rolled at. on_roll_buff_lost keeps the two in step,
--- and checking both means a loss event that never arrives - a reload or a
--- zone mid-roll - cannot leave a stale entry answering for a live one.
--- @return boolean
local function roll_is_active(roll_name)
    for _, roll in ipairs(_G.cor_active_rolls or {}) do
        if roll.name == roll_name then
            return buffactive[roll_name] and true or false
        end
    end
    return false
end

--- Does Crooked Cards apply to this cast?
---
--- Crooked is a property of the ROLL. The buff leaves the player the instant
--- the Phantom Roll goes out, so the roll's own record carries it from then
--- on - which is why a Double-Up stays crooked long after the buff is gone.
---
--- Only a fresh Phantom Roll can pick Crooked up: a Double-Up of a roll that
--- is not crooked stays that way, and leaves the buff for the next real roll.
--- @param roll_name string
--- @param is_new_roll boolean False when this cast is a Double-Up
--- @return boolean
local function crooked_applies(roll_name, is_new_roll)
    -- A Double-Up adds to the roll already running, so that roll's record is
    -- the only thing that can say Crooked is on it.
    if not is_new_roll then
        return roll_already_crooked(roll_name)
    end

    -- A fresh Phantom Roll replaces whatever was there, stale flag included.
    -- Only the buff counts.
    if not _G.cor_crooked_timestamp then
        return false
    end

    if buffactive['Crooked Cards'] then
        return true
    end

    -- Buff gone but recent: it was consumed by this very roll.
    return (os.time() - _G.cor_crooked_timestamp) <= 60
end

--- The active-roll record for a roll, or nil.
--- @param roll_name string
--- @return table|nil
local function find_active_roll(roll_name)
    for _, roll in ipairs(_G.cor_active_rolls or {}) do
        if roll.name == roll_name then
            return roll
        end
    end
    return nil
end

--- "Phantom Roll +" gear and job bonus that apply to this cast.
---
--- Both are settled per roll, not per cast (BG-Wiki, Phantom Roll):
--- gear counts from the cast it was worn on - the Phantom Roll or a Double-Up -
--- and stays for the Double-Ups after it even once removed, so a Double-Up
--- keeps the best value seen so far. The job bonus is decided by the initial
--- Phantom Roll only; a job joining afterwards cannot add it with Double-Up.
--- @param roll_name string
--- @param roll_data table|nil Roll definition
--- @param is_new_roll boolean False when this cast is a Double-Up
--- @return number gear bonus, boolean job bonus
local function roll_bonus_sources(roll_name, roll_data, is_new_roll)
    local gear_now = RollTracker.get_phantom_roll_bonus()
    local record = not is_new_roll and find_active_roll(roll_name) or nil

    if record and record.gear_bonus ~= nil then
        return math.max(record.gear_bonus, gear_now), record.job_bonus or false
    end

    local has_job_bonus = roll_data and roll_data.job_bonus
        and roll_has_job_bonus(roll_data) or false
    return gear_now, has_job_bonus
end

--- The bonus this roll grants, job bonus and Crooked included.
--- @param gear_bonus number "Phantom Roll +" value that applies
--- @param has_job_bonus boolean Whether the job bonus applies
--- @return number bonus
local function compute_bonus(roll_name, roll_value, is_crooked, gear_bonus, has_job_bonus)
    local player_job = player and player.main_job or 'COR'

    local bonus = RollData.calculate_bonus(roll_name, roll_value, player_job,
                                           gear_bonus, has_job_bonus)

    if is_crooked then
        bonus = bonus * 1.2
    end

    return bonus
end

--- Record the roll as the one now in effect.
---
--- The fields are assigned rather than the table replaced: other modules hold
--- a reference to cor_last_roll and would keep reading the old one.
local function record_last_roll(roll_name, roll_value, affected_count,
                                total_count, missed_names)
    local last = _G.cor_last_roll
    last.name = roll_name
    last.value = roll_value
    last.timestamp = os.time()
    last.affected_count = affected_count
    last.total_count = total_count
    last.missed_names = missed_names
end

--- Spend the Crooked Cards timestamp once a roll has used it.
---
--- Crooked belongs to the ROLL, not to the player. The buff leaves the player
--- the instant the roll goes out, but the roll keeps the property until
--- another roll pushes it out of the active list - which is why a Double-Up of
--- a crooked roll is still crooked long after the buff is gone.
---
--- The timestamp only covers the one cast between the buff vanishing and
--- track_active_roll stamping the roll. The Phantom Roll that read it spends
--- it: left standing, its 60s window would hand Crooked to the next roll.
--- A Double-Up spends nothing, so it cannot waste a buff meant for the next
--- real roll.
--- @param is_crooked boolean Whether Crooked applies to this cast
--- @param is_new_roll boolean False when this cast is a Double-Up
local function consume_crooked(is_crooked, is_new_roll)
    if is_crooked and is_new_roll then
        _G.cor_crooked_timestamp = nil
    end
end

--- Note an 11 and report it.
---
--- An 11 resets the timer, drops every roll's recast to 30s and removes the
--- bust DEBUFF - you can still roll a 12, it just costs nothing. It holds
--- while ANY 11 is up, so the flag is set here and cleared elsewhere.
--- @return boolean
local function note_natural_eleven(roll_value)
    if roll_value ~= 11 then
        return false
    end
    _G.cor_natural_eleven_active = true
    return true
end

--- The job-bonus entry to show, when the party actually has that job.
--- @return table|nil
local function job_bonus_entry(roll_data, has_job_bonus)
    if roll_data and roll_data.job_bonus and has_job_bonus then
        return roll_data.job_bonus[1]
    end
    return nil
end

---   Handle a roll landing: record it, work out the bonus, and report it
---   @param roll_name string Name of the roll
---   @param roll_value number Value rolled, 1-12
---   @param target_ids table|nil Set of the ids the roll reached (its action
---          packet); nil when unknown (//gs c roll typed by hand)
function RollTracker.on_roll_cast(roll_name, roll_value, target_ids)
    local current_time = os.clock()
    if is_duplicate_report(roll_name, roll_value, current_time) then
        return
    end

    _G.cor_last_roll_display.name = roll_name
    _G.cor_last_roll_display.value = roll_value
    _G.cor_last_roll_display.timestamp = current_time

    -- Read before track_active_roll rewrites the record below.
    local is_new_roll = not roll_is_active(roll_name)

    if roll_value == 12 then
        -- The busted roll is lost, and a fresh Phantom Roll spent the buff on
        -- its way out - it never reaches track_active_roll, so nothing else
        -- would clear the timestamp and the next roll would inherit Crooked.
        -- A Double-Up that busts spent nothing.
        if is_new_roll then
            _G.cor_crooked_timestamp = nil
        end
        RollTracker.handle_bust(roll_name)
        return
    end

    -- Recounted every cast: members move in and out of range between rolls.
    local affected_count, total_count, missed_names =
        RollTracker.count_party_members_with_buff(roll_name, target_ids)
    record_last_roll(roll_name, roll_value, affected_count, total_count, missed_names)

    local roll_data = RollData.get_roll(roll_name)
    local is_crooked = crooked_applies(roll_name, is_new_roll)
    local gear_bonus, has_job_bonus = roll_bonus_sources(roll_name, roll_data, is_new_roll)
    local final_bonus = compute_bonus(roll_name, roll_value, is_crooked,
                                      gear_bonus, has_job_bonus)
    consume_crooked(is_crooked, is_new_roll)

    local is_natural_eleven = note_natural_eleven(roll_value)

    RollTracker.track_active_roll(roll_name, roll_value, is_crooked, is_new_roll,
                                  gear_bonus, has_job_bonus)
    RollTracker.display_roll_result(roll_name, roll_value, final_bonus,
        roll_data and roll_data.effect_type or '',
        RollData.is_lucky(roll_name, roll_value),
        RollData.is_unlucky(roll_name, roll_value),
        is_natural_eleven,
        -- The rate shown is for the NEXT Double-Up, not this roll.
        RollData.calculate_bust_rate(roll_value),
        job_bonus_entry(roll_data, has_job_bonus), is_crooked, missed_names)
end

---   Track active roll in state
---   @param roll_name string Name of the roll
---   @param roll_value number Value of the roll
---   @param has_crooked boolean If this roll has Crooked Cards attached
---   @param is_new_roll boolean|nil True for a fresh Phantom Roll, false for a Double-Up
---   @param gear_bonus number|nil "Phantom Roll +" value settled for this roll
---   @param has_job_bonus boolean|nil Job bonus settled at the initial roll
function RollTracker.track_active_roll(roll_name, roll_value, has_crooked, is_new_roll,
                                       gear_bonus, has_job_bonus)
    -- Find existing roll or add new
    local found = false
    for i, roll in ipairs(_G.cor_active_rolls) do
        if roll.name == roll_name then
            roll.value = roll_value
            roll.timestamp = os.time()
            -- A fresh Phantom Roll replaces the old one, Crooked included, so
            -- a re-roll cannot inherit it from the instance that wore off. A
            -- Double-Up only adds to what is there and keeps the flag - as
            -- does the buff-detection path, which passes no is_new_roll.
            if is_new_roll then
                roll.has_crooked = has_crooked or false
            elseif has_crooked then
                roll.has_crooked = true
            end
            if gear_bonus ~= nil then
                roll.gear_bonus = gear_bonus
                roll.job_bonus = has_job_bonus or false
            end
            found = true
            break
        end
    end

    if not found then
        table.insert(_G.cor_active_rolls, {
            name = roll_name,
            value = roll_value,
            timestamp = os.time(),
            has_crooked = has_crooked or false,
            gear_bonus = gear_bonus,
            job_bonus = has_job_bonus or false
        })
    end

    -- Limit to 2 rolls max (FFXI hard limit - Crooked Cards does NOT allow 3rd roll)
    if #_G.cor_active_rolls > 2 then
        table.remove(_G.cor_active_rolls, 1) -- Remove oldest
    end

    -- Remember the value past a reload (see sync_with_buffs)
    for _, roll in ipairs(_G.cor_active_rolls) do
        if roll.name == roll_name then
            saved_rolls()[roll_name] = {value = roll.value, timestamp = roll.timestamp, has_crooked = roll.has_crooked}
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   BUST HANDLING
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle bust (roll value 12)
---   @param roll_name string Name of the roll that busted
function RollTracker.handle_bust(roll_name)
    -- Get roll data
    local roll_data = RollData.get_roll(roll_name)
    if not roll_data then
        return
    end

    -- Remove roll from active rolls
    for i, roll in ipairs(_G.cor_active_rolls) do
        if roll.name == roll_name then
            table.remove(_G.cor_active_rolls, i)
            break
        end
    end

    -- Clear Natural 11 status
    _G.cor_natural_eleven_active = false

    -- Display bust message
    MessageFormatter.show_roll_bust(roll_name, roll_data.bust_effect, roll_data.effect_type)
    pcall(function() require('shared/utils/dualbox/roll_share').bust(roll_name, roll_data.bust_effect, roll_data.effect_type) end)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PARTY AND DISPLAY (roll_party.lua, roll_display.lua)
---  ═══════════════════════════════════════════════════════════════════════════

-- Re-exported on RollTracker, and called through it below: callers and the
-- offline tests (scripts/audit/difftest_rolltracker.lua) replace them there.
RollTracker.validate_party_cache = RollParty.validate_party_cache
RollTracker.is_job_in_party_zone = RollParty.is_job_in_party_zone
RollTracker.count_party_members_with_buff = RollParty.count_party_members_with_buff
RollTracker.display_roll_result = RollDisplay.display_roll_result
RollTracker.display_double_up_status = RollDisplay.display_double_up_status

---  ═══════════════════════════════════════════════════════════════════════════
---   BONUS CALCULATION
---  ═══════════════════════════════════════════════════════════════════════════

--- Highest "Phantom Roll +" value in the gear worn right now (roll_gear.lua)
--- @return number
function RollTracker.get_phantom_roll_bonus()
    return require('shared/jobs/cor/functions/logic/roll_gear').bonus()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CLEANUP
---  ═══════════════════════════════════════════════════════════════════════════

---   Clear Natural 11 status when buff lost
function RollTracker.clear_natural_eleven()
    _G.cor_natural_eleven_active = false
end

---   Clear last roll data
function RollTracker.clear_last_roll()
    _G.cor_last_roll.name = nil
    _G.cor_last_roll.value = nil
    _G.cor_last_roll.timestamp = nil
    _G.cor_last_roll.affected_count = nil
    _G.cor_last_roll.total_count = nil
    _G.cor_last_roll.missed_names = nil
end

---   Clear all roll tracking state
function RollTracker.clear_all()
    _G.cor_active_rolls = {}
    RollTracker.clear_last_roll()
    RollTracker.clear_natural_eleven()
end

---   Complete cleanup of ALL RollTracker state (for job changes)
---   Called from file_unload() when changing from COR to another job
function RollTracker.cleanup()
    -- Clear active rolls
    _G.cor_active_rolls = {}

    -- Clear last roll state
    _G.cor_last_roll = {
        name = nil,
        value = nil,
        timestamp = nil,
        affected_count = nil,
        total_count = nil,
        missed_names = nil
    }

    -- Clear display duplicate prevention
    _G.cor_last_roll_display = {
        name = nil,
        value = nil,
        timestamp = nil
    }

    -- Clear Natural 11 tracking
    _G.cor_natural_eleven_active = false

    -- Clear Crooked Cards timestamp
    _G.cor_crooked_timestamp = nil

    -- Party jobs are deliberately NOT cleared here. They live in the windower
    -- table so they survive a reload; wiping them on unload would defeat that
    -- and put us back to learning every member's job from scratch.
    -- //gs c clearparty is the way to drop them on purpose.
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return RollTracker

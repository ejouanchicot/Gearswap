---  ═══════════════════════════════════════════════════════════════════════════
---   COR Roll Tracker - Smart Roll Tracking and Display
---  ═══════════════════════════════════════════════════════════════════════════
---   Tracks Phantom Rolls cast by the player and provides intelligent feedback:
---   - Detects rolls via action packets (category 6)
---   - Calculates exact bonuses including gear/job bonuses
---   - Automatic party member job detection via packet parsing (0xDD/0xDF)
---   - Displays Lucky/Unlucky status with formatted messages
---   - Tracks Natural 11 benefits (instant recast + 30s recast + bust immunity)
---   - Monitors Double-Up windows (45 seconds)
---   - Calculates bust rates with color-coded warnings
---   - Non-cumulative Phantom Roll +X gear (only highest bonus applies)
---   - Job bonus detection: COR main/sub OR any party member OR Tricorne proc
---
---   @file    jobs/cor/functions/logic/roll_tracker.lua
---   @author  Tetsouo
---   @version 1.2
---   @date    Created: 2025-10-08
---   @date    Updated: 2025-10-09 - Added automatic party job detection
---   @requires roll_data, MessageFormatter
---  ═══════════════════════════════════════════════════════════════════════════

local RollTracker = {}

-- Load dependencies
local RollData = require('shared/jobs/cor/functions/logic/roll_data')
local MessageFormatter = require('shared/utils/messages/message_formatter')

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
        affected_count = nil,  -- Party members affected (calculated only on initial roll)
        total_count = nil,     -- Total party members (calculated only on initial roll)
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

---   Detect roll via buff application (more reliable for GearSwap)
---   Called from job_buff_change when roll buff is gained
---   @param buff_name string Name of the buff (e.g., "Fighter's Roll")
---   @return boolean True if roll was tracked
function RollTracker.on_roll_buff_gained(buff_name)
    -- Check if buff is a Phantom Roll
    if not buff_name:endswith(' Roll') then
        return false
    end

    -- Get roll data
    local roll_data = RollData.get_roll(buff_name)
    if not roll_data then
        return false
    end

    -- Since we can't get the exact value from buff alone, we'll track it when cast
    -- This function is called AFTER the roll, so we use last_roll data
    if _G.cor_last_roll and _G.cor_last_roll.name == buff_name then
        RollTracker.track_active_roll(buff_name, _G.cor_last_roll.value)
    end

    return true
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
--- The active list is checked too, because nothing ever expires an entry from
--- it: a roll that wore off is still listed, and it is the buff that says it
--- is gone. A roll's buff carries the roll's own name.
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

--- The bonus this roll grants, job bonus and Crooked included.
--- @return number bonus, boolean whether a job bonus applied
local function compute_bonus(roll_name, roll_value, roll_data, is_crooked)
    local phantom_roll_bonus = RollTracker.get_phantom_roll_bonus()
    local player_job = player and player.main_job or 'COR'

    local has_job_bonus = false
    if roll_data and roll_data.job_bonus then
        has_job_bonus = roll_has_job_bonus(roll_data)
    end

    local bonus = RollData.calculate_bonus(roll_name, roll_value, player_job,
                                           phantom_roll_bonus, has_job_bonus)

    if is_crooked then
        bonus = bonus * 1.2
    end

    return bonus, has_job_bonus
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
function RollTracker.on_roll_cast(roll_name, roll_value)
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
        RollTracker.count_party_members_with_buff(roll_name)
    record_last_roll(roll_name, roll_value, affected_count, total_count, missed_names)

    local roll_data = RollData.get_roll(roll_name)
    local is_crooked = crooked_applies(roll_name, is_new_roll)
    local final_bonus, has_job_bonus = compute_bonus(roll_name, roll_value,
                                                     roll_data, is_crooked)
    consume_crooked(is_crooked, is_new_roll)

    local is_natural_eleven = note_natural_eleven(roll_value)

    RollTracker.track_active_roll(roll_name, roll_value, is_crooked, is_new_roll)
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
function RollTracker.track_active_roll(roll_name, roll_value, has_crooked, is_new_roll)
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
            found = true
            break
        end
    end

    if not found then
        table.insert(_G.cor_active_rolls, {
            name = roll_name,
            value = roll_value,
            timestamp = os.time(),
            has_crooked = has_crooked or false
        })
    end

    -- Limit to 2 rolls max (FFXI hard limit - Crooked Cards does NOT allow 3rd roll)
    if #_G.cor_active_rolls > 2 then
        table.remove(_G.cor_active_rolls, 1) -- Remove oldest
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
end

---  ═══════════════════════════════════════════════════════════════════════════
---   BONUS CALCULATION
---  ═══════════════════════════════════════════════════════════════════════════

--- How many party members are actually present.
--- @param party table windower.ffxi.get_party()
--- @return number count, table set of member ids still in the party
local function party_membership(party)
    local count, ids = 0, {}
    for i = 0, 5 do
        local member = party['p' .. i]
        if member and member.mob then
            count = count + 1
            if member.mob.id then
                ids[member.mob.id] = true
            end
        end
    end
    return count, ids
end

--- Empty the cache without replacing it.
---
--- The sandbox name and windower._cor_party_jobs are the same table, so
--- assigning a fresh one would leave the persistent copy full of stale entries
--- that came back on the next reload.
local function clear_party_jobs()
    for k in pairs(_G.cor_party_jobs) do
        _G.cor_party_jobs[k] = nil
    end
end

--- Drop members who left, and entries too old to trust.
---
--- Ten minutes, not thirty seconds. A quiet party member emits no 0xDD - no
--- zone, no equipment change, no buff - so a short TTL made their job vanish
--- and took their contribution to the roll bonus with it. Zoning and party
--- changes already clear the cache above, so a long life here is safe.
--- @param valid_ids table Ids still in the party
local function drop_departed_and_expired(valid_ids)
    local TTL = 600
    local now = os.time()

    for player_id, job_data in pairs(_G.cor_party_jobs) do
        if not valid_ids[player_id] then
            _G.cor_party_jobs[player_id] = nil
        elseif job_data.timestamp and (now - job_data.timestamp > TTL) then
            _G.cor_party_jobs[player_id] = nil
        end
    end
end

---   Validate and clean party job cache (auto-refresh on zone/party changes)
---   @return void
function RollTracker.validate_party_cache()
    if not player or not _G.cor_party_state then
        return
    end

    local info = windower.ffxi.get_info()
    local party = windower.ffxi.get_party()
    if not info or not party then
        return
    end

    local current_zone = info.zone
    local current_party_count, valid_ids = party_membership(party)
    local cache_state = _G.cor_party_state

    -- zone_id starts at 0, which is not a zone. Adopting it silently is the
    -- point: treating it as a zone change made the first roll after a load
    -- wipe the jobs the packet listener had just collected, and the job bonus
    -- only ever appeared from the Double-Up onwards.
    if cache_state.zone_id == 0 then
        cache_state.zone_id = current_zone
        cache_state.party_count = current_party_count

    elseif cache_state.zone_id ~= current_zone then
        -- A real zone change: jobs read in the old zone are stale.
        clear_party_jobs()
        cache_state.zone_id = current_zone
        cache_state.party_count = current_party_count
        return

    elseif cache_state.party_count ~= current_party_count then
        clear_party_jobs()
        cache_state.party_count = current_party_count
        return
    end

    drop_departed_and_expired(valid_ids)
end

---   Is a job present in the party, for the purpose of a roll's job bonus?
---
---   Three sources, tried in order of how much they can be trusted.
---
---   1. The Corsair's own main or subjob, which needs no lookup at all.
---   2. The other box, when dual-boxing. This is the only source that does not
---      wait for the server: the character says so itself when its job
---      changes. Without it, a dual-boxed member standing still never
---      registers and the roll silently loses the bonus.
---   3. The packet cache, filled from 0xDD as members join, zone or change
---      state.
---
---   @param job_code string Job the roll wants, e.g. 'WAR'
---   @return boolean
function RollTracker.is_job_in_party_zone(job_code)
    if not job_code or not player or not player.main_job then
        return false
    end

    RollTracker.validate_party_cache()

    if player.main_job == job_code or player.sub_job == job_code then
        return true
    end

    local other = _G.AltJobState
    if other and other.job == job_code then
        return true
    end

    -- Main job only, by choice: a party member's subjob does not grant the
    -- roll's job bonus.
    for _, job_data in pairs(_G.cor_party_jobs or {}) do
        if job_data.main_job == job_code then
            return true
        end
    end

    return false
end

---   Check if equipped gear can proc job bonus (Comm/Lanun Tricorne)
---   @return boolean True if wearing Comm/Lanun Tricorne
function RollTracker.has_job_bonus_proc_gear()
    if not player or not player.equipment then
        return false
    end

    local head = player.equipment.head
    if not head then
        return false
    end

    -- Comm. Tricorne / +1 / +2 (~33% proc)
    if head:match('Comm%.? Tricorne') or head:match('Commodore Tricorne') then
        return true
    end

    -- Lanun Tricorne / +1 / +2 / +3 (~50% proc)
    if head:match('Lanun Tricorne') then
        return true
    end

    return false
end

---   Get highest +Phantom Roll bonus from equipped gear
---   NOTE: Phantom Roll potency is NOT cumulative - only highest value counts
---   (Unlike Phantom Roll Duration which IS cumulative)
---   @return number Highest Phantom Roll bonus
function RollTracker.get_phantom_roll_bonus()
    local max_bonus = 0

    -- Check specific gear pieces and track the HIGHEST value only
    if player and player.equipment then
        local gear = player.equipment

        -- Main Hand Weapons (highest bonuses)
        -- Rostam (main) = +8 (BEST)
        if gear.main and gear.main:match('Rostam') then
            max_bonus = math.max(max_bonus, 8)
        end

        -- Lanun Knife (main) = +7
        if gear.main and gear.main:match('Lanun Knife') then
            max_bonus = math.max(max_bonus, 7)
        end

        -- Commodore's Knife (main) = +6
        if gear.main and (gear.main:match('Commodore\'s Knife') or gear.main:match('Commodore Knife')) then
            max_bonus = math.max(max_bonus, 6)
        end

        -- Neck
        -- Regal Necklace (neck) = +7
        if gear.neck and gear.neck:match('Regal Necklace') then
            max_bonus = math.max(max_bonus, 7)
        end

        -- Rings
        -- Barataria Ring (ring) = +5
        if (gear.left_ring and gear.left_ring:match('Barataria Ring')) or
            (gear.right_ring and gear.right_ring:match('Barataria Ring')) then
            max_bonus = math.max(max_bonus, 5)
        end

        -- Merirosvo Ring (ring) = +3
        if (gear.left_ring and gear.left_ring:match('Merirosvo Ring')) or
            (gear.right_ring and gear.right_ring:match('Merirosvo Ring')) then
            max_bonus = math.max(max_bonus, 3)
        end

        -- NOTE: Compensator, Camulus's Mantle, etc. give +Duration, NOT +Potency
        -- They are NOT checked here
    end

    return max_bonus
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PARTY TRACKING
---  ═══════════════════════════════════════════════════════════════════════════

---   Count party members affected by a specific roll buff
---   @param roll_name string Name of the roll buff (e.g., "Fighter's Roll")
---   @return number affected_count Number of members with the buff
---   @return number total_count Total party members
---   @return table missed_names Array of player names who missed the roll
function RollTracker.count_party_members_with_buff(roll_name)
    local party = windower.ffxi.get_party()
    if not party then
        return 0, 0, {}
    end

    local total_count = 0
    local affected_count = 0
    local missed_names = {}

    -- Check all party slots (p0 to p5)
    for i = 0, 5 do
        local member = party['p' .. i]
        if member and member.mob then
            total_count = total_count + 1
            local member_name = member.name or "Unknown"

            -- Check if this member has the roll buff
            -- Note: buffactive only works for player, not party members in GearSwap
            -- We'll count the COR (self) and estimate based on range
            if i == 0 then
                -- Player (COR) - ALWAYS affected by own rolls
                -- Cannot miss your own Phantom Roll in FFXI
                affected_count = affected_count + 1
            else
                -- Party members - assume affected if in range from COR
                -- Phantom Roll range depends on Luzaf's Ring:
                --   Without Luzaf: 8 yalms
                --   With Luzaf's Ring: 16 yalms
                local roll_range = 8  -- Default: no Luzaf
                if state and state.LuzafRing and state.LuzafRing.value == 'ON' then
                    roll_range = 16  -- Luzaf's Ring equipped
                end

                local member_entity = windower.ffxi.get_mob_by_id(member.mob.id)
                if member_entity and member_entity.distance then
                    local distance = math.sqrt(member_entity.distance)
                    if distance <= roll_range then
                        affected_count = affected_count + 1
                    else
                        table.insert(missed_names, member_name)
                    end
                else
                    -- No entity data - assume missed
                    table.insert(missed_names, member_name)
                end
            end
        end
    end

    return affected_count, total_count, missed_names
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DISPLAY FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

---   Display roll result with all details
---   @param roll_name string Name of the roll
---   @param roll_value number Value rolled
---   @param final_bonus number Final bonus value
---   @param effect_type string Type of effect
---   @param is_lucky boolean If lucky number
---   @param is_unlucky boolean If unlucky number
---   @param is_natural_eleven boolean If natural 11
---   @param bust_rate number Bust rate percentage
---   @param job_bonus_info string|nil Job code if job bonus active (e.g., "RNG")
---   @param is_crooked boolean If Crooked Cards buff active
---   @param missed_names table Array of player names who missed the roll
function RollTracker.display_roll_result(roll_name, roll_value, final_bonus, effect_type, is_lucky, is_unlucky, is_natural_eleven, bust_rate, job_bonus_info, is_crooked, missed_names)
    -- Format roll value with Lucky/Unlucky status (ASCII only)
    local value_display = tostring(roll_value)
    if is_lucky then
        value_display = value_display .. ' LUCKY!'
    elseif is_unlucky then
        value_display = value_display .. ' (unlucky)'
    end

    -- Format bonus display with proper sign
    local bonus_display = string.format("%+g%s", final_bonus, effect_type)

    -- Job bonus indicator passed separately (not added to bonus_display)

    -- Get party member count from stored state (calculated only on initial roll, not Double-Up)
    local affected_count = _G.cor_last_roll.affected_count
    local total_count = _G.cor_last_roll.total_count

    -- Get lucky/unlucky numbers for Snake Eye decision
    local roll_data = RollData.get_roll(roll_name)
    local lucky_num = roll_data and roll_data.lucky or nil
    local unlucky_num = roll_data and roll_data.unlucky or nil

    -- Get roll range for display (same logic as count_party_members_with_buff)
    local roll_range = 8  -- Default: no Luzaf
    if state and state.LuzafRing and state.LuzafRing.value == 'ON' then
        roll_range = 16  -- Luzaf's Ring equipped
    end

    -- Main roll message with bust rate integrated (Natural 11 message now integrated inside)
    MessageFormatter.show_roll_result(roll_name, value_display, bonus_display, is_crooked, affected_count, total_count, lucky_num, unlucky_num, missed_names, bust_rate, job_bonus_info, roll_range)
end

---   Display Double-Up window status
---   Called from commands or periodically
function RollTracker.display_double_up_status()
    if not _G.cor_last_roll.name or not _G.cor_last_roll.timestamp then
        MessageFormatter.show_no_active_roll()
        return
    end

    local elapsed = os.time() - _G.cor_last_roll.timestamp
    local remaining = 45 - elapsed

    if remaining > 0 then
        MessageFormatter.show_roll_double_up_window(remaining)
    else
        MessageFormatter.show_roll_double_up_expired()
    end
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

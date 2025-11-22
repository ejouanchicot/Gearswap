---============================================================================
--- COR Roll Tracker - Smart Roll Tracking and Display
---============================================================================
--- Tracks Phantom Rolls cast by the player and provides intelligent feedback:
--- - Detects rolls via action packets (category 6)
--- - Calculates exact bonuses including gear/job bonuses
--- - Automatic party member job detection via packet parsing (0xDD/0xDF)
--- - Displays Lucky/Unlucky status with formatted messages
--- - Tracks Natural 11 benefits (instant recast + 30s recast + bust immunity)
--- - Monitors Double-Up windows (45 seconds)
--- - Calculates bust rates with color-coded warnings
--- - Non-cumulative Phantom Roll +X gear (only highest bonus applies)
--- - Job bonus detection: COR main/sub OR any party member OR Tricorne proc
---
--- @file jobs/cor/functions/logic/roll_tracker.lua
--- @author Tetsouo
--- @version 1.2
--- @date Created: 2025-10-08
--- @date Updated: 2025-10-09 - Production release with automatic party job detection
--- @requires roll_data, MessageFormatter
---============================================================================

local RollTracker = {}

-- Load dependencies
local RollData = require('shared/jobs/cor/functions/logic/roll_data')
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- STATE TRACKING
---============================================================================

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

---============================================================================
--- ROLL DETECTION (Packet Parsing)
---============================================================================

--- Detect roll from action packet
--- Action category 6 = Job Ability used
--- @param act table Action packet data
--- @return string|nil roll_name, number|nil roll_value
function RollTracker.detect_roll(act)
    if not act or act.category ~= 6 then
        return nil, nil
    end

    -- Check if actor is the player (with nil protection)
    if not player or not player.id or act.actor_id ~= player.id then
        return nil, nil
    end

    -- Get roll ID from param (ability ID)
    local roll_id = act.param

    -- Map roll IDs to roll names (from resources)
    -- This requires res.job_abilities which might not be available in GearSwap
    -- For now, we'll detect via buff application instead
    -- This is a placeholder - actual implementation will detect via buff names

    return nil, nil
end

--- Detect roll via buff application (more reliable for GearSwap)
--- Called from job_buff_change when roll buff is gained
--- @param buff_name string Name of the buff (e.g., "Fighter's Roll")
--- @return boolean True if roll was tracked
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

--- Called when a roll is CAST (from precast/midcast/aftercast)
--- This is where we'll actually track the roll value
--- @param roll_name string Name of the roll
--- @param roll_value number Value rolled (1-12)
function RollTracker.on_roll_cast(roll_name, roll_value)
    -- ==========================================================================
    -- DUPLICATE PREVENTION (Windower action event fires multiple times)
    -- ==========================================================================
    -- Check if this exact roll+value was just displayed (within 500ms)
    local current_time = os.clock()
    if _G.cor_last_roll_display.name == roll_name and
       _G.cor_last_roll_display.value == roll_value and
       _G.cor_last_roll_display.timestamp and
       (current_time - _G.cor_last_roll_display.timestamp) < 0.5 then
        -- Duplicate detected - skip processing
        return
    end

    -- Update last display timestamp
    _G.cor_last_roll_display.name = roll_name
    _G.cor_last_roll_display.value = roll_value
    _G.cor_last_roll_display.timestamp = current_time

    -- Check if bust (12)
    if roll_value == 12 then
        RollTracker.handle_bust(roll_name)
        return
    end

    -- Detect if this is a Double-Up (roll already exists) or initial roll
    local is_double_up = false
    for _, roll in ipairs(_G.cor_active_rolls) do
        if roll.name == roll_name then
            is_double_up = true
            break
        end
    end

    -- Store for buff tracking
    _G.cor_last_roll.name = roll_name
    _G.cor_last_roll.value = roll_value
    _G.cor_last_roll.timestamp = os.time()

    -- Count party members affected (recalculate each time in case members moved)
    local affected_count, total_count, missed_names = RollTracker.count_party_members_with_buff(roll_name)
    _G.cor_last_roll.affected_count = affected_count
    _G.cor_last_roll.total_count = total_count
    _G.cor_last_roll.missed_names = missed_names

    -- Calculate bonus with job detection
    local phantom_roll_bonus = RollTracker.get_phantom_roll_bonus()
    local player_job = player and player.main_job or 'COR'

    -- Get roll data to check for job bonus
    local roll_data = RollData.get_roll(roll_name)
    local has_job_bonus = false

    if roll_data and roll_data.job_bonus then
        local required_job = roll_data.job_bonus[1]

        -- Check if job is in party (COR main/sub OR any party member via packet data)
        -- NOTE: We do NOT apply bonus for Tricorne proc because we cannot detect if it actually proc'd
        -- The game will apply the Tricorne bonus automatically if it procs, but we only display
        -- job bonus in our messages if the job is actually detected in the party
        if RollTracker.is_job_in_party_zone(required_job) then
            has_job_bonus = true
        end
    end

    local final_bonus = RollData.calculate_bonus(roll_name, roll_value, player_job, phantom_roll_bonus, has_job_bonus)

    -- Check for Crooked Cards buff and apply +20% multiplier
    -- IMPORTANT: Crooked Cards buff is CONSUMED when you cast a new roll (disappears immediately)
    -- But it PERSISTS on that roll through Double-Ups
    local is_crooked = false

    -- PRIORITY 1: Check if this roll already has Crooked attached (from active rolls list)
    -- This handles Double-Up - if original roll had Crooked, Double-Up keeps it
    if _G.cor_active_rolls then
        for _, roll in ipairs(_G.cor_active_rolls) do
            if roll.name == roll_name and roll.has_crooked then
                is_crooked = true
                break
            end
        end
    end

    -- PRIORITY 2: Check if Crooked Cards was used recently OR buff is still active
    -- Timestamp persists until we consume it with a NEW roll (not Double-Up)
    if not is_crooked and _G.cor_crooked_timestamp then
        -- Check if buff is still active OR if we just used Crooked recently
        if buffactive['Crooked Cards'] then
            is_crooked = true
        else
            -- Buff disappeared (was consumed or expired), but check timestamp for latency
            local time_since_crooked = os.time() - _G.cor_crooked_timestamp
            if time_since_crooked <= 60 then
                is_crooked = true
            end
        end
    end

    -- Clear timestamp ONLY when consuming Crooked with a NEW roll (not Double-Up)
    if is_crooked and not is_double_up and _G.cor_crooked_timestamp then
        _G.cor_crooked_timestamp = nil
    end

    -- Apply Crooked multiplier if active
    if is_crooked then
        final_bonus = final_bonus * 1.2
    end

    -- Check Lucky/Unlucky
    local is_lucky = RollData.is_lucky(roll_name, roll_value)
    local is_unlucky = RollData.is_unlucky(roll_name, roll_value)

    -- Check Natural 11
    -- NOTE: Natural 11 benefits (instant reset, 30s recast, bust DEBUFF immunity):
    -- - Instant reset: Timer goes to 0 immediately (only if no Bust debuff active)
    -- - 30s recast: Timer reduced to 30s for all rolls (while ANY 11 active)
    -- - Bust immunity: You CAN still bust (roll 12), but NO BUST DEBUFF applied
    --   This means you can immediately re-roll even after busting (no 2-bust penalty)
    -- - Benefits persist as long as ANY 11 roll remains active on the Corsair
    -- - Multiple 11s can be active simultaneously (2 max, or 3 with Crooked Cards)
    local is_natural_eleven = (roll_value == 11)
    if is_natural_eleven then
        _G.cor_natural_eleven_active = true
    end

    -- Get roll data for effect type (reuse from earlier in function)
    -- Note: roll_data was already fetched at line 145, don't fetch again
    local effect_type = roll_data and roll_data.effect_type or ''

    -- Get job bonus info for display
    local job_bonus_info = nil
    if roll_data and roll_data.job_bonus and has_job_bonus then
        job_bonus_info = roll_data.job_bonus[1]  -- Job code (e.g., "DNC")
    end

    -- Calculate bust rate for NEXT Double-Up action
    -- Roll system: Initial roll = 1d6 (1-6), Double-Up = +1d6 each time
    -- Bust if total > 11
    -- Display shows risk for the NEXT Double-Up, not current roll
    local bust_rate = RollData.calculate_bust_rate(roll_value)

    -- Track this roll as active (with Crooked flag if applicable)
    RollTracker.track_active_roll(roll_name, roll_value, is_crooked)

    -- Display formatted message
    RollTracker.display_roll_result(roll_name, roll_value, final_bonus, effect_type, is_lucky, is_unlucky, is_natural_eleven, bust_rate, job_bonus_info, is_crooked, missed_names)
end

--- Track active roll in state
--- @param roll_name string Name of the roll
--- @param roll_value number Value of the roll
--- @param has_crooked boolean If this roll has Crooked Cards attached
function RollTracker.track_active_roll(roll_name, roll_value, has_crooked)
    -- Find existing roll or add new
    local found = false
    for i, roll in ipairs(_G.cor_active_rolls) do
        if roll.name == roll_name then
            roll.value = roll_value
            roll.timestamp = os.time()
            -- Update Crooked flag (only set if true, don't clear if false)
            if has_crooked then
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

---============================================================================
--- BUST HANDLING
---============================================================================

--- Handle bust (roll value 12)
--- @param roll_name string Name of the roll that busted
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

---============================================================================
--- BONUS CALCULATION
---============================================================================

--- Validate and clean party job cache (auto-refresh on zone/party changes)
--- Detects zone changes and party composition changes to clear stale data
--- @return void
function RollTracker.validate_party_cache()
    if not player or not _G.cor_party_state then
        return
    end

    -- Get current zone and party info
    local info = windower.ffxi.get_info()
    local party = windower.ffxi.get_party()

    if not info or not party then
        return
    end

    local current_zone = info.zone
    local current_party_count = 0

    -- Count actual party members
    for i = 0, 5 do
        if party['p' .. i] and party['p' .. i].mob then
            current_party_count = current_party_count + 1
        end
    end

    -- Check if zone changed
    if _G.cor_party_state.zone_id ~= current_zone then
        _G.cor_party_jobs = {}
        _G.cor_party_state.zone_id = current_zone
        _G.cor_party_state.party_count = current_party_count
        return
    end

    -- Check if party composition changed
    if _G.cor_party_state.party_count ~= current_party_count then
        _G.cor_party_jobs = {}
        _G.cor_party_state.party_count = current_party_count
        return
    end

    -- Remove entries for players no longer in party + expired entries (TTL)
    if _G.cor_party_jobs then
        local valid_ids = {}
        for i = 0, 5 do
            local member = party['p' .. i]
            if member and member.mob and member.mob.id then
                valid_ids[member.mob.id] = true
            end
        end

        local current_time = os.time()
        local TTL = 30  -- 30 seconds time-to-live

        for player_id, job_data in pairs(_G.cor_party_jobs) do
            -- Remove if player not in party anymore
            if not valid_ids[player_id] then
                _G.cor_party_jobs[player_id] = nil
            -- Remove if data is older than TTL (stale data)
            elseif job_data.timestamp and (current_time - job_data.timestamp > TTL) then
                _G.cor_party_jobs[player_id] = nil
            end
        end
    end
end

--- Check if job is present in party (COR or party members)
--- Uses packet-parsed party job data from _G.cor_party_jobs AND windower party data as fallback
--- @param job_code string Job code (e.g., "WAR", "RNG", "SAM")
--- @return boolean True if job found in party
function RollTracker.is_job_in_party_zone(job_code)
    -- CRITICAL: Protect ALL player accesses
    if not job_code or not player or not player.main_job then
        return false
    end

    -- Auto-refresh party cache if needed
    RollTracker.validate_party_cache()

    -- Check if player (COR) has the job as main or sub
    if player.main_job == job_code then
        return true
    end

    if player.sub_job and player.sub_job == job_code then
        return true
    end

    -- Check party members (from packet parsing)
    -- NOTE: Only check MAIN job, not subjob (as requested by user)
    if _G.cor_party_jobs then
        for player_id, job_data in pairs(_G.cor_party_jobs) do
            if job_data.main_job == job_code then
                return true
            end
        end
    end

    -- FALLBACK: Check windower party data directly (works for trusts and multibox)
    -- This is more reliable than packet parsing for local party members
    local party = windower.ffxi.get_party()
    if party and player.id then
        for i = 0, 5 do
            local member = party['p' .. i]
            if member and member.mob then
                -- Get member's job from party data
                -- Note: party data contains main_job and sub_job as JOB IDs, not names
                -- We need to check the mob name and see if we can get job from elsewhere

                -- Try to get from windower party member info
                if member.mob.id and member.mob.id ~= player.id then
                    -- Check if we have cached job data that matches (MAIN job only)
                    local cached = _G.cor_party_jobs and _G.cor_party_jobs[member.mob.id]
                    if cached and cached.main_job == job_code then
                        return true
                    end
                end
            end
        end
    end

    return false
end

--- Check if equipped gear can proc job bonus (Comm/Lanun Tricorne)
--- @return boolean True if wearing Comm/Lanun Tricorne
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

--- Get highest +Phantom Roll bonus from equipped gear
--- NOTE: Phantom Roll potency is NOT cumulative - only highest value counts
--- (Unlike Phantom Roll Duration which IS cumulative)
--- @return number Highest Phantom Roll bonus
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

---============================================================================
--- PARTY TRACKING
---============================================================================

--- Count party members affected by a specific roll buff
--- @param roll_name string Name of the roll buff (e.g., "Fighter's Roll")
--- @return number affected_count Number of members with the buff
--- @return number total_count Total party members
--- @return table missed_names Array of player names who missed the roll
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

---============================================================================
--- DISPLAY FUNCTIONS
---============================================================================

--- Display roll result with all details
--- @param roll_name string Name of the roll
--- @param roll_value number Value rolled
--- @param final_bonus number Final bonus value
--- @param effect_type string Type of effect
--- @param is_lucky boolean If lucky number
--- @param is_unlucky boolean If unlucky number
--- @param is_natural_eleven boolean If natural 11
--- @param bust_rate number Bust rate percentage
--- @param job_bonus_info string|nil Job code if job bonus active (e.g., "RNG")
--- @param is_crooked boolean If Crooked Cards buff active
--- @param missed_names table Array of player names who missed the roll
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

--- Display Double-Up window status
--- Called from commands or periodically
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

---============================================================================
--- CLEANUP
---============================================================================

--- Clear Natural 11 status when buff lost
function RollTracker.clear_natural_eleven()
    _G.cor_natural_eleven_active = false
end

--- Clear last roll data
function RollTracker.clear_last_roll()
    _G.cor_last_roll.name = nil
    _G.cor_last_roll.value = nil
    _G.cor_last_roll.timestamp = nil
    _G.cor_last_roll.affected_count = nil
    _G.cor_last_roll.total_count = nil
    _G.cor_last_roll.missed_names = nil
end

--- Clear all roll tracking state
function RollTracker.clear_all()
    _G.cor_active_rolls = {}
    RollTracker.clear_last_roll()
    RollTracker.clear_natural_eleven()
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return RollTracker

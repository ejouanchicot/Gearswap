---============================================================================
--- COR Party Tracker - Packet Parsing Module
---============================================================================
--- Handles two critical COR tracking systems via Windower packet parsing:
---   1. Phantom Roll Value Detection (action packets, category 6)
---   2. Party Member Job Detection (incoming chunk 0xDD/0xDF packets)
---
--- @module party_tracker
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-11-03 (extracted from Tetsouo_COR.lua)
---
--- Features:
---   • Roll value detection (1-12) for all Phantom Rolls including Double-Up
---   • Auto-detection of party member jobs for accurate roll bonuses
---   • Event handler lifecycle management (init/cleanup)
---   • Prevents duplicate handlers via _G event ID tracking
---
--- Dependencies:
---   • RollTracker module (shared/jobs/cor/functions/logic/roll_tracker.lua)
---   • Windower packets library
---   • Windower resources library (job ID >> job code conversion)
---
--- Usage:
---   local PartyTracker = require('shared/jobs/cor/functions/logic/party_tracker')
---   PartyTracker.init()  -- Call in user_setup() or after get_sets()
---   PartyTracker.cleanup()  -- Call in file_unload()
---============================================================================

local PartyTracker = {}

-- Message formatter
local MessageCOR = require('shared/utils/messages/formatters/jobs/message_cor')

---============================================================================
--- INITIALIZATION
---============================================================================

--- Initialize party tracking event handlers
--- Must be called after RollTracker is loaded
function PartyTracker.init()
    -- Load RollTracker (required for roll detection)
    local roll_tracker_loaded, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
    if not roll_tracker_loaded or not RollTracker then
        MessageCOR.show_rolltracker_load_failed()
        RollTracker = nil
    end

    -- Initialize party job storage
    if not _G.cor_party_jobs then
        _G.cor_party_jobs = {}
    end

    -- Track current zone/party for auto-refresh
    if not _G.cor_party_state then
        _G.cor_party_state = {
            zone_id = 0,
            party_count = 0
        }
    end

    ---=========================================================================
    --- PHANTOM ROLL DETECTION (Action Packet Parser)
    ---=========================================================================

    -- Register action event handler (category 6 = Job Ability)
    -- Store event ID in _G for cleanup
    _G.cor_action_event_id = windower.raw_register_event('action', function(act)
        -- CRITICAL: Exit immediately if player not available (prevents crash on reload)
        if not player or not player.id then
            return
        end

        -- Only process if COR job
        if not player.main_job or player.main_job ~= 'COR' then
            return
        end

        -- Category 6 = Job Ability used
        if act.category ~= 6 then
            return
        end

        -- Check if actor is the player
        if act.actor_id ~= player.id then
            return
        end

        -- RollTracker is loaded at module level - just check if it exists
        if not RollTracker then
            return
        end

        -- Exclude Fold only (Fold = 195)
        if act.param == 195 then
            return  -- Not a roll action
        end

        -- Check if it's a Phantom Roll using Windower resources
        -- Phantom Rolls have type 'CorsairRoll' in res.job_abilities
        local is_phantom_roll = false

        -- Try using Windower resources (cleanest method)
        local res_success = pcall(function()
            if res and res.job_abilities and res.job_abilities[act.param] then
                local ability = res.job_abilities[act.param]
                if ability.type == 'CorsairRoll' then
                    is_phantom_roll = true
                end
            end
        end)

        -- Fallback: Range check (Phantom Roll IDs are 98-192)
        if not res_success or not is_phantom_roll then
            if act.param >= 98 and act.param <= 192 then
                is_phantom_roll = true
            end
        end

        if not is_phantom_roll then
            return  -- Not a Phantom Roll
        end

        -- Extract roll value from packet
        -- The packet doesn't contain the roll TYPE (Chaos, Sam, etc)
        -- Only the VALUE (1-12)
        local roll_value = act.targets and act.targets[1] and act.targets[1].actions and act.targets[1].actions[1] and act.targets[1].actions[1].param

        if roll_value and roll_value >= 1 and roll_value <= 12 then
            -- Get roll name from ability ID using Windower resources
            local roll_name = nil

            -- Load resources library inside event handler
            local res_success, res = pcall(require, 'resources')
            if res_success and res and res.job_abilities and res.job_abilities[act.param] then
                roll_name = res.job_abilities[act.param].en  -- English name
            end

            -- Check if this is a Double-Up (last roll still active)
            -- Double-Up uses the SAME ability ID as the previous roll
            local is_double_up = false

            -- Check if we have a last roll and if it was recent (within 45s - Double-Up window)
            if _G.cor_last_roll and _G.cor_last_roll.name and _G.cor_last_roll.timestamp then
                local elapsed = os.time() - _G.cor_last_roll.timestamp

                -- If last roll was within Double-Up window (45 seconds)
                if elapsed <= 45 then
                    is_double_up = true
                end
            end

            -- ALWAYS process immediately now that we have the roll name from ability ID
            if roll_name then
                RollTracker.on_roll_cast(roll_name, roll_value)
            else
                -- Fallback: store for buff detection if we couldn't get name
                _G.cor_pending_roll_value = roll_value
                _G.cor_pending_roll_timestamp = os.time()
            end
        end
    end)

    ---=========================================================================
    --- PARTY MEMBER JOB DETECTION (Packet Parser)
    ---=========================================================================

    -- Load packets library for parsing
    local packets_loaded, packets = pcall(require, 'packets')
    if not packets_loaded or not packets then
        MessageCOR.show_packets_load_failed()
        return  -- Exit early if packets library not available
    end

    -- Load resources library for job conversion
    local res_loaded, res = pcall(require, 'resources')
    if not res_loaded or not res then
        MessageCOR.show_resources_load_failed()
        return  -- Exit early if resources library not available
    end

    -- Register event for party member updates (packet 0xDD and 0xDF)
    -- Store event ID in _G for cleanup in file_unload
    _G.cor_party_event_id = windower.raw_register_event('incoming chunk', function(id, original, modified, injected, blocked)
        -- Process party member update (0xDD) and char update (0xDF)
        -- 0xDD = Party member list (multiple members in one packet)
        -- 0xDF = Char update (single character, including self)
        if id ~= 0xDD and id ~= 0xDF then
            return
        end

        -- Parse the packet
        local success, packet = pcall(packets.parse, 'incoming', original)
        if not success or not packet then
            return
        end

        -- Extract party member info
        local name = packet['Name']
        local player_id = packet['ID']
        local main_job_id = packet['Main job']
        local sub_job_id = packet['Sub job']
        local main_job_level = packet['Main job level']

        -- Validate data (main job level > 0 means valid data)
        -- Note: 0xDF doesn't have Name, only ID - we'll store by ID instead
        if player_id and main_job_id and main_job_level and main_job_level > 0 then
            -- SKIP LOCAL PLAYER: For the local player (self), we use player.main_job which is always current
            -- Packets can contain stale data for the local player after job changes
            if player and player.id and player_id == player.id then
                return  -- Skip storing local player in cache
            end

            -- Convert job IDs to job codes using res.jobs
            local main_job = nil
            local sub_job = nil

            if res and res.jobs then
                if res.jobs[main_job_id] then
                    main_job = res.jobs[main_job_id].ens  -- "WAR", "RNG", etc.
                end
                if sub_job_id and res.jobs[sub_job_id] then
                    sub_job = res.jobs[sub_job_id].ens
                end
            end

            -- Store in global table (keyed by player ID since 0xDF doesn't have Name)
            -- Only store OTHER party members, not the local player
            if main_job then
                -- Try to get name from windower party list
                local player_name = name or "Unknown"

                -- Check if this player is in the windower party data
                local party = windower.ffxi.get_party()
                if party then
                    for i = 0, 5 do
                        local member = party['p' .. i]
                        if member and member.mob and member.mob.id == player_id then
                            player_name = member.name or player_name
                            break
                        end
                    end
                end

                -- Check if this is an update (job changed)
                local is_update = false
                if _G.cor_party_jobs[player_id] then
                    local old_data = _G.cor_party_jobs[player_id]
                    if old_data.main_job ~= main_job or old_data.sub_job ~= sub_job then
                        is_update = true
                    end
                end

                -- Store by player ID (not name, since 0xDF doesn't have it)
                _G.cor_party_jobs[player_id] = {
                    id = player_id,
                    name = player_name,
                    main_job = main_job,
                    sub_job = sub_job,
                    main_job_level = main_job_level,
                    timestamp = os.time()  -- For TTL validation
                }
            end
        end
    end)
end

---============================================================================
--- CLEANUP
---============================================================================

--- Cleanup event handlers and state
--- Must be called in file_unload()
function PartyTracker.cleanup()
    -- Unregister event handlers (CRITICAL for preventing duplicate handlers)
    if _G.cor_action_event_id then
        windower.unregister_event(_G.cor_action_event_id)
        _G.cor_action_event_id = nil
    end

    if _G.cor_party_event_id then
        windower.unregister_event(_G.cor_party_event_id)
        _G.cor_party_event_id = nil
    end

    -- Clear pending roll detection state (prevents stale data after reload)
    _G.cor_pending_roll_value = nil
    _G.cor_pending_roll_timestamp = nil
end

return PartyTracker

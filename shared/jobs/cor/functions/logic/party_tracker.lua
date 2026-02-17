---============================================================================
--- COR Party Tracker - Packet Parsing Module
---============================================================================
--- Handles two critical COR tracking systems via Windower packet parsing:
---   1. Phantom Roll Value Detection (action packet 0x028, category 6)
---   2. Party Member Job Detection (incoming chunk 0xDD/0xDF packets)
---
--- @module party_tracker
--- @author Tetsouo
--- @version 2.0.0
--- @date Created: 2025-11-03 (extracted from Tetsouo_COR.lua)
--- @date Updated: 2026-02-17 - Raw action packet parsing (GearSwap sandbox fix)
---
--- Features:
---   • Roll value detection (1-12) via raw action packet parsing (0x028)
---   • Auto-detection of party member jobs for accurate roll bonuses
---   • Event handler lifecycle management (init/cleanup)
---   • Prevents duplicate handlers via _G event ID tracking
---
--- Technical Notes:
---   • GearSwap sandbox does NOT support windower.register_event('action')
---     reliably - the parsed action table is not passed to user scripts
---   • Instead, we intercept raw incoming chunk 0x028 and parse the
---     bit-packed action data manually to extract roll values
---   • package.loaded is nil in GearSwap sandbox (cannot clear require cache)
---
--- Dependencies:
---   • RollTracker module (shared/jobs/cor/functions/logic/roll_tracker.lua)
---   • Windower packets library (for party member detection only)
---   • Windower resources library (job ID >> job code conversion)
---
--- Usage:
---   local PartyTracker = require('shared/jobs/cor/functions/logic/party_tracker')
---   PartyTracker.init()  -- Call in user_setup() or after get_sets()
---   PartyTracker.cleanup()  -- Call in file_unload()
---============================================================================

local PartyTracker = {}

-- Message formatter (lazy-loaded to prevent module-level require failures)
local MessageCOR = nil
local function get_MessageCOR()
    if not MessageCOR then
        local ok, mod = pcall(require, 'shared/utils/messages/formatters/jobs/message_cor')
        if ok then MessageCOR = mod end
    end
    return MessageCOR
end

---============================================================================
--- BIT READER (for action packet 0x028 parsing)
---============================================================================
--- FFXI action packets use LSB-first bit-packed data after an 8-byte header.
--- These helpers extract fields without requiring the `bit` library.

--- Read `count` bits starting at `bit_offset` from binary string `data`
--- Uses LSB-first ordering (standard for FFXI packets)
--- @param data string Binary packet data
--- @param bit_offset number Bit offset from start of data (0-indexed)
--- @param count number Number of bits to read
--- @return number Unsigned integer value
local function read_bits(data, bit_offset, count)
    local value = 0
    local power = 1
    for i = 0, count - 1 do
        local byte_pos = math.floor((bit_offset + i) / 8) + 1
        local bit_pos = (bit_offset + i) % 8
        local byte_val = data:byte(byte_pos) or 0
        if math.floor(byte_val / (2 ^ bit_pos)) % 2 == 1 then
            value = value + power
        end
        power = power * 2
    end
    return value
end

--- Read uint32 little-endian at byte offset (1-indexed)
--- @param data string Binary data
--- @param offset number Byte offset (1-indexed)
--- @return number uint32 value
local function read_uint32_le(data, offset)
    local b1, b2, b3, b4 = data:byte(offset, offset + 3)
    if not b1 then return 0 end
    return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

---============================================================================
--- INITIALIZATION
---============================================================================

--- Initialize party tracking event handlers
--- Must be called after RollTracker is loaded
function PartyTracker.init()
    -- CRITICAL: Cleanup existing handlers first to prevent duplicates
    -- This ensures init() is idempotent (safe to call multiple times)
    PartyTracker.cleanup()

    -- Verify RollTracker loads correctly (warn once at init time)
    local roll_tracker_loaded = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
    if not roll_tracker_loaded then
        local mc = get_MessageCOR()
        if mc then mc.show_rolltracker_load_failed() end
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

    -- Load packets library for party member parsing (0xDD/0xDF)
    local packets_loaded, packets = pcall(require, 'packets')
    if not packets_loaded or not packets then
        local mc = get_MessageCOR()
        if mc then mc.show_packets_load_failed() end
        return  -- Exit early if packets library not available
    end

    -- Load resources library for job/ability conversion
    local res_loaded, res = pcall(require, 'resources')
    if not res_loaded or not res then
        local mc = get_MessageCOR()
        if mc then mc.show_resources_load_failed() end
        return  -- Exit early if resources library not available
    end

    ---=========================================================================
    --- SINGLE INCOMING CHUNK HANDLER
    --- Handles BOTH roll detection (0x028) AND party job detection (0xDD/0xDF)
    ---=========================================================================
    _G.cor_party_event_id = windower.raw_register_event('incoming chunk', function(id, original, modified, injected, blocked)

        ---=====================================================================
        --- PHANTOM ROLL DETECTION (Action Packet 0x028)
        ---=====================================================================
        --- Action packet structure (after 8-byte header):
        ---   Bit-packed: target_count(6) | category(4) | param(16) | unknown(16) | recast(32)
        ---   Per target: target_id(32) | action_count(4)
        ---   Per action: reaction(5) | animation(12) | effect(5) | stagger(7) |
        ---              knockback(3) | param(17) | message(10) | unknown(31) | has_add(1)
        ---
        --- Roll value = first target's first action's param (17 bits at offset 142)
        ---=====================================================================
        if id == 0x028 then
            -- Safety: need at least header(8) + some packed data
            if not original or #original < 16 then return end

            -- CRITICAL: Exit if player not available
            if not player or not player.id then return end

            -- Only process if COR job
            if not player.main_job or player.main_job ~= 'COR' then return end

            -- Read actor ID from header (bytes 5-8, uint32 LE)
            local actor_id = read_uint32_le(original, 5)

            -- Only process own actions
            if actor_id ~= player.id then return end

            -- Read bit-packed data (starts at byte 9)
            local packed = original:sub(9)
            if not packed or #packed < 20 then return end

            -- Category at bit offset 6 (4 bits)
            local category = read_bits(packed, 6, 4)

            -- Category 6 = Job Ability used
            if category ~= 6 then return end

            -- Param (ability ID) at bit offset 10 (16 bits)
            local ability_id = read_bits(packed, 10, 16)

            -- Exclude Fold (ability ID 195)
            if ability_id == 195 then return end

            -- Check if it's a Phantom Roll
            local is_phantom_roll = false

            -- Try Windower resources (cleanest method)
            pcall(function()
                if res and res.job_abilities and res.job_abilities[ability_id] then
                    if res.job_abilities[ability_id].type == 'CorsairRoll' then
                        is_phantom_roll = true
                    end
                end
            end)

            -- Fallback: Range check (Phantom Roll IDs are 98-192)
            if not is_phantom_roll then
                if ability_id >= 98 and ability_id <= 192 then
                    is_phantom_roll = true
                end
            end

            if not is_phantom_roll then return end

            -- Extract roll value from first target's first action param
            -- Bit offset 142 (17 bits) from start of packed data
            local roll_value = read_bits(packed, 142, 17)

            if roll_value and roll_value >= 1 and roll_value <= 12 then
                -- Get roll name from ability ID
                local roll_name = nil
                pcall(function()
                    if res and res.job_abilities and res.job_abilities[ability_id] then
                        roll_name = res.job_abilities[ability_id].en
                    end
                end)

                if roll_name then
                    -- Load RollTracker dynamically (prevents stale closure across gs reloads)
                    local rt_ok, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
                    if rt_ok and RollTracker then
                        local call_ok, call_err = pcall(RollTracker.on_roll_cast, roll_name, roll_value)
                        if not call_ok then
                            local mf_ok, MF = pcall(require, 'shared/utils/messages/message_formatter')
                            if mf_ok and MF then
                                MF.show_error('[COR] RollTracker error: ' .. tostring(call_err))
                            end
                        end
                    end
                else
                    -- Fallback: store for buff detection if we couldn't get name
                    _G.cor_pending_roll_value = roll_value
                    _G.cor_pending_roll_timestamp = os.time()
                end
            end

            return
        end

        ---=====================================================================
        --- PARTY MEMBER JOB DETECTION (Packets 0xDD/0xDF)
        ---=====================================================================
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
        if player_id and main_job_id and main_job_level and main_job_level > 0 then
            -- SKIP LOCAL PLAYER: packets can contain stale data for self after job changes
            if player and player.id and player_id == player.id then
                return
            end

            -- Convert job IDs to job codes using res.jobs
            local main_job = nil
            local sub_job = nil

            if res and res.jobs then
                if res.jobs[main_job_id] then
                    main_job = res.jobs[main_job_id].ens
                end
                if sub_job_id and res.jobs[sub_job_id] then
                    sub_job = res.jobs[sub_job_id].ens
                end
            end

            if main_job then
                -- Try to get name from windower party list
                local player_name = name or "Unknown"

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

                -- Re-initialize if needed (safety check)
                if not _G.cor_party_jobs then
                    _G.cor_party_jobs = {}
                end

                -- Store by player ID
                _G.cor_party_jobs[player_id] = {
                    id = player_id,
                    name = player_name,
                    main_job = main_job,
                    sub_job = sub_job,
                    main_job_level = main_job_level,
                    timestamp = os.time()
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
    -- Legacy: cor_action_event_id was used for register_event('action') in v1.x
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

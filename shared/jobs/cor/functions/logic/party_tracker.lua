---  ═══════════════════════════════════════════════════════════════════════════
---   COR Party Tracker - Packet Parsing Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Auto-detects party member main/sub jobs by parsing incoming party update
---   packets (0xDD/0xDF). Used by RollTracker to grant correct roll bonuses
---   based on party composition.
---
---   @file    shared/jobs/cor/functions/logic/party_tracker.lua
---   @author  Tetsouo
---   @version 2.1.0
---   @date    Created: 2025-11-03 (extracted from Tetsouo_COR.lua)
---   @date    Updated: 2026-05-08 - Single canonical roll-detection path:
---            raw_register_event('action') is now owned by this module
---            (PartyTracker.init_roll_listener), called from .init(). The
---            inline duplicate that used to live in Tetsouo_COR/Kaories_COR
---            entry points has been removed. Old 0x028 bit-unpack path
---            removed earlier in the same update.
---
---   Features:
---   • Phantom Roll detection via raw_register_event('action')
---   • Auto-detection of party member jobs for accurate roll bonuses
---     (incoming chunk 0xDD/0xDF parsed via the packets library)
---   • Event handler lifecycle management (init/cleanup, idempotent)
---
---   Dependencies:
---   • RollTracker module (shared/jobs/cor/functions/logic/roll_tracker.lua)
---   • Windower packets library (for party member detection)
---   • Windower resources library (job ID >> job code conversion)
---
---   Usage:
---   local PartyTracker = require('shared/jobs/cor/functions/logic/party_tracker')
---   PartyTracker.init()  -- Call in user_setup() or after get_sets()
---   PartyTracker.cleanup()  -- Call in file_unload()
---  ═══════════════════════════════════════════════════════════════════════════

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

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Register the action event listener that detects Phantom Rolls and
---   forwards them to RollTracker.on_roll_cast. This is the single
---   roll-detection path (the COR entry files no longer carry their own).
---   Idempotent: unregisters any previous handler before registering a new
---   one, so calling init() repeatedly is safe.
---   @return nil
function PartyTracker.init_roll_listener()
    if _G.cor_action_event_id then
        windower.unregister_event(_G.cor_action_event_id)
        _G.cor_action_event_id = nil
    end

    _G.cor_action_event_id = windower.raw_register_event('action', function(act)
        if not act or type(act) ~= 'table' then return end
        if not player or not player.id then return end
        if player.main_job ~= 'COR' then return end
        if act.category ~= 6 then return end
        if act.actor_id ~= player.id then return end

        -- Category 6 also carries Quick Draw, Waltzes and every other JA:
        -- only a CorsairRoll entry in res is a roll (Double-Up comes in
        -- under the id of the roll it doubles).
        local roll_name = nil
        pcall(function()
            local r = require('resources')
            local ability = r and r.job_abilities and r.job_abilities[act.param]
            if ability and ability.type == 'CorsairRoll' then
                roll_name = ability.en
            end
        end)
        if not roll_name then return end

        local roll_value = act.targets and act.targets[1] and act.targets[1].actions
            and act.targets[1].actions[1] and act.targets[1].actions[1].param
        if not roll_value or roll_value < 1 or roll_value > 12 then return end

        local rt_ok, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
        if rt_ok and RollTracker and RollTracker.on_roll_cast then
            local call_ok, call_err = pcall(RollTracker.on_roll_cast, roll_name, roll_value)
            if not call_ok then
                local mf_ok, MF = pcall(require, 'shared/utils/messages/message_formatter')
                if mf_ok and MF then
                    MF.show_error('[COR] RollTracker error: ' .. tostring(call_err))
                end
            end
        end
    end)
end

---   Initialize party tracking event handlers (roll listener + 0xDD/0xDF
---   party job parser). Calls cleanup() first, so it is idempotent.
---   @return nil
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

    -- Register the roll detection listener (single canonical path)
    PartyTracker.init_roll_listener()

    -- Party jobs live in the windower table, not in _G.
    --
    -- _G here is the GearSwap sandbox, which is rebuilt on every reload and
    -- every job change. The jobs themselves only arrive in 0xDD/0xDF packets,
    -- which the server sends when a member changes state - joining, zoning,
    -- gaining a buff. Keeping the table in the sandbox meant a reload threw
    -- away everything learned and nothing came back until somebody moved.
    -- The windower table is a C++ object and outlives all of that.
    windower._cor_party_jobs = windower._cor_party_jobs or {}
    windower._cor_party_state = windower._cor_party_state or {
        zone_id = 0,
        party_count = 0
    }
    _G.cor_party_jobs = windower._cor_party_jobs
    _G.cor_party_state = windower._cor_party_state

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

    ---══════════════════════════════════════════════════════════════════════════
    --- PARTY MEMBER JOB DETECTION (Packets 0xDD/0xDF)
    ---══════════════════════════════════════════════════════════════════════════
    --- Roll detection lives on its own action-event handler (init_roll_listener
    --- above). Splitting the two avoids the historical double-fire of
    --- RollTracker.on_roll_cast we used to get when both paths processed the
    --- same Phantom Roll packet.
    _G.cor_party_event_id = windower.raw_register_event('incoming chunk', function(id, original, modified, injected, blocked)
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

                -- Re-initialize if needed, keeping the persistent table and
                -- the sandbox view pointing at the same object.
                if not _G.cor_party_jobs then
                    windower._cor_party_jobs = windower._cor_party_jobs or {}
                    _G.cor_party_jobs = windower._cor_party_jobs
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

---  ═══════════════════════════════════════════════════════════════════════════
---   DISPLAY
---  ═══════════════════════════════════════════════════════════════════════════

--- Job known for a party member: the packet cache (by id, else by name when
--- the member is in another zone), else the dual-box alt's own report.
--- @param member table windower.ffxi.get_party() entry
--- @return table|nil {main_job, sub_job, main_job_level}
local function known_job(member)
    local jobs = _G.cor_party_jobs or {}
    local id = member.mob and member.mob.id
    if id and jobs[id] then return jobs[id] end
    for _, entry in pairs(jobs) do
        if entry.name == member.name then return entry end
    end
    local cfg, alt = _G.DualBoxConfig, _G.AltJobState
    local alt_name = cfg and (cfg.alt_character or cfg.alt_name)
    if alt and alt.job and alt_name and alt_name:lower() == tostring(member.name):lower() then
        return {main_job = alt.job, sub_job = alt.subjob ~= 'NON' and alt.subjob or nil,
            main_job_level = (alt.main_level or 0) > 0 and alt.main_level or nil}
    end
    return nil
end

--- The party as the game lists it (members 1-5, this character left out),
--- each with the job known for it or none. The packet cache alone is empty
--- after a //lua reload until each member zones or changes job.
--- @return table Array of {name, main_job?, sub_job?, main_job_level?}
function PartyTracker.members_for_display()
    local party = windower.ffxi.get_party() or {}
    local members = {}
    for i = 1, 5 do
        local member = party['p' .. i]
        if member and member.name then
            local job = known_job(member) or {}
            members[#members + 1] = {name = member.name, main_job = job.main_job,
                sub_job = job.sub_job, main_job_level = job.main_job_level}
        end
    end
    return members
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CLEANUP
---  ═══════════════════════════════════════════════════════════════════════════

---   Cleanup event handlers and state
---   Must be called in file_unload()
function PartyTracker.cleanup()
    -- Unregister event handlers (CRITICAL for preventing duplicate handlers)
    -- cor_action_event_id: roll listener (init_roll_listener)
    if _G.cor_action_event_id then
        windower.unregister_event(_G.cor_action_event_id)
        _G.cor_action_event_id = nil
    end

    if _G.cor_party_event_id then
        windower.unregister_event(_G.cor_party_event_id)
        _G.cor_party_event_id = nil
    end

    -- Clear pending roll detection state. Nothing in the project sets these
    -- two globals any more; the clear is harmless.
    _G.cor_pending_roll_value = nil
    _G.cor_pending_roll_timestamp = nil
end

return PartyTracker

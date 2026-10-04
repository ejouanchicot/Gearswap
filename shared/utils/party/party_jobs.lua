---============================================================================
--- Party Jobs - the main job of each party member, for every job
---============================================================================
--- The game gives a member's jobs only in the 0xDD / 0xDF packets, sent when
--- that member joins, zones, changes job or gains a buff. Each one seen is
--- kept on `windower` (it outlives a reload and a job change: GearSwap
--- rebuilds its sandbox, the windower table stays).
---
--- A member not seen yet in a packet is found by name (another zone), then,
--- for the dual-box alt, by its own report (_G.AltJobState), then for a
--- trust by its name (TRUSTS below). Unknown otherwise.
---
--- COR keeps its own copy of this tracking for its roll bonuses
--- (shared/jobs/cor/functions/logic/party_tracker.lua); it moves onto this
--- module once this one has been tested in game.
---
--- @file    shared/utils/party/party_jobs.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-02
---============================================================================

local PartyJobs = {}

-- Trusts whose support counts, by the first word of their name, lower case
local TRUSTS = {joachim = 'BRD', ulmia = 'BRD', qultada = 'COR', sylvie = 'GEO'}

--- The packet cache: member id -> {id, name, main_job, sub_job, main_job_level}.
local function cache()
    windower._party_jobs = windower._party_jobs or {}
    return windower._party_jobs
end

--- Store one member from a parsed 0xDD / 0xDF packet (this character left out:
--- its own packets can lag behind a job change, player.main_job is exact).
--- @param packet table packets.parse result
--- @param jobs table res.jobs
local function store(packet, jobs)
    local id, main_id, level = packet['ID'], packet['Main job'], packet['Main job level']
    if not (id and main_id and level and level > 0) then return end
    if player and player.id == id then return end
    local main = jobs[main_id] and jobs[main_id].ens
    if not main then return end
    local sub_id = packet['Sub job']
    cache()[id] = {id = id, name = packet['Name'], main_job = main,
        sub_job = sub_id and jobs[sub_id] and jobs[sub_id].ens or nil, main_job_level = level}
end

--- Listen for 0xDD / 0xDF, once per sandbox (GearSwap drops the event on reload).
function PartyJobs.install()
    if rawget(_G, '_party_jobs_installed') then return end
    local ok_p, packets = pcall(require, 'packets')
    local ok_r, resources = pcall(require, 'resources')
    if not (ok_p and packets and ok_r and resources and resources.jobs) then return end
    _G._party_jobs_installed = true
    windower.raw_register_event('incoming chunk', function(id, original)
        if id ~= 0xDD and id ~= 0xDF then return end
        local ok, packet = pcall(packets.parse, 'incoming', original)
        if ok and packet then pcall(store, packet, resources.jobs) end
    end)
end

--- The dual-box alt's own report, when this member is the alt.
--- @param name string
--- @return table|nil
local function alt_job(name)
    local cfg, alt = rawget(_G, 'DualBoxConfig'), rawget(_G, 'AltJobState')
    local alt_name = cfg and (cfg.alt_character or cfg.alt_name)
    if not (alt and alt.job and alt_name and alt_name:lower() == tostring(name):lower()) then return nil end
    return {main_job = alt.job, sub_job = alt.subjob ~= 'NON' and alt.subjob or nil}
end

--- The job known for a member of windower.ffxi.get_party().
--- @param member table
--- @return table|nil {main_job, sub_job?}
function PartyJobs.job_of(member)
    local jobs, id = cache(), member.mob and member.mob.id
    if id and jobs[id] then return jobs[id] end
    for _, entry in pairs(jobs) do
        if entry.name == member.name then return entry end
    end
    local found = alt_job(member.name)
    if found then return found end
    local trust = TRUSTS[tostring(member.name):lower():match('^%a+') or '']
    return trust and {main_job = trust, trust = true} or nil
end

--- The party in this zone, this character first: {name, main_job?, trust?}.
--- Members in another zone are left out (their songs and rolls cannot reach).
--- @return table
function PartyJobs.members_here()
    local ok, party = pcall(windower.ffxi.get_party)
    party = ok and party or {}
    local me, out = party.p0, {}
    out[1] = {name = player and player.name, main_job = player and player.main_job, self = true}
    for i = 1, 5 do
        local member = party['p' .. i]
        if member and member.name and (not me or member.zone == me.zone) then
            local job = PartyJobs.job_of(member) or {}
            -- a trust whose job came from its party packet is still a trust (its support is weaker than a player's)
            local named = TRUSTS[tostring(member.name):lower():match('^%a+') or '']
            local trust = job.trust or (named ~= nil and not (member.mob and member.mob.is_npc == false))
            out[#out + 1] = {name = member.name, main_job = job.main_job, trust = trust or nil}
        end
    end
    return out
end

return PartyJobs

---  ═══════════════════════════════════════════════════════════════════════════
---   COR Roll Party - who is in the party, and who a roll reached
---  ═══════════════════════════════════════════════════════════════════════════
---   The party side of the roll tracker:
---   - the party job cache PartyTracker fills from 0xDD/0xDF, kept valid
---     across zone and party changes (validate_party_cache)
---   - whether a job is present, for a roll's job bonus (is_job_in_party_zone)
---   - how many members a roll reached, and who missed it
---   The cache itself lives in _G.cor_party_jobs / _G.cor_party_state
---   (set up by PartyTracker); this module only reads and prunes it.
---
---   @file    shared/jobs/cor/functions/logic/roll_party.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local RollParty = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   PARTY JOB CACHE
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
function RollParty.validate_party_cache()
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
function RollParty.is_job_in_party_zone(job_code)
    if not job_code or not player or not player.main_job then
        return false
    end

    RollParty.validate_party_cache()

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

---  ═══════════════════════════════════════════════════════════════════════════
---   ROLL RANGE AND REACH
---  ═══════════════════════════════════════════════════════════════════════════

--- Phantom Roll range in yalms: 8, or 16 with Luzaf's Ring (LuzafRing state).
--- @return number
function RollParty.roll_range()
    if state and state.LuzafRing and state.LuzafRing.value == 'ON' then
        return 16
    end
    return 8
end

---   Count party members affected by a specific roll buff.
---   The roll's action packet lists exactly who it reached: with it, a member
---   missed the roll when its id is not in the list. Without it, the member's
---   distance is compared to the roll range, an estimate: Windower's distance
---   counts the height, and the LuzafRing mode may not match the ring worn.
---   @param roll_name string Name of the roll buff (e.g., "Fighter's Roll")
---   @param target_ids table|nil Set of the ids the roll reached
---   @return number affected_count Number of members with the buff
---   @return number total_count Total party members
---   @return table missed_names Array of player names who missed the roll
function RollParty.count_party_members_with_buff(roll_name, target_ids)
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
            elseif target_ids then
                if target_ids[member.mob.id] then
                    affected_count = affected_count + 1
                else
                    table.insert(missed_names, member_name)
                end
            else
                -- Party members - assume affected if in range from COR
                local roll_range = RollParty.roll_range()

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

return RollParty

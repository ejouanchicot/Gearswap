---============================================================================
--- Support Tier - the weaponskill and engaged sets by the support in the party
---============================================================================
--- How much a party buffs you (attack, accuracy, the mob's defense) changes
--- the best weaponskill and engaged sets, and neither a roll's number nor a Geo spell's
--- potency can be read. What can be read is who is there, so the tier is
--- taken from the support jobs in this zone (you included), from
--- party_jobs.lua:
---   Full    a GEO and a BRD or a COR
---   Group   a BRD, a COR or a GEO
---   Solo    none of them
---   Trust   all the support there is comes from trusts (Sylvie, Ulmia,
---           Joachim, Qultada: party_jobs.lua TRUSTS), weaker than players'
--- Not shown in the HUD; //gs c support shows the tier and the party,
--- //gs c support solo|group|full|trust forces one, //gs c support auto goes
--- back to the party.
---
--- The set itself is the Full one; a Group or Solo version under it is
--- worn in that tier, Solo falling back to Group, then to the set itself.
--- No version written: nothing changes.
---   sets.precast.WS['Upheaval']          Full (and any tier without its own)
---   sets.precast.WS['Upheaval'].Group    Group
---   sets.precast.WS['Upheaval'].Solo     Solo
---   sets.precast.WS['Upheaval'].Trust    Trust, then what the same party
---                                        would give without it (Full or Group)
---   sets.engaged.PDT.Solo, sets.engaged.LaphriaAFM3.Group...
--- Weaponskill sets: after Mote's own choice (WeaponskillMode): with Acc,
--- .Acc.Solo is the Solo one. Engaged sets: on the set each job's builder
--- picks before its layers (weapons, stances' ammo...), through
--- SupportTier.engaged (shared/jobs/<job>/functions/logic/set_builder.lua).
---
--- @file    shared/utils/party/support_tier.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-02
---============================================================================

local SupportTier = {}

local PartyJobs = require('shared/utils/party/party_jobs')

local FORCE_NAMES = {solo = 'Solo', group = 'Group', full = 'Full', trust = 'Trust'}
local SUPPORT_JOBS = {BRD = true, COR = true, GEO = true}
-- The versions tried in each tier, closest first (then the set itself)
local CHAIN = {Full = {}, Group = {'Group'}, Solo = {'Solo', 'Group'}}

--- The tier the support jobs give, trusts counted like players.
--- @param members table PartyJobs.members_here()
--- @return string tier, boolean trusts_only (some support, all of it from trusts)
local function jobs_tier(members)
    local has, players = {}, false
    for _, member in ipairs(members) do
        if SUPPORT_JOBS[member.main_job or ''] then
            has[member.main_job] = true
            if not member.trust then players = true end
        end
    end
    local any = has.GEO or has.BRD or has.COR
    if has.GEO and (has.BRD or has.COR) then return 'Full', not players end
    if any then return 'Group', not players end
    return 'Solo', false
end

--- The tier the party gives (or the forced one).
--- @return string tier, boolean forced, table members
function SupportTier.tier()
    local members = PartyJobs.members_here()
    if windower._support_forced then return windower._support_forced, true, members end
    local tier, trusts_only = jobs_tier(members)
    return trusts_only and 'Trust' or tier, false, members
end

--- The versions a tier tries, closest first: Trust then what the same party gives without it, so a set with no
--- .Trust version is worn as before.
--- @param tier string
--- @return table
local function chain_of(tier)
    if tier ~= 'Trust' then return CHAIN[tier] or {} end
    local base = jobs_tier(PartyJobs.members_here())
    local out = {'Trust'}
    for _, name in ipairs(CHAIN[base] or {}) do out[#out + 1] = name end
    return out
end

--- The tier's version of a weaponskill set, or the set itself.
--- @param set table The set Mote chose
--- @param tier string
--- @return table set, string|nil version
function SupportTier.version(set, tier)
    for _, name in ipairs(chain_of(tier)) do
        if type(set[name]) == 'table' then return set[name], name end
    end
    return set, nil
end

--- The tier's version of an engaged set, or the set itself (a set built by
--- set_combine has no version under it: unchanged).
--- @param set table|nil The engaged set the job's builder picked
--- @return table|nil
function SupportTier.engaged(set)
    if type(set) ~= 'table' then return set end
    local ok, tier = pcall(SupportTier.tier)
    if not ok then return set end
    return (SupportTier.version(set, tier))
end

--- Wrap Mote's get_weaponskill_set, once per sandbox.
function SupportTier.install()
    PartyJobs.install()
    if rawget(_G, '_support_tier_installed') then return end
    local original = rawget(_G, 'get_weaponskill_set')
    if type(original) ~= 'function' then return end
    _G._support_tier_installed = true
    _G.get_weaponskill_set = function(equipSet, spell, spellMap)
        local set = original(equipSet, spell, spellMap)
        if type(set) ~= 'table' then return set end
        local ok, tier = pcall(SupportTier.tier)
        if not ok then return set end
        local chosen, name = SupportTier.version(set, tier)
        if name and mote_vars and mote_vars.set_breadcrumbs then mote_vars.set_breadcrumbs:append(name) end
        return chosen
    end
end

local TIER_KIND = {Full = 'good', Group = 'warn', Solo = 'bad', Trust = 'warn'}

--- One field a member: its job green when it counts, gray when not known yet.
--- @param members table PartyJobs.members_here()
--- @return table InfoBlock fields
local function member_fields(members)
    local out = {}
    for _, m in ipairs(members) do
        local job = m.main_job and (m.main_job .. (m.trust and ' (trust)' or '')) or 'not known yet'
        local kind = nil
        if SUPPORT_JOBS[m.main_job or ''] then kind = 'good' elseif not m.main_job then kind = 'dim' end
        out[#out + 1] = {(m.name or '?') .. (m.self and ' (you)' or ''), job, kind}
    end
    return out
end

--- //gs c support [auto|solo|group|full|trust]
--- @param args table Words after "support"
--- @return boolean true (handled)
function SupportTier.command(args)
    local word = args and args[1] and args[1]:lower()
    if word == 'auto' then windower._support_forced = nil
    elseif word and FORCE_NAMES[word] then windower._support_forced = FORCE_NAMES[word] end
    -- the engaged set worn now follows the new tier (Mote's own refresh)
    local update = rawget(_G, 'handle_update')
    if word and type(update) == 'function' then pcall(update, {'auto'}) end
    local tier, forced, members = SupportTier.tier()
    local fields = {
        {'Tier', tier .. (forced and ' (forced: //gs c support auto to undo)' or ' (from the party)'), forced and 'warn' or TIER_KIND[tier]},
        {'Sets read', #chain_of(tier) == 0 and 'the set itself' or ('.' .. table.concat(chain_of(tier), ', then .') .. ', then the set itself')},
    }
    for _, f in ipairs(member_fields(members)) do fields[#fields + 1] = f end
    require('shared/utils/messages/info_block').show({tag = 'SUPPORT', title = 'Weaponskill and engaged sets by party support', fields = fields})
    return true
end

return SupportTier

---============================================================================
--- Support Tier - the weaponskill set by the support in the party
---============================================================================
--- How much a party buffs you (attack, accuracy, the mob's defense) changes
--- the best weaponskill set, and neither a roll's number nor a Geo spell's
--- potency can be read. What can be read is who is there, so the tier is
--- taken from the support jobs in this zone (you included), from
--- party_jobs.lua:
---   Full    a GEO and a BRD or a COR
---   Group   a BRD, a COR or a GEO
---   Solo    none of them
--- Not shown in the HUD; //gs c support shows the tier and the party,
--- //gs c support solo|group|full forces one, //gs c support auto goes back
--- to the party.
---
--- Weaponskill sets: the set itself is the Full one; a Group or Solo
--- version under it is worn in that tier, Solo falling back to Group, then
--- to the set itself. No version written: nothing changes.
---   sets.precast.WS['Upheaval']          Full (and any tier without its own)
---   sets.precast.WS['Upheaval'].Group    Group
---   sets.precast.WS['Upheaval'].Solo     Solo
--- After Mote's own choice (WeaponskillMode): with Acc, .Acc.Solo is the
--- Solo one.
---
--- @file    shared/utils/party/support_tier.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-02
---============================================================================

local SupportTier = {}

local PartyJobs = require('shared/utils/party/party_jobs')

local FORCE_NAMES = {solo = 'Solo', group = 'Group', full = 'Full'}
local SUPPORT_JOBS = {BRD = true, COR = true, GEO = true}
-- The versions tried in each tier, closest first (then the set itself)
local CHAIN = {Full = {}, Group = {'Group'}, Solo = {'Solo', 'Group'}}

--- The tier the party gives (or the forced one).
--- @return string tier, boolean forced, table members
function SupportTier.tier()
    local members = PartyJobs.members_here()
    if windower._support_forced then return windower._support_forced, true, members end
    local has = {}
    for _, member in ipairs(members) do
        if SUPPORT_JOBS[member.main_job or ''] then has[member.main_job] = true end
    end
    if has.GEO and (has.BRD or has.COR) then return 'Full', false, members end
    if has.GEO or has.BRD or has.COR then return 'Group', false, members end
    return 'Solo', false, members
end

--- The tier's version of a weaponskill set, or the set itself.
--- @param set table The set Mote chose
--- @param tier string
--- @return table set, string|nil version
function SupportTier.version(set, tier)
    for _, name in ipairs(CHAIN[tier] or {}) do
        if type(set[name]) == 'table' then return set[name], name end
    end
    return set, nil
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

--- "Name JOB" for each member, "?" when the job is not known yet.
local function party_line(members)
    local out = {}
    for _, m in ipairs(members) do
        out[#out + 1] = ('%s %s%s'):format(m.name or '?', m.main_job or '?', m.trust and ' (trust)' or '')
    end
    return table.concat(out, ', ')
end

--- //gs c support [auto|solo|group|full]
--- @param args table Words after "support"
--- @return boolean true (handled)
function SupportTier.command(args)
    local word = args and args[1] and args[1]:lower()
    if word == 'auto' then windower._support_forced = nil
    elseif word and FORCE_NAMES[word] then windower._support_forced = FORCE_NAMES[word] end
    local tier, forced, members = SupportTier.tier()
    require('shared/utils/messages/info_block').show({tag = 'SUPPORT', title = 'Weaponskill set by party support', fields = {
        {'Tier', tier .. (forced and ' (forced: //gs c support auto to undo)' or ' (from the party)')},
        {'Party here', party_line(members)},
        {'Sets read', tier == 'Full' and 'the WS set itself' or ('.' .. table.concat(CHAIN[tier], ', then .') .. ', then the WS set itself')},
    }})
    return true
end

return SupportTier

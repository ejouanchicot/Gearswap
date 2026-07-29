---============================================================================
--- Tier Refiner - Generic spell tier downgrading
---============================================================================
--- Job-agnostic engine for "cast the highest tier that is actually available".
--- Walks a correspondence table downward (III -> II -> base) until it finds a
--- tier whose recast is ready and whose MP cost is covered, then fires that
--- spell instead of the requested one. When no tier is available it cancels
--- the cast and shows every tier's remaining recast in a single block.
---
--- The caller supplies the correspondence table, so the engine carries no
--- knowledge of any particular job or spell family:
---   BLM  -> jobs/blm/functions/logic/refiner/correspondence.lua
---   RDM  -> data/spells/RDM_ENFEEBLE_TIERS.lua
---
--- Correspondence format: correspondence[tier].replace = next_lower_tier,
--- where '' means the base tier (spell name without a roman numeral).
---
--- @file shared/utils/precast/tier_refiner.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-07-28
---============================================================================

local TierRefiner = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageCooldowns = require('shared/utils/messages/formatters/combat/message_cooldowns')

--- Iteration bound for a tier walk. The deepest chain is Fire VI -> V -> IV ->
--- III -> II -> I -> base, i.e. 7 spells to test, so 6 would silently drop the
--- base tier. 8 leaves margin without risking a runaway on a malformed table.
local MAX_STEPS = 8

--- Guard against recursive refinement: the replacement is fired through
--- @input, which runs precast again a fraction of a second later.
local REPLACEMENT_COOLDOWN = 0.2
local last_replacement_time = 0

--- Resolve Windower resources across the several ways they may be exposed.
local function get_res()
    return res or windower.res or require('resources')
end

---============================================================================
--- TIER RESOLUTION
---============================================================================

--- Walk the correspondence table and return the first castable tier
--- A tier is castable when its recast is 0 and the player can pay its MP.
--- @param spell_name string       Requested spell name (returned when nothing else fits)
--- @param correspondence table    Tier mapping for the family
--- @param category string         Family prefix (e.g. 'Blind', 'Dia')
--- @param tier string             Requested tier ('III', 'II', '')
--- @param spell_recasts table     windower.ffxi.get_spell_recasts()
--- @param player_mp number        Current MP
--- @return string Name of the spell to actually cast
function TierRefiner.find_available_tier(spell_name, correspondence, category, tier, spell_recasts, player_mp)
    if not (spell_name and correspondence and category and tier and spell_recasts and player_mp) then
        return spell_name
    end

    local resources = get_res()
    if not resources then return spell_name end

    local res_spells = resources.spells
    local current = tier

    for _ = 1, MAX_STEPS do
        if not current then break end

        local test_name = (current == '') and category or (category .. ' ' .. current)
        local test_spell = res_spells:with('en', test_name)

        if test_spell and spell_recasts[test_spell.recast_id] == 0
            and player_mp >= (test_spell.mp_cost or 999) then
            return test_name
        end

        local next_tier = correspondence[current]
        if not next_tier then break end
        current = next_tier.replace
    end

    return spell_name
end

---============================================================================
--- RECAST DISPLAY
---============================================================================

--- Collect the remaining recast of every tier below the requested one
--- @param category string      Family prefix
--- @param start_tier string    Tier to start walking from
--- @param correspondence table Tier mapping
--- @param spell_recasts table  Recast data
--- @return table List of { type, name, value (seconds), action_type }
function TierRefiner.collect_tier_cooldowns(category, start_tier, correspondence, spell_recasts)
    local resources = get_res()
    if not resources then return {} end

    local res_spells = resources.spells
    local cooldowns = {}
    local current = start_tier

    for _ = 1, MAX_STEPS do
        if not current or not correspondence[current] then break end

        local next_tier = correspondence[current].replace
        local name = (next_tier == '') and category or (category .. ' ' .. next_tier)
        local data = res_spells:with('en', name)
        local raw = data and spell_recasts[data.recast_id]

        if raw and raw > 0 then
            table.insert(cooldowns, {
                type = 'cooldown',
                name = name,
                value = raw / 100,  -- centiseconds -> seconds
                action_type = 'Magic',
            })
        end

        if next_tier == '' then break end
        current = next_tier
    end

    return cooldowns
end

--- Cancel the cast and show the requested spell plus every lower tier's recast
--- @param spell table          Spell being cast
--- @param correspondence table Tier mapping
--- @param category string      Family prefix
--- @param tier string          Requested tier
--- @param spell_recasts table  Recast data
--- @param eventArgs table      Event args (.cancel is set)
function TierRefiner.show_unavailable(spell, correspondence, category, tier, spell_recasts, eventArgs)
    local resources = get_res()
    local data = resources and resources.spells:with('en', spell.english)
    if not data then return end

    local raw = spell_recasts[data.recast_id]
    if not raw or raw == 0 then return end  -- ready after all, let it through

    eventArgs.cancel = true

    local cooldowns = { {
        type = 'cooldown',
        name = spell.english,
        value = raw / 100,
        action_type = 'Magic',
    } }

    for _, cd in ipairs(TierRefiner.collect_tier_cooldowns(category, tier, correspondence, spell_recasts)) do
        table.insert(cooldowns, cd)
    end

    MessageCooldowns.show_multi_status(cooldowns)
end

---============================================================================
--- EXECUTION
---============================================================================

--- Cancel the requested spell and fire the replacement through @input
--- @input is used rather than a raw cast so GearSwap's own hooks run for the
--- replacement (correct midcast gear).
--- @param spell table      Original spell
--- @param new_spell string Replacement spell name
--- @param eventArgs table  Event args (.cancel is set)
--- @param now number       os.clock() stamp for the recursion guard
function TierRefiner.execute_replacement(spell, new_spell, eventArgs, now)
    last_replacement_time = now

    send_command('wait 0.1; @input /ma "' .. new_spell .. '" ' .. tostring(spell.target.raw))
    eventArgs.cancel = true

    local spell_recasts = windower.ffxi.get_spell_recasts()
    local resources = get_res()
    local data = resources and resources.spells:with('en', spell.english)
    local recast_seconds = 0

    if data and spell_recasts and spell_recasts[data.recast_id] then
        recast_seconds = spell_recasts[data.recast_id] / 100
    end

    MessageFormatter.show_spell_refinement(spell.english, new_spell, recast_seconds)
end

---============================================================================
--- PUBLIC ENTRY POINT
---============================================================================

--- Refine a spell against its tier family
--- Replaces the standard cooldown check for spells that have a correspondence
--- entry: it either casts a lower tier or reports every tier's recast.
--- @param spell table          Spell from job_precast
--- @param eventArgs table      Event args (.cancel is set when handled)
--- @param correspondence table Tier mapping for this spell's family
--- @return boolean True when the refiner took responsibility for the spell
function TierRefiner.refine(spell, eventArgs, correspondence)
    if not (spell and eventArgs and correspondence) then return false end

    local now = os.clock()
    if (now - last_replacement_time) < REPLACEMENT_COOLDOWN then return false end

    local spell_recasts = windower.ffxi.get_spell_recasts()
    if not spell_recasts then return false end

    local category, tier = spell.name:match('(%a+)%s*(%a*)')
    if not category then return false end

    local new_spell = TierRefiner.find_available_tier(
        spell.english, correspondence, category, tier, spell_recasts, player.mp
    )

    if new_spell ~= spell.english then
        TierRefiner.execute_replacement(spell, new_spell, eventArgs, now)
    else
        TierRefiner.show_unavailable(spell, correspondence, category, tier, spell_recasts, eventArgs)
    end

    return true
end

return TierRefiner

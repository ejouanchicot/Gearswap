---  ═══════════════════════════════════════════════════════════════════════════
---   Recast Display - Group + show recast info for unavailable spells
---  ═══════════════════════════════════════════════════════════════════════════
---   When a spell can't be cast (cooldown), this module collects the recast
---   times of the spell AND its lower tiers (via correspondence table), then
---   shows them all in a single grouped panel via MessageCooldowns.
---
---   Two cases handled:
---     1. Spell with refinement (Fire VI, Stoneja...) - show all tier recasts
---     2. Spell without refinement (Impact, Stun...)  - show only own recast
---
---   Also exposes a helper to collect -ga tier recasts (used by the main
---   refine_various_spells function for -ja fallback display).
---
---   Public API:
---     • show_for_unavailable_spell(spell, correspondence, category, level,
---                                   spell_recasts, eventArgs)
---     • collect_ga_tier_cooldowns(base_element, spell_recasts) -> list
---
---   @file    jobs/blm/functions/logic/refiner/recast_display.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from spell_refiner.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local Correspondence    = require('shared/jobs/blm/functions/logic/refiner/correspondence')
local MessageCooldowns  = require('shared/utils/messages/formatters/combat/message_cooldowns')

local RecastDisplay = {}

--- Walk a tier correspondence table downward and collect any tier whose
--- recast is currently > 0. Returns a list ready for show_multi_status().
---
--- @param category string         Category prefix (e.g. 'Fire', 'Firaga')
--- @param start_level string      Starting tier (e.g. 'III')
--- @param correspondence table    Tier mapping for that category
--- @param spell_recasts table     Result of windower.ffxi.get_spell_recasts()
--- @param res table               Windower resources
--- @return table list of {type='cooldown', name, value (sec), action_type}
local function collect_tier_cooldowns(category, start_level, correspondence, spell_recasts, res)
    local cooldowns = {}
    local currentTier = start_level
    local resSpells = res.spells

    for _ = 1, 6 do
        if not currentTier or not correspondence[currentTier] then
            break
        end

        local nextLevel = correspondence[currentTier].replace

        if nextLevel == '' then
            -- Base tier (no roman numeral)
            local baseTierSpell = resSpells:with('en', category)
            if baseTierSpell then
                local raw = spell_recasts[baseTierSpell.recast_id]
                if raw and raw > 0 then
                    table.insert(cooldowns, {
                        type = "cooldown",
                        name = category,
                        value = raw / 100, -- centiseconds -> seconds
                        action_type = "Magic"
                    })
                end
            end
            break
        else
            local nextTierSpellName = category .. ' ' .. nextLevel
            local nextTierSpell = resSpells:with('en', nextTierSpellName)
            if nextTierSpell then
                local raw = spell_recasts[nextTierSpell.recast_id]
                if raw and raw > 0 then
                    table.insert(cooldowns, {
                        type = "cooldown",
                        name = nextTierSpellName,
                        value = raw / 100,
                        action_type = "Magic"
                    })
                end
            end
            currentTier = nextLevel
        end
    end

    return cooldowns
end

--- Show recast information for an unavailable spell (cancels the cast).
--- Two cases:
---   1. Spell WITH refinement (correspondence table) - show original + all
---      lower tier recasts in one block.
---   2. Spell WITHOUT refinement - show only the spell's own recast.
---
--- @param spell table            The spell that can't be cast
--- @param correspondence table?  Tier mapping for the spell's category
--- @param spellCategory string   Category prefix
--- @param spellLevel string      Current tier
--- @param spell_recasts table    Recast data
--- @param eventArgs table        Event args (.cancel will be set to true)
function RecastDisplay.show_for_unavailable_spell(spell, correspondence, spellCategory, spellLevel, spell_recasts, eventArgs)
    local res = res or windower.res or require('resources')
    if not res then
        return
    end

    local originalSpellData = res.spells:with('en', spell.english)
    if not originalSpellData then
        return
    end

    local recastTime_raw = spell_recasts[originalSpellData.recast_id]
    if not recastTime_raw or recastTime_raw == 0 then
        return -- Spell is ready, nothing to display
    end

    -- Spell on cooldown - cancel cast and show recast info
    eventArgs.cancel = true

    if correspondence then
        -- Case 1: spell with refinement - show original + lower tiers
        local cooldowns = {{
            type = "cooldown",
            name = spell.english,
            value = recastTime_raw / 100,
            action_type = "Magic"
        }}

        local tier_cooldowns = collect_tier_cooldowns(spellCategory, spellLevel, correspondence, spell_recasts, res)
        for _, cd in ipairs(tier_cooldowns) do
            table.insert(cooldowns, cd)
        end

        MessageCooldowns.show_multi_status(cooldowns)
    else
        -- Case 2: spell without refinement - show only its own recast
        MessageCooldowns.show_spell_cooldown(spell.english, recastTime_raw)
    end
end

--- Collect recasts for the -ga III/II/I family of a given base element.
--- Used by refine_various_spells when a -ja spell is unavailable, to show
--- all -ga alternatives in the same cooldown block.
---
--- @param base_element string    e.g. 'Fire' for Firaja -> Firaga III/II/I
--- @param spell_recasts table    Recast data
--- @return table list of {type='cooldown', name, value (sec), action_type}
function RecastDisplay.collect_ga_tier_cooldowns(base_element, spell_recasts)
    local res = res or windower.res or require('resources')
    if not res then
        return {}
    end

    local gaCorrespondence = Correspondence.get(base_element .. 'ga')
    if not gaCorrespondence then
        return {}
    end

    return collect_tier_cooldowns(base_element .. 'ga', 'III', gaCorrespondence, spell_recasts, res)
end

return RecastDisplay

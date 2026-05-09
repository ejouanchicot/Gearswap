---  ═══════════════════════════════════════════════════════════════════════════
---   Replacement Logic - Spell tier downgrade + cancellation rules
---  ═══════════════════════════════════════════════════════════════════════════
---   Pure logic for deciding which spell to actually cast given recast +
---   MP availability. Does NOT execute the cast itself - returns the new
---   spell name and lets the caller (refine_various_spells) issue the
---   /ma command.
---
---   Public API:
---     • find_available_tier(spell, recasts, mp, correspondence,
---                            category, level) -> (new_name, replacement?)
---     • find_ja_replacement(spell, recasts, mp, res) -> new_name
---     • should_cancel(new_name, replacement, mp, spell) -> bool
---
---   Naming choice: function names are snake_case to match project style;
---   they wrap the original camelCase handle_*/handle_ja_* internals.
---
---   @file    jobs/blm/functions/logic/refiner/replacement_logic.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from spell_refiner.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local Correspondence = require('shared/jobs/blm/functions/logic/refiner/correspondence')
local BLMMessages    = require('shared/utils/messages/formatters/jobs/message_blm')

local ReplacementLogic = {}

--- Find an available tier for the given spell category by walking the
--- correspondence table downward (VI -> V -> IV -> ...) until one is ready
--- (recast = 0 AND player has enough MP). Returns the new spell name plus a
--- replacement marker (nil if unchanged).
---
--- @param spell table         The spell object from GearSwap
--- @param spell_recasts table Result of windower.ffxi.get_spell_recasts()
--- @param player_mp number    Current player MP
--- @param correspondence table The category's tier mapping (or nil)
--- @param spellCategory string Category prefix (e.g. 'Fire', 'Stonega')
--- @param spellLevel string    Current tier (e.g. 'VI', 'III', '')
--- @return string newSpell     New spell name (== original if no change)
--- @return string|nil replacement  newSpell when changed, nil otherwise
function ReplacementLogic.find_available_tier(spell, spell_recasts, player_mp, correspondence, spellCategory, spellLevel)
    -- Validate inputs
    if not spell or not spell_recasts or not player_mp or not spellCategory or not spellLevel then
        BLMMessages.show_spell_replacement_error()
        return spell and spell.english or "", nil
    end

    local currentLevel = spellLevel
    local newSpell = spell.english
    local originalSpell = spell.english

    if not correspondence then
        return newSpell, nil
    end

    local res = res or windower.res or require('resources')
    if not res then
        return newSpell, nil
    end

    -- Walk down tiers (max 6 iterations: VI -> V -> IV -> III -> II -> I)
    local maxIterations = 6
    local resSpells = res.spells

    for _ = 1, maxIterations do
        if not currentLevel then
            break
        end

        local testSpellName = (currentLevel == '') and spellCategory or (spellCategory .. ' ' .. currentLevel)
        local testSpell = resSpells:with('en', testSpellName)

        if testSpell then
            local mpCost = testSpell.mp_cost or 999
            local recastId = testSpell.recast_id

            if spell_recasts[recastId] == 0 and player_mp >= mpCost then
                newSpell = testSpellName
                break -- Found an available tier
            end
        end

        local tier = correspondence[currentLevel]
        if not tier then
            break
        end

        currentLevel = tier.replace

        -- Handle base tier (empty string = tier I) with early exit
        if currentLevel == '' then
            local tierOneSpell = spellCategory
            local tierOne = resSpells:with('en', tierOneSpell)
            if tierOne then
                local mpCost = tierOne.mp_cost or 999
                if spell_recasts[tierOne.recast_id] == 0 and player_mp >= mpCost then
                    newSpell = tierOneSpell
                end
            end
            break
        end
    end

    return newSpell, (newSpell ~= originalSpell and newSpell or nil)
end

--- Special handling for -ja spells (Firaja, Stoneja, etc.) which have no
--- explicit tier system. If the -ja spell is unavailable (recast or MP),
--- downgrades to the corresponding -ga III/II/I family.
---
--- @param spell table          The -ja spell object
--- @param spell_recasts table  Recast data
--- @param player_mp number     Current MP
--- @param res table            Windower resources
--- @return string newSpell     Final spell name to cast
function ReplacementLogic.find_ja_replacement(spell, spell_recasts, player_mp, res)
    local originalSpell = spell.english
    local newSpell = originalSpell

    -- Check if the original -ja spell is unavailable
    local originalJaSpell = res.spells:with('en', originalSpell)
    local jaUnavailable = false

    if originalJaSpell then
        local recast = spell_recasts[originalJaSpell.recast_id] or 0
        local mpCost = originalJaSpell.mp_cost or 999
        if recast > 0 or player_mp < mpCost then
            jaUnavailable = true
        end
    else
        jaUnavailable = true -- Spell not found, treat as unavailable
    end

    if jaUnavailable then
        local baseElement = string.gsub(spell.name, 'ja.*', '') -- Fire, Stone, etc.
        local gaCorrespondence = Correspondence.get(baseElement .. 'ga')

        if gaCorrespondence then
            -- Try to find available -ga spell starting from III
            local gaNewSpell = ReplacementLogic.find_available_tier(
                { english = baseElement .. 'ga III', name = baseElement .. 'ga III' },
                spell_recasts, player_mp, gaCorrespondence, baseElement .. 'ga', 'III'
            )

            if gaNewSpell and gaNewSpell ~= baseElement .. 'ga III' then
                newSpell = gaNewSpell
            else
                newSpell = baseElement .. 'ga III' -- Fallback to ga III
            end
        else
            newSpell = string.gsub(spell.name, 'ja', 'ga') .. ' III' -- Original logic
        end
    end

    return newSpell
end

--- Decide if a spell should be cancelled outright (no replacement found AND
--- player is too low on MP for even the base tier).
---
--- @param newSpell string       Final spell name after replacement
--- @param replacement string?   Replacement spell name (nil if unchanged)
--- @param player_mp number      Current MP
--- @param spell table           Original spell object
--- @return boolean              True if the spell should be cancelled
function ReplacementLogic.should_cancel(newSpell, replacement, player_mp, spell)
    if not newSpell or not player_mp or not spell then
        return false
    end

    -- Cancel if downgrade hit base tier ('') AND not Aspir AND MP below threshold
    if replacement == '' and newSpell ~= 'Aspir' and player_mp < (newSpell == 'Aspir' and 10 or 9) then
        cancel_spell()
        return true
    end

    return false
end

return ReplacementLogic

---============================================================================
--- BLM Spell Refinement Module - Intelligent Spell Tier Management
---============================================================================
--- Professional spell refinement providing intelligent spell replacement,
--- tier management, and casting optimization for Black Mage spell automation.
---
--- Features:
---   • Intelligent Tier Downgrading (automatic VI→V→IV→III→II→I fallback)
---   • MP and Recast Awareness (smart replacement based on availability)
---   • Magic Burst Integration (proper spell announcement for burst timing)
---   • Ja-spell Handling (special logic for -ja to -ga spell transitions)
---   • Breakga Replacement (secure Breakga→Break fallback with lag protection)
---   • Recast Display (comprehensive tier recast information display)
---
--- Dependencies:
---   • CooldownChecker (for recast validation)
---   • MessageFormatter (for status display)
---
--- @file jobs/blm/functions/logic/spell_refiner.lua
--- @author Tetsouo
--- @version 2.0 (Migrated from old SPELL_REFINEMENT.lua)
--- @date Migrated: 2025-10-15
---============================================================================

local SpellRefiner = {}

-- Load dependencies (centralized systems)
local MessageFormatter = require('shared/utils/messages/message_formatter')
local CooldownChecker = require('shared/utils/precast/cooldown_checker')
local BLMMessages = require('shared/utils/messages/formatters/jobs/message_blm')
local MessageCooldowns = require('shared/utils/messages/formatters/combat/message_cooldowns')

---============================================================================
--- SPELL CORRESPONDENCE TABLES
---============================================================================

--- Spell tier correspondence for downgrading
--- Maps each tier to its lower replacement tier
--- @type table<string, table<string, table>> Spell tier correspondence
local SPELL_CORRESPONDENCE = {
    -- Fire spells (VI → V → IV → III → II → I)
    Fire = {
        ['VI'] = { replace = 'V' },
        ['V'] = { replace = 'IV' },
        ['IV'] = { replace = 'III' },
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' } -- Base tier (no numeral)
    },
    -- Blizzard spells
    Blizzard = {
        ['VI'] = { replace = 'V' },
        ['V'] = { replace = 'IV' },
        ['IV'] = { replace = 'III' },
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Aero spells
    Aero = {
        ['VI'] = { replace = 'V' },
        ['V'] = { replace = 'IV' },
        ['IV'] = { replace = 'III' },
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Stone spells
    Stone = {
        ['VI'] = { replace = 'V' },
        ['V'] = { replace = 'IV' },
        ['IV'] = { replace = 'III' },
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Thunder spells
    Thunder = {
        ['VI'] = { replace = 'V' },
        ['V'] = { replace = 'IV' },
        ['IV'] = { replace = 'III' },
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Water spells
    Water = {
        ['VI'] = { replace = 'V' },
        ['V'] = { replace = 'IV' },
        ['IV'] = { replace = 'III' },
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- AOE -ga spells (III → II → I)
    Firaga = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    Blizzaga = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    Aeroga = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    Stonega = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    Thundaga = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    Waterga = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Sleep spells (III → II → I)
    Sleep = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Sleepga spells (II → I)
    Sleepga = {
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Break spells (Breakga → Break handled specially, but add for consistency)
    Break = {
        ['I'] = { replace = '' }
    },
    -- Bind spells (II → I)
    Bind = {
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Bio spells (V → IV → III → II → I)
    Bio = {
        ['V'] = { replace = 'IV' },
        ['IV'] = { replace = 'III' },
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Poison spells (V → IV → III → II → I)
    Poison = {
        ['V'] = { replace = 'IV' },
        ['IV'] = { replace = 'III' },
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Drain spells (III → II → I)
    Drain = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Aspir spells (III → II → I)
    Aspir = {
        ['III'] = { replace = 'II' },
        ['II'] = { replace = 'I' },
        ['I'] = { replace = '' }
    },
    -- Burn spells
    Burn = {
        ['I'] = { replace = '' }
    },
    -- Frost spells
    Frost = {
        ['I'] = { replace = '' }
    },
    -- Choke spells
    Choke = {
        ['I'] = { replace = '' }
    },
    -- Rasp spells
    Rasp = {
        ['I'] = { replace = '' }
    },
    -- Shock spells
    Shock = {
        ['I'] = { replace = '' }
    },
    -- Drown spells
    Drown = {
        ['I'] = { replace = '' }
    }
}

--- Anti-spam protection for spell replacement
local last_replacement_time = 0
local REPLACEMENT_COOLDOWN = 0.2 -- 0.2s to allow normal recast

--- Anti-spam protection for individual spells
--- @type table<string, number> Map of spell name to last cast timestamp
local last_cast_times = {}
local CAST_COOLDOWN = 2.0

---============================================================================
--- ANTI-SPAM PROTECTION
---============================================================================

--- Check if spell replacement is safe (anti-spam)
--- @param currentTime number Current timestamp
--- @param cooldown number Cooldown duration (optional, defaults to REPLACEMENT_COOLDOWN)
--- @return boolean true if safe to replace
local function isReplacementSafe(currentTime, cooldown)
    local cd = cooldown or REPLACEMENT_COOLDOWN
    return (currentTime - last_replacement_time) >= cd
end

--- Update last replacement time
--- @param currentTime number Current timestamp
local function updateLastReplacementTime(currentTime)
    last_replacement_time = currentTime
end

--- Check if spell is safe to cast (anti-spam protection)
--- @param spellName string Name of the spell to check
--- @param currentTime number Current timestamp
--- @return boolean true if safe to cast
local function isSpellSafeToCast(spellName, currentTime)
    local lastCast = last_cast_times[spellName]
    if not lastCast then
        return true
    end

    return (currentTime - lastCast) >= CAST_COOLDOWN
end

--- Update last cast time for a spell
--- @param spellName string Name of the spell
--- @param currentTime number Current timestamp
local function updateLastCastTime(spellName, currentTime)
    last_cast_times[spellName] = currentTime
end

---============================================================================
--- SPELL REPLACEMENT CORE
---============================================================================

--- Handles the replacement of a spell based on recast and MP availability
--- Checks if a spell needs to be replaced and modifies the spell name accordingly
--- @param spell table The spell to be checked for replacement
--- @param spell_recasts table The table containing recast times for all spells
--- @param player_mp number The current MP of the player
--- @param correspondence table The correspondence between spells and replacements
--- @param spellCategory string The category of the spell (e.g., 'Fire', 'Cure')
--- @param spellLevel string The level of the spell (e.g., 'I', 'II', 'III')
--- @return string newSpell The name of the new spell after replacement
--- @return string|nil replacement The name of the replacement spell or nil
function SpellRefiner.handle_spell_replacement(spell, spell_recasts, player_mp, correspondence, spellCategory, spellLevel)
    -- Validate inputs
    if not spell or not spell_recasts or not player_mp or not spellCategory or not spellLevel then
        BLMMessages.show_spell_replacement_error()
        return spell and spell.english or "", nil
    end

    local currentLevel = spellLevel
    local newSpell = spell.english
    local originalSpell = spell.english

    -- If no correspondence table, return original spell
    if not correspondence then
        return newSpell, nil
    end

    -- Get cached resources for performance
    local res = res or windower.res or require('resources')
    if not res then
        return newSpell, nil
    end

    -- Optimized tier checking with early exit and cached lookups
    local maxIterations = 6 -- Prevent infinite loops (VI → V → IV → III → II → I)
    local resSpells = res.spells
    local playerMp = player_mp

    for iteration = 1, maxIterations do
        if not currentLevel then
            break
        end

        -- Build the spell name for this tier (optimized string concatenation)
        local testSpellName = (currentLevel == '') and spellCategory or (spellCategory .. ' ' .. currentLevel)

        -- Try to get spell info using cached resource table
        local testSpell = resSpells:with('en', testSpellName)

        if testSpell then
            local mpCost = testSpell.mp_cost or 999
            local recastId = testSpell.recast_id

            -- Check availability with cached values
            if spell_recasts[recastId] == 0 and playerMp >= mpCost then
                newSpell = testSpellName
                break -- Early exit on success
            end
        end

        -- Get next lower tier from correspondence table
        local tier = correspondence[currentLevel]
        if not tier then
            break -- Early exit if no more tiers
        end

        currentLevel = tier.replace

        -- Handle base tier (empty string = tier I) with early exit
        if currentLevel == '' then
            local tierOneSpell = spellCategory
            local tierOne = resSpells:with('en', tierOneSpell)
            if tierOne then
                local mpCost = tierOne.mp_cost or 999
                if spell_recasts[tierOne.recast_id] == 0 and playerMp >= mpCost then
                    newSpell = tierOneSpell
                end
            end
            break -- Always exit after checking base tier
        end
    end

    -- NOTE: Logging removed - replacement message shown in _execute_spell_replacement()
    -- This function is silent to avoid duplicate messages

    return newSpell, (newSpell ~= originalSpell and newSpell or nil)
end

--- Special handling for -ja spell replacement to -ga series
--- @param spell table Original spell object
--- @param spell_recasts table Spell recast data
--- @param player_mp number Current player MP
--- @param res table Windower resources
--- @return string New spell name after -ja processing
function SpellRefiner._handle_ja_spell_replacement(spell, spell_recasts, player_mp, res)
    local originalSpell = spell.english
    local newSpell = originalSpell

    -- First check if the original -ja spell is actually unavailable
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

    -- Only downgrade to -ga series if the -ja spell is truly unavailable
    if jaUnavailable then
        local baseElement = string.gsub(spell.name, 'ja.*', '') -- Fire, Stone, etc.
        local gaCorrespondence = SPELL_CORRESPONDENCE[baseElement .. 'ga']

        if gaCorrespondence then
            -- Try to find available -ga spell starting from III
            local gaNewSpell, _ = SpellRefiner.handle_spell_replacement(
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

---============================================================================
--- SPELL CANCELLATION LOGIC
---============================================================================

--- Handles the cancellation of a spell based on replacement and MP availability
--- Checks if a spell needs to be cancelled and cancels it if necessary
--- @param newSpell string The name of the new spell after replacement
--- @param replacement string|nil The name of the replacement spell
--- @param player_mp number The current MP of the player
--- @param spell table The original spell before replacement
--- @return boolean true if spell was cancelled
function SpellRefiner.handle_spell_cancellation(newSpell, replacement, player_mp, spell)
    if not newSpell or not player_mp or not spell then
        return false
    end

    if replacement == '' and newSpell ~= 'Aspir' and player_mp < (newSpell == 'Aspir' and 10 or 9) then
        cancel_spell()
        return true
    end

    return false
end

---============================================================================
--- MAIN REFINEMENT FUNCTION
---============================================================================

--- Refines various spells based on their recast times and player's MP
--- Checks if a spell needs to be replaced or cancelled and modifies accordingly
--- ENHANCED: Now includes lag compensation to prevent spell replacement spam
--- @param spell table The spell to be checked for replacement or cancellation
--- @param eventArgs table The event arguments to be updated if needed
function SpellRefiner.refine_various_spells(spell, eventArgs)
    if not spell or not eventArgs then
        BLMMessages.show_spell_refinement_error()
        return
    end

    local currentTime = os.clock() -- More precise than os.time() for anti-spam

    -- Skip replacement if we just replaced a spell (reduced to 0.2s to allow normal recast)
    if not isReplacementSafe(currentTime, 0.2) then
        return
    end

    local newSpell = spell.english
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local player_mp = player.mp

    if not spell_recasts then
        BLMMessages.show_spell_recasts_error()
        return
    end

    -- SPECIAL CASE: Check for -ja spells FIRST (they have no tier system)
    if spell.name:find('ja') then
        -- Get resources
        local res = res or windower.res or require('resources')
        if res then
            newSpell = SpellRefiner._handle_ja_spell_replacement(spell, spell_recasts, player_mp, res)
        end

        -- Handle Magic Burst announcement with refined spell name
        SpellRefiner._handle_magic_burst_announcement(spell, newSpell)

        -- Execute replacement if needed
        if newSpell ~= spell.english then
            SpellRefiner._execute_spell_replacement(spell, newSpell, eventArgs, currentTime)
        else
            -- Show recast info if -ja spell unavailable and no replacement found
            local res = res or windower.res or require('resources')
            if res then
                local jaSpellData = res.spells:with('en', spell.english)
                if jaSpellData and spell_recasts[jaSpellData.recast_id] > 0 then
                    eventArgs.cancel = true

                    -- Collect -ja spell cooldown
                    local cooldowns = {{
                        type = "cooldown",
                        name = spell.english,
                        value = spell_recasts[jaSpellData.recast_id] / 100,  -- Convert centiseconds to seconds
                        action_type = "Magic"
                    }}

                    -- Also collect cooldowns for -ga spell alternatives
                    local baseElement = string.gsub(spell.name, 'ja.*', '')
                    local gaCorrespondence = SPELL_CORRESPONDENCE[baseElement .. 'ga']
                    if gaCorrespondence then
                        -- Collect -ga tier recasts
                        local currentTier = 'III'
                        local resSpells = res.spells

                        for iteration = 1, 3 do
                            if not currentTier or not gaCorrespondence[currentTier] then
                                break
                            end

                            local nextLevel = gaCorrespondence[currentTier].replace

                            if nextLevel == '' then
                                -- Check base tier
                                local baseTierSpell = resSpells:with('en', baseElement .. 'ga')
                                if baseTierSpell then
                                    local baseTierRecast_raw = spell_recasts[baseTierSpell.recast_id]
                                    if baseTierRecast_raw and baseTierRecast_raw > 0 then
                                        table.insert(cooldowns, {
                                            type = "cooldown",
                                            name = baseElement .. 'ga',
                                            value = baseTierRecast_raw / 100,
                                            action_type = "Magic"
                                        })
                                    end
                                end
                                break
                            else
                                -- Check next tier
                                local nextTierSpellName = baseElement .. 'ga ' .. nextLevel
                                local nextTierSpell = resSpells:with('en', nextTierSpellName)
                                if nextTierSpell then
                                    local nextTierRecast_raw = spell_recasts[nextTierSpell.recast_id]
                                    if nextTierRecast_raw and nextTierRecast_raw > 0 then
                                        table.insert(cooldowns, {
                                            type = "cooldown",
                                            name = nextTierSpellName,
                                            value = nextTierRecast_raw / 100,
                                            action_type = "Magic"
                                        })
                                    end
                                end
                                currentTier = nextLevel
                            end
                        end
                    end

                    -- Display all cooldowns in a single block
                    MessageCooldowns.show_multi_status(cooldowns)
                end
            end
        end

        return
    end

    -- NORMAL CASE: Tiered spells (Fire VI, Firaga III, etc.)
    local spellCategory, spellLevel = spell.name:match('(%a+)%s*(%a*)')
    local correspondence = SPELL_CORRESPONDENCE[spellCategory]

    -- Attempt spell replacement
    newSpell, replacement = SpellRefiner.handle_spell_replacement(
        spell, spell_recasts, player_mp, correspondence, spellCategory, spellLevel
    )

    -- Handle spell cancellation if needed
    if SpellRefiner.handle_spell_cancellation(newSpell, replacement, player_mp, spell) then
        eventArgs.cancel = true
        BLMMessages.show_insufficient_mp_error(player_mp)
        return
    end

    -- Handle Magic Burst announcement with refined spell name
    SpellRefiner._handle_magic_burst_announcement(spell, newSpell)

    -- Process spell replacement or show recast information
    if newSpell ~= spell.english then
        SpellRefiner._execute_spell_replacement(spell, newSpell, eventArgs, currentTime)
    else
        SpellRefiner._handle_recast_display(spell, correspondence, spellCategory, spellLevel, spell_recasts, eventArgs)
    end

    -- Handle special Breakga replacement
    SpellRefiner._handle_breakga_replacement(spell, spell_recasts, eventArgs, currentTime)
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Handle Magic Burst announcement with proper spell name
--- @param originalSpell table Original spell object
--- @param finalSpellName string Final spell name after refinement
function SpellRefiner._handle_magic_burst_announcement(originalSpell, finalSpellName)
    if state and state.MagicBurstMode and state.MagicBurstMode.value == 'On' and originalSpell.skill == 'Elemental Magic' then
        -- Parse the final spell name to get category and level
        local finalCategory, finalLevel = finalSpellName:match('(%a+)%s*(%a*)')

        -- Handle different spell types correctly
        local displayName
        if finalSpellName:find('ja') then
            -- For -ja spells, just use the full name (no tier)
            displayName = finalSpellName
        elseif not finalLevel or finalLevel == '' then
            -- For base tier spells (Fire, Cure, etc.), just use the category
            displayName = finalCategory
        else
            -- For tiered spells (Fire III, Cure IV, etc.), show category + level
            displayName = finalCategory .. ' ' .. finalLevel
        end

        -- Determine wait time based on spell tier/type
        local wait_time
        if finalSpellName:find('ja') then
            -- Aja spells: wait 2 seconds
            wait_time = 'wait 2; '
        elseif finalLevel == 'VI' then
            -- Tier VI: wait 2 seconds
            wait_time = 'wait 2; '
        else
            -- Everything else: wait 1 second
            wait_time = 'wait 1; '
        end

        send_command(wait_time .. 'input /p Casting: [' .. displayName .. '] => Nuke')
    end
end

--- Execute spell replacement with timing and logging
--- @param originalSpell table Original spell object
--- @param newSpell string New spell name
--- @param eventArgs table Event arguments to modify
--- @param currentTime number Current timestamp
function SpellRefiner._execute_spell_replacement(originalSpell, newSpell, eventArgs, currentTime)
    -- Update timestamp to prevent rapid replacements
    updateLastReplacementTime(currentTime)

    -- Send the replacement spell command with minimal delay (reduced from 0.1s)
    -- Use @input to trigger GearSwap hooks for the refined spell
    send_command('wait 0.1; @input /ma "' .. newSpell .. '" ' .. tostring(originalSpell.target.raw))
    eventArgs.cancel = true

    -- Show refinement message with proper formatting
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local res = res or windower.res or require('resources')
    local originalSpellData = res and res.spells:with('en', originalSpell.english)
    local recast_seconds = 0

    if originalSpellData and spell_recasts and spell_recasts[originalSpellData.recast_id] then
        recast_seconds = spell_recasts[originalSpellData.recast_id] / 100
    end

    BLMMessages.show_spell_refinement(originalSpell.english, newSpell, recast_seconds)
end

--- Handle recast display for unavailable spells (grouped in single block)
--- @param spell table Original spell object
--- @param correspondence table Specific spell category correspondence
--- @param spellCategory string Spell category name
--- @param spellLevel string Spell level/tier
--- @param spell_recasts table Current spell recast times
--- @param eventArgs table Event arguments to modify
function SpellRefiner._handle_recast_display(spell, correspondence, spellCategory, spellLevel, spell_recasts, eventArgs)
    local res = res or windower.res or require('resources')
    if not res then
        return
    end

    -- Check if original spell is on cooldown
    local originalSpellData = res.spells:with('en', spell.english)
    if not originalSpellData then
        return
    end

    local recastTime_raw = spell_recasts[originalSpellData.recast_id]
    if not recastTime_raw or recastTime_raw == 0 then
        return  -- Spell is ready, no need to display anything
    end

    -- Spell is on cooldown - cancel cast and show recast info
    eventArgs.cancel = true

    -- CASE 1: Spell WITH refinement system (has correspondence table)
    if correspondence then
        -- Collect original spell cooldown
        local cooldowns = {{
            type = "cooldown",
            name = spell.english,
            value = recastTime_raw / 100,  -- Convert centiseconds to seconds
            action_type = "Magic"
        }}

        -- Collect lower tier recasts
        local currentTier = spellLevel
        local resSpells = res.spells

        for iteration = 1, 6 do
            if not currentTier or not correspondence[currentTier] then
                break
            end

            local nextLevel = correspondence[currentTier].replace

            if nextLevel == '' then
                -- Check base tier
                local baseTierSpell = resSpells:with('en', spellCategory)
                if baseTierSpell then
                    local baseTierRecast_raw = spell_recasts[baseTierSpell.recast_id]
                    if baseTierRecast_raw and baseTierRecast_raw > 0 then
                        table.insert(cooldowns, {
                            type = "cooldown",
                            name = spellCategory,
                            value = baseTierRecast_raw / 100,
                            action_type = "Magic"
                        })
                    end
                end
                break
            else
                -- Check next tier
                local nextTierSpellName = spellCategory .. ' ' .. nextLevel
                local nextTierSpell = resSpells:with('en', nextTierSpellName)
                if nextTierSpell then
                    local nextTierRecast_raw = spell_recasts[nextTierSpell.recast_id]
                    if nextTierRecast_raw and nextTierRecast_raw > 0 then
                        table.insert(cooldowns, {
                            type = "cooldown",
                            name = nextTierSpellName,
                            value = nextTierRecast_raw / 100,
                            action_type = "Magic"
                        })
                    end
                end
                currentTier = nextLevel
            end
        end

        -- Display all cooldowns in a single block
        MessageCooldowns.show_multi_status(cooldowns)

    -- CASE 2: Spell WITHOUT refinement system (like Impact, Stun, etc.)
    else
        -- Just show the spell's own recast time
        MessageCooldowns.show_spell_cooldown(spell.english, recastTime_raw)
    end
end

--- Display recast information for spell tiers (grouped in single block)
--- @param spellCategory string Spell category name
--- @param spellLevel string Current spell level/tier
--- @param correspondence table Spell tier correspondence
--- @param spell_recasts table Current spell recast times
--- @param res table Windower resources
function SpellRefiner._display_tier_recasts(spellCategory, spellLevel, correspondence, spell_recasts, res)
    local currentTier = spellLevel
    local resSpells = res.spells -- Cache resource table

    -- Collect all cooldowns in a table for grouped display
    local cooldowns = {}

    -- Use numeric for loop for better performance
    for iteration = 1, 6 do
        if not currentTier or not correspondence[currentTier] then
            break -- Early exit if no more tiers
        end

        local nextLevel = correspondence[currentTier].replace

        if nextLevel == '' then
            -- Check base tier (no roman numeral) with cached lookups
            local baseTierSpell = resSpells:with('en', spellCategory)
            if baseTierSpell then
                local baseTierRecast_raw = spell_recasts[baseTierSpell.recast_id]
                if baseTierRecast_raw and baseTierRecast_raw > 0 then
                    -- Add to cooldowns table (convert centiseconds to seconds)
                    table.insert(cooldowns, {
                        type = "cooldown",
                        name = spellCategory,
                        value = baseTierRecast_raw / 100,
                        action_type = "Magic"
                    })
                end
            end
            break -- Always exit after base tier
        else
            -- Check next tier with optimized string building
            local nextTierSpellName = spellCategory .. ' ' .. nextLevel
            local nextTierSpell = resSpells:with('en', nextTierSpellName)
            if nextTierSpell then
                local nextTierRecast_raw = spell_recasts[nextTierSpell.recast_id]
                if nextTierRecast_raw and nextTierRecast_raw > 0 then
                    -- Add to cooldowns table (convert centiseconds to seconds)
                    table.insert(cooldowns, {
                        type = "cooldown",
                        name = nextTierSpellName,
                        value = nextTierRecast_raw / 100,
                        action_type = "Magic"
                    })
                end
            end
            currentTier = nextLevel -- Update for next iteration
        end
    end

    -- Display all cooldowns in a single block
    if #cooldowns > 0 then
        MessageCooldowns.show_multi_status(cooldowns)
    end
end

--- Handle special Breakga to Break replacement
--- @param spell table Original spell object
--- @param spell_recasts table Current spell recast times
--- @param eventArgs table Event arguments to modify
--- @param currentTime number Current timestamp
function SpellRefiner._handle_breakga_replacement(spell, spell_recasts, eventArgs, currentTime)
    if spell.english == 'Breakga' and spell_recasts[spell.recast_id] > 0 then
        -- LAG COMPENSATION: Secure Breakga -> Break replacement
        local breakKey = "Breakga_to_Break"
        if isSpellSafeToCast(breakKey, currentTime) then
            cancel_spell()
            local newSpell = 'Break'

            -- Get Break spell ID dynamically
            local res = res or windower.res or require('resources')
            if not res then
                return
            end

            local break_spell = res.spells:with('en', 'Break')
            local break_id = break_spell and break_spell.id or 255

            if spell_recasts[break_id] > 0 then
                cancel_spell()
                eventArgs.cancel = true
                -- Show with proper formatting (centiseconds for MessageCooldowns)
                MessageCooldowns.show_spell_cooldown(newSpell, spell_recasts[break_id])
            else
                send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
                eventArgs.cancel = true
                updateLastCastTime(breakKey, currentTime)
            end
        else
            -- Breakga replacement blocked
            eventArgs.cancel = true
            BLMMessages.show_breakga_blocked()
        end
    end
end

return SpellRefiner

---============================================================================
--- Midcast Manager - Universal Nested Set Selection with Complete Fallback Chain
---============================================================================
--- Centralized midcast gear selection system for ALL jobs with support for:
---   - Nested sets (e.g., mnd_potency.Valeur, self.Duration, FreeNuke.Fire)
---   - Complete fallback chain (root type > nested type > mode > base)
---   - Universal API for all magic skill types
---   - Database integration (optional)
---   - Root-level spell_family sets (sets.midcast.BarAilment, .Enspell, .Gain)
---   - Guaranteed equipment (always fallback to base set)
---
--- USAGE:
---   local MidcastManager = require('shared/utils/midcast/midcast_manager')
---
---   -- In job_post_midcast:
---   MidcastManager.select_set({
---       skill = 'Enhancing Magic',
---       spell = spell,
---       mode_state = state.EnhancingMode,
---       database_func = EnhancingSPELLS.get_spell_family  -- Returns 'BarAilment', 'Enspell', etc.
---   })
---
--- @file midcast_manager.lua
--- @author Tetsouo
--- @version 2.0 - Added root-level spell_family support (PRIORITY 6)
--- @date Created: 2025-10-24 | Updated: 2025-11-10
---============================================================================

local MidcastManager = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageMidcast = require('shared/utils/messages/formatters/magic/message_midcast')

---============================================================================
--- DEBUGGING / LOGGING (Must be defined before use)
---============================================================================

-- Persist debug state in global scope (survives reloads)
if _G.MidcastManagerDebugState == nil then
    _G.MidcastManagerDebugState = false
end

--- Get debug state (always read from global)
--- @return boolean
local function is_debug_enabled()
    return _G.MidcastManagerDebugState == true
end

--- Enable debug logging
function MidcastManager.enable_debug()
    _G.MidcastManagerDebugState = true
    MessageMidcast.show_debug_enabled()
end

--- Disable debug logging
function MidcastManager.disable_debug()
    MessageMidcast.show_debug_disabled()
    _G.MidcastManagerDebugState = false
end

--- Toggle debug logging
function MidcastManager.toggle_debug()
    if is_debug_enabled() then
        MidcastManager.disable_debug()
    else
        MidcastManager.enable_debug()
    end
end

--- Get debug property (for external access)
MidcastManager.debug = setmetatable({}, {
    __index = function(t, k)
        return is_debug_enabled()
    end
})

-- Old debug functions removed - now using MessageMidcast.show_* directly

---============================================================================
--- CORE SELECTION LOGIC
---============================================================================

--- Select and equip midcast set with complete fallback chain
--- @param config table Configuration table with following keys:
---   - skill: string - Spell skill (e.g., 'Enfeebling Magic', 'Elemental Magic')
---   - spell: table - Spell object from GearSwap
---   - mode_value: string|nil - Direct mode value (e.g., 'MagicBurst', 'Potency'). Takes precedence over mode_state.
---   - mode_state: table|nil - State object for mode selection (e.g., state.EnfeebleMode). Used if mode_value not provided.
---   - database_func: function|nil - Function to get spell type from database
---   - target_func: function|nil - Function to determine target type (e.g., 'self' vs 'others')
---   - extra_key: string|nil - Extra key for set selection (e.g., 'Saboteur')
--- @return boolean True if set was equipped, false otherwise
function MidcastManager.select_set(config)
    -- Validate required parameters
    if not config or not config.skill then
        return false
    end

    -- Validate sets.midcast exists
    if not sets or not sets.midcast then
        return false
    end

    -- Get base set path (e.g., sets.midcast['Enfeebling Magic'])
    -- Special case: 'Singing' uses sets.midcast.BardSong as base
    local base_set = nil
    if config.skill == 'Singing' then
        base_set = sets.midcast.BardSong
    else
        base_set = sets.midcast[config.skill]
    end

    if not base_set then
        return false
    end

    -- DEBUG: Show header with spell info
    if is_debug_enabled() and config and config.spell then
        local spell_name = config.spell.english or 'Unknown'
        local target_name = (config.spell.target and config.spell.target.name) or
            (player and player.name) or 'Unknown'
        MessageMidcast.show_debug_header(spell_name, config.skill, target_name)
    end

    ---========================================================================
    --- SPECIAL HANDLING: BARD SONGS (Singing skill)
    ---========================================================================
    -- Songs have unique logic that doesn't fit the standard fallback pattern
    -- Fallback order: Exact name → Base song → Song type → Instrument → Base
    if config.skill == 'Singing' and config.spell and config.spell.english then
        local spell_name = config.spell.english
        local selected_set = nil
        local selected_set_path = nil
        local debug_steps = {}

        -- STEP 1: Try exact spell name (sets.midcast["Honor March"])
        if sets.midcast[spell_name] then
            selected_set = sets.midcast[spell_name]
            selected_set_path = 'sets.midcast["' .. spell_name .. '"]'
            if is_debug_enabled() then
                table.insert(debug_steps, {step = 1, label = "Exact Match", status = "ok", value = spell_name})
            end
        else
            -- STEP 1.5: Try PascalCase version (remove spaces: "Honor March" → "HonorMarch")
            local pascal_name = spell_name:gsub("%s+", "")
            if pascal_name ~= spell_name and sets.midcast[pascal_name] then
                selected_set = sets.midcast[pascal_name]
                selected_set_path = 'sets.midcast.' .. pascal_name
                if is_debug_enabled() then
                    table.insert(debug_steps, {step = 1.5, label = "PascalCase", status = "ok", value = pascal_name})
                end
            else
                if is_debug_enabled() then
                    table.insert(debug_steps, {step = 1, label = "Exact Match", status = "warn", value = "Not found"})
                end
            end
        end

        if not selected_set then

            -- STEP 2: Try base song name (remove tier: "Knight's Minne V" → "Knight's Minne")
            local base_song = spell_name:match("^(.+)%s+[IVX]+$") or spell_name
            if base_song ~= spell_name and sets.midcast[base_song] then
                selected_set = sets.midcast[base_song]
                selected_set_path = 'sets.midcast["' .. base_song .. '"]'
                if is_debug_enabled() then
                    table.insert(debug_steps, {step = 2, label = "Base Song", status = "ok", value = base_song})
                end
            else
                if is_debug_enabled() then
                    table.insert(debug_steps, {step = 2, label = "Base Song", status = "warn", value = "Not found"})
                end

                -- STEP 3: Try song type (last word: "Minne", "Madrigal", etc.)
                local song_type = MidcastManager.get_song_type(spell_name)
                if song_type and sets.midcast[song_type] then
                    selected_set = sets.midcast[song_type]
                    selected_set_path = 'sets.midcast.' .. song_type
                    if is_debug_enabled() then
                        table.insert(debug_steps, {step = 3, label = "Song Type", status = "ok", value = song_type})
                    end
                else
                    if is_debug_enabled() then
                        table.insert(debug_steps, {step = 3, label = "Song Type", status = "warn", value = "Not found"})
                    end
                end
            end
        end

        -- STEP 3.5: Try first word (for "Honor March" → "Honor", "Blade Madrigal" → "Blade")
        if not selected_set then
            local base_song = spell_name:match("^(.+)%s+[IVX]+$") or spell_name
            local first_word = base_song:match("^(%S+)")
            if first_word and first_word ~= base_song and sets.midcast[first_word] then
                selected_set = sets.midcast[first_word]
                selected_set_path = 'sets.midcast.' .. first_word
                if is_debug_enabled() then
                    table.insert(debug_steps, {step = 3.5, label = "First Word", status = "ok", value = first_word})
                end
            else
                if is_debug_enabled() and first_word and first_word ~= base_song then
                    table.insert(debug_steps, {step = 3.5, label = "First Word", status = "warn", value = "Not found"})
                end
            end
        end

        -- STEP 4: Apply instrument-specific gear (if available)
        local instrument = MidcastManager.get_song_instrument(spell_name)
        if instrument and sets.midcast.Songs and sets.midcast.Songs[instrument] then
            -- Layer instrument set on top of selected set
            if selected_set then
                selected_set = set_combine(selected_set, sets.midcast.Songs[instrument])
            else
                selected_set = sets.midcast.Songs[instrument]
            end
            if is_debug_enabled() then
                table.insert(debug_steps, {step = 4, label = "Instrument", status = "ok", value = instrument})
            end
        else
            if is_debug_enabled() then
                table.insert(debug_steps, {step = 4, label = "Instrument", status = "info", value = "Default"})
            end
        end

        -- STEP 5: Check for Troubadour buff (duration gear)
        if buffactive and buffactive['Troubadour'] and sets.midcast.Songs and sets.midcast.Songs.Duration then
            if selected_set then
                selected_set = set_combine(selected_set, sets.midcast.Songs.Duration)
            else
                selected_set = sets.midcast.Songs.Duration
            end
            if is_debug_enabled() then
                table.insert(debug_steps, {step = 5, label = "Buff", status = "ok", value = "Troubadour (duration)"})
            end
        end

        -- STEP 6: Fallback to base song set if nothing found
        if not selected_set then
            selected_set = base_set  -- sets.midcast.BardSong
            selected_set_path = 'sets.midcast.BardSong'
            if is_debug_enabled() then
                table.insert(debug_steps, {step = 6, label = "Fallback", status = "info", value = "BardSong (base)"})
            end
        end

        -- Equip the selected set
        if selected_set then
            equip(selected_set)

            -- Show debug info
            if is_debug_enabled() then
                for _, step_data in ipairs(debug_steps) do
                    MessageMidcast.show_debug_step(step_data.step, step_data.label, step_data.status, step_data.value)
                end

                MessageMidcast.show_result_header()
                MessageMidcast.show_result(selected_set_path or "Combined", false)

                -- Show equipment (all slots)
                local slot_order = {
                    'main', 'sub', 'range', 'ammo',
                    'head', 'neck', 'ear1', 'ear2',
                    'body', 'hands', 'ring1', 'ring2',
                    'back', 'waist', 'legs', 'feet'
                }

                for _, slot in ipairs(slot_order) do
                    if selected_set[slot] then
                        local item = selected_set[slot]
                        local item_name = (type(item) == 'table' and item.name) or (type(item) == 'string' and item) or nil
                        if item_name then
                            MessageMidcast.show_equipment_line(slot, item_name)
                        end
                    end
                end

                MessageMidcast.show_result_header()
            end

            return true
        end

        return false
    end

    ---========================================================================
    --- STANDARD MIDCAST LOGIC (All other skills)
    ---========================================================================

    local selected_set = nil
    local selected_set_path = nil  -- Track the full set path for debug display
    local mode_value = nil
    local type_value = nil
    local target_value = nil

    -- STEP 1: Get mode value from state OR direct value (if provided)
    if config.mode_value then
        mode_value = config.mode_value
        if is_debug_enabled() then
            MessageMidcast.show_debug_step(1, 'Mode', 'ok', '"' .. tostring(mode_value) .. '"')
        end
    elseif config.mode_state and config.mode_state.value then
        mode_value = config.mode_state.value
        if is_debug_enabled() then
            MessageMidcast.show_debug_step(1, 'Mode', 'ok', '"' .. tostring(mode_value) .. '"')
        end
    else
        if is_debug_enabled() then
            MessageMidcast.show_debug_step(1, 'Mode', 'warn', 'No mode provided')
        end
    end

    -- STEP 2: Get type value from database (if provided)
    if config.database_func and config.spell and config.spell.english then
        local success, result = pcall(config.database_func, config.spell.english)
        if success then
            type_value = result
            if is_debug_enabled() then
                MessageMidcast.show_debug_step(2, 'Type (DB)', 'ok', '"' .. tostring(type_value) .. '"')
            end
        else
            if is_debug_enabled() then
                MessageMidcast.show_debug_step(2, 'Type (DB)', 'fail', 'Error: ' .. tostring(result))
            end
        end
    else
        if is_debug_enabled() then
            MessageMidcast.show_debug_step(2, 'Type (DB)', 'info', 'No database')
        end
    end

    -- STEP 3: Get target value from target_func (if provided)
    if config.target_func and config.spell then
        local success, result = pcall(config.target_func, config.spell)
        if success then
            target_value = result
            if is_debug_enabled() then
                MessageMidcast.show_debug_step(3, 'Target', 'ok', '"' .. tostring(target_value) .. '"')
            end
        else
            if is_debug_enabled() then
                MessageMidcast.show_debug_step(3, 'Target', 'fail', 'Error: ' .. tostring(result))
            end
        end
    else
        if is_debug_enabled() then
            MessageMidcast.show_debug_step(3, 'Target', 'info', 'No target func')
        end
    end

    -- Show priorities header
    if is_debug_enabled() then
        MessageMidcast.show_priorities_header()
    end

    -- Helper function: Try to find a set at a given path
    -- Returns: set, path_string, success
    -- IMPORTANT: Only the FINAL destination needs to be a valid equipment set
    -- Intermediate paths can be missing (no need to create empty tables)
    local function try_path(...)
        local path_parts = {...}
        local current = sets.midcast
        local path_str = 'sets.midcast'

        for i, part in ipairs(path_parts) do
            if not current or type(current) ~= 'table' then
                return nil, nil, false
            end

            current = current[part]

            -- Build path string for debug
            if type(part) == 'string' and part:match('[^%w_]') then
                path_str = path_str .. '["' .. part .. '"]'
            else
                path_str = path_str .. '.' .. tostring(part)
            end

            -- If current is nil at ANY level, path doesn't exist
            if current == nil then
                return nil, nil, false
            end
        end

        -- Final destination must be a table (equipment set)
        if current and type(current) == 'table' then
            -- Additional validation: check if it looks like an equipment set
            -- (has at least one valid slot or is empty table waiting for merging)
            return current, path_str, true
        end

        return nil, nil, false
    end

    -- PRIORITY 0: Try exact spell name at root level (sets.midcast[spell_exact])
    -- Example: sets.midcast["Refresh III"], sets.midcast["Haste II"]
    if config.spell and config.spell.english then
        local found_set, found_path, success = try_path(config.spell.english)
        if success then
            selected_set = found_set
            selected_set_path = found_path
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(0, '"' .. config.spell.english .. '"', true)
            end
        elseif is_debug_enabled() then
            MessageMidcast.show_priority_check(0, '"' .. config.spell.english .. '"', false)
        end
    end

    -- PRIORITY 1: EXHAUSTIVE SEARCH for spell base name with all combinations
    -- Tries ALL possible paths: [spell].[target], [target].[spell], [skill].[spell].[target], etc.
    if not selected_set and config.spell and config.spell.english then
        local base_name = config.spell.english:gsub("%s+[IVX]+$", "")
        local paths_to_try = {}

        -- Build all possible paths based on what values we have
        if target_value then
            -- Root level combinations
            table.insert(paths_to_try, {base_name, target_value})  -- sets.midcast.Refresh.others
            table.insert(paths_to_try, {target_value, base_name})  -- sets.midcast.others.Refresh

            -- Skill level combinations
            if config.skill then
                table.insert(paths_to_try, {config.skill, base_name, target_value})  -- sets.midcast['Enhancing Magic'].Refresh.others
                table.insert(paths_to_try, {config.skill, target_value, base_name})  -- sets.midcast['Enhancing Magic'].others.Refresh
            end
        end

        -- Try without target (for self-casts or as fallback)
        if target_value ~= 'others' then
            table.insert(paths_to_try, {base_name})  -- sets.midcast.Refresh
            if config.skill then
                table.insert(paths_to_try, {config.skill, base_name})  -- sets.midcast['Enhancing Magic'].Refresh
            end
        end

        -- Try each path in order
        for i, path_parts in ipairs(paths_to_try) do
            local found_set, found_path, success = try_path(unpack(path_parts))
            if success then
                selected_set = found_set
                selected_set_path = found_path
                if is_debug_enabled() then
                    MessageMidcast.show_priority_check(1, table.concat(path_parts, '.'), true)
                end
                break
            elseif is_debug_enabled() and i == 1 then
                MessageMidcast.show_priority_check(1, table.concat(path_parts, '.'), false)
            end
        end
    end

    -- PRIORITY 2: Try triple nested set (type + target + mode)
    if not selected_set and type_value and target_value and mode_value then
        local triple_nested = base_set[type_value]
        if triple_nested and type(triple_nested) == 'table' then
            triple_nested = triple_nested[target_value]
            if triple_nested and type(triple_nested) == 'table' and triple_nested[mode_value] then
                selected_set = triple_nested[mode_value]
                selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. type_value .. '.' .. target_value .. '.' .. mode_value
                if is_debug_enabled() then
                    MessageMidcast.show_priority_check(2, type_value .. '.' .. target_value .. '.' .. mode_value, true)
                end
            end
        end
    end

    -- PRIORITY 3: Try double nested set (type + mode)
    if not selected_set and type_value and mode_value then
        local double_nested = base_set[type_value]
        if double_nested and type(double_nested) == 'table' and double_nested[mode_value] then
            selected_set = double_nested[mode_value]
            selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. type_value .. '.' .. mode_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(3, type_value .. '.' .. mode_value, true)
            end
        end
    end

    -- PRIORITY 4: Try double nested set (target + mode)
    if not selected_set and target_value and mode_value then
        local double_nested = base_set[target_value]
        if double_nested and type(double_nested) == 'table' and double_nested[mode_value] then
            selected_set = double_nested[mode_value]
            selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. target_value .. '.' .. mode_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(4, target_value .. '.' .. mode_value, true)
            end
        end
    end

    -- PRIORITY 5: Try target-specific set (nested under skill)
    -- Higher priority than type because target differentiation is more specific
    -- Example: sets.midcast['Enhancing Magic'].others (for Composure/Empyrean bonus)
    -- Also tries: sets.midcast.others (root level target)
    if not selected_set and target_value then
        -- First try skill-based target
        if base_set[target_value] then
            selected_set = base_set[target_value]
            selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. target_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(5, 'Target (' .. target_value .. ')', true)
            end
        -- Fallback to root-level target
        elseif sets.midcast[target_value] then
            selected_set = sets.midcast[target_value]
            selected_set_path = 'sets.midcast.' .. target_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(5, 'Target root (' .. target_value .. ')', true)
            end
        elseif is_debug_enabled() then
            MessageMidcast.show_priority_check(5, 'Target (' .. target_value .. ')', false)
        end
    end

    -- PRIORITY 6: Try type-specific set at ROOT level (spell_family)
    -- Example: sets.midcast.BarAilment, sets.midcast.Enspell, sets.midcast.Gain
    -- Allows universal spell_family sets without nesting under skill
    if not selected_set and type_value then
        if sets.midcast[type_value] then
            selected_set = sets.midcast[type_value]
            selected_set_path = 'sets.midcast.' .. type_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(6, 'Type root (' .. type_value .. ')', true)
            end
        elseif is_debug_enabled() then
            MessageMidcast.show_priority_check(6, 'Type root (' .. type_value .. ')', false)
        end
    end

    -- PRIORITY 7: Try type-specific set (nested under skill)
    -- Lower priority than target and root type to allow more specific sets to override
    -- Example: sets.midcast['Enhancing Magic'].Refresh
    if not selected_set and type_value then
        if base_set[type_value] then
            selected_set = base_set[type_value]
            selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. type_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(7, 'Type (' .. type_value .. ')', true)
            end
        end
    end

    -- PRIORITY 8: Try mode-specific set (nested under skill)
    if not selected_set and mode_value then
        if base_set[mode_value] then
            selected_set = base_set[mode_value]
            selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. mode_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(8, 'Mode (' .. mode_value .. ')', true)
            end
        end
    end

    -- PRIORITY 9: Final fallback - base set (skill only)
    if not selected_set then
        selected_set = base_set
        selected_set_path = 'sets.midcast["' .. config.skill .. '"]'
    end

    -- Equip final set
    if selected_set then
        equip(selected_set)

        -- Show result and equipment list if debug
        if is_debug_enabled() then
            -- Determine set type for result message
            local is_fallback = (selected_set == base_set)

            MessageMidcast.show_result_header()
            MessageMidcast.show_result(selected_set_path, is_fallback)

            -- Define slot order (FFXI standard order)
            local slot_order = {
                'main', 'sub', 'range', 'ammo',
                'head', 'neck', 'ear1', 'ear2',
                'body', 'hands', 'ring1', 'ring2',
                'back', 'waist', 'legs', 'feet'
            }

            -- Display items in slot order (1 per line)
            for _, slot in ipairs(slot_order) do
                if selected_set[slot] then
                    local item = selected_set[slot]
                    local item_name = (type(item) == 'table' and item.name) or (type(item) == 'string' and item) or nil
                    if item_name then
                        MessageMidcast.show_equipment_line(slot, item_name)
                    end
                end
            end

            MessageMidcast.show_result_header()
        end

        return true
    end

    return false
end

---============================================================================
--- HELPER FUNCTIONS FOR COMMON PATTERNS
---============================================================================

--- Determine target type for Enhancing Magic (Composure logic)
--- @param spell table Spell object from GearSwap
--- @return string|nil 'Composure' if buffactive and targeting others, nil otherwise
function MidcastManager.get_enhancing_target(spell)
    if not spell or not spell.target then
        return nil
    end

    -- If Composure is active AND casting on someone else (not self)
    -- Return 'Composure' to use sets.midcast['Enhancing Magic'].Composure
    -- (regardless of target type: PLAYER, NPC, TRUST, MOB, etc.)
    if buffactive and buffactive['Composure'] and spell.target.name and spell.target.name ~= player.name then
        return 'Composure'
    else
        return nil  -- Use base set (no target differentiation)
    end
end

--- Determine element for Elemental Magic (optional filter)
--- @param spell table Spell object from GearSwap
--- @return string|nil Element name (e.g., 'Fire', 'Ice', 'Thunder')
function MidcastManager.get_element(spell)
    if not spell or not spell.element then
        return nil
    end

    return spell.element
end

---============================================================================
--- BARD SONG HELPER FUNCTIONS
---============================================================================

--- Extract song type from spell name (last word after removing tier)
--- Examples: "Knight's Minne V" → "Minne", "Blade Madrigal" → "Madrigal"
--- @param spell_name string Full spell name
--- @return string|nil Song type (e.g., "Minne", "Madrigal", "March")
function MidcastManager.get_song_type(spell_name)
    if not spell_name then
        return nil
    end

    -- Remove tier suffix (II, III, IV, V, VI)
    local base_song = spell_name:match("^(.+)%s+[IVX]+$") or spell_name

    -- Extract last word (song type)
    local song_type = base_song:match("%s+(%S+)$") or base_song

    return song_type
end

--- Get required instrument for a song (if any)
--- Uses SongRotationManager if available
--- @param spell_name string Song name
--- @return string|nil Instrument name (e.g., "Gjallarhorn", "Marsyas", "Daurdabla")
function MidcastManager.get_song_instrument(spell_name)
    if not spell_name then
        return nil
    end

    -- Try to use SongRotationManager if available
    if _G.SongRotationManager and _G.SongRotationManager.get_required_instrument then
        return _G.SongRotationManager.get_required_instrument(spell_name)
    end

    -- Fallback: Basic instrument detection
    if spell_name == "Honor March" then
        return "Marsyas"
    elseif spell_name == "Aria of Passion" then
        return "Loughnashade"
    end

    return nil  -- Use default instrument from BardSong set
end

---============================================================================
--- PRESET CONFIGURATIONS FOR COMMON JOB PATTERNS
---============================================================================

--- RDM Enfeebling Magic configuration
--- @param spell table Spell object
--- @param database_func function Function to get enfeebling type (e.g., RDMSpells.get_enfeebling_type)
--- @return table Configuration for select_set()
function MidcastManager.rdm_enfeebling(spell, database_func)
    return {
        skill = 'Enfeebling Magic',
        spell = spell,
        mode_state = state.EnfeebleMode,
        database_func = database_func
    }
end

--- RDM/WHM/GEO Enhancing Magic configuration
--- @param spell table Spell object
--- @return table Configuration for select_set()
function MidcastManager.enhancing(spell)
    return {
        skill = 'Enhancing Magic',
        spell = spell,
        mode_state = state.EnhancingMode,
        target_func = MidcastManager.get_enhancing_target
    }
end

--- BLM/RDM/GEO Elemental Magic configuration
--- @param spell table Spell object
--- @return table Configuration for select_set()
function MidcastManager.elemental(spell)
    return {
        skill = 'Elemental Magic',
        spell = spell,
        mode_state = state.NukeMode
    }
end

--- WHM/RDM/PLD Cure Magic configuration
--- @param spell table Spell object
--- @return table Configuration for select_set()
function MidcastManager.cure(spell)
    return {
        skill = 'Healing Magic',
        spell = spell,
        mode_state = state.CureMode
    }
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MidcastManager

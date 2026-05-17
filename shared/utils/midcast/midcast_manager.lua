-- MidcastManager: universal nested set selection with 9-level fallback chain.
-- Supports spell name > skill > type > target > mode > base, plus Bard song matching.
--
-- Refactored 2026-05-12: split god function `select_set` (499 lines) into:
--   - `select_singing_set()` for BRD Singing skill
--   - `select_standard_set()` for the 9-priority chain (all other skills)
--   - `equip_with_debug()` for the duplicated equipment debug dump
--   - `try_path()` lifted to module-private helper

local MidcastManager = {}

local MessageMidcast = require('shared/utils/messages/formatters/magic/message_midcast')

-- Persist debug state in global scope (survives reloads)
if _G.MidcastManagerDebugState == nil then
    _G.MidcastManagerDebugState = false
end

--- Get debug state (always read from global)
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

--- Get debug property (for external access).
--- Only the canonical key 'enabled' is recognized; any other key returns nil
--- so typos surface immediately instead of silently returning the boolean.
local DEBUG_KEYS = { enabled = true }
MidcastManager.debug = setmetatable({}, {
    __index = function(t, k)
        if DEBUG_KEYS[k] then return is_debug_enabled() end
        return nil
    end
})

---============================================================================
--- MODULE-PRIVATE HELPERS
---============================================================================

-- FFXI slot order (used by debug equipment dump)
local SLOT_ORDER = {
    'main', 'sub', 'range', 'ammo',
    'head', 'neck', 'ear1', 'ear2',
    'body', 'hands', 'ring1', 'ring2',
    'back', 'waist', 'legs', 'feet'
}

--- Helper: try to find a set at a given nested path.
--- IMPORTANT: Only the FINAL destination needs to be a valid equipment set.
--- Intermediate paths can be missing (no need to create empty tables).
--- @return set, path_string, success
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

        if current == nil then
            return nil, nil, false
        end
    end

    if current and type(current) == 'table' then
        return current, path_str, true
    end

    return nil, nil, false
end

--- Equip a set and (when debug enabled) print its full equipment list.
--- Shared by singing and standard branches to eliminate duplicate slot-order loops.
--- @param selected_set table Equipment set to apply
--- @param selected_set_path string Path string for debug display
--- @param is_fallback boolean Whether this is the base/fallback set
local function equip_with_debug(selected_set, selected_set_path, is_fallback)
    equip(selected_set)

    if not is_debug_enabled() then
        return
    end

    MessageMidcast.show_result_header()
    MessageMidcast.show_result(selected_set_path or 'Combined', is_fallback)

    for _, slot in ipairs(SLOT_ORDER) do
        if selected_set[slot] then
            local item = selected_set[slot]
            local item_name = (type(item) == 'table' and item.name)
                or (type(item) == 'string' and item)
                or nil
            if item_name then
                MessageMidcast.show_equipment_line(slot, item_name)
            end
        end
    end

    MessageMidcast.show_result_header()
end

---============================================================================
--- BRD SINGING BRANCH
--- Unique fallback chain: exact name → base song → song type → first word →
--- instrument layer → Troubadour overlay → base set (BardSong)
---============================================================================

local function select_singing_set(config, base_set)
    if not (config.spell and config.spell.english) then
        return false
    end

    local spell_name   = config.spell.english
    local selected_set = nil
    local selected_set_path = nil
    local debug_steps  = {}

    -- Step 1: Exact spell name (sets.midcast["Honor March"])
    if sets.midcast[spell_name] then
        selected_set = sets.midcast[spell_name]
        selected_set_path = 'sets.midcast["' .. spell_name .. '"]'
        if is_debug_enabled() then
            table.insert(debug_steps, {step=1, label="Exact Match", status="ok", value=spell_name})
        end
    else
        -- Step 1.5: PascalCase ("Honor March" → "HonorMarch")
        local pascal_name = spell_name:gsub("%s+", "")
        if pascal_name ~= spell_name and sets.midcast[pascal_name] then
            selected_set = sets.midcast[pascal_name]
            selected_set_path = 'sets.midcast.' .. pascal_name
            if is_debug_enabled() then
                table.insert(debug_steps, {step=1.5, label="PascalCase", status="ok", value=pascal_name})
            end
        else
            if is_debug_enabled() then
                table.insert(debug_steps, {step=1, label="Exact Match", status="warn", value="Not found"})
            end
        end
    end

    if not selected_set then
        -- Step 2: Base song (strip tier "V" etc.)
        local base_song = spell_name:match("^(.+)%s+[IVX]+$") or spell_name
        if base_song ~= spell_name and sets.midcast[base_song] then
            selected_set = sets.midcast[base_song]
            selected_set_path = 'sets.midcast["' .. base_song .. '"]'
            if is_debug_enabled() then
                table.insert(debug_steps, {step=2, label="Base Song", status="ok", value=base_song})
            end
        else
            if is_debug_enabled() then
                table.insert(debug_steps, {step=2, label="Base Song", status="warn", value="Not found"})
            end

            -- Step 3: Song type (last word: "Minne", "Madrigal", etc.)
            local song_type = MidcastManager.get_song_type(spell_name)
            if song_type and sets.midcast[song_type] then
                selected_set = sets.midcast[song_type]
                selected_set_path = 'sets.midcast.' .. song_type
                if is_debug_enabled() then
                    table.insert(debug_steps, {step=3, label="Song Type", status="ok", value=song_type})
                end
            else
                if is_debug_enabled() then
                    table.insert(debug_steps, {step=3, label="Song Type", status="warn", value="Not found"})
                end
            end
        end
    end

    -- Step 3.5: First word ("Honor March" → "Honor")
    if not selected_set then
        local base_song = spell_name:match("^(.+)%s+[IVX]+$") or spell_name
        local first_word = base_song:match("^(%S+)")
        if first_word and first_word ~= base_song and sets.midcast[first_word] then
            selected_set = sets.midcast[first_word]
            selected_set_path = 'sets.midcast.' .. first_word
            if is_debug_enabled() then
                table.insert(debug_steps, {step=3.5, label="First Word", status="ok", value=first_word})
            end
        else
            if is_debug_enabled() and first_word and first_word ~= base_song then
                table.insert(debug_steps, {step=3.5, label="First Word", status="warn", value="Not found"})
            end
        end
    end

    -- Step 4: Layer instrument-specific gear
    local instrument = MidcastManager.get_song_instrument(spell_name)
    if instrument and sets.midcast.Songs and sets.midcast.Songs[instrument] then
        if selected_set then
            selected_set = set_combine(selected_set, sets.midcast.Songs[instrument])
        else
            selected_set = sets.midcast.Songs[instrument]
        end
        if is_debug_enabled() then
            table.insert(debug_steps, {step=4, label="Instrument", status="ok", value=instrument})
        end
    else
        if is_debug_enabled() then
            table.insert(debug_steps, {step=4, label="Instrument", status="info", value="Default"})
        end
    end

    -- Step 5: Troubadour buff overlay (duration gear)
    if buffactive and buffactive['Troubadour']
       and sets.midcast.Songs and sets.midcast.Songs.Duration then
        if selected_set then
            selected_set = set_combine(selected_set, sets.midcast.Songs.Duration)
        else
            selected_set = sets.midcast.Songs.Duration
        end
        if is_debug_enabled() then
            table.insert(debug_steps, {step=5, label="Buff", status="ok", value="Troubadour (duration)"})
        end
    end

    -- Step 6: Final fallback to BardSong base
    if not selected_set then
        selected_set = base_set
        selected_set_path = 'sets.midcast.BardSong'
        if is_debug_enabled() then
            table.insert(debug_steps, {step=6, label="Fallback", status="info", value="BardSong (base)"})
        end
    end

    if not selected_set then
        return false
    end

    -- Emit debug steps before equipping
    if is_debug_enabled() then
        for _, step_data in ipairs(debug_steps) do
            MessageMidcast.show_debug_step(step_data.step, step_data.label, step_data.status, step_data.value)
        end
    end

    equip_with_debug(selected_set, selected_set_path, false)
    return true
end

---============================================================================
--- STANDARD 9-PRIORITY BRANCH
--- Fallback chain (highest priority first):
---   P0: exact spell name at root
---   P1: exhaustive base-name combinations (target/skill/spell mix)
---   P2: type + target + mode (triple nested)
---   P3: type + mode (double nested)
---   P4: target + mode (double nested)
---   P5: target-specific (under skill, then root)
---   P6: type-specific at root
---   P7: type-specific under skill
---   P8: mode-specific under skill
---   P9: base set (skill only) — final fallback
---============================================================================

--- Resolve mode/type/target values from config and database functions.
--- @return mode_value, type_value, target_value
local function resolve_metadata(config)
    local mode_value, type_value, target_value

    -- Mode
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

    -- Type (from database func)
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

    -- Target (from target func)
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

    return mode_value, type_value, target_value
end

local function select_standard_set(config, base_set)
    local selected_set = nil
    local selected_set_path = nil

    local mode_value, type_value, target_value = resolve_metadata(config)

    if is_debug_enabled() then
        MessageMidcast.show_priorities_header()
    end

    -- P0: exact spell name at root (sets.midcast["Refresh III"])
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

    -- P1: exhaustive search with base name + target + skill combinations
    if not selected_set and config.spell and config.spell.english then
        local base_name = config.spell.english:gsub("%s+[IVX]+$", "")
        local paths_to_try = {}

        if target_value then
            table.insert(paths_to_try, {base_name, target_value})
            table.insert(paths_to_try, {target_value, base_name})
            if config.skill then
                table.insert(paths_to_try, {config.skill, base_name, target_value})
                table.insert(paths_to_try, {config.skill, target_value, base_name})
            end
        end

        if target_value ~= 'others' then
            table.insert(paths_to_try, {base_name})
            if config.skill then
                table.insert(paths_to_try, {config.skill, base_name})
            end
        end

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

    -- P2: triple nested (type + target + mode)
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

    -- P3: double nested (type + mode)
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

    -- P4: double nested (target + mode)
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

    -- P5: target-specific (under skill, then root)
    if not selected_set and target_value then
        if base_set[target_value] then
            selected_set = base_set[target_value]
            selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. target_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(5, 'Target (' .. target_value .. ')', true)
            end
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

    -- P6: type-specific at root (spell_family)
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

    -- P7: type-specific (under skill)
    if not selected_set and type_value then
        if base_set[type_value] then
            selected_set = base_set[type_value]
            selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. type_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(7, 'Type (' .. type_value .. ')', true)
            end
        end
    end

    -- P8: mode-specific (under skill)
    if not selected_set and mode_value then
        if base_set[mode_value] then
            selected_set = base_set[mode_value]
            selected_set_path = 'sets.midcast["' .. config.skill .. '"].' .. mode_value
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(8, 'Mode (' .. mode_value .. ')', true)
            end
        end
    end

    -- P9: final fallback to base set
    if not selected_set then
        selected_set = base_set
        selected_set_path = 'sets.midcast["' .. config.skill .. '"]'
    end

    if not selected_set then
        return false
    end

    local is_fallback = (selected_set == base_set)
    equip_with_debug(selected_set, selected_set_path, is_fallback)
    return true
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Universal midcast set selection.
--- Validates input, resolves base set, then delegates to the appropriate
--- branch (Singing for BRD, standard 9-priority chain otherwise).
--- @param config table { skill, spell, mode_state?, mode_value?, database_func?, target_func? }
--- @return boolean True if a set was equipped, false on validation failure
function MidcastManager.select_set(config)
    -- Validate input
    if not config or not config.skill then
        return false
    end

    if not sets or not sets.midcast then
        return false
    end

    -- Resolve base set: Singing uses BardSong, everything else uses sets.midcast[skill]
    local base_set
    if config.skill == 'Singing' then
        base_set = sets.midcast.BardSong
    else
        base_set = sets.midcast[config.skill]
    end

    if not base_set then
        return false
    end

    -- Debug header
    if is_debug_enabled() and config.spell then
        local spell_name = config.spell.english or 'Unknown'
        local target_name = (config.spell.target and config.spell.target.name)
            or (player and player.name) or 'Unknown'
        MessageMidcast.show_debug_header(spell_name, config.skill, target_name)
    end

    -- Route to the appropriate branch
    if config.skill == 'Singing' then
        return select_singing_set(config, base_set)
    else
        return select_standard_set(config, base_set)
    end
end

---============================================================================
--- HELPER FUNCTIONS (common job patterns)
---============================================================================

--- Determine target type for Enhancing Magic (Composure logic)
function MidcastManager.get_enhancing_target(spell)
    if not spell or not spell.target then
        return nil
    end

    -- If Composure is active AND casting on someone else (not self)
    -- Return 'Composure' to use sets.midcast['Enhancing Magic'].Composure
    -- (regardless of target type: PLAYER, NPC, TRUST, MOB, etc.)
    if buffactive and buffactive['Composure']
       and spell.target.name and spell.target.name ~= player.name then
        return 'Composure'
    else
        return nil
    end
end

--- Determine element for Elemental Magic (optional filter)
function MidcastManager.get_element(spell)
    if not spell or not spell.element then
        return nil
    end
    return spell.element
end

---============================================================================
--- BARD SONG HELPERS
---============================================================================

--- Extract song type from spell name (last word after removing tier)
--- Examples: "Knight's Minne V" → "Minne", "Blade Madrigal" → "Madrigal"
function MidcastManager.get_song_type(spell_name)
    if not spell_name then
        return nil
    end
    local base_song = spell_name:match("^(.+)%s+[IVX]+$") or spell_name
    local song_type = base_song:match("%s+(%S+)$") or base_song
    return song_type
end

--- Get required instrument for a song (if any).
--- Uses SongRotationManager if available, otherwise falls back to known specials.
function MidcastManager.get_song_instrument(spell_name)
    if not spell_name then
        return nil
    end

    if _G.SongRotationManager and _G.SongRotationManager.get_required_instrument then
        return _G.SongRotationManager.get_required_instrument(spell_name)
    end

    if spell_name == "Honor March" then
        return "Marsyas"
    elseif spell_name == "Aria of Passion" then
        return "Loughnashade"
    end

    return nil
end

---============================================================================
--- PRESET CONFIGS (common job patterns)
---============================================================================

--- RDM Enfeebling Magic configuration
function MidcastManager.rdm_enfeebling(spell, database_func)
    return {
        skill = 'Enfeebling Magic',
        spell = spell,
        mode_state = state.EnfeebleMode,
        database_func = database_func
    }
end

--- RDM/WHM/GEO Enhancing Magic configuration
function MidcastManager.enhancing(spell)
    return {
        skill = 'Enhancing Magic',
        spell = spell,
        mode_state = state.EnhancingMode,
        target_func = MidcastManager.get_enhancing_target
    }
end

--- BLM/RDM/GEO Elemental Magic configuration
function MidcastManager.elemental(spell)
    return {
        skill = 'Elemental Magic',
        spell = spell,
        mode_state = state.NukeMode
    }
end

--- WHM/RDM/PLD Cure Magic configuration
function MidcastManager.cure(spell)
    return {
        skill = 'Healing Magic',
        spell = spell,
        mode_state = state.CureMode
    }
end

return MidcastManager

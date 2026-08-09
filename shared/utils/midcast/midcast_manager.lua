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

--- Song set selection, in two phases.
---
--- PICKERS choose one set, most specific first, and stop at the first hit.
--- LAYERS then add to whatever was chosen - instrument gear and the Troubadour
--- overlay combine with the pick rather than replacing it, which is why they
--- are not part of the same chain.
---
--- Every picker returns (set, path, debug_step) instead of writing into shared
--- locals. The debug trail is collected by the caller for the same reason the
--- set is: a function cannot append to a table it was handed a copy of, and
--- that mistake does not show up in any diff.

--- Step 1: the song's own name, spaced or PascalCase.
local function song_by_name(spell_name)
    if sets.midcast[spell_name] then
        return sets.midcast[spell_name],
               'sets.midcast["' .. spell_name .. '"]',
               {step = 1, label = "Exact Name", status = "ok", value = spell_name}
    end

    local pascal_name = spell_name:gsub("%s+", "")
    if pascal_name ~= spell_name and sets.midcast[pascal_name] then
        return sets.midcast[pascal_name],
               'sets.midcast.' .. pascal_name,
               {step = 1.5, label = "PascalCase", status = "ok", value = pascal_name}
    end

    return nil, nil, {step = 1, label = "Exact Name", status = "warn", value = "Not found"}
end

--- Step 2: the song without its tier - "Valor Minuet IV" to "Valor Minuet".
local function song_by_base_name(spell_name)
    local base_song = spell_name:match("^(.+)%s+[IVX]+$") or spell_name
    if base_song ~= spell_name and sets.midcast[base_song] then
        return sets.midcast[base_song],
               'sets.midcast["' .. base_song .. '"]',
               {step = 2, label = "Base Song", status = "ok", value = base_song}
    end
    return nil, nil, {step = 2, label = "Base Song", status = "warn", value = "Not found"}
end

--- Step 3: the family, which is the last word - Minne, Madrigal, March.
local function song_by_type(spell_name)
    local song_type = MidcastManager.get_song_type(spell_name)
    if song_type and sets.midcast[song_type] then
        return sets.midcast[song_type],
               'sets.midcast.' .. song_type,
               {step = 3, label = "Song Type", status = "ok", value = song_type}
    end
    return nil, nil, {step = 3, label = "Song Type", status = "warn", value = "Not found"}
end

--- Step 3.5: the first word - "Honor March" to "Honor".
local function song_by_first_word(spell_name)
    local base_song = spell_name:match("^(.+)%s+[IVX]+$") or spell_name
    local first_word = base_song:match("^(%S+)")
    if not (first_word and first_word ~= base_song) then
        return nil
    end
    if sets.midcast[first_word] then
        return sets.midcast[first_word],
               'sets.midcast.' .. first_word,
               {step = 3.5, label = "First Word", status = "ok", value = first_word}
    end
    return nil, nil, {step = 3.5, label = "First Word", status = "warn", value = "Not found"}
end

-- Order is priority: the first picker that returns a set wins.
local SONG_PICKERS = { song_by_name, song_by_base_name, song_by_type, song_by_first_word }

--- Step 4: instrument gear, combined onto whatever was picked.
local function layer_instrument(selected_set, spell_name)
    local instrument = MidcastManager.get_song_instrument(spell_name)
    if instrument and sets.midcast.Songs and sets.midcast.Songs[instrument] then
        local layered = selected_set
                        and set_combine(selected_set, sets.midcast.Songs[instrument])
                        or sets.midcast.Songs[instrument]
        return layered, {step = 4, label = "Instrument", status = "ok", value = instrument}
    end
    return selected_set, {step = 4, label = "Instrument", status = "info", value = "Default"}
end

--- Step 5: Troubadour extends the song, so its duration gear goes on top.
local function layer_troubadour(selected_set)
    if buffactive and buffactive['Troubadour']
       and sets.midcast.Songs and sets.midcast.Songs.Duration then
        local layered = selected_set
                        and set_combine(selected_set, sets.midcast.Songs.Duration)
                        or sets.midcast.Songs.Duration
        return layered, {step = 5, label = "Buff", status = "ok", value = "Troubadour (duration)"}
    end
    return selected_set, nil
end

local function select_singing_set(config, base_set)
    if not (config.spell and config.spell.english) then
        return false
    end

    local spell_name = config.spell.english
    local debug_steps = {}
    local selected_set, selected_set_path

    for _, pick in ipairs(SONG_PICKERS) do
        local found, path, step = pick(spell_name)
        if step and is_debug_enabled() then
            table.insert(debug_steps, step)
        end
        if found then
            selected_set, selected_set_path = found, path
            break
        end
    end

    local step
    selected_set, step = layer_instrument(selected_set, spell_name)
    if step and is_debug_enabled() then
        table.insert(debug_steps, step)
    end

    selected_set, step = layer_troubadour(selected_set)
    if step and is_debug_enabled() then
        table.insert(debug_steps, step)
    end

    -- Step 6: no song set of any kind matched, so the BardSong base stands.
    if not selected_set then
        selected_set = base_set
        selected_set_path = 'sets.midcast.BardSong'
        if is_debug_enabled() then
            table.insert(debug_steps, {step = 6, label = "Fallback", status = "info", value = "BardSong (base)"})
        end
    end

    if not selected_set then
        return false
    end

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

--- One level of the midcast priority cascade.
---
--- Every resolver takes the same context and returns the set it found together
--- with the path that names it, or nothing. They RETURN rather than assign into
--- a shared local: a resolver that wrote to a value it received would be
--- writing to a copy, and the cascade would quietly stop selecting anything.
---
--- The order of RESOLVERS below IS the priority. Moving an entry changes which
--- set wins.

--- P0: the exact spell name at the root - sets.midcast["Refresh III"]
local function resolve_exact_spell(ctx)
    if not (ctx.config.spell and ctx.config.spell.english) then
        return nil
    end
    local found_set, found_path, success = try_path(ctx.config.spell.english)
    if success then
        if is_debug_enabled() then
            MessageMidcast.show_priority_check(0, '"' .. ctx.config.spell.english .. '"', true)
        end
        return found_set, found_path
    end
    if is_debug_enabled() then
        MessageMidcast.show_priority_check(0, '"' .. ctx.config.spell.english .. '"', false)
    end
    return nil
end

--- P1: the tier-less spell name, crossed with target and skill.
local function resolve_base_name(ctx)
    if not (ctx.config.spell and ctx.config.spell.english) then
        return nil
    end

    local base_name = ctx.config.spell.english:gsub("%s+[IVX]+$", "")
    local paths_to_try = {}

    if ctx.target then
        table.insert(paths_to_try, {base_name, ctx.target})
        table.insert(paths_to_try, {ctx.target, base_name})
        if ctx.config.skill then
            table.insert(paths_to_try, {ctx.config.skill, base_name, ctx.target})
            table.insert(paths_to_try, {ctx.config.skill, ctx.target, base_name})
        end
    end

    if ctx.target ~= 'others' then
        table.insert(paths_to_try, {base_name})
        if ctx.config.skill then
            table.insert(paths_to_try, {ctx.config.skill, base_name})
        end
    end

    for i, path_parts in ipairs(paths_to_try) do
        local found_set, found_path, success = try_path(unpack(path_parts))
        if success then
            if is_debug_enabled() then
                MessageMidcast.show_priority_check(1, table.concat(path_parts, '.'), true)
            end
            return found_set, found_path
        elseif is_debug_enabled() and i == 1 then
            MessageMidcast.show_priority_check(1, table.concat(path_parts, '.'), false)
        end
    end
    return nil
end

--- P2: type, then target, then mode - the deepest nesting supported.
local function resolve_type_target_mode(ctx)
    if not (ctx.type and ctx.target and ctx.mode) then
        return nil
    end
    local nested = ctx.base_set[ctx.type]
    if not (nested and type(nested) == 'table') then
        return nil
    end
    nested = nested[ctx.target]
    if not (nested and type(nested) == 'table' and nested[ctx.mode]) then
        return nil
    end
    if is_debug_enabled() then
        MessageMidcast.show_priority_check(2, ctx.type .. '.' .. ctx.target .. '.' .. ctx.mode, true)
    end
    return nested[ctx.mode],
           'sets.midcast["' .. ctx.config.skill .. '"].' .. ctx.type .. '.' .. ctx.target .. '.' .. ctx.mode
end

--- P3: type, then mode.
local function resolve_type_mode(ctx)
    if not (ctx.type and ctx.mode) then
        return nil
    end
    local nested = ctx.base_set[ctx.type]
    if not (nested and type(nested) == 'table' and nested[ctx.mode]) then
        return nil
    end
    if is_debug_enabled() then
        MessageMidcast.show_priority_check(3, ctx.type .. '.' .. ctx.mode, true)
    end
    return nested[ctx.mode],
           'sets.midcast["' .. ctx.config.skill .. '"].' .. ctx.type .. '.' .. ctx.mode
end

--- P4: target, then mode.
local function resolve_target_mode(ctx)
    if not (ctx.target and ctx.mode) then
        return nil
    end
    local nested = ctx.base_set[ctx.target]
    if not (nested and type(nested) == 'table' and nested[ctx.mode]) then
        return nil
    end
    if is_debug_enabled() then
        MessageMidcast.show_priority_check(4, ctx.target .. '.' .. ctx.mode, true)
    end
    return nested[ctx.mode],
           'sets.midcast["' .. ctx.config.skill .. '"].' .. ctx.target .. '.' .. ctx.mode
end

--- P5: target alone, under the skill first and then at the root.
local function resolve_target(ctx)
    if not ctx.target then
        return nil
    end
    if ctx.base_set[ctx.target] then
        if is_debug_enabled() then
            MessageMidcast.show_priority_check(5, 'Target (' .. ctx.target .. ')', true)
        end
        return ctx.base_set[ctx.target],
               'sets.midcast["' .. ctx.config.skill .. '"].' .. ctx.target
    end
    if sets.midcast[ctx.target] then
        if is_debug_enabled() then
            MessageMidcast.show_priority_check(5, 'Target root (' .. ctx.target .. ')', true)
        end
        return sets.midcast[ctx.target], 'sets.midcast.' .. ctx.target
    end
    if is_debug_enabled() then
        MessageMidcast.show_priority_check(5, 'Target (' .. ctx.target .. ')', false)
    end
    return nil
end

--- P6: the spell family at the root.
local function resolve_type_root(ctx)
    if not ctx.type then
        return nil
    end
    if sets.midcast[ctx.type] then
        if is_debug_enabled() then
            MessageMidcast.show_priority_check(6, 'Type root (' .. ctx.type .. ')', true)
        end
        return sets.midcast[ctx.type], 'sets.midcast.' .. ctx.type
    end
    if is_debug_enabled() then
        MessageMidcast.show_priority_check(6, 'Type root (' .. ctx.type .. ')', false)
    end
    return nil
end

--- P7: the spell family under the skill.
local function resolve_type_under_skill(ctx)
    if not (ctx.type and ctx.base_set[ctx.type]) then
        return nil
    end
    if is_debug_enabled() then
        MessageMidcast.show_priority_check(7, 'Type (' .. ctx.type .. ')', true)
    end
    return ctx.base_set[ctx.type],
           'sets.midcast["' .. ctx.config.skill .. '"].' .. ctx.type
end

--- P8: the mode under the skill.
local function resolve_mode(ctx)
    if not (ctx.mode and ctx.base_set[ctx.mode]) then
        return nil
    end
    if is_debug_enabled() then
        MessageMidcast.show_priority_check(8, 'Mode (' .. ctx.mode .. ')', true)
    end
    return ctx.base_set[ctx.mode],
           'sets.midcast["' .. ctx.config.skill .. '"].' .. ctx.mode
end

-- Order is priority. P9, the base set itself, is the fallback below.
local RESOLVERS = {
    resolve_exact_spell,
    resolve_base_name,
    resolve_type_target_mode,
    resolve_type_mode,
    resolve_target_mode,
    resolve_target,
    resolve_type_root,
    resolve_type_under_skill,
    resolve_mode,
}

local function select_standard_set(config, base_set)
    local mode_value, type_value, target_value = resolve_metadata(config)

    if is_debug_enabled() then
        MessageMidcast.show_priorities_header()
    end

    local ctx = {
        config   = config,
        base_set = base_set,
        mode     = mode_value,
        type     = type_value,
        target   = target_value,
    }

    local selected_set, selected_set_path
    for _, resolve in ipairs(RESOLVERS) do
        selected_set, selected_set_path = resolve(ctx)
        if selected_set then
            break
        end
    end

    -- P9: nothing more specific matched, so the skill's own set stands.
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

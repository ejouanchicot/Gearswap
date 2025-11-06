---============================================================================
--- Midcast Manager - Universal Nested Set Selection with Complete Fallback Chain
---============================================================================
--- Centralized midcast gear selection system for ALL jobs with support for:
---   - Nested sets (e.g., mnd_potency.Valeur, self.Duration, FreeNuke.Fire)
---   - Complete fallback chain (nested > type > mode > base)
---   - Universal API for all magic skill types
---   - Database integration (optional)
---   - Guaranteed equipment (always fallback to base set)
---
--- USAGE:
---   local MidcastManager = require('shared/utils/midcast/midcast_manager')
---
---   -- In job_post_midcast:
---   MidcastManager.select_set({
---       skill = 'Enfeebling Magic',
---       spell = spell,
---       mode_state = state.EnfeebleMode,
---       database_func = RDMSpells.get_enfeebling_type,
---       extra_conditions = { ... }
---   })
---
--- @file midcast_manager.lua
--- @author Tetsouo
--- @version 1.0 - Universal Midcast Manager
--- @date Created: 2025-10-24
---============================================================================

local MidcastManager = {}

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
    add_to_chat(160, '===================================================')
    add_to_chat(160, '[MidcastManager] DEBUG MODE ENABLED')
    add_to_chat(160, '===================================================')
end

--- Disable debug logging
function MidcastManager.disable_debug()
    add_to_chat(160, '[MidcastManager] DEBUG MODE DISABLED')
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

--- Log debug message
--- @param message string Debug message
--- @param color number|nil Chat color (default 160 = light blue)
local function debug_log(message, color)
    if is_debug_enabled() then
        add_to_chat(color or 160, '[MidcastManager] ' .. message)
    end
end

--- Log debug header
--- @param message string Header message
local function debug_header(message)
    if is_debug_enabled() then
        add_to_chat(8, '-------------------------------------------------')
        add_to_chat(8, '[MidcastManager] ' .. message)
        add_to_chat(8, '-------------------------------------------------')
    end
end

--- Log debug step
--- @param step number Step number
--- @param message string Step message
--- @param result string|nil Result (OK/FAIL/WARN)
local function debug_step(step, message, result)
    if is_debug_enabled() then
        local prefix = string.format('  STEP %d: ', step)
        local suffix = result and (' -> ' .. result) or ''
        add_to_chat(160, '[MidcastManager] ' .. prefix .. message .. suffix)
    end
end

--- Log set info
--- @param set_name string Set name/path
--- @param exists boolean Whether set exists
local function debug_set(set_name, exists)
    if is_debug_enabled() then
        local status = exists and '[OK] EXISTS' or '[FAIL] NOT FOUND'
        local color = exists and 158 or 167
        add_to_chat(color, '[MidcastManager]     +- ' .. set_name .. ' -> ' .. status)
    end
end

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
    -- DEBUG: Start logging
    if is_debug_enabled() and config and config.spell then
        debug_header('SELECT_SET CALLED: ' .. (config.spell.english or 'Unknown Spell'))
    end

    -- Validate required parameters
    if not config or not config.skill then
        debug_log('[FAIL] VALIDATION FAILED: config or config.skill missing', 167)
        return false
    end

    debug_log('Skill: ' .. config.skill, 158)

    -- Validate sets.midcast exists
    if not sets or not sets.midcast then
        debug_log('[FAIL] VALIDATION FAILED: sets.midcast not found', 167)
        return false
    end

    -- Get base set path (e.g., sets.midcast['Enfeebling Magic'])
    local base_set = sets.midcast[config.skill]
    if not base_set then
        debug_log('[FAIL] VALIDATION FAILED: sets.midcast[\'' .. config.skill .. '\'] not found', 167)
        return false
    end

    debug_log('[OK] Base set found: sets.midcast[\'' .. config.skill .. '\']', 158)

    local selected_set = nil
    local mode_value = nil
    local type_value = nil
    local target_value = nil

    -- STEP 1: Get mode value from state OR direct value (if provided)
    if config.mode_value then
        -- Direct mode value provided (e.g., "Magic Burst", "MB", etc.)
        mode_value = config.mode_value
        debug_step(1, 'Mode (direct value)', '[OK] mode = "' .. tostring(mode_value) .. '"')
    elseif config.mode_state and config.mode_state.value then
        -- Mode state object provided (e.g., state.MagicBurstMode)
        mode_value = config.mode_state.value
        debug_step(1, 'Mode from state', '[OK] mode = "' .. tostring(mode_value) .. '"')
    else
        debug_step(1, 'Mode', '[WARN] No mode_value or mode_state provided')
    end

    -- STEP 2: Get type value from database (if provided)
    if config.database_func and config.spell and config.spell.english then
        local success, result = pcall(config.database_func, config.spell.english)
        if success then
            type_value = result
            debug_step(2, 'Type from database', '[OK] type = "' .. tostring(type_value) .. '"')
        else
            debug_step(2, 'Type from database', '[FAIL] ERROR: ' .. tostring(result))
        end
    else
        debug_step(2, 'Type from database', '[WARN] No database_func provided')
    end

    -- STEP 3: Get target value from target_func (if provided)
    if config.target_func and config.spell then
        local success, result = pcall(config.target_func, config.spell)
        if success then
            target_value = result
            debug_step(3, 'Target from target_func', '[OK] target = "' .. tostring(target_value) .. '"')
        else
            debug_step(3, 'Target from target_func', '[FAIL] ERROR: ' .. tostring(result))
        end
    else
        debug_step(3, 'Target from target_func', '[WARN] No target_func provided')
    end

    debug_log('CHECKING PRIORITIES (Spell-Specific -> Nested -> Type -> Mode -> Base):', 8)

    -- PRIORITY 0: Try spell-specific set first (highest priority)
    -- Example: sets.midcast["Stoneskin"], sets.midcast["Haste"]
    if config.spell and config.spell.english then
        debug_log('  [P0] Spell-Specific: ["' .. config.spell.english .. '"]')
        if sets.midcast[config.spell.english] then
            selected_set = sets.midcast[config.spell.english]
            debug_log('  [OK] [P0] FOUND: Spell-specific set selected! (sets.midcast["' .. config.spell.english .. '"])', 158)
        else
            debug_set('["' .. config.spell.english .. '"]', false)
        end
    end

    -- PRIORITY 1: Try triple nested set (type + target + mode)
    -- Example: sets.midcast['Elemental Magic'].Fire.MB.Acc
    if not selected_set and type_value and target_value and mode_value then
        debug_log('  [P1] Triple Nested: [' .. type_value .. '][' .. target_value .. '][' .. mode_value .. ']')
        local triple_nested = base_set[type_value]
        if triple_nested and type(triple_nested) == 'table' then
            triple_nested = triple_nested[target_value]
            if triple_nested and type(triple_nested) == 'table' and triple_nested[mode_value] then
                selected_set = triple_nested[mode_value]
                debug_log('  [OK] [P1] FOUND: Triple nested set selected!', 158)
            else
                debug_set('[' .. type_value .. '][' .. target_value .. '][' .. mode_value .. ']', false)
            end
        else
            debug_set('[' .. type_value .. '][' .. target_value .. ']', false)
        end
    end

    -- PRIORITY 2: Try double nested set (type + mode)
    -- Example: sets.midcast['Enfeebling Magic'].mnd_potency.Valeur
    if not selected_set and type_value and mode_value then
        debug_log('  [P2] Double Nested (type+mode): [' .. type_value .. '][' .. mode_value .. ']')
        local double_nested = base_set[type_value]
        if double_nested and type(double_nested) == 'table' and double_nested[mode_value] then
            selected_set = double_nested[mode_value]
            debug_log('  [OK] [P2] FOUND: Type+Mode nested set selected!', 158)
        else
            debug_set('[' .. type_value .. '][' .. mode_value .. ']', false)
        end
    end

    -- PRIORITY 3: Try double nested set (target + mode)
    -- Example: sets.midcast['Enhancing Magic'].self.Duration
    if not selected_set and target_value and mode_value then
        debug_log('  [P3] Double Nested (target+mode): [' .. target_value .. '][' .. mode_value .. ']')
        local double_nested = base_set[target_value]
        if double_nested and type(double_nested) == 'table' and double_nested[mode_value] then
            selected_set = double_nested[mode_value]
            debug_log('  [OK] [P3] FOUND: Target+Mode nested set selected!', 158)
        else
            debug_set('[' .. target_value .. '][' .. mode_value .. ']', false)
        end
    end

    -- PRIORITY 4: Try type-specific set
    -- Example: sets.midcast['Enfeebling Magic'].mnd_potency
    if not selected_set and type_value then
        debug_log('  [P4] Type Set: [' .. type_value .. ']')
        if base_set[type_value] then
            selected_set = base_set[type_value]
            debug_log('  [OK] [P4] FOUND: Type-specific set selected!', 158)
        else
            debug_set('[' .. type_value .. ']', false)
        end
    end

    -- PRIORITY 5: Try target-specific set
    -- Example: sets.midcast['Enhancing Magic'].self
    if not selected_set and target_value then
        debug_log('  [P5] Target Set: [' .. target_value .. ']')
        if base_set[target_value] then
            selected_set = base_set[target_value]
            debug_log('  [OK] [P5] FOUND: Target-specific set selected!', 158)
        else
            debug_set('[' .. target_value .. ']', false)
        end
    end

    -- PRIORITY 6: Try mode-specific set
    -- Example: sets.midcast['Enfeebling Magic'].Valeur
    if not selected_set and mode_value then
        debug_log('  [P6] Mode Set: [' .. mode_value .. ']')

        if base_set[mode_value] then
            selected_set = base_set[mode_value]
            debug_log('  [OK] [P6] FOUND: Mode-specific set selected!', 158)
        else
            debug_set('[' .. mode_value .. ']', false)
        end
    end

    -- PRIORITY 7: Final fallback - base set
    -- Example: sets.midcast['Enfeebling Magic']
    if not selected_set then
        debug_log('  [P7] Base Set: (fallback)', 206)
        selected_set = base_set
        debug_log('  [OK] [P7] FALLBACK: Base set selected!', 206)
    end

    -- Equip final set
    if selected_set then
        debug_log('[SUCCESS] EQUIPPING SET (success)', 158)
        equip(selected_set)

        -- Show equipped items if debug
        if is_debug_enabled() then
            debug_log('Equipped items:', 8)
            for slot, item in pairs(selected_set) do
                if type(item) == 'table' and item.name then
                    debug_log('    * ' .. slot .. ': ' .. item.name, 160)
                elseif type(item) == 'string' then
                    debug_log('    * ' .. slot .. ': ' .. item, 160)
                end
            end
        end

        return true
    end

    debug_log('[FAIL] FAILED: No set to equip (should never happen!)', 167)
    return false
end

---============================================================================
--- HELPER FUNCTIONS FOR COMMON PATTERNS
---============================================================================

--- Determine target type (self vs others) for Enhancing Magic
--- @param spell table Spell object from GearSwap
--- @return string|nil 'self', 'others', or nil
function MidcastManager.get_enhancing_target(spell)
    if not spell or not spell.target then
        return 'self'
    end

    if spell.target.type == 'PLAYER' and spell.target.name ~= player.name then
        return 'others'
    else
        return 'self'
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

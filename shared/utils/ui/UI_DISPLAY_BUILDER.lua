---============================================================================
--- UI Display Builder - Centralized Job Display Logic
---============================================================================
--- Replaces 247 lines of job-specific display duplication with intelligent
--- categorization system. Eliminates monolithic if/elseif job blocks.
---
--- @file ui/UI_DISPLAY_BUILDER.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-09-26
---============================================================================

local UIDisplayBuilder = {}

-- Load dependencies
local KeybindLoader = require('shared/utils/ui/UI_LOADER')

---============================================================================
--- KEYBIND CATEGORIZATION SYSTEM
---============================================================================

-- State categorization patterns
local categorization_rules = {
    spell_patterns = {
        "Spell", "Element", "Tier", "Aja", "Storm", "Bar", "EnSpell", "Spike",
        "Gain", "ecosystem", "species", "RuneElement", "Light", "Dark", "Rune",
        "BRDRotation", "VictoryMarch",  -- BRD song settings moved from modes
        "Etude",  -- BRD Etude stat buffs (EtudeType: STR/DEX/VIT/AGI/INT/MND/CHR)
        "QuickDraw",  -- COR Quick Draw element selection
        "Roll", "Luzaf",  -- COR Phantom Roll selection (MainRoll, SubRoll, LuzafRing)
        "Indi", "Geo", "AOE"  -- GEO Geocolure/Indicolure/AOE spells
    },

    ja_patterns = {
        "Step", "BRDSong"  -- Fixed from BRDSlot to BRDSong
    },

    weapon_patterns = {
        "Weapon", "WeaponSet", "SubSet", "Proc"
    },

    mode_patterns = {
        "Mode", "Combat", "Engaged", "Idle", "Enfeeble", "Nuke", "petIdleMode", "AutoPetEngage",
        "Rotation",  -- Removed BRDRotation and VictoryMarch - moved to spell_patterns
        "Xp",  -- XP mode for PLD/RDM
        "UseAltStep",  -- DNC step configuration mode (must be before ja_patterns check)
        "Auto",  -- Auto-trigger states (ClimacticAuto, etc.)
        "Lock",  -- Lock states (RangeLock for THF, etc.)
        "Marcato",  -- BRD auto-Marcato song selection (MarcatoSong: HonorMarch/AriaPassion/Off)
        "Dance"  -- DNC dance selection (Dance: Saber Dance/Fan Dance)
    }
}

--- Check if a state matches any pattern in a category
--- @param state_name string The state name to check
--- @param patterns table List of patterns to match against
--- @return boolean True if state matches any pattern
local function matches_category(state_name, patterns)
    for _, pattern in ipairs(patterns) do
        if state_name:find(pattern) then
            return true
        end
    end
    return false
end

--- Categorize a keybind based on its state
--- @param bind table Keybind object with key, desc, state
--- @return string Category name (spell, ja, weapon, mode, other)
local function categorize_keybind(bind)
    if not bind.state then
        return "other"
    end

    -- Check mode patterns FIRST (specific patterns like UseAltStep before generic "Step")
    if matches_category(bind.state, categorization_rules.mode_patterns) then
        return "mode"
    elseif matches_category(bind.state, categorization_rules.spell_patterns) then
        return "spell"
    elseif matches_category(bind.state, categorization_rules.ja_patterns) then
        return "ja"
    elseif matches_category(bind.state, categorization_rules.weapon_patterns) then
        return "weapon"
    else
        return "other"
    end
end

--- Filter out reverse keybinds (those with arrows)
--- @param keybinds table List of keybind objects
--- @return table Filtered keybinds without reverse arrows
local function filter_reverse_keybinds(keybinds)
    local filtered = {}
    for _, bind in ipairs(keybinds) do
        if not bind.desc:find("←") then
            table.insert(filtered, bind)
        end
    end
    return filtered
end

---============================================================================
--- DISPLAY KEY EXTRACTION
---============================================================================

--- Extract display keys for each category from job keybinds
--- @param job string The job abbreviation
--- @return table Categories with their respective keys
function UIDisplayBuilder.extract_display_keys(job)
    -- Get keybinds from KeybindLoader
    local keybinds = KeybindLoader.get_job_keybinds(job)

    if not keybinds then
        -- Use fallbacks if no config available
        keybinds = KeybindLoader.get_fallback_keybinds(job)
    end

    -- Add job-specific elements (like BRD song slots) - IMPORTANT: Must match UI_MANAGER flow
    if keybinds then
        keybinds = KeybindLoader.add_job_specific_elements(job, keybinds)
    end

    if not keybinds then
        return {
            spell_keys = {},
            ja_keys = {},
            weapon_keys = {},
            mode_keys = {}
        }
    end

    -- Filter out reverse keybinds for cleaner display
    keybinds = filter_reverse_keybinds(keybinds)

    -- Categorize keybinds
    local categories = {
        spell_keys = {},
        ja_keys = {},
        weapon_keys = {},
        mode_keys = {}
    }

    for _, bind in ipairs(keybinds) do
        local category = categorize_keybind(bind)

        if category == "spell" then
            table.insert(categories.spell_keys, bind.key)
        elseif category == "ja" then
            table.insert(categories.ja_keys, bind.key)
        elseif category == "weapon" then
            table.insert(categories.weapon_keys, bind.key)
        elseif category == "mode" then
            table.insert(categories.mode_keys, bind.key)
        end
    end

    -- Special handling for BRD song slots (display only)
    if job == "BRD" then
        -- Add empty key for song slots (handled by special display logic)
        table.insert(categories.ja_keys, "")
    end

    return categories
end

---============================================================================
--- JOB-SPECIFIC ENHANCEMENTS
---============================================================================

-- Job-specific enhancement rules
local job_enhancements = {
    BRD = {
        enhancing_keys = nil, -- BRD doesn't use enhancing section
        special_handling = function(categories)
            -- BRD song slots are handled in ja_keys with empty key
            return categories
        end
    },

    RDM = {
        enhancing_keys = function()
            -- RDM has specific enhancing spell keys
            return { "Ctrl+6", "Ctrl+7", "Ctrl+8", "Ctrl+9", "Ctrl+0" }
        end,
        special_handling = function(categories)
            return categories
        end
    },

    -- Add more job-specific enhancements as needed
    default = {
        enhancing_keys = nil,
        special_handling = function(categories)
            return categories
        end
    }
}

--- Apply job-specific enhancements to display categories
--- @param job string The job abbreviation
--- @param categories table Base categories
--- @return table Enhanced categories
function UIDisplayBuilder.apply_job_enhancements(job, categories)
    local enhancement = job_enhancements[job] or job_enhancements.default

    -- Apply special handling
    if enhancement.special_handling then
        categories = enhancement.special_handling(categories)
    end

    -- Add enhancing keys if available
    if enhancement.enhancing_keys then
        categories.enhancing_keys = enhancement.enhancing_keys()
    end

    return categories
end

---============================================================================
--- MAIN DISPLAY BUILDER FUNCTION
---============================================================================

--- Build complete display key structure for a job
--- @param job string The job abbreviation
--- @return table Complete display structure with all key categories
function UIDisplayBuilder.build_display_structure(job)
    -- Extract base categories
    local categories = UIDisplayBuilder.extract_display_keys(job)

    -- Apply job-specific enhancements
    categories = UIDisplayBuilder.apply_job_enhancements(job, categories)

    -- Ensure all required categories exist
    categories.spell_keys = categories.spell_keys or {}
    categories.ja_keys = categories.ja_keys or {}
    categories.weapon_keys = categories.weapon_keys or {}
    categories.mode_keys = categories.mode_keys or {}
    categories.enhancing_keys = categories.enhancing_keys or nil

    return categories
end

---============================================================================
--- VALIDATION AND DIAGNOSTICS
---============================================================================

--- Validate display structure
--- @param job string The job abbreviation
--- @param structure table Display structure to validate
--- @return boolean, table valid, issues
function UIDisplayBuilder.validate_structure(job, structure)
    local issues = {}

    -- Check required fields
    local required_fields = { "spell_keys", "ja_keys", "weapon_keys", "mode_keys" }
    for _, field in ipairs(required_fields) do
        if not structure[field] then
            table.insert(issues, "Missing required field: " .. field)
        elseif type(structure[field]) ~= "table" then
            table.insert(issues, "Field " .. field .. " must be a table")
        end
    end

    -- Check for empty structure (might indicate config issues)
    local total_keys = 0
    for _, field in ipairs(required_fields) do
        if structure[field] then
            total_keys = total_keys + #structure[field]
        end
    end

    if total_keys == 0 then
        table.insert(issues, "No display keys found for job " .. job .. " - check keybind configuration")
    end

    return #issues == 0, issues
end

--- Get statistics about categorization rules
--- @return table Statistics about rules and patterns
function UIDisplayBuilder.get_categorization_stats()
    local stats = {
        total_patterns = 0,
        categories = {}
    }

    for category, patterns in pairs(categorization_rules) do
        stats.categories[category] = #patterns
        stats.total_patterns = stats.total_patterns + #patterns
    end

    return stats
end

return UIDisplayBuilder

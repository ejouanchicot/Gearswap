---============================================================================
--- UI Display Builder - Centralized Job Display Logic
---============================================================================
--- Sorts a job's keybinds into the HUD sections (spells, abilities, weapons,
--- modes) from an explicit `section` field or, failing that, from patterns
--- matched against the state name. Shared by every job.
---
--- @file shared/utils/ui/UI_DISPLAY_BUILDER.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2025-09-26
---============================================================================

local UIDisplayBuilder = {}

local KeybindLoader = require('shared/utils/ui/UI_LOADER')
local UIStyle = require('shared/utils/ui/ui_style')

---============================================================================
--- KEYBIND CATEGORIZATION SYSTEM
---============================================================================

-- State categorization patterns (plain substring match via string.find).
-- mode_patterns are checked first, then spell, ja, weapon.
local categorization_rules = {
    spell_patterns = {
        "Spell", "Element", "Tier", "Aja", "Storm", "Bar", "EnSpell", "Spike",
        "Gain", "Ecosystem", "species", "RuneElement", "Light", "Dark", "Rune",
        "BRDRotation", "VictoryMarch",  -- BRD song settings (no BRDRotation state exists today)
        "Etude",  -- BRD Etude stat buffs (EtudeType: STR/DEX/VIT/AGI/INT/MND/CHR)
        "QuickDraw",  -- COR Quick Draw element selection
        "Roll", "Luzaf",  -- COR Phantom Roll selection (MainRoll, SubRoll, LuzafRing)
        "Indi", "Geo", "AOE"  -- GEO Geocolure/Indicolure/AOE spells
    },

    ja_patterns = {
        "Step", "BRDSong",  -- DNC steps, BRD song slots (BRDSong1..5)
        "WS"  -- Weaponskill slots (WS1..WS5), rebuilt per equipped weapon
    },

    weapon_patterns = {
        "Weapon", "WeaponSet", "SubSet", "Proc",
        "Instrument"  -- BRD MainInstrument: the instrument IS the range slot
    },

    mode_patterns = {
        "Mode", "Combat", "Engaged", "Idle", "Enfeeble", "Nuke", "PetIdleMode", "AutoPetEngage",
        "Rotation",
        "Xp",  -- XP mode for PLD/RDM
        "PhalanxSIRD",  -- Phalanx SIRD override for PLD
        "UseAltStep",  -- DNC step configuration mode (must be before ja_patterns check)
        "Auto",  -- Auto-trigger states (ClimacticAuto, etc.)
        "Lock",  -- Lock states (RangeLock for THF, etc.)
        "Marcato",  -- BRD auto-Marcato song selection (MarcatoSong: HonorMarch/AriaPassion/Off)
        "Dance",  -- DNC dance selection (Dance: Saber Dance/Fan Dance)
        "Samba",  -- DNC samba selection (Samba: Haste/Drain II/Aspir)
        -- BLM stratagem toggles: listed here so they land in modes rather than
        -- matching the generic "AOE" spell pattern checked further down.
        "SneakInvi",
        "Klimaform",
        "Favor",  -- SMN AvatarFavor toggle
        "Regen"   -- PLD /SCH and /RUN: sets.idleRegen laid over the idle set
    }
}

--- Section names accepted in a bind's `section` field -> HUD bucket.
local SECTION_ALIASES = {
    mode = "mode", modes = "mode",
    spell = "spell", spells = "spell",
    ability = "ja", abilities = "ja", ja = "ja",
    weapon = "weapon", weapons = "weapon",
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
    -- The player's own choice (UI_CONFIG layout.move_to_section) wins over all
    local forced = UIStyle.forced_section(bind)
    if forced then
        return forced
    end

    -- An explicit section (custom states, see custom_states.lua) wins over
    -- guessing from the state name.
    if SECTION_ALIASES[bind.section] then
        return SECTION_ALIASES[bind.section]
    end

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
    end

    -- Anything unmatched is a mode rather than nothing. extract_display_keys
    -- builds four buckets and has nowhere to put an "other", so a state whose
    -- name matched no pattern used to be dropped without a word - which is how
    -- BRD's MainInstrument and SMN's AvatarFavor, both the job's signature
    -- ^numpad3 slot, were missing from the HUD while their keys worked fine.
    -- A row in a section you did not expect is a far cheaper mistake than a
    -- row that is not there at all.
    return "mode"
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

--- The HUD section of one row (spell, ja, weapon, mode, other), for the
--- renderer: a row without a key ('') is drawn only in its own section.
--- @param bind table Keybind entry
--- @return string
function UIDisplayBuilder.categorize(bind)
    return categorize_keybind(bind)
end

--- Extract display keys for each category from job keybinds
--- @param job string The job abbreviation
--- @param keybinds table|nil The rows ui_display already built (BRD song slots
---   included); read from the job's keybind file when not given
--- @return table Categories with their respective keys
function UIDisplayBuilder.extract_display_keys(job, keybinds)
    if not keybinds then
        keybinds = KeybindLoader.get_job_keybinds(job)
        -- Add job-specific elements (like BRD song slots), as
        -- ui_display.get_current_job_keybinds() does for the rendered rows.
        if keybinds then
            keybinds = KeybindLoader.add_job_specific_elements(job, keybinds)
        end
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

    return categories
end

---============================================================================
--- MAIN DISPLAY BUILDER FUNCTION
---============================================================================

--- Build complete display key structure for a job. No row is ever sorted
--- into the enhancing section: the name stays accepted in the section order
--- (UI_CONFIG.lua, <JOB>_HUD.lua) and draws nothing.
--- @param job string The job abbreviation
--- @param keybinds table|nil Rows already built by the caller (see extract_display_keys)
--- @return table Complete display structure with all key categories
function UIDisplayBuilder.build_display_structure(job, keybinds)
    local categories = UIDisplayBuilder.extract_display_keys(job, keybinds)
    categories.spell_keys = categories.spell_keys or {}
    categories.ja_keys = categories.ja_keys or {}
    categories.weapon_keys = categories.weapon_keys or {}
    categories.mode_keys = categories.mode_keys or {}
    return categories
end

return UIDisplayBuilder

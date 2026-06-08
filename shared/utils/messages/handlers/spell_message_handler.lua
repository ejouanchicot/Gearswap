---============================================================================
--- Universal Spell Message Handler - Multi-Database Spell Message System
---============================================================================
--- Automatically detects and displays spell messages for ANY job/subjob combo.
--- Works by checking ALL spell databases until spell is found.
---
--- Features:
---   - Works for main job AND subjob spells
---   - Auto-detects spell database (skill-based or job-based)
---   - Respects ENFEEBLING_MESSAGES_CONFIG
---   - Respects ENHANCING_MESSAGES_CONFIG
---   - Zero job-specific code needed
---   - LAZY LOADING: Databases load on first spell cast (eliminates startup lag)
---
--- Architecture:
---   - PRIORITY 1: Skill-based databases (6 total: ENFEEBLING, ENHANCING, DARK, HEALING, ELEMENTAL, DIVINE)
---   - PRIORITY 2: Job-based databases (BLM_SPELL_DATABASE, RDM_SPELL_DATABASE, etc.)
---
--- Performance:
---   - Databases load on-demand when first spell is cast (not at require time)
---   - Lazy-loaded on first spell usage
---   - Once loaded, databases remain cached for instant access
---
--- Examples:
---   - WAR/RDM casting Haste >> Shows message from ENHANCING_MAGIC_DATABASE
---   - DNC/WHM casting Cure III >> Shows message from HEALING_MAGIC_DATABASE
---   - BLM casting Bio >> Shows message from ENFEEBLING_MAGIC_DATABASE
---   - GEO casting Aspir >> Shows message from DARK_MAGIC_DATABASE
---   - BLM casting Fire III >> Shows message from ELEMENTAL_MAGIC_DATABASE
---   - WHM casting Banish >> Shows message from DIVINE_MAGIC_DATABASE
---
--- @file shared/utils/messages/handlers/spell_message_handler.lua
--- @author Tetsouo
--- @version 2.3 - Lazy Loading (performance optimization)
--- @date Created: 2025-10-30 | Updated: 2025-11-04
---============================================================================

local SpellMessageHandler = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageCore = require('shared/utils/messages/message_core')

---============================================================================
--- MAGIC DATABASES (LAZY, PER-SKILL LOADING)
---============================================================================
--- Databases load individually, on demand. The first cast of a spell loads ONLY
--- the database matching that spell's skill (fast path), instead of every magic
--- database at once. This removes the first-cast freeze. Loaded modules are
--- cached; failed loads are remembered (false) so they are not retried per cast.

local db_cache = {}

--- Load a magic database by module path, memoized.
--- @param path string Module path
--- @return table|nil Database module, or nil if it failed to load
local function load_db(path)
    if db_cache[path] == nil then
        local success, db = pcall(require, path)
        db_cache[path] = (success and db) or false
    end
    return db_cache[path] or nil
end

-- Fast path: spell.skill -> the single database that holds it.
local SKILL_PATH = {
    ['Enfeebling Magic'] = 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE',
    ['Enhancing Magic']  = 'shared/data/magic/ENHANCING_MAGIC_DATABASE',
    ['Dark Magic']       = 'shared/data/magic/DARK_MAGIC_DATABASE',
    ['Healing Magic']    = 'shared/data/magic/HEALING_MAGIC_DATABASE',
    ['Elemental Magic']  = 'shared/data/magic/ELEMENTAL_MAGIC_DATABASE',
    ['Divine Magic']     = 'shared/data/magic/DIVINE_MAGIC_DATABASE',
    ['Ninjutsu']         = 'shared/data/magic/NINJUTSU_DATABASE',
    ['Blue Magic']       = 'shared/data/magic/BLU_SPELL_DATABASE',
    ['Summoning Magic']  = 'shared/data/magic/SMN_SPELL_DATABASE',
    ['Singing']          = 'shared/data/magic/BRD_SPELL_DATABASE',
    ['Geomancy']         = 'shared/data/magic/GEO_SPELL_DATABASE',
}

-- Fallback search order (priority: skill databases first, then job databases).
-- Only consulted when the fast path misses (skill/category mismatch, or a spell
-- not declared by its expected skill). `name` is the returned database label.
local FALLBACK_DATABASES = {
    { name = 'Enfeebling Magic', path = 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE' },
    { name = 'Enhancing Magic',  path = 'shared/data/magic/ENHANCING_MAGIC_DATABASE' },
    { name = 'Dark Magic',       path = 'shared/data/magic/DARK_MAGIC_DATABASE' },
    { name = 'Healing Magic',    path = 'shared/data/magic/HEALING_MAGIC_DATABASE' },
    { name = 'Elemental Magic',  path = 'shared/data/magic/ELEMENTAL_MAGIC_DATABASE' },
    { name = 'Divine Magic',     path = 'shared/data/magic/DIVINE_MAGIC_DATABASE' },
    { name = 'Ninjutsu',         path = 'shared/data/magic/NINJUTSU_DATABASE' },
    { name = 'RDM',              path = 'shared/data/magic/RDM_SPELL_DATABASE' },
    { name = 'WHM',              path = 'shared/data/magic/WHM_SPELL_DATABASE' },
    { name = 'BLM',              path = 'shared/data/magic/BLM_SPELL_DATABASE' },
    { name = 'GEO',              path = 'shared/data/magic/GEO_SPELL_DATABASE' },
    { name = 'BRD',              path = 'shared/data/magic/BRD_SPELL_DATABASE' },
    { name = 'SCH',              path = 'shared/data/magic/SCH_SPELL_DATABASE' },
    { name = 'BLU',              path = 'shared/data/magic/BLU_SPELL_DATABASE' },
    { name = 'SMN',              path = 'shared/data/magic/SMN_SPELL_DATABASE' },
}

-- Load message configs ONCE and cache the reference
-- The table is modified by set_display_mode() so we always see current mode
local ENFEEBLING_MESSAGES_CONFIG = nil
local ENHANCING_MESSAGES_CONFIG = nil

local function ensure_configs_loaded()
    if not ENFEEBLING_MESSAGES_CONFIG then
        local success, config = pcall(require, 'shared/config/ENFEEBLING_MESSAGES_CONFIG')
        if success then
            ENFEEBLING_MESSAGES_CONFIG = config
        else
            ENFEEBLING_MESSAGES_CONFIG = {
                display_mode = 'on',
                is_enabled = function() return true end,
                show_description = function() return false end
            }
        end
    end

    if not ENHANCING_MESSAGES_CONFIG then
        local success, config = pcall(require, 'shared/config/ENHANCING_MESSAGES_CONFIG')
        if success then
            ENHANCING_MESSAGES_CONFIG = config
        else
            ENHANCING_MESSAGES_CONFIG = {
                display_mode = 'on',
                is_enabled = function() return true end,
                show_description = function() return false end
            }
        end
    end
end

---============================================================================
--- SPELL LOOKUP
---============================================================================

--- Search for a spell, loading only the database(s) actually needed.
--- Fast path: the spell's own skill maps to a single database (1 require).
--- Fallback: scan the remaining databases in priority order (skill before job).
--- @param spell table Spell object from GearSwap (needs .name and .skill)
--- @return table|nil spell_data Spell data if found
--- @return string|nil database_name Name of database where spell was found
local function find_spell_in_databases(spell)
    local spell_name = spell.name

    -- FAST PATH: one database, selected by the spell's skill.
    local fast_path = spell.skill and SKILL_PATH[spell.skill]
    if fast_path then
        local db = load_db(fast_path)
        if db and db.spells and db.spells[spell_name] then
            return db.spells[spell_name], spell.skill
        end
    end

    -- FALLBACK: handles skill/category mismatches and job-unique spells.
    for _, db_entry in ipairs(FALLBACK_DATABASES) do
        if db_entry.path ~= fast_path then
            local db = load_db(db_entry.path)
            if db and db.spells and db.spells[spell_name] then
                return db.spells[spell_name], db_entry.name
            end
        end
    end

    return nil, nil
end

---============================================================================
--- MESSAGE DISPLAY
---============================================================================

--- Show spell message if config enabled
--- @param spell table Spell object from GearSwap
--- @param show_separator boolean Optional - show separator after message (default: true)
function SpellMessageHandler.show_message(spell, show_separator)
    -- Handle magic spells and Blood Pacts (SMN abilities treated as spells)
    if not spell then
        return
    end

    -- Accept Magic, BloodPactRage, and BloodPactWard action types
    local valid_action_types = {
        ['Magic'] = true,
        ['BloodPactRage'] = true,
        ['BloodPactWard'] = true
    }

    if not valid_action_types[spell.action_type] then
        return
    end

    -- Skip Geomancy spells (handled manually in GEO_MIDCAST)
    if spell.skill == 'Geomancy' then
        return
    end

    -- Skip BRD songs (handled manually in BRD_MIDCAST)
    if spell.skill == 'Singing' then
        return
    end

    -- Find spell in databases FIRST (before checking spell.skill)
    -- This is critical because some spells have mismatched skill vs category
    -- Example: Bio has spell.skill = "Dark Magic" but category = "Enfeebling"
    local spell_data, db_name = find_spell_in_databases(spell)

    if not spell_data then
        -- Spell not found in any database
        return
    end

    -- Ensure configs are loaded (only loads once, then cached)
    ensure_configs_loaded()

    -- Determine config based on spell CATEGORY (not spell.skill!)
    -- This allows Dark Magic spells with Enfeebling effects to show correctly
    local config = nil
    local category = spell_data.category

    -- Strategy: Only Enfeebling uses ENFEEBLING_MESSAGES_CONFIG
    -- All other categories use ENHANCING_MESSAGES_CONFIG by default
    -- This automatically covers: Enhancing, Healing, Divine, Dark, Elemental, Helix,
    -- Blue Magic (Buff/Physical/Magical/Breath/Debuff), Summoning (Avatar/Spirit/BP),
    -- BRD songs (26+ categories), GEO (Geocolure/Indicolure), and any future categories

    if category == 'Enfeebling' then
        config = ENFEEBLING_MESSAGES_CONFIG
    else
        -- Default: Use ENHANCING_MESSAGES_CONFIG for all other spell types
        -- This includes: Enhancing, Healing, Divine, Dark, Elemental, Helix,
        -- Blue Magic, Summoning, BRD songs, GEO spells, etc.
        config = ENHANCING_MESSAGES_CONFIG
    end

    -- Check if messages are enabled
    if not config or not config.is_enabled() then
        return
    end

    -- Prepare description (only if mode is 'full')
    local description = nil
    if config.show_description() then
        description = spell_data.description
    end

    -- Get target name and type (for buffs)
    local target_name = nil
    local target_type = nil
    if spell.target and spell.target.name then
        target_name = spell.target.name

        -- Detect target type with priority logic:
        -- IMPORTANT: Check spawn_type == 16 (monster) BEFORE is_npc!
        -- Both monsters and NPCs have is_npc = true, so spawn_type differentiates them
        -- 1. Player (in party/alliance or charmed)
        -- 2. Monster (spawn_type 16 - CHECK FIRST!)
        -- 3. NPC (spawn_type 2 or is_npc - portals, ???, vendors)

        if spell.target.in_party or spell.target.in_alliance then
            -- Party/alliance member = Player
            target_type = "PLAYER"
        elseif spell.target.charmed then
            -- Charmed mob = treat as player (it's helping us)
            target_type = "PLAYER"
        elseif spell.target.spawn_type == 16 then
            -- spawn_type 16 = Monster/Enemy (CHECK BEFORE is_npc!)
            target_type = "MONSTER"
        elseif spell.target.spawn_type == 2 or spell.target.is_npc then
            -- spawn_type 2 = NPC (includes portals, ??? NPCs, vendors, etc.)
            target_type = "NPC"
        elseif spell.target.type then
            -- Fallback to Windower's type if available
            target_type = spell.target.type
        else
            -- Default to MONSTER for unknown types (combat target assumption)
            target_type = "MONSTER"
        end
    end

    -- Use spell.english instead of spell.name (GearSwap convention)
    local spell_name = spell.english or spell.name or "Unknown"

    -- Get spell element from database (for color coding)
    local spell_element = spell_data.element

    -- Display message with target and get message length
    -- Pass spell.skill to detect Healing Magic spells, spell_element for color, and target_type for target color
    local message_length = MessageFormatter.show_spell_activated(spell_name, description, target_name, spell.skill, spell_element, target_type)

    -- Display separator after spell message (default: true unless explicitly disabled)
    -- Length = message length + 2 additional "=" characters
    if show_separator ~= false then
        MessageCore.show_separator(message_length + 2)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SpellMessageHandler

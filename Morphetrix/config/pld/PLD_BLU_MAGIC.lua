---============================================================================
--- PLD Blue Magic Configuration - Dynamic AOE Spell Detection
---============================================================================
--- Automatically detects equipped Blue Magic spells and creates AOE rotation.
--- Falls back to manual configuration if BLU subjob data unavailable.
---
--- Features:
---   • Dynamic spell detection from equipped Blue Magic spells
---   • Enmity-optimized spell priority (enmity/sec calculation)
---   • Automatic fallback to manual rotation if detection fails
---   • Priority sorting by enmity efficiency (CE+VE / Recast time)
---   • AOE-only spells (excludes Defense Down, DOT, Conal spells)
---   • Debug info API for rotation verification
---
--- Usage:
---   • get_rotation() - Returns active AOE spell rotation (dynamic or manual)
---   • is_dynamic() - Check if using dynamic detection
---   • get_info() - Get rotation info for debugging
---
--- @file    config/pld/PLD_BLU_MAGIC.lua
--- @author  Morphetrix
--- @version 2.0 - Dynamic spell detection
--- @date    Created: 2025-10-04
---============================================================================
local PLD_BLU_MAGIC = {}

---============================================================================
--- AOE SPELL DATABASE (Enmity Optimized)
---============================================================================
--- All AOE Blue Magic spells for PLD tank enmity generation (Level 1-60)
--- EXCLUDED: Defense Down spells, DOT effects, Conal spells
--- Source: https://www.bg-wiki.com/ffxi/Blue_Mage
---
--- Priority Formula: (Cumulative + Volatile) / Recast = Enmity per second
--- Higher enmity/sec = better for tank spam rotation
---
--- Spell Data (CE/VE/Total - Recast - Enmity/sec):
--- - Geist Wall:    320/320/640 - 30s = 21.33 enmity/sec ⭐ BEST (Dispel utility)
--- - Stinking Gas:  320/320/640 - 37s = 17.30 enmity/sec (VIT Down)
--- - Sheep Song:    320/320/640 - 60s = 10.67 enmity/sec (Sleep)
--- - Sound Blast:   1/320/321   - 30s = 10.70 enmity/sec (INT Down, weak CE)
--- - Soporific:     320/320/640 - 90s = 7.11 enmity/sec  (Sleep, long recast)
---
--- Note: Yawn (Level 64) impossible for PLD/BLU subjob (cap 60 with Master Level 50)
---============================================================================

PLD_BLU_MAGIC.aoe_spell_database = {{
    name = 'Geist Wall',
    enmity = 640,
    recast = 30,
    priority = 21.33
}, -- Best enmity/sec + Dispel
{
    name = 'Stinking Gas',
    enmity = 640,
    recast = 37,
    priority = 17.30
}, -- Excellent enmity/sec
{
    name = 'Sound Blast',
    enmity = 321,
    recast = 30,
    priority = 10.70
}, -- Decent (low CE)
{
    name = 'Sheep Song',
    enmity = 640,
    recast = 60,
    priority = 10.67
}, -- Good + Sleep utility
{
    name = 'Soporific',
    enmity = 640,
    recast = 90,
    priority = 7.11
} -- Backup Sleep
}

---============================================================================
--- FALLBACK MANUAL ROTATION
---============================================================================
--- Used when dynamic detection fails or BLU subjob not equipped
--- Priority order: Best enmity/sec first
---============================================================================

PLD_BLU_MAGIC.manual_rotation = {'Geist Wall', -- 21.33 enmity/sec (30s recast) - BEST
'Stinking Gas', -- 17.30 enmity/sec (37s recast)
'Sound Blast', -- 10.70 enmity/sec (30s recast)
'Sheep Song', -- 10.67 enmity/sec (60s recast)
'Soporific' -- 7.11 enmity/sec (90s recast)
}

---============================================================================
--- DYNAMIC SPELL DETECTION
---============================================================================

--- Get equipped BLU spells from Windower API
--- @return table|nil Array of equipped spell IDs, or nil if unavailable
local function get_equipped_blu_spells()
    if not windower or not windower.ffxi then
        return nil
    end

    local blu_data = windower.ffxi.get_mjob_data()
    if not blu_data or not blu_data.spells then
        return nil
    end

    return blu_data.spells
end

--- Check if a spell is equipped by name
--- @param spell_name string Spell name to check
--- @return boolean True if spell is equipped
local function is_spell_equipped(spell_name)
    local equipped_ids = get_equipped_blu_spells()
    if not equipped_ids then
        return false
    end

    local res = require('resources')
    local spell_data = res.spells:with('en', spell_name)
    if not spell_data then
        return false
    end

    for _, spell_id in ipairs(equipped_ids) do
        if spell_id == spell_data.id then
            return true
        end
    end

    return false
end

--- Build dynamic AOE rotation from equipped spells
--- @return table Array of spell names sorted by enmity efficiency (enmity/sec)
local function build_dynamic_rotation()
    local rotation = {}

    -- Sort database by priority (enmity/sec, highest first)
    local sorted_spells = {}
    for _, spell in ipairs(PLD_BLU_MAGIC.aoe_spell_database) do
        table.insert(sorted_spells, spell)
    end
    table.sort(sorted_spells, function(a, b)
        return a.priority > b.priority
    end)

    -- Add equipped spells to rotation in enmity efficiency order
    for _, spell in ipairs(sorted_spells) do
        if is_spell_equipped(spell.name) then
            table.insert(rotation, spell.name)
        end
    end

    return rotation
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Get the current AOE spell rotation (dynamic or fallback)
--- @return table Array of spell names in priority order
function PLD_BLU_MAGIC.get_rotation()
    -- Try dynamic detection first
    local dynamic_rotation = build_dynamic_rotation()

    -- Use dynamic if at least 1 AOE spell equipped
    if #dynamic_rotation > 0 then
        return dynamic_rotation
    end

    -- Fallback to manual rotation
    return PLD_BLU_MAGIC.manual_rotation
end

--- Check if using dynamic detection
--- @return boolean True if dynamic rotation active
function PLD_BLU_MAGIC.is_dynamic()
    local dynamic_rotation = build_dynamic_rotation()
    return #dynamic_rotation > 0
end

--- Get rotation info for debugging
--- @return table {mode, count, spells}
function PLD_BLU_MAGIC.get_info()
    local rotation = PLD_BLU_MAGIC.get_rotation()
    local is_dynamic = PLD_BLU_MAGIC.is_dynamic()

    return {
        mode = is_dynamic and "Dynamic" or "Manual",
        count = #rotation,
        spells = rotation
    }
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLD_BLU_MAGIC

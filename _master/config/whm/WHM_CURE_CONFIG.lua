---============================================================================
--- WHM Cure Configuration - Auto-Tier System
---============================================================================
--- Defines HP thresholds for automatic Cure tier selection.
--- Based on DNC Waltz system - automatically downgrades Cure tier if target
--- doesn't need full heal, optimizing MP efficiency.
---
--- Features:
---   • Auto-tier selection based on target HP missing
---   • MP efficiency (don't waste Cure VI on 100 HP missing)
---   • Stoneskin awareness (optional override to force big Cure)
---   • Configurable thresholds per Cure tier
---
--- Usage:
---   • Loaded by WHM_PRECAST.lua during Cure spell precast
---   • Call CureManager.select_cure_tier(spell, target_hpp) to get optimal tier
---   • Override with //gs c cure max to force highest tier (for Stoneskin farming)
---
--- @file    config/whm/WHM_CURE_CONFIG.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-21
---============================================================================

local WHMCureConfig = {}

---============================================================================
--- CURE TIER THRESHOLDS
---============================================================================

--- HP thresholds for Cure tier selection (based on HP missing)
--- Format: {min_hp_missing, max_hp_missing, spell_name}
--- Logic: If target missing HP is in range >> use this Cure tier
WHMCureConfig.cure_tiers = {
    -- Cure I: 0-200 HP missing (base ~130 HP, potency ~160 HP)
    {min = 0, max = 200, spell = 'Cure'},

    -- Cure II: 200-400 HP missing (base ~250 HP, potency ~300 HP)
    {min = 200, max = 400, spell = 'Cure II'},

    -- Cure III: 400-700 HP missing (base ~450 HP, potency ~550 HP)
    {min = 400, max = 700, spell = 'Cure III'},

    -- Cure IV: 700-1100 HP missing (base ~650 HP, potency ~850 HP)
    {min = 700, max = 1100, spell = 'Cure IV'},

    -- Cure V: 1100-1600 HP missing (base ~950 HP, potency ~1200 HP)
    {min = 1100, max = 1600, spell = 'Cure V'},

    -- Cure VI: 1600+ HP missing (base ~1300 HP, potency ~1700 HP)
    {min = 1600, max = 99999, spell = 'Cure VI'}
}

--- Curaga tier thresholds (AOE heals - less aggressive downgrade)
--- Curaga is expensive MP, so we're more conservative
WHMCureConfig.curaga_tiers = {
    -- Curaga: 0-300 HP missing
    {min = 0, max = 300, spell = 'Curaga'},

    -- Curaga II: 300-600 HP missing
    {min = 300, max = 600, spell = 'Curaga II'},

    -- Curaga III: 600-1000 HP missing
    {min = 600, max = 1000, spell = 'Curaga III'},

    -- Curaga IV: 1000-1400 HP missing
    {min = 1000, max = 1400, spell = 'Curaga IV'},

    -- Curaga V: 1400+ HP missing
    {min = 1400, max = 99999, spell = 'Curaga V'}
}

---============================================================================
--- AUTO-TIER SETTINGS
---============================================================================

--- Enable/disable auto-tier system
--- Set to false to disable automatic Cure tier selection
WHMCureConfig.auto_tier_enabled = true

--- Safety margin (extra HP to heal beyond missing)
--- Add this amount to missing HP when selecting tier (prevents near-miss heals)
--- Default: 50 HP
WHMCureConfig.safety_margin = 50

---============================================================================
--- DEBUG SETTINGS
---============================================================================

--- Show debug messages for Cure tier selection
--- Prints: "Target missing X HP >> Selected Cure Y"
--- Note: Formatted WHM messages are shown regardless of this setting
WHMCureConfig.debug_messages = false -- Set to true to enable verbose debug output

--- Message color (for add_to_chat)
WHMCureConfig.message_color = 8 -- Light blue

---============================================================================
--- MODULE EXPORT
---============================================================================

return WHMCureConfig

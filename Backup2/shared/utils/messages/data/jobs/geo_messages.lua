---============================================================================
--- GEO Message Data - Geomancer Messages
---============================================================================
--- Pure data file for GEO job messages
--- Used by new message system (api/messages.lua)
---
--- @file data/jobs/geo_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- SPELL CASTING (with inline colors)
    ---========================================================================

    indi_cast = {
        template = "{gray}[{lightblue}{job}{gray}] [{cyan}{spell}{gray}] {gray}>> {description}",
        color = 1  -- Base color (white)
    },

    geo_cast = {
        template = "{gray}[{lightblue}{job}{gray}] [{cyan}{spell}{gray}] {gray}>> {description}",
        color = 1  -- Base color (white)
    },

    ---========================================================================
    --- SPELL REFINEMENT
    ---========================================================================

    spell_refined = {
        template = "{gray}[{cyan}GEO{gray}] {blue}Refined: {white}{desired} {gray}>> {white}{final}",
        color = 1  -- Base color
    },

    no_tier_available = {
        template = "{gray}[{cyan}GEO{gray}] {red}No available tier for: {white}{spell}",
        color = 1  -- Base color
    }
}

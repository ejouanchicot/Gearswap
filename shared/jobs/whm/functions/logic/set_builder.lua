---  ═══════════════════════════════════════════════════════════════════════════
---   Set Builder - Shared Set Construction Logic (WHM)
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized set building for both engaged and idle states.
---   Handles:
---   • Town detection (safe zones with optimized gear)
---   • MP recovery optimization (latent refresh)
---   • Movement speed gear application
---   Unlike the other jobs, latent refresh and movement gear are applied in
---   town too (in_town is not used).
---
---   Used by: WHM_IDLE.lua and WHM_ENGAGED.lua
---
---   @file    shared/jobs/whm/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-21
---  ═══════════════════════════════════════════════════════════════════════════
local SetBuilder = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

-- Load base set builder (universal functions for town/movement)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE SET CONSTRUCTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Build idle set with town detection, MP recovery, and movement
---   Priority:
---   1. Town detection >> sets.idle.Town / sets.Adoulin
---   2. MP recovery (< 51%) >> sets.latent_refresh
---   3. Movement speed >> movement gear
---
---   @param base_set table Base idle set from whm_sets.lua
---   @return table Complete idle set with all modifications
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- TOWN DETECTION
    -- ══════════════════════════════════════════════════════════════════════════
    -- select_idle_base_town returns (set, is_in_town)
    local result, in_town = BaseSetBuilder.select_idle_base_town(base_set)

    -- ══════════════════════════════════════════════════════════════════════════
    -- MP RECOVERY (Latent Refresh - Timara WHM pattern)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Apply latent refresh gear if MP < 51% (WHM_CONFIG.lua refresh_mp_below)
    local mp_below = require('shared/utils/core/job_config').get('WHM', 'refresh_mp_below', 51)
    if player and player.mpp and player.mpp < mp_below then
        if sets.latent_refresh then
            result = set_combine(result, sets.latent_refresh)
        end
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- MOVEMENT SPEED
    -- ══════════════════════════════════════════════════════════════════════════
    result = BaseSetBuilder.apply_movement(result)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED SET CONSTRUCTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Build engaged set for WHM (minimal - WHM rarely melees)
---   @param base_set table Base engaged set from whm_sets.lua
---   @return table Complete engaged set (usually unchanged for WHM)
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- the party support's version of it (.Solo, .Group: shared/utils/party/support_tier.lua)
    return require('shared/utils/party/support_tier').engaged(base_set)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder

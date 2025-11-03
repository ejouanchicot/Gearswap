---============================================================================
--- Warp Precast - Force Fast Cast for Warp Spells (Universal)
---============================================================================
--- Forces Fast Cast gear when casting warp/teleport spells
--- Works for ALL jobs (BLM main, BLM sub, WHM main, WHM sub)
---
--- Why needed:
---   - MyHome addon can bypass normal GearSwap precast hooks
---   - Manual warp casts may not trigger proper precast
---   - Ensures FC always applied for transport spells
---
--- @file warp_precast.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-10-26
---============================================================================

local WarpPrecast = {}

-- Load MessageWarp for formatted messages
local MessageWarp = require('shared/utils/messages/message_warp')

---============================================================================
--- PRECAST FORCE FC
---============================================================================

--- Force Fast Cast gear for warp spells
--- @param spell table The spell object
--- @return boolean True if FC was applied
function WarpPrecast.force_fc(spell)
    if not spell or not spell.name then
        return false
    end

    local WarpDetector = require('shared/utils/warp/warp_detector')
    local is_warp, warp_data = WarpDetector.is_warp_spell(spell)

    if not is_warp then
        return false  -- Not a warp spell
    end

    -- Check if player has FC set available
    if not sets or not sets.precast or not sets.precast.FC then
        MessageWarp.show_precast_fc_warning(spell.name)
        return false
    end

    -- Equip Fast Cast set
    equip(sets.precast.FC)
    MessageWarp.show_force_fc(spell.name)

    return true
end

---============================================================================
--- INTEGRATION HOOK (called from job_precast)
---============================================================================

--- Hook function to be called from job_precast or global precast
--- @param spell table The spell object
--- @param eventArgs table Event arguments (optional)
--- @return boolean True if handled
function WarpPrecast.handle_precast(spell, eventArgs)
    -- Only process magic actions
    if not spell or spell.action_type ~= 'Magic' then
        return false
    end

    -- Check if it's a warp spell
    local WarpDetector = require('shared/utils/warp/warp_detector')
    local is_warp, warp_data = WarpDetector.is_warp_spell(spell)

    if not is_warp then
        return false  -- Not a warp spell
    end

    -- Force FC
    local fc_applied = WarpPrecast.force_fc(spell)

    -- Also trigger equipment lock
    local WarpEquipment = require('shared/utils/warp/warp_equipment')
    WarpEquipment.on_warp_spell(spell)

    return fc_applied
end

---============================================================================
--- MOTE HOOK (Global Precast Override)
---============================================================================

--- Global function for Mote-Include integration
--- Call this from Mote-Include's precast handler
--- @param spell table The spell object
--- @param eventArgs table Event arguments
function WarpPrecast.global_precast_hook(spell, eventArgs)
    -- Only handle warp spells
    if not spell or spell.action_type ~= 'Magic' then
        return
    end

    WarpPrecast.handle_precast(spell, eventArgs)
end

---============================================================================
--- INITIALIZATION
---============================================================================

--- Initialize warp precast system
function WarpPrecast.init()
    MessageWarp.show_precast_initialized()
end

return WarpPrecast

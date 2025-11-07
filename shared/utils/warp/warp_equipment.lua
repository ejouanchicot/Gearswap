---============================================================================
--- Warp Equipment Manager - Equipment Lock During Warp/Teleport
---============================================================================
--- Prevents equipment swaps during warp to avoid:
---   - Ring being swapped off during warp → warp cancels
---   - Main weapon being swapped off during warp → warp cancels
---
--- @file warp_equipment.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-10-26
---============================================================================

local WarpEquipment = {}

-- Load MessageWarp for formatted messages
local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

---============================================================================
--- STATE TRACKING
---============================================================================

local is_locked = false
local lock_timer = nil
local current_warp_type = nil  -- 'spell' or 'item'
local current_slot = nil  -- Track which slot is locked

---============================================================================
--- EQUIPMENT LOCK/UNLOCK
---============================================================================

--- Lock equipment slots to prevent swaps during warp
--- @param warp_type string Type of warp ('spell' or 'item')
--- @param duration number Duration to keep locked (seconds)
--- @param tag string Optional tag to display ([WARP] or [TELE])
--- @param slot string Optional slot being used ('ring1', 'main', etc.)
function WarpEquipment.lock(warp_type, duration, tag, slot)
    if is_locked then
        -- Already locked, will create new timer (old one will complete or be overwritten)
        lock_timer = nil
    end

    -- Lock specific slot or all equipment slots
    local success, err = pcall(function()
        if slot then
            -- Lock only the specified slot
            disable(slot)
        else
            -- Lock ALL equipment slots (for spells or when slot not specified)
            disable('main', 'sub', 'range', 'ammo',
                    'head', 'neck', 'ear1', 'ear2',
                    'body', 'hands', 'ring1', 'ring2',
                    'back', 'waist', 'legs', 'feet')
        end
    end)

    if not success then
        MessageWarp.show_equipment_lock_error(err)
        return
    end

    is_locked = true
    current_warp_type = warp_type
    current_slot = slot or 'all'

    -- Show lock message
    local display_tag = tag or 'WARP'
    local display_slot = slot or 'all slots'
    MessageWarp.show_equipment_locked(display_tag, display_slot)

    -- Schedule auto-unlock after duration + safety buffer
    local unlock_delay = (duration or 15) + 3  -- +3s safety buffer
    lock_timer = coroutine.schedule(function()
        WarpEquipment.unlock(true)  -- true = timeout unlock
    end, unlock_delay)
end

--- Unlock equipment slots after warp completes
--- @param is_timeout boolean True if unlocking due to timeout (optional)
--- @param tag string Optional tag to display ([WARP] or [TELE])
function WarpEquipment.unlock(is_timeout, tag)
    if not is_locked then
        return  -- Not locked, nothing to do
    end

    -- Clear timer reference (no need to cancel, will complete naturally)
    lock_timer = nil

    -- Unlock specific slot or all equipment slots
    local success, err = pcall(function()
        if current_slot and current_slot ~= 'all' then
            -- Unlock only the slot that was locked
            enable(current_slot)
        else
            -- Unlock ALL equipment slots
            enable('main', 'sub', 'range', 'ammo',
                   'head', 'neck', 'ear1', 'ear2',
                   'body', 'hands', 'ring1', 'ring2',
                   'back', 'waist', 'legs', 'feet')
        end
    end)

    if not success then
        MessageWarp.show_equipment_unlock_error(err)
        return
    end

    -- Show unlock message
    local display_tag = tag or 'WARP'
    local display_slot = current_slot or 'all slots'
    MessageWarp.show_equipment_unlocked(display_tag, display_slot)

    is_locked = false
    current_warp_type = nil
    current_slot = nil

    -- Force gear update after unlock to restore proper sets
    coroutine.schedule(function()
        if player then
            if player.status == 'Engaged' then
                equip(sets.engaged)
            elseif player.status == 'Idle' then
                equip(sets.idle)
            end
        end
    end, 0.5)
end

---============================================================================
--- AUTOMATIC WARP DETECTION
---============================================================================

--- Handle warp spell cast (called from precast)
--- @param spell table The warp spell object
function WarpEquipment.on_warp_spell(spell)
    -- Spells don't need equipment lock (they can't be unequipped)
    -- This function is kept for compatibility but does nothing
    return
end

--- Handle warp item usage (called from action event)
--- @param warp_data table The warp item data
function WarpEquipment.on_warp_item(warp_data)
    if not warp_data then return end

    local duration = warp_data.duration or 12
    local slot = warp_data.slot

    -- Convert generic slot names to specific GearSwap slots
    if slot == 'ring' then
        slot = 'ring1'  -- Default to ring1
    end
    -- 'main' and 'item' stay as-is

    -- Determine tag based on item name
    local tag = 'WARP'
    if warp_data.name and (warp_data.name:find('Teleport') or warp_data.name:find('Dim') or
                            warp_data.name:find('Holla') or warp_data.name:find('Dem') or
                            warp_data.name:find('Mea') or warp_data.name:find('Vahzl') or
                            warp_data.name:find('Yhoat') or warp_data.name:find('Altep')) then
        tag = 'TELE'
    end

    WarpEquipment.lock('item', duration, tag, slot)
end

---============================================================================
--- INITIALIZATION
---============================================================================

--- Initialize the warp equipment system
function WarpEquipment.init()
    local WarpDetector = require('shared/utils/warp/warp_detector')

    -- Register callback for item usage detection
    WarpDetector.register_callback(function(warp_type, warp_data)
        if warp_type == 'item' then
            WarpEquipment.on_warp_item(warp_data)
        end
    end)

    -- Initialize action listener for item detection
    WarpDetector.init_action_listener()

    -- Show init message
    MessageWarp.show_equipment_initialized()
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Check if equipment is currently locked
--- @return boolean True if locked
function WarpEquipment.is_locked()
    return is_locked
end

--- Get current warp type
--- @return string|nil Current warp type ('spell', 'item', or nil)
function WarpEquipment.get_warp_type()
    return current_warp_type
end

--- Force unlock (emergency use only)
--- @param tag string Optional tag to display ([WARP] or [TELE])
function WarpEquipment.force_unlock(tag)
    WarpEquipment.unlock(false, tag)
end

return WarpEquipment

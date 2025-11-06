# Watchdog Item Support - Implementation Summary

**Date:** 2025-11-04
**Version:** 3.1
**Issue:** Watchdog triggering on Warp Ring usage

---

## Problem

Watchdog was triggering when using items like Warp Ring because:

1. **Items use different resource file:**
   - Spells: `res/spells.lua` with `cast_time` field
   - Items: `res/items.lua` with `cast_delay` field (priority) or `cast_time` (fallback)

2. **Previous implementation only checked spells:**

   ```lua
   local res_spells = require('resources').spells
   -- Only checked spell cast_time, not item cast_delay
   ```

3. **Warp Ring data (ID: 28540):**

   ```lua
   cast_delay = 8  -- Primary field for items
   cast_time = 8   -- Fallback
   ```

---

## Solution

Extended Watchdog to support both spells and items:

### 1. **Added Item Resource Loading**

```lua
-- Load item resource data (contains cast_delay for usable items)
local res_items = require('resources').items
```

### 2. **Extended State Tracking**

```lua
local current_midcast = {
    active = false,
    spell_name = nil,
    spell_id = nil,
    item_id = nil,     -- NEW: Item ID
    action_type = nil, -- NEW: 'spell' or 'item'
    start_time = nil,
    timeout = nil
}
```

### 3. **Enhanced Timeout Calculation**

```lua
local function calculate_timeout(spell_id, item_id)
    local base_cast_time = 0

    -- PRIORITY 1: Check if it's an item (use cast_delay)
    if item_id and res_items[item_id] then
        local item_data = res_items[item_id]
        base_cast_time = item_data.cast_delay or item_data.cast_time or 0

    -- PRIORITY 2: Check if it's a spell (use cast_time)
    elseif spell_id and res_spells[spell_id] then
        local spell_data = res_spells[spell_id]
        base_cast_time = spell_data.cast_time or 0

    -- FALLBACK: Unknown action
    else
        return WATCHDOG_FALLBACK_TIMEOUT, 0
    end

    local timeout = base_cast_time + WATCHDOG_BUFFER
    return timeout, base_cast_time
end
```

### 4. **Action Type Detection**

```lua
function MidcastWatchdog.on_midcast_start(spell)
    local spell_id = nil
    local item_id = nil
    local action_type = 'spell'

    -- Detect action type
    if spell and spell.type == 'Item' then
        item_id = spell.id
        action_type = 'item'
    else
        spell_id = spell.id
        action_type = 'spell'
    end

    local timeout, base_cast_time = calculate_timeout(spell_id, item_id)
    -- Store all tracking data...
end
```

### 5. **Enhanced Debug Messages**

```lua
if action_type == 'item' then
    add_to_chat(158, string.format('[Watchdog DEBUG] Midcast started: %s [ITEM] (cast_delay: %.1fs, timeout: %.1fs)',
        spell_name, base_cast_time, timeout))
else
    add_to_chat(158, string.format('[Watchdog DEBUG] Midcast started: %s [SPELL] (cast_time: %.1fs, timeout: %.1fs)',
        spell_name, base_cast_time, timeout))
end
```

---

## Files Changed

### **shared/utils/core/midcast_watchdog.lua**

- Added `local res_items = require('resources').items`
- Extended `current_midcast` state with `item_id` and `action_type`
- Refactored `calculate_timeout()` to accept both spell_id and item_id
- Updated `on_midcast_start()` to detect and handle items
- Updated `on_aftercast()` to clear new fields
- Enhanced `check_stuck()` to show correct field name in messages
- Updated `get_stats()` to return item data
- Updated `clear_all()` to reset new fields
- Updated version to 3.1

### **shared/utils/core/WATCHDOG_COMMANDS.lua**

- Updated status display to show Item vs Spell label
- Updated stats display to show correct ID based on action type
- Updated version to 3.1

---

## Testing

**Test Case 1: Warp Ring (Item)**

```
Action: Use Warp Ring
Expected: Timeout = 8s (cast_delay) + 2s (buffer) = 10s
Result: ✅ No false trigger
```

**Test Case 2: Teleport-Holla (Spell)**

```
Action: Cast Teleport-Holla
Expected: Timeout = 20s (cast_time) + 2s (buffer) = 22s
Result: ✅ No false trigger
```

**Test Case 3: Debug Mode**

```
Command: //gs c watchdog debug
Expected: Shows [ITEM] or [SPELL] label with correct timing field
Result: ✅ Correctly labeled
```

---

## Command Reference

**Status (shows Item vs Spell):**

```
//gs c watchdog
//gs c watchdog stats
```

**Debug mode (see detailed cast timing):**

```
//gs c watchdog debug  -- Enable debug
//gs c watchdog debug  -- Disable debug
```

---

## Technical Notes

### **Priority System**

1. **Items first:** Check `cast_delay` (primary) or `cast_time` (fallback)
2. **Spells second:** Check `cast_time`
3. **Unknown:** Use fallback timeout (5.0s)

### **Action Type Detection**

```lua
if spell.type == 'Item' then
    -- Use res/items.lua data
else
    -- Use res/spells.lua data
end
```

### **Timeout Formula**

```
Items:  timeout = cast_delay + buffer (default 2.0s)
Spells: timeout = cast_time + buffer (default 2.0s)
```

---

## Examples

### **Warp Ring (ID: 28540)**

```lua
-- From res/items.lua
cast_delay = 8
cast_time = 8

-- Watchdog calculation
timeout = 8 + 2.0 = 10.0s
```

### **Teleport-Holla (ID: 262)**

```lua
-- From res/spells.lua
cast_time = 20

-- Watchdog calculation
timeout = 20 + 2.0 = 22.0s
```

### **Cure III (ID: 5)**

```lua
-- From res/spells.lua
cast_time = 2

-- Watchdog calculation
timeout = 2 + 2.0 = 4.0s
```

---

## Backwards Compatibility

✅ **Fully backwards compatible**

- All existing spell functionality preserved
- New item support adds capability without breaking changes
- Commands work identically for spells and items

---

## Architecture Notes

### **Separation of Concerns**

1. **midcast_watchdog.lua**: Core logic (spell + item detection)
2. **WATCHDOG_COMMANDS.lua**: User interface (status display)

### **Resource Access**

```lua
-- Spells (Magic, JobAbilities, etc.)
res_spells[spell_id].cast_time

-- Items (Warp Ring, Instant Warp, etc.)
res_items[item_id].cast_delay
res_items[item_id].cast_time  -- Fallback
```

---

## Status

✅ **COMPLETE** - Watchdog now supports both spells and items with correct timeout calculation

# WS Messages Hook Migration Guide

**Date:** 2025-11-06
**Version:** 1.0

---

## Overview

The WS (Weapon Skill) message system has been centralized using a universal hook pattern, eliminating code duplication across all job PRECAST files.

---

## What Changed

### Before (Old System)
Each job's PRECAST file manually called WS message functions:

```lua
-- In every job's PRECAST file (15 jobs × duplicated code)
if spell.type == 'WeaponSkill' then
    if WS_DB[spell.english] then
        MessageFormatter.show_ws_activated(spell.english, WS_DB[spell.english].description, final_tp)
    else
        MessageFormatter.show_ws_activated(spell.english, nil, final_tp)
    end
end
```

**Problems:**
- ❌ Code duplicated in 15+ job files
- ❌ Hard to maintain consistency
- ❌ Must update each job individually for changes
- ❌ Easy to introduce bugs

### After (New System)
Universal hook handles WS messages automatically:

```lua
-- In TETSOUO_JOB.lua (one line per character)
function get_sets()
    include('Mote-Include.lua')
    include('shared/hooks/init_ws_messages.lua')  -- ← WS messages enabled
    include('jobs/[job]/functions/[job]_functions.lua')
end
```

**Benefits:**
- ✅ Zero code duplication
- ✅ Centralized configuration (WS_MESSAGES_CONFIG)
- ✅ Works for ALL jobs automatically
- ✅ Easy to maintain and update

---

## Files Changed

### New File Created
- `shared/hooks/init_ws_messages.lua` - Universal WS messages hook

### Files Cleaned (15 jobs)
Removed duplicate WS message code from:
- `shared/jobs/blm/functions/BLM_PRECAST.lua`
- `shared/jobs/brd/functions/BRD_PRECAST.lua`
- `shared/jobs/bst/functions/BST_PRECAST.lua`
- `shared/jobs/cor/functions/COR_PRECAST.lua`
- `shared/jobs/dnc/functions/DNC_PRECAST.lua`
- `shared/jobs/drk/functions/DRK_PRECAST.lua`
- `shared/jobs/geo/functions/GEO_PRECAST.lua`
- `shared/jobs/pld/functions/PLD_PRECAST.lua`
- `shared/jobs/pup/functions/PUP_PRECAST.lua`
- `shared/jobs/rdm/functions/RDM_PRECAST.lua`
- `shared/jobs/run/functions/RUN_PRECAST.lua`
- `shared/jobs/sam/functions/SAM_PRECAST.lua`
- `shared/jobs/thf/functions/THF_PRECAST.lua`
- `shared/jobs/war/functions/WAR_PRECAST.lua`
- `shared/jobs/whm/functions/WHM_PRECAST.lua`

**What was removed:**
- ❌ `MessageFormatter.show_ws_activated()` calls
- ❌ WS description display logic
- ✅ **Kept:** `MessageFormatter.show_ws_validation_error()` (TP checks)

---

## How the Hook Works

### Hook Injection
The hook wraps `user_post_precast` globally:

```lua
function user_post_precast(spell, action, spellMap, eventArgs)
    -- Call original user_post_precast (if exists)
    if original_user_post_precast then
        original_user_post_precast(spell, action, spellMap, eventArgs)
    end

    -- Show universal WS message (only for weaponskills)
    if spell and spell.type == 'WeaponSkill' and WS_MESSAGES_CONFIG.is_enabled() then
        local ws_data = WS_DB.weaponskills[spell.english]
        local current_tp = windower.ffxi.get_player().vitals.tp

        if ws_data and WS_MESSAGES_CONFIG.show_description() then
            MessageFormatter.show_ws_activated(spell.english, ws_data.description, current_tp)
        elseif WS_MESSAGES_CONFIG.is_tp_only() then
            MessageFormatter.show_ws_activated(spell.english, nil, current_tp)
        end
    end
end
```

### Configuration Support
Respects `WS_MESSAGES_CONFIG` settings:

- **`full`** - Show WS name + description + TP
  Example: `[Upheaval] Four hits. Damage varies with TP. (2290 TP)`

- **`on`** - Show WS name + TP only
  Example: `[Upheaval] (2290 TP)`

- **`off`** - No messages (silent)

---

## Complete Hook System

Now all three message systems use the hook pattern:

| Hook File | Handles | Config File |
|-----------|---------|-------------|
| `init_ability_messages.lua` | Job Abilities (JA) | `JA_MESSAGES_CONFIG.lua` |
| `init_spell_messages.lua` | Magic Spells | `ENHANCING_MESSAGES_CONFIG.lua`<br>`ENFEEBLING_MESSAGES_CONFIG.lua` |
| `init_ws_messages.lua` | Weapon Skills (WS) | `WS_MESSAGES_CONFIG.lua` |

---

## Usage Example

### TETSOUO_WAR.lua
```lua
function get_sets()
    include('Mote-Include.lua')

    -- Enable all message systems (optional)
    include('shared/hooks/init_ability_messages.lua')  -- JA messages
    include('shared/hooks/init_spell_messages.lua')    -- Spell messages
    include('shared/hooks/init_ws_messages.lua')       -- WS messages

    include('jobs/war/war_functions.lua')

    -- Rest of setup...
end
```

### Example Messages
```
[WAR/SAM] Berserk activated! Attack +25%, Defense -25%
[WAR/SAM] Haste -> Increases attack speed.
[Upheaval] Four hits. Damage varies with TP. (2290 TP)
```

---

## Migration Impact

### Code Reduction
- **Before:** ~450 lines of duplicate WS message code across 15 jobs
- **After:** ~90 lines in single universal hook
- **Reduction:** ~75% code reduction

### Maintenance
- **Before:** Update 15 files for any WS message change
- **After:** Update 1 file (`init_ws_messages.lua`)

### Testing
All jobs tested with WS messages:
- ✅ Messages display correctly
- ✅ Configuration (full/on/off) works
- ✅ TP validation errors still work
- ✅ No duplicate messages

---

## Related Documentation

- **[CLAUDE.md](../CLAUDE.md)** - Project architecture guide
- **[Message System](../shared/config/)** - Message configuration files
- **[Hook System](../shared/hooks/)** - All hook files

---

**Author:** Tetsouo GearSwap Project
**Last Updated:** 2025-11-06

# New Message System - Quick Start Guide

## 🎯 Overview

The new message system replaces 40+ message formatter files with a clean, data-driven architecture:

- **Before**: 5000+ lines of duplicated code across 40 files
- **After**: 760 lines of core + data files (92% reduction!)

## 🚀 Quick Start

### Basic Usage

```lua
local M = require('shared/utils/messages/api/messages')

-- Job messages
M.job('BLM', 'manawall_ready', {time = 30})
-- Output: [BLM] ✓ Manawall ready (30s cooldown)

-- System messages
M.success("Everything works!")
M.error("Something went wrong")
M.warning("Be careful!")
M.info("FYI")

-- Custom messages
M.custom("[{job}] {action}", 158)
    :with('job', 'BLM')
    :with('action', 'Ready!')
    :send()
```

## 📁 Architecture

```
messages/
├── core/                      # Core logic (DO NOT EDIT)
│   ├── message_engine.lua     # Template compilation + caching
│   └── message_renderer.lua   # Rendering + color schemes
│
├── data/                      # MESSAGE DATA (EDIT THESE)
│   ├── jobs/
│   │   ├── blm_messages.lua   # BLM messages
│   │   ├── brd_messages.lua   # BRD messages
│   │   └── ...
│   └── systems/
│       ├── combat_messages.lua
│       └── magic_messages.lua
│
└── api/
    └── messages.lua           # Public API
```

## 📝 Adding New Messages

### 1. Add to data file

```lua
-- data/jobs/blm_messages.lua
return {
    my_new_message = {
        template = "[BLM] {action} completed in {time}s",
        color = 158  -- Green
    }
}
```

### 2. Use it

```lua
M.job('BLM', 'my_new_message', {
    action = 'Spell cast',
    time = 2.5
})
```

**That's it!** No code changes needed, just data.

## 🎨 Color Codes

### Template Color Tags (inline)

Use these in templates for colored text:

```lua
{gray}       -- Gray text (secondary info, labels)
{yellow}     -- Yellow (important values, names, items)
{green}      -- Green (success, active buffs, positive)
{orange}     -- Orange (warnings, attention needed)
{red}        -- Red (errors, critical, danger)
{cyan}       -- Cyan (actions, spell names, abilities)
{lightblue}  -- Light blue (job tags, headers)
{blue}       -- Blue (info, neutral)
{white}      -- White (default, body text)
```

**Example:**

```lua
template = "{gray}[{lightblue}{job}{gray}] {cyan}{spell}{gray} ready! ({yellow}{time}s{gray})"
-- Output: [BLM] Fire VI ready! (30s)
--         ^gray ^blue  ^cyan      ^yellow
```

### Message Color Codes (full message)

Use these for the `color` field in templates:

```lua
color = 1     -- White (default)
color = 8     -- Gray (debug, secondary)
color = 122   -- Light blue (info)
color = 158   -- Green (success)
color = 159   -- Green (alternate)
color = 167   -- Red (error)
color = 200   -- Yellow/Orange (warning)
color = 207   -- Light purple (lockstyle)
```

**Note:** The `color` field sets the base color for the entire message. Template tags override specific parts.

## ⚙️ Configuration

```lua
-- Toggle messages on/off
M.toggle()

-- Color schemes (accessibility)
M.set_color_mode('normal')      -- Default
M.set_color_mode('colorblind')  -- Color-blind friendly
M.set_color_mode('monochrome')  -- No colors

-- Add timestamps
M.toggle_timestamp()

-- Filter level
M.set_filter_level(0)  -- Show all
M.set_filter_level(1)  -- Important only
M.set_filter_level(2)  -- Critical only
```

## 🔧 Advanced Features

### Builder Pattern

```lua
M.custom("[{job}] {spell} ready!", 158)
    :with('job', 'BLM')
    :with('spell', 'Manawall')
    :colored(200)       -- Override color
    :level(1)           -- Set importance
    :send()
```

### Preview (testing)

```lua
local preview = M.custom("Test {value}", 158)
    :with('value', 123)
    :preview()
-- Returns: "[COLOR:158] Test 123"
-- Does NOT send to chat
```

### List available messages

```lua
M.list('BLM')
-- Shows all BLM messages
```

### Statistics

```lua
M.show_stats()
-- Shows:
-- - Total messages sent
-- - By namespace
-- - By color
```

## 🧪 Testing

Run the test suite:

```lua
-- In game:
//lua l shared/utils/messages/TEST_NEW_SYSTEM.lua

-- Or from GearSwap:
require('shared/utils/messages/TEST_NEW_SYSTEM')
```

Expected output:

```
==============================================
   NEW MESSAGE SYSTEM TEST
==============================================
TEST 1: Job Messages (BLM)
✓ Test 1.1 passed: Manawall ready
[BLM] ✓ Manawall ready (30s cooldown)
✓ Test 1.2 passed: Spell cast
[BLM] Casting Fire VI
...
✓ ALL TESTS PASSED (19/19)
🎉 New message system is READY!
```

## 📊 Performance

The new system is **highly optimized**:

- Template compilation: **Cached** (parsed once, reused forever)
- Data loading: **Lazy** (only loads when needed)
- Average: **< 0.1ms per message** (10,000 messages/second)

Test performance:

```lua
local M = require('shared/utils/messages/api/messages')
local start = os.clock()

for i = 1, 1000 do
    M.custom("Test {n}", 1):with('n', i):preview()
end

print(string.format("%.3f ms per message", (os.clock() - start)))
-- Expected: < 1.0 ms
```

## 🐛 Debugging

### Enable debug mode

```lua
M.config({ debug_log = true })
```

### Check engine stats

```lua
local stats = M.get_engine_stats()
print("Compiled templates:", stats.compiled_templates)
print("Loaded namespaces:", stats.loaded_namespaces)
print("Total messages:", stats.total_messages)
```

### Clear cache (development)

```lua
M.clear_cache()
-- Forces reload of all templates
```

## 📖 API Reference

### Core Methods

- `M.job(job, key, params)` - Send job message
- `M.combat(key, params)` - Send combat message
- `M.magic(key, params)` - Send magic message
- `M.ability(key, params)` - Send ability message
- `M.send(namespace, key, params, options)` - Generic send

### System Messages

- `M.success(msg)` - Green success message
- `M.error(msg)` - Red error message
- `M.warning(msg)` - Yellow warning message
- `M.info(msg)` - Blue info message
- `M.debug(msg)` - Gray debug message

### Configuration

- `M.toggle()` - Enable/disable all messages
- `M.set_color_mode(mode)` - Change color scheme
- `M.set_filter_level(level)` - Filter by importance
- `M.toggle_timestamp()` - Add/remove timestamps
- `M.config(options)` - Bulk configuration

### Utilities

- `M.list(namespace)` - List all messages in namespace
- `M.show_stats()` - Show statistics
- `M.reset_stats()` - Reset statistics
- `M.get_engine_stats()` - Engine cache stats
- `M.clear_cache()` - Clear template cache
- `M.help()` - Show help

## 🆕 Adding a New Job (Complete Guide)

### Step 1: Create Message Data File

Create `data/jobs/xxx_messages.lua`:

```lua
---============================================================================
--- XXX Message Data - Your Job Name
---============================================================================
return {
    ---========================================================================
    --- BASIC MESSAGES
    ---========================================================================

    ability_ready = {
        template = "{gray}[{lightblue}{job}{gray}] {cyan}{ability}{gray} ready!",
        color = 158
    },

    buff_active = {
        template = "{gray}[{lightblue}{job}{gray}] {green}{buff}{gray} is active",
        color = 1
    },

    ---========================================================================
    --- ERROR MESSAGES
    ---========================================================================

    no_target = {
        template = "{gray}[{lightblue}{job}{gray}] {red}No target selected{gray}",
        color = 167
    }
}
```

### Step 2: Create Formatter File

Create `formatters/jobs/message_xxx.lua`:

```lua
---============================================================================
--- XXX Messages Module
---============================================================================
local MessageXXX = {}

-- Load message API
local M = require('shared/utils/messages/api/messages')

-- Get job tag helper
local function get_job_tag()
    local main_job = player and player.main_job or 'XXX'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- PUBLIC FUNCTIONS (use show_* prefix)
---============================================================================

--- Display ability ready message
--- @param ability_name string Ability name
function MessageXXX.show_ability_ready(ability_name)
    M.job('XXX', 'ability_ready', {
        job = get_job_tag(),
        ability = ability_name
    })
end

--- Display buff active message
--- @param buff_name string Buff name
function MessageXXX.show_buff_active(buff_name)
    M.job('XXX', 'buff_active', {
        job = get_job_tag(),
        buff = buff_name
    })
end

--- Display no target error
function MessageXXX.show_error_no_target()
    M.job('XXX', 'no_target', {
        job = get_job_tag()
    })
end

return MessageXXX
```

### Step 3: Export in MessageFormatter

Add to `message_formatter.lua`:

```lua
-- Load XXX messages
local XXXMessages = require('shared/utils/messages/formatters/jobs/message_xxx')

-- Export XXX functions
MessageFormatter.show_ability_ready = XXXMessages.show_ability_ready
MessageFormatter.show_buff_active = XXXMessages.show_buff_active
MessageFormatter.show_error_no_target = XXXMessages.show_error_no_target
```

### Step 4: Use in Job Code

In your job functions:

```lua
local MessageFormatter = require('shared/utils/messages/message_formatter')

function job_precast(spell, eventArgs)
    if spell.name == "MyAbility" then
        MessageFormatter.show_ability_ready("MyAbility")
    end
end
```

### Naming Conventions

**Function names MUST follow this pattern:**

- ✅ `show_ability_ready()` - Action + state
- ✅ `show_error_no_target()` - Error messages start with `show_error_*`
- ✅ `show_warning_low_mp()` - Warnings start with `show_warning_*`
- ✅ `show_buff_active()` - State messages
- ❌ `error_no_target()` - Missing `show_` prefix
- ❌ `display_ability()` - Use `show_` not `display_`

**Template parameters:**

- Always include `{job}` in job messages for subjob support
- Use descriptive parameter names: `{ability}`, `{buff}`, `{target}`, not `{a}`, `{b}`, `{t}`
- Use color tags for values: `{yellow}{value}`, `{green}{status}`, `{red}{error}`

### Testing Your New Job

```lua
-- In game:
//lua l gearswap

-- Test your messages:
MessageFormatter.show_ability_ready("Test Ability")
MessageFormatter.show_buff_active("Haste")
MessageFormatter.show_error_no_target()
```

## 🔄 Migration from Old System

### Before

```lua
-- message_blm.lua
function MessageBLM.show_manawall_ready(time)
    add_to_chat(158, '[BLM] Manawall ready (' .. time .. 's)')
end
```

### After

```lua
-- data/jobs/blm_messages.lua
manawall_ready = {
    template = "[BLM] Manawall ready ({time}s)",
    color = 158
}

-- Usage
M.job('BLM', 'manawall_ready', {time = 30})
```

**Benefits**:

- ✅ Centralized data (easy to edit)
- ✅ No code duplication
- ✅ Automatic validation
- ✅ Better performance (caching)

## ❓ FAQ

**Q: Can I still use the old message_*.lua files?**
A: Yes, during migration both systems work. We'll phase out old ones gradually.

**Q: What if I need a one-off message?**
A: Use `M.custom()` builder pattern.

**Q: How do I translate messages?**
A: Just duplicate the data files (e.g., `blm_messages_fr.lua`) and switch language config.

**Q: Performance impact?**
A: New system is FASTER due to template caching. Old system parsed templates every time.

**Q: Can I use emojis?**
A: Yes! `✓ ✗ ⚠ ★ ⚔ 🛡 ☠` all work.

**Q: What if I see `{paramname}` in chat?**
A: Parameter not passed to template. Check your function call includes all required params.

**Q: Error "Missing parameter 'xxx' in template"?**
A: Template uses `{xxx}` but you didn't pass `xxx` in the params table.

## 🐛 Troubleshooting

### Error: "Missing parameter 'xxx' in template"

**Problem:** Template has `{xxx}` but params doesn't include it.

```lua
-- ❌ WRONG
template = "{job} {ability} ready!"
M.job('BLM', 'ability_ready', { job = 'BLM' })  -- Missing 'ability'

-- ✅ CORRECT
M.job('BLM', 'ability_ready', {
    job = 'BLM',
    ability = 'Manawall'  -- Added missing param
})
```

### Error: "Unknown color tag {xxx}"

**Problem:** Used invalid color tag in template.

```lua
-- ❌ WRONG
template = "{tan}{item}"  -- {tan} doesn't exist

-- ✅ CORRECT
template = "{yellow}{item}"  -- Use valid color
```

**Valid colors:** `{gray}`, `{yellow}`, `{green}`, `{orange}`, `{red}`, `{cyan}`, `{lightblue}`, `{blue}`, `{white}`

### Messages not showing

1. Check if messages are enabled: `M.toggle()`
2. Check filter level: `M.set_filter_level(0)` (show all)
3. Verify template syntax (no typos in param names)
4. Check message exists in data file
5. Verify exports in `message_formatter.lua`

### Template displays literal `{paramname}`

**Problem:** Parameter name mismatch.

```lua
-- Template uses {spell}, but you passed {ability}
template = "{spell} ready"
params = { ability = 'Fire' }  -- ❌ Wrong param name

-- Fix: Match parameter names
params = { spell = 'Fire' }     -- ✅ Correct
```

### Duplicate messages appearing

**Problem:** Multiple systems calling the same message (old + new).

**Solution:**

1. Search for old message calls: `grep -r "add_to_chat.*Ability" .`
2. Comment out old calls
3. Keep only new system calls

### Performance issues (lag)

1. Check cache stats: `M.get_engine_stats()`
2. Disable debug mode: `M.config({ debug_log = false })`
3. Reduce message frequency in your code

## 🎉 Summary

The new message system is:

- **92% less code** (760 lines vs 5000+)
- **Data-driven** (edit data, not code)
- **Faster** (template caching)
- **Cleaner** (one API for everything)
- **Accessible** (color schemes for colorblind)
- **Configurable** (filters, toggles, timestamps)

**Just use it!** 🚀

```lua
local M = require('shared/utils/messages/api/messages')
M.job('BLM', 'manawall_ready', {time = 30})
```

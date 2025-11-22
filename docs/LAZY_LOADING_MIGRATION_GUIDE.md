# Lazy Loading Migration Guide - Apply WAR Optimizations to All Jobs

## Summary

WAR optimization reduced loading from **1020ms → 215ms (-80%)**.

**Centralized optimizations (ALREADY DONE for ALL jobs):**
- ✅ init_ws_messages.lua (~300ms saved)
- ✅ init_ability_messages.lua (~250ms saved)
- ✅ init_spell_messages.lua (~200ms saved)
- ✅ INIT_SYSTEMS.lua (~5ms saved)

**Job-specific optimizations (need to replicate for each job):**
- ⚠️ 9-11 modules per job (~600ms saved per job)

---

## Quick Migration Checklist

For each job (BRD, PLD, RDM, COR, etc.):

### 1. LOCKSTYLE Module (30ms)
**File:** `shared/jobs/[job]/functions/[JOB]_LOCKSTYLE.lua`

**Find:**
```lua
local LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')
return LockstyleManager.create('JOB', 'config/job/JOB_LOCKSTYLE', 4, 'SAM')
```

**Replace with:** (use WAR_LOCKSTYLE.lua as template)
```lua
-- Lazy loading: Module created on first use
local LockstyleManager = nil
local lockstyle_module = nil

local function get_lockstyle_module()
    if not lockstyle_module then
        if not LockstyleManager then
            LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')
        end
        lockstyle_module = LockstyleManager.create(...)
    end
    return lockstyle_module
end

function select_default_lockstyle()
    return get_lockstyle_module().select_default_lockstyle()
end
-- ... exports
```

---

### 2. MACROBOOK Module (45ms)
**File:** `shared/jobs/[job]/functions/[JOB]_MACROBOOK.lua`

**Template:** Copy from `WAR_MACROBOOK.lua` (lines 23-48)

---

### 3. PRECAST Module (150-180ms) ⚠️ BIGGEST SAVINGS
**File:** `shared/jobs/[job]/functions/[JOB]_PRECAST.lua`

**Find all require() at top:**
```lua
local MessageFormatter = require('...')
local CooldownChecker = require('...')
local PrecastGuard = require('...')
-- etc.
```

**Replace with lazy loading pattern from WAR_PRECAST.lua (lines 22-94):**
```lua
local MessageFormatter = nil
local CooldownChecker = nil
-- etc.

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end
    MessageFormatter = require('...')
    -- ... load all
    modules_loaded = true
end

function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()  -- ← Add this first!
    -- ... rest of function
end
```

---

### 4. MIDCAST Module (15-20ms)
**File:** `shared/jobs/[job]/functions/[JOB]_MIDCAST.lua`

**Template:** Copy pattern from `WAR_MIDCAST.lua` (lines 15-32)

---

### 5. IDLE Module (50ms)
**File:** `shared/jobs/[job]/functions/[JOB]_IDLE.lua`

**Find:**
```lua
local SetBuilder = require('shared/jobs/[job]/functions/logic/set_builder')
```

**Replace:**
```lua
local SetBuilder = nil

function customize_idle_set(idleSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/[job]/functions/logic/set_builder')
    end
    -- ... rest
end
```

---

### 6. ENGAGED Module (100ms)
**File:** `shared/jobs/[job]/functions/[JOB]_ENGAGED.lua`

**Same pattern as IDLE** - lazy load SetBuilder

---

### 7. STATUS Module (30ms)
**File:** `shared/jobs/[job]/functions/[JOB]_STATUS.lua`

**Find:**
```lua
local DoomManager = require('shared/utils/debuff/doom_manager')
```

**Replace with pattern from WAR_STATUS.lua (lines 20-38)**

---

### 8. BUFFS Module (80ms)
**File:** `shared/jobs/[job]/functions/[JOB]_BUFFS.lua`

**Find all require() at top, replace with:**
```lua
local SmartbuffManager = nil
local DoomManager = nil

local function ensure_managers_loaded()
    if not SmartbuffManager then
        SmartbuffManager = require('...')
    end
    if not DoomManager then
        DoomManager = require('...')
    end
end

-- Call ensure_managers_loaded() in every exported function
```

---

### 9. COMMANDS Module (56ms)
**File:** `shared/jobs/[job]/functions/[JOB]_COMMANDS.lua`

**Template:** Copy lazy loading pattern from `WAR_COMMANDS.lua` (lines 22-36)

---

## Automated Batch Processing (Advanced)

For bulk migration, use find/replace across files:

### Step 1: Find all LOCKSTYLE files
```bash
find shared/jobs/*/functions/*_LOCKSTYLE.lua
```

### Step 2: Use sed/awk to apply pattern (Linux/Git Bash)
```bash
for job in brd blm bst cor dnc drk geo pld rdm run sam thf whm; do
    file="shared/jobs/$job/functions/${job^^}_LOCKSTYLE.lua"
    if [ -f "$file" ]; then
        echo "Optimizing $file..."
        # Apply transformation (use WAR_LOCKSTYLE.lua as template)
    fi
done
```

### Step 3: Test each job after migration
```bash
//lua reload gearswap
```

---

## Expected Results Per Job

| Job | Before | After | Savings |
|-----|--------|-------|---------|
| WAR | 1020ms | 215ms | -80% ✅ |
| BRD | ~950ms | ~200ms | -79% (estimated) |
| PLD | ~900ms | ~190ms | -79% (estimated) |
| RDM | ~980ms | ~210ms | -79% (estimated) |
| ... | ... | ... | ... |

---

## Priority Order (Biggest Impact First)

1. **PRECAST** (150-180ms) ⚠️ DO THIS FIRST
2. **ENGAGED** (100ms)
3. **IDLE** (50ms)
4. **COMMANDS** (56ms)
5. **MACROBOOK** (45ms)
6. **BUFFS** (30-80ms depending on job)
7. **LOCKSTYLE** (30ms)
8. **STATUS** (30ms)
9. **MIDCAST** (15-20ms)

---

## Testing Checklist

After migrating each job:

- [ ] Load test: `//lua reload gearswap` (check timings in chat)
- [ ] Functionality test: Use abilities/spells/WS
- [ ] Command test: `//gs c [command]`
- [ ] Subjob test: Change subjob
- [ ] Combat test: Engage enemy

---

## Common Pitfalls

1. ❌ **Don't lazy-load in `[job]_functions.lua`** - That file just includes others
2. ❌ **Don't forget to call `ensure_*_loaded()`** in EVERY exported function
3. ❌ **Don't break factory returns** - LOCKSTYLE/MACROBOOK need special wrappers
4. ✅ **Do copy exact patterns from WAR** - They're battle-tested

---

## Need Help?

Reference files (fully optimized):
- `shared/jobs/war/functions/WAR_PRECAST.lua`
- `shared/jobs/war/functions/WAR_COMMANDS.lua`
- `shared/jobs/war/functions/WAR_LOCKSTYLE.lua`
- `shared/jobs/war/functions/WAR_MACROBOOK.lua`

Compare before/after using git diff or manual inspection.

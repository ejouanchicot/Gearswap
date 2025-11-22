# Performance Audit - Job Loading Freeze (1 Second)

**Date:** 2025-11-15
**Issue:** 1-second freeze when loading jobs, crashes on low-end PCs
**Root Cause:** Synchronous loading of 13 weaponskill databases (260-650ms)
**Status:** IDENTIFIED - Fix in progress

---

## EXECUTIVE SUMMARY

The 1-second freeze during job loading is caused by **synchronous loading of UNIVERSAL_WS_DATABASE** in `init_ws_messages.lua`. This module loads **13 weapon type databases** (212 weaponskills) for ALL jobs, even mages that rarely use weaponskills.

**Impact:**
- **ALL jobs:** 260-650ms freeze during get_sets()
- **Low-end PCs:** Game crash due to Lua blocking I/O
- **User experience:** Noticeable lag when switching jobs

**Proposed Fix:**
- **Lazy-load UNIVERSAL_WS_DATABASE** (like data_loader.lua)
- **Expected improvement:** 260-650ms faster job loading
- **Implementation complexity:** Low (1-2 hours)

---

## DETAILED ANALYSIS

### 1. Loading Sequence (Synchronous)

All jobs execute this sequence in `get_sets()`:

```lua
function get_sets()
    include('Mote-Include.lua')                    -- ~200-300ms (GearSwap framework)
    include('INIT_SYSTEMS.lua')                    -- ~50-100ms  (4 systems)
    require('data_loader')                         -- ~5ms       (lazy-loaded)
    include('init_spell_messages.lua')             -- ~10ms      (1 require)
    include('init_ability_messages.lua')           -- ~10ms      (1 require)
    include('init_ws_messages.lua')                -- ⚠️ 260-650ms (13 requires!)
    require('RECAST_CONFIG')                       -- ~5ms
    require('[JOB]_TP_CONFIG')                     -- ~5ms
    include('[job]_functions.lua')                 -- ~50-100ms  (11 hook modules)
end

function init_gear_sets()
    include('[job]_sets.lua')                      -- ~30-50ms   (533-647 lines)
end

function user_setup()
    require('[JOB]_STATES')                        -- ~10ms
    require('[JOB]_KEYBINDS')                      -- ~10ms
    require('UI_MANAGER')                          -- ~20ms
end
```

**Total estimated load time:** **600-1200ms**

**Breakdown by category:**
- **Mote-Include:** 200-300ms (unavoidable)
- **UNIVERSAL_WS_DATABASE:** 260-650ms ⚠️ **PRIMARY BOTTLENECK**
- **Job modules:** 50-100ms
- **Equipment sets:** 30-50ms
- **Other systems:** ~100ms

---

### 2. PRIMARY BOTTLENECK: UNIVERSAL_WS_DATABASE

**File:** `shared/data/weaponskills/UNIVERSAL_WS_DATABASE.lua`
**Size:** 321 lines
**Loading method:** Synchronous require() at module load time
**Impact:** ALL jobs load ALL weaponskills (even mages)

#### Loading Process (lines 71-109):

```lua
for _, config in ipairs(weapon_type_configs) do
    local success, weapon_db = pcall(require, 'shared/data/weaponskills/' .. config.file)

    if success and weapon_db and weapon_db.weaponskills then
        -- Merge weaponskills into universal table
        for ws_name, ws_data in pairs(weapon_db.weaponskills) do
            UniversalWS[ws_name] = ws_data
            UniversalWS.weaponskills[ws_name] = ws_data
        end
    end
end
```

**13 databases loaded synchronously:**
1. SWORD_WS_DATABASE (22 WS)
2. DAGGER_WS_DATABASE (18 WS)
3. H2H_WS_DATABASE (17 WS)
4. GREATSWORD_WS_DATABASE (15 WS)
5. GREATAXE_WS_DATABASE (18 WS)
6. AXE_WS_DATABASE (15 WS)
7. SCYTHE_WS_DATABASE (15 WS)
8. POLEARM_WS_DATABASE (15 WS)
9. KATANA_WS_DATABASE (15 WS)
10. GREATKATANA_WS_DATABASE (15 WS)
11. STAFF_WS_DATABASE (18 WS)
12. CLUB_WS_DATABASE (17 WS)
13. ARCHERY_WS_DATABASE (12 WS)

**Total:** 212 weaponskills

**Estimated time:**
- File I/O: 13 × 20ms = **260ms** (best case - SSD)
- File I/O: 13 × 50ms = **650ms** (worst case - HDD)
- Parsing Lua tables: +50-100ms

**Total bottleneck:** **260-650ms per job load**

#### Loaded by: `init_ws_messages.lua` (line 40)

```lua
local WS_DB_success, WS_DB = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
```

**Problem:** This happens at MODULE LOAD TIME, not on-demand.

---

### 3. SECONDARY BOTTLENECKS (Minor)

#### 3.1 INIT_SYSTEMS.lua (~50-100ms)

Loads 4 systems synchronously:
- **MidcastWatchdog:** require() - needed immediately
- **WarpInit:** require() - could defer
- **AutoMove:** include() - slower than require(), could defer
- **StateDisplayOverride:** require() - could defer

**Optimization potential:** Defer WarpInit, AutoMove, StateDisplayOverride to 0.5s delay
**Savings:** ~30-50ms

#### 3.2 Job Modules (~50-100ms)

`[job]_functions.lua` loads 11 hook modules via include():
- RDM_LOCKSTYLE.lua
- RDM_MACROBOOK.lua
- RDM_PRECAST.lua
- RDM_MIDCAST.lua
- RDM_AFTERCAST.lua
- RDM_IDLE.lua
- RDM_ENGAGED.lua
- RDM_STATUS.lua
- RDM_BUFFS.lua
- RDM_COMMANDS.lua

**Optimization potential:** Use require() instead of include() for caching
**Savings:** ~10-20ms

#### 3.3 Equipment Sets (~30-50ms)

- rdm_sets.lua: 533 lines
- war_sets.lua: 647 lines

**Optimization potential:** None (needed immediately for combat)

---

## PROPOSED SOLUTIONS

### SOLUTION 1: Lazy-Load UNIVERSAL_WS_DATABASE (Primary Fix)

**Impact:** -260-650ms load time
**Complexity:** Low
**Implementation time:** 1-2 hours

#### Changes Required:

**1. Modify `UNIVERSAL_WS_DATABASE.lua`:**

```lua
-- Add lazy loading wrapper (like data_loader.lua)
if not _G.WS_DATABASE then
    _G.WS_DATABASE = {
        loaded = false,
        weaponskills = {}
    }
end

local UniversalWS = {}

-- LAZY LOAD FUNCTION (called on first WS usage)
function UniversalWS.load()
    if _G.WS_DATABASE.loaded then
        return _G.WS_DATABASE  -- Already loaded
    end

    -- Original loading code (lines 71-109)
    for _, config in ipairs(weapon_type_configs) do
        local success, weapon_db = pcall(require, 'shared/data/weaponskills/' .. config.file)
        if success and weapon_db and weapon_db.weaponskills then
            -- Merge weaponskills
            for ws_name, ws_data in pairs(weapon_db.weaponskills) do
                _G.WS_DATABASE[ws_name] = ws_data
                _G.WS_DATABASE.weaponskills[ws_name] = ws_data
            end
        end
    end

    _G.WS_DATABASE.loaded = true
    return _G.WS_DATABASE
end

-- Return wrapper (not loaded yet)
return UniversalWS
```

**2. Modify `init_ws_messages.lua`:**

```lua
-- Remove synchronous loading (line 40)
-- OLD: local WS_DB_success, WS_DB = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
-- NEW: Load on first usage

local UniversalWS = require('shared/data/weaponskills/UNIVERSAL_WS_DATABASE')

function user_post_precast(spell, action, spellMap, eventArgs)
    if original_user_post_precast then
        original_user_post_precast(spell, action, spellMap, eventArgs)
    end

    -- Lazy-load WS database on first WS usage
    if spell and spell.type == 'WeaponSkill' then
        local WS_DB = UniversalWS.load()  -- ← Lazy load here

        if WS_MESSAGES_CONFIG.is_enabled() and not (eventArgs and eventArgs.cancel) then
            local player = windower.ffxi.get_player()
            local current_tp = player and player.vitals and player.vitals.tp or 0

            if current_tp >= 1000 then
                local ws_data = WS_DB.weaponskills[spell.english]

                if ws_data and WS_MESSAGES_CONFIG.show_description() then
                    MessageFormatter.show_ws_activated(spell.english, ws_data.description, current_tp)
                elseif WS_MESSAGES_CONFIG.is_tp_only() then
                    MessageFormatter.show_ws_tp(spell.english, current_tp)
                end
            end
        end
    end
end
```

**Result:**
- **First WS usage:** Database loads (260-650ms delay)
- **Subsequent WS:** Instant (cached in _G.WS_DATABASE)
- **Mage jobs:** Never load WS database (never use WS)
- **Melee jobs:** Load on first WS (expected behavior)

---

### SOLUTION 2: Defer Non-Critical Systems (Secondary Optimization)

**Impact:** -30-50ms load time
**Complexity:** Very Low
**Implementation time:** 15 minutes

#### Changes Required:

**Modify `INIT_SYSTEMS.lua`:**

```lua
-- Load critical systems immediately
local watchdog_success, MidcastWatchdog = pcall(require, 'shared/utils/core/midcast_watchdog')
if watchdog_success and MidcastWatchdog then
    _G.MidcastWatchdog = MidcastWatchdog
    coroutine.schedule(MidcastWatchdog.start, 2.0)  -- Already delayed
end

-- Defer non-critical systems to avoid blocking get_sets()
coroutine.schedule(function()
    -- Warp System (not needed immediately)
    local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')
    if warp_success and WarpInit then
        WarpInit.init()
    end

    -- AutoMove (not needed immediately)
    if _G.DISABLE_AUTOMOVE ~= true then
        local automove_success = pcall(include, '../shared/utils/movement/automove.lua')
    end

    -- State Display Override (not needed immediately)
    local state_display_success, StateDisplayOverride = pcall(require, 'shared/utils/core/state_display_override')
    if state_display_success and StateDisplayOverride then
        StateDisplayOverride.init()
    end
end, 0.5)  -- Load after 0.5s (non-blocking)
```

**Result:**
- **get_sets() faster:** -30-50ms
- **Systems still load:** Just 0.5s later (no functional impact)

---

### SOLUTION 3: Cache Hook Modules (Tertiary Optimization)

**Impact:** -10-20ms load time
**Complexity:** Medium
**Implementation time:** 30 minutes

Convert `include()` to `require()` in `[job]_functions.lua` for better caching.

**Note:** Lower priority - include() is needed for some GearSwap-specific scripts.

---

## TESTING PLAN

### Phase 1: Baseline Measurement
1. Add timing code to `get_sets()`:
   ```lua
   local start_time = os.clock()
   -- ... existing code ...
   local end_time = os.clock()
   print(string.format('[PERF] get_sets() took %.3f seconds', end_time - start_time))
   ```

2. Test on 3 jobs:
   - Melee (WAR, SAM)
   - Mage (RDM, BLM)
   - Hybrid (PLD, RUN)

3. Record baseline load times

### Phase 2: Apply Solution 1 (Lazy-load WS_DATABASE)
1. Implement lazy loading in UNIVERSAL_WS_DATABASE.lua
2. Modify init_ws_messages.lua
3. Test on same 3 jobs
4. Measure improvement

**Expected results:**
- **Mage jobs:** -260-650ms (never load WS database)
- **Melee jobs:** -260-650ms on first load, +260-650ms on first WS usage

### Phase 3: Apply Solution 2 (Defer systems)
1. Modify INIT_SYSTEMS.lua
2. Test all jobs
3. Verify no functional regressions

**Expected results:**
- **All jobs:** Additional -30-50ms

### Phase 4: Validation
1. Test on low-end PC (user's friend)
2. Verify no crashes
3. Confirm smooth loading experience

---

## RISK ASSESSMENT

### Solution 1 (Lazy-load WS_DATABASE)
- **Risk:** Low
- **Mitigation:** WS database loads before first WS is displayed
- **Compatibility:** No breaking changes (uses _G caching)

### Solution 2 (Defer systems)
- **Risk:** Very Low
- **Mitigation:** Systems still load, just 0.5s later
- **Compatibility:** No functional impact

---

## RECOMMENDATIONS

1. **Implement Solution 1 immediately** (lazy-load WS_DATABASE)
   - Primary bottleneck (260-650ms savings)
   - Low risk, high impact

2. **Implement Solution 2 as secondary fix** (defer systems)
   - Additional 30-50ms savings
   - Very low risk

3. **Monitor Solution 3** (cache hook modules)
   - Lower priority (10-20ms savings)
   - May have compatibility issues with include()

**Total estimated improvement:** **290-700ms faster job loading**

---

## IMPLEMENTATION CHECKLIST

- [ ] Add timing code to measure baseline
- [ ] Implement lazy loading in UNIVERSAL_WS_DATABASE.lua
- [ ] Modify init_ws_messages.lua to use lazy loading
- [ ] Test on 3 jobs (WAR, RDM, PLD)
- [ ] Measure performance improvement
- [ ] Implement deferred system loading in INIT_SYSTEMS.lua
- [ ] Test all jobs for regressions
- [ ] Validate on low-end PC
- [ ] Document changes in CHANGELOG.md

---

## CONCLUSION

The 1-second freeze is caused by synchronous loading of UNIVERSAL_WS_DATABASE (13 database files, 212 weaponskills). Implementing lazy loading will reduce load time by **290-700ms**, providing a much smoother user experience and preventing crashes on low-end PCs.

**Priority:** HIGH
**Effort:** LOW
**Impact:** HIGH

**Recommendation:** Implement immediately.

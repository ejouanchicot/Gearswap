# Performance Profiler - Usage Guide

## Quick Start

### Enable Profiling (Persistent)
```
//gs c perf start
```

**Note:** State is saved to file, so it persists across reloads! ✅

### Reload Job to See Timings
```
//lua reload gearswap
```

You'll see color-coded timing output in chat:
```
[PERF:get_sets] After Mote-Include:                200ms  (yellow)
[PERF:get_sets] After INIT_SYSTEMS:                205ms  (red)
[PERF:get_sets] After data_loader:                 206ms  (red)
[PERF:get_sets] After spell messages:              207ms  (red)
[PERF:get_sets] After ability messages:            208ms  (red)
[PERF:get_sets] After WS messages:                 209ms  (red)
[PERF:get_sets] After configs:                     210ms  (red)
[PERF:get_sets] After war_functions:               219ms  (red)
  [WAR] message_buffs:                    5ms  (yellow)
  [WAR] WAR_PRECAST:                      1ms  (green)
  [WAR] WAR_MIDCAST:                      0ms  (green)
  [WAR] WAR_AFTERCAST:                    0ms  (green)
  [WAR] WAR_IDLE:                         0ms  (green)
  [WAR] WAR_ENGAGED:                      1ms  (green)
  [WAR] WAR_STATUS:                       1ms  (green)
  [WAR] WAR_BUFFS:                        0ms  (green)
  [WAR] WAR_LOCKSTYLE:                    0ms  (green)
  [WAR] WAR_MACROBOOK:                    0ms  (green)
  [WAR] WAR_COMMANDS:                     0ms  (green)
  [WAR] WAR_MOVEMENT:                     1ms  (green)
  [WAR] DualBoxManager:                   0ms  (green)
  [WAR] TOTAL war_functions:              9ms  (green)
[PERF:get_sets] TOTAL:                             219ms  (green)
==========================================================================
```

**Timings are color-coded for instant visual feedback:**
- 🟢 **Green** = Excellent performance
- 🟡 **Yellow** = Acceptable (watch if optimizing)
- 🔴 **Red** = Slow (needs optimization)

### Disable Profiling
```
//gs c perf stop
```

### Check Status
```
//gs c perf status
```

### Toggle On/Off
```
//gs c perf toggle
```

---

## Commands

| Command | Aliases | Description |
|---------|---------|-------------|
| `//gs c perf start` | `on`, `enable` | Enable profiling |
| `//gs c perf stop` | `off`, `disable` | Disable profiling |
| `//gs c perf toggle` | - | Toggle profiling on/off |
| `//gs c perf status` | - | Show current profiling status |

---

## How It Works

### Persistent State Across Reloads ✅
The profiling state is **saved to a file** (`data/.profiler_enabled`):
- **Enable:** Creates the file → profiling ON (even after reload)
- **Disable:** Deletes the file → profiling OFF
- **Automatic:** State reads from file at startup

**Workflow:**
```
//gs c perf start          ← Creates data/.profiler_enabled
//lua reload gearswap      ← Reads file, sees enabled=true ✅
[PERF] Timings appear!     ← Profiling works!
//gs c perf stop           ← Deletes data/.profiler_enabled
//lua reload gearswap      ← Reads file (not found), disabled ✅
```

### Zero Performance Impact When Disabled
When profiling is **disabled** (default):
- All `Profiler.mark()` calls are no-ops (instant return)
- Zero CPU overhead
- Zero memory allocation
- No chat output

### Performance Tracking When Enabled
When profiling is **enabled**:
- Timing checkpoints recorded via `os.clock()`
- Results displayed in chat during job load
- ~1-2ms overhead total (negligible)
- State persists until you run `//gs c perf stop`

### Intelligent Color Coding 🎨

Timings are **automatically color-coded** based on performance thresholds:

**Main Checkpoints** (cumulative times):
| Color | Threshold | Status |
|-------|-----------|--------|
| 🟢 Green | < 50ms | Excellent |
| 🟡 Yellow | 50-100ms | Acceptable |
| 🔴 Red | > 100ms | Needs optimization |

**Job Modules** (individual module load times):
| Color | Threshold | Status |
|-------|-----------|--------|
| 🟢 Green | < 5ms | Excellent |
| 🟡 Yellow | 5-10ms | Acceptable |
| 🔴 Red | > 10ms | Slow (investigate) |

**Total get_sets**:
| Color | Threshold | Status |
|-------|-----------|--------|
| 🟢 Green | < 200ms | Excellent (no lag) |
| 🟡 Yellow | 200-300ms | Acceptable (minor lag) |
| 🔴 Red | > 300ms | Problematic (causes freeze) |

**Total job_functions**:
| Color | Threshold | Status |
|-------|-----------|--------|
| 🟢 Green | < 50ms | Excellent |
| 🟡 Yellow | 50-100ms | Acceptable |
| 🔴 Red | > 100ms | Slow (apply lazy loading) |

**Example Visual Feedback:**
```
[PERF:get_sets] TOTAL: 219ms  ← Shows in GREEN (excellent!)
[WAR] WAR_PRECAST: 15ms        ← Shows in RED (needs lazy loading!)
```

---

## Use Cases

### 1. Verify Optimizations
After applying lazy loading, enable profiling to confirm improvements:
```
//gs c perf start
//lua reload gearswap
```

Expected result: Most modules at 0-10ms

### 2. Debug Performance Issues
If job loading feels slow:
```
//gs c perf start
//lua reload gearswap
```

Look for modules taking >50ms and apply lazy loading

### 3. Compare Before/After
**Before optimization:**
```
[PERF:get_sets] After war_functions: 820ms
```

**After optimization:**
```
[PERF:get_sets] After war_functions: 219ms
```

Savings: 601ms (-73%)

---

## Profiling Other Jobs

The profiling system is integrated into:
- ✅ WAR (fully instrumented)
- ⚠️ Other jobs (need to add profiler calls)

### Adding Profiling to Other Jobs

#### Step 1: Modify `Tetsouo_[JOB].lua`
```lua
function get_sets()
    local Profiler = require('shared/utils/debug/performance_profiler')
    Profiler.start('get_sets')

    include('Mote-Include.lua')
    Profiler.mark('After Mote-Include')

    -- ... more code ...

    Profiler.finish()
end
```

#### Step 2: Modify `[job]_functions.lua`
```lua
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('[JOB]')

include('../shared/jobs/[job]/functions/[JOB]_PRECAST.lua')
TIMER('[JOB]_PRECAST')
-- ... repeat for all modules
```

#### Step 3: Add Commands to `[JOB]_COMMANDS.lua`
Copy the `perf` command block from `WAR_COMMANDS.lua` (lines 153-174)

---

## Advanced Usage

### Profiling Specific Functions
```lua
local Profiler = require('shared/utils/debug/performance_profiler')

function my_slow_function()
    Profiler.measure('my_slow_function', function()
        -- code to measure
        for i = 1, 1000000 do
            -- something expensive
        end
    end)
end
```

Output:
```
[PERF:MEASURE] my_slow_function: 234ms
```

### Profiling Function Calls
```lua
local result = Profiler.profile_call('expensive_operation', expensive_function, arg1, arg2)
```

Output:
```
[PERF:CALL] expensive_operation: 156ms
```

---

## Troubleshooting

### "Profiling is disabled" message
**Cause:** You forgot to enable profiling before reloading
**Fix:**
```
//gs c perf start
//lua reload gearswap
```

### No output in chat
**Cause:** Profiling enabled but job not reloaded
**Fix:** Reload job: `//lua reload gearswap`

### Timings seem wrong
**Cause:** System load or other addons interfering
**Fix:**
1. Close other programs
2. Disable other Windower addons temporarily
3. Reload multiple times and average the results

---

## Performance Baselines

### Optimized (Lazy Loading Applied)
```
Mote-Include:      ~200ms (external framework, can't optimize)
INIT_SYSTEMS:      ~0-2ms
data_loader:       ~0ms
spell messages:    ~1ms
ability messages:  ~1ms
WS messages:       ~1ms
configs:           ~1ms
[job]_functions:   ~9-15ms
TOTAL:             ~210-220ms ✅
```

### Unoptimized (Eager Loading)
```
Mote-Include:      ~200ms
INIT_SYSTEMS:      ~5ms
data_loader:       ~0ms
spell messages:    ~254ms
ability messages:  ~300ms
WS messages:       ~351ms
configs:           ~1ms
[job]_functions:   ~613ms
TOTAL:             ~1720ms ❌
```

**Target:** <250ms total
**Acceptable:** 200-300ms
**Needs optimization:** >400ms

---

## FAQ

**Q: Does profiling affect performance during gameplay?**
A: No. Profiling only runs during job loading (get_sets()), not during combat.

**Q: Can I leave profiling enabled all the time?**
A: Yes, but you'll see timing output every time you reload. It's recommended to disable it after debugging.

**Q: Will this work on other characters?**
A: Yes, if they use the same job files. The profiler is global via `_G.PERFORMANCE_PROFILING`.

**Q: Can I customize the output format?**
A: Yes, edit `shared/utils/debug/performance_profiler.lua` and modify the `add_to_chat()` calls.

---

## See Also

- `docs/PERFORMANCE_OPTIMIZATION_SUMMARY.md` - Full optimization results
- `docs/LAZY_LOADING_MIGRATION_GUIDE.md` - How to optimize other jobs
- `shared/utils/debug/performance_profiler.lua` - Profiler source code

---

**Status:** ✅ WAR fully instrumented | 📋 Other jobs need instrumentation

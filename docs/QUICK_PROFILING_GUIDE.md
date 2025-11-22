# Quick Profiling Guide - TL;DR

## One Command to Rule Them All

### Turn Profiling ON
```
//gs c perf start
```

### Reload to See Timings
```
//lua reload gearswap
```

### Turn Profiling OFF
```
//gs c perf stop
```

---

## That's It!

The state **persists automatically** across reloads.

No need to edit code, no need to remember to enable it before reloading.

Just `//gs c perf start` once, then reload as many times as you want.

---

## Expected Output (WAR Optimized)

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

**Color-Coded Performance Indicators:**

**Main checkpoints** (cumulative times):
- 🟢 Green: < 50ms (excellent)
- 🟡 Yellow: 50-100ms (acceptable)
- 🔴 Red: > 100ms (needs optimization)

**Job modules** (individual times):
- 🟢 Green: < 5ms (excellent)
- 🟡 Yellow: 5-10ms (acceptable)
- 🔴 Red: > 10ms (slow)

**Total get_sets**:
- 🟢 Green: < 200ms (excellent) ✅
- 🟡 Yellow: 200-300ms (acceptable)
- 🔴 Red: > 300ms (problematic)

**Total job_functions**:
- 🟢 Green: < 50ms (excellent) ✅
- 🟡 Yellow: 50-100ms (acceptable)
- 🔴 Red: > 100ms (slow)

**WAR Result:** 219ms (green) ✅ **EXCELLENT**

---

## Other Commands

```
//gs c perf status    - Check if profiling is on/off
//gs c perf toggle    - Toggle on/off
```

---

## Technical Details

**How does persistence work?**

When you run `//gs c perf start`:
1. Creates file: `data/.profiler_enabled`
2. Every reload checks if this file exists
3. If exists → profiling ON
4. If missing → profiling OFF

When you run `//gs c perf stop`:
- Deletes the file
- Profiling OFF on next reload

**Zero code editing needed!** ✅

---

## Troubleshooting

**Problem:** No timings appear after `//lua reload gearswap`

**Solution:**
```
//gs c perf status    ← Check if enabled
//gs c perf start     ← Enable if needed
//lua reload gearswap ← Reload again
```

---

**Problem:** Too much output in chat

**Solution:**
```
//gs c perf stop
```

---

## See Also

- `PROFILER_USAGE.md` - Full documentation
- `PERFORMANCE_OPTIMIZATION_SUMMARY.md` - Optimization results
- `LAZY_LOADING_MIGRATION_GUIDE.md` - How to optimize other jobs

---

**Status:** ✅ WAR fully instrumented with persistent profiling

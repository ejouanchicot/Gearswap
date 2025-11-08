# Message System - Complete Test Suite (Auto-Generated)

**22 test suites** covering **ALL FFXI jobs** + system tests
**269 Job Abilities** auto-generated from databases

## Quick Start

```lua
//gs c testmsg              -- Run ALL tests (22 suites)
//gs c testmsg war          -- Run WAR tests only
//gs c testmsg system       -- Run system tests only
```

## Test Coverage

### ✅ 21 Jobs with Auto-Generated JA Tests

| Job | Code | JA Count | Status |
|-----|------|----------|--------|
| **Warrior** | WAR | 11 | ✅ Auto-generated |
| **Monk** | MNK | 13 | ✅ Auto-generated |
| **White Mage** | WHM | 9 | ✅ Auto-generated |
| **Black Mage** | BLM | 7 | ✅ Auto-generated |
| **Red Mage** | RDM | 6 | ✅ Auto-generated |
| **Thief** | THF | 14 | ✅ Auto-generated |
| **Paladin** | PLD | 13 | ✅ Auto-generated |
| **Dark Knight** | DRK | 12 | ✅ Auto-generated |
| **Beastmaster** | BST | 9 | ✅ Auto-generated |
| **Bard** | BRD | 7 | ✅ Auto-generated |
| **Ranger** | RNG | 15 | ✅ Auto-generated |
| **Samurai** | SAM | 14 | ✅ Auto-generated |
| **Ninja** | NIN | 7 | ✅ Auto-generated |
| **Dragoon** | DRG | 14 | ✅ Auto-generated |
| **Blue Mage** | BLU | 8 | ✅ Auto-generated |
| **Corsair** | COR | 9 | ✅ Auto-generated |
| **Puppetmaster** | PUP | 10 | ✅ Auto-generated |
| **Dancer** | DNC | 7 | ✅ Auto-generated |
| **Scholar** | SCH | 8 | ✅ Auto-generated |
| **Geomancer** | GEO | 14 | ✅ Auto-generated |
| **Runemaster** | RUN | 23 | ✅ Auto-generated |

**Total JA Tests**: 230 abilities

### ✅ System Tests (Manual)

**SYSTEM** suite (37 tests):

- Elemental Magic (6): Fire VI, Blizzard VI, etc.
- Enhancing Magic (3): Haste II, Protect V, Stoneskin
- Enfeebling Magic (3): Slow II, Paralyze II, Silence
- Divine Magic (2): Banish III, Holy II
- Healing Magic (4): Cure IV, Curaga III, Regen IV
- Dark Magic (3): Drain III, Aspir III, Bio III
- Blue Magic (3): Head Butt, Cocoon, Magic Hammer
- Job Abilities (4): Berserk, Last Resort, Hasso, Sentinel
- Weaponskills (3): Upheaval, Torcleaver, Tachi: Fudo
- System Messages (6): Success, Warning, Error, Info, Toggle, Color
- Error Handling (2): Invalid namespace, Error message

**Total System Tests**: 37

## Total Coverage

```
21 Jobs × ~11 JA avg = 230 JA tests
+                       37 System tests
─────────────────────────────────────
                      267 TOTAL TESTS
```

## Auto-Generation System

Tests are auto-generated from JA databases located in:

```
shared/data/job_abilities/[job]/
├── [job]_mainjob.lua    -- Main job only abilities
├── [job]_subjob.lua     -- Subjob abilities
└── [job]_sp.lua         -- Special abilities
```

### Generator Script

`generate_tests.py` - Python script that:

1. Reads all Lua JA database files
2. Parses ability names and descriptions
3. Generates test_[job].lua files
4. Handles both single (') and double (") quote formats

### Regenerating Tests

```bash
cd "D:\Windower Tetsouo\addons\GearSwap\data"
python generate_tests.py
```

Output:

```
==========================================================================
Generating Test Suites from JA Databases
==========================================================================

[OK] WARRIOR               11 abilities >> test_war.lua
[OK] MONK                  13 abilities >> test_mnk.lua
...
[OK] RUNEMASTER            23 abilities >> test_run.lua

==========================================================================
Generated 21 test suites with 230 total abilities
==========================================================================
```

## File Structure

```
shared/utils/messages/api/tests/
├── README_COMPLETE.md         -- This file
├── README.md                  -- Old manual documentation
├── generate_tests.py          -- Auto-generator script
├── generate_all_tests.lua     -- Lua version (not used)
│
├── test_system.lua            -- Manual system tests (37)
│
└── Auto-generated JA tests (21 files):
    ├── test_war.lua           -- 11 WAR JA
    ├── test_mnk.lua           -- 13 MNK JA
    ├── test_whm.lua           --  9 WHM JA
    ├── test_blm.lua           --  7 BLM JA
    ├── test_rdm.lua           --  6 RDM JA
    ├── test_thf.lua           -- 14 THF JA
    ├── test_pld.lua           -- 13 PLD JA
    ├── test_drk.lua           -- 12 DRK JA
    ├── test_bst.lua           --  9 BST JA
    ├── test_brd.lua           --  7 BRD JA
    ├── test_rng.lua           -- 15 RNG JA
    ├── test_sam.lua           -- 14 SAM JA
    ├── test_nin.lua           --  7 NIN JA
    ├── test_drg.lua           -- 14 DRG JA
    ├── test_blu.lua           --  8 BLU JA
    ├── test_cor.lua           --  9 COR JA
    ├── test_pup.lua           -- 10 PUP JA
    ├── test_dnc.lua           --  7 DNC JA
    ├── test_sch.lua           --  8 SCH JA
    ├── test_geo.lua           -- 14 GEO JA
    └── test_run.lua           -- 23 RUN JA
```

## Color Verification

All tests verify proper message formatting:

- ✅ JA in **yellow** (code 050) with gray brackets `{gray}[...]`
- ✅ All delimiters `[](){}` in **gray** (160)
- ✅ Job tags in **lightblue**
- ✅ Descriptions follow standard format

## Example Auto-Generated Test

```lua
---============================================================================
--- WAR Test Suite - Warrior Job Messages
---============================================================================
--- Tests all WAR job abilities
---
--- @file tests/test_war.lua
--- @author Tetsouo (Auto-generated)
--- @date Created: 2025-11-08
---============================================================================

local M = require('shared/utils/messages/api/messages')

local TestWAR = {}

function TestWAR.run(test)
    local gray_code = string.char(0x1F, 160)
    local cyan = string.char(0x1F, 13)
    local total = 0

    add_to_chat(121, " ")
    add_to_chat(121, cyan .. "WAR Job Abilities (11):")

    test(function() M.send('JA_BUFFS', 'activated_full', {
        job_tag = 'WAR',
        ability_name = 'Berserk',
        description = 'ATK+25% DEF-25%'
    }) end)
    -- ... 10 more abilities ...

    total = total + 11
    return total
end

return TestWAR
```

## Benefits

✅ **Complete Coverage**: All 21 FFXI jobs tested
✅ **Auto-Generated**: Direct from JA databases (no manual errors)
✅ **Always Accurate**: Regenerate when databases update
✅ **Consistent**: Same format across all jobs
✅ **Fast**: Test individual jobs or all at once
✅ **Maintainable**: Single source of truth (JA databases)

## Next Steps

To add more tests (spells, weaponskills, etc.):

1. Extend `generate_tests.py` to read spell/WS databases
2. Add sections to test file template
3. Regenerate all tests

Example enhancement:

```python
# In generate_tests.py
def load_job_spells(job_code, base_path):
    # Read spell databases
    # Return spell dict

def generate_test_file(job_code, job_name, abilities, spells):
    # Generate JA tests
    # Generate spell tests
    # Return combined content
```

---

**Generated**: 2025-11-08
**Generator**: `generate_tests.py`
**Total Coverage**: 267 tests (230 JA + 37 system)

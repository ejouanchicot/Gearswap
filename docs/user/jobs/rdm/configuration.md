# RDM - Configuration Files

**Location**: `Tetsouo/config/rdm/`

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `RDM_KEYBINDS.lua` | Keybind definitions (32 total) |
| `RDM_LOCKSTYLE.lua` | Lockstyle per subjob |
| `RDM_MACROBOOK.lua` | Macrobook per subjob |
| `RDM_STATES.lua` | All state definitions (20 states) |
| `RDM_TP_CONFIG.lua` | TP bonus thresholds |
| `RDM_SABOTEUR_CONFIG.lua` | Auto-Saboteur spell list |

---

## ⌨️ Keybinds Config

**File**: `Tetsouo/config/rdm/RDM_KEYBINDS.lua`

```lua
local RDMKeybinds = {}

RDMKeybinds.binds = {
    -- Alt+ Keys (States/Cycling)
    {key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon"},
    {key = "!2", command = "cycle SubWeapon", desc = "Sub Weapon", state = "SubWeapon"},
    {key = "!3", command = "cycle EngagedMode", desc = "Engaged Mode", state = "EngagedMode"},
    -- ... 29 more keybinds ...
}

function RDMKeybinds.bind_all()
    -- Auto-binds all keys on load
end

function RDMKeybinds.unbind_all()
    -- Auto-unbinds all keys on unload
end

return RDMKeybinds
```

**Customization**:

```lua
-- Change Alt+1 to Alt+Q:
{key = "!q", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon"},

-- Add new keybind:
{key = "!r", command = "cycle MyNewState", desc = "My State", state = "MyNewState"},
```

---

## 🎨 Lockstyle Config

**File**: `Tetsouo/config/rdm/RDM_LOCKSTYLE.lua`

```lua
local RDMLockstyleConfig = {}

RDMLockstyleConfig.default = 1

RDMLockstyleConfig.by_subjob = {
    ['NIN'] = 1,  -- Dualwield melee build
    ['WHM'] = 2,  -- Support/healing build
    ['BLM'] = 3,  -- Nuking build
    ['SCH'] = 4,  -- Hybrid magic build
    ['DNC'] = 5,  -- Melee/support build
}

return RDMLockstyleConfig
```

**How it works**:

- When you load RDM/NIN → applies lockstyle #1
- When you change to RDM/WHM → applies lockstyle #2
- If subjob not in list → applies default (#1)

**Customization**:

```lua
-- Change NIN lockstyle to #10:
['NIN'] = 10,

-- Add new subjob:
['BLU'] = 6,  -- Blue magic build
```

---

## 📖 Macrobook Config

**File**: `Tetsouo/config/rdm/RDM_MACROBOOK.lua`

```lua
local RDMMacroConfig = {}

RDMMacroConfig.default = {book = 1, page = 1}

RDMMacroConfig.solo = {
    ['NIN'] = {book = 1, page = 1},  -- RDM/NIN - Dualwield melee
    ['WHM'] = {book = 1, page = 2},  -- RDM/WHM - Support/healing
    ['BLM'] = {book = 1, page = 3},  -- RDM/BLM - Nuking
    ['SCH'] = {book = 1, page = 4},  -- RDM/SCH - Hybrid magic
    ['DNC'] = {book = 1, page = 5},  -- RDM/DNC - Melee/support
}

RDMMacroConfig.dualbox = {
    -- Uncomment to add dual-boxing configurations
    -- ['GEO'] = {
    --     ['NIN'] = { book = 2, page = 1 },
    --     ['WHM'] = { book = 2, page = 2 },
    --     -- RDM+GEO dual-box macros
    -- },
}

return RDMMacroConfig
```

**How it works**:

- Solo play: Uses `solo` table
- Dual-boxing: Uses `dualbox` table (if alt job detected)
- System auto-selects book/page based on current subjob

**Customization**:

```lua
-- Change NIN macrobook to Book 2, Page 5:
['NIN'] = {book = 2, page = 5},

-- Add dual-boxing config:
RDMMacroConfig.dualbox = {
    ['GEO'] = {
        ['NIN'] = { book = 3, page = 1 },
        ['WHM'] = { book = 3, page = 2 },
    },
}
```

---

## 🎯 States Config

**File**: `Tetsouo/config/rdm/RDM_STATES.lua`

```lua
local RDMStates = {}

function RDMStates.configure()
    -- Combat modes
    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('Normal')

    state.EngagedMode = M{'DT', 'Acc', 'TP', 'Enspell'}
    state.EngagedMode:set('DT')

    state.IdleMode = M{'Refresh', 'DT'}
    state.IdleMode:set('Refresh')

    -- Weapon selection
    state.MainWeapon = M{'Naegling', 'Colada', 'Daybreak'}
    state.MainWeapon:set('Naegling')

    state.SubWeapon = M{'Ammurapi', 'Genmei'}
    state.SubWeapon:set('Genmei')

    -- ... 15 more states ...
end

function RDMStates.validate()
    -- Validates all states are configured
end

return RDMStates
```

**Customization**:

```lua
-- Add new weapon:
state.MainWeapon = M{'Naegling', 'Colada', 'Daybreak', 'Crocea Mors'}

-- Change default:
state.EnfeebleMode:set('Skill')  -- Instead of 'Potency'

-- Add new mode:
state.EnfeebleMode = M{'Potency', 'Skill', 'Duration', 'Macc'}
```

---

## ⚡ TP Config

**File**: `Tetsouo/config/rdm/RDM_TP_CONFIG.lua`

```lua
local RDMTPCONFIG = {}

RDMTPCONFIG.tp_sets = {
    ['default'] = {
        min_tp = 1000,
        sets.engaged.Normal
    },
    ['high_tp'] = {
        min_tp = 2000,
        sets.engaged.HighTP  -- High TP gear (TP Bonus+)
    },
}

return RDMTPCONFIG
```

**Purpose**: Automatically switches engaged gear based on TP levels.

**Customization**:

```lua
-- Add intermediate TP tier:
['mid_tp'] = {
    min_tp = 1500,
    sets.engaged.MidTP
},
```

---

## 🎭 Saboteur Config

**File**: `Tetsouo/config/rdm/RDM_SABOTEUR_CONFIG.lua`

```lua
local RDMSaboteurConfig = {}

RDMSaboteurConfig.auto_trigger_spells = {
    'Slow II',
    'Paralyze II',
    'Addle II',
    'Distract III',
    'Frazzle III',
    'Poison II',
}

RDMSaboteurConfig.wait_time = 2  -- Seconds to wait after Saboteur

return RDMSaboteurConfig
```

**Purpose**: When `SaboteurMode = On`, auto-casts Saboteur before these spells.

**Customization**:

```lua
-- Add more spells:
RDMSaboteurConfig.auto_trigger_spells = {
    'Slow II',
    'Paralyze II',
    'Gravity II',  -- Added
    'Bind',        -- Added
}

-- Change wait time:
RDMSaboteurConfig.wait_time = 3  -- 3 seconds instead of 2
```

---

## 🔧 Customization Examples

### Example 1: Add New Keybind

```lua
-- In RDM_KEYBINDS.lua:
{key = "!r", command = "cycle MyNewState", desc = "My State", state = "MyNewState"},
```

### Example 2: Change Lockstyle

```lua
-- In RDM_LOCKSTYLE.lua:
RDMLockstyleConfig.by_subjob = {
    ['NIN'] = 10,  -- Changed from 1 to 10
    ['WHM'] = 2,
    -- ...
}
```

### Example 3: Add Dual-Boxing Macros

```lua
-- In RDM_MACROBOOK.lua:
RDMMacroConfig.dualbox = {
    ['GEO'] = {
        ['NIN'] = { book = 5, page = 1 },  -- RDM+GEO with NIN subjob
        ['WHM'] = { book = 5, page = 2 },  -- RDM+GEO with WHM subjob
    },
}
```

### Example 4: Add Auto-Saboteur Spell

```lua
-- In RDM_SABOTEUR_CONFIG.lua:
RDMSaboteurConfig.auto_trigger_spells = {
    'Slow II',
    'Paralyze II',
    'Gravity II',  -- Added
    'Silence',     -- Added
}
```

### Example 5: Add New State

```lua
-- In RDM_STATES.lua:
state.MyNewState = M{'Option1', 'Option2', 'Option3'}
state.MyNewState:set('Option1')

-- Then add keybind and sets in other files
```

---

## 🔄 Applying Changes

After modifying config files:

1. **Save the file**
2. **Reload GearSwap**:

   ```
   //gs reload
   ```

3. **Verify changes**:

   ```
   //gs c checksets  # For set changes
   //gs c ui         # For keybind changes
   ```

**Note**: Changes to states require GearSwap reload to take effect.

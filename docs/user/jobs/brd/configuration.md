# BRD - Configuration Files

**Location**: `Tetsouo/config/brd/`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `BRD_KEYBINDS.lua` | Keybind definitions |
| `BRD_LOCKSTYLE.lua` | Lockstyle per subjob |
| `BRD_MACROBOOK.lua` | Macrobook per subjob |
| `BRD_STATES.lua` | State definitions |

---

## Lockstyle Config

**File**: `Tetsouo/config/brd/BRD_LOCKSTYLE.lua`

```lua
local BRDLockstyleConfig = {}

BRDLockstyleConfig.default = 7

BRDLockstyleConfig.by_subjob = {
    ['WHM'] = 7,
    ['RDM'] = 7,
    ['NIN'] = 7,
    ['DNC'] = 7,
}

return BRDLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## Macrobook Config

**File**: `Tetsouo/config/brd/BRD_MACROBOOK.lua`

```lua
local BRDMacroConfig = {}

BRDMacroConfig.default = {book = 36, page = 1}

BRDMacroConfig.solo = {
    ['WHM'] = {book = 36, page = 1},
    ['RDM'] = {book = 36, page = 1},
    ['NIN'] = {book = 36, page = 1},
    ['DNC'] = {book = 34, page = 1},
    ['SCH'] = {book = 31, page = 1},
}

return BRDMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## Customization Examples

### Change lockstyle

```lua
-- Modify BRD_LOCKSTYLE.lua
BRDLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify BRD_MACROBOOK.lua
BRDMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

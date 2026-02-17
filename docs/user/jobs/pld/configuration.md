# PLD - Configuration Files

**Location**: `Tetsouo/config/pld/`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `PLD_KEYBINDS.lua` | Keybind definitions |
| `PLD_LOCKSTYLE.lua` | Lockstyle per subjob |
| `PLD_MACROBOOK.lua` | Macrobook per subjob |
| `PLD_STATES.lua` | State definitions |

---

## Lockstyle Config

**File**: `Tetsouo/config/pld/PLD_LOCKSTYLE.lua`

```lua
local PLDLockstyleConfig = {}

PLDLockstyleConfig.default = 3

PLDLockstyleConfig.by_subjob = {
    ['RUN'] = 3,
    ['BLU'] = 3,
    ['RDM'] = 3,
    ['WAR'] = 3,
    ['NIN'] = 3,
}

return PLDLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## Macrobook Config

**File**: `Tetsouo/config/pld/PLD_MACROBOOK.lua`

```lua
local PLDMacroConfig = {}

PLDMacroConfig.default = {book = 15, page = 1}

PLDMacroConfig.solo = {
    ['RUN'] = {book = 16, page = 1},
    ['BLU'] = {book = 19, page = 1},
    ['RDM'] = {book = 20, page = 1},
    ['default'] = {book = 15, page = 1},
}

return PLDMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## Customization Examples

### Change lockstyle

```lua
-- Modify PLD_LOCKSTYLE.lua
PLDLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify PLD_MACROBOOK.lua
PLDMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

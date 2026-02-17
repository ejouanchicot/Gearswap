# DRK - Configuration Files

**Location**: `Tetsouo/config/drk/`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `DRK_KEYBINDS.lua` | Keybind definitions |
| `DRK_LOCKSTYLE.lua` | Lockstyle per subjob |
| `DRK_MACROBOOK.lua` | Macrobook per subjob |
| `DRK_STATES.lua` | State definitions |

---

## Lockstyle Config

**File**: `Tetsouo/config/drk/DRK_LOCKSTYLE.lua`

```lua
local DRKLockstyleConfig = {}

DRKLockstyleConfig.default = 1

DRKLockstyleConfig.by_subjob = {
    ['SAM'] = 1,
    ['WAR'] = 1,
    ['NIN'] = 2,
    ['DNC'] = 3,
}

return DRKLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## Macrobook Config

**File**: `Tetsouo/config/drk/DRK_MACROBOOK.lua`

```lua
local DRKMacroConfig = {}

DRKMacroConfig.default = {book = 1, page = 1}

DRKMacroConfig.solo = {
    ['SAM'] = {book = 4, page = 1},
    ['WAR'] = {book = 4, page = 2},
    ['NIN'] = {book = 1, page = 3},
    ['DNC'] = {book = 1, page = 4},
    ['default'] = {book = 1, page = 1},
}

return DRKMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## Customization Examples

### Change lockstyle

```lua
-- Modify DRK_LOCKSTYLE.lua
DRKLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify DRK_MACROBOOK.lua
DRKMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

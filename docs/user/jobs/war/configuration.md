# WAR - Configuration Files

**Location**: `Tetsouo/config/war/`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `WAR_KEYBINDS.lua` | Keybind definitions |
| `WAR_LOCKSTYLE.lua` | Lockstyle per subjob |
| `WAR_MACROBOOK.lua` | Macrobook per subjob |
| `WAR_STATES.lua` | State definitions |

---

## Lockstyle Config

**File**: `Tetsouo/config/war/WAR_LOCKSTYLE.lua`

```lua
local WARLockstyleConfig = {}

WARLockstyleConfig.default = 4

WARLockstyleConfig.by_subjob = {
    ['SAM'] = 4,
    ['DRG'] = 4,
    ['DNC'] = 4,
    ['NIN'] = 4,
}

return WARLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## Macrobook Config

**File**: `Tetsouo/config/war/WAR_MACROBOOK.lua`

```lua
local WARMacroConfig = {}

WARMacroConfig.default = {book = 1, page = 1}

WARMacroConfig.solo = {
    
}

return WARMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## Customization Examples

### Change lockstyle

```lua
-- Modify WAR_LOCKSTYLE.lua
WARLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify WAR_MACROBOOK.lua
WARMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

# SAM - Configuration Files

**Location**: `Tetsouo/config/sam/`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `SAM_KEYBINDS.lua` | Keybind definitions |
| `SAM_LOCKSTYLE.lua` | Lockstyle per subjob |
| `SAM_MACROBOOK.lua` | Macrobook per subjob |
| `SAM_STATES.lua` | State definitions |

---

## Lockstyle Config

**File**: `Tetsouo/config/sam/SAM_LOCKSTYLE.lua`

```lua
local SAMLockstyleConfig = {}

SAMLockstyleConfig.default = 2

SAMLockstyleConfig.by_subjob = {
    ['WAR'] = 2,
    ['DRG'] = 2,
    ['NIN'] = 2,
    ['DNC'] = 2,
}

return SAMLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## Macrobook Config

**File**: `Tetsouo/config/sam/SAM_MACROBOOK.lua`

```lua
local SAMMacroConfig = {}

SAMMacroConfig.default = {book = 2, page = 1}

SAMMacroConfig.solo = {
    ['WAR'] = {book = 2, page = 1},
    ['DRG'] = {book = 2, page = 1},
    ['NIN'] = {book = 2, page = 1},
    ['DNC'] = {book = 2, page = 1},
}

return SAMMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## Customization Examples

### Change lockstyle

```lua
-- Modify SAM_LOCKSTYLE.lua
SAMLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify SAM_MACROBOOK.lua
SAMMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

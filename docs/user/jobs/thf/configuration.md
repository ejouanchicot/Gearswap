# THF - Configuration Files

**Location**: `Tetsouo/config/thf/`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `THF_KEYBINDS.lua` | Keybind definitions |
| `THF_LOCKSTYLE.lua` | Lockstyle per subjob |
| `THF_MACROBOOK.lua` | Macrobook per subjob |
| `THF_STATES.lua` | State definitions |

---

## Lockstyle Config

**File**: `Tetsouo/config/thf/THF_LOCKSTYLE.lua`

```lua
local THFLockstyleConfig = {}

THFLockstyleConfig.default = 1

THFLockstyleConfig.by_subjob = {
    ['DNC'] = 1,
    ['NIN'] = 1,
    ['WAR'] = 1,
}

return THFLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## Macrobook Config

**File**: `Tetsouo/config/thf/THF_MACROBOOK.lua`

```lua
local THFMacroConfig = {}

THFMacroConfig.default = {book = 1, page = 1}

THFMacroConfig.solo = {
    ['WAR'] = {book = 3, page = 1},
    ['DNC'] = {book = 3, page = 1},
    ['NIN'] = {book = 3, page = 1},
}

return THFMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## Customization Examples

### Change lockstyle

```lua
-- Modify THF_LOCKSTYLE.lua
THFLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify THF_MACROBOOK.lua
THFMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

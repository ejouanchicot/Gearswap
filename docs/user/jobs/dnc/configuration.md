# DNC - Configuration Files

**Location**: `Tetsouo/config/dnc/`

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `DNC_KEYBINDS.lua` | Keybind definitions |
| `DNC_LOCKSTYLE.lua` | Lockstyle per subjob |
| `DNC_MACROBOOK.lua` | Macrobook per subjob |
| `DNC_STATES.lua` | State definitions |

---

## 🎨 Lockstyle Config

**File**: `Tetsouo/config/dnc/DNC_LOCKSTYLE.lua`

```lua
local DNCLockstyleConfig = {}

DNCLockstyleConfig.default = 2

DNCLockstyleConfig.by_subjob = {
    ['NIN'] = 2,
    ['SAM'] = 2,
    ['WAR'] = 2,
    ['THF'] = 2,
    ['DRG'] = 2,
}

return DNCLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## 📖 Macrobook Config

**File**: `Tetsouo/config/dnc/DNC_MACROBOOK.lua`

```lua
local DNCMacroConfig = {}

DNCMacroConfig.default = {book = 4, page = 1}

DNCMacroConfig.solo = {
    ['NIN'] = {book = 4, page = 1},
    ['DRG'] = {book = 5, page = 1},
    ['SAM'] = {book = 4, page = 1},
    ['WAR'] = {book = 5, page = 1},
    ['THF'] = {book = 4, page = 1},
    ['default'] = {book = 4, page = 1},
}

return DNCMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## 🔧 Customization Examples

### Change lockstyle

```lua
-- Modify DNC_LOCKSTYLE.lua
DNCLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify DNC_MACROBOOK.lua
DNCMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

# WHM - Configuration Files

**Location**: `Tetsouo/config/whm/`

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `WHM_KEYBINDS.lua` | Keybind definitions |
| `WHM_LOCKSTYLE.lua` | Lockstyle per subjob |
| `WHM_MACROBOOK.lua` | Macrobook per subjob |
| `WHM_STATES.lua` | State definitions |

---

## 🎨 Lockstyle Config

**File**: `Tetsouo/config/whm/WHM_LOCKSTYLE.lua`

```lua
local WHMLockstyleConfig = {}

WHMLockstyleConfig.default = 3

WHMLockstyleConfig.by_subjob = {
    ['RDM'] = 3,
    ['SCH'] = 3,
    ['BLM'] = 3,
    ['BLU'] = 3,
    ['GEO'] = 3,
}

return WHMLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## 📖 Macrobook Config

**File**: `Tetsouo/config/whm/WHM_MACROBOOK.lua`

```lua
local WHMMacroConfig = {}

WHMMacroConfig.default = {book = 1, page = 1}

WHMMacroConfig.solo = {
    ['RDM'] = {book = 11, page = 1},
    ['SCH'] = {book = 11, page = 2},
    ['BLM'] = {book = 11, page = 3},
    ['BLU'] = {book = 11, page = 4},
    ['GEO'] = {book = 11, page = 5},
}

return WHMMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## 🔧 Customization Examples

### Change lockstyle

```lua
-- Modify WHM_LOCKSTYLE.lua
WHMLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify WHM_MACROBOOK.lua
WHMMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

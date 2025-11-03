# BLM - Configuration Files

**Location**: `Tetsouo/config/blm/`

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `BLM_KEYBINDS.lua` | Keybind definitions |
| `BLM_LOCKSTYLE.lua` | Lockstyle per subjob |
| `BLM_MACROBOOK.lua` | Macrobook per subjob |
| `BLM_STATES.lua` | State definitions |

---

## 🎨 Lockstyle Config

**File**: `Tetsouo/config/blm/BLM_LOCKSTYLE.lua`

```lua
local BLMLockstyleConfig = {}

BLMLockstyleConfig.default = 5

BLMLockstyleConfig.by_subjob = {
    ['SCH'] = 5,
    ['RDM'] = 5,
    ['WHM'] = 5,
}

return BLMLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## 📖 Macrobook Config

**File**: `Tetsouo/config/blm/BLM_MACROBOOK.lua`

```lua
local BLMMacroConfig = {}

BLMMacroConfig.default = {book = 8, page = 1}

BLMMacroConfig.solo = {
    ['SCH'] = {book = 10, page = 1},
    ['RDM'] = {book = 11, page = 1},
    ['WHM'] = {book = 8, page = 1},
}

return BLMMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## 🔧 Customization Examples

### Change lockstyle

```lua
-- Modify BLM_LOCKSTYLE.lua
BLMLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify BLM_MACROBOOK.lua
BLMMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

# GEO - Configuration Files

**Location**: `Tetsouo/config/geo/`

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `GEO_KEYBINDS.lua` | Keybind definitions |
| `GEO_LOCKSTYLE.lua` | Lockstyle per subjob |
| `GEO_MACROBOOK.lua` | Macrobook per subjob |
| `GEO_STATES.lua` | State definitions |

---

## 🎨 Lockstyle Config

**File**: `Tetsouo/config/geo/GEO_LOCKSTYLE.lua`

```lua
local GEOLockstyleConfig = {}

GEOLockstyleConfig.default = 5

GEOLockstyleConfig.by_subjob = {
    ['WHM'] = 5,
    ['RDM'] = 5,
    ['BLM'] = 5,
    ['SCH'] = 5,
}

return GEOLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## 📖 Macrobook Config

**File**: `Tetsouo/config/geo/GEO_MACROBOOK.lua`

```lua
local GEOMacroConfig = {}

GEOMacroConfig.default = {book = 1, page = 1}

GEOMacroConfig.solo = {
    
}

return GEOMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## 🔧 Customization Examples

### Change lockstyle

```lua
-- Modify GEO_LOCKSTYLE.lua
GEOLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify GEO_MACROBOOK.lua
GEOMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

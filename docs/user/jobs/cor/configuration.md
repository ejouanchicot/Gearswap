# COR - Configuration Files

**Location**: `Tetsouo/config/cor/`

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `COR_KEYBINDS.lua` | Keybind definitions |
| `COR_LOCKSTYLE.lua` | Lockstyle per subjob |
| `COR_MACROBOOK.lua` | Macrobook per subjob |
| `COR_STATES.lua` | State definitions |

---

## 🎨 Lockstyle Config

**File**: `Tetsouo/config/cor/COR_LOCKSTYLE.lua`

```lua
local CORLockstyleConfig = {}

CORLockstyleConfig.default = 3

CORLockstyleConfig.by_subjob = {
    ['DNC'] = 3,
    ['NIN'] = 3,
    ['WAR'] = 3,
    ['SAM'] = 3,
}

return CORLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## 📖 Macrobook Config

**File**: `Tetsouo/config/cor/COR_MACROBOOK.lua`

```lua
local CORMacroConfig = {}

CORMacroConfig.default = {book = 1, page = 1}

CORMacroConfig.solo = {
    
}

return CORMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## 🔧 Customization Examples

### Change lockstyle

```lua
-- Modify COR_LOCKSTYLE.lua
CORLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify COR_MACROBOOK.lua
CORMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

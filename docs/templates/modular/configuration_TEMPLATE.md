# [JOB] - Configuration Files

**Location**: `Tetsouo/config/[job]/`

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `[JOB]_KEYBINDS.lua` | Keybind definitions |
| `[JOB]_LOCKSTYLE.lua` | Lockstyle per subjob |
| `[JOB]_MACROBOOK.lua` | Macrobook per subjob |
| [ADDITIONAL_CONFIGS] | |

---

## ⌨️ Keybinds Config

**File**: `Tetsouo/config/[job]/[JOB]_KEYBINDS.lua`

```lua
local [JOB]Keybinds = {}

[JOB]Keybinds.keybinds = {
    [KEYBIND_SAMPLE]
}

return [JOB]Keybinds
```

---

## 🎨 Lockstyle Config

**File**: `Tetsouo/config/[job]/[JOB]_LOCKSTYLE.lua`

```lua
local [JOB]LockstyleConfig = {}

[JOB]LockstyleConfig.default = [DEFAULT_LOCKSTYLE]

[JOB]LockstyleConfig.by_subjob = {
    [LOCKSTYLE_SUBJOBS]
}

return [JOB]LockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob. If no specific lockstyle is defined, it uses the default.

---

## 📖 Macrobook Config

**File**: `Tetsouo/config/[job]/[JOB]_MACROBOOK.lua`

```lua
local [JOB]MacroConfig = {}

[JOB]MacroConfig.default = {book = [DEFAULT_BOOK], page = [DEFAULT_PAGE]}

[JOB]MacroConfig.macrobooks = {
    [MACROBOOK_SUBJOBS]
}

return [JOB]MacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## 🔧 Customization Examples

### Add a keybind

```lua
-- Add to [JOB]_KEYBINDS.lua
{key = "!9", command = "cycle YourState", desc = "Your State", state = "YourState"}
```

### Change lockstyle

```lua
-- Modify [JOB]_LOCKSTYLE.lua
[JOB]LockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed from 1 to 5
    -- ...
}
```

### Modify macrobook

```lua
-- Modify [JOB]_MACROBOOK.lua
[JOB]MacroConfig.macrobooks = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
    -- ...
}
```

# BST - Configuration Files

**Location**: `Tetsouo/config/bst/`

---

## Configuration Files

| File | Purpose |
|------|---------|
| `BST_KEYBINDS.lua` | Keybind definitions |
| `BST_LOCKSTYLE.lua` | Lockstyle per subjob |
| `BST_MACROBOOK.lua` | Macrobook per subjob |
| `BST_STATES.lua` | State definitions |

---

## Lockstyle Config

**File**: `Tetsouo/config/bst/BST_LOCKSTYLE.lua`

```lua
local BSTLockstyleConfig = {}

BSTLockstyleConfig.default = 6

BSTLockstyleConfig.by_subjob = {
    ['SAM'] = 6,
    ['NIN'] = 6,
    ['DNC'] = 6,
    ['WHM'] = 6,
    ['RDM'] = 6,
    ['PLD'] = 6,
    ['DRK'] = 6,
    ['BST'] = 6,
    ['MNK'] = 6,
    ['WAR'] = 6,
    ['THF'] = 6,
    ['BRD'] = 6,
    ['COR'] = 6,
    ['PUP'] = 6,
    ['SCH'] = 6,
    ['GEO'] = 6,
    ['RUN'] = 6,
    ['SMN'] = 6,
    ['BLU'] = 6,
}

return BSTLockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## Macrobook Config

**File**: `Tetsouo/config/bst/BST_MACROBOOK.lua`

```lua
local BSTMacroConfig = {}

BSTMacroConfig.default = {book = 1, page = 1}

BSTMacroConfig.solo = {
    ['SAM'] = {book = 12, page = 1},
    ['NIN'] = {book = 12, page = 1},
    ['DNC'] = {book = 12, page = 1},
    ['WHM'] = {book = 12, page = 1},
    ['RDM'] = {book = 12, page = 1},
    ['BLU'] = {book = 12, page = 1},
}

return BSTMacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## Customization Examples

### Change lockstyle

```lua
-- Modify BST_LOCKSTYLE.lua
BSTLockstyleConfig.by_subjob = {
    ['SAM'] = 5,  -- Changed to lockstyle #5
}
```

### Modify macrobook

```lua
-- Modify BST_MACROBOOK.lua
BSTMacroConfig.solo = {
    ['SAM'] = {book = 2, page = 3},  -- Changed book/page
}
```

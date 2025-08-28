# GearSwap Configuration Guide

## 📝 Essential Configuration

**Principle**: Only one file `Tetsouo/config/settings.lua` to modify, then `//gs reload`.

### Characters

```lua
settings.players = {
    main = 'Tetsouo',     -- Your main character
    alt_enabled = true,   -- true = dual-box, false = solo only
    alt = 'Kaories',      -- Your alt character
}
```

### Lockstyles

```lua
settings.macros.lockstyles = {
    THF = 1, -- 🗡️ Thief
    DNC = 2, -- 💃 Dancer  
    PLD = 3, -- 🛡️ Paladin
    WAR = 4, -- ⚔️ Warrior
    BLM = 5, -- 🔮 Black Mage
    BST = 6, -- 🐺 Beast Master
    BRD = 7, -- 🎵 Bard
}
```

### Dual-Boxing Macros

```lua
settings.macros.dual_box = {
    THF = {
        WAR = {                           -- THF/WAR subjob
            RDM = { book = 1, page = 1 }, -- + Alt RDM
            GEO = { book = 2, page = 1 }, -- + Alt GEO
            COR = { book = 3, page = 1 }, -- + Alt COR
        },
        DNC = {                           -- THF/DNC subjob
            RDM = { book = 1, page = 1 },
            GEO = { book = 2, page = 1 },
            COR = { book = 3, page = 1 },
        }
    },
    BLM = {
        SCH = {                           -- BLM/SCH subjob
            RDM = { book = 7, page = 1 },
            GEO = { book = 8, page = 1 },
            COR = { book = 9, page = 1 },
        }
    }
    -- ... More jobs in the complete file
}
```

### Solo Macros

```lua
settings.macros.solo = {
    THF = {
        WAR = { book = 1, page = 1 }, -- THF/WAR solo
        DNC = { book = 1, page = 1 }, -- THF/DNC solo
        NIN = { book = 1, page = 1 }, -- THF/NIN solo
    },
    BLM = {
        RDM = { book = 10, page = 1 }, -- BLM/RDM solo
        SCH = { book = 7, page = 1 },  -- BLM/SCH solo
    }
    -- ... More jobs in the complete file
}
```

## 🎨 Advanced Customization

### Interface and Colors

```lua
settings.ui = {
    colors = {
        error = 167,   -- 🔴 Red - Errors
        warning = 057, -- 🟠 Orange - Warnings  
        info = 050,    -- 🟡 Yellow - Information
        debug = 160,   -- ⚫ Gray - Debug
        success = 158, -- 🟢 Green - Success
    },
    messages = {
        show_timestamps = false,
        show_separators = true,
    }
}
```

### Debug and Diagnostics

```lua
settings.debug = {
    enabled = false,       -- Debug mode
    level = 'INFO',        -- ERROR/WARN/INFO/DEBUG
    show_swaps = true,     -- Show equipment changes
    show_cooldowns = true, -- Show spell cooldowns
}
```

### Movement and Combat

```lua
settings.movement = {
    threshold = 1.0,        -- Movement detection threshold
    check_interval = 15,    -- Check frequency
    engaged_moving = false, -- Movement equipment in combat
}

settings.combat = {
    auto_cancel = {
        retaliation_on_move = true, -- Cancel Retaliation on movement
        cancel_conflicts = true,    -- Cancel conflicting buffs
    },
    weaponskill = {
        auto_adjust_ears = true,    -- Adjust earrings according to TP
        moonshade_threshold = 1750, -- TP threshold for Moonshade
        range_check = true,         -- Check WS range
    }
}
```

### Job-Specific Configuration

```lua
settings.jobs = {
    THF = {
        default_th_mode = 'Tag',           -- Default TH mode
        maintain_sa_ta_idle = true,        -- Keep SA/TA equipment when idle
        auto_sa_ta_combat = true,          -- Auto SA/TA in combat
        prefer_specialized_th_sets = true, -- Specialized TH sets
    },
    BLM = {
        default_mode = 'MagicBurst',       -- Default mode
        auto_buffs = { 'Stoneskin', 'Blink', 'Aquaveil', 'Ice Spikes' },
        save_mp_threshold = 100,           -- MP conservation threshold
    },
    WAR = {
        default_weapon = 'Chango',         -- Default weapon
        auto_restraint = true,             -- Auto restraint
        auto_cancel_retaliation = true,    -- Cancel Retaliation on movement
    },
    BST = {
        default_jug = 'Dire Broth',       -- Default jug pet
        auto_reward_hp = 50,               -- Auto Reward HP threshold
    }
}
```

### Automation

```lua
settings.automation = {
    buffs = {
        refresh_threshold = 30, -- Min time before refresh (sec)
        cast_delay = 2,         -- Delay between spells (sec)
    },
    spells = {
        auto_downgrade = true,  -- Auto downgrade if higher tier on CD
        cancel_on_no_mp = true, -- Cancel if not enough MP
    }
}
```

## 🛠️ Troubleshooting

- **Macros don't change** → Check name spelling + `//gs c status`  
- **Alt not detected** → `alt_enabled = true` + exact spelling
- **Syntax errors** → Commas, brackets in settings.lua
- **Temporary debug** → `settings.debug.enabled = true` + `//gs reload`

The settings.lua file contains **all** the centralized system configuration.
